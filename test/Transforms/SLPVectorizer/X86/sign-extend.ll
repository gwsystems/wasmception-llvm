; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -slp-vectorizer < %s -S -o - -mtriple=x86_64-apple-macosx10.10.0 -mcpu=core2 | FileCheck %s

define <4 x i32> @sign_extend_v_v(<4 x i16> %lhs) {
; CHECK-LABEL: @sign_extend_v_v(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[VECEXT:%.*]] = extractelement <4 x i16> [[LHS:%.*]], i32 0
; CHECK-NEXT:    [[CONV:%.*]] = sext i16 [[VECEXT]] to i32
; CHECK-NEXT:    [[VECINIT:%.*]] = insertelement <4 x i32> undef, i32 [[CONV]], i32 0
; CHECK-NEXT:    [[VECEXT1:%.*]] = extractelement <4 x i16> [[LHS]], i32 1
; CHECK-NEXT:    [[CONV2:%.*]] = sext i16 [[VECEXT1]] to i32
; CHECK-NEXT:    [[VECINIT3:%.*]] = insertelement <4 x i32> [[VECINIT]], i32 [[CONV2]], i32 1
; CHECK-NEXT:    [[VECEXT4:%.*]] = extractelement <4 x i16> [[LHS]], i32 2
; CHECK-NEXT:    [[CONV5:%.*]] = sext i16 [[VECEXT4]] to i32
; CHECK-NEXT:    [[VECINIT6:%.*]] = insertelement <4 x i32> [[VECINIT3]], i32 [[CONV5]], i32 2
; CHECK-NEXT:    [[VECEXT7:%.*]] = extractelement <4 x i16> [[LHS]], i32 3
; CHECK-NEXT:    [[CONV8:%.*]] = sext i16 [[VECEXT7]] to i32
; CHECK-NEXT:    [[VECINIT9:%.*]] = insertelement <4 x i32> [[VECINIT6]], i32 [[CONV8]], i32 3
; CHECK-NEXT:    ret <4 x i32> [[VECINIT9]]
;
entry:
  %vecext = extractelement <4 x i16> %lhs, i32 0
  %conv = sext i16 %vecext to i32
  %vecinit = insertelement <4 x i32> undef, i32 %conv, i32 0
  %vecext1 = extractelement <4 x i16> %lhs, i32 1
  %conv2 = sext i16 %vecext1 to i32
  %vecinit3 = insertelement <4 x i32> %vecinit, i32 %conv2, i32 1
  %vecext4 = extractelement <4 x i16> %lhs, i32 2
  %conv5 = sext i16 %vecext4 to i32
  %vecinit6 = insertelement <4 x i32> %vecinit3, i32 %conv5, i32 2
  %vecext7 = extractelement <4 x i16> %lhs, i32 3
  %conv8 = sext i16 %vecext7 to i32
  %vecinit9 = insertelement <4 x i32> %vecinit6, i32 %conv8, i32 3
  ret <4 x i32> %vecinit9
}
