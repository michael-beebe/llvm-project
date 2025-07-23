; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

@SHMEM_TEAM_SHARED = external constant ptr
@SHMEM_TEAM_WORLD = external constant ptr

declare void @free(ptr)

declare ptr @malloc(i64)

declare void @shmem_free(ptr)

declare void @shmem_putmem(ptr, ptr, i64, i32)

declare ptr @shmem_malloc(i64)

declare void @shmem_finalize()

declare void @shmem_barrier_all()

declare void @shmem_team_destroy(ptr)

declare void @shmem_team_sync(ptr)

declare i32 @shmem_team_split_2d(ptr, i32, ptr, i64, ptr, ptr, i64, ptr)

declare i32 @shmem_team_split_strided(ptr, i32, i32, i32, ptr, i64, ptr)

declare i32 @shmem_team_n_pes(ptr)

declare i32 @shmem_team_my_pe(ptr)

declare i32 @shmem_n_pes()

declare i32 @shmem_my_pe()

declare void @shmem_init()

define void @test_teams() {
  call void @shmem_init()
  %1 = call i32 @shmem_my_pe()
  %2 = call i32 @shmem_n_pes()
  %3 = call i32 @shmem_team_my_pe(ptr @SHMEM_TEAM_WORLD)
  %4 = call i32 @shmem_team_n_pes(ptr @SHMEM_TEAM_WORLD)
  %5 = call i32 @shmem_team_my_pe(ptr @SHMEM_TEAM_SHARED)
  %6 = alloca ptr, align 8
  %7 = call i32 @shmem_team_split_strided(ptr @SHMEM_TEAM_WORLD, i32 0, i32 1, i32 2, ptr null, i64 0, ptr %6)
  %8 = load ptr, ptr %6, align 8
  %9 = alloca ptr, align 8
  %10 = alloca ptr, align 8
  %11 = call i32 @shmem_team_split_2d(ptr @SHMEM_TEAM_WORLD, i32 2, ptr null, i64 0, ptr %9, ptr null, i64 0, ptr %10)
  %12 = load ptr, ptr %9, align 8
  %13 = load ptr, ptr %10, align 8
  call void @shmem_team_sync(ptr %8)
  call void @shmem_team_sync(ptr %12)
  call void @shmem_team_sync(ptr %13)
  %14 = call i32 @shmem_team_my_pe(ptr %8)
  %15 = call i32 @shmem_team_n_pes(ptr %8)
  call void @shmem_team_destroy(ptr %8)
  call void @shmem_team_destroy(ptr %12)
  call void @shmem_team_destroy(ptr %13)
  call void @shmem_barrier_all()
  call void @shmem_finalize()
  ret void
}

define void @test_team_communication() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_team_split_strided(ptr @SHMEM_TEAM_WORLD, i32 0, i32 1, i32 2, ptr null, i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 40)
  %5 = call ptr @malloc(i64 40)
  %6 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %5, 0
  %7 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %6, ptr %5, 1
  %8 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %7, i64 0, 2
  %9 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %8, i64 10, 3, 0
  %10 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %9, i64 1, 4, 0
  call void @shmem_team_sync(ptr %3)
  %11 = call i32 @shmem_team_my_pe(ptr %3)
  %12 = call i32 @shmem_team_n_pes(ptr %3)
  %13 = icmp eq i32 %11, 0
  %14 = select i1 %13, i32 1, i32 0
  %15 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %10, 0
  call void @shmem_putmem(ptr %4, ptr %15, i64 40, i32 %14)
  call void @shmem_team_sync(ptr %3)
  %16 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %10, 0
  call void @free(ptr %16)
  call void @shmem_free(ptr %4)
  call void @shmem_team_destroy(ptr %3)
  call void @shmem_finalize()
  ret void
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
