; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s | FileCheck %s

target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-unknown"

define void @PR22524({ float, float }* %arg) {
; Check that we can materialize the zero constants we store in two places here,
; and at least form a legal store of the floating point value at the end.
; The DAG combiner at one point contained bugs that given enough permutations
; would incorrectly form an illegal operation for the last of these stores when
; it folded it to a zero too late to legalize the zero store operation. If this
; ever starts forming a zero store instead of movss, the test case has stopped
; being useful.
;
; CHECK-LABEL: PR22524:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    movd %eax, %xmm0
; CHECK-NEXT:    xorps %xmm1, %xmm1
; CHECK-NEXT:    mulss %xmm0, %xmm1
; CHECK-NEXT:    movq $0, (%rdi)
; CHECK-NEXT:    movss %xmm1, 4(%rdi)
; CHECK-NEXT:    retq
entry:
  %0 = getelementptr inbounds { float, float }, { float, float }* %arg,  i32 0, i32 1
  store float 0.000000e+00, float* %0, align 4
  %1 = getelementptr inbounds { float, float }, { float, float }* %arg, i64 0,  i32 0
  %2 = bitcast float* %1 to i64*
  %3 = load i64, i64* %2, align 8
  %4 = trunc i64 %3 to i32
  %5 = lshr i64 %3, 32
  %6 = trunc i64 %5 to i32
  %7 = bitcast i32 %6 to float
  %8 = fmul float %7, 0.000000e+00
  %9 = bitcast float* %1 to i32*
  store i32 %6, i32* %9, align 4
  store float %8, float* %0, align 4
  ret void
}
