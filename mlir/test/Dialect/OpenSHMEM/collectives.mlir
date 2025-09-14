// RUN: mlir-opt %s --convert-openshmem-to-llvm --convert-func-to-llvm --reconcile-unrealized-casts | mlir-translate --mlir-to-llvmir | FileCheck %s

// Test OpenSHMEM collective operations

module {
  func.func @test_alltoallmem() {
    // Initialize OpenSHMEM
    openshmem.region {

    // Set SHMEM_TEAM_WORLD to a team handle
    %team = openshmem.team_world -> !openshmem.team
    
    // Number of elements to transfer
    %nelems = arith.constant 10 : index // 10 elements
    %size = arith.constant 40 : index // 10 elements * 4 bytes each = 40 bytes

    // Allocate symmetric memory for dest and source
    %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
    %source = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
    
    // Perform alltoallmem operations
    %retval = openshmem.alltoallmem(%team, %dest, %source, %nelems) : !openshmem.team, memref<i32, #openshmem.symmetric_memory>, memref<i32, #openshmem.symmetric_memory>, index -> i32

    // Free symmetric memory
    openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
    openshmem.free(%source) : memref<i32, #openshmem.symmetric_memory>

    // Finalize OpenSHMEM
    }
    return
  }

// CHECK-LABEL: llvm.func @test_alltoallmem()
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: %0 = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_alltoallmem(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i64) -> i32
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

func.func @test_alltoallsmem() {
  // Initialize OpenSHMEM
  openshmem.region {

  // Set SHMEM_TEAM_WORLD to a team handle
  %team = openshmem.team_world -> !openshmem.team

  // Number of elements to transfer
  %nelems = arith.constant 10 : index // 10 elements
  %size = arith.constant 40 : index // 10 elements * 4 bytes each = 40 bytes

  // Allocate symmetric memory for dest and source
  %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
  %source = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

  // Stride for destination and source
  %dst = arith.constant 2 : index // 2 elements
  %sst = arith.constant 2 : index // 2 elements

  // Perform alltoallsmem operations
  %retval = openshmem.alltoallsmem(%team, %dest, %source, %dst, %sst, %nelems) : !openshmem.team, memref<i32, #openshmem.symmetric_memory>, memref<i32, #openshmem.symmetric_memory>, index, index, index -> i32

  // Free symmetric memory
  openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
  openshmem.free(%source) : memref<i32, #openshmem.symmetric_memory>

  // Finalize OpenSHMEM
  }
  return
}

// CHECK-LABEL: llvm.func @test_alltoallsmem()
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: %0 = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_alltoallsmem(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i64, i64, i64) -> i32
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

func.func @test_broadcastmem() {
  // Initialize OpenSHMEM
  openshmem.region {

  // Set SHMEM_TEAM_WORLD to a team handle
  %team = openshmem.team_world -> !openshmem.team

  // Number of elements to transfer
  %nelems = arith.constant 10 : index // 10 elements
  %size = arith.constant 40 : index // 10 elements * 4 bytes each = 40 bytes
  %pe_root = arith.constant 0 : i32 // Root PE number

  // Allocate symmetric memory for dest and source
  %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
  %source = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

  // Perform broadcastmem operations
  %retval = openshmem.broadcastmem(%team, %dest, %source, %nelems, %pe_root) : !openshmem.team, memref<i32, #openshmem.symmetric_memory>, memref<i32, #openshmem.symmetric_memory>, index, i32 -> i32

  // Free symmetric memory
  openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
  openshmem.free(%source) : memref<i32, #openshmem.symmetric_memory>

  // Finalize OpenSHMEM
  }
  return
}

// CHECK-LABEL: llvm.func @test_broadcastmem()
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: %0 = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_broadcastmem(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i64, i32) -> i32
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

func.func @test_collectmem() {
  // Initialize OpenSHMEM
  openshmem.region {

  // Set SHMEM_TEAM_WORLD to a team handle
  %team = openshmem.team_world -> !openshmem.team

  // Number of elements to transfer
  %nelems = arith.constant 10 : index // 10 elements
  %size = arith.constant 40 : index // 10 elements * 4 bytes each = 40 bytes

  // Allocate symmetric memory for dest and source
  %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
  %source = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

  // Perform collectmem operations
  %retval = openshmem.collectmem(%team, %dest, %source, %nelems) : !openshmem.team, memref<i32, #openshmem.symmetric_memory>, memref<i32, #openshmem.symmetric_memory>, index -> i32

  // Free symmetric memory
  openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
  openshmem.free(%source) : memref<i32, #openshmem.symmetric_memory>

  // Finalize OpenSHMEM
  }
  return
}

// CHECK-LABEL: llvm.func @test_collectmem()
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: %0 = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_collectmem(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i64) -> i32
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

func.func @test_fcollectmem() {
  // Initialize OpenSHMEM
  openshmem.region {

  // Set SHMEM_TEAM_WORLD to a team handle
  %team = openshmem.team_world -> !openshmem.team

  // Number of elements to transfer
  %nelems = arith.constant 10 : index // 10 elements
  %size = arith.constant 40 : index // 10 elements * 4 bytes each = 40 bytes

  // Allocate symmetric memory for dest and source
  %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
  %source = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

  // Perform fcollectmem operations
  %retval = openshmem.fcollectmem(%team, %dest, %source, %nelems) : !openshmem.team, memref<i32, #openshmem.symmetric_memory>, memref<i32, #openshmem.symmetric_memory>, index -> i32

  // Free symmetric memory
  openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
  openshmem.free(%source) : memref<i32, #openshmem.symmetric_memory>

  // Finalize OpenSHMEM
  }
  return
}

// CHECK-LABEL: llvm.func @test_fcollectmem()
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: %0 = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_fcollectmem(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i64) -> i32
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

func.func @test_andreduce() {
  // Initialize OpenSHMEM
  openshmem.region {

  // Set SHMEM_TEAM_WORLD to a team handle
  %team = openshmem.team_world -> !openshmem.team

  // Number of elements to reduce
  %nreduce = arith.constant 10 : index // 10 elements
  %size = arith.constant 40 : index // 10 elements * 4 bytes each = 40 bytes

  // Allocate symmetric memory for dest and source
  %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
  %source = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

  // Perform andreduce operations
  %retval = openshmem.andreduce(%team, %dest, %source, %nreduce) : !openshmem.team, memref<i32, #openshmem.symmetric_memory>, memref<i32, #openshmem.symmetric_memory>, index -> i32

  // Free symmetric memory
  openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
  openshmem.free(%source) : memref<i32, #openshmem.symmetric_memory>

  // Finalize OpenSHMEM
  }
  return
}

// CHECK-LABEL: llvm.func @test_andreduce()
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: %0 = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_and_reduce(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i64) -> i32
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

func.func @test_orreduce() {
  // Initialize OpenSHMEM
  openshmem.region {

  // Set SHMEM_TEAM_WORLD to a team handle
  %team = openshmem.team_world -> !openshmem.team

  // Number of elements to reduce
  %nreduce = arith.constant 10 : index // 10 elements
  %size = arith.constant 40 : index // 10 elements * 4 bytes each = 40 bytes

  // Allocate symmetric memory for dest and source
  %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
  %source = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

  // Perform orreduce operations
  %retval = openshmem.orreduce(%team, %dest, %source, %nreduce) : !openshmem.team, memref<i32, #openshmem.symmetric_memory>, memref<i32, #openshmem.symmetric_memory>, index -> i32

  // Free symmetric memory
  openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
  openshmem.free(%source) : memref<i32, #openshmem.symmetric_memory>

  // Finalize OpenSHMEM
  }
  return
}

// CHECK-LABEL: llvm.func @test_orreduce()
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: %0 = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_or_reduce(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i64) -> i32
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

func.func @test_xorreduce() {
  // Initialize OpenSHMEM
  openshmem.region {

  // Set SHMEM_TEAM_WORLD to a team handle
  %team = openshmem.team_world -> !openshmem.team

  // Number of elements to reduce
  %nreduce = arith.constant 10 : index // 10 elements
  %size = arith.constant 40 : index // 10 elements * 4 bytes each = 40 bytes

  // Allocate symmetric memory for dest and source
  %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
  %source = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

  // Perform xorreduce operations
  %retval = openshmem.xorreduce(%team, %dest, %source, %nreduce) : !openshmem.team, memref<i32, #openshmem.symmetric_memory>, memref<i32, #openshmem.symmetric_memory>, index -> i32

  // Free symmetric memory
  openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
  openshmem.free(%source) : memref<i32, #openshmem.symmetric_memory>

  // Finalize OpenSHMEM
  }
  return
}

// CHECK-LABEL: llvm.func @test_xorreduce()
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: %0 = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_xor_reduce(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i64) -> i32
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

func.func @test_maxreduce() {
  // Initialize OpenSHMEM
  openshmem.region {

  // Set SHMEM_TEAM_WORLD to a team handle
  %team = openshmem.team_world -> !openshmem.team

  // Number of elements to reduce
  %nreduce = arith.constant 10 : index // 10 elements
  %size = arith.constant 40 : index // 10 elements * 4 bytes each = 40 bytes

  // Allocate symmetric memory for dest and source
  %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
  %source = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

  // Perform maxreduce operations
  %retval = openshmem.maxreduce(%team, %dest, %source, %nreduce) : !openshmem.team, memref<i32, #openshmem.symmetric_memory>, memref<i32, #openshmem.symmetric_memory>, index -> i32

  // Free symmetric memory
  openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
  openshmem.free(%source) : memref<i32, #openshmem.symmetric_memory>

  // Finalize OpenSHMEM
  }
  return
}

// CHECK-LABEL: llvm.func @test_maxreduce()
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: %0 = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_max_reduce(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i64) -> i32
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

func.func @test_minreduce() {
  // Initialize OpenSHMEM
  openshmem.region {

  // Set SHMEM_TEAM_WORLD to a team handle
  %team = openshmem.team_world -> !openshmem.team

  // Number of elements to reduce
  %nreduce = arith.constant 10 : index // 10 elements
  %size = arith.constant 40 : index // 10 elements * 4 bytes each = 40 bytes

  // Allocate symmetric memory for dest and source
  %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
  %source = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

  // Perform minreduce operations
  %retval = openshmem.minreduce(%team, %dest, %source, %nreduce) : !openshmem.team, memref<i32, #openshmem.symmetric_memory>, memref<i32, #openshmem.symmetric_memory>, index -> i32

  // Free symmetric memory
  openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
  openshmem.free(%source) : memref<i32, #openshmem.symmetric_memory>

  // Finalize OpenSHMEM
  }
  return
}

// CHECK-LABEL: llvm.func @test_minreduce()
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: %0 = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_min_reduce(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i64) -> i32
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

func.func @test_sumreduce() {
  // Initialize OpenSHMEM
  openshmem.region {

  // Set SHMEM_TEAM_WORLD to a team handle
  %team = openshmem.team_world -> !openshmem.team

  // Number of elements to reduce
  %nreduce = arith.constant 10 : index // 10 elements
  %size = arith.constant 40 : index // 10 elements * 4 bytes each = 40 bytes

  // Allocate symmetric memory for dest and source
  %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
  %source = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

  // Perform sumreduce operations
  %retval = openshmem.sumreduce(%team, %dest, %source, %nreduce) : !openshmem.team, memref<i32, #openshmem.symmetric_memory>, memref<i32, #openshmem.symmetric_memory>, index -> i32

  // Free symmetric memory
  openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
  openshmem.free(%source) : memref<i32, #openshmem.symmetric_memory>

  // Finalize OpenSHMEM
  }
  return
}

// CHECK-LABEL: llvm.func @test_sumreduce()
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: %0 = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_sum_reduce(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i64) -> i32
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

func.func @test_prodreduce() {
  // Initialize OpenSHMEM
  openshmem.region {

  // Set SHMEM_TEAM_WORLD to a team handle
  %team = openshmem.team_world -> !openshmem.team

  // Number of elements to reduce
  %nreduce = arith.constant 10 : index // 10 elements
  %size = arith.constant 40 : index // 10 elements * 4 bytes each = 40 bytes

  // Allocate symmetric memory for dest and source
  %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
  %source = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

  // Perform prodreduce operations
  %retval = openshmem.prodreduce(%team, %dest, %source, %nreduce) : !openshmem.team, memref<i32, #openshmem.symmetric_memory>, memref<i32, #openshmem.symmetric_memory>, index -> i32

  // Free symmetric memory
  openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
  openshmem.free(%source) : memref<i32, #openshmem.symmetric_memory>

  // Finalize OpenSHMEM
  }
  return
}

// CHECK-LABEL: llvm.func @test_prodreduce()
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: %0 = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_prod_reduce(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i64) -> i32
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

func.func @test_alltoall_typed() {
  // Initialize OpenSHMEM
  openshmem.region {

  // Set SHMEM_TEAM_WORLD to a team handle
  %team = openshmem.team_world -> !openshmem.team
  
  // Number of elements to transfer
  %nelems = arith.constant 10 : index // 10 elements
  %size = arith.constant 40 : index // 10 elements * 4 bytes each = 40 bytes

  // Allocate symmetric memory for dest and source
  %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
  %source = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
  
  // Perform typed alltoall operations
  %retval = openshmem.alltoall(%team, %dest, %source, %nelems) : !openshmem.team, memref<i32, #openshmem.symmetric_memory>, memref<i32, #openshmem.symmetric_memory>, index -> i32

  // Free symmetric memory
  openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
  openshmem.free(%source) : memref<i32, #openshmem.symmetric_memory>

  // Finalize OpenSHMEM
  }
  return
}

// CHECK-LABEL: llvm.func @test_alltoall_typed()
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: %0 = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_int_alltoall(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i64) -> i32
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

func.func @test_alltoalls_typed() {
  // Initialize OpenSHMEM
  openshmem.region {

  // Set SHMEM_TEAM_WORLD to a team handle
  %team = openshmem.team_world -> !openshmem.team

  // Number of elements to transfer
  %nelems = arith.constant 10 : index // 10 elements
  %size = arith.constant 40 : index // 10 elements * 4 bytes each = 40 bytes

  // Allocate symmetric memory for dest and source
  %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
  %source = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

  // Stride for destination and source
  %dst = arith.constant 2 : index // 2 elements
  %sst = arith.constant 2 : index // 2 elements

  // Perform typed strided alltoall operations
  %retval = openshmem.alltoalls(%team, %dest, %source, %dst, %sst, %nelems) : !openshmem.team, memref<i32, #openshmem.symmetric_memory>, memref<i32, #openshmem.symmetric_memory>, index, index, index -> i32

  // Free symmetric memory
  openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
  openshmem.free(%source) : memref<i32, #openshmem.symmetric_memory>

  // Finalize OpenSHMEM
  }
  return
}

// CHECK-LABEL: llvm.func @test_alltoalls_typed()
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: %0 = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_int_alltoalls(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i64, i64, i64) -> i32
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

func.func @test_broadcast_typed() {
  // Initialize OpenSHMEM
  openshmem.region {

  // Set SHMEM_TEAM_WORLD to a team handle
  %team = openshmem.team_world -> !openshmem.team

  // Number of elements to transfer
  %nelems = arith.constant 10 : index // 10 elements
  %size = arith.constant 40 : index // 10 elements * 4 bytes each = 40 bytes
  %pe_root = arith.constant 0 : i32 // Root PE number

  // Allocate symmetric memory for dest and source
  %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
  %source = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

  // Perform typed broadcast operations
  %retval = openshmem.broadcast(%team, %dest, %source, %nelems, %pe_root) : !openshmem.team, memref<i32, #openshmem.symmetric_memory>, memref<i32, #openshmem.symmetric_memory>, index, i32 -> i32

  // Free symmetric memory
  openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
  openshmem.free(%source) : memref<i32, #openshmem.symmetric_memory>

  // Finalize OpenSHMEM
  }
  return
}

// CHECK-LABEL: llvm.func @test_broadcast_typed()
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: %0 = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_int_broadcast(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i64, i32) -> i32
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

func.func @test_collect_typed() {
  // Initialize OpenSHMEM
  openshmem.init

  // Set SHMEM_TEAM_WORLD to a team handle
  %team = openshmem.team_world -> !openshmem.team

  // Number of elements to transfer
  %nelems = arith.constant 10 : index // 10 elements
  %size = arith.constant 40 : index // 10 elements * 4 bytes each = 40 bytes

  // Allocate symmetric memory for dest and source
  %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
  %source = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

  // Perform typed collect operations
  %retval = openshmem.collect(%team, %dest, %source, %nelems) : !openshmem.team, memref<i32, #openshmem.symmetric_memory>, memref<i32, #openshmem.symmetric_memory>, index -> i32

  // Free symmetric memory
  openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
  openshmem.free(%source) : memref<i32, #openshmem.symmetric_memory>

  // Finalize OpenSHMEM
  openshmem.finalize
  return
}

// CHECK-LABEL: llvm.func @test_collect_typed()
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: %0 = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_int_collect(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i64) -> i32
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

func.func @test_fcollect_typed() {
  // Initialize OpenSHMEM
  openshmem.region {

  // Set SHMEM_TEAM_WORLD to a team handle
  %team = openshmem.team_world -> !openshmem.team

  // Number of elements to transfer
  %nelems = arith.constant 10 : index // 10 elements
  %size = arith.constant 40 : index // 10 elements * 4 bytes each = 40 bytes

  // Allocate symmetric memory for dest and source
  %dest = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>
  %source = openshmem.malloc(%size) : index -> memref<i32, #openshmem.symmetric_memory>

  // Perform typed fcollect operations
  %retval = openshmem.fcollect(%team, %dest, %source, %nelems) : !openshmem.team, memref<i32, #openshmem.symmetric_memory>, memref<i32, #openshmem.symmetric_memory>, index -> i32

  // Free symmetric memory
  openshmem.free(%dest) : memref<i32, #openshmem.symmetric_memory>
  openshmem.free(%source) : memref<i32, #openshmem.symmetric_memory>

  // Finalize OpenSHMEM
  }
  return
}

// CHECK-LABEL: llvm.func @test_fcollect_typed()
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: %0 = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_malloc(%{{.*}}) : (i64) -> !llvm.ptr
// CHECK: llvm.call @shmem_int_fcollect(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i64) -> i32
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_free(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return

}
