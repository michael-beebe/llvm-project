//===- OpenSHMEMTypes.td - OpenSHMEM dialect types --------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMTYPES_TD
#define MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMTYPES_TD

include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEM.td"
include "mlir/IR/AttrTypeBase.td"

//===----------------------------------------------------------------------===//
// Base OpenSHMEM type
//===----------------------------------------------------------------------===//

class OpenSHMEM_Type<string name, string typeMnemonic, list<Trait> traits = []>
    : TypeDef<OpenSHMEM_Dialect, name, traits> {
  let mnemonic = typeMnemonic;
}

//===----------------------------------------------------------------------===//
// Processing Element (PE) type
//===----------------------------------------------------------------------===//

def OpenSHMEM_PE : OpenSHMEM_Type<"PE", "pe"> {
  let summary = "OpenSHMEM Processing Element number";
  let description = [{
    Represents a Processing Element (PE) number in an OpenSHMEM program.
    PE numbers range from 0 to n_pes()-1.
  }];
}

//===----------------------------------------------------------------------===//
// Size type for memory operations
//===----------------------------------------------------------------------===//

def OpenSHMEM_Size : OpenSHMEM_Type<"Size", "size"> {
  let summary = "Size type for OpenSHMEM memory operations";
  let description = [{
    Represents a size value used in OpenSHMEM memory operations.
    Typically corresponds to size_t in C.
  }];
}

//===----------------------------------------------------------------------===//
// Return value type for error checking
//===----------------------------------------------------------------------===//

def OpenSHMEM_Retval : OpenSHMEM_Type<"Retval", "retval"> {
  let summary = "Return value type for OpenSHMEM operations";
  let description = [{
    Represents a return value from OpenSHMEM operations that can be used
    for error checking. Typically corresponds to int in C.
  }];
}

//===----------------------------------------------------------------------===//
// Symmetric memory type
//===----------------------------------------------------------------------===//

def OpenSHMEM_SymmetricMemRef : OpenSHMEM_Type<"SymmetricMemRef", 
                     "symmetric_memref" > {
    let summary = "Symmetric memory reference";
    let description = [{
    Represents a reference to symmetric memory that is accessible from all PEs.
    This memory has the same virtual address on all PEs and can be used in
    one-sided communication operations.
  }];
  
  let parameters = (ins
    "Type":$elementType
  );
  
  let assemblyFormat = "`<` $elementType `>`";
}

//===----------------------------------------------------------------------===//
// Type constraints for operations
//===----------------------------------------------------------------------===//

// // Valid types for OpenSHMEM data operations
// def OpenSHMEM_DataType : AnyTypeOf<[
//   I8, I16, I32, I64,
//   F16, F32, F64,
//   Index
// ], "OpenSHMEM-compatible data type">;

#endif // MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMTYPES_TD
