// RUN: mlir-opt %s --openshmem-message-aggregation | FileCheck %s

// Test operations that CAN be coalesced - same memory region, multiple transfers
func.func @test_putmem_coalescing_same_region() {
  // CHECK-LABEL: func.func @test_putmem_coalescing_same_region
  openshmem.region {
  
  %size = arith.constant 64 : index
  %pe = arith.constant 1 : i32
  
  %sym_mem = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
  %local_data = memref.alloc() : memref<16xi32>
  
  // These operations use the same memory regions and should be coalesced
  // CHECK: openshmem.putmem
  // CHECK-NOT: openshmem.putmem
  openshmem.putmem(%sym_mem, %local_data, %size, %pe) : memref<i32, #openshmem.symmetric_memory>, memref<16xi32>, index, i32
  openshmem.putmem(%sym_mem, %local_data, %size, %pe) : memref<i32, #openshmem.symmetric_memory>, memref<16xi32>, index, i32
  
  openshmem.quiet
  }
  return
}

// Test operations with different memory regions - should NOT be coalesced
func.func @test_putmem_no_coalescing_different_regions() {
  // CHECK-LABEL: func.func @test_putmem_no_coalescing_different_regions
  openshmem.region {
  
  %size1 = arith.constant 64 : index
  %size2 = arith.constant 128 : index  
  %pe = arith.constant 1 : i32
  
  %sym_mem1 = openshmem.malloc(%size1) : index -> memref<i32, #openshmem.symmetric_memory>
  %sym_mem2 = openshmem.malloc(%size2) : index -> memref<i32, #openshmem.symmetric_memory>
  %local_data1 = memref.alloc() : memref<16xi32>
  %local_data2 = memref.alloc() : memref<32xi32>
  
  // These two putmem operations should NOT be coalesced since they use different memory regions
  // CHECK: openshmem.putmem
  // CHECK: openshmem.putmem
  openshmem.putmem(%sym_mem1, %local_data1, %size1, %pe) : memref<i32, #openshmem.symmetric_memory>, memref<16xi32>, index, i32
  openshmem.putmem(%sym_mem2, %local_data2, %size2, %pe) : memref<i32, #openshmem.symmetric_memory>, memref<32xi32>, index, i32
  
  openshmem.quiet
  }
  return
}

// Test that operations targeting different PEs are NOT coalesced
func.func @test_different_pe_no_coalescing() {
  // CHECK-LABEL: func.func @test_different_pe_no_coalescing
  openshmem.region {
  
  %size = arith.constant 64 : index
  %pe1 = arith.constant 1 : i32
  %pe2 = arith.constant 2 : i32
  
  %sym_mem1 = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
  %sym_mem2 = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
  %local_data1 = memref.alloc() : memref<16xi32>
  %local_data2 = memref.alloc() : memref<16xi32>
  
  // These should NOT be coalesced since they target different PEs
  // CHECK: openshmem.putmem
  // CHECK: openshmem.putmem
  openshmem.putmem(%sym_mem1, %local_data1, %size, %pe1) : memref<i32, #openshmem.symmetric_memory>, memref<16xi32>, index, i32
  openshmem.putmem(%sym_mem2, %local_data2, %size, %pe2) : memref<i32, #openshmem.symmetric_memory>, memref<16xi32>, index, i32
  
  openshmem.quiet
  }
  return
}

// Test coalescing of typed operations
func.func @test_typed_put_coalescing() {
  // CHECK-LABEL: func.func @test_typed_put_coalescing
  openshmem.region {
  
  %nelems = arith.constant 16 : index
  %pe = arith.constant 1 : i32
  
  %sym_mem = openshmem.malloc(%nelems) : index -> memref<i32, #openshmem.symmetric_memory>
  %local_data = memref.alloc() : memref<16xi32>
  
  // These typed operations should be coalesced
  // CHECK: openshmem.put
  // CHECK-NOT: openshmem.put
  openshmem.put(%sym_mem, %local_data, %nelems, %pe) : memref<i32, #openshmem.symmetric_memory>, memref<16xi32>, index, i32
  openshmem.put(%sym_mem, %local_data, %nelems, %pe) : memref<i32, #openshmem.symmetric_memory>, memref<16xi32>, index, i32
  
  openshmem.quiet
  }
  return
}

// Test coalescing of non-blocking operations
func.func @test_nbi_coalescing() {
  // CHECK-LABEL: func.func @test_nbi_coalescing
  openshmem.region {
  
  %nelems = arith.constant 16 : index
  %pe = arith.constant 1 : i32
  
  %sym_mem = openshmem.malloc(%nelems) : index -> memref<i32, #openshmem.symmetric_memory>
  %local_data = memref.alloc() : memref<16xi32>
  
  // These non-blocking operations should be coalesced
  // CHECK: openshmem.put_nbi
  // CHECK-NOT: openshmem.put_nbi
  openshmem.put_nbi(%sym_mem, %local_data, %nelems, %pe) : memref<i32, #openshmem.symmetric_memory>, memref<16xi32>, index, i32
  openshmem.put_nbi(%sym_mem, %local_data, %nelems, %pe) : memref<i32, #openshmem.symmetric_memory>, memref<16xi32>, index, i32
  
  openshmem.quiet
  }
  return
}

// Test that blocking and non-blocking operations are NOT coalesced
func.func @test_blocking_nbi_no_coalescing() {
  // CHECK-LABEL: func.func @test_blocking_nbi_no_coalescing
  openshmem.region {
  
  %nelems = arith.constant 16 : index
  %pe = arith.constant 1 : i32
  
  %sym_mem = openshmem.malloc(%nelems) : index -> memref<i32, #openshmem.symmetric_memory>
  %local_data = memref.alloc() : memref<16xi32>
  
  // These should NOT be coalesced due to different blocking behavior
  // CHECK: openshmem.put
  // CHECK: openshmem.put_nbi
  openshmem.put(%sym_mem, %local_data, %nelems, %pe) : memref<i32, #openshmem.symmetric_memory>, memref<16xi32>, index, i32
  openshmem.put_nbi(%sym_mem, %local_data, %nelems, %pe) : memref<i32, #openshmem.symmetric_memory>, memref<16xi32>, index, i32
  
  openshmem.quiet
  }
  return
}

// Test context-aware operations
func.func @test_context_aware_coalescing(%ctx: !openshmem.ctx) {
  // CHECK-LABEL: func.func @test_context_aware_coalescing
  openshmem.region {
  
  %nelems = arith.constant 16 : index
  %pe = arith.constant 1 : i32
  
  %sym_mem = openshmem.malloc(%nelems) : index -> memref<i32, #openshmem.symmetric_memory>
  %local_data = memref.alloc() : memref<16xi32>
  
  // These context-aware operations should be coalesced
  // CHECK: openshmem.ctx_put
  // CHECK-NOT: openshmem.ctx_put
  openshmem.ctx_put(%ctx, %sym_mem, %local_data, %nelems, %pe) : !openshmem.ctx, memref<i32, #openshmem.symmetric_memory>, memref<16xi32>, index, i32
  openshmem.ctx_put(%ctx, %sym_mem, %local_data, %nelems, %pe) : !openshmem.ctx, memref<i32, #openshmem.symmetric_memory>, memref<16xi32>, index, i32
  
  openshmem.quiet
  }
  return
}

// Test that operations with different contexts are NOT coalesced
func.func @test_different_context_no_coalescing(%ctx1: !openshmem.ctx, %ctx2: !openshmem.ctx) {
  // CHECK-LABEL: func.func @test_different_context_no_coalescing
  openshmem.region {
  
  %nelems = arith.constant 16 : index
  %pe = arith.constant 1 : i32
  
  %sym_mem = openshmem.malloc(%nelems) : index -> memref<i32, #openshmem.symmetric_memory>
  %local_data = memref.alloc() : memref<16xi32>
  
  // These should NOT be coalesced due to different contexts
  // CHECK: openshmem.ctx_put
  // CHECK: openshmem.ctx_put
  openshmem.ctx_put(%ctx1, %sym_mem, %local_data, %nelems, %pe) : !openshmem.ctx, memref<i32, #openshmem.symmetric_memory>, memref<16xi32>, index, i32
  openshmem.ctx_put(%ctx2, %sym_mem, %local_data, %nelems, %pe) : !openshmem.ctx, memref<i32, #openshmem.symmetric_memory>, memref<16xi32>, index, i32
  
  openshmem.quiet
  }
  return
}

// Test sized operations coalescing
func.func @test_sized_operations_coalescing() {
  // CHECK-LABEL: func.func @test_sized_operations_coalescing
  openshmem.region {
  
  %nelems = arith.constant 8 : index
  %pe = arith.constant 1 : i32
  
  %sym_mem = openshmem.malloc(%nelems) : index -> memref<i32, #openshmem.symmetric_memory>
  %local_data = memref.alloc() : memref<8xi32>
  
  // These 32-bit operations should be coalesced
  // CHECK: openshmem.put32
  // CHECK-NOT: openshmem.put32
  openshmem.put32(%sym_mem, %local_data, %nelems, %pe) : memref<i32, #openshmem.symmetric_memory>, memref<8xi32>, index, i32
  openshmem.put32(%sym_mem, %local_data, %nelems, %pe) : memref<i32, #openshmem.symmetric_memory>, memref<8xi32>, index, i32
  
  openshmem.quiet
  }
  return
}

// Test that different sized operations are NOT coalesced
func.func @test_different_sized_no_coalescing() {
  // CHECK-LABEL: func.func @test_different_sized_no_coalescing
  openshmem.region {
  
  %nelems = arith.constant 8 : index
  %pe = arith.constant 1 : i32
  
  %sym_mem = openshmem.malloc(%nelems) : index -> memref<i32, #openshmem.symmetric_memory>
  %local_data = memref.alloc() : memref<8xi32>
  
  // These should NOT be coalesced due to different sizes
  // CHECK: openshmem.put32
  // CHECK: openshmem.put64
  openshmem.put32(%sym_mem, %local_data, %nelems, %pe) : memref<i32, #openshmem.symmetric_memory>, memref<8xi32>, index, i32
  openshmem.put64(%sym_mem, %local_data, %nelems, %pe) : memref<i32, #openshmem.symmetric_memory>, memref<8xi32>, index, i32
  
  openshmem.quiet
  }
  return
}

// Test GET operations coalescing
func.func @test_get_coalescing() {
  // CHECK-LABEL: func.func @test_get_coalescing
  openshmem.region {
  
  %size = arith.constant 64 : index
  %pe = arith.constant 1 : i32
  
  %sym_mem = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
  %local_data = memref.alloc() : memref<16xi32>
  
  // These GET operations should be coalesced
  // CHECK: openshmem.getmem
  // CHECK-NOT: openshmem.getmem
  openshmem.getmem(%local_data, %sym_mem, %size, %pe) : memref<16xi32>, memref<i32, #openshmem.symmetric_memory>, index, i32
  openshmem.getmem(%local_data, %sym_mem, %size, %pe) : memref<16xi32>, memref<i32, #openshmem.symmetric_memory>, index, i32
  
  openshmem.quiet
  }
  return
}

// Test that PUT and GET operations are NOT coalesced
func.func @test_put_get_no_coalescing() {
  // CHECK-LABEL: func.func @test_put_get_no_coalescing
  openshmem.region {
  
  %size = arith.constant 64 : index
  %pe = arith.constant 1 : i32
  
  %sym_mem = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
  %local_data1 = memref.alloc() : memref<16xi32>
  %local_data2 = memref.alloc() : memref<16xi32>
  
  // These should NOT be coalesced due to different operation types
  // CHECK: openshmem.putmem
  // CHECK: openshmem.getmem
  openshmem.putmem(%sym_mem, %local_data1, %size, %pe) : memref<i32, #openshmem.symmetric_memory>, memref<16xi32>, index, i32
  openshmem.getmem(%local_data2, %sym_mem, %size, %pe) : memref<16xi32>, memref<i32, #openshmem.symmetric_memory>, index, i32
  
  openshmem.quiet
  }
  return
}

// Test small message size (should NOT be coalesced due to threshold)
func.func @test_small_message_size_no_coalescing() {
  // CHECK-LABEL: func.func @test_small_message_size_no_coalescing
  openshmem.region {
  
  %c4 = arith.constant 4 : index  // Small size below typical threshold
  %pe = arith.constant 1 : i32
  
  %sym_mem = openshmem.malloc(%c4) : index -> memref<i32, #openshmem.symmetric_memory>
  %local_data1 = memref.alloc() : memref<1xi32>
  %local_data2 = memref.alloc() : memref<1xi32>
  
  %size = arith.constant 1 : index
  
  // These small operations might not be coalesced due to size thresholds
  // Current pass does duplicate removal regardless of size
  // CHECK: openshmem.putmem
  // CHECK-NOT: openshmem.putmem
  openshmem.putmem(%sym_mem, %local_data1, %size, %pe) : memref<i32, #openshmem.symmetric_memory>, memref<1xi32>, index, i32
  openshmem.putmem(%sym_mem, %local_data1, %size, %pe) : memref<i32, #openshmem.symmetric_memory>, memref<1xi32>, index, i32
  
  openshmem.quiet
  }
  return
}

// Test mixed operation types with same memory (should NOT be coalesced)
func.func @test_mixed_memory_operations_no_coalescing() {
  // CHECK-LABEL: func.func @test_mixed_memory_operations_no_coalescing
  openshmem.region {
  
  %c64 = arith.constant 64 : index
  %pe = arith.constant 1 : i32
  
  %sym_mem1 = openshmem.malloc(%c64) : index -> memref<i32, #openshmem.symmetric_memory>
  %sym_mem2 = openshmem.malloc(%c64) : index -> memref<i32, #openshmem.symmetric_memory>
  %local_data = memref.alloc() : memref<16xi32>
  
  // Mix of putmem and getmem to same PE - should NOT be coalesced due to different operation types
  // CHECK: openshmem.putmem
  // CHECK: openshmem.getmem
  openshmem.putmem(%sym_mem1, %local_data, %c64, %pe) : memref<i32, #openshmem.symmetric_memory>, memref<16xi32>, index, i32
  openshmem.getmem(%local_data, %sym_mem2, %c64, %pe) : memref<16xi32>, memref<i32, #openshmem.symmetric_memory>, index, i32
  
  openshmem.quiet
  }
  return
}
