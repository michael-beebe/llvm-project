# OpenSHMEM Dialect Modularization Guide

This document outlines the strategy for modularizing the OpenSHMEM MLIR dialect to improve maintainability and organization.

## Overview

The original `OpenSHMEMOps.td` and `OpenSHMEMToLLVM.cpp` files have grown large (2100+ lines and 1900+ lines respectively). This modularization breaks them into logical, category-based modules.

## File Structure

### TableGen Files (`.td`)

```
mlir/include/mlir/Dialect/OpenSHMEM/IR/
├── OpenSHMEM.td                    # Main dialect definition (unchanged)
├── OpenSHMEMTypes.td               # Type definitions (unchanged)
├── OpenSHMEMBase.td                # Base operations and traits ✓ CREATED
├── OpenSHMEMSetup.td               # Init, finalize, query ops ✓ CREATED
├── OpenSHMEMMemory.td              # Memory allocation/deallocation ✓ CREATED
├── OpenSHMEMRMAOps.td              # Put/Get operations (RMA)
├── OpenSHMEMCollectives.td         # Collective operations
├── OpenSHMEMTeams.td               # Team operations
├── OpenSHMEMContexts.td            # Context operations
├── OpenSHMEMAtomics.td             # Atomic operations
├── OpenSHMEMSync.td                # Synchronization operations
└── OpenSHMEMOps.td                 # Main include file ✓ UPDATED
```

### C++ Conversion Files

```
mlir/lib/Conversion/OpenSHMEMToLLVM/
├── OpenSHMEMToLLVM.cpp             # Main pass and registration ✓ UPDATED
├── SetupOpsToLLVM.h                # Header for setup ops ✓ CREATED
├── SetupOpsToLLVM.cpp              # Init, finalize, query ops ✓ CREATED
├── MemoryOpsToLLVM.h               # Header for memory ops
├── MemoryOpsToLLVM.cpp             # Memory allocation/deallocation
├── RMAOpsToLLVM.h                  # Header for RMA ops
├── RMAOpsToLLVM.cpp                # Put/Get operations
├── CollectiveOpsToLLVM.h           # Header for collective ops
├── CollectiveOpsToLLVM.cpp         # Collective operations
├── TeamOpsToLLVM.h                 # Header for team ops
├── TeamOpsToLLVM.cpp               # Team operations
├── ContextOpsToLLVM.h              # Header for context ops
├── ContextOpsToLLVM.cpp            # Context operations
├── AtomicOpsToLLVM.h               # Header for atomic ops
├── AtomicOpsToLLVM.cpp             # Atomic operations
├── SyncOpsToLLVM.h                 # Header for sync ops
└── SyncOpsToLLVM.cpp               # Synchronization operations
```

## Categorization Strategy

### 1. Setup Operations (`SetupOps`)
- `init` - Initialize OpenSHMEM library
- `finalize` - Finalize OpenSHMEM library  
- `my_pe` - Get current PE number
- `n_pes` - Get total number of PEs

### 2. Memory Operations (`MemoryOps`)
- `malloc` - Allocate symmetric memory
- `free` - Free symmetric memory
- Future: `realloc`, `align`, `calloc`

### 3. RMA Operations (`RMAOps`)
- `put` variants (typed, sized, context-aware, non-blocking)
- `get` variants (typed, sized, context-aware, non-blocking)
- `putmem` / `getmem` (untyped memory operations)

### 4. Collective Operations (`CollectiveOps`)
- `alltoallmem` / `alltoallsmem`
- `broadcastmem`
- `collectmem` / `fcollectmem`
- Future: typed collectives, reductions

### 5. Team Operations (`TeamOps`)
- `team_split_strided` / `team_split_2d`
- `team_my_pe` / `team_n_pes`
- `team_sync` / `team_destroy`
- `team_world` / `team_shared` (predefined teams)

### 6. Context Operations (`ContextOps`)
- `ctx_create` / `team_create_ctx`
- `ctx_destroy`
- `ctx_get_team`

### 7. Atomic Operations (`AtomicOps`)
- `atomic_fetch` / `ctx_atomic_fetch`
- `atomic_set` / `ctx_atomic_set`
- Future: other atomic operations

### 8. Synchronization Operations (`SyncOps`)
- `barrier_all` / `barrier` (deprecated)
- `quiet`
- Future: fence, locks, point-to-point synchronization

## Implementation Steps

### Phase 1: TableGen Modularization ✓ STARTED
1. ✅ Create `OpenSHMEMBase.td` with common definitions
2. ✅ Create `OpenSHMEMSetup.td` for setup operations
3. ✅ Create `OpenSHMEMMemory.td` for memory operations
4. ✅ Update main `OpenSHMEMOps.td` to include modular files
5. ⏳ Create remaining category-specific `.td` files
6. ⏳ Move appropriate operations from original file to new files

### Phase 2: C++ Conversion Modularization ✓ STARTED
1. ✅ Create header files for each category
2. ✅ Create `SetupOpsToLLVM.cpp` with setup operation patterns
3. ✅ Update main `OpenSHMEMToLLVM.cpp` to use modular patterns
4. ⏳ Create remaining category-specific `.cpp` files
5. ⏳ Move patterns from main file to category files
6. ⏳ Update pattern population to call modular functions

### Phase 3: Build System Updates
1. ⏳ Update `CMakeLists.txt` to include new source files
2. ⏳ Verify compilation and tests

### Phase 4: Testing and Validation
1. ⏳ Ensure all existing tests pass
2. ⏳ Add any missing test coverage for new modular structure

## Benefits

1. **Maintainability**: Smaller, focused files are easier to understand and modify
2. **Parallel Development**: Multiple developers can work on different categories simultaneously
3. **Reduced Merge Conflicts**: Changes to different operation categories won't conflict
4. **Better Organization**: Related operations are grouped together logically
5. **Incremental Development**: New operation categories can be added without modifying existing files
6. **Code Reuse**: Common utilities can be shared across modules

## Migration Strategy

### For Developers
1. Find the operation you're working on in the original files
2. Determine its category based on the categorization above
3. Look for the operation in the appropriate modular file
4. If not yet moved, move it following the established pattern

### For New Operations
1. Determine the appropriate category
2. Add the TableGen definition to the corresponding `.td` file
3. Add the conversion pattern to the corresponding `.cpp` file
4. Add the pattern to the population function

## Example: Moving an Operation

### TableGen (RMA Operation)
```tablegen
// In OpenSHMEMRMAOps.td
def OpenSHMEM_PutOp : OpenSHMEM_Op<"put", []> {
  // ... existing definition
};
```

### C++ Conversion
```cpp
// In RMAOpsToLLVM.h
namespace openshmem {
void populateRMAOpsToLLVMConversionPatterns(LLVMTypeConverter &converter,
                                            RewritePatternSet &patterns);
}

// In RMAOpsToLLVM.cpp
struct PutOpLowering : public ConvertOpToLLVMPattern<openshmem::PutOp> {
  // ... existing pattern
};

void openshmem::populateRMAOpsToLLVMConversionPatterns(
    LLVMTypeConverter &converter, RewritePatternSet &patterns) {
  patterns.add<PutOpLowering, GetOpLowering, ...>(converter);
}
```

### Main File Update
```cpp
// In OpenSHMEMToLLVM.cpp
#include "RMAOpsToLLVM.h"

void openshmem::populateOpenSHMEMToLLVMConversionPatterns(...) {
  // ...
  populateRMAOpsToLLVMConversionPatterns(converter, patterns);
  // ...
}
```

## Status

- ✅ Phase 1 Started: Base structure and setup operations modularized
- ✅ Phase 2 Started: Setup operations conversion patterns modularized
- ⏳ Remaining categories need to be modularized
- ⏳ Build system needs to be updated
- ⏳ Testing and validation needed

This modularization will significantly improve the maintainability and organization of the OpenSHMEM dialect while preserving all existing functionality. 