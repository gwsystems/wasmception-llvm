// Simple test for a fuzzer. The fuzzer must find a particular string.
#include <cstring>
#include <cstdint>
#include <cstdio>
#include <cstdlib>

extern "C" void LLVMFuzzerTestOneInput(const uint8_t *Data, size_t Size) {
  // TODO: check other sizes.
  char *S = (char*)Data;
  if (Size >= 8 && strncmp(S, "01234567", 8) == 0) {
    if (Size >= 12 && strncmp(S + 8, "ABCD", 4) == 0) {
      if (Size >= 14 && strncmp(S + 12, "XY", 2) == 0) {
        if (Size >= 16 && strncmp(S + 14, "KLM", 3) == 0) {
          fprintf(stderr, "BINGO\n");
          exit(1);
        }
      }
    }
  }
}
