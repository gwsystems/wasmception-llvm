// RUN: %llvmgcc -S -O0 -g %s -o - | FileCheck %s
// Insure that dbg.declare lines for locals refer to correct line number records.
// Radar 8152866.
void foo() {
  int l = 0;    // line #4: CHECK: {{call.*llvm.dbg.declare.*%l.*\!dbg }}[[variable_l:![0-9]+]]
  int p = 0;    // line #5: CHECK: {{call.*llvm.dbg.declare.*%p.*\!dbg }}[[variable_p:![0-9]+]]
}
// Now match the line number records:
// CHECK: {{^}}[[variable_l]]{{ = metadata ![{]i32 5,}}
// CHECK: {{^}}[[variable_p]]{{ = metadata ![{]i32 6,}}
