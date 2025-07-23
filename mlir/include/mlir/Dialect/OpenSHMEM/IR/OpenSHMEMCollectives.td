//===- OpenSHMEMCollectives.td - OpenSHMEM collective operations -*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMCOLLECTIVES_TD
#define MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMCOLLECTIVES_TD

include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEMBase.td"

//===----------------------------------------------------------------------===//
// AlltoallmemOp
//
// TODO: Can we support both alltoall and alltoallmem with one operation and one
//       lowering pass?
// 
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

#endif // MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMCOLLECTIVES_TD 