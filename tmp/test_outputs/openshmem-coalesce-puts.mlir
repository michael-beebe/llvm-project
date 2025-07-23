module {
  func.func @test_coalesce_puts(%arg0: memref<100xi32>, %arg1: !openshmem.symmetric_memref<i32>) {
    %c1_i32 = arith.constant 1 : i32
    %c12 = arith.constant 12 : index
    openshmem.putmem(%arg1, %arg0, %c12, %c1_i32) : <i32>, memref<100xi32>, index, i32
    return
  }
  func.func @test_different_pes(%arg0: memref<100xi32>, %arg1: !openshmem.symmetric_memref<i32>) {
    %c0_i32 = arith.constant 0 : i32
    %c1_i32 = arith.constant 1 : i32
    %c2_i32 = arith.constant 2 : i32
    %c4 = arith.constant 4 : index
    openshmem.putmem(%arg1, %arg0, %c4, %c0_i32) : <i32>, memref<100xi32>, index, i32
    openshmem.putmem(%arg1, %arg0, %c4, %c1_i32) : <i32>, memref<100xi32>, index, i32
    openshmem.putmem(%arg1, %arg0, %c4, %c2_i32) : <i32>, memref<100xi32>, index, i32
    return
  }
}

