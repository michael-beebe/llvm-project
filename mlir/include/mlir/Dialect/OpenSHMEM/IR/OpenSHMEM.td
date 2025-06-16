//===- OpenSHMEM.td - OpenSHMEM dialect definition --------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEM_TD
#define MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEM_TD

include "mlir/IR/AttrTypeBase.td"
include "mlir/IR/OpBase.td"
include "mlir/IR/EnumAttr.td"

def OpenSHMEM_Dialect : Dialect {
  // TODO:
  let name = "openshmem";
  let cppNamespace = "::mlir::openshmem";
  let description = [{
    This dialect models the OpenSHMEM (Open Symmetric Hierarchical Memory) 
    programming model. It provides operations for one-sided communication
    and symmetric memory management in PGAS (Partitioned Global Address Space)
    programming.

    This dialect is under active development and is designed as a proof-of-concept
    for representing OpenSHMEM operations in MLIR.
  }];

  let useDefaultAttributePrinterParser = 1;
  let useDefaultTypePrinterParser = 1;
}

#endif // MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEM_TD
