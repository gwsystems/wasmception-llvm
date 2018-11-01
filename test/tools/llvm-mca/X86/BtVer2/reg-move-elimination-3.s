# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=btver2 -iterations=3 -timeline -register-file-stats < %s | FileCheck %s

vxorps  %xmm0, %xmm0, %xmm0
vmovaps %xmm0, %xmm1
vmovups %xmm1, %xmm2
vmovapd %xmm2, %xmm3
vmovupd %xmm3, %xmm4
vmovdqa %xmm4, %xmm5
vmovdqu %xmm5, %xmm0

# CHECK:      Iterations:        3
# CHECK-NEXT: Instructions:      21
# CHECK-NEXT: Total Cycles:      12
# CHECK-NEXT: Total uOps:        21

# CHECK:      Dispatch Width:    2
# CHECK-NEXT: uOps Per Cycle:    1.75
# CHECK-NEXT: IPC:               1.75
# CHECK-NEXT: Block RThroughput: 3.5

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      0     0.50                        vxorps	%xmm0, %xmm0, %xmm0
# CHECK-NEXT:  1      1     0.50                        vmovaps	%xmm0, %xmm1
# CHECK-NEXT:  1      1     0.50                        vmovups	%xmm1, %xmm2
# CHECK-NEXT:  1      1     0.50                        vmovapd	%xmm2, %xmm3
# CHECK-NEXT:  1      1     0.50                        vmovupd	%xmm3, %xmm4
# CHECK-NEXT:  1      1     0.50                        vmovdqa	%xmm4, %xmm5
# CHECK-NEXT:  1      1     0.50                        vmovdqu	%xmm5, %xmm0

# CHECK:      Register File statistics:
# CHECK-NEXT: Total number of mappings created:    0
# CHECK-NEXT: Max number of mappings used:         0

# CHECK:      *  Register File #1 -- JFpuPRF:
# CHECK-NEXT:    Number of physical registers:     72
# CHECK-NEXT:    Total number of mappings created: 0
# CHECK-NEXT:    Max number of mappings used:      0
# CHECK-NEXT:    Number of optimizable moves:      18
# CHECK-NEXT:    Number of moves eliminated:       18  (100.0%)
# CHECK-NEXT:    Number of zero moves:             18  (100.0%)
# CHECK-NEXT:    Max moves eliminated per cycle:   2

# CHECK:      *  Register File #2 -- JIntegerPRF:
# CHECK-NEXT:    Number of physical registers:     64
# CHECK-NEXT:    Total number of mappings created: 0
# CHECK-NEXT:    Max number of mappings used:      0

# CHECK:      Resources:
# CHECK-NEXT: [0]   - JALU0
# CHECK-NEXT: [1]   - JALU1
# CHECK-NEXT: [2]   - JDiv
# CHECK-NEXT: [3]   - JFPA
# CHECK-NEXT: [4]   - JFPM
# CHECK-NEXT: [5]   - JFPU0
# CHECK-NEXT: [6]   - JFPU1
# CHECK-NEXT: [7]   - JLAGU
# CHECK-NEXT: [8]   - JMul
# CHECK-NEXT: [9]   - JSAGU
# CHECK-NEXT: [10]  - JSTC
# CHECK-NEXT: [11]  - JVALU0
# CHECK-NEXT: [12]  - JVALU1
# CHECK-NEXT: [13]  - JVIMUL

# CHECK:      Resource pressure per iteration:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   [12]   [13]
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -      -      -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   [12]   [13]   Instructions:
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -      -      -     vxorps	%xmm0, %xmm0, %xmm0
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -      -      -     vmovaps	%xmm0, %xmm1
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -      -      -     vmovups	%xmm1, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -      -      -     vmovapd	%xmm2, %xmm3
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -      -      -     vmovupd	%xmm3, %xmm4
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -      -      -     vmovdqa	%xmm4, %xmm5
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -      -      -     vmovdqu	%xmm5, %xmm0

# CHECK:      Timeline view:
# CHECK-NEXT:                     01
# CHECK-NEXT: Index     0123456789

# CHECK:      [0,0]     DR   .    ..   vxorps	%xmm0, %xmm0, %xmm0
# CHECK-NEXT: [0,1]     DR   .    ..   vmovaps	%xmm0, %xmm1
# CHECK-NEXT: [0,2]     .DR  .    ..   vmovups	%xmm1, %xmm2
# CHECK-NEXT: [0,3]     .DR  .    ..   vmovapd	%xmm2, %xmm3
# CHECK-NEXT: [0,4]     . DR .    ..   vmovupd	%xmm3, %xmm4
# CHECK-NEXT: [0,5]     . DR .    ..   vmovdqa	%xmm4, %xmm5
# CHECK-NEXT: [0,6]     .  DR.    ..   vmovdqu	%xmm5, %xmm0
# CHECK-NEXT: [1,0]     .  DR.    ..   vxorps	%xmm0, %xmm0, %xmm0
# CHECK-NEXT: [1,1]     .   DR    ..   vmovaps	%xmm0, %xmm1
# CHECK-NEXT: [1,2]     .   DR    ..   vmovups	%xmm1, %xmm2
# CHECK-NEXT: [1,3]     .    DR   ..   vmovapd	%xmm2, %xmm3
# CHECK-NEXT: [1,4]     .    DR   ..   vmovupd	%xmm3, %xmm4
# CHECK-NEXT: [1,5]     .    .DR  ..   vmovdqa	%xmm4, %xmm5
# CHECK-NEXT: [1,6]     .    .DR  ..   vmovdqu	%xmm5, %xmm0
# CHECK-NEXT: [2,0]     .    . DR ..   vxorps	%xmm0, %xmm0, %xmm0
# CHECK-NEXT: [2,1]     .    . DR ..   vmovaps	%xmm0, %xmm1
# CHECK-NEXT: [2,2]     .    .  DR..   vmovups	%xmm1, %xmm2
# CHECK-NEXT: [2,3]     .    .  DR..   vmovapd	%xmm2, %xmm3
# CHECK-NEXT: [2,4]     .    .   DR.   vmovupd	%xmm3, %xmm4
# CHECK-NEXT: [2,5]     .    .   DR.   vmovdqa	%xmm4, %xmm5
# CHECK-NEXT: [2,6]     .    .    DR   vmovdqu	%xmm5, %xmm0

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     3     0.0    0.0    0.0       vxorps	%xmm0, %xmm0, %xmm0
# CHECK-NEXT: 1.     3     0.0    0.0    0.0       vmovaps	%xmm0, %xmm1
# CHECK-NEXT: 2.     3     0.0    0.0    0.0       vmovups	%xmm1, %xmm2
# CHECK-NEXT: 3.     3     0.0    0.0    0.0       vmovapd	%xmm2, %xmm3
# CHECK-NEXT: 4.     3     0.0    0.0    0.0       vmovupd	%xmm3, %xmm4
# CHECK-NEXT: 5.     3     0.0    0.0    0.0       vmovdqa	%xmm4, %xmm5
# CHECK-NEXT: 6.     3     0.0    0.0    0.0       vmovdqu	%xmm5, %xmm0
