// RUN: mlir-opt %s --convert-openshmem-to-llvm --convert-func-to-llvm --reconcile-unrealized-casts | mlir-translate --mlir-to-llvmir | FileCheck %s

// Test OpenSHMEM context management operations

module {
  func.func @test_context_ops() {
    // Initialize OpenSHMEM
    openshmem.region {

    // Options for context creation
    %opts = arith.constant 0 : i64

    // Create a context from the world team
    %ctx, %status = openshmem.ctx_create(%opts) : i64 -> !openshmem.ctx, i32

    // Get SHMEM_TEAM_WORLD
    %team = openshmem.team_world -> !openshmem.team

    // Create a context for a team
    %team_ctx, %team_status = openshmem.team_create_ctx(%team, %opts) : !openshmem.team, i64 -> !openshmem.ctx, i32

    // Query the team associated with a context
    %team_from_ctx, %get_status = openshmem.ctx_get_team(%team_ctx) : !openshmem.ctx -> !openshmem.team, i32

    // Destroy the contexts
    openshmem.ctx_destroy(%ctx) : !openshmem.ctx
    openshmem.ctx_destroy(%team_ctx) : !openshmem.ctx

    // Finalize OpenSHMEM
    }
    return
  }

// CHECK-LABEL: llvm.func @test_context_ops()
// CHECK: llvm.call @shmem_init() : () -> ()
// CHECK: %{{.*}} = llvm.call @shmem_ctx_create(%{{.*}}, %{{.*}}) : (i64, !llvm.ptr) -> i32
// CHECK: %{{.*}} = llvm.mlir.addressof @SHMEM_TEAM_WORLD : !llvm.ptr
// CHECK: %{{.*}} = llvm.call @shmem_team_create_ctx(%{{.*}}, %{{.*}}, %{{.*}}) : (!llvm.ptr, i64, !llvm.ptr) -> i32
// CHECK: %{{.*}} = llvm.call @shmem_ctx_get_team(%{{.*}}, %{{.*}}) : (!llvm.ptr, !llvm.ptr) -> i32
// CHECK: llvm.call @shmem_ctx_destroy(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_ctx_destroy(%{{.*}}) : (!llvm.ptr) -> ()
// CHECK: llvm.call @shmem_finalize() : () -> ()
// CHECK: llvm.return
}
