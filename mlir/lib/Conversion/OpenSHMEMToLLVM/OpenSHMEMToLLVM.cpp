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

/// Extract raw pointer and size from memref for OpenSHMEM operations
std::pair<Value, Value> getRawPtrAndSize(const Location loc,
                                         ConversionPatternRewriter &rewriter,
                                         Value memRef, Type elType) {
  Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());
  Value dataPtr =
      rewriter.create<LLVM::ExtractValueOp>(loc, ptrType, memRef, 1);
  Value offset = rewriter.create<LLVM::ExtractValueOp>(
      loc, rewriter.getI64Type(), memRef, 2);
  Value resPtr =
      rewriter.create<LLVM::GEPOp>(loc, ptrType, elType, dataPtr, offset);

  // For size, we need to check the memref structure
  Value size;
  if (cast<LLVM::LLVMStructType>(memRef.getType()).getBody().size() > 3) {
    size = rewriter.create<LLVM::ExtractValueOp>(loc, memRef,
                                                 ArrayRef<int64_t>{3, 0});
    size = rewriter.create<LLVM::TruncOp>(loc, rewriter.getI64Type(), size);
  } else {
    size = rewriter.create<arith::ConstantIntOp>(loc, 1, 64);
  }
  return {resPtr, size};
}

//===----------------------------------------------------------------------===//
// Conversion patterns for OpenSHMEM operations
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

    // Convert the result memref type to LLVM struct type
    auto memrefType = cast<MemRefType>(op.getResult(0).getType());
    auto convertedType = typeConverter->convertType(memrefType);
    if (!convertedType)
      return failure();

    // Create a memref descriptor from the malloc'd pointer
    auto memrefDescriptor = MemRefDescriptor::fromStaticShape(
        rewriter, loc, *static_cast<const LLVMTypeConverter *>(typeConverter),
        memrefType, callOp.getResult());

    SmallVector<Value> replacements;
    replacements.push_back(memrefDescriptor);
    if (op.getRetval()) {
      // Return success (0) for now
      Value success = rewriter.create<arith::ConstantIntOp>(loc, 0, 32);
      replacements.push_back(success);
    }

    rewriter.replaceOp(op, replacements);
    return success();
  }
};

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

    // Extract pointer from memref
    Value dataPtr = rewriter.create<LLVM::ExtractValueOp>(loc, ptrType,
                                                          adaptor.getPtr(), 1);

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

struct PutOpLowering : public ConvertOpToLLVMPattern<openshmem::PutOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::PutOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());
    Type elemType = op.getDest().getType().getElementType();

    // Extract pointers and size
    auto [destPtr, destSize] =
        getRawPtrAndSize(loc, rewriter, adaptor.getDest(), elemType);
    auto [srcPtr, srcSize] =
        getRawPtrAndSize(loc, rewriter, adaptor.getSrc(), elemType);

    // void shmem_put_nbi(void *dest, const void *source, size_t nelems, int pe)
    auto funcType = LLVM::LLVMFunctionType::get(
        rewriter.getI32Type(),
        {ptrType, ptrType, rewriter.getI64Type(), rewriter.getI32Type()});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, "shmem_put_nbi", funcType);

    // Replace with function call
    auto callOp = rewriter.create<LLVM::CallOp>(
        loc, funcDecl,
        ValueRange{destPtr, srcPtr, adaptor.getSize(), adaptor.getPe()});

    if (op.getRetval())
      rewriter.replaceOp(op, callOp.getResult());
    else
      rewriter.eraseOp(op);

    return success();
  }
};

struct GetOpLowering : public ConvertOpToLLVMPattern<openshmem::GetOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::GetOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());
    Type elemType = op.getDest().getType().getElementType();

    // Extract pointers and size
    auto [destPtr, destSize] =
        getRawPtrAndSize(loc, rewriter, adaptor.getDest(), elemType);
    auto [srcPtr, srcSize] =
        getRawPtrAndSize(loc, rewriter, adaptor.getSrc(), elemType);

    // void shmem_get_nbi(void *dest, const void *source, size_t nelems, int pe)
    auto funcType = LLVM::LLVMFunctionType::get(
        rewriter.getI32Type(),
        {ptrType, ptrType, rewriter.getI64Type(), rewriter.getI32Type()});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, "shmem_get_nbi", funcType);

    // Replace with function call
    auto callOp = rewriter.create<LLVM::CallOp>(
        loc, funcDecl,
        ValueRange{destPtr, srcPtr, adaptor.getSize(), adaptor.getPe()});

    if (op.getRetval())
      rewriter.replaceOp(op, callOp.getResult());
    else
      rewriter.eraseOp(op);

    return success();
  }
};

struct SymmetricCastOpLowering
    : public ConvertOpToLLVMPattern<openshmem::SymmetricCastOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::SymmetricCastOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    // This is just a type cast operation, so we just pass through the value
    rewriter.replaceOp(op, adaptor.getMemref());
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

} // namespace

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

//===----------------------------------------------------------------------===//
// Pattern population and pass creation
//===----------------------------------------------------------------------===//

void openshmem::populateOpenSHMEMToLLVMConversionPatterns(
    LLVMTypeConverter &converter, RewritePatternSet &patterns) {

  // Add type conversions for OpenSHMEM types
  // Note: We no longer need conversions for PEType and SizeType since we use
  // standard types now

  converter.addConversion([](openshmem::RetvalType type) -> Type {
    return IntegerType::get(type.getContext(),
                            32); // return values are typically int
  });

  converter.addConversion([](openshmem::SymmetricMemRefType type) -> Type {
    return LLVM::LLVMPointerType::get(
        type.getContext()); // symmetric memref becomes a pointer
  });

  // Remove constant operations since we use arith.constant now
  patterns.add<InitOpLowering, FinalizeOpLowering, MyPeOpLowering,
               NPesOpLowering, MallocOpLowering, FreeOpLowering, PutOpLowering,
               GetOpLowering, SymmetricCastOpLowering>(converter);
}

void openshmem::registerConvertOpenSHMEMToLLVMInterface(
    DialectRegistry &registry) {
  registry.addExtension(
      +[](MLIRContext *ctx, openshmem::OpenSHMEMDialect *dialect) {
        dialect->addInterfaces<OpenSHMEMToLLVMDialectInterface>();
      });
}