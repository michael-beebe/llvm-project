#include <shmem.h>
#include <stdio.h>

int main(int argc, char *argv[]) {
  shmem_init();

  int rank = shmem_my_pe();
  int size = shmem_n_pes();

  printf("Hello from PE %d of %d\n", rank, size);

  shmem_finalize();
  return 0;
}
