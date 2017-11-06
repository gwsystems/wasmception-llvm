; RUN: opt < %s -basicaa -slp-vectorizer -slp-threshold=-999 -dce -S -mtriple=x86_64-apple-macosx10.8.0 -mcpu=corei7-avx | FileCheck %s

target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.8.0"

declare double @sin(double)
declare double @cos(double)
declare double @pow(double, double)
declare double @exp2(double)
declare double @sqrt(double)
declare i64 @round(i64)


define void @sin_libm(double* %a, double* %b) {
; CHECK-LABEL: @sin_libm(
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast double* %a to <2 x double>*
; CHECK-NEXT:    [[TMP2:%.*]] = load <2 x double>, <2 x double>* [[TMP1]], align 8
; CHECK-NEXT:    [[TMP3:%.*]] = call <2 x double> @llvm.sin.v2f64(<2 x double> [[TMP2]])
; CHECK-NEXT:    [[TMP4:%.*]] = bitcast double* %b to <2 x double>*
; CHECK-NEXT:    store <2 x double> [[TMP3]], <2 x double>* [[TMP4]], align 8
; CHECK-NEXT:    ret void
;
  %a0 = load double, double* %a, align 8
  %idx1 = getelementptr inbounds double, double* %a, i64 1
  %a1 = load double, double* %idx1, align 8
  %sin1 = tail call double @sin(double %a0) nounwind readnone
  %sin2 = tail call double @sin(double %a1) nounwind readnone
  store double %sin1, double* %b, align 8
  %idx2 = getelementptr inbounds double, double* %b, i64 1
  store double %sin2, double* %idx2, align 8
  ret void
}

define void @cos_libm(double* %a, double* %b) {
; CHECK-LABEL: @cos_libm(
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast double* %a to <2 x double>*
; CHECK-NEXT:    [[TMP2:%.*]] = load <2 x double>, <2 x double>* [[TMP1]], align 8
; CHECK-NEXT:    [[TMP3:%.*]] = call <2 x double> @llvm.cos.v2f64(<2 x double> [[TMP2]])
; CHECK-NEXT:    [[TMP4:%.*]] = bitcast double* %b to <2 x double>*
; CHECK-NEXT:    store <2 x double> [[TMP3]], <2 x double>* [[TMP4]], align 8
; CHECK-NEXT:    ret void
;
  %a0 = load double, double* %a, align 8
  %idx1 = getelementptr inbounds double, double* %a, i64 1
  %a1 = load double, double* %idx1, align 8
  %cos1 = tail call double @cos(double %a0) nounwind readnone
  %cos2 = tail call double @cos(double %a1) nounwind readnone
  store double %cos1, double* %b, align 8
  %idx2 = getelementptr inbounds double, double* %b, i64 1
  store double %cos2, double* %idx2, align 8
  ret void
}

define void @pow_libm(double* %a, double* %b) {
; CHECK-LABEL: @pow_libm(
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast double* %a to <2 x double>*
; CHECK-NEXT:    [[TMP2:%.*]] = load <2 x double>, <2 x double>* [[TMP1]], align 8
; CHECK-NEXT:    [[TMP3:%.*]] = call <2 x double> @llvm.pow.v2f64(<2 x double> [[TMP2]], <2 x double> [[TMP2]])
; CHECK-NEXT:    [[TMP4:%.*]] = bitcast double* %b to <2 x double>*
; CHECK-NEXT:    store <2 x double> [[TMP3]], <2 x double>* [[TMP4]], align 8
; CHECK-NEXT:    ret void
;
  %a0 = load double, double* %a, align 8
  %idx1 = getelementptr inbounds double, double* %a, i64 1
  %a1 = load double, double* %idx1, align 8
  %pow1 = tail call double @pow(double %a0, double %a0) nounwind readnone
  %pow2 = tail call double @pow(double %a1, double %a1) nounwind readnone
  store double %pow1, double* %b, align 8
  %idx2 = getelementptr inbounds double, double* %b, i64 1
  store double %pow2, double* %idx2, align 8
  ret void
}

define void @exp_libm(double* %a, double* %b) {
; CHECK-LABEL: @exp_libm(
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast double* %a to <2 x double>*
; CHECK-NEXT:    [[TMP2:%.*]] = load <2 x double>, <2 x double>* [[TMP1]], align 8
; CHECK-NEXT:    [[TMP3:%.*]] = call <2 x double> @llvm.exp2.v2f64(<2 x double> [[TMP2]])
; CHECK-NEXT:    [[TMP4:%.*]] = bitcast double* %b to <2 x double>*
; CHECK-NEXT:    store <2 x double> [[TMP3]], <2 x double>* [[TMP4]], align 8
; CHECK-NEXT:    ret void
;
  %a0 = load double, double* %a, align 8
  %idx1 = getelementptr inbounds double, double* %a, i64 1
  %a1 = load double, double* %idx1, align 8
  %exp1 = tail call double @exp2(double %a0) nounwind readnone
  %exp2 = tail call double @exp2(double %a1) nounwind readnone
  store double %exp1, double* %b, align 8
  %idx2 = getelementptr inbounds double, double* %b, i64 1
  store double %exp2, double* %idx2, align 8
  ret void
}

; No fast-math-flags are required to convert sqrt library calls to an intrinsic. 
; We just need to know that errno is not set (readnone).

define void @sqrt_libm_no_errno(double* %a, double* %b) {
; CHECK-LABEL: @sqrt_libm_no_errno(
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast double* %a to <2 x double>*
; CHECK-NEXT:    [[TMP2:%.*]] = load <2 x double>, <2 x double>* [[TMP1]], align 8
; CHECK-NEXT:    [[TMP3:%.*]] = call <2 x double> @llvm.sqrt.v2f64(<2 x double> [[TMP2]])
; CHECK-NEXT:    [[TMP4:%.*]] = bitcast double* %b to <2 x double>*
; CHECK-NEXT:    store <2 x double> [[TMP3]], <2 x double>* [[TMP4]], align 8
; CHECK-NEXT:    ret void
;
  %a0 = load double, double* %a, align 8
  %idx1 = getelementptr inbounds double, double* %a, i64 1
  %a1 = load double, double* %idx1, align 8
  %sqrt1 = tail call double @sqrt(double %a0) nounwind readnone
  %sqrt2 = tail call double @sqrt(double %a1) nounwind readnone
  store double %sqrt1, double* %b, align 8
  %idx2 = getelementptr inbounds double, double* %b, i64 1
  store double %sqrt2, double* %idx2, align 8
  ret void
}

; The sqrt intrinsic does not set errno, but a non-constant sqrt call might, so this can't vectorize.
; The nnan on the call does not matter because there's no guarantee in the C standard that a negative
; input would result in a nan output ("On a domain error, the function returns an 
; implementation-defined value.")

define void @sqrt_libm_errno(double* %a, double* %b) {
; CHECK-LABEL: @sqrt_libm_errno(
; CHECK-NEXT:    [[A0:%.*]] = load double, double* %a, align 8
; CHECK-NEXT:    [[IDX1:%.*]] = getelementptr inbounds double, double* %a, i64 1
; CHECK-NEXT:    [[A1:%.*]] = load double, double* [[IDX1]], align 8
; CHECK-NEXT:    [[SQRT1:%.*]] = tail call nnan double @sqrt(double [[A0]]) #2
; CHECK-NEXT:    [[SQRT2:%.*]] = tail call nnan double @sqrt(double [[A1]]) #2
; CHECK-NEXT:    store double [[SQRT1]], double* %b, align 8
; CHECK-NEXT:    [[IDX2:%.*]] = getelementptr inbounds double, double* %b, i64 1
; CHECK-NEXT:    store double [[SQRT2]], double* [[IDX2]], align 8
; CHECK-NEXT:    ret void
;
  %a0 = load double, double* %a, align 8
  %idx1 = getelementptr inbounds double, double* %a, i64 1
  %a1 = load double, double* %idx1, align 8
  %sqrt1 = tail call nnan double @sqrt(double %a0) nounwind
  %sqrt2 = tail call nnan double @sqrt(double %a1) nounwind
  store double %sqrt1, double* %b, align 8
  %idx2 = getelementptr inbounds double, double* %b, i64 1
  store double %sqrt2, double* %idx2, align 8
  ret void
}

; Negative test case
define void @round_custom(i64* %a, i64* %b) {
; CHECK-LABEL: @round_custom(
; CHECK-NEXT:    [[A0:%.*]] = load i64, i64* %a, align 8
; CHECK-NEXT:    [[IDX1:%.*]] = getelementptr inbounds i64, i64* %a, i64 1
; CHECK-NEXT:    [[A1:%.*]] = load i64, i64* [[IDX1]], align 8
; CHECK-NEXT:    [[ROUND1:%.*]] = tail call i64 @round(i64 [[A0]]) #3
; CHECK-NEXT:    [[ROUND2:%.*]] = tail call i64 @round(i64 [[A1]]) #3
; CHECK-NEXT:    store i64 [[ROUND1]], i64* %b, align 8
; CHECK-NEXT:    [[IDX2:%.*]] = getelementptr inbounds i64, i64* %b, i64 1
; CHECK-NEXT:    store i64 [[ROUND2]], i64* [[IDX2]], align 8
; CHECK-NEXT:    ret void
;
  %a0 = load i64, i64* %a, align 8
  %idx1 = getelementptr inbounds i64, i64* %a, i64 1
  %a1 = load i64, i64* %idx1, align 8
  %round1 = tail call i64 @round(i64 %a0) nounwind readnone
  %round2 = tail call i64 @round(i64 %a1) nounwind readnone
  store i64 %round1, i64* %b, align 8
  %idx2 = getelementptr inbounds i64, i64* %b, i64 1
  store i64 %round2, i64* %idx2, align 8
  ret void
}


; CHECK: declare <2 x double> @llvm.sin.v2f64(<2 x double>) [[ATTR0:#[0-9]+]]
; CHECK: declare <2 x double> @llvm.cos.v2f64(<2 x double>) [[ATTR0]]
; CHECK: declare <2 x double> @llvm.pow.v2f64(<2 x double>, <2 x double>) [[ATTR0]]
; CHECK: declare <2 x double> @llvm.exp2.v2f64(<2 x double>) [[ATTR0]]

; CHECK: attributes [[ATTR0]] = { nounwind readnone speculatable }

