# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=bdver2 -timeline -timeline-max-iterations=2 < %s | FileCheck %s

# VALU0/VALU1
vpmulld     %xmm0, %xmm1, %xmm2
vpand       %xmm0, %xmm1, %xmm2

# VIMUL/STC
vcvttps2dq  %xmm0, %xmm2
vpclmulqdq  $0, %xmm0, %xmm1, %xmm2

# FPA/FPM
vaddps      %xmm0, %xmm1, %xmm2
vsqrtps     %xmm0, %xmm2

# FPA/FPM YMM
vaddps      %ymm0, %ymm1, %ymm2
vsqrtps     %ymm0, %ymm2

# CHECK:      Iterations:        100
# CHECK-NEXT: Instructions:      800
# CHECK-NEXT: Total Cycles:      3244
# CHECK-NEXT: Total uOps:        1500

# CHECK:      Dispatch Width:    4
# CHECK-NEXT: uOps Per Cycle:    0.46
# CHECK-NEXT: IPC:               0.25
# CHECK-NEXT: Block RThroughput: 32.5

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      5     2.00                        vpmulld	%xmm0, %xmm1, %xmm2
# CHECK-NEXT:  1      2     0.50                        vpand	%xmm0, %xmm1, %xmm2
# CHECK-NEXT:  1      4     1.00                        vcvttps2dq	%xmm0, %xmm2
# CHECK-NEXT:  6      12    1.00                        vpclmulqdq	$0, %xmm0, %xmm1, %xmm2
# CHECK-NEXT:  1      5     1.00                        vaddps	%xmm0, %xmm1, %xmm2
# CHECK-NEXT:  1      9     10.50                       vsqrtps	%xmm0, %xmm2
# CHECK-NEXT:  2      5     2.00                        vaddps	%ymm0, %ymm1, %ymm2
# CHECK-NEXT:  2      9     21.00                       vsqrtps	%ymm0, %ymm2

# CHECK:      Resources:
# CHECK-NEXT: [0.0] - PdAGLU01
# CHECK-NEXT: [0.1] - PdAGLU01
# CHECK-NEXT: [1]   - PdBranch
# CHECK-NEXT: [2]   - PdCount
# CHECK-NEXT: [3]   - PdDiv
# CHECK-NEXT: [4]   - PdEX0
# CHECK-NEXT: [5]   - PdEX1
# CHECK-NEXT: [6]   - PdFPCVT
# CHECK-NEXT: [7.0] - PdFPFMA
# CHECK-NEXT: [7.1] - PdFPFMA
# CHECK-NEXT: [8.0] - PdFPMAL
# CHECK-NEXT: [8.1] - PdFPMAL
# CHECK-NEXT: [9]   - PdFPMMA
# CHECK-NEXT: [10]  - PdFPSTO
# CHECK-NEXT: [11]  - PdFPU0
# CHECK-NEXT: [12]  - PdFPU1
# CHECK-NEXT: [13]  - PdFPU2
# CHECK-NEXT: [14]  - PdFPU3
# CHECK-NEXT: [15]  - PdFPXBR
# CHECK-NEXT: [16.0] - PdLoad
# CHECK-NEXT: [16.1] - PdLoad
# CHECK-NEXT: [17]  - PdMul
# CHECK-NEXT: [18]  - PdStore

# CHECK:      Resource pressure per iteration:
# CHECK-NEXT: [0.0]  [0.1]  [1]    [2]    [3]    [4]    [5]    [6]    [7.0]  [7.1]  [8.0]  [8.1]  [9]    [10]   [11]   [12]   [13]   [14]   [15]   [16.0] [16.1] [17]   [18]
# CHECK-NEXT:  -      -      -      -      -      -      -      -     32.29  32.71  1.00   1.00   3.00   1.00   6.00   6.00    -      -      -      -      -      -      -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0.0]  [0.1]  [1]    [2]    [3]    [4]    [5]    [6]    [7.0]  [7.1]  [8.0]  [8.1]  [9]    [10]   [11]   [12]   [13]   [14]   [15]   [16.0] [16.1] [17]   [18]   Instructions:
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -     0.02   0.98   2.00    -     2.00   1.00    -      -      -      -      -      -      -     vpmulld	%xmm0, %xmm1, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -     0.98   0.02    -      -      -     1.00    -      -      -      -      -      -      -     vpand	%xmm0, %xmm1, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -      -     1.00    -     1.00    -      -      -      -      -      -      -     vcvttps2dq	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -     1.00    -     1.00    -      -      -      -      -      -      -      -     vpclmulqdq	$0, %xmm0, %xmm1, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -      -      -     0.50   0.50    -      -      -      -     1.00    -      -      -      -      -      -      -      -     vaddps	%xmm0, %xmm1, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -      -      -     10.71  10.29   -      -      -      -      -     1.00    -      -      -      -      -      -      -     vsqrtps	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -      -      -     0.50   0.50    -      -      -      -     2.00    -      -      -      -      -      -      -      -     vaddps	%ymm0, %ymm1, %ymm2
# CHECK-NEXT:  -      -      -      -      -      -      -      -     20.58  21.42   -      -      -      -      -     2.00    -      -      -      -      -      -      -     vsqrtps	%ymm0, %ymm2

# CHECK:      Timeline view:
# CHECK-NEXT:                     0123456789          0123456789          012345678
# CHECK-NEXT: Index     0123456789          0123456789          0123456789

# CHECK:      [0,0]     DeeeeeER  .    .    .    .    .    .    .    .    .    .  .   vpmulld	%xmm0, %xmm1, %xmm2
# CHECK-NEXT: [0,1]     D=eeE--R  .    .    .    .    .    .    .    .    .    .  .   vpand	%xmm0, %xmm1, %xmm2
# CHECK-NEXT: [0,2]     D==eeeeER .    .    .    .    .    .    .    .    .    .  .   vcvttps2dq	%xmm0, %xmm2
# CHECK-NEXT: [0,3]     .D=eeeeeeeeeeeeER   .    .    .    .    .    .    .    .  .   vpclmulqdq	$0, %xmm0, %xmm1, %xmm2
# CHECK-NEXT: [0,4]     . D=eeeeeE------R   .    .    .    .    .    .    .    .  .   vaddps	%xmm0, %xmm1, %xmm2
# CHECK-NEXT: [0,5]     . D=eeeeeeeeeE--R   .    .    .    .    .    .    .    .  .   vsqrtps	%xmm0, %xmm2
# CHECK-NEXT: [0,6]     .  D=eeeeeE-----R   .    .    .    .    .    .    .    .  .   vaddps	%ymm0, %ymm1, %ymm2
# CHECK-NEXT: [0,7]     .  D==eeeeeeeeeE-R  .    .    .    .    .    .    .    .  .   vsqrtps	%ymm0, %ymm2
# CHECK-NEXT: [1,0]     .   D===eeeeeE---R  .    .    .    .    .    .    .    .  .   vpmulld	%xmm0, %xmm1, %xmm2
# CHECK-NEXT: [1,1]     .   DeeE---------R  .    .    .    .    .    .    .    .  .   vpand	%xmm0, %xmm1, %xmm2
# CHECK-NEXT: [1,2]     .   D====eeeeE---R  .    .    .    .    .    .    .    .  .   vcvttps2dq	%xmm0, %xmm2
# CHECK-NEXT: [1,3]     .    D=eeeeeeeeeeeeER    .    .    .    .    .    .    .  .   vpclmulqdq	$0, %xmm0, %xmm1, %xmm2
# CHECK-NEXT: [1,4]     .    .D==================eeeeeER   .    .    .    .    .  .   vaddps	%xmm0, %xmm1, %xmm2
# CHECK-NEXT: [1,5]     .    .D===================eeeeeeeeeER   .    .    .    .  .   vsqrtps	%xmm0, %xmm2
# CHECK-NEXT: [1,6]     .    . D=======================================eeeeeER .  .   vaddps	%ymm0, %ymm1, %ymm2
# CHECK-NEXT: [1,7]     .    . D========================================eeeeeeeeeER   vsqrtps	%ymm0, %ymm2

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     2     2.5    2.5    1.5       vpmulld	%xmm0, %xmm1, %xmm2
# CHECK-NEXT: 1.     2     1.5    1.5    5.5       vpand	%xmm0, %xmm1, %xmm2
# CHECK-NEXT: 2.     2     4.0    4.0    1.5       vcvttps2dq	%xmm0, %xmm2
# CHECK-NEXT: 3.     2     2.0    2.0    0.0       vpclmulqdq	$0, %xmm0, %xmm1, %xmm2
# CHECK-NEXT: 4.     2     10.5   10.5   3.0       vaddps	%xmm0, %xmm1, %xmm2
# CHECK-NEXT: 5.     2     11.0   11.0   1.0       vsqrtps	%xmm0, %xmm2
# CHECK-NEXT: 6.     2     21.0   21.0   2.5       vaddps	%ymm0, %ymm1, %ymm2
# CHECK-NEXT: 7.     2     22.0   22.0   0.5       vsqrtps	%ymm0, %ymm2
