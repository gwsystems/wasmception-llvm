; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instsimplify -S | FileCheck %s

define i47 @shl_by_0(i47 %A) {
; CHECK-LABEL: @shl_by_0(
; CHECK-NEXT:    ret i47 [[A:%.*]]
;
  %B = shl i47 %A, 0
  ret i47 %B
}

define i41 @shl_0(i41 %X) {
; CHECK-LABEL: @shl_0(
; CHECK-NEXT:    ret i41 0
;
  %B = shl i41 0, %X
  ret i41 %B
}

define <2 x i41> @shl_0_vec_undef_elt(<2 x i41> %X) {
; CHECK-LABEL: @shl_0_vec_undef_elt(
; CHECK-NEXT:    ret <2 x i41> zeroinitializer
;
  %B = shl <2 x i41> <i41 0, i41 undef>, %X
  ret <2 x i41> %B
}

define i41 @ashr_by_0(i41 %A) {
; CHECK-LABEL: @ashr_by_0(
; CHECK-NEXT:    ret i41 [[A:%.*]]
;
  %B = ashr i41 %A, 0
  ret i41 %B
}

define i39 @ashr_0(i39 %X) {
; CHECK-LABEL: @ashr_0(
; CHECK-NEXT:    ret i39 0
;
  %B = ashr i39 0, %X
  ret i39 %B
}

define <2 x i141> @ashr_0_vec_undef_elt(<2 x i141> %X) {
; CHECK-LABEL: @ashr_0_vec_undef_elt(
; CHECK-NEXT:    ret <2 x i141> zeroinitializer
;
  %B = shl <2 x i141> <i141 undef, i141 0>, %X
  ret <2 x i141> %B
}

define i55 @lshr_by_bitwidth(i55 %A) {
; CHECK-LABEL: @lshr_by_bitwidth(
; CHECK-NEXT:    ret i55 undef
;
  %B = lshr i55 %A, 55
  ret i55 %B
}

define i32 @shl_by_bitwidth(i32 %A) {
; CHECK-LABEL: @shl_by_bitwidth(
; CHECK-NEXT:    ret i32 undef
;
  %B = shl i32 %A, 32
  ret i32 %B
}

define <4 x i32> @lshr_by_bitwidth_splat(<4 x i32> %A) {
; CHECK-LABEL: @lshr_by_bitwidth_splat(
; CHECK-NEXT:    ret <4 x i32> undef
;
  %B = lshr <4 x i32> %A, <i32 32, i32 32, i32 32, i32 32>     ;; shift all bits out
  ret <4 x i32> %B
}

define <4 x i32> @lshr_by_0_splat(<4 x i32> %A) {
; CHECK-LABEL: @lshr_by_0_splat(
; CHECK-NEXT:    ret <4 x i32> [[A:%.*]]
;
  %B = lshr <4 x i32> %A, zeroinitializer
  ret <4 x i32> %B
}

define <4 x i32> @shl_by_bitwidth_splat(<4 x i32> %A) {
; CHECK-LABEL: @shl_by_bitwidth_splat(
; CHECK-NEXT:    ret <4 x i32> undef
;
  %B = shl <4 x i32> %A, <i32 32, i32 32, i32 32, i32 32>     ;; shift all bits out
  ret <4 x i32> %B
}

define i32 @ashr_undef() {
; CHECK-LABEL: @ashr_undef(
; CHECK-NEXT:    ret i32 0
;
  %B = ashr i32 undef, 2  ;; top two bits must be equal, so not undef
  ret i32 %B
}

define i32 @ashr_undef_variable_shift_amount(i32 %A) {
; CHECK-LABEL: @ashr_undef_variable_shift_amount(
; CHECK-NEXT:    ret i32 0
;
  %B = ashr i32 undef, %A  ;; top %A bits must be equal, so not undef
  ret i32 %B
}

define i32 @ashr_all_ones(i32 %A) {
; CHECK-LABEL: @ashr_all_ones(
; CHECK-NEXT:    ret i32 -1
;
  %B = ashr i32 -1, %A
  ret i32 %B
}

define <3 x i8> @ashr_all_ones_vec_with_undef_elts(<3 x i8> %x, <3 x i8> %y) {
; CHECK-LABEL: @ashr_all_ones_vec_with_undef_elts(
; CHECK-NEXT:    ret <3 x i8> <i8 -1, i8 -1, i8 -1>
;
  %sh = ashr <3 x i8> <i8 undef, i8 -1, i8 undef>, %y
  ret <3 x i8> %sh
}

define i8 @lshr_by_sext_bool(i1 %x, i8 %y) {
; CHECK-LABEL: @lshr_by_sext_bool(
; CHECK-NEXT:    ret i8 [[Y:%.*]]
;
  %s = sext i1 %x to i8
  %r = lshr i8 %y, %s
  ret i8 %r
}

define <2 x i8> @lshr_by_sext_bool_vec(<2 x i1> %x, <2 x i8> %y) {
; CHECK-LABEL: @lshr_by_sext_bool_vec(
; CHECK-NEXT:    ret <2 x i8> [[Y:%.*]]
;
  %s = sext <2 x i1> %x to <2 x i8>
  %r = lshr <2 x i8> %y, %s
  ret <2 x i8> %r
}

define i8 @ashr_by_sext_bool(i1 %x, i8 %y) {
; CHECK-LABEL: @ashr_by_sext_bool(
; CHECK-NEXT:    ret i8 [[Y:%.*]]
;
  %s = sext i1 %x to i8
  %r = ashr i8 %y, %s
  ret i8 %r
}

define <2 x i8> @ashr_by_sext_bool_vec(<2 x i1> %x, <2 x i8> %y) {
; CHECK-LABEL: @ashr_by_sext_bool_vec(
; CHECK-NEXT:    ret <2 x i8> [[Y:%.*]]
;
  %s = sext <2 x i1> %x to <2 x i8>
  %r = ashr <2 x i8> %y, %s
  ret <2 x i8> %r
}

define i8 @shl_by_sext_bool(i1 %x, i8 %y) {
; CHECK-LABEL: @shl_by_sext_bool(
; CHECK-NEXT:    ret i8 [[Y:%.*]]
;
  %s = sext i1 %x to i8
  %r = shl i8 %y, %s
  ret i8 %r
}

define <2 x i8> @shl_by_sext_bool_vec(<2 x i1> %x, <2 x i8> %y) {
; CHECK-LABEL: @shl_by_sext_bool_vec(
; CHECK-NEXT:    ret <2 x i8> [[Y:%.*]]
;
  %s = sext <2 x i1> %x to <2 x i8>
  %r = shl <2 x i8> %y, %s
  ret <2 x i8> %r
}

define i64 @shl_or_shr(i32 %a, i32 %b) {
; CHECK-LABEL: @shl_or_shr(
; CHECK-NEXT:    [[TMP1:%.*]] = zext i32 [[A:%.*]] to i64
; CHECK-NEXT:    [[TMP2:%.*]] = zext i32 [[B:%.*]] to i64
; CHECK-NEXT:    [[TMP3:%.*]] = shl nuw i64 [[TMP1]], 32
; CHECK-NEXT:    [[TMP4:%.*]] = or i64 [[TMP2]], [[TMP3]]
; CHECK-NEXT:    [[TMP5:%.*]] = lshr i64 [[TMP4]], 32
; CHECK-NEXT:    ret i64 [[TMP5]]
;
  %tmp1 = zext i32 %a to i64
  %tmp2 = zext i32 %b to i64
  %tmp3 = shl nuw i64 %tmp1, 32
  %tmp4 = or i64 %tmp2, %tmp3
  %tmp5 = lshr i64 %tmp4, 32
  ret i64 %tmp5
}

; Since shift count of shl is smaller than the size of %b, OR cannot be eliminated.
define i64 @shl_or_shr2(i32 %a, i32 %b) {
; CHECK-LABEL: @shl_or_shr2(
; CHECK-NEXT:    [[TMP1:%.*]] = zext i32 [[A:%.*]] to i64
; CHECK-NEXT:    [[TMP2:%.*]] = zext i32 [[B:%.*]] to i64
; CHECK-NEXT:    [[TMP3:%.*]] = shl nuw i64 [[TMP1]], 31
; CHECK-NEXT:    [[TMP4:%.*]] = or i64 [[TMP2]], [[TMP3]]
; CHECK-NEXT:    [[TMP5:%.*]] = lshr i64 [[TMP4]], 31
; CHECK-NEXT:    ret i64 [[TMP5]]
;
  %tmp1 = zext i32 %a to i64
  %tmp2 = zext i32 %b to i64
  %tmp3 = shl nuw i64 %tmp1, 31
  %tmp4 = or i64 %tmp2, %tmp3
  %tmp5 = lshr i64 %tmp4, 31
  ret i64 %tmp5
}

; Unit test for vector integer
define <2 x i64> @shl_or_shr1v(<2 x i32> %a, <2 x i32> %b) {
; CHECK-LABEL: @shl_or_shr1v(
; CHECK-NEXT:    [[TMP1:%.*]] = zext <2 x i32> [[A:%.*]] to <2 x i64>
; CHECK-NEXT:    [[TMP2:%.*]] = zext <2 x i32> [[B:%.*]] to <2 x i64>
; CHECK-NEXT:    [[TMP3:%.*]] = shl nuw <2 x i64> [[TMP1]], <i64 32, i64 32>
; CHECK-NEXT:    [[TMP4:%.*]] = or <2 x i64> [[TMP3]], [[TMP2]]
; CHECK-NEXT:    [[TMP5:%.*]] = lshr <2 x i64> [[TMP4]], <i64 32, i64 32>
; CHECK-NEXT:    ret <2 x i64> [[TMP5]]
;
  %tmp1 = zext <2 x i32> %a to <2 x i64>
  %tmp2 = zext <2 x i32> %b to <2 x i64>
  %tmp3 = shl nuw <2 x i64> %tmp1, <i64 32, i64 32>
  %tmp4 = or <2 x i64> %tmp3, %tmp2
  %tmp5 = lshr <2 x i64> %tmp4, <i64 32, i64 32>
  ret <2 x i64> %tmp5
}

; Negative unit test for vector integer
define <2 x i64> @shl_or_shr2v(<2 x i32> %a, <2 x i32> %b) {
; CHECK-LABEL: @shl_or_shr2v(
; CHECK-NEXT:    [[TMP1:%.*]] = zext <2 x i32> [[A:%.*]] to <2 x i64>
; CHECK-NEXT:    [[TMP2:%.*]] = zext <2 x i32> [[B:%.*]] to <2 x i64>
; CHECK-NEXT:    [[TMP3:%.*]] = shl nuw <2 x i64> [[TMP1]], <i64 31, i64 31>
; CHECK-NEXT:    [[TMP4:%.*]] = or <2 x i64> [[TMP2]], [[TMP3]]
; CHECK-NEXT:    [[TMP5:%.*]] = lshr <2 x i64> [[TMP4]], <i64 31, i64 31>
; CHECK-NEXT:    ret <2 x i64> [[TMP5]]
;
  %tmp1 = zext <2 x i32> %a to <2 x i64>
  %tmp2 = zext <2 x i32> %b to <2 x i64>
  %tmp3 = shl nuw <2 x i64> %tmp1, <i64 31, i64 31>
  %tmp4 = or <2 x i64> %tmp2, %tmp3
  %tmp5 = lshr <2 x i64> %tmp4, <i64 31, i64 31>
  ret <2 x i64> %tmp5
}
