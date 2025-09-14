// RUN: mlir-opt %s --openshmem-atomic-fusion | FileCheck %s

module {
  func.func @fuse_add_constants(%dest: memref<i32, #openshmem.symmetric_memory>) {
    %pe = arith.constant 3 : i32
    %c1 = arith.constant 4 : i32
    %c2 = arith.constant 5 : i32
    openshmem.region {
      // CHECK-LABEL: func.func @fuse_add_constants
      // CHECK: openshmem.region {
      // CHECK: openshmem.atomic_add(%{{.*}}, %{{.*}}, %{{.*}})
      // CHECK-NOT: openshmem.atomic_add
      openshmem.atomic_add(%dest, %c1, %pe) : memref<i32, #openshmem.symmetric_memory>, i32, i32
      openshmem.atomic_add(%dest, %c2, %pe) : memref<i32, #openshmem.symmetric_memory>, i32, i32
      // CHECK: }
    }
    return
  }

  // Dead fetch folding: fetch_add -> add when result unused
  func.func @dead_fetch_add_folds(%dest: memref<i32, #openshmem.symmetric_memory>) {
    %pe = arith.constant 0 : i32
    %c = arith.constant 8 : i32
    openshmem.region {
      // CHECK-LABEL: func.func @dead_fetch_add_folds
      // CHECK: openshmem.region {
      // CHECK: openshmem.atomic_add(
      // CHECK-NOT: openshmem.atomic_fetch_add
      %r = openshmem.atomic_fetch_add(%dest, %c, %pe) : memref<i32, #openshmem.symmetric_memory>, i32, i32 -> i32
      // CHECK: }
    }
    return
  }

  // Dead fetch folding: fetch_or -> or when result unused
  func.func @dead_fetch_or_folds(%dest: memref<i64, #openshmem.symmetric_memory>) {
    %pe = arith.constant 2 : i32
    %c = arith.constant 42 : i64
    openshmem.region {
      // CHECK-LABEL: func.func @dead_fetch_or_folds
      // CHECK: openshmem.region {
      // CHECK: openshmem.atomic_or(
      // CHECK-NOT: openshmem.atomic_fetch_or
      %r = openshmem.atomic_fetch_or(%dest, %c, %pe) : memref<i64, #openshmem.symmetric_memory>, i64, i32 -> i64
      // CHECK: }
    }
    return
  }

  // Dead fetch folding: fetch_xor -> xor when result unused
  func.func @dead_fetch_xor_folds(%dest: memref<i32, #openshmem.symmetric_memory>) {
    %pe = arith.constant 5 : i32
    %c = arith.constant 7 : i32
    openshmem.region {
      // CHECK-LABEL: func.func @dead_fetch_xor_folds
      // CHECK: openshmem.region {
      // CHECK: openshmem.atomic_xor(
      // CHECK-NOT: openshmem.atomic_fetch_xor
      %r = openshmem.atomic_fetch_xor(%dest, %c, %pe) : memref<i32, #openshmem.symmetric_memory>, i32, i32 -> i32
      // CHECK: }
    }
    return
  }

  // Ensure we do NOT fold fetch_and (no non-fetch and op exists)
  func.func @dead_fetch_and_does_not_fold(%dest: memref<i32, #openshmem.symmetric_memory>) {
    %pe = arith.constant 7 : i32
    %c = arith.constant 255 : i32
    openshmem.region {
      // CHECK-LABEL: func.func @dead_fetch_and_does_not_fold
      // CHECK: openshmem.region {
      // CHECK: openshmem.atomic_fetch_and(
      %r = openshmem.atomic_fetch_and(%dest, %c, %pe) : memref<i32, #openshmem.symmetric_memory>, i32, i32 -> i32
      // CHECK: }
    }
    return
  }

  // Chain fusion over more than two adds
  func.func @fuse_add_chain_long(%dest: memref<i32, #openshmem.symmetric_memory>) {
    %pe = arith.constant 3 : i32
    %c1 = arith.constant 4 : i32
    %c2 = arith.constant 5 : i32
    %c3 = arith.constant 6 : i32
    openshmem.region {
      // CHECK-LABEL: func.func @fuse_add_chain_long
      // CHECK: openshmem.region {
      // CHECK: openshmem.atomic_add(
      // CHECK-NOT: openshmem.atomic_add(
      openshmem.atomic_add(%dest, %c1, %pe) : memref<i32, #openshmem.symmetric_memory>, i32, i32
      openshmem.atomic_add(%dest, %c2, %pe) : memref<i32, #openshmem.symmetric_memory>, i32, i32
      openshmem.atomic_add(%dest, %c3, %pe) : memref<i32, #openshmem.symmetric_memory>, i32, i32
      // CHECK: }
    }
    return
  }

  // Chain fusion for OR with three constants
  func.func @fuse_or_chain_long(%dest: memref<i32, #openshmem.symmetric_memory>) {
    %pe = arith.constant 1 : i32
    %v1 = arith.constant 1 : i32
    %v2 = arith.constant 2 : i32
    %v3 = arith.constant 4 : i32
    openshmem.region {
      // CHECK-LABEL: func.func @fuse_or_chain_long
      // CHECK: openshmem.region {
      // CHECK: openshmem.atomic_or(
      // CHECK-NOT: openshmem.atomic_or(
      openshmem.atomic_or(%dest, %v1, %pe) : memref<i32, #openshmem.symmetric_memory>, i32, i32
      openshmem.atomic_or(%dest, %v2, %pe) : memref<i32, #openshmem.symmetric_memory>, i32, i32
      openshmem.atomic_or(%dest, %v3, %pe) : memref<i32, #openshmem.symmetric_memory>, i32, i32
      // CHECK: }
    }
    return
  }

  // Chain fusion for XOR with three constants
  func.func @fuse_xor_chain_long(%dest: memref<i64, #openshmem.symmetric_memory>) {
    %pe = arith.constant 9 : i32
    %v1 = arith.constant 1 : i64
    %v2 = arith.constant 3 : i64
    %v3 = arith.constant 7 : i64
    openshmem.region {
      // CHECK-LABEL: func.func @fuse_xor_chain_long
      // CHECK: openshmem.region {
      // CHECK: openshmem.atomic_xor(
      // CHECK-NOT: openshmem.atomic_xor(
      openshmem.atomic_xor(%dest, %v1, %pe) : memref<i64, #openshmem.symmetric_memory>, i64, i32
      openshmem.atomic_xor(%dest, %v2, %pe) : memref<i64, #openshmem.symmetric_memory>, i64, i32
      openshmem.atomic_xor(%dest, %v3, %pe) : memref<i64, #openshmem.symmetric_memory>, i64, i32
      // CHECK: }
    }
    return
  }

  // Mixed add then inc -> single add, inc removed
  func.func @fuse_add_then_inc(%dest: memref<i32, #openshmem.symmetric_memory>) {
    %pe = arith.constant 4 : i32
    %c = arith.constant 10 : i32
    openshmem.region {
      // CHECK-LABEL: func.func @fuse_add_then_inc
      // CHECK: openshmem.region {
      // CHECK: openshmem.atomic_add(
      // CHECK-NOT: openshmem.atomic_inc
      openshmem.atomic_add(%dest, %c, %pe) : memref<i32, #openshmem.symmetric_memory>, i32, i32
      openshmem.atomic_inc(%dest, %pe) : memref<i32, #openshmem.symmetric_memory>, i32
      // CHECK: }
    }
    return
  }

  // Mixed inc then add -> single add, inc replaced
  func.func @fuse_inc_then_add(%dest: memref<i32, #openshmem.symmetric_memory>) {
    %pe = arith.constant 4 : i32
    %c = arith.constant 10 : i32
    openshmem.region {
      // CHECK-LABEL: func.func @fuse_inc_then_add
      // CHECK: openshmem.region {
      // CHECK: openshmem.atomic_add(
      // CHECK-NOT: openshmem.atomic_inc
      openshmem.atomic_inc(%dest, %pe) : memref<i32, #openshmem.symmetric_memory>, i32
      openshmem.atomic_add(%dest, %c, %pe) : memref<i32, #openshmem.symmetric_memory>, i32, i32
      // CHECK: }
    }
    return
  }

  // Negative: do not fuse across quiet
  func.func @no_fuse_across_quiet(%dest: memref<i32, #openshmem.symmetric_memory>) {
    %pe = arith.constant 0 : i32
    %c1 = arith.constant 1 : i32
    %c2 = arith.constant 2 : i32
    openshmem.region {
      // CHECK-LABEL: func.func @no_fuse_across_quiet
      // CHECK: openshmem.region {
      // CHECK: openshmem.atomic_add(
      // CHECK: openshmem.quiet
      // CHECK: openshmem.atomic_add(
      openshmem.atomic_add(%dest, %c1, %pe) : memref<i32, #openshmem.symmetric_memory>, i32, i32
      openshmem.quiet
      openshmem.atomic_add(%dest, %c2, %pe) : memref<i32, #openshmem.symmetric_memory>, i32, i32
      // CHECK: }
    }
    return
  }

  // Negative: different dest -> no fusion
  func.func @no_fuse_different_dest(%dest1: memref<i32, #openshmem.symmetric_memory>, %dest2: memref<i32, #openshmem.symmetric_memory>) {
    %pe = arith.constant 0 : i32
    %c = arith.constant 1 : i32
    openshmem.region {
      // CHECK-LABEL: func.func @no_fuse_different_dest
      // CHECK: openshmem.region {
      // CHECK: openshmem.atomic_add(%arg0,
      // CHECK: openshmem.atomic_add(%arg1,
      openshmem.atomic_add(%dest1, %c, %pe) : memref<i32, #openshmem.symmetric_memory>, i32, i32
      openshmem.atomic_add(%dest2, %c, %pe) : memref<i32, #openshmem.symmetric_memory>, i32, i32
      // CHECK: }
    }
    return
  }

  // Negative: different PE -> no fusion
  func.func @no_fuse_different_pe(%dest: memref<i32, #openshmem.symmetric_memory>) {
    %pe0 = arith.constant 0 : i32
    %pe1 = arith.constant 1 : i32
    %c = arith.constant 1 : i32
    openshmem.region {
      // CHECK-LABEL: func.func @no_fuse_different_pe
      // CHECK: openshmem.region {
      // CHECK: openshmem.atomic_add(
      // CHECK: openshmem.atomic_add(
      openshmem.atomic_add(%dest, %c, %pe0) : memref<i32, #openshmem.symmetric_memory>, i32, i32
      openshmem.atomic_add(%dest, %c, %pe1) : memref<i32, #openshmem.symmetric_memory>, i32, i32
      // CHECK: }
    }
    return
  }

  // Negative: intervening side-effecting op prevents adjacency
  func.func @no_fuse_with_intervening_op(%dest: memref<i32, #openshmem.symmetric_memory>,
                                         %buf: memref<i32>, %x: i32) {
    %pe = arith.constant 0 : i32
    %c1 = arith.constant 1 : i32
    %c2 = arith.constant 2 : i32
    openshmem.region {
      // CHECK-LABEL: func.func @no_fuse_with_intervening_op
      // CHECK: openshmem.region {
      // CHECK: openshmem.atomic_add(
      // CHECK: memref.store
      // CHECK: openshmem.atomic_add(
      openshmem.atomic_add(%dest, %c1, %pe) : memref<i32, #openshmem.symmetric_memory>, i32, i32
      %tmp = arith.addi %x, %c2 : i32
      memref.store %tmp, %buf[] : memref<i32>
      openshmem.atomic_add(%dest, %c2, %pe) : memref<i32, #openshmem.symmetric_memory>, i32, i32
      // CHECK: }
    }
    return
  }
  func.func @fuse_inc_chain(%dest: memref<i64, #openshmem.symmetric_memory>) {
    %pe = arith.constant 1 : i32
    openshmem.region {
      // CHECK-LABEL: func.func @fuse_inc_chain
      // CHECK: openshmem.region {
      // CHECK: openshmem.atomic_add(%{{.*}}, %{{.*}}, %{{.*}})
      // CHECK-NOT: openshmem.atomic_inc
      openshmem.atomic_inc(%dest, %pe) : memref<i64, #openshmem.symmetric_memory>, i32
      openshmem.atomic_inc(%dest, %pe) : memref<i64, #openshmem.symmetric_memory>, i32
      openshmem.atomic_inc(%dest, %pe) : memref<i64, #openshmem.symmetric_memory>, i32
      // CHECK: }
    }
    return
  }

  func.func @fuse_or_constants(%dest: memref<i32, #openshmem.symmetric_memory>) {
    %pe = arith.constant 7 : i32
    %v1 = arith.constant 16 : i32
    %v2 = arith.constant 32 : i32
    openshmem.region {
      // CHECK-LABEL: func.func @fuse_or_constants
      // CHECK: openshmem.region {
      // CHECK: openshmem.atomic_or(%{{.*}}, %{{.*}}, %{{.*}})
      // CHECK-NOT: openshmem.atomic_or
      openshmem.atomic_or(%dest, %v1, %pe) : memref<i32, #openshmem.symmetric_memory>, i32, i32
      openshmem.atomic_or(%dest, %v2, %pe) : memref<i32, #openshmem.symmetric_memory>, i32, i32
      // CHECK: }
    }
    return
  }

  func.func @fuse_xor_constants(%dest: memref<i64, #openshmem.symmetric_memory>) {
    %pe = arith.constant 7 : i32
    %v1 = arith.constant 85 : i64
    %v2 = arith.constant 170 : i64
    openshmem.region {
      // CHECK-LABEL: func.func @fuse_xor_constants
      // CHECK: openshmem.region {
      // CHECK: openshmem.atomic_xor(%{{.*}}, %{{.*}}, %{{.*}})
      // CHECK-NOT: openshmem.atomic_xor
      openshmem.atomic_xor(%dest, %v1, %pe) : memref<i64, #openshmem.symmetric_memory>, i64, i32
      openshmem.atomic_xor(%dest, %v2, %pe) : memref<i64, #openshmem.symmetric_memory>, i64, i32
      // CHECK: }
    }
    return
  }
}


