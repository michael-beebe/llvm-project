// RUN: mlir-opt %s --convert-openshmem-to-llvm --convert-func-to-llvm --reconcile-unrealized-casts | mlir-translate --mlir-to-llvmir | FileCheck %s

// Test OpenSHMEM point-to-point synchronization operations

module {
  func.func @test_wait_until() {
    // Initialize OpenSHMEM
    openshmem.init

    // Allocate symmetric memory for ivar
    %size = arith.constant 4 : index // size of i32
    %ivar = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
    %cmp = arith.constant 1 : i32 // SHMEM_CMP_EQ
    %cmp_value = arith.constant 42 : i32

    // Perform wait_until operation
    openshmem.wait_until(%ivar, %cmp, %cmp_value) : memref<i32, #openshmem.symmetric_memory>, i32, i32

    // Free memory
    openshmem.free(%ivar) : memref<i32, #openshmem.symmetric_memory>

    // Finalize OpenSHMEM
    openshmem.finalize
    return
  }

// CHECK-LABEL: llvm.func @test_wait_until()
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_wait_until32(%{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, i32, i32) -> ()
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

  func.func @test_wait_until_all() {
    // Initialize OpenSHMEM
    openshmem.init

    // Allocate symmetric memory for ivars (needs to be accessible by remote PEs)
    %ivars_size = arith.constant 40 : index // 10 elements * 4 bytes each = 40 bytes
    %ivars = openshmem.malloc(%ivars_size) : index -> memref<i32, #openshmem.symmetric_memory>
    
    // Allocate local memory for status array
    %status = memref.alloc() : memref<10xi32>
    %nelems = arith.constant 10 : index
    %cmp = arith.constant 1 : i32 // SHMEM_CMP_EQ
    %cmp_value = arith.constant 42 : i32

    // Perform wait_until_all operation (using symmetric memref directly)
    openshmem.wait_until_all(%ivars, %nelems, %status, %cmp, %cmp_value) : memref<i32, #openshmem.symmetric_memory>, index, memref<10xi32>, i32, i32

    // Free memory
    openshmem.free(%ivars) : memref<i32, #openshmem.symmetric_memory>
    memref.dealloc %status : memref<10xi32>

    // Finalize OpenSHMEM
    openshmem.finalize
    return
  }

// CHECK-LABEL: llvm.func @test_wait_until_all()
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_wait_until_all32(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, i64, !llvm.ptr, i32, i32) -> ()
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

  func.func @test_wait_until_any() {
    // Initialize OpenSHMEM
    openshmem.init

    // Allocate symmetric memory for ivars (needs to be accessible by remote PEs)
    %ivars_size = arith.constant 40 : index // 10 elements * 4 bytes each = 40 bytes
    %ivars = openshmem.malloc(%ivars_size) : index -> memref<i32, #openshmem.symmetric_memory>
    
    // Allocate local memory for status array
    %status = memref.alloc() : memref<10xi32>
    %nelems = arith.constant 10 : index
    %cmp = arith.constant 1 : i32 // SHMEM_CMP_EQ
    %cmp_value = arith.constant 42 : i32

    // Perform wait_until_any operation (using symmetric memref directly)
    openshmem.wait_until_any(%ivars, %nelems, %status, %cmp, %cmp_value) : memref<i32, #openshmem.symmetric_memory>, index, memref<10xi32>, i32, i32

    // Free memory
    openshmem.free(%ivars) : memref<i32, #openshmem.symmetric_memory>
    memref.dealloc %status : memref<10xi32>

    // Finalize OpenSHMEM
    openshmem.finalize
    return
  }

// CHECK-LABEL: llvm.func @test_wait_until_any()
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_wait_until_any32(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, i64, !llvm.ptr, i32, i32) -> ()
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

  func.func @test_wait_until_some() {
    // Initialize OpenSHMEM
    openshmem.init

    // Allocate symmetric memory for ivars (needs to be accessible by remote PEs)
    %ivars_size = arith.constant 40 : index // 10 elements * 4 bytes each = 40 bytes
    %ivars = openshmem.malloc(%ivars_size) : index -> memref<i32, #openshmem.symmetric_memory>
    
    // Allocate local memory for indices and status arrays
    %indices = memref.alloc() : memref<10xindex>
    %status = memref.alloc() : memref<10xi32>
    %nelems = arith.constant 10 : index
    %cmp = arith.constant 1 : i32 // SHMEM_CMP_EQ
    %cmp_value = arith.constant 42 : i32

    // Perform wait_until_some operation
    %result = openshmem.wait_until_some(%ivars, %nelems, %indices, %status, %cmp, %cmp_value) : memref<i32, #openshmem.symmetric_memory>, index, memref<10xindex>, memref<10xi32>, i32, i32 -> index

    // Free memory
    openshmem.free(%ivars) : memref<i32, #openshmem.symmetric_memory>
    memref.dealloc %indices : memref<10xindex>
    memref.dealloc %status : memref<10xi32>

    // Finalize OpenSHMEM
    openshmem.finalize
    return
  }

// CHECK-LABEL: llvm.func @test_wait_until_some()
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: %{{.*}} = llvm.call @shmem_wait_until_some32(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, i64, !llvm.ptr, !llvm.ptr, i32, i32) -> i64
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

  func.func @test_wait_until_all_vector() {
    // Initialize OpenSHMEM
    openshmem.init

    // Allocate symmetric memory for ivars (needs to be accessible by remote PEs)
    %ivars_size = arith.constant 40 : index // 10 elements * 4 bytes each = 40 bytes
    %ivars = openshmem.malloc(%ivars_size) : index -> memref<i32, #openshmem.symmetric_memory>
    
    // Allocate local memory for status and cmp_values arrays
    %status = memref.alloc() : memref<10xi32>
    %cmp_values = memref.alloc() : memref<10xi32>
    %nelems = arith.constant 10 : index
    %cmp = arith.constant 1 : i32 // SHMEM_CMP_EQ

    // Perform wait_until_all_vector operation
    openshmem.wait_until_all_vector(%ivars, %nelems, %status, %cmp, %cmp_values) : memref<i32, #openshmem.symmetric_memory>, index, memref<10xi32>, i32, memref<10xi32>

    // Free memory
    openshmem.free(%ivars) : memref<i32, #openshmem.symmetric_memory>
    memref.dealloc %status : memref<10xi32>
    memref.dealloc %cmp_values : memref<10xi32>

    // Finalize OpenSHMEM
    openshmem.finalize
    return
  }

// CHECK-LABEL: llvm.func @test_wait_until_all_vector()
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_wait_until_all_vector(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, i64, !llvm.ptr, i32, !llvm.ptr) -> ()
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

  func.func @test_wait_until_any_vector() {
    // Initialize OpenSHMEM
    openshmem.init

    // Allocate symmetric memory for ivars (needs to be accessible by remote PEs)
    %ivars_size = arith.constant 40 : index // 10 elements * 4 bytes each = 40 bytes
    %ivars = openshmem.malloc(%ivars_size) : index -> memref<i32, #openshmem.symmetric_memory>
    
    // Allocate local memory for status and cmp_values arrays
    %status = memref.alloc() : memref<10xi32>
    %cmp_values = memref.alloc() : memref<10xi32>
    %nelems = arith.constant 10 : index
    %cmp = arith.constant 1 : i32 // SHMEM_CMP_EQ

    // Perform wait_until_any_vector operation
    openshmem.wait_until_any_vector(%ivars, %nelems, %status, %cmp, %cmp_values) : memref<i32, #openshmem.symmetric_memory>, index, memref<10xi32>, i32, memref<10xi32>

    // Free memory
    openshmem.free(%ivars) : memref<i32, #openshmem.symmetric_memory>
    memref.dealloc %status : memref<10xi32>
    memref.dealloc %cmp_values : memref<10xi32>

    // Finalize OpenSHMEM
    openshmem.finalize
    return
  }

// CHECK-LABEL: llvm.func @test_wait_until_any_vector()
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_wait_until_any_vector(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, i64, !llvm.ptr, i32, !llvm.ptr) -> ()
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

  func.func @test_wait_until_some_vector() {
    // Initialize OpenSHMEM
    openshmem.init

    // Allocate symmetric memory for ivars (needs to be accessible by remote PEs)
    %ivars_size = arith.constant 40 : index // 10 elements * 4 bytes each = 40 bytes
    %ivars = openshmem.malloc(%ivars_size) : index -> memref<i32, #openshmem.symmetric_memory>
    
    // Allocate local memory for indices, status, and cmp_values arrays
    %indices = memref.alloc() : memref<10xindex>
    %status = memref.alloc() : memref<10xi32>
    %cmp_values = memref.alloc() : memref<10xi32>
    %nelems = arith.constant 10 : index
    %cmp = arith.constant 1 : i32 // SHMEM_CMP_EQ

    // Perform wait_until_some_vector operation
    %result = openshmem.wait_until_some_vector(%ivars, %nelems, %indices, %status, %cmp, %cmp_values) : memref<i32, #openshmem.symmetric_memory>, index, memref<10xindex>, memref<10xi32>, i32, memref<10xi32> -> index

    // Free memory
    openshmem.free(%ivars) : memref<i32, #openshmem.symmetric_memory>
    memref.dealloc %indices : memref<10xindex>
    memref.dealloc %status : memref<10xi32>
    memref.dealloc %cmp_values : memref<10xi32>

    // Finalize OpenSHMEM
    openshmem.finalize
    return
  }

// CHECK-LABEL: llvm.func @test_wait_until_some_vector()
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: %{{.*}} = llvm.call @shmem_wait_until_some_vector(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, i64, !llvm.ptr, !llvm.ptr, i32, !llvm.ptr) -> i64
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

  func.func @test_test() {
    // Initialize OpenSHMEM
    openshmem.init

    // Allocate symmetric memory for ivar
    %size = arith.constant 4 : index // size of i32
    %ivar = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
    %cmp = arith.constant 1 : i32 // SHMEM_CMP_EQ
    %cmp_value = arith.constant 42 : i32

    // Perform test operation
    %result = openshmem.test(%ivar, %cmp, %cmp_value) : memref<i32, #openshmem.symmetric_memory>, i32, i32 -> i32

    // Free memory
    openshmem.free(%ivar) : memref<i32, #openshmem.symmetric_memory>

    // Finalize OpenSHMEM
    openshmem.finalize
    return
  }

// CHECK-LABEL: llvm.func @test_test()
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: %{{.*}} = llvm.call @shmem_test32(%{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, i32, i32) -> i32
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

  func.func @test_test_all() {
    // Initialize OpenSHMEM
    openshmem.init

    // Allocate symmetric memory for ivars (needs to be accessible by remote PEs)
    %ivars_size = arith.constant 40 : index // 10 elements * 4 bytes each = 40 bytes
    %ivars = openshmem.malloc(%ivars_size) : index -> memref<i32, #openshmem.symmetric_memory>
    
    // Allocate local memory for status array
    %status = memref.alloc() : memref<10xi32>
    %nelems = arith.constant 10 : index
    %cmp = arith.constant 1 : i32 // SHMEM_CMP_EQ
    %cmp_value = arith.constant 42 : i32

    // Perform test_all operation
    %result = openshmem.test_all(%ivars, %nelems, %status, %cmp, %cmp_value) : memref<i32, #openshmem.symmetric_memory>, index, memref<10xi32>, i32, i32 -> i32

    // Free memory
    openshmem.free(%ivars) : memref<i32, #openshmem.symmetric_memory>
    memref.dealloc %status : memref<10xi32>

    // Finalize OpenSHMEM
    openshmem.finalize
    return
  }

// CHECK-LABEL: llvm.func @test_test_all()
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: %{{.*}} = llvm.call @shmem_test_all32(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, i64, !llvm.ptr, i32, i32) -> i32
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

  func.func @test_test_any() {
    // Initialize OpenSHMEM
    openshmem.init

    // Allocate symmetric memory for ivars (needs to be accessible by remote PEs)
    %ivars_size = arith.constant 40 : index // 10 elements * 4 bytes each = 40 bytes
    %ivars = openshmem.malloc(%ivars_size) : index -> memref<i32, #openshmem.symmetric_memory>
    
    // Allocate local memory for status array
    %status = memref.alloc() : memref<10xi32>
    %nelems = arith.constant 10 : index
    %cmp = arith.constant 1 : i32 // SHMEM_CMP_EQ
    %cmp_value = arith.constant 42 : i32

    // Perform test_any operation
    %result = openshmem.test_any(%ivars, %nelems, %status, %cmp, %cmp_value) : memref<i32, #openshmem.symmetric_memory>, index, memref<10xi32>, i32, i32 -> index

    // Free memory
    openshmem.free(%ivars) : memref<i32, #openshmem.symmetric_memory>
    memref.dealloc %status : memref<10xi32>

    // Finalize OpenSHMEM
    openshmem.finalize
    return
  }

// CHECK-LABEL: llvm.func @test_test_any()
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: %{{.*}} = llvm.call @shmem_test_any32(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, i64, !llvm.ptr, i32, i32) -> i64
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

  func.func @test_test_some() {
    // Initialize OpenSHMEM
    openshmem.init

    // Allocate symmetric memory for ivars (needs to be accessible by remote PEs)
    %ivars_size = arith.constant 40 : index // 10 elements * 4 bytes each = 40 bytes
    %ivars = openshmem.malloc(%ivars_size) : index -> memref<i32, #openshmem.symmetric_memory>
    
    // Allocate local memory for indices and status arrays
    %indices = memref.alloc() : memref<10xindex>
    %status = memref.alloc() : memref<10xi32>
    %nelems = arith.constant 10 : index
    %cmp = arith.constant 1 : i32 // SHMEM_CMP_EQ
    %cmp_value = arith.constant 42 : i32

    // Perform test_some operation
    %result = openshmem.test_some(%ivars, %nelems, %indices, %status, %cmp, %cmp_value) : memref<i32, #openshmem.symmetric_memory>, index, memref<10xindex>, memref<10xi32>, i32, i32 -> index

    // Free memory
    openshmem.free(%ivars) : memref<i32, #openshmem.symmetric_memory>
    memref.dealloc %indices : memref<10xindex>
    memref.dealloc %status : memref<10xi32>

    // Finalize OpenSHMEM
    openshmem.finalize
    return
  }

// CHECK-LABEL: llvm.func @test_test_some()
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: %{{.*}} = llvm.call @shmem_test_some32(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, i64, !llvm.ptr, !llvm.ptr, i32, i32) -> i64
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

  func.func @test_test_all_vector() {
    // Initialize OpenSHMEM
    openshmem.init

    // Allocate symmetric memory for ivars (needs to be accessible by remote PEs)
    %ivars_size = arith.constant 40 : index // 10 elements * 4 bytes each = 40 bytes
    %ivars = openshmem.malloc(%ivars_size) : index -> memref<i32, #openshmem.symmetric_memory>
    
    // Allocate local memory for status and cmp_values arrays
    %status = memref.alloc() : memref<10xi32>
    %cmp_values = memref.alloc() : memref<10xi32>
    %nelems = arith.constant 10 : index
    %cmp = arith.constant 1 : i32 // SHMEM_CMP_EQ

    // Perform test_all_vector operation
    %result = openshmem.test_all_vector(%ivars, %nelems, %status, %cmp, %cmp_values) : memref<i32, #openshmem.symmetric_memory>, index, memref<10xi32>, i32, memref<10xi32> -> i32

    // Free memory
    openshmem.free(%ivars) : memref<i32, #openshmem.symmetric_memory>
    memref.dealloc %status : memref<10xi32>
    memref.dealloc %cmp_values : memref<10xi32>

    // Finalize OpenSHMEM
    openshmem.finalize
    return
  }

// CHECK-LABEL: llvm.func @test_test_all_vector()
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: %{{.*}} = llvm.call @shmem_test_all_vector(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, i64, !llvm.ptr, i32, !llvm.ptr) -> i32
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

  func.func @test_test_any_vector() {
    // Initialize OpenSHMEM
    openshmem.init

    // Allocate symmetric memory for ivars (needs to be accessible by remote PEs)
    %ivars_size = arith.constant 40 : index // 10 elements * 4 bytes each = 40 bytes
    %ivars = openshmem.malloc(%ivars_size) : index -> memref<i32, #openshmem.symmetric_memory>
    
    // Allocate local memory for status and cmp_values arrays
    %status = memref.alloc() : memref<10xi32>
    %cmp_values = memref.alloc() : memref<10xi32>
    %nelems = arith.constant 10 : index
    %cmp = arith.constant 1 : i32 // SHMEM_CMP_EQ

    // Perform test_any_vector operation
    %result = openshmem.test_any_vector(%ivars, %nelems, %status, %cmp, %cmp_values) : memref<i32, #openshmem.symmetric_memory>, index, memref<10xi32>, i32, memref<10xi32> -> index

    // Free memory
    openshmem.free(%ivars) : memref<i32, #openshmem.symmetric_memory>
    memref.dealloc %status : memref<10xi32>
    memref.dealloc %cmp_values : memref<10xi32>

    // Finalize OpenSHMEM
    openshmem.finalize
    return
  }

// CHECK-LABEL: llvm.func @test_test_any_vector()
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: %{{.*}} = llvm.call @shmem_test_any_vector(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, i64, !llvm.ptr, i32, !llvm.ptr) -> i64
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

  func.func @test_test_some_vector() {
    // Initialize OpenSHMEM
    openshmem.init

    // Allocate symmetric memory for ivars (needs to be accessible by remote PEs)
    %ivars_size = arith.constant 40 : index // 10 elements * 4 bytes each = 40 bytes
    %ivars = openshmem.malloc(%ivars_size) : index -> memref<i32, #openshmem.symmetric_memory>
    
    // Allocate local memory for indices, status, and cmp_values arrays
    %indices = memref.alloc() : memref<10xindex>
    %status = memref.alloc() : memref<10xi32>
    %cmp_values = memref.alloc() : memref<10xi32>
    %nelems = arith.constant 10 : index
    %cmp = arith.constant 1 : i32 // SHMEM_CMP_EQ

    // Perform test_some_vector operation
    %result = openshmem.test_some_vector(%ivars, %nelems, %indices, %status, %cmp, %cmp_values) : memref<i32, #openshmem.symmetric_memory>, index, memref<10xindex>, memref<10xi32>, i32, memref<10xi32> -> index

    // Free memory
    openshmem.free(%ivars) : memref<i32, #openshmem.symmetric_memory>
    memref.dealloc %indices : memref<10xindex>
    memref.dealloc %status : memref<10xi32>
    memref.dealloc %cmp_values : memref<10xi32>

    // Finalize OpenSHMEM
    openshmem.finalize
    return
  }

// CHECK-LABEL: llvm.func @test_test_some_vector()
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: %{{.*}} = llvm.call @shmem_test_some_vector(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, i64, !llvm.ptr, !llvm.ptr, i32, !llvm.ptr) -> i64
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

  func.func @test_signal_wait_until() {
    // Initialize OpenSHMEM
    openshmem.init

    // Allocate symmetric memory for signal address (must be accessible by remote PEs)
    %sig_size = arith.constant 8 : index // 1 element * 8 bytes = 8 bytes
    %sig_addr = openshmem.malloc(%sig_size) : index -> memref<i64, #openshmem.symmetric_memory>
    %cmp = arith.constant 1 : i32 // SHMEM_CMP_EQ
    %cmp_value = arith.constant 42 : i64

    // Perform signal_wait_until operation (using symmetric memref directly)
    %result = openshmem.signal_wait_until(%sig_addr, %cmp, %cmp_value) : memref<i64, #openshmem.symmetric_memory>, i32, i64 -> i64

    // Free memory
    openshmem.free(%sig_addr) : memref<i64, #openshmem.symmetric_memory>

    // Finalize OpenSHMEM
    openshmem.finalize
    return
  }

// CHECK-LABEL: llvm.func @test_signal_wait_until()
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: %{{.*}} = llvm.call @shmem_signal_wait_until(%{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, i32, i64) -> i64
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

}
