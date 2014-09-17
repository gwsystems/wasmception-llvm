// RUN: llvm-cov show %S/Inputs/showExpansions.covmapping -instr-profile %S/Inputs/showExpansions.profdata -dump -show-expansions -filename-equivalence %s 2>&1 | FileCheck %s

#define DO_SOMETHING_ELSE() \
  do {                      \
  } while (0)
#define ANOTHER_THING() \
  do {                  \
    if (0) {            \
    }                   \
  } while (0)

#define DO_SOMETHING(x)    \
  do {                     \
    if (x)                 \
      DO_SOMETHING_ELSE(); \
    else                   \
      ANOTHER_THING();     \
  } while (0)

int main(int argc, const char *argv[]) {
  for (int i = 0; i < 100; ++i)
    DO_SOMETHING(i);
  return 0;
}

// CHECK: Expansion at line 22, 5 -> 17
// CHECK: Expansion at line 15, 7 -> 24
// CHECK: Expansion at line 17, 7 -> 20

// llvm-cov doesn't work on big endian yet
// XFAIL: powerpc64-, s390x, mips-, mips64-, sparc
