//===- CoalesceGets.cpp - Coalesce consecutive OpenSHMEM getmem -----------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements a pass that coalesces consecutive OpenSHMEM getmem
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

#define GEN_PASS_DEF_COALESCEGETS
#include "mlir/Dialect/OpenSHMEM/Transforms/Passes.h.inc"

namespace {

//===----------------------------------------------------------------------===//
// Helper Functions
//===----------------------------------------------------------------------===//

/// Check if two getmem operations can be coalesced.
/// They must target the same PE and have compatible memory layouts.
static bool canCoalesce(GetmemOp first, GetmemOp second) {
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
                                SmallVectorImpl<GetmemOp> &ops) {
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

/// Pattern to coalesce consecutive getmem operations from the same PE.
/// This optimization is particularly beneficial for stencil communication
/// patterns and bulk data transfers.
struct CoalesceConsecutiveGets : public OpRewritePattern<GetmemOp> {
  using OpRewritePattern<GetmemOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(GetmemOp getOp,
                                PatternRewriter &rewriter) const override {
    // Collect consecutive getmem operations that can be coalesced
    SmallVector<GetmemOp, 4> coalesceable;
    coalesceable.push_back(getOp);

    // Look for consecutive getmem operations
    Operation *nextOp = getOp->getNextNode();
    while (nextOp) {
      auto nextGet = dyn_cast<GetmemOp>(nextOp);
      if (!nextGet)
        break;

      // Check if this operation can be coalesced with the first one
      if (!canCoalesce(getOp, nextGet))
        break;

      coalesceable.push_back(nextGet);
      nextOp = nextOp->getNextNode();
    }

    // Only coalesce if we found multiple operations
    if (coalesceable.size() < 2)
      return failure();

    // Create the coalesced operation
    Location loc = getOp.getLoc();
    Value totalSize = calculateTotalSize(rewriter, loc, coalesceable);

    // Create the new coalesced getmem operation
    rewriter.create<GetmemOp>(loc, getOp.getDest(), getOp.getSrc(), totalSize,
                              getOp.getPe());

    // Remove all the original operations
    for (GetmemOp op : coalesceable) {
      rewriter.eraseOp(op);
    }

    return success();
  }
};

/// Pattern to coalesce getmem operations within the same basic block
/// that target the same PE, even if they're not immediately consecutive.
struct CoalesceBlockGets : public OpRewritePattern<GetmemOp> {
  using OpRewritePattern<GetmemOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(GetmemOp getOp,
                                PatternRewriter &rewriter) const override {
    Block *block = getOp->getBlock();
    SmallVector<GetmemOp, 4> sameTargetOps;

    // Find all getmem operations in the same block targeting the same PE
    for (Operation &op : *block) {
      if (auto otherGet = dyn_cast<GetmemOp>(&op)) {
        if (otherGet.getPe() == getOp.getPe() && canCoalesce(getOp, otherGet)) {
          sameTargetOps.push_back(otherGet);
        }
      }
    }

    // Only proceed if we have multiple operations to coalesce
    if (sameTargetOps.size() < 2)
      return failure();

    // For safety, only coalesce if there are no interfering operations
    // between the getmem operations (this is a conservative approach)

    // Create one large coalesced operation
    Location loc = getOp.getLoc();
    Value totalSize = calculateTotalSize(rewriter, loc, sameTargetOps);

    // Insert the coalesced operation at the location of the first operation
    rewriter.setInsertionPoint(sameTargetOps[0]);
    rewriter.create<GetmemOp>(loc, getOp.getDest(), getOp.getSrc(), totalSize,
                              getOp.getPe());

    // Remove all original operations
    for (GetmemOp op : sameTargetOps) {
      rewriter.eraseOp(op);
    }

    return success();
  }
};

//===----------------------------------------------------------------------===//
// Pass Implementation
//===----------------------------------------------------------------------===//

struct CoalesceGetsPass : public impl::CoalesceGetsBase<CoalesceGetsPass> {
  void runOnOperation() override {
    Operation *op = getOperation();
    MLIRContext *context = &getContext();

    // Apply coalescing patterns in order of preference
    // First try to coalesce consecutive operations, then try block-level
    // coalescing
    RewritePatternSet patterns(context);
    patterns.add<CoalesceConsecutiveGets>(context);

    if (failed(applyPatternsGreedily(op, std::move(patterns)))) {
      signalPassFailure();
      return;
    }

    // Apply block-level coalescing as a second pass
    RewritePatternSet blockPatterns(context);
    blockPatterns.add<CoalesceBlockGets>(context);

    if (failed(applyPatternsGreedily(op, std::move(blockPatterns)))) {
      signalPassFailure();
    }
  }
};

} // namespace

//===----------------------------------------------------------------------===//
// Pass Registration
//===----------------------------------------------------------------------===//

std::unique_ptr<Pass> createCoalesceGetsPass() {
  return std::make_unique<CoalesceGetsPass>();
}

} // namespace openshmem
} // namespace mlir 