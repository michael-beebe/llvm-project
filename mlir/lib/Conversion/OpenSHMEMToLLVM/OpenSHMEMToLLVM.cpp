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
#include "mlir/Support/LLVM.h"
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

/// Utility to get or define a function in the module
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

/// Utility to extract the data pointer from a memref
static Value getMemRefDataPtr(Location loc, ConversionPatternRewriter &rewriter,
                              Value memref) {
  // Assumes memref is a MemRef descriptor (struct), extract the pointer (field
  // 0)
  auto ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());
  return rewriter.create<LLVM::ExtractValueOp>(loc, ptrType, memref, 0);
}

/// Utility to extract element type from symmetric memref
static Type getSymmetricMemRefElementType(Value symmetricMemRef) {
  auto symMemRefType =
      llvm::dyn_cast<openshmem::SymmetricMemRefType>(symmetricMemRef.getType());
  if (!symMemRefType) {
    return nullptr;
  }
  return symMemRefType.getElementType();
}

/// Utility to generate typed function names based on element type
static std::string getTypedFunctionName(StringRef baseName, Type elementType) {
  std::string funcName = "shmem_";
  funcName += baseName.str();

  // Map MLIR types to OpenSHMEM type suffixes
  if (elementType.isInteger(8)) {
    funcName += "8";
  } else if (elementType.isInteger(16)) {
    funcName += "16";
  } else if (elementType.isInteger(32)) {
    funcName += "32";
  } else if (elementType.isInteger(64)) {
    funcName += "64";
  } else if (elementType.isF32()) {
    funcName += "32";
  } else if (elementType.isF64()) {
    funcName += "64";
  } else if (elementType.isF128()) {
    funcName += "128";
  } else {
    // For unsupported types, fall back to generic name
    // This should be validated earlier in the process
    funcName = "shmem_" + baseName.str();
  }

  return funcName;
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

    // void shmem_init(void)
    auto funcType = LLVM::LLVMFunctionType::get(
        mlir::LLVM::LLVMVoidType::get(rewriter.getContext()), {});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, "shmem_init", funcType);

    // Replace with function call
    rewriter.create<LLVM::CallOp>(loc, funcDecl, ValueRange{});
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
    auto funcType = LLVM::LLVMFunctionType::get(
        mlir::LLVM::LLVMVoidType::get(rewriter.getContext()), {});
    LLVM::LLVMFuncOp funcDecl = getOrDefineFunction(moduleOp, loc, rewriter,
                                                    "shmem_finalize", funcType);

    // Replace with function call
    rewriter.create<LLVM::CallOp>(loc, funcDecl, ValueRange{});
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

//===----------------------------------------------------------------------===//
// BarrierAllOp Lowering
//===----------------------------------------------------------------------===//

struct BarrierAllOpLowering
    : public ConvertOpToLLVMPattern<openshmem::BarrierAllOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::BarrierAllOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();

    // void shmem_barrier_all(void)
    auto funcType = LLVM::LLVMFunctionType::get(
        mlir::LLVM::LLVMVoidType::get(rewriter.getContext()), {});
    LLVM::LLVMFuncOp funcDecl = getOrDefineFunction(
        moduleOp, loc, rewriter, "shmem_barrier_all", funcType);

    // Replace with function call
    rewriter.create<LLVM::CallOp>(loc, funcDecl, ValueRange{});
    rewriter.eraseOp(op);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// QuietOp Lowering
//===----------------------------------------------------------------------===//

struct QuietOpLowering : public ConvertOpToLLVMPattern<openshmem::QuietOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::QuietOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();

    // void shmem_quiet(void)
    auto funcType = LLVM::LLVMFunctionType::get(
        mlir::LLVM::LLVMVoidType::get(rewriter.getContext()), {});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, "shmem_quiet", funcType);

    // Replace with function call
    rewriter.create<LLVM::CallOp>(loc, funcDecl, ValueRange{});
    rewriter.eraseOp(op);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// BarrierOp Lowering (deprecated)
//===----------------------------------------------------------------------===//

struct BarrierOpLowering : public ConvertOpToLLVMPattern<openshmem::BarrierOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::BarrierOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());

    // void shmem_barrier(int PE_start, int logPE_stride, int PE_size, long
    // *pSync)
    auto funcType = LLVM::LLVMFunctionType::get(
        mlir::LLVM::LLVMVoidType::get(rewriter.getContext()),
        {rewriter.getI32Type(), rewriter.getI32Type(), rewriter.getI32Type(),
         ptrType});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, "shmem_barrier", funcType);

    // The psync argument is already a pointer (symmetric_memref converts to
    // pointer)
    Value psyncPtr = adaptor.getPsync();

    rewriter.create<LLVM::CallOp>(loc, funcDecl,
                                  ValueRange{adaptor.getPeStart(),
                                             adaptor.getLogPeStride(),
                                             adaptor.getPeSize(), psyncPtr});
    rewriter.eraseOp(op);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// TeamSplitStridedOp Lowering
//===----------------------------------------------------------------------===//

struct TeamSplitStridedOpLowering
    : public ConvertOpToLLVMPattern<openshmem::TeamSplitStridedOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::TeamSplitStridedOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());

    // int shmem_team_split_strided(shmem_team_t parent_team, int start, int
    // stride, int size,
    //                              const shmem_team_config_t *config, long
    //                              config_mask, shmem_team_t *new_team)
    auto funcType = LLVM::LLVMFunctionType::get(
        rewriter.getI32Type(),
        {ptrType, rewriter.getI32Type(), rewriter.getI32Type(),
         rewriter.getI32Type(), ptrType, rewriter.getI64Type(), ptrType});
    LLVM::LLVMFuncOp funcDecl = getOrDefineFunction(
        moduleOp, loc, rewriter, "shmem_team_split_strided", funcType);

    // Allocate space for the new team
    Value one = rewriter.create<LLVM::ConstantOp>(
        loc, rewriter.getI32Type(), rewriter.getI32IntegerAttr(1));
    Value newTeamPtr =
        rewriter.create<LLVM::AllocaOp>(loc, ptrType, ptrType, one);

    // Pass NULL for config and 0 for config_mask (simplified)
    Value nullPtr = rewriter.create<LLVM::ZeroOp>(loc, ptrType);
    Value zeroMask = rewriter.create<LLVM::ConstantOp>(
        loc, rewriter.getI64Type(), rewriter.getI64IntegerAttr(0));

    auto callOp = rewriter.create<LLVM::CallOp>(
        loc, funcDecl,
        ValueRange{adaptor.getParentTeam(), adaptor.getStart(),
                   adaptor.getStride(), adaptor.getSize(), nullPtr, zeroMask,
                   newTeamPtr});

    // Load the new team pointer
    Value newTeam = rewriter.create<LLVM::LoadOp>(loc, ptrType, newTeamPtr);

    SmallVector<Value> replacements;
    replacements.push_back(newTeam);
    replacements.push_back(callOp.getResult());

    rewriter.replaceOp(op, replacements);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// TeamSplit2dOp Lowering
//===----------------------------------------------------------------------===//

struct TeamSplit2dOpLowering
    : public ConvertOpToLLVMPattern<openshmem::TeamSplit2dOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::TeamSplit2dOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());

    // int shmem_team_split_2d(shmem_team_t parent_team, int xrange,
    //                         const shmem_team_config_t *xaxis_config, long
    //                         xaxis_mask, shmem_team_t *xaxis_team, const
    //                         shmem_team_config_t *yaxis_config, long
    //                         yaxis_mask, shmem_team_t *yaxis_team)
    auto funcType = LLVM::LLVMFunctionType::get(
        rewriter.getI32Type(),
        {ptrType, rewriter.getI32Type(), ptrType, rewriter.getI64Type(),
         ptrType, ptrType, rewriter.getI64Type(), ptrType});
    LLVM::LLVMFuncOp funcDecl = getOrDefineFunction(
        moduleOp, loc, rewriter, "shmem_team_split_2d", funcType);

    // Allocate space for the new teams
    Value one = rewriter.create<LLVM::ConstantOp>(
        loc, rewriter.getI32Type(), rewriter.getI32IntegerAttr(1));
    Value xaxisTeamPtr =
        rewriter.create<LLVM::AllocaOp>(loc, ptrType, ptrType, one);
    Value yaxisTeamPtr =
        rewriter.create<LLVM::AllocaOp>(loc, ptrType, ptrType, one);

    // Pass NULL for configs and 0 for config_masks (simplified)
    Value nullPtr = rewriter.create<LLVM::ZeroOp>(loc, ptrType);
    Value zeroMask = rewriter.create<LLVM::ConstantOp>(
        loc, rewriter.getI64Type(), rewriter.getI64IntegerAttr(0));

    auto callOp = rewriter.create<LLVM::CallOp>(
        loc, funcDecl,
        ValueRange{adaptor.getParentTeam(), adaptor.getXrange(), nullPtr,
                   zeroMask, xaxisTeamPtr, nullPtr, zeroMask, yaxisTeamPtr});

    // Load the new team pointers
    Value xaxisTeam = rewriter.create<LLVM::LoadOp>(loc, ptrType, xaxisTeamPtr);
    Value yaxisTeam = rewriter.create<LLVM::LoadOp>(loc, ptrType, yaxisTeamPtr);

    SmallVector<Value> replacements;
    replacements.push_back(xaxisTeam);
    replacements.push_back(yaxisTeam);
    replacements.push_back(callOp.getResult());

    rewriter.replaceOp(op, replacements);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// TeamMyPeOp Lowering
//===----------------------------------------------------------------------===//

struct TeamMyPeOpLowering
    : public ConvertOpToLLVMPattern<openshmem::TeamMyPeOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::TeamMyPeOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());

    // int shmem_team_my_pe(shmem_team_t team)
    auto funcType =
        LLVM::LLVMFunctionType::get(rewriter.getI32Type(), {ptrType});
    LLVM::LLVMFuncOp funcDecl = getOrDefineFunction(
        moduleOp, loc, rewriter, "shmem_team_my_pe", funcType);

    auto callOp = rewriter.create<LLVM::CallOp>(loc, funcDecl,
                                                ValueRange{adaptor.getTeam()});
    rewriter.replaceOp(op, callOp.getResult());
    return success();
  }
};

//===----------------------------------------------------------------------===//
// TeamNPesOp Lowering
//===----------------------------------------------------------------------===//

struct TeamNPesOpLowering
    : public ConvertOpToLLVMPattern<openshmem::TeamNPesOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::TeamNPesOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());

    // int shmem_team_n_pes(shmem_team_t team)
    auto funcType =
        LLVM::LLVMFunctionType::get(rewriter.getI32Type(), {ptrType});
    LLVM::LLVMFuncOp funcDecl = getOrDefineFunction(
        moduleOp, loc, rewriter, "shmem_team_n_pes", funcType);

    auto callOp = rewriter.create<LLVM::CallOp>(loc, funcDecl,
                                                ValueRange{adaptor.getTeam()});
    rewriter.replaceOp(op, callOp.getResult());
    return success();
  }
};

//===----------------------------------------------------------------------===//
// TeamSyncOp Lowering
//===----------------------------------------------------------------------===//

struct TeamSyncOpLowering
    : public ConvertOpToLLVMPattern<openshmem::TeamSyncOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::TeamSyncOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());

    // void shmem_team_sync(shmem_team_t team)
    auto funcType = LLVM::LLVMFunctionType::get(
        mlir::LLVM::LLVMVoidType::get(rewriter.getContext()), {ptrType});
    LLVM::LLVMFuncOp funcDecl = getOrDefineFunction(
        moduleOp, loc, rewriter, "shmem_team_sync", funcType);

    rewriter.create<LLVM::CallOp>(loc, funcDecl, ValueRange{adaptor.getTeam()});
    rewriter.eraseOp(op);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// TeamDestroyOp Lowering
//===----------------------------------------------------------------------===//

struct TeamDestroyOpLowering
    : public ConvertOpToLLVMPattern<openshmem::TeamDestroyOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::TeamDestroyOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());

    // void shmem_team_destroy(shmem_team_t team)
    auto funcType = LLVM::LLVMFunctionType::get(
        mlir::LLVM::LLVMVoidType::get(rewriter.getContext()), {ptrType});
    LLVM::LLVMFuncOp funcDecl = getOrDefineFunction(
        moduleOp, loc, rewriter, "shmem_team_destroy", funcType);

    rewriter.create<LLVM::CallOp>(loc, funcDecl, ValueRange{adaptor.getTeam()});
    rewriter.eraseOp(op);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// TeamWorldOp Lowering
//===----------------------------------------------------------------------===//

struct TeamWorldOpLowering
    : public ConvertOpToLLVMPattern<openshmem::TeamWorldOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::TeamWorldOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());

    // Get SHMEM_TEAM_WORLD as a global constant
    // In practice, this would be a predefined constant in the OpenSHMEM library
    LLVM::GlobalOp globalTeamWorld;
    if (!(globalTeamWorld =
              moduleOp.lookupSymbol<LLVM::GlobalOp>("SHMEM_TEAM_WORLD"))) {
      ConversionPatternRewriter::InsertionGuard guard(rewriter);
      rewriter.setInsertionPointToStart(moduleOp.getBody());
      globalTeamWorld = rewriter.create<LLVM::GlobalOp>(
          loc, ptrType, /*isConstant=*/true, LLVM::Linkage::External,
          "SHMEM_TEAM_WORLD", Attribute{});
    }

    Value teamWorldAddr =
        rewriter.create<LLVM::AddressOfOp>(loc, globalTeamWorld);
    rewriter.replaceOp(op, teamWorldAddr);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// TeamSharedOp Lowering
//===----------------------------------------------------------------------===//

struct TeamSharedOpLowering
    : public ConvertOpToLLVMPattern<openshmem::TeamSharedOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::TeamSharedOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());

    // Get SHMEM_TEAM_SHARED as a global constant
    LLVM::GlobalOp globalTeamShared;
    if (!(globalTeamShared =
              moduleOp.lookupSymbol<LLVM::GlobalOp>("SHMEM_TEAM_SHARED"))) {
      ConversionPatternRewriter::InsertionGuard guard(rewriter);
      rewriter.setInsertionPointToStart(moduleOp.getBody());
      globalTeamShared = rewriter.create<LLVM::GlobalOp>(
          loc, ptrType, /*isConstant=*/true, LLVM::Linkage::External,
          "SHMEM_TEAM_SHARED", Attribute{});
    }

    Value teamSharedAddr =
        rewriter.create<LLVM::AddressOfOp>(loc, globalTeamShared);
    rewriter.replaceOp(op, teamSharedAddr);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// CtxCreateOp Lowering
//===----------------------------------------------------------------------===//

struct CtxCreateOpLowering
    : public ConvertOpToLLVMPattern<openshmem::CtxCreateOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::CtxCreateOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());
    Type i64Type = rewriter.getI64Type();
    Type i32Type = rewriter.getI32Type();

    // int shmem_ctx_create(long options, shmem_ctx_t *ctx)
    auto funcType = LLVM::LLVMFunctionType::get(i32Type, {i64Type, ptrType});
    LLVM::LLVMFuncOp funcDecl = getOrDefineFunction(
        moduleOp, loc, rewriter, "shmem_ctx_create", funcType);

    // Allocate space for the context handle
    Value one = rewriter.create<LLVM::ConstantOp>(
        loc, i32Type, rewriter.getI32IntegerAttr(1));
    Value ctxPtr = rewriter.create<LLVM::AllocaOp>(loc, ptrType, ptrType, one);

    // Call the function
    auto callOp = rewriter.create<LLVM::CallOp>(
        loc, funcDecl, ValueRange{adaptor.getOptions(), ctxPtr});

    // Load the context handle
    Value ctx = rewriter.create<LLVM::LoadOp>(loc, ptrType, ctxPtr);

    SmallVector<Value> replacements;
    replacements.push_back(ctx);
    replacements.push_back(callOp.getResult());
    rewriter.replaceOp(op, replacements);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// TeamCreateCtxOp Lowering
//===----------------------------------------------------------------------===//

struct TeamCreateCtxOpLowering
    : public ConvertOpToLLVMPattern<openshmem::TeamCreateCtxOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::TeamCreateCtxOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());
    Type i64Type = rewriter.getI64Type();
    Type i32Type = rewriter.getI32Type();

    // int shmem_team_create_ctx(shmem_team_t team, long options, shmem_ctx_t
    // *ctx)
    auto funcType =
        LLVM::LLVMFunctionType::get(i32Type, {ptrType, i64Type, ptrType});
    LLVM::LLVMFuncOp funcDecl = getOrDefineFunction(
        moduleOp, loc, rewriter, "shmem_team_create_ctx", funcType);

    // Allocate space for the context handle
    Value one = rewriter.create<LLVM::ConstantOp>(
        loc, i32Type, rewriter.getI32IntegerAttr(1));
    Value ctxPtr = rewriter.create<LLVM::AllocaOp>(loc, ptrType, ptrType, one);

    // Call the function
    auto callOp = rewriter.create<LLVM::CallOp>(
        loc, funcDecl,
        ValueRange{adaptor.getTeam(), adaptor.getOptions(), ctxPtr});

    // Load the context handle
    Value ctx = rewriter.create<LLVM::LoadOp>(loc, ptrType, ctxPtr);

    SmallVector<Value> replacements;
    replacements.push_back(ctx);
    replacements.push_back(callOp.getResult());
    rewriter.replaceOp(op, replacements);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// CtxDestroyOp Lowering
//===----------------------------------------------------------------------===//

struct CtxDestroyOpLowering
    : public ConvertOpToLLVMPattern<openshmem::CtxDestroyOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::CtxDestroyOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());

    // void shmem_ctx_destroy(shmem_ctx_t ctx)
    auto funcType = LLVM::LLVMFunctionType::get(
        mlir::LLVM::LLVMVoidType::get(rewriter.getContext()), {ptrType});
    LLVM::LLVMFuncOp funcDecl = getOrDefineFunction(
        moduleOp, loc, rewriter, "shmem_ctx_destroy", funcType);

    rewriter.create<LLVM::CallOp>(loc, funcDecl, ValueRange{adaptor.getCtx()});
    rewriter.eraseOp(op);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// CtxGetTeamOp Lowering
//===----------------------------------------------------------------------===//

struct CtxGetTeamOpLowering
    : public ConvertOpToLLVMPattern<openshmem::CtxGetTeamOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::CtxGetTeamOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());
    Type i32Type = rewriter.getI32Type();

    // int shmem_ctx_get_team(shmem_ctx_t ctx, shmem_team_t *team)
    auto funcType = LLVM::LLVMFunctionType::get(i32Type, {ptrType, ptrType});
    LLVM::LLVMFuncOp funcDecl = getOrDefineFunction(
        moduleOp, loc, rewriter, "shmem_ctx_get_team", funcType);

    // Allocate space for the team handle
    Value one = rewriter.create<LLVM::ConstantOp>(
        loc, i32Type, rewriter.getI32IntegerAttr(1));
    Value teamPtr = rewriter.create<LLVM::AllocaOp>(loc, ptrType, ptrType, one);

    // Call the function
    auto callOp = rewriter.create<LLVM::CallOp>(
        loc, funcDecl, ValueRange{adaptor.getCtx(), teamPtr});

    // Load the team handle
    Value team = rewriter.create<LLVM::LoadOp>(loc, ptrType, teamPtr);

    SmallVector<Value> replacements;
    replacements.push_back(team);
    replacements.push_back(callOp.getResult());
    rewriter.replaceOp(op, replacements);
    return success();
  }
};

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
// CollectmemOP Lowering
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

//===----------------------------------------------------------------------===//
// Typed Put Operations Lowering
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// PutOp Lowering (Typed - Generic)
//===----------------------------------------------------------------------===//

struct PutOpLowering : public ConvertOpToLLVMPattern<openshmem::PutOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::PutOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());

    // Get element type from symmetric memref
    Type elementType = getSymmetricMemRefElementType(op.getDest());
    if (!elementType) {
      return failure();
    }

    // Generate function name based on type
    std::string funcName = getTypedFunctionName("put", elementType);

    // void shmem_put(TYPE *dest, const TYPE *source, size_t nelems, int pe)
    Type sizeType = getTypeConverter()->getIndexType();
    auto funcType = LLVM::LLVMFunctionType::get(
        mlir::LLVM::LLVMVoidType::get(rewriter.getContext()),
        {ptrType, ptrType, sizeType, rewriter.getI32Type()});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, funcName, funcType);

    // dest: symmetric_memref (already a pointer after type conversion)
    Value destPtr = adaptor.getDest();
    // source: memref (need to extract pointer)
    Value sourcePtr = getMemRefDataPtr(loc, rewriter, adaptor.getSource());

    rewriter.create<LLVM::CallOp>(
        loc, funcDecl,
        ValueRange{destPtr, sourcePtr, adaptor.getNelems(), adaptor.getPe()});
    rewriter.eraseOp(op);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// CtxPutOp Lowering (Typed - Context-aware)
//===----------------------------------------------------------------------===//

struct CtxPutOpLowering : public ConvertOpToLLVMPattern<openshmem::CtxPutOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::CtxPutOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());

    // Get element type from symmetric memref
    Type elementType = getSymmetricMemRefElementType(op.getDest());
    if (!elementType) {
      return failure();
    }

    // Generate function name based on type
    std::string funcName = getTypedFunctionName("ctx_put", elementType);

    // void shmem_put(shmem_ctx_t ctx, TYPE *dest, const TYPE *source, size_t
    // nelems, int pe)
    Type sizeType = getTypeConverter()->getIndexType();
    auto funcType = LLVM::LLVMFunctionType::get(
        mlir::LLVM::LLVMVoidType::get(rewriter.getContext()),
        {ptrType, ptrType, ptrType, sizeType, rewriter.getI32Type()});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, funcName, funcType);

    // ctx: context (already a pointer after type conversion)
    Value ctxPtr = adaptor.getCtx();
    // dest: symmetric_memref (already a pointer after type conversion)
    Value destPtr = adaptor.getDest();
    // source: memref (need to extract pointer)
    Value sourcePtr = getMemRefDataPtr(loc, rewriter, adaptor.getSource());

    rewriter.create<LLVM::CallOp>(loc, funcDecl,
                                  ValueRange{ctxPtr, destPtr, sourcePtr,
                                             adaptor.getNelems(),
                                             adaptor.getPe()});
    rewriter.eraseOp(op);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// PutNbiOp Lowering (Typed - Non-blocking)
//===----------------------------------------------------------------------===//

struct PutNbiOpLowering : public ConvertOpToLLVMPattern<openshmem::PutNbiOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::PutNbiOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());

    // Get element type from symmetric memref
    Type elementType = getSymmetricMemRefElementType(op.getDest());
    if (!elementType) {
      return failure();
    }

    // Generate function name based on type
    std::string funcName = getTypedFunctionName("put_nbi", elementType);

    // void shmem_put_n(TYPE *dest, const TYPE *source, size_t nelems, int pe)
    Type sizeType = getTypeConverter()->getIndexType();
    auto funcType = LLVM::LLVMFunctionType::get(
        mlir::LLVM::LLVMVoidType::get(rewriter.getContext()),
        {ptrType, ptrType, sizeType, rewriter.getI32Type()});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, funcName, funcType);

    // dest: symmetric_memref (already a pointer after type conversion)
    Value destPtr = adaptor.getDest();
    // source: memref (need to extract pointer)
    Value sourcePtr = getMemRefDataPtr(loc, rewriter, adaptor.getSource());

    rewriter.create<LLVM::CallOp>(
        loc, funcDecl,
        ValueRange{destPtr, sourcePtr, adaptor.getNelems(), adaptor.getPe()});
    rewriter.eraseOp(op);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// CtxPutNbiOp Lowering (Typed - Context-aware Non-blocking)
//===----------------------------------------------------------------------===//

struct CtxPutNbiOpLowering
    : public ConvertOpToLLVMPattern<openshmem::CtxPutNbiOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::CtxPutNbiOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());

    // Get element type from symmetric memref
    Type elementType = getSymmetricMemRefElementType(op.getDest());
    if (!elementType) {
      return failure();
    }

    // Generate function name based on type
    std::string funcName = getTypedFunctionName("put_nbi", elementType);

    // void shmem_put_nbi(shmem_ctx_t ctx, TYPE *dest, const TYPE *source,
    // size_t nelems, int pe)
    Type sizeType = getTypeConverter()->getIndexType();
    auto funcType = LLVM::LLVMFunctionType::get(
        mlir::LLVM::LLVMVoidType::get(rewriter.getContext()),
        {ptrType, ptrType, ptrType, sizeType, rewriter.getI32Type()});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, funcName, funcType);

    // ctx: context (already a pointer after type conversion)
    Value ctxPtr = adaptor.getCtx();
    // dest: symmetric_memref (already a pointer after type conversion)
    Value destPtr = adaptor.getDest();
    // source: memref (need to extract pointer)
    Value sourcePtr = getMemRefDataPtr(loc, rewriter, adaptor.getSource());

    rewriter.create<LLVM::CallOp>(loc, funcDecl,
                                  ValueRange{ctxPtr, destPtr, sourcePtr,
                                             adaptor.getNelems(),
                                             adaptor.getPe()});
    rewriter.eraseOp(op);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// PutSizedOp Lowering (Sized variants)
//===----------------------------------------------------------------------===//

#define GEN_PUT_SIZED_LOWERING(SZ)                                             \
  struct Put##SZ##OpLowering                                                   \
      : public ConvertOpToLLVMPattern<openshmem::Put##SZ##Op> {                \
    using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;                      \
    LogicalResult                                                              \
    matchAndRewrite(openshmem::Put##SZ##Op op, OpAdaptor adaptor,              \
                    ConversionPatternRewriter &rewriter) const override {      \
      Location loc = op.getLoc();                                              \
      auto moduleOp = op->getParentOfType<ModuleOp>();                         \
      Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());        \
      Type sizeType = getTypeConverter()->getIndexType();                      \
      auto funcType = LLVM::LLVMFunctionType::get(                             \
          mlir::LLVM::LLVMVoidType::get(rewriter.getContext()),                \
          {ptrType, ptrType, sizeType, rewriter.getI32Type()});                \
      LLVM::LLVMFuncOp funcDecl = getOrDefineFunction(                         \
          moduleOp, loc, rewriter, "shmem_put" #SZ, funcType);                 \
      Value destPtr = adaptor.getDest();                                       \
      Value sourcePtr = getMemRefDataPtr(loc, rewriter, adaptor.getSource());  \
      rewriter.create<LLVM::CallOp>(loc, funcDecl,                             \
                                    ValueRange{destPtr, sourcePtr,             \
                                               adaptor.getNelems(),            \
                                               adaptor.getPe()});              \
      rewriter.eraseOp(op);                                                    \
      return success();                                                        \
    }                                                                          \
  };
GEN_PUT_SIZED_LOWERING(8)
GEN_PUT_SIZED_LOWERING(16)
GEN_PUT_SIZED_LOWERING(32)
GEN_PUT_SIZED_LOWERING(64)
GEN_PUT_SIZED_LOWERING(128)
#undef GEN_PUT_SIZED_LOWERING

//===----------------------------------------------------------------------===//
// CtxPut8/16/32/64/128Op Lowering (Context-aware Sized)
//===----------------------------------------------------------------------===//
#define GEN_CTX_PUT_SIZED_LOWERING(SZ)                                         \
  struct CtxPut##SZ##OpLowering                                                \
      : public ConvertOpToLLVMPattern<openshmem::CtxPut##SZ##Op> {             \
    using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;                      \
    LogicalResult                                                              \
    matchAndRewrite(openshmem::CtxPut##SZ##Op op, OpAdaptor adaptor,           \
                    ConversionPatternRewriter &rewriter) const override {      \
      Location loc = op.getLoc();                                              \
      auto moduleOp = op->getParentOfType<ModuleOp>();                         \
      Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());        \
      Type sizeType = getTypeConverter()->getIndexType();                      \
      auto funcType = LLVM::LLVMFunctionType::get(                             \
          mlir::LLVM::LLVMVoidType::get(rewriter.getContext()),                \
          {ptrType, ptrType, ptrType, sizeType, rewriter.getI32Type()});       \
      LLVM::LLVMFuncOp funcDecl = getOrDefineFunction(                         \
          moduleOp, loc, rewriter, "shmem_ctx_put" #SZ, funcType);             \
      Value ctxPtr = adaptor.getCtx();                                         \
      Value destPtr = adaptor.getDest();                                       \
      Value sourcePtr = getMemRefDataPtr(loc, rewriter, adaptor.getSource());  \
      rewriter.create<LLVM::CallOp>(loc, funcDecl,                             \
                                    ValueRange{ctxPtr, destPtr, sourcePtr,     \
                                               adaptor.getNelems(),            \
                                               adaptor.getPe()});              \
      rewriter.eraseOp(op);                                                    \
      return success();                                                        \
    }                                                                          \
  };
GEN_CTX_PUT_SIZED_LOWERING(8)
GEN_CTX_PUT_SIZED_LOWERING(16)
GEN_CTX_PUT_SIZED_LOWERING(32)
GEN_CTX_PUT_SIZED_LOWERING(64)
GEN_CTX_PUT_SIZED_LOWERING(128)
#undef GEN_CTX_PUT_SIZED_LOWERING

//===----------------------------------------------------------------------===//
// PutmemOp Lowering
//===----------------------------------------------------------------------===//

struct PutmemOpLowering : public ConvertOpToLLVMPattern<openshmem::PutmemOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::PutmemOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());

    // dest: symmetric_memref (already a pointer after type conversion)
    Value destPtr = adaptor.getDest();
    // src: memref (need to extract pointer)
    Value srcPtr = getMemRefDataPtr(loc, rewriter, adaptor.getSrc());

    // void shmem_putmem(void *dest, const void *source, size_t nelems, int pe)
    // Note: for putmem, nelems represents the number of bytes to transfer
    // size_t is typically the same as index type on the target platform
    Type sizeType = getTypeConverter()->getIndexType();
    auto funcType = LLVM::LLVMFunctionType::get(
        mlir::LLVM::LLVMVoidType::get(rewriter.getContext()),
        {ptrType, ptrType, sizeType, rewriter.getI32Type()});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, "shmem_putmem", funcType);

    rewriter.create<LLVM::CallOp>(
        loc, funcDecl,
        ValueRange{destPtr, srcPtr, adaptor.getSize(), adaptor.getPe()});
    rewriter.eraseOp(op);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// PutmemNbiOp Lowering
//===----------------------------------------------------------------------===//

struct PutmemNbiOpLowering
    : public ConvertOpToLLVMPattern<openshmem::PutmemNbiOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::PutmemNbiOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());

    // dest: symmetric_memref (already a pointer after type conversion)
    Value destPtr = adaptor.getDest();
    // src: memref (need to extract pointer)
    Value srcPtr = getMemRefDataPtr(loc, rewriter, adaptor.getSrc());

    // void shmem_putmem_nbi(void *dest, const void *source, size_t nelems, int
    // pe)
    Type sizeType = getTypeConverter()->getIndexType();
    auto funcType = LLVM::LLVMFunctionType::get(
        mlir::LLVM::LLVMVoidType::get(rewriter.getContext()),
        {ptrType, ptrType, sizeType, rewriter.getI32Type()});
    LLVM::LLVMFuncOp funcDecl = getOrDefineFunction(
        moduleOp, loc, rewriter, "shmem_putmem_nbi", funcType);

    rewriter.create<LLVM::CallOp>(
        loc, funcDecl,
        ValueRange{destPtr, srcPtr, adaptor.getNelems(), adaptor.getPe()});
    rewriter.eraseOp(op);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// GetmemOp Lowering
//===----------------------------------------------------------------------===//

struct GetmemOpLowering : public ConvertOpToLLVMPattern<openshmem::GetmemOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::GetmemOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());

    // dest: memref (need to extract pointer)
    Value destPtr = getMemRefDataPtr(loc, rewriter, adaptor.getDest());
    // src: symmetric_memref (already a pointer after type conversion)
    Value srcPtr = adaptor.getSrc();

    // void shmem_getmem(void *dest, const void *source, size_t nelems, int pe)
    // Note: for getmem, nelems represents the number of bytes to transfer
    // size_t is typically the same as index type on the target platform
    Type sizeType = getTypeConverter()->getIndexType();
    auto funcType = LLVM::LLVMFunctionType::get(
        mlir::LLVM::LLVMVoidType::get(rewriter.getContext()),
        {ptrType, ptrType, sizeType, rewriter.getI32Type()});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, "shmem_getmem", funcType);

    rewriter.create<LLVM::CallOp>(
        loc, funcDecl,
        ValueRange{destPtr, srcPtr, adaptor.getSize(), adaptor.getPe()});
    rewriter.eraseOp(op);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// GetmemNbiOp Lowering
//===----------------------------------------------------------------------===//

struct GetmemNbiOpLowering
    : public ConvertOpToLLVMPattern<openshmem::GetmemNbiOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(openshmem::GetmemNbiOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());

    // dest: memref (need to extract pointer)
    Value destPtr = getMemRefDataPtr(loc, rewriter, adaptor.getDest());
    // src: symmetric_memref (already a pointer after type conversion)
    Value srcPtr = adaptor.getSrc();

    // void shmem_getmem_nbi(void *dest, const void *source, size_t nelems, int
    // pe)
    Type sizeType = getTypeConverter()->getIndexType();
    auto funcType = LLVM::LLVMFunctionType::get(
        mlir::LLVM::LLVMVoidType::get(rewriter.getContext()),
        {ptrType, ptrType, sizeType, rewriter.getI32Type()});
    LLVM::LLVMFuncOp funcDecl = getOrDefineFunction(
        moduleOp, loc, rewriter, "shmem_getmem_nbi", funcType);

    rewriter.create<LLVM::CallOp>(
        loc, funcDecl,
        ValueRange{destPtr, srcPtr, adaptor.getNelems(), adaptor.getPe()});
    rewriter.eraseOp(op);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// GetOp Lowering (Typed - Generic)
//===----------------------------------------------------------------------===//
struct GetOpLowering : public ConvertOpToLLVMPattern<openshmem::GetOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;
  LogicalResult
  matchAndRewrite(openshmem::GetOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());
    Type elementType = getSymmetricMemRefElementType(op.getSource());
    if (!elementType)
      return failure();
    std::string funcName = getTypedFunctionName("get", elementType);
    Type sizeType = getTypeConverter()->getIndexType();
    auto funcType = LLVM::LLVMFunctionType::get(
        mlir::LLVM::LLVMVoidType::get(rewriter.getContext()),
        {ptrType, ptrType, sizeType, rewriter.getI32Type()});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, funcName, funcType);
    Value destPtr = getMemRefDataPtr(loc, rewriter, adaptor.getDest());
    Value sourcePtr = adaptor.getSource();
    rewriter.create<LLVM::CallOp>(
        loc, funcDecl,
        ValueRange{destPtr, sourcePtr, adaptor.getNelems(), adaptor.getPe()});
    rewriter.eraseOp(op);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// CtxGetOp Lowering (Typed - Context-aware)
//===----------------------------------------------------------------------===//
struct CtxGetOpLowering : public ConvertOpToLLVMPattern<openshmem::CtxGetOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;
  LogicalResult
  matchAndRewrite(openshmem::CtxGetOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());
    Type elementType = getSymmetricMemRefElementType(op.getSource());
    if (!elementType)
      return failure();
    std::string funcName = getTypedFunctionName("ctx_get", elementType);
    Type sizeType = getTypeConverter()->getIndexType();
    auto funcType = LLVM::LLVMFunctionType::get(
        mlir::LLVM::LLVMVoidType::get(rewriter.getContext()),
        {ptrType, ptrType, ptrType, sizeType, rewriter.getI32Type()});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, funcName, funcType);
    Value ctxPtr = adaptor.getCtx();
    Value destPtr = getMemRefDataPtr(loc, rewriter, adaptor.getDest());
    Value sourcePtr = adaptor.getSource();
    rewriter.create<LLVM::CallOp>(loc, funcDecl,
                                  ValueRange{ctxPtr, destPtr, sourcePtr,
                                             adaptor.getNelems(),
                                             adaptor.getPe()});
    rewriter.eraseOp(op);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// GetNbiOp Lowering (Typed - Non-blocking)
//===----------------------------------------------------------------------===//
struct GetNbiOpLowering : public ConvertOpToLLVMPattern<openshmem::GetNbiOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;
  LogicalResult
  matchAndRewrite(openshmem::GetNbiOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());
    Type elementType = getSymmetricMemRefElementType(op.getSource());
    if (!elementType)
      return failure();
    std::string funcName = getTypedFunctionName("get_nbi", elementType);
    Type sizeType = getTypeConverter()->getIndexType();
    auto funcType = LLVM::LLVMFunctionType::get(
        mlir::LLVM::LLVMVoidType::get(rewriter.getContext()),
        {ptrType, ptrType, sizeType, rewriter.getI32Type()});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, funcName, funcType);
    Value destPtr = getMemRefDataPtr(loc, rewriter, adaptor.getDest());
    Value sourcePtr = adaptor.getSource();
    rewriter.create<LLVM::CallOp>(
        loc, funcDecl,
        ValueRange{destPtr, sourcePtr, adaptor.getNelems(), adaptor.getPe()});
    rewriter.eraseOp(op);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// CtxGetNbiOp Lowering (Typed - Context-aware Non-blocking)
//===----------------------------------------------------------------------===//
struct CtxGetNbiOpLowering
    : public ConvertOpToLLVMPattern<openshmem::CtxGetNbiOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;
  LogicalResult
  matchAndRewrite(openshmem::CtxGetNbiOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    auto moduleOp = op->getParentOfType<ModuleOp>();
    Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());
    Type elementType = getSymmetricMemRefElementType(op.getSource());
    if (!elementType)
      return failure();
    std::string funcName = getTypedFunctionName("ctx_get_nbi", elementType);
    Type sizeType = getTypeConverter()->getIndexType();
    auto funcType = LLVM::LLVMFunctionType::get(
        mlir::LLVM::LLVMVoidType::get(rewriter.getContext()),
        {ptrType, ptrType, ptrType, sizeType, rewriter.getI32Type()});
    LLVM::LLVMFuncOp funcDecl =
        getOrDefineFunction(moduleOp, loc, rewriter, funcName, funcType);
    Value ctxPtr = adaptor.getCtx();
    Value destPtr = getMemRefDataPtr(loc, rewriter, adaptor.getDest());
    Value sourcePtr = adaptor.getSource();
    rewriter.create<LLVM::CallOp>(loc, funcDecl,
                                  ValueRange{ctxPtr, destPtr, sourcePtr,
                                             adaptor.getNelems(),
                                             adaptor.getPe()});
    rewriter.eraseOp(op);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// Get8/16/32/64/128Op Lowering (Sized)
//===----------------------------------------------------------------------===//
#define GEN_GET_SIZED_LOWERING(SZ)                                             \
  struct Get##SZ##OpLowering                                                   \
      : public ConvertOpToLLVMPattern<openshmem::Get##SZ##Op> {                \
    using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;                      \
    LogicalResult                                                              \
    matchAndRewrite(openshmem::Get##SZ##Op op, OpAdaptor adaptor,              \
                    ConversionPatternRewriter &rewriter) const override {      \
      Location loc = op.getLoc();                                              \
      auto moduleOp = op->getParentOfType<ModuleOp>();                         \
      Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());        \
      Type sizeType = getTypeConverter()->getIndexType();                      \
      auto funcType = LLVM::LLVMFunctionType::get(                             \
          mlir::LLVM::LLVMVoidType::get(rewriter.getContext()),                \
          {ptrType, ptrType, sizeType, rewriter.getI32Type()});                \
      LLVM::LLVMFuncOp funcDecl = getOrDefineFunction(                         \
          moduleOp, loc, rewriter, "shmem_get" #SZ, funcType);                 \
      Value destPtr = getMemRefDataPtr(loc, rewriter, adaptor.getDest());      \
      Value sourcePtr = adaptor.getSource();                                   \
      rewriter.create<LLVM::CallOp>(loc, funcDecl,                             \
                                    ValueRange{destPtr, sourcePtr,             \
                                               adaptor.getNelems(),            \
                                               adaptor.getPe()});              \
      rewriter.eraseOp(op);                                                    \
      return success();                                                        \
    }                                                                          \
  };
GEN_GET_SIZED_LOWERING(8)
GEN_GET_SIZED_LOWERING(16)
GEN_GET_SIZED_LOWERING(32)
GEN_GET_SIZED_LOWERING(64)
GEN_GET_SIZED_LOWERING(128)
#undef GEN_GET_SIZED_LOWERING

//===----------------------------------------------------------------------===//
// CtxGet8/16/32/64/128Op Lowering (Context-aware Sized)
//===----------------------------------------------------------------------===//
#define GEN_CTX_GET_SIZED_LOWERING(SZ)                                         \
  struct CtxGet##SZ##OpLowering                                                \
      : public ConvertOpToLLVMPattern<openshmem::CtxGet##SZ##Op> {             \
    using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;                      \
    LogicalResult                                                              \
    matchAndRewrite(openshmem::CtxGet##SZ##Op op, OpAdaptor adaptor,           \
                    ConversionPatternRewriter &rewriter) const override {      \
      Location loc = op.getLoc();                                              \
      auto moduleOp = op->getParentOfType<ModuleOp>();                         \
      Type ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());        \
      Type sizeType = getTypeConverter()->getIndexType();                      \
      auto funcType = LLVM::LLVMFunctionType::get(                             \
          mlir::LLVM::LLVMVoidType::get(rewriter.getContext()),                \
          {ptrType, ptrType, ptrType, sizeType, rewriter.getI32Type()});       \
      LLVM::LLVMFuncOp funcDecl = getOrDefineFunction(                         \
          moduleOp, loc, rewriter, "shmem_ctx_get" #SZ, funcType);             \
      Value ctxPtr = adaptor.getCtx();                                         \
      Value destPtr = getMemRefDataPtr(loc, rewriter, adaptor.getDest());      \
      Value sourcePtr = adaptor.getSource();                                   \
      rewriter.create<LLVM::CallOp>(loc, funcDecl,                             \
                                    ValueRange{ctxPtr, destPtr, sourcePtr,     \
                                               adaptor.getNelems(),            \
                                               adaptor.getPe()});              \
      rewriter.eraseOp(op);                                                    \
      return success();                                                        \
    }                                                                          \
  };
GEN_CTX_GET_SIZED_LOWERING(8)
GEN_CTX_GET_SIZED_LOWERING(16)
GEN_CTX_GET_SIZED_LOWERING(32)
GEN_CTX_GET_SIZED_LOWERING(64)
GEN_CTX_GET_SIZED_LOWERING(128)
#undef GEN_CTX_GET_SIZED_LOWERING

//===----------------------------------------------------------------------===//
// AtomicFetchOp Lowering (Typed - Generic)
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

//===----------------------------------------------------------------------===//
// CtxAtomicFetchOp Lowering (Typed - Context-aware)
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

//===----------------------------------------------------------------------===//
// AtomicSetOp Lowering (Typed - Generic)
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
// CtxAtomicSetOp Lowering (Typed - Context-aware)
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

} // namespace

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

//===----------------------------------------------------------------------===//
// Pattern population and pass creation
//===----------------------------------------------------------------------===//

void openshmem::populateOpenSHMEMToLLVMConversionPatterns(
    LLVMTypeConverter &converter, RewritePatternSet &patterns) {

  // Add type conversions for OpenSHMEM types
  // Note: OpenSHMEM_Retval has been removed and replaced with I32

  converter.addConversion([](openshmem::SymmetricMemRefType type) -> Type {
    // Convert symmetric memref to LLVM pointer type for now
    // This is a simplified approach - in a full implementation we'd want proper
    // memref handling
    return LLVM::LLVMPointerType::get(type.getElementType().getContext());
  });

  converter.addConversion([](openshmem::TeamType type) -> Type {
    // Convert team to LLVM pointer type (shmem_team_t is typically a pointer)
    return LLVM::LLVMPointerType::get(type.getContext());
  });

  converter.addConversion([](openshmem::CtxType type) -> Type {
    // Convert ctx to LLVM pointer type (shmem_ctx_t is typically a pointer)
    return LLVM::LLVMPointerType::get(type.getContext());
  });

  patterns.add<
      // Setup
      InitOpLowering, FinalizeOpLowering, MyPeOpLowering, NPesOpLowering,

      // Memory handling
      MallocOpLowering, FreeOpLowering, PutmemOpLowering, GetmemOpLowering,
      PutmemNbiOpLowering, GetmemNbiOpLowering,

      // Barrier operations
      BarrierAllOpLowering, BarrierOpLowering, QuietOpLowering,

      // Team and context operations
      TeamSplitStridedOpLowering, TeamSplit2dOpLowering, TeamMyPeOpLowering,
      TeamNPesOpLowering, TeamSyncOpLowering, TeamDestroyOpLowering,
      TeamWorldOpLowering, TeamSharedOpLowering, TeamCreateCtxOpLowering,
      CtxCreateOpLowering, CtxDestroyOpLowering, CtxGetTeamOpLowering,

      // Collective operations
      AlltoallmemOpLowering, AlltoallsmemOpLowering, BroadcastmemOpLowering,
      CollectmemOpLowering, FCollectmemOpLowering,

      // Typed put operations
      PutOpLowering, CtxPutOpLowering, PutNbiOpLowering, CtxPutNbiOpLowering,
      Put8OpLowering, Put16OpLowering, Put32OpLowering, Put64OpLowering,
      Put128OpLowering, CtxPut8OpLowering, CtxPut16OpLowering,
      CtxPut32OpLowering, CtxPut64OpLowering, CtxPut128OpLowering,
      // Typed get operations
      GetOpLowering, CtxGetOpLowering, GetNbiOpLowering, CtxGetNbiOpLowering,
      Get8OpLowering, Get16OpLowering, Get32OpLowering, Get64OpLowering,
      Get128OpLowering, CtxGet8OpLowering, CtxGet16OpLowering,
      CtxGet32OpLowering, CtxGet64OpLowering, CtxGet128OpLowering,
      // Atomic fetch operations
      AtomicFetchOpLowering, CtxAtomicFetchOpLowering,
      // Atomic set operations
      AtomicSetOpLowering, CtxAtomicSetOpLowering>(converter);
}

void openshmem::registerConvertOpenSHMEMToLLVMInterface(
    DialectRegistry &registry) {
  registry.addExtension(
      +[](MLIRContext *ctx, openshmem::OpenSHMEMDialect *dialect) {
        dialect->addInterfaces<OpenSHMEMToLLVMDialectInterface>();
      });
}
