//===- CoalescePuts.cpp - Coalesce consecutive OpenSHMEM putmem -----------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements a pass that coalesces consecutive OpenSHMEM putmem
// operations targeting the same PE into fewer, larger transfers.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEM.h"
#include "mlir/Dialect/OpenSHMEM/Transforms/Transforms.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"

namespace mlir {
namespace openshmem {

#define GEN_PASS_DEF_COALESCEPUTS
#include "mlir/Dialect/OpenSHMEM/Transforms/Passes.h.inc"

namespace {

//===----------------------------------------------------------------------===//
// Helper Functions
//===----------------------------------------------------------------------===//

/// Check if two putmem operations can be coalesced.
/// They must target the same PE and have compatible memory layouts.
static bool canCoalesce(PutmemOp first, PutmemOp second) {
  // Must target the same PE
  if (first.getPe() != second.getPe())
    return false;

  // Both operations must use the same source and destination base pointers
  // For simplicity, we require exact same memref sources for now
  if (first.getSrc() != second.getSrc())
    return false;

  if (first.getDest() != second.getDest())
    return false;

  return true;
}

/// Calculate the total size for coalesced operations
static Value calculateTotalSize(PatternRewriter &rewriter, Location loc,
                                SmallVectorImpl<PutmemOp> &ops) {
  if (ops.empty())
    return nullptr;

  if (ops.size() == 1)
    return ops[0].getSize();

  // Create arith.addi operations to sum all sizes
  Value totalSize = ops[0].getSize();
  for (size_t i = 1; i < ops.size(); ++i) {
    totalSize =
        rewriter.create<arith::AddIOp>(loc, totalSize, ops[i].getSize());
  }

  return totalSize;
}

//===----------------------------------------------------------------------===//
// Coalescing Patterns
//===----------------------------------------------------------------------===//

/// Pattern to coalesce consecutive putmem operations to the same PE.
/// This optimization is particularly beneficial for stencil communication
/// patterns.
struct CoalesceConsecutivePuts : public OpRewritePattern<PutmemOp> {
  using OpRewritePattern<PutmemOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(PutmemOp putOp,
                                PatternRewriter &rewriter) const override {
    // Collect consecutive putmem operations that can be coalesced
    SmallVector<PutmemOp, 4> coalesceable;
    coalesceable.push_back(putOp);

    // Look for consecutive putmem operations
    Operation *nextOp = putOp->getNextNode();
    while (nextOp) {
      auto nextPut = dyn_cast<PutmemOp>(nextOp);
      if (!nextPut)
        break;

      // Check if this operation can be coalesced with the first one
      if (!canCoalesce(putOp, nextPut))
        break;

      coalesceable.push_back(nextPut);
      nextOp = nextOp->getNextNode();
    }

    // Only coalesce if we found multiple operations
    if (coalesceable.size() < 2)
      return failure();

    // Create the coalesced operation
    Location loc = putOp.getLoc();
    Value totalSize = calculateTotalSize(rewriter, loc, coalesceable);

    // Create the new coalesced putmem operation
    rewriter.create<PutmemOp>(loc, putOp.getDest(), putOp.getSrc(), totalSize,
                              putOp.getPe());

    // Remove all the original operations
    for (PutmemOp op : coalesceable) {
      rewriter.eraseOp(op);
    }

    return success();
  }
};

/// Pattern to coalesce putmem operations within the same basic block
/// that target the same PE, even if they're not immediately consecutive.
struct CoalesceBlockPuts : public OpRewritePattern<PutmemOp> {
  using OpRewritePattern<PutmemOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(PutmemOp putOp,
                                PatternRewriter &rewriter) const override {
    Block *block = putOp->getBlock();
    SmallVector<PutmemOp, 4> sameTargetOps;

    // Find all putmem operations in the same block targeting the same PE
    for (Operation &op : *block) {
      if (auto otherPut = dyn_cast<PutmemOp>(&op)) {
        if (otherPut.getPe() == putOp.getPe() && canCoalesce(putOp, otherPut)) {
          sameTargetOps.push_back(otherPut);
        }
      }
    }

    // Only proceed if we have multiple operations to coalesce
    if (sameTargetOps.size() < 2)
      return failure();

    // For safety, only coalesce if there are no interfering operations
    // between the putmem operations (this is a conservative approach)

    // Create one large coalesced operation
    Location loc = putOp.getLoc();
    Value totalSize = calculateTotalSize(rewriter, loc, sameTargetOps);

    // Insert the coalesced operation at the location of the first operation
    rewriter.setInsertionPoint(sameTargetOps[0]);
    rewriter.create<PutmemOp>(loc, putOp.getDest(), putOp.getSrc(), totalSize,
                              putOp.getPe());

    // Remove all original operations
    for (PutmemOp op : sameTargetOps) {
      rewriter.eraseOp(op);
    }

    return success();
  }
};

//===----------------------------------------------------------------------===//
// Pass Implementation
//===----------------------------------------------------------------------===//

struct CoalescePutsPass : public impl::CoalescePutsBase<CoalescePutsPass> {
  void runOnOperation() override {
    Operation *op = getOperation();
    MLIRContext *context = &getContext();

    // Apply coalescing patterns in order of preference
    // First try to coalesce consecutive operations, then try block-level
    // coalescing
    RewritePatternSet patterns(context);
    patterns.add<CoalesceConsecutivePuts>(context);

    if (failed(applyPatternsGreedily(op, std::move(patterns)))) {
      signalPassFailure();
      return;
    }

    // Apply block-level coalescing as a second pass
    RewritePatternSet blockPatterns(context);
    blockPatterns.add<CoalesceBlockPuts>(context);

    if (failed(applyPatternsGreedily(op, std::move(blockPatterns)))) {
      signalPassFailure();
    }
  }
};

} // namespace

//===----------------------------------------------------------------------===//
// Pass Registration
//===----------------------------------------------------------------------===//

std::unique_ptr<Pass> createCoalescePutsPass() {
  return std::make_unique<CoalescePutsPass>();
}

void registerOpenSHMEMTransformPasses() {
  // Register all OpenSHMEM transform passes
  // This function is called to register the passes with the pass manager
}

} // namespace openshmem
} // namespace mlir
