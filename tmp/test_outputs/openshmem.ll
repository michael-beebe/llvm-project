; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

declare void @free(ptr)

declare ptr @malloc(i64)

declare void @shmem_finalize()

declare void @shmem_free(ptr)

declare void @shmem_quiet()

declare void @shmem_get(ptr, ptr, i64, i32)

declare void @shmem_put(ptr, ptr, i64, i32)

declare void @shmem_barrier_all()

declare ptr @shmem_malloc(i64)

declare i32 @shmem_n_pes()

declare i32 @shmem_my_pe()

declare void @shmem_init()

define void @main() {
  call void @shmem_init()
  %1 = call i32 @shmem_my_pe()
  %2 = call i32 @shmem_n_pes()
  %3 = call ptr @shmem_malloc(i64 40)
  %4 = call ptr @malloc(i64 40)
  %5 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %4, 0
  %6 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %5, ptr %4, 1
  %7 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %6, i64 0, 2
  %8 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %7, i64 10, 3, 0
  %9 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %8, i64 1, 4, 0
  call void @shmem_barrier_all()
  %10 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %9, 0
  call void @shmem_put(ptr %3, ptr %10, i64 10, i32 1)
  call void @shmem_get(ptr %10, ptr %3, i64 10, i32 1)
  call void @shmem_quiet()
  %11 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %9, 0
  call void @free(ptr %11)
  call void @shmem_free(ptr %3)
  call void @shmem_finalize()
  ret void
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
