//===- CoalescePuts.cpp - Coalesce consecutive OpenSHMEM puts -------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements a pass that coalesces consecutive OpenSHMEM put
// operations targeting the same PE into fewer, larger transfers.
//
//===----------------------------------------------------------------------===//

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
// Coalescing Patterns
//===----------------------------------------------------------------------===//

/// Pattern to coalesce consecutive put operations to the same PE.
/// This is the core optimization for stencil communication patterns.
struct CoalesceConsecutivePuts : public OpRewritePattern<PutOp> {
  using OpRewritePattern<PutOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(PutOp putOp,
                                PatternRewriter &rewriter) const override {
    // // Look for another PutOp immediately following this one
    // Operation *nextOp = putOp->getNextNode();
    // if (!nextOp)
    //   return failure();

    // auto nextPut = dyn_cast<PutOp>(nextOp);
    // if (!nextPut)
    //   return failure();

    // // Check if they target the same PE
    // if (putOp.getPe() != nextPut.getPe())
    //   return failure();

    // For now, just report that we found the pattern
    // TODO: Implement actual coalescing logic that:
    // 1. Checks if memory regions are contiguous or can be made contiguous
    // 2. Combines into a single larger put operation
    // 3. Updates size and memory references accordingly
    // 4. Handles any intermediate operations that might interfere

    // This is a placeholder - actual implementation would be more complex
    return failure();
  }
};

//===----------------------------------------------------------------------===//
// Pass Implementation
//===----------------------------------------------------------------------===//

struct CoalescePutsPass : public impl::CoalescePutsBase<CoalescePutsPass> {
  void runOnOperation() override {
    Operation *op = getOperation();
    MLIRContext *context = &getContext();

    // Apply coalescing patterns
    RewritePatternSet patterns(context);
    patterns.add<CoalesceConsecutivePuts>(context);

    if (failed(applyPatternsAndFoldGreedily(op, std::move(patterns)))) {
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

} // namespace openshmem
} // namespace mlir