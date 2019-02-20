; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -disable-peephole -mtriple=i686-unknown-unknown   -mattr=+sse2     | FileCheck %s --check-prefix=X32SSE --check-prefix=X32SSE2
; RUN: llc < %s -disable-peephole -mtriple=x86_64-unknown-unknown -mattr=+sse2     | FileCheck %s --check-prefix=X64SSE --check-prefix=X64SSE2
; RUN: llc < %s -disable-peephole -mtriple=i686-unknown-unknown   -mattr=+sse4.1   | FileCheck %s --check-prefix=X32SSE --check-prefix=X32SSE4
; RUN: llc < %s -disable-peephole -mtriple=x86_64-unknown-unknown -mattr=+sse4.1   | FileCheck %s --check-prefix=X64SSE --check-prefix=X64SSE4
; RUN: llc < %s -disable-peephole -mtriple=i686-unknown-unknown   -mattr=+avx      | FileCheck %s --check-prefix=X32AVX --check-prefix=X32AVX1
; RUN: llc < %s -disable-peephole -mtriple=x86_64-unknown-unknown -mattr=+avx      | FileCheck %s --check-prefix=X64AVX --check-prefix=X64AVX1
; RUN: llc < %s -disable-peephole -mtriple=i686-unknown-unknown   -mattr=+avx2     | FileCheck %s --check-prefix=X32AVX --check-prefix=X32AVX2
; RUN: llc < %s -disable-peephole -mtriple=x86_64-unknown-unknown -mattr=+avx2     | FileCheck %s --check-prefix=X64AVX --check-prefix=X64AVX2
; RUN: llc < %s -disable-peephole -mtriple=i686-unknown-unknown   -mattr=+avx512f  | FileCheck %s --check-prefix=X32AVX --check-prefix=X32AVX512F
; RUN: llc < %s -disable-peephole -mtriple=x86_64-unknown-unknown -mattr=+avx512f  | FileCheck %s --check-prefix=X64AVX --check-prefix=X64AVX512F

define <16 x i8> @elt0_v16i8(i8 %x) {
; X32SSE2-LABEL: elt0_v16i8:
; X32SSE2:       # %bb.0:
; X32SSE2-NEXT:    movss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; X32SSE2-NEXT:    movaps {{.*#+}} xmm0 = [0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255]
; X32SSE2-NEXT:    andnps %xmm1, %xmm0
; X32SSE2-NEXT:    orps {{\.LCPI.*}}, %xmm0
; X32SSE2-NEXT:    retl
;
; X64SSE2-LABEL: elt0_v16i8:
; X64SSE2:       # %bb.0:
; X64SSE2-NEXT:    movd %edi, %xmm1
; X64SSE2-NEXT:    movdqa {{.*#+}} xmm0 = [0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255]
; X64SSE2-NEXT:    pandn %xmm1, %xmm0
; X64SSE2-NEXT:    por {{.*}}(%rip), %xmm0
; X64SSE2-NEXT:    retq
;
; X32SSE4-LABEL: elt0_v16i8:
; X32SSE4:       # %bb.0:
; X32SSE4-NEXT:    movdqa {{.*#+}} xmm0 = <u,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15>
; X32SSE4-NEXT:    pinsrb $0, {{[0-9]+}}(%esp), %xmm0
; X32SSE4-NEXT:    retl
;
; X64SSE4-LABEL: elt0_v16i8:
; X64SSE4:       # %bb.0:
; X64SSE4-NEXT:    movdqa {{.*#+}} xmm0 = <u,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15>
; X64SSE4-NEXT:    pinsrb $0, %edi, %xmm0
; X64SSE4-NEXT:    retq
;
; X32AVX-LABEL: elt0_v16i8:
; X32AVX:       # %bb.0:
; X32AVX-NEXT:    vmovdqa {{.*#+}} xmm0 = <u,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15>
; X32AVX-NEXT:    vpinsrb $0, {{[0-9]+}}(%esp), %xmm0, %xmm0
; X32AVX-NEXT:    retl
;
; X64AVX-LABEL: elt0_v16i8:
; X64AVX:       # %bb.0:
; X64AVX-NEXT:    vmovdqa {{.*#+}} xmm0 = <u,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15>
; X64AVX-NEXT:    vpinsrb $0, %edi, %xmm0, %xmm0
; X64AVX-NEXT:    retq
   %ins = insertelement <16 x i8> <i8 42, i8 1, i8 2, i8 3, i8 4, i8 5, i8 6, i8 7, i8 8, i8 9, i8 10, i8 11, i8 12, i8 13, i8 14, i8 15>, i8 %x, i32 0
   ret <16 x i8> %ins
}

define <8 x i16> @elt5_v8i16(i16 %x) {
; X32SSE-LABEL: elt5_v8i16:
; X32SSE:       # %bb.0:
; X32SSE-NEXT:    movdqa {{.*#+}} xmm0 = <42,1,2,3,4,u,6,7>
; X32SSE-NEXT:    pinsrw $5, {{[0-9]+}}(%esp), %xmm0
; X32SSE-NEXT:    retl
;
; X64SSE-LABEL: elt5_v8i16:
; X64SSE:       # %bb.0:
; X64SSE-NEXT:    movdqa {{.*#+}} xmm0 = <42,1,2,3,4,u,6,7>
; X64SSE-NEXT:    pinsrw $5, %edi, %xmm0
; X64SSE-NEXT:    retq
;
; X32AVX-LABEL: elt5_v8i16:
; X32AVX:       # %bb.0:
; X32AVX-NEXT:    vmovdqa {{.*#+}} xmm0 = <42,1,2,3,4,u,6,7>
; X32AVX-NEXT:    vpinsrw $5, {{[0-9]+}}(%esp), %xmm0, %xmm0
; X32AVX-NEXT:    retl
;
; X64AVX-LABEL: elt5_v8i16:
; X64AVX:       # %bb.0:
; X64AVX-NEXT:    vmovdqa {{.*#+}} xmm0 = <42,1,2,3,4,u,6,7>
; X64AVX-NEXT:    vpinsrw $5, %edi, %xmm0, %xmm0
; X64AVX-NEXT:    retq
   %ins = insertelement <8 x i16> <i16 42, i16 1, i16 2, i16 3, i16 4, i16 5, i16 6, i16 7>, i16 %x, i32 5
   ret <8 x i16> %ins
}

define <4 x i32> @elt3_v4i32(i32 %x) {
; X32SSE2-LABEL: elt3_v4i32:
; X32SSE2:       # %bb.0:
; X32SSE2-NEXT:    movaps {{.*#+}} xmm0 = <42,1,2,u>
; X32SSE2-NEXT:    movss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; X32SSE2-NEXT:    shufps {{.*#+}} xmm1 = xmm1[0,0],xmm0[2,0]
; X32SSE2-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,1],xmm1[2,0]
; X32SSE2-NEXT:    retl
;
; X64SSE2-LABEL: elt3_v4i32:
; X64SSE2:       # %bb.0:
; X64SSE2-NEXT:    movd %edi, %xmm1
; X64SSE2-NEXT:    movaps {{.*#+}} xmm0 = <42,1,2,u>
; X64SSE2-NEXT:    shufps {{.*#+}} xmm1 = xmm1[0,0],xmm0[2,0]
; X64SSE2-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,1],xmm1[2,0]
; X64SSE2-NEXT:    retq
;
; X32SSE4-LABEL: elt3_v4i32:
; X32SSE4:       # %bb.0:
; X32SSE4-NEXT:    movdqa {{.*#+}} xmm0 = <42,1,2,u>
; X32SSE4-NEXT:    pinsrd $3, {{[0-9]+}}(%esp), %xmm0
; X32SSE4-NEXT:    retl
;
; X64SSE4-LABEL: elt3_v4i32:
; X64SSE4:       # %bb.0:
; X64SSE4-NEXT:    movdqa {{.*#+}} xmm0 = <42,1,2,u>
; X64SSE4-NEXT:    pinsrd $3, %edi, %xmm0
; X64SSE4-NEXT:    retq
;
; X32AVX-LABEL: elt3_v4i32:
; X32AVX:       # %bb.0:
; X32AVX-NEXT:    vmovdqa {{.*#+}} xmm0 = <42,1,2,u>
; X32AVX-NEXT:    vpinsrd $3, {{[0-9]+}}(%esp), %xmm0, %xmm0
; X32AVX-NEXT:    retl
;
; X64AVX-LABEL: elt3_v4i32:
; X64AVX:       # %bb.0:
; X64AVX-NEXT:    vmovdqa {{.*#+}} xmm0 = <42,1,2,u>
; X64AVX-NEXT:    vpinsrd $3, %edi, %xmm0, %xmm0
; X64AVX-NEXT:    retq
   %ins = insertelement <4 x i32> <i32 42, i32 1, i32 2, i32 3>, i32 %x, i32 3
   ret <4 x i32> %ins
}

define <2 x i64> @elt0_v2i64(i64 %x) {
; X32SSE-LABEL: elt0_v2i64:
; X32SSE:       # %bb.0:
; X32SSE-NEXT:    movl $1, %eax
; X32SSE-NEXT:    movd %eax, %xmm1
; X32SSE-NEXT:    movq {{.*#+}} xmm0 = mem[0],zero
; X32SSE-NEXT:    punpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; X32SSE-NEXT:    retl
;
; X64SSE2-LABEL: elt0_v2i64:
; X64SSE2:       # %bb.0:
; X64SSE2-NEXT:    movq %rdi, %xmm1
; X64SSE2-NEXT:    movapd {{.*#+}} xmm0 = <u,1>
; X64SSE2-NEXT:    movsd {{.*#+}} xmm0 = xmm1[0],xmm0[1]
; X64SSE2-NEXT:    retq
;
; X64SSE4-LABEL: elt0_v2i64:
; X64SSE4:       # %bb.0:
; X64SSE4-NEXT:    movdqa {{.*#+}} xmm0 = <u,1>
; X64SSE4-NEXT:    pinsrq $0, %rdi, %xmm0
; X64SSE4-NEXT:    retq
;
; X32AVX-LABEL: elt0_v2i64:
; X32AVX:       # %bb.0:
; X32AVX-NEXT:    movl $1, %eax
; X32AVX-NEXT:    vmovd %eax, %xmm0
; X32AVX-NEXT:    vmovq {{.*#+}} xmm1 = mem[0],zero
; X32AVX-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm1[0],xmm0[0]
; X32AVX-NEXT:    retl
;
; X64AVX-LABEL: elt0_v2i64:
; X64AVX:       # %bb.0:
; X64AVX-NEXT:    vmovdqa {{.*#+}} xmm0 = <u,1>
; X64AVX-NEXT:    vpinsrq $0, %rdi, %xmm0, %xmm0
; X64AVX-NEXT:    retq
   %ins = insertelement <2 x i64> <i64 42, i64 1>, i64 %x, i32 0
   ret <2 x i64> %ins
}

define <4 x float> @elt1_v4f32(float %x) {
; X32SSE2-LABEL: elt1_v4f32:
; X32SSE2:       # %bb.0:
; X32SSE2-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; X32SSE2-NEXT:    movaps {{.*#+}} xmm1 = <4.2E+1,u,2.0E+0,3.0E+0>
; X32SSE2-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,0],xmm1[0,0]
; X32SSE2-NEXT:    shufps {{.*#+}} xmm0 = xmm0[2,0],xmm1[2,3]
; X32SSE2-NEXT:    retl
;
; X64SSE2-LABEL: elt1_v4f32:
; X64SSE2:       # %bb.0:
; X64SSE2-NEXT:    movaps {{.*#+}} xmm1 = <4.2E+1,u,2.0E+0,3.0E+0>
; X64SSE2-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,0],xmm1[0,0]
; X64SSE2-NEXT:    shufps {{.*#+}} xmm0 = xmm0[2,0],xmm1[2,3]
; X64SSE2-NEXT:    retq
;
; X32SSE4-LABEL: elt1_v4f32:
; X32SSE4:       # %bb.0:
; X32SSE4-NEXT:    movaps {{.*#+}} xmm0 = <4.2E+1,u,2.0E+0,3.0E+0>
; X32SSE4-NEXT:    insertps {{.*#+}} xmm0 = xmm0[0],mem[0],xmm0[2,3]
; X32SSE4-NEXT:    retl
;
; X64SSE4-LABEL: elt1_v4f32:
; X64SSE4:       # %bb.0:
; X64SSE4-NEXT:    movaps {{.*#+}} xmm1 = <4.2E+1,u,2.0E+0,3.0E+0>
; X64SSE4-NEXT:    insertps {{.*#+}} xmm1 = xmm1[0],xmm0[0],xmm1[2,3]
; X64SSE4-NEXT:    movaps %xmm1, %xmm0
; X64SSE4-NEXT:    retq
;
; X32AVX-LABEL: elt1_v4f32:
; X32AVX:       # %bb.0:
; X32AVX-NEXT:    vmovaps {{.*#+}} xmm0 = <4.2E+1,u,2.0E+0,3.0E+0>
; X32AVX-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0],mem[0],xmm0[2,3]
; X32AVX-NEXT:    retl
;
; X64AVX-LABEL: elt1_v4f32:
; X64AVX:       # %bb.0:
; X64AVX-NEXT:    vmovaps {{.*#+}} xmm1 = <4.2E+1,u,2.0E+0,3.0E+0>
; X64AVX-NEXT:    vinsertps {{.*#+}} xmm0 = xmm1[0],xmm0[0],xmm1[2,3]
; X64AVX-NEXT:    retq
   %ins = insertelement <4 x float> <float 42.0, float 1.0, float 2.0, float 3.0>, float %x, i32 1
   ret <4 x float> %ins
}

define <2 x double> @elt1_v2f64(double %x) {
; X32SSE-LABEL: elt1_v2f64:
; X32SSE:       # %bb.0:
; X32SSE-NEXT:    movapd {{.*#+}} xmm0 = <4.2E+1,u>
; X32SSE-NEXT:    movhpd {{.*#+}} xmm0 = xmm0[0],mem[0]
; X32SSE-NEXT:    retl
;
; X64SSE-LABEL: elt1_v2f64:
; X64SSE:       # %bb.0:
; X64SSE-NEXT:    movaps {{.*#+}} xmm1 = <4.2E+1,u>
; X64SSE-NEXT:    movlhps {{.*#+}} xmm1 = xmm1[0],xmm0[0]
; X64SSE-NEXT:    movaps %xmm1, %xmm0
; X64SSE-NEXT:    retq
;
; X32AVX-LABEL: elt1_v2f64:
; X32AVX:       # %bb.0:
; X32AVX-NEXT:    vmovapd {{.*#+}} xmm0 = <4.2E+1,u>
; X32AVX-NEXT:    vmovhpd {{.*#+}} xmm0 = xmm0[0],mem[0]
; X32AVX-NEXT:    retl
;
; X64AVX-LABEL: elt1_v2f64:
; X64AVX:       # %bb.0:
; X64AVX-NEXT:    vmovaps {{.*#+}} xmm1 = <4.2E+1,u>
; X64AVX-NEXT:    vmovlhps {{.*#+}} xmm0 = xmm1[0],xmm0[0]
; X64AVX-NEXT:    retq
   %ins = insertelement <2 x double> <double 42.0, double 1.0>, double %x, i32 1
   ret <2 x double> %ins
}

define <8 x i32> @elt7_v8i32(i32 %x) {
; X32SSE2-LABEL: elt7_v8i32:
; X32SSE2:       # %bb.0:
; X32SSE2-NEXT:    movaps {{.*#+}} xmm1 = <4,5,6,u>
; X32SSE2-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; X32SSE2-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,0],xmm1[2,0]
; X32SSE2-NEXT:    shufps {{.*#+}} xmm1 = xmm1[0,1],xmm0[2,0]
; X32SSE2-NEXT:    movaps {{.*#+}} xmm0 = [42,1,2,3]
; X32SSE2-NEXT:    retl
;
; X64SSE2-LABEL: elt7_v8i32:
; X64SSE2:       # %bb.0:
; X64SSE2-NEXT:    movd %edi, %xmm0
; X64SSE2-NEXT:    movaps {{.*#+}} xmm1 = <4,5,6,u>
; X64SSE2-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,0],xmm1[2,0]
; X64SSE2-NEXT:    shufps {{.*#+}} xmm1 = xmm1[0,1],xmm0[2,0]
; X64SSE2-NEXT:    movaps {{.*#+}} xmm0 = [42,1,2,3]
; X64SSE2-NEXT:    retq
;
; X32SSE4-LABEL: elt7_v8i32:
; X32SSE4:       # %bb.0:
; X32SSE4-NEXT:    movdqa {{.*#+}} xmm1 = <4,5,6,u>
; X32SSE4-NEXT:    pinsrd $3, {{[0-9]+}}(%esp), %xmm1
; X32SSE4-NEXT:    movaps {{.*#+}} xmm0 = [42,1,2,3]
; X32SSE4-NEXT:    retl
;
; X64SSE4-LABEL: elt7_v8i32:
; X64SSE4:       # %bb.0:
; X64SSE4-NEXT:    movdqa {{.*#+}} xmm1 = <4,5,6,u>
; X64SSE4-NEXT:    pinsrd $3, %edi, %xmm1
; X64SSE4-NEXT:    movaps {{.*#+}} xmm0 = [42,1,2,3]
; X64SSE4-NEXT:    retq
;
; X32AVX-LABEL: elt7_v8i32:
; X32AVX:       # %bb.0:
; X32AVX-NEXT:    vbroadcastss {{[0-9]+}}(%esp), %ymm0
; X32AVX-NEXT:    vblendps {{.*#+}} ymm0 = mem[0,1,2,3,4,5,6],ymm0[7]
; X32AVX-NEXT:    retl
;
; X64AVX1-LABEL: elt7_v8i32:
; X64AVX1:       # %bb.0:
; X64AVX1-NEXT:    vmovd %edi, %xmm0
; X64AVX1-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,1,2,0]
; X64AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm0, %ymm0
; X64AVX1-NEXT:    vblendps {{.*#+}} ymm0 = mem[0,1,2,3,4,5,6],ymm0[7]
; X64AVX1-NEXT:    retq
;
; X64AVX2-LABEL: elt7_v8i32:
; X64AVX2:       # %bb.0:
; X64AVX2-NEXT:    vmovd %edi, %xmm0
; X64AVX2-NEXT:    vpbroadcastd %xmm0, %ymm0
; X64AVX2-NEXT:    vpblendd {{.*#+}} ymm0 = mem[0,1,2,3,4,5,6],ymm0[7]
; X64AVX2-NEXT:    retq
;
; X64AVX512F-LABEL: elt7_v8i32:
; X64AVX512F:       # %bb.0:
; X64AVX512F-NEXT:    vmovd %edi, %xmm0
; X64AVX512F-NEXT:    vpbroadcastd %xmm0, %ymm0
; X64AVX512F-NEXT:    vpblendd {{.*#+}} ymm0 = mem[0,1,2,3,4,5,6],ymm0[7]
; X64AVX512F-NEXT:    retq
   %ins = insertelement <8 x i32> <i32 42, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>, i32 %x, i32 7
   ret <8 x i32> %ins
}

define <8 x float> @elt6_v8f32(float %x) {
; X32SSE2-LABEL: elt6_v8f32:
; X32SSE2:       # %bb.0:
; X32SSE2-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; X32SSE2-NEXT:    movaps {{.*#+}} xmm1 = <4.0E+0,5.0E+0,u,7.0E+0>
; X32SSE2-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,0],xmm1[3,0]
; X32SSE2-NEXT:    shufps {{.*#+}} xmm1 = xmm1[0,1],xmm0[0,2]
; X32SSE2-NEXT:    movaps {{.*#+}} xmm0 = [4.2E+1,1.0E+0,2.0E+0,3.0E+0]
; X32SSE2-NEXT:    retl
;
; X64SSE2-LABEL: elt6_v8f32:
; X64SSE2:       # %bb.0:
; X64SSE2-NEXT:    movaps {{.*#+}} xmm1 = <4.0E+0,5.0E+0,u,7.0E+0>
; X64SSE2-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,0],xmm1[3,0]
; X64SSE2-NEXT:    shufps {{.*#+}} xmm1 = xmm1[0,1],xmm0[0,2]
; X64SSE2-NEXT:    movaps {{.*#+}} xmm0 = [4.2E+1,1.0E+0,2.0E+0,3.0E+0]
; X64SSE2-NEXT:    retq
;
; X32SSE4-LABEL: elt6_v8f32:
; X32SSE4:       # %bb.0:
; X32SSE4-NEXT:    movaps {{.*#+}} xmm1 = <4.0E+0,5.0E+0,u,7.0E+0>
; X32SSE4-NEXT:    insertps {{.*#+}} xmm1 = xmm1[0,1],mem[0],xmm1[3]
; X32SSE4-NEXT:    movaps {{.*#+}} xmm0 = [4.2E+1,1.0E+0,2.0E+0,3.0E+0]
; X32SSE4-NEXT:    retl
;
; X64SSE4-LABEL: elt6_v8f32:
; X64SSE4:       # %bb.0:
; X64SSE4-NEXT:    movaps {{.*#+}} xmm1 = <4.0E+0,5.0E+0,u,7.0E+0>
; X64SSE4-NEXT:    insertps {{.*#+}} xmm1 = xmm1[0,1],xmm0[0],xmm1[3]
; X64SSE4-NEXT:    movaps {{.*#+}} xmm0 = [4.2E+1,1.0E+0,2.0E+0,3.0E+0]
; X64SSE4-NEXT:    retq
;
; X32AVX-LABEL: elt6_v8f32:
; X32AVX:       # %bb.0:
; X32AVX-NEXT:    vbroadcastss {{[0-9]+}}(%esp), %ymm0
; X32AVX-NEXT:    vblendps {{.*#+}} ymm0 = mem[0,1,2,3,4,5],ymm0[6],mem[7]
; X32AVX-NEXT:    retl
;
; X64AVX1-LABEL: elt6_v8f32:
; X64AVX1:       # %bb.0:
; X64AVX1-NEXT:    vmovddup {{.*#+}} xmm0 = xmm0[0,0]
; X64AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm0, %ymm0
; X64AVX1-NEXT:    vblendps {{.*#+}} ymm0 = mem[0,1,2,3,4,5],ymm0[6],mem[7]
; X64AVX1-NEXT:    retq
;
; X64AVX2-LABEL: elt6_v8f32:
; X64AVX2:       # %bb.0:
; X64AVX2-NEXT:    vbroadcastss %xmm0, %ymm0
; X64AVX2-NEXT:    vblendps {{.*#+}} ymm0 = mem[0,1,2,3,4,5],ymm0[6],mem[7]
; X64AVX2-NEXT:    retq
;
; X64AVX512F-LABEL: elt6_v8f32:
; X64AVX512F:       # %bb.0:
; X64AVX512F-NEXT:    vbroadcastss %xmm0, %ymm0
; X64AVX512F-NEXT:    vblendps {{.*#+}} ymm0 = mem[0,1,2,3,4,5],ymm0[6],mem[7]
; X64AVX512F-NEXT:    retq
   %ins = insertelement <8 x float> <float 42.0, float 1.0, float 2.0, float 3.0, float 4.0, float 5.0, float 6.0, float 7.0>, float %x, i32 6
   ret <8 x float> %ins
}

define <8 x i64> @elt5_v8i64(i64 %x) {
; X32SSE-LABEL: elt5_v8i64:
; X32SSE:       # %bb.0:
; X32SSE-NEXT:    movl $4, %eax
; X32SSE-NEXT:    movd %eax, %xmm2
; X32SSE-NEXT:    movq {{.*#+}} xmm0 = mem[0],zero
; X32SSE-NEXT:    punpcklqdq {{.*#+}} xmm2 = xmm2[0],xmm0[0]
; X32SSE-NEXT:    movaps {{.*#+}} xmm0 = [42,0,1,0]
; X32SSE-NEXT:    movaps {{.*#+}} xmm1 = [2,0,3,0]
; X32SSE-NEXT:    movaps {{.*#+}} xmm3 = [6,0,7,0]
; X32SSE-NEXT:    retl
;
; X64SSE2-LABEL: elt5_v8i64:
; X64SSE2:       # %bb.0:
; X64SSE2-NEXT:    movq %rdi, %xmm0
; X64SSE2-NEXT:    movdqa {{.*#+}} xmm2 = <4,u>
; X64SSE2-NEXT:    punpcklqdq {{.*#+}} xmm2 = xmm2[0],xmm0[0]
; X64SSE2-NEXT:    movaps {{.*#+}} xmm0 = [42,1]
; X64SSE2-NEXT:    movaps {{.*#+}} xmm1 = [2,3]
; X64SSE2-NEXT:    movaps {{.*#+}} xmm3 = [6,7]
; X64SSE2-NEXT:    retq
;
; X64SSE4-LABEL: elt5_v8i64:
; X64SSE4:       # %bb.0:
; X64SSE4-NEXT:    movdqa {{.*#+}} xmm2 = <4,u>
; X64SSE4-NEXT:    pinsrq $1, %rdi, %xmm2
; X64SSE4-NEXT:    movaps {{.*#+}} xmm0 = [42,1]
; X64SSE4-NEXT:    movaps {{.*#+}} xmm1 = [2,3]
; X64SSE4-NEXT:    movaps {{.*#+}} xmm3 = [6,7]
; X64SSE4-NEXT:    retq
;
; X32AVX1-LABEL: elt5_v8i64:
; X32AVX1:       # %bb.0:
; X32AVX1-NEXT:    movl $4, %eax
; X32AVX1-NEXT:    vmovd %eax, %xmm0
; X32AVX1-NEXT:    vmovq {{.*#+}} xmm1 = mem[0],zero
; X32AVX1-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; X32AVX1-NEXT:    vinsertf128 $1, {{\.LCPI.*}}, %ymm0, %ymm1
; X32AVX1-NEXT:    vmovaps {{.*#+}} ymm0 = [42,0,1,0,2,0,3,0]
; X32AVX1-NEXT:    retl
;
; X64AVX1-LABEL: elt5_v8i64:
; X64AVX1:       # %bb.0:
; X64AVX1-NEXT:    vmovdqa {{.*#+}} xmm0 = <4,u,6,7>
; X64AVX1-NEXT:    vpinsrq $1, %rdi, %xmm0, %xmm0
; X64AVX1-NEXT:    vblendps {{.*#+}} ymm1 = ymm0[0,1,2,3],mem[4,5,6,7]
; X64AVX1-NEXT:    vmovaps {{.*#+}} ymm0 = [42,1,2,3]
; X64AVX1-NEXT:    retq
;
; X32AVX2-LABEL: elt5_v8i64:
; X32AVX2:       # %bb.0:
; X32AVX2-NEXT:    movl $4, %eax
; X32AVX2-NEXT:    vmovd %eax, %xmm0
; X32AVX2-NEXT:    vmovq {{.*#+}} xmm1 = mem[0],zero
; X32AVX2-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; X32AVX2-NEXT:    vinserti128 $1, {{\.LCPI.*}}, %ymm0, %ymm1
; X32AVX2-NEXT:    vmovaps {{.*#+}} ymm0 = [42,0,1,0,2,0,3,0]
; X32AVX2-NEXT:    retl
;
; X64AVX2-LABEL: elt5_v8i64:
; X64AVX2:       # %bb.0:
; X64AVX2-NEXT:    vmovdqa {{.*#+}} xmm0 = <4,u,6,7>
; X64AVX2-NEXT:    vpinsrq $1, %rdi, %xmm0, %xmm0
; X64AVX2-NEXT:    vpblendd {{.*#+}} ymm1 = ymm0[0,1,2,3],mem[4,5,6,7]
; X64AVX2-NEXT:    vmovaps {{.*#+}} ymm0 = [42,1,2,3]
; X64AVX2-NEXT:    retq
;
; X32AVX512F-LABEL: elt5_v8i64:
; X32AVX512F:       # %bb.0:
; X32AVX512F-NEXT:    vmovdqa {{.*#+}} ymm0 = [42,0,1,0,2,0,3,0]
; X32AVX512F-NEXT:    movl $4, %eax
; X32AVX512F-NEXT:    vmovd %eax, %xmm1
; X32AVX512F-NEXT:    vmovq {{.*#+}} xmm2 = mem[0],zero
; X32AVX512F-NEXT:    vpunpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm2[0]
; X32AVX512F-NEXT:    vinserti128 $1, {{\.LCPI.*}}, %ymm1, %ymm1
; X32AVX512F-NEXT:    vinserti64x4 $1, %ymm1, %zmm0, %zmm0
; X32AVX512F-NEXT:    retl
;
; X64AVX512F-LABEL: elt5_v8i64:
; X64AVX512F:       # %bb.0:
; X64AVX512F-NEXT:    vmovq %rdi, %xmm1
; X64AVX512F-NEXT:    vmovdqa64 {{.*#+}} zmm2 = [0,1,2,3,4,8,6,7]
; X64AVX512F-NEXT:    vmovdqa64 {{.*#+}} zmm0 = <42,1,2,3,4,u,6,7>
; X64AVX512F-NEXT:    vpermt2q %zmm1, %zmm2, %zmm0
; X64AVX512F-NEXT:    retq
   %ins = insertelement <8 x i64> <i64 42, i64 1, i64 2, i64 3, i64 4, i64 5, i64 6, i64 7>, i64 %x, i32 5
   ret <8 x i64> %ins
}

define <8 x double> @elt1_v8f64(double %x) {
; X32SSE-LABEL: elt1_v8f64:
; X32SSE:       # %bb.0:
; X32SSE-NEXT:    movapd {{.*#+}} xmm0 = <4.2E+1,u>
; X32SSE-NEXT:    movhpd {{.*#+}} xmm0 = xmm0[0],mem[0]
; X32SSE-NEXT:    movaps {{.*#+}} xmm1 = [2.0E+0,3.0E+0]
; X32SSE-NEXT:    movaps {{.*#+}} xmm2 = [4.0E+0,5.0E+0]
; X32SSE-NEXT:    movaps {{.*#+}} xmm3 = [6.0E+0,7.0E+0]
; X32SSE-NEXT:    retl
;
; X64SSE-LABEL: elt1_v8f64:
; X64SSE:       # %bb.0:
; X64SSE-NEXT:    movaps {{.*#+}} xmm4 = <4.2E+1,u>
; X64SSE-NEXT:    movlhps {{.*#+}} xmm4 = xmm4[0],xmm0[0]
; X64SSE-NEXT:    movaps {{.*#+}} xmm1 = [2.0E+0,3.0E+0]
; X64SSE-NEXT:    movaps {{.*#+}} xmm2 = [4.0E+0,5.0E+0]
; X64SSE-NEXT:    movaps {{.*#+}} xmm3 = [6.0E+0,7.0E+0]
; X64SSE-NEXT:    movaps %xmm4, %xmm0
; X64SSE-NEXT:    retq
;
; X32AVX1-LABEL: elt1_v8f64:
; X32AVX1:       # %bb.0:
; X32AVX1-NEXT:    vmovapd {{.*#+}} xmm0 = <4.2E+1,u,2.0E+0,3.0E+0>
; X32AVX1-NEXT:    vmovhpd {{.*#+}} xmm0 = xmm0[0],mem[0]
; X32AVX1-NEXT:    vblendpd {{.*#+}} ymm0 = ymm0[0,1],mem[2,3]
; X32AVX1-NEXT:    vmovaps {{.*#+}} ymm1 = [4.0E+0,5.0E+0,6.0E+0,7.0E+0]
; X32AVX1-NEXT:    retl
;
; X64AVX1-LABEL: elt1_v8f64:
; X64AVX1:       # %bb.0:
; X64AVX1-NEXT:    vmovaps {{.*#+}} xmm1 = <4.2E+1,u,2.0E+0,3.0E+0>
; X64AVX1-NEXT:    vmovlhps {{.*#+}} xmm0 = xmm1[0],xmm0[0]
; X64AVX1-NEXT:    vblendps {{.*#+}} ymm0 = ymm0[0,1,2,3],mem[4,5,6,7]
; X64AVX1-NEXT:    vmovaps {{.*#+}} ymm1 = [4.0E+0,5.0E+0,6.0E+0,7.0E+0]
; X64AVX1-NEXT:    retq
;
; X32AVX2-LABEL: elt1_v8f64:
; X32AVX2:       # %bb.0:
; X32AVX2-NEXT:    vmovapd {{.*#+}} xmm0 = <4.2E+1,u,2.0E+0,3.0E+0>
; X32AVX2-NEXT:    vmovhpd {{.*#+}} xmm0 = xmm0[0],mem[0]
; X32AVX2-NEXT:    vblendpd {{.*#+}} ymm0 = ymm0[0,1],mem[2,3]
; X32AVX2-NEXT:    vmovaps {{.*#+}} ymm1 = [4.0E+0,5.0E+0,6.0E+0,7.0E+0]
; X32AVX2-NEXT:    retl
;
; X64AVX2-LABEL: elt1_v8f64:
; X64AVX2:       # %bb.0:
; X64AVX2-NEXT:    vmovaps {{.*#+}} xmm1 = <4.2E+1,u,2.0E+0,3.0E+0>
; X64AVX2-NEXT:    vmovlhps {{.*#+}} xmm0 = xmm1[0],xmm0[0]
; X64AVX2-NEXT:    vblendps {{.*#+}} ymm0 = ymm0[0,1,2,3],mem[4,5,6,7]
; X64AVX2-NEXT:    vmovaps {{.*#+}} ymm1 = [4.0E+0,5.0E+0,6.0E+0,7.0E+0]
; X64AVX2-NEXT:    retq
;
; X32AVX512F-LABEL: elt1_v8f64:
; X32AVX512F:       # %bb.0:
; X32AVX512F-NEXT:    vmovapd {{.*#+}} xmm0 = <4.2E+1,u,2.0E+0,3.0E+0,4.0E+0,5.0E+0,6.0E+0,7.0E+0>
; X32AVX512F-NEXT:    vmovhpd {{.*#+}} xmm0 = xmm0[0],mem[0]
; X32AVX512F-NEXT:    vmovapd {{.*#+}} zmm1 = <4.2E+1,u,2.0E+0,3.0E+0,4.0E+0,5.0E+0,6.0E+0,7.0E+0>
; X32AVX512F-NEXT:    vinsertf32x4 $0, %xmm0, %zmm1, %zmm0
; X32AVX512F-NEXT:    retl
;
; X64AVX512F-LABEL: elt1_v8f64:
; X64AVX512F:       # %bb.0:
; X64AVX512F-NEXT:    vmovaps {{.*#+}} xmm1 = <4.2E+1,u,2.0E+0,3.0E+0,4.0E+0,5.0E+0,6.0E+0,7.0E+0>
; X64AVX512F-NEXT:    vmovlhps {{.*#+}} xmm0 = xmm1[0],xmm0[0]
; X64AVX512F-NEXT:    vmovaps {{.*#+}} zmm1 = <4.2E+1,u,2.0E+0,3.0E+0,4.0E+0,5.0E+0,6.0E+0,7.0E+0>
; X64AVX512F-NEXT:    vinsertf32x4 $0, %xmm0, %zmm1, %zmm0
; X64AVX512F-NEXT:    retq
   %ins = insertelement <8 x double> <double 42.0, double 1.0, double 2.0, double 3.0, double 4.0, double 5.0, double 6.0, double 7.0>, double %x, i32 1
   ret <8 x double> %ins
}

