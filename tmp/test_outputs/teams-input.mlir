// RUN: mlir-opt %s --convert-openshmem-to-llvm --convert-func-to-llvm --reconcile-unrealized-casts | mlir-translate --mlir-to-llvmir | FileCheck %s

// Test the OpenSHMEM dialect team operations

module {
  func.func @test_teams() {
    // Initialize OpenSHMEM
    openshmem.init
    
    // Get PE information
    %pe = openshmem.my_pe : i32
    %npes = openshmem.n_pes : i32

    // Get predefined teams
    %world_team = openshmem.team_world -> !openshmem.team
    %shared_team = openshmem.team_shared -> !openshmem.team

    // Query team information
    %world_pe = openshmem.team_my_pe(%world_team) : !openshmem.team -> i32
    %world_npes = openshmem.team_n_pes(%world_team) : !openshmem.team -> i32
    %shared_pe = openshmem.team_my_pe(%shared_team) : !openshmem.team -> i32

    // Create strided teams (split world team into groups of 2 with stride 1)
    %start = arith.constant 0 : i32
    %stride = arith.constant 1 : i32  
    %size = arith.constant 2 : i32
    %strided_team, %ret1 = openshmem.team_split_strided(%world_team, %start, %stride, %size) : 
      !openshmem.team, i32, i32, i32 -> !openshmem.team, i32

    // Create 2D teams (split world team into 2D grid)
    %xrange = arith.constant 2 : i32
    %xaxis_team, %yaxis_team, %ret2 = openshmem.team_split_2d(%world_team, %xrange) : 
      !openshmem.team, i32 -> !openshmem.team, !openshmem.team, i32

    // Use teams for synchronization
    openshmem.team_sync(%strided_team) : !openshmem.team
    openshmem.team_sync(%xaxis_team) : !openshmem.team
    openshmem.team_sync(%yaxis_team) : !openshmem.team

    // Query team-specific information
    %strided_pe = openshmem.team_my_pe(%strided_team) : !openshmem.team -> i32
    %strided_npes = openshmem.team_n_pes(%strided_team) : !openshmem.team -> i32

    // Clean up teams
    openshmem.team_destroy(%strided_team) : !openshmem.team
    openshmem.team_destroy(%xaxis_team) : !openshmem.team
    openshmem.team_destroy(%yaxis_team) : !openshmem.team

    // Global barrier before finalization
    openshmem.barrier_all

    // Finalize OpenSHMEM
    openshmem.finalize
    return
  }

  func.func @test_team_communication() {
    openshmem.init
    
    %world_team = openshmem.team_world -> !openshmem.team
    
    // Split into pairs
    %start = arith.constant 0 : i32
    %stride = arith.constant 1 : i32
    %size = arith.constant 2 : i32
    %pair_team, %ret = openshmem.team_split_strided(%world_team, %start, %stride, %size) : 
      !openshmem.team, i32, i32, i32 -> !openshmem.team, i32

    // Allocate symmetric memory
    %mem_size = arith.constant 40 : index
    %sym_mem = openshmem.malloc(%mem_size) : index -> !openshmem.symmetric_memref<i32>
    
    // Allocate local memory
    %local_data = memref.alloc() : memref<10xi32>
    
    // Synchronize within team before communication
    openshmem.team_sync(%pair_team) : !openshmem.team
    
    // Get team PE information for communication
    %team_pe = openshmem.team_my_pe(%pair_team) : !openshmem.team -> i32
    %team_npes = openshmem.team_n_pes(%pair_team) : !openshmem.team -> i32
    
    // Calculate target PE within team (if PE 0, send to PE 1, and vice versa)
    %zero = arith.constant 0 : i32
    %one = arith.constant 1 : i32
    %cmp = arith.cmpi eq, %team_pe, %zero : i32
    %target_team_pe = arith.select %cmp, %one, %zero : i32
    
    // Convert team PE to global PE for communication
    // This is simplified - in practice you'd need proper PE translation
    %target_global_pe = arith.addi %target_team_pe, %zero : i32  // Simplified assumption
    
    // Perform communication
    %put_size = arith.constant 40 : index
    openshmem.putmem(%sym_mem, %local_data, %put_size, %target_global_pe) : 
      !openshmem.symmetric_memref<i32>, memref<10xi32>, index, i32

    // Synchronize within team after communication
    openshmem.team_sync(%pair_team) : !openshmem.team
    
    // Clean up
    memref.dealloc %local_data : memref<10xi32>
    openshmem.free(%sym_mem) : !openshmem.symmetric_memref<i32>
    openshmem.team_destroy(%pair_team) : !openshmem.team
    
    openshmem.finalize
    return
  }
}

// CHECK: define void @test_teams()
// CHECK: call void @shmem_init()
// CHECK: call i32 @shmem_my_pe()
// CHECK: call i32 @shmem_n_pes()
// CHECK: @SHMEM_TEAM_WORLD
// CHECK: @SHMEM_TEAM_SHARED
// CHECK: call i32 @shmem_team_my_pe(ptr
// CHECK: call i32 @shmem_team_n_pes(ptr
// CHECK: call i32 @shmem_team_my_pe(ptr
// CHECK: call void @shmem_team_sync(ptr
// CHECK: call void @shmem_team_destroy(ptr
// CHECK: call void @shmem_finalize() 