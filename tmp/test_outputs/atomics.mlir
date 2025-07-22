module {
  llvm.func @shmem_ctx_atomic_inc64(!llvm.ptr, !llvm.ptr, i32)
  llvm.func @shmem_ctx_atomic_inc32(!llvm.ptr, !llvm.ptr, i32)
  llvm.func @shmem_atomic_inc64(!llvm.ptr, i32)
  llvm.func @shmem_atomic_inc32(!llvm.ptr, i32)
  llvm.func @shmem_ctx_atomic_fetch_inc64(!llvm.ptr, !llvm.ptr, i32) -> i64
  llvm.func @shmem_ctx_atomic_fetch_inc32(!llvm.ptr, !llvm.ptr, i32) -> i32
  llvm.func @shmem_atomic_fetch_inc64(!llvm.ptr, i32) -> i64
  llvm.func @shmem_atomic_fetch_inc32(!llvm.ptr, i32) -> i32
  llvm.func @shmem_ctx_atomic_swap64(!llvm.ptr, !llvm.ptr, i64, i32) -> i64
  llvm.func @shmem_ctx_atomic_swap32(!llvm.ptr, !llvm.ptr, i32, i32) -> i32
  llvm.func @shmem_atomic_swap64(!llvm.ptr, i64, i32) -> i64
  llvm.func @shmem_atomic_swap32(!llvm.ptr, i32, i32) -> i32
  llvm.func @shmem_ctx_atomic_compare_swap64(!llvm.ptr, !llvm.ptr, i64, i64, i32) -> i64
  llvm.func @shmem_ctx_atomic_compare_swap32(!llvm.ptr, !llvm.ptr, i32, i32, i32) -> i32
  llvm.func @shmem_atomic_compare_swap64(!llvm.ptr, i64, i64, i32) -> i64
  llvm.func @shmem_atomic_compare_swap32(!llvm.ptr, i32, i32, i32) -> i32
  llvm.func @shmem_ctx_atomic_set64(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_ctx_atomic_set32(!llvm.ptr, !llvm.ptr, i32, i32)
  llvm.func @shmem_atomic_set64(!llvm.ptr, i64, i32)
  llvm.func @shmem_atomic_set32(!llvm.ptr, i32, i32)
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
    %4 = llvm.bitcast %3 : i32 to f32
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
    %4 = llvm.bitcast %3 : i64 to f64
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
    %9 = llvm.bitcast %8 : i32 to f32
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
    %9 = llvm.bitcast %8 : i64 to f64
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%7) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i32_atomic_set() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(4 : index) : i64
    %2 = llvm.mlir.constant(42 : i32) : i32
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    llvm.call @shmem_atomic_set32(%3, %2, %0) : (!llvm.ptr, i32, i32) -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i64_atomic_set() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(8 : index) : i64
    %2 = llvm.mlir.constant(42 : i64) : i64
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    llvm.call @shmem_atomic_set64(%3, %2, %0) : (!llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_f32_atomic_set() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(4 : index) : i64
    %2 = llvm.mlir.constant(4.200000e+01 : f32) : f32
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %4 = llvm.bitcast %2 : f32 to i32
    llvm.call @shmem_atomic_set32(%3, %4, %0) : (!llvm.ptr, i32, i32) -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_f64_atomic_set() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(8 : index) : i64
    %2 = llvm.mlir.constant(4.200000e+01 : f64) : f64
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %4 = llvm.bitcast %2 : f64 to i64
    llvm.call @shmem_atomic_set64(%3, %4, %0) : (!llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i32_atomic_set() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(4 : index) : i64
    %7 = llvm.mlir.constant(42 : i32) : i32
    %8 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    llvm.call @shmem_ctx_atomic_set32(%4, %8, %7, %5) : (!llvm.ptr, !llvm.ptr, i32, i32) -> ()
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%8) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i64_atomic_set() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(8 : index) : i64
    %7 = llvm.mlir.constant(42 : i64) : i64
    %8 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    llvm.call @shmem_ctx_atomic_set64(%4, %8, %7, %5) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%8) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_f32_atomic_set() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(4 : index) : i64
    %7 = llvm.mlir.constant(4.200000e+01 : f32) : f32
    %8 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %9 = llvm.bitcast %7 : f32 to i32
    llvm.call @shmem_ctx_atomic_set32(%4, %8, %9, %5) : (!llvm.ptr, !llvm.ptr, i32, i32) -> ()
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%8) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_f64_atomic_set() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(8 : index) : i64
    %7 = llvm.mlir.constant(4.200000e+01 : f64) : f64
    %8 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %9 = llvm.bitcast %7 : f64 to i64
    llvm.call @shmem_ctx_atomic_set64(%4, %8, %9, %5) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%8) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i32_atomic_compare_swap() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(4 : index) : i64
    %2 = llvm.mlir.constant(42 : i32) : i32
    %3 = llvm.mlir.constant(43 : i32) : i32
    %4 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %5 = llvm.call @shmem_atomic_compare_swap32(%4, %2, %3, %0) : (!llvm.ptr, i32, i32, i32) -> i32
    llvm.call @shmem_free(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i64_atomic_compare_swap() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(8 : index) : i64
    %2 = llvm.mlir.constant(42 : i64) : i64
    %3 = llvm.mlir.constant(43 : i64) : i64
    %4 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %5 = llvm.call @shmem_atomic_compare_swap64(%4, %2, %3, %0) : (!llvm.ptr, i64, i64, i32) -> i64
    llvm.call @shmem_free(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_f32_atomic_compare_swap() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(4 : index) : i64
    %2 = llvm.mlir.constant(4.200000e+01 : f32) : f32
    %3 = llvm.mlir.constant(4.300000e+01 : f32) : f32
    %4 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %5 = llvm.bitcast %2 : f32 to i32
    %6 = llvm.bitcast %3 : f32 to i32
    %7 = llvm.call @shmem_atomic_compare_swap32(%4, %5, %6, %0) : (!llvm.ptr, i32, i32, i32) -> i32
    %8 = llvm.bitcast %7 : i32 to f32
    llvm.call @shmem_free(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_f64_atomic_compare_swap() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(8 : index) : i64
    %2 = llvm.mlir.constant(4.200000e+01 : f64) : f64
    %3 = llvm.mlir.constant(4.300000e+01 : f64) : f64
    %4 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %5 = llvm.bitcast %2 : f64 to i64
    %6 = llvm.bitcast %3 : f64 to i64
    %7 = llvm.call @shmem_atomic_compare_swap64(%4, %5, %6, %0) : (!llvm.ptr, i64, i64, i32) -> i64
    %8 = llvm.bitcast %7 : i64 to f64
    llvm.call @shmem_free(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i32_atomic_compare_swap() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(4 : index) : i64
    %7 = llvm.mlir.constant(42 : i32) : i32
    %8 = llvm.mlir.constant(43 : i32) : i32
    %9 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %10 = llvm.call @shmem_ctx_atomic_compare_swap32(%4, %9, %7, %8, %5) : (!llvm.ptr, !llvm.ptr, i32, i32, i32) -> i32
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%9) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i64_atomic_compare_swap() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(8 : index) : i64
    %7 = llvm.mlir.constant(42 : i64) : i64
    %8 = llvm.mlir.constant(43 : i64) : i64
    %9 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %10 = llvm.call @shmem_ctx_atomic_compare_swap64(%4, %9, %7, %8, %5) : (!llvm.ptr, !llvm.ptr, i64, i64, i32) -> i64
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%9) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_f32_atomic_compare_swap() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(4 : index) : i64
    %7 = llvm.mlir.constant(4.200000e+01 : f32) : f32
    %8 = llvm.mlir.constant(4.300000e+01 : f32) : f32
    %9 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %10 = llvm.bitcast %7 : f32 to i32
    %11 = llvm.bitcast %8 : f32 to i32
    %12 = llvm.call @shmem_ctx_atomic_compare_swap32(%4, %9, %10, %11, %5) : (!llvm.ptr, !llvm.ptr, i32, i32, i32) -> i32
    %13 = llvm.bitcast %12 : i32 to f32
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%9) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_f64_atomic_compare_swap() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(8 : index) : i64
    %7 = llvm.mlir.constant(4.200000e+01 : f64) : f64
    %8 = llvm.mlir.constant(4.300000e+01 : f64) : f64
    %9 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %10 = llvm.bitcast %7 : f64 to i64
    %11 = llvm.bitcast %8 : f64 to i64
    %12 = llvm.call @shmem_ctx_atomic_compare_swap64(%4, %9, %10, %11, %5) : (!llvm.ptr, !llvm.ptr, i64, i64, i32) -> i64
    %13 = llvm.bitcast %12 : i64 to f64
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%9) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i32_atomic_swap() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(4 : index) : i64
    %2 = llvm.mlir.constant(42 : i32) : i32
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %4 = llvm.call @shmem_atomic_swap32(%3, %2, %0) : (!llvm.ptr, i32, i32) -> i32
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i64_atomic_swap() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(8 : index) : i64
    %2 = llvm.mlir.constant(42 : i64) : i64
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %4 = llvm.call @shmem_atomic_swap64(%3, %2, %0) : (!llvm.ptr, i64, i32) -> i64
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i32_atomic_swap() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(4 : index) : i64
    %7 = llvm.mlir.constant(42 : i32) : i32
    %8 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %9 = llvm.call @shmem_ctx_atomic_swap32(%4, %8, %7, %5) : (!llvm.ptr, !llvm.ptr, i32, i32) -> i32
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%8) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i64_atomic_swap() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(8 : index) : i64
    %7 = llvm.mlir.constant(42 : i64) : i64
    %8 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %9 = llvm.call @shmem_ctx_atomic_swap64(%4, %8, %7, %5) : (!llvm.ptr, !llvm.ptr, i64, i32) -> i64
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%8) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_f32_atomic_swap() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(4 : index) : i64
    %2 = llvm.mlir.constant(4.200000e+01 : f32) : f32
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %4 = llvm.bitcast %2 : f32 to i32
    %5 = llvm.call @shmem_atomic_swap32(%3, %4, %0) : (!llvm.ptr, i32, i32) -> i32
    %6 = llvm.bitcast %5 : i32 to f32
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_f64_atomic_swap() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(8 : index) : i64
    %2 = llvm.mlir.constant(4.200000e+01 : f64) : f64
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %4 = llvm.bitcast %2 : f64 to i64
    %5 = llvm.call @shmem_atomic_swap64(%3, %4, %0) : (!llvm.ptr, i64, i32) -> i64
    %6 = llvm.bitcast %5 : i64 to f64
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_f32_atomic_swap() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(4 : index) : i64
    %7 = llvm.mlir.constant(4.200000e+01 : f32) : f32
    %8 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %9 = llvm.bitcast %7 : f32 to i32
    %10 = llvm.call @shmem_ctx_atomic_swap32(%4, %8, %9, %5) : (!llvm.ptr, !llvm.ptr, i32, i32) -> i32
    %11 = llvm.bitcast %10 : i32 to f32
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%8) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_f64_atomic_swap() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(8 : index) : i64
    %7 = llvm.mlir.constant(4.200000e+01 : f64) : f64
    %8 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %9 = llvm.bitcast %7 : f64 to i64
    %10 = llvm.call @shmem_ctx_atomic_swap64(%4, %8, %9, %5) : (!llvm.ptr, !llvm.ptr, i64, i32) -> i64
    %11 = llvm.bitcast %10 : i64 to f64
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%8) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i32_atomic_fetch_inc() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(4 : index) : i64
    %2 = llvm.mlir.constant(42 : i32) : i32
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %4 = llvm.call @shmem_atomic_fetch_inc32(%3, %0) : (!llvm.ptr, i32) -> i32
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i64_atomic_fetch_inc() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(8 : index) : i64
    %2 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %3 = llvm.call @shmem_atomic_fetch_inc64(%2, %0) : (!llvm.ptr, i32) -> i64
    llvm.call @shmem_free(%2) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i32_atomic_fetch_inc() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(4 : index) : i64
    %7 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %8 = llvm.call @shmem_ctx_atomic_fetch_inc32(%4, %7, %5) : (!llvm.ptr, !llvm.ptr, i32) -> i32
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%7) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i64_atomic_fetch_inc() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(8 : index) : i64
    %7 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %8 = llvm.call @shmem_ctx_atomic_fetch_inc64(%4, %7, %5) : (!llvm.ptr, !llvm.ptr, i32) -> i64
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%7) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i32_atomic_inc() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(4 : index) : i64
    %2 = llvm.mlir.constant(42 : i32) : i32
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    llvm.call @shmem_atomic_inc32(%3, %0) : (!llvm.ptr, i32) -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i64_atomic_inc() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(8 : index) : i64
    %2 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    llvm.call @shmem_atomic_inc64(%2, %0) : (!llvm.ptr, i32) -> ()
    llvm.call @shmem_free(%2) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i32_atomic_inc() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(4 : index) : i64
    %7 = llvm.mlir.constant(42 : i32) : i32
    %8 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    llvm.call @shmem_ctx_atomic_inc32(%4, %8, %5) : (!llvm.ptr, !llvm.ptr, i32) -> ()
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%8) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i64_atomic_inc() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(8 : index) : i64
    %7 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    llvm.call @shmem_ctx_atomic_inc64(%4, %7, %5) : (!llvm.ptr, !llvm.ptr, i32) -> ()
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%7) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
}

