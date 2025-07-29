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
  let summary = "Equivalent to the shmem_init C API";
  let description = [{
    Initializes the OpenSHMEM runtime environment. This must be the first
    OpenSHMEM routine called by a program.

    Arguments:
    - (none)

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
  let summary = "Equivalent to the shmem_finalize C API";
  let description = [{
    Finalizes the OpenSHMEM runtime environment and cleans up resources.
    This should be the last OpenSHMEM routine called by a program.

    Arguments:
    - (none)

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
  let summary = "Equivalent to the shmem_my_pe C API";
  let description = [{
    Returns the processing element (PE) number of the calling PE. PE numbers
    are integers from 0 to n_pes() - 1.

    Arguments:
    - (none)

    Results:
    - pe: The PE number of the calling PE

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
  let summary = "Equivalent to the shmem_n_pes C API";
  let description = [{
    Returns the total number of processing elements (PEs) in the OpenSHMEM
    program.

    Arguments:
    - (none)

    Results:
    - n_pes: The total number of PEs

    ```c
    int shmem_n_pes(void);
    ```
  }];

  let results = (outs I32:$n_pes);
  let assemblyFormat = "attr-dict `:` type($n_pes)";
}

#endif // MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMSETUP_TD 
