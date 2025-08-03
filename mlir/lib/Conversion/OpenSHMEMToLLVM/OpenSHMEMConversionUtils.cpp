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
  
  // Map MLIR types to OpenSHMEM type names (not sizes!)
  // These must match the actual function names in the OpenSHMEM library
  if (elementType.isInteger(8)) {
    funcName += "char_";
  } else if (elementType.isInteger(16)) {
    funcName += "short_";
  } else if (elementType.isInteger(32)) {
    funcName += "int_";
  } else if (elementType.isInteger(64)) {
    funcName += "long_";
  } else if (elementType.isF32()) {
    funcName += "float_";
  } else if (elementType.isF64()) {
    funcName += "double_";
  } else if (elementType.isF128()) {
    // F128 uses sized functions, not typed functions
    // Return early with sized pattern: shmem_put128, shmem_get128
    funcName += baseName.str() + "128";
    return funcName;
  } else {
    // For unsupported types, fall back to generic name
    // This should be validated earlier in the process
    funcName = "shmem_" + baseName.str();
    return funcName;
  }
  
  funcName += baseName.str();
  return funcName;
}

std::string getSizedFunctionName(StringRef baseName, Type elementType) {
  std::string funcName = "shmem_";
  
  // Map MLIR types to OpenSHMEM sized type names
  // Used for pt2pt sync operations that require sized names (especially vectors)
  // Note: OpenSHMEM only has int32 and int64 sized functions for sync operations
  if (elementType.isInteger(64)) {
    funcName += "int64_";
  } else if (elementType.isF64()) {
    // Double operations in pt2pt sync use int64 for storage
    funcName += "int64_";
  } else {
    // All other types (i8, i16, i32, f32, etc.) use int32
    // This includes most common cases
    funcName += "int32_";
  }
  
  funcName += baseName.str();
  return funcName;
}

} // namespace openshmem
} // namespace mlir 