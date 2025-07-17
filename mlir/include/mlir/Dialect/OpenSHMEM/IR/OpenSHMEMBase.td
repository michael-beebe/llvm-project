//===- OpenSHMEMBase.td - OpenSHMEM base definitions -------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMBASE_TD
#define MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMBASE_TD

include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEM.td"
include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEMTypes.td"
include "mlir/Interfaces/SideEffectInterfaces.td"
include "mlir/IR/BuiltinTypes.td"

//===----------------------------------------------------------------------===//
// Traits
//===----------------------------------------------------------------------===//

// TODO: add traits for collective, etc.

//===----------------------------------------------------------------------===//
// Base OpenSHMEM operation
//===----------------------------------------------------------------------===//

class OpenSHMEM_Op<string mnemonic, list<Trait> traits = []>
    : Op<OpenSHMEM_Dialect, mnemonic, traits>;

#endif // MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMBASE_TD 