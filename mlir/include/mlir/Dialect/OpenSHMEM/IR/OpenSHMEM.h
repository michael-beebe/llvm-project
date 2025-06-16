//===- OpenSHMEM.h - OpenSHMEM dialect declaration ------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEM_H
#define MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEM_H

#include "mlir/IR/Dialect.h"

namespace mlir {
namespace openshmem {

class OpenSHMEMDialect : public Dialect {
public:
  static constexpr StringLiteral getDialectNamespace() { return "openshmem"; }

  explicit OpenSHMEMDialect(MLIRContext *context);

  /// Initialize the dialect.
  void initialize();
};

} // namespace openshmem
} // namespace mlir

#endif // MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEM_H
