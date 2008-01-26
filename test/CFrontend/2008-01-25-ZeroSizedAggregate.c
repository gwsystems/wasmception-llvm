// RUN: %llvmgcc %s -S -o -

// Aggregates of size zero should be dropped from argument list.
typedef long int Tlong;
struct S2411 {
  __attribute__((aligned)) Tlong:0;
};

extern struct S2411 a2411[5];
extern void checkx2411(struct S2411);
void test2411(void) {
  checkx2411(a2411[0]);
}

// A field that is an aggregates of size zero should be dropped during
// type conversion.
typedef unsigned long long int Tal2ullong __attribute__((aligned(2)));
struct S2525 {
 Tal2ullong: 0;
 struct {
 } e;
};
struct S2525 s2525;
