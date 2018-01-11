; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -instcombine < %s | FileCheck %s

define double @fdiv_sin_cos(double %a) {
; CHECK-LABEL: @fdiv_sin_cos(
; CHECK-NEXT:    [[TMP1:%.*]] = call double @llvm.sin.f64(double [[A:%.*]])
; CHECK-NEXT:    [[TMP2:%.*]] = call double @llvm.cos.f64(double [[A]])
; CHECK-NEXT:    [[DIV:%.*]] = fdiv double [[TMP1]], [[TMP2]]
; CHECK-NEXT:    ret double [[DIV]]
;
  %1 = call double @llvm.sin.f64(double %a)
  %2 = call double @llvm.cos.f64(double %a)
  %div = fdiv double %1, %2
  ret double %div
}

define double @fdiv_strict_sin_strict_cos_fast(double %a) {
; CHECK-LABEL: @fdiv_strict_sin_strict_cos_fast(
; CHECK-NEXT:    [[TMP1:%.*]] = call double @llvm.sin.f64(double [[A:%.*]])
; CHECK-NEXT:    [[TMP2:%.*]] = call fast double @llvm.cos.f64(double [[A]])
; CHECK-NEXT:    [[DIV:%.*]] = fdiv double [[TMP1]], [[TMP2]]
; CHECK-NEXT:    ret double [[DIV]]
;
  %1 = call double @llvm.sin.f64(double %a)
  %2 = call fast double @llvm.cos.f64(double %a)
  %div = fdiv double %1, %2
  ret double %div
}

define double @fdiv_fast_sin_strict_cos_strict(double %a) {
; CHECK-LABEL: @fdiv_fast_sin_strict_cos_strict(
; CHECK-NEXT:    [[TAN:%.*]] = call fast double @tan(double [[A:%.*]])
; CHECK-NEXT:    ret double [[TAN]]
;
  %1 = call double @llvm.sin.f64(double %a)
  %2 = call double @llvm.cos.f64(double %a)
  %div = fdiv fast double %1, %2
  ret double %div
}

define double @fdiv_fast_sin_fast_cos_strict(double %a) {
; CHECK-LABEL: @fdiv_fast_sin_fast_cos_strict(
; CHECK-NEXT:    [[TAN:%.*]] = call fast double @tan(double [[A:%.*]])
; CHECK-NEXT:    ret double [[TAN]]
;
  %1 = call fast double @llvm.sin.f64(double %a)
  %2 = call double @llvm.cos.f64(double %a)
  %div = fdiv fast double %1, %2
  ret double %div
}

define double @fdiv_sin_cos_fast_multiple_uses(double %a) {
; CHECK-LABEL: @fdiv_sin_cos_fast_multiple_uses(
; CHECK-NEXT:    [[TMP1:%.*]] = call fast double @llvm.sin.f64(double [[A:%.*]])
; CHECK-NEXT:    [[TMP2:%.*]] = call fast double @llvm.cos.f64(double [[A]])
; CHECK-NEXT:    [[DIV:%.*]] = fdiv fast double [[TMP1]], [[TMP2]]
; CHECK-NEXT:    call void @use(double [[TMP2]])
; CHECK-NEXT:    ret double [[DIV]]
;
  %1 = call fast double @llvm.sin.f64(double %a)
  %2 = call fast double @llvm.cos.f64(double %a)
  %div = fdiv fast double %1, %2
  call void @use(double %2)
  ret double %div
}

define double @fdiv_sin_cos_fast(double %a) {
; CHECK-LABEL: @fdiv_sin_cos_fast(
; CHECK-NEXT:    [[TMP1:%.*]] = call fast double @tan(double [[A:%.*]])
; CHECK-NEXT:    ret double [[TMP1]]
;
  %1 = call fast double @llvm.sin.f64(double %a)
  %2 = call fast double @llvm.cos.f64(double %a)
  %div = fdiv fast double %1, %2
  ret double %div
}

define float @fdiv_sinf_cosf_fast(float %a) {
; CHECK-LABEL: @fdiv_sinf_cosf_fast(
; CHECK-NEXT:    [[TMP1:%.*]] = call fast float @tanf(float [[A:%.*]])
; CHECK-NEXT:    ret float [[TMP1]]
;
  %1 = call fast float @llvm.sin.f32(float %a)
  %2 = call fast float @llvm.cos.f32(float %a)
  %div = fdiv fast float %1, %2
  ret float %div
}

define fp128 @fdiv_sinfp128_cosfp128_fast(fp128 %a) {
; CHECK-LABEL: @fdiv_sinfp128_cosfp128_fast(
; CHECK-NEXT:    [[TMP0:%.*]] = call fast fp128 @tanl(fp128 [[A:%.*]])
; CHECK-NEXT:    ret fp128 [[TMP0]]
;
  %1 = call fast fp128 @llvm.sin.fp128(fp128 %a)
  %2 = call fast fp128 @llvm.cos.fp128(fp128 %a)
  %div = fdiv fast fp128 %1, %2
  ret fp128 %div
}

declare double @llvm.sin.f64(double)
declare float @llvm.sin.f32(float)
declare fp128 @llvm.sin.fp128(fp128)

declare double @llvm.cos.f64(double)
declare float @llvm.cos.f32(float)
declare fp128 @llvm.cos.fp128(fp128)

declare void @use(double)
