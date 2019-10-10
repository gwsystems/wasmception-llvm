# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=x86-64 -timeline -timeline-max-iterations=3 -iterations=1500 < %s | FileCheck %s

# The CMP instruction doesn't depend on the value of EAX.  It can set the flags
# without having to read the inputs.

cmp %eax, %eax
cmovae %ebx, %eax

# CHECK:      Iterations:        1500
# CHECK-NEXT: Instructions:      3000
# CHECK-NEXT: Total Cycles:      4503
# CHECK-NEXT: Total uOps:        4500

# CHECK:      Dispatch Width:    4
# CHECK-NEXT: uOps Per Cycle:    1.00
# CHECK-NEXT: IPC:               0.67
# CHECK-NEXT: Block RThroughput: 0.8

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      1     0.33                        cmpl	%eax, %eax
# CHECK-NEXT:  2      2     0.67                        cmovael	%ebx, %eax

# CHECK:      Resources:
# CHECK-NEXT: [0]   - SBDivider
# CHECK-NEXT: [1]   - SBFPDivider
# CHECK-NEXT: [2]   - SBPort0
# CHECK-NEXT: [3]   - SBPort1
# CHECK-NEXT: [4]   - SBPort4
# CHECK-NEXT: [5]   - SBPort5
# CHECK-NEXT: [6.0] - SBPort23
# CHECK-NEXT: [6.1] - SBPort23

# CHECK:      Resource pressure per iteration:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6.0]  [6.1]
# CHECK-NEXT:  -      -     1.00   1.00    -     1.00    -      -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6.0]  [6.1]  Instructions:
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -     cmpl	%eax, %eax
# CHECK-NEXT:  -      -     1.00   1.00    -      -      -      -     cmovael	%ebx, %eax

# CHECK:      Timeline view:
# CHECK-NEXT:                     01
# CHECK-NEXT: Index     0123456789

# CHECK:      [0,0]     DeER .    ..   cmpl	%eax, %eax
# CHECK-NEXT: [0,1]     D=eeER    ..   cmovael	%ebx, %eax
# CHECK-NEXT: [1,0]     D===eER   ..   cmpl	%eax, %eax
# CHECK-NEXT: [1,1]     .D===eeER ..   cmovael	%ebx, %eax
# CHECK-NEXT: [2,0]     .D=====eER..   cmpl	%eax, %eax
# CHECK-NEXT: [2,1]     . D=====eeER   cmovael	%ebx, %eax

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     3     3.7    0.3    0.0       cmpl	%eax, %eax
# CHECK-NEXT: 1.     3     4.0    0.0    0.0       cmovael	%ebx, %eax
# CHECK-NEXT:        3     3.8    0.2    0.0       <total>
