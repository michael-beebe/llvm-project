//===- OpenSHMEMConversionUtils.h - Shared conversion utilities -*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file declares utility functions shared across OpenSHMEM to LLVM 
// conversion patterns. These utilities help eliminate code duplication
// across the modular conversion files.
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_LIB_CONVERSION_OPENSHMEMTOLLVM_OPENSHMEMCONVERSIONUTILS_H
#define MLIR_LIB_CONVERSION_OPENSHMEMTOLLVM_OPENSHMEMCONVERSIONUTILS_H

#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/IR/Types.h"
#include "mlir/IR/Value.h"
#include "mlir/Transforms/DialectConversion.h"

namespace mlir {
namespace openshmem {

//===----------------------------------------------------------------------===//
// Function declaration utilities
//===----------------------------------------------------------------------===//

/// Utility to get or define a function in the module. If the function with
/// the given name already exists, returns it. Otherwise, creates a new 
/// function declaration with external linkage.
LLVM::LLVMFuncOp getOrDefineFunction(ModuleOp &moduleOp,
                                    const Location loc,
                                    ConversionPatternRewriter &rewriter,
                                    StringRef name,
                                    LLVM::LLVMFunctionType type);

//===----------------------------------------------------------------------===//
// Memory reference utilities  
//===----------------------------------------------------------------------===//

/// Utility to extract the data pointer from a memref descriptor.
/// Assumes memref is a MemRef descriptor (struct) and extracts the pointer
/// from field 0.
Value getMemRefDataPtr(Location loc, ConversionPatternRewriter &rewriter,
                       Value memref);

/// Utility to extract element type from symmetric memref.
/// Returns nullptr if the value is not a SymmetricMemRefType.
Type getSymmetricMemRefElementType(Value symmetricMemRef);

//===----------------------------------------------------------------------===//
// OpenSHMEM function naming utilities
//===----------------------------------------------------------------------===//

/// Utility to generate typed function names based on element type.
/// Maps MLIR types to OpenSHMEM type suffixes (e.g., "put" + i32 -> "shmem_put32").
/// For unsupported types, falls back to generic name.
std::string getTypedFunctionName(StringRef baseName, Type elementType);

} // namespace openshmem
} // namespace mlir

#endif // MLIR_LIB_CONVERSION_OPENSHMEMTOLLVM_OPENSHMEMCONVERSIONUTILS_H 