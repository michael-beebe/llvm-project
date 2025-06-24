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

/// Pattern to coalesce consecutive putmem operations to the same PE.
/// This is the core optimization for stencil communication patterns.
struct CoalesceConsecutivePuts : public OpRewritePattern<PutmemOp> {
  using OpRewritePattern<PutmemOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(PutmemOp putOp,
                                PatternRewriter &rewriter) const override {
    // // Look for another PutmemOp immediately following this one
    // Operation *nextOp = putOp->getNextNode();
    // if (!nextOp)
    //   return failure();

    // auto nextPut = dyn_cast<PutmemOp>(nextOp);
    // if (!nextPut)
    //   return failure();

    // // Check if they target the same PE
    // if (putOp.getPe() != nextPut.getPe())
    //   return failure();

    // For now, just report that we found the pattern
    // TODO: Implement actual coalescing logic that:
    // 1. Checks if memory regions are contiguous or can be made contiguous
    // 2. Combines into a single larger putmem operation
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

    if (failed(applyPatternsGreedily(op, std::move(patterns)))) {
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

//===----------------------------------------------------------------------===//
// Pass Registration
//===----------------------------------------------------------------------===//

void registerOpenSHMEMTransformPasses() {
  // Register all OpenSHMEM transform passes
  // This function is called to register the passes with the pass manager
}

} // namespace openshmem
} // namespace mlir
