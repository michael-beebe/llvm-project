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
// shmem_init
//===----------------------------------------------------------------------===//

def OpenSHMEM_InitOp : OpenSHMEM_Op<"init", []> {
  let summary =
      "Initialize the OpenSHMEM library, equivalent to `shmem_init()`";
  let description = [{
    This operation initializes the OpenSHMEM library and must be called before
    most OpenSHMEM operations. It sets up the partitioned global address space
    and initializes the processing element (PE) environment.
  }];

  let results = (outs);

  let assemblyFormat = "attr-dict";
}

//===----------------------------------------------------------------------===//
// shmem_finalize
//===----------------------------------------------------------------------===//

def OpenSHMEM_FinalizeOp : OpenSHMEM_Op<"finalize", []> {
  let summary = "Finalize the OpenSHMEM library, equivalent to `shmem_finalize()`";
  let description = [{
    This operation finalizes the OpenSHMEM library and should be called at the
    end of the program to clean up resources and properly terminate the
    partitioned global address space.
  }];

  let results = (outs);

  let assemblyFormat = "attr-dict";
}

#endif // MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMOPS_TD
