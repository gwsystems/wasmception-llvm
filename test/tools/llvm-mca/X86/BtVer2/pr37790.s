# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=btver2 -lqueue=2 -iterations=2 -resource-pressure=false -timeline -timeline-max-cycles=104 < %s | FileCheck %s

int3
stmxcsr (%rsp)

# CHECK:      Iterations:        2
# CHECK-NEXT: Instructions:      4
# CHECK-NEXT: Total Cycles:      205
# CHECK-NEXT: Total uOps:        4

# CHECK:      Dispatch Width:    2
# CHECK-NEXT: uOps Per Cycle:    0.02
# CHECK-NEXT: IPC:               0.02
# CHECK-NEXT: Block RThroughput: 1.0

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      100   0.50    *      *      U     int3
# CHECK-NEXT:  1      1     1.00           *      U     stmxcsr	(%rsp)

# CHECK:      Timeline view:
# CHECK-NEXT:                     0123456789          0123456789          0123456789          0123456789          0123456789
# CHECK-NEXT: Index     0123456789          0123456789          0123456789          0123456789          0123456789          0123

# CHECK:      [0,0]     DeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeER.   int3
# CHECK-NEXT: [0,1]     D====================================================================================================eER   stmxcsr	(%rsp)

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     2     51.0   0.5    0.0       int3
# CHECK-NEXT: 1.     2     151.0  0.0    0.0       stmxcsr	(%rsp)
