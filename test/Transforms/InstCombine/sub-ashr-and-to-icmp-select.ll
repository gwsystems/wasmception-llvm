; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -instcombine %s -S -o - | FileCheck %s

; Clamp negative to zero:
; E.g., clamp0 implemented in a shifty way, could be optimized as v > 0 ? v : 0, where sub hasNoSignedWrap.
; int32 clamp0(int32 v) {
;   return ((-(v) >> 31) & (v));
; }
;

; Scalar Types

define i8 @sub_ashr_and_i8(i8 %x, i8 %y) {
; CHECK-LABEL: @sub_ashr_and_i8(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp sgt i8 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[AND:%.*]] = select i1 [[TMP1]], i8 [[X]], i8 0
; CHECK-NEXT:    ret i8 [[AND]]
;
  %sub = sub nsw i8 %y, %x
  %shr = ashr i8 %sub, 7
  %and = and i8 %shr, %x
  ret i8 %and
}

define i16 @sub_ashr_and_i16(i16 %x, i16 %y) {
; CHECK-LABEL: @sub_ashr_and_i16(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp sgt i16 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[AND:%.*]] = select i1 [[TMP1]], i16 [[X]], i16 0
; CHECK-NEXT:    ret i16 [[AND]]
;

  %sub = sub nsw i16 %y, %x
  %shr = ashr i16 %sub, 15
  %and = and i16 %shr, %x
  ret i16 %and
}

define i32 @sub_ashr_and_i32(i32 %x, i32 %y) {
; CHECK-LABEL: @sub_ashr_and_i32(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp sgt i32 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[AND:%.*]] = select i1 [[TMP1]], i32 [[X]], i32 0
; CHECK-NEXT:    ret i32 [[AND]]
;
  %sub = sub nsw i32 %y, %x
  %shr = ashr i32 %sub, 31
  %and = and i32 %shr, %x
  ret i32 %and
}

define i64 @sub_ashr_and_i64(i64 %x, i64 %y) {
; CHECK-LABEL: @sub_ashr_and_i64(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp sgt i64 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[AND:%.*]] = select i1 [[TMP1]], i64 [[X]], i64 0
; CHECK-NEXT:    ret i64 [[AND]]
;
  %sub = sub nsw i64 %y, %x
  %shr = ashr i64 %sub, 63
  %and = and i64 %shr, %x
  ret i64 %and
}

; nuw nsw

define i32 @sub_ashr_and_i32_nuw_nsw(i32 %x, i32 %y) {
; CHECK-LABEL: @sub_ashr_and_i32_nuw_nsw(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp sgt i32 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[AND:%.*]] = select i1 [[TMP1]], i32 [[X]], i32 0
; CHECK-NEXT:    ret i32 [[AND]]
;
  %sub = sub nuw nsw i32 %y, %x
  %shr = ashr i32 %sub, 31
  %and = and i32 %shr, %x
  ret i32 %and
}

; Commute

define i32 @sub_ashr_and_i32_commute(i32 %x, i32 %y) {
; CHECK-LABEL: @sub_ashr_and_i32_commute(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp sgt i32 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[AND:%.*]] = select i1 [[TMP1]], i32 [[X]], i32 0
; CHECK-NEXT:    ret i32 [[AND]]
;
  %sub = sub nsw i32 %y, %x
  %shr = ashr i32 %sub, 31
  %and = and i32 %x, %shr  ; commute %x and %shr
  ret i32 %and
}

; Vector Types

define <4 x i32> @sub_ashr_and_i32_vec(<4 x i32> %x, <4 x i32> %y) {
; CHECK-LABEL: @sub_ashr_and_i32_vec(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp sgt <4 x i32> [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[AND:%.*]] = select <4 x i1> [[TMP1]], <4 x i32> [[X]], <4 x i32> zeroinitializer
; CHECK-NEXT:    ret <4 x i32> [[AND]]
;
  %sub = sub nsw <4 x i32> %y, %x
  %shr = ashr <4 x i32> %sub, <i32 31, i32 31, i32 31, i32 31>
  %and = and <4 x i32> %shr, %x
  ret <4 x i32> %and
}

define <4 x i32> @sub_ashr_and_i32_vec_nuw_nsw(<4 x i32> %x, <4 x i32> %y) {
; CHECK-LABEL: @sub_ashr_and_i32_vec_nuw_nsw(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp sgt <4 x i32> [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[AND:%.*]] = select <4 x i1> [[TMP1]], <4 x i32> [[X]], <4 x i32> zeroinitializer
; CHECK-NEXT:    ret <4 x i32> [[AND]]
;
  %sub = sub nuw nsw <4 x i32> %y, %x
  %shr = ashr <4 x i32> %sub, <i32 31, i32 31, i32 31, i32 31>
  %and = and <4 x i32> %shr, %x
  ret <4 x i32> %and
}

define <4 x i32> @sub_ashr_and_i32_vec_commute(<4 x i32> %x, <4 x i32> %y) {
; CHECK-LABEL: @sub_ashr_and_i32_vec_commute(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp sgt <4 x i32> [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[AND:%.*]] = select <4 x i1> [[TMP1]], <4 x i32> [[X]], <4 x i32> zeroinitializer
; CHECK-NEXT:    ret <4 x i32> [[AND]]
;
  %sub = sub nsw <4 x i32> %y, %x
  %shr = ashr <4 x i32> %sub, <i32 31, i32 31, i32 31, i32 31>
  %and = and <4 x i32> %x, %shr  ; commute %x and %shr
  ret <4 x i32> %and
}

; Extra uses

define i32 @sub_ashr_and_i32_extra_use_sub(i32 %x, i32 %y, i32* %p) {
; CHECK-LABEL: @sub_ashr_and_i32_extra_use_sub(
; CHECK-NEXT:    [[SUB:%.*]] = sub nsw i32 [[Y:%.*]], [[X:%.*]]
; CHECK-NEXT:    store i32 [[SUB]], i32* [[P:%.*]], align 4
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt i32 [[Y]], [[X]]
; CHECK-NEXT:    [[AND:%.*]] = select i1 [[TMP1]], i32 [[X]], i32 0
; CHECK-NEXT:    ret i32 [[AND]]
;
  %sub = sub nsw i32 %y, %x
  store i32 %sub, i32* %p
  %shr = ashr i32 %sub, 31
  %and = and i32 %shr, %x
  ret i32 %and
}

define i32 @sub_ashr_and_i32_extra_use_and(i32 %x, i32 %y, i32* %p) {
; CHECK-LABEL: @sub_ashr_and_i32_extra_use_and(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp sgt i32 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[AND:%.*]] = select i1 [[TMP1]], i32 [[X]], i32 0
; CHECK-NEXT:    store i32 [[AND]], i32* [[P:%.*]], align 4
; CHECK-NEXT:    ret i32 [[AND]]
;
  %sub = sub nsw i32 %y, %x
  %shr = ashr i32 %sub, 31
  %and = and i32 %shr, %x
  store i32 %and, i32* %p
  ret i32 %and
}

; Negative Tests

define i32 @sub_ashr_and_i32_extra_use_ashr(i32 %x, i32 %y, i32* %p) {
; CHECK-LABEL: @sub_ashr_and_i32_extra_use_ashr(
; CHECK-NEXT:    [[SUB:%.*]] = sub nsw i32 [[Y:%.*]], [[X:%.*]]
; CHECK-NEXT:    [[SHR:%.*]] = ashr i32 [[SUB]], 31
; CHECK-NEXT:    store i32 [[SHR]], i32* [[P:%.*]], align 4
; CHECK-NEXT:    [[AND:%.*]] = and i32 [[SHR]], [[X]]
; CHECK-NEXT:    ret i32 [[AND]]
;
  %sub = sub nsw i32 %y, %x
  %shr = ashr i32 %sub, 31
  store i32 %shr, i32* %p
  %and = and i32 %shr, %x
  ret i32 %and
}

define i32 @sub_ashr_and_i32_no_nuw_nsw(i32 %x, i32 %y) {
; CHECK-LABEL: @sub_ashr_and_i32_no_nuw_nsw(
; CHECK-NEXT:    [[SUB:%.*]] = sub i32 [[Y:%.*]], [[X:%.*]]
; CHECK-NEXT:    [[SHR:%.*]] = ashr i32 [[SUB]], 7
; CHECK-NEXT:    [[AND:%.*]] = and i32 [[SHR]], [[X]]
; CHECK-NEXT:    ret i32 [[AND]]
;
  %sub = sub i32 %y, %x
  %shr = ashr i32 %sub, 7
  %and = and i32 %shr, %x
  ret i32 %and
}

define <4 x i32> @sub_ashr_and_i32_vec_undef(<4 x i32> %x, <4 x i32> %y) {
; CHECK-LABEL: @sub_ashr_and_i32_vec_undef(
; CHECK-NEXT:    [[SUB:%.*]] = sub nsw <4 x i32> [[Y:%.*]], [[X:%.*]]
; CHECK-NEXT:    [[SHR:%.*]] = ashr <4 x i32> [[SUB]], <i32 31, i32 31, i32 31, i32 undef>
; CHECK-NEXT:    [[AND:%.*]] = and <4 x i32> [[SHR]], [[X]]
; CHECK-NEXT:    ret <4 x i32> [[AND]]
;
  %sub = sub nsw <4 x i32> %y, %x
  %shr = ashr <4 x i32> %sub, <i32 31, i32 31, i32 31, i32 undef>
  %and = and <4 x i32> %shr, %x
  ret <4 x i32> %and
}

define i32 @sub_ashr_and_i32_shift_wrong_bit(i32 %x, i32 %y) {
; CHECK-LABEL: @sub_ashr_and_i32_shift_wrong_bit(
; CHECK-NEXT:    [[SUB:%.*]] = sub nsw i32 [[Y:%.*]], [[X:%.*]]
; CHECK-NEXT:    [[SHR:%.*]] = ashr i32 [[SUB]], 15
; CHECK-NEXT:    [[AND:%.*]] = and i32 [[SHR]], [[X]]
; CHECK-NEXT:    ret i32 [[AND]]
;
  %sub = sub nsw i32 %y, %x
  %shr = ashr i32 %sub, 15
  %and = and i32 %shr, %x
  ret i32 %and
}
