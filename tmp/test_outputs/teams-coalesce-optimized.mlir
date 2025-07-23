module {
  func.func @test_teams_with_coalescing() {
    %c1_i32 = arith.constant 1 : i32
    %c40 = arith.constant 40 : index
    openshmem.init
    %0 = openshmem.team_world -> !openshmem.team
    %ptr = openshmem.malloc(%c40) : index -> <i32>
    %alloc = memref.alloc() : memref<10xi32>
    openshmem.team_sync(%0) : !openshmem.team
    openshmem.putmem(%ptr, %alloc, %c40, %c1_i32) : <i32>, memref<10xi32>, index, i32
    openshmem.team_sync(%0) : !openshmem.team
    memref.dealloc %alloc : memref<10xi32>
    openshmem.free(%ptr) : <i32>
    openshmem.finalize
    return
  }
}

