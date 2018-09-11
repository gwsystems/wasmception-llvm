; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse2    | FileCheck %s --check-prefix=SSE2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse4.1  | FileCheck %s --check-prefix=SSE41
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx     | FileCheck %s --check-prefix=AVX1

define float @trunc_unsigned_f32(float %x) #0 {
; SSE2-LABEL: trunc_unsigned_f32:
; SSE2:       # %bb.0:
; SSE2-NEXT:    cvttss2si %xmm0, %rax
; SSE2-NEXT:    movl %eax, %eax
; SSE2-NEXT:    xorps %xmm0, %xmm0
; SSE2-NEXT:    cvtsi2ssq %rax, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: trunc_unsigned_f32:
; SSE41:       # %bb.0:
; SSE41-NEXT:    roundss $11, %xmm0, %xmm0
; SSE41-NEXT:    retq
;
; AVX1-LABEL: trunc_unsigned_f32:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vroundss $11, %xmm0, %xmm0, %xmm0
; AVX1-NEXT:    retq
  %i = fptoui float %x to i32
  %r = uitofp i32 %i to float
  ret float %r
}

define double @trunc_unsigned_f64(double %x) #0 {
; SSE2-LABEL: trunc_unsigned_f64:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; SSE2-NEXT:    movapd %xmm0, %xmm2
; SSE2-NEXT:    subsd %xmm1, %xmm2
; SSE2-NEXT:    cvttsd2si %xmm2, %rax
; SSE2-NEXT:    movabsq $-9223372036854775808, %rcx # imm = 0x8000000000000000
; SSE2-NEXT:    xorq %rax, %rcx
; SSE2-NEXT:    cvttsd2si %xmm0, %rax
; SSE2-NEXT:    ucomisd %xmm1, %xmm0
; SSE2-NEXT:    cmovaeq %rcx, %rax
; SSE2-NEXT:    movq %rax, %xmm1
; SSE2-NEXT:    punpckldq {{.*#+}} xmm1 = xmm1[0],mem[0],xmm1[1],mem[1]
; SSE2-NEXT:    subpd {{.*}}(%rip), %xmm1
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm1[2,3,0,1]
; SSE2-NEXT:    addpd %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: trunc_unsigned_f64:
; SSE41:       # %bb.0:
; SSE41-NEXT:    roundsd $11, %xmm0, %xmm0
; SSE41-NEXT:    retq
;
; AVX1-LABEL: trunc_unsigned_f64:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vroundsd $11, %xmm0, %xmm0, %xmm0
; AVX1-NEXT:    retq
  %i = fptoui double %x to i64
  %r = uitofp i64 %i to double
  ret double %r
}

define <4 x float> @trunc_unsigned_v4f32(<4 x float> %x) #0 {
; SSE2-LABEL: trunc_unsigned_v4f32:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movaps %xmm0, %xmm1
; SSE2-NEXT:    shufps {{.*#+}} xmm1 = xmm1[3,1],xmm0[2,3]
; SSE2-NEXT:    cvttss2si %xmm1, %rax
; SSE2-NEXT:    movd %eax, %xmm1
; SSE2-NEXT:    movaps %xmm0, %xmm2
; SSE2-NEXT:    unpckhpd {{.*#+}} xmm2 = xmm2[1],xmm0[1]
; SSE2-NEXT:    cvttss2si %xmm2, %rax
; SSE2-NEXT:    movd %eax, %xmm2
; SSE2-NEXT:    punpckldq {{.*#+}} xmm2 = xmm2[0],xmm1[0],xmm2[1],xmm1[1]
; SSE2-NEXT:    cvttss2si %xmm0, %rax
; SSE2-NEXT:    movd %eax, %xmm1
; SSE2-NEXT:    shufps {{.*#+}} xmm0 = xmm0[1,1,2,3]
; SSE2-NEXT:    cvttss2si %xmm0, %rax
; SSE2-NEXT:    movd %eax, %xmm0
; SSE2-NEXT:    punpckldq {{.*#+}} xmm1 = xmm1[0],xmm0[0],xmm1[1],xmm0[1]
; SSE2-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm2[0]
; SSE2-NEXT:    movdqa {{.*#+}} xmm0 = [65535,65535,65535,65535]
; SSE2-NEXT:    pand %xmm1, %xmm0
; SSE2-NEXT:    por {{.*}}(%rip), %xmm0
; SSE2-NEXT:    psrld $16, %xmm1
; SSE2-NEXT:    por {{.*}}(%rip), %xmm1
; SSE2-NEXT:    addps {{.*}}(%rip), %xmm1
; SSE2-NEXT:    addps %xmm0, %xmm1
; SSE2-NEXT:    movaps %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: trunc_unsigned_v4f32:
; SSE41:       # %bb.0:
; SSE41-NEXT:    roundps $11, %xmm0, %xmm0
; SSE41-NEXT:    retq
;
; AVX1-LABEL: trunc_unsigned_v4f32:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vroundps $11, %xmm0, %xmm0
; AVX1-NEXT:    retq
  %i = fptoui <4 x float> %x to <4 x i32>
  %r = uitofp <4 x i32> %i to <4 x float>
  ret <4 x float> %r
}

define <2 x double> @trunc_unsigned_v2f64(<2 x double> %x) #0 {
; SSE2-LABEL: trunc_unsigned_v2f64:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movapd %xmm0, %xmm1
; SSE2-NEXT:    unpckhpd {{.*#+}} xmm1 = xmm1[1],xmm0[1]
; SSE2-NEXT:    movsd {{.*#+}} xmm2 = mem[0],zero
; SSE2-NEXT:    movapd %xmm1, %xmm3
; SSE2-NEXT:    subsd %xmm2, %xmm3
; SSE2-NEXT:    cvttsd2si %xmm3, %rax
; SSE2-NEXT:    movabsq $-9223372036854775808, %rcx # imm = 0x8000000000000000
; SSE2-NEXT:    xorq %rcx, %rax
; SSE2-NEXT:    cvttsd2si %xmm1, %rdx
; SSE2-NEXT:    ucomisd %xmm2, %xmm1
; SSE2-NEXT:    cmovaeq %rax, %rdx
; SSE2-NEXT:    movapd %xmm0, %xmm1
; SSE2-NEXT:    subsd %xmm2, %xmm1
; SSE2-NEXT:    cvttsd2si %xmm1, %rax
; SSE2-NEXT:    xorq %rcx, %rax
; SSE2-NEXT:    cvttsd2si %xmm0, %rcx
; SSE2-NEXT:    ucomisd %xmm2, %xmm0
; SSE2-NEXT:    cmovaeq %rax, %rcx
; SSE2-NEXT:    movq %rcx, %xmm1
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [1127219200,1160773632,0,0]
; SSE2-NEXT:    punpckldq {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
; SSE2-NEXT:    movapd {{.*#+}} xmm3 = [4.503600e+15,1.934281e+25]
; SSE2-NEXT:    subpd %xmm3, %xmm1
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm1[2,3,0,1]
; SSE2-NEXT:    addpd %xmm1, %xmm0
; SSE2-NEXT:    movq %rdx, %xmm1
; SSE2-NEXT:    punpckldq {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
; SSE2-NEXT:    subpd %xmm3, %xmm1
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm1[2,3,0,1]
; SSE2-NEXT:    addpd %xmm1, %xmm2
; SSE2-NEXT:    unpcklpd {{.*#+}} xmm0 = xmm0[0],xmm2[0]
; SSE2-NEXT:    retq
;
; SSE41-LABEL: trunc_unsigned_v2f64:
; SSE41:       # %bb.0:
; SSE41-NEXT:    roundpd $11, %xmm0, %xmm0
; SSE41-NEXT:    retq
;
; AVX1-LABEL: trunc_unsigned_v2f64:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vroundpd $11, %xmm0, %xmm0
; AVX1-NEXT:    retq
  %i = fptoui <2 x double> %x to <2 x i64>
  %r = uitofp <2 x i64> %i to <2 x double>
  ret <2 x double> %r
}

define <4 x double> @trunc_unsigned_v4f64(<4 x double> %x) #0 {
; SSE2-LABEL: trunc_unsigned_v4f64:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movapd %xmm1, %xmm3
; SSE2-NEXT:    unpckhpd {{.*#+}} xmm3 = xmm3[1],xmm1[1]
; SSE2-NEXT:    movsd {{.*#+}} xmm2 = mem[0],zero
; SSE2-NEXT:    movapd %xmm3, %xmm4
; SSE2-NEXT:    subsd %xmm2, %xmm4
; SSE2-NEXT:    cvttsd2si %xmm4, %rcx
; SSE2-NEXT:    movabsq $-9223372036854775808, %rdx # imm = 0x8000000000000000
; SSE2-NEXT:    xorq %rdx, %rcx
; SSE2-NEXT:    cvttsd2si %xmm3, %rax
; SSE2-NEXT:    ucomisd %xmm2, %xmm3
; SSE2-NEXT:    cmovaeq %rcx, %rax
; SSE2-NEXT:    movapd %xmm1, %xmm3
; SSE2-NEXT:    subsd %xmm2, %xmm3
; SSE2-NEXT:    cvttsd2si %xmm3, %rsi
; SSE2-NEXT:    xorq %rdx, %rsi
; SSE2-NEXT:    cvttsd2si %xmm1, %rcx
; SSE2-NEXT:    ucomisd %xmm2, %xmm1
; SSE2-NEXT:    cmovaeq %rsi, %rcx
; SSE2-NEXT:    movapd %xmm0, %xmm1
; SSE2-NEXT:    unpckhpd {{.*#+}} xmm1 = xmm1[1],xmm0[1]
; SSE2-NEXT:    movapd %xmm1, %xmm3
; SSE2-NEXT:    subsd %xmm2, %xmm3
; SSE2-NEXT:    cvttsd2si %xmm3, %rsi
; SSE2-NEXT:    xorq %rdx, %rsi
; SSE2-NEXT:    cvttsd2si %xmm1, %rdi
; SSE2-NEXT:    ucomisd %xmm2, %xmm1
; SSE2-NEXT:    cmovaeq %rsi, %rdi
; SSE2-NEXT:    movapd %xmm0, %xmm1
; SSE2-NEXT:    subsd %xmm2, %xmm1
; SSE2-NEXT:    cvttsd2si %xmm1, %rsi
; SSE2-NEXT:    xorq %rdx, %rsi
; SSE2-NEXT:    cvttsd2si %xmm0, %rdx
; SSE2-NEXT:    ucomisd %xmm2, %xmm0
; SSE2-NEXT:    cmovaeq %rsi, %rdx
; SSE2-NEXT:    movq %rdx, %xmm1
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [1127219200,1160773632,0,0]
; SSE2-NEXT:    punpckldq {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
; SSE2-NEXT:    movapd {{.*#+}} xmm3 = [4.503600e+15,1.934281e+25]
; SSE2-NEXT:    subpd %xmm3, %xmm1
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm1[2,3,0,1]
; SSE2-NEXT:    addpd %xmm1, %xmm0
; SSE2-NEXT:    movq %rdi, %xmm1
; SSE2-NEXT:    punpckldq {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
; SSE2-NEXT:    subpd %xmm3, %xmm1
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm1[2,3,0,1]
; SSE2-NEXT:    addpd %xmm1, %xmm4
; SSE2-NEXT:    unpcklpd {{.*#+}} xmm0 = xmm0[0],xmm4[0]
; SSE2-NEXT:    movq %rcx, %xmm4
; SSE2-NEXT:    punpckldq {{.*#+}} xmm4 = xmm4[0],xmm2[0],xmm4[1],xmm2[1]
; SSE2-NEXT:    subpd %xmm3, %xmm4
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm4[2,3,0,1]
; SSE2-NEXT:    addpd %xmm4, %xmm1
; SSE2-NEXT:    movq %rax, %xmm4
; SSE2-NEXT:    punpckldq {{.*#+}} xmm4 = xmm4[0],xmm2[0],xmm4[1],xmm2[1]
; SSE2-NEXT:    subpd %xmm3, %xmm4
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm4[2,3,0,1]
; SSE2-NEXT:    addpd %xmm4, %xmm2
; SSE2-NEXT:    unpcklpd {{.*#+}} xmm1 = xmm1[0],xmm2[0]
; SSE2-NEXT:    retq
;
; SSE41-LABEL: trunc_unsigned_v4f64:
; SSE41:       # %bb.0:
; SSE41-NEXT:    roundpd $11, %xmm0, %xmm0
; SSE41-NEXT:    roundpd $11, %xmm1, %xmm1
; SSE41-NEXT:    retq
;
; AVX1-LABEL: trunc_unsigned_v4f64:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vroundpd $11, %ymm0, %ymm0
; AVX1-NEXT:    retq
  %i = fptoui <4 x double> %x to <4 x i64>
  %r = uitofp <4 x i64> %i to <4 x double>
  ret <4 x double> %r
}

define float @trunc_signed_f32(float %x) #0 {
; SSE2-LABEL: trunc_signed_f32:
; SSE2:       # %bb.0:
; SSE2-NEXT:    cvttss2si %xmm0, %eax
; SSE2-NEXT:    xorps %xmm0, %xmm0
; SSE2-NEXT:    cvtsi2ssl %eax, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: trunc_signed_f32:
; SSE41:       # %bb.0:
; SSE41-NEXT:    roundss $11, %xmm0, %xmm0
; SSE41-NEXT:    retq
;
; AVX1-LABEL: trunc_signed_f32:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vroundss $11, %xmm0, %xmm0, %xmm0
; AVX1-NEXT:    retq
  %i = fptosi float %x to i32
  %r = sitofp i32 %i to float
  ret float %r
}

define double @trunc_signed_f64(double %x) #0 {
; SSE2-LABEL: trunc_signed_f64:
; SSE2:       # %bb.0:
; SSE2-NEXT:    cvttsd2si %xmm0, %rax
; SSE2-NEXT:    xorps %xmm0, %xmm0
; SSE2-NEXT:    cvtsi2sdq %rax, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: trunc_signed_f64:
; SSE41:       # %bb.0:
; SSE41-NEXT:    roundsd $11, %xmm0, %xmm0
; SSE41-NEXT:    retq
;
; AVX1-LABEL: trunc_signed_f64:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vroundsd $11, %xmm0, %xmm0, %xmm0
; AVX1-NEXT:    retq
  %i = fptosi double %x to i64
  %r = sitofp i64 %i to double
  ret double %r
}

define <4 x float> @trunc_signed_v4f32(<4 x float> %x) #0 {
; SSE2-LABEL: trunc_signed_v4f32:
; SSE2:       # %bb.0:
; SSE2-NEXT:    cvttps2dq %xmm0, %xmm0
; SSE2-NEXT:    cvtdq2ps %xmm0, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: trunc_signed_v4f32:
; SSE41:       # %bb.0:
; SSE41-NEXT:    roundps $11, %xmm0, %xmm0
; SSE41-NEXT:    retq
;
; AVX1-LABEL: trunc_signed_v4f32:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vroundps $11, %xmm0, %xmm0
; AVX1-NEXT:    retq
  %i = fptosi <4 x float> %x to <4 x i32>
  %r = sitofp <4 x i32> %i to <4 x float>
  ret <4 x float> %r
}

define <2 x double> @trunc_signed_v2f64(<2 x double> %x) #0 {
; SSE2-LABEL: trunc_signed_v2f64:
; SSE2:       # %bb.0:
; SSE2-NEXT:    cvttsd2si %xmm0, %rax
; SSE2-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; SSE2-NEXT:    cvttsd2si %xmm0, %rcx
; SSE2-NEXT:    xorps %xmm0, %xmm0
; SSE2-NEXT:    cvtsi2sdq %rax, %xmm0
; SSE2-NEXT:    cvtsi2sdq %rcx, %xmm1
; SSE2-NEXT:    movlhps {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; SSE2-NEXT:    retq
;
; SSE41-LABEL: trunc_signed_v2f64:
; SSE41:       # %bb.0:
; SSE41-NEXT:    roundpd $11, %xmm0, %xmm0
; SSE41-NEXT:    retq
;
; AVX1-LABEL: trunc_signed_v2f64:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vroundpd $11, %xmm0, %xmm0
; AVX1-NEXT:    retq
  %i = fptosi <2 x double> %x to <2 x i64>
  %r = sitofp <2 x i64> %i to <2 x double>
  ret <2 x double> %r
}

define <4 x double> @trunc_signed_v4f64(<4 x double> %x) #0 {
; SSE2-LABEL: trunc_signed_v4f64:
; SSE2:       # %bb.0:
; SSE2-NEXT:    cvttsd2si %xmm1, %rax
; SSE2-NEXT:    movhlps {{.*#+}} xmm1 = xmm1[1,1]
; SSE2-NEXT:    cvttsd2si %xmm1, %rcx
; SSE2-NEXT:    cvttsd2si %xmm0, %rdx
; SSE2-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; SSE2-NEXT:    cvttsd2si %xmm0, %rsi
; SSE2-NEXT:    xorps %xmm0, %xmm0
; SSE2-NEXT:    cvtsi2sdq %rdx, %xmm0
; SSE2-NEXT:    xorps %xmm1, %xmm1
; SSE2-NEXT:    cvtsi2sdq %rsi, %xmm1
; SSE2-NEXT:    movlhps {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; SSE2-NEXT:    xorps %xmm1, %xmm1
; SSE2-NEXT:    cvtsi2sdq %rax, %xmm1
; SSE2-NEXT:    cvtsi2sdq %rcx, %xmm2
; SSE2-NEXT:    movlhps {{.*#+}} xmm1 = xmm1[0],xmm2[0]
; SSE2-NEXT:    retq
;
; SSE41-LABEL: trunc_signed_v4f64:
; SSE41:       # %bb.0:
; SSE41-NEXT:    roundpd $11, %xmm0, %xmm0
; SSE41-NEXT:    roundpd $11, %xmm1, %xmm1
; SSE41-NEXT:    retq
;
; AVX1-LABEL: trunc_signed_v4f64:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vroundpd $11, %ymm0, %ymm0
; AVX1-NEXT:    retq
  %i = fptosi <4 x double> %x to <4 x i64>
  %r = sitofp <4 x i64> %i to <4 x double>
  ret <4 x double> %r
}

; The fold may be guarded to allow existing code to continue 
; working based on its assumptions of float->int overflow.

define float @trunc_unsigned_f32_disable_via_attr(float %x) #1 {
; SSE2-LABEL: trunc_unsigned_f32_disable_via_attr:
; SSE2:       # %bb.0:
; SSE2-NEXT:    cvttss2si %xmm0, %rax
; SSE2-NEXT:    movl %eax, %eax
; SSE2-NEXT:    xorps %xmm0, %xmm0
; SSE2-NEXT:    cvtsi2ssq %rax, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: trunc_unsigned_f32_disable_via_attr:
; SSE41:       # %bb.0:
; SSE41-NEXT:    cvttss2si %xmm0, %rax
; SSE41-NEXT:    movl %eax, %eax
; SSE41-NEXT:    xorps %xmm0, %xmm0
; SSE41-NEXT:    cvtsi2ssq %rax, %xmm0
; SSE41-NEXT:    retq
;
; AVX1-LABEL: trunc_unsigned_f32_disable_via_attr:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vcvttss2si %xmm0, %rax
; AVX1-NEXT:    movl %eax, %eax
; AVX1-NEXT:    vcvtsi2ssq %rax, %xmm1, %xmm0
; AVX1-NEXT:    retq
  %i = fptoui float %x to i32
  %r = uitofp i32 %i to float
  ret float %r
}

define double @trunc_signed_f64_disable_via_attr(double %x) #1 {
; SSE2-LABEL: trunc_signed_f64_disable_via_attr:
; SSE2:       # %bb.0:
; SSE2-NEXT:    cvttsd2si %xmm0, %rax
; SSE2-NEXT:    xorps %xmm0, %xmm0
; SSE2-NEXT:    cvtsi2sdq %rax, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: trunc_signed_f64_disable_via_attr:
; SSE41:       # %bb.0:
; SSE41-NEXT:    cvttsd2si %xmm0, %rax
; SSE41-NEXT:    xorps %xmm0, %xmm0
; SSE41-NEXT:    cvtsi2sdq %rax, %xmm0
; SSE41-NEXT:    retq
;
; AVX1-LABEL: trunc_signed_f64_disable_via_attr:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vcvttsd2si %xmm0, %rax
; AVX1-NEXT:    vcvtsi2sdq %rax, %xmm1, %xmm0
; AVX1-NEXT:    retq
  %i = fptosi double %x to i64
  %r = sitofp i64 %i to double
  ret double %r
}

attributes #0 = { nounwind "no-signed-zeros-fp-math"="true" }
attributes #1 = { nounwind "no-signed-zeros-fp-math"="true" "strict-float-cast-overflow"="false" }

