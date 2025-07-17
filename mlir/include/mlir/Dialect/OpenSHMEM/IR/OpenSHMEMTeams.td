//===- OpenSHMEMTeams.td - OpenSHMEM team operations -------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMTEAMS_TD
#define MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMTEAMS_TD

include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEMBase.td"

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
    This operation returns the total number of PEs in the specified team.

    Arguments:
    - team: The team to query

    Results:
    - n_pes: Number of PEs in the team

    Signature:
    ```c
    int shmem_team_n_pes(shmem_team_t team);
    ```
  }];

  let arguments = (ins OpenSHMEM_Team:$team);
  let results = (outs I32:$n_pes);
  let assemblyFormat = "`(` $team `)` attr-dict `:` type($team) `->` type($n_pes)";
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

#endif // MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMTEAMS_TD 