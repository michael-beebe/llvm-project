//===- OpenSHMEMToLLVM.cpp - OpenSHMEM to LLVM conversion ----------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "mlir/Conversion/OpenSHMEMToLLVM/OpenSHMEMToLLVM.h"
#include "OpenSHMEMConversionUtils.h"
#include "SetupOpsToLLVM.h"
#include "MemoryOpsToLLVM.h"
#include "RMAOpsToLLVM.h"
#include "CollectiveOpsToLLVM.h"
#include "TeamOpsToLLVM.h"
#include "ContextOpsToLLVM.h"
#include "AtomicOpsToLLVM.h"
#include "SyncOpsToLLVM.h"
#include "Pt2ptSyncOpsToLLVM.h"
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
using namespace mlir::openshmem;

namespace {

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

  // Populate patterns
  populateSetupOpsToLLVMConversionPatterns(converter, patterns);
  populateMemoryOpsToLLVMConversionPatterns(converter, patterns);
  populateRMAOpsToLLVMConversionPatterns(converter, patterns);
  populateCollectiveOpsToLLVMConversionPatterns(converter, patterns);
  populateTeamOpsToLLVMConversionPatterns(converter, patterns);
  populateContextOpsToLLVMConversionPatterns(converter, patterns);
  populateAtomicOpsToLLVMConversionPatterns(converter, patterns);
  populateSyncOpsToLLVMConversionPatterns(converter, patterns);
  populatePt2ptSyncOpsToLLVMConversionPatterns(converter, patterns);
}

void openshmem::registerConvertOpenSHMEMToLLVMInterface(
    DialectRegistry &registry) {
  registry.addExtension(
      +[](MLIRContext *ctx, openshmem::OpenSHMEMDialect *dialect) {
        dialect->addInterfaces<OpenSHMEMToLLVMDialectInterface>();
      });
}
