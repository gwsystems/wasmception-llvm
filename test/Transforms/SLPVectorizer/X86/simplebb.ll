; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -basicaa -slp-vectorizer -dce -S -mtriple=x86_64-apple-macosx10.8.0 -mcpu=corei7-avx | FileCheck %s

target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.8.0"

; Simple 3-pair chain with loads and stores
define void @test1(double* %a, double* %b, double* %c) {
; CHECK-LABEL: @test1(
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast double* [[A:%.*]] to <2 x double>*
; CHECK-NEXT:    [[TMP2:%.*]] = load <2 x double>, <2 x double>* [[TMP1]], align 8
; CHECK-NEXT:    [[TMP3:%.*]] = bitcast double* [[B:%.*]] to <2 x double>*
; CHECK-NEXT:    [[TMP4:%.*]] = load <2 x double>, <2 x double>* [[TMP3]], align 8
; CHECK-NEXT:    [[TMP5:%.*]] = fmul <2 x double> [[TMP2]], [[TMP4]]
; CHECK-NEXT:    [[TMP6:%.*]] = bitcast double* [[C:%.*]] to <2 x double>*
; CHECK-NEXT:    store <2 x double> [[TMP5]], <2 x double>* [[TMP6]], align 8
; CHECK-NEXT:    ret void
;
  %i0 = load double, double* %a, align 8
  %i1 = load double, double* %b, align 8
  %mul = fmul double %i0, %i1
  %arrayidx3 = getelementptr inbounds double, double* %a, i64 1
  %i3 = load double, double* %arrayidx3, align 8
  %arrayidx4 = getelementptr inbounds double, double* %b, i64 1
  %i4 = load double, double* %arrayidx4, align 8
  %mul5 = fmul double %i3, %i4
  store double %mul, double* %c, align 8
  %arrayidx5 = getelementptr inbounds double, double* %c, i64 1
  store double %mul5, double* %arrayidx5, align 8
  ret void
}

; Simple 3-pair chain with loads and stores, obfuscated with bitcasts
define void @test2(double* %a, double* %b, i8* %e) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast double* [[A:%.*]] to <2 x double>*
; CHECK-NEXT:    [[TMP2:%.*]] = load <2 x double>, <2 x double>* [[TMP1]], align 8
; CHECK-NEXT:    [[TMP3:%.*]] = bitcast double* [[B:%.*]] to <2 x double>*
; CHECK-NEXT:    [[TMP4:%.*]] = load <2 x double>, <2 x double>* [[TMP3]], align 8
; CHECK-NEXT:    [[TMP5:%.*]] = fmul <2 x double> [[TMP2]], [[TMP4]]
; CHECK-NEXT:    [[C:%.*]] = bitcast i8* [[E:%.*]] to double*
; CHECK-NEXT:    [[TMP6:%.*]] = bitcast double* [[C]] to <2 x double>*
; CHECK-NEXT:    store <2 x double> [[TMP5]], <2 x double>* [[TMP6]], align 8
; CHECK-NEXT:    ret void
;
  %i0 = load double, double* %a, align 8
  %i1 = load double, double* %b, align 8
  %mul = fmul double %i0, %i1
  %arrayidx3 = getelementptr inbounds double, double* %a, i64 1
  %i3 = load double, double* %arrayidx3, align 8
  %arrayidx4 = getelementptr inbounds double, double* %b, i64 1
  %i4 = load double, double* %arrayidx4, align 8
  %mul5 = fmul double %i3, %i4
  %c = bitcast i8* %e to double*
  store double %mul, double* %c, align 8
  %carrayidx5 = getelementptr inbounds i8, i8* %e, i64 8
  %arrayidx5 = bitcast i8* %carrayidx5 to double*
  store double %mul5, double* %arrayidx5, align 8
  ret void
}

; Don't vectorize volatile loads.
define void @test_volatile_load(double* %a, double* %b, double* %c) {
; CHECK-LABEL: @test_volatile_load(
; CHECK-NEXT:    [[I0:%.*]] = load volatile double, double* [[A:%.*]], align 8
; CHECK-NEXT:    [[I1:%.*]] = load volatile double, double* [[B:%.*]], align 8
; CHECK-NEXT:    [[MUL:%.*]] = fmul double [[I0]], [[I1]]
; CHECK-NEXT:    [[ARRAYIDX3:%.*]] = getelementptr inbounds double, double* [[A]], i64 1
; CHECK-NEXT:    [[I3:%.*]] = load double, double* [[ARRAYIDX3]], align 8
; CHECK-NEXT:    [[ARRAYIDX4:%.*]] = getelementptr inbounds double, double* [[B]], i64 1
; CHECK-NEXT:    [[I4:%.*]] = load double, double* [[ARRAYIDX4]], align 8
; CHECK-NEXT:    [[MUL5:%.*]] = fmul double [[I3]], [[I4]]
; CHECK-NEXT:    store double [[MUL]], double* [[C:%.*]], align 8
; CHECK-NEXT:    [[ARRAYIDX5:%.*]] = getelementptr inbounds double, double* [[C]], i64 1
; CHECK-NEXT:    store double [[MUL5]], double* [[ARRAYIDX5]], align 8
; CHECK-NEXT:    ret void
;
  %i0 = load volatile double, double* %a, align 8
  %i1 = load volatile double, double* %b, align 8
  %mul = fmul double %i0, %i1
  %arrayidx3 = getelementptr inbounds double, double* %a, i64 1
  %i3 = load double, double* %arrayidx3, align 8
  %arrayidx4 = getelementptr inbounds double, double* %b, i64 1
  %i4 = load double, double* %arrayidx4, align 8
  %mul5 = fmul double %i3, %i4
  store double %mul, double* %c, align 8
  %arrayidx5 = getelementptr inbounds double, double* %c, i64 1
  store double %mul5, double* %arrayidx5, align 8
  ret void
}

; Don't vectorize volatile stores.
define void @test_volatile_store(double* %a, double* %b, double* %c) {
; CHECK-LABEL: @test_volatile_store(
; CHECK-NEXT:    [[I0:%.*]] = load double, double* [[A:%.*]], align 8
; CHECK-NEXT:    [[I1:%.*]] = load double, double* [[B:%.*]], align 8
; CHECK-NEXT:    [[MUL:%.*]] = fmul double [[I0]], [[I1]]
; CHECK-NEXT:    [[ARRAYIDX3:%.*]] = getelementptr inbounds double, double* [[A]], i64 1
; CHECK-NEXT:    [[I3:%.*]] = load double, double* [[ARRAYIDX3]], align 8
; CHECK-NEXT:    [[ARRAYIDX4:%.*]] = getelementptr inbounds double, double* [[B]], i64 1
; CHECK-NEXT:    [[I4:%.*]] = load double, double* [[ARRAYIDX4]], align 8
; CHECK-NEXT:    [[MUL5:%.*]] = fmul double [[I3]], [[I4]]
; CHECK-NEXT:    store volatile double [[MUL]], double* [[C:%.*]], align 8
; CHECK-NEXT:    [[ARRAYIDX5:%.*]] = getelementptr inbounds double, double* [[C]], i64 1
; CHECK-NEXT:    store volatile double [[MUL5]], double* [[ARRAYIDX5]], align 8
; CHECK-NEXT:    ret void
;
  %i0 = load double, double* %a, align 8
  %i1 = load double, double* %b, align 8
  %mul = fmul double %i0, %i1
  %arrayidx3 = getelementptr inbounds double, double* %a, i64 1
  %i3 = load double, double* %arrayidx3, align 8
  %arrayidx4 = getelementptr inbounds double, double* %b, i64 1
  %i4 = load double, double* %arrayidx4, align 8
  %mul5 = fmul double %i3, %i4
  store volatile double %mul, double* %c, align 8
  %arrayidx5 = getelementptr inbounds double, double* %c, i64 1
  store volatile double %mul5, double* %arrayidx5, align 8
  ret void
}

