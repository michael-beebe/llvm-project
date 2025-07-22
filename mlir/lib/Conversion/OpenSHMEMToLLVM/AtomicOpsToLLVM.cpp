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

//===----------------------------------------------------------------------===//
// AtomicFetchOp Lowering
//===----------------------------------------------------------------------===//

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

    // Determine the return type for the function call
    Type returnCallType = elementType;
    if (elementType.isF64()) {
      returnCallType = rewriter.getI64Type();
    } else if (elementType.isF32()) {
      returnCallType = rewriter.getI32Type();
    }

    // TYPE shmem_atomic_fetch(const TYPE *source, int pe)
    auto funcType = LLVM::LLVMFunctionType::get(
        returnCallType, {ptrType, rewriter.getI32Type()});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, funcName, funcType);

    // source: symmetric_memref (already a pointer after type conversion)
    Value sourcePtr = adaptor.getSource();

    auto callOp = rewriter.create<LLVM::CallOp>(
        loc, funcDecl, ValueRange{sourcePtr, adaptor.getPe()});

    Value result = callOp.getResult();
    // Convert result back to original type if needed
    if (elementType.isF64()) {
      result = rewriter.create<LLVM::BitcastOp>(loc, elementType, result);
    } else if (elementType.isF32()) {
      result = rewriter.create<LLVM::BitcastOp>(loc, elementType, result);
    }

    rewriter.replaceOp(op, result);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// CtxAtomicFetchOp Lowering
//===----------------------------------------------------------------------===//

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

    // Determine the return type for the function call
    Type returnCallType = elementType;
    if (elementType.isF64()) {
      returnCallType = rewriter.getI64Type();
    } else if (elementType.isF32()) {
      returnCallType = rewriter.getI32Type();
    }

    // TYPE shmem_atomic_fetch(shmem_ctx_t ctx, const TYPE *source, int pe)
    auto funcType = LLVM::LLVMFunctionType::get(
        returnCallType, {ptrType, ptrType, rewriter.getI32Type()});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, funcName, funcType);

    // ctx: context (already a pointer after type conversion)
    Value ctxPtr = adaptor.getCtx();
    // source: symmetric_memref (already a pointer after type conversion)
    Value sourcePtr = adaptor.getSource();

    auto callOp = rewriter.create<LLVM::CallOp>(
        loc, funcDecl, ValueRange{ctxPtr, sourcePtr, adaptor.getPe()});

    Value result = callOp.getResult();
    // Convert result back to original type if needed
    if (elementType.isF64()) {
      result = rewriter.create<LLVM::BitcastOp>(loc, elementType, result);
    } else if (elementType.isF32()) {
      result = rewriter.create<LLVM::BitcastOp>(loc, elementType, result);
    }

    rewriter.replaceOp(op, result);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// AtomicSetOp Lowering
//===----------------------------------------------------------------------===//

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

//===----------------------------------------------------------------------===//
// CtxAtomicSetOp Lowering
//===----------------------------------------------------------------------===//

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

//===----------------------------------------------------------------------===//
// AtomicCompareSwapOp Lowering
//===----------------------------------------------------------------------===//

struct AtomicCompareSwapOpLowering
    : public ConvertOpToLLVMPattern<openshmem::AtomicCompareSwapOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;
  LogicalResult
  matchAndRewrite(openshmem::AtomicCompareSwapOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());
    Type elementType = getSymmetricMemRefElementType(op.getDest());
    if (!elementType) {
      return failure();
    }

    // Generate function name based on type
    std::string funcName =
        getTypedFunctionName("atomic_compare_swap", elementType);

    // Determine the type for the value arguments in the function call
    Type condCallType = elementType;
    Type valueCallType = elementType;
    Type returnCallType = elementType;
    if (elementType.isF64()) {
      condCallType = rewriter.getI64Type();
      valueCallType = rewriter.getI64Type();
      returnCallType = rewriter.getI64Type();
    } else if (elementType.isF32()) {
      condCallType = rewriter.getI32Type();
      valueCallType = rewriter.getI32Type();
      returnCallType = rewriter.getI32Type();
    }

    // TYPE shmem_atomic_compare_swap(TYPE *dest, TYPE cond, TYPE value, int pe)
    auto funcType = LLVM::LLVMFunctionType::get(
        returnCallType,
        {ptrType, condCallType, valueCallType, rewriter.getI32Type()});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, funcName, funcType);

    // dest: symmetric_memref (already a pointer after type conversion)
    Value destPtr = adaptor.getDest();
    // cond: scalar value, may need casting
    Value cond = adaptor.getCond();
    if (elementType.isF64()) {
      cond = rewriter.create<LLVM::BitcastOp>(loc, rewriter.getI64Type(), cond);
    } else if (elementType.isF32()) {
      cond = rewriter.create<LLVM::BitcastOp>(loc, rewriter.getI32Type(), cond);
    }

    // value: scalar value, may need casting
    Value value = adaptor.getValue();
    if (elementType.isF64()) {
      value =
          rewriter.create<LLVM::BitcastOp>(loc, rewriter.getI64Type(), value);
    } else if (elementType.isF32()) {
      value =
          rewriter.create<LLVM::BitcastOp>(loc, rewriter.getI32Type(), value);
    }

    auto callOp = rewriter.create<LLVM::CallOp>(
        loc, funcDecl, ValueRange{destPtr, cond, value, adaptor.getPe()});

    Value result = callOp.getResult();
    // Convert result back to original type if needed
    if (elementType.isF64()) {
      result = rewriter.create<LLVM::BitcastOp>(loc, elementType, result);
    } else if (elementType.isF32()) {
      result = rewriter.create<LLVM::BitcastOp>(loc, elementType, result);
    }

    rewriter.replaceOp(op, result);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// CtxAtomicCompareSwapOp Lowering
//===----------------------------------------------------------------------===//

struct CtxAtomicCompareSwapOpLowering
    : public ConvertOpToLLVMPattern<openshmem::CtxAtomicCompareSwapOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;
  LogicalResult
  matchAndRewrite(openshmem::CtxAtomicCompareSwapOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());
    Type elementType = getSymmetricMemRefElementType(op.getDest());
    if (!elementType) {
      return failure();
    }

    // Generate function name based on type
    std::string funcName =
        getTypedFunctionName("ctx_atomic_compare_swap", elementType);

    // Determine the type for the value arguments in the function call
    Type condCallType = elementType;
    Type valueCallType = elementType;
    Type returnCallType = elementType;
    if (elementType.isF64()) {
      condCallType = rewriter.getI64Type();
      valueCallType = rewriter.getI64Type();
      returnCallType = rewriter.getI64Type();
    } else if (elementType.isF32()) {
      condCallType = rewriter.getI32Type();
      valueCallType = rewriter.getI32Type();
      returnCallType = rewriter.getI32Type();
    }

    // TYPE shmem_ctx_atomic_compare_swap(shmem_ctx_t ctx, TYPE *dest, TYPE
    // cond, TYPE value, int pe)
    auto funcType = LLVM::LLVMFunctionType::get(
        returnCallType,
        {ptrType, ptrType, condCallType, valueCallType, rewriter.getI32Type()});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, funcName, funcType);

    // ctx: context (already a pointer after type conversion)
    Value ctxPtr = adaptor.getCtx();
    // dest: symmetric_memref (already a pointer after type conversion)
    Value destPtr = adaptor.getDest();
    // cond: scalar value, may need casting
    Value cond = adaptor.getCond();
    if (elementType.isF64()) {
      cond = rewriter.create<LLVM::BitcastOp>(loc, rewriter.getI64Type(), cond);
    } else if (elementType.isF32()) {
      cond = rewriter.create<LLVM::BitcastOp>(loc, rewriter.getI32Type(), cond);
    }

    // value: scalar value, may need casting
    Value value = adaptor.getValue();
    if (elementType.isF64()) {
      value =
          rewriter.create<LLVM::BitcastOp>(loc, rewriter.getI64Type(), value);
    } else if (elementType.isF32()) {
      value =
          rewriter.create<LLVM::BitcastOp>(loc, rewriter.getI32Type(), value);
    }

    auto callOp = rewriter.create<LLVM::CallOp>(
        loc, funcDecl,
        ValueRange{ctxPtr, destPtr, cond, value, adaptor.getPe()});

    Value result = callOp.getResult();
    // Convert result back to original type if needed
    if (elementType.isF64()) {
      result = rewriter.create<LLVM::BitcastOp>(loc, elementType, result);
    } else if (elementType.isF32()) {
      result = rewriter.create<LLVM::BitcastOp>(loc, elementType, result);
    }

    rewriter.replaceOp(op, result);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// AtomicSwapOp Lowering
//===----------------------------------------------------------------------===//

struct AtomicSwapOpLowering
    : public ConvertOpToLLVMPattern<openshmem::AtomicSwapOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;
  LogicalResult
  matchAndRewrite(openshmem::AtomicSwapOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());
    Type elementType = getSymmetricMemRefElementType(op.getDest());
    if (!elementType) {
      return failure();
    }

    // Generate function name based on type
    std::string funcName = getTypedFunctionName("atomic_swap", elementType);

    // Determine the type for the value arguments in the function call
    Type valueCallType = elementType;
    Type returnCallType = elementType;
    if (elementType.isF64()) {
      valueCallType = rewriter.getI64Type();
      returnCallType = rewriter.getI64Type();
    } else if (elementType.isF32()) {
      valueCallType = rewriter.getI32Type();
      returnCallType = rewriter.getI32Type();
    }

    // TYPE shmem_atomic_swap(TYPE *dest, TYPE value, int pe)
    auto funcType = LLVM::LLVMFunctionType::get(
        returnCallType, {ptrType, valueCallType, rewriter.getI32Type()});
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

    auto callOp = rewriter.create<LLVM::CallOp>(
        loc, funcDecl, ValueRange{destPtr, value, adaptor.getPe()});

    Value result = callOp.getResult();
    // Convert result back to original type if needed
    if (elementType.isF64()) {
      result = rewriter.create<LLVM::BitcastOp>(loc, elementType, result);
    } else if (elementType.isF32()) {
      result = rewriter.create<LLVM::BitcastOp>(loc, elementType, result);
    }

    rewriter.replaceOp(op, result);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// CtxAtomicSwapOp Lowering
//===----------------------------------------------------------------------===//

struct CtxAtomicSwapOpLowering
    : public ConvertOpToLLVMPattern<openshmem::CtxAtomicSwapOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;
  LogicalResult
  matchAndRewrite(openshmem::CtxAtomicSwapOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());
    Type elementType = getSymmetricMemRefElementType(op.getDest());
    if (!elementType) {
      return failure();
    }

    // Generate function name based on type
    std::string funcName = getTypedFunctionName("ctx_atomic_swap", elementType);

    // Determine the type for the value arguments in the function call
    Type valueCallType = elementType;
    Type returnCallType = elementType;
    if (elementType.isF64()) {
      valueCallType = rewriter.getI64Type();
      returnCallType = rewriter.getI64Type();
    } else if (elementType.isF32()) {
      valueCallType = rewriter.getI32Type();
      returnCallType = rewriter.getI32Type();
    }

    // TYPE shmem_ctx_atomic_swap(shmem_ctx_t ctx, TYPE *dest, TYPE value, int
    // pe)
    auto funcType = LLVM::LLVMFunctionType::get(
        returnCallType,
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

    auto callOp = rewriter.create<LLVM::CallOp>(
        loc, funcDecl, ValueRange{ctxPtr, destPtr, value, adaptor.getPe()});

    Value result = callOp.getResult();
    // Convert result back to original type if needed
    if (elementType.isF64()) {
      result = rewriter.create<LLVM::BitcastOp>(loc, elementType, result);
    } else if (elementType.isF32()) {
      result = rewriter.create<LLVM::BitcastOp>(loc, elementType, result);
    }

    rewriter.replaceOp(op, result);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// AtomicFetchIncOp Lowering
//===----------------------------------------------------------------------===//

struct AtomicFetchIncOpLowering
    : public ConvertOpToLLVMPattern<openshmem::AtomicFetchIncOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;
  LogicalResult
  matchAndRewrite(openshmem::AtomicFetchIncOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());
    Type elementType = getSymmetricMemRefElementType(op.getDest());
    if (!elementType) {
      return failure();
    }

    // Generate function name based on type
    std::string funcName =
        getTypedFunctionName("atomic_fetch_inc", elementType);

    // Determine the return type for the function call
    Type returnCallType = elementType;
    if (elementType.isF64()) {
      returnCallType = rewriter.getI64Type();
    } else if (elementType.isF32()) {
      returnCallType = rewriter.getI32Type();
    }

    // TYPE shmem_atomic_fetch_inc(TYPE *dest, int pe)
    auto funcType = LLVM::LLVMFunctionType::get(
        returnCallType, {ptrType, rewriter.getI32Type()});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, funcName, funcType);

    // dest: symmetric_memref (already a pointer after type conversion)
    Value destPtr = adaptor.getDest();

    auto callOp = rewriter.create<LLVM::CallOp>(
        loc, funcDecl, ValueRange{destPtr, adaptor.getPe()});

    Value result = callOp.getResult();
    // Convert result back to original type if needed
    if (elementType.isF64()) {
      result = rewriter.create<LLVM::BitcastOp>(loc, elementType, result);
    } else if (elementType.isF32()) {
      result = rewriter.create<LLVM::BitcastOp>(loc, elementType, result);
    }

    rewriter.replaceOp(op, result);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// CtxAtomicFetchIncOp Lowering
//===----------------------------------------------------------------------===//

struct CtxAtomicFetchIncOpLowering
    : public ConvertOpToLLVMPattern<openshmem::CtxAtomicFetchIncOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;
  LogicalResult
  matchAndRewrite(openshmem::CtxAtomicFetchIncOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();

    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());
    Type elementType = getSymmetricMemRefElementType(op.getDest());
    if (!elementType) {
      return failure();
    }

    // Generate function name based on type
    std::string funcName =
        getTypedFunctionName("ctx_atomic_fetch_inc", elementType);

    // Determine the return type for the function call
    Type returnCallType = elementType;
    if (elementType.isF64()) {
      returnCallType = rewriter.getI64Type();
    } else if (elementType.isF32()) {
      returnCallType = rewriter.getI32Type();
    }

    // TYPE shmem_ctx_atomic_fetch_inc(shmem_ctx_t ctx, TYPE *dest, int pe)
    auto funcType = LLVM::LLVMFunctionType::get(
        returnCallType, {ptrType, ptrType, rewriter.getI32Type()});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, funcName, funcType);

    // ctx: context (already a pointer after type conversion)
    Value ctxPtr = adaptor.getCtx();
    // dest: symmetric_memref (already a pointer after type conversion)
    Value destPtr = adaptor.getDest();

    auto callOp = rewriter.create<LLVM::CallOp>(
        loc, funcDecl, ValueRange{ctxPtr, destPtr, adaptor.getPe()});

    Value result = callOp.getResult();
    // Convert result back to original type if needed
    if (elementType.isF64()) {
      result = rewriter.create<LLVM::BitcastOp>(loc, elementType, result);
    } else if (elementType.isF32()) {
      result = rewriter.create<LLVM::BitcastOp>(loc, elementType, result);
    }

    rewriter.replaceOp(op, result);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// AtomicIncOp Lowering
//===----------------------------------------------------------------------===//

struct AtomicIncOpLowering
    : public ConvertOpToLLVMPattern<openshmem::AtomicIncOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;
  LogicalResult
  matchAndRewrite(openshmem::AtomicIncOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());
    Type elementType = getSymmetricMemRefElementType(op.getDest());
    if (!elementType) {
      return failure();
    }

    // Generate function name based on type
    std::string funcName = getTypedFunctionName("atomic_inc", elementType);

    // void shmem_atomic_inc(TYPE *dest, int pe)
    auto funcType = LLVM::LLVMFunctionType::get(
        mlir::LLVM::LLVMVoidType::get(rewriter.getContext()),
        {ptrType, rewriter.getI32Type()});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, funcName, funcType);

    // dest: symmetric_memref (already a pointer after type conversion)
    Value destPtr = adaptor.getDest();

    rewriter.create<LLVM::CallOp>(loc, funcDecl,
                                  ValueRange{destPtr, adaptor.getPe()});

    rewriter.eraseOp(op);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// CtxAtomicIncOp Lowering
//===----------------------------------------------------------------------===//

struct CtxAtomicIncOpLowering
    : public ConvertOpToLLVMPattern<openshmem::CtxAtomicIncOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;
  LogicalResult
  matchAndRewrite(openshmem::CtxAtomicIncOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());
    Type elementType = getSymmetricMemRefElementType(op.getDest());
    if (!elementType) {
      return failure();
    }

    // Generate function name based on type
    std::string funcName = getTypedFunctionName("ctx_atomic_inc", elementType);

    // void shmem_ctx_atomic_inc(shmem_ctx_t ctx, TYPE *dest, int pe)
    auto funcType = LLVM::LLVMFunctionType::get(
        mlir::LLVM::LLVMVoidType::get(rewriter.getContext()),
        {ptrType, ptrType, rewriter.getI32Type()});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, funcName, funcType);

    // ctx: context (already a pointer after type conversion)
    Value ctxPtr = adaptor.getCtx();
    // dest: symmetric_memref (already a pointer after type conversion)
    Value destPtr = adaptor.getDest();

    rewriter.create<LLVM::CallOp>(loc, funcDecl,
                                  ValueRange{ctxPtr, destPtr, adaptor.getPe()});

    rewriter.eraseOp(op);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// AtomicFetchAddOp Lowering
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// CtxAtomicFetchAddOp Lowering
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// AtomicAddOp Lowering
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// CtxAtomicAddOp Lowering
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// AtomicFetchAndOp Lowering
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// CtxAtomicFetchAndOp Lowering
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// AtomicFetchOrOp Lowering
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// CtxAtomicFetchOrOp Lowering
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// AtomicOrOp Lowering
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// CtxAtomicOrOp Lowering
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// AtomicFetchXorOp Lowering
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// CtxAtomicFetchXorOp Lowering
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// AtomicXorOp Lowering
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// CtxAtomicXorOp Lowering
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// AtomicFetchNbiOp Lowering
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// CtxAtomicFetchNbiOp Lowering
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// AtomicCompareSwapNbiOp Lowering
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// CtxAtomicCompareSwapNbiOp Lowering
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// AtomicSwapNbiOp Lowering
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// CtxAtomicSwapNbiOp Lowering
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// AtomicFetchIncNbiOp Lowering
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// CtxAtomicFetchIncNbiOp Lowering
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// AtomicFetchAddNbiOp Lowering
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// CtxAtomicFetchAddNbiOp Lowering
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// AtomicFetchAndNbiOp Lowering
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// CtxAtomicFetchAndNbiOp Lowering
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// AtomicFetchOrNbiOp Lowering
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// CtxAtomicFetchOrNbiOp Lowering
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// AtomicFetchXorNbiOp Lowering
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// CtxAtomicFetchXorNbiOp Lowering
//===----------------------------------------------------------------------===//


} // namespace

void openshmem::populateAtomicOpsToLLVMConversionPatterns(
    LLVMTypeConverter &converter, RewritePatternSet &patterns) {
  patterns.add<AtomicFetchOpLowering, CtxAtomicFetchOpLowering,
               AtomicSetOpLowering, CtxAtomicSetOpLowering,
               AtomicCompareSwapOpLowering, CtxAtomicCompareSwapOpLowering,
               AtomicSwapOpLowering, CtxAtomicSwapOpLowering,
               AtomicFetchIncOpLowering, CtxAtomicFetchIncOpLowering,
               AtomicIncOpLowering, CtxAtomicIncOpLowering>(converter);
}
