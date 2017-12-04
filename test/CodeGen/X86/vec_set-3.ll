; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i386-unknown -mattr=+sse2,+sse4.1 | FileCheck %s --check-prefix=X86
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+sse2,+sse4.1 | FileCheck %s --check-prefix=X64

define <4 x float> @test(float %a) {
; X86-LABEL: test:
; X86:       # %bb.0:
; X86-NEXT:    insertps {{.*#+}} xmm0 = zero,mem[0],zero,zero
; X86-NEXT:    retl
;
; X64-LABEL: test:
; X64:       # %bb.0:
; X64-NEXT:    insertps {{.*#+}} xmm0 = zero,xmm0[0],zero,zero
; X64-NEXT:    retq
  %tmp = insertelement <4 x float> zeroinitializer, float %a, i32 1
  %tmp5 = insertelement <4 x float> %tmp, float 0.000000e+00, i32 2
  %tmp6 = insertelement <4 x float> %tmp5, float 0.000000e+00, i32 3
  ret <4 x float> %tmp6
}

define <2 x i64> @test2(i32 %a) {
; X86-LABEL: test2:
; X86:       # %bb.0:
; X86-NEXT:    movd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; X86-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,1,0,1]
; X86-NEXT:    retl
;
; X64-LABEL: test2:
; X64:       # %bb.0:
; X64-NEXT:    movd %edi, %xmm0
; X64-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,1,0,1]
; X64-NEXT:    retq
  %tmp7 = insertelement <4 x i32> zeroinitializer, i32 %a, i32 2
  %tmp9 = insertelement <4 x i32> %tmp7, i32 0, i32 3
  %tmp10 = bitcast <4 x i32> %tmp9 to <2 x i64>
  ret <2 x i64> %tmp10
}

define <4 x float> @test3(<4 x float> %A) {
; X86-LABEL: test3:
; X86:       # %bb.0:
; X86-NEXT:    insertps {{.*#+}} xmm0 = zero,xmm0[0],zero,zero
; X86-NEXT:    retl
;
; X64-LABEL: test3:
; X64:       # %bb.0:
; X64-NEXT:    insertps {{.*#+}} xmm0 = zero,xmm0[0],zero,zero
; X64-NEXT:    retq
  %tmp0 = extractelement <4 x float> %A, i32 0
  %tmp1 = insertelement <4 x float> <float 0.000000e+00, float undef, float undef, float undef >, float %tmp0, i32 1
  %tmp2 = insertelement <4 x float> %tmp1, float 0.000000e+00, i32 2
  ret <4 x float> %tmp2
}
