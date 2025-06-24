module attributes {openshmem.num_pes = 16 : i32} {
  func.func @main() {
    %c1_i32 = arith.constant 1 : i32
    %c10_i64 = arith.constant 10 : i64
    %c40_i64 = arith.constant 40 : i64
    openshmem.init
    %0 = openshmem.my_pe : i32
    %1 = openshmem.n_pes : i32
    %ptr = openshmem.malloc(%c40_i64) : i64 -> <i32>
    %alloc = memref.alloc() : memref<10xi32>
    openshmem.barrier_all
    openshmem.put(%ptr, %alloc, %c10_i64, %c1_i32) : <i32>, memref<10xi32>, i64, i32
    openshmem.get(%alloc, %ptr, %c10_i64, %c1_i32) : memref<10xi32>, <i32>, i64, i32
    openshmem.quiet
    memref.dealloc %alloc : memref<10xi32>
    openshmem.free(%ptr) : <i32>
    openshmem.finalize
    return
  }
}

