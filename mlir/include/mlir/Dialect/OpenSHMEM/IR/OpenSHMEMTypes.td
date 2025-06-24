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
//
// FIXME: I don't think this is needed.
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
//
// FIXME: I don't think this is needed.
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

def OpenSHMEM_SymmetricMemRef : OpenSHMEM_Type<"SymmetricMemRef", "symmetric_memref"> {
  l et summary = "Symmetric memory reference (distinct from memref)";
  let description = [{
    Represents a reference to symmetric memory that is accessible from all PEs.
    This type is distinct from standard memref: it is only produced by openshmem.malloc
    and is required for all OpenSHMEM operations that use symmetric memory (e.g., putmem, getmem, free).
    Symmetric memory has the same virtual address on all PEs and can be used in
    one-sided communication operations. Only values of this type are valid for
    OpenSHMEM symmetric memory operations.
  }];
  
  let parameters = (ins
    "Type":$elementType
  );
  
  let assemblyFormat = "`<` $elementType `>`";
}

//===----------------------------------------------------------------------===//
// Team type
//===----------------------------------------------------------------------===//

// TODO: implement teams

def OpenSHMEM_Team : OpenSHMEM_Type<"Team", "team"> {
  let summary = "Team type for OpenSHMEM operations";
  let description = [{
    Represents a team of PEs in an OpenSHMEM program.
  }];
  let parameters = (ins
    "Type":$elementType
  );
  
  let assemblyFormat = "`<` $elementType `>`";
}

#endif // MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMTYPES_TD
