; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse2 | FileCheck %s --check-prefix=ALL --check-prefix=SSE --check-prefix=SSE2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse4.1 | FileCheck %s --check-prefix=ALL --check-prefix=SSE --check-prefix=SSE41
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx | FileCheck %s --check-prefix=ALL --check-prefix=AVX --check-prefix=AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx2 | FileCheck %s --check-prefix=ALL --check-prefix=AVX --check-prefix=AVX2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+xop,+avx | FileCheck %s --check-prefix=ALL --check-prefix=XOP --check-prefix=XOPAVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+xop,+avx2 | FileCheck %s --check-prefix=ALL --check-prefix=XOP --check-prefix=XOPAVX2
;
; Just one 32-bit run to make sure we do reasonable things for i64 shifts.
; RUN: llc < %s -mtriple=i686-unknown-unknown -mattr=+sse2 | FileCheck %s --check-prefix=ALL --check-prefix=X32-SSE --check-prefix=X32-SSE2

;
; Variable Shifts
;

define <2 x i64> @var_shift_v2i64(<2 x i64> %a, <2 x i64> %b) nounwind {
; SSE2-LABEL: var_shift_v2i64:
; SSE2:       # BB#0:
; SSE2-NEXT:    pshufd {{.*#+}} xmm3 = xmm1[2,3,0,1]
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    psllq %xmm3, %xmm2
; SSE2-NEXT:    psllq %xmm1, %xmm0
; SSE2-NEXT:    movsd {{.*#+}} xmm2 = xmm0[0],xmm2[1]
; SSE2-NEXT:    movapd %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: var_shift_v2i64:
; SSE41:       # BB#0:
; SSE41-NEXT:    movdqa %xmm0, %xmm2
; SSE41-NEXT:    psllq %xmm1, %xmm2
; SSE41-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[2,3,0,1]
; SSE41-NEXT:    psllq %xmm1, %xmm0
; SSE41-NEXT:    pblendw {{.*#+}} xmm0 = xmm2[0,1,2,3],xmm0[4,5,6,7]
; SSE41-NEXT:    retq
;
; AVX1-LABEL: var_shift_v2i64:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpsllq %xmm1, %xmm0, %xmm2
; AVX1-NEXT:    vpshufd {{.*#+}} xmm1 = xmm1[2,3,0,1]
; AVX1-NEXT:    vpsllq %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpblendw {{.*#+}} xmm0 = xmm2[0,1,2,3],xmm0[4,5,6,7]
; AVX1-NEXT:    retq
;
; AVX2-LABEL: var_shift_v2i64:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpsllvq %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: var_shift_v2i64:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vpshlq %xmm1, %xmm0, %xmm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: var_shift_v2i64:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vpsllvq %xmm1, %xmm0, %xmm0
; XOPAVX2-NEXT:    retq
;
; X32-SSE-LABEL: var_shift_v2i64:
; X32-SSE:       # BB#0:
; X32-SSE-NEXT:    pshufd {{.*#+}} xmm3 = xmm1[2,3,0,1]
; X32-SSE-NEXT:    movdqa %xmm0, %xmm2
; X32-SSE-NEXT:    psllq %xmm3, %xmm2
; X32-SSE-NEXT:    movq {{.*#+}} xmm1 = xmm1[0],zero
; X32-SSE-NEXT:    psllq %xmm1, %xmm0
; X32-SSE-NEXT:    movsd {{.*#+}} xmm2 = xmm0[0],xmm2[1]
; X32-SSE-NEXT:    movapd %xmm2, %xmm0
; X32-SSE-NEXT:    retl
  %shift = shl <2 x i64> %a, %b
  ret <2 x i64> %shift
}

define <4 x i32> @var_shift_v4i32(<4 x i32> %a, <4 x i32> %b) nounwind {
; SSE2-LABEL: var_shift_v4i32:
; SSE2:       # BB#0:
; SSE2-NEXT:    pslld $23, %xmm1
; SSE2-NEXT:    paddd {{.*}}(%rip), %xmm1
; SSE2-NEXT:    cvttps2dq %xmm1, %xmm1
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm1[1,1,3,3]
; SSE2-NEXT:    pmuludq %xmm0, %xmm1
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[0,2,2,3]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,1,3,3]
; SSE2-NEXT:    pmuludq %xmm2, %xmm0
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; SSE2-NEXT:    punpckldq {{.*#+}} xmm1 = xmm1[0],xmm0[0],xmm1[1],xmm0[1]
; SSE2-NEXT:    movdqa %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: var_shift_v4i32:
; SSE41:       # BB#0:
; SSE41-NEXT:    pslld $23, %xmm1
; SSE41-NEXT:    paddd {{.*}}(%rip), %xmm1
; SSE41-NEXT:    cvttps2dq %xmm1, %xmm1
; SSE41-NEXT:    pmulld %xmm1, %xmm0
; SSE41-NEXT:    retq
;
; AVX1-LABEL: var_shift_v4i32:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpslld $23, %xmm1, %xmm1
; AVX1-NEXT:    vpaddd {{.*}}(%rip), %xmm1, %xmm1
; AVX1-NEXT:    vcvttps2dq %xmm1, %xmm1
; AVX1-NEXT:    vpmulld %xmm0, %xmm1, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: var_shift_v4i32:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpsllvd %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: var_shift_v4i32:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vpshld %xmm1, %xmm0, %xmm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: var_shift_v4i32:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vpsllvd %xmm1, %xmm0, %xmm0
; XOPAVX2-NEXT:    retq
;
; X32-SSE-LABEL: var_shift_v4i32:
; X32-SSE:       # BB#0:
; X32-SSE-NEXT:    pslld $23, %xmm1
; X32-SSE-NEXT:    paddd .LCPI1_0, %xmm1
; X32-SSE-NEXT:    cvttps2dq %xmm1, %xmm1
; X32-SSE-NEXT:    pshufd {{.*#+}} xmm2 = xmm1[1,1,3,3]
; X32-SSE-NEXT:    pmuludq %xmm0, %xmm1
; X32-SSE-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[0,2,2,3]
; X32-SSE-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,1,3,3]
; X32-SSE-NEXT:    pmuludq %xmm2, %xmm0
; X32-SSE-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; X32-SSE-NEXT:    punpckldq {{.*#+}} xmm1 = xmm1[0],xmm0[0],xmm1[1],xmm0[1]
; X32-SSE-NEXT:    movdqa %xmm1, %xmm0
; X32-SSE-NEXT:    retl
  %shift = shl <4 x i32> %a, %b
  ret <4 x i32> %shift
}

define <8 x i16> @var_shift_v8i16(<8 x i16> %a, <8 x i16> %b) nounwind {
; SSE2-LABEL: var_shift_v8i16:
; SSE2:       # BB#0:
; SSE2-NEXT:    psllw $12, %xmm1
; SSE2-NEXT:    movdqa %xmm1, %xmm2
; SSE2-NEXT:    psraw $15, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm3
; SSE2-NEXT:    pandn %xmm0, %xmm3
; SSE2-NEXT:    psllw $8, %xmm0
; SSE2-NEXT:    pand %xmm2, %xmm0
; SSE2-NEXT:    por %xmm3, %xmm0
; SSE2-NEXT:    paddw %xmm1, %xmm1
; SSE2-NEXT:    movdqa %xmm1, %xmm2
; SSE2-NEXT:    psraw $15, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm3
; SSE2-NEXT:    pandn %xmm0, %xmm3
; SSE2-NEXT:    psllw $4, %xmm0
; SSE2-NEXT:    pand %xmm2, %xmm0
; SSE2-NEXT:    por %xmm3, %xmm0
; SSE2-NEXT:    paddw %xmm1, %xmm1
; SSE2-NEXT:    movdqa %xmm1, %xmm2
; SSE2-NEXT:    psraw $15, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm3
; SSE2-NEXT:    pandn %xmm0, %xmm3
; SSE2-NEXT:    psllw $2, %xmm0
; SSE2-NEXT:    pand %xmm2, %xmm0
; SSE2-NEXT:    por %xmm3, %xmm0
; SSE2-NEXT:    paddw %xmm1, %xmm1
; SSE2-NEXT:    psraw $15, %xmm1
; SSE2-NEXT:    movdqa %xmm1, %xmm2
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    psllw $1, %xmm0
; SSE2-NEXT:    pand %xmm1, %xmm0
; SSE2-NEXT:    por %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: var_shift_v8i16:
; SSE41:       # BB#0:
; SSE41-NEXT:    movdqa %xmm0, %xmm2
; SSE41-NEXT:    movdqa %xmm1, %xmm0
; SSE41-NEXT:    psllw $12, %xmm0
; SSE41-NEXT:    psllw $4, %xmm1
; SSE41-NEXT:    por %xmm0, %xmm1
; SSE41-NEXT:    movdqa %xmm1, %xmm3
; SSE41-NEXT:    paddw %xmm3, %xmm3
; SSE41-NEXT:    movdqa %xmm2, %xmm4
; SSE41-NEXT:    psllw $8, %xmm4
; SSE41-NEXT:    movdqa %xmm1, %xmm0
; SSE41-NEXT:    pblendvb %xmm4, %xmm2
; SSE41-NEXT:    movdqa %xmm2, %xmm1
; SSE41-NEXT:    psllw $4, %xmm1
; SSE41-NEXT:    movdqa %xmm3, %xmm0
; SSE41-NEXT:    pblendvb %xmm1, %xmm2
; SSE41-NEXT:    movdqa %xmm2, %xmm1
; SSE41-NEXT:    psllw $2, %xmm1
; SSE41-NEXT:    paddw %xmm3, %xmm3
; SSE41-NEXT:    movdqa %xmm3, %xmm0
; SSE41-NEXT:    pblendvb %xmm1, %xmm2
; SSE41-NEXT:    movdqa %xmm2, %xmm1
; SSE41-NEXT:    psllw $1, %xmm1
; SSE41-NEXT:    paddw %xmm3, %xmm3
; SSE41-NEXT:    movdqa %xmm3, %xmm0
; SSE41-NEXT:    pblendvb %xmm1, %xmm2
; SSE41-NEXT:    movdqa %xmm2, %xmm0
; SSE41-NEXT:    retq
;
; AVX1-LABEL: var_shift_v8i16:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpsllw $12, %xmm1, %xmm2
; AVX1-NEXT:    vpsllw $4, %xmm1, %xmm1
; AVX1-NEXT:    vpor %xmm2, %xmm1, %xmm1
; AVX1-NEXT:    vpaddw %xmm1, %xmm1, %xmm2
; AVX1-NEXT:    vpsllw $8, %xmm0, %xmm3
; AVX1-NEXT:    vpblendvb %xmm1, %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vpsllw $4, %xmm0, %xmm1
; AVX1-NEXT:    vpblendvb %xmm2, %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpsllw $2, %xmm0, %xmm1
; AVX1-NEXT:    vpaddw %xmm2, %xmm2, %xmm2
; AVX1-NEXT:    vpblendvb %xmm2, %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpsllw $1, %xmm0, %xmm1
; AVX1-NEXT:    vpaddw %xmm2, %xmm2, %xmm2
; AVX1-NEXT:    vpblendvb %xmm2, %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: var_shift_v8i16:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpmovzxwd {{.*#+}} ymm1 = xmm1[0],zero,xmm1[1],zero,xmm1[2],zero,xmm1[3],zero,xmm1[4],zero,xmm1[5],zero,xmm1[6],zero,xmm1[7],zero
; AVX2-NEXT:    vpmovzxwd {{.*#+}} ymm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; AVX2-NEXT:    vpsllvd %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpshufb {{.*#+}} ymm0 = ymm0[0,1,4,5,8,9,12,13],zero,zero,zero,zero,zero,zero,zero,zero,ymm0[16,17,20,21,24,25,28,29],zero,zero,zero,zero,zero,zero,zero,zero
; AVX2-NEXT:    vpermq {{.*#+}} ymm0 = ymm0[0,2,2,3]
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; XOP-LABEL: var_shift_v8i16:
; XOP:       # BB#0:
; XOP-NEXT:    vpshlw %xmm1, %xmm0, %xmm0
; XOP-NEXT:    retq
;
; X32-SSE-LABEL: var_shift_v8i16:
; X32-SSE:       # BB#0:
; X32-SSE-NEXT:    psllw $12, %xmm1
; X32-SSE-NEXT:    movdqa %xmm1, %xmm2
; X32-SSE-NEXT:    psraw $15, %xmm2
; X32-SSE-NEXT:    movdqa %xmm2, %xmm3
; X32-SSE-NEXT:    pandn %xmm0, %xmm3
; X32-SSE-NEXT:    psllw $8, %xmm0
; X32-SSE-NEXT:    pand %xmm2, %xmm0
; X32-SSE-NEXT:    por %xmm3, %xmm0
; X32-SSE-NEXT:    paddw %xmm1, %xmm1
; X32-SSE-NEXT:    movdqa %xmm1, %xmm2
; X32-SSE-NEXT:    psraw $15, %xmm2
; X32-SSE-NEXT:    movdqa %xmm2, %xmm3
; X32-SSE-NEXT:    pandn %xmm0, %xmm3
; X32-SSE-NEXT:    psllw $4, %xmm0
; X32-SSE-NEXT:    pand %xmm2, %xmm0
; X32-SSE-NEXT:    por %xmm3, %xmm0
; X32-SSE-NEXT:    paddw %xmm1, %xmm1
; X32-SSE-NEXT:    movdqa %xmm1, %xmm2
; X32-SSE-NEXT:    psraw $15, %xmm2
; X32-SSE-NEXT:    movdqa %xmm2, %xmm3
; X32-SSE-NEXT:    pandn %xmm0, %xmm3
; X32-SSE-NEXT:    psllw $2, %xmm0
; X32-SSE-NEXT:    pand %xmm2, %xmm0
; X32-SSE-NEXT:    por %xmm3, %xmm0
; X32-SSE-NEXT:    paddw %xmm1, %xmm1
; X32-SSE-NEXT:    psraw $15, %xmm1
; X32-SSE-NEXT:    movdqa %xmm1, %xmm2
; X32-SSE-NEXT:    pandn %xmm0, %xmm2
; X32-SSE-NEXT:    psllw $1, %xmm0
; X32-SSE-NEXT:    pand %xmm1, %xmm0
; X32-SSE-NEXT:    por %xmm2, %xmm0
; X32-SSE-NEXT:    retl
  %shift = shl <8 x i16> %a, %b
  ret <8 x i16> %shift
}

define <16 x i8> @var_shift_v16i8(<16 x i8> %a, <16 x i8> %b) nounwind {
; SSE2-LABEL: var_shift_v16i8:
; SSE2:       # BB#0:
; SSE2-NEXT:    psllw $5, %xmm1
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    pxor %xmm3, %xmm3
; SSE2-NEXT:    pcmpgtb %xmm1, %xmm3
; SSE2-NEXT:    movdqa %xmm3, %xmm4
; SSE2-NEXT:    pandn %xmm0, %xmm4
; SSE2-NEXT:    psllw $4, %xmm0
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE2-NEXT:    pand %xmm3, %xmm0
; SSE2-NEXT:    por %xmm4, %xmm0
; SSE2-NEXT:    paddb %xmm1, %xmm1
; SSE2-NEXT:    pxor %xmm3, %xmm3
; SSE2-NEXT:    pcmpgtb %xmm1, %xmm3
; SSE2-NEXT:    movdqa %xmm3, %xmm4
; SSE2-NEXT:    pandn %xmm0, %xmm4
; SSE2-NEXT:    psllw $2, %xmm0
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE2-NEXT:    pand %xmm3, %xmm0
; SSE2-NEXT:    por %xmm4, %xmm0
; SSE2-NEXT:    paddb %xmm1, %xmm1
; SSE2-NEXT:    pcmpgtb %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm1
; SSE2-NEXT:    pandn %xmm0, %xmm1
; SSE2-NEXT:    paddb %xmm0, %xmm0
; SSE2-NEXT:    pand %xmm2, %xmm0
; SSE2-NEXT:    por %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: var_shift_v16i8:
; SSE41:       # BB#0:
; SSE41-NEXT:    movdqa %xmm0, %xmm2
; SSE41-NEXT:    psllw $5, %xmm1
; SSE41-NEXT:    movdqa %xmm2, %xmm3
; SSE41-NEXT:    psllw $4, %xmm3
; SSE41-NEXT:    pand {{.*}}(%rip), %xmm3
; SSE41-NEXT:    movdqa %xmm1, %xmm0
; SSE41-NEXT:    pblendvb %xmm3, %xmm2
; SSE41-NEXT:    movdqa %xmm2, %xmm3
; SSE41-NEXT:    psllw $2, %xmm3
; SSE41-NEXT:    pand {{.*}}(%rip), %xmm3
; SSE41-NEXT:    paddb %xmm1, %xmm1
; SSE41-NEXT:    movdqa %xmm1, %xmm0
; SSE41-NEXT:    pblendvb %xmm3, %xmm2
; SSE41-NEXT:    movdqa %xmm2, %xmm3
; SSE41-NEXT:    paddb %xmm3, %xmm3
; SSE41-NEXT:    paddb %xmm1, %xmm1
; SSE41-NEXT:    movdqa %xmm1, %xmm0
; SSE41-NEXT:    pblendvb %xmm3, %xmm2
; SSE41-NEXT:    movdqa %xmm2, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: var_shift_v16i8:
; AVX:       # BB#0:
; AVX-NEXT:    vpsllw $5, %xmm1, %xmm1
; AVX-NEXT:    vpsllw $4, %xmm0, %xmm2
; AVX-NEXT:    vpand {{.*}}(%rip), %xmm2, %xmm2
; AVX-NEXT:    vpblendvb %xmm1, %xmm2, %xmm0, %xmm0
; AVX-NEXT:    vpsllw $2, %xmm0, %xmm2
; AVX-NEXT:    vpand {{.*}}(%rip), %xmm2, %xmm2
; AVX-NEXT:    vpaddb %xmm1, %xmm1, %xmm1
; AVX-NEXT:    vpblendvb %xmm1, %xmm2, %xmm0, %xmm0
; AVX-NEXT:    vpaddb %xmm0, %xmm0, %xmm2
; AVX-NEXT:    vpaddb %xmm1, %xmm1, %xmm1
; AVX-NEXT:    vpblendvb %xmm1, %xmm2, %xmm0, %xmm0
; AVX-NEXT:    retq
;
; XOP-LABEL: var_shift_v16i8:
; XOP:       # BB#0:
; XOP-NEXT:    vpshlb %xmm1, %xmm0, %xmm0
; XOP-NEXT:    retq
;
; X32-SSE-LABEL: var_shift_v16i8:
; X32-SSE:       # BB#0:
; X32-SSE-NEXT:    psllw $5, %xmm1
; X32-SSE-NEXT:    pxor %xmm2, %xmm2
; X32-SSE-NEXT:    pxor %xmm3, %xmm3
; X32-SSE-NEXT:    pcmpgtb %xmm1, %xmm3
; X32-SSE-NEXT:    movdqa %xmm3, %xmm4
; X32-SSE-NEXT:    pandn %xmm0, %xmm4
; X32-SSE-NEXT:    psllw $4, %xmm0
; X32-SSE-NEXT:    pand .LCPI3_0, %xmm0
; X32-SSE-NEXT:    pand %xmm3, %xmm0
; X32-SSE-NEXT:    por %xmm4, %xmm0
; X32-SSE-NEXT:    paddb %xmm1, %xmm1
; X32-SSE-NEXT:    pxor %xmm3, %xmm3
; X32-SSE-NEXT:    pcmpgtb %xmm1, %xmm3
; X32-SSE-NEXT:    movdqa %xmm3, %xmm4
; X32-SSE-NEXT:    pandn %xmm0, %xmm4
; X32-SSE-NEXT:    psllw $2, %xmm0
; X32-SSE-NEXT:    pand .LCPI3_1, %xmm0
; X32-SSE-NEXT:    pand %xmm3, %xmm0
; X32-SSE-NEXT:    por %xmm4, %xmm0
; X32-SSE-NEXT:    paddb %xmm1, %xmm1
; X32-SSE-NEXT:    pcmpgtb %xmm1, %xmm2
; X32-SSE-NEXT:    movdqa %xmm2, %xmm1
; X32-SSE-NEXT:    pandn %xmm0, %xmm1
; X32-SSE-NEXT:    paddb %xmm0, %xmm0
; X32-SSE-NEXT:    pand %xmm2, %xmm0
; X32-SSE-NEXT:    por %xmm1, %xmm0
; X32-SSE-NEXT:    retl
  %shift = shl <16 x i8> %a, %b
  ret <16 x i8> %shift
}

;
; Uniform Variable Shifts
;

define <2 x i64> @splatvar_shift_v2i64(<2 x i64> %a, <2 x i64> %b) nounwind {
; SSE-LABEL: splatvar_shift_v2i64:
; SSE:       # BB#0:
; SSE-NEXT:    psllq %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: splatvar_shift_v2i64:
; AVX:       # BB#0:
; AVX-NEXT:    vpsllq %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
;
; XOP-LABEL: splatvar_shift_v2i64:
; XOP:       # BB#0:
; XOP-NEXT:    vpsllq %xmm1, %xmm0, %xmm0
; XOP-NEXT:    retq
;
; X32-SSE-LABEL: splatvar_shift_v2i64:
; X32-SSE:       # BB#0:
; X32-SSE-NEXT:    movq {{.*#+}} xmm1 = xmm1[0],zero
; X32-SSE-NEXT:    psllq %xmm1, %xmm0
; X32-SSE-NEXT:    retl
  %splat = shufflevector <2 x i64> %b, <2 x i64> undef, <2 x i32> zeroinitializer
  %shift = shl <2 x i64> %a, %splat
  ret <2 x i64> %shift
}

define <4 x i32> @splatvar_shift_v4i32(<4 x i32> %a, <4 x i32> %b) nounwind {
; SSE2-LABEL: splatvar_shift_v4i32:
; SSE2:       # BB#0:
; SSE2-NEXT:    xorps %xmm2, %xmm2
; SSE2-NEXT:    movss {{.*#+}} xmm2 = xmm1[0],xmm2[1,2,3]
; SSE2-NEXT:    pslld %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: splatvar_shift_v4i32:
; SSE41:       # BB#0:
; SSE41-NEXT:    pxor %xmm2, %xmm2
; SSE41-NEXT:    pblendw {{.*#+}} xmm2 = xmm1[0,1],xmm2[2,3,4,5,6,7]
; SSE41-NEXT:    pslld %xmm2, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: splatvar_shift_v4i32:
; AVX:       # BB#0:
; AVX-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; AVX-NEXT:    vpblendw {{.*#+}} xmm1 = xmm1[0,1],xmm2[2,3,4,5,6,7]
; AVX-NEXT:    vpslld %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
;
; XOP-LABEL: splatvar_shift_v4i32:
; XOP:       # BB#0:
; XOP-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; XOP-NEXT:    vpblendw {{.*#+}} xmm1 = xmm1[0,1],xmm2[2,3,4,5,6,7]
; XOP-NEXT:    vpslld %xmm1, %xmm0, %xmm0
; XOP-NEXT:    retq
;
; X32-SSE-LABEL: splatvar_shift_v4i32:
; X32-SSE:       # BB#0:
; X32-SSE-NEXT:    xorps %xmm2, %xmm2
; X32-SSE-NEXT:    movss {{.*#+}} xmm2 = xmm1[0],xmm2[1,2,3]
; X32-SSE-NEXT:    pslld %xmm2, %xmm0
; X32-SSE-NEXT:    retl
  %splat = shufflevector <4 x i32> %b, <4 x i32> undef, <4 x i32> zeroinitializer
  %shift = shl <4 x i32> %a, %splat
  ret <4 x i32> %shift
}

define <8 x i16> @splatvar_shift_v8i16(<8 x i16> %a, <8 x i16> %b) nounwind {
; SSE2-LABEL: splatvar_shift_v8i16:
; SSE2:       # BB#0:
; SSE2-NEXT:    movd %xmm1, %eax
; SSE2-NEXT:    movzwl %ax, %eax
; SSE2-NEXT:    movd %eax, %xmm1
; SSE2-NEXT:    psllw %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: splatvar_shift_v8i16:
; SSE41:       # BB#0:
; SSE41-NEXT:    pxor %xmm2, %xmm2
; SSE41-NEXT:    pblendw {{.*#+}} xmm2 = xmm1[0],xmm2[1,2,3,4,5,6,7]
; SSE41-NEXT:    psllw %xmm2, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: splatvar_shift_v8i16:
; AVX:       # BB#0:
; AVX-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; AVX-NEXT:    vpblendw {{.*#+}} xmm1 = xmm1[0],xmm2[1,2,3,4,5,6,7]
; AVX-NEXT:    vpsllw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
;
; XOP-LABEL: splatvar_shift_v8i16:
; XOP:       # BB#0:
; XOP-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; XOP-NEXT:    vpblendw {{.*#+}} xmm1 = xmm1[0],xmm2[1,2,3,4,5,6,7]
; XOP-NEXT:    vpsllw %xmm1, %xmm0, %xmm0
; XOP-NEXT:    retq
;
; X32-SSE-LABEL: splatvar_shift_v8i16:
; X32-SSE:       # BB#0:
; X32-SSE-NEXT:    movd %xmm1, %eax
; X32-SSE-NEXT:    movzwl %ax, %eax
; X32-SSE-NEXT:    movd %eax, %xmm1
; X32-SSE-NEXT:    psllw %xmm1, %xmm0
; X32-SSE-NEXT:    retl
  %splat = shufflevector <8 x i16> %b, <8 x i16> undef, <8 x i32> zeroinitializer
  %shift = shl <8 x i16> %a, %splat
  ret <8 x i16> %shift
}

define <16 x i8> @splatvar_shift_v16i8(<16 x i8> %a, <16 x i8> %b) nounwind {
; SSE2-LABEL: splatvar_shift_v16i8:
; SSE2:       # BB#0:
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm1 = xmm1[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[0,1,0,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm1 = xmm1[0,0,0,0,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm2 = xmm1[0,1,2,3,4,4,4,4]
; SSE2-NEXT:    psllw $5, %xmm2
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    pxor %xmm3, %xmm3
; SSE2-NEXT:    pcmpgtb %xmm2, %xmm3
; SSE2-NEXT:    movdqa %xmm3, %xmm4
; SSE2-NEXT:    pandn %xmm0, %xmm4
; SSE2-NEXT:    psllw $4, %xmm0
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE2-NEXT:    pand %xmm3, %xmm0
; SSE2-NEXT:    por %xmm4, %xmm0
; SSE2-NEXT:    paddb %xmm2, %xmm2
; SSE2-NEXT:    pxor %xmm3, %xmm3
; SSE2-NEXT:    pcmpgtb %xmm2, %xmm3
; SSE2-NEXT:    movdqa %xmm3, %xmm4
; SSE2-NEXT:    pandn %xmm0, %xmm4
; SSE2-NEXT:    psllw $2, %xmm0
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE2-NEXT:    pand %xmm3, %xmm0
; SSE2-NEXT:    por %xmm4, %xmm0
; SSE2-NEXT:    paddb %xmm2, %xmm2
; SSE2-NEXT:    pcmpgtb %xmm2, %xmm1
; SSE2-NEXT:    movdqa %xmm1, %xmm2
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    paddb %xmm0, %xmm0
; SSE2-NEXT:    pand %xmm1, %xmm0
; SSE2-NEXT:    por %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: splatvar_shift_v16i8:
; SSE41:       # BB#0:
; SSE41-NEXT:    movdqa %xmm0, %xmm2
; SSE41-NEXT:    pxor %xmm0, %xmm0
; SSE41-NEXT:    pshufb %xmm0, %xmm1
; SSE41-NEXT:    psllw $5, %xmm1
; SSE41-NEXT:    movdqa %xmm1, %xmm3
; SSE41-NEXT:    paddb %xmm3, %xmm3
; SSE41-NEXT:    movdqa %xmm2, %xmm4
; SSE41-NEXT:    psllw $4, %xmm4
; SSE41-NEXT:    pand {{.*}}(%rip), %xmm4
; SSE41-NEXT:    movdqa %xmm1, %xmm0
; SSE41-NEXT:    pblendvb %xmm4, %xmm2
; SSE41-NEXT:    movdqa %xmm2, %xmm1
; SSE41-NEXT:    psllw $2, %xmm1
; SSE41-NEXT:    pand {{.*}}(%rip), %xmm1
; SSE41-NEXT:    movdqa %xmm3, %xmm0
; SSE41-NEXT:    pblendvb %xmm1, %xmm2
; SSE41-NEXT:    movdqa %xmm2, %xmm1
; SSE41-NEXT:    paddb %xmm1, %xmm1
; SSE41-NEXT:    paddb %xmm3, %xmm3
; SSE41-NEXT:    movdqa %xmm3, %xmm0
; SSE41-NEXT:    pblendvb %xmm1, %xmm2
; SSE41-NEXT:    movdqa %xmm2, %xmm0
; SSE41-NEXT:    retq
;
; AVX1-LABEL: splatvar_shift_v16i8:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; AVX1-NEXT:    vpshufb %xmm2, %xmm1, %xmm1
; AVX1-NEXT:    vpsllw $5, %xmm1, %xmm1
; AVX1-NEXT:    vpaddb %xmm1, %xmm1, %xmm2
; AVX1-NEXT:    vpsllw $4, %xmm0, %xmm3
; AVX1-NEXT:    vpand {{.*}}(%rip), %xmm3, %xmm3
; AVX1-NEXT:    vpblendvb %xmm1, %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vpsllw $2, %xmm0, %xmm1
; AVX1-NEXT:    vpand {{.*}}(%rip), %xmm1, %xmm1
; AVX1-NEXT:    vpblendvb %xmm2, %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpaddb %xmm0, %xmm0, %xmm1
; AVX1-NEXT:    vpaddb %xmm2, %xmm2, %xmm2
; AVX1-NEXT:    vpblendvb %xmm2, %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: splatvar_shift_v16i8:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpbroadcastb %xmm1, %xmm1
; AVX2-NEXT:    vpsllw $5, %xmm1, %xmm1
; AVX2-NEXT:    vpsllw $4, %xmm0, %xmm2
; AVX2-NEXT:    vpand {{.*}}(%rip), %xmm2, %xmm2
; AVX2-NEXT:    vpblendvb %xmm1, %xmm2, %xmm0, %xmm0
; AVX2-NEXT:    vpsllw $2, %xmm0, %xmm2
; AVX2-NEXT:    vpand {{.*}}(%rip), %xmm2, %xmm2
; AVX2-NEXT:    vpaddb %xmm1, %xmm1, %xmm1
; AVX2-NEXT:    vpblendvb %xmm1, %xmm2, %xmm0, %xmm0
; AVX2-NEXT:    vpaddb %xmm0, %xmm0, %xmm2
; AVX2-NEXT:    vpaddb %xmm1, %xmm1, %xmm1
; AVX2-NEXT:    vpblendvb %xmm1, %xmm2, %xmm0, %xmm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: splatvar_shift_v16i8:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; XOPAVX1-NEXT:    vpshufb %xmm2, %xmm1, %xmm1
; XOPAVX1-NEXT:    vpshlb %xmm1, %xmm0, %xmm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: splatvar_shift_v16i8:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vpbroadcastb %xmm1, %xmm1
; XOPAVX2-NEXT:    vpshlb %xmm1, %xmm0, %xmm0
; XOPAVX2-NEXT:    retq
;
; X32-SSE-LABEL: splatvar_shift_v16i8:
; X32-SSE:       # BB#0:
; X32-SSE-NEXT:    punpcklbw {{.*#+}} xmm1 = xmm1[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; X32-SSE-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[0,1,0,3]
; X32-SSE-NEXT:    pshuflw {{.*#+}} xmm1 = xmm1[0,0,0,0,4,5,6,7]
; X32-SSE-NEXT:    pshufhw {{.*#+}} xmm2 = xmm1[0,1,2,3,4,4,4,4]
; X32-SSE-NEXT:    psllw $5, %xmm2
; X32-SSE-NEXT:    pxor %xmm1, %xmm1
; X32-SSE-NEXT:    pxor %xmm3, %xmm3
; X32-SSE-NEXT:    pcmpgtb %xmm2, %xmm3
; X32-SSE-NEXT:    movdqa %xmm3, %xmm4
; X32-SSE-NEXT:    pandn %xmm0, %xmm4
; X32-SSE-NEXT:    psllw $4, %xmm0
; X32-SSE-NEXT:    pand .LCPI7_0, %xmm0
; X32-SSE-NEXT:    pand %xmm3, %xmm0
; X32-SSE-NEXT:    por %xmm4, %xmm0
; X32-SSE-NEXT:    paddb %xmm2, %xmm2
; X32-SSE-NEXT:    pxor %xmm3, %xmm3
; X32-SSE-NEXT:    pcmpgtb %xmm2, %xmm3
; X32-SSE-NEXT:    movdqa %xmm3, %xmm4
; X32-SSE-NEXT:    pandn %xmm0, %xmm4
; X32-SSE-NEXT:    psllw $2, %xmm0
; X32-SSE-NEXT:    pand .LCPI7_1, %xmm0
; X32-SSE-NEXT:    pand %xmm3, %xmm0
; X32-SSE-NEXT:    por %xmm4, %xmm0
; X32-SSE-NEXT:    paddb %xmm2, %xmm2
; X32-SSE-NEXT:    pcmpgtb %xmm2, %xmm1
; X32-SSE-NEXT:    movdqa %xmm1, %xmm2
; X32-SSE-NEXT:    pandn %xmm0, %xmm2
; X32-SSE-NEXT:    paddb %xmm0, %xmm0
; X32-SSE-NEXT:    pand %xmm1, %xmm0
; X32-SSE-NEXT:    por %xmm2, %xmm0
; X32-SSE-NEXT:    retl
  %splat = shufflevector <16 x i8> %b, <16 x i8> undef, <16 x i32> zeroinitializer
  %shift = shl <16 x i8> %a, %splat
  ret <16 x i8> %shift
}

;
; Constant Shifts
;

define <2 x i64> @constant_shift_v2i64(<2 x i64> %a) nounwind {
; SSE2-LABEL: constant_shift_v2i64:
; SSE2:       # BB#0:
; SSE2-NEXT:    movdqa %xmm0, %xmm1
; SSE2-NEXT:    psllq $7, %xmm1
; SSE2-NEXT:    psllq $1, %xmm0
; SSE2-NEXT:    movsd {{.*#+}} xmm1 = xmm0[0],xmm1[1]
; SSE2-NEXT:    movapd %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: constant_shift_v2i64:
; SSE41:       # BB#0:
; SSE41-NEXT:    movdqa %xmm0, %xmm1
; SSE41-NEXT:    psllq $7, %xmm1
; SSE41-NEXT:    psllq $1, %xmm0
; SSE41-NEXT:    pblendw {{.*#+}} xmm0 = xmm0[0,1,2,3],xmm1[4,5,6,7]
; SSE41-NEXT:    retq
;
; AVX1-LABEL: constant_shift_v2i64:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpsllq $7, %xmm0, %xmm1
; AVX1-NEXT:    vpsllq $1, %xmm0, %xmm0
; AVX1-NEXT:    vpblendw {{.*#+}} xmm0 = xmm0[0,1,2,3],xmm1[4,5,6,7]
; AVX1-NEXT:    retq
;
; AVX2-LABEL: constant_shift_v2i64:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpsllvq {{.*}}(%rip), %xmm0, %xmm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: constant_shift_v2i64:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vpshlq {{.*}}(%rip), %xmm0, %xmm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: constant_shift_v2i64:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vpsllvq {{.*}}(%rip), %xmm0, %xmm0
; XOPAVX2-NEXT:    retq
;
; X32-SSE-LABEL: constant_shift_v2i64:
; X32-SSE:       # BB#0:
; X32-SSE-NEXT:    movdqa %xmm0, %xmm1
; X32-SSE-NEXT:    psllq $7, %xmm1
; X32-SSE-NEXT:    psllq $1, %xmm0
; X32-SSE-NEXT:    movsd {{.*#+}} xmm1 = xmm0[0],xmm1[1]
; X32-SSE-NEXT:    movapd %xmm1, %xmm0
; X32-SSE-NEXT:    retl
  %shift = shl <2 x i64> %a, <i64 1, i64 7>
  ret <2 x i64> %shift
}

define <4 x i32> @constant_shift_v4i32(<4 x i32> %a) nounwind {
; SSE2-LABEL: constant_shift_v4i32:
; SSE2:       # BB#0:
; SSE2-NEXT:    movdqa {{.*#+}} xmm1 = [16,32,64,128]
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm0[1,1,3,3]
; SSE2-NEXT:    pmuludq %xmm1, %xmm0
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[1,1,3,3]
; SSE2-NEXT:    pmuludq %xmm2, %xmm1
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[0,2,2,3]
; SSE2-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; SSE2-NEXT:    retq
;
; SSE41-LABEL: constant_shift_v4i32:
; SSE41:       # BB#0:
; SSE41-NEXT:    pmulld {{.*}}(%rip), %xmm0
; SSE41-NEXT:    retq
;
; AVX1-LABEL: constant_shift_v4i32:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpmulld {{.*}}(%rip), %xmm0, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: constant_shift_v4i32:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpsllvd {{.*}}(%rip), %xmm0, %xmm0
; AVX2-NEXT:    retq
;
; XOPAVX1-LABEL: constant_shift_v4i32:
; XOPAVX1:       # BB#0:
; XOPAVX1-NEXT:    vpshld {{.*}}(%rip), %xmm0, %xmm0
; XOPAVX1-NEXT:    retq
;
; XOPAVX2-LABEL: constant_shift_v4i32:
; XOPAVX2:       # BB#0:
; XOPAVX2-NEXT:    vpsllvd {{.*}}(%rip), %xmm0, %xmm0
; XOPAVX2-NEXT:    retq
;
; X32-SSE-LABEL: constant_shift_v4i32:
; X32-SSE:       # BB#0:
; X32-SSE-NEXT:    movdqa {{.*#+}} xmm1 = [16,32,64,128]
; X32-SSE-NEXT:    pshufd {{.*#+}} xmm2 = xmm0[1,1,3,3]
; X32-SSE-NEXT:    pmuludq %xmm1, %xmm0
; X32-SSE-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; X32-SSE-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[1,1,3,3]
; X32-SSE-NEXT:    pmuludq %xmm2, %xmm1
; X32-SSE-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[0,2,2,3]
; X32-SSE-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; X32-SSE-NEXT:    retl
  %shift = shl <4 x i32> %a, <i32 4, i32 5, i32 6, i32 7>
  ret <4 x i32> %shift
}

define <8 x i16> @constant_shift_v8i16(<8 x i16> %a) nounwind {
; SSE-LABEL: constant_shift_v8i16:
; SSE:       # BB#0:
; SSE-NEXT:    pmullw {{.*}}(%rip), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: constant_shift_v8i16:
; AVX:       # BB#0:
; AVX-NEXT:    vpmullw {{.*}}(%rip), %xmm0, %xmm0
; AVX-NEXT:    retq
;
; XOP-LABEL: constant_shift_v8i16:
; XOP:       # BB#0:
; XOP-NEXT:    vpshlw {{.*}}(%rip), %xmm0, %xmm0
; XOP-NEXT:    retq
;
; X32-SSE-LABEL: constant_shift_v8i16:
; X32-SSE:       # BB#0:
; X32-SSE-NEXT:    pmullw .LCPI10_0, %xmm0
; X32-SSE-NEXT:    retl
  %shift = shl <8 x i16> %a, <i16 0, i16 1, i16 2, i16 3, i16 4, i16 5, i16 6, i16 7>
  ret <8 x i16> %shift
}

define <16 x i8> @constant_shift_v16i8(<16 x i8> %a) nounwind {
; SSE2-LABEL: constant_shift_v16i8:
; SSE2:       # BB#0:
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [0,1,2,3,4,5,6,7,7,6,5,4,3,2,1,0]
; SSE2-NEXT:    psllw $5, %xmm2
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    pxor %xmm3, %xmm3
; SSE2-NEXT:    pcmpgtb %xmm2, %xmm3
; SSE2-NEXT:    movdqa %xmm3, %xmm4
; SSE2-NEXT:    pandn %xmm0, %xmm4
; SSE2-NEXT:    psllw $4, %xmm0
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE2-NEXT:    pand %xmm3, %xmm0
; SSE2-NEXT:    por %xmm4, %xmm0
; SSE2-NEXT:    paddb %xmm2, %xmm2
; SSE2-NEXT:    pxor %xmm3, %xmm3
; SSE2-NEXT:    pcmpgtb %xmm2, %xmm3
; SSE2-NEXT:    movdqa %xmm3, %xmm4
; SSE2-NEXT:    pandn %xmm0, %xmm4
; SSE2-NEXT:    psllw $2, %xmm0
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE2-NEXT:    pand %xmm3, %xmm0
; SSE2-NEXT:    por %xmm4, %xmm0
; SSE2-NEXT:    paddb %xmm2, %xmm2
; SSE2-NEXT:    pcmpgtb %xmm2, %xmm1
; SSE2-NEXT:    movdqa %xmm1, %xmm2
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    paddb %xmm0, %xmm0
; SSE2-NEXT:    pand %xmm1, %xmm0
; SSE2-NEXT:    por %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: constant_shift_v16i8:
; SSE41:       # BB#0:
; SSE41-NEXT:    movdqa %xmm0, %xmm1
; SSE41-NEXT:    movdqa {{.*#+}} xmm0 = [0,1,2,3,4,5,6,7,7,6,5,4,3,2,1,0]
; SSE41-NEXT:    psllw $5, %xmm0
; SSE41-NEXT:    movdqa %xmm1, %xmm2
; SSE41-NEXT:    psllw $4, %xmm2
; SSE41-NEXT:    pand {{.*}}(%rip), %xmm2
; SSE41-NEXT:    pblendvb %xmm2, %xmm1
; SSE41-NEXT:    movdqa %xmm1, %xmm2
; SSE41-NEXT:    psllw $2, %xmm2
; SSE41-NEXT:    pand {{.*}}(%rip), %xmm2
; SSE41-NEXT:    paddb %xmm0, %xmm0
; SSE41-NEXT:    pblendvb %xmm2, %xmm1
; SSE41-NEXT:    movdqa %xmm1, %xmm2
; SSE41-NEXT:    paddb %xmm2, %xmm2
; SSE41-NEXT:    paddb %xmm0, %xmm0
; SSE41-NEXT:    pblendvb %xmm2, %xmm1
; SSE41-NEXT:    movdqa %xmm1, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: constant_shift_v16i8:
; AVX:       # BB#0:
; AVX-NEXT:    vmovdqa {{.*#+}} xmm1 = [0,1,2,3,4,5,6,7,7,6,5,4,3,2,1,0]
; AVX-NEXT:    vpsllw $5, %xmm1, %xmm1
; AVX-NEXT:    vpsllw $4, %xmm0, %xmm2
; AVX-NEXT:    vpand {{.*}}(%rip), %xmm2, %xmm2
; AVX-NEXT:    vpblendvb %xmm1, %xmm2, %xmm0, %xmm0
; AVX-NEXT:    vpsllw $2, %xmm0, %xmm2
; AVX-NEXT:    vpand {{.*}}(%rip), %xmm2, %xmm2
; AVX-NEXT:    vpaddb %xmm1, %xmm1, %xmm1
; AVX-NEXT:    vpblendvb %xmm1, %xmm2, %xmm0, %xmm0
; AVX-NEXT:    vpaddb %xmm0, %xmm0, %xmm2
; AVX-NEXT:    vpaddb %xmm1, %xmm1, %xmm1
; AVX-NEXT:    vpblendvb %xmm1, %xmm2, %xmm0, %xmm0
; AVX-NEXT:    retq
;
; XOP-LABEL: constant_shift_v16i8:
; XOP:       # BB#0:
; XOP-NEXT:    vpshlb {{.*}}(%rip), %xmm0, %xmm0
; XOP-NEXT:    retq
;
; X32-SSE-LABEL: constant_shift_v16i8:
; X32-SSE:       # BB#0:
; X32-SSE-NEXT:    movdqa {{.*#+}} xmm2 = [0,1,2,3,4,5,6,7,7,6,5,4,3,2,1,0]
; X32-SSE-NEXT:    psllw $5, %xmm2
; X32-SSE-NEXT:    pxor %xmm1, %xmm1
; X32-SSE-NEXT:    pxor %xmm3, %xmm3
; X32-SSE-NEXT:    pcmpgtb %xmm2, %xmm3
; X32-SSE-NEXT:    movdqa %xmm3, %xmm4
; X32-SSE-NEXT:    pandn %xmm0, %xmm4
; X32-SSE-NEXT:    psllw $4, %xmm0
; X32-SSE-NEXT:    pand .LCPI11_1, %xmm0
; X32-SSE-NEXT:    pand %xmm3, %xmm0
; X32-SSE-NEXT:    por %xmm4, %xmm0
; X32-SSE-NEXT:    paddb %xmm2, %xmm2
; X32-SSE-NEXT:    pxor %xmm3, %xmm3
; X32-SSE-NEXT:    pcmpgtb %xmm2, %xmm3
; X32-SSE-NEXT:    movdqa %xmm3, %xmm4
; X32-SSE-NEXT:    pandn %xmm0, %xmm4
; X32-SSE-NEXT:    psllw $2, %xmm0
; X32-SSE-NEXT:    pand .LCPI11_2, %xmm0
; X32-SSE-NEXT:    pand %xmm3, %xmm0
; X32-SSE-NEXT:    por %xmm4, %xmm0
; X32-SSE-NEXT:    paddb %xmm2, %xmm2
; X32-SSE-NEXT:    pcmpgtb %xmm2, %xmm1
; X32-SSE-NEXT:    movdqa %xmm1, %xmm2
; X32-SSE-NEXT:    pandn %xmm0, %xmm2
; X32-SSE-NEXT:    paddb %xmm0, %xmm0
; X32-SSE-NEXT:    pand %xmm1, %xmm0
; X32-SSE-NEXT:    por %xmm2, %xmm0
; X32-SSE-NEXT:    retl
  %shift = shl <16 x i8> %a, <i8 0, i8 1, i8 2, i8 3, i8 4, i8 5, i8 6, i8 7, i8 7, i8 6, i8 5, i8 4, i8 3, i8 2, i8 1, i8 0>
  ret <16 x i8> %shift
}

;
; Uniform Constant Shifts
;

define <2 x i64> @splatconstant_shift_v2i64(<2 x i64> %a) nounwind {
; SSE-LABEL: splatconstant_shift_v2i64:
; SSE:       # BB#0:
; SSE-NEXT:    psllq $7, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: splatconstant_shift_v2i64:
; AVX:       # BB#0:
; AVX-NEXT:    vpsllq $7, %xmm0, %xmm0
; AVX-NEXT:    retq
;
; XOP-LABEL: splatconstant_shift_v2i64:
; XOP:       # BB#0:
; XOP-NEXT:    vpsllq $7, %xmm0, %xmm0
; XOP-NEXT:    retq
;
; X32-SSE-LABEL: splatconstant_shift_v2i64:
; X32-SSE:       # BB#0:
; X32-SSE-NEXT:    psllq $7, %xmm0
; X32-SSE-NEXT:    retl
  %shift = shl <2 x i64> %a, <i64 7, i64 7>
  ret <2 x i64> %shift
}

define <4 x i32> @splatconstant_shift_v4i32(<4 x i32> %a) nounwind {
; SSE-LABEL: splatconstant_shift_v4i32:
; SSE:       # BB#0:
; SSE-NEXT:    pslld $5, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: splatconstant_shift_v4i32:
; AVX:       # BB#0:
; AVX-NEXT:    vpslld $5, %xmm0, %xmm0
; AVX-NEXT:    retq
;
; XOP-LABEL: splatconstant_shift_v4i32:
; XOP:       # BB#0:
; XOP-NEXT:    vpslld $5, %xmm0, %xmm0
; XOP-NEXT:    retq
;
; X32-SSE-LABEL: splatconstant_shift_v4i32:
; X32-SSE:       # BB#0:
; X32-SSE-NEXT:    pslld $5, %xmm0
; X32-SSE-NEXT:    retl
  %shift = shl <4 x i32> %a, <i32 5, i32 5, i32 5, i32 5>
  ret <4 x i32> %shift
}

define <8 x i16> @splatconstant_shift_v8i16(<8 x i16> %a) nounwind {
; SSE-LABEL: splatconstant_shift_v8i16:
; SSE:       # BB#0:
; SSE-NEXT:    psllw $3, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: splatconstant_shift_v8i16:
; AVX:       # BB#0:
; AVX-NEXT:    vpsllw $3, %xmm0, %xmm0
; AVX-NEXT:    retq
;
; XOP-LABEL: splatconstant_shift_v8i16:
; XOP:       # BB#0:
; XOP-NEXT:    vpsllw $3, %xmm0, %xmm0
; XOP-NEXT:    retq
;
; X32-SSE-LABEL: splatconstant_shift_v8i16:
; X32-SSE:       # BB#0:
; X32-SSE-NEXT:    psllw $3, %xmm0
; X32-SSE-NEXT:    retl
  %shift = shl <8 x i16> %a, <i16 3, i16 3, i16 3, i16 3, i16 3, i16 3, i16 3, i16 3>
  ret <8 x i16> %shift
}

define <16 x i8> @splatconstant_shift_v16i8(<16 x i8> %a) nounwind {
; SSE-LABEL: splatconstant_shift_v16i8:
; SSE:       # BB#0:
; SSE-NEXT:    psllw $3, %xmm0
; SSE-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: splatconstant_shift_v16i8:
; AVX:       # BB#0:
; AVX-NEXT:    vpsllw $3, %xmm0, %xmm0
; AVX-NEXT:    vpand {{.*}}(%rip), %xmm0, %xmm0
; AVX-NEXT:    retq
;
; XOP-LABEL: splatconstant_shift_v16i8:
; XOP:       # BB#0:
; XOP-NEXT:    vpshlb {{.*}}(%rip), %xmm0, %xmm0
; XOP-NEXT:    retq
;
; X32-SSE-LABEL: splatconstant_shift_v16i8:
; X32-SSE:       # BB#0:
; X32-SSE-NEXT:    psllw $3, %xmm0
; X32-SSE-NEXT:    pand .LCPI15_0, %xmm0
; X32-SSE-NEXT:    retl
  %shift = shl <16 x i8> %a, <i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3, i8 3>
  ret <16 x i8> %shift
}
