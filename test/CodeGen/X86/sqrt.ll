; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mattr=-avx,+sse2                             | FileCheck %s --check-prefix=SSE2
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mattr=-avx,+sse2 -fast-isel -fast-isel-abort=1 | FileCheck %s --check-prefix=SSE2
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mattr=-avx2,+avx                             | FileCheck %s --check-prefix=AVX
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mattr=-avx2,+avx -fast-isel -fast-isel-abort=1 | FileCheck %s --check-prefix=AVX

define float @test_sqrt_f32(float %a) {
; SSE2-LABEL: test_sqrt_f32:
; SSE2:       ## %bb.0:
; SSE2-NEXT:    sqrtss %xmm0, %xmm0
; SSE2-NEXT:    retq
;
; AVX-LABEL: test_sqrt_f32:
; AVX:       ## %bb.0:
; AVX-NEXT:    vsqrtss %xmm0, %xmm0, %xmm0
; AVX-NEXT:    retq
  %res = call float @llvm.sqrt.f32(float %a)
  ret float %res
}
declare float @llvm.sqrt.f32(float) nounwind readnone

define double @test_sqrt_f64(double %a) {
; SSE2-LABEL: test_sqrt_f64:
; SSE2:       ## %bb.0:
; SSE2-NEXT:    sqrtsd %xmm0, %xmm0
; SSE2-NEXT:    retq
;
; AVX-LABEL: test_sqrt_f64:
; AVX:       ## %bb.0:
; AVX-NEXT:    vsqrtsd %xmm0, %xmm0, %xmm0
; AVX-NEXT:    retq
  %res = call double @llvm.sqrt.f64(double %a)
  ret double %res
}
declare double @llvm.sqrt.f64(double) nounwind readnone


