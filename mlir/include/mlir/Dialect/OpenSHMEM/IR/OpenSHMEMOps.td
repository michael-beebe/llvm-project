//===- OpenSHMEMOps.td - OpenSHMEM dialect operations ------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMOPS_TD
#define MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMOPS_TD

include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEM.td"
include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEMTypes.td"
include "mlir/Interfaces/SideEffectInterfaces.td"

include "mlir/IR/BuiltinTypes.td"

//----------------------------------
// TODO: REMAINING OPERATIONS
//----------------------------------
// - shmem_realloc, shmem_align, shmem_calloc
// - shmem_p, shmem_g
// - atomics
// - context-aware atomics
// - typed collectives
// - reductions
// - pt2pt synch operations
// - lock/unlock
// - fence
// - context-aware rma
// - signaling

//===----------------------------------------------------------------------===//
// Traits
//===----------------------------------------------------------------------===//

// TODO: add traits for collective, etc.

//===----------------------------------------------------------------------===//
// Base OpenSHMEM operation
//===----------------------------------------------------------------------===//

class OpenSHMEM_Op<string mnemonic, list<Trait> traits = []>
    : Op<OpenSHMEM_Dialect, mnemonic, traits>;

//===----------------------------------------------------------------------===//
// InitOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_InitOp : OpenSHMEM_Op<"init", []> {
  let summary = "Initialize the OpenSHMEM library";
  let description = [{
    This operation initializes the OpenSHMEM runtime environment.
    It must be called before any other OpenSHMEM operations.
    
    Signature:
    ```c
    void shmem_init(void);
    ```
  }];
  let assemblyFormat = "attr-dict";
}

//===----------------------------------------------------------------------===//
// FinalizeOp  
//===----------------------------------------------------------------------===//

def OpenSHMEM_FinalizeOp : OpenSHMEM_Op<"finalize", []> {
  let summary = "Finalize the OpenSHMEM library";
  let description = [{
    This operation finalizes the OpenSHMEM runtime environment.
    It should be called before program termination.
    
    Signature:
    ```c
    void shmem_finalize(void);
    ```
  }];
  let assemblyFormat = "attr-dict";
}

//===----------------------------------------------------------------------===//
// MyPeOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_MyPeOp : OpenSHMEM_Op<"my_pe", []> {
  let summary = "Get the current PE (Processing Element) number";
  let description = [{
    This operation returns the number of the calling PE. PEs are numbered 
    from 0 to n_pes()-1, where n_pes() is the total number of PEs.
    
    Signature:
    ```c
    int shmem_my_pe(void);
    ```
  }];

  let results = (outs I32:$pe);
  let assemblyFormat = "attr-dict `:` type($pe)";
}

//===----------------------------------------------------------------------===//
// NPesOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_NPesOp : OpenSHMEM_Op<"n_pes", []> {
  let summary = "Get the total number of PEs";
  let description = [{
    This operation returns the total number of PEs in the OpenSHMEM program.
    
    Signature:
    ```c
    int shmem_n_pes(void);
    ```
  }];

  let results = (outs I32:$n_pes);
  let assemblyFormat = "attr-dict `:` type($n_pes)";
}

//===----------------------------------------------------------------------===//
// MallocOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_MallocOp : OpenSHMEM_Op<"malloc", []> {
  let summary = "Allocate symmetric memory";
  let description = [{
    This operation allocates symmetric memory that is accessible from all PEs.
    The allocated memory can be used in putmem/getmem operations. The size parameter
    specifies the number of bytes to allocate.
    
    This is a collective operation - all PEs must participate. The returned
    memory reference points to symmetric memory that has the same virtual
    address on all PEs.
    
    Arguments:
    - size: Number of bytes to allocate (index)
    
    Results:
    - ptr: A symmetric memory reference containing the allocated memory
    
    Signature:
    ```c
    void *shmem_malloc(size_t size);
    ```
    
    This operation can optionally return an `i32` value that can be used
    to check for errors (0 for success, non-zero for failure).
  }];

  let arguments = (ins Index:$size);
  
  let results = (outs 
    OpenSHMEM_SymmetricMemRef:$ptr,
    Optional<I32>:$retval
  );
  
  let assemblyFormat = "`(` $size `)` attr-dict `:` type($size) `->` "
                       "type($ptr) (`,` type($retval)^)?";
}

//===----------------------------------------------------------------------===//
// FreeOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_FreeOp : OpenSHMEM_Op<"free", []> {
  let summary = "Free symmetric memory";
  let description = [{
    This operation frees symmetric memory that was previously allocated with
    openshmem.malloc. The memory reference must point to symmetric memory
    allocated by a previous malloc operation.
    
    This is a collective operation - all PEs must participate and free the
    same symmetric memory allocation.
    
    Arguments:
    - ptr: Memory reference to free (must be symmetric memory)
    
    Signature:
    ```c
    void shmem_free(void *ptr);
    ```
  }];
  
  let arguments = (ins OpenSHMEM_SymmetricMemRef:$ptr);
  let assemblyFormat = "`(` $ptr `)` attr-dict `:` type($ptr)";
}

//===----------------------------------------------------------------------===//
// BarrierAllOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_BarrierAllOp : OpenSHMEM_Op<"barrier_all", []> {
  let summary = "Barrier operation (matches shmem_barrier_all C API)";
  let description = [{
    This operation performs a barrier operation on all PEs in the program.
    It is a collective operation - all PEs must participate.

    Signature:
    ```c
    void shmem_barrier_all(void);
    ```
  }];

  let assemblyFormat = "attr-dict";
}

//===----------------------------------------------------------------------===//
// BarrierOp (deprecated, but kept for compatibility)
//===----------------------------------------------------------------------===//

def OpenSHMEM_BarrierOp : OpenSHMEM_Op<"barrier", []> {
  let summary = "Deprecated barrier operation";
  let description = [{
    This operation performs a barrier operation on a subset of PEs.
    This is deprecated in favor of team-based barriers.

    Arguments:
    - pe_start: Starting PE number in the active set
    - log_pe_stride: Log2 of the stride between PEs in the active set
    - pe_size: Number of PEs in the active set
    - psync: Symmetric memory array used for synchronization
             (must be allocated with openshmem.malloc)

    Signature:
    ```c
    void shmem_barrier(int PE_start, int logPE_stride, int PE_size, long *pSync);
    ```
    
    Note: The psync array must be initialized to SHMEM_SYNC_VALUE before use and
    must be allocated in symmetric memory accessible to all participating PEs.
  }];

  let arguments = (ins 
    I32 : $pe_start, 
    I32 : $log_pe_stride, 
    I32 : $pe_size, 
    OpenSHMEM_SymmetricMemRef : $psync
  );
  let assemblyFormat = "`(` $pe_start `,` $log_pe_stride `,` $pe_size `,` $psync `)` attr-dict `:` "
                       "type($pe_start) `,` type($log_pe_stride) `,` type($pe_size) `,` type($psync)";
}

//===----------------------------------------------------------------------===//
// QuietOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_QuietOp : OpenSHMEM_Op<"quiet", []> {
  let summary = "Quiet operation (matches shmem_quiet C API)";
  let description = [{
    This operation performs a quiet operation on the calling PE.
    It ensures that all previously issued put/get operations from the 
    calling PE have completed before returning.

    Signature:
    ```c
    void shmem_quiet(void);
    ```
  }];

  let assemblyFormat = "attr-dict";
}

//===----------------------------------------------------------------------===//
// Team Operations
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// TeamSplitStridedOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_TeamSplitStridedOp : OpenSHMEM_Op<"team_split_strided", []> {
  let summary = "Split a team into strided subteams";
  let description = [{
    This operation splits a parent team into subteams based on a strided pattern.
    PEs are assigned to subteams in a round-robin fashion with the specified stride.
    
    Arguments:
    - parent_team: The parent team to split
    - start: Starting PE number in the parent team
    - stride: Stride for PE assignment
    - size: Number of PEs in each subteam
    
    Results:
    - new_team: The new team that the calling PE belongs to (or null if not participating)
    - retval: Return value for error checking (0 for success, non-zero for failure)
    
    Signature:
    ```c
    int shmem_team_split_strided(shmem_team_t parent_team, int start, int stride, int size, 
                                const shmem_team_config_t *config, long config_mask, 
                                shmem_team_t *new_team);
    ```
  }];

  let arguments = (ins 
    OpenSHMEM_Team:$parent_team,
    I32:$start,
    I32:$stride, 
    I32:$size
  );
  
  let results = (outs 
    OpenSHMEM_Team:$new_team,
    I32:$retval
  );
  
  let assemblyFormat = "`(` $parent_team `,` $start `,` $stride `,` $size `)` attr-dict `:` "
                       "type($parent_team) `,` type($start) `,` type($stride) `,` type($size) `->` "
                       "type($new_team) `,` type($retval)";
}

//===----------------------------------------------------------------------===//
// TeamSplit2dOp  
//===----------------------------------------------------------------------===//

def OpenSHMEM_TeamSplit2dOp : OpenSHMEM_Op<"team_split_2d", []> {
  let summary = "Split a team into 2D subteams";
  let description = [{
    This operation splits a parent team into 2D subteams arranged in a grid pattern.
    Useful for organizing PEs in a 2D topology for stencil computations.
    
    Arguments:
    - parent_team: The parent team to split
    - xrange: Number of teams in the x dimension
    
    Results:
    - xaxis_team: Team containing PEs in the same row
    - yaxis_team: Team containing PEs in the same column
    - retval: Return value for error checking (0 for success, non-zero for failure)
    
    Signature:
    ```c
    int shmem_team_split_2d(shmem_team_t parent_team, int xrange,
                           const shmem_team_config_t *xaxis_config, long xaxis_mask,
                           shmem_team_t *xaxis_team,
                           const shmem_team_config_t *yaxis_config, long yaxis_mask,
                           shmem_team_t *yaxis_team);
    ```
  }];

  let arguments = (ins 
    OpenSHMEM_Team:$parent_team,
    I32:$xrange
  );
  
  let results = (outs 
    OpenSHMEM_Team:$xaxis_team,
    OpenSHMEM_Team:$yaxis_team,
    I32:$retval
  );
  
  let assemblyFormat = "`(` $parent_team `,` $xrange `)` attr-dict `:` "
                       "type($parent_team) `,` type($xrange) `->` "
                       "type($xaxis_team) `,` type($yaxis_team) `,` type($retval)";
}

//===----------------------------------------------------------------------===//
// TeamMyPeOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_TeamMyPeOp : OpenSHMEM_Op<"team_my_pe", []> {
  let summary = "Get PE number within a team";
  let description = [{
    This operation returns the PE number of the calling PE within the specified team.
    PE numbers within a team range from 0 to team_n_pes()-1.
    
    Arguments:
    - team: The team to query
    
    Results:
    - pe: PE number within the team
    
    Signature:
    ```c
    int shmem_team_my_pe(shmem_team_t team);
    ```
  }];

  let arguments = (ins OpenSHMEM_Team:$team);
  let results = (outs I32:$pe);
  let assemblyFormat = "`(` $team `)` attr-dict `:` type($team) `->` type($pe)";
}

//===----------------------------------------------------------------------===//
// TeamNPesOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_TeamNPesOp : OpenSHMEM_Op<"team_n_pes", []> {
  let summary = "Get number of PEs in a team";
  let description = [{
    This operation returns the total number  of PEs in the specified team.

                    Arguments : -team : The team to query

                                            Results : -n_pes
      : Number of PEs in the team

            Signature :
    ```c int shmem_team_n_pes(shmem_team_t team);
  ```
}];

let arguments = (ins OpenSHMEM_Team : $team);
let results = (outs I32 : $n_pes);
let assemblyFormat =
    "`(` $team `)` attr-dict `:` type($team) `->` type($n_pes)";
}

//===----------------------------------------------------------------------===//
// TeamSyncOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_TeamSyncOp : OpenSHMEM_Op<"team_sync", []> {
  let summary = "Synchronize all PEs in a team";
  let description = [{
    This operation performs a barrier synchronization on all PEs in the specified team.
    All PEs in the team must call this operation before any PE can continue.
    
    Arguments:
    - team: The team to synchronize
    
    Signature:
    ```c
    void shmem_team_sync(shmem_team_t team);
    ```
  }];

  let arguments = (ins OpenSHMEM_Team:$team);
  let assemblyFormat = "`(` $team `)` attr-dict `:` type($team)";
}

//===----------------------------------------------------------------------===//
// TeamDestroyOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_TeamDestroyOp : OpenSHMEM_Op<"team_destroy", []> {
  let summary = "Destroy a team";
  let description = [{
    This operation destroys a team that was previously created by a team split operation.
    After destruction, the team handle becomes invalid and should not be used.
    
    Arguments:
    - team: The team to destroy
    
    Signature:
    ```c
    void shmem_team_destroy(shmem_team_t team);
    ```
  }];

  let arguments = (ins OpenSHMEM_Team:$team);
  let assemblyFormat = "`(` $team `)` attr-dict `:` type($team)";
}

//===----------------------------------------------------------------------===//
// Predefined Teams
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// TeamWorldOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_TeamWorldOp : OpenSHMEM_Op<"team_world", []> {
  let summary = "Get the world team (all PEs)";
  let description = [{
    This operation returns a reference to the predefined world team that contains
    all PEs in the OpenSHMEM program. This is equivalent to SHMEM_TEAM_WORLD.
    
    Results:
    - team: The world team
  }];

  let results = (outs OpenSHMEM_Team:$team);
  let assemblyFormat = "attr-dict `->` type($team)";
}

//===----------------------------------------------------------------------===//
// TeamSharedOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_TeamSharedOp : OpenSHMEM_Op<"team_shared", []> {
  let summary = "Get the shared memory team";
  let description = [{
    This operation returns a reference to the predefined shared memory team.
    This team contains PEs that share memory and can perform optimized
    communication. This is equivalent to SHMEM_TEAM_SHARED.
    
    Results:
    - team: The shared memory team
  }];

  let results = (outs OpenSHMEM_Team:$team);
  let assemblyFormat = "attr-dict `->` type($team)";
}

//===----------------------------------------------------------------------===//
// CreateCtxOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_CtxCreateOp : OpenSHMEM_Op<"ctx_create", []> {
  let summary = "Create a new OpenSHMEM context";
  let description = [{
    This operation creates a new OpenSHMEM context with the given options.

    C API:
    ```c
    int shmem_ctx_create(long options, shmem_ctx_t *ctx);
    ```

    Arguments:
    - options: The set of options requested for the given context (i64).
    Multiple options may be requested by combining them with a bitwise OR
    operation; otherwise, 0 can be given if no options are requested.

    Results:
    - ctx: A handle to the newly created context (!openshmem.ctx).
    - status: Status code (i32), 0 for success, nonzero for failure.
  }];
  let arguments = (ins I64:$options);
  let results = (outs OpenSHMEM_Ctx:$ctx, I32:$status);
  let assemblyFormat = "`(` $options `)` attr-dict `:` type($options) `->` type($ctx) `,` type($status)";
}

//===----------------------------------------------------------------------===//
// TeamCreateCtxOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_TeamCreateCtxOp : OpenSHMEM_Op<"team_create_ctx", []> {
  let summary = "Create a new OpenSHMEM context for a team";
  let description = [{
    This operation creates a new OpenSHMEM context associated with the
    given team and options.

    C API:
    ```c
    int shmem_team_create_ctx(shmem_team_t team, long options, shmem_ctx_t *ctx);
    ```

    Arguments:
    - team: Handle to the specified PE team (!openshmem.team).
    - options: The set of options requested for the given context (i64).
    Multiple options may be requested by combining them with a bitwise OR operation;
    otherwise, 0 can be given if no options are requested.

    Results:
    - ctx: A handle to the newly created context (!openshmem.ctx).
    - status: Status code (i32), 0 for success, nonzero for failure.
  }];
  let arguments = (ins OpenSHMEM_Team:$team, I64:$options);
  let results = (outs OpenSHMEM_Ctx:$ctx, I32:$status);
  let assemblyFormat = "`(` $team `,` $options `)` attr-dict `:` type($team) `,` type($options) `->` type($ctx) `,` type($status)";
}

//===----------------------------------------------------------------------===//
// DestroyCtxOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_CtxDestroyOp : OpenSHMEM_Op<"ctx_destroy", []> {
  let summary = "Destroy an OpenSHMEM context";
  let description = [{
    This operation destroys an OpenSHMEM context that was previously created
    by ctx_create or team_create_ctx.

    C API:
    ```c
    void shmem_ctx_destroy(shmem_ctx_t ctx);
    ```

    Arguments:
    - ctx: Handle to the context that will be destroyed (!openshmem.ctx).
  }];
  let arguments = (ins OpenSHMEM_Ctx:$ctx);
  let assemblyFormat = "`(` $ctx `)` attr-dict `:` type($ctx)";
}

//===----------------------------------------------------------------------===//
// CtxGetTeamOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_CtxGetTeamOp : OpenSHMEM_Op<"ctx_get_team", []> {
  let summary = "Retrieve the team associated with a communication context";
  let description = [{
    This operation returns the team associated with the specified communication context.

    C API:
    ```c
    int shmem_ctx_get_team(shmem_ctx_t ctx, shmem_team_t *team);
    ```

    Arguments:
    - ctx: Handle to a communication context (!openshmem.ctx).

    Results:
    - team: Handle to the associated PE team (!openshmem.team).
    - status: Status code (i32), 0 for success, nonzero for failure.
  }];
  let arguments = (ins OpenSHMEM_Ctx:$ctx);
  let results = (outs OpenSHMEM_Team:$team, I32:$status);
  let assemblyFormat = "`(` $ctx `)` attr-dict `:` type($ctx) `->` type($team) `,` type($status)";
}

//===----------------------------------------------------------------------===//
// AlltoallmemOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_AlltoallmemOp : OpenSHMEM_Op<"alltoallmem", []> {
  let summary = "All-to-all communication";
  let description = [{
    This operation performs an all-to-all communication operation.
    
    Exchanges a fixed amount of contiguous data blocks between all pairs
    of PEs participating in the collective routine.

    Arguments:
    - team: The team to participate in
    - dest: Destination symmetric memory reference
    - source: Source symmetric memory reference
    - nelems: Number of elements to transfer

    Results:
    - retval: Return value for error checking (0 for success, non-zero for failure)

    Signature:
    ```c
    int shmem_alltoallmem(shmem_team_t team, void *dest, const void *source, size_t nelems);
    ```
  }];

  let arguments = (ins
    OpenSHMEM_Team:$team,
    OpenSHMEM_SymmetricMemRef:$dest,
    OpenSHMEM_SymmetricMemRef:$source,
    Index:$nelems
  );

  let assemblyFormat = "`(` $team `,` $dest `,` $source `,` $nelems `)` attr-dict `:` "
                       "type($team) `,` type($dest) `,` type($source) `,` type($nelems)";

  let results = (outs
    I32:$retval
  );

  let assemblyFormat = "`(` $team `,` $dest `,` $source `,` $nelems `)` attr-dict `:` "
                       "type($team) `,` type($dest) `,` type($source) `,` type($nelems) `->` "
                       "type($retval)";
}

//===----------------------------------------------------------------------===//
// AlltoallsmemOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_AlltoallsmemOp : OpenSHMEM_Op<"alltoallsmem", []> {
  let summary = "All-to-all communication";
  let description = [{
    This operation performs a strided all-to-all communication operation.

    Exchanges a fixed amount of strided data blocks between all pairs of
    PEs participating in the collective routine.

    Arguments:
    - team: The team to participate in
    - dest: Destination symmetric memory reference
    - source: Source symmetric memory reference
    - nelems: Number of elements to transfer
    - dst: Stride for destination memory
    - sst: Stride for source memory

    Results:
    - retval: Return value for error checking (0 for success, non-zero for failure)

    Signature:
    ```c
    int shmem_alltoallsmem(shmem_team_t team, void *dest, const void *source,
                        ptrdiff_t dst, ptrdiff_t sst, size_t nelems);
    ```
  }];

  let arguments = (ins
    OpenSHMEM_Team:$team,
    OpenSHMEM_SymmetricMemRef:$dest,
    OpenSHMEM_SymmetricMemRef:$source,
    Index:$dst,
    Index:$sst,
    Index:$nelems
  );

  let results = (outs
    I32:$retval
  );

  let assemblyFormat = "`(` $team `,` $dest `,` $source `,` $dst `,` $sst `,` $nelems `)` attr-dict `:` "
                       "type($team) `,` type($dest) `,` type($source) `,` type($dst) `,` type($sst) `,` type($nelems) `->` "
                       "type($retval)";
}

//===----------------------------------------------------------------------===//
// BroadcastmemOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_BroadcastmemOp : OpenSHMEM_Op<"broadcastmem", []> {
  let summary = "Broadcast a value to all PEs in a team";
  let description = [{
    This operation performs a broadcast operation on a value to all PEs in a team.

    Broadcasts a block of data from one PE to one or more destination PEs.

    Arguments:
    - team: The team to participate in
    - dest: Destination symmetric memory reference
    - source: Source symmetric memory reference
    - nelems: Number of elements to transfer
    - PE_root: Root PE number

    Results:
    - retval: Return value for error checking (0 for success, non-zero for failure)

    Signature:
    ```c
    int shmem_broadcastmem(shmem_team_t team, void *dest, const void *source,
                           size_t nelems, int PE_root);
    ```
  }];

  let arguments = (ins
    OpenSHMEM_Team:$team,
    OpenSHMEM_SymmetricMemRef:$dest,
    OpenSHMEM_SymmetricMemRef:$source,
    Index:$nelems,
    I32:$PE_root
  );

  let results = (outs
    I32:$retval
  );

  let assemblyFormat = "`(` $team `,` $dest `,` $source `,` $nelems `,` $PE_root `)` attr-dict `:` "
                       "type($team) `,` type($dest) `,` type($source) `,` type($nelems) `,` type($PE_root) `->` "
                       "type($retval)";
}

//===----------------------------------------------------------------------===//
// CollectmemOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_CollectmemOp : OpenSHMEM_Op<"collectmem", []> {
  let summary = "Collect a value from all PEs in a team";
  let description = [{
    This operation performs a collect operation on a value from all PEs in a team.

    Concatenates blocks of data from multiple PEs to an array in every PE
    participating in the collective routine.

    Arguments:
    - team: The team to participate in
    - dest: Destination symmetric memory reference
    - source: Source symmetric memory reference
    - nelems: Number of elements to transfer

    Results:
    - retval: Return value for error checking (0 for success, non-zero for failure)

    Signature:
    ```c
    int shmem_collectmem(shmem_team_t team, void *dest, const void *source, size_t nelems);
    ```
  }];

  let arguments = (ins
    OpenSHMEM_Team:$team,
    OpenSHMEM_SymmetricMemRef:$dest,
    OpenSHMEM_SymmetricMemRef:$source,
    Index:$nelems
  );

  let results = (outs
    I32:$retval
  );

  let assemblyFormat = "`(` $team `,` $dest `,` $source `,` $nelems `)` attr-dict `:` "
                       "type($team) `,` type($dest) `,` type($source) `,` type($nelems) `->` "
                       "type($retval)";
}

//===----------------------------------------------------------------------===//
// FCollectmemOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_FCollectmemOp : OpenSHMEM_Op<"fcollectmem", []> {
  let summary = "Collect a value from all PEs in a team";
  let description = [{
    This operation performs a fixed-size collect operation on a value from all PEs in a team.

    Concatenates blocks of data from multiple PEs to an array in every PE
    participating in the collective routine.

    Arguments:
    - team: The team to participate in
    - dest: Destination symmetric memory reference
    - source: Source symmetric memory reference
    - nelems: Number of elements to transfer

    Results:
    - retval: Return value for error checking (0 for success, non-zero for failure)

    Signature:
    ```c
    int shmem_fcollectmem(shmem_team_t team, void *dest, const void *source, size_t nelems);
    ```
  }];

  let arguments = (ins
    OpenSHMEM_Team:$team,
    OpenSHMEM_SymmetricMemRef:$dest,
    OpenSHMEM_SymmetricMemRef:$source,
    Index:$nelems
  );

  let results = (outs
    I32:$retval
  );

  let assemblyFormat = "`(` $team `,` $dest `,` $source `,` $nelems `)` attr-dict `:` "
                       "type($team) `,` type($dest) `,` type($source) `,` type($nelems) `->` "
                       "type($retval)";
}

//===----------------------------------------------------------------------===//
// Typed RMA Operations
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// PutOp (Typed - Generic)
//===----------------------------------------------------------------------===//

def OpenSHMEM_PutOp : OpenSHMEM_Op<"put", []> {
  let summary = "Typed blocking put operation (generic)";
  let description = [{
    This operation performs a typed blocking put, copying data from the source
    memory region on the calling PE to the destination symmetric memory region on 
    the target PE. The operation copies `nelems` elements of the specified type.
    
    This is the generic typed equivalent of putmem, providing type safety and better
    performance for known data types. The element type is inferred from the symmetric
    memref type.
    
    Arguments:
    - dest: Destination symmetric memory reference on the target PE
      (!openshmem.symmetric_memref<T> where T is a supported RMA type)
    - source: Source local memory reference on the calling PE (memref<T>)
    - nelems: Number of elements to transfer (index)
    - pe: Target PE number (i32)
    
    The element type T must be one of the supported OpenSHMEM RMA types.
    
    Signature:
    ```c
    void shmem_put(TYPE *dest, const TYPE *source, size_t nelems, int pe);
    ```
    where TYPE is one of the standard RMA types from Table 5.
  }];

  let arguments = (ins 
    OpenSHMEM_SymmetricMemRef:$dest,
    AnyMemRef:$source,
    Index:$nelems,
    I32:$pe
  );
  
  let assemblyFormat = "`(` $dest `,` $source `,` $nelems `,` $pe `)` attr-dict `:` "
                       "type($dest) `,` type($source) `,` type($nelems) `,` type($pe)";
}

//===----------------------------------------------------------------------===//
// CtxPutOp (Typed - Context-aware)
//===----------------------------------------------------------------------===//

def OpenSHMEM_CtxPutOp : OpenSHMEM_Op<"ctx_put", []> {
  let summary = "Typed blocking put operation with context";
  let description = [{
    This operation performs a typed blocking put with a specific context, copying data 
    from the source memory region on the calling PE to the destination symmetric memory 
    region on the target PE. The operation copies `nelems` elements of the specified type.
    
    Arguments:
    - ctx: OpenSHMEM context handle (!openshmem.ctx)
    - dest: Destination symmetric memory reference on the target PE
      (!openshmem.symmetric_memref<T> where T is a supported RMA type)
    - source: Source local memory reference on the calling PE (memref<T>)
    - nelems: Number of elements to transfer (index)
    - pe: Target PE number (i32)
    
    The element type T must be one of the supported OpenSHMEM RMA types.
    
    Signature:
    ```c
    void shmem_put(shmem_ctx_t ctx, TYPE *dest, const TYPE *source, size_t nelems, int pe);
    ```
    where TYPE is one of the standard RMA types from Table 5.
  }];

  let arguments = (ins 
    OpenSHMEM_Ctx:$ctx,
    OpenSHMEM_SymmetricMemRef:$dest,
    AnyMemRef:$source,
    Index:$nelems,
    I32:$pe
  );
  
  let assemblyFormat = "`(` $ctx `,` $dest `,` $source `,` $nelems `,` $pe `)` attr-dict `:` "
                       "type($ctx) `,` type($dest) `,` type($source) `,` type($nelems) `,` type($pe)";
}

//===----------------------------------------------------------------------===//
// PutNbiOp (Typed - Non-blocking)
//===----------------------------------------------------------------------===//

def OpenSHMEM_PutNbiOp : OpenSHMEM_Op<"put_nbi", []> {
  let summary = "Typed non-blocking put operation (generic)";
  let description = [{
    This operation performs a typed non-blocking put, copying data from the source
    memory region on the calling PE to the destination symmetric memory region on 
    the target PE. The operation copies `nelems` elements and returns immediately
    after the data has been copied out of the source array.
    
    This is the generic typed equivalent of putmem_nbi, providing type safety and better
    performance for known data types.
    
    Arguments:
    - dest: Destination symmetric memory reference on the target PE
      (!openshmem.symmetric_memref<T> where T is a supported RMA type)
    - source: Source local memory reference on the calling PE (memref<T>)
    - nelems: Number of elements to transfer (index)
    - pe: Target PE number (i32)
    
    The element type T must be one of the supported OpenSHMEM RMA types.
    
    Signature:
    ```c
    void shmem_put_n(TYPE *dest, const TYPE *source, size_t nelems, int pe);
    ```
    where TYPE is one of the standard RMA types from Table 5.
  }];

  let arguments = (ins 
    OpenSHMEM_SymmetricMemRef:$dest,
    AnyMemRef:$source,
    Index:$nelems,
    I32:$pe
  );
  
  let assemblyFormat = "`(` $dest `,` $source `,` $nelems `,` $pe `)` attr-dict `:` "
                       "type($dest) `,` type($source) `,` type($nelems) `,` type($pe)";
}

//===----------------------------------------------------------------------===//
// CtxPutNOp (Typed - Context-aware Non-blocking)
//===----------------------------------------------------------------------===//

def OpenSHMEM_CtxPutNbiOp : OpenSHMEM_Op<"ctx_put_nbi", []> {
  let summary = "Typed non-blocking put operation with context";
  let description = [{
    This operation performs a typed non-blocking put with a specific context, copying data 
    from the source memory region on the calling PE to the destination symmetric memory 
    region on the target PE. The operation copies `nelems` elements and returns immediately
    after the data has been copied out of the source array.
    
    Arguments:
    - ctx: OpenSHMEM context handle (!openshmem.ctx)
    - dest: Destination symmetric memory reference on the target PE
      (!openshmem.symmetric_memref<T> where T is a supported RMA type)
    - source: Source local memory reference on the calling PE (memref<T>)
    - nelems: Number of elements to transfer (index)
    - pe: Target PE number (i32)
    
    The element type T must be one of the supported OpenSHMEM RMA types.
    
    Signature:
    ```c
    void shmem_put_n(shmem_ctx_t ctx, TYPE *dest, const TYPE *source, size_t nelems, int pe);
    ```
    where TYPE is one of the standard RMA types from Table 5.
  }];

  let arguments = (ins 
    OpenSHMEM_Ctx:$ctx,
    OpenSHMEM_SymmetricMemRef:$dest,
    AnyMemRef:$source,
    Index:$nelems,
    I32:$pe
  );
  
  let assemblyFormat = "`(` $ctx `,` $dest `,` $source `,` $nelems `,` $pe `)` attr-dict `:` "
                       "type($ctx) `,` type($dest) `,` type($source) `,` type($nelems) `,` type($pe)";
}

//===----------------------------------------------------------------------===//
// PutSizedOp (Sized variants - 8, 16, 32, 64, 128)
//===----------------------------------------------------------------------===//

def OpenSHMEM_Put8Op : OpenSHMEM_Op<"put8", []> {
  let summary = "8-bit sized put operation";
  let description = [{
    This operation performs an 8-bit sized put operation, copying data from the source
    memory region on the calling PE to the destination symmetric memory region on 
    the target PE. The operation copies `nelems` bytes.
    
    Arguments:
    - dest: Destination symmetric memory reference on the target PE
      (!openshmem.symmetric_memref<i8>)
    - source: Source local memory reference on the calling PE (memref<i8>)
    - nelems: Number of bytes to transfer (index)
    - pe: Target PE number (i32)
    
    Signature:
    ```c
    void shmem_put8(void *dest, const void *source, size_t nelems, int pe);
    ```
  }];

  let arguments = (ins 
    OpenSHMEM_SymmetricMemRef:$dest,
    AnyMemRef:$source,
    Index:$nelems,
    I32:$pe
  );
  
  let assemblyFormat = "`(` $dest `,` $source `,` $nelems `,` $pe `)` attr-dict `:` "
                       "type($dest) `,` type($source) `,` type($nelems) `,` type($pe)";
}

def OpenSHMEM_Put16Op : OpenSHMEM_Op<"put16", []> {
  let summary = "16-bit sized put operation";
  let description = [{
    This operation performs a 16-bit sized put operation, copying data from the source
    memory region on the calling PE to the destination symmetric memory region on 
    the target PE. The operation copies `nelems` bytes.
    
    Arguments:
    - dest: Destination symmetric memory reference on the target PE
      (!openshmem.symmetric_memref<i16>)
    - source: Source local memory reference on the calling PE (memref<i16>)
    - nelems: Number of bytes to transfer (index)
    - pe: Target PE number (i32)
    
    Signature:
    ```c
    void shmem_put16(void *dest, const void *source, size_t nelems, int pe);
    ```
  }];

  let arguments = (ins 
    OpenSHMEM_SymmetricMemRef:$dest,
    AnyMemRef:$source,
    Index:$nelems,
    I32:$pe
  );
  
  let assemblyFormat = "`(` $dest `,` $source `,` $nelems `,` $pe `)` attr-dict `:` "
                       "type($dest) `,` type($source) `,` type($nelems) `,` type($pe)";
}

def OpenSHMEM_Put32Op : OpenSHMEM_Op<"put32", []> {
  let summary = "32-bit sized put operation";
  let description = [{
    This operation performs a 32-bit sized put operation, copying data from the source
    memory region on the calling PE to the destination symmetric memory region on 
    the target PE. The operation copies `nelems` bytes.
    
    Arguments:
    - dest: Destination symmetric memory reference on the target PE
      (!openshmem.symmetric_memref<i32>)
    - source: Source local memory reference on the calling PE (memref<i32>)
    - nelems: Number of bytes to transfer (index)
    - pe: Target PE number (i32)
    
    Signature:
    ```c
    void shmem_put32(void *dest, const void *source, size_t nelems, int pe);
    ```
  }];

  let arguments = (ins 
    OpenSHMEM_SymmetricMemRef:$dest,
    AnyMemRef:$source,
    Index:$nelems,
    I32:$pe
  );
  
  let assemblyFormat = "`(` $dest `,` $source `,` $nelems `,` $pe `)` attr-dict `:` "
                       "type($dest) `,` type($source) `,` type($nelems) `,` type($pe)";
}

def OpenSHMEM_Put64Op : OpenSHMEM_Op<"put64", []> {
  let summary = "64-bit sized put operation";
  let description = [{
    This operation performs a 64-bit sized put operation, copying data from the source
    memory region on the calling PE to the destination symmetric memory region on 
    the target PE. The operation copies `nelems` bytes.
    
    Arguments:
    - dest: Destination symmetric memory reference on the target PE
      (!openshmem.symmetric_memref<i64>)
    - source: Source local memory reference on the calling PE (memref<i64>)
    - nelems: Number of bytes to transfer (index)
    - pe: Target PE number (i32)
    
    Signature:
    ```c
    void shmem_put64(void *dest, const void *source, size_t nelems, int pe);
    ```
  }];

  let arguments = (ins 
    OpenSHMEM_SymmetricMemRef:$dest,
    AnyMemRef:$source,
    Index:$nelems,
    I32:$pe
  );
  
  let assemblyFormat = "`(` $dest `,` $source `,` $nelems `,` $pe `)` attr-dict `:` "
                       "type($dest) `,` type($source) `,` type($nelems) `,` type($pe)";
}

def OpenSHMEM_Put128Op : OpenSHMEM_Op<"put128", []> {
  let summary = "128-bit sized put operation";
  let description = [{
    This operation performs a 128-bit sized put operation, copying data from the source
    memory region on the calling PE to the destination symmetric memory region on 
    the target PE. The operation copies `nelems` bytes.
    
    Arguments:
    - dest: Destination symmetric memory reference on the target PE
      (!openshmem.symmetric_memref<f128> or vector type)
    - source: Source local memory reference on the calling PE (memref<f128> or vector type)
    - nelems: Number of bytes to transfer (index)
    - pe: Target PE number (i32)
    
    Signature:
    ```c
    void shmem_put128(void *dest, const void *source, size_t nelems, int pe);
    ```
  }];

  let arguments = (ins 
    OpenSHMEM_SymmetricMemRef:$dest,
    AnyMemRef:$source,
    Index:$nelems,
    I32:$pe
  );
  
  let assemblyFormat = "`(` $dest `,` $source `,` $nelems `,` $pe `)` attr-dict `:` "
                       "type($dest) `,` type($source) `,` type($nelems) `,` type($pe)";
}

//===----------------------------------------------------------------------===//
// PutmemOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_PutmemOp : OpenSHMEM_Op<"putmem", []> {
  let summary = "Blocking putmem operation (matches shmem_putmem C API)";
  let description = [{
    This operation performs a blocking putmem, copying raw memory from the source
    memory region on the calling PE to the destination symmetric memory region on 
    the target PE. The operation copies `size` bytes and returns only after the
    data has been copied out of the source array on the local PE.
    
    Arguments:
    - dest: Destination symmetric memory reference on the target 
      PE (!openshmem.symmetric_memref<T>)
    - src: Source local memory reference on the calling PE (any type)
   - size : Number of bytes to transfer(index) -
            pe : Target PE number(i32)

                     Signature :
    ```c void shmem_putmem(void * dest, const void * src, size_t nelems,
                            int pe);
  ```

      Note : For putmem operations,
             nelems represents the number of bytes to transfer.
}];

let arguments = (ins OpenSHMEM_SymmetricMemRef
                 : $dest, AnyType
                 : $src, Index
                 : $size, I32
                 : $pe);

let assemblyFormat = "`(` $dest `,` $src `,` $size `,` $pe `)` attr-dict `:` "
                     "type($dest) `,` type($src) `,` type($size) `,` type($pe)";
}

//===----------------------------------------------------------------------===//
// PutmemNbiOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_PutmemNbiOp : OpenSHMEM_Op<"putmem_nbi", []> {
  let summary = "Non-blocking putmem operation (matches shmem_putmem_nbi C API)";
  let description = [{
    This operation performs a non-blocking putmem, copying raw memory from the source
    memory region on the calling PE to the destination symmetric memory region on 
    the target PE. The operation copies `nelems` bytes and returns immediately after the
    data has been copied out of the source array on the local PE.

    The nonblocking put routines provide a method for copying data from a
    contiguous local data object to a data object on a specified PE. The
    nonblocking put routines return immediately after the data has been copied
    out of the source array on the local PE.

    Arguments:
    - dest: Destination symmetric memory reference on the target
      PE (!openshmem.symmetric_memref<T>)
    - src: Source local memory reference on the calling PE (any type)
    - nelems: Number of bytes to transfer (index)
    - pe: Target PE number (i32)

    Signature:
    ```c void shmem_putmem_nbi(void * dest, const void * src, size_t nelems,
                               int pe);
  ```
  }];

  let arguments = (ins OpenSHMEM_SymmetricMemRef
                 : $dest, AnyType
                 : $src, Index
                 : $nelems, I32
                 : $pe);

  let assemblyFormat = "`(` $dest `,` $src `,` $nelems `,` $pe `)` attr-dict `:` "
                       "type($dest) `,` type($src) `,` type($nelems) `,` type($pe)";
}

//===----------------------------------------------------------------------===//
// GetmemOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_GetmemOp : OpenSHMEM_Op<"getmem", []> {
  let summary = "Blocking getmem operation (matches shmem_getmem C API)";
  let description = [{
    This operation performs a blocking getmem, copying raw memory from the source
    symmetric memory region on the target PE to the destination local memory region on
    the calling PE. The operation copies `size` bytes and returns only after the
    data has been delivered to the destination array on the local PE.
    
    Arguments:
    - dest: Destination local memory reference on the calling PE (any type)
    - src: Source symmetric memory reference on the target
      PE (!openshmem.symmetric_memref<T>)
    - size: Number of bytes to transfer (index)
    - pe: Target PE number (i32)
    
    Signature:
    ```c
    void shmem_getmem(void *dest, const void *src, size_t nelems, int pe);
    ```
    
    Note: For getmem operations, nelems represents the number of bytes to transfer.
  }];

  let arguments = (ins
    AnyType : $dest,
    OpenSHMEM_SymmetricMemRef : $src,
    Index : $size, 
    I32 : $pe
  );

  let assemblyFormat = "`(` $dest `,` $src `,` $size `,` $pe `)` attr-dict `:` "
                       "type($dest) `,` type($src) `,` type($size) `,` type($pe)";
}

//===----------------------------------------------------------------------===//
// GetmemNbiOp
//===----------------------------------------------------------------------===//

def OpenSHMEM_GetmemNbiOp : OpenSHMEM_Op<"getmem_nbi", []> {
  let summary = "Non-blocking getmem operation (matches shmem_getmem_nbi C API)";
  let description = [{
    This operation performs a non-blocking getmem, copying raw memory from the source
    symmetric memory region on the target PE to the destination local memory region on
    the calling PE. The operation copies `size` bytes and returns immediately after the
    data has been delivered to the destination array on the local PE.

    The nonblocking get routines provide a method for copying data from a
    data object on a specified PE to a contiguous local data object. The
    nonblocking get routines return immediately after the data has been copied
    into the destination array on the local PE.

    Arguments:
    - dest: Destination local memory reference on the calling PE (any type)
    - src: Source symmetric memory reference on the target
      PE (!openshmem.symmetric_memref<T>)
    - nelems: Number of bytes to transfer (index)
    - pe: Target PE number (i32)

    Signature:
    ```c
    void shmem_getmem_nbi(void *dest, const void *src, size_t nelems, int pe);
    ```

    Note: For getmem_nbi operations, nelems represents the number of bytes to transfer.
  }];

  let arguments = (ins
    AnyType : $dest,
    OpenSHMEM_SymmetricMemRef : $src,
    Index : $nelems, 
    I32 : $pe
  );

  let assemblyFormat = "`(` $dest `,` $src `,` $nelems `,` $pe `)` attr-dict `:` "
                       "type($dest) `,` type($src) `,` type($nelems) `,` type($pe)";
}

#endif // MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMOPS_TD
