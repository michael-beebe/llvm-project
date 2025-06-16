// RUN: mlir-opt %s --convert-openshmem-to-llvm --convert-func-to-llvm --reconcile-unrealized-casts | mlir-translate --mlir-to-llvmir | FileCheck %s

// TODO: add more operations as we implement them

module {
  func.func @openshmem_program() {
    openshmem.init
    %pe = openshmem.my_pe : i32
    %npes = openshmem.n_pes : i32

    // Allocate symmetric memory for 10 integers (40 bytes)
    %size = arith.constant 40 : i64
    %sym_mem = openshmem.malloc(%size) : i64 -> !openshmem.symmetric_memref<i32>
    
    // Free the symmetric memory
    openshmem.free(%sym_mem) : !openshmem.symmetric_memref<i32>

    openshmem.finalize
    return
  }
}

// CHECK: define void @openshmem_program()
// CHECK: call i32 @shmem_init()
// CHECK: call i32 @shmem_my_pe()
// CHECK: call i32 @shmem_n_pes()
// CHECK: call i8* @shmem_malloc(i64 40)
// CHECK: call i32 @shmem_free(i8* %{{.*}})
// CHECK: call i32 @shmem_finalize()
// CHECK: ret void
