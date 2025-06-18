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
    
    This operation can optionally return an `!openshmem.retval` value that can be used
    to check for errors.
  }];

  let results = (outs Optional<OpenSHMEM_Retval>:$retval);
  let assemblyFormat = "attr-dict (`:` type($retval)^)?";
}

//===----------------------------------------------------------------------===//
// FinalizeOp  
//===----------------------------------------------------------------------===//

def OpenSHMEM_FinalizeOp : OpenSHMEM_Op<"finalize", []> {
  let summary = "Finalize the OpenSHMEM library";
  let description = [{
    This operation finalizes the OpenSHMEM runtime environment.
    It should be called before program termination.
    
    This operation can optionally return an `!openshmem.retval` value that can be used
    to check for errors.
  }];

  let results = (outs Optional<OpenSHMEM_Retval>:$retval);
  let assemblyFormat = "attr-dict (`:` type($retval)^)?";
}

//===----------------------------------------------------------------------===//
// MyPeOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_MyPeOp : OpenSHMEM_Op<"my_pe", []> {
  let summary = "Get the current PE (Processing Element) number";
  let description = [{
    This operation returns the number of the calling PE. PEs are numbered 
    from 0 to n_pes()-1, where n_pes() is the total number of PEs.
    
    Equivalent to `shmem_my_pe()`.
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
    
    Equivalent to `shmem_n_pes()`.
  }];

  let results = (outs I32:$n_pes);
  let assemblyFormat = "attr-dict `:` type($n_pes)";
}

//===----------------------------------------------------------------------===//
// MallocOp
// TODO: this should use memref
// FIXME: shmem_malloc does not return anything. I don't think we should have
//        it return an OpenSHMEM_Retval.
//===----------------------------------------------------------------------===//

def OpenSHMEM_MallocOp : OpenSHMEM_Op<"malloc", []> {
  let summary = "Allocate symmetric memory";
  let description = [{
    This operation allocates symmetric memory that is accessible from all PEs.
    The allocated memory can be used in put/get operations. The size parameter
    specifies the number of bytes to allocate.
    
    This is a collective operation - all PEs must participate. The returned
    memory reference points to symmetric memory that has the same virtual
    address on all PEs.
    
    Arguments:
    - size: Number of bytes to allocate (i64)
    
    Results:
    - ptr: A symmetric memory reference containing the allocated memory
    
    Equivalent to `shmem_malloc()`.
    
    This operation can optionally return an `!openshmem.retval` value that can be used
    to check for errors.
  }];

  let arguments = (ins I64:$size);
  
  let results = (outs 
    OpenSHMEM_SymmetricMemRef:$ptr,
    Optional<OpenSHMEM_Retval>:$retval
  );
  
  let assemblyFormat = "`(` $size `)` attr-dict `:` type($size) `->` "
                       "type($ptr) (`,` type($retval)^)?";
}

//===----------------------------------------------------------------------===//
// FreeOp
// TODO: this should use memref
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
    
    Equivalent to `shmem_free()`.
    
    This operation can optionally return an `!openshmem.retval` value that can be used
    to check for errors.
  }];

  let arguments = (ins OpenSHMEM_SymmetricMemRef:$ptr);
  
  let results = (outs Optional<OpenSHMEM_Retval>:$retval);
  
  let assemblyFormat = "`(` $ptr `)` attr-dict `:` type($ptr) "
                       "(`->` type($retval)^)?";
}

//===----------------------------------------------------------------------===//
// PutOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_PutOp : OpenSHMEM_Op<"put", []> {
  let summary = "Blocking put operation (matches shmem_put C API)";
  let description = [{
    This operation performs a blocking put, copying data from the source
    memory region on the calling PE to the destination symmetric memory region on 
    the target PE. The operation copies `size` elements and returns only after the
    data has been copied out of the source array on the local PE.
    
    Arguments:
    - dest: Destination symmetric memory reference on the target PE (!openshmem.symmetric_memref<T>)
    - src: Source local memory reference on the calling PE (any type)
    - size: Number of elements to transfer (i64)
    - pe: Target PE number (i32)
    
    Equivalent to `shmem_put()` in the C API.
    
    This operation has no return value.
  }];

  let arguments = (ins 
    OpenSHMEM_SymmetricMemRef:$dest,
    AnyType:$src, 
    I64:$size,
    I32:$pe
  );

  let assemblyFormat =
      "`(` $dest `,` $src `,` $size `,` $pe `)` attr-dict `:` "
      "type($dest) `,` type($src) `,` type($size) `,` type($pe)";
}

//===----------------------------------------------------------------------===//
// GetOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_GetOp : OpenSHMEM_Op<"get", []> {
  let summary = "Blocking get operation (matches shmem_get C API)";
  let description = [{
    This operation performs a blocking get, copying data from the source
    symmetric memory region on the target PE to the destination local memory region on
    the calling PE. The operation copies `size` elements and returns only after the
    data has been delivered to the destination array on the local PE.
    
    Arguments:
    - dest: Destination local memory reference on the calling PE (any type)
    - src: Source symmetric memory reference on the target PE (!openshmem.symmetric_memref<T>)
    - size: Number of elements to transfer (i64)
    - pe: Target PE number (i32)
    
    Equivalent to `shmem_get()` in the C API.
    
    This operation has no return value.
  }];

  let arguments = (ins
    AnyType:$dest,
    OpenSHMEM_SymmetricMemRef:$src,
    I64:$size, 
    I32:$pe
  );

  let assemblyFormat = "`(` $dest `,` $src `,` $size `,` $pe `)` attr-dict `:` "
                       "type($dest) `,` type($src) `,` type($size) `,` type($pe)";
}

#endif // MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMOPS_TD
