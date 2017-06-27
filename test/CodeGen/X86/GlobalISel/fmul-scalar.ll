; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=x86_64-linux-gnu -global-isel -verify-machineinstrs < %s -o - | FileCheck %s --check-prefix=ALL --check-prefix=X64
define float @test_fmul_float(float %arg1, float %arg2) {
; ALL-LABEL: test_fmul_float:
; ALL:       # BB#0:
; ALL-NEXT:    mulss %xmm1, %xmm0
; ALL-NEXT:    retq
  %ret = fmul float %arg1, %arg2
  ret float %ret
}

define double @test_fmul_double(double %arg1, double %arg2) {
; ALL-LABEL: test_fmul_double:
; ALL:       # BB#0:
; ALL-NEXT:    mulsd %xmm1, %xmm0
; ALL-NEXT:    retq
  %ret = fmul double %arg1, %arg2
  ret double %ret
}

