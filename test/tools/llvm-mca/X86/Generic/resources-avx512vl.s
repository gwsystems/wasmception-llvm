# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=x86-64 -instruction-tables < %s | FileCheck %s

vaddpd            %xmm16, %xmm17, %xmm19
vaddpd            (%rax), %xmm17, %xmm19
vaddpd            %xmm16, %xmm17, %xmm19 {k1}
vaddpd            (%rax), %xmm17, %xmm19 {k1}
vaddpd            %xmm16, %xmm17, %xmm19 {z}{k1}
vaddpd            (%rax), %xmm17, %xmm19 {z}{k1}

vaddpd            %ymm16, %ymm17, %ymm19
vaddpd            (%rax), %ymm17, %ymm19
vaddpd            %ymm16, %ymm17, %ymm19 {k1}
vaddpd            (%rax), %ymm17, %ymm19 {k1}
vaddpd            %ymm16, %ymm17, %ymm19 {z}{k1}
vaddpd            (%rax), %ymm17, %ymm19 {z}{k1}

vaddps            %xmm16, %xmm17, %xmm19
vaddps            (%rax), %xmm17, %xmm19
vaddps            %xmm16, %xmm17, %xmm19 {k1}
vaddps            (%rax), %xmm17, %xmm19 {k1}
vaddps            %xmm16, %xmm17, %xmm19 {z}{k1}
vaddps            (%rax), %xmm17, %xmm19 {z}{k1}

vaddps            %ymm16, %ymm17, %ymm19
vaddps            (%rax), %ymm17, %ymm19
vaddps            %ymm16, %ymm17, %ymm19 {k1}
vaddps            (%rax), %ymm17, %ymm19 {k1}
vaddps            %ymm16, %ymm17, %ymm19 {z}{k1}
vaddps            (%rax), %ymm17, %ymm19 {z}{k1}

vdivpd            %xmm16, %xmm17, %xmm19
vdivpd            (%rax), %xmm17, %xmm19
vdivpd            %xmm16, %xmm17, %xmm19 {k1}
vdivpd            (%rax), %xmm17, %xmm19 {k1}
vdivpd            %xmm16, %xmm17, %xmm19 {z}{k1}
vdivpd            (%rax), %xmm17, %xmm19 {z}{k1}

vdivpd            %ymm16, %ymm17, %ymm19
vdivpd            (%rax), %ymm17, %ymm19
vdivpd            %ymm16, %ymm17, %ymm19 {k1}
vdivpd            (%rax), %ymm17, %ymm19 {k1}
vdivpd            %ymm16, %ymm17, %ymm19 {z}{k1}
vdivpd            (%rax), %ymm17, %ymm19 {z}{k1}

vdivps            %xmm16, %xmm17, %xmm19
vdivps            (%rax), %xmm17, %xmm19
vdivps            %xmm16, %xmm17, %xmm19 {k1}
vdivps            (%rax), %xmm17, %xmm19 {k1}
vdivps            %xmm16, %xmm17, %xmm19 {z}{k1}
vdivps            (%rax), %xmm17, %xmm19 {z}{k1}

vdivps            %ymm16, %ymm17, %ymm19
vdivps            (%rax), %ymm17, %ymm19
vdivps            %ymm16, %ymm17, %ymm19 {k1}
vdivps            (%rax), %ymm17, %ymm19 {k1}
vdivps            %ymm16, %ymm17, %ymm19 {z}{k1}
vdivps            (%rax), %ymm17, %ymm19 {z}{k1}

vmulpd            %xmm16, %xmm17, %xmm19
vmulpd            (%rax), %xmm17, %xmm19
vmulpd            %xmm16, %xmm17, %xmm19 {k1}
vmulpd            (%rax), %xmm17, %xmm19 {k1}
vmulpd            %xmm16, %xmm17, %xmm19 {z}{k1}
vmulpd            (%rax), %xmm17, %xmm19 {z}{k1}

vmulpd            %ymm16, %ymm17, %ymm19
vmulpd            (%rax), %ymm17, %ymm19
vmulpd            %ymm16, %ymm17, %ymm19 {k1}
vmulpd            (%rax), %ymm17, %ymm19 {k1}
vmulpd            %ymm16, %ymm17, %ymm19 {z}{k1}
vmulpd            (%rax), %ymm17, %ymm19 {z}{k1}

vmulps            %xmm16, %xmm17, %xmm19
vmulps            (%rax), %xmm17, %xmm19
vmulps            %xmm16, %xmm17, %xmm19 {k1}
vmulps            (%rax), %xmm17, %xmm19 {k1}
vmulps            %xmm16, %xmm17, %xmm19 {z}{k1}
vmulps            (%rax), %xmm17, %xmm19 {z}{k1}

vmulps            %ymm16, %ymm17, %ymm19
vmulps            (%rax), %ymm17, %ymm19
vmulps            %ymm16, %ymm17, %ymm19 {k1}
vmulps            (%rax), %ymm17, %ymm19 {k1}
vmulps            %ymm16, %ymm17, %ymm19 {z}{k1}
vmulps            (%rax), %ymm17, %ymm19 {z}{k1}

vsubpd            %xmm16, %xmm17, %xmm19
vsubpd            (%rax), %xmm17, %xmm19
vsubpd            %xmm16, %xmm17, %xmm19 {k1}
vsubpd            (%rax), %xmm17, %xmm19 {k1}
vsubpd            %xmm16, %xmm17, %xmm19 {z}{k1}
vsubpd            (%rax), %xmm17, %xmm19 {z}{k1}

vsubpd            %ymm16, %ymm17, %ymm19
vsubpd            (%rax), %ymm17, %ymm19
vsubpd            %ymm16, %ymm17, %ymm19 {k1}
vsubpd            (%rax), %ymm17, %ymm19 {k1}
vsubpd            %ymm16, %ymm17, %ymm19 {z}{k1}
vsubpd            (%rax), %ymm17, %ymm19 {z}{k1}

vsubps            %xmm16, %xmm17, %xmm19
vsubps            (%rax), %xmm17, %xmm19
vsubps            %xmm16, %xmm17, %xmm19 {k1}
vsubps            (%rax), %xmm17, %xmm19 {k1}
vsubps            %xmm16, %xmm17, %xmm19 {z}{k1}
vsubps            (%rax), %xmm17, %xmm19 {z}{k1}

vsubps            %ymm16, %ymm17, %ymm19
vsubps            (%rax), %ymm17, %ymm19
vsubps            %ymm16, %ymm17, %ymm19 {k1}
vsubps            (%rax), %ymm17, %ymm19 {k1}
vsubps            %ymm16, %ymm17, %ymm19 {z}{k1}
vsubps            (%rax), %ymm17, %ymm19 {z}{k1}

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      3     1.00                        vaddpd	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  2      9     1.00    *                   vaddpd	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  1      3     1.00                        vaddpd	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  2      9     1.00    *                   vaddpd	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  1      3     1.00                        vaddpd	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  2      9     1.00    *                   vaddpd	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  1      3     1.00                        vaddpd	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  2      10    1.00    *                   vaddpd	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  1      3     1.00                        vaddpd	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  2      10    1.00    *                   vaddpd	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  1      3     1.00                        vaddpd	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  2      10    1.00    *                   vaddpd	(%rax), %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  1      3     1.00                        vaddps	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  2      9     1.00    *                   vaddps	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  1      3     1.00                        vaddps	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  2      9     1.00    *                   vaddps	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  1      3     1.00                        vaddps	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  2      9     1.00    *                   vaddps	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  1      3     1.00                        vaddps	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  2      10    1.00    *                   vaddps	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  1      3     1.00                        vaddps	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  2      10    1.00    *                   vaddps	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  1      3     1.00                        vaddps	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  2      10    1.00    *                   vaddps	(%rax), %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  1      22    22.00                       vdivpd	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  2      28    22.00   *                   vdivpd	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  1      22    22.00                       vdivpd	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  2      28    22.00   *                   vdivpd	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  1      22    22.00                       vdivpd	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  2      28    22.00   *                   vdivpd	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  3      45    44.00                       vdivpd	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  4      52    44.00   *                   vdivpd	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  3      45    44.00                       vdivpd	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  4      52    44.00   *                   vdivpd	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  3      45    44.00                       vdivpd	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  4      52    44.00   *                   vdivpd	(%rax), %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  1      14    14.00                       vdivps	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  2      20    14.00   *                   vdivps	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  1      14    14.00                       vdivps	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  2      20    14.00   *                   vdivps	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  1      14    14.00                       vdivps	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  2      20    14.00   *                   vdivps	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  3      29    28.00                       vdivps	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  4      36    28.00   *                   vdivps	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  3      29    28.00                       vdivps	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  4      36    28.00   *                   vdivps	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  3      29    28.00                       vdivps	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  4      36    28.00   *                   vdivps	(%rax), %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  1      5     1.00                        vmulpd	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  2      11    1.00    *                   vmulpd	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  1      5     1.00                        vmulpd	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  2      11    1.00    *                   vmulpd	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  1      5     1.00                        vmulpd	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  2      11    1.00    *                   vmulpd	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  1      5     1.00                        vmulpd	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  2      12    1.00    *                   vmulpd	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  1      5     1.00                        vmulpd	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  2      12    1.00    *                   vmulpd	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  1      5     1.00                        vmulpd	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  2      12    1.00    *                   vmulpd	(%rax), %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  1      5     1.00                        vmulps	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  2      11    1.00    *                   vmulps	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  1      5     1.00                        vmulps	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  2      11    1.00    *                   vmulps	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  1      5     1.00                        vmulps	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  2      11    1.00    *                   vmulps	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  1      5     1.00                        vmulps	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  2      12    1.00    *                   vmulps	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  1      5     1.00                        vmulps	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  2      12    1.00    *                   vmulps	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  1      5     1.00                        vmulps	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  2      12    1.00    *                   vmulps	(%rax), %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  1      3     1.00                        vsubpd	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  2      9     1.00    *                   vsubpd	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  1      3     1.00                        vsubpd	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  2      9     1.00    *                   vsubpd	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  1      3     1.00                        vsubpd	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  2      9     1.00    *                   vsubpd	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  1      3     1.00                        vsubpd	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  2      10    1.00    *                   vsubpd	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  1      3     1.00                        vsubpd	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  2      10    1.00    *                   vsubpd	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  1      3     1.00                        vsubpd	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  2      10    1.00    *                   vsubpd	(%rax), %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  1      3     1.00                        vsubps	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  2      9     1.00    *                   vsubps	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  1      3     1.00                        vsubps	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  2      9     1.00    *                   vsubps	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  1      3     1.00                        vsubps	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  2      9     1.00    *                   vsubps	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  1      3     1.00                        vsubps	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  2      10    1.00    *                   vsubps	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  1      3     1.00                        vsubps	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  2      10    1.00    *                   vsubps	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  1      3     1.00                        vsubps	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  2      10    1.00    *                   vsubps	(%rax), %ymm17, %ymm19 {%k1} {z}

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
# CHECK-NEXT:  -     648.00 66.00  48.00   -     6.00   24.00  24.00

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6.0]  [6.1]  Instructions:
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -     vaddpd	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  -      -      -     1.00    -      -     0.50   0.50   vaddpd	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -     vaddpd	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -      -      -     1.00    -      -     0.50   0.50   vaddpd	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -     vaddpd	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     1.00    -      -     0.50   0.50   vaddpd	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -     vaddpd	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  -      -      -     1.00    -      -     0.50   0.50   vaddpd	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -     vaddpd	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -      -      -     1.00    -      -     0.50   0.50   vaddpd	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -     vaddpd	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     1.00    -      -     0.50   0.50   vaddpd	(%rax), %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -     vaddps	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  -      -      -     1.00    -      -     0.50   0.50   vaddps	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -     vaddps	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -      -      -     1.00    -      -     0.50   0.50   vaddps	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -     vaddps	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     1.00    -      -     0.50   0.50   vaddps	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -     vaddps	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  -      -      -     1.00    -      -     0.50   0.50   vaddps	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -     vaddps	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -      -      -     1.00    -      -     0.50   0.50   vaddps	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -     vaddps	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     1.00    -      -     0.50   0.50   vaddps	(%rax), %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  -     22.00  1.00    -      -      -      -      -     vdivpd	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  -     22.00  1.00    -      -      -     0.50   0.50   vdivpd	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  -     22.00  1.00    -      -      -      -      -     vdivpd	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -     22.00  1.00    -      -      -     0.50   0.50   vdivpd	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -     22.00  1.00    -      -      -      -      -     vdivpd	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -     22.00  1.00    -      -      -     0.50   0.50   vdivpd	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -     44.00  2.50    -      -     0.50    -      -     vdivpd	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  -     44.00  2.50    -      -     0.50   0.50   0.50   vdivpd	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  -     44.00  2.50    -      -     0.50    -      -     vdivpd	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -     44.00  2.50    -      -     0.50   0.50   0.50   vdivpd	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -     44.00  2.50    -      -     0.50    -      -     vdivpd	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  -     44.00  2.50    -      -     0.50   0.50   0.50   vdivpd	(%rax), %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  -     14.00  1.00    -      -      -      -      -     vdivps	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  -     14.00  1.00    -      -      -     0.50   0.50   vdivps	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  -     14.00  1.00    -      -      -      -      -     vdivps	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -     14.00  1.00    -      -      -     0.50   0.50   vdivps	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -     14.00  1.00    -      -      -      -      -     vdivps	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -     14.00  1.00    -      -      -     0.50   0.50   vdivps	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -     28.00  2.50    -      -     0.50    -      -     vdivps	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  -     28.00  2.50    -      -     0.50   0.50   0.50   vdivps	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  -     28.00  2.50    -      -     0.50    -      -     vdivps	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -     28.00  2.50    -      -     0.50   0.50   0.50   vdivps	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -     28.00  2.50    -      -     0.50    -      -     vdivps	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  -     28.00  2.50    -      -     0.50   0.50   0.50   vdivps	(%rax), %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  -      -     1.00    -      -      -      -      -     vmulpd	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  -      -     1.00    -      -      -     0.50   0.50   vmulpd	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  -      -     1.00    -      -      -      -      -     vmulpd	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -      -     1.00    -      -      -     0.50   0.50   vmulpd	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -      -     1.00    -      -      -      -      -     vmulpd	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -     1.00    -      -      -     0.50   0.50   vmulpd	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -     1.00    -      -      -      -      -     vmulpd	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  -      -     1.00    -      -      -     0.50   0.50   vmulpd	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  -      -     1.00    -      -      -      -      -     vmulpd	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -      -     1.00    -      -      -     0.50   0.50   vmulpd	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -      -     1.00    -      -      -      -      -     vmulpd	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  -      -     1.00    -      -      -     0.50   0.50   vmulpd	(%rax), %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  -      -     1.00    -      -      -      -      -     vmulps	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  -      -     1.00    -      -      -     0.50   0.50   vmulps	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  -      -     1.00    -      -      -      -      -     vmulps	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -      -     1.00    -      -      -     0.50   0.50   vmulps	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -      -     1.00    -      -      -      -      -     vmulps	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -     1.00    -      -      -     0.50   0.50   vmulps	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -     1.00    -      -      -      -      -     vmulps	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  -      -     1.00    -      -      -     0.50   0.50   vmulps	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  -      -     1.00    -      -      -      -      -     vmulps	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -      -     1.00    -      -      -     0.50   0.50   vmulps	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -      -     1.00    -      -      -      -      -     vmulps	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  -      -     1.00    -      -      -     0.50   0.50   vmulps	(%rax), %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -     vsubpd	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  -      -      -     1.00    -      -     0.50   0.50   vsubpd	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -     vsubpd	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -      -      -     1.00    -      -     0.50   0.50   vsubpd	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -     vsubpd	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     1.00    -      -     0.50   0.50   vsubpd	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -     vsubpd	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  -      -      -     1.00    -      -     0.50   0.50   vsubpd	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -     vsubpd	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -      -      -     1.00    -      -     0.50   0.50   vsubpd	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -     vsubpd	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     1.00    -      -     0.50   0.50   vsubpd	(%rax), %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -     vsubps	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  -      -      -     1.00    -      -     0.50   0.50   vsubps	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -     vsubps	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -      -      -     1.00    -      -     0.50   0.50   vsubps	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -     vsubps	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     1.00    -      -     0.50   0.50   vsubps	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -     vsubps	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  -      -      -     1.00    -      -     0.50   0.50   vsubps	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -     vsubps	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -      -      -     1.00    -      -     0.50   0.50   vsubps	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -     vsubps	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     1.00    -      -     0.50   0.50   vsubps	(%rax), %ymm17, %ymm19 {%k1} {z}
