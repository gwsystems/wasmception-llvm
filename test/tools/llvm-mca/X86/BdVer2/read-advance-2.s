# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=bdver2 -iterations=1 -resource-pressure=0 -timeline < %s | FileCheck %s

  imull  %esi
  imull  (%rdi)

# The second integer multiply can start at cycle 2 because the implicit reads
# can start after the load operand is evaluated.

# CHECK:      Iterations:        1
# CHECK-NEXT: Instructions:      2
# CHECK-NEXT: Total Cycles:      15
# CHECK-NEXT: Total uOps:        2

# CHECK:      Dispatch Width:    4
# CHECK-NEXT: uOps Per Cycle:    0.13
# CHECK-NEXT: IPC:               0.13
# CHECK-NEXT: Block RThroughput: 8.0

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      4     4.00                        imull	%esi
# CHECK-NEXT:  1      8     4.00    *                   imull	(%rdi)

# CHECK:      Timeline view:
# CHECK-NEXT:                     01234
# CHECK-NEXT: Index     0123456789

# CHECK:      [0,0]     DeeeeER   .   .   imull	%esi
# CHECK-NEXT: [0,1]     D====eeeeeeeeER   imull	(%rdi)

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     1     1.0    1.0    0.0       imull	%esi
# CHECK-NEXT: 1.     1     5.0    4.0    0.0       imull	(%rdi)
