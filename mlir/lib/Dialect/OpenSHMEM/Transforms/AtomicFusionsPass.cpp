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

    // Pattern 1: Fuse a chain of atomic_add with constant values
    // More efficient approach: walk UP from constants to find all their uses
    struct FuseAdd final : OpRewritePattern<AtomicAddOp> {
      using OpRewritePattern::OpRewritePattern;
      LogicalResult matchAndRewrite(AtomicAddOp head,
                                    PatternRewriter &rewriter) const override {
        // Instead of walking down from each operation, collect all atomic_add ops
        // that use constants, then process them together
        SmallVector<AtomicAddOp> constantAddOps;
        
        // Find all atomic_add operations with constant values in the same block
        Block *block = head->getBlock();
        for (Operation &op : *block) {
          if (auto addOp = dyn_cast<AtomicAddOp>(&op)) {
            if (addOp.getValue().getDefiningOp<arith::ConstantOp>()) {
              constantAddOps.push_back(addOp);
            }
          }
        }
        
        if (constantAddOps.size() < 2)
          return failure();
          
        // Group operations by destination and PE
        llvm::DenseMap<std::pair<Value, Value>, SmallVector<AtomicAddOp>> groups;
        for (auto addOp : constantAddOps) {
          auto key = std::make_pair(addOp.getDest(), addOp.getPe());
          groups[key].push_back(addOp);
        }
        
        bool madeChanges = false;
        for (auto &[key, ops] : groups) {
          if (ops.size() < 2) continue;
          
          // Sort operations by their position in the block
          std::sort(ops.begin(), ops.end(), [](AtomicAddOp a, AtomicAddOp b) {
            return a->isBeforeInBlock(b);
          });
          
          // Process consecutive operations
          for (size_t i = 0; i < ops.size() - 1; ++i) {
            AtomicAddOp current = ops[i];
            AtomicAddOp next = ops[i + 1];
            
            // Check if they are consecutive in the block
            if (current->getNextNode() != next) continue;
            
            // Get constant values
            auto c1 = current.getValue().getDefiningOp<arith::ConstantOp>();
            auto c2 = next.getValue().getDefiningOp<arith::ConstantOp>();
            if (!c1 || !c2) continue;
            
            auto a1 = dyn_cast<IntegerAttr>(c1.getValue());
            auto a2 = dyn_cast<IntegerAttr>(c2.getValue());
            if (!a1 || !a2 || a1.getType() != a2.getType()) continue;
            
            // Combine the constants
            APInt sum = a1.getValue() + a2.getValue();
            auto newConst = rewriter.create<arith::ConstantOp>(
                current.getLoc(), IntegerAttr::get(a1.getType(), sum));
            
            // Update the first operation and erase the second
            rewriter.modifyOpInPlace(current, [&] {
              current.getValueMutable().assign(newConst.getResult());
            });
            rewriter.eraseOp(next);
            madeChanges = true;
            
            // Remove the erased operation from our list
            ops.erase(ops.begin() + i + 1);
            --i; // Adjust index since we removed an element
          }
        }
        
        return madeChanges ? success() : failure();
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

        // Check if we're inside a region - if so, only look within the region
        auto region = inc1->getParentOfType<openshmem::Region>();

        while (auto incN = dyn_cast_or_null<AtomicIncOp>(cursor)) {
          // If we're in a region, stop if we go outside the region
          if (region && !region->isAncestor(cursor))
            break;

          if (incN.getDest() != inc1.getDest() || incN.getPe() != inc1.getPe())
            break;
          chain.push_back(incN);
          cursor = incN->getNextNode();
        }
        if (chain.size() < 2)
          return failure();
        // Replace first with atomic_add 1*count, erase rest
        // Derive integer element type from memref with symmetric memory space.
        auto memRefType = dyn_cast<MemRefType>(inc1.getDest().getType());
        if (!memRefType || !memRefType.getMemorySpace() ||
            !llvm::isa<openshmem::SymmetricMemorySpaceAttr>(
                memRefType.getMemorySpace()))
          return failure();
        auto intElemTy = dyn_cast<IntegerType>(memRefType.getElementType());
        if (!intElemTy)
          return failure();
        auto loc = inc1.getLoc();
        auto c = rewriter.create<arith::ConstantOp>(
            loc,
            IntegerAttr::get(intElemTy, static_cast<int64_t>(chain.size())));
        rewriter.replaceOpWithNewOp<AtomicAddOp>(inc1, inc1.getDest(),
                                                 c.getResult(), inc1.getPe());
        for (size_t i = 1; i < chain.size(); ++i)
          rewriter.eraseOp(chain[i]);
        return success();
      }
    };

    // Pattern 3: Fuse a chain of atomic_or with constant operands
    struct FuseOr final : OpRewritePattern<AtomicOrOp> {
      using OpRewritePattern::OpRewritePattern;
      LogicalResult matchAndRewrite(AtomicOrOp or1,
                                    PatternRewriter &rewriter) const override {
        auto c1 = or1.getValue().getDefiningOp<arith::ConstantOp>();
        auto a1 =
            dyn_cast_or_null<IntegerAttr>(c1 ? c1.getValue() : Attribute());
        if (!a1)
          return failure();
        APInt combined = a1.getValue();
        SmallVector<Operation *> toErase;
        Operation *cursor = or1->getNextNode();

        // Check if we're inside a region - if so, only look within the region
        auto region = or1->getParentOfType<openshmem::Region>();

        while (auto orN = dyn_cast_or_null<AtomicOrOp>(cursor)) {
          // If we're in a region, stop if we go outside the region
          if (region && !region->isAncestor(cursor))
            break;

          if (orN.getDest() != or1.getDest() || orN.getPe() != or1.getPe())
            break;
          auto cN = orN.getValue().getDefiningOp<arith::ConstantOp>();
          auto aN =
              dyn_cast_or_null<IntegerAttr>(cN ? cN.getValue() : Attribute());
          if (!aN || aN.getType() != a1.getType())
            break;
          combined |= aN.getValue();
          toErase.push_back(orN);
          cursor = orN->getNextNode();
        }
        if (toErase.empty())
          return failure();
        auto constCombined = rewriter.create<arith::ConstantOp>(
            or1.getLoc(), IntegerAttr::get(a1.getType(), combined));
        rewriter.modifyOpInPlace(or1, [&] {
          or1.getValueMutable().assign(constCombined.getResult());
        });
        for (Operation *op : toErase)
          rewriter.eraseOp(op);
        return success();
      }
    };

    // Pattern 4: Fuse a chain of atomic_xor with constant operands. If the
    // combined constant is 0, erase the entire chain as a no-op.
    struct FuseXor final : OpRewritePattern<AtomicXorOp> {
      using OpRewritePattern::OpRewritePattern;
      LogicalResult matchAndRewrite(AtomicXorOp x1,
                                    PatternRewriter &rewriter) const override {
        auto c1 = x1.getValue().getDefiningOp<arith::ConstantOp>();
        auto a1 =
            dyn_cast_or_null<IntegerAttr>(c1 ? c1.getValue() : Attribute());
        if (!a1)
          return failure();
        APInt combined = a1.getValue();
        SmallVector<Operation *> toErase;
        Operation *cursor = x1->getNextNode();

        // Check if we're inside a region - if so, only look within the region
        auto region = x1->getParentOfType<openshmem::Region>();

        while (auto xN = dyn_cast_or_null<AtomicXorOp>(cursor)) {
          // If we're in a region, stop if we go outside the region
          if (region && !region->isAncestor(cursor))
            break;

          if (xN.getDest() != x1.getDest() || xN.getPe() != x1.getPe())
            break;
          auto cN = xN.getValue().getDefiningOp<arith::ConstantOp>();
          auto aN =
              dyn_cast_or_null<IntegerAttr>(cN ? cN.getValue() : Attribute());
          if (!aN || aN.getType() != a1.getType())
            break;
          combined ^= aN.getValue();
          toErase.push_back(xN);
          cursor = xN->getNextNode();
        }
        if (toErase.empty())
          return failure();
        if (combined.isZero()) {
          for (Operation *op : toErase)
            rewriter.eraseOp(op);
          rewriter.eraseOp(x1);
          return success();
        }
        auto constCombined = rewriter.create<arith::ConstantOp>(
            x1.getLoc(), IntegerAttr::get(a1.getType(), combined));
        rewriter.modifyOpInPlace(x1, [&] {
          x1.getValueMutable().assign(constCombined.getResult());
        });
        for (Operation *op : toErase)
          rewriter.eraseOp(op);
        return success();
      }
    };

    // Pattern 5: add followed by inc -> collapse into single add (increment +1)
    struct FuseAddInc final : OpRewritePattern<AtomicAddOp> {
      using OpRewritePattern::OpRewritePattern;
      LogicalResult matchAndRewrite(AtomicAddOp add,
                                    PatternRewriter &rewriter) const override {
        auto inc = dyn_cast_or_null<AtomicIncOp>(add->getNextNode());
        if (!inc)
          return failure();

        // Check if we're inside a region - if so, ensure inc is also in the
        // same region
        auto region = add->getParentOfType<openshmem::Region>();
        if (region && !region->isAncestor(inc))
          return failure();

        if (add.getDest() != inc.getDest() || add.getPe() != inc.getPe())
          return failure();
        auto c = add.getValue().getDefiningOp<arith::ConstantOp>();
        auto a = dyn_cast_or_null<IntegerAttr>(c ? c.getValue() : Attribute());
        if (!a)
          return failure();
        APInt sum = a.getValue() + 1;
        auto newConst = rewriter.create<arith::ConstantOp>(
            add.getLoc(), IntegerAttr::get(a.getType(), sum));
        rewriter.modifyOpInPlace(
            add, [&] { add.getValueMutable().assign(newConst.getResult()); });
        rewriter.eraseOp(inc);
        return success();
      }
    };

    // Pattern 6: inc followed by add -> replace inc by add with (1+const) and
    // erase add
    struct FuseIncAdd final : OpRewritePattern<AtomicIncOp> {
      using OpRewritePattern::OpRewritePattern;
      LogicalResult matchAndRewrite(AtomicIncOp inc,
                                    PatternRewriter &rewriter) const override {
        auto add = dyn_cast_or_null<AtomicAddOp>(inc->getNextNode());
        if (!add)
          return failure();

        // Check if we're inside a region - if so, ensure add is also in the
        // same region
        auto region = inc->getParentOfType<openshmem::Region>();
        if (region && !region->isAncestor(add))
          return failure();

        if (inc.getDest() != add.getDest() || inc.getPe() != add.getPe())
          return failure();
        auto c = add.getValue().getDefiningOp<arith::ConstantOp>();
        auto a = dyn_cast_or_null<IntegerAttr>(c ? c.getValue() : Attribute());
        if (!a)
          return failure();
        APInt sum = a.getValue() + 1;
        // Derive element integer type from memref with symmetric memory space.
        auto memRefType = dyn_cast<MemRefType>(inc.getDest().getType());
        if (!memRefType || !memRefType.getMemorySpace() ||
            !llvm::isa<openshmem::SymmetricMemorySpaceAttr>(
                memRefType.getMemorySpace()))
          return failure();
        auto intElemTy = dyn_cast<IntegerType>(memRefType.getElementType());
        if (!intElemTy || intElemTy != a.getType())
          return failure();
        auto newConst = rewriter.create<arith::ConstantOp>(
            inc.getLoc(), IntegerAttr::get(intElemTy, sum));
        rewriter.replaceOpWithNewOp<AtomicAddOp>(
            inc, inc.getDest(), newConst.getResult(), inc.getPe());
        rewriter.eraseOp(add);
        return success();
      }
    };

    // Pattern 7: dead fetch variants -> non-fetch equivalent
    struct DropDeadFetchAdd final : OpRewritePattern<AtomicFetchAddOp> {
      using OpRewritePattern::OpRewritePattern;
      LogicalResult matchAndRewrite(AtomicFetchAddOp op,
                                    PatternRewriter &rewriter) const override {
        if (!op->use_empty())
          return failure();
        rewriter.replaceOpWithNewOp<AtomicAddOp>(op, op.getDest(),
                                                 op.getValue(), op.getPe());
        return success();
      }
    };
    struct DropDeadFetchOr final : OpRewritePattern<AtomicFetchOrOp> {
      using OpRewritePattern::OpRewritePattern;
      LogicalResult matchAndRewrite(AtomicFetchOrOp op,
                                    PatternRewriter &rewriter) const override {
        if (!op->use_empty())
          return failure();
        rewriter.replaceOpWithNewOp<AtomicOrOp>(op, op.getDest(), op.getValue(),
                                                op.getPe());
        return success();
      }
    };
    struct DropDeadFetchXor final : OpRewritePattern<AtomicFetchXorOp> {
      using OpRewritePattern::OpRewritePattern;
      LogicalResult matchAndRewrite(AtomicFetchXorOp op,
                                    PatternRewriter &rewriter) const override {
        if (!op->use_empty())
          return failure();
        rewriter.replaceOpWithNewOp<AtomicXorOp>(op, op.getDest(),
                                                 op.getValue(), op.getPe());
        return success();
      }
    };
    // Note: No non-fetch "atomic_and" op is defined in the dialect; skip it.

    patterns.add<FuseAdd, FuseIncChain, FuseOr, FuseXor, FuseAddInc, FuseIncAdd,
                 DropDeadFetchAdd, DropDeadFetchOr, DropDeadFetchXor>(ctx);

    if (failed(applyPatternsGreedily(op, std::move(patterns))))
      signalPassFailure();
  }
};

} // namespace

std::unique_ptr<Pass> mlir::openshmem::createAtomicFusionPass() {
  return std::make_unique<AtomicFusionPass>();
}
