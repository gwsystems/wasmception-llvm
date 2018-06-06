# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=btver2 -timeline -register-file-stats -iterations=5 < %s | FileCheck %s

# TODO sbbl  %eax, %eax
# TODO sbbq  %rax, %rax
# TODO subl  %eax, %eax
# TODO subq  %rax, %rax
# TODO xorl  %eax, %eax
# TODO xorq  %rax, %rax

pcmpgtb   %mm2, %mm2
pcmpgtd   %mm2, %mm2
pcmpgtw   %mm2, %mm2
pcmpgtb   %xmm2, %xmm2
pcmpgtd   %xmm2, %xmm2
pcmpgtq   %xmm2, %xmm2
pcmpgtw   %xmm2, %xmm2
vpcmpgtb  %xmm3, %xmm3, %xmm3
vpcmpgtd  %xmm3, %xmm3, %xmm3
vpcmpgtq  %xmm3, %xmm3, %xmm3
vpcmpgtw  %xmm3, %xmm3, %xmm3

vpcmpgtb  %xmm3, %xmm3, %xmm5
vpcmpgtd  %xmm3, %xmm3, %xmm5
vpcmpgtq  %xmm3, %xmm3, %xmm5
vpcmpgtw  %xmm3, %xmm3, %xmm5

psubb   %mm2, %mm2
psubd   %mm2, %mm2
psubq   %mm2, %mm2
psubw   %mm2, %mm2
psubb   %xmm2, %xmm2
psubd   %xmm2, %xmm2
psubq   %xmm2, %xmm2
psubw   %xmm2, %xmm2
vpsubb  %xmm3, %xmm3, %xmm3
vpsubd  %xmm3, %xmm3, %xmm3
vpsubq  %xmm3, %xmm3, %xmm3
vpsubw  %xmm3, %xmm3, %xmm3

vpsubb  %xmm3, %xmm3, %xmm5
vpsubd  %xmm3, %xmm3, %xmm5
vpsubq  %xmm3, %xmm3, %xmm5
vpsubw  %xmm3, %xmm3, %xmm5

andnps  %xmm0, %xmm0
andnpd  %xmm1, %xmm1
vandnps %xmm2, %xmm2, %xmm2
vandnpd %xmm1, %xmm1, %xmm1
pandn   %mm2, %mm2
pandn   %xmm2, %xmm2
vpandn  %xmm3, %xmm3, %xmm3

vandnps %xmm2, %xmm2, %xmm5
vandnpd %xmm1, %xmm1, %xmm5
vpandn  %xmm3, %xmm3, %xmm5

xorps  %xmm0, %xmm0
xorpd  %xmm1, %xmm1
vxorps %xmm2, %xmm2, %xmm2
vxorpd %xmm1, %xmm1, %xmm1
pxor   %mm2, %mm2
pxor   %xmm2, %xmm2
vpxor  %xmm3, %xmm3, %xmm3

vxorps %xmm4, %xmm4, %xmm5
vxorpd %xmm1, %xmm1, %xmm3
vpxor  %xmm3, %xmm3, %xmm5

# CHECK:      Iterations:        5
# CHECK-NEXT: Instructions:      255
# CHECK-NEXT: Total Cycles:      135
# CHECK-NEXT: Dispatch Width:    2
# CHECK-NEXT: IPC:               1.89
# CHECK-NEXT: Block RThroughput: 25.5

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      1     0.50                        pcmpgtb	%mm2, %mm2
# CHECK-NEXT:  1      1     0.50                        pcmpgtd	%mm2, %mm2
# CHECK-NEXT:  1      1     0.50                        pcmpgtw	%mm2, %mm2
# CHECK-NEXT:  1      1     0.50                        pcmpgtb	%xmm2, %xmm2
# CHECK-NEXT:  1      1     0.50                        pcmpgtd	%xmm2, %xmm2
# CHECK-NEXT:  1      1     0.50                        pcmpgtq	%xmm2, %xmm2
# CHECK-NEXT:  1      1     0.50                        pcmpgtw	%xmm2, %xmm2
# CHECK-NEXT:  1      1     0.50                        vpcmpgtb	%xmm3, %xmm3, %xmm3
# CHECK-NEXT:  1      1     0.50                        vpcmpgtd	%xmm3, %xmm3, %xmm3
# CHECK-NEXT:  1      1     0.50                        vpcmpgtq	%xmm3, %xmm3, %xmm3
# CHECK-NEXT:  1      1     0.50                        vpcmpgtw	%xmm3, %xmm3, %xmm3
# CHECK-NEXT:  1      1     0.50                        vpcmpgtb	%xmm3, %xmm3, %xmm5
# CHECK-NEXT:  1      1     0.50                        vpcmpgtd	%xmm3, %xmm3, %xmm5
# CHECK-NEXT:  1      1     0.50                        vpcmpgtq	%xmm3, %xmm3, %xmm5
# CHECK-NEXT:  1      1     0.50                        vpcmpgtw	%xmm3, %xmm3, %xmm5
# CHECK-NEXT:  1      1     0.50                        psubb	%mm2, %mm2
# CHECK-NEXT:  1      1     0.50                        psubd	%mm2, %mm2
# CHECK-NEXT:  1      1     0.50                        psubq	%mm2, %mm2
# CHECK-NEXT:  1      1     0.50                        psubw	%mm2, %mm2
# CHECK-NEXT:  1      1     0.50                        psubb	%xmm2, %xmm2
# CHECK-NEXT:  1      1     0.50                        psubd	%xmm2, %xmm2
# CHECK-NEXT:  1      1     0.50                        psubq	%xmm2, %xmm2
# CHECK-NEXT:  1      1     0.50                        psubw	%xmm2, %xmm2
# CHECK-NEXT:  1      1     0.50                        vpsubb	%xmm3, %xmm3, %xmm3
# CHECK-NEXT:  1      1     0.50                        vpsubd	%xmm3, %xmm3, %xmm3
# CHECK-NEXT:  1      1     0.50                        vpsubq	%xmm3, %xmm3, %xmm3
# CHECK-NEXT:  1      1     0.50                        vpsubw	%xmm3, %xmm3, %xmm3
# CHECK-NEXT:  1      1     0.50                        vpsubb	%xmm3, %xmm3, %xmm5
# CHECK-NEXT:  1      1     0.50                        vpsubd	%xmm3, %xmm3, %xmm5
# CHECK-NEXT:  1      1     0.50                        vpsubq	%xmm3, %xmm3, %xmm5
# CHECK-NEXT:  1      1     0.50                        vpsubw	%xmm3, %xmm3, %xmm5
# CHECK-NEXT:  1      1     0.50                        andnps	%xmm0, %xmm0
# CHECK-NEXT:  1      1     0.50                        andnpd	%xmm1, %xmm1
# CHECK-NEXT:  1      1     0.50                        vandnps	%xmm2, %xmm2, %xmm2
# CHECK-NEXT:  1      1     0.50                        vandnpd	%xmm1, %xmm1, %xmm1
# CHECK-NEXT:  1      1     0.50                        pandn	%mm2, %mm2
# CHECK-NEXT:  1      1     0.50                        pandn	%xmm2, %xmm2
# CHECK-NEXT:  1      1     0.50                        vpandn	%xmm3, %xmm3, %xmm3
# CHECK-NEXT:  1      1     0.50                        vandnps	%xmm2, %xmm2, %xmm5
# CHECK-NEXT:  1      1     0.50                        vandnpd	%xmm1, %xmm1, %xmm5
# CHECK-NEXT:  1      1     0.50                        vpandn	%xmm3, %xmm3, %xmm5
# CHECK-NEXT:  1      0     0.50                        xorps	%xmm0, %xmm0
# CHECK-NEXT:  1      0     0.50                        xorpd	%xmm1, %xmm1
# CHECK-NEXT:  1      0     0.50                        vxorps	%xmm2, %xmm2, %xmm2
# CHECK-NEXT:  1      0     0.50                        vxorpd	%xmm1, %xmm1, %xmm1
# CHECK-NEXT:  1      1     0.50                        pxor	%mm2, %mm2
# CHECK-NEXT:  1      0     0.50                        pxor	%xmm2, %xmm2
# CHECK-NEXT:  1      0     0.50                        vpxor	%xmm3, %xmm3, %xmm3
# CHECK-NEXT:  1      0     0.50                        vxorps	%xmm4, %xmm4, %xmm5
# CHECK-NEXT:  1      0     0.50                        vxorpd	%xmm1, %xmm1, %xmm3
# CHECK-NEXT:  1      0     0.50                        vpxor	%xmm3, %xmm3, %xmm5

# CHECK:      Register File statistics:
# CHECK-NEXT: Total number of mappings created:    210
# CHECK-NEXT: Max number of mappings used:         14

# CHECK:      *  Register File #1 -- JFpuPRF:
# CHECK-NEXT:    Number of physical registers:     72
# CHECK-NEXT:    Total number of mappings created: 210
# CHECK-NEXT:    Max number of mappings used:      14

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
# CHECK-NEXT:  -      -      -     3.00   3.00   21.00  21.00   -      -      -      -     18.00  18.00   -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   [12]   [13]   Instructions:
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -      -      -     1.00    -     pcmpgtb	%mm2, %mm2
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -      -      -      -     1.00    -      -     pcmpgtd	%mm2, %mm2
# CHECK-NEXT:  -      -      -      -      -     0.60   0.40    -      -      -      -     0.60   0.40    -     pcmpgtw	%mm2, %mm2
# CHECK-NEXT:  -      -      -      -      -     0.40   0.60    -      -      -      -     0.40   0.60    -     pcmpgtb	%xmm2, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -      -      -     1.00    -     pcmpgtd	%xmm2, %xmm2
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -      -      -      -     1.00    -      -     pcmpgtq	%xmm2, %xmm2
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -      -      -      -     1.00    -      -     pcmpgtw	%xmm2, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -      -      -     1.00    -     vpcmpgtb	%xmm3, %xmm3, %xmm3
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -      -      -     1.00    -     vpcmpgtd	%xmm3, %xmm3, %xmm3
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -      -      -      -     1.00    -      -     vpcmpgtq	%xmm3, %xmm3, %xmm3
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -      -      -     1.00    -     vpcmpgtw	%xmm3, %xmm3, %xmm3
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -      -      -      -     1.00    -      -     vpcmpgtb	%xmm3, %xmm3, %xmm5
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -      -      -     1.00    -     vpcmpgtd	%xmm3, %xmm3, %xmm5
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -      -      -      -     1.00    -      -     vpcmpgtq	%xmm3, %xmm3, %xmm5
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -      -      -     1.00    -     vpcmpgtw	%xmm3, %xmm3, %xmm5
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -      -      -      -     1.00    -      -     psubb	%mm2, %mm2
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -      -      -      -     1.00    -      -     psubd	%mm2, %mm2
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -      -      -      -     1.00    -      -     psubq	%mm2, %mm2
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -      -      -      -     1.00    -      -     psubw	%mm2, %mm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -      -      -     1.00    -     psubb	%xmm2, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -      -      -     1.00    -     psubd	%xmm2, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -      -      -     1.00    -     psubq	%xmm2, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -      -      -     1.00    -     psubw	%xmm2, %xmm2
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -      -      -      -     1.00    -      -     vpsubb	%xmm3, %xmm3, %xmm3
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -      -      -     1.00    -     vpsubd	%xmm3, %xmm3, %xmm3
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -      -      -      -     1.00    -      -     vpsubq	%xmm3, %xmm3, %xmm3
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -      -      -      -      -     1.00    -     vpsubw	%xmm3, %xmm3, %xmm3
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -      -      -      -     1.00    -      -     vpsubb	%xmm3, %xmm3, %xmm5
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -      -      -     1.00    -     vpsubd	%xmm3, %xmm3, %xmm5
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -      -      -      -     1.00    -      -     vpsubq	%xmm3, %xmm3, %xmm5
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -      -      -     1.00    -     vpsubw	%xmm3, %xmm3, %xmm5
# CHECK-NEXT:  -      -      -      -     1.00    -     1.00    -      -      -      -      -      -      -     andnps	%xmm0, %xmm0
# CHECK-NEXT:  -      -      -     1.00    -      -     1.00    -      -      -      -      -      -      -     andnpd	%xmm1, %xmm1
# CHECK-NEXT:  -      -      -      -     1.00   1.00    -      -      -      -      -      -      -      -     vandnps	%xmm2, %xmm2, %xmm2
# CHECK-NEXT:  -      -      -     1.00    -      -     1.00    -      -      -      -      -      -      -     vandnpd	%xmm1, %xmm1, %xmm1
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -      -      -      -     1.00    -      -     pandn	%mm2, %mm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -      -      -     1.00    -     pandn	%xmm2, %xmm2
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -      -      -      -     1.00    -      -     vpandn	%xmm3, %xmm3, %xmm3
# CHECK-NEXT:  -      -      -      -     1.00    -     1.00    -      -      -      -      -      -      -     vandnps	%xmm2, %xmm2, %xmm5
# CHECK-NEXT:  -      -      -     1.00    -     1.00    -      -      -      -      -      -      -      -     vandnpd	%xmm1, %xmm1, %xmm5
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -      -      -     1.00    -     vpandn	%xmm3, %xmm3, %xmm5
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -      -      -     xorps	%xmm0, %xmm0
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -      -      -     xorpd	%xmm1, %xmm1
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -      -      -     vxorps	%xmm2, %xmm2, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -      -      -     vxorpd	%xmm1, %xmm1, %xmm1
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -      -      -      -     1.00    -      -     pxor	%mm2, %mm2
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -      -      -     pxor	%xmm2, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -      -      -     vpxor	%xmm3, %xmm3, %xmm3
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -      -      -     vxorps	%xmm4, %xmm4, %xmm5
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -      -      -     vxorpd	%xmm1, %xmm1, %xmm3
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -      -      -     vpxor	%xmm3, %xmm3, %xmm5

# CHECK:      Timeline view:
# CHECK-NEXT:                     0123456789          0123456789          0123456789          0123456789
# CHECK-NEXT: Index     0123456789          0123456789          0123456789          0123456789

# CHECK:      [0,0]     DeER .    .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   pcmpgtb	%mm2, %mm2
# CHECK-NEXT: [0,1]     D=eER.    .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   pcmpgtd	%mm2, %mm2
# CHECK-NEXT: [0,2]     .D=eER    .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   pcmpgtw	%mm2, %mm2
# CHECK-NEXT: [0,3]     .DeE-R    .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   pcmpgtb	%xmm2, %xmm2
# CHECK-NEXT: [0,4]     . DeE-R   .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   pcmpgtd	%xmm2, %xmm2
# CHECK-NEXT: [0,5]     . D=eER   .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   pcmpgtq	%xmm2, %xmm2
# CHECK-NEXT: [0,6]     .  D=eER  .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   pcmpgtw	%xmm2, %xmm2
# CHECK-NEXT: [0,7]     .  DeE-R  .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   vpcmpgtb	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: [0,8]     .   DeE-R .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   vpcmpgtd	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: [0,9]     .   D=eER .    .    .    .    .    .    .    .    .    .    .    .    .    .   .   vpcmpgtq	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: [0,10]    .    D=eER.    .    .    .    .    .    .    .    .    .    .    .    .    .   .   vpcmpgtw	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: [0,11]    .    D==eER    .    .    .    .    .    .    .    .    .    .    .    .    .   .   vpcmpgtb	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: [0,12]    .    .D=eER    .    .    .    .    .    .    .    .    .    .    .    .    .   .   vpcmpgtd	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: [0,13]    .    .D==eER   .    .    .    .    .    .    .    .    .    .    .    .    .   .   vpcmpgtq	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: [0,14]    .    . D=eER   .    .    .    .    .    .    .    .    .    .    .    .    .   .   vpcmpgtw	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: [0,15]    .    . D==eER  .    .    .    .    .    .    .    .    .    .    .    .    .   .   psubb	%mm2, %mm2
# CHECK-NEXT: [0,16]    .    .  D==eER .    .    .    .    .    .    .    .    .    .    .    .    .   .   psubd	%mm2, %mm2
# CHECK-NEXT: [0,17]    .    .  D===eER.    .    .    .    .    .    .    .    .    .    .    .    .   .   psubq	%mm2, %mm2
# CHECK-NEXT: [0,18]    .    .   D===eER    .    .    .    .    .    .    .    .    .    .    .    .   .   psubw	%mm2, %mm2
# CHECK-NEXT: [0,19]    .    .   DeE---R    .    .    .    .    .    .    .    .    .    .    .    .   .   psubb	%xmm2, %xmm2
# CHECK-NEXT: [0,20]    .    .    DeE---R   .    .    .    .    .    .    .    .    .    .    .    .   .   psubd	%xmm2, %xmm2
# CHECK-NEXT: [0,21]    .    .    D=eE--R   .    .    .    .    .    .    .    .    .    .    .    .   .   psubq	%xmm2, %xmm2
# CHECK-NEXT: [0,22]    .    .    .D=eE--R  .    .    .    .    .    .    .    .    .    .    .    .   .   psubw	%xmm2, %xmm2
# CHECK-NEXT: [0,23]    .    .    .D==eE-R  .    .    .    .    .    .    .    .    .    .    .    .   .   vpsubb	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: [0,24]    .    .    . D==eE-R .    .    .    .    .    .    .    .    .    .    .    .   .   vpsubd	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: [0,25]    .    .    . D===eER .    .    .    .    .    .    .    .    .    .    .    .   .   vpsubq	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: [0,26]    .    .    .  D===eER.    .    .    .    .    .    .    .    .    .    .    .   .   vpsubw	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: [0,27]    .    .    .  D====eER    .    .    .    .    .    .    .    .    .    .    .   .   vpsubb	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: [0,28]    .    .    .   D===eER    .    .    .    .    .    .    .    .    .    .    .   .   vpsubd	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: [0,29]    .    .    .   D====eER   .    .    .    .    .    .    .    .    .    .    .   .   vpsubq	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: [0,30]    .    .    .    D===eER   .    .    .    .    .    .    .    .    .    .    .   .   vpsubw	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: [0,31]    .    .    .    DeE----R  .    .    .    .    .    .    .    .    .    .    .   .   andnps	%xmm0, %xmm0
# CHECK-NEXT: [0,32]    .    .    .    .DeE---R  .    .    .    .    .    .    .    .    .    .    .   .   andnpd	%xmm1, %xmm1
# CHECK-NEXT: [0,33]    .    .    .    .D===eE-R .    .    .    .    .    .    .    .    .    .    .   .   vandnps	%xmm2, %xmm2, %xmm2
# CHECK-NEXT: [0,34]    .    .    .    . D==eE-R .    .    .    .    .    .    .    .    .    .    .   .   vandnpd	%xmm1, %xmm1, %xmm1
# CHECK-NEXT: [0,35]    .    .    .    . D===eE-R.    .    .    .    .    .    .    .    .    .    .   .   pandn	%mm2, %mm2
# CHECK-NEXT: [0,36]    .    .    .    .  D==eE-R.    .    .    .    .    .    .    .    .    .    .   .   pandn	%xmm2, %xmm2
# CHECK-NEXT: [0,37]    .    .    .    .  D===eE-R    .    .    .    .    .    .    .    .    .    .   .   vpandn	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: [0,38]    .    .    .    .   D==eE-R    .    .    .    .    .    .    .    .    .    .   .   vandnps	%xmm2, %xmm2, %xmm5
# CHECK-NEXT: [0,39]    .    .    .    .   D===eE-R   .    .    .    .    .    .    .    .    .    .   .   vandnpd	%xmm1, %xmm1, %xmm5
# CHECK-NEXT: [0,40]    .    .    .    .    D==eE-R   .    .    .    .    .    .    .    .    .    .   .   vpandn	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: [0,41]    .    .    .    .    D------R  .    .    .    .    .    .    .    .    .    .   .   xorps	%xmm0, %xmm0
# CHECK-NEXT: [0,42]    .    .    .    .    .D-----R  .    .    .    .    .    .    .    .    .    .   .   xorpd	%xmm1, %xmm1
# CHECK-NEXT: [0,43]    .    .    .    .    .D------R .    .    .    .    .    .    .    .    .    .   .   vxorps	%xmm2, %xmm2, %xmm2
# CHECK-NEXT: [0,44]    .    .    .    .    . D-----R .    .    .    .    .    .    .    .    .    .   .   vxorpd	%xmm1, %xmm1, %xmm1
# CHECK-NEXT: [0,45]    .    .    .    .    . D=eE---R.    .    .    .    .    .    .    .    .    .   .   pxor	%mm2, %mm2
# CHECK-NEXT: [0,46]    .    .    .    .    .  D-----R.    .    .    .    .    .    .    .    .    .   .   pxor	%xmm2, %xmm2
# CHECK-NEXT: [0,47]    .    .    .    .    .  D------R    .    .    .    .    .    .    .    .    .   .   vpxor	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: [0,48]    .    .    .    .    .   D-----R    .    .    .    .    .    .    .    .    .   .   vxorps	%xmm4, %xmm4, %xmm5
# CHECK-NEXT: [0,49]    .    .    .    .    .   D------R   .    .    .    .    .    .    .    .    .   .   vxorpd	%xmm1, %xmm1, %xmm3
# CHECK-NEXT: [0,50]    .    .    .    .    .    D-----R   .    .    .    .    .    .    .    .    .   .   vpxor	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: [1,0]     .    .    .    .    .    DeE----R  .    .    .    .    .    .    .    .    .   .   pcmpgtb	%mm2, %mm2
# CHECK-NEXT: [1,1]     .    .    .    .    .    .DeE---R  .    .    .    .    .    .    .    .    .   .   pcmpgtd	%mm2, %mm2
# CHECK-NEXT: [1,2]     .    .    .    .    .    .D=eE---R .    .    .    .    .    .    .    .    .   .   pcmpgtw	%mm2, %mm2
# CHECK-NEXT: [1,3]     .    .    .    .    .    . DeE---R .    .    .    .    .    .    .    .    .   .   pcmpgtb	%xmm2, %xmm2
# CHECK-NEXT: [1,4]     .    .    .    .    .    . D=eE---R.    .    .    .    .    .    .    .    .   .   pcmpgtd	%xmm2, %xmm2
# CHECK-NEXT: [1,5]     .    .    .    .    .    .  D=eE--R.    .    .    .    .    .    .    .    .   .   pcmpgtq	%xmm2, %xmm2
# CHECK-NEXT: [1,6]     .    .    .    .    .    .  D==eE--R    .    .    .    .    .    .    .    .   .   pcmpgtw	%xmm2, %xmm2
# CHECK-NEXT: [1,7]     .    .    .    .    .    .   DeE---R    .    .    .    .    .    .    .    .   .   vpcmpgtb	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: [1,8]     .    .    .    .    .    .   D=eE---R   .    .    .    .    .    .    .    .   .   vpcmpgtd	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: [1,9]     .    .    .    .    .    .    D=eE--R   .    .    .    .    .    .    .    .   .   vpcmpgtq	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: [1,10]    .    .    .    .    .    .    D==eE--R  .    .    .    .    .    .    .    .   .   vpcmpgtw	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: [1,11]    .    .    .    .    .    .    .D==eE-R  .    .    .    .    .    .    .    .   .   vpcmpgtb	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: [1,12]    .    .    .    .    .    .    .D==eE--R .    .    .    .    .    .    .    .   .   vpcmpgtd	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: [1,13]    .    .    .    .    .    .    . D==eE-R .    .    .    .    .    .    .    .   .   vpcmpgtq	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: [1,14]    .    .    .    .    .    .    . D==eE--R.    .    .    .    .    .    .    .   .   vpcmpgtw	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: [1,15]    .    .    .    .    .    .    .  D==eE-R.    .    .    .    .    .    .    .   .   psubb	%mm2, %mm2
# CHECK-NEXT: [1,16]    .    .    .    .    .    .    .  D===eE-R    .    .    .    .    .    .    .   .   psubd	%mm2, %mm2
# CHECK-NEXT: [1,17]    .    .    .    .    .    .    .   D===eER    .    .    .    .    .    .    .   .   psubq	%mm2, %mm2
# CHECK-NEXT: [1,18]    .    .    .    .    .    .    .   D====eER   .    .    .    .    .    .    .   .   psubw	%mm2, %mm2
# CHECK-NEXT: [1,19]    .    .    .    .    .    .    .    DeE---R   .    .    .    .    .    .    .   .   psubb	%xmm2, %xmm2
# CHECK-NEXT: [1,20]    .    .    .    .    .    .    .    D=eE---R  .    .    .    .    .    .    .   .   psubd	%xmm2, %xmm2
# CHECK-NEXT: [1,21]    .    .    .    .    .    .    .    .D=eE--R  .    .    .    .    .    .    .   .   psubq	%xmm2, %xmm2
# CHECK-NEXT: [1,22]    .    .    .    .    .    .    .    .D==eE--R .    .    .    .    .    .    .   .   psubw	%xmm2, %xmm2
# CHECK-NEXT: [1,23]    .    .    .    .    .    .    .    . D==eE-R .    .    .    .    .    .    .   .   vpsubb	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: [1,24]    .    .    .    .    .    .    .    . D===eE-R.    .    .    .    .    .    .   .   vpsubd	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: [1,25]    .    .    .    .    .    .    .    .  D===eER.    .    .    .    .    .    .   .   vpsubq	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: [1,26]    .    .    .    .    .    .    .    .  D====eER    .    .    .    .    .    .   .   vpsubw	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: [1,27]    .    .    .    .    .    .    .    .   D====eER   .    .    .    .    .    .   .   vpsubb	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: [1,28]    .    .    .    .    .    .    .    .   D====eER   .    .    .    .    .    .   .   vpsubd	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: [1,29]    .    .    .    .    .    .    .    .    D====eER  .    .    .    .    .    .   .   vpsubq	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: [1,30]    .    .    .    .    .    .    .    .    D====eER  .    .    .    .    .    .   .   vpsubw	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: [1,31]    .    .    .    .    .    .    .    .    .DeE----R .    .    .    .    .    .   .   andnps	%xmm0, %xmm0
# CHECK-NEXT: [1,32]    .    .    .    .    .    .    .    .    .D=eE---R .    .    .    .    .    .   .   andnpd	%xmm1, %xmm1
# CHECK-NEXT: [1,33]    .    .    .    .    .    .    .    .    . D===eE-R.    .    .    .    .    .   .   vandnps	%xmm2, %xmm2, %xmm2
# CHECK-NEXT: [1,34]    .    .    .    .    .    .    .    .    . D===eE-R.    .    .    .    .    .   .   vandnpd	%xmm1, %xmm1, %xmm1
# CHECK-NEXT: [1,35]    .    .    .    .    .    .    .    .    .  D===eE-R    .    .    .    .    .   .   pandn	%mm2, %mm2
# CHECK-NEXT: [1,36]    .    .    .    .    .    .    .    .    .  D===eE-R    .    .    .    .    .   .   pandn	%xmm2, %xmm2
# CHECK-NEXT: [1,37]    .    .    .    .    .    .    .    .    .   D===eE-R   .    .    .    .    .   .   vpandn	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: [1,38]    .    .    .    .    .    .    .    .    .   D===eE-R   .    .    .    .    .   .   vandnps	%xmm2, %xmm2, %xmm5
# CHECK-NEXT: [1,39]    .    .    .    .    .    .    .    .    .    D===eE-R  .    .    .    .    .   .   vandnpd	%xmm1, %xmm1, %xmm5
# CHECK-NEXT: [1,40]    .    .    .    .    .    .    .    .    .    D===eE-R  .    .    .    .    .   .   vpandn	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: [1,41]    .    .    .    .    .    .    .    .    .    .D------R .    .    .    .    .   .   xorps	%xmm0, %xmm0
# CHECK-NEXT: [1,42]    .    .    .    .    .    .    .    .    .    .D------R .    .    .    .    .   .   xorpd	%xmm1, %xmm1
# CHECK-NEXT: [1,43]    .    .    .    .    .    .    .    .    .    . D------R.    .    .    .    .   .   vxorps	%xmm2, %xmm2, %xmm2
# CHECK-NEXT: [1,44]    .    .    .    .    .    .    .    .    .    . D------R.    .    .    .    .   .   vxorpd	%xmm1, %xmm1, %xmm1
# CHECK-NEXT: [1,45]    .    .    .    .    .    .    .    .    .    .  D=eE---R    .    .    .    .   .   pxor	%mm2, %mm2
# CHECK-NEXT: [1,46]    .    .    .    .    .    .    .    .    .    .  D------R    .    .    .    .   .   pxor	%xmm2, %xmm2
# CHECK-NEXT: [1,47]    .    .    .    .    .    .    .    .    .    .   D------R   .    .    .    .   .   vpxor	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: [1,48]    .    .    .    .    .    .    .    .    .    .   D------R   .    .    .    .   .   vxorps	%xmm4, %xmm4, %xmm5
# CHECK-NEXT: [1,49]    .    .    .    .    .    .    .    .    .    .    D------R  .    .    .    .   .   vxorpd	%xmm1, %xmm1, %xmm3
# CHECK-NEXT: [1,50]    .    .    .    .    .    .    .    .    .    .    D------R  .    .    .    .   .   vpxor	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: [2,0]     .    .    .    .    .    .    .    .    .    .    .DeE----R .    .    .    .   .   pcmpgtb	%mm2, %mm2
# CHECK-NEXT: [2,1]     .    .    .    .    .    .    .    .    .    .    .D=eE---R .    .    .    .   .   pcmpgtd	%mm2, %mm2
# CHECK-NEXT: [2,2]     .    .    .    .    .    .    .    .    .    .    . D=eE---R.    .    .    .   .   pcmpgtw	%mm2, %mm2
# CHECK-NEXT: [2,3]     .    .    .    .    .    .    .    .    .    .    . DeE----R.    .    .    .   .   pcmpgtb	%xmm2, %xmm2
# CHECK-NEXT: [2,4]     .    .    .    .    .    .    .    .    .    .    .  DeE----R    .    .    .   .   pcmpgtd	%xmm2, %xmm2
# CHECK-NEXT: [2,5]     .    .    .    .    .    .    .    .    .    .    .  D=eE---R    .    .    .   .   pcmpgtq	%xmm2, %xmm2
# CHECK-NEXT: [2,6]     .    .    .    .    .    .    .    .    .    .    .   D=eE---R   .    .    .   .   pcmpgtw	%xmm2, %xmm2
# CHECK-NEXT: [2,7]     .    .    .    .    .    .    .    .    .    .    .   DeE----R   .    .    .   .   vpcmpgtb	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: [2,8]     .    .    .    .    .    .    .    .    .    .    .    DeE----R  .    .    .   .   vpcmpgtd	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: [2,9]     .    .    .    .    .    .    .    .    .    .    .    D=eE---R  .    .    .   .   vpcmpgtq	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: [2,10]    .    .    .    .    .    .    .    .    .    .    .    .D=eE---R .    .    .   .   vpcmpgtw	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: [2,11]    .    .    .    .    .    .    .    .    .    .    .    .D==eE--R .    .    .   .   vpcmpgtb	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: [2,12]    .    .    .    .    .    .    .    .    .    .    .    . D=eE---R.    .    .   .   vpcmpgtd	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: [2,13]    .    .    .    .    .    .    .    .    .    .    .    . D==eE--R.    .    .   .   vpcmpgtq	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: [2,14]    .    .    .    .    .    .    .    .    .    .    .    .  D=eE---R    .    .   .   vpcmpgtw	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: [2,15]    .    .    .    .    .    .    .    .    .    .    .    .  D==eE--R    .    .   .   psubb	%mm2, %mm2
# CHECK-NEXT: [2,16]    .    .    .    .    .    .    .    .    .    .    .    .   D==eE--R   .    .   .   psubd	%mm2, %mm2
# CHECK-NEXT: [2,17]    .    .    .    .    .    .    .    .    .    .    .    .   D===eE-R   .    .   .   psubq	%mm2, %mm2
# CHECK-NEXT: [2,18]    .    .    .    .    .    .    .    .    .    .    .    .    D===eE-R  .    .   .   psubw	%mm2, %mm2
# CHECK-NEXT: [2,19]    .    .    .    .    .    .    .    .    .    .    .    .    DeE----R  .    .   .   psubb	%xmm2, %xmm2
# CHECK-NEXT: [2,20]    .    .    .    .    .    .    .    .    .    .    .    .    .DeE----R .    .   .   psubd	%xmm2, %xmm2
# CHECK-NEXT: [2,21]    .    .    .    .    .    .    .    .    .    .    .    .    .D=eE---R .    .   .   psubq	%xmm2, %xmm2
# CHECK-NEXT: [2,22]    .    .    .    .    .    .    .    .    .    .    .    .    . D=eE---R.    .   .   psubw	%xmm2, %xmm2
# CHECK-NEXT: [2,23]    .    .    .    .    .    .    .    .    .    .    .    .    . D==eE--R.    .   .   vpsubb	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: [2,24]    .    .    .    .    .    .    .    .    .    .    .    .    .  D==eE--R    .   .   vpsubd	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: [2,25]    .    .    .    .    .    .    .    .    .    .    .    .    .  D===eE-R    .   .   vpsubq	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: [2,26]    .    .    .    .    .    .    .    .    .    .    .    .    .   D===eE-R   .   .   vpsubw	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: [2,27]    .    .    .    .    .    .    .    .    .    .    .    .    .   D====eER   .   .   vpsubb	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: [2,28]    .    .    .    .    .    .    .    .    .    .    .    .    .    D===eE-R  .   .   vpsubd	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: [2,29]    .    .    .    .    .    .    .    .    .    .    .    .    .    D====eER  .   .   vpsubq	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: [2,30]    .    .    .    .    .    .    .    .    .    .    .    .    .    .D===eE-R .   .   vpsubw	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: [2,31]    .    .    .    .    .    .    .    .    .    .    .    .    .    .DeE----R .   .   andnps	%xmm0, %xmm0
# CHECK-NEXT: [2,32]    .    .    .    .    .    .    .    .    .    .    .    .    .    . DeE----R.   .   andnpd	%xmm1, %xmm1
# CHECK-NEXT: [2,33]    .    .    .    .    .    .    .    .    .    .    .    .    .    . D===eE-R.   .   vandnps	%xmm2, %xmm2, %xmm2
# CHECK-NEXT: [2,34]    .    .    .    .    .    .    .    .    .    .    .    .    .    .  D==eE--R   .   vandnpd	%xmm1, %xmm1, %xmm1
# CHECK-NEXT: [2,35]    .    .    .    .    .    .    .    .    .    .    .    .    .    .  D===eE-R   .   pandn	%mm2, %mm2
# CHECK-NEXT: [2,36]    .    .    .    .    .    .    .    .    .    .    .    .    .    .   D==eE--R  .   pandn	%xmm2, %xmm2
# CHECK-NEXT: [2,37]    .    .    .    .    .    .    .    .    .    .    .    .    .    .   D===eE-R  .   vpandn	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: [2,38]    .    .    .    .    .    .    .    .    .    .    .    .    .    .    D==eE--R .   vandnps	%xmm2, %xmm2, %xmm5
# CHECK-NEXT: [2,39]    .    .    .    .    .    .    .    .    .    .    .    .    .    .    D===eE-R .   vandnpd	%xmm1, %xmm1, %xmm5
# CHECK-NEXT: [2,40]    .    .    .    .    .    .    .    .    .    .    .    .    .    .    .D==eE--R.   vpandn	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: [2,41]    .    .    .    .    .    .    .    .    .    .    .    .    .    .    .D------R.   xorps	%xmm0, %xmm0
# CHECK-NEXT: [2,42]    .    .    .    .    .    .    .    .    .    .    .    .    .    .    . D------R   xorpd	%xmm1, %xmm1
# CHECK-NEXT: [2,43]    .    .    .    .    .    .    .    .    .    .    .    .    .    .    . D------R   vxorps	%xmm2, %xmm2, %xmm2

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     3     1.0    1.0    2.7       pcmpgtb	%mm2, %mm2
# CHECK-NEXT: 1.     3     1.7    0.0    2.0       pcmpgtd	%mm2, %mm2
# CHECK-NEXT: 2.     3     2.0    0.0    2.0       pcmpgtw	%mm2, %mm2
# CHECK-NEXT: 3.     3     1.0    1.0    2.7       pcmpgtb	%xmm2, %xmm2
# CHECK-NEXT: 4.     3     1.3    0.0    2.7       pcmpgtd	%xmm2, %xmm2
# CHECK-NEXT: 5.     3     2.0    0.0    1.7       pcmpgtq	%xmm2, %xmm2
# CHECK-NEXT: 6.     3     2.3    0.0    1.7       pcmpgtw	%xmm2, %xmm2
# CHECK-NEXT: 7.     3     1.0    1.0    2.7       vpcmpgtb	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: 8.     3     1.3    0.0    2.7       vpcmpgtd	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: 9.     3     2.0    0.0    1.7       vpcmpgtq	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: 10.    3     2.3    0.0    1.7       vpcmpgtw	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: 11.    3     3.0    0.0    1.0       vpcmpgtb	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: 12.    3     2.3    0.0    1.7       vpcmpgtd	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: 13.    3     3.0    1.0    1.0       vpcmpgtq	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: 14.    3     2.3    1.0    1.7       vpcmpgtw	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: 15.    3     3.0    3.0    1.0       psubb	%mm2, %mm2
# CHECK-NEXT: 16.    3     3.3    0.0    1.0       psubd	%mm2, %mm2
# CHECK-NEXT: 17.    3     4.0    0.0    0.3       psubq	%mm2, %mm2
# CHECK-NEXT: 18.    3     4.3    0.0    0.3       psubw	%mm2, %mm2
# CHECK-NEXT: 19.    3     1.0    1.0    3.3       psubb	%xmm2, %xmm2
# CHECK-NEXT: 20.    3     1.3    0.0    3.3       psubd	%xmm2, %xmm2
# CHECK-NEXT: 21.    3     2.0    0.0    2.3       psubq	%xmm2, %xmm2
# CHECK-NEXT: 22.    3     2.3    0.0    2.3       psubw	%xmm2, %xmm2
# CHECK-NEXT: 23.    3     3.0    3.0    1.3       vpsubb	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: 24.    3     3.3    0.0    1.3       vpsubd	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: 25.    3     4.0    0.0    0.3       vpsubq	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: 26.    3     4.3    0.0    0.3       vpsubw	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: 27.    3     5.0    0.0    0.0       vpsubb	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: 28.    3     4.3    0.0    0.3       vpsubd	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: 29.    3     5.0    1.0    0.0       vpsubq	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: 30.    3     4.3    1.0    0.3       vpsubw	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: 31.    3     1.0    1.0    4.0       andnps	%xmm0, %xmm0
# CHECK-NEXT: 32.    3     1.3    1.3    3.3       andnpd	%xmm1, %xmm1
# CHECK-NEXT: 33.    3     4.0    4.0    1.0       vandnps	%xmm2, %xmm2, %xmm2
# CHECK-NEXT: 34.    3     3.3    2.0    1.3       vandnpd	%xmm1, %xmm1, %xmm1
# CHECK-NEXT: 35.    3     4.0    4.0    1.0       pandn	%mm2, %mm2
# CHECK-NEXT: 36.    3     3.3    0.0    1.3       pandn	%xmm2, %xmm2
# CHECK-NEXT: 37.    3     4.0    4.0    1.0       vpandn	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: 38.    3     3.3    0.0    1.3       vandnps	%xmm2, %xmm2, %xmm5
# CHECK-NEXT: 39.    3     4.0    2.0    1.0       vandnpd	%xmm1, %xmm1, %xmm5
# CHECK-NEXT: 40.    3     3.3    0.0    1.3       vpandn	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: 41.    3     0.0    0.0    6.0       xorps	%xmm0, %xmm0
# CHECK-NEXT: 42.    3     0.0    0.0    5.7       xorpd	%xmm1, %xmm1
# CHECK-NEXT: 43.    3     0.0    0.0    6.0       vxorps	%xmm2, %xmm2, %xmm2
# CHECK-NEXT: 44.    2     0.0    0.0    5.5       vxorpd	%xmm1, %xmm1, %xmm1
# CHECK-NEXT: 45.    2     2.0    2.0    3.0       pxor	%mm2, %mm2
# CHECK-NEXT: 46.    2     0.0    0.0    5.5       pxor	%xmm2, %xmm2
# CHECK-NEXT: 47.    2     0.0    0.0    6.0       vpxor	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: 48.    2     0.0    0.0    5.5       vxorps	%xmm4, %xmm4, %xmm5
# CHECK-NEXT: 49.    2     0.0    0.0    6.0       vxorpd	%xmm1, %xmm1, %xmm3
# CHECK-NEXT: 50.    2     0.0    0.0    5.5       vpxor	%xmm3, %xmm3, %xmm5
