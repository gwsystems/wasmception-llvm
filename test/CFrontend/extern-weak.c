// RUN: %llvmgcc -O3 -S -o - -emit-llvm %s | grep extern_weak &&
// RUN: %llvmgcc -O3 -S -o - -emit-llvm | llvm-as | llc

#ifndef __linux__
void foo() __attribute__((weak_import));
#else
void foo() __attribute__((weak));
#endif

void bar() { foo(); }

