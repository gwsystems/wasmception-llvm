// RUN: %llvmgcc %s -S -o - | llc

union U { int x; float p; };
void foo() {
  union U bar;
  __asm__ volatile("foo %0\n" : "=r"(bar));
}
