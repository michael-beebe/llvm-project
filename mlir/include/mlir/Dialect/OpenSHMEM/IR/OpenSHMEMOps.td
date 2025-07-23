//===- OpenSHMEMOps.td - OpenSHMEM dialect operations ------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMOPS_TD
#define MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMOPS_TD

include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEMBase.td"
include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEMSetup.td"
include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEMMemory.td"
include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEMRMAOps.td"
include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEMCollectives.td"
include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEMTeams.td"
include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEMContexts.td"
include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEMAtomics.td"
include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEMSync.td"

//===----------------------------------------------------------------------===//
// TODO: REMAINING OPERATIONS
//===----------------------------------------------------------------------===//
// The following operations are not yet implemented and should be added
// to the appropriate modular files when needed:
//
// Op to initialize the default context
//
// Memory Operations:
// - shmem_realloc, shmem_align, shmem_calloc
//
// Point-to-Point Operations:
// - shmem_iput, shmem_iget
//
// Typed Collective Operations:
// - typed variants of collective operations (alltoall_TYPE, etc.)
//
// Reduction Operations:
// - shmem_and_reduce, shmem_or_reduce, shmem_xor_reduce
// - shmem_max_reduce, shmem_min_reduce, shmem_sum_reduce, shmem_prod_reduce
//
// Point-to-Point Synchronization:
// - shmem_wait_until, shmem_test, shmem_wait_until_all, shmem_wait_until_any
// - shmem_wait_until_some, shmem_test_all, shmem_test_any, shmem_test_some
//
// Lock Operations:
// - shmem_set_lock, shmem_clear_lock, shmem_test_lock
//
// Fence Operations:
// - shmem_fence, shmem_ctx_fence
//
// Signal Operations:  
// - shmem_put_signal, shmem_put_signal_nbi
// - shmem_signal_fetch, shmem_signal_set
//
//
//===----------------------------------------------------------------------===//

#endif // MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMOPS_TD
