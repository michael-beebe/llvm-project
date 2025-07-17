//===- OpenSHMEMMemory.td - OpenSHMEM memory operations ----*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_OPENSHMEM_IR_OPENSHEMMMEMORY_TD
#define MLIR_DIALECT_OPENSHMEM_IR_OPENSHEMMMEMORY_TD

include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEMBase.td"

//===----------------------------------------------------------------------===//
// MallocOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_MallocOp : OpenSHMEM_Op<"malloc", []> {
  let summary = "Allocate symmetric memory";
  let description = [{
    This operation allocates symmetric memory that is accessible from all PEs.
    The allocated memory can be used in putmem/getmem operations. The size parameter
    specifies the number of bytes to allocate.
    
    This is a collective operation - all PEs must participate. The returned
    memory reference points to symmetric memory that has the same virtual
    address on all PEs.
    
    Arguments:
    - size: Number of bytes to allocate (index)
    
    Results:
    - ptr: A symmetric memory reference containing the allocated memory
    
    Signature:
    ```c
    void *shmem_malloc(size_t size);
    ```
    
    This operation can optionally return an `i32` value that can be used
    to check for errors (0 for success, non-zero for failure).
  }];

  let arguments = (ins Index:$size);
  
  let results = (outs 
    OpenSHMEM_SymmetricMemRef:$ptr,
    Optional<I32>:$retval
  );
  
  let assemblyFormat = "`(` $size `)` attr-dict `:` type($size) `->` "
                       "type($ptr) (`,` type($retval)^)?";
}

//===----------------------------------------------------------------------===//
// FreeOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_FreeOp : OpenSHMEM_Op<"free", []> {
  let summary = "Free symmetric memory";
  let description = [{
    This operation frees symmetric memory that was previously allocated with
    openshmem.malloc. The memory reference must point to symmetric memory
    allocated by a previous malloc operation.
    
    This is a collective operation - all PEs must participate and free the
    same symmetric memory allocation.
    
    Arguments:
    - ptr: Memory reference to free (must be symmetric memory)
    
    Signature:
    ```c
    void shmem_free(void *ptr);
    ```
  }];
  
  let arguments = (ins OpenSHMEM_SymmetricMemRef:$ptr);
  let assemblyFormat = "`(` $ptr `)` attr-dict `:` type($ptr)";
}

#endif // MLIR_DIALECT_OPENSHMEM_IR_OPENSHEMMMEMORY_TD 