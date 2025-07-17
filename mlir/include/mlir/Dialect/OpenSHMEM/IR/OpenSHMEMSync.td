//===- OpenSHMEMSync.td - OpenSHMEM synchronization operations -*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMSYNC_TD
#define MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMSYNC_TD

include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEMBase.td"

//===----------------------------------------------------------------------===//
// BarrierAllOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_BarrierAllOp : OpenSHMEM_Op<"barrier_all", []> {
  let summary = "Barrier operation (matches shmem_barrier_all C API)";
  let description = [{
    This operation performs a barrier operation on all PEs in the program.
    It is a collective operation - all PEs must participate.

    Signature:
    ```c
    void shmem_barrier_all(void);
    ```
  }];

  let assemblyFormat = "attr-dict";
}

//===----------------------------------------------------------------------===//
// BarrierOp (deprecated, but kept for compatibility)
//===----------------------------------------------------------------------===//

def OpenSHMEM_BarrierOp : OpenSHMEM_Op<"barrier", []> {
  let summary = "Deprecated barrier operation";
  let description = [{
    This operation performs a barrier operation on a subset of PEs.
    This is deprecated in favor of team-based barriers.

    Arguments:
    - pe_start: Starting PE number in the active set
    - log_pe_stride: Log2 of the stride between PEs in the active set
    - pe_size: Number of PEs in the active set
    - psync: Symmetric memory array used for synchronization
             (must be allocated with openshmem.malloc)

    Signature:
    ```c
    void shmem_barrier(int PE_start, int logPE_stride, int PE_size, long *pSync);
    ```
    
    Note: The psync array must be initialized to SHMEM_SYNC_VALUE before use and
    must be allocated in symmetric memory accessible to all participating PEs.
  }];

  let arguments = (ins 
    I32 : $pe_start, 
    I32 : $log_pe_stride, 
    I32 : $pe_size, 
    OpenSHMEM_SymmetricMemRef : $psync
  );
  let assemblyFormat = "`(` $pe_start `,` $log_pe_stride `,` $pe_size `,` $psync `)` attr-dict `:` "
                       "type($pe_start) `,` type($log_pe_stride) `,` type($pe_size) `,` type($psync)";
}

//===----------------------------------------------------------------------===//
// QuietOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_QuietOp : OpenSHMEM_Op<"quiet", []> {
  let summary = "Quiet operation (matches shmem_quiet C API)";
  let description = [{
    This operation performs a quiet operation on the calling PE.
    It ensures that all previously issued put/get operations from the 
    calling PE have completed before returning.

    Signature:
    ```c
    void shmem_quiet(void);
    ```
  }];

  let assemblyFormat = "attr-dict";
}

#endif // MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMSYNC_TD 