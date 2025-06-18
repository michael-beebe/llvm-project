//===- OpenSHMEMToLLVM.cpp - OpenSHMEM to LLVM conversion ----------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "mlir/Conversion/OpenSHMEMToLLVM/OpenSHMEMToLLVM.h"
#include "mlir/Conversion/ConvertToLLVM/ToLLVMInterface.h"
#include "mlir/Conversion/LLVMCommon/ConversionTarget.h"
#include "mlir/Conversion/LLVMCommon/MemRefBuilder.h"
#include "mlir/Conversion/LLVMCommon/Pattern.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/LLVMIR/LLVMTypes.h"
#include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEM.h"
#include "mlir/IR/Types.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/DialectConversion.h"
#include <memory>

namespace mlir {
#define GEN_PASS_DEF_CONVERTOPENSHMEMTOLLVMPASS
#include "mlir/Conversion/Passes.h.inc"
} // namespace mlir

using namespace mlir;

namespace {

//===----------------------------------------------------------------------===//
// Utility functions for creating LLVM function declarations
//===----------------------------------------------------------------------===//

static LLVM::LLVMFuncOp getOrDefineFunction(ModuleOp &moduleOp,
                                            const Location loc,
                                            ConversionPatternRewriter &rewriter,
                                            StringRef name,
                                            LLVM::LLVMFunctionType type) {
  LLVM::LLVMFuncOp funcOp;
  if (!(funcOp = moduleOp.lookupSymbol<LLVM::LLVMFuncOp>(name))) {
    ConversionPatternRewriter::InsertionGuard guard(rewriter);
    rewriter.setInsertionPointToStart(moduleOp.getBody());
    funcOp = rewriter.create<LLVM::LLVMFuncOp>(loc, name, type,
                                               LLVM::Linkage::External);
  }
  return funcOp;
}

// Utility to extract the data pointer from a memref
static Value getMemRefDataPtr(Location loc, ConversionPatternRewriter &rewriter,
                              Value memref) {
  // Assumes memref is a MemRef descriptor (struct), extract the pointer (field
  // 0)
  auto ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());
  return rewriter.create<LLVM::ExtractValueOp>(loc, ptrType, memref, 0);
}

//===----------------------------------------------------------------------===//
// InitOp Lowering
//===----------------------------------------------------------------------===//

struct InitOpLowering : public ConvertOpToLLVMPattern<openshmem::InitOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::InitOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();

    // int shmem_init(void)
    auto funcType = LLVM::LLVMFunctionType::get(rewriter.getI32Type(), {});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, "shmem_init", funcType);

    // Replace with function call
    auto callOp = rewriter.create<LLVM::CallOp>(loc, funcDecl, ValueRange{});

    if (op.getRetval())
      rewriter.replaceOp(op, callOp.getResult());
    else
      rewriter.eraseOp(op);

    return success();
  }
};

//===----------------------------------------------------------------------===//
// FinalizeOp Lowering
//===----------------------------------------------------------------------===//

struct FinalizeOpLowering
    : public ConvertOpToLLVMPattern<openshmem::FinalizeOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::FinalizeOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();

    // void shmem_finalize(void)
    auto funcType = LLVM::LLVMFunctionType::get(rewriter.getI32Type(), {});
    LLVM::LLVMFuncOp funcDecl = getOrDefineFunction(moduleOp, loc, rewriter,
                                                    "shmem_finalize", funcType);

    // Replace with function call
    auto callOp = rewriter.create<LLVM::CallOp>(loc, funcDecl, ValueRange{});

    if (op.getRetval())
      rewriter.replaceOp(op, callOp.getResult());
    else
      rewriter.eraseOp(op);

    return success();
  }
};

//===----------------------------------------------------------------------===//
// MyPeOp Lowering
//===----------------------------------------------------------------------===//

struct MyPeOpLowering : public ConvertOpToLLVMPattern<openshmem::MyPeOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::MyPeOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();

    // int shmem_my_pe(void)
    auto funcType = LLVM::LLVMFunctionType::get(rewriter.getI32Type(), {});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, "shmem_my_pe", funcType);

    // Replace with function call
    auto callOp = rewriter.create<LLVM::CallOp>(loc, funcDecl, ValueRange{});
    rewriter.replaceOp(op, callOp.getResult());

    return success();
  }
};

//===----------------------------------------------------------------------===//
// NPesOp Lowering
//===----------------------------------------------------------------------===//

struct NPesOpLowering : public ConvertOpToLLVMPattern<openshmem::NPesOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::NPesOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();

    // int shmem_n_pes(void)
    auto funcType = LLVM::LLVMFunctionType::get(rewriter.getI32Type(), {});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, "shmem_n_pes", funcType);

    // Replace with function call
    auto callOp = rewriter.create<LLVM::CallOp>(loc, funcDecl, ValueRange{});
    rewriter.replaceOp(op, callOp.getResult());

    return success();
  }
};

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
    auto funcType =
        LLVM::LLVMFunctionType::get(ptrType, {rewriter.getI64Type()});
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
    auto funcType =
        LLVM::LLVMFunctionType::get(rewriter.getI32Type(), {ptrType});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, "shmem_free", funcType);

    // The symmetric_memref is just a pointer
    Value dataPtr = adaptor.getPtr();

    // Replace with function call
    auto callOp =
        rewriter.create<LLVM::CallOp>(loc, funcDecl, ValueRange{dataPtr});

    if (op.getRetval())
      rewriter.replaceOp(op, callOp.getResult());
    else
      rewriter.eraseOp(op);

    return success();
  }
};

//===----------------------------------------------------------------------===//
// PutOp Lowering
//===----------------------------------------------------------------------===//

struct PutOpLowering : public ConvertOpToLLVMPattern<openshmem::PutOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::PutOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());

    // dest: symmetric_memref (already a pointer after type conversion)
    Value destPtr = adaptor.getDest();
    // src: memref (need to extract pointer)
    Value srcPtr = getMemRefDataPtr(loc, rewriter, adaptor.getSrc());

    // void shmem_put(void *dest, const void *source, size_t nelems, int pe)
    auto funcType = LLVM::LLVMFunctionType::get(
        mlir::LLVM::LLVMVoidType::get(rewriter.getContext()),
        {ptrType, ptrType, rewriter.getI64Type(), rewriter.getI32Type()});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, "shmem_put", funcType);

    rewriter.create<LLVM::CallOp>(
        loc, funcDecl,
        ValueRange{destPtr, srcPtr, adaptor.getSize(), adaptor.getPe()});
    rewriter.eraseOp(op);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// GetOp Lowering
//===----------------------------------------------------------------------===//

struct GetOpLowering : public ConvertOpToLLVMPattern<openshmem::GetOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::GetOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());

    // dest: memref (need to extract pointer)
    Value destPtr = getMemRefDataPtr(loc, rewriter, adaptor.getDest());
    // src: symmetric_memref (already a pointer after type conversion)
    Value srcPtr = adaptor.getSrc();

    // void shmem_get(void *dest, const void *source, size_t nelems, int pe)
    auto funcType = LLVM::LLVMFunctionType::get(
        mlir::LLVM::LLVMVoidType::get(rewriter.getContext()),
        {ptrType, ptrType, rewriter.getI64Type(), rewriter.getI32Type()});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, "shmem_get", funcType);

    rewriter.create<LLVM::CallOp>(
        loc, funcDecl,
        ValueRange{destPtr, srcPtr, adaptor.getSize(), adaptor.getPe()});
    rewriter.eraseOp(op);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// Pass and conversion setup
//===----------------------------------------------------------------------===//

struct ConvertOpenSHMEMToLLVMPass
    : public impl::ConvertOpenSHMEMToLLVMPassBase<ConvertOpenSHMEMToLLVMPass> {
  using Base::Base;

  void getDependentDialects(DialectRegistry &registry) const override {
    registry.insert<LLVM::LLVMDialect, openshmem::OpenSHMEMDialect>();
  }

  void runOnOperation() override {
    ConversionTarget target(getContext());
    RewritePatternSet patterns(&getContext());
    LLVMTypeConverter converter(&getContext());

    // Configure conversion target
    target.addLegalDialect<LLVM::LLVMDialect>();
    target.addIllegalDialect<openshmem::OpenSHMEMDialect>();

    // Populate conversion patterns
    openshmem::populateOpenSHMEMToLLVMConversionPatterns(converter, patterns);

    if (failed(applyPartialConversion(getOperation(), target,
                                      std::move(patterns))))
      signalPassFailure();
  }
};

//===----------------------------------------------------------------------===//
// ConvertToLLVMPatternInterface implementation
//===----------------------------------------------------------------------===//

/// Implement the interface to convert OpenSHMEM to LLVM.
struct OpenSHMEMToLLVMDialectInterface : public ConvertToLLVMPatternInterface {
  using ConvertToLLVMPatternInterface::ConvertToLLVMPatternInterface;
  /// Hook for derived dialect interface to provide conversion patterns
  /// and mark dialect legal for the conversion target.
  void populateConvertToLLVMConversionPatterns(
      ConversionTarget &target, LLVMTypeConverter &typeConverter,
      RewritePatternSet &patterns) const final {
    openshmem::populateOpenSHMEMToLLVMConversionPatterns(typeConverter,
                                                         patterns);
  }
};
} // namespace

//===----------------------------------------------------------------------===//
// Pattern population and pass creation
//===----------------------------------------------------------------------===//

void openshmem::populateOpenSHMEMToLLVMConversionPatterns(
    LLVMTypeConverter &converter, RewritePatternSet &patterns) {

  // Add type conversions for OpenSHMEM types
  converter.addConversion([](openshmem::RetvalType type) -> Type {
    return IntegerType::get(type.getContext(),
                            32); // return values are typically int
  });

  converter.addConversion([](openshmem::SymmetricMemRefType type) -> Type {
    // Convert symmetric memref to LLVM pointer type for now
    // This is a simplified approach - in a full implementation we'd want proper
    // memref handling
    return LLVM::LLVMPointerType::get(type.getElementType().getContext());
  });

  patterns
      .add<InitOpLowering, FinalizeOpLowering, MyPeOpLowering, NPesOpLowering,
           MallocOpLowering, FreeOpLowering, PutOpLowering, GetOpLowering>(
          converter);
}

void openshmem::registerConvertOpenSHMEMToLLVMInterface(
    DialectRegistry &registry) {
  registry.addExtension(
      +[](MLIRContext *ctx, openshmem::OpenSHMEMDialect *dialect) {
        dialect->addInterfaces<OpenSHMEMToLLVMDialectInterface>();
      });
}
