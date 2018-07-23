# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=znver1 -iterations=1500 -timeline -timeline-max-iterations=8 < %s | FileCheck %s

lzcnt %ax, %bx  ## partial register stall.

# CHECK:      Iterations:        1500
# CHECK-NEXT: Instructions:      1500
# CHECK-NEXT: Total Cycles:      379
# CHECK-NEXT: Dispatch Width:    4
# CHECK-NEXT: IPC:               3.96
# CHECK-NEXT: Block RThroughput: 0.3

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      2     0.25                        lzcntw	%ax, %bx

# CHECK:      Resources:
# CHECK-NEXT: [0]   - ZnAGU0
# CHECK-NEXT: [1]   - ZnAGU1
# CHECK-NEXT: [2]   - ZnALU0
# CHECK-NEXT: [3]   - ZnALU1
# CHECK-NEXT: [4]   - ZnALU2
# CHECK-NEXT: [5]   - ZnALU3
# CHECK-NEXT: [6]   - ZnDivider
# CHECK-NEXT: [7]   - ZnFPU0
# CHECK-NEXT: [8]   - ZnFPU1
# CHECK-NEXT: [9]   - ZnFPU2
# CHECK-NEXT: [10]  - ZnFPU3
# CHECK-NEXT: [11]  - ZnMultiplier

# CHECK:      Resource pressure per iteration:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]
# CHECK-NEXT:  -      -     0.25   0.25   0.25   0.25    -      -      -      -      -      -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   Instructions:
# CHECK-NEXT:  -      -     0.25   0.25   0.25   0.25    -      -      -      -      -      -     lzcntw	%ax, %bx

# CHECK:      Timeline view:
# CHECK-NEXT: Index     012345

# CHECK:      [0,0]     DeeER.   lzcntw	%ax, %bx
# CHECK-NEXT: [1,0]     DeeER.   lzcntw	%ax, %bx
# CHECK-NEXT: [2,0]     DeeER.   lzcntw	%ax, %bx
# CHECK-NEXT: [3,0]     DeeER.   lzcntw	%ax, %bx
# CHECK-NEXT: [4,0]     .DeeER   lzcntw	%ax, %bx
# CHECK-NEXT: [5,0]     .DeeER   lzcntw	%ax, %bx
# CHECK-NEXT: [6,0]     .DeeER   lzcntw	%ax, %bx
# CHECK-NEXT: [7,0]     .DeeER   lzcntw	%ax, %bx

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     8     1.0    1.0    0.0       lzcntw	%ax, %bx
