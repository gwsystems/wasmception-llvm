; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-- -mattr=+sse4.1   | FileCheck %s --check-prefixes=SSE,SSE41
; RUN: llc < %s -mtriple=i686-- -mattr=+avx      | FileCheck %s --check-prefixes=AVX,AVX1
; RUN: llc < %s -mtriple=i686-- -mattr=+avx2     | FileCheck %s --check-prefixes=AVX,AVX2
; RUN: llc < %s -mtriple=i686-- -mattr=+avx512vl | FileCheck %s --check-prefixes=AVX,AVX512VL

; Test an isel pattern for a splatted VZLOAD.

define <4 x float> @movddup_load_fold(float %x, float %y) {
; SSE-LABEL: movddup_load_fold:
; SSE:       # %bb.0:
; SSE-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; SSE-NEXT:    movddup {{.*#+}} xmm0 = xmm0[0,0]
; SSE-NEXT:    retl
;
; AVX-LABEL: movddup_load_fold:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; AVX-NEXT:    vmovddup {{.*#+}} xmm0 = xmm0[0,0]
; AVX-NEXT:    retl
  %i0 = insertelement <4 x float> zeroinitializer, float %x, i32 0
  %i1 = insertelement <4 x float> %i0, float %y, i32 1
  %dup = shufflevector <4 x float> %i1, <4 x float> undef, <4 x i32> <i32 0, i32 1, i32 0, i32 1>
  ret <4 x float> %dup
}

