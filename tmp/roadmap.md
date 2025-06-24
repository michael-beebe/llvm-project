# Project Plan: OpenSHMEM MLIR Dialect Proof-of-Concept

**Author:** Michael Beebe  
**Date:** Summer 2025

## Overview

This project develops a proof-of-concept OpenSHMEM MLIR dialect to model OpenSHMEM's partitioned global address space (PGAS) primitives. The dialect includes `shmem_put` and `shmem_get` operations, a symmetric memory type, a C-to-MLIR conversion, a lowering pass to OpenSHMEM library calls, a communication coalescing pass, and tests. The goal is a working prototype that processes C programs and benchmarks, enabling a 5–10 page paper for the LLVM-HPC Workshop at SC 2025 (deadline: August 15, 2025). The project is implemented in a fork of `llvm-project` (main branch, https://github.com/llvm/llvm-project).

## Roadmap/To-Do List

The following tasks are required to complete the project, mapped to `llvm-project` directories.

1. **Set Up Fork and Study MLIR** [COMPLETE]

   - Fork `llvm-project`, clone locally, configure build (CMake, Ninja).
   - Study MLIR via Toy Tutorial (https://mlir.llvm.org/docs/Tutorials/Toy).
   - Post RFC on LLVM Discourse (https://discourse.llvm.org).
   - _Directory_: None (repository root).

2. **Define Operations** [COMPLETE]

   - Define `shmem_put` and `shmem_get` in TableGen (e.g., `shmem.put dest, src, size, pe`).
   - Implement the symmetric heap somehow (IMPORTANT)
      - Use `memref` for symmetric memory or define `shmem.symmem`.
   - Reference MPI dialect (`mlir/include/mlir/Dialect/MPI/MPIOps.td`).
   - _Directory_: `mlir/include/mlir/Dialect/OpenSHMEM` (`OpenSHMEMOps.td`, `OpenSHMEMOps.h`).

3. **Design Type System** [COMPLETE]

   - _Directory_: `mlir/include/mlir/Dialect/OpenSHMEM` (`OpenSHMEMTypes.td`, `OpenSHMEMTypes.h`).

4. **Implement Operation Semantics** [COMPLETE]

   - **NOT STARTED**: Full C++ implementation for parsing, verification, and canonicalization.
   - **NOT STARTED**: Follow MPI dialect patterns for operation structure and verification.
   - _Directory_: `mlir/lib/Dialect/OpenSHMEM` (`OpenSHMEMOps.cpp`).

5. **Memory Model & Synchronization** [NOT STARTED]

   - Add `shmem_fence`, `shmem_quiet`, `shmem_barrier_all` operations for memory ordering.
   - Implement memory ordering attributes (acquire, release, etc.).
   - Integrate with MLIR's memory effect interfaces.
   - _Directory_: `mlir/include/mlir/Dialect/OpenSHMEM` (`OpenSHMEMOps.td`), `mlir/lib/Dialect/OpenSHMEM` (`OpenSHMEMOps.cpp`).

6. **Error Handling & Diagnostics** [NOT STARTED]

   - Implement proper error messages for invalid operations.
   - Add diagnostic support for type mismatches and invalid memory spaces.
   - Create custom diagnostic categories for OpenSHMEM-specific errors.
   - _Directory_: `mlir/lib/Dialect/OpenSHMEM` (`OpenSHMEMOps.cpp`).

7. **Develop Lowering Pass** [NOT STARTED]

   - Create a pass to lower `shmem.put` and `shmem.get` to OpenSHMEM library calls (e.g., `shmem_put`, `shmem_get`).
   - Use MLIR's `CallOp` for library invocation.
   - _Directory_: `mlir/lib/Conversion` (`OpenSHMEMToLLVM.cpp`).

8. **Implement C-to-MLIR Conversion** [NOT STARTED]

   - Modify Clang to emit OpenSHMEM dialect operations for `shmem_put` and `shmem_get` C calls.
   - Update AST-to-MLIR lowering, mapping API calls to `shmem.put`, `shmem.get`.
   - Reference OpenMP handling (`clang/lib/CodeGen/CGOpenMPRuntime.cpp`).
   - _Directory_: `clang/lib/CodeGen`.

9. **Documentation** [NOT STARTED]

   - Create dialect documentation with operation descriptions and examples.
   - Write developer guide for extending the dialect.
   - Document design decisions and limitations.
   - _Directory_: `mlir/docs/Dialects/OpenSHMEM.md`.

10. **Implement Coalescing Pass** [NOT STARTED]

    - Develop a pass to merge consecutive `shmem.put` operations to the same PE into one.
    - Use `RewritePattern`, inspired by `mlir/lib/Transforms/Canonicalizer.cpp`.
    - _Directory_: `mlir/lib/Dialect/OpenSHMEM` (`OpenSHMEMCoalesce.cpp`).

11. **Write Tests** [NOT STARTED]

    - **NOT STARTED**: Basic test infrastructure with 6 test files covering core operations.
    - **NOT STARTED**: All tests pass with `mlir-opt` validation.
    - **NOT STARTED**: Comprehensive coverage of PE operations, memory operations, basic functionality.
    - **TODO**: Integration tests with coalescing pass, performance benchmarks.
    - _Directory_: `mlir/test/Dialect/OpenSHMEM` (`basic_ops.mlir`, `pe_ops.mlir`, etc.).

12. **Integration Testing Strategy** [NOT STARTED]

    - Test with real OpenSHMEM implementations (e.g., OpenMPI, Cray).
    - Validate performance improvements with actual applications.
    - Create regression test suite for dialect evolution.
    - _Directory_: `mlir/test/Integration/OpenSHMEM`.

13. **Performance Validation** [NOT STARTED]

    - Benchmark coalescing pass effectiveness using `bench_multiple_puts`.
    - Implement 2D heat equation stencil to demonstrate boundary exchange optimization.
    - Compare generated code quality against hand-optimized OpenSHMEM stencil implementations.
    - Measure communication volume reduction and computation-communication overlap effectiveness.
    - Profile compilation time impact of new dialect.
    - _Directory_: `mlir/test/Benchmarks/OpenSHMEM`.

14. **Update Build System** [NOT STARTED]

    - **NOT STARTED**: Full CMake integration with LLVM build system.
    - **NOT STARTED**: Optimized build script (`tmp/build.sh`) with multiple build configurations.
    - **NOT STARTED**: Proper dialect registration and tool integration.
    - **FIXED**: All compilation issues resolved, dialect builds successfully.
    - _Directory_: `mlir/CMakeLists.txt`, `mlir/lib/Dialect/OpenSHMEM/CMakeLists.txt`.

15. **Submit Pull Request**

    - Push code to fork's branch (`openshmem-dialect`).
    - Submit PR to `llvm-project/main` per https://llvm.org/docs/Contributing.html.
    - _Directory_: None (GitHub fork).

16. **Write Paper**
    - Draft a 5–10 page paper for LLVM-HPC Workshop, including dialect design, coalescing pass, and benchmark results.
    - Submit by August 15, 2025.
    - _Directory_: External (paper).

## Major Architectural Decisions Made

### Type System Simplification (Following MPI Pattern)
**Decision**: Replaced custom OpenSHMEM types (`!openshmem.pe`, `!openshmem.size`) with standard MLIR types (`i32`, `i64`).

**Rationale**: 
- Aligns with established MLIR dialect patterns (GPU, MPI, etc.)
- Eliminates complexity of type conversion operations
- Reduces cognitive overhead for developers
- Follows MLIR best practices of using custom types only for opaque handles

**Impact**: 
- Removed 4 type conversion operations that were no longer needed
- Simplified all operation signatures
- Maintained type safety only where truly important (symmetric memory)

### Build and Compilation Infrastructure
**Status**: Fully operational with optimized developer workflow.
- Clean separation of MLIR-only vs. full builds
- Robust error handling and dependency management  
- Comprehensive test validation pipeline

## C Benchmark Integration

The dialect will process C programs via Clang, converting OpenSHMEM calls (e.g., `shmem_put`) to MLIR IR. A modified benchmark, `bench_multiple_puts`, tests the coalescing pass:

```c
#include <shmem.h>
void bench_multiple_puts(int elem_count, int ntimes) {
  shmem_init();
  int dest_pe = (shmem_my_pe() + 1) % shmem_n_pes();
  long *source = shmem_malloc(3 * elem_count * sizeof(long));
  long *dest = shmem_malloc(3 * elem_count * sizeof(long));
  for (int i = 0; i < ntimes; i++) {
    shmem_put(&dest[0], &source[0], elem_count, dest_pe);
    shmem_put(&dest[elem_count], &source[elem_count], elem_count, dest_pe);
    shmem_put(&dest[2 * elem_count], &source[2 * elem_count], elem_count, dest_pe);
    shmem_quiet();
  }
  shmem_free(source); shmem_free(dest); shmem_finalize();
}
```

The coalescing pass merges the three `shmem_put` calls into one, reducing latency. Tests measure performance on a cluster.

## Stencil Computing as Primary Validation Target

The 2D heat equation provides an ideal validation case for demonstrating the dialect's optimization capabilities in a realistic scientific computing context. This application represents a broad class of stencil computations that are fundamental to computational science, including computational fluid dynamics, climate modeling, and materials simulation.

In a typical 2D heat equation implementation using OpenSHMEM, each PE manages a subdomain of the overall grid and must exchange boundary values with its four neighbors at every timestep. Traditional implementations require explicit management of communication phases:

```c
// Traditional approach - separate communication phases
shmem_put(north_neighbor_data, local_south_boundary, boundary_size, north_pe);
shmem_put(south_neighbor_data, local_north_boundary, boundary_size, south_pe);
shmem_put(east_neighbor_data, local_west_boundary, boundary_size, east_pe);
shmem_put(west_neighbor_data, local_east_boundary, boundary_size, west_pe);
shmem_quiet();  // Wait for all communications to complete
compute_interior_points();
compute_boundary_points();
```

The OpenSHMEM MLIR dialect can optimize this pattern by automatically coalescing boundary exchanges, overlapping communication with interior computation, and prefetching data for future timesteps. These optimizations are particularly valuable for stencil codes because they are communication-intensive and highly sensitive to latency and bandwidth efficiency.

For validation purposes, the 2D heat equation offers several advantages: it has a well-understood analytical solution for verification, exhibits clear performance scaling characteristics, and represents communication patterns found in many production scientific applications. The benchmark will compare dialect-generated code against both naive and hand-optimized OpenSHMEM implementations, measuring metrics such as communication volume reduction, achieved computation-communication overlap, and overall time-to-solution scaling.

## Discussion: Design Challenges and Open Questions

This section addresses fundamental design challenges and limitations of the OpenSHMEM MLIR dialect approach.

### Runtime vs. Compile-Time Information

One of the most fundamental challenges facing the OpenSHMEM MLIR dialect is the mismatch between OpenSHMEM's runtime execution model and MLIR's compile-time optimization framework. In traditional OpenSHMEM programming, the number of processing elements (PEs) is determined at job launch time through the MPI launcher (`mpirun -np 16 ./program`), and applications typically discover their PE count and identity through runtime calls to `shmem_n_pes()` and `shmem_my_pe()`. This runtime flexibility allows the same executable to run efficiently on different cluster configurations without recompilation.

However, MLIR's strength lies in compile-time analysis and optimization, where having static type information enables powerful transformations and verification. The current dialect implementation uses static `!openshmem.pe` types, which creates a fundamental tension: how can we optimize communication patterns when we don't know at compile time how many PEs will participate, or whether a particular PE number will be valid at runtime?

This problem extends beyond simple bounds checking. Many OpenSHMEM optimization opportunities depend on the PE count and topology. For instance, a coalescing pass might want to optimize differently for power-of-two PE counts versus prime numbers, or a stencil computation might benefit from different communication patterns on 2D vs. 3D PE arrangements. Without compile-time knowledge of these parameters, such optimizations become significantly more complex.

Several approaches could address this challenge, each with trade-offs. Parametric types like `!openshmem.pe<?>` could represent unknown PE counts while enabling the compiler to generate specialized code paths for different scenarios. Template specialization could generate optimized versions for common configurations (powers of 2, small counts), with fallback paths for arbitrary sizes. Alternatively, symbolic computation approaches could defer PE-dependent optimizations until link time or even runtime, though this would limit the scope of possible transformations.

### Symmetric Memory Type Safety

The OpenSHMEM memory model presents another significant design challenge that cuts to the heart of program correctness. OpenSHMEM distinguishes between two fundamentally different classes of memory: symmetric memory, which is allocated collectively across all PEs and accessible for remote operations, and local memory, which is private to each PE and cannot be accessed remotely. This distinction is not merely a performance consideration—it's a correctness requirement. Attempting to perform a `shmem_put` or `shmem_get` operation using a source or destination pointer that references local memory results in undefined behavior and typically runtime crashes.

Currently, the dialect implementation sidesteps this critical distinction by using `AnyMemRef` for all memory references, essentially treating all memory as equivalent. This approach is expedient for initial development but fundamentally unsafe, as it allows the compiler to accept programs like `shmem_put(dest, local_ptr, size, pe)` where `local_ptr` points to stack-allocated or heap-allocated local memory. Such programs would compile successfully but fail at runtime in subtle and hard-to-debug ways.

A robust solution requires embedding the symmetric vs. local distinction directly into the type system. The dialect should enforce that remote operations like `shmem_put` and `shmem_get` can only accept `!openshmem.symmetric_memref<T>` types for their memory operands, not arbitrary `memref` types. This approach would catch many programming errors at compile time rather than runtime. However, implementing this correctly requires careful tracking of memory provenance: when `shmem_malloc` allocates symmetric memory, the resulting pointer must carry that information in its type, and the type system must prevent any operations that could "launder" symmetric pointers through local memory references.

### Target Use Cases and Limitations

Understanding where the OpenSHMEM MLIR dialect will provide value—and where it won't—is crucial for setting realistic expectations and guiding development priorities. The dialect's primary value proposition lies not in replacing direct OpenSHMEM programming, but in serving as a compiler optimization and analysis tool for specific classes of HPC applications.

The dialect excels in scenarios with predictable, regular communication patterns that can benefit from compile-time analysis and optimization. Stencil computations, which are ubiquitous in scientific computing, represent an ideal target. These applications typically feature nearest-neighbor communication patterns where each PE communicates with a small, statically determinable set of neighbors based on grid topology. A 2D heat equation solver serves as an excellent concrete example: each PE requires boundary data from its four neighbors (north, south, east, west) at every timestep, creating a predictable communication pattern that traditional OpenSHMEM implementations handle with separate `shmem_put` calls for each boundary.

The dialect can analyze these stencil patterns to enable optimizations that would be difficult or impossible to implement safely by hand. Communication coalescing can combine multiple small boundary transfers into fewer, larger messages, reducing network overhead. More sophisticated analysis can automatically insert non-blocking communication operations and overlap boundary exchanges with interior computation, a optimization that requires careful dependency analysis to ensure correctness. The compiler can also prefetch boundary data for the next timestep while computing the current iteration, effectively pipelining the computation-communication cycle.

Perhaps most importantly, the dialect is well-suited for serving as a compilation target for higher-level domain-specific languages. Rather than expecting programmers to write MLIR directly, the dialect can serve as an intermediate representation for DSLs that automatically generate parallel code. In this model, tools like Halide for image processing or tensor computation frameworks could lower their high-level descriptions to OpenSHMEM operations, with the dialect providing a clean abstraction layer for optimization. A stencil DSL could express the 2D heat equation at a high level and rely on the dialect to generate efficient, optimized OpenSHMEM communication code automatically.

However, the dialect faces significant limitations in several important areas. Legacy code migration represents a particularly challenging case, as existing C and Fortran OpenSHMEM applications would require substantial rewriting to benefit from the dialect. The abstraction overhead and complexity of MLIR make it poorly suited for interactive development, where programmers want to quickly prototype and debug communication patterns. Applications with dynamic or irregular communication patterns—where the communication graph depends on runtime data—cannot benefit from compile-time optimization and may actually perform worse due to the additional abstraction layers.

### Integration Strategy Questions

**Ecosystem Fit**: How does this dialect integrate with existing HPC toolchains?

**Open Questions**:

- **Compiler Integration**: How to connect with existing OpenSHMEM implementations (OpenMPI, Cray, etc.)?
- **Runtime Overhead**: Will MLIR abstractions introduce performance penalties?
- **Developer Workflow**: Who writes MLIR OpenSHMEM code vs. generates it?
- **Debugging Story**: How to debug optimized MLIR-generated OpenSHMEM code?
- **Standards Compliance**: Relationship to OpenSHMEM specification versions?

### Missing Infrastructure Components

**Collective Operations**: The current dialect focuses on point-to-point operations but lacks:

- Barriers (`shmem_barrier_all`, `shmem_sync_all`)
- Reductions (`shmem_sum_reduce`, `shmem_max_reduce`)
- Broadcasts (`shmem_broadcast`)
- Active sets and teams for subset operations

**Memory Ordering**: Critical for correctness but not yet implemented:

- Fence operations (`shmem_fence`, `shmem_quiet`)
- Memory ordering attributes (acquire, release, relaxed)
- Integration with MLIR's memory effect interfaces

**Non-blocking Operations**: Limited support for asynchronous patterns:

- Completion tracking for non-blocking puts/gets
- Multiple outstanding operations management
- Overlap opportunities between computation and communication

### Performance and Scalability Concerns

The success of any compiler infrastructure ultimately depends on its ability to generate efficient code while maintaining reasonable compilation times, and the OpenSHMEM dialect faces several performance challenges that could limit its practical adoption. The complex type checking required to enforce symmetric memory safety, combined with sophisticated optimization passes for communication analysis, may significantly increase compilation times compared to direct OpenSHMEM compilation. For large HPC applications that can take hours to build even with traditional compilers, any substantial increase in compilation overhead could be a barrier to adoption.

Runtime performance presents an even more critical concern. The HPC community has spent decades optimizing OpenSHMEM implementations for specific network architectures, with vendors like Cray, Intel, and Mellanox providing highly tuned libraries that exploit hardware-specific features like InfiniBand RDMA capabilities or Cray Aries network topology. The additional abstraction layers introduced by MLIR compilation raise questions about whether generated code can match the performance of hand-tuned OpenSHMEM implementations. Moreover, preserving vendor-specific optimizations through the MLIR compilation pipeline may require significant engineering effort and close cooperation with OpenSHMEM implementers.

Scalability validation presents another dimension of concern. While the dialect may work well for moderate-scale applications, testing at true HPC scale—thousands or tens of thousands of PEs—may reveal fundamental limitations in the approach. Large symmetric memory allocations could stress the type system and memory management, while complex communication patterns involving many PEs might overwhelm optimization passes or produce suboptimal code. The dialect's usefulness ultimately depends on demonstrating that it can handle real-world HPC workloads at the scales where OpenSHMEM provides value over alternatives like MPI.

## Deliverables

- **Code**: Dialect, C-to-MLIR conversion, lowering and coalescing passes, tests.
- **Pull Request**: Submitted to `llvm-project/main`.
- **Paper**: 5–10 pages for LLVM-HPC Workshop, submitted by August 15, 2025.
- **Tests**: C benchmark demonstrating coalescing benefits.

## Discussion


