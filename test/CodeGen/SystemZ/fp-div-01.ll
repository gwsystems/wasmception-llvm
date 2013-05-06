; Test 32-bit floating-point division.
;
; RUN: llc < %s -mtriple=s390x-linux-gnu | FileCheck %s

; Check register division.
define float @f1(float %f1, float %f2) {
; CHECK: f1:
; CHECK: debr %f0, %f2
; CHECK: br %r14
  %res = fdiv float %f1, %f2
  ret float %res
}

; Check the low end of the DEB range.
define float @f2(float %f1, float *%ptr) {
; CHECK: f2:
; CHECK: deb %f0, 0(%r2)
; CHECK: br %r14
  %f2 = load float *%ptr
  %res = fdiv float %f1, %f2
  ret float %res
}

; Check the high end of the aligned DEB range.
define float @f3(float %f1, float *%base) {
; CHECK: f3:
; CHECK: deb %f0, 4092(%r2)
; CHECK: br %r14
  %ptr = getelementptr float *%base, i64 1023
  %f2 = load float *%ptr
  %res = fdiv float %f1, %f2
  ret float %res
}

; Check the next word up, which needs separate address logic.
; Other sequences besides this one would be OK.
define float @f4(float %f1, float *%base) {
; CHECK: f4:
; CHECK: aghi %r2, 4096
; CHECK: deb %f0, 0(%r2)
; CHECK: br %r14
  %ptr = getelementptr float *%base, i64 1024
  %f2 = load float *%ptr
  %res = fdiv float %f1, %f2
  ret float %res
}

; Check negative displacements, which also need separate address logic.
define float @f5(float %f1, float *%base) {
; CHECK: f5:
; CHECK: aghi %r2, -4
; CHECK: deb %f0, 0(%r2)
; CHECK: br %r14
  %ptr = getelementptr float *%base, i64 -1
  %f2 = load float *%ptr
  %res = fdiv float %f1, %f2
  ret float %res
}

; Check that DEB allows indices.
define float @f6(float %f1, float *%base, i64 %index) {
; CHECK: f6:
; CHECK: sllg %r1, %r3, 2
; CHECK: deb %f0, 400(%r1,%r2)
; CHECK: br %r14
  %ptr1 = getelementptr float *%base, i64 %index
  %ptr2 = getelementptr float *%ptr1, i64 100
  %f2 = load float *%ptr2
  %res = fdiv float %f1, %f2
  ret float %res
}
