//===- CollectiveOpsToLLVM.cpp - Collective operations conversion patterns ===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "CollectiveOpsToLLVM.h"
#include "OpenSHMEMConversionUtils.h"
#include "mlir/Conversion/LLVMCommon/ConversionTarget.h"
#include "mlir/Conversion/LLVMCommon/Pattern.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/LLVMIR/LLVMTypes.h"
#include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEM.h"
#include "mlir/IR/Types.h"
#include "mlir/Support/LLVM.h"
#include "mlir/Transforms/DialectConversion.h"

using namespace mlir;
using namespace mlir::openshmem;

namespace {

//===----------------------------------------------------------------------===//
// AlltoallmemOp Lowering
//===----------------------------------------------------------------------===//

struct AlltoallmemOpLowering
    : public ConvertOpToLLVMPattern<openshmem::AlltoallmemOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::AlltoallmemOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());

    // int shmem_alltoallmem(shmem_team_t team, void *dest, const void *source,
    // size_t nelems) size_t is typically the same as index type on the target
    // platform
    Type sizeType = getTypeConverter()->getIndexType();
    auto funcType = LLVM::LLVMFunctionType::get(
        rewriter.getI32Type(), {ptrType, ptrType, ptrType, sizeType});
    LLVM::LLVMFuncOp funcDecl = getOrDefineFunction(
        moduleOp, loc, rewriter, "shmem_alltoallmem", funcType);

    // dest and source are already pointers (symmetric_memref converts to
    // pointer)
    Value destPtr = adaptor.getDest();
    Value sourcePtr = adaptor.getSource();

    auto callOp = rewriter.create<LLVM::CallOp>(
        loc, funcDecl,
        ValueRange{adaptor.getTeam(), destPtr, sourcePtr, adaptor.getNelems()});

    rewriter.replaceOp(op, callOp.getResult());
    return success();
  }
};

//===----------------------------------------------------------------------===//
// AlltoallsmemOp Lowering
//===----------------------------------------------------------------------===//

struct AlltoallsmemOpLowering
    : public ConvertOpToLLVMPattern<openshmem::AlltoallsmemOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::AlltoallsmemOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());

    // int shmem_alltoallsmem(shmem_team_t team, void *dest, const void *source,
    //                        ptrdiff_t dst, ptrdiff_t sst, size_t nelems);
    Type sizeType = getTypeConverter()->getIndexType();
    auto funcType = LLVM::LLVMFunctionType::get(
        rewriter.getI32Type(),
        {ptrType, ptrType, ptrType, sizeType, sizeType, sizeType});
    LLVM::LLVMFuncOp funcDecl = getOrDefineFunction(
        moduleOp, loc, rewriter, "shmem_alltoallsmem", funcType);

    // dest and source are already pointers (symmetric_memref converts to
    // pointer)
    Value destPtr = adaptor.getDest();
    Value sourcePtr = adaptor.getSource();
    Value dst = adaptor.getDst();
    Value sst = adaptor.getSst();
    Value nelems = adaptor.getNelems();

    auto callOp = rewriter.create<LLVM::CallOp>(
        loc, funcDecl,
        ValueRange{adaptor.getTeam(), destPtr, sourcePtr, dst, sst, nelems});

    rewriter.replaceOp(op, callOp.getResult());
    return success();
  }
};

//===----------------------------------------------------------------------===//
// BroadcastmemOp Lowering
//===----------------------------------------------------------------------===//

struct BroadcastmemOpLowering
    : public ConvertOpToLLVMPattern<openshmem::BroadcastmemOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::BroadcastmemOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());
    Type sizeType = getTypeConverter()->getIndexType();

    // int shmem_broadcastmem(shmem_team_t team, void *dest, const void *source,
    //                        size_t nelems, int PE_root);
    auto funcType = LLVM::LLVMFunctionType::get(
        rewriter.getI32Type(),
        {ptrType, ptrType, ptrType, sizeType, rewriter.getI32Type()});
    LLVM::LLVMFuncOp funcDecl = getOrDefineFunction(
        moduleOp, loc, rewriter, "shmem_broadcastmem", funcType);

    // dest and source are already pointers (symmetric_memref converts to
    // pointer)
    Value destPtr = adaptor.getDest();
    Value sourcePtr = adaptor.getSource();
    Value nelems = adaptor.getNelems();
    Value peRoot = adaptor.getPERoot();

    auto callOp = rewriter.create<LLVM::CallOp>(
        loc, funcDecl,
        ValueRange{adaptor.getTeam(), destPtr, sourcePtr, nelems, peRoot});

    rewriter.replaceOp(op, callOp.getResult());
    return success();
  }
};

//===----------------------------------------------------------------------===//
// CollectmemOp Lowering
//===----------------------------------------------------------------------===//

struct CollectmemOpLowering
    : public ConvertOpToLLVMPattern<openshmem::CollectmemOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::CollectmemOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());
    Type sizeType = getTypeConverter()->getIndexType();

    // int shmem_collectmem(shmem_team_t team, void *dest, const void *source,
    // size_t nelems);
    auto funcType = LLVM::LLVMFunctionType::get(
        rewriter.getI32Type(), {ptrType, ptrType, ptrType, sizeType});
    LLVM::LLVMFuncOp funcDecl = getOrDefineFunction(
        moduleOp, loc, rewriter, "shmem_collectmem", funcType);

    // dest and source are already pointers (symmetric_memref converts to
    // pointer)
    Value destPtr = adaptor.getDest();
    Value sourcePtr = adaptor.getSource();
    Value nelems = adaptor.getNelems();

    auto callOp = rewriter.create<LLVM::CallOp>(
        loc, funcDecl,
        ValueRange{adaptor.getTeam(), destPtr, sourcePtr, nelems});

    rewriter.replaceOp(op, callOp.getResult());
    return success();
  }
};

//===----------------------------------------------------------------------===//
// FCollectmemOp Lowering
//===----------------------------------------------------------------------===//

struct FCollectmemOpLowering
    : public ConvertOpToLLVMPattern<openshmem::FCollectmemOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::FCollectmemOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());
    Type sizeType = getTypeConverter()->getIndexType();

    // int shmem_fcollectmem(shmem_team_t team, void *dest, const void *source,
    // size_t nelems);
    auto funcType = LLVM::LLVMFunctionType::get(
        rewriter.getI32Type(), {ptrType, ptrType, ptrType, sizeType});
    LLVM::LLVMFuncOp funcDecl = getOrDefineFunction(
        moduleOp, loc, rewriter, "shmem_fcollectmem", funcType);

    // dest and source are already pointers (symmetric_memref converts to
    // pointer)
    Value destPtr = adaptor.getDest();
    Value sourcePtr = adaptor.getSource();
    Value nelems = adaptor.getNelems();

    auto callOp = rewriter.create<LLVM::CallOp>(
        loc, funcDecl,
        ValueRange{adaptor.getTeam(), destPtr, sourcePtr, nelems});

    rewriter.replaceOp(op, callOp.getResult());
    return success();
  }
};

} // namespace

//===----------------------------------------------------------------------===//
// Pattern population
//===----------------------------------------------------------------------===//

void openshmem::populateCollectiveOpsToLLVMConversionPatterns(
    LLVMTypeConverter &converter, RewritePatternSet &patterns) {
  patterns.add<AlltoallmemOpLowering, AlltoallsmemOpLowering,
               BroadcastmemOpLowering, CollectmemOpLowering,
               FCollectmemOpLowering>(converter);
} 