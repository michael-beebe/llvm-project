//===- AtomicOpsToLLVM.cpp - Atomic operations conversion patterns -------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "AtomicOpsToLLVM.h"
#include "OpenSHMEMConversionUtils.h"
#include "mlir/Conversion/LLVMCommon/ConversionTarget.h"
#include "mlir/Conversion/LLVMCommon/Pattern.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEM.h"
#include "mlir/Transforms/DialectConversion.h"

using namespace mlir;
using namespace mlir::openshmem;

namespace {

// Note: Utility functions have been moved to OpenSHMEMConversionUtils.h/cpp
// to eliminate code duplication across conversion files.

struct AtomicFetchOpLowering
    : public ConvertOpToLLVMPattern<openshmem::AtomicFetchOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;
  LogicalResult
  matchAndRewrite(openshmem::AtomicFetchOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());

    // Get element type from symmetric memref
    Type elementType = getSymmetricMemRefElementType(op.getSource());
    if (!elementType) {
      return failure();
    }

    // Generate function name based on type
    std::string funcName = getTypedFunctionName("atomic_fetch", elementType);

    // TYPE shmem_atomic_fetch(const TYPE *source, int pe)
    auto funcType = LLVM::LLVMFunctionType::get(
        elementType, {ptrType, rewriter.getI32Type()});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, funcName, funcType);

    // source: symmetric_memref (already a pointer after type conversion)
    Value sourcePtr = adaptor.getSource();

    auto callOp = rewriter.create<LLVM::CallOp>(
        loc, funcDecl, ValueRange{sourcePtr, adaptor.getPe()});
    rewriter.replaceOp(op, callOp.getResult());
    return success();
  }
};

struct CtxAtomicFetchOpLowering
    : public ConvertOpToLLVMPattern<openshmem::CtxAtomicFetchOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;
  LogicalResult
  matchAndRewrite(openshmem::CtxAtomicFetchOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());

    // Get element type from symmetric memref
    Type elementType = getSymmetricMemRefElementType(op.getSource());
    if (!elementType) {
      return failure();
    }

    // Generate function name based on type
    std::string funcName =
        getTypedFunctionName("ctx_atomic_fetch", elementType);

    // TYPE shmem_atomic_fetch(shmem_ctx_t ctx, const TYPE *source, int pe)
    auto funcType = LLVM::LLVMFunctionType::get(
        elementType, {ptrType, ptrType, rewriter.getI32Type()});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, funcName, funcType);

    // ctx: context (already a pointer after type conversion)
    Value ctxPtr = adaptor.getCtx();
    // source: symmetric_memref (already a pointer after type conversion)
    Value sourcePtr = adaptor.getSource();

    auto callOp = rewriter.create<LLVM::CallOp>(
        loc, funcDecl, ValueRange{ctxPtr, sourcePtr, adaptor.getPe()});
    rewriter.replaceOp(op, callOp.getResult());
    return success();
  }
};

struct AtomicSetOpLowering
    : public ConvertOpToLLVMPattern<openshmem::AtomicSetOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;
  LogicalResult
  matchAndRewrite(openshmem::AtomicSetOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());
    Type elementType = getSymmetricMemRefElementType(op.getDest());
    if (!elementType) {
      return failure();
    }

    // Generate function name based on type
    std::string funcName = getTypedFunctionName("atomic_set", elementType);

    // Determine the type for the value argument in the function call
    Type valueCallType = elementType;
    if (elementType.isF64()) {
      valueCallType = rewriter.getI64Type();
    } else if (elementType.isF32()) {
      valueCallType = rewriter.getI32Type();
    }

    // void shmem_atomic_set(TYPE *dest, TYPE value, int pe)
    auto funcType = LLVM::LLVMFunctionType::get(
        mlir::LLVM::LLVMVoidType::get(rewriter.getContext()),
        {ptrType, valueCallType, rewriter.getI32Type()});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, funcName, funcType);

    // dest: symmetric_memref (already a pointer after type conversion)
    Value destPtr = adaptor.getDest();
    // value: scalar value, may need casting
    Value value = adaptor.getValue();
    if (elementType.isF64()) {
      value =
          rewriter.create<LLVM::BitcastOp>(loc, rewriter.getI64Type(), value);
    } else if (elementType.isF32()) {
      value =
          rewriter.create<LLVM::BitcastOp>(loc, rewriter.getI32Type(), value);
    }

    rewriter.create<LLVM::CallOp>(loc, funcDecl,
                                  ValueRange{destPtr, value, adaptor.getPe()});
    rewriter.eraseOp(op);
    return success();
  }
};

struct CtxAtomicSetOpLowering
    : public ConvertOpToLLVMPattern<openshmem::CtxAtomicSetOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::CtxAtomicSetOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());
    Type elementType = getSymmetricMemRefElementType(op.getDest());
    if (!elementType) {
      return failure();
    }

    // Generate function name based on type
    std::string funcName = getTypedFunctionName("ctx_atomic_set", elementType);

    // Determine the type for the value argument in the function call
    Type valueCallType = elementType;
    if (elementType.isF64()) {
      valueCallType = rewriter.getI64Type();
    } else if (elementType.isF32()) {
      valueCallType = rewriter.getI32Type();
    }

    // void shmem_ctx_atomic_set(shmem_ctx_t ctx, TYPE *dest, TYPE value, int
    // pe)
    auto funcType = LLVM::LLVMFunctionType::get(
        mlir::LLVM::LLVMVoidType::get(rewriter.getContext()),
        {ptrType, ptrType, valueCallType, rewriter.getI32Type()});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, funcName, funcType);

    // ctx: context (already a pointer after type conversion)
    Value ctxPtr = adaptor.getCtx();
    // dest: symmetric_memref (already a pointer after type conversion)
    Value destPtr = adaptor.getDest();
    // value: scalar value, may need casting
    Value value = adaptor.getValue();
    if (elementType.isF64()) {
      value =
          rewriter.create<LLVM::BitcastOp>(loc, rewriter.getI64Type(), value);
    } else if (elementType.isF32()) {
      value =
          rewriter.create<LLVM::BitcastOp>(loc, rewriter.getI32Type(), value);
    }

    rewriter.create<LLVM::CallOp>(
        loc, funcDecl, ValueRange{ctxPtr, destPtr, value, adaptor.getPe()});
    rewriter.eraseOp(op);
    return success();
  }
};

} // namespace

void openshmem::populateAtomicOpsToLLVMConversionPatterns(
    LLVMTypeConverter &converter, RewritePatternSet &patterns) {
  patterns.add<AtomicFetchOpLowering, CtxAtomicFetchOpLowering,
               AtomicSetOpLowering, CtxAtomicSetOpLowering>(converter);
}