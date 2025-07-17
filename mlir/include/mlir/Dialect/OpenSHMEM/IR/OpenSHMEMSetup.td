//===- OpenSHMEMSetup.td - OpenSHMEM setup operations ------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMSETUP_TD
#define MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMSETUP_TD

include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEMBase.td"

//===----------------------------------------------------------------------===//
// InitOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_InitOp : OpenSHMEM_Op<"init", []> {
  let summary = "Initialize the OpenSHMEM library";
  let description = [{
    This operation initializes the OpenSHMEM runtime environment.
    It must be called before any other OpenSHMEM operations.
    
    Signature:
    ```c
    void shmem_init(void);
    ```
  }];
  let assemblyFormat = "attr-dict";
}

//===----------------------------------------------------------------------===//
// FinalizeOp  
//===----------------------------------------------------------------------===//

def OpenSHMEM_FinalizeOp : OpenSHMEM_Op<"finalize", []> {
  let summary = "Finalize the OpenSHMEM library";
  let description = [{
    This operation finalizes the OpenSHMEM runtime environment.
    It should be called before program termination.
    
    Signature:
    ```c
    void shmem_finalize(void);
    ```
  }];
  let assemblyFormat = "attr-dict";
}

//===----------------------------------------------------------------------===//
// MyPeOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_MyPeOp : OpenSHMEM_Op<"my_pe", []> {
  let summary = "Get the current PE (Processing Element) number";
  let description = [{
    This operation returns the number of the calling PE. PEs are numbered 
    from 0 to n_pes()-1, where n_pes() is the total number of PEs.
    
    Signature:
    ```c
    int shmem_my_pe(void);
    ```
  }];

  let results = (outs I32:$pe);
  let assemblyFormat = "attr-dict `:` type($pe)";
}

//===----------------------------------------------------------------------===//
// NPesOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_NPesOp : OpenSHMEM_Op<"n_pes", []> {
  let summary = "Get the total number of PEs";
  let description = [{
    This operation returns the total number of PEs in the OpenSHMEM program.
    
    Signature:
    ```c
    int shmem_n_pes(void);
    ```
  }];

  let results = (outs I32:$n_pes);
  let assemblyFormat = "attr-dict `:` type($n_pes)";
}

#endif // MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMSETUP_TD 