module {
  llvm.func @shmem_ctx_atomic_fetch64(!llvm.ptr, !llvm.ptr, i32) -> i64
  llvm.func @shmem_ctx_destroy(!llvm.ptr)
  llvm.func @shmem_ctx_atomic_fetch32(!llvm.ptr, !llvm.ptr, i32) -> i32
  llvm.func @shmem_ctx_create(i64, !llvm.ptr) -> i32
  llvm.func @shmem_atomic_fetch64(!llvm.ptr, i32) -> i64
  llvm.func @shmem_finalize()
  llvm.func @shmem_free(!llvm.ptr)
  llvm.func @shmem_atomic_fetch32(!llvm.ptr, i32) -> i32
  llvm.func @shmem_malloc(i64) -> !llvm.ptr
  llvm.func @shmem_init()
  llvm.func @test_i32_atomic_fetch() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(4 : index) : i64
    %2 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %3 = llvm.call @shmem_atomic_fetch32(%2, %0) : (!llvm.ptr, i32) -> i32
    llvm.call @shmem_free(%2) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i64_atomic_fetch() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(8 : index) : i64
    %2 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %3 = llvm.call @shmem_atomic_fetch64(%2, %0) : (!llvm.ptr, i32) -> i64
    llvm.call @shmem_free(%2) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_f32_atomic_fetch() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(4 : index) : i64
    %2 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %3 = llvm.call @shmem_atomic_fetch32(%2, %0) : (!llvm.ptr, i32) -> i32
    llvm.call @shmem_free(%2) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_f64_atomic_fetch() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(8 : index) : i64
    %2 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %3 = llvm.call @shmem_atomic_fetch64(%2, %0) : (!llvm.ptr, i32) -> i64
    llvm.call @shmem_free(%2) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i32_atomic_fetch() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(4 : index) : i64
    %7 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %8 = llvm.call @shmem_ctx_atomic_fetch32(%4, %7, %5) : (!llvm.ptr, !llvm.ptr, i32) -> i32
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%7) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i64_atomic_fetch() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(8 : index) : i64
    %7 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %8 = llvm.call @shmem_ctx_atomic_fetch64(%4, %7, %5) : (!llvm.ptr, !llvm.ptr, i32) -> i64
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%7) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_f32_atomic_fetch() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(4 : index) : i64
    %7 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %8 = llvm.call @shmem_ctx_atomic_fetch32(%4, %7, %5) : (!llvm.ptr, !llvm.ptr, i32) -> i32
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%7) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_f64_atomic_fetch() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(8 : index) : i64
    %7 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %8 = llvm.call @shmem_ctx_atomic_fetch64(%4, %7, %5) : (!llvm.ptr, !llvm.ptr, i32) -> i64
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%7) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
}

