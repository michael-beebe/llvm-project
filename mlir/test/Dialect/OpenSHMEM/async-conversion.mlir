// RUN: mlir-opt %s --openshmem-async-conversion | FileCheck %s

module {
  // put -> put_nbi when followed by quiet
  func.func @convert_put_nbi(%dst: memref<i32, #openshmem.symmetric_memory>, %src: memref<i32>, %pe: i32) {
    %c1 = arith.constant 1 : index
    openshmem.region {
      openshmem.put(%dst, %src, %c1, %pe) : memref<i32, #openshmem.symmetric_memory>, memref<i32>, index, i32
      openshmem.quiet
    }
    return
  }
  // CHECK-LABEL: func.func @convert_put_nbi
  // CHECK: openshmem.region {
  // CHECK: openshmem.put_nbi
  // CHECK: openshmem.quiet
  // CHECK: }

  // ctx_put -> ctx_put_nbi when followed by quiet
  func.func @convert_ctx_put_nbi(%ctx: !openshmem.ctx, %dst: memref<i32, #openshmem.symmetric_memory>, %src: memref<i32>, %pe: i32) {
    %c8 = arith.constant 8 : index
    openshmem.region {
      openshmem.ctx_put(%ctx, %dst, %src, %c8, %pe) : !openshmem.ctx, memref<i32, #openshmem.symmetric_memory>, memref<i32>, index, i32
      openshmem.quiet
    }
    return
  }
  // CHECK-LABEL: func.func @convert_ctx_put_nbi
  // CHECK: openshmem.region {
  // CHECK: openshmem.ctx_put_nbi
  // CHECK: openshmem.quiet
  // CHECK: }

  // get -> get_nbi when followed by quiet
  func.func @convert_get_nbi(%dst: memref<i32>, %src: memref<i32, #openshmem.symmetric_memory>, %pe: i32) {
    %c4 = arith.constant 4 : index
    openshmem.region {
      openshmem.get(%dst, %src, %c4, %pe) : memref<i32>, memref<i32, #openshmem.symmetric_memory>, index, i32
      openshmem.quiet
    }
    return
  }
  // CHECK-LABEL: func.func @convert_get_nbi
  // CHECK: openshmem.region {
  // CHECK: openshmem.get_nbi
  // CHECK: openshmem.quiet
  // CHECK: }

  // putmem -> putmem_nbi when followed by quiet
  func.func @convert_putmem_nbi(%dst: memref<i8, #openshmem.symmetric_memory>, %src: memref<i8>, %pe: i32) {
    %sz = arith.constant 16 : index
    openshmem.region {
      openshmem.putmem(%dst, %src, %sz, %pe) : memref<i8, #openshmem.symmetric_memory>, memref<i8>, index, i32
      openshmem.quiet
    }
    return
  }
  // CHECK-LABEL: func.func @convert_putmem_nbi
  // CHECK: openshmem.region {
  // CHECK: openshmem.putmem_nbi
  // CHECK: openshmem.quiet
  // CHECK: }

  // getmem -> getmem_nbi when followed by quiet
  func.func @convert_getmem_nbi(%dst: memref<i8>, %src: memref<i8, #openshmem.symmetric_memory>, %pe: i32) {
    %sz = arith.constant 32 : index
    openshmem.region {
      openshmem.getmem(%dst, %src, %sz, %pe) : memref<i8>, memref<i8, #openshmem.symmetric_memory>, index, i32
      openshmem.quiet
    }
    return
  }
  // CHECK-LABEL: func.func @convert_getmem_nbi
  // CHECK: openshmem.region {
  // CHECK: openshmem.getmem_nbi
  // CHECK: openshmem.quiet
  // CHECK: }
}


// Real-world style: multiple RMA ops before a single quiet
module {
  // Two puts followed by a single quiet → both convert
  func.func @batch_puts(%d1: memref<i32, #openshmem.symmetric_memory>, %s1: memref<i32>,
                        %d2: memref<i32, #openshmem.symmetric_memory>, %s2: memref<i32>,
                        %pe: i32) {
    %n = arith.constant 1 : index
    openshmem.region {
      openshmem.put(%d1, %s1, %n, %pe) : memref<i32, #openshmem.symmetric_memory>, memref<i32>, index, i32
      openshmem.put(%d2, %s2, %n, %pe) : memref<i32, #openshmem.symmetric_memory>, memref<i32>, index, i32
      %x = arith.constant 42 : i32
      %y = arith.constant 1 : i32
      %z = arith.addi %x, %y : i32
      openshmem.quiet
    }
    return
  }
  // CHECK-LABEL: func.func @batch_puts
  // CHECK: openshmem.region {
  // CHECK: openshmem.put_nbi
  // CHECK: openshmem.put_nbi
  // CHECK: openshmem.quiet
  // CHECK: }

  // Mix ctx_put and putmem before a single quiet → both convert
  func.func @mix_ctx_put_and_putmem(%ctx: !openshmem.ctx,
                                    %d: memref<i8, #openshmem.symmetric_memory>, %s: memref<i8>,
                                    %d2: memref<i32, #openshmem.symmetric_memory>, %s2: memref<i32>,
                                    %pe: i32) {
    %n8 = arith.constant 8 : index
    %n1 = arith.constant 1 : index
    openshmem.region {
      openshmem.ctx_put(%ctx, %d2, %s2, %n1, %pe) : !openshmem.ctx, memref<i32, #openshmem.symmetric_memory>, memref<i32>, index, i32
      openshmem.putmem(%d, %s, %n8, %pe) : memref<i8, #openshmem.symmetric_memory>, memref<i8>, index, i32
      openshmem.quiet
    }
    return
  }
  // CHECK-LABEL: func.func @mix_ctx_put_and_putmem
  // CHECK: openshmem.region {
  // CHECK: openshmem.ctx_put_nbi
  // CHECK: openshmem.putmem_nbi
  // CHECK: openshmem.quiet
  // CHECK: }

  // get converts if destination not used before a later quiet
  func.func @get_no_intervening_use(%dst: memref<i32>, %src: memref<i32, #openshmem.symmetric_memory>, %pe: i32) {
    %n = arith.constant 1 : index
    openshmem.region {
      openshmem.get(%dst, %src, %n, %pe) : memref<i32>, memref<i32, #openshmem.symmetric_memory>, index, i32
      %c = arith.constant 0 : i32
      %d = arith.addi %c, %c : i32
      openshmem.quiet
    }
    return
  }
  // CHECK-LABEL: func.func @get_no_intervening_use
  // CHECK: openshmem.region {
  // CHECK: openshmem.get_nbi
  // CHECK: openshmem.quiet
  // CHECK: }

  // get does not convert if destination is used before the quiet
  func.func @get_with_intervening_use(%dst: memref<i32>, %src: memref<i32, #openshmem.symmetric_memory>, %sink: memref<i32>, %pe: i32) {
    %n = arith.constant 1 : index
    openshmem.region {
      openshmem.get(%dst, %src, %n, %pe) : memref<i32>, memref<i32, #openshmem.symmetric_memory>, index, i32
      %val = memref.load %dst[] : memref<i32>
      %e = arith.addi %val, %val : i32
      memref.store %e, %sink[] : memref<i32>
      openshmem.quiet
    }
    return
  }
  // CHECK-LABEL: func.func @get_with_intervening_use
  // CHECK: openshmem.region {
  // CHECK: openshmem.get(
  // CHECK: memref.store
  // CHECK: openshmem.quiet
  // CHECK: }
}

// Barrier treated as sync: conversions allowed by barrier
// RUN: mlir-opt %s --openshmem-async-conversion='treat-barriers-as-sync=true' | FileCheck %s --check-prefix=BARRIER
module {
  func.func @barrier_sync_put(%d: memref<i32, #openshmem.symmetric_memory>, %s: memref<i32>, %pe: i32) {
    %n = arith.constant 1 : index
    openshmem.region {
      openshmem.put(%d, %s, %n, %pe) : memref<i32, #openshmem.symmetric_memory>, memref<i32>, index, i32
      openshmem.barrier_all
    }
    return
  }
  // BARRIER-LABEL: func.func @barrier_sync_put
  // BARRIER: openshmem.region {
  // BARRIER: openshmem.put_nbi
  // BARRIER: openshmem.barrier_all
  // BARRIER: }
}

// Aggressive mode: insert quiet at end to enable conversion
// RUN: mlir-opt %s --openshmem-async-conversion='aggressive-insert-quiet=true treat-barriers-as-sync=false' | FileCheck %s --check-prefix=AGGR
module {
  func.func @aggressive_put(%d: memref<i32, #openshmem.symmetric_memory>, %s: memref<i32>, %pe: i32) {
    %n = arith.constant 1 : index
    openshmem.region {
      openshmem.put(%d, %s, %n, %pe) : memref<i32, #openshmem.symmetric_memory>, memref<i32>, index, i32
    }
    return
  }
  // AGGR-LABEL: func.func @aggressive_put
  // AGGR: openshmem.region {
  // AGGR: openshmem.put_nbi
  // AGGR: openshmem.quiet
  // AGGR: }
}


