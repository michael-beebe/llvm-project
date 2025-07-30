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

def MessageAggregation : Pass<"openshmem-message-aggregation"> {
  let summary = "Comprehensive message aggregation for OpenSHMEM operations";
  let description = [{
    This pass performs comprehensive analysis and optimization of OpenSHMEM
    communication patterns. It identifies opportunities to coalesce multiple
    small transfers into fewer, larger ones across all RMA operation types.
    
    Key optimizations include:
    - Contiguous memory access coalescing
    - Same-target operation batching  
    - Cross-operation type optimization
    - Non-blocking conversion for better overlap
    
    The pass respects OpenSHMEM semantics including context boundaries,
    synchronization points, and memory ordering requirements.
  }];
  
  let options = [
    Option<"enablePutCoalescing", "enable-put-coalescing", "bool", 
           /*default=*/"true",
           "Enable coalescing of put operations">,
    Option<"enableGetCoalescing", "enable-get-coalescing", "bool",
           /*default=*/"true", 
           "Enable coalescing of get operations">,
    Option<"enableCrossOpOptimization", "enable-cross-op", "bool",
           /*default=*/"true",
           "Enable optimization across different operation types">,
    Option<"enableNonBlockingConversion", "enable-nb-conversion", "bool",
           /*default=*/"false",
           "Convert blocking operations to non-blocking where beneficial">,
    Option<"maxCoalescingDistance", "max-distance", "unsigned",
           /*default=*/"10",
           "Maximum number of intervening operations to consider for coalescing">,
    Option<"minMessageSize", "min-message-size", "unsigned", 
           /*default=*/"64",
           "Minimum message size (bytes) to consider for coalescing">,
    Option<"maxMessageSize", "max-message-size", "unsigned",
           /*default=*/"1048576", 
           "Maximum coalesced message size (bytes)">,
    Option<"enableStridedAccess", "enable-strided", "bool",
           /*default=*/"false",
           "Enable optimization of strided access patterns">,
    Option<"debugMode", "debug", "bool",
           /*default=*/"false",
           "Enable detailed debug output for transformation decisions">
  ];
  
  let constructor = "mlir::openshmem::createMessageAggregationPass()";
  let dependentDialects = ["mlir::openshmem::OpenSHMEMDialect", "mlir::arith::ArithDialect"];
}

def InjectNumPEs : Pass<"openshmem-inject-num-pes"> {
  let summary = "Injects or overrides the openshmem.num_pes module attribute";
  let description = [{
    This pass injects or overrides the `openshmem.num_pes` module attribute.
    Use this to specify the number of PEs for optimization or analysis without
    modifying the input MLIR file.
  }];
  let options = [
    Option<"numPEs", "num-pes", "int", "-1",
           "Number of PEs to inject as a module attribute">
  ];
  let constructor = "mlir::openshmem::createInjectNumPEsPass() ";
      let dependentDialects = ["mlir::openshmem::OpenSHMEMDialect"];
}

#endif // MLIR_DIALECT_OPENSHMEM_TRANSFORMS_PASSES_TD
