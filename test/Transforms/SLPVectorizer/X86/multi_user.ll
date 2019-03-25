; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -basicaa -slp-vectorizer -dce -S -mtriple=x86_64-apple-macosx10.8.0 -mcpu=corei7-avx | FileCheck %s

target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.7.0"

;int foo (int *A, int n) {
;  A[0] += n * 5 + 7;
;  A[1] += n * 5 + 8;
;  A[2] += n * 5 + 9;
;  A[3] += n * 5 + 10;
;  A[4] += n * 5 + 11;
;}

define i32 @foo(i32* nocapture %A, i32 %n) {
; CHECK-LABEL: @foo(
; CHECK-NEXT:    [[TMP1:%.*]] = mul nsw i32 [[N:%.*]], 5
; CHECK-NEXT:    [[TMP2:%.*]] = insertelement <4 x i32> undef, i32 [[TMP1]], i32 0
; CHECK-NEXT:    [[TMP3:%.*]] = insertelement <4 x i32> [[TMP2]], i32 [[TMP1]], i32 1
; CHECK-NEXT:    [[TMP4:%.*]] = insertelement <4 x i32> [[TMP3]], i32 [[TMP1]], i32 2
; CHECK-NEXT:    [[TMP5:%.*]] = insertelement <4 x i32> [[TMP4]], i32 [[TMP1]], i32 3
; CHECK-NEXT:    [[TMP6:%.*]] = add nsw <4 x i32> [[TMP5]], <i32 7, i32 8, i32 9, i32 10>
; CHECK-NEXT:    [[TMP7:%.*]] = bitcast i32* [[A:%.*]] to <4 x i32>*
; CHECK-NEXT:    [[TMP8:%.*]] = load <4 x i32>, <4 x i32>* [[TMP7]], align 4
; CHECK-NEXT:    [[TMP9:%.*]] = add nsw <4 x i32> [[TMP6]], [[TMP8]]
; CHECK-NEXT:    [[TMP10:%.*]] = bitcast i32* [[A]] to <4 x i32>*
; CHECK-NEXT:    store <4 x i32> [[TMP9]], <4 x i32>* [[TMP10]], align 4
; CHECK-NEXT:    [[TMP11:%.*]] = add nsw i32 [[TMP1]], 11
; CHECK-NEXT:    [[TMP12:%.*]] = getelementptr inbounds i32, i32* [[A]], i64 4
; CHECK-NEXT:    [[TMP13:%.*]] = load i32, i32* [[TMP12]], align 4
; CHECK-NEXT:    [[TMP14:%.*]] = add nsw i32 [[TMP11]], [[TMP13]]
; CHECK-NEXT:    store i32 [[TMP14]], i32* [[TMP12]], align 4
; CHECK-NEXT:    ret i32 undef
;
  %1 = mul nsw i32 %n, 5
  %2 = add nsw i32 %1, 7
  %3 = load i32, i32* %A, align 4
  %4 = add nsw i32 %2, %3
  store i32 %4, i32* %A, align 4
  %5 = add nsw i32 %1, 8
  %6 = getelementptr inbounds i32, i32* %A, i64 1
  %7 = load i32, i32* %6, align 4
  %8 = add nsw i32 %5, %7
  store i32 %8, i32* %6, align 4
  %9 = add nsw i32 %1, 9
  %10 = getelementptr inbounds i32, i32* %A, i64 2
  %11 = load i32, i32* %10, align 4
  %12 = add nsw i32 %9, %11
  store i32 %12, i32* %10, align 4
  %13 = add nsw i32 %1, 10
  %14 = getelementptr inbounds i32, i32* %A, i64 3
  %15 = load i32, i32* %14, align 4
  %16 = add nsw i32 %13, %15
  store i32 %16, i32* %14, align 4
  %17 = add nsw i32 %1, 11
  %18 = getelementptr inbounds i32, i32* %A, i64 4
  %19 = load i32, i32* %18, align 4
  %20 = add nsw i32 %17, %19
  store i32 %20, i32* %18, align 4
  ret i32 undef
}
