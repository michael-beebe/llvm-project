; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

declare void @shmem_long_ctx_atomic_fetch_xor_nbi(ptr, ptr, ptr, i64, i32)

declare void @shmem_int_ctx_atomic_fetch_xor_nbi(ptr, ptr, ptr, i32, i32)

declare void @shmem_long_atomic_fetch_xor_nbi(ptr, ptr, i64, i32)

declare void @shmem_int_atomic_fetch_xor_nbi(ptr, ptr, i32, i32)

declare void @shmem_long_ctx_atomic_fetch_or_nbi(ptr, ptr, ptr, i64, i32)

declare void @shmem_int_ctx_atomic_fetch_or_nbi(ptr, ptr, ptr, i32, i32)

declare void @shmem_long_atomic_fetch_or_nbi(ptr, ptr, i64, i32)

declare void @shmem_int_atomic_fetch_or_nbi(ptr, ptr, i32, i32)

declare void @shmem_long_ctx_atomic_fetch_and_nbi(ptr, ptr, ptr, i64, i32)

declare void @shmem_int_ctx_atomic_fetch_and_nbi(ptr, ptr, ptr, i32, i32)

declare void @shmem_long_atomic_fetch_and_nbi(ptr, ptr, i64, i32)

declare void @shmem_int_atomic_fetch_and_nbi(ptr, ptr, i32, i32)

declare void @shmem_long_ctx_atomic_fetch_add_nbi(ptr, ptr, ptr, i64, i32)

declare void @shmem_int_ctx_atomic_fetch_add_nbi(ptr, ptr, ptr, i32, i32)

declare void @shmem_long_atomic_fetch_add_nbi(ptr, ptr, i64, i32)

declare void @shmem_int_atomic_fetch_add_nbi(ptr, ptr, i32, i32)

declare void @shmem_long_ctx_atomic_fetch_inc_nbi(ptr, ptr, ptr, i32)

declare void @shmem_int_ctx_atomic_fetch_inc_nbi(ptr, ptr, ptr, i32)

declare void @shmem_long_atomic_fetch_inc_nbi(ptr, ptr, i32)

declare void @shmem_int_atomic_fetch_inc_nbi(ptr, ptr, i32)

declare void @shmem_long_ctx_atomic_swap_nbi(ptr, ptr, ptr, i64, i32)

declare void @shmem_int_ctx_atomic_swap_nbi(ptr, ptr, ptr, i32, i32)

declare void @shmem_long_atomic_swap_nbi(ptr, ptr, i64, i32)

declare void @shmem_int_atomic_swap_nbi(ptr, ptr, i32, i32)

declare void @shmem_long_ctx_atomic_compare_swap_nbi(ptr, ptr, ptr, i64, i64, i32)

declare void @shmem_int_ctx_atomic_compare_swap_nbi(ptr, ptr, ptr, i32, i32, i32)

declare void @shmem_long_atomic_compare_swap_nbi(ptr, ptr, i64, i64, i32)

declare void @shmem_int_atomic_compare_swap_nbi(ptr, ptr, i32, i32, i32)

declare void @shmem_long_ctx_atomic_fetch_nbi(ptr, ptr, ptr, i32)

declare void @shmem_int_ctx_atomic_fetch_nbi(ptr, ptr, ptr, i32)

declare void @shmem_long_atomic_fetch_nbi(ptr, ptr, i32)

declare void @shmem_int_atomic_fetch_nbi(ptr, ptr, i32)

declare void @shmem_long_ctx_atomic_xor(ptr, ptr, i64, i32)

declare void @shmem_int_ctx_atomic_xor(ptr, ptr, i32, i32)

declare void @shmem_long_atomic_xor(ptr, i64, i32)

declare void @shmem_int_atomic_xor(ptr, i32, i32)

declare i64 @shmem_long_ctx_atomic_fetch_xor(ptr, ptr, i64, i32)

declare i32 @shmem_int_ctx_atomic_fetch_xor(ptr, ptr, i32, i32)

declare i64 @shmem_long_atomic_fetch_xor(ptr, i64, i32)

declare i32 @shmem_int_atomic_fetch_xor(ptr, i32, i32)

declare void @shmem_long_ctx_atomic_or(ptr, ptr, i64, i32)

declare void @shmem_int_ctx_atomic_or(ptr, ptr, i32, i32)

declare void @shmem_long_atomic_or(ptr, i64, i32)

declare void @shmem_int_atomic_or(ptr, i32, i32)

declare i64 @shmem_long_ctx_atomic_fetch_or(ptr, ptr, i64, i32)

declare i32 @shmem_int_ctx_atomic_fetch_or(ptr, ptr, i32, i32)

declare i64 @shmem_long_atomic_fetch_or(ptr, i64, i32)

declare i32 @shmem_int_atomic_fetch_or(ptr, i32, i32)

declare i64 @shmem_long_ctx_atomic_fetch_and(ptr, ptr, i64, i32)

declare i32 @shmem_int_ctx_atomic_fetch_and(ptr, ptr, i32, i32)

declare i64 @shmem_long_atomic_fetch_and(ptr, i64, i32)

declare i32 @shmem_int_atomic_fetch_and(ptr, i32, i32)

declare void @shmem_long_ctx_atomic_add(ptr, ptr, i64, i32)

declare void @shmem_int_ctx_atomic_add(ptr, ptr, i32, i32)

declare void @shmem_long_atomic_add(ptr, i64, i32)

declare void @shmem_int_atomic_add(ptr, i32, i32)

declare i64 @shmem_long_ctx_atomic_fetch_add(ptr, ptr, i64, i32)

declare i32 @shmem_int_ctx_atomic_fetch_add(ptr, ptr, i32, i32)

declare i64 @shmem_double_atomic_fetch_add(ptr, i64, i32)

declare i32 @shmem_float_atomic_fetch_add(ptr, i32, i32)

declare i64 @shmem_long_atomic_fetch_add(ptr, i64, i32)

declare i32 @shmem_int_atomic_fetch_add(ptr, i32, i32)

declare void @shmem_long_ctx_atomic_inc(ptr, ptr, i32)

declare void @shmem_int_ctx_atomic_inc(ptr, ptr, i32)

declare void @shmem_long_atomic_inc(ptr, i32)

declare void @shmem_int_atomic_inc(ptr, i32)

declare i64 @shmem_long_ctx_atomic_fetch_inc(ptr, ptr, i32)

declare i32 @shmem_int_ctx_atomic_fetch_inc(ptr, ptr, i32)

declare i64 @shmem_long_atomic_fetch_inc(ptr, i32)

declare i32 @shmem_int_atomic_fetch_inc(ptr, i32)

declare i64 @shmem_double_ctx_atomic_swap(ptr, ptr, i64, i32)

declare i32 @shmem_float_ctx_atomic_swap(ptr, ptr, i32, i32)

declare i64 @shmem_double_atomic_swap(ptr, i64, i32)

declare i32 @shmem_float_atomic_swap(ptr, i32, i32)

declare i64 @shmem_long_ctx_atomic_swap(ptr, ptr, i64, i32)

declare i32 @shmem_int_ctx_atomic_swap(ptr, ptr, i32, i32)

declare i64 @shmem_long_atomic_swap(ptr, i64, i32)

declare i32 @shmem_int_atomic_swap(ptr, i32, i32)

declare i64 @shmem_double_ctx_atomic_compare_swap(ptr, ptr, i64, i64, i32)

declare i32 @shmem_float_ctx_atomic_compare_swap(ptr, ptr, i32, i32, i32)

declare i64 @shmem_long_ctx_atomic_compare_swap(ptr, ptr, i64, i64, i32)

declare i32 @shmem_int_ctx_atomic_compare_swap(ptr, ptr, i32, i32, i32)

declare i64 @shmem_double_atomic_compare_swap(ptr, i64, i64, i32)

declare i32 @shmem_float_atomic_compare_swap(ptr, i32, i32, i32)

declare i64 @shmem_long_atomic_compare_swap(ptr, i64, i64, i32)

declare i32 @shmem_int_atomic_compare_swap(ptr, i32, i32, i32)

declare void @shmem_double_ctx_atomic_set(ptr, ptr, i64, i32)

declare void @shmem_float_ctx_atomic_set(ptr, ptr, i32, i32)

declare void @shmem_long_ctx_atomic_set(ptr, ptr, i64, i32)

declare void @shmem_int_ctx_atomic_set(ptr, ptr, i32, i32)

declare void @shmem_double_atomic_set(ptr, i64, i32)

declare void @shmem_float_atomic_set(ptr, i32, i32)

declare void @shmem_long_atomic_set(ptr, i64, i32)

declare void @shmem_int_atomic_set(ptr, i32, i32)

declare i64 @shmem_double_ctx_atomic_fetch(ptr, ptr, i32)

declare i32 @shmem_float_ctx_atomic_fetch(ptr, ptr, i32)

declare i64 @shmem_long_ctx_atomic_fetch(ptr, ptr, i32)

declare void @shmem_ctx_destroy(ptr)

declare i32 @shmem_int_ctx_atomic_fetch(ptr, ptr, i32)

declare i32 @shmem_ctx_create(i64, ptr)

declare i64 @shmem_double_atomic_fetch(ptr, i32)

declare i32 @shmem_float_atomic_fetch(ptr, i32)

declare i64 @shmem_long_atomic_fetch(ptr, i32)

declare void @shmem_finalize()

declare void @shmem_free(ptr)

declare i32 @shmem_int_atomic_fetch(ptr, i32)

declare ptr @shmem_malloc(i64)

declare void @shmem_init()

define void @test_i32_atomic_fetch() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = call i32 @shmem_int_atomic_fetch(ptr %1, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_fetch() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = call i64 @shmem_long_atomic_fetch(ptr %1, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_f32_atomic_fetch() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = call i32 @shmem_float_atomic_fetch(ptr %1, i32 1)
  %3 = bitcast i32 %2 to float
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_f64_atomic_fetch() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = call i64 @shmem_double_atomic_fetch(ptr %1, i32 1)
  %3 = bitcast i64 %2 to double
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i32_atomic_fetch() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 4)
  %5 = call i32 @shmem_int_ctx_atomic_fetch(ptr %3, ptr %4, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i64_atomic_fetch() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 8)
  %5 = call i64 @shmem_long_ctx_atomic_fetch(ptr %3, ptr %4, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_f32_atomic_fetch() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 4)
  %5 = call i32 @shmem_float_ctx_atomic_fetch(ptr %3, ptr %4, i32 1)
  %6 = bitcast i32 %5 to float
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_f64_atomic_fetch() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 8)
  %5 = call i64 @shmem_double_ctx_atomic_fetch(ptr %3, ptr %4, i32 1)
  %6 = bitcast i64 %5 to double
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_set() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  call void @shmem_int_atomic_set(ptr %1, i32 42, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_set() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  call void @shmem_long_atomic_set(ptr %1, i64 42, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_f32_atomic_set() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  call void @shmem_float_atomic_set(ptr %1, i32 1109917696, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_f64_atomic_set() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  call void @shmem_double_atomic_set(ptr %1, i64 4631107791820423168, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i32_atomic_set() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 4)
  call void @shmem_int_ctx_atomic_set(ptr %3, ptr %4, i32 42, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i64_atomic_set() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 8)
  call void @shmem_long_ctx_atomic_set(ptr %3, ptr %4, i64 42, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_f32_atomic_set() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 4)
  call void @shmem_float_ctx_atomic_set(ptr %3, ptr %4, i32 1109917696, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_f64_atomic_set() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 8)
  call void @shmem_double_ctx_atomic_set(ptr %3, ptr %4, i64 4631107791820423168, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_compare_swap() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = call i32 @shmem_int_atomic_compare_swap(ptr %1, i32 42, i32 43, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_compare_swap() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = call i64 @shmem_long_atomic_compare_swap(ptr %1, i64 42, i64 43, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_f32_atomic_compare_swap() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = call i32 @shmem_float_atomic_compare_swap(ptr %1, i32 1109917696, i32 1110179840, i32 1)
  %3 = bitcast i32 %2 to float
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_f64_atomic_compare_swap() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = call i64 @shmem_double_atomic_compare_swap(ptr %1, i64 4631107791820423168, i64 4631248529308778496, i32 1)
  %3 = bitcast i64 %2 to double
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i32_atomic_compare_swap() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 4)
  %5 = call i32 @shmem_int_ctx_atomic_compare_swap(ptr %3, ptr %4, i32 42, i32 43, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i64_atomic_compare_swap() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 8)
  %5 = call i64 @shmem_long_ctx_atomic_compare_swap(ptr %3, ptr %4, i64 42, i64 43, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_f32_atomic_compare_swap() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 4)
  %5 = call i32 @shmem_float_ctx_atomic_compare_swap(ptr %3, ptr %4, i32 1109917696, i32 1110179840, i32 1)
  %6 = bitcast i32 %5 to float
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_f64_atomic_compare_swap() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 8)
  %5 = call i64 @shmem_double_ctx_atomic_compare_swap(ptr %3, ptr %4, i64 4631107791820423168, i64 4631248529308778496, i32 1)
  %6 = bitcast i64 %5 to double
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_swap() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = call i32 @shmem_int_atomic_swap(ptr %1, i32 42, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_swap() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = call i64 @shmem_long_atomic_swap(ptr %1, i64 42, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i32_atomic_swap() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 4)
  %5 = call i32 @shmem_int_ctx_atomic_swap(ptr %3, ptr %4, i32 42, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i64_atomic_swap() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 8)
  %5 = call i64 @shmem_long_ctx_atomic_swap(ptr %3, ptr %4, i64 42, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_f32_atomic_swap() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = call i32 @shmem_float_atomic_swap(ptr %1, i32 1109917696, i32 1)
  %3 = bitcast i32 %2 to float
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_f64_atomic_swap() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = call i64 @shmem_double_atomic_swap(ptr %1, i64 4631107791820423168, i32 1)
  %3 = bitcast i64 %2 to double
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_f32_atomic_swap() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 4)
  %5 = call i32 @shmem_float_ctx_atomic_swap(ptr %3, ptr %4, i32 1109917696, i32 1)
  %6 = bitcast i32 %5 to float
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_f64_atomic_swap() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 8)
  %5 = call i64 @shmem_double_ctx_atomic_swap(ptr %3, ptr %4, i64 4631107791820423168, i32 1)
  %6 = bitcast i64 %5 to double
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_fetch_inc() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = call i32 @shmem_int_atomic_fetch_inc(ptr %1, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_fetch_inc() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = call i64 @shmem_long_atomic_fetch_inc(ptr %1, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i32_atomic_fetch_inc() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 4)
  %5 = call i32 @shmem_int_ctx_atomic_fetch_inc(ptr %3, ptr %4, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i64_atomic_fetch_inc() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 8)
  %5 = call i64 @shmem_long_ctx_atomic_fetch_inc(ptr %3, ptr %4, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_inc() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  call void @shmem_int_atomic_inc(ptr %1, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_inc() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  call void @shmem_long_atomic_inc(ptr %1, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i32_atomic_inc() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 4)
  call void @shmem_int_ctx_atomic_inc(ptr %3, ptr %4, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i64_atomic_inc() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 8)
  call void @shmem_long_ctx_atomic_inc(ptr %3, ptr %4, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_fetch_add() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = call i32 @shmem_int_atomic_fetch_add(ptr %1, i32 5, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_fetch_add() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = call i64 @shmem_long_atomic_fetch_add(ptr %1, i64 5, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_f32_atomic_fetch_add() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = call i32 @shmem_float_atomic_fetch_add(ptr %1, i32 1084227584, i32 1)
  %3 = bitcast i32 %2 to float
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_f64_atomic_fetch_add() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = call i64 @shmem_double_atomic_fetch_add(ptr %1, i64 4617315517961601024, i32 1)
  %3 = bitcast i64 %2 to double
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i32_atomic_fetch_add() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 4)
  %5 = call i32 @shmem_int_ctx_atomic_fetch_add(ptr %3, ptr %4, i32 5, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i64_atomic_fetch_add() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 8)
  %5 = call i64 @shmem_long_ctx_atomic_fetch_add(ptr %3, ptr %4, i64 5, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_add() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  call void @shmem_int_atomic_add(ptr %1, i32 5, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_add() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  call void @shmem_long_atomic_add(ptr %1, i64 5, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i32_atomic_add() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 4)
  call void @shmem_int_ctx_atomic_add(ptr %3, ptr %4, i32 5, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i64_atomic_add() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 8)
  call void @shmem_long_ctx_atomic_add(ptr %3, ptr %4, i64 5, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_fetch_and() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = call i32 @shmem_int_atomic_fetch_and(ptr %1, i32 255, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_fetch_and() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = call i64 @shmem_long_atomic_fetch_and(ptr %1, i64 255, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i32_atomic_fetch_and() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 4)
  %5 = call i32 @shmem_int_ctx_atomic_fetch_and(ptr %3, ptr %4, i32 255, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i64_atomic_fetch_and() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 8)
  %5 = call i64 @shmem_long_ctx_atomic_fetch_and(ptr %3, ptr %4, i64 255, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_fetch_or() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = call i32 @shmem_int_atomic_fetch_or(ptr %1, i32 128, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_fetch_or() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = call i64 @shmem_long_atomic_fetch_or(ptr %1, i64 128, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i32_atomic_fetch_or() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 4)
  %5 = call i32 @shmem_int_ctx_atomic_fetch_or(ptr %3, ptr %4, i32 128, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i64_atomic_fetch_or() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 8)
  %5 = call i64 @shmem_long_ctx_atomic_fetch_or(ptr %3, ptr %4, i64 128, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_or() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  call void @shmem_int_atomic_or(ptr %1, i32 128, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_or() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  call void @shmem_long_atomic_or(ptr %1, i64 128, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i32_atomic_or() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 4)
  call void @shmem_int_ctx_atomic_or(ptr %3, ptr %4, i32 128, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i64_atomic_or() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 8)
  call void @shmem_long_ctx_atomic_or(ptr %3, ptr %4, i64 128, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_fetch_xor() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = call i32 @shmem_int_atomic_fetch_xor(ptr %1, i32 85, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_fetch_xor() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = call i64 @shmem_long_atomic_fetch_xor(ptr %1, i64 85, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i32_atomic_fetch_xor() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 4)
  %5 = call i32 @shmem_int_ctx_atomic_fetch_xor(ptr %3, ptr %4, i32 85, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i64_atomic_fetch_xor() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 8)
  %5 = call i64 @shmem_long_ctx_atomic_fetch_xor(ptr %3, ptr %4, i64 85, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_xor() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  call void @shmem_int_atomic_xor(ptr %1, i32 85, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_xor() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  call void @shmem_long_atomic_xor(ptr %1, i64 85, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i32_atomic_xor() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 4)
  call void @shmem_int_ctx_atomic_xor(ptr %3, ptr %4, i32 85, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i64_atomic_xor() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 8)
  call void @shmem_long_ctx_atomic_xor(ptr %3, ptr %4, i64 85, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_fetch_nbi() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = alloca ptr, i64 4, align 8
  call void @shmem_int_atomic_fetch_nbi(ptr %2, ptr %1, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_fetch_nbi() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = alloca ptr, i64 4, align 8
  call void @shmem_long_atomic_fetch_nbi(ptr %2, ptr %1, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i32_atomic_fetch_nbi() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 4)
  %5 = alloca ptr, i64 4, align 8
  call void @shmem_int_ctx_atomic_fetch_nbi(ptr %3, ptr %5, ptr %4, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i64_atomic_fetch_nbi() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 8)
  %5 = alloca ptr, i64 4, align 8
  call void @shmem_long_ctx_atomic_fetch_nbi(ptr %3, ptr %5, ptr %4, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_compare_swap_nbi() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = alloca ptr, i64 4, align 8
  call void @shmem_int_atomic_compare_swap_nbi(ptr %2, ptr %1, i32 42, i32 43, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_compare_swap_nbi() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = alloca ptr, i64 4, align 8
  call void @shmem_long_atomic_compare_swap_nbi(ptr %2, ptr %1, i64 42, i64 43, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i32_atomic_compare_swap_nbi() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 4)
  %5 = alloca ptr, i64 4, align 8
  call void @shmem_int_ctx_atomic_compare_swap_nbi(ptr %3, ptr %5, ptr %4, i32 42, i32 43, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i64_atomic_compare_swap_nbi() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 8)
  %5 = alloca ptr, i64 4, align 8
  call void @shmem_long_ctx_atomic_compare_swap_nbi(ptr %3, ptr %5, ptr %4, i64 42, i64 43, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_swap_nbi() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = alloca ptr, i64 4, align 8
  call void @shmem_int_atomic_swap_nbi(ptr %2, ptr %1, i32 42, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_swap_nbi() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = alloca ptr, i64 4, align 8
  call void @shmem_long_atomic_swap_nbi(ptr %2, ptr %1, i64 42, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i32_atomic_swap_nbi() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 4)
  %5 = alloca ptr, i64 4, align 8
  call void @shmem_int_ctx_atomic_swap_nbi(ptr %3, ptr %5, ptr %4, i32 42, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i64_atomic_swap_nbi() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 8)
  %5 = alloca ptr, i64 4, align 8
  call void @shmem_long_ctx_atomic_swap_nbi(ptr %3, ptr %5, ptr %4, i64 42, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_fetch_inc_nbi() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = alloca ptr, i64 4, align 8
  call void @shmem_int_atomic_fetch_inc_nbi(ptr %2, ptr %1, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_fetch_inc_nbi() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = alloca ptr, i64 4, align 8
  call void @shmem_long_atomic_fetch_inc_nbi(ptr %2, ptr %1, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i32_atomic_fetch_inc_nbi() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 4)
  %5 = alloca ptr, i64 4, align 8
  call void @shmem_int_ctx_atomic_fetch_inc_nbi(ptr %3, ptr %5, ptr %4, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i64_atomic_fetch_inc_nbi() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 8)
  %5 = alloca ptr, i64 4, align 8
  call void @shmem_long_ctx_atomic_fetch_inc_nbi(ptr %3, ptr %5, ptr %4, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_fetch_add_nbi() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = alloca ptr, i64 4, align 8
  call void @shmem_int_atomic_fetch_add_nbi(ptr %2, ptr %1, i32 5, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_fetch_add_nbi() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = alloca ptr, i64 4, align 8
  call void @shmem_long_atomic_fetch_add_nbi(ptr %2, ptr %1, i64 5, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i32_atomic_fetch_add_nbi() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 4)
  %5 = alloca ptr, i64 4, align 8
  call void @shmem_int_ctx_atomic_fetch_add_nbi(ptr %3, ptr %5, ptr %4, i32 5, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i64_atomic_fetch_add_nbi() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 8)
  %5 = alloca ptr, i64 4, align 8
  call void @shmem_long_ctx_atomic_fetch_add_nbi(ptr %3, ptr %5, ptr %4, i64 5, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_fetch_and_nbi() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = alloca ptr, i64 4, align 8
  call void @shmem_int_atomic_fetch_and_nbi(ptr %2, ptr %1, i32 255, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_fetch_and_nbi() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = alloca ptr, i64 4, align 8
  call void @shmem_long_atomic_fetch_and_nbi(ptr %2, ptr %1, i64 255, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i32_atomic_fetch_and_nbi() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 4)
  %5 = alloca ptr, i64 4, align 8
  call void @shmem_int_ctx_atomic_fetch_and_nbi(ptr %3, ptr %5, ptr %4, i32 255, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i64_atomic_fetch_and_nbi() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 8)
  %5 = alloca ptr, i64 4, align 8
  call void @shmem_long_ctx_atomic_fetch_and_nbi(ptr %3, ptr %5, ptr %4, i64 255, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_fetch_or_nbi() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = alloca ptr, i64 4, align 8
  call void @shmem_int_atomic_fetch_or_nbi(ptr %2, ptr %1, i32 128, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_fetch_or_nbi() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = alloca ptr, i64 4, align 8
  call void @shmem_long_atomic_fetch_or_nbi(ptr %2, ptr %1, i64 128, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i32_atomic_fetch_or_nbi() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 4)
  %5 = alloca ptr, i64 4, align 8
  call void @shmem_int_ctx_atomic_fetch_or_nbi(ptr %3, ptr %5, ptr %4, i32 128, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i64_atomic_fetch_or_nbi() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 8)
  %5 = alloca ptr, i64 4, align 8
  call void @shmem_long_ctx_atomic_fetch_or_nbi(ptr %3, ptr %5, ptr %4, i64 128, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_fetch_xor_nbi() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = alloca ptr, i64 4, align 8
  call void @shmem_int_atomic_fetch_xor_nbi(ptr %2, ptr %1, i32 85, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_fetch_xor_nbi() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = alloca ptr, i64 4, align 8
  call void @shmem_long_atomic_fetch_xor_nbi(ptr %2, ptr %1, i64 85, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i32_atomic_fetch_xor_nbi() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 4)
  %5 = alloca ptr, i64 4, align 8
  call void @shmem_int_ctx_atomic_fetch_xor_nbi(ptr %3, ptr %5, ptr %4, i32 85, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_ctx_i64_atomic_fetch_xor_nbi() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 8)
  %5 = alloca ptr, i64 4, align 8
  call void @shmem_long_ctx_atomic_fetch_xor_nbi(ptr %3, ptr %5, ptr %4, i64 85, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
