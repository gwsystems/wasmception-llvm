# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=x86-64 -instruction-tables < %s | FileCheck %s

vfmaddpd    %xmm0, %xmm1, %xmm2, %xmm3
vfmaddpd    (%rax), %xmm1, %xmm2, %xmm3
vfmaddpd    %xmm0, (%rax), %xmm2, %xmm3

vfmaddpd    %ymm0, %ymm1, %ymm2, %ymm3
vfmaddpd    (%rax), %ymm1, %ymm2, %ymm3
vfmaddpd    %ymm0, (%rax), %ymm2, %ymm3

vfmaddps    %xmm0, %xmm1, %xmm2, %xmm3
vfmaddps    (%rax), %xmm1, %xmm2, %xmm3
vfmaddps    %xmm0, (%rax), %xmm2, %xmm3

vfmaddps    %ymm0, %ymm1, %ymm2, %ymm3
vfmaddps    (%rax), %ymm1, %ymm2, %ymm3
vfmaddps    %ymm0, (%rax), %ymm2, %ymm3

vfmaddsd    %xmm0, %xmm1, %xmm2, %xmm3
vfmaddsd    (%rax), %xmm1, %xmm2, %xmm3
vfmaddsd    %xmm0, (%rax), %xmm2, %xmm3

vfmaddss    %xmm0, %xmm1, %xmm2, %xmm3
vfmaddss    (%rax), %xmm1, %xmm2, %xmm3
vfmaddss    %xmm0, (%rax), %xmm2, %xmm3

vfmaddsubpd %xmm0, %xmm1, %xmm2, %xmm3
vfmaddsubpd (%rax), %xmm1, %xmm2, %xmm3
vfmaddsubpd %xmm0, (%rax), %xmm2, %xmm3

vfmaddsubpd %ymm0, %ymm1, %ymm2, %ymm3
vfmaddsubpd (%rax), %ymm1, %ymm2, %ymm3
vfmaddsubpd %ymm0, (%rax), %ymm2, %ymm3

vfmaddsubps %xmm0, %xmm1, %xmm2, %xmm3
vfmaddsubps (%rax), %xmm1, %xmm2, %xmm3
vfmaddsubps %xmm0, (%rax), %xmm2, %xmm3

vfmaddsubps %ymm0, %ymm1, %ymm2, %ymm3
vfmaddsubps (%rax), %ymm1, %ymm2, %ymm3
vfmaddsubps %ymm0, (%rax), %ymm2, %ymm3

vfmsubaddpd %xmm0, %xmm1, %xmm2, %xmm3
vfmsubaddpd (%rax), %xmm1, %xmm2, %xmm3
vfmsubaddpd %xmm0, (%rax), %xmm2, %xmm3

vfmsubaddpd %ymm0, %ymm1, %ymm2, %ymm3
vfmsubaddpd (%rax), %ymm1, %ymm2, %ymm3
vfmsubaddpd %ymm0, (%rax), %ymm2, %ymm3

vfmsubaddps %xmm0, %xmm1, %xmm2, %xmm3
vfmsubaddps (%rax), %xmm1, %xmm2, %xmm3
vfmsubaddps %xmm0, (%rax), %xmm2, %xmm3

vfmsubaddps %ymm0, %ymm1, %ymm2, %ymm3
vfmsubaddps (%rax), %ymm1, %ymm2, %ymm3
vfmsubaddps %ymm0, (%rax), %ymm2, %ymm3

vfmsubpd    %xmm0, %xmm1, %xmm2, %xmm3
vfmsubpd    (%rax), %xmm1, %xmm2, %xmm3
vfmsubpd    %xmm0, (%rax), %xmm2, %xmm3

vfmsubpd    %ymm0, %ymm1, %ymm2, %ymm3
vfmsubpd    (%rax), %ymm1, %ymm2, %ymm3
vfmsubpd    %ymm0, (%rax), %ymm2, %ymm3

vfmsubps    %xmm0, %xmm1, %xmm2, %xmm3
vfmsubps    (%rax), %xmm1, %xmm2, %xmm3
vfmsubps    %xmm0, (%rax), %xmm2, %xmm3

vfmsubps    %ymm0, %ymm1, %ymm2, %ymm3
vfmsubps    (%rax), %ymm1, %ymm2, %ymm3
vfmsubps    %ymm0, (%rax), %ymm2, %ymm3

vfmsubsd    %xmm0, %xmm1, %xmm2, %xmm3
vfmsubsd    (%rax), %xmm1, %xmm2, %xmm3
vfmsubsd    %xmm0, (%rax), %xmm2, %xmm3

vfmsubss    %xmm0, %xmm1, %xmm2, %xmm3
vfmsubss    (%rax), %xmm1, %xmm2, %xmm3
vfmsubss    %xmm0, (%rax), %xmm2, %xmm3

vfnmaddpd   %xmm0, %xmm1, %xmm2, %xmm3
vfnmaddpd   (%rax), %xmm1, %xmm2, %xmm3
vfnmaddpd   %xmm0, (%rax), %xmm2, %xmm3

vfnmaddpd   %ymm0, %ymm1, %ymm2, %ymm3
vfnmaddpd   (%rax), %ymm1, %ymm2, %ymm3
vfnmaddpd   %ymm0, (%rax), %ymm2, %ymm3

vfnmaddps   %xmm0, %xmm1, %xmm2, %xmm3
vfnmaddps   (%rax), %xmm1, %xmm2, %xmm3
vfnmaddps   %xmm0, (%rax), %xmm2, %xmm3

vfnmaddps   %ymm0, %ymm1, %ymm2, %ymm3
vfnmaddps   (%rax), %ymm1, %ymm2, %ymm3
vfnmaddps   %ymm0, (%rax), %ymm2, %ymm3

vfnmaddsd   %xmm0, %xmm1, %xmm2, %xmm3
vfnmaddsd   (%rax), %xmm1, %xmm2, %xmm3
vfnmaddsd   %xmm0, (%rax), %xmm2, %xmm3

vfnmaddss   %xmm0, %xmm1, %xmm2, %xmm3
vfnmaddss   (%rax), %xmm1, %xmm2, %xmm3
vfnmaddss   %xmm0, (%rax), %xmm2, %xmm3

vfnmsubpd   %xmm0, %xmm1, %xmm2, %xmm3
vfnmsubpd   (%rax), %xmm1, %xmm2, %xmm3
vfnmsubpd   %xmm0, (%rax), %xmm2, %xmm3

vfnmsubpd   %ymm0, %ymm1, %ymm2, %ymm3
vfnmsubpd   (%rax), %ymm1, %ymm2, %ymm3
vfnmsubpd   %ymm0, (%rax), %ymm2, %ymm3

vfnmsubps   %xmm0, %xmm1, %xmm2, %xmm3
vfnmsubps   (%rax), %xmm1, %xmm2, %xmm3
vfnmsubps   %xmm0, (%rax), %xmm2, %xmm3

vfnmsubps   %ymm0, %ymm1, %ymm2, %ymm3
vfnmsubps   (%rax), %ymm1, %ymm2, %ymm3
vfnmsubps   %ymm0, (%rax), %ymm2, %ymm3

vfnmsubsd   %xmm0, %xmm1, %xmm2, %xmm3
vfnmsubsd   (%rax), %xmm1, %xmm2, %xmm3
vfnmsubsd   %xmm0, (%rax), %xmm2, %xmm3

vfnmsubss   %xmm0, %xmm1, %xmm2, %xmm3
vfnmsubss   (%rax), %xmm1, %xmm2, %xmm3
vfnmsubss   %xmm0, (%rax), %xmm2, %xmm3

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      5     0.50                        vfmaddpd	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfmaddpd	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfmaddpd	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  1      5     0.50                        vfmaddpd	%ymm0, %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  2      10    0.50    *                   vfmaddpd	(%rax), %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  2      10    0.50    *                   vfmaddpd	%ymm0, (%rax), %ymm2, %ymm3
# CHECK-NEXT:  1      5     0.50                        vfmaddps	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfmaddps	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfmaddps	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  1      5     0.50                        vfmaddps	%ymm0, %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  2      10    0.50    *                   vfmaddps	(%rax), %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  2      10    0.50    *                   vfmaddps	%ymm0, (%rax), %ymm2, %ymm3
# CHECK-NEXT:  1      5     0.50                        vfmaddsd	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfmaddsd	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfmaddsd	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  1      5     0.50                        vfmaddss	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfmaddss	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfmaddss	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  1      5     0.50                        vfmaddsubpd	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfmaddsubpd	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfmaddsubpd	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  1      5     0.50                        vfmaddsubpd	%ymm0, %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  2      10    0.50    *                   vfmaddsubpd	(%rax), %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  2      10    0.50    *                   vfmaddsubpd	%ymm0, (%rax), %ymm2, %ymm3
# CHECK-NEXT:  1      5     0.50                        vfmaddsubps	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfmaddsubps	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfmaddsubps	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  1      5     0.50                        vfmaddsubps	%ymm0, %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  2      10    0.50    *                   vfmaddsubps	(%rax), %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  2      10    0.50    *                   vfmaddsubps	%ymm0, (%rax), %ymm2, %ymm3
# CHECK-NEXT:  1      5     0.50                        vfmsubaddpd	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfmsubaddpd	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfmsubaddpd	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  1      5     0.50                        vfmsubaddpd	%ymm0, %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  2      10    0.50    *                   vfmsubaddpd	(%rax), %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  2      10    0.50    *                   vfmsubaddpd	%ymm0, (%rax), %ymm2, %ymm3
# CHECK-NEXT:  1      5     0.50                        vfmsubaddps	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfmsubaddps	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfmsubaddps	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  1      5     0.50                        vfmsubaddps	%ymm0, %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  2      10    0.50    *                   vfmsubaddps	(%rax), %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  2      10    0.50    *                   vfmsubaddps	%ymm0, (%rax), %ymm2, %ymm3
# CHECK-NEXT:  1      5     0.50                        vfmsubpd	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfmsubpd	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfmsubpd	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  1      5     0.50                        vfmsubpd	%ymm0, %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  2      10    0.50    *                   vfmsubpd	(%rax), %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  2      10    0.50    *                   vfmsubpd	%ymm0, (%rax), %ymm2, %ymm3
# CHECK-NEXT:  1      5     0.50                        vfmsubps	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfmsubps	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfmsubps	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  1      5     0.50                        vfmsubps	%ymm0, %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  2      10    0.50    *                   vfmsubps	(%rax), %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  2      10    0.50    *                   vfmsubps	%ymm0, (%rax), %ymm2, %ymm3
# CHECK-NEXT:  1      5     0.50                        vfmsubsd	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfmsubsd	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfmsubsd	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  1      5     0.50                        vfmsubss	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfmsubss	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfmsubss	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  1      5     0.50                        vfnmaddpd	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfnmaddpd	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfnmaddpd	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  1      5     0.50                        vfnmaddpd	%ymm0, %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  2      10    0.50    *                   vfnmaddpd	(%rax), %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  2      10    0.50    *                   vfnmaddpd	%ymm0, (%rax), %ymm2, %ymm3
# CHECK-NEXT:  1      5     0.50                        vfnmaddps	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfnmaddps	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfnmaddps	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  1      5     0.50                        vfnmaddps	%ymm0, %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  2      10    0.50    *                   vfnmaddps	(%rax), %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  2      10    0.50    *                   vfnmaddps	%ymm0, (%rax), %ymm2, %ymm3
# CHECK-NEXT:  1      5     0.50                        vfnmaddsd	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfnmaddsd	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfnmaddsd	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  1      5     0.50                        vfnmaddss	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfnmaddss	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfnmaddss	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  1      5     0.50                        vfnmsubpd	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfnmsubpd	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfnmsubpd	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  1      5     0.50                        vfnmsubpd	%ymm0, %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  2      10    0.50    *                   vfnmsubpd	(%rax), %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  2      10    0.50    *                   vfnmsubpd	%ymm0, (%rax), %ymm2, %ymm3
# CHECK-NEXT:  1      5     0.50                        vfnmsubps	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfnmsubps	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfnmsubps	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  1      5     0.50                        vfnmsubps	%ymm0, %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  2      10    0.50    *                   vfnmsubps	(%rax), %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  2      10    0.50    *                   vfnmsubps	%ymm0, (%rax), %ymm2, %ymm3
# CHECK-NEXT:  1      5     0.50                        vfnmsubsd	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfnmsubsd	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfnmsubsd	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  1      5     0.50                        vfnmsubss	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfnmsubss	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  2      10    0.50    *                   vfnmsubss	%xmm0, (%rax), %xmm2, %xmm3

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
# CHECK-NEXT:  -      -     48.00  48.00   -      -     32.00  32.00

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6.0]  [6.1]  Instructions:
# CHECK-NEXT:  -      -     0.50   0.50    -      -      -      -     vfmaddpd	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmaddpd	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmaddpd	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -      -      -     vfmaddpd	%ymm0, %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmaddpd	(%rax), %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmaddpd	%ymm0, (%rax), %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -      -      -     vfmaddps	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmaddps	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmaddps	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -      -      -     vfmaddps	%ymm0, %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmaddps	(%rax), %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmaddps	%ymm0, (%rax), %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -      -      -     vfmaddsd	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmaddsd	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmaddsd	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -      -      -     vfmaddss	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmaddss	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmaddss	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -      -      -     vfmaddsubpd	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmaddsubpd	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmaddsubpd	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -      -      -     vfmaddsubpd	%ymm0, %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmaddsubpd	(%rax), %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmaddsubpd	%ymm0, (%rax), %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -      -      -     vfmaddsubps	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmaddsubps	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmaddsubps	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -      -      -     vfmaddsubps	%ymm0, %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmaddsubps	(%rax), %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmaddsubps	%ymm0, (%rax), %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -      -      -     vfmsubaddpd	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmsubaddpd	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmsubaddpd	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -      -      -     vfmsubaddpd	%ymm0, %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmsubaddpd	(%rax), %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmsubaddpd	%ymm0, (%rax), %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -      -      -     vfmsubaddps	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmsubaddps	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmsubaddps	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -      -      -     vfmsubaddps	%ymm0, %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmsubaddps	(%rax), %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmsubaddps	%ymm0, (%rax), %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -      -      -     vfmsubpd	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmsubpd	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmsubpd	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -      -      -     vfmsubpd	%ymm0, %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmsubpd	(%rax), %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmsubpd	%ymm0, (%rax), %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -      -      -     vfmsubps	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmsubps	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmsubps	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -      -      -     vfmsubps	%ymm0, %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmsubps	(%rax), %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmsubps	%ymm0, (%rax), %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -      -      -     vfmsubsd	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmsubsd	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmsubsd	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -      -      -     vfmsubss	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmsubss	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfmsubss	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -      -      -     vfnmaddpd	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfnmaddpd	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfnmaddpd	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -      -      -     vfnmaddpd	%ymm0, %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfnmaddpd	(%rax), %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfnmaddpd	%ymm0, (%rax), %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -      -      -     vfnmaddps	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfnmaddps	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfnmaddps	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -      -      -     vfnmaddps	%ymm0, %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfnmaddps	(%rax), %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfnmaddps	%ymm0, (%rax), %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -      -      -     vfnmaddsd	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfnmaddsd	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfnmaddsd	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -      -      -     vfnmaddss	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfnmaddss	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfnmaddss	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -      -      -     vfnmsubpd	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfnmsubpd	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfnmsubpd	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -      -      -     vfnmsubpd	%ymm0, %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfnmsubpd	(%rax), %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfnmsubpd	%ymm0, (%rax), %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -      -      -     vfnmsubps	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfnmsubps	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfnmsubps	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -      -      -     vfnmsubps	%ymm0, %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfnmsubps	(%rax), %ymm1, %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfnmsubps	%ymm0, (%rax), %ymm2, %ymm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -      -      -     vfnmsubsd	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfnmsubsd	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfnmsubsd	%xmm0, (%rax), %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -      -      -     vfnmsubss	%xmm0, %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfnmsubss	(%rax), %xmm1, %xmm2, %xmm3
# CHECK-NEXT:  -      -     0.50   0.50    -      -     0.50   0.50   vfnmsubss	%xmm0, (%rax), %xmm2, %xmm3
