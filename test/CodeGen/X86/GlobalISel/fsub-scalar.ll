; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=x86_64-linux-gnu -global-isel -verify-machineinstrs < %s -o - | FileCheck %s --check-prefix=ALL --check-prefix=X64
define float @test_fsub_float(float %arg1, float %arg2) {
; ALL-LABEL: test_fsub_float:
; ALL:       # BB#0:
; ALL-NEXT:    subss %xmm1, %xmm0
; ALL-NEXT:    retq
  %ret = fsub float %arg1, %arg2
  ret float %ret
}

define double @test_fsub_double(double %arg1, double %arg2) {
; ALL-LABEL: test_fsub_double:
; ALL:       # BB#0:
; ALL-NEXT:    subsd %xmm1, %xmm0
; ALL-NEXT:    retq
  %ret = fsub double %arg1, %arg2
  ret double %ret
}

