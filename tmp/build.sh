#!/bin/bash

# Simple OpenSHMEM MLIR Dialect Build Script
set -e

BUILD_DIR="build"
JOBS=$(($(nproc) / 2))

# Default projects and targets
PROJECTS="mlir;clang;lld"
TARGETS="mlir-opt mlir-translate clang FileCheck"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
  --clean)
    echo "Cleaning build directory..."
    rm -rf "$BUILD_DIR"
    ;;
  --passes)
    PROJECTS="mlir"
    TARGETS="obj.MLIROpenSHMEMTransforms mlir-opt"
    echo "Building OpenSHMEM transforms only (fast rebuild)"
    ;;
  --mlir)
    PROJECTS="mlir"
    TARGETS="mlir-opt mlir-translate FileCheck"
    echo "Building MLIR only"
    ;;
  --clang)
    PROJECTS="mlir;clang;clang-tools-extra"
    TARGETS="mlir-opt mlir-translate clang clang-tidy clang-format FileCheck"
    echo "Building MLIR + Clang + Tools"
    ;;
  --all)
    PROJECTS="mlir;clang;clang-tools-extra;lld"
    TARGETS="mlir-opt mlir-translate clang clang-tidy clang-format lld FileCheck"
    echo "Building MLIR + Clang + Tools + LLD"
    ;;
  --help | -h)
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  --clean     Clean build directory"
    echo "  --passes Build OpenSHMEM transforms only (fast)"
    echo "  --mlir      Build MLIR only (includes FileCheck)"
    echo "  --clang     Build MLIR + Clang (includes FileCheck)"
    echo "  --all       Build MLIR + Clang + LLD (includes FileCheck, default)"
    echo "  --help      Show this help"
    exit 0
    ;;
  *)
    echo "Unknown option: $1"
    echo "Use --help for usage information"
    exit 1
    ;;
  esac
  shift
done

# Create build directory
mkdir -p "$BUILD_DIR"

echo "Building OpenSHMEM MLIR Dialect..."
echo "Using $JOBS parallel jobs"

cd "$BUILD_DIR"

# Simple CMake configuration for OpenSHMEM dialect
cmake -G "Unix Makefiles" \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_EXE_LINKER_FLAGS="-Wl,--no-relax" \
  -DLLVM_USE_LINKER=gold \
  -DLLVM_ENABLE_PROJECTS="$PROJECTS" \
  -DLLVM_TARGETS_TO_BUILD=host \
  -DLLVM_ENABLE_ASSERTIONS=OFF \
  -DMLIR_ENABLE_BINDINGS_PYTHON=OFF \
  -DLLVM_BUILD_EXAMPLES=OFF \
  -DLLVM_BUILD_TESTS=OFF \
  -DLLVM_BUILD_DOCS=OFF \
  ../llvm

# Build selected targets
echo "Building: $TARGETS"
make -j"$JOBS" $TARGETS

echo "Done! Tools available at:"
for target in $TARGETS; do
  if [[ -f "bin/$target" ]]; then
    echo "  $(pwd)/bin/$target"
  fi
done


