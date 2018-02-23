; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -instcombine < %s | FileCheck %s

declare double @llvm.sqrt.f64(double) nounwind readnone speculatable
declare void @use(double)

; sqrt(a) * sqrt(b) no math flags

define double @sqrt_a_sqrt_b(double %a, double %b) {
; CHECK-LABEL: @sqrt_a_sqrt_b(
; CHECK-NEXT:    [[TMP1:%.*]] = call double @llvm.sqrt.f64(double [[A:%.*]])
; CHECK-NEXT:    [[TMP2:%.*]] = call double @llvm.sqrt.f64(double [[B:%.*]])
; CHECK-NEXT:    [[MUL:%.*]] = fmul double [[TMP1]], [[TMP2]]
; CHECK-NEXT:    ret double [[MUL]]
;
  %1 = call double @llvm.sqrt.f64(double %a)
  %2 = call double @llvm.sqrt.f64(double %b)
  %mul = fmul double %1, %2
  ret double %mul
}

; sqrt(a) * sqrt(b) fast-math, multiple uses

define double @sqrt_a_sqrt_b_multiple_uses(double %a, double %b) {
; CHECK-LABEL: @sqrt_a_sqrt_b_multiple_uses(
; CHECK-NEXT:    [[TMP1:%.*]] = call fast double @llvm.sqrt.f64(double [[A:%.*]])
; CHECK-NEXT:    [[TMP2:%.*]] = call fast double @llvm.sqrt.f64(double [[B:%.*]])
; CHECK-NEXT:    [[MUL:%.*]] = fmul fast double [[TMP1]], [[TMP2]]
; CHECK-NEXT:    call void @use(double [[TMP2]])
; CHECK-NEXT:    ret double [[MUL]]
;
  %1 = call fast double @llvm.sqrt.f64(double %a)
  %2 = call fast double @llvm.sqrt.f64(double %b)
  %mul = fmul fast double %1, %2
  call void @use(double %2)
  ret double %mul
}

; sqrt(a) * sqrt(b) => sqrt(a*b) with fast-math

define double @sqrt_a_sqrt_b_reassoc(double %a, double %b) {
; CHECK-LABEL: @sqrt_a_sqrt_b_reassoc(
; CHECK-NEXT:    [[TMP1:%.*]] = fmul reassoc double [[A:%.*]], [[B:%.*]]
; CHECK-NEXT:    [[TMP2:%.*]] = call reassoc double @llvm.sqrt.f64(double [[TMP1]])
; CHECK-NEXT:    ret double [[TMP2]]
;
  %1 = call double @llvm.sqrt.f64(double %a)
  %2 = call double @llvm.sqrt.f64(double %b)
  %mul = fmul reassoc double %1, %2
  ret double %mul
}

; sqrt(a) * sqrt(b) * sqrt(c) * sqrt(d) => sqrt(a*b*c*d) with fast-math
; 'reassoc' on the fmuls is all that is required, but check propagation of other FMF.

define double @sqrt_a_sqrt_b_sqrt_c_sqrt_d_reassoc(double %a, double %b, double %c, double %d) {
; CHECK-LABEL: @sqrt_a_sqrt_b_sqrt_c_sqrt_d_reassoc(
; CHECK-NEXT:    [[TMP1:%.*]] = fmul reassoc arcp double [[A:%.*]], [[B:%.*]]
; CHECK-NEXT:    [[TMP2:%.*]] = fmul reassoc nnan double [[TMP1]], [[C:%.*]]
; CHECK-NEXT:    [[TMP3:%.*]] = fmul reassoc ninf double [[TMP2]], [[D:%.*]]
; CHECK-NEXT:    [[TMP4:%.*]] = call reassoc ninf double @llvm.sqrt.f64(double [[TMP3]])
; CHECK-NEXT:    ret double [[TMP4]]
;
  %1 = call double @llvm.sqrt.f64(double %a)
  %2 = call double @llvm.sqrt.f64(double %b)
  %3 = call double @llvm.sqrt.f64(double %c)
  %4 = call double @llvm.sqrt.f64(double %d)
  %mul = fmul reassoc arcp double %1, %2
  %mul1 = fmul reassoc nnan double %mul, %3
  %mul2 = fmul reassoc ninf double %mul1, %4
  ret double %mul2
}

