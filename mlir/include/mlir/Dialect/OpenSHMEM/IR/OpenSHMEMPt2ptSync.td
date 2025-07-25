//===- OpenSHMEMPt2ptSync.td - OpenSHMEM point-to-point synchronization operations -*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMPT2PTSYNC_TD
#define MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMPT2PTSYNC_TD

include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEMBase.td"

//===----------------------------------------------------------------------===//
// WaitUntilOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_WaitUntilOp : OpenSHMEM_Op<"wait_until", []> {
  let summary = "Equivalent to shmem_wait_until C API";

  let description = [{
    Wait for a variable on the local PE to change

    C API:
    ```c
    void shmem_wait_until(TYPE *ivar, int cmp, TYPE cmp_value);
    ```
  }];

  let arguments = (ins 
    OpenSHMEM_SymmetricMemRef:$ivar,
    I32:$cmp,
    AnyType:$cmp_value
  );

  let assemblyFormat = "`(` $ivar `,` $cmp `,` $cmp_value `)` attr-dict `:` "
                       "type($ivar) `,` type($cmp) `,` type($cmp_value)";
}

//===----------------------------------------------------------------------===//
// WaitUntilAllOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_WaitUntilAllOp : OpenSHMEM_Op<"wait_until_all", []> {
  let summary = "Equivalent to shmem_wait_until_all C API";

  let description = [{
    Wait on an array of variables on the local PE until all variables meet
    the specified wait condition.

    C API:
    ```c
    void shmem_wait_until_all(TYPE *ivars, size_t nelems, const int *status,
                              int cmp, TYPE cmp_value);
    ```
  }];

  let arguments = (ins 
    OpenSHMEM_SymmetricMemRef:$ivars,
    Index:$nelems,
    AnyMemRef:$status,
    I32:$cmp,
    AnyType:$cmp_value
  );

  let assemblyFormat = "`(` $ivars `,` $nelems `,` $status `,` $cmp `,` $cmp_value `)` attr-dict `:` "
                       "type($ivars) `,` type($nelems) `,` type($status) `,` type($cmp) `,` type($cmp_value)";
}

//===----------------------------------------------------------------------===//
// WaitUntilAnyOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_WaitUntilAnyOp : OpenSHMEM_Op<"wait_until_any", []> {
  let summary = "Equivalent to shmem_wait_until_any C API";

  let description = [{
    Wait on an array of variables on the local PE until any variable meets
    the specified wait condition.

    C API:
    ```c
    void shmem_wait_until_any(TYPE *ivars, size_t nelems, const int *status,
                              int cmp, TYPE cmp_value);
    ```
  }];

  let arguments = (ins 
    OpenSHMEM_SymmetricMemRef:$ivars,
    Index:$nelems,
    AnyMemRef:$status,
    I32:$cmp,
    AnyType:$cmp_value
  );

  let assemblyFormat = "`(` $ivars `,` $nelems `,` $status `,` $cmp `,` $cmp_value `)` attr-dict `:` "
                       "type($ivars) `,` type($nelems) `,` type($status) `,` type($cmp) `,` type($cmp_value)";
}

//===----------------------------------------------------------------------===//
// WaitUntilSomeOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_WaitUntilSomeOp : OpenSHMEM_Op<"wait_until_some", []> {
  let summary = "Equivalent to shmem_wait_until_some C API";

  let description = [{
    Wait on an array of variables on the local PE until at least one variable
    meets the specified wait condition.

    C API:
    ```c
    size_t shmem_wait_until_some(TYPE *ivars, size_t nelems, size_t *indices,
                                 const int *status, int cmp, TYPE cmp_value);
    ```
  }];

  let arguments = (ins 
    OpenSHMEM_SymmetricMemRef:$ivars,
    Index:$nelems,
    AnyMemRef:$indices,
    AnyMemRef:$status,
    I32:$cmp,
    AnyType:$cmp_value
  );

  let results = (outs Index:$result);

  let assemblyFormat = "`(` $ivars `,` $nelems `,` $indices `,` $status `,` $cmp `,` $cmp_value `)` attr-dict `:` "
                       "type($ivars) `,` type($nelems) `,` type($indices) `,` type($status) `,` type($cmp) `,` type($cmp_value) `->` type($result)";
}

//===----------------------------------------------------------------------===//
// WaitUntilAllVectorOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_WaitUntilAllVectorOp : OpenSHMEM_Op<"wait_until_all_vector", []> {
  let summary = "Equivalent to shmem_wait_until_all_vector C API";

  let description = [{
    Wait on an array of variables on the local PE until all variables
    meet the specified wait conditions.

    C API:
    ```c
    void shmem_wait_until_all_vector(TYPE *ivars, size_t nelems,
                                     const int *status, int cmp,
                                     TYPE *cmp_values);
    ```
  }];

  let arguments = (ins 
    OpenSHMEM_SymmetricMemRef:$ivars,
    Index:$nelems,
    AnyMemRef:$status,
    I32:$cmp,
    AnyMemRef:$cmp_values
  );

  let assemblyFormat = "`(` $ivars `,` $nelems `,` $status `,` $cmp `,` $cmp_values `)` attr-dict `:` "
                       "type($ivars) `,` type($nelems) `,` type($status) `,` type($cmp) `,` type($cmp_values)";
}

//===----------------------------------------------------------------------===//
// WaitUntilAnyVectorOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_WaitUntilAnyVectorOp : OpenSHMEM_Op<"wait_until_any_vector", []> {
  let summary = "Equivalent to shmem_wait_until_any_vector C API";

  let description = [{
    Wait on an array of variables on the local PE until any variable meets
    the specified wait conditions.

    C API:
    ```c
    void shmem_wait_until_any_vector(TYPE *ivars, size_t nelems,
                                     const int *status, int cmp,
                                     TYPE *cmp_values);
    ```
  }];

  let arguments = (ins 
    OpenSHMEM_SymmetricMemRef:$ivars,
    Index:$nelems,
    AnyMemRef:$status,
    I32:$cmp,
    AnyMemRef:$cmp_values
  );

  let assemblyFormat = "`(` $ivars `,` $nelems `,` $status `,` $cmp `,` $cmp_values `)` attr-dict `:` "
                       "type($ivars) `,` type($nelems) `,` type($status) `,` type($cmp) `,` type($cmp_values)";
}

//===----------------------------------------------------------------------===//
// WaitUntilSomeVectorOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_WaitUntilSomeVectorOp : OpenSHMEM_Op<"wait_until_some_vector", []> {
  let summary = "Equivalent to shmem_wait_until_some_vector C API";

  let description = [{
    Wait on an array of variables on the local PE until at least one variable
    meets its specified wait condition.

    C API:
    ```c
    size_t shmem_wait_until_some_vector(TYPE *ivars, size_t nelems,
                                        size_t *indices, const int *status,
                                        int cmp, TYPE *cmp_values);
    ```
  }];

  let arguments = (ins 
    OpenSHMEM_SymmetricMemRef:$ivars,
    Index:$nelems,
    AnyMemRef:$indices,
    AnyMemRef:$status,
    I32:$cmp,
    AnyMemRef:$cmp_values
  );

  let results = (outs Index:$result);

  let assemblyFormat = "`(` $ivars `,` $nelems `,` $indices `,` $status `,` $cmp `,` $cmp_values `)` attr-dict `:` "
                       "type($ivars) `,` type($nelems) `,` type($indices) `,` type($status) `,` type($cmp) `,` type($cmp_values) `->` type($result)";
}

//===----------------------------------------------------------------------===//
// TestOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_TestOp : OpenSHMEM_Op<"test", []> {
  let summary = "Equivalent to shmem_test C API";

  let description = [{
    Indicate whether a variable on the local PE meets the specified condition.

    C API:
    ```c
    int shmem_test(TYPE *ivar, int cmp, TYPE cmp_value);
    ```
  }];

  let arguments = (ins 
    OpenSHMEM_SymmetricMemRef:$ivar,
    I32:$cmp,
    AnyType:$cmp_value
  );

  let results = (outs I32:$result);

  let assemblyFormat = "`(` $ivar `,` $cmp `,` $cmp_value `)` attr-dict `:` "
                       "type($ivar) `,` type($cmp) `,` type($cmp_value) `->` type($result)";
}

//===----------------------------------------------------------------------===//
// TestAllOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_TestAllOp : OpenSHMEM_Op<"test_all", []> {
  let summary = "Equivalent to shmem_test_all C API";

  let description = [{
    Indicate whether all variables within an array of variables on the local
    PE meet a specified test condition.

    C API:
    ```c
    int shmem_test_all(TYPE *ivars, size_t nelems, const int *status,
                       int cmp, TYPE cmp_value);
    ```
  }];

  let arguments = (ins 
    OpenSHMEM_SymmetricMemRef:$ivars,
    Index:$nelems,
    AnyMemRef:$status,
    I32:$cmp,
    AnyType:$cmp_value
  );

  let results = (outs I32:$result);

  let assemblyFormat = "`(` $ivars `,` $nelems `,` $status `,` $cmp `,` $cmp_value `)` attr-dict `:` "
                       "type($ivars) `,` type($nelems) `,` type($status) `,` type($cmp) `,` type($cmp_value) `->` type($result)";
}

//===----------------------------------------------------------------------===//
// TestAnyOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_TestAnyOp : OpenSHMEM_Op<"test_any", []> {
  let summary = "Equivalent to shmem_test_any C API";

  let description = [{
    Indicate whether any one variable within an array of variables on the
    local PE meets a specified test condition.

    C API:
    ```c
    size_t shmem_test_any(TYPE *ivars, size_t nelems, const int *status,
                       int cmp, TYPE cmp_value);
    ```
  }];

  let arguments = (ins 
    OpenSHMEM_SymmetricMemRef:$ivars,
    Index:$nelems,
    AnyMemRef:$status,
    I32:$cmp,
    AnyType:$cmp_value
  );

  let results = (outs Index:$result);

  let assemblyFormat = "`(` $ivars `,` $nelems `,` $status `,` $cmp `,` $cmp_value `)` attr-dict `:` "
                       "type($ivars) `,` type($nelems) `,` type($status) `,` type($cmp) `,` type($cmp_value) `->` type($result)";
}

//===----------------------------------------------------------------------===//
// TestSomeOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_TestSomeOp : OpenSHMEM_Op<"test_some", []> {
  let summary = "Equivalent to shmem_test_some C API";

  let description = [{
    Indicate whether at least one variable within an array of variables on
    the local PE meets a specified test condition.

    C API:
    ```c
    size_t shmem_test_some(TYPE *ivars, size_t nelems, size_t *indices,
                           const int *status, int cmp, TYPE cmp_value);
    ```
  }];

  let arguments = (ins 
    OpenSHMEM_SymmetricMemRef:$ivars,
    Index:$nelems,
    AnyMemRef:$indices,
    AnyMemRef:$status,
    I32:$cmp,
    AnyType:$cmp_value
  );

  let results = (outs Index:$result);

  let assemblyFormat = "`(` $ivars `,` $nelems `,` $indices `,` $status `,` $cmp `,` $cmp_value `)` attr-dict `:` "
                       "type($ivars) `,` type($nelems) `,` type($indices) `,` type($status) `,` type($cmp) `,` type($cmp_value) `->` type($result)";
}

//===----------------------------------------------------------------------===//
// TestAllVectorOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_TestAllVectorOp : OpenSHMEM_Op<"test_all_vector", []> {
  let summary = "Equivalent to shmem_test_all_vector C API";

  let description = [{
    Test if all variables on the local PE meet the specified wait conditions.

    C API:
    ```c
    int shmem_test_all_vector(TYPE *ivars, size_t nelems, const int *status,
                              int cmp, TYPE *cmp_values);
    ```
  }];

  let arguments = (ins 
    OpenSHMEM_SymmetricMemRef:$ivars,
    Index:$nelems,
    AnyMemRef:$status,
    I32:$cmp,
    AnyMemRef:$cmp_values
  );

  let results = (outs I32:$result);

  let assemblyFormat = "`(` $ivars `,` $nelems `,` $status `,` $cmp `,` $cmp_values `)` attr-dict `:` "
                       "type($ivars) `,` type($nelems) `,` type($status) `,` type($cmp) `,` type($cmp_values) `->` type($result)";
}

//===----------------------------------------------------------------------===//
// TestAnyVectorOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_TestAnyVectorOp : OpenSHMEM_Op<"test_any_vector", []> {
  let summary = "Equivalent to shmem_test_any_vector C API";

  let description = [{
    Indicate whether any one variable within an array of variables on the
    local PE meets its specified test condition.

    C API:
    ```c
    size_t shmem_test_any_vector(TYPE *ivars, size_t nelems, const int *status,
                              int cmp, TYPE *cmp_values);
    ```
  }];

  let arguments = (ins 
    OpenSHMEM_SymmetricMemRef:$ivars,
    Index:$nelems,
    AnyMemRef:$status,
    I32:$cmp,
    AnyMemRef:$cmp_values
  );

  let results = (outs Index:$result);

  let assemblyFormat = "`(` $ivars `,` $nelems `,` $status `,` $cmp `,` $cmp_values `)` attr-dict `:` "
                       "type($ivars) `,` type($nelems) `,` type($status) `,` type($cmp) `,` type($cmp_values) `->` type($result)";
}

//===----------------------------------------------------------------------===//
// TestSomeVectorOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_TestSomeVectorOp : OpenSHMEM_Op<"test_some_vector", []> {
  let summary = "Equivalent to shmem_test_some_vector C API";

  let description = [{
    Indicate whether at least one variable within an array of variables on
    the local PE meets its specified test condition.

    C API:
    ```c
    size_t shmem_test_some_vector(TYPE *ivars, size_t nelems, size_t *indices,
                                  const int *status, int cmp, TYPE *cmp_values);
    ```
  }];

  let arguments = (ins 
    OpenSHMEM_SymmetricMemRef:$ivars,
    Index:$nelems,
    AnyMemRef:$indices,
    AnyMemRef:$status,
    I32:$cmp,
    AnyMemRef:$cmp_values
  );

  let results = (outs Index:$result);

  let assemblyFormat = "`(` $ivars `,` $nelems `,` $indices `,` $status `,` $cmp `,` $cmp_values `)` attr-dict `:` "
                       "type($ivars) `,` type($nelems) `,` type($indices) `,` type($status) `,` type($cmp) `,` type($cmp_values) `->` type($result)";
}

//===----------------------------------------------------------------------===//
// SignalWaitUntilOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_SignalWaitUntilOp : OpenSHMEM_Op<"signal_wait_until", []> {
  let summary = "Equivalent to shmem_signal_wait_until C API";

  let description = [{
    Wait for a variable on the local PE to change from a signaling operation.

    C API:
    ```c
    uint64_t shmem_signal_wait_until(uint64_t *sig_addr, int cmp,
                                     uint64_t cmp_value);
    ```
  }];

  let arguments = (ins 
    OpenSHMEM_SymmetricMemRef:$sig_addr,
    I32:$cmp,
    I64:$cmp_value
  );

  let results = (outs I64:$result);

  let assemblyFormat = "`(` $sig_addr `,` $cmp `,` $cmp_value `)` attr-dict `:` "
                       "type($sig_addr) `,` type($cmp) `,` type($cmp_value) `->` type($result)";
}

#endif // MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMPT2PTSYNC_TD
