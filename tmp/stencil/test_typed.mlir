// Test program to verify typed function name generation
module {
  func.func @test_typed(%arg0: i32, %arg1: !llvm.ptr) -> i32 {
    // Initialize OpenSHMEM
    openshmem.init

    // Get PE info (return i32 directly like in hello.mlir)
    %my_pe_i32 = openshmem.my_pe : i32
    %n_pes_i32 = openshmem.n_pes : i32

    // Allocate symmetric memory
    %c64 = arith.constant 64 : index
    %sym_mem = openshmem.malloc(%c64) : index -> !openshmem.symmetric_memref<f32>
    
    // Allocate local memory for testing typed operations
    %c1 = arith.constant 1 : index
    %local_mem = memref.alloca() : memref<1xf32>
    
    // Test openshmem.put with f32 - should generate shmem_float_put
    openshmem.put(%sym_mem, %local_mem, %c1, %my_pe_i32) : !openshmem.symmetric_memref<f32>, memref<1xf32>, index, i32
    
    // Test openshmem.get with f32 - should generate shmem_float_get
    openshmem.get(%local_mem, %sym_mem, %c1, %my_pe_i32) : memref<1xf32>, !openshmem.symmetric_memref<f32>, index, i32

    // Clean up
    openshmem.free(%sym_mem) : !openshmem.symmetric_memref<f32>
    openshmem.finalize

    %c0 = arith.constant 0 : i32
    return %c0 : i32
  }
}