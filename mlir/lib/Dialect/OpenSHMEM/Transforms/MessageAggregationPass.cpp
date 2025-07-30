//===- MessageAggregationPass.cpp - OpenSHMEM message aggregation --------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements a comprehensive message aggregation pass for OpenSHMEM
// operations that analyzes and optimizes communication patterns.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEM.h"
#include "mlir/Dialect/OpenSHMEM/Transforms/Passes.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/Support/Debug.h"

using namespace mlir;
using namespace mlir::openshmem;

#define GEN_PASS_DEF_MESSAGEAGGREGATION
#include "mlir/Dialect/OpenSHMEM/Transforms/Passes.h.inc"

namespace {

//===----------------------------------------------------------------------===//
// Data Structures
//===----------------------------------------------------------------------===//

/// Represents a memory access operation that can be optimized
struct MemoryAccess {
  Operation *op;                           // The operation itself
  Value destMemRef;                        // Destination memory reference
  Value srcMemRef;                         // Source memory reference
  Value size;                              // Transfer size
  Value pe;                                // Target PE
  bool isNonBlocking;                      // Whether operation is non-blocking
  enum OpType { PUT = 0, GET = 1 } opType; // Operation type

  MemoryAccess(Operation *op, Value dest, Value src, Value sz, Value targetPE,
               bool nonBlocking, OpType type)
      : op(op), destMemRef(dest), srcMemRef(src), size(sz), pe(targetPE),
        isNonBlocking(nonBlocking), opType(type) {}
};

/// Groups operations that can potentially be coalesced together
struct CoalescingGroup {
  SmallVector<Operation *, 4> operations;
  Value pe;
  bool isNonBlocking;
  MemoryAccess::OpType opType;

  CoalescingGroup() = default;
};

/// Memory access analyzer that identifies coalescable patterns
class MemoryAccessAnalyzer {
public:
  MemoryAccessAnalyzer(unsigned minMsgSize, unsigned maxDistance, bool debug)
      : minMessageSize(minMsgSize), maxCoalescingDistance(maxDistance),
        debugMode(debug) {}

  /// Analyze a block and extract memory access patterns
  void analyzeBlock(Block &block) {
    memoryAccesses.clear();

    for (Operation &op : block) {
      if (auto memAccess = extractMemoryAccess(&op)) {
        memoryAccesses.push_back(*memAccess);
      }
    }
  }

  /// Get the collected memory accesses
  const SmallVector<MemoryAccess, 8> &getMemoryAccesses() const {
    return memoryAccesses;
  }

private:
  /// Extract memory access information from OpenSHMEM operations
  std::optional<MemoryAccess> extractMemoryAccess(Operation *op) {
    // Handle putmem operations (blocking)
    if (auto putmemOp = dyn_cast<PutmemOp>(op)) {
      return MemoryAccess(op, putmemOp.getDest(), putmemOp.getSrc(),
                          putmemOp.getSize(), putmemOp.getPe(), false,
                          MemoryAccess::PUT);
    }

    // Handle getmem operations (blocking)
    if (auto getmemOp = dyn_cast<GetmemOp>(op)) {
      return MemoryAccess(op, getmemOp.getDest(), getmemOp.getSrc(),
                          getmemOp.getSize(), getmemOp.getPe(), false,
                          MemoryAccess::GET);
    }

    // Handle putmem_nbi operations (non-blocking)
    if (auto putmemNbiOp = dyn_cast<PutmemNbiOp>(op)) {
      return MemoryAccess(op, putmemNbiOp.getDest(), putmemNbiOp.getSrc(),
                          putmemNbiOp.getNelems(), putmemNbiOp.getPe(), true,
                          MemoryAccess::PUT);
    }

    // Handle getmem_nbi operations (non-blocking)
    if (auto getmemNbiOp = dyn_cast<GetmemNbiOp>(op)) {
      return MemoryAccess(op, getmemNbiOp.getDest(), getmemNbiOp.getSrc(),
                          getmemNbiOp.getNelems(), getmemNbiOp.getPe(), true,
                          MemoryAccess::GET);
    }

    // Handle typed put operations (blocking)
    if (auto putOp = dyn_cast<PutOp>(op)) {
      return MemoryAccess(op, putOp.getDest(), putOp.getSource(),
                          putOp.getNelems(), putOp.getPe(), false,
                          MemoryAccess::PUT);
    }

    // Handle typed get operations (blocking)
    if (auto getOp = dyn_cast<GetOp>(op)) {
      return MemoryAccess(op, getOp.getDest(), getOp.getSource(),
                          getOp.getNelems(), getOp.getPe(), false,
                          MemoryAccess::GET);
    }

    return std::nullopt;
  }

  unsigned minMessageSize;
  unsigned maxCoalescingDistance;
  bool debugMode;
  SmallVector<MemoryAccess, 8> memoryAccesses;
};

/// Communication pattern detector
class CommunicationPatternDetector {
public:
  CommunicationPatternDetector(const SmallVector<MemoryAccess, 8> &accesses,
                               bool debug)
      : memoryAccesses(accesses), debugMode(debug) {}

  /// Detect coalescable communication patterns
  SmallVector<std::unique_ptr<CoalescingGroup>, 4> detectPatterns() {
    SmallVector<std::unique_ptr<CoalescingGroup>, 4> groups;

    // Group operations by (PE, isNonBlocking, opType)
    // Using int instead of bool for DenseMapInfo compatibility
    llvm::DenseMap<std::tuple<mlir::Value, int, int>, CoalescingGroup *>
        groupMap;

    for (const auto &access : memoryAccesses) {
      // Group by PE, blocking behavior, and operation type
      auto key =
          std::make_tuple(access.pe, static_cast<int>(access.isNonBlocking),
                          static_cast<int>(access.opType));

      auto it = groupMap.find(key);
      if (it == groupMap.end()) {
        auto group = std::make_unique<CoalescingGroup>();
        group->pe = access.pe;
        group->isNonBlocking = access.isNonBlocking;
        group->opType = access.opType;
        group->operations.push_back(access.op);
        groupMap[key] = group.get();
        groups.push_back(std::move(group));
      } else {
        it->second->operations.push_back(access.op);
      }
    }

    // Filter groups that have potential for coalescing
    SmallVector<std::unique_ptr<CoalescingGroup>, 4> coalescableGroups;
    for (auto &group : groups) {
      if (group->operations.size() >= 2) {
        if (debugMode) {
          llvm::dbgs() << "Found coalescable group with "
                       << group->operations.size()
                       << " operations targeting same PE\n";
        }
        coalescableGroups.push_back(std::move(group));
      }
    }

    return coalescableGroups;
  }

  /// Check if two operations can be safely coalesced
  bool canCoalesceOperations(const MemoryAccess &a, const MemoryAccess &b) {
    // Must target the same PE
    if (a.pe != b.pe)
      return false;

    // Must have same operation type (PUT vs GET)
    if (a.opType != b.opType)
      return false;

    // Must have same blocking behavior
    if (a.isNonBlocking != b.isNonBlocking)
      return false;

    // NEW: Must use the same source and destination memory regions
    // Real message aggregation would require more sophisticated memory layout
    // analysis
    if (a.srcMemRef != b.srcMemRef || a.destMemRef != b.destMemRef)
      return false;

    return true;
  }

private:
  const SmallVector<MemoryAccess, 8> &memoryAccesses;
  bool debugMode;
};

/// Transformation engine that applies coalescing optimizations
class TransformationEngine {
public:
  TransformationEngine(PatternRewriter &rewriter, bool debug,
                       const SmallVector<MemoryAccess, 8> &accesses)
      : rewriter(rewriter), debugMode(debug), memoryAccesses(accesses) {}

  /// Check if a group can be coalesced
  bool canCoalesceGroup(const CoalescingGroup &group) {
    if (group.operations.size() < 2)
      return false;

    // Build a map from operations to their memory access info
    DenseMap<Operation *, const MemoryAccess *> opToAccess;
    for (const auto &access : memoryAccesses) {
      opToAccess[access.op] = &access;
    }

    // Basic safety checks
    for (size_t i = 0; i < group.operations.size(); ++i) {
      for (size_t j = i + 1; j < group.operations.size(); ++j) {
        auto *accessI = opToAccess.lookup(group.operations[i]);
        auto *accessJ = opToAccess.lookup(group.operations[j]);
        if (!accessI || !accessJ) {
          return false;
        }

        CommunicationPatternDetector detector(memoryAccesses, debugMode);
        if (!detector.canCoalesceOperations(*accessI, *accessJ)) {
          return false;
        }
      }
    }

    return true;
  }

  /// Apply coalescing transformation to a group of operations
  LogicalResult coalesceGroup(const CoalescingGroup &group) {
    if (group.operations.size() < 2)
      return failure();

    if (debugMode) {
      llvm::dbgs() << "Coalescing group of " << group.operations.size()
                   << " operations\n";
    }

    // For now, implement a simple optimization that's safe:
    // Only coalesce identical operations (same operands, same result)
    // In a real implementation, this would be much more sophisticated

    // Check if all operations are truly identical
    Operation *firstOp = group.operations[0];
    for (size_t i = 1; i < group.operations.size(); ++i) {
      Operation *op = group.operations[i];

      // Check if operations have same number of operands and results
      if (firstOp->getNumOperands() != op->getNumOperands() ||
          firstOp->getNumResults() != op->getNumResults()) {
        if (debugMode) {
          llvm::dbgs()
              << "Cannot coalesce: operations have different signatures\n";
        }
        return failure();
      }

      // Check if all operands are identical
      for (unsigned j = 0; j < firstOp->getNumOperands(); ++j) {
        if (firstOp->getOperand(j) != op->getOperand(j)) {
          if (debugMode) {
            llvm::dbgs()
                << "Cannot coalesce: operations have different operands\n";
          }
          return failure();
        }
      }
    }

    // If we reach here, all operations are identical
    // We can safely remove the duplicates and keep only the first one
    if (debugMode) {
      llvm::dbgs() << "Removing " << (group.operations.size() - 1)
                   << " duplicate operations\n";
    }

    // Remove all operations except the first one
    for (size_t i = 1; i < group.operations.size(); ++i) {
      rewriter.eraseOp(group.operations[i]);
    }

    return success();
  }

private:
  /// Calculate total transfer size for a group of operations
  Value calculateTotalSize(const CoalescingGroup &group) {
    if (group.operations.empty())
      return nullptr;

    // Build a map from operations to their memory access info
    DenseMap<Operation *, const MemoryAccess *> opToAccess;
    for (const auto &access : memoryAccesses) {
      opToAccess[access.op] = &access;
    }

    Location loc = group.operations[0]->getLoc();
    auto *firstAccess = opToAccess.lookup(group.operations[0]);
    if (!firstAccess)
      return nullptr;

    Value totalSize = firstAccess->size;

    for (size_t i = 1; i < group.operations.size(); ++i) {
      auto *access = opToAccess.lookup(group.operations[i]);
      if (!access)
        return nullptr;
      totalSize = rewriter.create<arith::AddIOp>(loc, totalSize, access->size);
    }

    return totalSize;
  }

  Operation *createCoalescedOperation(const CoalescingGroup &group,
                                      Value totalSize) {
    if (group.operations.empty())
      return nullptr;

    // Build a map from operations to their memory access info
    DenseMap<Operation *, const MemoryAccess *> opToAccess;
    for (const auto &access : memoryAccesses) {
      opToAccess[access.op] = &access;
    }

    auto *firstAccess = opToAccess.lookup(group.operations[0]);
    if (!firstAccess)
      return nullptr;

    Location loc = firstAccess->op->getLoc();

    // TODO: This is a simplified transformation. In a real implementation,
    // we would need to:
    // 1. Verify memory regions are contiguous or calculate stride patterns
    // 2. Handle different source/destination layouts
    // 3. Ensure proper memory alignment
    // 4. Consider context boundaries and synchronization requirements

    if (group.isNonBlocking) {
      if (group.opType == MemoryAccess::PUT) {
        return rewriter.create<PutmemNbiOp>(loc, firstAccess->destMemRef,
                                            firstAccess->srcMemRef, totalSize,
                                            firstAccess->pe);
      } else {
        return rewriter.create<GetmemNbiOp>(loc, firstAccess->destMemRef,
                                            firstAccess->srcMemRef, totalSize,
                                            firstAccess->pe);
      }
    } else {
      if (group.opType == MemoryAccess::PUT) {
        return rewriter.create<PutmemOp>(loc, firstAccess->destMemRef,
                                         firstAccess->srcMemRef, totalSize,
                                         firstAccess->pe);
      } else {
        return rewriter.create<GetmemOp>(loc, firstAccess->destMemRef,
                                         firstAccess->srcMemRef, totalSize,
                                         firstAccess->pe);
      }
    }
  }

  PatternRewriter &rewriter;
  bool debugMode;
  const SmallVector<MemoryAccess, 8> &memoryAccesses;
};

} // namespace

namespace mlir {
namespace openshmem {

//===----------------------------------------------------------------------===//
// Pattern Implementation
//===----------------------------------------------------------------------===//

/// Pattern that applies message aggregation optimizations
struct MessageAggregationPattern : public OpRewritePattern<func::FuncOp> {
  MessageAggregationPattern(MLIRContext *context, unsigned minMsgSize,
                            unsigned maxDistance, bool enablePut,
                            bool enableGet, bool debug)
      : OpRewritePattern<func::FuncOp>(context), minMessageSize(minMsgSize),
        maxCoalescingDistance(maxDistance), enablePutCoalescing(enablePut),
        enableGetCoalescing(enableGet), debugMode(debug) {}

  LogicalResult matchAndRewrite(func::FuncOp func,
                                PatternRewriter &rewriter) const override {
    bool madeChanges = false;

    // Apply message aggregation to all blocks in the function
    func.walk([&](Block *block) {
      MemoryAccessAnalyzer analyzer(minMessageSize, maxCoalescingDistance,
                                    debugMode);
      analyzer.analyzeBlock(*block);

      CommunicationPatternDetector detector(analyzer.getMemoryAccesses(),
                                            debugMode);
      auto groups = detector.detectPatterns();

      TransformationEngine engine(rewriter, debugMode,
                                  analyzer.getMemoryAccesses());

      for (const auto &group : groups) {
        // Skip groups based on configuration
        if (group->opType == MemoryAccess::PUT && !enablePutCoalescing)
          continue;
        if (group->opType == MemoryAccess::GET && !enableGetCoalescing)
          continue;

        if (engine.canCoalesceGroup(*group)) {
          if (engine.coalesceGroup(*group).succeeded()) {
            madeChanges = true;
          }
        }
      }
    });

    return madeChanges ? success() : failure();
  }

private:
  unsigned minMessageSize;
  unsigned maxCoalescingDistance;
  bool enablePutCoalescing;
  bool enableGetCoalescing;
  bool debugMode;
};

//===----------------------------------------------------------------------===//
// Pass Implementation
//===----------------------------------------------------------------------===//

struct MessageAggregationPass
    : public ::impl::MessageAggregationBase<MessageAggregationPass> {
  using ::impl::MessageAggregationBase<
      MessageAggregationPass>::MessageAggregationBase;

  void runOnOperation() override {
    Operation *op = getOperation();
    MLIRContext *context = &getContext();

    if (debugMode) {
      llvm::outs() << "MessageAggregation pass running with options:\n";
      llvm::outs() << "  enablePutCoalescing: " << enablePutCoalescing << "\n";
      llvm::outs() << "  enableGetCoalescing: " << enableGetCoalescing << "\n";
      llvm::outs() << "  enableCrossOpOptimization: "
                   << enableCrossOpOptimization << "\n";
      llvm::outs() << "  maxCoalescingDistance: " << maxCoalescingDistance
                   << "\n";
      llvm::outs() << "  minMessageSize: " << minMessageSize << "\n";
    }

    // Early exit if all optimizations are disabled
    if (!enablePutCoalescing && !enableGetCoalescing &&
        !enableCrossOpOptimization) {
      return;
    }

    // Apply message aggregation patterns
    RewritePatternSet patterns(context);
    patterns.add<MessageAggregationPattern>(
        context, minMessageSize, maxCoalescingDistance, enablePutCoalescing,
        enableGetCoalescing, debugMode);

    if (failed(applyPatternsGreedily(op, std::move(patterns)))) {
      signalPassFailure();
    }
  }
};

//===----------------------------------------------------------------------===//
// Pass Registration
//===----------------------------------------------------------------------===//

std::unique_ptr<Pass> createMessageAggregationPass() {
  return std::make_unique<MessageAggregationPass>();
}

} // namespace openshmem
} // namespace mlir
