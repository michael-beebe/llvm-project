; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

@SHMEM_TEAM_WORLD = external constant ptr

declare void @shmem_ctx_destroy(ptr)

declare i32 @shmem_ctx_get_team(ptr, ptr)

declare i32 @shmem_team_create_ctx(ptr, i64, ptr)

declare i32 @shmem_ctx_create(i64, ptr)

declare void @shmem_finalize()

declare void @shmem_init()

define void @test_context_ops() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_ctx_create(i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = alloca ptr, align 8
  %5 = call i32 @shmem_team_create_ctx(ptr @SHMEM_TEAM_WORLD, i64 0, ptr %4)
  %6 = load ptr, ptr %4, align 8
  %7 = alloca ptr, align 8
  %8 = call i32 @shmem_ctx_get_team(ptr %6, ptr %7)
  %9 = load ptr, ptr %7, align 8
  call void @shmem_ctx_destroy(ptr %3)
  call void @shmem_ctx_destroy(ptr %6)
  call void @shmem_finalize()
  ret void
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
