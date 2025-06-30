// RUN: mlir-opt %s --convert-openshmem-to-llvm --convert-func-to-llvm --reconcile-unrealized-casts | mlir-translate --mlir-to-llvmir | FileCheck %s

// Test the OpenSHMEM dialect with symmetric memory types and putmem/getmem operations

module {
  func.func @main() {
    // Initialize OpenSHMEM
    openshmem.init
    
    // Get PE information
    %pe = openshmem.my_pe : i32
    %npes = openshmem.n_pes : i32

    // Allocate symmetric memory for 10 integers (40 bytes)
    %size = arith.constant 40 : index
    %sym_mem = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i32>

    // Allocate local memory
    %local_data = memref.alloc() : memref<10xi32>
    %put_size = arith.constant 40 : index  // 10 elements * 4 bytes each = 40 bytes
    %target_pe = arith.constant 1 : i32

    // Barrier all PEs
    openshmem.barrier_all
    
    // Demonstrate team usage
    %world_team = openshmem.team_world -> !openshmem.team
    openshmem.team_sync(%world_team) : !openshmem.team

    // Put raw memory to PE 1 (no result)
    openshmem.putmem(%sym_mem, %local_data, %put_size, %target_pe) : 
      !openshmem.symmetric_memref<i32>, memref<10xi32>, index, i32

    // Get raw memory from PE 1 (no result)
    %get_size = arith.constant 40 : index  // 10 elements * 4 bytes each = 40 bytes
    openshmem.getmem(%local_data, %sym_mem, %get_size, %target_pe) : 
      memref<10xi32>, !openshmem.symmetric_memref<i32>, index, i32

    // Quiet all PEs
    openshmem.quiet

    // Free local memory
    memref.dealloc %local_data : memref<10xi32>
    
    // Free the symmetric memory
    openshmem.free(%sym_mem) : !openshmem.symmetric_memref<i32>

    // Finalize OpenSHMEM
    openshmem.finalize
    return
  }
}

// CHECK: define void @main()
// CHECK: call void @shmem_init()
// CHECK: call i32 @shmem_my_pe()
// CHECK: call i32 @shmem_n_pes()
// CHECK: call ptr @shmem_malloc(i{{32|64}} 40)
// CHECK: call void @shmem_barrier_all()
// CHECK: @SHMEM_TEAM_WORLD
// CHECK: call void @shmem_putmem(ptr %{{.*}}, ptr %{{.*}}, i{{32|64}} 40, i32 1)
// CHECK: call void @shmem_getmem(ptr %{{.*}}, ptr %{{.*}}, i{{32|64}} 40, i32 1)
// CHECK: call void @shmem_quiet()
// CHECK: call void @shmem_free(ptr %{{.*}})
// CHECK: call void @shmem_finalize()
// CHECK: ret void
