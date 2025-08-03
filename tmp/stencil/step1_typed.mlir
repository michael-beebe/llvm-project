module attributes {openshmem.num_pes = 4 : i32} {
  func.func @test_typed(%arg0: i32, %arg1: !llvm.ptr) -> i32 {
    openshmem.init
    %0 = openshmem.my_pe : i32
    %1 = openshmem.n_pes : i32
    %c64 = arith.constant 64 : index
    %2 = openshmem.malloc(%c64) : index -> <f32>
    %c1 = arith.constant 1 : index
    %alloca = memref.alloca() : memref<1xf32>
    openshmem.put(%2, %alloca, %c1, %0) : <f32>, memref<1xf32>, index, i32
    openshmem.get(%alloca, %2, %c1, %0) : memref<1xf32>, <f32>, index, i32
    openshmem.free(%2) : <f32>
    openshmem.finalize
    %c0_i32 = arith.constant 0 : i32
    return %c0_i32 : i32
  }
}

