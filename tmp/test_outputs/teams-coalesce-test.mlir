module {
  func.func @test_teams_with_coalescing() {
    openshmem.init
    %world_team = openshmem.team_world -> !openshmem.team
    
    // Allocate memory
    %size = arith.constant 40 : index
    %sym_mem = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i32>
    %local_data = memref.alloc() : memref<10xi32>
    
    // Team sync before communication
    openshmem.team_sync(%world_team) : !openshmem.team
    
    // Multiple puts that could be coalesced
    %pe1 = arith.constant 1 : i32
    %size1 = arith.constant 20 : index
    %size2 = arith.constant 20 : index
    openshmem.putmem(%sym_mem, %local_data, %size1, %pe1) : 
      !openshmem.symmetric_memref<i32>, memref<10xi32>, index, i32
    openshmem.putmem(%sym_mem, %local_data, %size2, %pe1) : 
      !openshmem.symmetric_memref<i32>, memref<10xi32>, index, i32
    
    // Team sync after communication
    openshmem.team_sync(%world_team) : !openshmem.team
    
    memref.dealloc %local_data : memref<10xi32>
    openshmem.free(%sym_mem) : !openshmem.symmetric_memref<i32>
    openshmem.finalize
    return
  }
}
