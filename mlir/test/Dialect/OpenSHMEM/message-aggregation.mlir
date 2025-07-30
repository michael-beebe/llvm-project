// RUN: mlir-opt %s --openshmem-message-aggregation | FileCheck %s

// Test operations that CAN be coalesced - same memory region, multiple transfers
func.func @test_putmem_coalescing_same_region() {
  // CHECK-LABEL: func.func @test_putmem_coalescing_same_region
  openshmem.init
  
  %size = arith.constant 64 : index
  %pe = arith.constant 1 : i32
  
  %sym_mem = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i32>
  %local_data = memref.alloc() : memref<16xi32>
  
  // These operations use the same memory regions and should be coalesced
  // CHECK: openshmem.putmem
  // CHECK-NOT: openshmem.putmem
  openshmem.putmem(%sym_mem, %local_data, %size, %pe) : !openshmem.symmetric_memref<i32>, memref<16xi32>, index, i32
  openshmem.putmem(%sym_mem, %local_data, %size, %pe) : !openshmem.symmetric_memref<i32>, memref<16xi32>, index, i32
  
  openshmem.quiet
  openshmem.finalize
  return
}

// Test operations with different memory regions - should NOT be coalesced
func.func @test_putmem_no_coalescing_different_regions() {
  // CHECK-LABEL: func.func @test_putmem_no_coalescing_different_regions
  openshmem.init
  
  %size1 = arith.constant 64 : index
  %size2 = arith.constant 128 : index  
  %pe = arith.constant 1 : i32
  
  %sym_mem1 = openshmem.malloc(%size1) : index -> !openshmem.symmetric_memref<i32>
  %sym_mem2 = openshmem.malloc(%size2) : index -> !openshmem.symmetric_memref<i32>
  %local_data1 = memref.alloc() : memref<16xi32>
  %local_data2 = memref.alloc() : memref<32xi32>
  
  // These two putmem operations should NOT be coalesced since they use different memory regions
  // CHECK: openshmem.putmem
  // CHECK: openshmem.putmem
  openshmem.putmem(%sym_mem1, %local_data1, %size1, %pe) : !openshmem.symmetric_memref<i32>, memref<16xi32>, index, i32
  openshmem.putmem(%sym_mem2, %local_data2, %size2, %pe) : !openshmem.symmetric_memref<i32>, memref<32xi32>, index, i32
  
  openshmem.quiet
  openshmem.finalize
  return
}

// Test that operations targeting different PEs are NOT coalesced
func.func @test_different_pe_no_coalescing() {
  // CHECK-LABEL: func.func @test_different_pe_no_coalescing
  openshmem.init
  
  %size = arith.constant 64 : index
  %pe1 = arith.constant 1 : i32
  %pe2 = arith.constant 2 : i32
  
  %sym_mem1 = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i32>
  %sym_mem2 = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i32>
  %local_data1 = memref.alloc() : memref<16xi32>
  %local_data2 = memref.alloc() : memref<16xi32>
  
  // These should NOT be coalesced since they target different PEs
  // CHECK: openshmem.putmem
  // CHECK: openshmem.putmem
  openshmem.putmem(%sym_mem1, %local_data1, %size, %pe1) : !openshmem.symmetric_memref<i32>, memref<16xi32>, index, i32
  openshmem.putmem(%sym_mem2, %local_data2, %size, %pe2) : !openshmem.symmetric_memref<i32>, memref<16xi32>, index, i32
  
  openshmem.quiet
  openshmem.finalize
  return
}
