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
  Operation *op;      // The operation itself
  Value destMemRef;   // Destination memory reference
  Value srcMemRef;    // Source memory reference
  Value size;         // Transfer size
  Value pe;           // Target PE
  Value ctx;          // Context (if context-aware operation)
  bool isNonBlocking; // Whether operation is non-blocking
  bool hasContext;    // Whether operation uses context
  enum OpType { PUT = 0, GET = 1 } opType; // Operation type
  enum OpVariant {
    GENERIC = 0, // put, get
    TYPED = 1,   // put<type>, get<type>
    SIZED = 2,   // put8/16/32/64/128
    MEMORY = 3,  // putmem, getmem
    POINT = 4    // p, g (single element)
  } opVariant;
  unsigned elementSize; // Size in bytes for sized operations
  Type elementType;     // Element type for typed operations

  MemoryAccess(Operation *op, Value dest, Value src, Value sz, Value targetPE,
               bool nonBlocking, OpType type, OpVariant variant = GENERIC,
               Value context = nullptr, unsigned elemSize = 0,
               Type elemType = nullptr)
      : op(op), destMemRef(dest), srcMemRef(src), size(sz), pe(targetPE),
        ctx(context), isNonBlocking(nonBlocking),
        hasContext(context != nullptr), opType(type), opVariant(variant),
        elementSize(elemSize), elementType(elemType) {}
};

/// Groups operations that can potentially be coalesced together
struct CoalescingGroup {
  SmallVector<Operation *, 4> operations;
  Value pe;
  Value ctx; // Context (null if no context)
  bool isNonBlocking;
  bool hasContext;
  MemoryAccess::OpType opType;
  MemoryAccess::OpVariant opVariant;

  CoalescingGroup() = default;
};

/// Memory layout analyzer for detecting contiguous and strided patterns
class MemoryLayoutAnalyzer {
public:
  /// Represents a memory region with base address and offset
  struct MemoryRegion {
    Value baseAddr;
    int64_t offset;
    int64_t size;

    MemoryRegion(Value base, int64_t off = 0, int64_t sz = 0)
        : baseAddr(base), offset(off), size(sz) {}
  };

  /// Check if two memory accesses are contiguous
  bool areContiguous(const MemoryAccess &a, const MemoryAccess &b) const {
    // For now, implement basic contiguity check
    // TODO: Add more sophisticated memory layout analysis
    if (a.destMemRef != b.destMemRef || a.srcMemRef != b.srcMemRef)
      return false;

    // Check if sizes are constant and can be analyzed
    auto aSize = getConstantSize(a.size);
    auto bSize = getConstantSize(b.size);

    return aSize && bSize && *aSize > 0 && *bSize > 0;
  }

  /// Extract memory region information from a memory access
  std::optional<MemoryRegion>
  getMemoryRegion(const MemoryAccess &access) const {
    // Basic implementation - extract base address
    return MemoryRegion(access.destMemRef, 0,
                        getConstantSize(access.size).value_or(0));
  }

private:
  /// Extract constant size if available
  std::optional<int64_t> getConstantSize(Value size) const {
    if (auto constOp = size.getDefiningOp<arith::ConstantOp>()) {
      if (auto intAttr = llvm::dyn_cast<IntegerAttr>(constOp.getValue())) {
        return intAttr.getInt();
      }
    }
    return std::nullopt;
  }
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
                          MemoryAccess::PUT, MemoryAccess::MEMORY);
    }

    // Handle getmem operations (blocking)
    if (auto getmemOp = dyn_cast<GetmemOp>(op)) {
      return MemoryAccess(op, getmemOp.getDest(), getmemOp.getSrc(),
                          getmemOp.getSize(), getmemOp.getPe(), false,
                          MemoryAccess::GET, MemoryAccess::MEMORY);
    }

    // Handle putmem_nbi operations (non-blocking)
    if (auto putmemNbiOp = dyn_cast<PutmemNbiOp>(op)) {
      return MemoryAccess(op, putmemNbiOp.getDest(), putmemNbiOp.getSrc(),
                          putmemNbiOp.getNelems(), putmemNbiOp.getPe(), true,
                          MemoryAccess::PUT, MemoryAccess::MEMORY);
    }

    // Handle getmem_nbi operations (non-blocking)
    if (auto getmemNbiOp = dyn_cast<GetmemNbiOp>(op)) {
      return MemoryAccess(op, getmemNbiOp.getDest(), getmemNbiOp.getSrc(),
                          getmemNbiOp.getNelems(), getmemNbiOp.getPe(), true,
                          MemoryAccess::GET, MemoryAccess::MEMORY);
    }

    // Handle typed put operations (blocking)
    if (auto putOp = dyn_cast<PutOp>(op)) {
      return MemoryAccess(op, putOp.getDest(), putOp.getSource(),
                          putOp.getNelems(), putOp.getPe(), false,
                          MemoryAccess::PUT, MemoryAccess::TYPED);
    }

    // Handle typed get operations (blocking)
    if (auto getOp = dyn_cast<GetOp>(op)) {
      return MemoryAccess(op, getOp.getDest(), getOp.getSource(),
                          getOp.getNelems(), getOp.getPe(), false,
                          MemoryAccess::GET, MemoryAccess::TYPED);
    }

    // Handle typed put_nbi operations (non-blocking)
    if (auto putNbiOp = dyn_cast<PutNbiOp>(op)) {
      return MemoryAccess(op, putNbiOp.getDest(), putNbiOp.getSource(),
                          putNbiOp.getNelems(), putNbiOp.getPe(), true,
                          MemoryAccess::PUT, MemoryAccess::TYPED);
    }

    // Handle typed get_nbi operations (non-blocking)
    if (auto getNbiOp = dyn_cast<GetNbiOp>(op)) {
      return MemoryAccess(op, getNbiOp.getDest(), getNbiOp.getSource(),
                          getNbiOp.getNelems(), getNbiOp.getPe(), true,
                          MemoryAccess::GET, MemoryAccess::TYPED);
    }

    // Handle context-aware put operations
    if (auto ctxPutOp = dyn_cast<CtxPutOp>(op)) {
      return MemoryAccess(op, ctxPutOp.getDest(), ctxPutOp.getSource(),
                          ctxPutOp.getNelems(), ctxPutOp.getPe(), false,
                          MemoryAccess::PUT, MemoryAccess::TYPED,
                          ctxPutOp.getCtx());
    }

    // Handle context-aware get operations
    if (auto ctxGetOp = dyn_cast<CtxGetOp>(op)) {
      return MemoryAccess(op, ctxGetOp.getDest(), ctxGetOp.getSource(),
                          ctxGetOp.getNelems(), ctxGetOp.getPe(), false,
                          MemoryAccess::GET, MemoryAccess::TYPED,
                          ctxGetOp.getCtx());
    }

    // Handle context-aware put_nbi operations
    if (auto ctxPutNbiOp = dyn_cast<CtxPutNbiOp>(op)) {
      return MemoryAccess(op, ctxPutNbiOp.getDest(), ctxPutNbiOp.getSource(),
                          ctxPutNbiOp.getNelems(), ctxPutNbiOp.getPe(), true,
                          MemoryAccess::PUT, MemoryAccess::TYPED,
                          ctxPutNbiOp.getCtx());
    }

    // Handle context-aware get_nbi operations
    if (auto ctxGetNbiOp = dyn_cast<CtxGetNbiOp>(op)) {
      return MemoryAccess(op, ctxGetNbiOp.getDest(), ctxGetNbiOp.getSource(),
                          ctxGetNbiOp.getNelems(), ctxGetNbiOp.getPe(), true,
                          MemoryAccess::GET, MemoryAccess::TYPED,
                          ctxGetNbiOp.getCtx());
    }

    // Handle sized put operations
    if (auto put8Op = dyn_cast<Put8Op>(op)) {
      return MemoryAccess(op, put8Op.getDest(), put8Op.getSource(),
                          put8Op.getNelems(), put8Op.getPe(), false,
                          MemoryAccess::PUT, MemoryAccess::SIZED, nullptr, 8);
    }
    if (auto put16Op = dyn_cast<Put16Op>(op)) {
      return MemoryAccess(op, put16Op.getDest(), put16Op.getSource(),
                          put16Op.getNelems(), put16Op.getPe(), false,
                          MemoryAccess::PUT, MemoryAccess::SIZED, nullptr, 16);
    }
    if (auto put32Op = dyn_cast<Put32Op>(op)) {
      return MemoryAccess(op, put32Op.getDest(), put32Op.getSource(),
                          put32Op.getNelems(), put32Op.getPe(), false,
                          MemoryAccess::PUT, MemoryAccess::SIZED, nullptr, 32);
    }
    if (auto put64Op = dyn_cast<Put64Op>(op)) {
      return MemoryAccess(op, put64Op.getDest(), put64Op.getSource(),
                          put64Op.getNelems(), put64Op.getPe(), false,
                          MemoryAccess::PUT, MemoryAccess::SIZED, nullptr, 64);
    }
    if (auto put128Op = dyn_cast<Put128Op>(op)) {
      return MemoryAccess(op, put128Op.getDest(), put128Op.getSource(),
                          put128Op.getNelems(), put128Op.getPe(), false,
                          MemoryAccess::PUT, MemoryAccess::SIZED, nullptr, 128);
    }

    // Handle sized get operations
    if (auto get8Op = dyn_cast<Get8Op>(op)) {
      return MemoryAccess(op, get8Op.getDest(), get8Op.getSource(),
                          get8Op.getNelems(), get8Op.getPe(), false,
                          MemoryAccess::GET, MemoryAccess::SIZED, nullptr, 8);
    }
    if (auto get16Op = dyn_cast<Get16Op>(op)) {
      return MemoryAccess(op, get16Op.getDest(), get16Op.getSource(),
                          get16Op.getNelems(), get16Op.getPe(), false,
                          MemoryAccess::GET, MemoryAccess::SIZED, nullptr, 16);
    }
    if (auto get32Op = dyn_cast<Get32Op>(op)) {
      return MemoryAccess(op, get32Op.getDest(), get32Op.getSource(),
                          get32Op.getNelems(), get32Op.getPe(), false,
                          MemoryAccess::GET, MemoryAccess::SIZED, nullptr, 32);
    }
    if (auto get64Op = dyn_cast<Get64Op>(op)) {
      return MemoryAccess(op, get64Op.getDest(), get64Op.getSource(),
                          get64Op.getNelems(), get64Op.getPe(), false,
                          MemoryAccess::GET, MemoryAccess::SIZED, nullptr, 64);
    }
    if (auto get128Op = dyn_cast<Get128Op>(op)) {
      return MemoryAccess(op, get128Op.getDest(), get128Op.getSource(),
                          get128Op.getNelems(), get128Op.getPe(), false,
                          MemoryAccess::GET, MemoryAccess::SIZED, nullptr, 128);
    }

    // Handle point-to-point operations
    if (auto pOp = dyn_cast<POp>(op)) {
      // For point operations, create a constant size of 1
      OpBuilder builder(op);
      auto indexType = IndexType::get(op->getContext());
      auto oneAttr = IntegerAttr::get(indexType, 1);
      Value sizeOne = builder.create<arith::ConstantOp>(op->getLoc(), oneAttr);

      return MemoryAccess(op, pOp.getDest(), pOp.getValue(), sizeOne,
                          pOp.getPe(), false, MemoryAccess::PUT,
                          MemoryAccess::POINT);
    }

    if (auto gOp = dyn_cast<GOp>(op)) {
      // For get point operations, create a constant size of 1
      OpBuilder builder(op);
      auto indexType = IndexType::get(op->getContext());
      auto oneAttr = IntegerAttr::get(indexType, 1);
      Value sizeOne = builder.create<arith::ConstantOp>(op->getLoc(), oneAttr);

      // For g operations, source and dest are swapped compared to normal
      // pattern
      return MemoryAccess(op, gOp.getSource(), gOp.getSource(), sizeOne,
                          gOp.getPe(), false, MemoryAccess::GET,
                          MemoryAccess::POINT);
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

    // Group operations by (PE, context, isNonBlocking, opType, opVariant,
    // elementSize) Using int instead of bool for DenseMapInfo compatibility
    llvm::DenseMap<
        std::tuple<mlir::Value, mlir::Value, int, int, int, unsigned>,
        CoalescingGroup *>
        groupMap;

    for (const auto &access : memoryAccesses) {
      // Group by PE, context, blocking behavior, operation type, variant, and
      // element size For sized operations, element size must also match
      unsigned elementSizeKey =
          (access.opVariant == MemoryAccess::SIZED) ? access.elementSize : 0;
      auto key = std::make_tuple(
          access.pe, access.ctx, static_cast<int>(access.isNonBlocking),
          static_cast<int>(access.opType), static_cast<int>(access.opVariant),
          elementSizeKey);

      auto it = groupMap.find(key);
      if (it == groupMap.end()) {
        auto group = std::make_unique<CoalescingGroup>();
        group->pe = access.pe;
        group->ctx = access.ctx;
        group->isNonBlocking = access.isNonBlocking;
        group->hasContext = access.hasContext;
        group->opType = access.opType;
        group->opVariant = access.opVariant;
        group->operations.push_back(access.op);
        groupMap[key] = group.get();
        groups.push_back(std::move(group));
      } else {
        it->second->operations.push_back(access.op);
      }
    }

    // Also detect cross-operation optimization opportunities
    // TODO: Re-enable after fixing cross-operation pattern detection
    // detectCrossOperationPatterns(groups);

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

  /// Detect cross-operation optimization patterns (e.g., put32 + put32 ->
  /// put64)
  void detectCrossOperationPatterns(
      SmallVector<std::unique_ptr<CoalescingGroup>, 4> &groups) {
    MemoryLayoutAnalyzer layoutAnalyzer;

    // Look for opportunities to combine smaller operations into larger ones
    for (const auto &access1 : memoryAccesses) {
      for (const auto &access2 : memoryAccesses) {
        if (access1.op >= access2.op)
          continue; // Avoid duplicates

        // Check if operations can be combined into a larger operation
        if (canCombineOperations(access1, access2, layoutAnalyzer)) {
          if (debugMode) {
            llvm::dbgs() << "Found cross-operation optimization opportunity\n";
          }
          // Create a special group for cross-operation optimization
          auto group = std::make_unique<CoalescingGroup>();
          group->pe = access1.pe;
          group->ctx = access1.ctx;
          group->isNonBlocking = access1.isNonBlocking;
          group->hasContext = access1.hasContext;
          group->opType = access1.opType;
          group->opVariant =
              MemoryAccess::SIZED; // Result will be a sized operation
          group->operations.push_back(access1.op);
          group->operations.push_back(access2.op);
          groups.push_back(std::move(group));
        }
      }
    }
  }

  /// Check if two operations can be combined into a larger operation
  bool canCombineOperations(const MemoryAccess &a, const MemoryAccess &b,
                            const MemoryLayoutAnalyzer &layoutAnalyzer) {
    // Must target same PE and have same blocking behavior
    if (a.pe != b.pe || a.isNonBlocking != b.isNonBlocking)
      return false;

    // Must have same operation type
    if (a.opType != b.opType)
      return false;

    // Must have same context behavior
    if (a.hasContext != b.hasContext || a.ctx != b.ctx)
      return false;

    // Check if both are sized operations that can be combined
    if (a.opVariant == MemoryAccess::SIZED &&
        b.opVariant == MemoryAccess::SIZED) {
      // For now, only combine operations of the same size
      // In future: put32 + put32 -> put64 (if memory layout allows)
      if (a.elementSize == b.elementSize &&
          layoutAnalyzer.areContiguous(a, b)) {
        return true;
      }
    }

    return false;
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

    // Must have same context behavior
    if (a.hasContext != b.hasContext)
      return false;

    // If both have contexts, they must be the same context
    if (a.hasContext && a.ctx != b.ctx)
      return false;

    // Must have compatible operation variants
    if (!areCompatibleVariants(a.opVariant, b.opVariant))
      return false;

    // Memory region compatibility check
    MemoryLayoutAnalyzer layoutAnalyzer;
    if (!layoutAnalyzer.areContiguous(a, b)) {
      // For non-contiguous accesses, require identical memory regions for
      // safety
      if (a.srcMemRef != b.srcMemRef || a.destMemRef != b.destMemRef)
        return false;
    }

    return true;
  }

private:
  /// Check if two operation variants are compatible for coalescing
  bool areCompatibleVariants(MemoryAccess::OpVariant a,
                             MemoryAccess::OpVariant b) {
    // Identical variants are always compatible
    if (a == b)
      return true;

    // MEMORY operations can coalesce with each other
    if (a == MemoryAccess::MEMORY && b == MemoryAccess::MEMORY)
      return true;

    // TYPED operations can coalesce with each other
    if (a == MemoryAccess::TYPED && b == MemoryAccess::TYPED)
      return true;

    // SIZED operations can coalesce with each other
    if (a == MemoryAccess::SIZED && b == MemoryAccess::SIZED)
      return true;

    // POINT operations can coalesce with each other (rarely useful but safe)
    if (a == MemoryAccess::POINT && b == MemoryAccess::POINT)
      return true;

    // Cross-variant coalescing requires more sophisticated analysis
    // For now, be conservative
    return false;
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

    // Strategy 1: Remove identical operations (safest implementation)
    if (areAllOperationsIdentical(group)) {
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

    // Strategy 2: Try to create a single coalesced operation if possible
    // TODO: Re-enable after fixing memory layout analysis
    // if (canCreateCoalescedOperation(group)) {
    //   return createAndReplaceWithCoalescedOperation(group);
    // }

    // Strategy 3: Optimize non-blocking operations by batching
    if (group.isNonBlocking && canBatchNonBlockingOperations(group)) {
      return batchNonBlockingOperations(group);
    }

    if (debugMode) {
      llvm::dbgs() << "Cannot coalesce group - no suitable strategy found\n";
    }
    return failure();
  }

private:
  /// Check if all operations in a group are identical
  bool areAllOperationsIdentical(const CoalescingGroup &group) {
    if (group.operations.empty())
      return false;

    Operation *firstOp = group.operations[0];
    for (size_t i = 1; i < group.operations.size(); ++i) {
      Operation *op = group.operations[i];

      // Check if operations have same number of operands and results
      if (firstOp->getNumOperands() != op->getNumOperands() ||
          firstOp->getNumResults() != op->getNumResults()) {
        return false;
      }

      // Check if all operands are identical
      for (unsigned j = 0; j < firstOp->getNumOperands(); ++j) {
        if (firstOp->getOperand(j) != op->getOperand(j)) {
          return false;
        }
      }
    }
    return true;
  }

  /// Check if a group can be transformed into a single coalesced operation
  bool canCreateCoalescedOperation(const CoalescingGroup &group) {
    // Build a map from operations to their memory access info
    DenseMap<Operation *, const MemoryAccess *> opToAccess;
    for (const auto &access : memoryAccesses) {
      opToAccess[access.op] = &access;
    }

    // Check if all operations access contiguous memory regions
    for (size_t i = 0; i < group.operations.size(); ++i) {
      for (size_t j = i + 1; j < group.operations.size(); ++j) {
        auto *accessI = opToAccess.lookup(group.operations[i]);
        auto *accessJ = opToAccess.lookup(group.operations[j]);
        if (!accessI || !accessJ) {
          return false;
        }

        // For simple coalescing, require same memory regions for now
        // TODO: Implement proper contiguous memory analysis using
        // MemoryLayoutAnalyzer
        if (accessI->srcMemRef != accessJ->srcMemRef ||
            accessI->destMemRef != accessJ->destMemRef) {
          return false;
        }
      }
    }

    return true;
  }

  /// Create a single coalesced operation to replace a group
  LogicalResult
  createAndReplaceWithCoalescedOperation(const CoalescingGroup &group) {
    // Calculate total size
    Value totalSize = calculateTotalSize(group);
    if (!totalSize) {
      return failure();
    }

    // Create the coalesced operation
    Operation *coalescedOp = createCoalescedOperation(group, totalSize);
    if (!coalescedOp) {
      return failure();
    }

    if (debugMode) {
      llvm::dbgs() << "Created coalesced operation replacing "
                   << group.operations.size() << " operations\n";
    }

    // Remove original operations
    for (Operation *op : group.operations) {
      rewriter.eraseOp(op);
    }

    return success();
  }

  /// Check if non-blocking operations can be batched for better performance
  bool canBatchNonBlockingOperations(const CoalescingGroup &group) {
    // Non-blocking operations can often be batched even if not contiguous
    // This is safe because they don't block and completion is checked
    // separately
    return group.isNonBlocking && group.operations.size() >= 2;
  }

  /// Batch non-blocking operations with improved scheduling
  LogicalResult batchNonBlockingOperations(const CoalescingGroup &group) {
    if (debugMode) {
      llvm::dbgs() << "Batching " << group.operations.size()
                   << " non-blocking operations\n";
    }

    // For non-blocking operations, we can often just reorder them to be
    // consecutive, which helps with hardware message batching
    // The actual coalescing happens at the hardware/runtime level

    // This is a placeholder - in a real implementation, we would:
    // 1. Reorder operations to be consecutive in the instruction stream
    // 2. Insert appropriate quiet/fence operations
    // 3. Consider converting to other non-blocking variants

    return success(); // Conservative: do nothing for now
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
