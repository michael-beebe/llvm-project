//===- OpenSHMEMOps.td - OpenSHMEM dialect operations ------*- tablegen -*-===//
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
    
    This operation can optionally return an `!openshmem.retval` value that can be used
    to check for errors.
  }];

  let arguments = (ins Index:$size);
  
  let results = (outs 
    OpenSHMEM_SymmetricMemRef:$ptr,
    Optional<OpenSHMEM_Retval>:$retval
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

//===----------------------------------------------------------------------===//
// PutmemOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_PutmemOp : OpenSHMEM_Op<"putmem", []> {
  let summary = "Blocking putmem operation (matches shmem_putmem C API)";
  let description = [{
    This operation performs a blocking putmem, copying raw memory from the source
    memory region on the calling PE to the destination symmetric memory region on 
    the target PE. The operation copies `size` bytes and returns only after the
    data has been copied out of the source array on the local PE.
    
    Arguments:
    - dest: Destination symmetric memory reference on the target PE (!openshmem.symmetric_memref<T>)
    - src: Source local memory reference on the calling PE (any type)
    - size: Number of bytes to transfer (index)
    - pe: Target PE number (i32)
    
    Signature:
    ```c
    void shmem_putmem(void *dest, const void *src, size_t nelems, int pe);
    ```
    
    Note: For putmem operations, nelems represents the number of bytes to transfer.
  }];

let arguments = (ins OpenSHMEM_SymmetricMemRef
                 : $dest, AnyType
                 : $src, Index
                 : $size, I32
                 : $pe);

let assemblyFormat = "`(` $dest `,` $src `,` $size `,` $pe `)` attr-dict `:` "
                     "type($dest) `,` type($src) `,` type($size) `,` type($pe)";
}

//===----------------------------------------------------------------------===//
// GetmemOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_GetmemOp : OpenSHMEM_Op<"getmem", []> {
  let summary = "Blocking getmem operation (matches shmem_getmem C API)";
  let description = [{
    This operation performs a blocking getmem, copying raw memory from the source
    symmetric memory region on the target PE to the destination local memory region on
    the calling PE. The operation copies `size` bytes and returns only after the
    data has been delivered to the destination array on the local PE.
    
    Arguments:
    - dest: Destination local memory reference on the calling PE (any type)
    - src: Source symmetric memory reference on the target PE (!openshmem.symmetric_memref<T>)
    - size: Number of bytes to transfer (index)
    - pe: Target PE number (i32)
    
    Signature:
    ```c
    void shmem_getmem(void *dest, const void *src, size_t nelems, int pe);
    ```
    
    Note: For getmem operations, nelems represents the number of bytes to transfer.
  }];

  let arguments = (ins
    AnyType:$dest,
    OpenSHMEM_SymmetricMemRef:$src,
    Index:$size, 
    I32:$pe
  );

  let assemblyFormat = "`(` $dest `,` $src `,` $size `,` $pe `)` attr-dict `:` "
                       "type($dest) `,` type($src) `,` type($size) `,` type($pe)";
}

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

#endif // MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMOPS_TD
