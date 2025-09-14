; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

@SHMEM_TEAM_SHARED = external constant ptr
@SHMEM_TEAM_WORLD = external constant ptr

declare i32 @shmem_g(ptr, i32)

declare void @shmem_p(ptr, i32, i32)

declare void @shmem_put32(ptr, ptr, i64, i32)

declare void @shmem_free(ptr)

declare void @shmem_putmem(ptr, ptr, i64, i32)

declare ptr @shmem_malloc(i64)

declare void @shmem_barrier_all()

declare void @shmem_team_destroy(ptr)

declare void @shmem_team_sync(ptr)

declare i32 @shmem_team_split_2d(ptr, i32, ptr, i64, ptr, ptr, i64, ptr)

declare i32 @shmem_team_split_strided(ptr, i32, i32, i32, ptr, i64, ptr)

declare i32 @shmem_team_n_pes(ptr)

declare i32 @shmem_team_my_pe(ptr)

declare i32 @shmem_n_pes()

declare i32 @shmem_my_pe()

declare void @shmem_finalize()

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

define void @test_predefined_teams() {
  call void @shmem_init()
  %1 = call i32 @shmem_team_my_pe(ptr @SHMEM_TEAM_WORLD)
  %2 = call i32 @shmem_team_my_pe(ptr @SHMEM_TEAM_SHARED)
  call void @shmem_finalize()
  ret void
}

define void @test_team_splits() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_team_split_strided(ptr @SHMEM_TEAM_WORLD, i32 0, i32 1, i32 2, ptr null, i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = call i32 @shmem_team_split_2d(ptr @SHMEM_TEAM_WORLD, i32 2, ptr null, i64 0, ptr %4, ptr null, i64 0, ptr %5)
  %7 = load ptr, ptr %4, align 8
  %8 = load ptr, ptr %5, align 8
  call void @shmem_team_destroy(ptr %3)
  call void @shmem_team_destroy(ptr %7)
  call void @shmem_team_destroy(ptr %8)
  call void @shmem_finalize()
  ret void
}

define void @test_team_queries() {
  call void @shmem_init()
  %1 = call i32 @shmem_team_my_pe(ptr @SHMEM_TEAM_WORLD)
  %2 = call i32 @shmem_team_n_pes(ptr @SHMEM_TEAM_WORLD)
  call void @shmem_finalize()
  ret void
}

define void @test_team_sync() {
  call void @shmem_init()
  call void @shmem_team_sync(ptr @SHMEM_TEAM_WORLD)
  call void @shmem_finalize()
  ret void
}

define void @test_team_communication() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_team_split_strided(ptr @SHMEM_TEAM_WORLD, i32 0, i32 1, i32 2, ptr null, i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 40)
  %5 = alloca ptr, i64 4, align 8
  call void @shmem_team_sync(ptr %3)
  %6 = call i32 @shmem_team_my_pe(ptr %3)
  %7 = call i32 @shmem_team_n_pes(ptr %3)
  %8 = icmp eq i32 %6, 0
  %9 = select i1 %8, i32 1, i32 0
  call void @shmem_putmem(ptr %4, ptr %5, i64 40, i32 %9)
  call void @shmem_team_sync(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_team_destroy(ptr %3)
  call void @shmem_finalize()
  ret void
}

define void @test_team_with_typed_rma() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_team_split_strided(ptr @SHMEM_TEAM_WORLD, i32 0, i32 2, i32 2, ptr null, i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = call ptr @shmem_malloc(i64 40)
  %5 = alloca ptr, i64 4, align 8
  call void @shmem_team_sync(ptr %3)
  call void @shmem_put32(ptr %4, ptr %5, i64 10, i32 1)
  call void @shmem_team_sync(ptr %3)
  call void @shmem_free(ptr %4)
  call void @shmem_team_destroy(ptr %3)
  call void @shmem_finalize()
  ret void
}

define void @test_multiple_team_splits() {
  call void @shmem_init()
  %1 = alloca ptr, align 8
  %2 = call i32 @shmem_team_split_strided(ptr @SHMEM_TEAM_WORLD, i32 0, i32 1, i32 4, ptr null, i64 0, ptr %1)
  %3 = load ptr, ptr %1, align 8
  %4 = alloca ptr, align 8
  %5 = call i32 @shmem_team_split_strided(ptr %3, i32 0, i32 1, i32 2, ptr null, i64 0, ptr %4)
  %6 = load ptr, ptr %4, align 8
  %7 = alloca ptr, align 8
  %8 = alloca ptr, align 8
  %9 = call i32 @shmem_team_split_2d(ptr @SHMEM_TEAM_WORLD, i32 4, ptr null, i64 0, ptr %7, ptr null, i64 0, ptr %8)
  %10 = load ptr, ptr %7, align 8
  %11 = load ptr, ptr %8, align 8
  call void @shmem_team_sync(ptr %6)
  call void @shmem_team_sync(ptr %10)
  call void @shmem_team_sync(ptr %11)
  %12 = call i32 @shmem_team_my_pe(ptr %6)
  %13 = call i32 @shmem_team_my_pe(ptr %10)
  %14 = call i32 @shmem_team_n_pes(ptr %11)
  call void @shmem_team_destroy(ptr %6)
  call void @shmem_team_destroy(ptr %3)
  call void @shmem_team_destroy(ptr %10)
  call void @shmem_team_destroy(ptr %11)
  call void @shmem_finalize()
  ret void
}

define void @test_teams_with_p2p() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 4)
  call void @shmem_team_sync(ptr @SHMEM_TEAM_WORLD)
  call void @shmem_p(ptr %1, i32 42, i32 1)
  %2 = call i32 @shmem_g(ptr %1, i32 1)
  call void @shmem_team_sync(ptr @SHMEM_TEAM_WORLD)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
