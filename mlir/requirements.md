# Requirements for OpenSHMEM MLIR Dialect Proof-of-Concept

This document outlines the tasks to create a minimal OpenSHMEM MLIR dialect with a few operations (`shmem_put`, `shmem_get`), a symmetric memory type, a lowering pass to OpenSHMEM library calls, and tests. The project is scoped for a summer internship and targets a fork of the `llvm-project` repository (main branch). Each task specifies the relevant directory in the fork.

## Code

### 1. Fork and Set Up Repository [COMPLETE]
- **Task**: Fork the `llvm-project` main branch, clone locally, and set up the build environment.
- **Details**:
  - Fork from https://github.com/llvm/llvm-project.
  - Clone: `git clone https://github.com/michael-beebe/llvm-project.git`.
  - Add upstream: `git remote add upstream https://github.com/llvm/llvm-project.git`.
  - Install dependencies (CMake, Ninja, C++ compiler) and build MLIR per llvm.org/docs/GettingStarted.html.
- **Directory**: None (repository root).

### 2. Define OpenSHMEM Dialect Base and Types
- **Task**: Create TableGen files to define the OpenSHMEM dialect foundation and basic types.
- **Details**:
  - Define dialect in `OpenSHMEM.td` with name "openshmem" and namespace "::mlir::openshmem".
  - Create basic types: `openshmem.retval` for return values (following MPI pattern).
  - Add error code enums if needed for return value checking.
  - Model after MPI dialect base (`mlir/include/mlir/Dialect/MPI/IR/MPI.td`).
- **Directory**: `mlir/include/mlir/Dialect/OpenSHMEM/IR` (create new).
  - Files: `OpenSHMEM.td`, `OpenSHMEMTypes.td`, `OpenSHMEM.h`.

### 3. Define Core OpenSHMEM Operations  
- **Task**: Create TableGen and header files to define essential OpenSHMEM operations.
- **Details**:
  - **Initialization ops**: 
    - `openshmem.init` - Initialize OpenSHMEM runtime (no args, optional retval)
    - `openshmem.finalize` - Clean up OpenSHMEM runtime (no args, optional retval)
    - `openshmem.my_pe` - Get current PE number (returns I32, optional retval)
    - `openshmem.n_pes` - Get total number of PEs (returns I32, optional retval)
  - **Communication ops** (focus for PoC):
    - `openshmem.put dest, src, size, pe` - One-sided put operation
    - `openshmem.get dest, src, size, pe` - One-sided get operation
  - Use `AnyMemRef` for memory arguments, `I64` for size, `I32` for PE IDs.
  - Runtime values (my_pe, n_pes) return SSA values like MPI dialect does.
  - Model after MPI dialect operations (`mlir/include/mlir/Dialect/MPI/IR/MPIOps.td`).
- **Directory**: `mlir/include/mlir/Dialect/OpenSHMEM/IR`.
  - Files: `OpenSHMEMOps.td`, `OpenSHMEMOps.h`.

### 4. Implement Operation Semantics
- **Task**: Write C++ code for operation parsing, verification, and canonicalization.
- **Details**:
  - Implement parsing/printing for all defined operations.
  - Add verification (e.g., check `memref` types, valid PE IDs, size constraints).
  - Include basic canonicalization (e.g., constant folding for sizes).
  - Handle proper assembly format for each operation type.
  - Reference MPI dialect implementation (`mlir/lib/Dialect/MPI/IR/MPIOps.cpp`).
- **Directory**: `mlir/lib/Dialect/OpenSHMEM/IR` (create new).
  - Files: `OpenSHMEM.cpp`, `OpenSHMEMOps.cpp`.

### 5. Define Symmetric Memory Type Strategy
- **Task**: Decide on approach for OpenSHMEM's symmetric memory representation.
- **Details**:
  - **Option 1 (Recommended for PoC)**: Use MLIR's `memref` type with verification.
    - Add verification in put/get ops to ensure memory layout compatibility.
    - Document conventions for symmetric vs local memory in operation descriptions.
  - **Option 2 (Future enhancement)**: Define custom `openshmem.symmem` type.
    - Custom type would enforce symmetric memory semantics at IR level.
    - More complex but provides stronger type safety.
  - For PoC, go with Option 1 and add TODO comments for future type system.
  - Reference `memref` type (`mlir/include/mlir/IR/MemRefBase.td`).
- **Directory**: `mlir/include/mlir/Dialect/OpenSHMEM/IR`.
  - Files: Update `OpenSHMEMOps.td`, potentially add `OpenSHMEMTypes.td` for custom types.

### 6. Implement Lowering Pass
- **Task**: Create a pass to lower OpenSHMEM operations to library calls.
- **Details**:
  - Write conversion pass `OpenSHMEMToLLVM` to map operations:
    - `openshmem.init` → `shmem_init()`
    - `openshmem.finalize` → `shmem_finalize()`  
    - `openshmem.my_pe` → `shmem_my_pe()`
    - `openshmem.n_pes` → `shmem_n_pes()`
    - `openshmem.put` → `shmem_put_nbi()` + proper memory ordering
    - `openshmem.get` → `shmem_get_nbi()` + completion semantics
  - Use MLIR's `func.call` to invoke library functions.
  - Handle `memref` descriptor to raw pointer conversion.
  - Add proper function declarations for OpenSHMEM library.
  - Reference MPI dialect lowerings and existing conversion passes.
- **Directory**: `mlir/lib/Conversion/OpenSHMEMToLLVM` (create new).
  - Files: `OpenSHMEMToLLVM.cpp`.

### 7. Write Comprehensive Tests
- **Task**: Create test cases to verify operations, semantics, and lowering.
- **Details**:
  - **Parsing tests**: Verify operation syntax and assembly format.
  - **Verification tests**: Test semantic constraints and error conditions.
  - **Canonicalization tests**: Test optimization patterns.
  - **Lowering tests**: Verify correct LLVM IR generation using `mlir-opt`.
  - **Integration tests**: Test with actual OpenSHMEM runtime if available.
  - Create `.mlir` test files for each operation category.
  - Reference MPI tests (`mlir/test/Dialect/MPI`).
- **Directory**: `mlir/test/Dialect/OpenSHMEM` (create new).
  - Files: `init.mlir`, `info.mlir`, `put.mlir`, `get.mlir`, `lowering.mlir`.

### 8. Update Build System and Registration
- **Task**: Configure CMake and register dialect with MLIR infrastructure.
- **Details**:
  - Add new directories to MLIR's build system.
  - Create `CMakeLists.txt` files for dialect and conversion pass.
  - **Register dialect**: Update `mlir/include/mlir/InitAllDialects.h` to include OpenSHMEM.
  - Update `mlir-opt` tool to load the dialect for testing.
  - Add tablegen dependencies and proper linking.
  - Reference MPI dialect's build setup (`mlir/lib/Dialect/MPI/CMakeLists.txt`).
- **Directory**: Multiple locations.
  - Files: `mlir/lib/Dialect/OpenSHMEM/CMakeLists.txt`, `mlir/lib/Conversion/OpenSHMEMToLLVM/CMakeLists.txt`, updates to existing CMake files.

### 9. Documentation and Examples
- **Task**: Create documentation and usage examples.
- **Details**:
  - Write README in dialect directory explaining design decisions.
  - Document symmetric memory conventions and limitations.
  - Create simple example `.mlir` programs showing put/get patterns.
  - Document build and testing procedures.
  - Include future enhancement roadmap (custom types, more operations).
- **Directory**: `mlir/lib/Dialect/OpenSHMEM` (README), `mlir/test/Dialect/OpenSHMEM` (examples).

## Publication

### 10. Document and Prepare for Publication
- **Task**: Document the dialect and draft a publication.
- **Details**:
  - Write a README in `mlir/lib/Dialect/OpenSHMEM` describing the dialect's design and usage.
  - Create a paper for a venue like OpenSHMEM Workshop at SC or LLVM Developers' Meeting.
  - Include design, implementation, and benchmark results (e.g., latency of `shmem_put` vs. native OpenSHMEM).
- **Directory**: `mlir/lib/Dialect/OpenSHMEM` (README), external (paper).

### 11. Engage Community and Submit Pull Request
- **Task**: Share work with the LLVM community and submit a PR.
- **Details**:
  - Post an RFC on LLVM Discourse (discourse.llvm.org) to outline the dialect's design.
  - Get feedback on `#mlir` Discord channel.
  - Push code to your fork's branch (e.g., `openshmem-dialect`).
  - Submit a PR to `llvm-project/main` per llvm.org/docs/Contributing.html.
- **Directory**: None (GitHub fork).

### Notes
- **Template**: Use the MPI dialect (`mlir/include/mlir/Dialect/MPI`, `mlir/lib/Dialect/MPI`) as a reference.
- **Runtime Values**: Follow MPI pattern - operations like `my_pe` and `n_pes` return SSA values that can be used in IR.
- **Symmetric Memory**: Start with `memref` + verification for PoC, design custom types later.
- **Publication**: A PR (even under review) and fork are citable for a paper.  