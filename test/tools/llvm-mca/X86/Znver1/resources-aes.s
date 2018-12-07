# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=znver1 -instruction-tables < %s | FileCheck %s

aesdec          %xmm0, %xmm2
aesdec          (%rax), %xmm2

aesdeclast      %xmm0, %xmm2
aesdeclast      (%rax), %xmm2

aesenc          %xmm0, %xmm2
aesenc          (%rax), %xmm2

aesenclast      %xmm0, %xmm2
aesenclast      (%rax), %xmm2

aesimc          %xmm0, %xmm2
aesimc          (%rax), %xmm2

aeskeygenassist $22, %xmm0, %xmm2
aeskeygenassist $22, (%rax), %xmm2

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      4     0.50                        aesdec	%xmm0, %xmm2
# CHECK-NEXT:  1      11    0.50    *                   aesdec	(%rax), %xmm2
# CHECK-NEXT:  1      4     0.50                        aesdeclast	%xmm0, %xmm2
# CHECK-NEXT:  1      11    0.50    *                   aesdeclast	(%rax), %xmm2
# CHECK-NEXT:  1      4     0.50                        aesenc	%xmm0, %xmm2
# CHECK-NEXT:  1      11    0.50    *                   aesenc	(%rax), %xmm2
# CHECK-NEXT:  1      4     0.50                        aesenclast	%xmm0, %xmm2
# CHECK-NEXT:  1      11    0.50    *                   aesenclast	(%rax), %xmm2
# CHECK-NEXT:  1      4     0.50                        aesimc	%xmm0, %xmm2
# CHECK-NEXT:  1      11    0.50    *                   aesimc	(%rax), %xmm2
# CHECK-NEXT:  1      4     0.50                        aeskeygenassist	$22, %xmm0, %xmm2
# CHECK-NEXT:  1      11    0.50    *                   aeskeygenassist	$22, (%rax), %xmm2

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
# CHECK-NEXT: 3.00   3.00    -      -      -      -      -     6.00   6.00    -      -      -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   Instructions:
# CHECK-NEXT:  -      -      -      -      -      -      -     0.50   0.50    -      -      -     aesdec	%xmm0, %xmm2
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -     0.50   0.50    -      -      -     aesdec	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -      -      -     0.50   0.50    -      -      -     aesdeclast	%xmm0, %xmm2
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -     0.50   0.50    -      -      -     aesdeclast	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -      -      -     0.50   0.50    -      -      -     aesenc	%xmm0, %xmm2
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -     0.50   0.50    -      -      -     aesenc	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -      -      -     0.50   0.50    -      -      -     aesenclast	%xmm0, %xmm2
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -     0.50   0.50    -      -      -     aesenclast	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -      -      -     0.50   0.50    -      -      -     aesimc	%xmm0, %xmm2
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -     0.50   0.50    -      -      -     aesimc	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -      -      -     0.50   0.50    -      -      -     aeskeygenassist	$22, %xmm0, %xmm2
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -     0.50   0.50    -      -      -     aeskeygenassist	$22, (%rax), %xmm2
