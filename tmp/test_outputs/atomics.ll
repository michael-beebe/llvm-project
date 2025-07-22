; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

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

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
