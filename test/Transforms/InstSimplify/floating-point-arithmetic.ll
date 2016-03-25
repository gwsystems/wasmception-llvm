; NOTE: Assertions have been autogenerated by update_test_checks.py
; RUN: opt < %s -instsimplify -S | FileCheck %s

; fsub -0.0, (fsub -0.0, X) ==> X
define float @fsub_-0_-0_x(float %a) {
; CHECK-LABEL: @fsub_-0_-0_x(
; CHECK:         ret float %a
;
  %t1 = fsub float -0.0, %a
  %ret = fsub float -0.0, %t1
  ret float %ret
}

; fsub 0.0, (fsub -0.0, X) != X
define float @fsub_0_-0_x(float %a) {
; CHECK-LABEL: @fsub_0_-0_x(
; CHECK:         [[T1:%.*]] = fsub float 0.000000e+00, %a
; CHECK-NEXT:    [[RET:%.*]] = fsub float -0.000000e+00, [[T1]]
; CHECK-NEXT:    ret float [[RET]]
;
  %t1 = fsub float 0.0, %a
  %ret = fsub float -0.0, %t1
  ret float %ret
}

; fsub -0.0, (fsub 0.0, X) != X
define float @fsub_-0_0_x(float %a) {
; CHECK-LABEL: @fsub_-0_0_x(
; CHECK:         [[T1:%.*]] = fsub float -0.000000e+00, %a
; CHECK-NEXT:    [[RET:%.*]] = fsub float 0.000000e+00, [[T1]]
; CHECK-NEXT:    ret float [[RET]]
;
  %t1 = fsub float -0.0, %a
  %ret = fsub float 0.0, %t1
  ret float %ret
}

; fsub X, 0 ==> X
define float @fsub_x_0(float %a) {
; CHECK-LABEL: @fsub_x_0(
; CHECK:         ret float %a
;
  %ret = fsub float %a, 0.0
  ret float %ret
}

; fadd X, -0 ==> X
define float @fadd_x_n0(float %a) {
; CHECK-LABEL: @fadd_x_n0(
; CHECK:         ret float %a
;
  %ret = fadd float %a, -0.0
  ret float %ret
}

; fmul X, 1.0 ==> X
define double @fmul_X_1(double %a) {
; CHECK-LABEL: @fmul_X_1(
; CHECK:         ret double %a
;
  %b = fmul double 1.000000e+00, %a
  ret double %b
}

; We can't optimize away the fadd in this test because the input
; value to the function and subsequently to the fadd may be -0.0.
; In that one special case, the result of the fadd should be +0.0
; rather than the first parameter of the fadd.

; Fragile test warning: We need 6 sqrt calls to trigger the bug
; because the internal logic has a magic recursion limit of 6.
; This is presented without any explanation or ability to customize.

declare float @sqrtf(float)

define float @PR22688(float %x) {
; CHECK-LABEL: @PR22688(
; CHECK:         [[TMP7:%.*]] = fadd float {{%.*}}, 0.000000e+00
; CHECK-NEXT:    ret float [[TMP7]]
;
  %1 = call float @sqrtf(float %x)
  %2 = call float @sqrtf(float %1)
  %3 = call float @sqrtf(float %2)
  %4 = call float @sqrtf(float %3)
  %5 = call float @sqrtf(float %4)
  %6 = call float @sqrtf(float %5)
  %7 = fadd float %6, 0.0
  ret float %7
}

