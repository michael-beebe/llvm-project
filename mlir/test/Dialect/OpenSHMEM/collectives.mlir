// RUN: mlir-opt %s --convert-openshmem-to-llvm --convert-func-to-llvm --reconcile-unrealized-casts | mlir-translate --mlir-to-llvmir | FileCheck %s

// Test OpenSHMEM collective operations

module {
  func.func @test_collectives() {
    // Initialize OpenSHMEM
    openshmem.init

    // Set SHMEM_TEAM_WORLD to a team handle
    %team = openshmem.team_world -> !openshmem.team
    
    // Number of elements to transfer
    %nelems = arith.constant 10 : index // 10 elements
    %size = arith.constant 40 : index // 10 elements * 4 bytes each = 40 bytes

    // Allocate symmetric memory for dest and source
    %dest = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i32>
    %source = openshmem.malloc(%size) : index -> !openshmem.symmetric_memref<i32>
    
    // Perform alltoallmem operations
    %retval = openshmem.alltoallmem(%team, %dest, %source, %nelems) : !openshmem.team, !openshmem.symmetric_memref<i32>, !openshmem.symmetric_memref<i32>, index -> i32

    // Free symmetric memory
    openshmem.free(%dest) : !openshmem.symmetric_memref<i32>
    openshmem.free(%source) : !openshmem.symmetric_memref<i32>

    // Finalize OpenSHMEM
    openshmem.finalize
    return
  }
}

// CHECK-LABEL: llvm.func @test_collectives()
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: %0 = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_alltoallmem(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i64) -> i32
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return