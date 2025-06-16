//===- Passes.td - OpenSHMEM dialect transformation passes -*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_OPENSHMEM_TRANSFORMS_PASSES_TD
#define MLIR_DIALECT_OPENSHMEM_TRANSFORMS_PASSES_TD

include "mlir/Pass/PassBase.td"

def CoalescePuts : Pass<"openshmem-coalesce-puts"> {
  let summary = "Coalesce consecutive OpenSHMEM put operations";
  let description = [{
    This pass identifies consecutive put operations targeting the same PE
    and attempts to coalesce them into fewer, larger transfers. This optimization
    is particularly beneficial for stencil computations where boundary data
    is transferred in multiple small messages.
    
    The pass looks for patterns like:
    ```
    openshmem.put %dest1, %src1, %size1, %pe
    openshmem.put %dest2, %src2, %size2, %pe
    ```
    
    And transforms them into more efficient single transfers when possible.
  }];
  let constructor = "mlir::openshmem::createCoalescePutsPass()";
  let dependentDialects = ["mlir::openshmem::OpenSHMEMDialect"];
}

#endif // MLIR_DIALECT_OPENSHMEM_TRANSFORMS_PASSES_TD 