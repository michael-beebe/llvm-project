//===- OpenSHMEMContexts.td - OpenSHMEM context operations -*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMCONTEXTS_TD
#define MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMCONTEXTS_TD

include "mlir/Dialect/OpenSHMEM/IR/OpenSHMEMBase.td"

// TODO: probably need an op to initialize the default context

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

#endif // MLIR_DIALECT_OPENSHMEM_IR_OPENSHMEMCONTEXTS_TD 