# Message Aggregation Pass Design

## Overview
A comprehensive message aggregation pass that analyzes and optimizes OpenSHMEM communication patterns across all RMA operation types.

## Architecture

### Core Components

1. **Memory Access Analyzer**
   - Tracks memory regions and access patterns
   - Identifies contiguous and strided access sequences
   - Handles both typed and untyped (memref) operations

2. **Communication Pattern Detector**
   - Groups operations by target PE
   - Identifies batchable operation sequences
   - Recognizes common communication idioms (halo exchanges, broadcasts, etc.)

3. **Dependency Analyzer**
   - Ensures memory safety during coalescing
   - Respects OpenSHMEM ordering semantics
   - Handles context boundaries and synchronization points

4. **Transformation Engine**
   - Applies coalescing transformations
   - Generates optimized communication sequences
   - Maintains correctness invariants

### Operation Coverage

#### Primary RMA Operations
- `putmem`, `getmem` - Untyped byte-level transfers
- `put`, `get` - Typed element transfers  
- `put_nbi`, `get_nbi` - Non-blocking variants
- `p`, `g` - Single element transfers

#### Sized Operations
- `put8/16/32/64/128` and corresponding gets
- Context-aware variants (`ctx_*`)

#### Analysis Considerations
- **Memory Layout**: Track base addresses, offsets, strides
- **Data Types**: Consider element sizes for typed operations
- **Contexts**: Respect context isolation boundaries
- **Synchronization**: Handle `quiet`, `fence`, barriers

### Transformation Patterns

#### 1. Contiguous Coalescing
```mlir
// Before
openshmem.putmem(%dest, %src1, %size1, %pe)
openshmem.putmem(%dest+offset, %src2, %size2, %pe)

// After  
openshmem.putmem(%dest, %coalesced_src, %total_size, %pe)
```

#### 2. Same-Target Batching
```mlir
// Before
openshmem.put(%dest1, %src1, %nelems1, %pe)
openshmem.put(%dest2, %src2, %nelems2, %pe)

// After (if memory layout allows)
openshmem.put(%batched_dest, %batched_src, %total_nelems, %pe)
```

#### 3. Cross-Operation Optimization
```mlir
// Before
openshmem.put32(%dest1, %src1, %nelems1, %pe)
openshmem.put32(%dest2, %src2, %nelems2, %pe)

// After
openshmem.put64(%optimized_dest, %optimized_src, %nelems_64, %pe)
```

#### 4. Non-blocking Conversion
```mlir
// Before
openshmem.put(%dest1, %src1, %nelems1, %pe)
compute_independent_work()
openshmem.put(%dest2, %src2, %nelems2, %pe)

// After
openshmem.put_nbi(%dest1, %src1, %nelems1, %pe)
compute_independent_work()
openshmem.put_nbi(%dest2, %src2, %nelems2, %pe)
openshmem.quiet
```

### Implementation Phases

#### Phase 1: Basic Contiguous Coalescing
- Handle simple consecutive operations
- Same operation type, same PE target
- Contiguous memory regions

#### Phase 2: Advanced Pattern Recognition  
- Cross-operation type coalescing
- Strided access pattern detection
- Non-contiguous but optimizable patterns

#### Phase 3: Context and Synchronization Awareness
- Respect context boundaries
- Handle synchronization semantics
- Optimize across synchronization points where safe

#### Phase 4: Performance Heuristics
- Cost models for transformation decisions
- Target-specific optimizations
- Adaptive thresholds based on message sizes

### Safety Constraints

1. **Memory Safety**
   - No overlapping source/destination conflicts
   - Preserve aliasing semantics
   - Respect memory coherency requirements

2. **OpenSHMEM Semantics**
   - Maintain ordering within contexts
   - Preserve completion semantics
   - Respect team and synchronization boundaries

3. **Correctness Invariants**
   - Data race freedom
   - Equivalent observable behavior
   - Exception safety (if applicable)

### Configuration Options

- **Coalescing thresholds**: Minimum/maximum message sizes
- **Pattern detection depth**: How far to look for coalescable operations  
- **Target-specific parameters**: Network/hardware specific optimizations
- **Debug/analysis modes**: Detailed reporting of transformation decisions 