; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+SSE2 | FileCheck %s --check-prefixes=SSE2-SSSE3,SSE2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+SSSE3 | FileCheck %s --check-prefixes=SSE2-SSSE3,SSSE3
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx | FileCheck %s --check-prefixes=AVX12,AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx2 | FileCheck %s --check-prefixes=AVX12,AVX2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f,+avx512vl,+avx512bw | FileCheck %s --check-prefix=AVX512

define i4 @v4i64(<4 x i64> %a, <4 x i64> %b, <4 x i64> %c, <4 x i64> %d) {
; SSE2-SSSE3-LABEL: v4i64:
; SSE2-SSSE3:       # BB#0:
; SSE2-SSSE3-NEXT:    movdqa {{.*#+}} xmm8 = [2147483648,0,2147483648,0]
; SSE2-SSSE3-NEXT:    pxor %xmm8, %xmm3
; SSE2-SSSE3-NEXT:    pxor %xmm8, %xmm1
; SSE2-SSSE3-NEXT:    movdqa %xmm1, %xmm9
; SSE2-SSSE3-NEXT:    pcmpgtd %xmm3, %xmm9
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm10 = xmm9[0,0,2,2]
; SSE2-SSSE3-NEXT:    pcmpeqd %xmm3, %xmm1
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[1,1,3,3]
; SSE2-SSSE3-NEXT:    pand %xmm10, %xmm1
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm3 = xmm9[1,1,3,3]
; SSE2-SSSE3-NEXT:    por %xmm1, %xmm3
; SSE2-SSSE3-NEXT:    pxor %xmm8, %xmm2
; SSE2-SSSE3-NEXT:    pxor %xmm8, %xmm0
; SSE2-SSSE3-NEXT:    movdqa %xmm0, %xmm1
; SSE2-SSSE3-NEXT:    pcmpgtd %xmm2, %xmm1
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm9 = xmm1[0,0,2,2]
; SSE2-SSSE3-NEXT:    pcmpeqd %xmm2, %xmm0
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm2 = xmm0[1,1,3,3]
; SSE2-SSSE3-NEXT:    pand %xmm9, %xmm2
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm0 = xmm1[1,1,3,3]
; SSE2-SSSE3-NEXT:    por %xmm2, %xmm0
; SSE2-SSSE3-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,2],xmm3[0,2]
; SSE2-SSSE3-NEXT:    pxor %xmm8, %xmm7
; SSE2-SSSE3-NEXT:    pxor %xmm8, %xmm5
; SSE2-SSSE3-NEXT:    movdqa %xmm5, %xmm1
; SSE2-SSSE3-NEXT:    pcmpgtd %xmm7, %xmm1
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm2 = xmm1[0,0,2,2]
; SSE2-SSSE3-NEXT:    pcmpeqd %xmm7, %xmm5
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm3 = xmm5[1,1,3,3]
; SSE2-SSSE3-NEXT:    pand %xmm2, %xmm3
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[1,1,3,3]
; SSE2-SSSE3-NEXT:    por %xmm3, %xmm1
; SSE2-SSSE3-NEXT:    pxor %xmm8, %xmm6
; SSE2-SSSE3-NEXT:    pxor %xmm8, %xmm4
; SSE2-SSSE3-NEXT:    movdqa %xmm4, %xmm2
; SSE2-SSSE3-NEXT:    pcmpgtd %xmm6, %xmm2
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm3 = xmm2[0,0,2,2]
; SSE2-SSSE3-NEXT:    pcmpeqd %xmm6, %xmm4
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm4 = xmm4[1,1,3,3]
; SSE2-SSSE3-NEXT:    pand %xmm3, %xmm4
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm2 = xmm2[1,1,3,3]
; SSE2-SSSE3-NEXT:    por %xmm4, %xmm2
; SSE2-SSSE3-NEXT:    shufps {{.*#+}} xmm2 = xmm2[0,2],xmm1[0,2]
; SSE2-SSSE3-NEXT:    andps %xmm0, %xmm2
; SSE2-SSSE3-NEXT:    movmskps %xmm2, %eax
; SSE2-SSSE3-NEXT:    # kill: %AL<def> %AL<kill> %EAX<kill>
; SSE2-SSSE3-NEXT:    ret{{[l|q]}}
;
; AVX1-LABEL: v4i64:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpcmpgtq %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpcmpgtq %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpacksswb %xmm4, %xmm0, %xmm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm1
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vpcmpgtq %xmm1, %xmm4, %xmm1
; AVX1-NEXT:    vpcmpgtq %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpacksswb %xmm1, %xmm2, %xmm1
; AVX1-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vmovmskps %xmm0, %eax
; AVX1-NEXT:    # kill: %AL<def> %AL<kill> %EAX<kill>
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    ret{{[l|q]}}
;
; AVX2-LABEL: v4i64:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpcmpgtq %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX2-NEXT:    vpacksswb %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpcmpgtq %ymm3, %ymm2, %ymm1
; AVX2-NEXT:    vextracti128 $1, %ymm1, %xmm2
; AVX2-NEXT:    vpacksswb %xmm2, %xmm1, %xmm1
; AVX2-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vmovmskps %xmm0, %eax
; AVX2-NEXT:    # kill: %AL<def> %AL<kill> %EAX<kill>
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    ret{{[l|q]}}
;
; AVX512-LABEL: v4i64:
; AVX512:       # BB#0:
; AVX512-NEXT:    vpcmpgtq %ymm1, %ymm0, %k1
; AVX512-NEXT:    vpcmpgtq %ymm3, %ymm2, %k0 {%k1}
; AVX512-NEXT:    kmovd %k0, %eax
; AVX512-NEXT:    movb %al, -{{[0-9]+}}(%rsp)
; AVX512-NEXT:    movb -{{[0-9]+}}(%rsp), %al
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    ret{{[l|q]}}
  %x0 = icmp sgt <4 x i64> %a, %b
  %x1 = icmp sgt <4 x i64> %c, %d
  %y = and <4 x i1> %x0, %x1
  %res = bitcast <4 x i1> %y to i4
  ret i4 %res
}

define i4 @v4f64(<4 x double> %a, <4 x double> %b, <4 x double> %c, <4 x double> %d) {
; SSE2-SSSE3-LABEL: v4f64:
; SSE2-SSSE3:       # BB#0:
; SSE2-SSSE3-NEXT:    cmpltpd %xmm1, %xmm3
; SSE2-SSSE3-NEXT:    cmpltpd %xmm0, %xmm2
; SSE2-SSSE3-NEXT:    shufps {{.*#+}} xmm2 = xmm2[0,2],xmm3[0,2]
; SSE2-SSSE3-NEXT:    cmpltpd %xmm5, %xmm7
; SSE2-SSSE3-NEXT:    cmpltpd %xmm4, %xmm6
; SSE2-SSSE3-NEXT:    shufps {{.*#+}} xmm6 = xmm6[0,2],xmm7[0,2]
; SSE2-SSSE3-NEXT:    andps %xmm2, %xmm6
; SSE2-SSSE3-NEXT:    movmskps %xmm6, %eax
; SSE2-SSSE3-NEXT:    # kill: %AL<def> %AL<kill> %EAX<kill>
; SSE2-SSSE3-NEXT:    ret{{[l|q]}}
;
; AVX12-LABEL: v4f64:
; AVX12:       # BB#0:
; AVX12-NEXT:    vcmpltpd %ymm0, %ymm1, %ymm0
; AVX12-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX12-NEXT:    vpacksswb %xmm1, %xmm0, %xmm0
; AVX12-NEXT:    vcmpltpd %ymm2, %ymm3, %ymm1
; AVX12-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX12-NEXT:    vpacksswb %xmm2, %xmm1, %xmm1
; AVX12-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX12-NEXT:    vmovmskps %xmm0, %eax
; AVX12-NEXT:    # kill: %AL<def> %AL<kill> %EAX<kill>
; AVX12-NEXT:    vzeroupper
; AVX12-NEXT:    ret{{[l|q]}}
;
; AVX512-LABEL: v4f64:
; AVX512:       # BB#0:
; AVX512-NEXT:    vcmpltpd %ymm0, %ymm1, %k1
; AVX512-NEXT:    vcmpltpd %ymm2, %ymm3, %k0 {%k1}
; AVX512-NEXT:    kmovd %k0, %eax
; AVX512-NEXT:    movb %al, -{{[0-9]+}}(%rsp)
; AVX512-NEXT:    movb -{{[0-9]+}}(%rsp), %al
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    ret{{[l|q]}}
  %x0 = fcmp ogt <4 x double> %a, %b
  %x1 = fcmp ogt <4 x double> %c, %d
  %y = and <4 x i1> %x0, %x1
  %res = bitcast <4 x i1> %y to i4
  ret i4 %res
}

define i16 @v16i16(<16 x i16> %a, <16 x i16> %b, <16 x i16> %c, <16 x i16> %d) {
; SSE2-SSSE3-LABEL: v16i16:
; SSE2-SSSE3:       # BB#0:
; SSE2-SSSE3-NEXT:    pcmpgtw %xmm3, %xmm1
; SSE2-SSSE3-NEXT:    pcmpgtw %xmm2, %xmm0
; SSE2-SSSE3-NEXT:    packsswb %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    pcmpgtw %xmm7, %xmm5
; SSE2-SSSE3-NEXT:    pcmpgtw %xmm6, %xmm4
; SSE2-SSSE3-NEXT:    packsswb %xmm5, %xmm4
; SSE2-SSSE3-NEXT:    pand %xmm0, %xmm4
; SSE2-SSSE3-NEXT:    pmovmskb %xmm4, %eax
; SSE2-SSSE3-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; SSE2-SSSE3-NEXT:    ret{{[l|q]}}
;
; AVX1-LABEL: v16i16:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpcmpgtw %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpcmpgtw %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpacksswb %xmm4, %xmm0, %xmm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm1
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vpcmpgtw %xmm1, %xmm4, %xmm1
; AVX1-NEXT:    vpcmpgtw %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpacksswb %xmm1, %xmm2, %xmm1
; AVX1-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpmovmskb %xmm0, %eax
; AVX1-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    ret{{[l|q]}}
;
; AVX2-LABEL: v16i16:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpcmpgtw %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX2-NEXT:    vpacksswb %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpcmpgtw %ymm3, %ymm2, %ymm1
; AVX2-NEXT:    vextracti128 $1, %ymm1, %xmm2
; AVX2-NEXT:    vpacksswb %xmm2, %xmm1, %xmm1
; AVX2-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpmovmskb %xmm0, %eax
; AVX2-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    ret{{[l|q]}}
;
; AVX512-LABEL: v16i16:
; AVX512:       # BB#0:
; AVX512-NEXT:    vpcmpgtw %ymm1, %ymm0, %k1
; AVX512-NEXT:    vpcmpgtw %ymm3, %ymm2, %k0 {%k1}
; AVX512-NEXT:    kmovd %k0, %eax
; AVX512-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    ret{{[l|q]}}
  %x0 = icmp sgt <16 x i16> %a, %b
  %x1 = icmp sgt <16 x i16> %c, %d
  %y = and <16 x i1> %x0, %x1
  %res = bitcast <16 x i1> %y to i16
  ret i16 %res
}

define i8 @v8i32(<8 x i32> %a, <8 x i32> %b, <8 x i32> %c, <8 x i32> %d) {
; SSE2-SSSE3-LABEL: v8i32:
; SSE2-SSSE3:       # BB#0:
; SSE2-SSSE3-NEXT:    pcmpgtd %xmm3, %xmm1
; SSE2-SSSE3-NEXT:    pcmpgtd %xmm2, %xmm0
; SSE2-SSSE3-NEXT:    packssdw %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    pcmpgtd %xmm7, %xmm5
; SSE2-SSSE3-NEXT:    pcmpgtd %xmm6, %xmm4
; SSE2-SSSE3-NEXT:    packssdw %xmm5, %xmm4
; SSE2-SSSE3-NEXT:    pand %xmm0, %xmm4
; SSE2-SSSE3-NEXT:    packsswb %xmm0, %xmm4
; SSE2-SSSE3-NEXT:    pmovmskb %xmm4, %eax
; SSE2-SSSE3-NEXT:    # kill: %AL<def> %AL<kill> %EAX<kill>
; SSE2-SSSE3-NEXT:    ret{{[l|q]}}
;
; AVX1-LABEL: v8i32:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpcmpgtd %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpcmpgtd %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpacksswb %xmm4, %xmm0, %xmm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm1
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vpcmpgtd %xmm1, %xmm4, %xmm1
; AVX1-NEXT:    vpcmpgtd %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpacksswb %xmm1, %xmm2, %xmm1
; AVX1-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpacksswb %xmm0, %xmm0, %xmm0
; AVX1-NEXT:    vpmovmskb %xmm0, %eax
; AVX1-NEXT:    # kill: %AL<def> %AL<kill> %EAX<kill>
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    ret{{[l|q]}}
;
; AVX2-LABEL: v8i32:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpcmpgtd %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX2-NEXT:    vpacksswb %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpcmpgtd %ymm3, %ymm2, %ymm1
; AVX2-NEXT:    vextracti128 $1, %ymm1, %xmm2
; AVX2-NEXT:    vpacksswb %xmm2, %xmm1, %xmm1
; AVX2-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpacksswb %xmm0, %xmm0, %xmm0
; AVX2-NEXT:    vpmovmskb %xmm0, %eax
; AVX2-NEXT:    # kill: %AL<def> %AL<kill> %EAX<kill>
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    ret{{[l|q]}}
;
; AVX512-LABEL: v8i32:
; AVX512:       # BB#0:
; AVX512-NEXT:    vpcmpgtd %ymm1, %ymm0, %k1
; AVX512-NEXT:    vpcmpgtd %ymm3, %ymm2, %k0 {%k1}
; AVX512-NEXT:    kmovd %k0, %eax
; AVX512-NEXT:    # kill: %AL<def> %AL<kill> %EAX<kill>
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    ret{{[l|q]}}
  %x0 = icmp sgt <8 x i32> %a, %b
  %x1 = icmp sgt <8 x i32> %c, %d
  %y = and <8 x i1> %x0, %x1
  %res = bitcast <8 x i1> %y to i8
  ret i8 %res
}

define i8 @v8f32(<8 x float> %a, <8 x float> %b, <8 x float> %c, <8 x float> %d) {
; SSE2-LABEL: v8f32:
; SSE2:       # BB#0:
; SSE2-NEXT:    cmpltps %xmm1, %xmm3
; SSE2-NEXT:    pshuflw {{.*#+}} xmm1 = xmm3[0,2,2,3,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm1 = xmm1[0,1,2,3,4,6,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[0,2,2,3]
; SSE2-NEXT:    cmpltps %xmm0, %xmm2
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm2[0,2,2,3,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,4,6,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; SSE2-NEXT:    punpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; SSE2-NEXT:    cmpltps %xmm5, %xmm7
; SSE2-NEXT:    pshuflw {{.*#+}} xmm1 = xmm7[0,2,2,3,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm1 = xmm1[0,1,2,3,4,6,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[0,2,2,3]
; SSE2-NEXT:    cmpltps %xmm4, %xmm6
; SSE2-NEXT:    pshuflw {{.*#+}} xmm2 = xmm6[0,2,2,3,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm2 = xmm2[0,1,2,3,4,6,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm2[0,2,2,3]
; SSE2-NEXT:    punpcklqdq {{.*#+}} xmm2 = xmm2[0],xmm1[0]
; SSE2-NEXT:    pand %xmm0, %xmm2
; SSE2-NEXT:    packsswb %xmm0, %xmm2
; SSE2-NEXT:    pmovmskb %xmm2, %eax
; SSE2-NEXT:    # kill: %AL<def> %AL<kill> %EAX<kill>
; SSE2-NEXT:    ret{{[l|q]}}
;
; SSSE3-LABEL: v8f32:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    cmpltps %xmm1, %xmm3
; SSSE3-NEXT:    movdqa {{.*#+}} xmm1 = [0,1,4,5,8,9,12,13,8,9,12,13,12,13,14,15]
; SSSE3-NEXT:    pshufb %xmm1, %xmm3
; SSSE3-NEXT:    cmpltps %xmm0, %xmm2
; SSSE3-NEXT:    pshufb %xmm1, %xmm2
; SSSE3-NEXT:    punpcklqdq {{.*#+}} xmm2 = xmm2[0],xmm3[0]
; SSSE3-NEXT:    cmpltps %xmm5, %xmm7
; SSSE3-NEXT:    pshufb %xmm1, %xmm7
; SSSE3-NEXT:    cmpltps %xmm4, %xmm6
; SSSE3-NEXT:    pshufb %xmm1, %xmm6
; SSSE3-NEXT:    punpcklqdq {{.*#+}} xmm6 = xmm6[0],xmm7[0]
; SSSE3-NEXT:    pand %xmm2, %xmm6
; SSSE3-NEXT:    packsswb %xmm0, %xmm6
; SSSE3-NEXT:    pmovmskb %xmm6, %eax
; SSSE3-NEXT:    # kill: %AL<def> %AL<kill> %EAX<kill>
; SSSE3-NEXT:    ret{{[l|q]}}
;
; AVX12-LABEL: v8f32:
; AVX12:       # BB#0:
; AVX12-NEXT:    vcmpltps %ymm0, %ymm1, %ymm0
; AVX12-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX12-NEXT:    vpacksswb %xmm1, %xmm0, %xmm0
; AVX12-NEXT:    vcmpltps %ymm2, %ymm3, %ymm1
; AVX12-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX12-NEXT:    vpacksswb %xmm2, %xmm1, %xmm1
; AVX12-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX12-NEXT:    vpacksswb %xmm0, %xmm0, %xmm0
; AVX12-NEXT:    vpmovmskb %xmm0, %eax
; AVX12-NEXT:    # kill: %AL<def> %AL<kill> %EAX<kill>
; AVX12-NEXT:    vzeroupper
; AVX12-NEXT:    ret{{[l|q]}}
;
; AVX512-LABEL: v8f32:
; AVX512:       # BB#0:
; AVX512-NEXT:    vcmpltps %ymm0, %ymm1, %k1
; AVX512-NEXT:    vcmpltps %ymm2, %ymm3, %k0 {%k1}
; AVX512-NEXT:    kmovd %k0, %eax
; AVX512-NEXT:    # kill: %AL<def> %AL<kill> %EAX<kill>
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    ret{{[l|q]}}
  %x0 = fcmp ogt <8 x float> %a, %b
  %x1 = fcmp ogt <8 x float> %c, %d
  %y = and <8 x i1> %x0, %x1
  %res = bitcast <8 x i1> %y to i8
  ret i8 %res
}

define i32 @v32i8(<32 x i8> %a, <32 x i8> %b, <32 x i8> %c, <32 x i8> %d) {
; SSE2-SSSE3-LABEL: v32i8:
; SSE2-SSSE3:       # BB#0:
; SSE2-SSSE3-NEXT:    pcmpgtb %xmm2, %xmm0
; SSE2-SSSE3-NEXT:    pcmpgtb %xmm3, %xmm1
; SSE2-SSSE3-NEXT:    pcmpgtb %xmm6, %xmm4
; SSE2-SSSE3-NEXT:    pand %xmm0, %xmm4
; SSE2-SSSE3-NEXT:    pcmpgtb %xmm7, %xmm5
; SSE2-SSSE3-NEXT:    pand %xmm1, %xmm5
; SSE2-SSSE3-NEXT:    pmovmskb %xmm4, %ecx
; SSE2-SSSE3-NEXT:    pmovmskb %xmm5, %eax
; SSE2-SSSE3-NEXT:    shll $16, %eax
; SSE2-SSSE3-NEXT:    orl %ecx, %eax
; SSE2-SSSE3-NEXT:    ret{{[l|q]}}
;
; AVX1-LABEL: v32i8:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpcmpgtb %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpcmpgtb %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm1
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm5
; AVX1-NEXT:    vpcmpgtb %xmm1, %xmm5, %xmm1
; AVX1-NEXT:    vpand %xmm1, %xmm4, %xmm1
; AVX1-NEXT:    vpcmpgtb %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpand %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vpmovmskb %xmm0, %ecx
; AVX1-NEXT:    vpmovmskb %xmm1, %eax
; AVX1-NEXT:    shll $16, %eax
; AVX1-NEXT:    orl %ecx, %eax
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    ret{{[l|q]}}
;
; AVX2-LABEL: v32i8:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpcmpgtb %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpcmpgtb %ymm3, %ymm2, %ymm1
; AVX2-NEXT:    vpand %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpmovmskb %ymm0, %eax
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    ret{{[l|q]}}
;
; AVX512-LABEL: v32i8:
; AVX512:       # BB#0:
; AVX512-NEXT:    vpcmpgtb %ymm1, %ymm0, %k1
; AVX512-NEXT:    vpcmpgtb %ymm3, %ymm2, %k0 {%k1}
; AVX512-NEXT:    kmovd %k0, %eax
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    ret{{[l|q]}}
  %x0 = icmp sgt <32 x i8> %a, %b
  %x1 = icmp sgt <32 x i8> %c, %d
  %y = and <32 x i1> %x0, %x1
  %res = bitcast <32 x i1> %y to i32
  ret i32 %res
}
