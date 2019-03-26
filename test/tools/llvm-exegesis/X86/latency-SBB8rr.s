# RUN: llvm-exegesis -mode=latency -opcode-name=SBB8rr | FileCheck %s

CHECK:      ---
CHECK-NEXT: mode: latency
CHECK-NEXT: key:
CHECK-NEXT:   instructions:
CHECK-NEXT:     SBB8rr
CHECK-NEXT: config: ''
CHECK-NEXT: register_initial_values:
CHECK-DAG: - '[[REG1:[A-Z0-9]+]]=0x0'
CHECK-LAST: ...
