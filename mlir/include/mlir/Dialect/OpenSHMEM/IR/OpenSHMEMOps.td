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
// MallocOp - Simplified for basic type
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
// FreeOp - Simplified for basic type
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
// PutOp - Simplified for basic type
//===----------------------------------------------------------------------===//

def OpenSHMEM_PutOp : OpenSHMEM_Op<"put", []> {
  let summary = "Perform a one-sided put operation";
  let description = [{
    This operation performs a one-sided put, copying data from the source
    memory region on the calling PE to the destination memory region on 
    the target PE. The operation copies `size` elements.
    
    Arguments:
    - dest: Destination memory reference on the target PE (symmetric memory)
    - src: Source memory reference on the calling PE (any type)
    - size: Number of elements to transfer (i64)
    - pe: Target PE number (i32)
    
    Equivalent to `shmem_put_nbi()` or similar OpenSHMEM put routines.
    
    This operation can optionally return an `!openshmem.retval` value that can be used
    to check for errors.
  }];

  let arguments = (ins 
    OpenSHMEM_SymmetricMemRef:$dest,
    AnyType:$src, 
    I64:$size,
    I32:$pe
  );

  let results = (outs Optional<OpenSHMEM_Retval>:$retval);

  let assemblyFormat =
      "`(` $dest `,` $src `,` $size `,` $pe `)` attr-dict `:` "
      "type($dest) `,` type($src) `,` type($size) `,` type($pe) "
      "(`->` type($retval)^)?";
}

//===----------------------------------------------------------------------===//
// GetOp - Simplified for basic type
//===----------------------------------------------------------------------===//

def OpenSHMEM_GetOp : OpenSHMEM_Op<"get", []> {
  let summary = "Perform a one-sided get operation";
  let description = [{
    This operation performs a one-sided get, copying data from the source
    memory region on the target PE to the destination memory region on
    the calling PE. The operation copies `size` elements.
    
    Arguments:
    - dest: Destination memory reference on the calling PE (any type)
    - src: Source memory reference on the target PE (symmetric memory)
    - size: Number of elements to transfer (i64)
    - pe: Target PE number (i32)
    
    Equivalent to `shmem_get_nbi()` or similar OpenSHMEM get routines.
    
    This operation can optionally return an `!openshmem.retval` value that can be used
    to check for errors.
  }];

  let arguments = (ins
    AnyType:$dest,
    OpenSHMEM_SymmetricMemRef:$src,
    I64:$size, 
    I32:$pe
  );
  
  let results = (outs Optional<OpenSHMEM_Retval>:$retval);
  
  let assemblyFormat = "`(` $dest `,` $src `,` $size `,` $pe `)` attr-dict `:` "
                       "type($dest) `,` type($src) `,` type($size) `,` type($pe) "
                       "(`->` type($retval)^)?";
}

//===----------------------------------------------------------------------===//
// SymmetricCastOp - Simplified for basic type
//===----------------------------------------------------------------------===//

def OpenSHMEM_SymmetricCastOp : OpenSHMEM_Op<"symmetric_cast", []> {
  let summary = "Cast a value to symmetric memory";
  let description = [{
    This operation casts a value to symmetric memory. This should only
    be used when the programmer knows the value points to symmetric
    memory (e.g., memory allocated with openshmem.malloc).
    
    This is a compiler hint operation that doesn't generate runtime code but
    changes the type information for better type safety and optimization.
    
    Arguments:
    - value: Value to cast
    
    Results:
    - symmetric_memref: The same value as symmetric memory
  }];

  let arguments = (ins AnyType:$value);
  let results = (outs OpenSHMEM_SymmetricMemRef:$symmetric_memref);
  let assemblyFormat = "`(` $value `)` attr-dict `:` type($value) `->` type($symmetric_memref)";
}

#endif // MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMOPS_TD
