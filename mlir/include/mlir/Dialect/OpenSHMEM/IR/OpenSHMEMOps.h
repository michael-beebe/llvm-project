//===- OpenSHMEMOps.h - OpenSHMEM operations declaration -----*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMOPS_H
#define MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMOPS_H

#include "mlir/IR/OpDefinition.h"

#define GET_OP_CLASSES
#include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEMOps.h.inc"

#endif // MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMOPS_H