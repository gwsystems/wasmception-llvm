; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S %s -instcombine | FileCheck %s

@glob = external global i16

define void @patatino(i8 %beth) {
; CHECK-LABEL: @patatino(
; CHECK-NEXT:    [[CONV:%.*]] = zext i8 [[BETH:%.*]] to i32
; CHECK-NEXT:    br i1 false, label [[IF_THEN9:%.*]], label [[IF_THEN9]]
; CHECK:       if.then9:
; CHECK-NEXT:    [[MUL:%.*]] = mul nuw nsw i32 [[CONV]], [[CONV]]
; CHECK-NEXT:    [[TINKY:%.*]] = load i16, i16* @glob, align 2
; CHECK-NEXT:    [[TMP1:%.*]] = trunc i32 [[MUL]] to i16
; CHECK-NEXT:    [[CONV14:%.*]] = and i16 [[TINKY]], [[TMP1]]
; CHECK-NEXT:    store i16 [[CONV14]], i16* @glob, align 2
; CHECK-NEXT:    ret void
;
  %conv = zext i8 %beth to i32
  %mul = mul nuw nsw i32 %conv, %conv
  %conv3 = and i32 %mul, 255
  %tobool8 = icmp ne i32 %mul, %conv3
  br i1 %tobool8, label %if.then9, label %if.then9

if.then9:
  %tinky = load i16, i16* @glob
  %conv13 = sext i16 %tinky to i32
  %and = and i32 %mul, %conv13
  %conv14 = trunc i32 %and to i16
  store i16 %conv14, i16* @glob
  ret void
}
