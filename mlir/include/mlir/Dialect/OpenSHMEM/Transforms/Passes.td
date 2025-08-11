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

def AtomicFusion : Pass<"openshmem-atomic-fusion"> {
  let summary = "Fuse adjacent OpenSHMEM atomic operations on the same location";
  let description = [{
    This pass performs simple, semantics-preserving fusion of adjacent atomic
    operations on the same symmetric memory location, PE, and context.

    Currently supported fusions (adjacent-only):
    - atomic_add + atomic_add -> atomic_add with summed value
    - atomic_or + atomic_or -> atomic_or with ORed value
    - atomic_xor + atomic_xor -> atomic_xor with XORed value
    - chains of atomic_inc -> a single atomic_add with a constant increment
    - For fetch variants (e.g., atomic_fetch_add), if results are dead, they
      are combined into a single non-fetch variant with the combined value

    The pass is conservative: it only considers immediately adjacent operations
    within a block and requires matching PE and, if present, matching context.
  }];

  let constructor = "mlir::openshmem::createAtomicFusionPass()";
  let dependentDialects = [
    "mlir::arith::ArithDialect",
    "mlir::openshmem::OpenSHMEMDialect"
  ];
}

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

def AsyncConversion : Pass<"openshmem-async-conversion"> {
  let summary = "Convert blocking OpenSHMEM RMA ops to non-blocking when trivially safe";
  let description = [{
    Performs simple, semantics-preserving async conversions of blocking RMA
    operations into their non-blocking (_nbi) variants when it is trivially
    safe. Currently, the pass applies the following peepholes when an
    operation is immediately followed by an `openshmem.quiet`:

    - put -> put_nbi
    - ctx_put -> ctx_put_nbi
    - get -> get_nbi (only if immediately followed by quiet)
    - ctx_get -> ctx_get_nbi (only if immediately followed by quiet)
    - putmem -> putmem_nbi
    - getmem -> getmem_nbi (only if immediately followed by quiet)

    These transformations ensure correctness by relying on the immediate
    `openshmem.quiet` to preserve completion semantics.
  }];

  let constructor = "mlir::openshmem::createAsyncConversionPass()";
  let dependentDialects = [
    "mlir::openshmem::OpenSHMEMDialect",
    "mlir::arith::ArithDialect"
  ];
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
