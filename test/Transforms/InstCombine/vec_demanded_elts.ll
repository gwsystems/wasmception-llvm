; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

define i32 @test2(float %f) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    [[TMP5:%.*]] = fmul float %f, %f
; CHECK-NEXT:    [[TMP21:%.*]] = bitcast float [[TMP5]] to i32
; CHECK-NEXT:    ret i32 [[TMP21]]
;
  %tmp5 = fmul float %f, %f
  %tmp9 = insertelement <4 x float> undef, float %tmp5, i32 0
  %tmp10 = insertelement <4 x float> %tmp9, float 0.000000e+00, i32 1
  %tmp11 = insertelement <4 x float> %tmp10, float 0.000000e+00, i32 2
  %tmp12 = insertelement <4 x float> %tmp11, float 0.000000e+00, i32 3
  %tmp19 = bitcast <4 x float> %tmp12 to <4 x i32>
  %tmp21 = extractelement <4 x i32> %tmp19, i32 0
  ret i32 %tmp21
}

define void @get_image() nounwind {
; CHECK-LABEL: @get_image(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = call i32 @fgetc(i8* null) #0
; CHECK-NEXT:    br i1 false, label %bb2, label %bb3
; CHECK:       bb2:
; CHECK-NEXT:    br label %bb3
; CHECK:       bb3:
; CHECK-NEXT:    unreachable
;
entry:
  %0 = call i32 @fgetc(i8* null) nounwind               ; <i32> [#uses=1]
  %1 = trunc i32 %0 to i8         ; <i8> [#uses=1]
  %tmp2 = insertelement <100 x i8> zeroinitializer, i8 %1, i32 1          ; <<100 x i8>> [#uses=1]
  %tmp1 = extractelement <100 x i8> %tmp2, i32 0          ; <i8> [#uses=1]
  %2 = icmp eq i8 %tmp1, 80               ; <i1> [#uses=1]
  br i1 %2, label %bb2, label %bb3

bb2:            ; preds = %entry
  br label %bb3

bb3:            ; preds = %bb2, %entry
  unreachable
}

; PR4340
define void @vac(<4 x float>* nocapture %a) nounwind {
; CHECK-LABEL: @vac(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    store <4 x float> zeroinitializer, <4 x float>* %a, align 16
; CHECK-NEXT:    ret void
;
entry:
  %tmp1 = load <4 x float>, <4 x float>* %a		; <<4 x float>> [#uses=1]
  %vecins = insertelement <4 x float> %tmp1, float 0.000000e+00, i32 0	; <<4 x float>> [#uses=1]
  %vecins4 = insertelement <4 x float> %vecins, float 0.000000e+00, i32 1; <<4 x float>> [#uses=1]
  %vecins6 = insertelement <4 x float> %vecins4, float 0.000000e+00, i32 2; <<4 x float>> [#uses=1]
  %vecins8 = insertelement <4 x float> %vecins6, float 0.000000e+00, i32 3; <<4 x float>> [#uses=1]
  store <4 x float> %vecins8, <4 x float>* %a
  ret void
}

declare i32 @fgetc(i8*)

define <4 x float> @dead_shuffle_elt(<4 x float> %x, <2 x float> %y) nounwind {
; CHECK-LABEL: @dead_shuffle_elt(
; CHECK-NEXT:    [[SHUFFLE_I:%.*]] = shufflevector <2 x float> %y, <2 x float> undef, <4 x i32> <i32 0, i32 1, i32 undef, i32 undef>
; CHECK-NEXT:    [[SHUFFLE9_I:%.*]] = shufflevector <4 x float> %x, <4 x float> [[SHUFFLE_I]], <4 x i32> <i32 4, i32 5, i32 2, i32 3>
; CHECK-NEXT:    ret <4 x float> [[SHUFFLE9_I]]
;
  %shuffle.i = shufflevector <2 x float> %y, <2 x float> %y, <4 x i32> <i32 0, i32 1, i32 0, i32 1>
  %shuffle9.i = shufflevector <4 x float> %x, <4 x float> %shuffle.i, <4 x i32> <i32 4, i32 5, i32 2, i32 3>
  ret <4 x float> %shuffle9.i
}

define <2 x float> @test_fptrunc(double %f) {
; CHECK-LABEL: @test_fptrunc(
; CHECK-NEXT:    [[TMP1:%.*]] = insertelement <2 x double> <double undef, double 0.000000e+00>, double %f, i32 0
; CHECK-NEXT:    [[TMP2:%.*]] = fptrunc <2 x double> [[TMP1]] to <2 x float>
; CHECK-NEXT:    ret <2 x float> [[TMP2]]
;
  %tmp9 = insertelement <4 x double> undef, double %f, i32 0
  %tmp10 = insertelement <4 x double> %tmp9, double 0.000000e+00, i32 1
  %tmp11 = insertelement <4 x double> %tmp10, double 0.000000e+00, i32 2
  %tmp12 = insertelement <4 x double> %tmp11, double 0.000000e+00, i32 3
  %tmp5 = fptrunc <4 x double> %tmp12 to <4 x float>
  %ret = shufflevector <4 x float> %tmp5, <4 x float> undef, <2 x i32> <i32 0, i32 1>
  ret <2 x float> %ret
}

define <2 x double> @test_fpext(float %f) {
; CHECK-LABEL: @test_fpext(
; CHECK-NEXT:    [[TMP1:%.*]] = insertelement <2 x float> <float undef, float 0.000000e+00>, float %f, i32 0
; CHECK-NEXT:    [[TMP2:%.*]] = fpext <2 x float> [[TMP1]] to <2 x double>
; CHECK-NEXT:    ret <2 x double> [[TMP2]]
;
  %tmp9 = insertelement <4 x float> undef, float %f, i32 0
  %tmp10 = insertelement <4 x float> %tmp9, float 0.000000e+00, i32 1
  %tmp11 = insertelement <4 x float> %tmp10, float 0.000000e+00, i32 2
  %tmp12 = insertelement <4 x float> %tmp11, float 0.000000e+00, i32 3
  %tmp5 = fpext <4 x float> %tmp12 to <4 x double>
  %ret = shufflevector <4 x double> %tmp5, <4 x double> undef, <2 x i32> <i32 0, i32 1>
  ret <2 x double> %ret
}

define <4 x double> @test_shuffle(<4 x double> %f) {
; CHECK-LABEL: @test_shuffle(
; CHECK-NEXT:    [[RET1:%.*]] = insertelement <4 x double> %f, double 1.000000e+00, i32 3
; CHECK-NEXT:    ret <4 x double> [[RET1]]
;
  %ret = shufflevector <4 x double> %f, <4 x double> <double undef, double 1.0, double undef, double undef>, <4 x i32> <i32 0, i32 1, i32 2, i32 5>
  ret <4 x double> %ret
}

define <4 x float> @test_select(float %f, float %g) {
; CHECK-LABEL: @test_select(
; CHECK-NEXT:    [[A3:%.*]] = insertelement <4 x float> <float undef, float undef, float undef, float 3.000000e+00>, float %f, i32 0
; CHECK-NEXT:    [[RET:%.*]] = shufflevector <4 x float> [[A3]], <4 x float> <float undef, float 4.000000e+00, float 5.000000e+00, float undef>, <4 x i32> <i32 0, i32 5, i32 6, i32 3>
; CHECK-NEXT:    ret <4 x float> [[RET]]
;
  %a0 = insertelement <4 x float> undef, float %f, i32 0
  %a1 = insertelement <4 x float> %a0, float 1.000000e+00, i32 1
  %a2 = insertelement <4 x float> %a1, float 2.000000e+00, i32 2
  %a3 = insertelement <4 x float> %a2, float 3.000000e+00, i32 3
  %b0 = insertelement <4 x float> undef, float %g, i32 0
  %b1 = insertelement <4 x float> %b0, float 4.000000e+00, i32 1
  %b2 = insertelement <4 x float> %b1, float 5.000000e+00, i32 2
  %b3 = insertelement <4 x float> %b2, float 6.000000e+00, i32 3
  %ret = select <4 x i1> <i1 true, i1 false, i1 false, i1 true>, <4 x float> %a3, <4 x float> %b3
  ret <4 x float> %ret
}

; Check that instcombine doesn't wrongly fold away the select completely.
; TODO: Should this be an insertelement rather than a shuffle?

define <2 x i64> @PR24922(<2 x i64> %v) {
; CHECK-LABEL: @PR24922(
; CHECK-NEXT:    [[RESULT1:%.*]] = insertelement <2 x i64> %v, i64 0, i32 0
; CHECK-NEXT:    ret <2 x i64> [[RESULT1]]
;
  %result = select <2 x i1> <i1 icmp eq (i64 extractelement (<2 x i64> bitcast (<4 x i32> <i32 15, i32 15, i32 15, i32 15> to <2 x i64>), i64 0), i64 0), i1 true>, <2 x i64> %v, <2 x i64> zeroinitializer
  ret <2 x i64> %result
}
