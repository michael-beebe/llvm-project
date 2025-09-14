#include "mlir/Dialect/OpenSHMEM/Transforms/Passes.h"

#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEM.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Support/LogicalResult.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"

// Generate pass base for AsyncConversion from TableGen definition
#define GEN_PASS_DEF_ASYNCCONVERSION
#include "mlir/Dialect/OpenSHMEM/Transforms/Passes.h.inc"

using namespace mlir;
using namespace mlir::openshmem;

namespace {

// Find a following sync (quiet or barrier_all) in the same block or region.
// With regions, we need to look within the region that contains the operation.
static Operation *findFollowingSyncInBlock(Operation *op,
                                           bool treatBarriersAsSync) {
  Operation *cursor = op->getNextNode();
  while (cursor) {
    if (isa<QuietOp>(cursor))
      return cursor;
    if (treatBarriersAsSync && isa<BarrierAllOp>(cursor))
      return cursor;
    cursor = cursor->getNextNode();
  }
  return nullptr;
}

// Find a following sync within a region. This handles the case where
// operations are contained within openshmem.region blocks.
static Operation *findFollowingSyncInRegion(Operation *op,
                                            bool treatBarriersAsSync) {
  // First check if we're inside a region
  if (auto region = op->getParentOfType<openshmem::Region>()) {
    // Look for sync operations within the same region
    Operation *cursor = op->getNextNode();
    while (cursor && region->isAncestor(cursor)) {
      if (isa<QuietOp>(cursor))
        return cursor;
      if (treatBarriersAsSync && isa<BarrierAllOp>(cursor))
        return cursor;
      cursor = cursor->getNextNode();
    }
  }

  // Fall back to block-level search for backward compatibility
  return findFollowingSyncInBlock(op, treatBarriersAsSync);
}

// Returns true if 'val' has any use by an operation placed strictly between
// 'start' and 'end' within the same block.
static bool valueHasInterveningUse(Value val, Operation *start,
                                   Operation *end) {
  for (OpOperand &use : val.getUses()) {
    Operation *user = use.getOwner();
    if (user->getBlock() != start->getBlock())
      continue;
    if (start->isBeforeInBlock(user) && user->isBeforeInBlock(end))
      return true;
  }
  return false;
}

struct ConvertPut final : OpRewritePattern<PutOp> {
  ConvertPut(MLIRContext *ctx, bool treatBarriers, bool aggressive)
      : OpRewritePattern(ctx), treatBarriersAsSync(treatBarriers),
        aggressiveInsertQuiet(aggressive) {}
  bool treatBarriersAsSync;
  bool aggressiveInsertQuiet;
  LogicalResult matchAndRewrite(PutOp op,
                                PatternRewriter &rewriter) const override {
    Operation *sync = findFollowingSyncInRegion(op, treatBarriersAsSync);
    if (!sync) {
      if (!aggressiveInsertQuiet)
        return failure();
      OpBuilder::InsertionGuard g(rewriter);
      // Insert quiet at the end of the region if we're in one, otherwise at end
      // of block
      if (auto region = op->getParentOfType<openshmem::Region>()) {
        rewriter.setInsertionPointToEnd(&region.getBody().front());
      } else {
        rewriter.setInsertionPointToEnd(op->getBlock());
      }
      sync = rewriter.create<QuietOp>(op.getLoc());
    }
    rewriter.replaceOpWithNewOp<PutNbiOp>(op, op.getDest(), op.getSource(),
                                          op.getNelems(), op.getPe());
    return success();
  }
};

struct ConvertCtxPut final : OpRewritePattern<CtxPutOp> {
  ConvertCtxPut(MLIRContext *ctx, bool treatBarriers, bool aggressive)
      : OpRewritePattern(ctx), treatBarriersAsSync(treatBarriers),
        aggressiveInsertQuiet(aggressive) {}
  bool treatBarriersAsSync;
  bool aggressiveInsertQuiet;
  LogicalResult matchAndRewrite(CtxPutOp op,
                                PatternRewriter &rewriter) const override {
    Operation *sync = findFollowingSyncInRegion(op, treatBarriersAsSync);
    if (!sync) {
      if (!aggressiveInsertQuiet)
        return failure();
      OpBuilder::InsertionGuard g(rewriter);
      // Insert quiet at the end of the region if we're in one, otherwise at end
      // of block
      if (auto region = op->getParentOfType<openshmem::Region>()) {
        rewriter.setInsertionPointToEnd(&region.getBody().front());
      } else {
        rewriter.setInsertionPointToEnd(op->getBlock());
      }
      sync = rewriter.create<QuietOp>(op.getLoc());
    }
    rewriter.replaceOpWithNewOp<CtxPutNbiOp>(op, op.getCtx(), op.getDest(),
                                             op.getSource(), op.getNelems(),
                                             op.getPe());
    return success();
  }
};

struct ConvertPutmem final : OpRewritePattern<PutmemOp> {
  ConvertPutmem(MLIRContext *ctx, bool treatBarriers, bool aggressive)
      : OpRewritePattern(ctx), treatBarriersAsSync(treatBarriers),
        aggressiveInsertQuiet(aggressive) {}
  bool treatBarriersAsSync;
  bool aggressiveInsertQuiet;
  LogicalResult matchAndRewrite(PutmemOp op,
                                PatternRewriter &rewriter) const override {
    Operation *sync = findFollowingSyncInRegion(op, treatBarriersAsSync);
    if (!sync) {
      if (!aggressiveInsertQuiet)
        return failure();
      OpBuilder::InsertionGuard g(rewriter);
      // Insert quiet at the end of the region if we're in one, otherwise at end
      // of block
      if (auto region = op->getParentOfType<openshmem::Region>()) {
        rewriter.setInsertionPointToEnd(&region.getBody().front());
      } else {
        rewriter.setInsertionPointToEnd(op->getBlock());
      }
      sync = rewriter.create<QuietOp>(op.getLoc());
    }
    rewriter.replaceOpWithNewOp<PutmemNbiOp>(op, op.getDest(), op.getSrc(),
                                             op.getSize(), op.getPe());
    return success();
  }
};

// get family (only safe when immediately followed by quiet)
struct ConvertGet final : OpRewritePattern<GetOp> {
  ConvertGet(MLIRContext *ctx, bool treatBarriers, bool aggressive)
      : OpRewritePattern(ctx), treatBarriersAsSync(treatBarriers),
        aggressiveInsertQuiet(aggressive) {}
  bool treatBarriersAsSync;
  bool aggressiveInsertQuiet;
  LogicalResult matchAndRewrite(GetOp op,
                                PatternRewriter &rewriter) const override {
    Operation *sync = findFollowingSyncInRegion(op, treatBarriersAsSync);
    if (!sync) {
      if (!aggressiveInsertQuiet)
        return failure();
      OpBuilder::InsertionGuard g(rewriter);
      // Insert quiet at the end of the region if we're in one, otherwise at end
      // of block
      if (auto region = op->getParentOfType<openshmem::Region>()) {
        rewriter.setInsertionPointToEnd(&region.getBody().front());
      } else {
        rewriter.setInsertionPointToEnd(op->getBlock());
      }
      sync = rewriter.create<QuietOp>(op.getLoc());
    }
    if (valueHasInterveningUse(op.getDest(), op.getOperation(), sync))
      return failure();
    rewriter.replaceOpWithNewOp<GetNbiOp>(op, op.getDest(), op.getSource(),
                                          op.getNelems(), op.getPe());
    return success();
  }
};

struct ConvertCtxGet final : OpRewritePattern<CtxGetOp> {
  ConvertCtxGet(MLIRContext *ctx, bool treatBarriers, bool aggressive)
      : OpRewritePattern(ctx), treatBarriersAsSync(treatBarriers),
        aggressiveInsertQuiet(aggressive) {}
  bool treatBarriersAsSync;
  bool aggressiveInsertQuiet;
  LogicalResult matchAndRewrite(CtxGetOp op,
                                PatternRewriter &rewriter) const override {
    Operation *sync = findFollowingSyncInRegion(op, treatBarriersAsSync);
    if (!sync) {
      if (!aggressiveInsertQuiet)
        return failure();
      OpBuilder::InsertionGuard g(rewriter);
      // Insert quiet at the end of the region if we're in one, otherwise at end
      // of block
      if (auto region = op->getParentOfType<openshmem::Region>()) {
        rewriter.setInsertionPointToEnd(&region.getBody().front());
      } else {
        rewriter.setInsertionPointToEnd(op->getBlock());
      }
      sync = rewriter.create<QuietOp>(op.getLoc());
    }
    if (valueHasInterveningUse(op.getDest(), op.getOperation(), sync))
      return failure();
    rewriter.replaceOpWithNewOp<CtxGetNbiOp>(op, op.getCtx(), op.getDest(),
                                             op.getSource(), op.getNelems(),
                                             op.getPe());
    return success();
  }
};

struct ConvertGetmem final : OpRewritePattern<GetmemOp> {
  ConvertGetmem(MLIRContext *ctx, bool treatBarriers, bool aggressive)
      : OpRewritePattern(ctx), treatBarriersAsSync(treatBarriers),
        aggressiveInsertQuiet(aggressive) {}
  bool treatBarriersAsSync;
  bool aggressiveInsertQuiet;
  LogicalResult matchAndRewrite(GetmemOp op,
                                PatternRewriter &rewriter) const override {
    Operation *sync = findFollowingSyncInRegion(op, treatBarriersAsSync);
    if (!sync) {
      if (!aggressiveInsertQuiet)
        return failure();
      OpBuilder::InsertionGuard g(rewriter);
      // Insert quiet at the end of the region if we're in one, otherwise at end
      // of block
      if (auto region = op->getParentOfType<openshmem::Region>()) {
        rewriter.setInsertionPointToEnd(&region.getBody().front());
      } else {
        rewriter.setInsertionPointToEnd(op->getBlock());
      }
      sync = rewriter.create<QuietOp>(op.getLoc());
    }
    if (valueHasInterveningUse(op.getDest(), op.getOperation(), sync))
      return failure();
    rewriter.replaceOpWithNewOp<GetmemNbiOp>(op, op.getDest(), op.getSrc(),
                                             op.getSize(), op.getPe());
    return success();
  }
};

struct AsyncConversionPass
    : public ::impl::AsyncConversionBase<AsyncConversionPass> {
  using ::impl::AsyncConversionBase<AsyncConversionPass>::AsyncConversionBase;

  void runOnOperation() override {
    Operation *op = getOperation();
    MLIRContext *ctx = &getContext();
    RewritePatternSet patterns(ctx);

    // Add patterns with options passed via constructors.
    bool treatBarriersAsSync = true;
    bool aggressiveInsertQuiet = false;
    patterns.add<ConvertPut>(ctx, treatBarriersAsSync, aggressiveInsertQuiet);
    patterns.add<ConvertCtxPut>(ctx, treatBarriersAsSync,
                                aggressiveInsertQuiet);
    patterns.add<ConvertPutmem>(ctx, treatBarriersAsSync,
                                aggressiveInsertQuiet);
    patterns.add<ConvertGet>(ctx, treatBarriersAsSync, aggressiveInsertQuiet);
    patterns.add<ConvertCtxGet>(ctx, treatBarriersAsSync,
                                aggressiveInsertQuiet);
    patterns.add<ConvertGetmem>(ctx, treatBarriersAsSync,
                                aggressiveInsertQuiet);

    if (failed(applyPatternsGreedily(op, std::move(patterns))))
      signalPassFailure();
  }
};

} // namespace

std::unique_ptr<Pass> mlir::openshmem::createAsyncConversionPass() {
  return std::make_unique<AsyncConversionPass>();
}
