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

// Find a following openshmem.quiet in the same block.
static QuietOp findFollowingQuietInBlock(Operation *op) {
  Operation *cursor = op->getNextNode();
  while (cursor) {
    if (auto q = dyn_cast<QuietOp>(cursor))
      return q;
    cursor = cursor->getNextNode();
  }
  return QuietOp();
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
  using OpRewritePattern::OpRewritePattern;
  LogicalResult matchAndRewrite(PutOp op,
                                PatternRewriter &rewriter) const override {
    auto q = findFollowingQuietInBlock(op);
    if (!q)
      return failure();
    rewriter.replaceOpWithNewOp<PutNbiOp>(op, op.getDest(), op.getSource(),
                                          op.getNelems(), op.getPe());
    return success();
  }
};

struct ConvertCtxPut final : OpRewritePattern<CtxPutOp> {
  using OpRewritePattern::OpRewritePattern;
  LogicalResult matchAndRewrite(CtxPutOp op,
                                PatternRewriter &rewriter) const override {
    auto q = findFollowingQuietInBlock(op);
    if (!q)
      return failure();
    rewriter.replaceOpWithNewOp<CtxPutNbiOp>(op, op.getCtx(), op.getDest(),
                                             op.getSource(), op.getNelems(),
                                             op.getPe());
    return success();
  }
};

struct ConvertPutmem final : OpRewritePattern<PutmemOp> {
  using OpRewritePattern::OpRewritePattern;
  LogicalResult matchAndRewrite(PutmemOp op,
                                PatternRewriter &rewriter) const override {
    auto q = findFollowingQuietInBlock(op);
    if (!q)
      return failure();
    rewriter.replaceOpWithNewOp<PutmemNbiOp>(op, op.getDest(), op.getSrc(),
                                             op.getSize(), op.getPe());
    return success();
  }
};

// get family (only safe when immediately followed by quiet)
struct ConvertGet final : OpRewritePattern<GetOp> {
  using OpRewritePattern::OpRewritePattern;
  LogicalResult matchAndRewrite(GetOp op,
                                PatternRewriter &rewriter) const override {
    auto q = findFollowingQuietInBlock(op);
    if (!q)
      return failure();
    if (valueHasInterveningUse(op.getDest(), op.getOperation(),
                               q.getOperation()))
      return failure();
    rewriter.replaceOpWithNewOp<GetNbiOp>(op, op.getDest(), op.getSource(),
                                          op.getNelems(), op.getPe());
    return success();
  }
};

struct ConvertCtxGet final : OpRewritePattern<CtxGetOp> {
  using OpRewritePattern::OpRewritePattern;
  LogicalResult matchAndRewrite(CtxGetOp op,
                                PatternRewriter &rewriter) const override {
    auto q = findFollowingQuietInBlock(op);
    if (!q)
      return failure();
    if (valueHasInterveningUse(op.getDest(), op.getOperation(),
                               q.getOperation()))
      return failure();
    rewriter.replaceOpWithNewOp<CtxGetNbiOp>(op, op.getCtx(), op.getDest(),
                                             op.getSource(), op.getNelems(),
                                             op.getPe());
    return success();
  }
};

struct ConvertGetmem final : OpRewritePattern<GetmemOp> {
  using OpRewritePattern::OpRewritePattern;
  LogicalResult matchAndRewrite(GetmemOp op,
                                PatternRewriter &rewriter) const override {
    auto q = findFollowingQuietInBlock(op);
    if (!q)
      return failure();
    if (valueHasInterveningUse(op.getDest(), op.getOperation(),
                               q.getOperation()))
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

    patterns.add<ConvertPut, ConvertCtxPut, ConvertPutmem, ConvertGet,
                 ConvertCtxGet, ConvertGetmem>(ctx);

    if (failed(applyPatternsGreedily(op, std::move(patterns))))
      signalPassFailure();
  }
};

} // namespace

std::unique_ptr<Pass> mlir::openshmem::createAsyncConversionPass() {
  return std::make_unique<AsyncConversionPass>();
}
