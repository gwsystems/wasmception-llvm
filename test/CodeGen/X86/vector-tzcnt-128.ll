; RUN: llc < %s -mtriple=x86_64-unknown-unknown | FileCheck %s --check-prefix=ALL --check-prefix=SSE --check-prefix=SSE2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse3 | FileCheck %s --check-prefix=ALL --check-prefix=SSE --check-prefix=SSE3
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+ssse3 | FileCheck %s --check-prefix=ALL --check-prefix=SSE --check-prefix=SSSE3
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse4.1 | FileCheck %s --check-prefix=ALL --check-prefix=SSE --check-prefix=SSE41
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx | FileCheck %s --check-prefix=ALL --check-prefix=AVX --check-prefix=AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx2 | FileCheck %s --check-prefix=ALL --check-prefix=AVX --check-prefix=AVX2

define <2 x i64> @testv2i64(<2 x i64> %in) nounwind {
; SSE2-LABEL: testv2i64:
; SSE2:       # BB#0:
; SSE2-NEXT:    movd %xmm0, %rax
; SSE2-NEXT:    bsfq %rax, %rax
; SSE2-NEXT:    movl $64, %ecx
; SSE2-NEXT:    cmoveq %rcx, %rax
; SSE2-NEXT:    movd %rax, %xmm1
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[2,3,0,1]
; SSE2-NEXT:    movd %xmm0, %rax
; SSE2-NEXT:    bsfq %rax, %rax
; SSE2-NEXT:    cmoveq %rcx, %rax
; SSE2-NEXT:    movd %rax, %xmm0
; SSE2-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm0[0]
; SSE2-NEXT:    movdqa %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSE3-LABEL: testv2i64:
; SSE3:       # BB#0:
; SSE3-NEXT:    movd %xmm0, %rax
; SSE3-NEXT:    bsfq %rax, %rax
; SSE3-NEXT:    movl $64, %ecx
; SSE3-NEXT:    cmoveq %rcx, %rax
; SSE3-NEXT:    movd %rax, %xmm1
; SSE3-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[2,3,0,1]
; SSE3-NEXT:    movd %xmm0, %rax
; SSE3-NEXT:    bsfq %rax, %rax
; SSE3-NEXT:    cmoveq %rcx, %rax
; SSE3-NEXT:    movd %rax, %xmm0
; SSE3-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm0[0]
; SSE3-NEXT:    movdqa %xmm1, %xmm0
; SSE3-NEXT:    retq
;
; SSSE3-LABEL: testv2i64:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    movd %xmm0, %rax
; SSSE3-NEXT:    bsfq %rax, %rax
; SSSE3-NEXT:    movl $64, %ecx
; SSSE3-NEXT:    cmoveq %rcx, %rax
; SSSE3-NEXT:    movd %rax, %xmm1
; SSSE3-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[2,3,0,1]
; SSSE3-NEXT:    movd %xmm0, %rax
; SSSE3-NEXT:    bsfq %rax, %rax
; SSSE3-NEXT:    cmoveq %rcx, %rax
; SSSE3-NEXT:    movd %rax, %xmm0
; SSSE3-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm0[0]
; SSSE3-NEXT:    movdqa %xmm1, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: testv2i64:
; SSE41:       # BB#0:
; SSE41-NEXT:    pextrq $1, %xmm0, %rax
; SSE41-NEXT:    bsfq %rax, %rax
; SSE41-NEXT:    movl $64, %ecx
; SSE41-NEXT:    cmoveq %rcx, %rax
; SSE41-NEXT:    movd %rax, %xmm1
; SSE41-NEXT:    movd %xmm0, %rax
; SSE41-NEXT:    bsfq %rax, %rax
; SSE41-NEXT:    cmoveq %rcx, %rax
; SSE41-NEXT:    movd %rax, %xmm0
; SSE41-NEXT:    punpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; SSE41-NEXT:    retq
;
; AVX-LABEL: testv2i64:
; AVX:       # BB#0:
; AVX-NEXT:    vpextrq $1, %xmm0, %rax
; AVX-NEXT:    bsfq %rax, %rax
; AVX-NEXT:    movl $64, %ecx
; AVX-NEXT:    cmoveq %rcx, %rax
; AVX-NEXT:    vmovq %rax, %xmm1
; AVX-NEXT:    vmovq %xmm0, %rax
; AVX-NEXT:    bsfq %rax, %rax
; AVX-NEXT:    cmoveq %rcx, %rax
; AVX-NEXT:    vmovq %rax, %xmm0
; AVX-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; AVX-NEXT:    retq
  %out = call <2 x i64> @llvm.cttz.v2i64(<2 x i64> %in, i1 0)
  ret <2 x i64> %out
}

define <2 x i64> @testv2i64u(<2 x i64> %in) nounwind {
; SSE2-LABEL: testv2i64u:
; SSE2:       # BB#0:
; SSE2-NEXT:    movd %xmm0, %rax
; SSE2-NEXT:    bsfq %rax, %rax
; SSE2-NEXT:    movd %rax, %xmm1
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[2,3,0,1]
; SSE2-NEXT:    movd %xmm0, %rax
; SSE2-NEXT:    bsfq %rax, %rax
; SSE2-NEXT:    movd %rax, %xmm0
; SSE2-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm0[0]
; SSE2-NEXT:    movdqa %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSE3-LABEL: testv2i64u:
; SSE3:       # BB#0:
; SSE3-NEXT:    movd %xmm0, %rax
; SSE3-NEXT:    bsfq %rax, %rax
; SSE3-NEXT:    movd %rax, %xmm1
; SSE3-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[2,3,0,1]
; SSE3-NEXT:    movd %xmm0, %rax
; SSE3-NEXT:    bsfq %rax, %rax
; SSE3-NEXT:    movd %rax, %xmm0
; SSE3-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm0[0]
; SSE3-NEXT:    movdqa %xmm1, %xmm0
; SSE3-NEXT:    retq
;
; SSSE3-LABEL: testv2i64u:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    movd %xmm0, %rax
; SSSE3-NEXT:    bsfq %rax, %rax
; SSSE3-NEXT:    movd %rax, %xmm1
; SSSE3-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[2,3,0,1]
; SSSE3-NEXT:    movd %xmm0, %rax
; SSSE3-NEXT:    bsfq %rax, %rax
; SSSE3-NEXT:    movd %rax, %xmm0
; SSSE3-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm0[0]
; SSSE3-NEXT:    movdqa %xmm1, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: testv2i64u:
; SSE41:       # BB#0:
; SSE41-NEXT:    pextrq $1, %xmm0, %rax
; SSE41-NEXT:    bsfq %rax, %rax
; SSE41-NEXT:    movd %rax, %xmm1
; SSE41-NEXT:    movd %xmm0, %rax
; SSE41-NEXT:    bsfq %rax, %rax
; SSE41-NEXT:    movd %rax, %xmm0
; SSE41-NEXT:    punpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; SSE41-NEXT:    retq
;
; AVX-LABEL: testv2i64u:
; AVX:       # BB#0:
; AVX-NEXT:    vpextrq $1, %xmm0, %rax
; AVX-NEXT:    bsfq %rax, %rax
; AVX-NEXT:    vmovq %rax, %xmm1
; AVX-NEXT:    vmovq %xmm0, %rax
; AVX-NEXT:    bsfq %rax, %rax
; AVX-NEXT:    vmovq %rax, %xmm0
; AVX-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; AVX-NEXT:    retq
  %out = call <2 x i64> @llvm.cttz.v2i64(<2 x i64> %in, i1 -1)
  ret <2 x i64> %out
}

define <4 x i32> @testv4i32(<4 x i32> %in) nounwind {
; SSE2-LABEL: testv4i32:
; SSE2:       # BB#0:
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    psubd %xmm0, %xmm2
; SSE2-NEXT:    pand %xmm0, %xmm2
; SSE2-NEXT:    psubd {{.*}}(%rip), %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    psrld $1, %xmm0
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE2-NEXT:    psubd %xmm0, %xmm2
; SSE2-NEXT:    movdqa {{.*#+}} xmm0 = [858993459,858993459,858993459,858993459]
; SSE2-NEXT:    movdqa %xmm2, %xmm3
; SSE2-NEXT:    pand %xmm0, %xmm3
; SSE2-NEXT:    psrld $2, %xmm2
; SSE2-NEXT:    pand %xmm0, %xmm2
; SSE2-NEXT:    paddd %xmm3, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    psrld $4, %xmm0
; SSE2-NEXT:    paddd %xmm2, %xmm0
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    punpckhdq {{.*#+}} xmm2 = xmm2[2],xmm1[2],xmm2[3],xmm1[3]
; SSE2-NEXT:    psadbw %xmm1, %xmm2
; SSE2-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; SSE2-NEXT:    psadbw %xmm1, %xmm0
; SSE2-NEXT:    packuswb %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE3-LABEL: testv4i32:
; SSE3:       # BB#0:
; SSE3-NEXT:    pxor %xmm1, %xmm1
; SSE3-NEXT:    pxor %xmm2, %xmm2
; SSE3-NEXT:    psubd %xmm0, %xmm2
; SSE3-NEXT:    pand %xmm0, %xmm2
; SSE3-NEXT:    psubd {{.*}}(%rip), %xmm2
; SSE3-NEXT:    movdqa %xmm2, %xmm0
; SSE3-NEXT:    psrld $1, %xmm0
; SSE3-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE3-NEXT:    psubd %xmm0, %xmm2
; SSE3-NEXT:    movdqa {{.*#+}} xmm0 = [858993459,858993459,858993459,858993459]
; SSE3-NEXT:    movdqa %xmm2, %xmm3
; SSE3-NEXT:    pand %xmm0, %xmm3
; SSE3-NEXT:    psrld $2, %xmm2
; SSE3-NEXT:    pand %xmm0, %xmm2
; SSE3-NEXT:    paddd %xmm3, %xmm2
; SSE3-NEXT:    movdqa %xmm2, %xmm0
; SSE3-NEXT:    psrld $4, %xmm0
; SSE3-NEXT:    paddd %xmm2, %xmm0
; SSE3-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE3-NEXT:    movdqa %xmm0, %xmm2
; SSE3-NEXT:    punpckhdq {{.*#+}} xmm2 = xmm2[2],xmm1[2],xmm2[3],xmm1[3]
; SSE3-NEXT:    psadbw %xmm1, %xmm2
; SSE3-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; SSE3-NEXT:    psadbw %xmm1, %xmm0
; SSE3-NEXT:    packuswb %xmm2, %xmm0
; SSE3-NEXT:    retq
;
; SSSE3-LABEL: testv4i32:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pxor %xmm1, %xmm1
; SSSE3-NEXT:    pxor %xmm2, %xmm2
; SSSE3-NEXT:    psubd %xmm0, %xmm2
; SSSE3-NEXT:    pand %xmm0, %xmm2
; SSSE3-NEXT:    psubd {{.*}}(%rip), %xmm2
; SSSE3-NEXT:    movdqa {{.*#+}} xmm3 = [15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15]
; SSSE3-NEXT:    movdqa %xmm2, %xmm4
; SSSE3-NEXT:    pand %xmm3, %xmm4
; SSSE3-NEXT:    movdqa {{.*#+}} xmm0 = [0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4]
; SSSE3-NEXT:    movdqa %xmm0, %xmm5
; SSSE3-NEXT:    pshufb %xmm4, %xmm5
; SSSE3-NEXT:    psrlw $4, %xmm2
; SSSE3-NEXT:    pand %xmm3, %xmm2
; SSSE3-NEXT:    pshufb %xmm2, %xmm0
; SSSE3-NEXT:    paddb %xmm5, %xmm0
; SSSE3-NEXT:    movdqa %xmm0, %xmm2
; SSSE3-NEXT:    punpckhdq {{.*#+}} xmm2 = xmm2[2],xmm1[2],xmm2[3],xmm1[3]
; SSSE3-NEXT:    psadbw %xmm1, %xmm2
; SSSE3-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; SSSE3-NEXT:    psadbw %xmm1, %xmm0
; SSSE3-NEXT:    packuswb %xmm2, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: testv4i32:
; SSE41:       # BB#0:
; SSE41-NEXT:    pxor %xmm1, %xmm1
; SSE41-NEXT:    pxor %xmm2, %xmm2
; SSE41-NEXT:    psubd %xmm0, %xmm2
; SSE41-NEXT:    pand %xmm0, %xmm2
; SSE41-NEXT:    psubd {{.*}}(%rip), %xmm2
; SSE41-NEXT:    movdqa {{.*#+}} xmm3 = [15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15]
; SSE41-NEXT:    movdqa %xmm2, %xmm4
; SSE41-NEXT:    pand %xmm3, %xmm4
; SSE41-NEXT:    movdqa {{.*#+}} xmm0 = [0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4]
; SSE41-NEXT:    movdqa %xmm0, %xmm5
; SSE41-NEXT:    pshufb %xmm4, %xmm5
; SSE41-NEXT:    psrlw $4, %xmm2
; SSE41-NEXT:    pand %xmm3, %xmm2
; SSE41-NEXT:    pshufb %xmm2, %xmm0
; SSE41-NEXT:    paddb %xmm5, %xmm0
; SSE41-NEXT:    movdqa %xmm0, %xmm2
; SSE41-NEXT:    punpckhdq {{.*#+}} xmm2 = xmm2[2],xmm1[2],xmm2[3],xmm1[3]
; SSE41-NEXT:    psadbw %xmm1, %xmm2
; SSE41-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; SSE41-NEXT:    psadbw %xmm1, %xmm0
; SSE41-NEXT:    packuswb %xmm2, %xmm0
; SSE41-NEXT:    retq
;
; AVX1-LABEL: testv4i32:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX1-NEXT:    vpsubd %xmm0, %xmm1, %xmm2
; AVX1-NEXT:    vpand %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vpsubd {{.*}}(%rip), %xmm0, %xmm0
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm2 = [15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15]
; AVX1-NEXT:    vpand %xmm2, %xmm0, %xmm3
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm4 = [0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4]
; AVX1-NEXT:    vpshufb %xmm3, %xmm4, %xmm3
; AVX1-NEXT:    vpsrlw $4, %xmm0, %xmm0
; AVX1-NEXT:    vpand %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vpshufb %xmm0, %xmm4, %xmm0
; AVX1-NEXT:    vpaddb %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vpunpckhdq {{.*#+}} xmm2 = xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; AVX1-NEXT:    vpsadbw %xmm2, %xmm1, %xmm2
; AVX1-NEXT:    vpunpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; AVX1-NEXT:    vpsadbw %xmm0, %xmm1, %xmm0
; AVX1-NEXT:    vpackuswb %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: testv4i32:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX2-NEXT:    vpsubd %xmm0, %xmm1, %xmm2
; AVX2-NEXT:    vpand %xmm2, %xmm0, %xmm0
; AVX2-NEXT:    vpbroadcastd {{.*}}(%rip), %xmm2
; AVX2-NEXT:    vpsubd %xmm2, %xmm0, %xmm0
; AVX2-NEXT:    vmovdqa {{.*#+}} xmm2 = [15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15]
; AVX2-NEXT:    vpand %xmm2, %xmm0, %xmm3
; AVX2-NEXT:    vmovdqa {{.*#+}} xmm4 = [0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4]
; AVX2-NEXT:    vpshufb %xmm3, %xmm4, %xmm3
; AVX2-NEXT:    vpsrlw $4, %xmm0, %xmm0
; AVX2-NEXT:    vpand %xmm2, %xmm0, %xmm0
; AVX2-NEXT:    vpshufb %xmm0, %xmm4, %xmm0
; AVX2-NEXT:    vpaddb %xmm3, %xmm0, %xmm0
; AVX2-NEXT:    vpunpckhdq {{.*#+}} xmm2 = xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; AVX2-NEXT:    vpsadbw %xmm2, %xmm1, %xmm2
; AVX2-NEXT:    vpunpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; AVX2-NEXT:    vpsadbw %xmm0, %xmm1, %xmm0
; AVX2-NEXT:    vpackuswb %xmm2, %xmm0, %xmm0
; AVX2-NEXT:    retq
  %out = call <4 x i32> @llvm.cttz.v4i32(<4 x i32> %in, i1 0)
  ret <4 x i32> %out
}

define <4 x i32> @testv4i32u(<4 x i32> %in) nounwind {
; SSE2-LABEL: testv4i32u:
; SSE2:       # BB#0:
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    psubd %xmm0, %xmm2
; SSE2-NEXT:    pand %xmm0, %xmm2
; SSE2-NEXT:    psubd {{.*}}(%rip), %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    psrld $1, %xmm0
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE2-NEXT:    psubd %xmm0, %xmm2
; SSE2-NEXT:    movdqa {{.*#+}} xmm0 = [858993459,858993459,858993459,858993459]
; SSE2-NEXT:    movdqa %xmm2, %xmm3
; SSE2-NEXT:    pand %xmm0, %xmm3
; SSE2-NEXT:    psrld $2, %xmm2
; SSE2-NEXT:    pand %xmm0, %xmm2
; SSE2-NEXT:    paddd %xmm3, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    psrld $4, %xmm0
; SSE2-NEXT:    paddd %xmm2, %xmm0
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    punpckhdq {{.*#+}} xmm2 = xmm2[2],xmm1[2],xmm2[3],xmm1[3]
; SSE2-NEXT:    psadbw %xmm1, %xmm2
; SSE2-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; SSE2-NEXT:    psadbw %xmm1, %xmm0
; SSE2-NEXT:    packuswb %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE3-LABEL: testv4i32u:
; SSE3:       # BB#0:
; SSE3-NEXT:    pxor %xmm1, %xmm1
; SSE3-NEXT:    pxor %xmm2, %xmm2
; SSE3-NEXT:    psubd %xmm0, %xmm2
; SSE3-NEXT:    pand %xmm0, %xmm2
; SSE3-NEXT:    psubd {{.*}}(%rip), %xmm2
; SSE3-NEXT:    movdqa %xmm2, %xmm0
; SSE3-NEXT:    psrld $1, %xmm0
; SSE3-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE3-NEXT:    psubd %xmm0, %xmm2
; SSE3-NEXT:    movdqa {{.*#+}} xmm0 = [858993459,858993459,858993459,858993459]
; SSE3-NEXT:    movdqa %xmm2, %xmm3
; SSE3-NEXT:    pand %xmm0, %xmm3
; SSE3-NEXT:    psrld $2, %xmm2
; SSE3-NEXT:    pand %xmm0, %xmm2
; SSE3-NEXT:    paddd %xmm3, %xmm2
; SSE3-NEXT:    movdqa %xmm2, %xmm0
; SSE3-NEXT:    psrld $4, %xmm0
; SSE3-NEXT:    paddd %xmm2, %xmm0
; SSE3-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE3-NEXT:    movdqa %xmm0, %xmm2
; SSE3-NEXT:    punpckhdq {{.*#+}} xmm2 = xmm2[2],xmm1[2],xmm2[3],xmm1[3]
; SSE3-NEXT:    psadbw %xmm1, %xmm2
; SSE3-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; SSE3-NEXT:    psadbw %xmm1, %xmm0
; SSE3-NEXT:    packuswb %xmm2, %xmm0
; SSE3-NEXT:    retq
;
; SSSE3-LABEL: testv4i32u:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pxor %xmm1, %xmm1
; SSSE3-NEXT:    pxor %xmm2, %xmm2
; SSSE3-NEXT:    psubd %xmm0, %xmm2
; SSSE3-NEXT:    pand %xmm0, %xmm2
; SSSE3-NEXT:    psubd {{.*}}(%rip), %xmm2
; SSSE3-NEXT:    movdqa {{.*#+}} xmm3 = [15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15]
; SSSE3-NEXT:    movdqa %xmm2, %xmm4
; SSSE3-NEXT:    pand %xmm3, %xmm4
; SSSE3-NEXT:    movdqa {{.*#+}} xmm0 = [0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4]
; SSSE3-NEXT:    movdqa %xmm0, %xmm5
; SSSE3-NEXT:    pshufb %xmm4, %xmm5
; SSSE3-NEXT:    psrlw $4, %xmm2
; SSSE3-NEXT:    pand %xmm3, %xmm2
; SSSE3-NEXT:    pshufb %xmm2, %xmm0
; SSSE3-NEXT:    paddb %xmm5, %xmm0
; SSSE3-NEXT:    movdqa %xmm0, %xmm2
; SSSE3-NEXT:    punpckhdq {{.*#+}} xmm2 = xmm2[2],xmm1[2],xmm2[3],xmm1[3]
; SSSE3-NEXT:    psadbw %xmm1, %xmm2
; SSSE3-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; SSSE3-NEXT:    psadbw %xmm1, %xmm0
; SSSE3-NEXT:    packuswb %xmm2, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: testv4i32u:
; SSE41:       # BB#0:
; SSE41-NEXT:    pxor %xmm1, %xmm1
; SSE41-NEXT:    pxor %xmm2, %xmm2
; SSE41-NEXT:    psubd %xmm0, %xmm2
; SSE41-NEXT:    pand %xmm0, %xmm2
; SSE41-NEXT:    psubd {{.*}}(%rip), %xmm2
; SSE41-NEXT:    movdqa {{.*#+}} xmm3 = [15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15]
; SSE41-NEXT:    movdqa %xmm2, %xmm4
; SSE41-NEXT:    pand %xmm3, %xmm4
; SSE41-NEXT:    movdqa {{.*#+}} xmm0 = [0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4]
; SSE41-NEXT:    movdqa %xmm0, %xmm5
; SSE41-NEXT:    pshufb %xmm4, %xmm5
; SSE41-NEXT:    psrlw $4, %xmm2
; SSE41-NEXT:    pand %xmm3, %xmm2
; SSE41-NEXT:    pshufb %xmm2, %xmm0
; SSE41-NEXT:    paddb %xmm5, %xmm0
; SSE41-NEXT:    movdqa %xmm0, %xmm2
; SSE41-NEXT:    punpckhdq {{.*#+}} xmm2 = xmm2[2],xmm1[2],xmm2[3],xmm1[3]
; SSE41-NEXT:    psadbw %xmm1, %xmm2
; SSE41-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; SSE41-NEXT:    psadbw %xmm1, %xmm0
; SSE41-NEXT:    packuswb %xmm2, %xmm0
; SSE41-NEXT:    retq
;
; AVX1-LABEL: testv4i32u:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX1-NEXT:    vpsubd %xmm0, %xmm1, %xmm2
; AVX1-NEXT:    vpand %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vpsubd {{.*}}(%rip), %xmm0, %xmm0
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm2 = [15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15]
; AVX1-NEXT:    vpand %xmm2, %xmm0, %xmm3
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm4 = [0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4]
; AVX1-NEXT:    vpshufb %xmm3, %xmm4, %xmm3
; AVX1-NEXT:    vpsrlw $4, %xmm0, %xmm0
; AVX1-NEXT:    vpand %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vpshufb %xmm0, %xmm4, %xmm0
; AVX1-NEXT:    vpaddb %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vpunpckhdq {{.*#+}} xmm2 = xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; AVX1-NEXT:    vpsadbw %xmm2, %xmm1, %xmm2
; AVX1-NEXT:    vpunpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; AVX1-NEXT:    vpsadbw %xmm0, %xmm1, %xmm0
; AVX1-NEXT:    vpackuswb %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: testv4i32u:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX2-NEXT:    vpsubd %xmm0, %xmm1, %xmm2
; AVX2-NEXT:    vpand %xmm2, %xmm0, %xmm0
; AVX2-NEXT:    vpbroadcastd {{.*}}(%rip), %xmm2
; AVX2-NEXT:    vpsubd %xmm2, %xmm0, %xmm0
; AVX2-NEXT:    vmovdqa {{.*#+}} xmm2 = [15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15]
; AVX2-NEXT:    vpand %xmm2, %xmm0, %xmm3
; AVX2-NEXT:    vmovdqa {{.*#+}} xmm4 = [0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4]
; AVX2-NEXT:    vpshufb %xmm3, %xmm4, %xmm3
; AVX2-NEXT:    vpsrlw $4, %xmm0, %xmm0
; AVX2-NEXT:    vpand %xmm2, %xmm0, %xmm0
; AVX2-NEXT:    vpshufb %xmm0, %xmm4, %xmm0
; AVX2-NEXT:    vpaddb %xmm3, %xmm0, %xmm0
; AVX2-NEXT:    vpunpckhdq {{.*#+}} xmm2 = xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; AVX2-NEXT:    vpsadbw %xmm2, %xmm1, %xmm2
; AVX2-NEXT:    vpunpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; AVX2-NEXT:    vpsadbw %xmm0, %xmm1, %xmm0
; AVX2-NEXT:    vpackuswb %xmm2, %xmm0, %xmm0
; AVX2-NEXT:    retq
  %out = call <4 x i32> @llvm.cttz.v4i32(<4 x i32> %in, i1 -1)
  ret <4 x i32> %out
}

define <8 x i16> @testv8i16(<8 x i16> %in) nounwind {
; SSE2-LABEL: testv8i16:
; SSE2:       # BB#0:
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    psubw %xmm0, %xmm1
; SSE2-NEXT:    pand %xmm0, %xmm1
; SSE2-NEXT:    psubw {{.*}}(%rip), %xmm1
; SSE2-NEXT:    movdqa %xmm1, %xmm0
; SSE2-NEXT:    psrlw $1, %xmm0
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE2-NEXT:    psubw %xmm0, %xmm1
; SSE2-NEXT:    movdqa {{.*#+}} xmm0 = [13107,13107,13107,13107,13107,13107,13107,13107]
; SSE2-NEXT:    movdqa %xmm1, %xmm2
; SSE2-NEXT:    pand %xmm0, %xmm2
; SSE2-NEXT:    psrlw $2, %xmm1
; SSE2-NEXT:    pand %xmm0, %xmm1
; SSE2-NEXT:    paddw %xmm2, %xmm1
; SSE2-NEXT:    movdqa %xmm1, %xmm2
; SSE2-NEXT:    psrlw $4, %xmm2
; SSE2-NEXT:    paddw %xmm1, %xmm2
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    psllw $8, %xmm0
; SSE2-NEXT:    paddb %xmm2, %xmm0
; SSE2-NEXT:    psrlw $8, %xmm0
; SSE2-NEXT:    retq
;
; SSE3-LABEL: testv8i16:
; SSE3:       # BB#0:
; SSE3-NEXT:    pxor %xmm1, %xmm1
; SSE3-NEXT:    psubw %xmm0, %xmm1
; SSE3-NEXT:    pand %xmm0, %xmm1
; SSE3-NEXT:    psubw {{.*}}(%rip), %xmm1
; SSE3-NEXT:    movdqa %xmm1, %xmm0
; SSE3-NEXT:    psrlw $1, %xmm0
; SSE3-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE3-NEXT:    psubw %xmm0, %xmm1
; SSE3-NEXT:    movdqa {{.*#+}} xmm0 = [13107,13107,13107,13107,13107,13107,13107,13107]
; SSE3-NEXT:    movdqa %xmm1, %xmm2
; SSE3-NEXT:    pand %xmm0, %xmm2
; SSE3-NEXT:    psrlw $2, %xmm1
; SSE3-NEXT:    pand %xmm0, %xmm1
; SSE3-NEXT:    paddw %xmm2, %xmm1
; SSE3-NEXT:    movdqa %xmm1, %xmm2
; SSE3-NEXT:    psrlw $4, %xmm2
; SSE3-NEXT:    paddw %xmm1, %xmm2
; SSE3-NEXT:    pand {{.*}}(%rip), %xmm2
; SSE3-NEXT:    movdqa %xmm2, %xmm0
; SSE3-NEXT:    psllw $8, %xmm0
; SSE3-NEXT:    paddb %xmm2, %xmm0
; SSE3-NEXT:    psrlw $8, %xmm0
; SSE3-NEXT:    retq
;
; SSSE3-LABEL: testv8i16:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pxor %xmm1, %xmm1
; SSSE3-NEXT:    psubw %xmm0, %xmm1
; SSSE3-NEXT:    pand %xmm0, %xmm1
; SSSE3-NEXT:    psubw {{.*}}(%rip), %xmm1
; SSSE3-NEXT:    movdqa {{.*#+}} xmm0 = [15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15]
; SSSE3-NEXT:    movdqa %xmm1, %xmm2
; SSSE3-NEXT:    pand %xmm0, %xmm2
; SSSE3-NEXT:    movdqa {{.*#+}} xmm3 = [0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4]
; SSSE3-NEXT:    movdqa %xmm3, %xmm4
; SSSE3-NEXT:    pshufb %xmm2, %xmm4
; SSSE3-NEXT:    psrlw $4, %xmm1
; SSSE3-NEXT:    pand %xmm0, %xmm1
; SSSE3-NEXT:    pshufb %xmm1, %xmm3
; SSSE3-NEXT:    paddb %xmm4, %xmm3
; SSSE3-NEXT:    movdqa %xmm3, %xmm0
; SSSE3-NEXT:    psllw $8, %xmm0
; SSSE3-NEXT:    paddb %xmm3, %xmm0
; SSSE3-NEXT:    psrlw $8, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: testv8i16:
; SSE41:       # BB#0:
; SSE41-NEXT:    pxor %xmm1, %xmm1
; SSE41-NEXT:    psubw %xmm0, %xmm1
; SSE41-NEXT:    pand %xmm0, %xmm1
; SSE41-NEXT:    psubw {{.*}}(%rip), %xmm1
; SSE41-NEXT:    movdqa {{.*#+}} xmm0 = [15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15]
; SSE41-NEXT:    movdqa %xmm1, %xmm2
; SSE41-NEXT:    pand %xmm0, %xmm2
; SSE41-NEXT:    movdqa {{.*#+}} xmm3 = [0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4]
; SSE41-NEXT:    movdqa %xmm3, %xmm4
; SSE41-NEXT:    pshufb %xmm2, %xmm4
; SSE41-NEXT:    psrlw $4, %xmm1
; SSE41-NEXT:    pand %xmm0, %xmm1
; SSE41-NEXT:    pshufb %xmm1, %xmm3
; SSE41-NEXT:    paddb %xmm4, %xmm3
; SSE41-NEXT:    movdqa %xmm3, %xmm0
; SSE41-NEXT:    psllw $8, %xmm0
; SSE41-NEXT:    paddb %xmm3, %xmm0
; SSE41-NEXT:    psrlw $8, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: testv8i16:
; AVX:       # BB#0:
; AVX-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX-NEXT:    vpsubw %xmm0, %xmm1, %xmm1
; AVX-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vpsubw {{.*}}(%rip), %xmm0, %xmm0
; AVX-NEXT:    vmovdqa {{.*#+}} xmm1 = [15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15]
; AVX-NEXT:    vpand %xmm1, %xmm0, %xmm2
; AVX-NEXT:    vmovdqa {{.*#+}} xmm3 = [0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4]
; AVX-NEXT:    vpshufb %xmm2, %xmm3, %xmm2
; AVX-NEXT:    vpsrlw $4, %xmm0, %xmm0
; AVX-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vpshufb %xmm0, %xmm3, %xmm0
; AVX-NEXT:    vpaddb %xmm2, %xmm0, %xmm0
; AVX-NEXT:    vpsllw $8, %xmm0, %xmm1
; AVX-NEXT:    vpaddb %xmm0, %xmm1, %xmm0
; AVX-NEXT:    vpsrlw $8, %xmm0, %xmm0
; AVX-NEXT:    retq
  %out = call <8 x i16> @llvm.cttz.v8i16(<8 x i16> %in, i1 0)
  ret <8 x i16> %out
}

define <8 x i16> @testv8i16u(<8 x i16> %in) nounwind {
; SSE2-LABEL: testv8i16u:
; SSE2:       # BB#0:
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    psubw %xmm0, %xmm1
; SSE2-NEXT:    pand %xmm0, %xmm1
; SSE2-NEXT:    psubw {{.*}}(%rip), %xmm1
; SSE2-NEXT:    movdqa %xmm1, %xmm0
; SSE2-NEXT:    psrlw $1, %xmm0
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE2-NEXT:    psubw %xmm0, %xmm1
; SSE2-NEXT:    movdqa {{.*#+}} xmm0 = [13107,13107,13107,13107,13107,13107,13107,13107]
; SSE2-NEXT:    movdqa %xmm1, %xmm2
; SSE2-NEXT:    pand %xmm0, %xmm2
; SSE2-NEXT:    psrlw $2, %xmm1
; SSE2-NEXT:    pand %xmm0, %xmm1
; SSE2-NEXT:    paddw %xmm2, %xmm1
; SSE2-NEXT:    movdqa %xmm1, %xmm2
; SSE2-NEXT:    psrlw $4, %xmm2
; SSE2-NEXT:    paddw %xmm1, %xmm2
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    psllw $8, %xmm0
; SSE2-NEXT:    paddb %xmm2, %xmm0
; SSE2-NEXT:    psrlw $8, %xmm0
; SSE2-NEXT:    retq
;
; SSE3-LABEL: testv8i16u:
; SSE3:       # BB#0:
; SSE3-NEXT:    pxor %xmm1, %xmm1
; SSE3-NEXT:    psubw %xmm0, %xmm1
; SSE3-NEXT:    pand %xmm0, %xmm1
; SSE3-NEXT:    psubw {{.*}}(%rip), %xmm1
; SSE3-NEXT:    movdqa %xmm1, %xmm0
; SSE3-NEXT:    psrlw $1, %xmm0
; SSE3-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE3-NEXT:    psubw %xmm0, %xmm1
; SSE3-NEXT:    movdqa {{.*#+}} xmm0 = [13107,13107,13107,13107,13107,13107,13107,13107]
; SSE3-NEXT:    movdqa %xmm1, %xmm2
; SSE3-NEXT:    pand %xmm0, %xmm2
; SSE3-NEXT:    psrlw $2, %xmm1
; SSE3-NEXT:    pand %xmm0, %xmm1
; SSE3-NEXT:    paddw %xmm2, %xmm1
; SSE3-NEXT:    movdqa %xmm1, %xmm2
; SSE3-NEXT:    psrlw $4, %xmm2
; SSE3-NEXT:    paddw %xmm1, %xmm2
; SSE3-NEXT:    pand {{.*}}(%rip), %xmm2
; SSE3-NEXT:    movdqa %xmm2, %xmm0
; SSE3-NEXT:    psllw $8, %xmm0
; SSE3-NEXT:    paddb %xmm2, %xmm0
; SSE3-NEXT:    psrlw $8, %xmm0
; SSE3-NEXT:    retq
;
; SSSE3-LABEL: testv8i16u:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pxor %xmm1, %xmm1
; SSSE3-NEXT:    psubw %xmm0, %xmm1
; SSSE3-NEXT:    pand %xmm0, %xmm1
; SSSE3-NEXT:    psubw {{.*}}(%rip), %xmm1
; SSSE3-NEXT:    movdqa {{.*#+}} xmm0 = [15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15]
; SSSE3-NEXT:    movdqa %xmm1, %xmm2
; SSSE3-NEXT:    pand %xmm0, %xmm2
; SSSE3-NEXT:    movdqa {{.*#+}} xmm3 = [0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4]
; SSSE3-NEXT:    movdqa %xmm3, %xmm4
; SSSE3-NEXT:    pshufb %xmm2, %xmm4
; SSSE3-NEXT:    psrlw $4, %xmm1
; SSSE3-NEXT:    pand %xmm0, %xmm1
; SSSE3-NEXT:    pshufb %xmm1, %xmm3
; SSSE3-NEXT:    paddb %xmm4, %xmm3
; SSSE3-NEXT:    movdqa %xmm3, %xmm0
; SSSE3-NEXT:    psllw $8, %xmm0
; SSSE3-NEXT:    paddb %xmm3, %xmm0
; SSSE3-NEXT:    psrlw $8, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: testv8i16u:
; SSE41:       # BB#0:
; SSE41-NEXT:    pxor %xmm1, %xmm1
; SSE41-NEXT:    psubw %xmm0, %xmm1
; SSE41-NEXT:    pand %xmm0, %xmm1
; SSE41-NEXT:    psubw {{.*}}(%rip), %xmm1
; SSE41-NEXT:    movdqa {{.*#+}} xmm0 = [15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15]
; SSE41-NEXT:    movdqa %xmm1, %xmm2
; SSE41-NEXT:    pand %xmm0, %xmm2
; SSE41-NEXT:    movdqa {{.*#+}} xmm3 = [0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4]
; SSE41-NEXT:    movdqa %xmm3, %xmm4
; SSE41-NEXT:    pshufb %xmm2, %xmm4
; SSE41-NEXT:    psrlw $4, %xmm1
; SSE41-NEXT:    pand %xmm0, %xmm1
; SSE41-NEXT:    pshufb %xmm1, %xmm3
; SSE41-NEXT:    paddb %xmm4, %xmm3
; SSE41-NEXT:    movdqa %xmm3, %xmm0
; SSE41-NEXT:    psllw $8, %xmm0
; SSE41-NEXT:    paddb %xmm3, %xmm0
; SSE41-NEXT:    psrlw $8, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: testv8i16u:
; AVX:       # BB#0:
; AVX-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX-NEXT:    vpsubw %xmm0, %xmm1, %xmm1
; AVX-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vpsubw {{.*}}(%rip), %xmm0, %xmm0
; AVX-NEXT:    vmovdqa {{.*#+}} xmm1 = [15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15]
; AVX-NEXT:    vpand %xmm1, %xmm0, %xmm2
; AVX-NEXT:    vmovdqa {{.*#+}} xmm3 = [0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4]
; AVX-NEXT:    vpshufb %xmm2, %xmm3, %xmm2
; AVX-NEXT:    vpsrlw $4, %xmm0, %xmm0
; AVX-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vpshufb %xmm0, %xmm3, %xmm0
; AVX-NEXT:    vpaddb %xmm2, %xmm0, %xmm0
; AVX-NEXT:    vpsllw $8, %xmm0, %xmm1
; AVX-NEXT:    vpaddb %xmm0, %xmm1, %xmm0
; AVX-NEXT:    vpsrlw $8, %xmm0, %xmm0
; AVX-NEXT:    retq
  %out = call <8 x i16> @llvm.cttz.v8i16(<8 x i16> %in, i1 -1)
  ret <8 x i16> %out
}

define <16 x i8> @testv16i8(<16 x i8> %in) nounwind {
; SSE2-LABEL: testv16i8:
; SSE2:       # BB#0:
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    psubb %xmm0, %xmm1
; SSE2-NEXT:    pand %xmm0, %xmm1
; SSE2-NEXT:    psubb {{.*}}(%rip), %xmm1
; SSE2-NEXT:    movdqa %xmm1, %xmm0
; SSE2-NEXT:    psrlw $1, %xmm0
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE2-NEXT:    psubb %xmm0, %xmm1
; SSE2-NEXT:    movdqa {{.*#+}} xmm0 = [51,51,51,51,51,51,51,51,51,51,51,51,51,51,51,51]
; SSE2-NEXT:    movdqa %xmm1, %xmm2
; SSE2-NEXT:    pand %xmm0, %xmm2
; SSE2-NEXT:    psrlw $2, %xmm1
; SSE2-NEXT:    pand %xmm0, %xmm1
; SSE2-NEXT:    paddb %xmm2, %xmm1
; SSE2-NEXT:    movdqa %xmm1, %xmm0
; SSE2-NEXT:    psrlw $4, %xmm0
; SSE2-NEXT:    paddb %xmm1, %xmm0
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE2-NEXT:    retq
;
; SSE3-LABEL: testv16i8:
; SSE3:       # BB#0:
; SSE3-NEXT:    pxor %xmm1, %xmm1
; SSE3-NEXT:    psubb %xmm0, %xmm1
; SSE3-NEXT:    pand %xmm0, %xmm1
; SSE3-NEXT:    psubb {{.*}}(%rip), %xmm1
; SSE3-NEXT:    movdqa %xmm1, %xmm0
; SSE3-NEXT:    psrlw $1, %xmm0
; SSE3-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE3-NEXT:    psubb %xmm0, %xmm1
; SSE3-NEXT:    movdqa {{.*#+}} xmm0 = [51,51,51,51,51,51,51,51,51,51,51,51,51,51,51,51]
; SSE3-NEXT:    movdqa %xmm1, %xmm2
; SSE3-NEXT:    pand %xmm0, %xmm2
; SSE3-NEXT:    psrlw $2, %xmm1
; SSE3-NEXT:    pand %xmm0, %xmm1
; SSE3-NEXT:    paddb %xmm2, %xmm1
; SSE3-NEXT:    movdqa %xmm1, %xmm0
; SSE3-NEXT:    psrlw $4, %xmm0
; SSE3-NEXT:    paddb %xmm1, %xmm0
; SSE3-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE3-NEXT:    retq
;
; SSSE3-LABEL: testv16i8:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pxor %xmm1, %xmm1
; SSSE3-NEXT:    psubb %xmm0, %xmm1
; SSSE3-NEXT:    pand %xmm0, %xmm1
; SSSE3-NEXT:    psubb {{.*}}(%rip), %xmm1
; SSSE3-NEXT:    movdqa {{.*#+}} xmm2 = [15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15]
; SSSE3-NEXT:    movdqa %xmm1, %xmm3
; SSSE3-NEXT:    pand %xmm2, %xmm3
; SSSE3-NEXT:    movdqa {{.*#+}} xmm0 = [0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4]
; SSSE3-NEXT:    movdqa %xmm0, %xmm4
; SSSE3-NEXT:    pshufb %xmm3, %xmm4
; SSSE3-NEXT:    psrlw $4, %xmm1
; SSSE3-NEXT:    pand %xmm2, %xmm1
; SSSE3-NEXT:    pshufb %xmm1, %xmm0
; SSSE3-NEXT:    paddb %xmm4, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: testv16i8:
; SSE41:       # BB#0:
; SSE41-NEXT:    pxor %xmm1, %xmm1
; SSE41-NEXT:    psubb %xmm0, %xmm1
; SSE41-NEXT:    pand %xmm0, %xmm1
; SSE41-NEXT:    psubb {{.*}}(%rip), %xmm1
; SSE41-NEXT:    movdqa {{.*#+}} xmm2 = [15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15]
; SSE41-NEXT:    movdqa %xmm1, %xmm3
; SSE41-NEXT:    pand %xmm2, %xmm3
; SSE41-NEXT:    movdqa {{.*#+}} xmm0 = [0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4]
; SSE41-NEXT:    movdqa %xmm0, %xmm4
; SSE41-NEXT:    pshufb %xmm3, %xmm4
; SSE41-NEXT:    psrlw $4, %xmm1
; SSE41-NEXT:    pand %xmm2, %xmm1
; SSE41-NEXT:    pshufb %xmm1, %xmm0
; SSE41-NEXT:    paddb %xmm4, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: testv16i8:
; AVX:       # BB#0:
; AVX-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX-NEXT:    vpsubb %xmm0, %xmm1, %xmm1
; AVX-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vpsubb {{.*}}(%rip), %xmm0, %xmm0
; AVX-NEXT:    vmovdqa {{.*#+}} xmm1 = [15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15]
; AVX-NEXT:    vpand %xmm1, %xmm0, %xmm2
; AVX-NEXT:    vmovdqa {{.*#+}} xmm3 = [0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4]
; AVX-NEXT:    vpshufb %xmm2, %xmm3, %xmm2
; AVX-NEXT:    vpsrlw $4, %xmm0, %xmm0
; AVX-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vpshufb %xmm0, %xmm3, %xmm0
; AVX-NEXT:    vpaddb %xmm2, %xmm0, %xmm0
; AVX-NEXT:    retq
  %out = call <16 x i8> @llvm.cttz.v16i8(<16 x i8> %in, i1 0)
  ret <16 x i8> %out
}

define <16 x i8> @testv16i8u(<16 x i8> %in) nounwind {
; SSE2-LABEL: testv16i8u:
; SSE2:       # BB#0:
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    psubb %xmm0, %xmm1
; SSE2-NEXT:    pand %xmm0, %xmm1
; SSE2-NEXT:    psubb {{.*}}(%rip), %xmm1
; SSE2-NEXT:    movdqa %xmm1, %xmm0
; SSE2-NEXT:    psrlw $1, %xmm0
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE2-NEXT:    psubb %xmm0, %xmm1
; SSE2-NEXT:    movdqa {{.*#+}} xmm0 = [51,51,51,51,51,51,51,51,51,51,51,51,51,51,51,51]
; SSE2-NEXT:    movdqa %xmm1, %xmm2
; SSE2-NEXT:    pand %xmm0, %xmm2
; SSE2-NEXT:    psrlw $2, %xmm1
; SSE2-NEXT:    pand %xmm0, %xmm1
; SSE2-NEXT:    paddb %xmm2, %xmm1
; SSE2-NEXT:    movdqa %xmm1, %xmm0
; SSE2-NEXT:    psrlw $4, %xmm0
; SSE2-NEXT:    paddb %xmm1, %xmm0
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE2-NEXT:    retq
;
; SSE3-LABEL: testv16i8u:
; SSE3:       # BB#0:
; SSE3-NEXT:    pxor %xmm1, %xmm1
; SSE3-NEXT:    psubb %xmm0, %xmm1
; SSE3-NEXT:    pand %xmm0, %xmm1
; SSE3-NEXT:    psubb {{.*}}(%rip), %xmm1
; SSE3-NEXT:    movdqa %xmm1, %xmm0
; SSE3-NEXT:    psrlw $1, %xmm0
; SSE3-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE3-NEXT:    psubb %xmm0, %xmm1
; SSE3-NEXT:    movdqa {{.*#+}} xmm0 = [51,51,51,51,51,51,51,51,51,51,51,51,51,51,51,51]
; SSE3-NEXT:    movdqa %xmm1, %xmm2
; SSE3-NEXT:    pand %xmm0, %xmm2
; SSE3-NEXT:    psrlw $2, %xmm1
; SSE3-NEXT:    pand %xmm0, %xmm1
; SSE3-NEXT:    paddb %xmm2, %xmm1
; SSE3-NEXT:    movdqa %xmm1, %xmm0
; SSE3-NEXT:    psrlw $4, %xmm0
; SSE3-NEXT:    paddb %xmm1, %xmm0
; SSE3-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE3-NEXT:    retq
;
; SSSE3-LABEL: testv16i8u:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pxor %xmm1, %xmm1
; SSSE3-NEXT:    psubb %xmm0, %xmm1
; SSSE3-NEXT:    pand %xmm0, %xmm1
; SSSE3-NEXT:    psubb {{.*}}(%rip), %xmm1
; SSSE3-NEXT:    movdqa {{.*#+}} xmm2 = [15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15]
; SSSE3-NEXT:    movdqa %xmm1, %xmm3
; SSSE3-NEXT:    pand %xmm2, %xmm3
; SSSE3-NEXT:    movdqa {{.*#+}} xmm0 = [0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4]
; SSSE3-NEXT:    movdqa %xmm0, %xmm4
; SSSE3-NEXT:    pshufb %xmm3, %xmm4
; SSSE3-NEXT:    psrlw $4, %xmm1
; SSSE3-NEXT:    pand %xmm2, %xmm1
; SSSE3-NEXT:    pshufb %xmm1, %xmm0
; SSSE3-NEXT:    paddb %xmm4, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: testv16i8u:
; SSE41:       # BB#0:
; SSE41-NEXT:    pxor %xmm1, %xmm1
; SSE41-NEXT:    psubb %xmm0, %xmm1
; SSE41-NEXT:    pand %xmm0, %xmm1
; SSE41-NEXT:    psubb {{.*}}(%rip), %xmm1
; SSE41-NEXT:    movdqa {{.*#+}} xmm2 = [15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15]
; SSE41-NEXT:    movdqa %xmm1, %xmm3
; SSE41-NEXT:    pand %xmm2, %xmm3
; SSE41-NEXT:    movdqa {{.*#+}} xmm0 = [0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4]
; SSE41-NEXT:    movdqa %xmm0, %xmm4
; SSE41-NEXT:    pshufb %xmm3, %xmm4
; SSE41-NEXT:    psrlw $4, %xmm1
; SSE41-NEXT:    pand %xmm2, %xmm1
; SSE41-NEXT:    pshufb %xmm1, %xmm0
; SSE41-NEXT:    paddb %xmm4, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: testv16i8u:
; AVX:       # BB#0:
; AVX-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX-NEXT:    vpsubb %xmm0, %xmm1, %xmm1
; AVX-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vpsubb {{.*}}(%rip), %xmm0, %xmm0
; AVX-NEXT:    vmovdqa {{.*#+}} xmm1 = [15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15]
; AVX-NEXT:    vpand %xmm1, %xmm0, %xmm2
; AVX-NEXT:    vmovdqa {{.*#+}} xmm3 = [0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4]
; AVX-NEXT:    vpshufb %xmm2, %xmm3, %xmm2
; AVX-NEXT:    vpsrlw $4, %xmm0, %xmm0
; AVX-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vpshufb %xmm0, %xmm3, %xmm0
; AVX-NEXT:    vpaddb %xmm2, %xmm0, %xmm0
; AVX-NEXT:    retq
  %out = call <16 x i8> @llvm.cttz.v16i8(<16 x i8> %in, i1 -1)
  ret <16 x i8> %out
}

define <2 x i64> @foldv2i64() nounwind {
; SSE-LABEL: foldv2i64:
; SSE:       # BB#0:
; SSE-NEXT:    movl $8, %eax
; SSE-NEXT:    movd %rax, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: foldv2i64:
; AVX:       # BB#0:
; AVX-NEXT:    movl $8, %eax
; AVX-NEXT:    vmovq %rax, %xmm0
; AVX-NEXT:    retq
  %out = call <2 x i64> @llvm.cttz.v2i64(<2 x i64> <i64 256, i64 -1>, i1 0)
  ret <2 x i64> %out
}

define <2 x i64> @foldv2i64u() nounwind {
; SSE-LABEL: foldv2i64u:
; SSE:       # BB#0:
; SSE-NEXT:    movl $8, %eax
; SSE-NEXT:    movd %rax, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: foldv2i64u:
; AVX:       # BB#0:
; AVX-NEXT:    movl $8, %eax
; AVX-NEXT:    vmovq %rax, %xmm0
; AVX-NEXT:    retq
  %out = call <2 x i64> @llvm.cttz.v2i64(<2 x i64> <i64 256, i64 -1>, i1 -1)
  ret <2 x i64> %out
}

define <4 x i32> @foldv4i32() nounwind {
; SSE-LABEL: foldv4i32:
; SSE:       # BB#0:
; SSE-NEXT:    movaps {{.*#+}} xmm0 = [8,0,32,0]
; SSE-NEXT:    retq
;
; AVX-LABEL: foldv4i32:
; AVX:       # BB#0:
; AVX-NEXT:    vmovaps {{.*#+}} xmm0 = [8,0,32,0]
; AVX-NEXT:    retq
  %out = call <4 x i32> @llvm.cttz.v4i32(<4 x i32> <i32 256, i32 -1, i32 0, i32 255>, i1 0)
  ret <4 x i32> %out
}

define <4 x i32> @foldv4i32u() nounwind {
; SSE-LABEL: foldv4i32u:
; SSE:       # BB#0:
; SSE-NEXT:    movaps {{.*#+}} xmm0 = [8,0,32,0]
; SSE-NEXT:    retq
;
; AVX-LABEL: foldv4i32u:
; AVX:       # BB#0:
; AVX-NEXT:    vmovaps {{.*#+}} xmm0 = [8,0,32,0]
; AVX-NEXT:    retq
  %out = call <4 x i32> @llvm.cttz.v4i32(<4 x i32> <i32 256, i32 -1, i32 0, i32 255>, i1 -1)
  ret <4 x i32> %out
}

define <8 x i16> @foldv8i16() nounwind {
; SSE-LABEL: foldv8i16:
; SSE:       # BB#0:
; SSE-NEXT:    movaps {{.*#+}} xmm0 = [8,0,16,0,16,0,3,3]
; SSE-NEXT:    retq
;
; AVX-LABEL: foldv8i16:
; AVX:       # BB#0:
; AVX-NEXT:    vmovaps {{.*#+}} xmm0 = [8,0,16,0,16,0,3,3]
; AVX-NEXT:    retq
  %out = call <8 x i16> @llvm.cttz.v8i16(<8 x i16> <i16 256, i16 -1, i16 0, i16 255, i16 -65536, i16 7, i16 24, i16 88>, i1 0)
  ret <8 x i16> %out
}

define <8 x i16> @foldv8i16u() nounwind {
; SSE-LABEL: foldv8i16u:
; SSE:       # BB#0:
; SSE-NEXT:    movaps {{.*#+}} xmm0 = [8,0,16,0,16,0,3,3]
; SSE-NEXT:    retq
;
; AVX-LABEL: foldv8i16u:
; AVX:       # BB#0:
; AVX-NEXT:    vmovaps {{.*#+}} xmm0 = [8,0,16,0,16,0,3,3]
; AVX-NEXT:    retq
  %out = call <8 x i16> @llvm.cttz.v8i16(<8 x i16> <i16 256, i16 -1, i16 0, i16 255, i16 -65536, i16 7, i16 24, i16 88>, i1 -1)
  ret <8 x i16> %out
}

define <16 x i8> @foldv16i8() nounwind {
; SSE-LABEL: foldv16i8:
; SSE:       # BB#0:
; SSE-NEXT:    movaps {{.*#+}} xmm0 = [8,0,8,0,8,0,3,3,1,1,0,1,2,3,4,5]
; SSE-NEXT:    retq
;
; AVX-LABEL: foldv16i8:
; AVX:       # BB#0:
; AVX-NEXT:    vmovaps {{.*#+}} xmm0 = [8,0,8,0,8,0,3,3,1,1,0,1,2,3,4,5]
; AVX-NEXT:    retq
  %out = call <16 x i8> @llvm.cttz.v16i8(<16 x i8> <i8 256, i8 -1, i8 0, i8 255, i8 -65536, i8 7, i8 24, i8 88, i8 -2, i8 254, i8 1, i8 2, i8 4, i8 8, i8 16, i8 32>, i1 0)
  ret <16 x i8> %out
}

define <16 x i8> @foldv16i8u() nounwind {
; SSE-LABEL: foldv16i8u:
; SSE:       # BB#0:
; SSE-NEXT:    movaps {{.*#+}} xmm0 = [8,0,8,0,8,0,3,3,1,1,0,1,2,3,4,5]
; SSE-NEXT:    retq
;
; AVX-LABEL: foldv16i8u:
; AVX:       # BB#0:
; AVX-NEXT:    vmovaps {{.*#+}} xmm0 = [8,0,8,0,8,0,3,3,1,1,0,1,2,3,4,5]
; AVX-NEXT:    retq
  %out = call <16 x i8> @llvm.cttz.v16i8(<16 x i8> <i8 256, i8 -1, i8 0, i8 255, i8 -65536, i8 7, i8 24, i8 88, i8 -2, i8 254, i8 1, i8 2, i8 4, i8 8, i8 16, i8 32>, i1 -1)
  ret <16 x i8> %out
}

declare <2 x i64> @llvm.cttz.v2i64(<2 x i64>, i1)
declare <4 x i32> @llvm.cttz.v4i32(<4 x i32>, i1)
declare <8 x i16> @llvm.cttz.v8i16(<8 x i16>, i1)
declare <16 x i8> @llvm.cttz.v16i8(<16 x i8>, i1)
