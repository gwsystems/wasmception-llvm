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

vpermw            %xmm16, %xmm17, %xmm19
vpermw            (%rax), %xmm17, %xmm19
vpermw            %xmm16, %xmm17, %xmm19 {k1}
vpermw            (%rax), %xmm17, %xmm19 {k1}
vpermw            %xmm16, %xmm17, %xmm19 {z}{k1}
vpermw            (%rax), %xmm17, %xmm19 {z}{k1}

vpermw            %ymm16, %ymm17, %ymm19
vpermw            (%rax), %ymm17, %ymm19
vpermw            %ymm16, %ymm17, %ymm19 {k1}
vpermw            (%rax), %ymm17, %ymm19 {k1}
vpermw            %ymm16, %ymm17, %ymm19 {z}{k1}
vpermw            (%rax), %ymm17, %ymm19 {z}{k1}

vpshufb           %xmm16, %xmm17, %xmm19
vpshufb           (%rax), %xmm17, %xmm19
vpshufb           %xmm16, %xmm17, %xmm19 {k1}
vpshufb           (%rax), %xmm17, %xmm19 {k1}
vpshufb           %xmm16, %xmm17, %xmm19 {z}{k1}
vpshufb           (%rax), %xmm17, %xmm19 {z}{k1}

vpshufb           %ymm16, %ymm17, %ymm19
vpshufb           (%rax), %ymm17, %ymm19
vpshufb           %ymm16, %ymm17, %ymm19 {k1}
vpshufb           (%rax), %ymm17, %ymm19 {k1}
vpshufb           %ymm16, %ymm17, %ymm19 {z}{k1}
vpshufb           (%rax), %ymm17, %ymm19 {z}{k1}

vpshufhw          $0, %xmm16, %xmm19
vpshufhw          $0, (%rax), %xmm19
vpshufhw          $0, %xmm16, %xmm19 {k1}
vpshufhw          $0, (%rax), %xmm19 {k1}
vpshufhw          $0, %xmm16, %xmm19 {z}{k1}
vpshufhw          $0, (%rax), %xmm19 {z}{k1}

vpshufhw          $0, %ymm16, %ymm19
vpshufhw          $0, (%rax), %ymm19
vpshufhw          $0, %ymm16, %ymm19 {k1}
vpshufhw          $0, (%rax), %ymm19 {k1}
vpshufhw          $0, %ymm16, %ymm19 {z}{k1}
vpshufhw          $0, (%rax), %ymm19 {z}{k1}

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

vpunpckhbw         %xmm16, %xmm17, %xmm19
vpunpckhbw         (%rax), %xmm17, %xmm19
vpunpckhbw         %xmm16, %xmm17, %xmm19 {k1}
vpunpckhbw         (%rax), %xmm17, %xmm19 {k1}
vpunpckhbw         %xmm16, %xmm17, %xmm19 {z}{k1}
vpunpckhbw         (%rax), %xmm17, %xmm19 {z}{k1}

vpunpckhbw         %ymm16, %ymm17, %ymm19
vpunpckhbw         (%rax), %ymm17, %ymm19
vpunpckhbw         %ymm16, %ymm17, %ymm19 {k1}
vpunpckhbw         (%rax), %ymm17, %ymm19 {k1}
vpunpckhbw         %ymm16, %ymm17, %ymm19 {z}{k1}
vpunpckhbw         (%rax), %ymm17, %ymm19 {z}{k1}

vpunpckhwd         %xmm16, %xmm17, %xmm19
vpunpckhwd         (%rax), %xmm17, %xmm19
vpunpckhwd         %xmm16, %xmm17, %xmm19 {k1}
vpunpckhwd         (%rax), %xmm17, %xmm19 {k1}
vpunpckhwd         %xmm16, %xmm17, %xmm19 {z}{k1}
vpunpckhwd         (%rax), %xmm17, %xmm19 {z}{k1}

vpunpckhwd         %ymm16, %ymm17, %ymm19
vpunpckhwd         (%rax), %ymm17, %ymm19
vpunpckhwd         %ymm16, %ymm17, %ymm19 {k1}
vpunpckhwd         (%rax), %ymm17, %ymm19 {k1}
vpunpckhwd         %ymm16, %ymm17, %ymm19 {z}{k1}
vpunpckhwd         (%rax), %ymm17, %ymm19 {z}{k1}

vpunpcklbw         %xmm16, %xmm17, %xmm19
vpunpcklbw         (%rax), %xmm17, %xmm19
vpunpcklbw         %xmm16, %xmm17, %xmm19 {k1}
vpunpcklbw         (%rax), %xmm17, %xmm19 {k1}
vpunpcklbw         %xmm16, %xmm17, %xmm19 {z}{k1}
vpunpcklbw         (%rax), %xmm17, %xmm19 {z}{k1}

vpunpcklbw         %ymm16, %ymm17, %ymm19
vpunpcklbw         (%rax), %ymm17, %ymm19
vpunpcklbw         %ymm16, %ymm17, %ymm19 {k1}
vpunpcklbw         (%rax), %ymm17, %ymm19 {k1}
vpunpcklbw         %ymm16, %ymm17, %ymm19 {z}{k1}
vpunpcklbw         (%rax), %ymm17, %ymm19 {z}{k1}

vpunpcklwd         %xmm16, %xmm17, %xmm19
vpunpcklwd         (%rax), %xmm17, %xmm19
vpunpcklwd         %xmm16, %xmm17, %xmm19 {k1}
vpunpcklwd         (%rax), %xmm17, %xmm19 {k1}
vpunpcklwd         %xmm16, %xmm17, %xmm19 {z}{k1}
vpunpcklwd         (%rax), %xmm17, %xmm19 {z}{k1}

vpunpcklwd         %ymm16, %ymm17, %ymm19
vpunpcklwd         (%rax), %ymm17, %ymm19
vpunpcklwd         %ymm16, %ymm17, %ymm19 {k1}
vpunpcklwd         (%rax), %ymm17, %ymm19 {k1}
vpunpcklwd         %ymm16, %ymm17, %ymm19 {z}{k1}
vpunpcklwd         (%rax), %ymm17, %ymm19 {z}{k1}

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
# CHECK-NEXT:  1      1     1.00                        vpermw	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  2      8     1.00    *                   vpermw	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  1      1     1.00                        vpermw	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  2      8     1.00    *                   vpermw	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  1      1     1.00                        vpermw	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  2      8     1.00    *                   vpermw	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  1      1     1.00                        vpermw	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  2      8     1.00    *                   vpermw	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  1      1     1.00                        vpermw	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  2      8     1.00    *                   vpermw	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  1      1     1.00                        vpermw	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  2      8     1.00    *                   vpermw	(%rax), %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  1      1     0.50                        vpshufb	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  2      7     0.50    *                   vpshufb	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  1      1     0.50                        vpshufb	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  2      7     0.50    *                   vpshufb	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  1      1     0.50                        vpshufb	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  2      7     0.50    *                   vpshufb	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  1      1     0.50                        vpshufb	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  2      8     0.50    *                   vpshufb	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  1      1     0.50                        vpshufb	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  2      8     0.50    *                   vpshufb	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  1      1     0.50                        vpshufb	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  2      8     0.50    *                   vpshufb	(%rax), %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  1      1     0.50                        vpshufhw	$0, %xmm16, %xmm19
# CHECK-NEXT:  2      7     0.50    *                   vpshufhw	$0, (%rax), %xmm19
# CHECK-NEXT:  1      1     0.50                        vpshufhw	$0, %xmm16, %xmm19 {%k1}
# CHECK-NEXT:  2      7     0.50    *                   vpshufhw	$0, (%rax), %xmm19 {%k1}
# CHECK-NEXT:  1      1     0.50                        vpshufhw	$0, %xmm16, %xmm19 {%k1} {z}
# CHECK-NEXT:  2      7     0.50    *                   vpshufhw	$0, (%rax), %xmm19 {%k1} {z}
# CHECK-NEXT:  1      1     1.00                        vpshufhw	$0, %ymm16, %ymm19
# CHECK-NEXT:  2      8     1.00    *                   vpshufhw	$0, (%rax), %ymm19
# CHECK-NEXT:  1      1     1.00                        vpshufhw	$0, %ymm16, %ymm19 {%k1}
# CHECK-NEXT:  2      8     1.00    *                   vpshufhw	$0, (%rax), %ymm19 {%k1}
# CHECK-NEXT:  1      1     1.00                        vpshufhw	$0, %ymm16, %ymm19 {%k1} {z}
# CHECK-NEXT:  2      8     1.00    *                   vpshufhw	$0, (%rax), %ymm19 {%k1} {z}
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
# CHECK-NEXT:  1      1     0.50                        vpunpckhbw	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  2      7     0.50    *                   vpunpckhbw	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  1      1     0.50                        vpunpckhbw	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  2      7     0.50    *                   vpunpckhbw	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  1      1     0.50                        vpunpckhbw	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  2      7     0.50    *                   vpunpckhbw	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  1      1     1.00                        vpunpckhbw	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  2      8     1.00    *                   vpunpckhbw	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  1      1     1.00                        vpunpckhbw	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  2      8     1.00    *                   vpunpckhbw	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  1      1     1.00                        vpunpckhbw	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  2      8     1.00    *                   vpunpckhbw	(%rax), %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  1      1     0.50                        vpunpckhwd	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  2      7     0.50    *                   vpunpckhwd	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  1      1     0.50                        vpunpckhwd	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  2      7     0.50    *                   vpunpckhwd	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  1      1     0.50                        vpunpckhwd	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  2      7     0.50    *                   vpunpckhwd	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  1      1     1.00                        vpunpckhwd	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  2      8     1.00    *                   vpunpckhwd	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  1      1     1.00                        vpunpckhwd	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  2      8     1.00    *                   vpunpckhwd	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  1      1     1.00                        vpunpckhwd	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  2      8     1.00    *                   vpunpckhwd	(%rax), %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  1      1     0.50                        vpunpcklbw	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  2      7     0.50    *                   vpunpcklbw	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  1      1     0.50                        vpunpcklbw	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  2      7     0.50    *                   vpunpcklbw	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  1      1     0.50                        vpunpcklbw	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  2      7     0.50    *                   vpunpcklbw	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  1      1     1.00                        vpunpcklbw	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  2      8     1.00    *                   vpunpcklbw	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  1      1     1.00                        vpunpcklbw	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  2      8     1.00    *                   vpunpcklbw	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  1      1     1.00                        vpunpcklbw	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  2      8     1.00    *                   vpunpcklbw	(%rax), %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  1      1     0.50                        vpunpcklwd	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  2      7     0.50    *                   vpunpcklwd	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  1      1     0.50                        vpunpcklwd	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  2      7     0.50    *                   vpunpcklwd	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  1      1     0.50                        vpunpcklwd	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  2      7     0.50    *                   vpunpcklwd	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  1      1     1.00                        vpunpcklwd	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  2      8     1.00    *                   vpunpcklwd	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  1      1     1.00                        vpunpcklwd	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  2      8     1.00    *                   vpunpcklwd	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  1      1     1.00                        vpunpcklwd	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  2      8     1.00    *                   vpunpcklwd	(%rax), %ymm17, %ymm19 {%k1} {z}

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
# CHECK-NEXT:  -      -      -     57.00   -     99.00  39.00  39.00

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
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -     vpermw	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  -      -      -      -      -     1.00   0.50   0.50   vpermw	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -     vpermw	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -      -      -      -      -     1.00   0.50   0.50   vpermw	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -     vpermw	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -      -      -      -     1.00   0.50   0.50   vpermw	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -     vpermw	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  -      -      -      -      -     1.00   0.50   0.50   vpermw	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -     vpermw	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -      -      -      -      -     1.00   0.50   0.50   vpermw	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -     vpermw	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  -      -      -      -      -     1.00   0.50   0.50   vpermw	(%rax), %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpshufb	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpshufb	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpshufb	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpshufb	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpshufb	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpshufb	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpshufb	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpshufb	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpshufb	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpshufb	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpshufb	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpshufb	(%rax), %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpshufhw	$0, %xmm16, %xmm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpshufhw	$0, (%rax), %xmm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpshufhw	$0, %xmm16, %xmm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpshufhw	$0, (%rax), %xmm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpshufhw	$0, %xmm16, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpshufhw	$0, (%rax), %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -     vpshufhw	$0, %ymm16, %ymm19
# CHECK-NEXT:  -      -      -      -      -     1.00   0.50   0.50   vpshufhw	$0, (%rax), %ymm19
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -     vpshufhw	$0, %ymm16, %ymm19 {%k1}
# CHECK-NEXT:  -      -      -      -      -     1.00   0.50   0.50   vpshufhw	$0, (%rax), %ymm19 {%k1}
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -     vpshufhw	$0, %ymm16, %ymm19 {%k1} {z}
# CHECK-NEXT:  -      -      -      -      -     1.00   0.50   0.50   vpshufhw	$0, (%rax), %ymm19 {%k1} {z}
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
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpunpckhbw	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpunpckhbw	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpunpckhbw	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpunpckhbw	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpunpckhbw	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpunpckhbw	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -     vpunpckhbw	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  -      -      -      -      -     1.00   0.50   0.50   vpunpckhbw	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -     vpunpckhbw	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -      -      -      -      -     1.00   0.50   0.50   vpunpckhbw	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -     vpunpckhbw	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  -      -      -      -      -     1.00   0.50   0.50   vpunpckhbw	(%rax), %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpunpckhwd	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpunpckhwd	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpunpckhwd	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpunpckhwd	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpunpckhwd	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpunpckhwd	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -     vpunpckhwd	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  -      -      -      -      -     1.00   0.50   0.50   vpunpckhwd	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -     vpunpckhwd	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -      -      -      -      -     1.00   0.50   0.50   vpunpckhwd	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -     vpunpckhwd	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  -      -      -      -      -     1.00   0.50   0.50   vpunpckhwd	(%rax), %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpunpcklbw	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpunpcklbw	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpunpcklbw	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpunpcklbw	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpunpcklbw	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpunpcklbw	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -     vpunpcklbw	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  -      -      -      -      -     1.00   0.50   0.50   vpunpcklbw	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -     vpunpcklbw	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -      -      -      -      -     1.00   0.50   0.50   vpunpcklbw	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -     vpunpcklbw	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  -      -      -      -      -     1.00   0.50   0.50   vpunpcklbw	(%rax), %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpunpcklwd	%xmm16, %xmm17, %xmm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpunpcklwd	(%rax), %xmm17, %xmm19
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpunpcklwd	%xmm16, %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpunpcklwd	(%rax), %xmm17, %xmm19 {%k1}
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     vpunpcklwd	%xmm16, %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   vpunpcklwd	(%rax), %xmm17, %xmm19 {%k1} {z}
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -     vpunpcklwd	%ymm16, %ymm17, %ymm19
# CHECK-NEXT:  -      -      -      -      -     1.00   0.50   0.50   vpunpcklwd	(%rax), %ymm17, %ymm19
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -     vpunpcklwd	%ymm16, %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -      -      -      -      -     1.00   0.50   0.50   vpunpcklwd	(%rax), %ymm17, %ymm19 {%k1}
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -     vpunpcklwd	%ymm16, %ymm17, %ymm19 {%k1} {z}
# CHECK-NEXT:  -      -      -      -      -     1.00   0.50   0.50   vpunpcklwd	(%rax), %ymm17, %ymm19 {%k1} {z}
