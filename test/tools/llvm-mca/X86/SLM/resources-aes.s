# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=goldmont -instruction-tables < %s | FileCheck %s

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
# CHECK-NEXT:  1      8     5.00                        aesdec	%xmm0, %xmm2
# CHECK-NEXT:  1      8     5.00    *                   aesdec	(%rax), %xmm2
# CHECK-NEXT:  1      8     5.00                        aesdeclast	%xmm0, %xmm2
# CHECK-NEXT:  1      8     5.00    *                   aesdeclast	(%rax), %xmm2
# CHECK-NEXT:  1      8     5.00                        aesenc	%xmm0, %xmm2
# CHECK-NEXT:  1      8     5.00    *                   aesenc	(%rax), %xmm2
# CHECK-NEXT:  1      8     5.00                        aesenclast	%xmm0, %xmm2
# CHECK-NEXT:  1      8     5.00    *                   aesenclast	(%rax), %xmm2
# CHECK-NEXT:  1      8     5.00                        aesimc	%xmm0, %xmm2
# CHECK-NEXT:  1      8     5.00    *                   aesimc	(%rax), %xmm2
# CHECK-NEXT:  1      8     5.00                        aeskeygenassist	$22, %xmm0, %xmm2
# CHECK-NEXT:  1      8     5.00    *                   aeskeygenassist	$22, (%rax), %xmm2

# CHECK:      Resources:
# CHECK-NEXT: [0]   - SLMDivider
# CHECK-NEXT: [1]   - SLMFPDivider
# CHECK-NEXT: [2]   - SLMFPMultiplier
# CHECK-NEXT: [3]   - SLM_FPC_RSV0
# CHECK-NEXT: [4]   - SLM_FPC_RSV1
# CHECK-NEXT: [5]   - SLM_IEC_RSV0
# CHECK-NEXT: [6]   - SLM_IEC_RSV1
# CHECK-NEXT: [7]   - SLM_MEC_RSV

# CHECK:      Resource pressure per iteration:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]
# CHECK-NEXT:  -      -      -     60.00   -      -      -     6.00

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    Instructions:
# CHECK-NEXT:  -      -      -     5.00    -      -      -      -     aesdec	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     5.00    -      -      -     1.00   aesdec	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     5.00    -      -      -      -     aesdeclast	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     5.00    -      -      -     1.00   aesdeclast	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     5.00    -      -      -      -     aesenc	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     5.00    -      -      -     1.00   aesenc	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     5.00    -      -      -      -     aesenclast	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     5.00    -      -      -     1.00   aesenclast	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     5.00    -      -      -      -     aesimc	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     5.00    -      -      -     1.00   aesimc	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     5.00    -      -      -      -     aeskeygenassist	$22, %xmm0, %xmm2
# CHECK-NEXT:  -      -      -     5.00    -      -      -     1.00   aeskeygenassist	$22, (%rax), %xmm2
