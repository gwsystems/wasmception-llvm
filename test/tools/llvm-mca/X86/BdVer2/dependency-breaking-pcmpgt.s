# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=x86-64 -timeline -timeline-max-iterations=3 -iterations=1500 < %s | FileCheck %s

# perf stat reports an IPC of 2.00 for this block of code.

# All of the vector packed compares from this test are zero idioms.  These zero
# idioms are all detected and removed by the register renamer.  That means, no
# uOp is executed, and there is no RAW dependency for any of the packed
# compares.

vpcmpgtb %xmm0, %xmm0, %xmm1
vpcmpgtw %xmm1, %xmm1, %xmm2
vpcmpgtd %xmm2, %xmm2, %xmm3
vpcmpgtq %xmm3, %xmm3, %xmm0

# CHECK:      Iterations:        1500
# CHECK-NEXT: Instructions:      6000
# CHECK-NEXT: Total Cycles:      1501
# CHECK-NEXT: Total uOps:        6000

# CHECK:      Dispatch Width:    4
# CHECK-NEXT: uOps Per Cycle:    4.00
# CHECK-NEXT: IPC:               4.00
# CHECK-NEXT: Block RThroughput: 1.0

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      0     0.25                        vpcmpgtb	%xmm0, %xmm0, %xmm1
# CHECK-NEXT:  1      0     0.25                        vpcmpgtw	%xmm1, %xmm1, %xmm2
# CHECK-NEXT:  1      0     0.25                        vpcmpgtd	%xmm2, %xmm2, %xmm3
# CHECK-NEXT:  1      0     0.25                        vpcmpgtq	%xmm3, %xmm3, %xmm0

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
# CHECK-NEXT:  -      -      -      -      -      -      -      -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6.0]  [6.1]  Instructions:
# CHECK-NEXT:  -      -      -      -      -      -      -      -     vpcmpgtb	%xmm0, %xmm0, %xmm1
# CHECK-NEXT:  -      -      -      -      -      -      -      -     vpcmpgtw	%xmm1, %xmm1, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -      -      -     vpcmpgtd	%xmm2, %xmm2, %xmm3
# CHECK-NEXT:  -      -      -      -      -      -      -      -     vpcmpgtq	%xmm3, %xmm3, %xmm0

# CHECK:      Timeline view:
# CHECK-NEXT: Index     0123

# CHECK:      [0,0]     DR .   vpcmpgtb	%xmm0, %xmm0, %xmm1
# CHECK-NEXT: [0,1]     DR .   vpcmpgtw	%xmm1, %xmm1, %xmm2
# CHECK-NEXT: [0,2]     DR .   vpcmpgtd	%xmm2, %xmm2, %xmm3
# CHECK-NEXT: [0,3]     DR .   vpcmpgtq	%xmm3, %xmm3, %xmm0
# CHECK-NEXT: [1,0]     .DR.   vpcmpgtb	%xmm0, %xmm0, %xmm1
# CHECK-NEXT: [1,1]     .DR.   vpcmpgtw	%xmm1, %xmm1, %xmm2
# CHECK-NEXT: [1,2]     .DR.   vpcmpgtd	%xmm2, %xmm2, %xmm3
# CHECK-NEXT: [1,3]     .DR.   vpcmpgtq	%xmm3, %xmm3, %xmm0
# CHECK-NEXT: [2,0]     . DR   vpcmpgtb	%xmm0, %xmm0, %xmm1
# CHECK-NEXT: [2,1]     . DR   vpcmpgtw	%xmm1, %xmm1, %xmm2
# CHECK-NEXT: [2,2]     . DR   vpcmpgtd	%xmm2, %xmm2, %xmm3
# CHECK-NEXT: [2,3]     . DR   vpcmpgtq	%xmm3, %xmm3, %xmm0

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     3     0.0    0.0    0.0       vpcmpgtb	%xmm0, %xmm0, %xmm1
# CHECK-NEXT: 1.     3     0.0    0.0    0.0       vpcmpgtw	%xmm1, %xmm1, %xmm2
# CHECK-NEXT: 2.     3     0.0    0.0    0.0       vpcmpgtd	%xmm2, %xmm2, %xmm3
# CHECK-NEXT: 3.     3     0.0    0.0    0.0       vpcmpgtq	%xmm3, %xmm3, %xmm0
