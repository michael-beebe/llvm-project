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
#include "mlir/Dialect/Arith/IR/Arith.h"

namespace mlir {
namespace openshmem {

#define GEN_PASS_DECL
#include "mlir/Dialect/OpenSHMEM/Transforms/Passes.h.inc"

//===----------------------------------------------------------------------===//
// Passes
//===----------------------------------------------------------------------===//

/// Create a comprehensive message aggregation pass for OpenSHMEM operations.
/// This pass performs analysis and optimization of communication patterns,
/// coalescing multiple small transfers into fewer, larger ones across all
/// RMA operation types while respecting OpenSHMEM semantics.
std::unique_ptr<Pass> createMessageAggregationPass();

/// Create a pass that fuses adjacent OpenSHMEM atomic operations operating on
/// the same address/PE/context into a single equivalent operation.
std::unique_ptr<Pass> createAtomicFusionPass();

/// Create a pass that converts blocking OpenSHMEM RMA ops to non-blocking
/// variants when trivially safe.
std::unique_ptr<Pass> createAsyncConversionPass();

/// Create a pass that injects or overrides the openshmem.num_pes module
/// attribute.
std::unique_ptr<Pass> createInjectNumPEsPass();

//===----------------------------------------------------------------------===//
// Registration
//===----------------------------------------------------------------------===//

/// Generate the code for registering passes.
#define GEN_PASS_REGISTRATION
#include "mlir/Dialect/OpenSHMEM/Transforms/Passes.h.inc"

} // namespace openshmem
} // namespace mlir

#endif // MLIR_DIALECT_OPENSHMEM_TRANSFORMS_PASSES_H
