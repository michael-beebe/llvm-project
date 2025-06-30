//===- Transforms.h - OpenSHMEM dialect transformation passes -*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_OPENSHMEM_TRANSFORMS_TRANSFORMS_H
#define MLIR_DIALECT_OPENSHMEM_TRANSFORMS_TRANSFORMS_H

#include "mlir/Pass/Pass.h"

namespace mlir {
namespace openshmem {

//===----------------------------------------------------------------------===//
// Passes
//===----------------------------------------------------------------------===//

/// Create a pass that coalesces consecutive OpenSHMEM put operations.
/// This pass looks for adjacent put operations targeting the same PE and
/// attempts to combine them into fewer, larger transfers for better
/// performance.
std::unique_ptr<Pass> createCoalescePutsPass();

/// Create a pass that coalesces consecutive OpenSHMEM get operations.
/// This pass looks for adjacent get operations targeting the same PE and
/// attempts to combine them into fewer, larger transfers for better
/// performance.
std::unique_ptr<Pass> createCoalesceGetsPass();

/// Create a pass that injects or overrides the openshmem.num_pes module
/// attribute. This pass allows specifying the number of PEs at compile time for
/// optimization purposes, even though the actual number is determined at
/// runtime.
std::unique_ptr<Pass> createInjectNumPEsPass();

//===----------------------------------------------------------------------===//
// Registration
//===----------------------------------------------------------------------===//

/// Register all OpenSHMEM transformation passes.
void registerOpenSHMEMTransformPasses();

} // namespace openshmem
} // namespace mlir

#endif // MLIR_DIALECT_OPENSHMEM_TRANSFORMS_TRANSFORMS_H