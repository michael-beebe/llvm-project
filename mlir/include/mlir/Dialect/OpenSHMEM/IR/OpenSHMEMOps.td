//===- OpenSHMEMOps.td - OpenSHMEM Operations -----------------*- tablegen
//-*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMOPS_TD
#define MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMOPS_TD

include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEM.td"
include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEMTypes.td"

class OpenSHMEM_Op<string mnemonic, list<Trait> traits = []>
    : Op<OpenSHMEM_Dialect, mnemonic, traits>;

//===----------------------------------------------------------------------===//
// Placeholder operation - will be replaced with actual OpenSHMEM operations
//===----------------------------------------------------------------------===//

// TODO: replace this with actual OpenSHMEM operations
def OpenSHMEM_PlaceholderOp : OpenSHMEM_Op<"placeholder", []> {
  let summary = "Placeholder operation for OpenSHMEM dialect";
  let description = [{
    This is a placeholder operation to get the build system working.
    It will be replaced with actual OpenSHMEM operations like put, get, fence, etc.
  }];

  let results = (outs);

  let assemblyFormat = "attr-dict";
}

#endif // MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMOPS_TD
