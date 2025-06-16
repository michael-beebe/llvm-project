//===- OpenSHMEMOps.cpp - OpenSHMEM dialect ops implementation ------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEM.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/DialectImplementation.h"
#include "mlir/IR/OpImplementation.h"
#include "mlir/IR/OperationSupport.h"

using namespace mlir;
using namespace mlir::openshmem;

// Register the dialect operations
#define GET_OP_CLASSES
#include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEMOps.cpp.inc"
