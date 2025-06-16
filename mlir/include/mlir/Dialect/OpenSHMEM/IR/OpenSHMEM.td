//===- OpenSHMEM.td - Base defs for openshmem dialect ----------*- tablegen
//-*-===//
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
  let name = "openshmem";
  let cppNamespace = "::mlir::openshmem";
  let description = [{
    This dialect models the OpenSHMEM partitioned global address space (PGAS) 
    programming model. It provides operations for symmetric memory allocation,
    remote memory access (put/get), and synchronization primitives.
    
    The dialect is designed to enable compile-time optimization of OpenSHMEM
    communication patterns, particularly for stencil computations and other
    regular communication patterns common in scientific computing.
  }];

  let useDefaultAttributePrinterParser = 1;
  let useDefaultTypePrinterParser = 1;
}

#endif // MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEM_TD
