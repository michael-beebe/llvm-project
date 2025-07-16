; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

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
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_f64_atomic_fetch() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 8)
  %2 = call i64 @shmem_atomic_fetch64(ptr %1, i32 1)
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
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_finalize()
  ret void
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
