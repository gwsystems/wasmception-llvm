; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-unknown -mattr=+sse2 | FileCheck %s --check-prefix=SSE --check-prefix=X86-SSE
; RUN: llc < %s -mtriple=i686-unknown-unknown -mattr=+avx  | FileCheck %s --check-prefix=AVX --check-prefix=AVX1 --check-prefix=X86-AVX --check-prefix=X86-AVX1
; RUN: llc < %s -mtriple=i686-unknown-unknown -mattr=+avx2 | FileCheck %s --check-prefix=AVX --check-prefix=AVX2 --check-prefix=X86-AVX --check-prefix=X86-AVX2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse2 | FileCheck %s --check-prefix=SSE --check-prefix=X64-SSE
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx  | FileCheck %s --check-prefix=AVX --check-prefix=AVX1 --check-prefix=X64-AVX --check-prefix=X64-AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx2 | FileCheck %s --check-prefix=AVX --check-prefix=AVX2 --check-prefix=X64-AVX --check-prefix=X64-AVX2

define <4 x i32> @trunc_ashr_v4i64(<4 x i64> %a) nounwind {
; SSE-LABEL: trunc_ashr_v4i64:
; SSE:       # %bb.0:
; SSE-NEXT:    psrad $31, %xmm1
; SSE-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[1,1,3,3]
; SSE-NEXT:    psrad $31, %xmm0
; SSE-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,1,3,3]
; SSE-NEXT:    packssdw %xmm1, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX1-LABEL: trunc_ashr_v4i64:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX1-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; AVX1-NEXT:    vpcmpgtq %xmm1, %xmm2, %xmm1
; AVX1-NEXT:    vpcmpgtq %xmm0, %xmm2, %xmm0
; AVX1-NEXT:    vpackssdw %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    ret{{[l|q]}}
;
; AVX2-LABEL: trunc_ashr_v4i64:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX2-NEXT:    vpcmpgtq %ymm0, %ymm1, %ymm0
; AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX2-NEXT:    vpackssdw %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    ret{{[l|q]}}
  %1 = ashr <4 x i64> %a, <i64 63, i64 63, i64 63, i64 63>
  %2 = trunc <4 x i64> %1 to <4 x i32>
  ret <4 x i32> %2
}

define <8 x i16> @trunc_ashr_v8i32(<8 x i32> %a) nounwind {
; SSE-LABEL: trunc_ashr_v8i32:
; SSE:       # %bb.0:
; SSE-NEXT:    psrad $31, %xmm1
; SSE-NEXT:    psrad $31, %xmm0
; SSE-NEXT:    packssdw %xmm1, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX1-LABEL: trunc_ashr_v8i32:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX1-NEXT:    vpsrad $31, %xmm1, %xmm1
; AVX1-NEXT:    vpsrad $31, %xmm0, %xmm0
; AVX1-NEXT:    vpackssdw %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    ret{{[l|q]}}
;
; AVX2-LABEL: trunc_ashr_v8i32:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpsrad $31, %ymm0, %ymm0
; AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX2-NEXT:    vpackssdw %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    ret{{[l|q]}}
  %1 = ashr <8 x i32> %a, <i32 31, i32 31, i32 31, i32 31, i32 31, i32 31, i32 31, i32 31>
  %2 = trunc <8 x i32> %1 to <8 x i16>
  ret <8 x i16> %2
}

define <8 x i16> @trunc_ashr_v4i32_icmp_v4i32(<4 x i32> %a, <4 x i32> %b) nounwind {
; X86-SSE-LABEL: trunc_ashr_v4i32_icmp_v4i32:
; X86-SSE:       # %bb.0:
; X86-SSE-NEXT:    psrad $31, %xmm0
; X86-SSE-NEXT:    pcmpgtd {{\.LCPI.*}}, %xmm1
; X86-SSE-NEXT:    packssdw %xmm1, %xmm0
; X86-SSE-NEXT:    retl
;
; X86-AVX-LABEL: trunc_ashr_v4i32_icmp_v4i32:
; X86-AVX:       # %bb.0:
; X86-AVX-NEXT:    vpsrad $31, %xmm0, %xmm0
; X86-AVX-NEXT:    vpcmpgtd {{\.LCPI.*}}, %xmm1, %xmm1
; X86-AVX-NEXT:    vpackssdw %xmm1, %xmm0, %xmm0
; X86-AVX-NEXT:    retl
;
; X64-SSE-LABEL: trunc_ashr_v4i32_icmp_v4i32:
; X64-SSE:       # %bb.0:
; X64-SSE-NEXT:    psrad $31, %xmm0
; X64-SSE-NEXT:    pcmpgtd {{.*}}(%rip), %xmm1
; X64-SSE-NEXT:    packssdw %xmm1, %xmm0
; X64-SSE-NEXT:    retq
;
; X64-AVX-LABEL: trunc_ashr_v4i32_icmp_v4i32:
; X64-AVX:       # %bb.0:
; X64-AVX-NEXT:    vpsrad $31, %xmm0, %xmm0
; X64-AVX-NEXT:    vpcmpgtd {{.*}}(%rip), %xmm1, %xmm1
; X64-AVX-NEXT:    vpackssdw %xmm1, %xmm0, %xmm0
; X64-AVX-NEXT:    retq
  %1 = ashr <4 x i32> %a, <i32 31, i32 31, i32 31, i32 31>
  %2 = icmp sgt <4 x i32> %b, <i32 1, i32 16, i32 255, i32 65535>
  %3 = sext <4 x i1> %2 to <4 x i32>
  %4 = shufflevector <4 x i32> %1, <4 x i32> %3, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %5 = trunc <8 x i32> %4 to <8 x i16>
  ret <8 x i16> %5
}

define <8 x i16> @trunc_ashr_v4i64_demandedelts(<4 x i64> %a0) {
; X86-SSE-LABEL: trunc_ashr_v4i64_demandedelts:
; X86-SSE:       # %bb.0:
; X86-SSE-NEXT:    movdqa %xmm0, %xmm2
; X86-SSE-NEXT:    psllq $63, %xmm2
; X86-SSE-NEXT:    movdqa %xmm0, %xmm3
; X86-SSE-NEXT:    movsd {{.*#+}} xmm3 = xmm2[0],xmm3[1]
; X86-SSE-NEXT:    movdqa %xmm1, %xmm2
; X86-SSE-NEXT:    psllq $63, %xmm2
; X86-SSE-NEXT:    movdqa %xmm1, %xmm4
; X86-SSE-NEXT:    movsd {{.*#+}} xmm4 = xmm2[0],xmm4[1]
; X86-SSE-NEXT:    psrlq $63, %xmm4
; X86-SSE-NEXT:    movsd {{.*#+}} xmm1 = xmm4[0],xmm1[1]
; X86-SSE-NEXT:    movapd {{.*#+}} xmm2 = [4.940656e-324,-0.000000e+00]
; X86-SSE-NEXT:    xorpd %xmm2, %xmm1
; X86-SSE-NEXT:    psubq %xmm2, %xmm1
; X86-SSE-NEXT:    psrlq $63, %xmm3
; X86-SSE-NEXT:    movsd {{.*#+}} xmm0 = xmm3[0],xmm0[1]
; X86-SSE-NEXT:    xorpd %xmm2, %xmm0
; X86-SSE-NEXT:    psubq %xmm2, %xmm0
; X86-SSE-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,0,0,0]
; X86-SSE-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[0,0,0,0]
; X86-SSE-NEXT:    pslld $16, %xmm1
; X86-SSE-NEXT:    psrad $16, %xmm1
; X86-SSE-NEXT:    pslld $16, %xmm0
; X86-SSE-NEXT:    psrad $16, %xmm0
; X86-SSE-NEXT:    packssdw %xmm1, %xmm0
; X86-SSE-NEXT:    retl
;
; X86-AVX1-LABEL: trunc_ashr_v4i64_demandedelts:
; X86-AVX1:       # %bb.0:
; X86-AVX1-NEXT:    movl $63, %eax
; X86-AVX1-NEXT:    vmovd %eax, %xmm1
; X86-AVX1-NEXT:    vpsllq %xmm1, %xmm0, %xmm2
; X86-AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; X86-AVX1-NEXT:    vpsllq %xmm1, %xmm0, %xmm0
; X86-AVX1-NEXT:    vmovdqa {{.*#+}} xmm3 = [0,2147483648,0,2147483648]
; X86-AVX1-NEXT:    vpsrlq %xmm1, %xmm3, %xmm3
; X86-AVX1-NEXT:    vpsrlq %xmm1, %xmm0, %xmm0
; X86-AVX1-NEXT:    vpxor %xmm3, %xmm0, %xmm0
; X86-AVX1-NEXT:    vpsubq %xmm3, %xmm0, %xmm0
; X86-AVX1-NEXT:    vpsrlq %xmm1, %xmm2, %xmm1
; X86-AVX1-NEXT:    vpxor %xmm3, %xmm1, %xmm1
; X86-AVX1-NEXT:    vpsubq %xmm3, %xmm1, %xmm1
; X86-AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; X86-AVX1-NEXT:    vpermilps {{.*#+}} ymm0 = ymm0[0,0,0,0,4,4,4,4]
; X86-AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; X86-AVX1-NEXT:    vmovdqa {{.*#+}} xmm2 = [0,1,4,5,8,9,12,13,8,9,12,13,12,13,14,15]
; X86-AVX1-NEXT:    vpshufb %xmm2, %xmm1, %xmm1
; X86-AVX1-NEXT:    vpshufb %xmm2, %xmm0, %xmm0
; X86-AVX1-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; X86-AVX1-NEXT:    vzeroupper
; X86-AVX1-NEXT:    retl
;
; X86-AVX2-LABEL: trunc_ashr_v4i64_demandedelts:
; X86-AVX2:       # %bb.0:
; X86-AVX2-NEXT:    vmovdqa {{.*#+}} ymm1 = [63,0,0,0,63,0,0,0]
; X86-AVX2-NEXT:    vpsllvq %ymm1, %ymm0, %ymm0
; X86-AVX2-NEXT:    vmovdqa {{.*#+}} ymm2 = [0,2147483648,0,2147483648,0,2147483648,0,2147483648]
; X86-AVX2-NEXT:    vpsrlvq %ymm1, %ymm2, %ymm3
; X86-AVX2-NEXT:    vpxor %ymm2, %ymm0, %ymm0
; X86-AVX2-NEXT:    vpsrlvq %ymm1, %ymm0, %ymm0
; X86-AVX2-NEXT:    vpsubq %ymm3, %ymm0, %ymm0
; X86-AVX2-NEXT:    vpshufb {{.*#+}} ymm0 = ymm0[0,1,0,1,0,1,0,1,0,1,0,1,0,1,2,3,16,17,16,17,16,17,16,17,16,17,16,17,16,17,18,19]
; X86-AVX2-NEXT:    vpermq {{.*#+}} ymm0 = ymm0[0,2,2,3]
; X86-AVX2-NEXT:    # kill: def $xmm0 killed $xmm0 killed $ymm0
; X86-AVX2-NEXT:    vzeroupper
; X86-AVX2-NEXT:    retl
;
; X64-SSE-LABEL: trunc_ashr_v4i64_demandedelts:
; X64-SSE:       # %bb.0:
; X64-SSE-NEXT:    movdqa %xmm0, %xmm2
; X64-SSE-NEXT:    psllq $63, %xmm2
; X64-SSE-NEXT:    movdqa %xmm0, %xmm3
; X64-SSE-NEXT:    movsd {{.*#+}} xmm3 = xmm2[0],xmm3[1]
; X64-SSE-NEXT:    movdqa %xmm1, %xmm2
; X64-SSE-NEXT:    psllq $63, %xmm2
; X64-SSE-NEXT:    movdqa %xmm1, %xmm4
; X64-SSE-NEXT:    movsd {{.*#+}} xmm4 = xmm2[0],xmm4[1]
; X64-SSE-NEXT:    psrlq $63, %xmm4
; X64-SSE-NEXT:    movsd {{.*#+}} xmm1 = xmm4[0],xmm1[1]
; X64-SSE-NEXT:    movapd {{.*#+}} xmm2 = [1,9223372036854775808]
; X64-SSE-NEXT:    xorpd %xmm2, %xmm1
; X64-SSE-NEXT:    psubq %xmm2, %xmm1
; X64-SSE-NEXT:    psrlq $63, %xmm3
; X64-SSE-NEXT:    movsd {{.*#+}} xmm0 = xmm3[0],xmm0[1]
; X64-SSE-NEXT:    xorpd %xmm2, %xmm0
; X64-SSE-NEXT:    psubq %xmm2, %xmm0
; X64-SSE-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,0,0,0]
; X64-SSE-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[0,0,0,0]
; X64-SSE-NEXT:    pslld $16, %xmm1
; X64-SSE-NEXT:    psrad $16, %xmm1
; X64-SSE-NEXT:    pslld $16, %xmm0
; X64-SSE-NEXT:    psrad $16, %xmm0
; X64-SSE-NEXT:    packssdw %xmm1, %xmm0
; X64-SSE-NEXT:    retq
;
; X64-AVX1-LABEL: trunc_ashr_v4i64_demandedelts:
; X64-AVX1:       # %bb.0:
; X64-AVX1-NEXT:    vpsllq $63, %xmm0, %xmm1
; X64-AVX1-NEXT:    vpblendw {{.*#+}} xmm1 = xmm1[0,1,2,3],xmm0[4,5,6,7]
; X64-AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; X64-AVX1-NEXT:    vpsllq $63, %xmm2, %xmm3
; X64-AVX1-NEXT:    vpblendw {{.*#+}} xmm3 = xmm3[0,1,2,3],xmm2[4,5,6,7]
; X64-AVX1-NEXT:    vpsrlq $63, %xmm3, %xmm3
; X64-AVX1-NEXT:    vpblendw {{.*#+}} xmm2 = xmm3[0,1,2,3],xmm2[4,5,6,7]
; X64-AVX1-NEXT:    vmovdqa {{.*#+}} xmm3 = [1,9223372036854775808]
; X64-AVX1-NEXT:    vpxor %xmm3, %xmm2, %xmm2
; X64-AVX1-NEXT:    vpsubq %xmm3, %xmm2, %xmm2
; X64-AVX1-NEXT:    vpsrlq $63, %xmm1, %xmm1
; X64-AVX1-NEXT:    vpblendw {{.*#+}} xmm0 = xmm1[0,1,2,3],xmm0[4,5,6,7]
; X64-AVX1-NEXT:    vpxor %xmm3, %xmm0, %xmm0
; X64-AVX1-NEXT:    vpsubq %xmm3, %xmm0, %xmm0
; X64-AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; X64-AVX1-NEXT:    vpermilps {{.*#+}} ymm0 = ymm0[0,0,0,0,4,4,4,4]
; X64-AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; X64-AVX1-NEXT:    vmovdqa {{.*#+}} xmm2 = [0,1,4,5,8,9,12,13,8,9,12,13,12,13,14,15]
; X64-AVX1-NEXT:    vpshufb %xmm2, %xmm1, %xmm1
; X64-AVX1-NEXT:    vpshufb %xmm2, %xmm0, %xmm0
; X64-AVX1-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; X64-AVX1-NEXT:    vzeroupper
; X64-AVX1-NEXT:    retq
;
; X64-AVX2-LABEL: trunc_ashr_v4i64_demandedelts:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    vpand {{.*}}(%rip), %ymm0, %ymm0
; X64-AVX2-NEXT:    vbroadcasti128 {{.*#+}} ymm1 = [1,9223372036854775808,1,9223372036854775808]
; X64-AVX2-NEXT:    # ymm1 = mem[0,1,0,1]
; X64-AVX2-NEXT:    vpxor %ymm1, %ymm0, %ymm0
; X64-AVX2-NEXT:    vpsubq %ymm1, %ymm0, %ymm0
; X64-AVX2-NEXT:    vpshufb {{.*#+}} ymm0 = ymm0[0,1,0,1,0,1,0,1,0,1,0,1,0,1,2,3,16,17,16,17,16,17,16,17,16,17,16,17,16,17,18,19]
; X64-AVX2-NEXT:    vpermq {{.*#+}} ymm0 = ymm0[0,2,2,3]
; X64-AVX2-NEXT:    # kill: def $xmm0 killed $xmm0 killed $ymm0
; X64-AVX2-NEXT:    vzeroupper
; X64-AVX2-NEXT:    retq
  %1 = shl <4 x i64> %a0, <i64 63, i64 0, i64 63, i64 0>
  %2 = ashr exact <4 x i64> %1, <i64 63, i64 0, i64 63, i64 0>
  %3 = bitcast <4 x i64> %2 to <8 x i32>
  %4 = shufflevector <8 x i32> %3, <8 x i32> undef, <8 x i32> <i32 0, i32 0, i32 0, i32 0, i32 4, i32 4, i32 4, i32 4>
  %5 = trunc <8 x i32> %4 to <8 x i16>
  ret <8 x i16> %5
}
