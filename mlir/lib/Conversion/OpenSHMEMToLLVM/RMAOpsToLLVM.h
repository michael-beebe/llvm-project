//===- RMAOpsToLLVM.h - RMA operations conversion patterns ----*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file declares conversion patterns for OpenSHMEM RMA (Remote Memory Access)
// operations to LLVM IR. This includes:
//
// - Typed put/get operations (put, ctx_put, put_nbi, ctx_put_nbi)
// - Sized put/get operations (put8, put16, put32, put64, put128)
// - Context-aware sized operations (ctx_put8, ctx_put16, etc.)
// - Memory operations (putmem, putmem_nbi, getmem, getmem_nbi)
// - All corresponding get operation variants
//
// Total: 32 RMA operations
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_LIB_CONVERSION_OPENSHMEMTOLLVM_RMAOPSTOLLVM_H
#define MLIR_LIB_CONVERSION_OPENSHMEMTOLLVM_RMAOPSTOLLVM_H

namespace mlir {
class LLVMTypeConverter;
class RewritePatternSet;

namespace openshmem {

/// Populate conversion patterns for OpenSHMEM RMA operations.
/// This includes all put/get variants, putmem/getmem operations,
/// and their sized and context-aware versions.
void populateRMAOpsToLLVMConversionPatterns(LLVMTypeConverter &converter,
                                            RewritePatternSet &patterns);

} // namespace openshmem
} // namespace mlir

#endif // MLIR_LIB_CONVERSION_OPENSHMEMTOLLVM_RMAOPSTOLLVM_H
