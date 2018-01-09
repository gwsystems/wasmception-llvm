; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+sse4.2 | FileCheck %s --check-prefix=SSE
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+avx | FileCheck %s --check-prefix=AVX --check-prefix=AVX1
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+avx2 | FileCheck %s --check-prefix=AVX --check-prefix=AVX2
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+avx512f,+avx512bw,+avx512vl | FileCheck %s --check-prefix=AVX512

define i64 @test_v2f64_sext(<2 x double> %a0, <2 x double> %a1) {
; SSE-LABEL: test_v2f64_sext:
; SSE:       # %bb.0:
; SSE-NEXT:    cmpltpd %xmm0, %xmm1
; SSE-NEXT:    pshufd {{.*#+}} xmm0 = xmm1[2,3,0,1]
; SSE-NEXT:    pand %xmm1, %xmm0
; SSE-NEXT:    movq %xmm0, %rax
; SSE-NEXT:    retq
;
; AVX-LABEL: test_v2f64_sext:
; AVX:       # %bb.0:
; AVX-NEXT:    vcmpltpd %xmm0, %xmm1, %xmm0
; AVX-NEXT:    vpermilpd {{.*#+}} xmm1 = xmm0[1,0]
; AVX-NEXT:    vandpd %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vmovq %xmm0, %rax
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_v2f64_sext:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vcmpltpd %xmm0, %xmm1, %xmm0
; AVX512-NEXT:    vpermilps {{.*#+}} xmm1 = xmm0[2,3,0,1]
; AVX512-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vmovq %xmm0, %rax
; AVX512-NEXT:    retq
  %c = fcmp ogt <2 x double> %a0, %a1
  %s = sext <2 x i1> %c to <2 x i64>
  %1 = shufflevector <2 x i64> %s, <2 x i64> undef, <2 x i32> <i32 1, i32 undef>
  %2 = and <2 x i64> %s, %1
  %3 = extractelement <2 x i64> %2, i32 0
  ret i64 %3
}

define i64 @test_v4f64_sext(<4 x double> %a0, <4 x double> %a1) {
; SSE-LABEL: test_v4f64_sext:
; SSE:       # %bb.0:
; SSE-NEXT:    cmpltpd %xmm1, %xmm3
; SSE-NEXT:    cmpltpd %xmm0, %xmm2
; SSE-NEXT:    andpd %xmm3, %xmm2
; SSE-NEXT:    pshufd {{.*#+}} xmm0 = xmm2[2,3,0,1]
; SSE-NEXT:    pand %xmm2, %xmm0
; SSE-NEXT:    movq %xmm0, %rax
; SSE-NEXT:    retq
;
; AVX-LABEL: test_v4f64_sext:
; AVX:       # %bb.0:
; AVX-NEXT:    vcmpltpd %ymm0, %ymm1, %ymm0
; AVX-NEXT:    vmovmskpd %ymm0, %eax
; AVX-NEXT:    xorl %ecx, %ecx
; AVX-NEXT:    cmpl $15, %eax
; AVX-NEXT:    movq $-1, %rax
; AVX-NEXT:    cmovneq %rcx, %rax
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_v4f64_sext:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vcmpltpd %ymm0, %ymm1, %ymm0
; AVX512-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX512-NEXT:    vpand %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[2,3,0,1]
; AVX512-NEXT:    vpand %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vmovq %xmm0, %rax
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %c = fcmp ogt <4 x double> %a0, %a1
  %s = sext <4 x i1> %c to <4 x i64>
  %1 = shufflevector <4 x i64> %s, <4 x i64> undef, <4 x i32> <i32 2, i32 3, i32 undef, i32 undef>
  %2 = and <4 x i64> %s, %1
  %3 = shufflevector <4 x i64> %2, <4 x i64> undef, <4 x i32> <i32 1, i32 undef, i32 undef, i32 undef>
  %4 = and <4 x i64> %2, %3
  %5 = extractelement <4 x i64> %4, i64 0
  ret i64 %5
}

define i64 @test_v4f64_legal_sext(<4 x double> %a0, <4 x double> %a1) {
; SSE-LABEL: test_v4f64_legal_sext:
; SSE:       # %bb.0:
; SSE-NEXT:    cmpltpd %xmm1, %xmm3
; SSE-NEXT:    cmpltpd %xmm0, %xmm2
; SSE-NEXT:    packssdw %xmm3, %xmm2
; SSE-NEXT:    movmskps %xmm2, %eax
; SSE-NEXT:    xorl %ecx, %ecx
; SSE-NEXT:    cmpl $15, %eax
; SSE-NEXT:    movl $-1, %eax
; SSE-NEXT:    cmovnel %ecx, %eax
; SSE-NEXT:    cltq
; SSE-NEXT:    retq
;
; AVX-LABEL: test_v4f64_legal_sext:
; AVX:       # %bb.0:
; AVX-NEXT:    vcmpltpd %ymm0, %ymm1, %ymm0
; AVX-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX-NEXT:    vpackssdw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vmovmskps %xmm0, %eax
; AVX-NEXT:    xorl %ecx, %ecx
; AVX-NEXT:    cmpl $15, %eax
; AVX-NEXT:    movl $-1, %eax
; AVX-NEXT:    cmovnel %ecx, %eax
; AVX-NEXT:    cltq
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_v4f64_legal_sext:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vcmpltpd %ymm0, %ymm1, %k1
; AVX512-NEXT:    vpcmpeqd %xmm0, %xmm0, %xmm0
; AVX512-NEXT:    vmovdqa32 %xmm0, %xmm0 {%k1} {z}
; AVX512-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[2,3,0,1]
; AVX512-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[1,1,2,3]
; AVX512-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vmovd %xmm0, %eax
; AVX512-NEXT:    cltq
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %c = fcmp ogt <4 x double> %a0, %a1
  %s = sext <4 x i1> %c to <4 x i32>
  %1 = shufflevector <4 x i32> %s, <4 x i32> undef, <4 x i32> <i32 2, i32 3, i32 undef, i32 undef>
  %2 = and <4 x i32> %s, %1
  %3 = shufflevector <4 x i32> %2, <4 x i32> undef, <4 x i32> <i32 1, i32 undef, i32 undef, i32 undef>
  %4 = and <4 x i32> %2, %3
  %5 = extractelement <4 x i32> %4, i64 0
  %6 = sext i32 %5 to i64
  ret i64 %6
}

define i32 @test_v4f32_sext(<4 x float> %a0, <4 x float> %a1) {
; SSE-LABEL: test_v4f32_sext:
; SSE:       # %bb.0:
; SSE-NEXT:    cmpltps %xmm0, %xmm1
; SSE-NEXT:    movmskps %xmm1, %eax
; SSE-NEXT:    xorl %ecx, %ecx
; SSE-NEXT:    cmpl $15, %eax
; SSE-NEXT:    movl $-1, %eax
; SSE-NEXT:    cmovnel %ecx, %eax
; SSE-NEXT:    retq
;
; AVX-LABEL: test_v4f32_sext:
; AVX:       # %bb.0:
; AVX-NEXT:    vcmpltps %xmm0, %xmm1, %xmm0
; AVX-NEXT:    vmovmskps %xmm0, %eax
; AVX-NEXT:    xorl %ecx, %ecx
; AVX-NEXT:    cmpl $15, %eax
; AVX-NEXT:    movl $-1, %eax
; AVX-NEXT:    cmovnel %ecx, %eax
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_v4f32_sext:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vcmpltps %xmm0, %xmm1, %xmm0
; AVX512-NEXT:    vpermilps {{.*#+}} xmm1 = xmm0[2,3,0,1]
; AVX512-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[1,1,2,3]
; AVX512-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vmovd %xmm0, %eax
; AVX512-NEXT:    retq
  %c = fcmp ogt <4 x float> %a0, %a1
  %s = sext <4 x i1> %c to <4 x i32>
  %1 = shufflevector <4 x i32> %s, <4 x i32> undef, <4 x i32> <i32 2, i32 3, i32 undef, i32 undef>
  %2 = and <4 x i32> %s, %1
  %3 = shufflevector <4 x i32> %2, <4 x i32> undef, <4 x i32> <i32 1, i32 undef, i32 undef, i32 undef>
  %4 = and <4 x i32> %2, %3
  %5 = extractelement <4 x i32> %4, i32 0
  ret i32 %5
}

define i32 @test_v8f32_sext(<8 x float> %a0, <8 x float> %a1) {
; SSE-LABEL: test_v8f32_sext:
; SSE:       # %bb.0:
; SSE-NEXT:    cmpltps %xmm1, %xmm3
; SSE-NEXT:    cmpltps %xmm0, %xmm2
; SSE-NEXT:    andps %xmm3, %xmm2
; SSE-NEXT:    movmskps %xmm2, %eax
; SSE-NEXT:    xorl %ecx, %ecx
; SSE-NEXT:    cmpl $15, %eax
; SSE-NEXT:    movl $-1, %eax
; SSE-NEXT:    cmovnel %ecx, %eax
; SSE-NEXT:    retq
;
; AVX-LABEL: test_v8f32_sext:
; AVX:       # %bb.0:
; AVX-NEXT:    vcmpltps %ymm0, %ymm1, %ymm0
; AVX-NEXT:    vmovmskps %ymm0, %eax
; AVX-NEXT:    xorl %ecx, %ecx
; AVX-NEXT:    cmpl $255, %eax
; AVX-NEXT:    movl $-1, %eax
; AVX-NEXT:    cmovnel %ecx, %eax
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_v8f32_sext:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vcmpltps %ymm0, %ymm1, %ymm0
; AVX512-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX512-NEXT:    vpand %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[2,3,0,1]
; AVX512-NEXT:    vpand %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[1,1,2,3]
; AVX512-NEXT:    vpand %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vmovd %xmm0, %eax
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %c = fcmp ogt <8 x float> %a0, %a1
  %s = sext <8 x i1> %c to <8 x i32>
  %1 = shufflevector <8 x i32> %s, <8 x i32> undef, <8 x i32> <i32 4, i32 5, i32 6, i32 7, i32 undef, i32 undef, i32 undef, i32 undef>
  %2 = and <8 x i32> %s, %1
  %3 = shufflevector <8 x i32> %2, <8 x i32> undef, <8 x i32> <i32 2, i32 3, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %4 = and <8 x i32> %2, %3
  %5 = shufflevector <8 x i32> %4, <8 x i32> undef, <8 x i32> <i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %6 = and <8 x i32> %4, %5
  %7 = extractelement <8 x i32> %6, i32 0
  ret i32 %7
}

define i32 @test_v8f32_legal_sext(<8 x float> %a0, <8 x float> %a1) {
; SSE-LABEL: test_v8f32_legal_sext:
; SSE:       # %bb.0:
; SSE-NEXT:    cmpltps %xmm1, %xmm3
; SSE-NEXT:    cmpltps %xmm0, %xmm2
; SSE-NEXT:    packssdw %xmm3, %xmm2
; SSE-NEXT:    pmovmskb %xmm2, %eax
; SSE-NEXT:    xorl %ecx, %ecx
; SSE-NEXT:    cmpl $65535, %eax # imm = 0xFFFF
; SSE-NEXT:    movl $-1, %eax
; SSE-NEXT:    cmovnel %ecx, %eax
; SSE-NEXT:    retq
;
; AVX-LABEL: test_v8f32_legal_sext:
; AVX:       # %bb.0:
; AVX-NEXT:    vcmpltps %ymm0, %ymm1, %ymm0
; AVX-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX-NEXT:    vpackssdw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vpmovmskb %xmm0, %eax
; AVX-NEXT:    xorl %ecx, %ecx
; AVX-NEXT:    cmpl $65535, %eax # imm = 0xFFFF
; AVX-NEXT:    movl $-1, %eax
; AVX-NEXT:    cmovnel %ecx, %eax
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_v8f32_legal_sext:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vcmpltps %ymm0, %ymm1, %k0
; AVX512-NEXT:    vpmovm2w %k0, %xmm0
; AVX512-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[2,3,0,1]
; AVX512-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[1,1,2,3]
; AVX512-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vpsrld $16, %xmm0, %xmm1
; AVX512-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vmovd %xmm0, %eax
; AVX512-NEXT:    cwtl
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %c = fcmp ogt <8 x float> %a0, %a1
  %s = sext <8 x i1> %c to <8 x i16>
  %1 = shufflevector <8 x i16> %s, <8 x i16> undef, <8 x i32> <i32 4, i32 5, i32 6, i32 7, i32 undef, i32 undef, i32 undef, i32 undef>
  %2 = and <8 x i16> %s, %1
  %3 = shufflevector <8 x i16> %2, <8 x i16> undef, <8 x i32> <i32 2, i32 3, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %4 = and <8 x i16> %2, %3
  %5 = shufflevector <8 x i16> %4, <8 x i16> undef, <8 x i32> <i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %6 = and <8 x i16> %4, %5
  %7 = extractelement <8 x i16> %6, i32 0
  %8 = sext i16 %7 to i32
  ret i32 %8
}

define i64 @test_v2i64_sext(<2 x i64> %a0, <2 x i64> %a1) {
; SSE-LABEL: test_v2i64_sext:
; SSE:       # %bb.0:
; SSE-NEXT:    pcmpgtq %xmm1, %xmm0
; SSE-NEXT:    pshufd {{.*#+}} xmm1 = xmm0[2,3,0,1]
; SSE-NEXT:    pand %xmm0, %xmm1
; SSE-NEXT:    movq %xmm1, %rax
; SSE-NEXT:    retq
;
; AVX-LABEL: test_v2i64_sext:
; AVX:       # %bb.0:
; AVX-NEXT:    vpcmpgtq %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[2,3,0,1]
; AVX-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vmovq %xmm0, %rax
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_v2i64_sext:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpcmpgtq %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[2,3,0,1]
; AVX512-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vmovq %xmm0, %rax
; AVX512-NEXT:    retq
  %c = icmp sgt <2 x i64> %a0, %a1
  %s = sext <2 x i1> %c to <2 x i64>
  %1 = shufflevector <2 x i64> %s, <2 x i64> undef, <2 x i32> <i32 1, i32 undef>
  %2 = and <2 x i64> %s, %1
  %3 = extractelement <2 x i64> %2, i32 0
  ret i64 %3
}

define i64 @test_v4i64_sext(<4 x i64> %a0, <4 x i64> %a1) {
; SSE-LABEL: test_v4i64_sext:
; SSE:       # %bb.0:
; SSE-NEXT:    pcmpgtq %xmm3, %xmm1
; SSE-NEXT:    pcmpgtq %xmm2, %xmm0
; SSE-NEXT:    pand %xmm1, %xmm0
; SSE-NEXT:    pshufd {{.*#+}} xmm1 = xmm0[2,3,0,1]
; SSE-NEXT:    pand %xmm0, %xmm1
; SSE-NEXT:    movq %xmm1, %rax
; SSE-NEXT:    retq
;
; AVX1-LABEL: test_v4i64_sext:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpcmpgtq %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpcmpgtq %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    vmovmskpd %ymm0, %eax
; AVX1-NEXT:    xorl %ecx, %ecx
; AVX1-NEXT:    cmpl $15, %eax
; AVX1-NEXT:    movq $-1, %rax
; AVX1-NEXT:    cmovneq %rcx, %rax
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test_v4i64_sext:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpcmpgtq %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vmovmskpd %ymm0, %eax
; AVX2-NEXT:    xorl %ecx, %ecx
; AVX2-NEXT:    cmpl $15, %eax
; AVX2-NEXT:    movq $-1, %rax
; AVX2-NEXT:    cmovneq %rcx, %rax
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: test_v4i64_sext:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpcmpgtq %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX512-NEXT:    vpand %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[2,3,0,1]
; AVX512-NEXT:    vpand %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vmovq %xmm0, %rax
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %c = icmp sgt <4 x i64> %a0, %a1
  %s = sext <4 x i1> %c to <4 x i64>
  %1 = shufflevector <4 x i64> %s, <4 x i64> undef, <4 x i32> <i32 2, i32 3, i32 undef, i32 undef>
  %2 = and <4 x i64> %s, %1
  %3 = shufflevector <4 x i64> %2, <4 x i64> undef, <4 x i32> <i32 1, i32 undef, i32 undef, i32 undef>
  %4 = and <4 x i64> %2, %3
  %5 = extractelement <4 x i64> %4, i64 0
  ret i64 %5
}

define i64 @test_v4i64_legal_sext(<4 x i64> %a0, <4 x i64> %a1) {
; SSE-LABEL: test_v4i64_legal_sext:
; SSE:       # %bb.0:
; SSE-NEXT:    pcmpgtq %xmm3, %xmm1
; SSE-NEXT:    pcmpgtq %xmm2, %xmm0
; SSE-NEXT:    packssdw %xmm1, %xmm0
; SSE-NEXT:    movmskps %xmm0, %eax
; SSE-NEXT:    xorl %ecx, %ecx
; SSE-NEXT:    cmpl $15, %eax
; SSE-NEXT:    movl $-1, %eax
; SSE-NEXT:    cmovnel %ecx, %eax
; SSE-NEXT:    cltq
; SSE-NEXT:    retq
;
; AVX1-LABEL: test_v4i64_legal_sext:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpcmpgtq %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpcmpgtq %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpackssdw %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vmovmskps %xmm0, %eax
; AVX1-NEXT:    xorl %ecx, %ecx
; AVX1-NEXT:    cmpl $15, %eax
; AVX1-NEXT:    movl $-1, %eax
; AVX1-NEXT:    cmovnel %ecx, %eax
; AVX1-NEXT:    cltq
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test_v4i64_legal_sext:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpcmpgtq %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX2-NEXT:    vpackssdw %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vmovmskps %xmm0, %eax
; AVX2-NEXT:    xorl %ecx, %ecx
; AVX2-NEXT:    cmpl $15, %eax
; AVX2-NEXT:    movl $-1, %eax
; AVX2-NEXT:    cmovnel %ecx, %eax
; AVX2-NEXT:    cltq
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: test_v4i64_legal_sext:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpcmpgtq %ymm1, %ymm0, %k1
; AVX512-NEXT:    vpcmpeqd %xmm0, %xmm0, %xmm0
; AVX512-NEXT:    vmovdqa32 %xmm0, %xmm0 {%k1} {z}
; AVX512-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[2,3,0,1]
; AVX512-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[1,1,2,3]
; AVX512-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vmovd %xmm0, %eax
; AVX512-NEXT:    cltq
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %c = icmp sgt <4 x i64> %a0, %a1
  %s = sext <4 x i1> %c to <4 x i32>
  %1 = shufflevector <4 x i32> %s, <4 x i32> undef, <4 x i32> <i32 2, i32 3, i32 undef, i32 undef>
  %2 = and <4 x i32> %s, %1
  %3 = shufflevector <4 x i32> %2, <4 x i32> undef, <4 x i32> <i32 1, i32 undef, i32 undef, i32 undef>
  %4 = and <4 x i32> %2, %3
  %5 = extractelement <4 x i32> %4, i64 0
  %6 = sext i32 %5 to i64
  ret i64 %6
}

define i32 @test_v4i32_sext(<4 x i32> %a0, <4 x i32> %a1) {
; SSE-LABEL: test_v4i32_sext:
; SSE:       # %bb.0:
; SSE-NEXT:    pcmpgtd %xmm1, %xmm0
; SSE-NEXT:    movmskps %xmm0, %eax
; SSE-NEXT:    xorl %ecx, %ecx
; SSE-NEXT:    cmpl $15, %eax
; SSE-NEXT:    movl $-1, %eax
; SSE-NEXT:    cmovnel %ecx, %eax
; SSE-NEXT:    retq
;
; AVX-LABEL: test_v4i32_sext:
; AVX:       # %bb.0:
; AVX-NEXT:    vpcmpgtd %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vmovmskps %xmm0, %eax
; AVX-NEXT:    xorl %ecx, %ecx
; AVX-NEXT:    cmpl $15, %eax
; AVX-NEXT:    movl $-1, %eax
; AVX-NEXT:    cmovnel %ecx, %eax
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_v4i32_sext:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpcmpgtd %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[2,3,0,1]
; AVX512-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[1,1,2,3]
; AVX512-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vmovd %xmm0, %eax
; AVX512-NEXT:    retq
  %c = icmp sgt <4 x i32> %a0, %a1
  %s = sext <4 x i1> %c to <4 x i32>
  %1 = shufflevector <4 x i32> %s, <4 x i32> undef, <4 x i32> <i32 2, i32 3, i32 undef, i32 undef>
  %2 = and <4 x i32> %s, %1
  %3 = shufflevector <4 x i32> %2, <4 x i32> undef, <4 x i32> <i32 1, i32 undef, i32 undef, i32 undef>
  %4 = and <4 x i32> %2, %3
  %5 = extractelement <4 x i32> %4, i32 0
  ret i32 %5
}

define i32 @test_v8i32_sext(<8 x i32> %a0, <8 x i32> %a1) {
; SSE-LABEL: test_v8i32_sext:
; SSE:       # %bb.0:
; SSE-NEXT:    pcmpgtd %xmm3, %xmm1
; SSE-NEXT:    pcmpgtd %xmm2, %xmm0
; SSE-NEXT:    pand %xmm1, %xmm0
; SSE-NEXT:    movmskps %xmm0, %eax
; SSE-NEXT:    xorl %ecx, %ecx
; SSE-NEXT:    cmpl $15, %eax
; SSE-NEXT:    movl $-1, %eax
; SSE-NEXT:    cmovnel %ecx, %eax
; SSE-NEXT:    retq
;
; AVX1-LABEL: test_v8i32_sext:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpcmpgtd %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpcmpgtd %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    vmovmskps %ymm0, %eax
; AVX1-NEXT:    xorl %ecx, %ecx
; AVX1-NEXT:    cmpl $255, %eax
; AVX1-NEXT:    movl $-1, %eax
; AVX1-NEXT:    cmovnel %ecx, %eax
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test_v8i32_sext:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpcmpgtd %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vmovmskps %ymm0, %eax
; AVX2-NEXT:    xorl %ecx, %ecx
; AVX2-NEXT:    cmpl $255, %eax
; AVX2-NEXT:    movl $-1, %eax
; AVX2-NEXT:    cmovnel %ecx, %eax
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: test_v8i32_sext:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpcmpgtd %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX512-NEXT:    vpand %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[2,3,0,1]
; AVX512-NEXT:    vpand %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[1,1,2,3]
; AVX512-NEXT:    vpand %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vmovd %xmm0, %eax
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %c = icmp sgt <8 x i32> %a0, %a1
  %s = sext <8 x i1> %c to <8 x i32>
  %1 = shufflevector <8 x i32> %s, <8 x i32> undef, <8 x i32> <i32 4, i32 5, i32 6, i32 7, i32 undef, i32 undef, i32 undef, i32 undef>
  %2 = and <8 x i32> %s, %1
  %3 = shufflevector <8 x i32> %2, <8 x i32> undef, <8 x i32> <i32 2, i32 3, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %4 = and <8 x i32> %2, %3
  %5 = shufflevector <8 x i32> %4, <8 x i32> undef, <8 x i32> <i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %6 = and <8 x i32> %4, %5
  %7 = extractelement <8 x i32> %6, i32 0
  ret i32 %7
}

define i32 @test_v8i32_legal_sext(<8 x i32> %a0, <8 x i32> %a1) {
; SSE-LABEL: test_v8i32_legal_sext:
; SSE:       # %bb.0:
; SSE-NEXT:    pcmpgtd %xmm3, %xmm1
; SSE-NEXT:    pcmpgtd %xmm2, %xmm0
; SSE-NEXT:    packssdw %xmm1, %xmm0
; SSE-NEXT:    pmovmskb %xmm0, %eax
; SSE-NEXT:    xorl %ecx, %ecx
; SSE-NEXT:    cmpl $65535, %eax # imm = 0xFFFF
; SSE-NEXT:    movl $-1, %eax
; SSE-NEXT:    cmovnel %ecx, %eax
; SSE-NEXT:    retq
;
; AVX1-LABEL: test_v8i32_legal_sext:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpcmpgtd %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpcmpgtd %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpackssdw %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vpmovmskb %xmm0, %eax
; AVX1-NEXT:    xorl %ecx, %ecx
; AVX1-NEXT:    cmpl $65535, %eax # imm = 0xFFFF
; AVX1-NEXT:    movl $-1, %eax
; AVX1-NEXT:    cmovnel %ecx, %eax
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test_v8i32_legal_sext:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpcmpgtd %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX2-NEXT:    vpackssdw %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpmovmskb %xmm0, %eax
; AVX2-NEXT:    xorl %ecx, %ecx
; AVX2-NEXT:    cmpl $65535, %eax # imm = 0xFFFF
; AVX2-NEXT:    movl $-1, %eax
; AVX2-NEXT:    cmovnel %ecx, %eax
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: test_v8i32_legal_sext:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpcmpgtd %ymm1, %ymm0, %k0
; AVX512-NEXT:    vpmovm2w %k0, %xmm0
; AVX512-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[2,3,0,1]
; AVX512-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[1,1,2,3]
; AVX512-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vpsrld $16, %xmm0, %xmm1
; AVX512-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vmovd %xmm0, %eax
; AVX512-NEXT:    cwtl
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %c = icmp sgt <8 x i32> %a0, %a1
  %s = sext <8 x i1> %c to <8 x i16>
  %1 = shufflevector <8 x i16> %s, <8 x i16> undef, <8 x i32> <i32 4, i32 5, i32 6, i32 7, i32 undef, i32 undef, i32 undef, i32 undef>
  %2 = and <8 x i16> %s, %1
  %3 = shufflevector <8 x i16> %2, <8 x i16> undef, <8 x i32> <i32 2, i32 3, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %4 = and <8 x i16> %2, %3
  %5 = shufflevector <8 x i16> %4, <8 x i16> undef, <8 x i32> <i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %6 = and <8 x i16> %4, %5
  %7 = extractelement <8 x i16> %6, i32 0
  %8 = sext i16 %7 to i32
  ret i32 %8
}

define i16 @test_v8i16_sext(<8 x i16> %a0, <8 x i16> %a1) {
; SSE-LABEL: test_v8i16_sext:
; SSE:       # %bb.0:
; SSE-NEXT:    pcmpgtw %xmm1, %xmm0
; SSE-NEXT:    pmovmskb %xmm0, %eax
; SSE-NEXT:    xorl %ecx, %ecx
; SSE-NEXT:    cmpl $65535, %eax # imm = 0xFFFF
; SSE-NEXT:    movl $-1, %eax
; SSE-NEXT:    cmovnel %ecx, %eax
; SSE-NEXT:    # kill: def %ax killed %ax killed %eax
; SSE-NEXT:    retq
;
; AVX-LABEL: test_v8i16_sext:
; AVX:       # %bb.0:
; AVX-NEXT:    vpcmpgtw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vpmovmskb %xmm0, %eax
; AVX-NEXT:    xorl %ecx, %ecx
; AVX-NEXT:    cmpl $65535, %eax # imm = 0xFFFF
; AVX-NEXT:    movl $-1, %eax
; AVX-NEXT:    cmovnel %ecx, %eax
; AVX-NEXT:    # kill: def %ax killed %ax killed %eax
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_v8i16_sext:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpcmpgtw %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[2,3,0,1]
; AVX512-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[1,1,2,3]
; AVX512-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vpsrld $16, %xmm0, %xmm1
; AVX512-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vmovd %xmm0, %eax
; AVX512-NEXT:    # kill: def %ax killed %ax killed %eax
; AVX512-NEXT:    retq
  %c = icmp sgt <8 x i16> %a0, %a1
  %s = sext <8 x i1> %c to <8 x i16>
  %1 = shufflevector <8 x i16> %s, <8 x i16> undef, <8 x i32> <i32 4, i32 5, i32 6, i32 7, i32 undef, i32 undef, i32 undef, i32 undef>
  %2 = and <8 x i16> %s, %1
  %3 = shufflevector <8 x i16> %2, <8 x i16> undef, <8 x i32> <i32 2, i32 3, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %4 = and <8 x i16> %2, %3
  %5 = shufflevector <8 x i16> %4, <8 x i16> undef, <8 x i32> <i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %6 = and <8 x i16> %4, %5
  %7 = extractelement <8 x i16> %6, i32 0
  ret i16 %7
}

define i16 @test_v16i16_sext(<16 x i16> %a0, <16 x i16> %a1) {
; SSE-LABEL: test_v16i16_sext:
; SSE:       # %bb.0:
; SSE-NEXT:    pcmpgtw %xmm3, %xmm1
; SSE-NEXT:    pcmpgtw %xmm2, %xmm0
; SSE-NEXT:    pand %xmm1, %xmm0
; SSE-NEXT:    pmovmskb %xmm0, %eax
; SSE-NEXT:    xorl %ecx, %ecx
; SSE-NEXT:    cmpl $65535, %eax # imm = 0xFFFF
; SSE-NEXT:    movl $-1, %eax
; SSE-NEXT:    cmovnel %ecx, %eax
; SSE-NEXT:    # kill: def %ax killed %ax killed %eax
; SSE-NEXT:    retq
;
; AVX1-LABEL: test_v16i16_sext:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpcmpgtw %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpcmpgtw %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    vandps %ymm2, %ymm0, %ymm0
; AVX1-NEXT:    vpermilps {{.*#+}} xmm1 = xmm0[2,3,0,1]
; AVX1-NEXT:    vandps %ymm1, %ymm0, %ymm0
; AVX1-NEXT:    vpermilps {{.*#+}} xmm1 = xmm0[1,1,2,3]
; AVX1-NEXT:    vandps %ymm1, %ymm0, %ymm0
; AVX1-NEXT:    vpsrld $16, %xmm0, %xmm1
; AVX1-NEXT:    vandps %ymm1, %ymm0, %ymm0
; AVX1-NEXT:    vmovd %xmm0, %eax
; AVX1-NEXT:    # kill: def %ax killed %ax killed %eax
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test_v16i16_sext:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpcmpgtw %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpmovmskb %ymm0, %ecx
; AVX2-NEXT:    xorl %eax, %eax
; AVX2-NEXT:    cmpl $-1, %ecx
; AVX2-NEXT:    cmovel %ecx, %eax
; AVX2-NEXT:    # kill: def %ax killed %ax killed %eax
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: test_v16i16_sext:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpcmpgtw %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX512-NEXT:    vpand %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[2,3,0,1]
; AVX512-NEXT:    vpand %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[1,1,2,3]
; AVX512-NEXT:    vpand %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vpsrld $16, %xmm0, %xmm1
; AVX512-NEXT:    vpand %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vmovd %xmm0, %eax
; AVX512-NEXT:    # kill: def %ax killed %ax killed %eax
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %c = icmp sgt <16 x i16> %a0, %a1
  %s = sext <16 x i1> %c to <16 x i16>
  %1 = shufflevector <16 x i16> %s, <16 x i16> undef, <16 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %2 = and <16 x i16> %s, %1
  %3 = shufflevector <16 x i16> %2, <16 x i16> undef, <16 x i32> <i32 4, i32 5, i32 6, i32 7, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %4 = and <16 x i16> %2, %3
  %5 = shufflevector <16 x i16> %4, <16 x i16> undef, <16 x i32> <i32 2, i32 3, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %6 = and <16 x i16> %4, %5
  %7 = shufflevector <16 x i16> %6, <16 x i16> undef, <16 x i32> <i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %8 = and <16 x i16> %6, %7
  %9 = extractelement <16 x i16> %8, i32 0
  ret i16 %9
}

define i16 @test_v16i16_legal_sext(<16 x i16> %a0, <16 x i16> %a1) {
; SSE-LABEL: test_v16i16_legal_sext:
; SSE:       # %bb.0:
; SSE-NEXT:    pcmpgtw %xmm3, %xmm1
; SSE-NEXT:    pcmpgtw %xmm2, %xmm0
; SSE-NEXT:    packsswb %xmm1, %xmm0
; SSE-NEXT:    pmovmskb %xmm0, %eax
; SSE-NEXT:    xorl %ecx, %ecx
; SSE-NEXT:    cmpl $65535, %eax # imm = 0xFFFF
; SSE-NEXT:    movl $-1, %eax
; SSE-NEXT:    cmovnel %ecx, %eax
; SSE-NEXT:    # kill: def %ax killed %ax killed %eax
; SSE-NEXT:    retq
;
; AVX1-LABEL: test_v16i16_legal_sext:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpcmpgtw %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpcmpgtw %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpacksswb %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vpmovmskb %xmm0, %eax
; AVX1-NEXT:    xorl %ecx, %ecx
; AVX1-NEXT:    cmpl $65535, %eax # imm = 0xFFFF
; AVX1-NEXT:    movl $-1, %eax
; AVX1-NEXT:    cmovnel %ecx, %eax
; AVX1-NEXT:    # kill: def %ax killed %ax killed %eax
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test_v16i16_legal_sext:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpcmpgtw %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX2-NEXT:    vpacksswb %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpmovmskb %xmm0, %eax
; AVX2-NEXT:    xorl %ecx, %ecx
; AVX2-NEXT:    cmpl $65535, %eax # imm = 0xFFFF
; AVX2-NEXT:    movl $-1, %eax
; AVX2-NEXT:    cmovnel %ecx, %eax
; AVX2-NEXT:    # kill: def %ax killed %ax killed %eax
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: test_v16i16_legal_sext:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpcmpgtw %ymm1, %ymm0, %k0
; AVX512-NEXT:    vpmovm2b %k0, %xmm0
; AVX512-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[2,3,0,1]
; AVX512-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[1,1,2,3]
; AVX512-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vpsrld $16, %xmm0, %xmm1
; AVX512-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vpsrlw $8, %xmm0, %xmm1
; AVX512-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vpextrb $0, %xmm0, %eax
; AVX512-NEXT:    movsbl %al, %eax
; AVX512-NEXT:    # kill: def %ax killed %ax killed %eax
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %c  = icmp sgt <16 x i16> %a0, %a1
  %s  = sext <16 x i1> %c to <16 x i8>
  %1  = shufflevector <16 x i8> %s, <16 x i8> undef, <16 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %2  = and <16 x i8> %s, %1
  %3  = shufflevector <16 x i8> %2, <16 x i8> undef, <16 x i32> <i32 4, i32 5, i32 6, i32 7, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %4  = and <16 x i8> %2, %3
  %5  = shufflevector <16 x i8> %4, <16 x i8> undef, <16 x i32> <i32 2, i32 3, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %6  = and <16 x i8> %4, %5
  %7  = shufflevector <16 x i8> %6, <16 x i8> undef, <16 x i32> <i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %8  = and <16 x i8> %6, %7
  %9  = extractelement <16 x i8> %8, i32 0
  %10 = sext i8 %9 to i16
  ret i16 %10
}

define i8 @test_v16i8_sext(<16 x i8> %a0, <16 x i8> %a1) {
; SSE-LABEL: test_v16i8_sext:
; SSE:       # %bb.0:
; SSE-NEXT:    pcmpgtb %xmm1, %xmm0
; SSE-NEXT:    pmovmskb %xmm0, %eax
; SSE-NEXT:    xorl %ecx, %ecx
; SSE-NEXT:    cmpl $65535, %eax # imm = 0xFFFF
; SSE-NEXT:    movl $-1, %eax
; SSE-NEXT:    cmovnel %ecx, %eax
; SSE-NEXT:    # kill: def %al killed %al killed %eax
; SSE-NEXT:    retq
;
; AVX-LABEL: test_v16i8_sext:
; AVX:       # %bb.0:
; AVX-NEXT:    vpcmpgtb %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vpmovmskb %xmm0, %eax
; AVX-NEXT:    xorl %ecx, %ecx
; AVX-NEXT:    cmpl $65535, %eax # imm = 0xFFFF
; AVX-NEXT:    movl $-1, %eax
; AVX-NEXT:    cmovnel %ecx, %eax
; AVX-NEXT:    # kill: def %al killed %al killed %eax
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_v16i8_sext:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpcmpgtb %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[2,3,0,1]
; AVX512-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[1,1,2,3]
; AVX512-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vpsrld $16, %xmm0, %xmm1
; AVX512-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vpsrlw $8, %xmm0, %xmm1
; AVX512-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vpextrb $0, %xmm0, %eax
; AVX512-NEXT:    # kill: def %al killed %al killed %eax
; AVX512-NEXT:    retq
  %c = icmp sgt <16 x i8> %a0, %a1
  %s = sext <16 x i1> %c to <16 x i8>
  %1 = shufflevector <16 x i8> %s, <16 x i8> undef, <16 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %2 = and <16 x i8> %s, %1
  %3 = shufflevector <16 x i8> %2, <16 x i8> undef, <16 x i32> <i32 4, i32 5, i32 6, i32 7, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %4 = and <16 x i8> %2, %3
  %5 = shufflevector <16 x i8> %4, <16 x i8> undef, <16 x i32> <i32 2, i32 3, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %6 = and <16 x i8> %4, %5
  %7 = shufflevector <16 x i8> %6, <16 x i8> undef, <16 x i32> <i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %8 = and <16 x i8> %6, %7
  %9 = extractelement <16 x i8> %8, i32 0
  ret i8 %9
}

define i8 @test_v32i8_sext(<32 x i8> %a0, <32 x i8> %a1) {
; SSE-LABEL: test_v32i8_sext:
; SSE:       # %bb.0:
; SSE-NEXT:    pcmpgtb %xmm3, %xmm1
; SSE-NEXT:    pcmpgtb %xmm2, %xmm0
; SSE-NEXT:    pand %xmm1, %xmm0
; SSE-NEXT:    pmovmskb %xmm0, %eax
; SSE-NEXT:    xorl %ecx, %ecx
; SSE-NEXT:    cmpl $65535, %eax # imm = 0xFFFF
; SSE-NEXT:    movl $-1, %eax
; SSE-NEXT:    cmovnel %ecx, %eax
; SSE-NEXT:    # kill: def %al killed %al killed %eax
; SSE-NEXT:    retq
;
; AVX1-LABEL: test_v32i8_sext:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpcmpgtb %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpcmpgtb %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    vandps %ymm2, %ymm0, %ymm0
; AVX1-NEXT:    vpermilps {{.*#+}} xmm1 = xmm0[2,3,0,1]
; AVX1-NEXT:    vandps %ymm1, %ymm0, %ymm0
; AVX1-NEXT:    vpermilps {{.*#+}} xmm1 = xmm0[1,1,2,3]
; AVX1-NEXT:    vandps %ymm1, %ymm0, %ymm0
; AVX1-NEXT:    vpsrld $16, %xmm0, %xmm1
; AVX1-NEXT:    vandps %ymm1, %ymm0, %ymm0
; AVX1-NEXT:    vpsrlw $8, %xmm0, %xmm1
; AVX1-NEXT:    vandps %ymm1, %ymm0, %ymm0
; AVX1-NEXT:    vpextrb $0, %xmm0, %eax
; AVX1-NEXT:    # kill: def %al killed %al killed %eax
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test_v32i8_sext:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpcmpgtb %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpmovmskb %ymm0, %ecx
; AVX2-NEXT:    xorl %eax, %eax
; AVX2-NEXT:    cmpl $-1, %ecx
; AVX2-NEXT:    cmovel %ecx, %eax
; AVX2-NEXT:    # kill: def %al killed %al killed %eax
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: test_v32i8_sext:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpcmpgtb %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX512-NEXT:    vpand %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[2,3,0,1]
; AVX512-NEXT:    vpand %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[1,1,2,3]
; AVX512-NEXT:    vpand %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vpsrld $16, %xmm0, %xmm1
; AVX512-NEXT:    vpand %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vpsrlw $8, %xmm0, %xmm1
; AVX512-NEXT:    vpand %ymm1, %ymm0, %ymm0
; AVX512-NEXT:    vpextrb $0, %xmm0, %eax
; AVX512-NEXT:    # kill: def %al killed %al killed %eax
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %c  = icmp sgt <32 x i8> %a0, %a1
  %s  = sext <32 x i1> %c to <32 x i8>
  %1  = shufflevector <32 x i8> %s, <32 x i8> undef, <32 x i32> <i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %2  = and <32 x i8> %s, %1
  %3  = shufflevector <32 x i8> %2, <32 x i8> undef, <32 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %4  = and <32 x i8> %2, %3
  %5  = shufflevector <32 x i8> %4, <32 x i8> undef, <32 x i32> <i32 4, i32 5, i32 6, i32 7, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %6  = and <32 x i8> %4, %5
  %7  = shufflevector <32 x i8> %6, <32 x i8> undef, <32 x i32> <i32 2, i32 3, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %8  = and <32 x i8> %6, %7
  %9  = shufflevector <32 x i8> %8, <32 x i8> undef, <32 x i32> <i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %10 = and <32 x i8> %8, %9
  %11 = extractelement <32 x i8> %10, i32 0
  ret i8 %11
}
