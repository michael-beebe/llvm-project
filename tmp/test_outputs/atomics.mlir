module {
  llvm.func @free(!llvm.ptr)
  llvm.func @malloc(i64) -> !llvm.ptr
  llvm.func @shmem_long_ctx_atomic_fetch_xor_nbi(!llvm.ptr, !llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_int_ctx_atomic_fetch_xor_nbi(!llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32)
  llvm.func @shmem_long_atomic_fetch_xor_nbi(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_int_atomic_fetch_xor_nbi(!llvm.ptr, !llvm.ptr, i32, i32)
  llvm.func @shmem_long_ctx_atomic_fetch_or_nbi(!llvm.ptr, !llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_int_ctx_atomic_fetch_or_nbi(!llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32)
  llvm.func @shmem_long_atomic_fetch_or_nbi(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_int_atomic_fetch_or_nbi(!llvm.ptr, !llvm.ptr, i32, i32)
  llvm.func @shmem_long_ctx_atomic_fetch_and_nbi(!llvm.ptr, !llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_int_ctx_atomic_fetch_and_nbi(!llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32)
  llvm.func @shmem_long_atomic_fetch_and_nbi(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_int_atomic_fetch_and_nbi(!llvm.ptr, !llvm.ptr, i32, i32)
  llvm.func @shmem_long_ctx_atomic_fetch_add_nbi(!llvm.ptr, !llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_int_ctx_atomic_fetch_add_nbi(!llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32)
  llvm.func @shmem_long_atomic_fetch_add_nbi(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_int_atomic_fetch_add_nbi(!llvm.ptr, !llvm.ptr, i32, i32)
  llvm.func @shmem_long_ctx_atomic_fetch_inc_nbi(!llvm.ptr, !llvm.ptr, !llvm.ptr, i32)
  llvm.func @shmem_int_ctx_atomic_fetch_inc_nbi(!llvm.ptr, !llvm.ptr, !llvm.ptr, i32)
  llvm.func @shmem_long_atomic_fetch_inc_nbi(!llvm.ptr, !llvm.ptr, i32)
  llvm.func @shmem_int_atomic_fetch_inc_nbi(!llvm.ptr, !llvm.ptr, i32)
  llvm.func @shmem_long_ctx_atomic_swap_nbi(!llvm.ptr, !llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_int_ctx_atomic_swap_nbi(!llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32)
  llvm.func @shmem_long_atomic_swap_nbi(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_int_atomic_swap_nbi(!llvm.ptr, !llvm.ptr, i32, i32)
  llvm.func @shmem_long_ctx_atomic_compare_swap_nbi(!llvm.ptr, !llvm.ptr, !llvm.ptr, i64, i64, i32)
  llvm.func @shmem_int_ctx_atomic_compare_swap_nbi(!llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32)
  llvm.func @shmem_long_atomic_compare_swap_nbi(!llvm.ptr, !llvm.ptr, i64, i64, i32)
  llvm.func @shmem_int_atomic_compare_swap_nbi(!llvm.ptr, !llvm.ptr, i32, i32, i32)
  llvm.func @shmem_long_ctx_atomic_fetch_nbi(!llvm.ptr, !llvm.ptr, !llvm.ptr, i32)
  llvm.func @shmem_int_ctx_atomic_fetch_nbi(!llvm.ptr, !llvm.ptr, !llvm.ptr, i32)
  llvm.func @shmem_long_atomic_fetch_nbi(!llvm.ptr, !llvm.ptr, i32)
  llvm.func @shmem_int_atomic_fetch_nbi(!llvm.ptr, !llvm.ptr, i32)
  llvm.func @shmem_long_ctx_atomic_xor(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_int_ctx_atomic_xor(!llvm.ptr, !llvm.ptr, i32, i32)
  llvm.func @shmem_long_atomic_xor(!llvm.ptr, i64, i32)
  llvm.func @shmem_int_atomic_xor(!llvm.ptr, i32, i32)
  llvm.func @shmem_long_ctx_atomic_fetch_xor(!llvm.ptr, !llvm.ptr, i64, i32) -> i64
  llvm.func @shmem_int_ctx_atomic_fetch_xor(!llvm.ptr, !llvm.ptr, i32, i32) -> i32
  llvm.func @shmem_long_atomic_fetch_xor(!llvm.ptr, i64, i32) -> i64
  llvm.func @shmem_int_atomic_fetch_xor(!llvm.ptr, i32, i32) -> i32
  llvm.func @shmem_long_ctx_atomic_or(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_int_ctx_atomic_or(!llvm.ptr, !llvm.ptr, i32, i32)
  llvm.func @shmem_long_atomic_or(!llvm.ptr, i64, i32)
  llvm.func @shmem_int_atomic_or(!llvm.ptr, i32, i32)
  llvm.func @shmem_long_ctx_atomic_fetch_or(!llvm.ptr, !llvm.ptr, i64, i32) -> i64
  llvm.func @shmem_int_ctx_atomic_fetch_or(!llvm.ptr, !llvm.ptr, i32, i32) -> i32
  llvm.func @shmem_long_atomic_fetch_or(!llvm.ptr, i64, i32) -> i64
  llvm.func @shmem_int_atomic_fetch_or(!llvm.ptr, i32, i32) -> i32
  llvm.func @shmem_long_ctx_atomic_fetch_and(!llvm.ptr, !llvm.ptr, i64, i32) -> i64
  llvm.func @shmem_int_ctx_atomic_fetch_and(!llvm.ptr, !llvm.ptr, i32, i32) -> i32
  llvm.func @shmem_long_atomic_fetch_and(!llvm.ptr, i64, i32) -> i64
  llvm.func @shmem_int_atomic_fetch_and(!llvm.ptr, i32, i32) -> i32
  llvm.func @shmem_long_ctx_atomic_add(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_int_ctx_atomic_add(!llvm.ptr, !llvm.ptr, i32, i32)
  llvm.func @shmem_long_atomic_add(!llvm.ptr, i64, i32)
  llvm.func @shmem_int_atomic_add(!llvm.ptr, i32, i32)
  llvm.func @shmem_long_ctx_atomic_fetch_add(!llvm.ptr, !llvm.ptr, i64, i32) -> i64
  llvm.func @shmem_int_ctx_atomic_fetch_add(!llvm.ptr, !llvm.ptr, i32, i32) -> i32
  llvm.func @shmem_double_atomic_fetch_add(!llvm.ptr, i64, i32) -> i64
  llvm.func @shmem_float_atomic_fetch_add(!llvm.ptr, i32, i32) -> i32
  llvm.func @shmem_long_atomic_fetch_add(!llvm.ptr, i64, i32) -> i64
  llvm.func @shmem_int_atomic_fetch_add(!llvm.ptr, i32, i32) -> i32
  llvm.func @shmem_long_ctx_atomic_inc(!llvm.ptr, !llvm.ptr, i32)
  llvm.func @shmem_int_ctx_atomic_inc(!llvm.ptr, !llvm.ptr, i32)
  llvm.func @shmem_long_atomic_inc(!llvm.ptr, i32)
  llvm.func @shmem_int_atomic_inc(!llvm.ptr, i32)
  llvm.func @shmem_long_ctx_atomic_fetch_inc(!llvm.ptr, !llvm.ptr, i32) -> i64
  llvm.func @shmem_int_ctx_atomic_fetch_inc(!llvm.ptr, !llvm.ptr, i32) -> i32
  llvm.func @shmem_long_atomic_fetch_inc(!llvm.ptr, i32) -> i64
  llvm.func @shmem_int_atomic_fetch_inc(!llvm.ptr, i32) -> i32
  llvm.func @shmem_double_ctx_atomic_swap(!llvm.ptr, !llvm.ptr, i64, i32) -> i64
  llvm.func @shmem_float_ctx_atomic_swap(!llvm.ptr, !llvm.ptr, i32, i32) -> i32
  llvm.func @shmem_double_atomic_swap(!llvm.ptr, i64, i32) -> i64
  llvm.func @shmem_float_atomic_swap(!llvm.ptr, i32, i32) -> i32
  llvm.func @shmem_long_ctx_atomic_swap(!llvm.ptr, !llvm.ptr, i64, i32) -> i64
  llvm.func @shmem_int_ctx_atomic_swap(!llvm.ptr, !llvm.ptr, i32, i32) -> i32
  llvm.func @shmem_long_atomic_swap(!llvm.ptr, i64, i32) -> i64
  llvm.func @shmem_int_atomic_swap(!llvm.ptr, i32, i32) -> i32
  llvm.func @shmem_double_ctx_atomic_compare_swap(!llvm.ptr, !llvm.ptr, i64, i64, i32) -> i64
  llvm.func @shmem_float_ctx_atomic_compare_swap(!llvm.ptr, !llvm.ptr, i32, i32, i32) -> i32
  llvm.func @shmem_long_ctx_atomic_compare_swap(!llvm.ptr, !llvm.ptr, i64, i64, i32) -> i64
  llvm.func @shmem_int_ctx_atomic_compare_swap(!llvm.ptr, !llvm.ptr, i32, i32, i32) -> i32
  llvm.func @shmem_double_atomic_compare_swap(!llvm.ptr, i64, i64, i32) -> i64
  llvm.func @shmem_float_atomic_compare_swap(!llvm.ptr, i32, i32, i32) -> i32
  llvm.func @shmem_long_atomic_compare_swap(!llvm.ptr, i64, i64, i32) -> i64
  llvm.func @shmem_int_atomic_compare_swap(!llvm.ptr, i32, i32, i32) -> i32
  llvm.func @shmem_double_ctx_atomic_set(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_float_ctx_atomic_set(!llvm.ptr, !llvm.ptr, i32, i32)
  llvm.func @shmem_long_ctx_atomic_set(!llvm.ptr, !llvm.ptr, i64, i32)
  llvm.func @shmem_int_ctx_atomic_set(!llvm.ptr, !llvm.ptr, i32, i32)
  llvm.func @shmem_double_atomic_set(!llvm.ptr, i64, i32)
  llvm.func @shmem_float_atomic_set(!llvm.ptr, i32, i32)
  llvm.func @shmem_long_atomic_set(!llvm.ptr, i64, i32)
  llvm.func @shmem_int_atomic_set(!llvm.ptr, i32, i32)
  llvm.func @shmem_double_ctx_atomic_fetch(!llvm.ptr, !llvm.ptr, i32) -> i64
  llvm.func @shmem_float_ctx_atomic_fetch(!llvm.ptr, !llvm.ptr, i32) -> i32
  llvm.func @shmem_long_ctx_atomic_fetch(!llvm.ptr, !llvm.ptr, i32) -> i64
  llvm.func @shmem_ctx_destroy(!llvm.ptr)
  llvm.func @shmem_int_ctx_atomic_fetch(!llvm.ptr, !llvm.ptr, i32) -> i32
  llvm.func @shmem_ctx_create(i64, !llvm.ptr) -> i32
  llvm.func @shmem_double_atomic_fetch(!llvm.ptr, i32) -> i64
  llvm.func @shmem_float_atomic_fetch(!llvm.ptr, i32) -> i32
  llvm.func @shmem_long_atomic_fetch(!llvm.ptr, i32) -> i64
  llvm.func @shmem_finalize()
  llvm.func @shmem_free(!llvm.ptr)
  llvm.func @shmem_int_atomic_fetch(!llvm.ptr, i32) -> i32
  llvm.func @shmem_malloc(i64) -> !llvm.ptr
  llvm.func @shmem_init()
  llvm.func @test_i32_atomic_fetch() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(4 : index) : i64
    %2 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %3 = llvm.call @shmem_int_atomic_fetch(%2, %0) : (!llvm.ptr, i32) -> i32
    llvm.call @shmem_free(%2) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i64_atomic_fetch() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(8 : index) : i64
    %2 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %3 = llvm.call @shmem_long_atomic_fetch(%2, %0) : (!llvm.ptr, i32) -> i64
    llvm.call @shmem_free(%2) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_f32_atomic_fetch() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(4 : index) : i64
    %2 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %3 = llvm.call @shmem_float_atomic_fetch(%2, %0) : (!llvm.ptr, i32) -> i32
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
    %3 = llvm.call @shmem_double_atomic_fetch(%2, %0) : (!llvm.ptr, i32) -> i64
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
    %8 = llvm.call @shmem_int_ctx_atomic_fetch(%4, %7, %5) : (!llvm.ptr, !llvm.ptr, i32) -> i32
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
    %8 = llvm.call @shmem_long_ctx_atomic_fetch(%4, %7, %5) : (!llvm.ptr, !llvm.ptr, i32) -> i64
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
    %8 = llvm.call @shmem_float_ctx_atomic_fetch(%4, %7, %5) : (!llvm.ptr, !llvm.ptr, i32) -> i32
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
    %8 = llvm.call @shmem_double_ctx_atomic_fetch(%4, %7, %5) : (!llvm.ptr, !llvm.ptr, i32) -> i64
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
    llvm.call @shmem_int_atomic_set(%3, %2, %0) : (!llvm.ptr, i32, i32) -> ()
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
    llvm.call @shmem_long_atomic_set(%3, %2, %0) : (!llvm.ptr, i64, i32) -> ()
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
    llvm.call @shmem_float_atomic_set(%3, %4, %0) : (!llvm.ptr, i32, i32) -> ()
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
    llvm.call @shmem_double_atomic_set(%3, %4, %0) : (!llvm.ptr, i64, i32) -> ()
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
    llvm.call @shmem_int_ctx_atomic_set(%4, %8, %7, %5) : (!llvm.ptr, !llvm.ptr, i32, i32) -> ()
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
    llvm.call @shmem_long_ctx_atomic_set(%4, %8, %7, %5) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
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
    llvm.call @shmem_float_ctx_atomic_set(%4, %8, %9, %5) : (!llvm.ptr, !llvm.ptr, i32, i32) -> ()
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
    llvm.call @shmem_double_ctx_atomic_set(%4, %8, %9, %5) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
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
    %5 = llvm.call @shmem_int_atomic_compare_swap(%4, %2, %3, %0) : (!llvm.ptr, i32, i32, i32) -> i32
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
    %5 = llvm.call @shmem_long_atomic_compare_swap(%4, %2, %3, %0) : (!llvm.ptr, i64, i64, i32) -> i64
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
    %7 = llvm.call @shmem_float_atomic_compare_swap(%4, %5, %6, %0) : (!llvm.ptr, i32, i32, i32) -> i32
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
    %7 = llvm.call @shmem_double_atomic_compare_swap(%4, %5, %6, %0) : (!llvm.ptr, i64, i64, i32) -> i64
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
    %10 = llvm.call @shmem_int_ctx_atomic_compare_swap(%4, %9, %7, %8, %5) : (!llvm.ptr, !llvm.ptr, i32, i32, i32) -> i32
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
    %10 = llvm.call @shmem_long_ctx_atomic_compare_swap(%4, %9, %7, %8, %5) : (!llvm.ptr, !llvm.ptr, i64, i64, i32) -> i64
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
    %12 = llvm.call @shmem_float_ctx_atomic_compare_swap(%4, %9, %10, %11, %5) : (!llvm.ptr, !llvm.ptr, i32, i32, i32) -> i32
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
    %12 = llvm.call @shmem_double_ctx_atomic_compare_swap(%4, %9, %10, %11, %5) : (!llvm.ptr, !llvm.ptr, i64, i64, i32) -> i64
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
    %4 = llvm.call @shmem_int_atomic_swap(%3, %2, %0) : (!llvm.ptr, i32, i32) -> i32
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
    %4 = llvm.call @shmem_long_atomic_swap(%3, %2, %0) : (!llvm.ptr, i64, i32) -> i64
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
    %9 = llvm.call @shmem_int_ctx_atomic_swap(%4, %8, %7, %5) : (!llvm.ptr, !llvm.ptr, i32, i32) -> i32
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
    %9 = llvm.call @shmem_long_ctx_atomic_swap(%4, %8, %7, %5) : (!llvm.ptr, !llvm.ptr, i64, i32) -> i64
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
    %5 = llvm.call @shmem_float_atomic_swap(%3, %4, %0) : (!llvm.ptr, i32, i32) -> i32
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
    %5 = llvm.call @shmem_double_atomic_swap(%3, %4, %0) : (!llvm.ptr, i64, i32) -> i64
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
    %10 = llvm.call @shmem_float_ctx_atomic_swap(%4, %8, %9, %5) : (!llvm.ptr, !llvm.ptr, i32, i32) -> i32
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
    %10 = llvm.call @shmem_double_ctx_atomic_swap(%4, %8, %9, %5) : (!llvm.ptr, !llvm.ptr, i64, i32) -> i64
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
    %4 = llvm.call @shmem_int_atomic_fetch_inc(%3, %0) : (!llvm.ptr, i32) -> i32
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i64_atomic_fetch_inc() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(8 : index) : i64
    %2 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %3 = llvm.call @shmem_long_atomic_fetch_inc(%2, %0) : (!llvm.ptr, i32) -> i64
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
    %8 = llvm.call @shmem_int_ctx_atomic_fetch_inc(%4, %7, %5) : (!llvm.ptr, !llvm.ptr, i32) -> i32
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
    %8 = llvm.call @shmem_long_ctx_atomic_fetch_inc(%4, %7, %5) : (!llvm.ptr, !llvm.ptr, i32) -> i64
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
    llvm.call @shmem_int_atomic_inc(%3, %0) : (!llvm.ptr, i32) -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i64_atomic_inc() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(8 : index) : i64
    %2 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    llvm.call @shmem_long_atomic_inc(%2, %0) : (!llvm.ptr, i32) -> ()
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
    llvm.call @shmem_int_ctx_atomic_inc(%4, %8, %5) : (!llvm.ptr, !llvm.ptr, i32) -> ()
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
    llvm.call @shmem_long_ctx_atomic_inc(%4, %7, %5) : (!llvm.ptr, !llvm.ptr, i32) -> ()
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%7) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i32_atomic_fetch_add() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(4 : index) : i64
    %2 = llvm.mlir.constant(5 : i32) : i32
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %4 = llvm.call @shmem_int_atomic_fetch_add(%3, %2, %0) : (!llvm.ptr, i32, i32) -> i32
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i64_atomic_fetch_add() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(8 : index) : i64
    %2 = llvm.mlir.constant(5 : i64) : i64
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %4 = llvm.call @shmem_long_atomic_fetch_add(%3, %2, %0) : (!llvm.ptr, i64, i32) -> i64
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_f32_atomic_fetch_add() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(4 : index) : i64
    %2 = llvm.mlir.constant(5.000000e+00 : f32) : f32
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %4 = llvm.bitcast %2 : f32 to i32
    %5 = llvm.call @shmem_float_atomic_fetch_add(%3, %4, %0) : (!llvm.ptr, i32, i32) -> i32
    %6 = llvm.bitcast %5 : i32 to f32
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_f64_atomic_fetch_add() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(8 : index) : i64
    %2 = llvm.mlir.constant(5.000000e+00 : f64) : f64
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %4 = llvm.bitcast %2 : f64 to i64
    %5 = llvm.call @shmem_double_atomic_fetch_add(%3, %4, %0) : (!llvm.ptr, i64, i32) -> i64
    %6 = llvm.bitcast %5 : i64 to f64
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i32_atomic_fetch_add() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(4 : index) : i64
    %7 = llvm.mlir.constant(5 : i32) : i32
    %8 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %9 = llvm.call @shmem_int_ctx_atomic_fetch_add(%4, %8, %7, %5) : (!llvm.ptr, !llvm.ptr, i32, i32) -> i32
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%8) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i64_atomic_fetch_add() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(8 : index) : i64
    %7 = llvm.mlir.constant(5 : i64) : i64
    %8 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %9 = llvm.call @shmem_long_ctx_atomic_fetch_add(%4, %8, %7, %5) : (!llvm.ptr, !llvm.ptr, i64, i32) -> i64
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%8) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i32_atomic_add() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(4 : index) : i64
    %2 = llvm.mlir.constant(5 : i32) : i32
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    llvm.call @shmem_int_atomic_add(%3, %2, %0) : (!llvm.ptr, i32, i32) -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i64_atomic_add() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(8 : index) : i64
    %2 = llvm.mlir.constant(5 : i64) : i64
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    llvm.call @shmem_long_atomic_add(%3, %2, %0) : (!llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i32_atomic_add() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(4 : index) : i64
    %7 = llvm.mlir.constant(5 : i32) : i32
    %8 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    llvm.call @shmem_int_ctx_atomic_add(%4, %8, %7, %5) : (!llvm.ptr, !llvm.ptr, i32, i32) -> ()
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%8) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i64_atomic_add() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(8 : index) : i64
    %7 = llvm.mlir.constant(5 : i64) : i64
    %8 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    llvm.call @shmem_long_ctx_atomic_add(%4, %8, %7, %5) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%8) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i32_atomic_fetch_and() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(4 : index) : i64
    %2 = llvm.mlir.constant(255 : i32) : i32
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %4 = llvm.call @shmem_int_atomic_fetch_and(%3, %2, %0) : (!llvm.ptr, i32, i32) -> i32
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i64_atomic_fetch_and() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(8 : index) : i64
    %2 = llvm.mlir.constant(255 : i64) : i64
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %4 = llvm.call @shmem_long_atomic_fetch_and(%3, %2, %0) : (!llvm.ptr, i64, i32) -> i64
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i32_atomic_fetch_and() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(4 : index) : i64
    %7 = llvm.mlir.constant(255 : i32) : i32
    %8 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %9 = llvm.call @shmem_int_ctx_atomic_fetch_and(%4, %8, %7, %5) : (!llvm.ptr, !llvm.ptr, i32, i32) -> i32
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%8) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i64_atomic_fetch_and() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(8 : index) : i64
    %7 = llvm.mlir.constant(255 : i64) : i64
    %8 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %9 = llvm.call @shmem_long_ctx_atomic_fetch_and(%4, %8, %7, %5) : (!llvm.ptr, !llvm.ptr, i64, i32) -> i64
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%8) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i32_atomic_fetch_or() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(4 : index) : i64
    %2 = llvm.mlir.constant(128 : i32) : i32
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %4 = llvm.call @shmem_int_atomic_fetch_or(%3, %2, %0) : (!llvm.ptr, i32, i32) -> i32
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i64_atomic_fetch_or() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(8 : index) : i64
    %2 = llvm.mlir.constant(128 : i64) : i64
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %4 = llvm.call @shmem_long_atomic_fetch_or(%3, %2, %0) : (!llvm.ptr, i64, i32) -> i64
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i32_atomic_fetch_or() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(4 : index) : i64
    %7 = llvm.mlir.constant(128 : i32) : i32
    %8 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %9 = llvm.call @shmem_int_ctx_atomic_fetch_or(%4, %8, %7, %5) : (!llvm.ptr, !llvm.ptr, i32, i32) -> i32
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%8) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i64_atomic_fetch_or() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(8 : index) : i64
    %7 = llvm.mlir.constant(128 : i64) : i64
    %8 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %9 = llvm.call @shmem_long_ctx_atomic_fetch_or(%4, %8, %7, %5) : (!llvm.ptr, !llvm.ptr, i64, i32) -> i64
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%8) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i32_atomic_or() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(4 : index) : i64
    %2 = llvm.mlir.constant(128 : i32) : i32
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    llvm.call @shmem_int_atomic_or(%3, %2, %0) : (!llvm.ptr, i32, i32) -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i64_atomic_or() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(8 : index) : i64
    %2 = llvm.mlir.constant(128 : i64) : i64
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    llvm.call @shmem_long_atomic_or(%3, %2, %0) : (!llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i32_atomic_or() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(4 : index) : i64
    %7 = llvm.mlir.constant(128 : i32) : i32
    %8 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    llvm.call @shmem_int_ctx_atomic_or(%4, %8, %7, %5) : (!llvm.ptr, !llvm.ptr, i32, i32) -> ()
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%8) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i64_atomic_or() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(8 : index) : i64
    %7 = llvm.mlir.constant(128 : i64) : i64
    %8 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    llvm.call @shmem_long_ctx_atomic_or(%4, %8, %7, %5) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%8) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i32_atomic_fetch_xor() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(4 : index) : i64
    %2 = llvm.mlir.constant(85 : i32) : i32
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %4 = llvm.call @shmem_int_atomic_fetch_xor(%3, %2, %0) : (!llvm.ptr, i32, i32) -> i32
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i64_atomic_fetch_xor() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(8 : index) : i64
    %2 = llvm.mlir.constant(85 : i64) : i64
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %4 = llvm.call @shmem_long_atomic_fetch_xor(%3, %2, %0) : (!llvm.ptr, i64, i32) -> i64
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i32_atomic_fetch_xor() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(4 : index) : i64
    %7 = llvm.mlir.constant(85 : i32) : i32
    %8 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %9 = llvm.call @shmem_int_ctx_atomic_fetch_xor(%4, %8, %7, %5) : (!llvm.ptr, !llvm.ptr, i32, i32) -> i32
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%8) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i64_atomic_fetch_xor() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(8 : index) : i64
    %7 = llvm.mlir.constant(85 : i64) : i64
    %8 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %9 = llvm.call @shmem_long_ctx_atomic_fetch_xor(%4, %8, %7, %5) : (!llvm.ptr, !llvm.ptr, i64, i32) -> i64
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%8) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i32_atomic_xor() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(4 : index) : i64
    %2 = llvm.mlir.constant(85 : i32) : i32
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    llvm.call @shmem_int_atomic_xor(%3, %2, %0) : (!llvm.ptr, i32, i32) -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i64_atomic_xor() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(8 : index) : i64
    %2 = llvm.mlir.constant(85 : i64) : i64
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    llvm.call @shmem_long_atomic_xor(%3, %2, %0) : (!llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i32_atomic_xor() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(4 : index) : i64
    %7 = llvm.mlir.constant(85 : i32) : i32
    %8 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    llvm.call @shmem_int_ctx_atomic_xor(%4, %8, %7, %5) : (!llvm.ptr, !llvm.ptr, i32, i32) -> ()
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%8) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i64_atomic_xor() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(8 : index) : i64
    %7 = llvm.mlir.constant(85 : i64) : i64
    %8 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    llvm.call @shmem_long_ctx_atomic_xor(%4, %8, %7, %5) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%8) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i32_atomic_fetch_nbi() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(4 : index) : i64
    %2 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %3 = llvm.mlir.constant(1 : index) : i64
    %4 = llvm.mlir.zero : !llvm.ptr
    %5 = llvm.getelementptr %4[%3] : (!llvm.ptr, i64) -> !llvm.ptr, i32
    %6 = llvm.ptrtoint %5 : !llvm.ptr to i64
    %7 = llvm.call @malloc(%6) : (i64) -> !llvm.ptr
    %8 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64)>
    %9 = llvm.insertvalue %7, %8[0] : !llvm.struct<(ptr, ptr, i64)> 
    %10 = llvm.insertvalue %7, %9[1] : !llvm.struct<(ptr, ptr, i64)> 
    %11 = llvm.mlir.constant(0 : index) : i64
    %12 = llvm.insertvalue %11, %10[2] : !llvm.struct<(ptr, ptr, i64)> 
    %13 = llvm.extractvalue %12[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @shmem_int_atomic_fetch_nbi(%13, %2, %0) : (!llvm.ptr, !llvm.ptr, i32) -> ()
    %14 = llvm.extractvalue %12[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @free(%14) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%2) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i64_atomic_fetch_nbi() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(8 : index) : i64
    %2 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %3 = llvm.mlir.constant(1 : index) : i64
    %4 = llvm.mlir.zero : !llvm.ptr
    %5 = llvm.getelementptr %4[%3] : (!llvm.ptr, i64) -> !llvm.ptr, i64
    %6 = llvm.ptrtoint %5 : !llvm.ptr to i64
    %7 = llvm.call @malloc(%6) : (i64) -> !llvm.ptr
    %8 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64)>
    %9 = llvm.insertvalue %7, %8[0] : !llvm.struct<(ptr, ptr, i64)> 
    %10 = llvm.insertvalue %7, %9[1] : !llvm.struct<(ptr, ptr, i64)> 
    %11 = llvm.mlir.constant(0 : index) : i64
    %12 = llvm.insertvalue %11, %10[2] : !llvm.struct<(ptr, ptr, i64)> 
    %13 = llvm.extractvalue %12[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @shmem_long_atomic_fetch_nbi(%13, %2, %0) : (!llvm.ptr, !llvm.ptr, i32) -> ()
    %14 = llvm.extractvalue %12[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @free(%14) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%2) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i32_atomic_fetch_nbi() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(4 : index) : i64
    %7 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %8 = llvm.mlir.constant(1 : index) : i64
    %9 = llvm.mlir.zero : !llvm.ptr
    %10 = llvm.getelementptr %9[%8] : (!llvm.ptr, i64) -> !llvm.ptr, i32
    %11 = llvm.ptrtoint %10 : !llvm.ptr to i64
    %12 = llvm.call @malloc(%11) : (i64) -> !llvm.ptr
    %13 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64)>
    %14 = llvm.insertvalue %12, %13[0] : !llvm.struct<(ptr, ptr, i64)> 
    %15 = llvm.insertvalue %12, %14[1] : !llvm.struct<(ptr, ptr, i64)> 
    %16 = llvm.mlir.constant(0 : index) : i64
    %17 = llvm.insertvalue %16, %15[2] : !llvm.struct<(ptr, ptr, i64)> 
    %18 = llvm.extractvalue %17[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @shmem_int_ctx_atomic_fetch_nbi(%4, %18, %7, %5) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i32) -> ()
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    %19 = llvm.extractvalue %17[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @free(%19) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%7) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i64_atomic_fetch_nbi() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(8 : index) : i64
    %7 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %8 = llvm.mlir.constant(1 : index) : i64
    %9 = llvm.mlir.zero : !llvm.ptr
    %10 = llvm.getelementptr %9[%8] : (!llvm.ptr, i64) -> !llvm.ptr, i64
    %11 = llvm.ptrtoint %10 : !llvm.ptr to i64
    %12 = llvm.call @malloc(%11) : (i64) -> !llvm.ptr
    %13 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64)>
    %14 = llvm.insertvalue %12, %13[0] : !llvm.struct<(ptr, ptr, i64)> 
    %15 = llvm.insertvalue %12, %14[1] : !llvm.struct<(ptr, ptr, i64)> 
    %16 = llvm.mlir.constant(0 : index) : i64
    %17 = llvm.insertvalue %16, %15[2] : !llvm.struct<(ptr, ptr, i64)> 
    %18 = llvm.extractvalue %17[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @shmem_long_ctx_atomic_fetch_nbi(%4, %18, %7, %5) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i32) -> ()
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    %19 = llvm.extractvalue %17[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @free(%19) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%7) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i32_atomic_compare_swap_nbi() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(4 : index) : i64
    %2 = llvm.mlir.constant(42 : i32) : i32
    %3 = llvm.mlir.constant(43 : i32) : i32
    %4 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : index) : i64
    %6 = llvm.mlir.zero : !llvm.ptr
    %7 = llvm.getelementptr %6[%5] : (!llvm.ptr, i64) -> !llvm.ptr, i32
    %8 = llvm.ptrtoint %7 : !llvm.ptr to i64
    %9 = llvm.call @malloc(%8) : (i64) -> !llvm.ptr
    %10 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64)>
    %11 = llvm.insertvalue %9, %10[0] : !llvm.struct<(ptr, ptr, i64)> 
    %12 = llvm.insertvalue %9, %11[1] : !llvm.struct<(ptr, ptr, i64)> 
    %13 = llvm.mlir.constant(0 : index) : i64
    %14 = llvm.insertvalue %13, %12[2] : !llvm.struct<(ptr, ptr, i64)> 
    %15 = llvm.extractvalue %14[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @shmem_int_atomic_compare_swap_nbi(%15, %4, %2, %3, %0) : (!llvm.ptr, !llvm.ptr, i32, i32, i32) -> ()
    %16 = llvm.extractvalue %14[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @free(%16) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i64_atomic_compare_swap_nbi() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(8 : index) : i64
    %2 = llvm.mlir.constant(42 : i64) : i64
    %3 = llvm.mlir.constant(43 : i64) : i64
    %4 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : index) : i64
    %6 = llvm.mlir.zero : !llvm.ptr
    %7 = llvm.getelementptr %6[%5] : (!llvm.ptr, i64) -> !llvm.ptr, i64
    %8 = llvm.ptrtoint %7 : !llvm.ptr to i64
    %9 = llvm.call @malloc(%8) : (i64) -> !llvm.ptr
    %10 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64)>
    %11 = llvm.insertvalue %9, %10[0] : !llvm.struct<(ptr, ptr, i64)> 
    %12 = llvm.insertvalue %9, %11[1] : !llvm.struct<(ptr, ptr, i64)> 
    %13 = llvm.mlir.constant(0 : index) : i64
    %14 = llvm.insertvalue %13, %12[2] : !llvm.struct<(ptr, ptr, i64)> 
    %15 = llvm.extractvalue %14[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @shmem_long_atomic_compare_swap_nbi(%15, %4, %2, %3, %0) : (!llvm.ptr, !llvm.ptr, i64, i64, i32) -> ()
    %16 = llvm.extractvalue %14[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @free(%16) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%4) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i32_atomic_compare_swap_nbi() {
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
    %10 = llvm.mlir.constant(1 : index) : i64
    %11 = llvm.mlir.zero : !llvm.ptr
    %12 = llvm.getelementptr %11[%10] : (!llvm.ptr, i64) -> !llvm.ptr, i32
    %13 = llvm.ptrtoint %12 : !llvm.ptr to i64
    %14 = llvm.call @malloc(%13) : (i64) -> !llvm.ptr
    %15 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64)>
    %16 = llvm.insertvalue %14, %15[0] : !llvm.struct<(ptr, ptr, i64)> 
    %17 = llvm.insertvalue %14, %16[1] : !llvm.struct<(ptr, ptr, i64)> 
    %18 = llvm.mlir.constant(0 : index) : i64
    %19 = llvm.insertvalue %18, %17[2] : !llvm.struct<(ptr, ptr, i64)> 
    %20 = llvm.extractvalue %19[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @shmem_int_ctx_atomic_compare_swap_nbi(%4, %20, %9, %7, %8, %5) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32, i32) -> ()
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    %21 = llvm.extractvalue %19[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @free(%21) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%9) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i64_atomic_compare_swap_nbi() {
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
    %10 = llvm.mlir.constant(1 : index) : i64
    %11 = llvm.mlir.zero : !llvm.ptr
    %12 = llvm.getelementptr %11[%10] : (!llvm.ptr, i64) -> !llvm.ptr, i64
    %13 = llvm.ptrtoint %12 : !llvm.ptr to i64
    %14 = llvm.call @malloc(%13) : (i64) -> !llvm.ptr
    %15 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64)>
    %16 = llvm.insertvalue %14, %15[0] : !llvm.struct<(ptr, ptr, i64)> 
    %17 = llvm.insertvalue %14, %16[1] : !llvm.struct<(ptr, ptr, i64)> 
    %18 = llvm.mlir.constant(0 : index) : i64
    %19 = llvm.insertvalue %18, %17[2] : !llvm.struct<(ptr, ptr, i64)> 
    %20 = llvm.extractvalue %19[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @shmem_long_ctx_atomic_compare_swap_nbi(%4, %20, %9, %7, %8, %5) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i64, i64, i32) -> ()
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    %21 = llvm.extractvalue %19[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @free(%21) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%9) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i32_atomic_swap_nbi() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(4 : index) : i64
    %2 = llvm.mlir.constant(42 : i32) : i32
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %4 = llvm.mlir.constant(1 : index) : i64
    %5 = llvm.mlir.zero : !llvm.ptr
    %6 = llvm.getelementptr %5[%4] : (!llvm.ptr, i64) -> !llvm.ptr, i32
    %7 = llvm.ptrtoint %6 : !llvm.ptr to i64
    %8 = llvm.call @malloc(%7) : (i64) -> !llvm.ptr
    %9 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64)>
    %10 = llvm.insertvalue %8, %9[0] : !llvm.struct<(ptr, ptr, i64)> 
    %11 = llvm.insertvalue %8, %10[1] : !llvm.struct<(ptr, ptr, i64)> 
    %12 = llvm.mlir.constant(0 : index) : i64
    %13 = llvm.insertvalue %12, %11[2] : !llvm.struct<(ptr, ptr, i64)> 
    %14 = llvm.extractvalue %13[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @shmem_int_atomic_swap_nbi(%14, %3, %2, %0) : (!llvm.ptr, !llvm.ptr, i32, i32) -> ()
    %15 = llvm.extractvalue %13[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @free(%15) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i64_atomic_swap_nbi() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(8 : index) : i64
    %2 = llvm.mlir.constant(42 : i64) : i64
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %4 = llvm.mlir.constant(1 : index) : i64
    %5 = llvm.mlir.zero : !llvm.ptr
    %6 = llvm.getelementptr %5[%4] : (!llvm.ptr, i64) -> !llvm.ptr, i64
    %7 = llvm.ptrtoint %6 : !llvm.ptr to i64
    %8 = llvm.call @malloc(%7) : (i64) -> !llvm.ptr
    %9 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64)>
    %10 = llvm.insertvalue %8, %9[0] : !llvm.struct<(ptr, ptr, i64)> 
    %11 = llvm.insertvalue %8, %10[1] : !llvm.struct<(ptr, ptr, i64)> 
    %12 = llvm.mlir.constant(0 : index) : i64
    %13 = llvm.insertvalue %12, %11[2] : !llvm.struct<(ptr, ptr, i64)> 
    %14 = llvm.extractvalue %13[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @shmem_long_atomic_swap_nbi(%14, %3, %2, %0) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    %15 = llvm.extractvalue %13[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @free(%15) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i32_atomic_swap_nbi() {
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
    %9 = llvm.mlir.constant(1 : index) : i64
    %10 = llvm.mlir.zero : !llvm.ptr
    %11 = llvm.getelementptr %10[%9] : (!llvm.ptr, i64) -> !llvm.ptr, i32
    %12 = llvm.ptrtoint %11 : !llvm.ptr to i64
    %13 = llvm.call @malloc(%12) : (i64) -> !llvm.ptr
    %14 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64)>
    %15 = llvm.insertvalue %13, %14[0] : !llvm.struct<(ptr, ptr, i64)> 
    %16 = llvm.insertvalue %13, %15[1] : !llvm.struct<(ptr, ptr, i64)> 
    %17 = llvm.mlir.constant(0 : index) : i64
    %18 = llvm.insertvalue %17, %16[2] : !llvm.struct<(ptr, ptr, i64)> 
    %19 = llvm.extractvalue %18[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @shmem_int_ctx_atomic_swap_nbi(%4, %19, %8, %7, %5) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32) -> ()
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    %20 = llvm.extractvalue %18[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @free(%20) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%8) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i64_atomic_swap_nbi() {
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
    %9 = llvm.mlir.constant(1 : index) : i64
    %10 = llvm.mlir.zero : !llvm.ptr
    %11 = llvm.getelementptr %10[%9] : (!llvm.ptr, i64) -> !llvm.ptr, i64
    %12 = llvm.ptrtoint %11 : !llvm.ptr to i64
    %13 = llvm.call @malloc(%12) : (i64) -> !llvm.ptr
    %14 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64)>
    %15 = llvm.insertvalue %13, %14[0] : !llvm.struct<(ptr, ptr, i64)> 
    %16 = llvm.insertvalue %13, %15[1] : !llvm.struct<(ptr, ptr, i64)> 
    %17 = llvm.mlir.constant(0 : index) : i64
    %18 = llvm.insertvalue %17, %16[2] : !llvm.struct<(ptr, ptr, i64)> 
    %19 = llvm.extractvalue %18[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @shmem_long_ctx_atomic_swap_nbi(%4, %19, %8, %7, %5) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    %20 = llvm.extractvalue %18[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @free(%20) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%8) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i32_atomic_fetch_inc_nbi() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(4 : index) : i64
    %2 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %3 = llvm.mlir.constant(1 : index) : i64
    %4 = llvm.mlir.zero : !llvm.ptr
    %5 = llvm.getelementptr %4[%3] : (!llvm.ptr, i64) -> !llvm.ptr, i32
    %6 = llvm.ptrtoint %5 : !llvm.ptr to i64
    %7 = llvm.call @malloc(%6) : (i64) -> !llvm.ptr
    %8 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64)>
    %9 = llvm.insertvalue %7, %8[0] : !llvm.struct<(ptr, ptr, i64)> 
    %10 = llvm.insertvalue %7, %9[1] : !llvm.struct<(ptr, ptr, i64)> 
    %11 = llvm.mlir.constant(0 : index) : i64
    %12 = llvm.insertvalue %11, %10[2] : !llvm.struct<(ptr, ptr, i64)> 
    %13 = llvm.extractvalue %12[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @shmem_int_atomic_fetch_inc_nbi(%13, %2, %0) : (!llvm.ptr, !llvm.ptr, i32) -> ()
    %14 = llvm.extractvalue %12[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @free(%14) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%2) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i64_atomic_fetch_inc_nbi() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(8 : index) : i64
    %2 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %3 = llvm.mlir.constant(1 : index) : i64
    %4 = llvm.mlir.zero : !llvm.ptr
    %5 = llvm.getelementptr %4[%3] : (!llvm.ptr, i64) -> !llvm.ptr, i64
    %6 = llvm.ptrtoint %5 : !llvm.ptr to i64
    %7 = llvm.call @malloc(%6) : (i64) -> !llvm.ptr
    %8 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64)>
    %9 = llvm.insertvalue %7, %8[0] : !llvm.struct<(ptr, ptr, i64)> 
    %10 = llvm.insertvalue %7, %9[1] : !llvm.struct<(ptr, ptr, i64)> 
    %11 = llvm.mlir.constant(0 : index) : i64
    %12 = llvm.insertvalue %11, %10[2] : !llvm.struct<(ptr, ptr, i64)> 
    %13 = llvm.extractvalue %12[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @shmem_long_atomic_fetch_inc_nbi(%13, %2, %0) : (!llvm.ptr, !llvm.ptr, i32) -> ()
    %14 = llvm.extractvalue %12[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @free(%14) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%2) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i32_atomic_fetch_inc_nbi() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(4 : index) : i64
    %7 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %8 = llvm.mlir.constant(1 : index) : i64
    %9 = llvm.mlir.zero : !llvm.ptr
    %10 = llvm.getelementptr %9[%8] : (!llvm.ptr, i64) -> !llvm.ptr, i32
    %11 = llvm.ptrtoint %10 : !llvm.ptr to i64
    %12 = llvm.call @malloc(%11) : (i64) -> !llvm.ptr
    %13 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64)>
    %14 = llvm.insertvalue %12, %13[0] : !llvm.struct<(ptr, ptr, i64)> 
    %15 = llvm.insertvalue %12, %14[1] : !llvm.struct<(ptr, ptr, i64)> 
    %16 = llvm.mlir.constant(0 : index) : i64
    %17 = llvm.insertvalue %16, %15[2] : !llvm.struct<(ptr, ptr, i64)> 
    %18 = llvm.extractvalue %17[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @shmem_int_ctx_atomic_fetch_inc_nbi(%4, %18, %7, %5) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i32) -> ()
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    %19 = llvm.extractvalue %17[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @free(%19) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%7) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i64_atomic_fetch_inc_nbi() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(8 : index) : i64
    %7 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %8 = llvm.mlir.constant(1 : index) : i64
    %9 = llvm.mlir.zero : !llvm.ptr
    %10 = llvm.getelementptr %9[%8] : (!llvm.ptr, i64) -> !llvm.ptr, i64
    %11 = llvm.ptrtoint %10 : !llvm.ptr to i64
    %12 = llvm.call @malloc(%11) : (i64) -> !llvm.ptr
    %13 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64)>
    %14 = llvm.insertvalue %12, %13[0] : !llvm.struct<(ptr, ptr, i64)> 
    %15 = llvm.insertvalue %12, %14[1] : !llvm.struct<(ptr, ptr, i64)> 
    %16 = llvm.mlir.constant(0 : index) : i64
    %17 = llvm.insertvalue %16, %15[2] : !llvm.struct<(ptr, ptr, i64)> 
    %18 = llvm.extractvalue %17[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @shmem_long_ctx_atomic_fetch_inc_nbi(%4, %18, %7, %5) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i32) -> ()
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    %19 = llvm.extractvalue %17[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @free(%19) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%7) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i32_atomic_fetch_add_nbi() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(4 : index) : i64
    %2 = llvm.mlir.constant(5 : i32) : i32
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %4 = llvm.mlir.constant(1 : index) : i64
    %5 = llvm.mlir.zero : !llvm.ptr
    %6 = llvm.getelementptr %5[%4] : (!llvm.ptr, i64) -> !llvm.ptr, i32
    %7 = llvm.ptrtoint %6 : !llvm.ptr to i64
    %8 = llvm.call @malloc(%7) : (i64) -> !llvm.ptr
    %9 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64)>
    %10 = llvm.insertvalue %8, %9[0] : !llvm.struct<(ptr, ptr, i64)> 
    %11 = llvm.insertvalue %8, %10[1] : !llvm.struct<(ptr, ptr, i64)> 
    %12 = llvm.mlir.constant(0 : index) : i64
    %13 = llvm.insertvalue %12, %11[2] : !llvm.struct<(ptr, ptr, i64)> 
    %14 = llvm.extractvalue %13[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @shmem_int_atomic_fetch_add_nbi(%14, %3, %2, %0) : (!llvm.ptr, !llvm.ptr, i32, i32) -> ()
    %15 = llvm.extractvalue %13[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @free(%15) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i64_atomic_fetch_add_nbi() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(8 : index) : i64
    %2 = llvm.mlir.constant(5 : i64) : i64
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %4 = llvm.mlir.constant(1 : index) : i64
    %5 = llvm.mlir.zero : !llvm.ptr
    %6 = llvm.getelementptr %5[%4] : (!llvm.ptr, i64) -> !llvm.ptr, i64
    %7 = llvm.ptrtoint %6 : !llvm.ptr to i64
    %8 = llvm.call @malloc(%7) : (i64) -> !llvm.ptr
    %9 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64)>
    %10 = llvm.insertvalue %8, %9[0] : !llvm.struct<(ptr, ptr, i64)> 
    %11 = llvm.insertvalue %8, %10[1] : !llvm.struct<(ptr, ptr, i64)> 
    %12 = llvm.mlir.constant(0 : index) : i64
    %13 = llvm.insertvalue %12, %11[2] : !llvm.struct<(ptr, ptr, i64)> 
    %14 = llvm.extractvalue %13[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @shmem_long_atomic_fetch_add_nbi(%14, %3, %2, %0) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    %15 = llvm.extractvalue %13[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @free(%15) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i32_atomic_fetch_add_nbi() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(4 : index) : i64
    %7 = llvm.mlir.constant(5 : i32) : i32
    %8 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %9 = llvm.mlir.constant(1 : index) : i64
    %10 = llvm.mlir.zero : !llvm.ptr
    %11 = llvm.getelementptr %10[%9] : (!llvm.ptr, i64) -> !llvm.ptr, i32
    %12 = llvm.ptrtoint %11 : !llvm.ptr to i64
    %13 = llvm.call @malloc(%12) : (i64) -> !llvm.ptr
    %14 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64)>
    %15 = llvm.insertvalue %13, %14[0] : !llvm.struct<(ptr, ptr, i64)> 
    %16 = llvm.insertvalue %13, %15[1] : !llvm.struct<(ptr, ptr, i64)> 
    %17 = llvm.mlir.constant(0 : index) : i64
    %18 = llvm.insertvalue %17, %16[2] : !llvm.struct<(ptr, ptr, i64)> 
    %19 = llvm.extractvalue %18[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @shmem_int_ctx_atomic_fetch_add_nbi(%4, %19, %8, %7, %5) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32) -> ()
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    %20 = llvm.extractvalue %18[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @free(%20) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%8) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i64_atomic_fetch_add_nbi() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(8 : index) : i64
    %7 = llvm.mlir.constant(5 : i64) : i64
    %8 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %9 = llvm.mlir.constant(1 : index) : i64
    %10 = llvm.mlir.zero : !llvm.ptr
    %11 = llvm.getelementptr %10[%9] : (!llvm.ptr, i64) -> !llvm.ptr, i64
    %12 = llvm.ptrtoint %11 : !llvm.ptr to i64
    %13 = llvm.call @malloc(%12) : (i64) -> !llvm.ptr
    %14 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64)>
    %15 = llvm.insertvalue %13, %14[0] : !llvm.struct<(ptr, ptr, i64)> 
    %16 = llvm.insertvalue %13, %15[1] : !llvm.struct<(ptr, ptr, i64)> 
    %17 = llvm.mlir.constant(0 : index) : i64
    %18 = llvm.insertvalue %17, %16[2] : !llvm.struct<(ptr, ptr, i64)> 
    %19 = llvm.extractvalue %18[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @shmem_long_ctx_atomic_fetch_add_nbi(%4, %19, %8, %7, %5) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    %20 = llvm.extractvalue %18[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @free(%20) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%8) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i32_atomic_fetch_and_nbi() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(4 : index) : i64
    %2 = llvm.mlir.constant(255 : i32) : i32
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %4 = llvm.mlir.constant(1 : index) : i64
    %5 = llvm.mlir.zero : !llvm.ptr
    %6 = llvm.getelementptr %5[%4] : (!llvm.ptr, i64) -> !llvm.ptr, i32
    %7 = llvm.ptrtoint %6 : !llvm.ptr to i64
    %8 = llvm.call @malloc(%7) : (i64) -> !llvm.ptr
    %9 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64)>
    %10 = llvm.insertvalue %8, %9[0] : !llvm.struct<(ptr, ptr, i64)> 
    %11 = llvm.insertvalue %8, %10[1] : !llvm.struct<(ptr, ptr, i64)> 
    %12 = llvm.mlir.constant(0 : index) : i64
    %13 = llvm.insertvalue %12, %11[2] : !llvm.struct<(ptr, ptr, i64)> 
    %14 = llvm.extractvalue %13[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @shmem_int_atomic_fetch_and_nbi(%14, %3, %2, %0) : (!llvm.ptr, !llvm.ptr, i32, i32) -> ()
    %15 = llvm.extractvalue %13[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @free(%15) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i64_atomic_fetch_and_nbi() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(8 : index) : i64
    %2 = llvm.mlir.constant(255 : i64) : i64
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %4 = llvm.mlir.constant(1 : index) : i64
    %5 = llvm.mlir.zero : !llvm.ptr
    %6 = llvm.getelementptr %5[%4] : (!llvm.ptr, i64) -> !llvm.ptr, i64
    %7 = llvm.ptrtoint %6 : !llvm.ptr to i64
    %8 = llvm.call @malloc(%7) : (i64) -> !llvm.ptr
    %9 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64)>
    %10 = llvm.insertvalue %8, %9[0] : !llvm.struct<(ptr, ptr, i64)> 
    %11 = llvm.insertvalue %8, %10[1] : !llvm.struct<(ptr, ptr, i64)> 
    %12 = llvm.mlir.constant(0 : index) : i64
    %13 = llvm.insertvalue %12, %11[2] : !llvm.struct<(ptr, ptr, i64)> 
    %14 = llvm.extractvalue %13[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @shmem_long_atomic_fetch_and_nbi(%14, %3, %2, %0) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    %15 = llvm.extractvalue %13[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @free(%15) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i32_atomic_fetch_and_nbi() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(4 : index) : i64
    %7 = llvm.mlir.constant(255 : i32) : i32
    %8 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %9 = llvm.mlir.constant(1 : index) : i64
    %10 = llvm.mlir.zero : !llvm.ptr
    %11 = llvm.getelementptr %10[%9] : (!llvm.ptr, i64) -> !llvm.ptr, i32
    %12 = llvm.ptrtoint %11 : !llvm.ptr to i64
    %13 = llvm.call @malloc(%12) : (i64) -> !llvm.ptr
    %14 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64)>
    %15 = llvm.insertvalue %13, %14[0] : !llvm.struct<(ptr, ptr, i64)> 
    %16 = llvm.insertvalue %13, %15[1] : !llvm.struct<(ptr, ptr, i64)> 
    %17 = llvm.mlir.constant(0 : index) : i64
    %18 = llvm.insertvalue %17, %16[2] : !llvm.struct<(ptr, ptr, i64)> 
    %19 = llvm.extractvalue %18[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @shmem_int_ctx_atomic_fetch_and_nbi(%4, %19, %8, %7, %5) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32) -> ()
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    %20 = llvm.extractvalue %18[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @free(%20) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%8) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i64_atomic_fetch_and_nbi() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(8 : index) : i64
    %7 = llvm.mlir.constant(255 : i64) : i64
    %8 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %9 = llvm.mlir.constant(1 : index) : i64
    %10 = llvm.mlir.zero : !llvm.ptr
    %11 = llvm.getelementptr %10[%9] : (!llvm.ptr, i64) -> !llvm.ptr, i64
    %12 = llvm.ptrtoint %11 : !llvm.ptr to i64
    %13 = llvm.call @malloc(%12) : (i64) -> !llvm.ptr
    %14 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64)>
    %15 = llvm.insertvalue %13, %14[0] : !llvm.struct<(ptr, ptr, i64)> 
    %16 = llvm.insertvalue %13, %15[1] : !llvm.struct<(ptr, ptr, i64)> 
    %17 = llvm.mlir.constant(0 : index) : i64
    %18 = llvm.insertvalue %17, %16[2] : !llvm.struct<(ptr, ptr, i64)> 
    %19 = llvm.extractvalue %18[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @shmem_long_ctx_atomic_fetch_and_nbi(%4, %19, %8, %7, %5) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    %20 = llvm.extractvalue %18[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @free(%20) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%8) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i32_atomic_fetch_or_nbi() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(4 : index) : i64
    %2 = llvm.mlir.constant(128 : i32) : i32
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %4 = llvm.mlir.constant(1 : index) : i64
    %5 = llvm.mlir.zero : !llvm.ptr
    %6 = llvm.getelementptr %5[%4] : (!llvm.ptr, i64) -> !llvm.ptr, i32
    %7 = llvm.ptrtoint %6 : !llvm.ptr to i64
    %8 = llvm.call @malloc(%7) : (i64) -> !llvm.ptr
    %9 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64)>
    %10 = llvm.insertvalue %8, %9[0] : !llvm.struct<(ptr, ptr, i64)> 
    %11 = llvm.insertvalue %8, %10[1] : !llvm.struct<(ptr, ptr, i64)> 
    %12 = llvm.mlir.constant(0 : index) : i64
    %13 = llvm.insertvalue %12, %11[2] : !llvm.struct<(ptr, ptr, i64)> 
    %14 = llvm.extractvalue %13[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @shmem_int_atomic_fetch_or_nbi(%14, %3, %2, %0) : (!llvm.ptr, !llvm.ptr, i32, i32) -> ()
    %15 = llvm.extractvalue %13[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @free(%15) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i64_atomic_fetch_or_nbi() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(8 : index) : i64
    %2 = llvm.mlir.constant(128 : i64) : i64
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %4 = llvm.mlir.constant(1 : index) : i64
    %5 = llvm.mlir.zero : !llvm.ptr
    %6 = llvm.getelementptr %5[%4] : (!llvm.ptr, i64) -> !llvm.ptr, i64
    %7 = llvm.ptrtoint %6 : !llvm.ptr to i64
    %8 = llvm.call @malloc(%7) : (i64) -> !llvm.ptr
    %9 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64)>
    %10 = llvm.insertvalue %8, %9[0] : !llvm.struct<(ptr, ptr, i64)> 
    %11 = llvm.insertvalue %8, %10[1] : !llvm.struct<(ptr, ptr, i64)> 
    %12 = llvm.mlir.constant(0 : index) : i64
    %13 = llvm.insertvalue %12, %11[2] : !llvm.struct<(ptr, ptr, i64)> 
    %14 = llvm.extractvalue %13[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @shmem_long_atomic_fetch_or_nbi(%14, %3, %2, %0) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    %15 = llvm.extractvalue %13[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @free(%15) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i32_atomic_fetch_or_nbi() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(4 : index) : i64
    %7 = llvm.mlir.constant(128 : i32) : i32
    %8 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %9 = llvm.mlir.constant(1 : index) : i64
    %10 = llvm.mlir.zero : !llvm.ptr
    %11 = llvm.getelementptr %10[%9] : (!llvm.ptr, i64) -> !llvm.ptr, i32
    %12 = llvm.ptrtoint %11 : !llvm.ptr to i64
    %13 = llvm.call @malloc(%12) : (i64) -> !llvm.ptr
    %14 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64)>
    %15 = llvm.insertvalue %13, %14[0] : !llvm.struct<(ptr, ptr, i64)> 
    %16 = llvm.insertvalue %13, %15[1] : !llvm.struct<(ptr, ptr, i64)> 
    %17 = llvm.mlir.constant(0 : index) : i64
    %18 = llvm.insertvalue %17, %16[2] : !llvm.struct<(ptr, ptr, i64)> 
    %19 = llvm.extractvalue %18[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @shmem_int_ctx_atomic_fetch_or_nbi(%4, %19, %8, %7, %5) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32) -> ()
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    %20 = llvm.extractvalue %18[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @free(%20) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%8) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i64_atomic_fetch_or_nbi() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(8 : index) : i64
    %7 = llvm.mlir.constant(128 : i64) : i64
    %8 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %9 = llvm.mlir.constant(1 : index) : i64
    %10 = llvm.mlir.zero : !llvm.ptr
    %11 = llvm.getelementptr %10[%9] : (!llvm.ptr, i64) -> !llvm.ptr, i64
    %12 = llvm.ptrtoint %11 : !llvm.ptr to i64
    %13 = llvm.call @malloc(%12) : (i64) -> !llvm.ptr
    %14 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64)>
    %15 = llvm.insertvalue %13, %14[0] : !llvm.struct<(ptr, ptr, i64)> 
    %16 = llvm.insertvalue %13, %15[1] : !llvm.struct<(ptr, ptr, i64)> 
    %17 = llvm.mlir.constant(0 : index) : i64
    %18 = llvm.insertvalue %17, %16[2] : !llvm.struct<(ptr, ptr, i64)> 
    %19 = llvm.extractvalue %18[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @shmem_long_ctx_atomic_fetch_or_nbi(%4, %19, %8, %7, %5) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    %20 = llvm.extractvalue %18[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @free(%20) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%8) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i32_atomic_fetch_xor_nbi() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(4 : index) : i64
    %2 = llvm.mlir.constant(85 : i32) : i32
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %4 = llvm.mlir.constant(1 : index) : i64
    %5 = llvm.mlir.zero : !llvm.ptr
    %6 = llvm.getelementptr %5[%4] : (!llvm.ptr, i64) -> !llvm.ptr, i32
    %7 = llvm.ptrtoint %6 : !llvm.ptr to i64
    %8 = llvm.call @malloc(%7) : (i64) -> !llvm.ptr
    %9 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64)>
    %10 = llvm.insertvalue %8, %9[0] : !llvm.struct<(ptr, ptr, i64)> 
    %11 = llvm.insertvalue %8, %10[1] : !llvm.struct<(ptr, ptr, i64)> 
    %12 = llvm.mlir.constant(0 : index) : i64
    %13 = llvm.insertvalue %12, %11[2] : !llvm.struct<(ptr, ptr, i64)> 
    %14 = llvm.extractvalue %13[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @shmem_int_atomic_fetch_xor_nbi(%14, %3, %2, %0) : (!llvm.ptr, !llvm.ptr, i32, i32) -> ()
    %15 = llvm.extractvalue %13[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @free(%15) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_i64_atomic_fetch_xor_nbi() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(8 : index) : i64
    %2 = llvm.mlir.constant(85 : i64) : i64
    %3 = llvm.call @shmem_malloc(%1) : (i64) -> !llvm.ptr
    %4 = llvm.mlir.constant(1 : index) : i64
    %5 = llvm.mlir.zero : !llvm.ptr
    %6 = llvm.getelementptr %5[%4] : (!llvm.ptr, i64) -> !llvm.ptr, i64
    %7 = llvm.ptrtoint %6 : !llvm.ptr to i64
    %8 = llvm.call @malloc(%7) : (i64) -> !llvm.ptr
    %9 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64)>
    %10 = llvm.insertvalue %8, %9[0] : !llvm.struct<(ptr, ptr, i64)> 
    %11 = llvm.insertvalue %8, %10[1] : !llvm.struct<(ptr, ptr, i64)> 
    %12 = llvm.mlir.constant(0 : index) : i64
    %13 = llvm.insertvalue %12, %11[2] : !llvm.struct<(ptr, ptr, i64)> 
    %14 = llvm.extractvalue %13[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @shmem_long_atomic_fetch_xor_nbi(%14, %3, %2, %0) : (!llvm.ptr, !llvm.ptr, i64, i32) -> ()
    %15 = llvm.extractvalue %13[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @free(%15) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%3) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i32_atomic_fetch_xor_nbi() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(4 : index) : i64
    %7 = llvm.mlir.constant(85 : i32) : i32
    %8 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %9 = llvm.mlir.constant(1 : index) : i64
    %10 = llvm.mlir.zero : !llvm.ptr
    %11 = llvm.getelementptr %10[%9] : (!llvm.ptr, i64) -> !llvm.ptr, i32
    %12 = llvm.ptrtoint %11 : !llvm.ptr to i64
    %13 = llvm.call @malloc(%12) : (i64) -> !llvm.ptr
    %14 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64)>
    %15 = llvm.insertvalue %13, %14[0] : !llvm.struct<(ptr, ptr, i64)> 
    %16 = llvm.insertvalue %13, %15[1] : !llvm.struct<(ptr, ptr, i64)> 
    %17 = llvm.mlir.constant(0 : index) : i64
    %18 = llvm.insertvalue %17, %16[2] : !llvm.struct<(ptr, ptr, i64)> 
    %19 = llvm.extractvalue %18[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @shmem_int_ctx_atomic_fetch_xor_nbi(%4, %19, %8, %7, %5) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32) -> ()
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    %20 = llvm.extractvalue %18[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @free(%20) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%8) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
  llvm.func @test_ctx_i64_atomic_fetch_xor_nbi() {
    llvm.call @shmem_init() : () -> ()
    %0 = llvm.mlir.constant(0 : i64) : i64
    %1 = llvm.mlir.constant(1 : i32) : i32
    %2 = llvm.alloca %1 x !llvm.ptr : (i32) -> !llvm.ptr
    %3 = llvm.call @shmem_ctx_create(%0, %2) : (i64, !llvm.ptr) -> i32
    %4 = llvm.load %2 : !llvm.ptr -> !llvm.ptr
    %5 = llvm.mlir.constant(1 : i32) : i32
    %6 = llvm.mlir.constant(8 : index) : i64
    %7 = llvm.mlir.constant(85 : i64) : i64
    %8 = llvm.call @shmem_malloc(%6) : (i64) -> !llvm.ptr
    %9 = llvm.mlir.constant(1 : index) : i64
    %10 = llvm.mlir.zero : !llvm.ptr
    %11 = llvm.getelementptr %10[%9] : (!llvm.ptr, i64) -> !llvm.ptr, i64
    %12 = llvm.ptrtoint %11 : !llvm.ptr to i64
    %13 = llvm.call @malloc(%12) : (i64) -> !llvm.ptr
    %14 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64)>
    %15 = llvm.insertvalue %13, %14[0] : !llvm.struct<(ptr, ptr, i64)> 
    %16 = llvm.insertvalue %13, %15[1] : !llvm.struct<(ptr, ptr, i64)> 
    %17 = llvm.mlir.constant(0 : index) : i64
    %18 = llvm.insertvalue %17, %16[2] : !llvm.struct<(ptr, ptr, i64)> 
    %19 = llvm.extractvalue %18[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @shmem_long_ctx_atomic_fetch_xor_nbi(%4, %19, %8, %7, %5) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i64, i32) -> ()
    llvm.call @shmem_ctx_destroy(%4) : (!llvm.ptr) -> ()
    %20 = llvm.extractvalue %18[0] : !llvm.struct<(ptr, ptr, i64)> 
    llvm.call @free(%20) : (!llvm.ptr) -> ()
    llvm.call @shmem_free(%8) : (!llvm.ptr) -> ()
    llvm.call @shmem_finalize() : () -> ()
    llvm.return
  }
}

