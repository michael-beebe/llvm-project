; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

declare ptr @malloc(i64)

declare void @shmem_put128(ptr, ptr, i64, i32)

declare void @shmem_put64(ptr, ptr, i64, i32)

declare void @shmem_put16(ptr, ptr, i64, i32)

declare void @shmem_put8(ptr, ptr, i64, i32)

declare void @shmem_put_n32(ptr, ptr, i64, i32)

declare void @shmem_put32(ptr, ptr, i64, i32)

declare void @shmem_getmem_nbi(ptr, ptr, i64, i32)

declare void @shmem_quiet()

declare void @shmem_putmem_nbi(ptr, ptr, i64, i32)

declare void @shmem_getmem(ptr, ptr, i64, i32)

declare void @shmem_finalize()

declare void @shmem_free(ptr)

declare void @shmem_putmem(ptr, ptr, i64, i32)

declare ptr @shmem_malloc(i64)

declare void @shmem_init()

define void @test_putmem() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 40)
  %2 = call ptr @malloc(i64 40)
  %3 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %2, 0
  %4 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %3, ptr %2, 1
  %5 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %4, i64 0, 2
  %6 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %5, i64 10, 3, 0
  %7 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %6, i64 1, 4, 0
  %8 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %7, 0
  call void @shmem_putmem(ptr %1, ptr %8, i64 40, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_getmem() {
  call void @shmem_init()
  %1 = call ptr @malloc(i64 40)
  %2 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %1, 0
  %3 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %2, ptr %1, 1
  %4 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %3, i64 0, 2
  %5 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %4, i64 10, 3, 0
  %6 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %5, i64 1, 4, 0
  %7 = call ptr @shmem_malloc(i64 40)
  %8 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %6, 0
  call void @shmem_getmem(ptr %8, ptr %7, i64 40, i32 1)
  call void @shmem_free(ptr %7)
  call void @shmem_finalize()
  ret void
}

define void @test_putmem_nbi() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 40)
  %2 = call ptr @malloc(i64 40)
  %3 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %2, 0
  %4 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %3, ptr %2, 1
  %5 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %4, i64 0, 2
  %6 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %5, i64 10, 3, 0
  %7 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %6, i64 1, 4, 0
  %8 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %7, 0
  call void @shmem_putmem_nbi(ptr %1, ptr %8, i64 40, i32 1)
  call void @shmem_quiet()
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_getmem_nbi() {
  call void @shmem_init()
  %1 = call ptr @malloc(i64 40)
  %2 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %1, 0
  %3 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %2, ptr %1, 1
  %4 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %3, i64 0, 2
  %5 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %4, i64 10, 3, 0
  %6 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %5, i64 1, 4, 0
  %7 = call ptr @shmem_malloc(i64 40)
  %8 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %6, 0
  call void @shmem_getmem_nbi(ptr %8, ptr %7, i64 40, i32 1)
  call void @shmem_quiet()
  call void @shmem_free(ptr %7)
  call void @shmem_finalize()
  ret void
}

define void @test_put_typed() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 40)
  %2 = call ptr @malloc(i64 40)
  %3 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %2, 0
  %4 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %3, ptr %2, 1
  %5 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %4, i64 0, 2
  %6 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %5, i64 10, 3, 0
  %7 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %6, i64 1, 4, 0
  %8 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %7, 0
  call void @shmem_put32(ptr %1, ptr %8, i64 10, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_put_n_typed() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 40)
  %2 = call ptr @malloc(i64 40)
  %3 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %2, 0
  %4 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %3, ptr %2, 1
  %5 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %4, i64 0, 2
  %6 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %5, i64 10, 3, 0
  %7 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %6, i64 1, 4, 0
  %8 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %7, 0
  call void @shmem_put_n32(ptr %1, ptr %8, i64 10, i32 1)
  call void @shmem_quiet()
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_put_sized() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 10)
  %2 = call ptr @malloc(i64 10)
  %3 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %2, 0
  %4 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %3, ptr %2, 1
  %5 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %4, i64 0, 2
  %6 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %5, i64 10, 3, 0
  %7 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %6, i64 1, 4, 0
  %8 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %7, 0
  call void @shmem_put8(ptr %1, ptr %8, i64 10, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_put16_sized() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 20)
  %2 = call ptr @malloc(i64 20)
  %3 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %2, 0
  %4 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %3, ptr %2, 1
  %5 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %4, i64 0, 2
  %6 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %5, i64 10, 3, 0
  %7 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %6, i64 1, 4, 0
  %8 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %7, 0
  call void @shmem_put16(ptr %1, ptr %8, i64 10, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_put32_sized() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 40)
  %2 = call ptr @malloc(i64 40)
  %3 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %2, 0
  %4 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %3, ptr %2, 1
  %5 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %4, i64 0, 2
  %6 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %5, i64 10, 3, 0
  %7 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %6, i64 1, 4, 0
  %8 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %7, 0
  call void @shmem_put32(ptr %1, ptr %8, i64 10, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_put64_sized() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 80)
  %2 = call ptr @malloc(i64 80)
  %3 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %2, 0
  %4 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %3, ptr %2, 1
  %5 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %4, i64 0, 2
  %6 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %5, i64 10, 3, 0
  %7 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %6, i64 1, 4, 0
  %8 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %7, 0
  call void @shmem_put64(ptr %1, ptr %8, i64 10, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

define void @test_put128_sized() {
  call void @shmem_init()
  %1 = call ptr @shmem_malloc(i64 160)
  %2 = call ptr @malloc(i64 160)
  %3 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %2, 0
  %4 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %3, ptr %2, 1
  %5 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %4, i64 0, 2
  %6 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %5, i64 10, 3, 0
  %7 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %6, i64 1, 4, 0
  %8 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %7, 0
  call void @shmem_put128(ptr %1, ptr %8, i64 10, i32 1)
  call void @shmem_free(ptr %1)
  call void @shmem_finalize()
  ret void
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
