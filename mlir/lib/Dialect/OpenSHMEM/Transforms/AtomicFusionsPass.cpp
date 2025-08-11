//===- AtomicFusionsPass.cpp - OpenSHMEM atomic fusion pass ---------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEM.h"
#include "mlir/Dialect/OpenSHMEM/Transforms/Passes.h"

// Generate pass base from TableGen definition (requires dialect headers first
// for dependentDialects types)
#define GEN_PASS_DEF_ATOMICFUSION
#include "mlir/Dialect/OpenSHMEM/Transforms/Passes.h.inc"

#include "mlir/IR/PatternMatch.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Support/LogicalResult.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"

using namespace mlir;
using namespace mlir::openshmem;

namespace {

struct AtomicFusionPass : public ::impl::AtomicFusionBase<AtomicFusionPass> {
  using ::impl::AtomicFusionBase<AtomicFusionPass>::AtomicFusionBase;

  void runOnOperation() override {
    Operation *op = getOperation();
    MLIRContext *ctx = &getContext();

    RewritePatternSet patterns(ctx);

    // Pattern 1: atomic_add + atomic_add -> atomic_add with summed constant
    struct FuseAdd final : OpRewritePattern<AtomicAddOp> {
      using OpRewritePattern::OpRewritePattern;
      LogicalResult matchAndRewrite(AtomicAddOp add1,
                                    PatternRewriter &rewriter) const override {
        Operation *next = add1->getNextNode();
        auto add2 = dyn_cast_or_null<AtomicAddOp>(next);
        if (!add2)
          return failure();
        if (add1.getDest() != add2.getDest() || add1.getPe() != add2.getPe())
          return failure();
        // Check both values are arith.const and same type.
        auto c1 = add1.getValue().getDefiningOp<arith::ConstantOp>();
        auto c2 = add2.getValue().getDefiningOp<arith::ConstantOp>();
        if (!c1 || !c2)
          return failure();
        auto attr1 = dyn_cast<IntegerAttr>(c1.getValue());
        auto attr2 = dyn_cast<IntegerAttr>(c2.getValue());
        if (!attr1 || !attr2 || attr1.getType() != attr2.getType())
          return failure();
        // Replace the first add with combined constant and erase the second.
        APInt sum = attr1.getValue() + attr2.getValue();
        auto loc = add1.getLoc();
        auto newConst = rewriter.create<arith::ConstantOp>(
            loc, IntegerAttr::get(attr1.getType(), sum));
        rewriter.modifyOpInPlace(add1, [&] {
          add1.getValueMutable().assign(newConst.getResult());
        });
        rewriter.eraseOp(add2);
        return success();
      }
    };

    // Pattern 2: atomic_inc chains -> single atomic_add with constant
    struct FuseIncChain final : OpRewritePattern<AtomicIncOp> {
      using OpRewritePattern::OpRewritePattern;
      LogicalResult matchAndRewrite(AtomicIncOp inc1,
                                    PatternRewriter &rewriter) const override {
        // Count consecutive AtomicIncOp on same dest/pe
        SmallVector<AtomicIncOp, 4> chain;
        chain.push_back(inc1);
        Operation *cursor = inc1->getNextNode();
        while (auto incN = dyn_cast_or_null<AtomicIncOp>(cursor)) {
          if (incN.getDest() != inc1.getDest() || incN.getPe() != inc1.getPe())
            break;
          chain.push_back(incN);
          cursor = incN->getNextNode();
        }
        if (chain.size() < 2)
          return failure();
        // Replace first with atomic_add 1*count, erase rest
        // Derive integer element type from symmetric memref element type.
        auto symTy = dyn_cast<SymmetricMemRefType>(inc1.getDest().getType());
        if (!symTy)
          return failure();
        auto intElemTy = dyn_cast<IntegerType>(symTy.getElementType());
        if (!intElemTy)
          return failure();
        auto loc = inc1.getLoc();
        auto c = rewriter.create<arith::ConstantOp>(
            loc, IntegerAttr::get(intElemTy, static_cast<int64_t>(chain.size())));
        rewriter.replaceOpWithNewOp<AtomicAddOp>(
            inc1, inc1.getDest(), c.getResult(), inc1.getPe());
        for (size_t i = 1; i < chain.size(); ++i)
          rewriter.eraseOp(chain[i]);
        return success();
      }
    };

    // Pattern 3: atomic_or + atomic_or with constant operands
    struct FuseOr final : OpRewritePattern<AtomicOrOp> {
      using OpRewritePattern::OpRewritePattern;
      LogicalResult matchAndRewrite(AtomicOrOp or1,
                                    PatternRewriter &rewriter) const override {
        auto or2 = dyn_cast_or_null<AtomicOrOp>(or1->getNextNode());
        if (!or2)
          return failure();
        if (or1.getDest() != or2.getDest() || or1.getPe() != or2.getPe())
          return failure();
        auto c1 = or1.getValue().getDefiningOp<arith::ConstantOp>();
        auto c2 = or2.getValue().getDefiningOp<arith::ConstantOp>();
        if (!c1 || !c2)
          return failure();
        auto a1 = dyn_cast<IntegerAttr>(c1.getValue());
        auto a2 = dyn_cast<IntegerAttr>(c2.getValue());
        if (!a1 || !a2 || a1.getType() != a2.getType())
          return failure();
        APInt combined = a1.getValue() | a2.getValue();
        auto loc = or1.getLoc();
        auto constCombined = rewriter.create<arith::ConstantOp>(
            loc, IntegerAttr::get(a1.getType(), combined));
        rewriter.modifyOpInPlace(or1, [&] {
          or1.getValueMutable().assign(constCombined.getResult());
        });
        rewriter.eraseOp(or2);
        return success();
      }
    };

    // Pattern 4: atomic_xor + atomic_xor with constant operands
    struct FuseXor final : OpRewritePattern<AtomicXorOp> {
      using OpRewritePattern::OpRewritePattern;
      LogicalResult matchAndRewrite(AtomicXorOp x1,
                                    PatternRewriter &rewriter) const override {
        auto x2 = dyn_cast_or_null<AtomicXorOp>(x1->getNextNode());
        if (!x2)
          return failure();
        if (x1.getDest() != x2.getDest() || x1.getPe() != x2.getPe())
          return failure();
        auto c1 = x1.getValue().getDefiningOp<arith::ConstantOp>();
        auto c2 = x2.getValue().getDefiningOp<arith::ConstantOp>();
        if (!c1 || !c2)
          return failure();
        auto a1 = dyn_cast<IntegerAttr>(c1.getValue());
        auto a2 = dyn_cast<IntegerAttr>(c2.getValue());
        if (!a1 || !a2 || a1.getType() != a2.getType())
          return failure();
        APInt combined = a1.getValue() ^ a2.getValue();
        auto loc = x1.getLoc();
        auto constCombined = rewriter.create<arith::ConstantOp>(
            loc, IntegerAttr::get(a1.getType(), combined));
        rewriter.modifyOpInPlace(x1, [&] {
          x1.getValueMutable().assign(constCombined.getResult());
        });
        rewriter.eraseOp(x2);
        return success();
      }
    };

    patterns.add<FuseAdd, FuseIncChain, FuseOr, FuseXor>(ctx);

    if (failed(applyPatternsGreedily(op, std::move(patterns))))
      signalPassFailure();
  }
};

} // namespace

std::unique_ptr<Pass> mlir::openshmem::createAtomicFusionPass() {
  return std::make_unique<AtomicFusionPass>();
}


