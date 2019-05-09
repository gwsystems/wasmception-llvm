# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=bdver2 -iterations=1 -scheduler-stats < %s | FileCheck %s

vmulps (%rsi), %xmm0, %xmm0
add  %rsi, %rsi

# CHECK:      Iterations:        1
# CHECK-NEXT: Instructions:      2
# CHECK-NEXT: Total Cycles:      13
# CHECK-NEXT: Total uOps:        2

# CHECK:      Dispatch Width:    4
# CHECK-NEXT: uOps Per Cycle:    0.15
# CHECK-NEXT: IPC:               0.15
# CHECK-NEXT: Block RThroughput: 1.5

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      10    1.50    *                   vmulps	(%rsi), %xmm0, %xmm0
# CHECK-NEXT:  1      1     1.00                        addq	%rsi, %rsi

# CHECK:      Schedulers - number of cycles where we saw N micro opcodes issued:
# CHECK-NEXT: [# issued], [# cycles]
# CHECK-NEXT:  0,          12  (92.3%)
# CHECK-NEXT:  2,          1  (7.7%)

# CHECK:      Scheduler's queue usage:
# CHECK-NEXT: [1] Resource name.
# CHECK-NEXT: [2] Average number of used buffer entries.
# CHECK-NEXT: [3] Maximum number of used buffer entries.
# CHECK-NEXT: [4] Total number of buffer entries.

# CHECK:       [1]            [2]        [3]        [4]
# CHECK-NEXT: PdEX             0          2          40
# CHECK-NEXT: PdFPU            0          1          64
# CHECK-NEXT: PdLoad           0          1          40
# CHECK-NEXT: PdStore          0          0          24

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
# CHECK-NEXT:  -     3.00    -      -      -      -     2.00    -      -     1.00    -      -      -      -      -     1.00    -      -      -      -     3.00    -      -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0.0]  [0.1]  [1]    [2]    [3]    [4]    [5]    [6]    [7.0]  [7.1]  [8.0]  [8.1]  [9]    [10]   [11]   [12]   [13]   [14]   [15]   [16.0] [16.1] [17]   [18]   Instructions:
# CHECK-NEXT:  -     3.00    -      -      -      -      -      -      -     1.00    -      -      -      -      -     1.00    -      -      -      -     3.00    -      -     vmulps	(%rsi), %xmm0, %xmm0
# CHECK-NEXT:  -      -      -      -      -      -     2.00    -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -     addq	%rsi, %rsi
