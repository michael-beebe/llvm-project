//===- OpenSHMEMAtomics.td - OpenSHMEM atomic operations ---*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_OPENSHMEM_IR_OPENSHEMATOMICS_TD
#define MLIR_DIALECT_OPENSHMEM_IR_OPENSHEMATOMICS_TD

include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEMBase.td"

//===----------------------------------------------------------------------===//
// Atomic Operations
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// AtomicFetchOp (Typed - Generic)
//===----------------------------------------------------------------------===//

def OpenSHMEM_AtomicFetchOp : OpenSHMEM_Op<"atomic_fetch", []> {
  let summary = "Atomic fetch operation (generic)";
  let description = [{
    This operation atomically fetches the value of a remote data object from
    the specified PE. The operation returns the value that was fetched.
    
    This is the generic typed equivalent of atomic fetch operations, providing
    type safety and better performance for known data types.
    
    Arguments:
    - source: Source symmetric memory reference on the target PE
      (!openshmem.symmetric_memref<T> where T is a supported atomic type)
    - pe: Target PE number (i32)
    
    Results:
    - result: The fetched value (T where T is a supported atomic type)
    
    The element type T must be one of the supported OpenSHMEM atomic types.
    
    Signature:
    ```c
    TYPE shmem_atomic_fetch(const TYPE *source, int pe);
    ```
    where TYPE is one of the extended AMO types from Table 7.
  }];

  let arguments = (ins 
    OpenSHMEM_SymmetricMemRef:$source,
    I32:$pe
  );
  
  let results = (outs AnyType:$result);
  
  let assemblyFormat = "`(` $source `,` $pe `)` attr-dict `:` "
                       "type($source) `,` type($pe) `->` type($result)";
}

//===----------------------------------------------------------------------===//
// CtxAtomicFetchOp (Typed - Context-aware)
//===----------------------------------------------------------------------===//

def OpenSHMEM_CtxAtomicFetchOp : OpenSHMEM_Op<"ctx_atomic_fetch", []> {
  let summary = "Atomic fetch operation with context";
  let description = [{
    This operation atomically fetches the value of a remote data object from
    the specified PE using a specific context. The operation returns the value
    that was fetched.
    
    Arguments:
    - ctx: OpenSHMEM context handle (!openshmem.ctx)
    - source: Source symmetric memory reference on the target PE
      (!openshmem.symmetric_memref<T> where T is a supported atomic type)
    - pe: Target PE number (i32)
    
    Results:
    - result: The fetched value (T where T is a supported atomic type)
    
    The element type T must be one of the supported OpenSHMEM atomic types.
    
    Signature:
    ```c
    TYPE shmem_atomic_fetch(shmem_ctx_t ctx, const TYPE *source, int pe);
    ```
    where TYPE is one of the extended AMO types from Table 7.
  }];

  let arguments = (ins 
    OpenSHMEM_Ctx:$ctx,
    OpenSHMEM_SymmetricMemRef:$source,
    I32:$pe
  );
  
  let results = (outs AnyType:$result);
  
  let assemblyFormat = "`(` $ctx `,` $source `,` $pe `)` attr-dict `:` "
                       "type($ctx) `,` type($source) `,` type($pe) `->` type($result)";
}

//===----------------------------------------------------------------------===//
// AtomicSetOp (Typed - Generic)
//===----------------------------------------------------------------------===//

def OpenSHMEM_AtomicSetOp : OpenSHMEM_Op<"atomic_set", []> {
  let summary = "Atomic set operation (generic)";
  let description = [{
    Atomically sets the value of a remote data object.

    Arguments:
    - dest: Destination symmetric memory reference on the target PE
      (!openshmem.symmetric_memref<T> where T is a supported atomic type)
    - value: Value to set (T where T is a supported atomic type)
    - pe: Target PE number (i32)

    Signature:
    ```c
    void shmem_atomic_set(TYPE *dest, TYPE value, int pe);
    ```
    where TYPE is one of the extended AMO types from Table 7.
  }];

  let arguments = (ins 
    OpenSHMEM_SymmetricMemRef:$dest,
    AnyType:$value,
    I32:$pe
  );
  
  let assemblyFormat = "`(` $dest `,` $value `,` $pe `)` attr-dict `:` "
                       "type($dest) `,` type($value) `,` type($pe)";
}

//===----------------------------------------------------------------------===//
// CtxAtomicSetOp (Typed - Context-aware)
//===----------------------------------------------------------------------===//

def OpenSHMEM_CtxAtomicSetOp : OpenSHMEM_Op<"ctx_atomic_set", []> {
  let summary = "Atomic set operation with context";
  let description = [{
    Atomically sets the value of a remote data object.
    
    Arguments:
    - ctx: A context handle specifying the context on which to perform the operation.
      When this argument is not provided, the operation is performed on the default
      context. (!openshmem.ctx)
    - dest: Destination symmetric memory reference on the target PE
      (!openshmem.symmetric_memref<T> where T is a supported atomic type)
    - value: Value to set (T where T is a supported atomic type)
    - pe: Target PE number (i32)

    Signature:
    ```c
    void shmem_ctx_atomic_set(shmem_ctx_t ctx, TYPE *dest, TYPE value, int pe);
    ```
    where TYPE is one of the extended AMO types from Table 7.
  }];

  let arguments = (ins 
    OpenSHMEM_Ctx:$ctx,
    OpenSHMEM_SymmetricMemRef:$dest,
    AnyType:$value,
    I32:$pe
  );
  
  let assemblyFormat = "`(` $ctx `,` $dest `,` $value `,` $pe `)` attr-dict `:` "
                       "type($ctx) `,` type($dest) `,` type($value) `,` type($pe)";
}

#endif // MLIR_DIALECT_OPENSHMEM_IR_OPENSHEMATOMICS_TD 