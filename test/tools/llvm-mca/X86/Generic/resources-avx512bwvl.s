# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=x86-64 -instruction-tables < %s | FileCheck %s

vpabsb            %xmm16, %xmm19
vpabsb            (%rax), %xmm19
vpabsb            %xmm16, %xmm19 {k1}
vpabsb            (%rax), %xmm19 {k1}
vpabsb            %xmm16, %xmm19 {z}{k1}
vpabsb            (%rax), %xmm19 {z}{k1}

vpabsb            %ymm16, %ymm19
vpabsb            (%rax), %ymm19
vpabsb            %ymm16, %ymm19 {k1}
vpabsb            (%rax), %ymm19 {k1}
vpabsb            %ymm16, %ymm19 {z}{k1}
vpabsb            (%rax), %ymm19 {z}{k1}

vpabsw            %xmm16, %xmm19
vpabsw            (%rax), %xmm19
vpabsw            %xmm16, %xmm19 {k1}
vpabsw            (%rax), %xmm19 {k1}
vpabsw            %xmm16, %xmm19 {z}{k1}
vpabsw            (%rax), %xmm19 {z}{k1}

vpabsw            %ymm16, %ymm19
vpabsw            (%rax), %ymm19
vpabsw            %ymm16, %ymm19 {k1}
vpabsw            (%rax), %ymm19 {k1}
vpabsw            %ymm16, %ymm19 {z}{k1}
vpabsw            (%rax), %ymm19 {z}{k1}

vpaddb            %xmm16, %xmm17, %xmm19
vpaddb            (%rax), %xmm17, %xmm19
vpaddb            %xmm16, %xmm17, %xmm19 {k1}
vpaddb            (%rax), %xmm17, %xmm19 {k1}
vpaddb            %xmm16, %xmm17, %xmm19 {z}{k1}
vpaddb            (%rax), %xmm17, %xmm19 {z}{k1}

vpaddb            %ymm16, %ymm17, %ymm19
vpaddb            (%rax), %ymm17, %ymm19
vpaddb            %ymm16, %ymm17, %ymm19 {k1}
vpaddb            (%rax), %ymm17, %ymm19 {k1}
vpaddb            %ymm16, %ymm17, %ymm19 {z}{k1}
vpaddb            (%rax), %ymm17, %ymm19 {z}{k1}

vpaddw            %xmm16, %xmm17, %xmm19
vpaddw            (%rax), %xmm17, %xmm19
vpaddw            %xmm16, %xmm17, %xmm19 {k1}
vpaddw            (%rax), %xmm17, %xmm19 {k1}
vpaddw            %xmm16, %xmm17, %xmm19 {z}{k1}
vpaddw            (%rax), %xmm17, %xmm19 {z}{k1}

vpaddw            %ymm16, %ymm17, %ymm19
vpaddw            (%rax), %ymm17, %ymm19
vpaddw            %ymm16, %ymm17, %ymm19 {k1}
vpaddw            (%rax), %ymm17, %ymm19 {k1}
vpaddw            %ymm16, %ymm17, %ymm19 {z}{k1}
vpaddw            (%rax), %ymm17, %ymm19 {z}{k1}

vpsubb            %xmm16, %xmm17, %xmm19
vpsubb            (%rax), %xmm17, %xmm19
vpsubb            %xmm16, %xmm17, %xmm19 {k1}
vpsubb            (%rax), %xmm17, %xmm19 {k1}
vpsubb            %xmm16, %xmm17, %xmm19 {z}{k1}
vpsubb            (%rax), %xmm17, %xmm19 {z}{k1}

vpsubb            %ymm16, %ymm17, %ymm19
vpsubb            (%rax), %ymm17, %ymm19
vpsubb            %ymm16, %ymm17, %ymm19 {k1}
vpsubb            (%rax), %ymm17, %ymm19 {k1}
vpsubb            %ymm16, %ymm17, %ymm19 {z}{k1}
vpsubb            (%rax), %ymm17, %ymm19 {z}{k1}

vpsubw            %xmm16, %xmm17, %xmm19
vpsubw            (%rax), %xmm17, %xmm19
vpsubw            %xmm16, %xmm17, %xmm19 {k1}
vpsubw            (%rax), %xmm17, %xmm19 {k1}
vpsubw            %xmm16, %xmm17, %xmm19 {z}{k1}
vpsubw            (%rax), %xmm17, %xmm19 {z}{k1}

vpsubw            %ymm16, %ymm17, %ymm19
vpsubw            (%rax), %ymm17, %ymm19
vpsubw            %ymm16, %ymm17, %ymm19 {k1}
vpsubw            (%rax), %ymm17, %ymm19 {k1}
vpsubw            %ymm16, %ymm17, %ymm19 {z}{k1}
vpsubw            (%rax), %ymm17, %ymm19 {z}{k1}

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      1     0.50                        vpabsb	%xmm16, %xmm19
# CHECK-NEXT:  2      7     0.50    *                   vpabsb	(%rax), %xmm19
# CHECK-NEXT:  1      1     0.50                        vpabsb	%xmm16, %xmm19 {%k1}
# CHECK-NEXT:  2      7     0.50    *                   vpabsb	(%rax), %xmm19 {%k1}
# CHECK-NEXT:  1      1     0.50                        vpabsb	%xmm16, %xmm19 {%k1} {z}
# CHECK-NEXT:  2      7     0.50    *                   vpabsb	(%rax), %xmm19 {%k1} {z}
# CHECK-NEXT:  1      1     0.50                        vpabsb	%ymm16, %ymm19
# CHECK-NEXT:  2      8     0.50    *                   vpabsb	(%rax), %ymm19
# CHECK-NEXT:  1      1     0.50                        vpabsb	%ymm16, %ymm19 {%k1}
# CHECK-NEXT:  2      8     0.50    *                   vpabsb	(%rax), %ymm19 {%k1}
# CHECK-NEXT:  1      1     0.50                        vpabsb	%ymm16, %ymm19 {%k1} {z}
# CHECK-NEXT:  2      8     0.50    *                   vpabsb	(%rax), %ymm19 {%k1} {z}
# CHECK-NEXT:  1      1     0.50                        vpabsw	%xmm16, %xmm19
# CHECK-NEXT:  2      7     0.50    *                   vpabsw	(%rax), %xmm19
# CHECK-NEXT:  1      1     0.50                        vpabsw	%xmm16, %xmm19 {%k1}
# CHECK-NEXT:  2      7     0.50    *                   vpabsw	(%rax), %xmm19 {%k1}
# CHECK-NEXT:  1      1     0.50                        vpabsw	%xmm16, %xmm19 {%k1} {z}
# CHECK-NEXT:  2      7     0.50    *                   vpabsw	(%rax), %xmm19 {%k1} {z}
# CHECK-NEXT:  1      1     0.50                        vpabsw	%ymm16, %ymm19
# CHECK-NEXT:  2      8     0.50    *                   vpabsw	(%rax), %ymm19
# CHECK-NEXT:  1      1     0.50                        vpabsw	%ymm16, %ymm19 {%k1}
# CHECK-NEXT:  2      8     0.50    *                   vpabsw	(%rax), %ymm19 {%k1}
# CHECK-NEXT:  1      1     0.50                        vpabsw	%ymm16, %ymm19 {%k1} {z}
# CHECK-NEXT:  2      8     0.50    *                   vpabsw	(%rax), %ymm19 {%k1} {z}
# CHECK-NEXT:  1      1     0.50                        vpaddb	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  2      7     0.50    *                   vpaddb	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  1      1     0.50                        vpaddb	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  2      7     0.50    *                   vpaddb	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  1      1     0.50                        vpaddb	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  2      7     0.50    *                   vpaddb	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  1      1     0.50                        vpaddb	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  2      8     0.50    *                   vpaddb	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  1      1     0.50                        vpaddb	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  2      8     0.50    *                   vpaddb	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  1      1     0.50                        vpaddb	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  2      8     0.50    *                   vpaddb	(%rax), %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  1      1     0.50                        vpaddw	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  2      7     0.50    *                   vpaddw	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  1      1     0.50                        vpaddw	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  2      7     0.50    *                   vpaddw	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  1      1     0.50                        vpaddw	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  2      7     0.50    *                   vpaddw	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  1      1     0.50                        vpaddw	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  2      8     0.50    *                   vpaddw	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  1      1     0.50                        vpaddw	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  2      8     0.50    *                   vpaddw	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  1      1     0.50                        vpaddw	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  2      8     0.50    *                   vpaddw	(%rax), %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  1      1     0.50                        vpsubb	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  2      7     0.50    *                   vpsubb	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  1      1     0.50                        vpsubb	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  2      7     0.50    *                   vpsubb	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  1      1     0.50                        vpsubb	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  2      7     0.50    *                   vpsubb	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  1      1     0.50                        vpsubb	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  2      8     0.50    *                   vpsubb	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  1      1     0.50                        vpsubb	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  2      8     0.50    *                   vpsubb	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  1      1     0.50                        vpsubb	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  2      8     0.50    *                   vpsubb	(%rax), %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  1      1     0.50                        vpsubw	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  2      7     0.50    *                   vpsubw	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  1      1     0.50                        vpsubw	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  2      7     0.50    *                   vpsubw	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  1      1     0.50                        vpsubw	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  2      7     0.50    *                   vpsubw	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  1      1     0.50                        vpsubw	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  2      8     0.50    *                   vpsubw	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  1      1     0.50                        vpsubw	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  2      8     0.50    *                   vpsubw	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  1      1     0.50                        vpsubw	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  2      8     0.50    *                   vpsubw	(%rax), %ymm17, %ymm19 {%k1} {z}

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
# CHECK-NEXT:  -      -      -     36.00   -     36.00  18.00  18.00

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6.0]  [6.1]  Instructions:
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpabsb	%xmm16, %xmm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpabsb	(%rax), %xmm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpabsb	%xmm16, %xmm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpabsb	(%rax), %xmm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpabsb	%xmm16, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpabsb	(%rax), %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpabsb	%ymm16, %ymm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpabsb	(%rax), %ymm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpabsb	%ymm16, %ymm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpabsb	(%rax), %ymm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpabsb	%ymm16, %ymm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpabsb	(%rax), %ymm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpabsw	%xmm16, %xmm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpabsw	(%rax), %xmm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpabsw	%xmm16, %xmm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpabsw	(%rax), %xmm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpabsw	%xmm16, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpabsw	(%rax), %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpabsw	%ymm16, %ymm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpabsw	(%rax), %ymm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpabsw	%ymm16, %ymm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpabsw	(%rax), %ymm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpabsw	%ymm16, %ymm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpabsw	(%rax), %ymm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpaddb	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpaddb	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpaddb	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpaddb	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpaddb	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpaddb	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpaddb	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpaddb	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpaddb	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpaddb	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpaddb	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpaddb	(%rax), %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpaddw	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpaddw	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpaddw	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpaddw	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpaddw	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpaddw	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpaddw	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpaddw	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpaddw	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpaddw	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpaddw	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpaddw	(%rax), %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpsubb	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpsubb	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpsubb	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpsubb	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpsubb	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpsubb	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpsubb	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpsubb	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpsubb	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpsubb	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpsubb	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpsubb	(%rax), %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpsubw	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpsubw	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpsubw	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpsubw	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpsubw	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpsubw	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpsubw	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpsubw	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpsubw	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpsubw	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpsubw	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpsubw	(%rax), %ymm17, %ymm19 {%k1} {z}
