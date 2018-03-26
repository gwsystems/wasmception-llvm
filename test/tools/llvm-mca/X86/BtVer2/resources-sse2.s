# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=btver2 -instruction-tables < %s | FileCheck %s --check-prefixes=CHECK,BTVER2

addpd       %xmm0, %xmm2
addpd       (%rax), %xmm2

addsd       %xmm0, %xmm2
addsd       (%rax), %xmm2

addsubpd    %xmm0, %xmm2
addsubpd    (%rax), %xmm2

andnpd      %xmm0, %xmm2
andnpd      (%rax), %xmm2

andpd       %xmm0, %xmm2
andpd       (%rax), %xmm2

cmppd       $0, %xmm0, %xmm2
cmppd       $0, (%rax), %xmm2

cmpsd       $0, %xmm0, %xmm2
cmpsd       $0, (%rax), %xmm2

comisd      %xmm0, %xmm1
comisd      (%rax), %xmm1

cvtdq2pd    %xmm0, %xmm2
cvtdq2pd    (%rax), %xmm2

cvtdq2ps    %xmm0, %xmm2
cvtdq2ps    (%rax), %xmm2

cvtpd2dq    %xmm0, %xmm2
cvtpd2dq    (%rax), %xmm2

cvtpd2ps    %xmm0, %xmm2
cvtpd2ps    (%rax), %xmm2

cvtps2dq    %xmm0, %xmm2
cvtps2dq    (%rax), %xmm2

cvtps2pd    %xmm0, %xmm2
cvtps2pd    (%rax), %xmm2

cvtsd2si    %xmm0, %ecx
cvtsd2si    %xmm0, %rcx
cvtsd2si    (%rax), %ecx
cvtsd2si    (%rax), %rcx

cvtsd2ss    %xmm0, %xmm2
cvtsd2ss    (%rax), %xmm2

cvtsi2sd    %ecx, %xmm2
cvtsi2sd    %rcx, %xmm2
cvtsi2sd    (%rax), %xmm2
cvtsi2sd    (%rax), %xmm2

cvtss2sd    %xmm0, %xmm2
cvtss2sd    (%rax), %xmm2

cvttpd2dq   %xmm0, %xmm2
cvttpd2dq   (%rax), %xmm2

cvttps2dq   %xmm0, %xmm2
cvttps2dq   (%rax), %xmm2

cvttsd2si   %xmm0, %ecx
cvttsd2si   %xmm0, %rcx
cvttsd2si   (%rax), %ecx
cvttsd2si   (%rax), %rcx

divpd       %xmm0, %xmm2
divpd       (%rax), %xmm2

divsd       %xmm0, %xmm2
divsd       (%rax), %xmm2

maskmovdqu  %xmm0, %xmm1

maxpd       %xmm0, %xmm2
maxpd       (%rax), %xmm2

maxsd       %xmm0, %xmm2
maxsd       (%rax), %xmm2

minpd       %xmm0, %xmm2
minpd       (%rax), %xmm2

minsd       %xmm0, %xmm2
minsd       (%rax), %xmm2

movapd      %xmm0, %xmm2
movapd      %xmm0, (%rax)
movapd      (%rax), %xmm2

movd        %eax, %xmm2
movd        (%rax), %xmm2

movd        %xmm0, %ecx
movd        %xmm0, (%rax)

movdqa      %xmm0, %xmm2
movdqa      %xmm0, (%rax)
movdqa      (%rax), %xmm2

movdqu      %xmm0, %xmm2
movdqu      %xmm0, (%rax)
movdqu      (%rax), %xmm2

movhpd      %xmm0, (%rax)
movhpd      (%rax), %xmm2

movlpd      %xmm0, (%rax)
movlpd      (%rax), %xmm2

movmskpd    %xmm0, %rcx

movntdq     %xmm0, (%rax)
movntpd     %xmm0, (%rax)

movq        %xmm0, %xmm2

movq        %rax, %xmm2
movq        (%rax), %xmm2

movq        %xmm0, %rcx
movq        %xmm0, (%rax)

movsd       %xmm0, %xmm2
movsd       %xmm0, (%rax)
movsd       (%rax), %xmm2

movupd      %xmm0, %xmm2
movupd      %xmm0, (%rax)
movupd      (%rax), %xmm2

mulpd       %xmm0, %xmm2
mulpd       (%rax), %xmm2

mulsd       %xmm0, %xmm2
mulsd       (%rax), %xmm2

orpd        %xmm0, %xmm2
orpd        (%rax), %xmm2

pabsb       %xmm0, %xmm2
pabsb       (%rax), %xmm2

pabsd       %xmm0, %xmm2
pabsd       (%rax), %xmm2

pabsw       %xmm0, %xmm2
pabsw       (%rax), %xmm2

packssdw    %xmm0, %xmm2
packssdw    (%rax), %xmm2

packsswb    %xmm0, %xmm2
packsswb    (%rax), %xmm2

packuswb    %xmm0, %xmm2
packuswb    (%rax), %xmm2

paddb       %xmm0, %xmm2
paddb       (%rax), %xmm2

paddd       %xmm0, %xmm2
paddd       (%rax), %xmm2

paddq       %xmm0, %xmm2
paddq       (%rax), %xmm2

paddsb      %xmm0, %xmm2
paddsb      (%rax), %xmm2

paddsw      %xmm0, %xmm2
paddsw      (%rax), %xmm2

paddusb     %xmm0, %xmm2
paddusb     (%rax), %xmm2

paddusw     %xmm0, %xmm2
paddusw     (%rax), %xmm2

paddw       %xmm0, %xmm2
paddw       (%rax), %xmm2

pand        %xmm0, %xmm2
pand        (%rax), %xmm2

pandn       %xmm0, %xmm2
pandn       (%rax), %xmm2

pavgb       %xmm0, %xmm2
pavgb       (%rax), %xmm2

pavgw       %xmm0, %xmm2
pavgw       (%rax), %xmm2

pcmpeqb     %xmm0, %xmm2
pcmpeqb     (%rax), %xmm2

pcmpeqd     %xmm0, %xmm2
pcmpeqd     (%rax), %xmm2

pcmpeqw     %xmm0, %xmm2
pcmpeqw     (%rax), %xmm2

pcmpgtb     %xmm0, %xmm2
pcmpgtb     (%rax), %xmm2

pcmpgtd     %xmm0, %xmm2
pcmpgtd     (%rax), %xmm2

pcmpgtw     %xmm0, %xmm2
pcmpgtw     (%rax), %xmm2

pextrw      $1, %xmm0, %rcx

pmaddwd     %xmm0, %xmm2
pmaddwd     (%rax), %xmm2

pmaxsw      %xmm0, %xmm2
pmaxsw      (%rax), %xmm2

pmaxub      %xmm0, %xmm2
pmaxub      (%rax), %xmm2

pminsw      %xmm0, %xmm2
pminsw      (%rax), %xmm2

pminub      %xmm0, %xmm2
pminub      (%rax), %xmm2

pmovmskb    %xmm0, %rcx

pmulhuw     %xmm0, %xmm2
pmulhuw     (%rax), %xmm2

pmulhw      %xmm0, %xmm2
pmulhw      (%rax), %xmm2

pmullw      %xmm0, %xmm2
pmullw      (%rax), %xmm2

pmuludq     %xmm0, %xmm2
pmuludq     (%rax), %xmm2

por         %xmm0, %xmm2
por         (%rax), %xmm2

psadbw      %xmm0, %xmm2
psadbw      (%rax), %xmm2

pshufd      $1, %xmm0, %xmm2
pshufd      $1, (%rax), %xmm2

pshufhw     $1, %xmm0, %xmm2
pshufhw     $1, (%rax), %xmm2

pshuflw     $1, %xmm0, %xmm2
pshuflw     $1, (%rax), %xmm2

pslld       $1, %xmm2
pslld       %xmm0, %xmm2
pslld       (%rax), %xmm2

pslldq      $1, %xmm2

psllq       $1, %xmm2
psllq       %xmm0, %xmm2
psllq       (%rax), %xmm2

psllw       $1, %xmm2
psllw       %xmm0, %xmm2
psllw       (%rax), %xmm2

psrad       $1, %xmm2
psrad       %xmm0, %xmm2
psrad       (%rax), %xmm2

psraw       $1, %xmm2
psraw       %xmm0, %xmm2
psraw       (%rax), %xmm2

psrld       $1, %xmm2
psrld       %xmm0, %xmm2
psrld       (%rax), %xmm2

psrldq      $1, %xmm2

psrlq       $1, %xmm2
psrlq       %xmm0, %xmm2
psrlq       (%rax), %xmm2

psrlw       $1, %xmm2
psrlw       %xmm0, %xmm2
psrlw       (%rax), %xmm2

psubb       %xmm0, %xmm2
psubb       (%rax), %xmm2

psubd       %xmm0, %xmm2
psubd       (%rax), %xmm2

psubq       %xmm0, %xmm2
psubq       (%rax), %xmm2

psubsb      %xmm0, %xmm2
psubsb      (%rax), %xmm2

psubsw      %xmm0, %xmm2
psubsw      (%rax), %xmm2

psubusb     %xmm0, %xmm2
psubusb     (%rax), %xmm2

psubusw     %xmm0, %xmm2
psubusw     (%rax), %xmm2

psubw       %xmm0, %xmm2
psubw       (%rax), %xmm2

punpckhbw   %xmm0, %xmm2
punpckhbw   (%rax), %xmm2

punpckhdq   %xmm0, %xmm2
punpckhdq   (%rax), %xmm2

punpckhqdq  %xmm0, %xmm2
punpckhqdq  (%rax), %xmm2

punpckhwd   %xmm0, %xmm2
punpckhwd   (%rax), %xmm2

punpcklbw   %xmm0, %xmm2
punpcklbw   (%rax), %xmm2

punpckldq   %xmm0, %xmm2
punpckldq   (%rax), %xmm2

punpcklqdq  %xmm0, %xmm2
punpcklqdq  (%rax), %xmm2

punpcklwd   %xmm0, %xmm2
punpcklwd   (%rax), %xmm2

pxor        %xmm0, %xmm2
pxor        (%rax), %xmm2

shufpd      $1, %xmm0, %xmm2
shufpd      $1, (%rax), %xmm2

sqrtpd      %xmm0, %xmm2
sqrtpd      (%rax), %xmm2

sqrtsd      %xmm0, %xmm2
sqrtsd      (%rax), %xmm2

subpd       %xmm0, %xmm2
subpd       (%rax), %xmm2

subsd       %xmm0, %xmm2
subsd       (%rax), %xmm2

ucomisd     %xmm0, %xmm1
ucomisd     (%rax), %xmm1

unpckhpd    %xmm0, %xmm2
unpckhpd    (%rax), %xmm2

unpcklpd    %xmm0, %xmm2
unpcklpd    (%rax), %xmm2

xorpd       %xmm0, %xmm2
xorpd       (%rax), %xmm2

# CHECK:      Resources:
# CHECK-NEXT: [0] - JALU0
# CHECK-NEXT: [1] - JALU1
# CHECK-NEXT: [2] - JDiv
# CHECK-NEXT: [3] - JFPA
# CHECK-NEXT: [4] - JFPM
# CHECK-NEXT: [5] - JFPU0
# CHECK-NEXT: [6] - JFPU1
# CHECK-NEXT: [7] - JLAGU
# CHECK-NEXT: [8] - JMul
# CHECK-NEXT: [9] - JSAGU
# CHECK-NEXT: [10] - JSTC
# CHECK-NEXT: [11] - JVALU0
# CHECK-NEXT: [12] - JVALU1
# CHECK-NEXT: [13] - JVIMUL


# CHECK: Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   [12]   [13]   	Instructions:
# CHECK-NEXT:  -      -      -     1.00    -     1.00    -      -      -      -      -      -      -      -     	addpd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     1.00    -     1.00    -     1.00    -      -      -      -      -      -     	addpd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     1.00    -     1.00    -      -      -      -      -      -      -      -     	addsd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     1.00    -     1.00    -     1.00    -      -      -      -      -      -     	addsd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     1.00    -     1.00    -      -      -      -      -      -      -      -     	addsubpd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     1.00    -     1.00    -     1.00    -      -      -      -      -      -     	addsubpd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     0.50   0.50   0.50   0.50    -      -      -      -      -      -      -     	andnpd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     0.50   0.50   0.50   0.50   1.00    -      -      -      -      -      -     	andnpd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     0.50   0.50   0.50   0.50    -      -      -      -      -      -      -     	andpd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     0.50   0.50   0.50   0.50   1.00    -      -      -      -      -      -     	andpd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     1.00    -     1.00    -      -      -      -      -      -      -      -     	cmppd	$0, %xmm0, %xmm2
# CHECK-NEXT:  -      -      -     1.00    -     1.00    -     1.00    -      -      -      -      -      -     	cmppd	$0, (%rax), %xmm2
# CHECK-NEXT:  -      -      -     1.00    -     1.00    -      -      -      -      -      -      -      -     	cmpsd	$0, %xmm0, %xmm2
# CHECK-NEXT:  -      -      -     1.00    -     1.00    -     1.00    -      -      -      -      -      -     	cmpsd	$0, (%rax), %xmm2
# CHECK-NEXT:  -      -      -     1.00    -     1.00    -      -      -      -      -      -      -      -     	comisd	%xmm0, %xmm1
# CHECK-NEXT:  -      -      -     1.00    -     1.00    -     1.00    -      -      -      -      -      -     	comisd	(%rax), %xmm1
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -     1.00    -      -      -     	cvtdq2pd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00   1.00    -      -     1.00    -      -      -     	cvtdq2pd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -     1.00    -      -      -     	cvtdq2ps	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00   1.00    -      -     1.00    -      -      -     	cvtdq2ps	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -     1.00    -      -      -     	cvtpd2dq	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00   1.00    -      -     1.00    -      -      -     	cvtpd2dq	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -     1.00    -      -      -     	cvtpd2ps	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00   1.00    -      -     1.00    -      -      -     	cvtpd2ps	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -     1.00    -      -      -     	cvtps2dq	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00   1.00    -      -     1.00    -      -      -     	cvtps2dq	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -     1.00    -      -      -     	cvtps2pd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00   1.00    -      -     1.00    -      -      -     	cvtps2pd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -     1.00    -      -      -     	cvtsd2si	%xmm0, %ecx
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -     1.00    -      -      -     	cvtsd2si	%xmm0, %rcx
# CHECK-NEXT:  -      -      -      -      -      -     1.00   1.00    -      -     1.00    -      -      -     	cvtsd2si	(%rax), %ecx
# CHECK-NEXT:  -      -      -      -      -      -     1.00   1.00    -      -     1.00    -      -      -     	cvtsd2si	(%rax), %rcx
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -     1.00    -      -      -     	cvtsd2ss	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00   1.00    -      -     1.00    -      -      -     	cvtsd2ss	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -     1.00    -      -      -     	cvtsi2sdl	%ecx, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -     1.00    -      -      -     	cvtsi2sdq	%rcx, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00   1.00    -      -     1.00    -      -      -     	cvtsi2sdl	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00   1.00    -      -     1.00    -      -      -     	cvtsi2sdl	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -     1.00    -      -      -     	cvtss2sd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00   1.00    -      -     1.00    -      -      -     	cvtss2sd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -     1.00    -      -      -     	cvttpd2dq	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00   1.00    -      -     1.00    -      -      -     	cvttpd2dq	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -     1.00    -      -      -     	cvttps2dq	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00   1.00    -      -     1.00    -      -      -     	cvttps2dq	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -     1.00    -      -      -     	cvttsd2si	%xmm0, %ecx
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -     1.00    -      -      -     	cvttsd2si	%xmm0, %rcx
# CHECK-NEXT:  -      -      -      -      -      -     1.00   1.00    -      -     1.00    -      -      -     	cvttsd2si	(%rax), %ecx
# CHECK-NEXT:  -      -      -      -      -      -     1.00   1.00    -      -     1.00    -      -      -     	cvttsd2si	(%rax), %rcx
# CHECK-NEXT:  -      -      -      -     19.00   -     1.00    -      -      -      -      -      -      -     	divpd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -     19.00   -     1.00   1.00    -      -      -      -      -      -     	divpd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -     19.00   -     1.00    -      -      -      -      -      -      -     	divsd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -     19.00   -     1.00   1.00    -      -      -      -      -      -     	divsd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -     1.00   1.00    -      -      -     	maskmovdqu	%xmm0, %xmm1
# CHECK-NEXT:  -      -      -     1.00    -     1.00    -      -      -      -      -      -      -      -     	maxpd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     1.00    -     1.00    -     1.00    -      -      -      -      -      -     	maxpd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     1.00    -     1.00    -      -      -      -      -      -      -      -     	maxsd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     1.00    -     1.00    -     1.00    -      -      -      -      -      -     	maxsd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     1.00    -     1.00    -      -      -      -      -      -      -      -     	minpd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     1.00    -     1.00    -     1.00    -      -      -      -      -      -     	minpd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     1.00    -     1.00    -      -      -      -      -      -      -      -     	minsd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     1.00    -     1.00    -     1.00    -      -      -      -      -      -     	minsd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     0.50   0.50   0.50   0.50    -      -      -      -      -      -      -     	movapd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -     1.00   1.00    -      -      -     	movapd	%xmm0, (%rax)
# CHECK-NEXT:  -      -      -     0.50   0.50   0.50   0.50   1.00    -      -      -      -      -      -     	movapd	(%rax), %xmm2
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -      -      -      -      -      -     	movd	%eax, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -      -     1.00    -      -      -      -      -      -     	movd	(%rax), %xmm2
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -      -      -      -      -      -     	movd	%xmm0, %ecx
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -     1.00    -      -      -      -     	movd	%xmm0, (%rax)
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	movdqa	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -     1.00   1.00    -      -      -     	movdqa	%xmm0, (%rax)
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	movdqa	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	movdqu	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -     1.00   1.00    -      -      -     	movdqu	%xmm0, (%rax)
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	movdqu	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -     1.00    -      -      -      -     	movhpd	%xmm0, (%rax)
# CHECK-NEXT:  -      -      -     0.50   0.50   0.50   0.50   1.00    -      -      -      -      -      -     	movhpd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -     1.00    -      -      -      -     	movlpd	%xmm0, (%rax)
# CHECK-NEXT:  -      -      -     0.50   0.50   0.50   0.50   1.00    -      -      -      -      -      -     	movlpd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     1.00    -     1.00    -      -      -      -      -      -      -      -     	movmskpd	%xmm0, %ecx
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -     1.00   1.00    -      -      -     	movntdq	%xmm0, (%rax)
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -     1.00   1.00    -      -      -     	movntpd	%xmm0, (%rax)
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	movq	%xmm0, %xmm2
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -      -      -      -      -      -     	movq	%rax, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -      -     1.00    -      -      -      -      -      -     	movq	(%rax), %xmm2
# CHECK-NEXT: 0.50   0.50    -      -      -      -      -      -      -      -      -      -      -      -     	movq	%xmm0, %rcx
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -     1.00    -      -      -      -     	movq	%xmm0, (%rax)
# CHECK-NEXT:  -      -      -     0.50   0.50   0.50   0.50    -      -      -      -      -      -      -     	movsd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -     1.00    -      -      -      -     	movsd	%xmm0, (%rax)
# CHECK-NEXT:  -      -      -      -      -      -      -     1.00    -      -      -      -      -      -     	movsd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     0.50   0.50   0.50   0.50    -      -      -      -      -      -      -     	movupd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -     1.00   1.00    -      -      -     	movupd	%xmm0, (%rax)
# CHECK-NEXT:  -      -      -     0.50   0.50   0.50   0.50   1.00    -      -      -      -      -      -     	movupd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -     2.00    -     1.00    -      -      -      -      -      -      -     	mulpd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -     2.00    -     1.00   1.00    -      -      -      -      -      -     	mulpd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -     2.00    -     1.00    -      -      -      -      -      -      -     	mulsd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -     2.00    -     1.00   1.00    -      -      -      -      -      -     	mulsd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     0.50   0.50   0.50   0.50    -      -      -      -      -      -      -     	orpd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     0.50   0.50   0.50   0.50   1.00    -      -      -      -      -      -     	orpd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	pabsb	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	pabsb	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	pabsd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	pabsd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	pabsw	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	pabsw	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	packssdw	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	packssdw	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	packsswb	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	packsswb	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	packuswb	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	packuswb	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	paddb	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	paddb	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	paddd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	paddd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	paddq	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	paddq	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	paddsb	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	paddsb	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	paddsw	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	paddsw	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	paddusb	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	paddusb	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	paddusw	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	paddusw	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	paddw	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	paddw	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	pand	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	pand	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	pandn	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	pandn	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	pavgb	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	pavgb	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	pavgw	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	pavgw	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	pcmpeqb	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	pcmpeqb	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	pcmpeqd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	pcmpeqd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	pcmpeqw	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	pcmpeqw	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	pcmpgtb	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	pcmpgtb	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	pcmpgtd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	pcmpgtd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	pcmpgtw	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	pcmpgtw	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	pextrw	$1, %xmm0, %ecx
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -      -      -      -      -      -     1.00   	pmaddwd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     1.00    -     1.00    -      -      -      -      -     1.00   	pmaddwd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	pmaxsw	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	pmaxsw	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	pmaxub	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	pmaxub	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	pminsw	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	pminsw	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	pminub	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	pminub	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     1.00    -     1.00    -      -      -      -      -      -      -      -     	pmovmskb	%xmm0, %ecx
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -      -      -      -      -      -     1.00   	pmulhuw	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     1.00    -     1.00    -      -      -      -      -     1.00   	pmulhuw	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -      -      -      -      -      -     1.00   	pmulhw	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     1.00    -     1.00    -      -      -      -      -     1.00   	pmulhw	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -      -      -      -      -      -     1.00   	pmullw	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     1.00    -     1.00    -      -      -      -      -     1.00   	pmullw	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -      -      -      -      -      -     1.00   	pmuludq	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     1.00    -     1.00    -      -      -      -      -     1.00   	pmuludq	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	por	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	por	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	psadbw	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	psadbw	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	pshufd	$1, %xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	pshufd	$1, (%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	pshufhw	$1, %xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	pshufhw	$1, (%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	pshuflw	$1, %xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	pshuflw	$1, (%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	pslld	$1, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	pslld	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	pslld	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	pslldq	$1, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	psllq	$1, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	psllq	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	psllq	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	psllw	$1, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	psllw	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	psllw	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	psrad	$1, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	psrad	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	psrad	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	psraw	$1, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	psraw	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	psraw	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	psrld	$1, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	psrld	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	psrld	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	psrldq	$1, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	psrlq	$1, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	psrlq	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	psrlq	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	psrlw	$1, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	psrlw	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	psrlw	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	psubb	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	psubb	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	psubd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	psubd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	psubq	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	psubq	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	psubsb	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	psubsb	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	psubsw	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	psubsw	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	psubusb	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	psubusb	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	psubusw	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	psubusw	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	psubw	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	psubw	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	punpckhbw	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	punpckhbw	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	punpckhdq	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	punpckhdq	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	punpckhqdq	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	punpckhqdq	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	punpckhwd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	punpckhwd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	punpcklbw	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	punpcklbw	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	punpckldq	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	punpckldq	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	punpcklqdq	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	punpcklqdq	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	punpcklwd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	punpcklwd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -     0.50   0.50    -     	pxor	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50   1.00    -      -      -     0.50   0.50    -     	pxor	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     0.50   0.50   0.50   0.50    -      -      -      -      -      -      -     	shufpd	$1, %xmm0, %xmm2
# CHECK-NEXT:  -      -      -     0.50   0.50   0.50   0.50   1.00    -      -      -      -      -      -     	shufpd	$1, (%rax), %xmm2
# CHECK-NEXT:  -      -      -      -     27.00   -     1.00    -      -      -      -      -      -      -     	sqrtpd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -     27.00   -     1.00   1.00    -      -      -      -      -      -     	sqrtpd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -     27.00   -     1.00    -      -      -      -      -      -      -     	sqrtsd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -     27.00   -     1.00   1.00    -      -      -      -      -      -     	sqrtsd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     1.00    -     1.00    -      -      -      -      -      -      -      -     	subpd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     1.00    -     1.00    -     1.00    -      -      -      -      -      -     	subpd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     1.00    -     1.00    -      -      -      -      -      -      -      -     	subsd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     1.00    -     1.00    -     1.00    -      -      -      -      -      -     	subsd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     1.00    -     1.00    -      -      -      -      -      -      -      -     	ucomisd	%xmm0, %xmm1
# CHECK-NEXT:  -      -      -     1.00    -     1.00    -     1.00    -      -      -      -      -      -     	ucomisd	(%rax), %xmm1
# CHECK-NEXT:  -      -      -     0.50   0.50   0.50   0.50    -      -      -      -      -      -      -     	unpckhpd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     0.50   0.50   0.50   0.50   1.00    -      -      -      -      -      -     	unpckhpd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     0.50   0.50   0.50   0.50    -      -      -      -      -      -      -     	unpcklpd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     0.50   0.50   0.50   0.50   1.00    -      -      -      -      -      -     	unpcklpd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     0.50   0.50   0.50   0.50    -      -      -      -      -      -      -     	xorpd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     0.50   0.50   0.50   0.50   1.00    -      -      -      -      -      -     	xorpd	(%rax), %xmm2
