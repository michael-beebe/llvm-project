#include <shmem.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
  shmem_init();

  int my_pe = shmem_my_pe();
  int n_pes = shmem_n_pes();

  printf("PE %d/%d: Starting stencil computation\n", my_pe, n_pes);

  // Simple stencil computation similar to the MLIR version
  // Allocate some symmetric memory
  void *ptr = shmem_malloc(64); // 64 bytes like the MLIR version
  printf("PE %d/%d: Allocated 64 bytes of symmetric memory\n", my_pe, n_pes);

  // Each PE owns 4 elements of a 16-element 1D grid
  int local_size = 4;
  int start_idx = my_pe * local_size;

  // Allocate local working arrays (with ghost cells for boundaries)
  float *local_grid = (float *)((char *)ptr); // Use symmetric memory as grid
  float *new_grid = local_grid + 8;           // Second half for new values

  // Initialize local grid with PE-specific values
  for (int i = 0; i < local_size; i++) {
    local_grid[i] = (float)(start_idx + i +
                            1); // Values 1,2,3,4 for PE0, 5,6,7,8 for PE1, etc.
  }

  printf(
      "PE %d/%d: Local grid range [%d-%d], initialized with values %.0f-%.0f\n",
      my_pe, n_pes, start_idx, start_idx + local_size - 1, local_grid[0],
      local_grid[local_size - 1]);

  // Synchronize after initialization
  shmem_barrier_all();

  // Get boundary values from neighbors for stencil computation
  float left_ghost = 0.0f, right_ghost = 0.0f;

  if (my_pe > 0) {
    // Get rightmost value from left neighbor (PE my_pe-1)
    int left_pe = my_pe - 1;
    int remote_idx = local_size - 1; // Last element of left neighbor
    shmem_float_get(&left_ghost, local_grid + remote_idx, 1, left_pe);
    printf("PE %d/%d: Got left boundary %.0f from PE %d\n", my_pe, n_pes,
           left_ghost, left_pe);
  }

  if (my_pe < n_pes - 1) {
    // Get leftmost value from right neighbor (PE my_pe+1)
    int right_pe = my_pe + 1;
    int remote_idx = 0; // First element of right neighbor
    shmem_float_get(&right_ghost, local_grid + remote_idx, 1, right_pe);
    printf("PE %d/%d: Got right boundary %.0f from PE %d\n", my_pe, n_pes,
           right_ghost, right_pe);
  }

  // Perform 3-point stencil: new[i] = 0.25 * (left + 2*center + right)
  for (int i = 0; i < local_size; i++) {
    float left = (i == 0 && my_pe > 0) ? left_ghost
                 : (i > 0)             ? local_grid[i - 1]
                                       : local_grid[i];
    float center = local_grid[i];
    float right = (i == local_size - 1 && my_pe < n_pes - 1) ? right_ghost
                  : (i < local_size - 1)                     ? local_grid[i + 1]
                                                             : local_grid[i];

    new_grid[i] = 0.25f * (left + 2.0f * center + right);
  }

  printf("PE %d/%d: Completed stencil computation, new values %.2f-%.2f\n",
         my_pe, n_pes, new_grid[0], new_grid[local_size - 1]);

  // Barrier synchronization
  printf("PE %d/%d: Entering barrier synchronization\n", my_pe, n_pes);
  shmem_barrier_all();
  printf("PE %d/%d: Completed barrier synchronization\n", my_pe, n_pes);

  // Free the memory
  shmem_free(ptr);
  printf("PE %d/%d: Freed symmetric memory, stencil complete\n", my_pe, n_pes);

  shmem_finalize();
  return 0;
}