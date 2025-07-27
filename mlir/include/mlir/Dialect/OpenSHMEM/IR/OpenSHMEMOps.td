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
include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEMPt2ptSync.td"

//===----------------------------------------------------------------------===//
// TODO: REMAINING v1.5 OPERATIONS
//===----------------------------------------------------------------------===//
// The following operations are not yet implemented and should be added
// to the appropriate modular files when needed:
//
// Op to initialize the default context
//
// Point-to-Point Operations:
// - shmem_iput, shmem_iget
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
