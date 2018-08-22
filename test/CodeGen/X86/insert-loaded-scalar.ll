; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-- -mattr=+sse4.1 | FileCheck %s --check-prefixes=ALL,SSE
; RUN: llc < %s -mtriple=x86_64-- -mattr=+avx    | FileCheck %s --check-prefixes=ALL,AVX,AVX1
; RUN: llc < %s -mtriple=x86_64-- -mattr=+avx2   | FileCheck %s --check-prefixes=ALL,AVX,AVX2

define <16 x i8> @load8_ins_elt0_v16i8(i8* %p) nounwind {
; SSE-LABEL: load8_ins_elt0_v16i8:
; SSE:       # %bb.0:
; SSE-NEXT:    movzbl (%rdi), %eax
; SSE-NEXT:    movd %eax, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: load8_ins_elt0_v16i8:
; AVX:       # %bb.0:
; AVX-NEXT:    movzbl (%rdi), %eax
; AVX-NEXT:    vmovd %eax, %xmm0
; AVX-NEXT:    retq
  %x = load i8, i8* %p
  %ins = insertelement <16 x i8> undef, i8 %x, i32 0
  ret <16 x i8> %ins
}

define <8 x i16> @load16_ins_elt0_v8i16(i16* %p) nounwind {
; SSE-LABEL: load16_ins_elt0_v8i16:
; SSE:       # %bb.0:
; SSE-NEXT:    movzwl (%rdi), %eax
; SSE-NEXT:    movd %eax, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: load16_ins_elt0_v8i16:
; AVX:       # %bb.0:
; AVX-NEXT:    movzwl (%rdi), %eax
; AVX-NEXT:    vmovd %eax, %xmm0
; AVX-NEXT:    retq
  %x = load i16, i16* %p
  %ins = insertelement <8 x i16> undef, i16 %x, i32 0
  ret <8 x i16> %ins
}

define <4 x i32> @load32_ins_elt0_v4i32(i32* %p) nounwind {
; SSE-LABEL: load32_ins_elt0_v4i32:
; SSE:       # %bb.0:
; SSE-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSE-NEXT:    retq
;
; AVX-LABEL: load32_ins_elt0_v4i32:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX-NEXT:    retq
  %x = load i32, i32* %p
  %ins = insertelement <4 x i32> undef, i32 %x, i32 0
  ret <4 x i32> %ins
}

define <2 x i64> @load64_ins_elt0_v2i64(i64* %p) nounwind {
; SSE-LABEL: load64_ins_elt0_v2i64:
; SSE:       # %bb.0:
; SSE-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; SSE-NEXT:    retq
;
; AVX-LABEL: load64_ins_elt0_v2i64:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; AVX-NEXT:    retq
  %x = load i64, i64* %p
  %ins = insertelement <2 x i64> undef, i64 %x, i32 0
  ret <2 x i64> %ins
}

define <4 x float> @load32_ins_elt0_v4f32(float* %p) nounwind {
; SSE-LABEL: load32_ins_elt0_v4f32:
; SSE:       # %bb.0:
; SSE-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSE-NEXT:    retq
;
; AVX-LABEL: load32_ins_elt0_v4f32:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX-NEXT:    retq
  %x = load float, float* %p
  %ins = insertelement <4 x float> undef, float %x, i32 0
  ret <4 x float> %ins
}

define <2 x double> @load64_ins_elt0_v2f64(double* %p) nounwind {
; SSE-LABEL: load64_ins_elt0_v2f64:
; SSE:       # %bb.0:
; SSE-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; SSE-NEXT:    retq
;
; AVX-LABEL: load64_ins_elt0_v2f64:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; AVX-NEXT:    retq
  %x = load double, double* %p
  %ins = insertelement <2 x double> undef, double %x, i32 0
  ret <2 x double> %ins
}

define <16 x i8> @load8_ins_eltc_v16i8(i8* %p) nounwind {
; SSE-LABEL: load8_ins_eltc_v16i8:
; SSE:       # %bb.0:
; SSE-NEXT:    movzbl (%rdi), %eax
; SSE-NEXT:    movd %eax, %xmm0
; SSE-NEXT:    pslld $24, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: load8_ins_eltc_v16i8:
; AVX:       # %bb.0:
; AVX-NEXT:    movzbl (%rdi), %eax
; AVX-NEXT:    vmovd %eax, %xmm0
; AVX-NEXT:    vpslld $24, %xmm0, %xmm0
; AVX-NEXT:    retq
  %x = load i8, i8* %p
  %ins = insertelement <16 x i8> undef, i8 %x, i32 3
  ret <16 x i8> %ins
}

define <8 x i16> @load16_ins_eltc_v8i16(i16* %p) nounwind {
; SSE-LABEL: load16_ins_eltc_v8i16:
; SSE:       # %bb.0:
; SSE-NEXT:    movzwl (%rdi), %eax
; SSE-NEXT:    movd %eax, %xmm0
; SSE-NEXT:    pslldq {{.*#+}} xmm0 = zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,xmm0[0,1,2,3,4,5]
; SSE-NEXT:    retq
;
; AVX1-LABEL: load16_ins_eltc_v8i16:
; AVX1:       # %bb.0:
; AVX1-NEXT:    movzwl (%rdi), %eax
; AVX1-NEXT:    vmovd %eax, %xmm0
; AVX1-NEXT:    vpslldq {{.*#+}} xmm0 = zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,xmm0[0,1,2,3,4,5]
; AVX1-NEXT:    retq
;
; AVX2-LABEL: load16_ins_eltc_v8i16:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpbroadcastw (%rdi), %xmm0
; AVX2-NEXT:    retq
  %x = load i16, i16* %p
  %ins = insertelement <8 x i16> undef, i16 %x, i32 5
  ret <8 x i16> %ins
}

define <4 x i32> @load32_ins_eltc_v4i32(i32* %p) nounwind {
; SSE-LABEL: load32_ins_eltc_v4i32:
; SSE:       # %bb.0:
; SSE-NEXT:    movd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSE-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,1,0,1]
; SSE-NEXT:    retq
;
; AVX1-LABEL: load32_ins_eltc_v4i32:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX1-NEXT:    vpermilps {{.*#+}} xmm0 = xmm0[0,1,0,1]
; AVX1-NEXT:    retq
;
; AVX2-LABEL: load32_ins_eltc_v4i32:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vmovd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX2-NEXT:    vpbroadcastq %xmm0, %xmm0
; AVX2-NEXT:    retq
  %x = load i32, i32* %p
  %ins = insertelement <4 x i32> undef, i32 %x, i32 2
  ret <4 x i32> %ins
}

define <2 x i64> @load64_ins_eltc_v2i64(i64* %p) nounwind {
; SSE-LABEL: load64_ins_eltc_v2i64:
; SSE:       # %bb.0:
; SSE-NEXT:    movq {{.*#+}} xmm0 = mem[0],zero
; SSE-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,1,0,1]
; SSE-NEXT:    retq
;
; AVX1-LABEL: load64_ins_eltc_v2i64:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; AVX1-NEXT:    vpermilps {{.*#+}} xmm0 = xmm0[0,1,0,1]
; AVX1-NEXT:    retq
;
; AVX2-LABEL: load64_ins_eltc_v2i64:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpbroadcastq (%rdi), %xmm0
; AVX2-NEXT:    retq
  %x = load i64, i64* %p
  %ins = insertelement <2 x i64> undef, i64 %x, i32 1
  ret <2 x i64> %ins
}

define <4 x float> @load32_ins_eltc_v4f32(float* %p) nounwind {
; SSE-LABEL: load32_ins_eltc_v4f32:
; SSE:       # %bb.0:
; SSE-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSE-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,1,2,0]
; SSE-NEXT:    retq
;
; AVX-LABEL: load32_ins_eltc_v4f32:
; AVX:       # %bb.0:
; AVX-NEXT:    vbroadcastss (%rdi), %xmm0
; AVX-NEXT:    retq
  %x = load float, float* %p
  %ins = insertelement <4 x float> undef, float %x, i32 3
  ret <4 x float> %ins
}

define <2 x double> @load64_ins_eltc_v2f64(double* %p) nounwind {
; SSE-LABEL: load64_ins_eltc_v2f64:
; SSE:       # %bb.0:
; SSE-NEXT:    movddup {{.*#+}} xmm0 = mem[0,0]
; SSE-NEXT:    retq
;
; AVX-LABEL: load64_ins_eltc_v2f64:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovddup {{.*#+}} xmm0 = mem[0,0]
; AVX-NEXT:    retq
  %x = load double, double* %p
  %ins = insertelement <2 x double> undef, double %x, i32 1
  ret <2 x double> %ins
}

define <16 x i8> @load8_ins_eltx_v16i8(i8* %p, i32 %y) nounwind {
; SSE-LABEL: load8_ins_eltx_v16i8:
; SSE:       # %bb.0:
; SSE-NEXT:    # kill: def $esi killed $esi def $rsi
; SSE-NEXT:    movb (%rdi), %al
; SSE-NEXT:    andl $15, %esi
; SSE-NEXT:    movb %al, -24(%rsp,%rsi)
; SSE-NEXT:    movaps -{{[0-9]+}}(%rsp), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: load8_ins_eltx_v16i8:
; AVX:       # %bb.0:
; AVX-NEXT:    # kill: def $esi killed $esi def $rsi
; AVX-NEXT:    movb (%rdi), %al
; AVX-NEXT:    andl $15, %esi
; AVX-NEXT:    movb %al, -24(%rsp,%rsi)
; AVX-NEXT:    vmovaps -{{[0-9]+}}(%rsp), %xmm0
; AVX-NEXT:    retq
  %x = load i8, i8* %p
  %ins = insertelement <16 x i8> undef, i8 %x, i32 %y
  ret <16 x i8> %ins
}

define <8 x i16> @load16_ins_eltx_v8i16(i16* %p, i32 %y) nounwind {
; SSE-LABEL: load16_ins_eltx_v8i16:
; SSE:       # %bb.0:
; SSE-NEXT:    # kill: def $esi killed $esi def $rsi
; SSE-NEXT:    movzwl (%rdi), %eax
; SSE-NEXT:    andl $7, %esi
; SSE-NEXT:    movw %ax, -24(%rsp,%rsi,2)
; SSE-NEXT:    movaps -{{[0-9]+}}(%rsp), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: load16_ins_eltx_v8i16:
; AVX:       # %bb.0:
; AVX-NEXT:    # kill: def $esi killed $esi def $rsi
; AVX-NEXT:    movzwl (%rdi), %eax
; AVX-NEXT:    andl $7, %esi
; AVX-NEXT:    movw %ax, -24(%rsp,%rsi,2)
; AVX-NEXT:    vmovaps -{{[0-9]+}}(%rsp), %xmm0
; AVX-NEXT:    retq
  %x = load i16, i16* %p
  %ins = insertelement <8 x i16> undef, i16 %x, i32 %y
  ret <8 x i16> %ins
}

define <4 x i32> @load32_ins_eltx_v4i32(i32* %p, i32 %y) nounwind {
; SSE-LABEL: load32_ins_eltx_v4i32:
; SSE:       # %bb.0:
; SSE-NEXT:    # kill: def $esi killed $esi def $rsi
; SSE-NEXT:    movl (%rdi), %eax
; SSE-NEXT:    andl $3, %esi
; SSE-NEXT:    movl %eax, -24(%rsp,%rsi,4)
; SSE-NEXT:    movaps -{{[0-9]+}}(%rsp), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: load32_ins_eltx_v4i32:
; AVX:       # %bb.0:
; AVX-NEXT:    # kill: def $esi killed $esi def $rsi
; AVX-NEXT:    movl (%rdi), %eax
; AVX-NEXT:    andl $3, %esi
; AVX-NEXT:    movl %eax, -24(%rsp,%rsi,4)
; AVX-NEXT:    vmovaps -{{[0-9]+}}(%rsp), %xmm0
; AVX-NEXT:    retq
  %x = load i32, i32* %p
  %ins = insertelement <4 x i32> undef, i32 %x, i32 %y
  ret <4 x i32> %ins
}

define <2 x i64> @load64_ins_eltx_v2i64(i64* %p, i32 %y) nounwind {
; SSE-LABEL: load64_ins_eltx_v2i64:
; SSE:       # %bb.0:
; SSE-NEXT:    # kill: def $esi killed $esi def $rsi
; SSE-NEXT:    movq (%rdi), %rax
; SSE-NEXT:    andl $1, %esi
; SSE-NEXT:    movq %rax, -24(%rsp,%rsi,8)
; SSE-NEXT:    movaps -{{[0-9]+}}(%rsp), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: load64_ins_eltx_v2i64:
; AVX:       # %bb.0:
; AVX-NEXT:    # kill: def $esi killed $esi def $rsi
; AVX-NEXT:    movq (%rdi), %rax
; AVX-NEXT:    andl $1, %esi
; AVX-NEXT:    movq %rax, -24(%rsp,%rsi,8)
; AVX-NEXT:    vmovaps -{{[0-9]+}}(%rsp), %xmm0
; AVX-NEXT:    retq
  %x = load i64, i64* %p
  %ins = insertelement <2 x i64> undef, i64 %x, i32 %y
  ret <2 x i64> %ins
}

define <4 x float> @load32_ins_eltx_v4f32(float* %p, i32 %y) nounwind {
; SSE-LABEL: load32_ins_eltx_v4f32:
; SSE:       # %bb.0:
; SSE-NEXT:    # kill: def $esi killed $esi def $rsi
; SSE-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSE-NEXT:    andl $3, %esi
; SSE-NEXT:    movss %xmm0, -24(%rsp,%rsi,4)
; SSE-NEXT:    movaps -{{[0-9]+}}(%rsp), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: load32_ins_eltx_v4f32:
; AVX:       # %bb.0:
; AVX-NEXT:    # kill: def $esi killed $esi def $rsi
; AVX-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX-NEXT:    andl $3, %esi
; AVX-NEXT:    vmovss %xmm0, -24(%rsp,%rsi,4)
; AVX-NEXT:    vmovaps -{{[0-9]+}}(%rsp), %xmm0
; AVX-NEXT:    retq
  %x = load float, float* %p
  %ins = insertelement <4 x float> undef, float %x, i32 %y
  ret <4 x float> %ins
}

define <2 x double> @load64_ins_eltx_v2f64(double* %p, i32 %y) nounwind {
; SSE-LABEL: load64_ins_eltx_v2f64:
; SSE:       # %bb.0:
; SSE-NEXT:    # kill: def $esi killed $esi def $rsi
; SSE-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; SSE-NEXT:    andl $1, %esi
; SSE-NEXT:    movsd %xmm0, -24(%rsp,%rsi,8)
; SSE-NEXT:    movaps -{{[0-9]+}}(%rsp), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: load64_ins_eltx_v2f64:
; AVX:       # %bb.0:
; AVX-NEXT:    # kill: def $esi killed $esi def $rsi
; AVX-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; AVX-NEXT:    andl $1, %esi
; AVX-NEXT:    vmovsd %xmm0, -24(%rsp,%rsi,8)
; AVX-NEXT:    vmovaps -{{[0-9]+}}(%rsp), %xmm0
; AVX-NEXT:    retq
  %x = load double, double* %p
  %ins = insertelement <2 x double> undef, double %x, i32 %y
  ret <2 x double> %ins
}

define <32 x i8> @load8_ins_elt0_v32i8(i8* %p) nounwind {
; SSE-LABEL: load8_ins_elt0_v32i8:
; SSE:       # %bb.0:
; SSE-NEXT:    movzbl (%rdi), %eax
; SSE-NEXT:    movd %eax, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: load8_ins_elt0_v32i8:
; AVX:       # %bb.0:
; AVX-NEXT:    movzbl (%rdi), %eax
; AVX-NEXT:    vmovd %eax, %xmm0
; AVX-NEXT:    retq
  %x = load i8, i8* %p
  %ins = insertelement <32 x i8> undef, i8 %x, i32 0
  ret <32 x i8> %ins
}

define <16 x i16> @load16_ins_elt0_v16i16(i16* %p) nounwind {
; SSE-LABEL: load16_ins_elt0_v16i16:
; SSE:       # %bb.0:
; SSE-NEXT:    movzwl (%rdi), %eax
; SSE-NEXT:    movd %eax, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: load16_ins_elt0_v16i16:
; AVX:       # %bb.0:
; AVX-NEXT:    movzwl (%rdi), %eax
; AVX-NEXT:    vmovd %eax, %xmm0
; AVX-NEXT:    retq
  %x = load i16, i16* %p
  %ins = insertelement <16 x i16> undef, i16 %x, i32 0
  ret <16 x i16> %ins
}

define <8 x i32> @load32_ins_elt0_v8i32(i32* %p) nounwind {
; SSE-LABEL: load32_ins_elt0_v8i32:
; SSE:       # %bb.0:
; SSE-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSE-NEXT:    retq
;
; AVX-LABEL: load32_ins_elt0_v8i32:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX-NEXT:    retq
  %x = load i32, i32* %p
  %ins = insertelement <8 x i32> undef, i32 %x, i32 0
  ret <8 x i32> %ins
}

define <4 x i64> @load64_ins_elt0_v4i64(i64* %p) nounwind {
; SSE-LABEL: load64_ins_elt0_v4i64:
; SSE:       # %bb.0:
; SSE-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; SSE-NEXT:    retq
;
; AVX-LABEL: load64_ins_elt0_v4i64:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; AVX-NEXT:    retq
  %x = load i64, i64* %p
  %ins = insertelement <4 x i64> undef, i64 %x, i32 0
  ret <4 x i64> %ins
}

define <8 x float> @load32_ins_elt0_v8f32(float* %p) nounwind {
; SSE-LABEL: load32_ins_elt0_v8f32:
; SSE:       # %bb.0:
; SSE-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSE-NEXT:    retq
;
; AVX-LABEL: load32_ins_elt0_v8f32:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX-NEXT:    retq
  %x = load float, float* %p
  %ins = insertelement <8 x float> undef, float %x, i32 0
  ret <8 x float> %ins
}

define <4 x double> @load64_ins_elt0_v4f64(double* %p) nounwind {
; SSE-LABEL: load64_ins_elt0_v4f64:
; SSE:       # %bb.0:
; SSE-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; SSE-NEXT:    retq
;
; AVX-LABEL: load64_ins_elt0_v4f64:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; AVX-NEXT:    retq
  %x = load double, double* %p
  %ins = insertelement <4 x double> undef, double %x, i32 0
  ret <4 x double> %ins
}

define <32 x i8> @load8_ins_eltc_v32i8(i8* %p) nounwind {
; SSE-LABEL: load8_ins_eltc_v32i8:
; SSE:       # %bb.0:
; SSE-NEXT:    movzbl (%rdi), %eax
; SSE-NEXT:    movd %eax, %xmm1
; SSE-NEXT:    psllq $40, %xmm1
; SSE-NEXT:    retq
;
; AVX1-LABEL: load8_ins_eltc_v32i8:
; AVX1:       # %bb.0:
; AVX1-NEXT:    movzbl (%rdi), %eax
; AVX1-NEXT:    vmovd %eax, %xmm0
; AVX1-NEXT:    vpsllq $40, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: load8_ins_eltc_v32i8:
; AVX2:       # %bb.0:
; AVX2-NEXT:    movzbl (%rdi), %eax
; AVX2-NEXT:    vmovd %eax, %xmm0
; AVX2-NEXT:    vpsllq $40, %xmm0, %xmm0
; AVX2-NEXT:    vinserti128 $1, %xmm0, %ymm0, %ymm0
; AVX2-NEXT:    retq
  %x = load i8, i8* %p
  %ins = insertelement <32 x i8> undef, i8 %x, i32 21
  ret <32 x i8> %ins
}

define <16 x i16> @load16_ins_eltc_v16i16(i16* %p) nounwind {
; SSE-LABEL: load16_ins_eltc_v16i16:
; SSE:       # %bb.0:
; SSE-NEXT:    movzwl (%rdi), %eax
; SSE-NEXT:    movd %eax, %xmm1
; SSE-NEXT:    psllq $48, %xmm1
; SSE-NEXT:    retq
;
; AVX1-LABEL: load16_ins_eltc_v16i16:
; AVX1:       # %bb.0:
; AVX1-NEXT:    movzwl (%rdi), %eax
; AVX1-NEXT:    vmovd %eax, %xmm0
; AVX1-NEXT:    vpsllq $48, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: load16_ins_eltc_v16i16:
; AVX2:       # %bb.0:
; AVX2-NEXT:    movzwl (%rdi), %eax
; AVX2-NEXT:    vmovd %eax, %xmm0
; AVX2-NEXT:    vpbroadcastw %xmm0, %xmm0
; AVX2-NEXT:    vinserti128 $1, %xmm0, %ymm0, %ymm0
; AVX2-NEXT:    retq
  %x = load i16, i16* %p
  %ins = insertelement <16 x i16> undef, i16 %x, i32 11
  ret <16 x i16> %ins
}

define <8 x i32> @load32_ins_eltc_v8i32(i32* %p) nounwind {
; SSE-LABEL: load32_ins_eltc_v8i32:
; SSE:       # %bb.0:
; SSE-NEXT:    movd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSE-NEXT:    pshufd {{.*#+}} xmm1 = xmm0[0,1,2,0]
; SSE-NEXT:    retq
;
; AVX1-LABEL: load32_ins_eltc_v8i32:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX1-NEXT:    vpermilps {{.*#+}} xmm0 = xmm0[0,1,2,0]
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: load32_ins_eltc_v8i32:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vbroadcastss (%rdi), %xmm0
; AVX2-NEXT:    vinsertf128 $1, %xmm0, %ymm0, %ymm0
; AVX2-NEXT:    retq
  %x = load i32, i32* %p
  %ins = insertelement <8 x i32> undef, i32 %x, i32 7
  ret <8 x i32> %ins
}

define <4 x i64> @load64_ins_eltc_v4i64(i64* %p) nounwind {
; SSE-LABEL: load64_ins_eltc_v4i64:
; SSE:       # %bb.0:
; SSE-NEXT:    movq {{.*#+}} xmm0 = mem[0],zero
; SSE-NEXT:    pshufd {{.*#+}} xmm1 = xmm0[0,1,0,1]
; SSE-NEXT:    retq
;
; AVX1-LABEL: load64_ins_eltc_v4i64:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; AVX1-NEXT:    vpermilps {{.*#+}} xmm0 = xmm0[0,1,0,1]
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: load64_ins_eltc_v4i64:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vbroadcastsd (%rdi), %ymm0
; AVX2-NEXT:    retq
  %x = load i64, i64* %p
  %ins = insertelement <4 x i64> undef, i64 %x, i32 3
  ret <4 x i64> %ins
}

define <8 x float> @load32_ins_eltc_v8f32(float* %p) nounwind {
; SSE-LABEL: load32_ins_eltc_v8f32:
; SSE:       # %bb.0:
; SSE-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSE-NEXT:    movsldup {{.*#+}} xmm1 = xmm0[0,0,2,2]
; SSE-NEXT:    retq
;
; AVX1-LABEL: load32_ins_eltc_v8f32:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX1-NEXT:    vmovsldup {{.*#+}} xmm0 = xmm0[0,0,2,2]
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: load32_ins_eltc_v8f32:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vbroadcastss (%rdi), %xmm0
; AVX2-NEXT:    vinsertf128 $1, %xmm0, %ymm0, %ymm0
; AVX2-NEXT:    retq
  %x = load float, float* %p
  %ins = insertelement <8 x float> undef, float %x, i32 5
  ret <8 x float> %ins
}

define <4 x double> @load64_ins_eltc_v4f64(double* %p) nounwind {
; SSE-LABEL: load64_ins_eltc_v4f64:
; SSE:       # %bb.0:
; SSE-NEXT:    movddup {{.*#+}} xmm1 = mem[0,0]
; SSE-NEXT:    retq
;
; AVX1-LABEL: load64_ins_eltc_v4f64:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmovddup {{.*#+}} xmm0 = mem[0,0]
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: load64_ins_eltc_v4f64:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vbroadcastsd (%rdi), %ymm0
; AVX2-NEXT:    retq
  %x = load double, double* %p
  %ins = insertelement <4 x double> undef, double %x, i32 3
  ret <4 x double> %ins
}

define <32 x i8> @load8_ins_eltx_v32i8(i8* %p, i32 %y) nounwind {
; SSE-LABEL: load8_ins_eltx_v32i8:
; SSE:       # %bb.0:
; SSE-NEXT:    pushq %rbp
; SSE-NEXT:    movq %rsp, %rbp
; SSE-NEXT:    andq $-32, %rsp
; SSE-NEXT:    subq $64, %rsp
; SSE-NEXT:    # kill: def $esi killed $esi def $rsi
; SSE-NEXT:    movb (%rdi), %al
; SSE-NEXT:    andl $31, %esi
; SSE-NEXT:    movb %al, (%rsp,%rsi)
; SSE-NEXT:    movaps (%rsp), %xmm0
; SSE-NEXT:    movaps {{[0-9]+}}(%rsp), %xmm1
; SSE-NEXT:    movq %rbp, %rsp
; SSE-NEXT:    popq %rbp
; SSE-NEXT:    retq
;
; AVX-LABEL: load8_ins_eltx_v32i8:
; AVX:       # %bb.0:
; AVX-NEXT:    pushq %rbp
; AVX-NEXT:    movq %rsp, %rbp
; AVX-NEXT:    andq $-32, %rsp
; AVX-NEXT:    subq $64, %rsp
; AVX-NEXT:    # kill: def $esi killed $esi def $rsi
; AVX-NEXT:    movb (%rdi), %al
; AVX-NEXT:    andl $31, %esi
; AVX-NEXT:    movb %al, (%rsp,%rsi)
; AVX-NEXT:    vmovaps (%rsp), %ymm0
; AVX-NEXT:    movq %rbp, %rsp
; AVX-NEXT:    popq %rbp
; AVX-NEXT:    retq
  %x = load i8, i8* %p
  %ins = insertelement <32 x i8> undef, i8 %x, i32 %y
  ret <32 x i8> %ins
}

define <16 x i16> @load16_ins_eltx_v16i16(i16* %p, i32 %y) nounwind {
; SSE-LABEL: load16_ins_eltx_v16i16:
; SSE:       # %bb.0:
; SSE-NEXT:    pushq %rbp
; SSE-NEXT:    movq %rsp, %rbp
; SSE-NEXT:    andq $-32, %rsp
; SSE-NEXT:    subq $64, %rsp
; SSE-NEXT:    # kill: def $esi killed $esi def $rsi
; SSE-NEXT:    movzwl (%rdi), %eax
; SSE-NEXT:    andl $15, %esi
; SSE-NEXT:    movw %ax, (%rsp,%rsi,2)
; SSE-NEXT:    movaps (%rsp), %xmm0
; SSE-NEXT:    movaps {{[0-9]+}}(%rsp), %xmm1
; SSE-NEXT:    movq %rbp, %rsp
; SSE-NEXT:    popq %rbp
; SSE-NEXT:    retq
;
; AVX-LABEL: load16_ins_eltx_v16i16:
; AVX:       # %bb.0:
; AVX-NEXT:    pushq %rbp
; AVX-NEXT:    movq %rsp, %rbp
; AVX-NEXT:    andq $-32, %rsp
; AVX-NEXT:    subq $64, %rsp
; AVX-NEXT:    # kill: def $esi killed $esi def $rsi
; AVX-NEXT:    movzwl (%rdi), %eax
; AVX-NEXT:    andl $15, %esi
; AVX-NEXT:    movw %ax, (%rsp,%rsi,2)
; AVX-NEXT:    vmovaps (%rsp), %ymm0
; AVX-NEXT:    movq %rbp, %rsp
; AVX-NEXT:    popq %rbp
; AVX-NEXT:    retq
  %x = load i16, i16* %p
  %ins = insertelement <16 x i16> undef, i16 %x, i32 %y
  ret <16 x i16> %ins
}

define <8 x i32> @load32_ins_eltx_v8i32(i32* %p, i32 %y) nounwind {
; SSE-LABEL: load32_ins_eltx_v8i32:
; SSE:       # %bb.0:
; SSE-NEXT:    pushq %rbp
; SSE-NEXT:    movq %rsp, %rbp
; SSE-NEXT:    andq $-32, %rsp
; SSE-NEXT:    subq $64, %rsp
; SSE-NEXT:    # kill: def $esi killed $esi def $rsi
; SSE-NEXT:    movl (%rdi), %eax
; SSE-NEXT:    andl $7, %esi
; SSE-NEXT:    movl %eax, (%rsp,%rsi,4)
; SSE-NEXT:    movaps (%rsp), %xmm0
; SSE-NEXT:    movaps {{[0-9]+}}(%rsp), %xmm1
; SSE-NEXT:    movq %rbp, %rsp
; SSE-NEXT:    popq %rbp
; SSE-NEXT:    retq
;
; AVX-LABEL: load32_ins_eltx_v8i32:
; AVX:       # %bb.0:
; AVX-NEXT:    pushq %rbp
; AVX-NEXT:    movq %rsp, %rbp
; AVX-NEXT:    andq $-32, %rsp
; AVX-NEXT:    subq $64, %rsp
; AVX-NEXT:    # kill: def $esi killed $esi def $rsi
; AVX-NEXT:    movl (%rdi), %eax
; AVX-NEXT:    andl $7, %esi
; AVX-NEXT:    movl %eax, (%rsp,%rsi,4)
; AVX-NEXT:    vmovaps (%rsp), %ymm0
; AVX-NEXT:    movq %rbp, %rsp
; AVX-NEXT:    popq %rbp
; AVX-NEXT:    retq
  %x = load i32, i32* %p
  %ins = insertelement <8 x i32> undef, i32 %x, i32 %y
  ret <8 x i32> %ins
}

define <4 x i64> @load64_ins_eltx_v4i64(i64* %p, i32 %y) nounwind {
; SSE-LABEL: load64_ins_eltx_v4i64:
; SSE:       # %bb.0:
; SSE-NEXT:    pushq %rbp
; SSE-NEXT:    movq %rsp, %rbp
; SSE-NEXT:    andq $-32, %rsp
; SSE-NEXT:    subq $64, %rsp
; SSE-NEXT:    # kill: def $esi killed $esi def $rsi
; SSE-NEXT:    movq (%rdi), %rax
; SSE-NEXT:    andl $3, %esi
; SSE-NEXT:    movq %rax, (%rsp,%rsi,8)
; SSE-NEXT:    movaps (%rsp), %xmm0
; SSE-NEXT:    movaps {{[0-9]+}}(%rsp), %xmm1
; SSE-NEXT:    movq %rbp, %rsp
; SSE-NEXT:    popq %rbp
; SSE-NEXT:    retq
;
; AVX-LABEL: load64_ins_eltx_v4i64:
; AVX:       # %bb.0:
; AVX-NEXT:    pushq %rbp
; AVX-NEXT:    movq %rsp, %rbp
; AVX-NEXT:    andq $-32, %rsp
; AVX-NEXT:    subq $64, %rsp
; AVX-NEXT:    # kill: def $esi killed $esi def $rsi
; AVX-NEXT:    movq (%rdi), %rax
; AVX-NEXT:    andl $3, %esi
; AVX-NEXT:    movq %rax, (%rsp,%rsi,8)
; AVX-NEXT:    vmovaps (%rsp), %ymm0
; AVX-NEXT:    movq %rbp, %rsp
; AVX-NEXT:    popq %rbp
; AVX-NEXT:    retq
  %x = load i64, i64* %p
  %ins = insertelement <4 x i64> undef, i64 %x, i32 %y
  ret <4 x i64> %ins
}

define <8 x float> @load32_ins_eltx_v8f32(float* %p, i32 %y) nounwind {
; SSE-LABEL: load32_ins_eltx_v8f32:
; SSE:       # %bb.0:
; SSE-NEXT:    pushq %rbp
; SSE-NEXT:    movq %rsp, %rbp
; SSE-NEXT:    andq $-32, %rsp
; SSE-NEXT:    subq $64, %rsp
; SSE-NEXT:    # kill: def $esi killed $esi def $rsi
; SSE-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSE-NEXT:    andl $7, %esi
; SSE-NEXT:    movss %xmm0, (%rsp,%rsi,4)
; SSE-NEXT:    movaps (%rsp), %xmm0
; SSE-NEXT:    movaps {{[0-9]+}}(%rsp), %xmm1
; SSE-NEXT:    movq %rbp, %rsp
; SSE-NEXT:    popq %rbp
; SSE-NEXT:    retq
;
; AVX-LABEL: load32_ins_eltx_v8f32:
; AVX:       # %bb.0:
; AVX-NEXT:    pushq %rbp
; AVX-NEXT:    movq %rsp, %rbp
; AVX-NEXT:    andq $-32, %rsp
; AVX-NEXT:    subq $64, %rsp
; AVX-NEXT:    # kill: def $esi killed $esi def $rsi
; AVX-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX-NEXT:    andl $7, %esi
; AVX-NEXT:    vmovss %xmm0, (%rsp,%rsi,4)
; AVX-NEXT:    vmovaps (%rsp), %ymm0
; AVX-NEXT:    movq %rbp, %rsp
; AVX-NEXT:    popq %rbp
; AVX-NEXT:    retq
  %x = load float, float* %p
  %ins = insertelement <8 x float> undef, float %x, i32 %y
  ret <8 x float> %ins
}

define <4 x double> @load64_ins_eltx_v4f64(double* %p, i32 %y) nounwind {
; SSE-LABEL: load64_ins_eltx_v4f64:
; SSE:       # %bb.0:
; SSE-NEXT:    pushq %rbp
; SSE-NEXT:    movq %rsp, %rbp
; SSE-NEXT:    andq $-32, %rsp
; SSE-NEXT:    subq $64, %rsp
; SSE-NEXT:    # kill: def $esi killed $esi def $rsi
; SSE-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; SSE-NEXT:    andl $3, %esi
; SSE-NEXT:    movsd %xmm0, (%rsp,%rsi,8)
; SSE-NEXT:    movaps (%rsp), %xmm0
; SSE-NEXT:    movaps {{[0-9]+}}(%rsp), %xmm1
; SSE-NEXT:    movq %rbp, %rsp
; SSE-NEXT:    popq %rbp
; SSE-NEXT:    retq
;
; AVX-LABEL: load64_ins_eltx_v4f64:
; AVX:       # %bb.0:
; AVX-NEXT:    pushq %rbp
; AVX-NEXT:    movq %rsp, %rbp
; AVX-NEXT:    andq $-32, %rsp
; AVX-NEXT:    subq $64, %rsp
; AVX-NEXT:    # kill: def $esi killed $esi def $rsi
; AVX-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; AVX-NEXT:    andl $3, %esi
; AVX-NEXT:    vmovsd %xmm0, (%rsp,%rsi,8)
; AVX-NEXT:    vmovaps (%rsp), %ymm0
; AVX-NEXT:    movq %rbp, %rsp
; AVX-NEXT:    popq %rbp
; AVX-NEXT:    retq
  %x = load double, double* %p
  %ins = insertelement <4 x double> undef, double %x, i32 %y
  ret <4 x double> %ins
}

