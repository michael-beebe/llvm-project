; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

declare void @free(ptr)

declare ptr @malloc(i64)

declare void @shmem_ctx_atomic_fetch_xor_nbi64(ptr, ptr, ptr, i64, i32)

declare void @shmem_ctx_atomic_fetch_xor_nbi32(ptr, ptr, ptr, i32, i32)

declare void @shmem_atomic_fetch_xor_nbi64(ptr, ptr, i64, i32)

declare void @shmem_atomic_fetch_xor_nbi32(ptr, ptr, i32, i32)

declare void @shmem_ctx_atomic_fetch_or_nbi64(ptr, ptr, ptr, i64, i32)

declare void @shmem_ctx_atomic_fetch_or_nbi32(ptr, ptr, ptr, i32, i32)

declare void @shmem_atomic_fetch_or_nbi64(ptr, ptr, i64, i32)

declare void @shmem_atomic_fetch_or_nbi32(ptr, ptr, i32, i32)

declare void @shmem_ctx_atomic_fetch_and_nbi64(ptr, ptr, ptr, i64, i32)

declare void @shmem_ctx_atomic_fetch_and_nbi32(ptr, ptr, ptr, i32, i32)

declare void @shmem_atomic_fetch_and_nbi64(ptr, ptr, i64, i32)

declare void @shmem_atomic_fetch_and_nbi32(ptr, ptr, i32, i32)

declare void @shmem_ctx_atomic_fetch_add_nbi64(ptr, ptr, ptr, i64, i32)

declare void @shmem_ctx_atomic_fetch_add_nbi32(ptr, ptr, ptr, i32, i32)

declare void @shmem_atomic_fetch_add_nbi64(ptr, ptr, i64, i32)

declare void @shmem_atomic_fetch_add_nbi32(ptr, ptr, i32, i32)

declare void @shmem_ctx_atomic_fetch_inc_nbi64(ptr, ptr, ptr, i32)

declare void @shmem_ctx_atomic_fetch_inc_nbi32(ptr, ptr, ptr, i32)

declare void @shmem_atomic_fetch_inc_nbi64(ptr, ptr, i32)

declare void @shmem_atomic_fetch_inc_nbi32(ptr, ptr, i32)

declare void @shmem_ctx_atomic_swap_nbi64(ptr, ptr, ptr, i64, i32)

declare void @shmem_ctx_atomic_swap_nbi32(ptr, ptr, ptr, i32, i32)

declare void @shmem_atomic_swap_nbi64(ptr, ptr, i64, i32)

declare void @shmem_atomic_swap_nbi32(ptr, ptr, i32, i32)

declare void @shmem_ctx_atomic_compare_swap_nbi64(ptr, ptr, ptr, i64, i64, i32)

declare void @shmem_ctx_atomic_compare_swap_nbi32(ptr, ptr, ptr, i32, i32, i32)

declare void @shmem_atomic_compare_swap_nbi64(ptr, ptr, i64, i64, i32)

declare void @shmem_atomic_compare_swap_nbi32(ptr, ptr, i32, i32, i32)

declare void @shmem_ctx_atomic_fetch_nbi64(ptr, ptr, ptr, i32)

declare void @shmem_ctx_atomic_fetch_nbi32(ptr, ptr, ptr, i32)

declare void @shmem_atomic_fetch_nbi64(ptr, ptr, i32)

declare void @shmem_atomic_fetch_nbi32(ptr, ptr, i32)

declare void @shmem_ctx_atomic_xor64(ptr, ptr, i64, i32)

declare void @shmem_ctx_atomic_xor32(ptr, ptr, i32, i32)

declare void @shmem_atomic_xor64(ptr, i64, i32)

declare void @shmem_atomic_xor32(ptr, i32, i32)

declare i64 @shmem_ctx_atomic_fetch_xor64(ptr, ptr, i64, i32)

declare i32 @shmem_ctx_atomic_fetch_xor32(ptr, ptr, i32, i32)

declare i64 @shmem_atomic_fetch_xor64(ptr, i64, i32)

declare i32 @shmem_atomic_fetch_xor32(ptr, i32, i32)

declare void @shmem_ctx_atomic_or64(ptr, ptr, i64, i32)

declare void @shmem_ctx_atomic_or32(ptr, ptr, i32, i32)

declare void @shmem_atomic_or64(ptr, i64, i32)

declare void @shmem_atomic_or32(ptr, i32, i32)

declare i64 @shmem_ctx_atomic_fetch_or64(ptr, ptr, i64, i32)

declare i32 @shmem_ctx_atomic_fetch_or32(ptr, ptr, i32, i32)

declare i64 @shmem_atomic_fetch_or64(ptr, i64, i32)

declare i32 @shmem_atomic_fetch_or32(ptr, i32, i32)

declare i64 @shmem_ctx_atomic_fetch_and64(ptr, ptr, i64, i32)

declare i32 @shmem_ctx_atomic_fetch_and32(ptr, ptr, i32, i32)

declare i64 @shmem_atomic_fetch_and64(ptr, i64, i32)

declare i32 @shmem_atomic_fetch_and32(ptr, i32, i32)

declare void @shmem_ctx_atomic_add64(ptr, ptr, i64, i32)

declare void @shmem_ctx_atomic_add32(ptr, ptr, i32, i32)

declare void @shmem_atomic_add64(ptr, i64, i32)

declare void @shmem_atomic_add32(ptr, i32, i32)

declare i64 @shmem_ctx_atomic_fetch_add64(ptr, ptr, i64, i32)

declare i32 @shmem_ctx_atomic_fetch_add32(ptr, ptr, i32, i32)

declare i64 @shmem_atomic_fetch_add64(ptr, i64, i32)

declare i32 @shmem_atomic_fetch_add32(ptr, i32, i32)

declare void @shmem_ctx_atomic_inc64(ptr, ptr, i32)

declare void @shmem_ctx_atomic_inc32(ptr, ptr, i32)

declare void @shmem_atomic_inc64(ptr, i32)

declare void @shmem_atomic_inc32(ptr, i32)

declare i64 @shmem_ctx_atomic_fetch_inc64(ptr, ptr, i32)

declare i32 @shmem_ctx_atomic_fetch_inc32(ptr, ptr, i32)

declare i64 @shmem_atomic_fetch_inc64(ptr, i32)

declare i32 @shmem_atomic_fetch_inc32(ptr, i32)

declare i64 @shmem_ctx_atomic_swap64(ptr, ptr, i64, i32)

declare i32 @shmem_ctx_atomic_swap32(ptr, ptr, i32, i32)

declare i64 @shmem_atomic_swap64(ptr, i64, i32)

declare i32 @shmem_atomic_swap32(ptr, i32, i32)

declare i64 @shmem_ctx_atomic_compare_swap64(ptr, ptr, i64, i64, i32)

declare i32 @shmem_ctx_atomic_compare_swap32(ptr, ptr, i32, i32, i32)

declare i64 @shmem_atomic_compare_swap64(ptr, i64, i64, i32)

declare i32 @shmem_atomic_compare_swap32(ptr, i32, i32, i32)

declare void @shmem_ctx_atomic_set64(ptr, ptr, i64, i32)

declare void @shmem_ctx_atomic_set32(ptr, ptr, i32, i32)

declare void @shmem_atomic_set64(ptr, i64, i32)

declare void @shmem_atomic_set32(ptr, i32, i32)

declare i64 @shmem_ctx_atomic_fetch64(ptr, ptr, i32)

declare void @shmem_ctx_destroy(ptr)

declare i32 @shmem_ctx_atomic_fetch32(ptr, ptr, i32)

declare i32 @shmem_ctx_create(i64, ptr)

declare i64 @shmem_atomic_fetch64(ptr, i32)

declare void @shmem_finalize()

declare void @shmem_free(ptr)

declare i32 @shmem_atomic_fetch32(ptr, i32)

declare ptr @shmem_malloc(i64)

declare void @shmem_init()

define void @test_i32_atomic_fetch() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = call i32 @shmem_atomic_fetch32(ptr %1, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_fetch() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = call i64 @shmem_atomic_fetch64(ptr %1, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_f32_atomic_fetch() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = call i32 @shmem_atomic_fetch32(ptr %1, i32 1)
  %3 = bitcast i32 %2 to float
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_f64_atomic_fetch() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = call i64 @shmem_atomic_fetch64(ptr %1, i32 1)
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
  %5 = call i32 @shmem_ctx_atomic_fetch32(ptr %3, ptr %4, i32 1)
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
  %5 = call i64 @shmem_ctx_atomic_fetch64(ptr %3, ptr %4, i32 1)
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
  %5 = call i32 @shmem_ctx_atomic_fetch32(ptr %3, ptr %4, i32 1)
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
  %5 = call i64 @shmem_ctx_atomic_fetch64(ptr %3, ptr %4, i32 1)
  %6 = bitcast i64 %5 to double
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_set() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  call void @shmem_atomic_set32(ptr %1, i32 42, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_set() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  call void @shmem_atomic_set64(ptr %1, i64 42, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_f32_atomic_set() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  call void @shmem_atomic_set32(ptr %1, i32 1109917696, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_f64_atomic_set() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  call void @shmem_atomic_set64(ptr %1, i64 4631107791820423168, i32 1)
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
  call void @shmem_ctx_atomic_set32(ptr %3, ptr %4, i32 42, i32 1)
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
  call void @shmem_ctx_atomic_set64(ptr %3, ptr %4, i64 42, i32 1)
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
  call void @shmem_ctx_atomic_set32(ptr %3, ptr %4, i32 1109917696, i32 1)
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
  call void @shmem_ctx_atomic_set64(ptr %3, ptr %4, i64 4631107791820423168, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_compare_swap() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = call i32 @shmem_atomic_compare_swap32(ptr %1, i32 42, i32 43, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_compare_swap() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = call i64 @shmem_atomic_compare_swap64(ptr %1, i64 42, i64 43, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_f32_atomic_compare_swap() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = call i32 @shmem_atomic_compare_swap32(ptr %1, i32 1109917696, i32 1110179840, i32 1)
  %3 = bitcast i32 %2 to float
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_f64_atomic_compare_swap() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = call i64 @shmem_atomic_compare_swap64(ptr %1, i64 4631107791820423168, i64 4631248529308778496, i32 1)
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
  %5 = call i32 @shmem_ctx_atomic_compare_swap32(ptr %3, ptr %4, i32 42, i32 43, i32 1)
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
  %5 = call i64 @shmem_ctx_atomic_compare_swap64(ptr %3, ptr %4, i64 42, i64 43, i32 1)
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
  %5 = call i32 @shmem_ctx_atomic_compare_swap32(ptr %3, ptr %4, i32 1109917696, i32 1110179840, i32 1)
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
  %5 = call i64 @shmem_ctx_atomic_compare_swap64(ptr %3, ptr %4, i64 4631107791820423168, i64 4631248529308778496, i32 1)
  %6 = bitcast i64 %5 to double
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_swap() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = call i32 @shmem_atomic_swap32(ptr %1, i32 42, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_swap() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = call i64 @shmem_atomic_swap64(ptr %1, i64 42, i32 1)
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
  %5 = call i32 @shmem_ctx_atomic_swap32(ptr %3, ptr %4, i32 42, i32 1)
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
  %5 = call i64 @shmem_ctx_atomic_swap64(ptr %3, ptr %4, i64 42, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_f32_atomic_swap() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = call i32 @shmem_atomic_swap32(ptr %1, i32 1109917696, i32 1)
  %3 = bitcast i32 %2 to float
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_f64_atomic_swap() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = call i64 @shmem_atomic_swap64(ptr %1, i64 4631107791820423168, i32 1)
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
  %5 = call i32 @shmem_ctx_atomic_swap32(ptr %3, ptr %4, i32 1109917696, i32 1)
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
  %5 = call i64 @shmem_ctx_atomic_swap64(ptr %3, ptr %4, i64 4631107791820423168, i32 1)
  %6 = bitcast i64 %5 to double
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_fetch_inc() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = call i32 @shmem_atomic_fetch_inc32(ptr %1, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_fetch_inc() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = call i64 @shmem_atomic_fetch_inc64(ptr %1, i32 1)
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
  %5 = call i32 @shmem_ctx_atomic_fetch_inc32(ptr %3, ptr %4, i32 1)
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
  %5 = call i64 @shmem_ctx_atomic_fetch_inc64(ptr %3, ptr %4, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_inc() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  call void @shmem_atomic_inc32(ptr %1, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_inc() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  call void @shmem_atomic_inc64(ptr %1, i32 1)
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
  call void @shmem_ctx_atomic_inc32(ptr %3, ptr %4, i32 1)
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
  call void @shmem_ctx_atomic_inc64(ptr %3, ptr %4, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_fetch_add() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = call i32 @shmem_atomic_fetch_add32(ptr %1, i32 5, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_fetch_add() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = call i64 @shmem_atomic_fetch_add64(ptr %1, i64 5, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_f32_atomic_fetch_add() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = call i32 @shmem_atomic_fetch_add32(ptr %1, i32 1084227584, i32 1)
  %3 = bitcast i32 %2 to float
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_f64_atomic_fetch_add() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = call i64 @shmem_atomic_fetch_add64(ptr %1, i64 4617315517961601024, i32 1)
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
  %5 = call i32 @shmem_ctx_atomic_fetch_add32(ptr %3, ptr %4, i32 5, i32 1)
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
  %5 = call i64 @shmem_ctx_atomic_fetch_add64(ptr %3, ptr %4, i64 5, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_add() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  call void @shmem_atomic_add32(ptr %1, i32 5, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_add() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  call void @shmem_atomic_add64(ptr %1, i64 5, i32 1)
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
  call void @shmem_ctx_atomic_add32(ptr %3, ptr %4, i32 5, i32 1)
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
  call void @shmem_ctx_atomic_add64(ptr %3, ptr %4, i64 5, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_fetch_and() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = call i32 @shmem_atomic_fetch_and32(ptr %1, i32 255, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_fetch_and() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = call i64 @shmem_atomic_fetch_and64(ptr %1, i64 255, i32 1)
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
  %5 = call i32 @shmem_ctx_atomic_fetch_and32(ptr %3, ptr %4, i32 255, i32 1)
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
  %5 = call i64 @shmem_ctx_atomic_fetch_and64(ptr %3, ptr %4, i64 255, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_fetch_or() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = call i32 @shmem_atomic_fetch_or32(ptr %1, i32 128, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_fetch_or() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = call i64 @shmem_atomic_fetch_or64(ptr %1, i64 128, i32 1)
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
  %5 = call i32 @shmem_ctx_atomic_fetch_or32(ptr %3, ptr %4, i32 128, i32 1)
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
  %5 = call i64 @shmem_ctx_atomic_fetch_or64(ptr %3, ptr %4, i64 128, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_or() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  call void @shmem_atomic_or32(ptr %1, i32 128, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_or() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  call void @shmem_atomic_or64(ptr %1, i64 128, i32 1)
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
  call void @shmem_ctx_atomic_or32(ptr %3, ptr %4, i32 128, i32 1)
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
  call void @shmem_ctx_atomic_or64(ptr %3, ptr %4, i64 128, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_fetch_xor() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = call i32 @shmem_atomic_fetch_xor32(ptr %1, i32 85, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_fetch_xor() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = call i64 @shmem_atomic_fetch_xor64(ptr %1, i64 85, i32 1)
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
  %5 = call i32 @shmem_ctx_atomic_fetch_xor32(ptr %3, ptr %4, i32 85, i32 1)
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
  %5 = call i64 @shmem_ctx_atomic_fetch_xor64(ptr %3, ptr %4, i64 85, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_xor() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  call void @shmem_atomic_xor32(ptr %1, i32 85, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_xor() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  call void @shmem_atomic_xor64(ptr %1, i64 85, i32 1)
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
  call void @shmem_ctx_atomic_xor32(ptr %3, ptr %4, i32 85, i32 1)
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
  call void @shmem_ctx_atomic_xor64(ptr %3, ptr %4, i64 85, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_fetch_nbi() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = call ptr @malloc(i64 4)
  %3 = insertvalue { ptr, ptr, i64 } poison, ptr %2, 0
  %4 = insertvalue { ptr, ptr, i64 } %3, ptr %2, 1
  %5 = insertvalue { ptr, ptr, i64 } %4, i64 0, 2
  %6 = extractvalue { ptr, ptr, i64 } %5, 0
  call void @shmem_atomic_fetch_nbi32(ptr %6, ptr %1, i32 1)
  %7 = extractvalue { ptr, ptr, i64 } %5, 0
  call void @free(ptr %7)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_fetch_nbi() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = call ptr @malloc(i64 8)
  %3 = insertvalue { ptr, ptr, i64 } poison, ptr %2, 0
  %4 = insertvalue { ptr, ptr, i64 } %3, ptr %2, 1
  %5 = insertvalue { ptr, ptr, i64 } %4, i64 0, 2
  %6 = extractvalue { ptr, ptr, i64 } %5, 0
  call void @shmem_atomic_fetch_nbi64(ptr %6, ptr %1, i32 1)
  %7 = extractvalue { ptr, ptr, i64 } %5, 0
  call void @free(ptr %7)
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
  %5 = call ptr @malloc(i64 4)
  %6 = insertvalue { ptr, ptr, i64 } poison, ptr %5, 0
  %7 = insertvalue { ptr, ptr, i64 } %6, ptr %5, 1
  %8 = insertvalue { ptr, ptr, i64 } %7, i64 0, 2
  %9 = extractvalue { ptr, ptr, i64 } %8, 0
  call void @shmem_ctx_atomic_fetch_nbi32(ptr %3, ptr %9, ptr %4, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  %10 = extractvalue { ptr, ptr, i64 } %8, 0
  call void @free(ptr %10)
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
  %5 = call ptr @malloc(i64 8)
  %6 = insertvalue { ptr, ptr, i64 } poison, ptr %5, 0
  %7 = insertvalue { ptr, ptr, i64 } %6, ptr %5, 1
  %8 = insertvalue { ptr, ptr, i64 } %7, i64 0, 2
  %9 = extractvalue { ptr, ptr, i64 } %8, 0
  call void @shmem_ctx_atomic_fetch_nbi64(ptr %3, ptr %9, ptr %4, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  %10 = extractvalue { ptr, ptr, i64 } %8, 0
  call void @free(ptr %10)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_compare_swap_nbi() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = call ptr @malloc(i64 4)
  %3 = insertvalue { ptr, ptr, i64 } poison, ptr %2, 0
  %4 = insertvalue { ptr, ptr, i64 } %3, ptr %2, 1
  %5 = insertvalue { ptr, ptr, i64 } %4, i64 0, 2
  %6 = extractvalue { ptr, ptr, i64 } %5, 0
  call void @shmem_atomic_compare_swap_nbi32(ptr %6, ptr %1, i32 42, i32 43, i32 1)
  %7 = extractvalue { ptr, ptr, i64 } %5, 0
  call void @free(ptr %7)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_compare_swap_nbi() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = call ptr @malloc(i64 8)
  %3 = insertvalue { ptr, ptr, i64 } poison, ptr %2, 0
  %4 = insertvalue { ptr, ptr, i64 } %3, ptr %2, 1
  %5 = insertvalue { ptr, ptr, i64 } %4, i64 0, 2
  %6 = extractvalue { ptr, ptr, i64 } %5, 0
  call void @shmem_atomic_compare_swap_nbi64(ptr %6, ptr %1, i64 42, i64 43, i32 1)
  %7 = extractvalue { ptr, ptr, i64 } %5, 0
  call void @free(ptr %7)
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
  %5 = call ptr @malloc(i64 4)
  %6 = insertvalue { ptr, ptr, i64 } poison, ptr %5, 0
  %7 = insertvalue { ptr, ptr, i64 } %6, ptr %5, 1
  %8 = insertvalue { ptr, ptr, i64 } %7, i64 0, 2
  %9 = extractvalue { ptr, ptr, i64 } %8, 0
  call void @shmem_ctx_atomic_compare_swap_nbi32(ptr %3, ptr %9, ptr %4, i32 42, i32 43, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  %10 = extractvalue { ptr, ptr, i64 } %8, 0
  call void @free(ptr %10)
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
  %5 = call ptr @malloc(i64 8)
  %6 = insertvalue { ptr, ptr, i64 } poison, ptr %5, 0
  %7 = insertvalue { ptr, ptr, i64 } %6, ptr %5, 1
  %8 = insertvalue { ptr, ptr, i64 } %7, i64 0, 2
  %9 = extractvalue { ptr, ptr, i64 } %8, 0
  call void @shmem_ctx_atomic_compare_swap_nbi64(ptr %3, ptr %9, ptr %4, i64 42, i64 43, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  %10 = extractvalue { ptr, ptr, i64 } %8, 0
  call void @free(ptr %10)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_swap_nbi() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = call ptr @malloc(i64 4)
  %3 = insertvalue { ptr, ptr, i64 } poison, ptr %2, 0
  %4 = insertvalue { ptr, ptr, i64 } %3, ptr %2, 1
  %5 = insertvalue { ptr, ptr, i64 } %4, i64 0, 2
  %6 = extractvalue { ptr, ptr, i64 } %5, 0
  call void @shmem_atomic_swap_nbi32(ptr %6, ptr %1, i32 42, i32 1)
  %7 = extractvalue { ptr, ptr, i64 } %5, 0
  call void @free(ptr %7)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_swap_nbi() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = call ptr @malloc(i64 8)
  %3 = insertvalue { ptr, ptr, i64 } poison, ptr %2, 0
  %4 = insertvalue { ptr, ptr, i64 } %3, ptr %2, 1
  %5 = insertvalue { ptr, ptr, i64 } %4, i64 0, 2
  %6 = extractvalue { ptr, ptr, i64 } %5, 0
  call void @shmem_atomic_swap_nbi64(ptr %6, ptr %1, i64 42, i32 1)
  %7 = extractvalue { ptr, ptr, i64 } %5, 0
  call void @free(ptr %7)
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
  %5 = call ptr @malloc(i64 4)
  %6 = insertvalue { ptr, ptr, i64 } poison, ptr %5, 0
  %7 = insertvalue { ptr, ptr, i64 } %6, ptr %5, 1
  %8 = insertvalue { ptr, ptr, i64 } %7, i64 0, 2
  %9 = extractvalue { ptr, ptr, i64 } %8, 0
  call void @shmem_ctx_atomic_swap_nbi32(ptr %3, ptr %9, ptr %4, i32 42, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  %10 = extractvalue { ptr, ptr, i64 } %8, 0
  call void @free(ptr %10)
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
  %5 = call ptr @malloc(i64 8)
  %6 = insertvalue { ptr, ptr, i64 } poison, ptr %5, 0
  %7 = insertvalue { ptr, ptr, i64 } %6, ptr %5, 1
  %8 = insertvalue { ptr, ptr, i64 } %7, i64 0, 2
  %9 = extractvalue { ptr, ptr, i64 } %8, 0
  call void @shmem_ctx_atomic_swap_nbi64(ptr %3, ptr %9, ptr %4, i64 42, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  %10 = extractvalue { ptr, ptr, i64 } %8, 0
  call void @free(ptr %10)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_fetch_inc_nbi() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = call ptr @malloc(i64 4)
  %3 = insertvalue { ptr, ptr, i64 } poison, ptr %2, 0
  %4 = insertvalue { ptr, ptr, i64 } %3, ptr %2, 1
  %5 = insertvalue { ptr, ptr, i64 } %4, i64 0, 2
  %6 = extractvalue { ptr, ptr, i64 } %5, 0
  call void @shmem_atomic_fetch_inc_nbi32(ptr %6, ptr %1, i32 1)
  %7 = extractvalue { ptr, ptr, i64 } %5, 0
  call void @free(ptr %7)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_fetch_inc_nbi() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = call ptr @malloc(i64 8)
  %3 = insertvalue { ptr, ptr, i64 } poison, ptr %2, 0
  %4 = insertvalue { ptr, ptr, i64 } %3, ptr %2, 1
  %5 = insertvalue { ptr, ptr, i64 } %4, i64 0, 2
  %6 = extractvalue { ptr, ptr, i64 } %5, 0
  call void @shmem_atomic_fetch_inc_nbi64(ptr %6, ptr %1, i32 1)
  %7 = extractvalue { ptr, ptr, i64 } %5, 0
  call void @free(ptr %7)
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
  %5 = call ptr @malloc(i64 4)
  %6 = insertvalue { ptr, ptr, i64 } poison, ptr %5, 0
  %7 = insertvalue { ptr, ptr, i64 } %6, ptr %5, 1
  %8 = insertvalue { ptr, ptr, i64 } %7, i64 0, 2
  %9 = extractvalue { ptr, ptr, i64 } %8, 0
  call void @shmem_ctx_atomic_fetch_inc_nbi32(ptr %3, ptr %9, ptr %4, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  %10 = extractvalue { ptr, ptr, i64 } %8, 0
  call void @free(ptr %10)
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
  %5 = call ptr @malloc(i64 8)
  %6 = insertvalue { ptr, ptr, i64 } poison, ptr %5, 0
  %7 = insertvalue { ptr, ptr, i64 } %6, ptr %5, 1
  %8 = insertvalue { ptr, ptr, i64 } %7, i64 0, 2
  %9 = extractvalue { ptr, ptr, i64 } %8, 0
  call void @shmem_ctx_atomic_fetch_inc_nbi64(ptr %3, ptr %9, ptr %4, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  %10 = extractvalue { ptr, ptr, i64 } %8, 0
  call void @free(ptr %10)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_fetch_add_nbi() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = call ptr @malloc(i64 4)
  %3 = insertvalue { ptr, ptr, i64 } poison, ptr %2, 0
  %4 = insertvalue { ptr, ptr, i64 } %3, ptr %2, 1
  %5 = insertvalue { ptr, ptr, i64 } %4, i64 0, 2
  %6 = extractvalue { ptr, ptr, i64 } %5, 0
  call void @shmem_atomic_fetch_add_nbi32(ptr %6, ptr %1, i32 5, i32 1)
  %7 = extractvalue { ptr, ptr, i64 } %5, 0
  call void @free(ptr %7)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_fetch_add_nbi() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = call ptr @malloc(i64 8)
  %3 = insertvalue { ptr, ptr, i64 } poison, ptr %2, 0
  %4 = insertvalue { ptr, ptr, i64 } %3, ptr %2, 1
  %5 = insertvalue { ptr, ptr, i64 } %4, i64 0, 2
  %6 = extractvalue { ptr, ptr, i64 } %5, 0
  call void @shmem_atomic_fetch_add_nbi64(ptr %6, ptr %1, i64 5, i32 1)
  %7 = extractvalue { ptr, ptr, i64 } %5, 0
  call void @free(ptr %7)
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
  %5 = call ptr @malloc(i64 4)
  %6 = insertvalue { ptr, ptr, i64 } poison, ptr %5, 0
  %7 = insertvalue { ptr, ptr, i64 } %6, ptr %5, 1
  %8 = insertvalue { ptr, ptr, i64 } %7, i64 0, 2
  %9 = extractvalue { ptr, ptr, i64 } %8, 0
  call void @shmem_ctx_atomic_fetch_add_nbi32(ptr %3, ptr %9, ptr %4, i32 5, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  %10 = extractvalue { ptr, ptr, i64 } %8, 0
  call void @free(ptr %10)
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
  %5 = call ptr @malloc(i64 8)
  %6 = insertvalue { ptr, ptr, i64 } poison, ptr %5, 0
  %7 = insertvalue { ptr, ptr, i64 } %6, ptr %5, 1
  %8 = insertvalue { ptr, ptr, i64 } %7, i64 0, 2
  %9 = extractvalue { ptr, ptr, i64 } %8, 0
  call void @shmem_ctx_atomic_fetch_add_nbi64(ptr %3, ptr %9, ptr %4, i64 5, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  %10 = extractvalue { ptr, ptr, i64 } %8, 0
  call void @free(ptr %10)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_fetch_and_nbi() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = call ptr @malloc(i64 4)
  %3 = insertvalue { ptr, ptr, i64 } poison, ptr %2, 0
  %4 = insertvalue { ptr, ptr, i64 } %3, ptr %2, 1
  %5 = insertvalue { ptr, ptr, i64 } %4, i64 0, 2
  %6 = extractvalue { ptr, ptr, i64 } %5, 0
  call void @shmem_atomic_fetch_and_nbi32(ptr %6, ptr %1, i32 255, i32 1)
  %7 = extractvalue { ptr, ptr, i64 } %5, 0
  call void @free(ptr %7)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_fetch_and_nbi() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = call ptr @malloc(i64 8)
  %3 = insertvalue { ptr, ptr, i64 } poison, ptr %2, 0
  %4 = insertvalue { ptr, ptr, i64 } %3, ptr %2, 1
  %5 = insertvalue { ptr, ptr, i64 } %4, i64 0, 2
  %6 = extractvalue { ptr, ptr, i64 } %5, 0
  call void @shmem_atomic_fetch_and_nbi64(ptr %6, ptr %1, i64 255, i32 1)
  %7 = extractvalue { ptr, ptr, i64 } %5, 0
  call void @free(ptr %7)
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
  %5 = call ptr @malloc(i64 4)
  %6 = insertvalue { ptr, ptr, i64 } poison, ptr %5, 0
  %7 = insertvalue { ptr, ptr, i64 } %6, ptr %5, 1
  %8 = insertvalue { ptr, ptr, i64 } %7, i64 0, 2
  %9 = extractvalue { ptr, ptr, i64 } %8, 0
  call void @shmem_ctx_atomic_fetch_and_nbi32(ptr %3, ptr %9, ptr %4, i32 255, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  %10 = extractvalue { ptr, ptr, i64 } %8, 0
  call void @free(ptr %10)
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
  %5 = call ptr @malloc(i64 8)
  %6 = insertvalue { ptr, ptr, i64 } poison, ptr %5, 0
  %7 = insertvalue { ptr, ptr, i64 } %6, ptr %5, 1
  %8 = insertvalue { ptr, ptr, i64 } %7, i64 0, 2
  %9 = extractvalue { ptr, ptr, i64 } %8, 0
  call void @shmem_ctx_atomic_fetch_and_nbi64(ptr %3, ptr %9, ptr %4, i64 255, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  %10 = extractvalue { ptr, ptr, i64 } %8, 0
  call void @free(ptr %10)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_fetch_or_nbi() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = call ptr @malloc(i64 4)
  %3 = insertvalue { ptr, ptr, i64 } poison, ptr %2, 0
  %4 = insertvalue { ptr, ptr, i64 } %3, ptr %2, 1
  %5 = insertvalue { ptr, ptr, i64 } %4, i64 0, 2
  %6 = extractvalue { ptr, ptr, i64 } %5, 0
  call void @shmem_atomic_fetch_or_nbi32(ptr %6, ptr %1, i32 128, i32 1)
  %7 = extractvalue { ptr, ptr, i64 } %5, 0
  call void @free(ptr %7)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_fetch_or_nbi() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = call ptr @malloc(i64 8)
  %3 = insertvalue { ptr, ptr, i64 } poison, ptr %2, 0
  %4 = insertvalue { ptr, ptr, i64 } %3, ptr %2, 1
  %5 = insertvalue { ptr, ptr, i64 } %4, i64 0, 2
  %6 = extractvalue { ptr, ptr, i64 } %5, 0
  call void @shmem_atomic_fetch_or_nbi64(ptr %6, ptr %1, i64 128, i32 1)
  %7 = extractvalue { ptr, ptr, i64 } %5, 0
  call void @free(ptr %7)
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
  %5 = call ptr @malloc(i64 4)
  %6 = insertvalue { ptr, ptr, i64 } poison, ptr %5, 0
  %7 = insertvalue { ptr, ptr, i64 } %6, ptr %5, 1
  %8 = insertvalue { ptr, ptr, i64 } %7, i64 0, 2
  %9 = extractvalue { ptr, ptr, i64 } %8, 0
  call void @shmem_ctx_atomic_fetch_or_nbi32(ptr %3, ptr %9, ptr %4, i32 128, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  %10 = extractvalue { ptr, ptr, i64 } %8, 0
  call void @free(ptr %10)
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
  %5 = call ptr @malloc(i64 8)
  %6 = insertvalue { ptr, ptr, i64 } poison, ptr %5, 0
  %7 = insertvalue { ptr, ptr, i64 } %6, ptr %5, 1
  %8 = insertvalue { ptr, ptr, i64 } %7, i64 0, 2
  %9 = extractvalue { ptr, ptr, i64 } %8, 0
  call void @shmem_ctx_atomic_fetch_or_nbi64(ptr %3, ptr %9, ptr %4, i64 128, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  %10 = extractvalue { ptr, ptr, i64 } %8, 0
  call void @free(ptr %10)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

define void @test_i32_atomic_fetch_xor_nbi() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  %2 = call ptr @malloc(i64 4)
  %3 = insertvalue { ptr, ptr, i64 } poison, ptr %2, 0
  %4 = insertvalue { ptr, ptr, i64 } %3, ptr %2, 1
  %5 = insertvalue { ptr, ptr, i64 } %4, i64 0, 2
  %6 = extractvalue { ptr, ptr, i64 } %5, 0
  call void @shmem_atomic_fetch_xor_nbi32(ptr %6, ptr %1, i32 85, i32 1)
  %7 = extractvalue { ptr, ptr, i64 } %5, 0
  call void @free(ptr %7)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_i64_atomic_fetch_xor_nbi() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = call ptr @malloc(i64 8)
  %3 = insertvalue { ptr, ptr, i64 } poison, ptr %2, 0
  %4 = insertvalue { ptr, ptr, i64 } %3, ptr %2, 1
  %5 = insertvalue { ptr, ptr, i64 } %4, i64 0, 2
  %6 = extractvalue { ptr, ptr, i64 } %5, 0
  call void @shmem_atomic_fetch_xor_nbi64(ptr %6, ptr %1, i64 85, i32 1)
  %7 = extractvalue { ptr, ptr, i64 } %5, 0
  call void @free(ptr %7)
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
  %5 = call ptr @malloc(i64 4)
  %6 = insertvalue { ptr, ptr, i64 } poison, ptr %5, 0
  %7 = insertvalue { ptr, ptr, i64 } %6, ptr %5, 1
  %8 = insertvalue { ptr, ptr, i64 } %7, i64 0, 2
  %9 = extractvalue { ptr, ptr, i64 } %8, 0
  call void @shmem_ctx_atomic_fetch_xor_nbi32(ptr %3, ptr %9, ptr %4, i32 85, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  %10 = extractvalue { ptr, ptr, i64 } %8, 0
  call void @free(ptr %10)
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
  %5 = call ptr @malloc(i64 8)
  %6 = insertvalue { ptr, ptr, i64 } poison, ptr %5, 0
  %7 = insertvalue { ptr, ptr, i64 } %6, ptr %5, 1
  %8 = insertvalue { ptr, ptr, i64 } %7, i64 0, 2
  %9 = extractvalue { ptr, ptr, i64 } %8, 0
  call void @shmem_ctx_atomic_fetch_xor_nbi64(ptr %3, ptr %9, ptr %4, i64 85, i32 1)
  call void @shmem_ctx_destroy(ptr %3)
  %10 = extractvalue { ptr, ptr, i64 } %8, 0
  call void @free(ptr %10)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
