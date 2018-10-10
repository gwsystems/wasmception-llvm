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
# CHECK-NEXT: Total Cycles:      16
# CHECK-NEXT: Total uOps:        21

# CHECK:      Dispatch Width:    2
# CHECK-NEXT: uOps Per Cycle:    1.31
# CHECK-NEXT: IPC:               1.31
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
# CHECK-NEXT: Total number of mappings created:    18
# CHECK-NEXT: Max number of mappings used:         9

# CHECK:      *  Register File #1 -- JFpuPRF:
# CHECK-NEXT:    Number of physical registers:     72
# CHECK-NEXT:    Total number of mappings created: 18
# CHECK-NEXT:    Max number of mappings used:      9

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
# CHECK-NEXT:  -      -      -     2.00   2.00   3.00   3.00    -      -      -      -     1.00   1.00    -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   [12]   [13]   Instructions:
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -      -      -     vxorps	%xmm0, %xmm0, %xmm0
# CHECK-NEXT:  -      -      -      -     1.00   0.33   0.67    -      -      -      -      -      -      -     vmovaps	%xmm0, %xmm1
# CHECK-NEXT:  -      -      -     1.00    -     0.67   0.33    -      -      -      -      -      -      -     vmovups	%xmm1, %xmm2
# CHECK-NEXT:  -      -      -      -     1.00    -     1.00    -      -      -      -      -      -      -     vmovapd	%xmm2, %xmm3
# CHECK-NEXT:  -      -      -     1.00    -     1.00    -      -      -      -      -      -      -      -     vmovupd	%xmm3, %xmm4
# CHECK-NEXT:  -      -      -      -      -     0.33   0.67    -      -      -      -      -     1.00    -     vmovdqa	%xmm4, %xmm5
# CHECK-NEXT:  -      -      -      -      -     0.67   0.33    -      -      -      -     1.00    -      -     vmovdqu	%xmm5, %xmm0

# CHECK:      Timeline view:
# CHECK-NEXT:                     012345
# CHECK-NEXT: Index     0123456789

# CHECK:      [0,0]     DR   .    .    .   vxorps	%xmm0, %xmm0, %xmm0
# CHECK-NEXT: [0,1]     DeER .    .    .   vmovaps	%xmm0, %xmm1
# CHECK-NEXT: [0,2]     .DeER.    .    .   vmovups	%xmm1, %xmm2
# CHECK-NEXT: [0,3]     .D=eER    .    .   vmovapd	%xmm2, %xmm3
# CHECK-NEXT: [0,4]     . D=eER   .    .   vmovupd	%xmm3, %xmm4
# CHECK-NEXT: [0,5]     . D==eER  .    .   vmovdqa	%xmm4, %xmm5
# CHECK-NEXT: [0,6]     .  D==eER .    .   vmovdqu	%xmm5, %xmm0
# CHECK-NEXT: [1,0]     .  D----R .    .   vxorps	%xmm0, %xmm0, %xmm0
# CHECK-NEXT: [1,1]     .   DeE--R.    .   vmovaps	%xmm0, %xmm1
# CHECK-NEXT: [1,2]     .   D=eE-R.    .   vmovups	%xmm1, %xmm2
# CHECK-NEXT: [1,3]     .    D=eE-R    .   vmovapd	%xmm2, %xmm3
# CHECK-NEXT: [1,4]     .    D==eER    .   vmovupd	%xmm3, %xmm4
# CHECK-NEXT: [1,5]     .    .D==eER   .   vmovdqa	%xmm4, %xmm5
# CHECK-NEXT: [1,6]     .    .D===eER  .   vmovdqu	%xmm5, %xmm0
# CHECK-NEXT: [2,0]     .    . D----R  .   vxorps	%xmm0, %xmm0, %xmm0
# CHECK-NEXT: [2,1]     .    . DeE---R .   vmovaps	%xmm0, %xmm1
# CHECK-NEXT: [2,2]     .    .  DeE--R .   vmovups	%xmm1, %xmm2
# CHECK-NEXT: [2,3]     .    .  D=eE--R.   vmovapd	%xmm2, %xmm3
# CHECK-NEXT: [2,4]     .    .   D=eE-R.   vmovupd	%xmm3, %xmm4
# CHECK-NEXT: [2,5]     .    .   D==eE-R   vmovdqa	%xmm4, %xmm5
# CHECK-NEXT: [2,6]     .    .    D==eER   vmovdqu	%xmm5, %xmm0

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     3     0.0    0.0    2.7       vxorps	%xmm0, %xmm0, %xmm0
# CHECK-NEXT: 1.     3     1.0    1.0    1.7       vmovaps	%xmm0, %xmm1
# CHECK-NEXT: 2.     3     1.3    0.0    1.0       vmovups	%xmm1, %xmm2
# CHECK-NEXT: 3.     3     2.0    0.0    1.0       vmovapd	%xmm2, %xmm3
# CHECK-NEXT: 4.     3     2.3    0.0    0.3       vmovupd	%xmm3, %xmm4
# CHECK-NEXT: 5.     3     3.0    0.0    0.3       vmovdqa	%xmm4, %xmm5
# CHECK-NEXT: 6.     3     3.3    0.0    0.0       vmovdqu	%xmm5, %xmm0
