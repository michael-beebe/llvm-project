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
    OpenSHMEM_SymmetricMemRef:$ptr
  );
  
  let assemblyFormat = "`(` $size `)` attr-dict `:` type($size) `->` "
                       "type($ptr)";
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
    - ptr: Symmetric address of an object in the symmetric heap.
    
    Signature:
    ```c
    void shmem_free(void *ptr);
    ```
  }];
  
  let arguments = (ins OpenSHMEM_SymmetricMemRef:$ptr);
  let assemblyFormat = "`(` $ptr `)` attr-dict `:` type($ptr)";
}

//===----------------------------------------------------------------------===//
// ReallocOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_ReallocOp : OpenSHMEM_Op<"realloc", []> {
  let summary = "Collectively resize an allocation of symmetric memory.";
  let description = [{
    Collective operation on the world team that changes the size of the block
    to which ptr points to the size (in bytes) specified by size. The contents
    of the block are unchanged up to the lesser of the new and old sizes.

    Arguments:
    - ptr: Symmetric address of an object in the symmetric heap
    - size: The size, in bytes, of a block to be allocated from the
            symmetric heap.

    Signature:
    ```c
    void *shmem_realloc(void *ptr, size_t size);
    ```
  }];

  let arguments = (ins
    OpenSHMEM_SymmetricMemRef:$ptr,
    Index:$size
  );

  let results = (outs 
    OpenSHMEM_SymmetricMemRef:$retval
  );

  let assemblyFormat = "`(` $ptr `,` $size `)` attr-dict `:` "
                       "type($ptr) `,` type($size) `->` type($retval)";
}

//===----------------------------------------------------------------------===//
// AlignOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_AlignOp : OpenSHMEM_Op<"align", []> {
  let summary = "Collectively allocate symmetric memory with a specified alignment.";
  let description = [{
    Collective operation on the world team that allocates a block in the symmetric
    heap that has a byte alignment specified by the alignment argument. The value
    of alignment shall be a multiple of sizeof(void *) that is also a power of
    two; otherwise, the behavior is undefined. When size is zero, the shmem_align
    routine performs no action and returns a null pointer; otherwise, shmem_align
    calls a barrier on exit. The value of the alignment and size arguments must
    be identical on all PEs; otherwise, the behavior is undefined.

    Arguments:
    - alignment: Byte alignment of the block allocated from the symmetric heap.
    - size: The size, in bytes, of a block to be allocated from the symmetric heap.

    Signature:
    - void *shmem_align(size_t alignment, size_t size);
  }];

  let arguments = (ins
    Index:$alignment,
    Index:$size
  );

  let results = (outs 
    OpenSHMEM_SymmetricMemRef:$retval
  );

  let assemblyFormat = "`(` $alignment `,` $size `)` attr-dict `:` "
                       "type($alignment) `,` type($size) `->` type($retval)";
}

//===----------------------------------------------------------------------===//
// CallocOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_CallocOp : OpenSHMEM_Op<"calloc", []> {
  let summary = "Collectively allocate symmetric memory with a specified alignment.";
  let description = [{
    Collective operation on the world team that allocates a block in the symmetric
    heap that has a byte alignment specified by the alignment argument. The value of
    alignment shall be a multiple of sizeof(void *) that is also a power of two;
    otherwise, the behavior is undefined. When size is zero, the shmem_align routine
    performs no action and returns a null pointer; otherwise, shmem_align calls a
    barrier on exit. The value of the alignment and size arguments must be identical
    on all PEs; otherwise, the behavior is undefined.

    Arguments:
    - count: The number of objects to allocate
    - size: The size of each object

    Signature:
    ```c
    void *shmem_calloc(size_t count, size_t size);
    ```
  }];

  let arguments = (ins
    Index:$count,
    Index:$size
  );

  let results = (outs 
    OpenSHMEM_SymmetricMemRef:$retval
  );

  let assemblyFormat = "`(` $count `,` $size `)` attr-dict `:` "
                       "type($count) `,` type($size) `->` type($retval)";
}

#endif // MLIR_DIALECT_OPENSHMEM_IR_OPENSHEMMMEMORY_TD 
