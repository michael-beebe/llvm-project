//===- OpenSHMEMTypes.td - OpenSHMEM types --------------------*- tablegen
//-*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file declares the OpenSHMEM dialect types.
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMTYPES_TD
#define MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMTYPES_TD

include "mlir/IR/AttrTypeBase.td"
include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEM.td"

//===----------------------------------------------------------------------===//
// OpenSHMEM Types
//===----------------------------------------------------------------------===//

class OpenSHMEM_Type<string name, string typeMnemonic, list<Trait> traits = []>
    : TypeDef<OpenSHMEM_Dialect, name, traits> {
  let mnemonic = typeMnemonic;
}

//===----------------------------------------------------------------------===//
// openshmem::SymmetricMemRefType
//===----------------------------------------------------------------------===//

// TODO: Uncomment when we implement the full type system
// def OpenSHMEM_SymmetricMemRef : OpenSHMEM_Type<"SymmetricMemRef",
// "symmetric_memref"> {
//   let summary = "OpenSHMEM symmetric memory reference";
//   let description = [{
//     This type represents a reference to symmetric memory that can be accessed
//     remotely by other processing elements (PEs). Symmetric memory is
//     allocated collectively across all PEs and provides the foundation for
//     OpenSHMEM's partitioned global address space model.
//
//     Symmetric memory references are required for remote memory operations
//     like shmem.put and shmem.get to ensure type safety and prevent
//     programming errors.
//   }];
// }

#endif // MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMTYPES_TD
