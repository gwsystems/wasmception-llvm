; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

define i32 @test_sdiv_canonicalize_op0(i32 %x, i32 %y) {
; CHECK-LABEL: @test_sdiv_canonicalize_op0(
; CHECK-NEXT:    [[NEG:%.*]] = sub nsw i32 0, [[X:%.*]]
; CHECK-NEXT:    [[SDIV:%.*]] = sdiv i32 [[NEG]], [[Y:%.*]]
; CHECK-NEXT:    ret i32 [[SDIV]]
;
  %neg = sub nsw i32 0, %x
  %sdiv = sdiv i32 %neg, %y
  ret i32 %sdiv
}

define i32 @test_sdiv_canonicalize_op0_exact(i32 %x, i32 %y) {
; CHECK-LABEL: @test_sdiv_canonicalize_op0_exact(
; CHECK-NEXT:    [[NEG:%.*]] = sub nsw i32 0, [[X:%.*]]
; CHECK-NEXT:    [[SDIV:%.*]] = sdiv exact i32 [[NEG]], [[Y:%.*]]
; CHECK-NEXT:    ret i32 [[SDIV]]
;
  %neg = sub nsw i32 0, %x
  %sdiv = sdiv exact i32 %neg, %y
  ret i32 %sdiv
}

define i32 @test_sdiv_canonicalize_op1(i32 %x, i32 %z) {
; CHECK-LABEL: @test_sdiv_canonicalize_op1(
; CHECK-NEXT:    [[Y:%.*]] = mul i32 [[Z:%.*]], 3
; CHECK-NEXT:    [[NEG:%.*]] = sub nsw i32 0, [[X:%.*]]
; CHECK-NEXT:    [[SDIV:%.*]] = sdiv i32 [[Y]], [[NEG]]
; CHECK-NEXT:    ret i32 [[SDIV]]
;
  %y = mul i32 %z, 3
  %neg = sub nsw i32 0, %x
  %sdiv = sdiv i32 %y, %neg
  ret i32 %sdiv
}

define i32 @test_sdiv_canonicalize_nonsw(i32 %x, i32 %y) {
; CHECK-LABEL: @test_sdiv_canonicalize_nonsw(
; CHECK-NEXT:    [[NEG:%.*]] = sub i32 0, [[X:%.*]]
; CHECK-NEXT:    [[SDIV:%.*]] = sdiv i32 [[NEG]], [[Y:%.*]]
; CHECK-NEXT:    ret i32 [[SDIV]]
;
  %neg = sub i32 0, %x
  %sdiv = sdiv i32 %neg, %y
  ret i32 %sdiv
}

define <2 x i32> @test_sdiv_canonicalize_vec(<2 x i32> %x, <2 x i32> %y) {
; CHECK-LABEL: @test_sdiv_canonicalize_vec(
; CHECK-NEXT:    [[NEG:%.*]] = sub nsw <2 x i32> zeroinitializer, [[X:%.*]]
; CHECK-NEXT:    [[SDIV:%.*]] = sdiv <2 x i32> [[NEG]], [[Y:%.*]]
; CHECK-NEXT:    ret <2 x i32> [[SDIV]]
;
  %neg = sub nsw <2 x i32> <i32 0, i32 0>, %x
  %sdiv = sdiv <2 x i32> %neg, %y
  ret <2 x i32> %sdiv
}

define i32 @test_sdiv_canonicalize_multiple_uses(i32 %x, i32 %y) {
; CHECK-LABEL: @test_sdiv_canonicalize_multiple_uses(
; CHECK-NEXT:    [[NEG:%.*]] = sub nsw i32 0, [[X:%.*]]
; CHECK-NEXT:    [[SDIV:%.*]] = sdiv i32 [[NEG]], [[Y:%.*]]
; CHECK-NEXT:    [[SDIV2:%.*]] = sdiv i32 [[SDIV]], [[NEG]]
; CHECK-NEXT:    ret i32 [[SDIV2]]
;
  %neg = sub nsw i32 0, %x
  %sdiv = sdiv i32 %neg, %y
  %sdiv2 = sdiv i32 %sdiv, %neg
  ret i32 %sdiv2
}

; There is combination: (X/-CE) -> -(X/CE)
; There is another combination: -(X/CE) -> (X/-CE)
; Make sure don't combine them endless.

@X = global i32 5

define i64 @test_sdiv_canonicalize_constexpr(i64 %L1) {
; currently opt folds (sub nsw i64 0, constexpr) -> (sub i64, 0, constexpr).
; sdiv canonicalize requires a nsw sub.
; CHECK-LABEL: @test_sdiv_canonicalize_constexpr(
; CHECK-NEXT:    [[B4:%.*]] = sdiv i64 [[L1:%.*]], sub (i64 0, i64 ptrtoint (i32* @X to i64))
; CHECK-NEXT:    ret i64 [[B4]]
;
  %v1 = ptrtoint i32* @X to i64
  %B8 = sub nsw i64 0, %v1
  %B4 = sdiv i64 %L1, %B8
  ret i64 %B4
}
