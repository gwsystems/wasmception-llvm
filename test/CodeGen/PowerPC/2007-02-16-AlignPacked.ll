; RUN: llvm-as < %s | llc -march=ppc32 -mtriple=powerpc-apple-darwin8.8.0 | grep 'align.*3'

@X = global <{i32, i32}> <{ i32 1, i32 123 }>
