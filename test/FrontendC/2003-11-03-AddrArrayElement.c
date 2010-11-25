// RUN: %llvmgcc -xc %s -S -o - | grep getelementptr

// This should be turned into a tasty getelementptr instruction, not a nasty
// series of casts and address arithmetic.

char Global[100];

char *test1(unsigned i) {
  return &Global[i];
}

