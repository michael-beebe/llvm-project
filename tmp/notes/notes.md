## 06/16/2025

### Build System Setup
- Added OpenSHMEM to main CMakeLists.txt files in both include/mlir/Dialect/ and lib/mlir/Dialect/
- Set up TableGen configuration for operations, types, and attributes in include/mlir/Dialect/OpenSHMEM/IR/CMakeLists.txt
- Configured library dependencies in lib/mlir/Dialect/OpenSHMEM/IR/CMakeLists.txt following MPI dialect pattern
- Set up Transforms CMakeLists.txt for future optimization passes
- Build system now ready for dialect implementation

### TableGen Setup
- Created OpenSHMEM.td with basic dialect definition and includes
- Created OpenSHMEMTypes.td with symmetric memory type definition
- Created OpenSHMEMOps.td with placeholder operation to get build working
- Created C++ implementation files: OpenSHMEM.cpp, OpenSHMEMOps.cpp
- Created header file: OpenSHMEM.h
- Basic dialect structure now in place for build to succeed

### Pushed to GitHub at 11am

### First Operations Implementation
- Replaced placeholder with shmem_init and shmem_finalize operations
- Following MPI dialect pattern for operation structure
- Operations ready for conversion to LLVM IR calls

### Testing Setup
- Created comprehensive test in openshmemops.mlir that converts MLIR to LLVM IR
- Simplified test.sh script to focus on conversion pipeline
- Test validates that OpenSHMEM operations can be lowered to actual library calls

### Conversion Pass Implementation
- Created OpenSHMEMToLLVM conversion pass following MPI pattern
- Implemented conversion patterns for shmem_init and shmem_finalize operations
- Added proper build system integration in Conversion CMakeLists.txt
- Pass converts OpenSHMEM operations to LLVM function calls (shmem_init(), shmem_finalize())


## 06/18/2025

### OpenSHMEM Dialect Refinement
- Removed `OpenSHMEM_SymmetricCastOp` from the dialect; all symmetric memory is now produced only by `openshmem.malloc`.
- Clarified that `!openshmem.symmetric_memref<T>` is a distinct type, not interchangeable with standard `memref<T>`.
- Updated lowering: all OpenSHMEM ops treat `symmetric_memref` as a pointer at the LLVM level.
- Standard MLIR memref operations (e.g., `memref.atomic_rmw`) do **not** apply to `symmetric_memref`.
- All OpenSHMEM put/get/free ops require `symmetric_memref` for symmetric memory arguments.


## 06/19/2025

### Symmetric Implementation
- Updated OpenSHMEM dialect to use blocking put/get operations matching the OpenSHMEM C API.
- Ensured `openshmem.malloc` returns a pointer type (`!llvm.ptr`) representing symmetric memory.
- Lowered all symmetric memory operations (put/get/free) to use raw pointers in LLVM IR.
- Validated the lowering pipeline with tests: all OpenSHMEM ops are correctly converted, and the final LLVM IR uses only pointers for symmetric memory, matching the C API.
- Removed unused code (e.g., `getRawPtrAndSize`) and ensured no memref or dialect-specific types remain after lowering.
- Confirmed that the symmetric heap is now fully and correctly supported in the dialect and lowering pipeline.

## 06/23/2025

### InjectNumPEsPass Implementation
- Implemented `InjectNumPEsPass` that injects or overrides the `openshmem.num_pes` module attribute
- Added pass definition in `Passes.td` with `--num-pes` option (defaults to -1, meaning no injection)
- Created `InjectNumPEsPass.cpp` with proper MLIR pass infrastructure integration
- Pass only injects attribute when `num-pes > 0`, allowing compile-time specification of PE count for optimizations
- Used old-style `GEN_PASS_CLASSES` approach for TableGen code generation to avoid constructor issues

### Pass Registration Infrastructure
- Fixed OpenSHMEM pass registration by properly organizing TableGen includes in header files
- Created `Passes.h` with `GEN_PASS_DECL` and `GEN_PASS_REGISTRATION` inside `openshmem` namespace
- Created minimal `Passes.cpp` implementation file (registration now handled in header)
- Added OpenSHMEM passes to `InitAllPasses.h` with proper `openshmem::registerOpenSHMEMPasses()` call
- Removed redundant manual library entries from `mlir-opt` CMakeLists.txt (libraries auto-registered via global properties)

### Testing and Validation
- Created comprehensive test files: `inject-num-pes.mlir`, `inject-num-pes-no-option.mlir`, `inject-num-pes-optimization-example.mlir`
- Created `test-inject-pass.sh` script with before/after output display for clear validation
- Updated main `test.sh` script to include InjectNumPEsPass testing alongside existing functionality
- Removed all emojis from test scripts for more professional output
- Verified pass works correctly: injects attribute when option provided, does nothing when option omitted
- Confirmed pass integrates properly with LLVM lowering pipeline and other OpenSHMEM passes

### Technical Details
- Pass operates on any `Operation*` and sets module-level attribute via `op->setAttr()`
- Uses `Builder::getI32IntegerAttr()` to create the integer attribute value
- Follows MLIR pass infrastructure patterns for option handling and registration
- Pass syntax: `--openshmem-inject-num-pes="num-pes=N"` where N is the desired PE count
