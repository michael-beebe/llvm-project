//===- OpenSHMEMConversionUtils.cpp - Shared conversion utilities -------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements utility functions shared across OpenSHMEM to LLVM 
// conversion patterns. These utilities help eliminate code duplication
// across the modular conversion files.
//
//===----------------------------------------------------------------------===//

#include "OpenSHMEMConversionUtils.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/LLVMIR/LLVMTypes.h"
#include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEM.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Support/LLVM.h"

using namespace mlir;

namespace mlir {
namespace openshmem {

//===----------------------------------------------------------------------===//
// Function declaration utilities
//===----------------------------------------------------------------------===//

LLVM::LLVMFuncOp getOrDefineFunction(ModuleOp &moduleOp,
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

//===----------------------------------------------------------------------===//
// Memory reference utilities  
//===----------------------------------------------------------------------===//

Value getMemRefDataPtr(Location loc, ConversionPatternRewriter &rewriter,
                       Value memref) {
  // Assumes memref is a MemRef descriptor (struct), extract the pointer (field 0)
  auto ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());
  return rewriter.create<LLVM::ExtractValueOp>(loc, ptrType, memref, 0);
}

Type getSymmetricMemRefElementType(Value symmetricMemRef) {
  auto symMemRefType =
      llvm::dyn_cast<openshmem::SymmetricMemRefType>(symmetricMemRef.getType());
  if (!symMemRefType) {
    return nullptr;
  }
  return symMemRefType.getElementType();
}

//===----------------------------------------------------------------------===//
// OpenSHMEM function naming utilities
//===----------------------------------------------------------------------===//

std::string getTypedFunctionName(StringRef baseName, Type elementType) {
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

} // namespace openshmem
} // namespace mlir 