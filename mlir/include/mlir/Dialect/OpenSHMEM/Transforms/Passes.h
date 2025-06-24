//===- Passes.h - OpenSHMEM dialect transformation passes -*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_OPENSHMEM_TRANSFORMS_PASSES_H
#define MLIR_DIALECT_OPENSHMEM_TRANSFORMS_PASSES_H

#include "mlir/Pass/Pass.h"

namespace mlir {
namespace openshmem {

#define GEN_PASS_DECL
#include "mlir/Dialect/OpenSHMEM/Transforms/Passes.h.inc"

/// Create a pass that coalesces consecutive OpenSHMEM put operations.
std::unique_ptr<Pass> createCoalescePutsPass();

/// Create a pass that injects or overrides the openshmem.num_pes module
/// attribute.
std::unique_ptr<Pass> createInjectNumPEsPass();

/// Generate the code for registering passes.
#define GEN_PASS_REGISTRATION
#include "mlir/Dialect/OpenSHMEM/Transforms/Passes.h.inc"

} // namespace openshmem
} // namespace mlir

#endif // MLIR_DIALECT_OPENSHMEM_TRANSFORMS_PASSES_H