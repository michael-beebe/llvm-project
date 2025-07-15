; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

@SHMEM_TEAM_WORLD = external constant ptr

declare i32 @shmem_fcollectmem(ptr, ptr, ptr, i64)

declare i32 @shmem_collectmem(ptr, ptr, ptr, i64)

declare i32 @shmem_broadcastmem(ptr, ptr, ptr, i64, i32)

declare i32 @shmem_alltoallsmem(ptr, ptr, ptr, i64, i64, i64)

declare void @shmem_finalize()

declare void @shmem_free(ptr)

declare i32 @shmem_alltoallmem(ptr, ptr, ptr, i64)

declare ptr @shmem_malloc(i64)

declare void @shmem_init()

define void @test_alltoallmem() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 40)
  %2 = call ptr @shmem_malloc(i64 40)
  %3 = call i32 @shmem_alltoallmem(ptr @SHMEM_TEAM_WORLD, ptr %1, ptr %2, i64 10)
  call void @shmem_free(ptr %1)
  call void @shmem_free(ptr %2)
  call void @shmem_finalize()
  ret void
}

define void @test_alltoallsmem() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 40)
  %2 = call ptr @shmem_malloc(i64 40)
  %3 = call i32 @shmem_alltoallsmem(ptr @SHMEM_TEAM_WORLD, ptr %1, ptr %2, i64 2, i64 2, i64 10)
  call void @shmem_free(ptr %1)
  call void @shmem_free(ptr %2)
  call void @shmem_finalize()
  ret void
}

define void @test_broadcastmem() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 40)
  %2 = call ptr @shmem_malloc(i64 40)
  %3 = call i32 @shmem_broadcastmem(ptr @SHMEM_TEAM_WORLD, ptr %1, ptr %2, i64 10, i32 0)
  call void @shmem_free(ptr %1)
  call void @shmem_free(ptr %2)
  call void @shmem_finalize()
  ret void
}

define void @test_collectmem() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 40)
  %2 = call ptr @shmem_malloc(i64 40)
  %3 = call i32 @shmem_collectmem(ptr @SHMEM_TEAM_WORLD, ptr %1, ptr %2, i64 10)
  call void @shmem_free(ptr %1)
  call void @shmem_free(ptr %2)
  call void @shmem_finalize()
  ret void
}

define void @test_fcollectmem() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 40)
  %2 = call ptr @shmem_malloc(i64 40)
  %3 = call i32 @shmem_fcollectmem(ptr @SHMEM_TEAM_WORLD, ptr %1, ptr %2, i64 10)
  call void @shmem_free(ptr %1)
  call void @shmem_free(ptr %2)
  call void @shmem_finalize()
  ret void
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
