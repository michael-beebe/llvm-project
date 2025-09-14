// RUN: mlir-opt %s --convert-openshmem-to-llvm --convert-func-to-llvm --reconcile-unrealized-casts | mlir-translate --mlir-to-llvmir | FileCheck %s

// Test OpenSHMEM Team Operations

module {
  // Test basic team functionality
  func.func @test_teams() {
    // Initialize OpenSHMEM
    openshmem.region {
    
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
    }
    return
  }

  // Test predefined teams
  func.func @test_predefined_teams() {
    openshmem.region {
    %world_team = openshmem.team_world -> !openshmem.team
    %shared_team = openshmem.team_shared -> !openshmem.team
    
    // Actually use the teams so they appear in the IR
    %pe1 = openshmem.team_my_pe(%world_team) : !openshmem.team -> i32
    %pe2 = openshmem.team_my_pe(%shared_team) : !openshmem.team -> i32
    }
    return
  }

  // Test team split operations
  func.func @test_team_splits() {
    openshmem.region {
    %world_team = openshmem.team_world -> !openshmem.team
    
    // Test strided split
    %start = arith.constant 0 : i32
    %stride = arith.constant 1 : i32
    %size = arith.constant 2 : i32
    %strided_team, %ret1 = openshmem.team_split_strided(%world_team, %start, %stride, %size) : 
      !openshmem.team, i32, i32, i32 -> !openshmem.team, i32
    
    // Test 2D split
    %xrange = arith.constant 2 : i32
    %xaxis_team, %yaxis_team, %ret2 = openshmem.team_split_2d(%world_team, %xrange) : 
      !openshmem.team, i32 -> !openshmem.team, !openshmem.team, i32
    
    openshmem.team_destroy(%strided_team) : !openshmem.team
    openshmem.team_destroy(%xaxis_team) : !openshmem.team
    openshmem.team_destroy(%yaxis_team) : !openshmem.team
    }
    return
  }

  // Test team query operations
  func.func @test_team_queries() {
    openshmem.region {
    %world_team = openshmem.team_world -> !openshmem.team
    
    %team_pe = openshmem.team_my_pe(%world_team) : !openshmem.team -> i32
    %team_npes = openshmem.team_n_pes(%world_team) : !openshmem.team -> i32
    
    }
    return
  }

  // Test team synchronization
  func.func @test_team_sync() {
    openshmem.region {
    %world_team = openshmem.team_world -> !openshmem.team
    openshmem.team_sync(%world_team) : !openshmem.team
    }
    return
  }

  // Test team communication with proper PE translation
  func.func @test_team_communication() {
    openshmem.region {
    
    %world_team = openshmem.team_world -> !openshmem.team
    
    // Split into pairs
    %start = arith.constant 0 : i32
    %stride = arith.constant 1 : i32
    %size = arith.constant 2 : i32
    %pair_team, %ret = openshmem.team_split_strided(%world_team, %start, %stride, %size) : 
      !openshmem.team, i32, i32, i32 -> !openshmem.team, i32

    // Allocate symmetric memory
    %mem_size = arith.constant 40 : index
    %sym_mem = openshmem.malloc(%mem_size) : index -> memref<i32, #openshmem.symmetric_memory>
    
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
      memref<i32, #openshmem.symmetric_memory>, memref<10xi32>, index, i32

    // Synchronize within team after communication
    openshmem.team_sync(%pair_team) : !openshmem.team
    
    // Clean up
    memref.dealloc %local_data : memref<10xi32>
    openshmem.free(%sym_mem) : memref<i32, #openshmem.symmetric_memory>
    openshmem.team_destroy(%pair_team) : !openshmem.team
    
    }
    return
  }

  // Test team with RMA operations
  func.func @test_team_with_typed_rma() {
    openshmem.region {
    %world_team = openshmem.team_world -> !openshmem.team
    
    // Create a strided team
    %start = arith.constant 0 : i32
    %stride = arith.constant 2 : i32
    %team_size = arith.constant 2 : i32
    %strided_team, %ret = openshmem.team_split_strided(%world_team, %start, %stride, %team_size) : 
      !openshmem.team, i32, i32, i32 -> !openshmem.team, i32
    
    // Allocate memory
    %mem_size = arith.constant 40 : index
    %sym_mem = openshmem.malloc(%mem_size) : index -> memref<i32, #openshmem.symmetric_memory>
    %local_mem = memref.alloc() : memref<10xi32>
    
    // Team sync before RMA
    openshmem.team_sync(%strided_team) : !openshmem.team
    
    // Perform typed RMA operation
    %nelems = arith.constant 10 : index
    %pe = arith.constant 1 : i32
    openshmem.put(%sym_mem, %local_mem, %nelems, %pe) : memref<i32, #openshmem.symmetric_memory>, memref<10xi32>, index, i32
    
    // Team sync after RMA
    openshmem.team_sync(%strided_team) : !openshmem.team
    
    // Cleanup
    memref.dealloc %local_mem : memref<10xi32>
    openshmem.free(%sym_mem) : memref<i32, #openshmem.symmetric_memory>
    openshmem.team_destroy(%strided_team) : !openshmem.team
    }
    return
  }

  // Test multiple team splits
  func.func @test_multiple_team_splits() {
    openshmem.region {
    %world_team = openshmem.team_world -> !openshmem.team
    
    // First split: divide into groups of 4
    %start1 = arith.constant 0 : i32
    %stride1 = arith.constant 1 : i32
    %size1 = arith.constant 4 : i32
    %group4_team, %ret1 = openshmem.team_split_strided(%world_team, %start1, %stride1, %size1) : 
      !openshmem.team, i32, i32, i32 -> !openshmem.team, i32
    
    // Second split: divide group4 into pairs
    %start2 = arith.constant 0 : i32
    %stride2 = arith.constant 1 : i32
    %size2 = arith.constant 2 : i32
    %pair_team, %ret2 = openshmem.team_split_strided(%group4_team, %start2, %stride2, %size2) : 
      !openshmem.team, i32, i32, i32 -> !openshmem.team, i32
    
    // 2D split on the world team
    %xrange = arith.constant 4 : i32
    %xaxis_team, %yaxis_team, %ret3 = openshmem.team_split_2d(%world_team, %xrange) : 
      !openshmem.team, i32 -> !openshmem.team, !openshmem.team, i32
    
    // Sync all teams
    openshmem.team_sync(%pair_team) : !openshmem.team
    openshmem.team_sync(%xaxis_team) : !openshmem.team
    openshmem.team_sync(%yaxis_team) : !openshmem.team
    
    // Query information from different teams
    %pair_pe = openshmem.team_my_pe(%pair_team) : !openshmem.team -> i32
    %xaxis_pe = openshmem.team_my_pe(%xaxis_team) : !openshmem.team -> i32
    %yaxis_npes = openshmem.team_n_pes(%yaxis_team) : !openshmem.team -> i32
    
    // Cleanup
    openshmem.team_destroy(%pair_team) : !openshmem.team
    openshmem.team_destroy(%group4_team) : !openshmem.team
    openshmem.team_destroy(%xaxis_team) : !openshmem.team
    openshmem.team_destroy(%yaxis_team) : !openshmem.team
    }
    return
  }

  // Test teams with point-to-point operations
  func.func @test_teams_with_p2p() {
    openshmem.region {
    %world_team = openshmem.team_world -> !openshmem.team
    
    // Allocate symmetric memory
    %mem_size = arith.constant 4 : index
    %sym_mem = openshmem.malloc(%mem_size) : index -> memref<i32, #openshmem.symmetric_memory>
    
    // Team sync before P2P
    openshmem.team_sync(%world_team) : !openshmem.team
    
    // Point-to-point put
    %value = arith.constant 42 : i32
    %pe = arith.constant 1 : i32
    openshmem.p(%sym_mem, %value, %pe) : memref<i32, #openshmem.symmetric_memory>, i32, i32
    
    // Point-to-point get
    %result = openshmem.g(%sym_mem, %pe) : memref<i32, #openshmem.symmetric_memory>, i32 -> i32
    
    // Team sync after P2P
    openshmem.team_sync(%world_team) : !openshmem.team
    
    openshmem.free(%sym_mem) : memref<i32, #openshmem.symmetric_memory>
    }
    return
  }
}

// Check for predefined team constants
// CHECK: @SHMEM_TEAM_SHARED = external constant ptr
// CHECK: @SHMEM_TEAM_WORLD = external constant ptr

// Check for team function declarations (in the order they appear in LLVM IR)
// CHECK: declare void @shmem_team_destroy(ptr)
// CHECK: declare void @shmem_team_sync(ptr)
// CHECK: declare i32 @shmem_team_split_2d(ptr, i32, ptr, i64, ptr, ptr, i64, ptr)
// CHECK: declare i32 @shmem_team_split_strided(ptr, i32, i32, i32, ptr, i64, ptr)
// CHECK: declare i32 @shmem_team_n_pes(ptr)
// CHECK: declare i32 @shmem_team_my_pe(ptr)

// Check basic team function
// CHECK-LABEL: define void @test_teams()
// CHECK: call void @shmem_init()
// CHECK: call i32 @shmem_my_pe()
// CHECK: call i32 @shmem_n_pes()
// CHECK: call i32 @shmem_team_my_pe(ptr @SHMEM_TEAM_WORLD)
// CHECK: call i32 @shmem_team_n_pes(ptr @SHMEM_TEAM_WORLD)
// CHECK: call i32 @shmem_team_my_pe(ptr @SHMEM_TEAM_SHARED)
// CHECK: call i32 @shmem_team_split_strided(ptr @SHMEM_TEAM_WORLD, i32 0, i32 1, i32 2, ptr null, i64 0, ptr
// CHECK: call i32 @shmem_team_split_2d(ptr @SHMEM_TEAM_WORLD, i32 2, ptr null, i64 0, ptr {{.*}}, ptr null, i64 0, ptr
// CHECK: call void @shmem_team_sync(ptr
// CHECK: call void @shmem_team_destroy(ptr
// CHECK: call void @shmem_barrier_all()
// CHECK: call void @shmem_finalize()

// Check predefined teams function  
// CHECK-LABEL: define void @test_predefined_teams()
// CHECK: call i32 @shmem_team_my_pe(ptr @SHMEM_TEAM_WORLD)
// CHECK: call i32 @shmem_team_my_pe(ptr @SHMEM_TEAM_SHARED)

// Check team splits function
// CHECK-LABEL: define void @test_team_splits()
// CHECK: call void @shmem_init()
// CHECK: call i32 @shmem_team_split_strided(ptr @SHMEM_TEAM_WORLD
// CHECK: call i32 @shmem_team_split_2d(ptr @SHMEM_TEAM_WORLD
// CHECK: call void @shmem_team_destroy(ptr
// CHECK: call void @shmem_finalize()

// Check team queries function
// CHECK-LABEL: define void @test_team_queries()
// CHECK: call i32 @shmem_team_my_pe(ptr @SHMEM_TEAM_WORLD)
// CHECK: call i32 @shmem_team_n_pes(ptr @SHMEM_TEAM_WORLD)

// Check team sync function  
// CHECK-LABEL: define void @test_team_sync()
// CHECK: call void @shmem_team_sync(ptr @SHMEM_TEAM_WORLD)

// Check team communication function
// CHECK-LABEL: define void @test_team_communication()
// CHECK: call i32 @shmem_team_split_strided(ptr @SHMEM_TEAM_WORLD
// CHECK: call ptr @shmem_malloc(i64
// CHECK: call void @shmem_team_sync(ptr
// CHECK: call i32 @shmem_team_my_pe(ptr
// CHECK: call i32 @shmem_team_n_pes(ptr
// CHECK: call void @shmem_putmem(ptr
// CHECK: call void @shmem_team_sync(ptr
// CHECK: call void @shmem_free(ptr
// CHECK: call void @shmem_team_destroy(ptr

// Check RMA with teams function
// CHECK-LABEL: define void @test_team_with_typed_rma()
// CHECK: call i32 @shmem_team_split_strided(ptr @SHMEM_TEAM_WORLD
// CHECK: call ptr @shmem_malloc(i64
// CHECK: call void @shmem_team_sync(ptr
// CHECK: call void @shmem_put32(ptr
// CHECK: call void @shmem_team_sync(ptr

// Check multiple splits function
// CHECK-LABEL: define void @test_multiple_team_splits()
// CHECK: call i32 @shmem_team_split_strided(ptr @SHMEM_TEAM_WORLD
// CHECK: call i32 @shmem_team_split_strided(ptr {{.*}}, i32 0, i32 1, i32 2
// CHECK: call i32 @shmem_team_split_2d(ptr @SHMEM_TEAM_WORLD
// CHECK: call void @shmem_team_sync(ptr
// CHECK: call i32 @shmem_team_my_pe(ptr
// CHECK: call i32 @shmem_team_n_pes(ptr
// CHECK: call void @shmem_team_destroy(ptr

// Check P2P with teams function
// CHECK-LABEL: define void @test_teams_with_p2p()
// CHECK: call void @shmem_team_sync(ptr @SHMEM_TEAM_WORLD)
// CHECK: call void @shmem_p(ptr
// CHECK: call i32 @shmem_g(ptr
// CHECK: call void @shmem_team_sync(ptr @SHMEM_TEAM_WORLD) 