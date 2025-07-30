//===- InjectNumPEsPass.cpp - Inject openshmem.num_pes attribute ----------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEM.h"
#include "mlir/Dialect/OpenSHMEM/Transforms/Passes.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/BuiltinOps.h"

namespace mlir {
namespace openshmem {
#define GEN_PASS_CLASSES
#include "mlir/Dialect/OpenSHMEM/Transforms/Passes.h.inc"
} // namespace openshmem
} // namespace mlir

using namespace mlir;
using namespace mlir::openshmem;

namespace {

struct InjectNumPEsPass : public InjectNumPEsBase<InjectNumPEsPass> {
  using InjectNumPEsBase<InjectNumPEsPass>::InjectNumPEsBase;

  void runOnOperation() override {
    Operation *op = getOperation();

    // Only inject if the numPEs option is provided (> 0)
    if (numPEs <= 0) {
      return;
    }

    // Create the attribute value
    Builder builder(&getContext());
    IntegerAttr numPEsAttr = builder.getI32IntegerAttr(numPEs);

    // Set the attribute on the module
    op->setAttr("openshmem.num_pes", numPEsAttr);
  }
};

} // namespace

std::unique_ptr<Pass> openshmem::createInjectNumPEsPass() {
  return std::make_unique<InjectNumPEsPass>();
}
