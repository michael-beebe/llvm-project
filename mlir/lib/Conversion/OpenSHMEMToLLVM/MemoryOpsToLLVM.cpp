//===- MemoryOpsToLLVM.cpp - Memory Operations Conversion -------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements conversion patterns for OpenSHMEM memory operations
// to LLVM dialect.
//
//===----------------------------------------------------------------------===//

#include "MemoryOpsToLLVM.h"
#include "OpenSHMEMConversionUtils.h"
#include "mlir/Conversion/LLVMCommon/Pattern.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEM.h"
#include "mlir/IR/PatternMatch.h"

using namespace mlir;
using namespace mlir::openshmem;

namespace {

//===----------------------------------------------------------------------===//
// MallocOp Lowering
//===----------------------------------------------------------------------===//

struct MallocOpLowering : public ConvertOpToLLVMPattern<openshmem::MallocOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::MallocOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());

    // void *shmem_malloc(size_t size)
    // size_t is typically the same as index type on the target platform
    Type sizeType = getTypeConverter()->getIndexType();
    auto funcType = LLVM::LLVMFunctionType::get(ptrType, {sizeType});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, "shmem_malloc", funcType);

    // Replace with function call
    auto callOp = rewriter.create<LLVM::CallOp>(loc, funcDecl,
                                                ValueRange{adaptor.getSize()});

    // Return the pointer as the symmetric_memref
    SmallVector<Value> replacements;
    replacements.push_back(callOp.getResult());
    if (op.getRetval()) {
      // Return success (0) for now
      Value success = rewriter.create<arith::ConstantIntOp>(loc, 0, 32);
      replacements.push_back(success);
    }

    rewriter.replaceOp(op, replacements);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// FreeOp Lowering
//===----------------------------------------------------------------------===//

struct FreeOpLowering : public ConvertOpToLLVMPattern<openshmem::FreeOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::FreeOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());

    // void shmem_free(void *ptr)
    auto funcType = LLVM::LLVMFunctionType::get(
        mlir::LLVM::LLVMVoidType::get(rewriter.getContext()), {ptrType});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, "shmem_free", funcType);

    // The symmetric_memref is just a pointer
    Value dataPtr = adaptor.getPtr();

    // Replace with function call
    rewriter.create<LLVM::CallOp>(loc, funcDecl, ValueRange{dataPtr});
    rewriter.eraseOp(op);
    return success();
  }
};

} // namespace

//===----------------------------------------------------------------------===//
// Pattern population
//===----------------------------------------------------------------------===//

void openshmem::populateMemoryOpsToLLVMConversionPatterns(
    LLVMTypeConverter &converter, RewritePatternSet &patterns) {
  patterns.add<MallocOpLowering, FreeOpLowering>(converter);
} 