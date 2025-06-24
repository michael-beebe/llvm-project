// RUN: mlir-opt %s --convert-openshmem-to-llvm --convert-func-to-llvm --reconcile-unrealized-casts | mlir-translate --mlir-to-llvmir | FileCheck %s

// Test the OpenSHMEM dialect with symmetric memory types and put/get operations

module {
  func.func @main() {
    // Initialize OpenSHMEM
    openshmem.init
    
    // Get PE information
    %pe = openshmem.my_pe : i32
    %npes = openshmem.n_pes : i32

    // Allocate symmetric memory for 10 integers (40 bytes)
    %size = arith.constant 40 : i64
    %sym_mem = openshmem.malloc(%size) : i64 -> !openshmem.symmetric_memref<i32>

    // Allocate local memory
    %local_data = memref.alloc() : memref<10xi32>
    %put_size = arith.constant 10 : i64
    %target_pe = arith.constant 1 : i32

    // Put data to PE 1 (no result)
    openshmem.put(%sym_mem, %local_data, %put_size, %target_pe) : 
      !openshmem.symmetric_memref<i32>, memref<10xi32>, i64, i32

    // Get data from PE 1 (no result)
    %get_size = arith.constant 10 : i64
    openshmem.get(%local_data, %sym_mem, %get_size, %target_pe) : 
      memref<10xi32>, !openshmem.symmetric_memref<i32>, i64, i32

    // Barrier all PEs
    openshmem.barrier_all

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
// CHECK: call i32 @shmem_init()
// CHECK: call i32 @shmem_my_pe()
// CHECK: call i32 @shmem_n_pes()
// CHECK: call i8* @shmem_malloc(i64 40)
// CHECK: call void @shmem_put(i8* %{{.*}}, i8* %{{.*}}, i64 10, i32 1)
// CHECK: call void @shmem_get(i8* %{{.*}}, i8* %{{.*}}, i64 10, i32 1)
// CHECK: call i32 @shmem_free(i8* %{{.*}})
// CHECK: call i32 @shmem_finalize()
// CHECK: ret void
