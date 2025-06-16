#!/bin/bash

OPENSHMEM_DIALECT_LIB="mlir/lib/Dialect/OpenSHMEM"
OPENSHMEM_DIALECT_INCLUDE="mlir/include/mlir/Dialect/OpenSHMEM"
OPENSHMEM_DIALECT_TRANSFORMS="mlir/lib/Dialect/OpenSHMEM/Transforms"

# Note: Test files (.mlir) should NOT be formatted with clang-format
# as it's designed for C/C++ code and will mess up MLIR syntax.

# Format the OpenSHMEM dialect library
echo -e "\nFormatting library..."
find "${OPENSHMEM_DIALECT_LIB}" -type f -name "*.h" -exec clang-format -style=llvm -i {} + && \
  echo "✓ Formatted .h files"
find "${OPENSHMEM_DIALECT_LIB}" -type f -name "*.cpp" -exec clang-format -style=llvm -i {} + && \
  echo "✓ Formatted .cpp files"
find "${OPENSHMEM_DIALECT_LIB}" -type f -name "*.td" -exec clang-format -style=llvm -i {} + && \
  echo "✓ Formatted .td files"

# Format the OpenSHMEM dialect include
echo -e "\nFormatting includes..."
find "${OPENSHMEM_DIALECT_INCLUDE}" -type f -name "*.h" -exec clang-format -style=llvm -i {} + && \
  echo "✓ Formatted .h files"
find "${OPENSHMEM_DIALECT_INCLUDE}" -type f -name "*.td" -exec clang-format -style=llvm -i {} + && \
  echo "✓ Formatted .td files"
find "${OPENSHMEM_DIALECT_INCLUDE}" -type f -name "*.cpp" -exec clang-format -style=llvm -i {} + && \
  echo "✓ Formatted .cpp files"

# Format the OpenSHMEM dialect transforms
echo -e "\nFormatting transforms..."
find "${OPENSHMEM_DIALECT_TRANSFORMS}" -type f -name "*.h" -exec clang-format -style=llvm -i {} + && \
  echo "✓ Formatted .h files"
find "${OPENSHMEM_DIALECT_TRANSFORMS}" -type f -name "*.cpp" -exec clang-format -style=llvm -i {} + && \
  echo "✓ Formatted .cpp files"
find "${OPENSHMEM_DIALECT_TRANSFORMS}" -type f -name "*.td" -exec clang-format -style=llvm -i {} + && \
  echo "✓ Formatted .td files"


