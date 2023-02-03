#include <hip/hip_runtime.h>
#include <hello_hip.hxx>

__global__ void hello_hip() {
  printf("Hello World!\n");
}

void launch_hello_hip() {
  hello_hip<<<1, 1>>>();
  hipDeviceSynchronize();
}
