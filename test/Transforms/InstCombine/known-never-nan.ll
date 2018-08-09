; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -instcombine %s | FileCheck %s

define i1 @nnan_fabs_src(double %arg) {
; CHECK-LABEL: @nnan_fabs_src(
; CHECK-NEXT:    ret i1 true
;
  %nnan = fadd nnan double %arg, 1.0
  %op = call double @llvm.fabs.f64(double %nnan)
  %tmp = fcmp ord double %op, %op
  ret i1 %tmp
}

define i1 @nnan_opicalize_src(double %arg) {
; CHECK-LABEL: @nnan_opicalize_src(
; CHECK-NEXT:    ret i1 true
;
  %nnan = fadd nnan double %arg, 1.0
  %op = call double @llvm.canonicalize.f64(double %nnan)
  %tmp = fcmp ord double %op, %op
  ret i1 %tmp
}

define i1 @nnan_copysign_src(double %arg0, double %arg1) {
; CHECK-LABEL: @nnan_copysign_src(
; CHECK-NEXT:    ret i1 true
;
  %nnan = fadd nnan double %arg0, 1.0
  %op = call double @llvm.copysign.f64(double %nnan, double %arg1)
  %tmp = fcmp ord double %op, %op
  ret i1 %tmp
}

define i1 @fabs_sqrt_src(double %arg0, double %arg1) {
; CHECK-LABEL: @fabs_sqrt_src(
; CHECK-NEXT:    ret i1 true
;
  %nnan = fadd nnan double %arg0, 1.0
  %fabs = call double @llvm.fabs.f64(double %nnan)
  %op = call double @llvm.sqrt.f64(double %fabs)
  %tmp = fcmp ord double %op, %op
  ret i1 %tmp
}

define i1 @fabs_sqrt_src_maybe_nan(double %arg0, double %arg1) {
; CHECK-LABEL: @fabs_sqrt_src_maybe_nan(
; CHECK-NEXT:    [[FABS:%.*]] = call double @llvm.fabs.f64(double [[ARG0:%.*]])
; CHECK-NEXT:    [[OP:%.*]] = call double @llvm.sqrt.f64(double [[FABS]])
; CHECK-NEXT:    [[TMP:%.*]] = fcmp ord double [[OP]], 0.000000e+00
; CHECK-NEXT:    ret i1 [[TMP]]
;
  %fabs = call double @llvm.fabs.f64(double %arg0)
  %op = call double @llvm.sqrt.f64(double %fabs)
  %tmp = fcmp ord double %op, %op
  ret i1 %tmp
}

declare double @llvm.sqrt.f64(double)
declare double @llvm.fabs.f64(double)
declare double @llvm.canonicalize.f64(double)
declare double @llvm.copysign.f64(double, double)
