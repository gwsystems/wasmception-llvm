; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

; PR1949

define i1 @test1(i32 %a) {
; CHECK-LABEL: @test1(
; CHECK-NEXT:    [[C:%.*]] = icmp ugt i32 %a, -5
; CHECK-NEXT:    ret i1 [[C]]
;
  %b = add i32 %a, 4
  %c = icmp ult i32 %b, 4
  ret i1 %c
}

define <2 x i1> @test1vec(<2 x i32> %a) {
; CHECK-LABEL: @test1vec(
; CHECK-NEXT:    [[C:%.*]] = icmp ugt <2 x i32> %a, <i32 -5, i32 -5>
; CHECK-NEXT:    ret <2 x i1> [[C]]
;
  %b = add <2 x i32> %a, <i32 4, i32 4>
  %c = icmp ult <2 x i32> %b, <i32 4, i32 4>
  ret <2 x i1> %c
}

define i1 @test2(i32 %a) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    [[C:%.*]] = icmp ult i32 %a, 4
; CHECK-NEXT:    ret i1 [[C]]
;
  %b = sub i32 %a, 4
  %c = icmp ugt i32 %b, -5
  ret i1 %c
}

define <2 x i1> @test2vec(<2 x i32> %a) {
; CHECK-LABEL: @test2vec(
; CHECK-NEXT:    [[C:%.*]] = icmp ult <2 x i32> %a, <i32 4, i32 4>
; CHECK-NEXT:    ret <2 x i1> [[C]]
;
  %b = sub <2 x i32> %a, <i32 4, i32 4>
  %c = icmp ugt <2 x i32> %b, <i32 -5, i32 -5>
  ret <2 x i1> %c
}

define i1 @test3(i32 %a) {
; CHECK-LABEL: @test3(
; CHECK-NEXT:    [[C:%.*]] = icmp sgt i32 %a, 2147483643
; CHECK-NEXT:    ret i1 [[C]]
;
  %b = add i32 %a, 4
  %c = icmp slt i32 %b, 2147483652
  ret i1 %c
}

define <2 x i1> @test3vec(<2 x i32> %a) {
; CHECK-LABEL: @test3vec(
; CHECK-NEXT:    [[C:%.*]] = icmp sgt <2 x i32> %a, <i32 2147483643, i32 2147483643>
; CHECK-NEXT:    ret <2 x i1> [[C]]
;
  %b = add <2 x i32> %a, <i32 4, i32 4>
  %c = icmp slt <2 x i32> %b, <i32 2147483652, i32 2147483652>
  ret <2 x i1> %c
}

define i1 @test4(i32 %a) {
; CHECK-LABEL: @test4(
; CHECK-NEXT:    [[C:%.*]] = icmp slt i32 %a, -4
; CHECK-NEXT:    ret i1 [[C]]
;
  %b = add i32 %a, 2147483652
  %c = icmp sge i32 %b, 4
  ret i1 %c
}

define <2 x i1> @test4vec(<2 x i32> %a) {
; CHECK-LABEL: @test4vec(
; CHECK-NEXT:    [[C:%.*]] = icmp slt <2 x i32> %a, <i32 -4, i32 -4>
; CHECK-NEXT:    ret <2 x i1> [[C]]
;
  %b = add <2 x i32> %a, <i32 2147483652, i32 2147483652>
  %c = icmp sge <2 x i32> %b, <i32 4, i32 4>
  ret <2 x i1> %c
}

; icmp Pred (add nsw X, C2), C --> icmp Pred X, (C - C2), when C - C2 does not overflow.
; This becomes equality because it's at the limit.

define i1 @nsw_slt1(i8 %a) {
; CHECK-LABEL: @nsw_slt1(
; CHECK-NEXT:    [[C:%.*]] = icmp eq i8 %a, -128
; CHECK-NEXT:    ret i1 [[C]]
;
  %b = add nsw i8 %a, 100
  %c = icmp slt i8 %b, -27
  ret i1 %c
}

define <2 x i1> @nsw_slt1_splat_vec(<2 x i8> %a) {
; CHECK-LABEL: @nsw_slt1_splat_vec(
; CHECK-NEXT:    [[C:%.*]] = icmp eq <2 x i8> [[A:%.*]], <i8 -128, i8 -128>
; CHECK-NEXT:    ret <2 x i1> [[C]]
;
  %b = add nsw <2 x i8> %a, <i8 100, i8 100>
  %c = icmp slt <2 x i8> %b, <i8 -27, i8 -27>
  ret <2 x i1> %c
}

; icmp Pred (add nsw X, C2), C --> icmp Pred X, (C - C2), when C - C2 does not overflow.
; This becomes equality because it's at the limit.

define i1 @nsw_slt2(i8 %a) {
; CHECK-LABEL: @nsw_slt2(
; CHECK-NEXT:    [[C:%.*]] = icmp ne i8 %a, 127
; CHECK-NEXT:    ret i1 [[C]]
;
  %b = add nsw i8 %a, -100
  %c = icmp slt i8 %b, 27
  ret i1 %c
}

define <2 x i1> @nsw_slt2_splat_vec(<2 x i8> %a) {
; CHECK-LABEL: @nsw_slt2_splat_vec(
; CHECK-NEXT:    [[C:%.*]] = icmp ne <2 x i8> [[A:%.*]], <i8 127, i8 127>
; CHECK-NEXT:    ret <2 x i1> [[C]]
;
  %b = add nsw <2 x i8> %a, <i8 -100, i8 -100>
  %c = icmp slt <2 x i8> %b, <i8 27, i8 27>
  ret <2 x i1> %c
}

; icmp Pred (add nsw X, C2), C --> icmp Pred X, (C - C2), when C - C2 does not overflow.
; Less than the limit, so the predicate doesn't change.

define i1 @nsw_slt3(i8 %a) {
; CHECK-LABEL: @nsw_slt3(
; CHECK-NEXT:    [[C:%.*]] = icmp slt i8 %a, -126
; CHECK-NEXT:    ret i1 [[C]]
;
  %b = add nsw i8 %a, 100
  %c = icmp slt i8 %b, -26
  ret i1 %c
}

; icmp Pred (add nsw X, C2), C --> icmp Pred X, (C - C2), when C - C2 does not overflow.
; Less than the limit, so the predicate doesn't change.

define i1 @nsw_slt4(i8 %a) {
; CHECK-LABEL: @nsw_slt4(
; CHECK-NEXT:    [[C:%.*]] = icmp slt i8 %a, 126
; CHECK-NEXT:    ret i1 [[C]]
;
  %b = add nsw i8 %a, -100
  %c = icmp slt i8 %b, 26
  ret i1 %c
}

; icmp Pred (add nsw X, C2), C --> icmp Pred X, (C - C2), when C - C2 does not overflow.
; Try sgt to make sure that works too.

define i1 @nsw_sgt1(i8 %a) {
; CHECK-LABEL: @nsw_sgt1(
; CHECK-NEXT:    [[C:%.*]] = icmp eq i8 %a, 127
; CHECK-NEXT:    ret i1 [[C]]
;
  %b = add nsw i8 %a, -100
  %c = icmp sgt i8 %b, 26
  ret i1 %c
}

; FIXME: This should be 'eq 127' as above.
define <2 x i1> @nsw_sgt1_splat_vec(<2 x i8> %a) {
; CHECK-LABEL: @nsw_sgt1_splat_vec(
; CHECK-NEXT:    [[C:%.*]] = icmp eq <2 x i8> [[A:%.*]], <i8 127, i8 127>
; CHECK-NEXT:    ret <2 x i1> [[C]]
;
  %b = add nsw <2 x i8> %a, <i8 -100, i8 -100>
  %c = icmp sgt <2 x i8> %b, <i8 26, i8 26>
  ret <2 x i1> %c
}

define i1 @nsw_sgt2(i8 %a) {
; CHECK-LABEL: @nsw_sgt2(
; CHECK-NEXT:    [[C:%.*]] = icmp sgt i8 [[A:%.*]], -126
; CHECK-NEXT:    ret i1 [[C]]
;
  %b = add nsw i8 %a, 100
  %c = icmp sgt i8 %b, -26
  ret i1 %c
}

define <2 x i1> @nsw_sgt2_splat_vec(<2 x i8> %a) {
; CHECK-LABEL: @nsw_sgt2_splat_vec(
; CHECK-NEXT:    [[C:%.*]] = icmp sgt <2 x i8> %a, <i8 -126, i8 -126>
; CHECK-NEXT:    ret <2 x i1> [[C]]
;
  %b = add nsw <2 x i8> %a, <i8 100, i8 100>
  %c = icmp sgt <2 x i8> %b, <i8 -26, i8 -26>
  ret <2 x i1> %c
}

; icmp Pred (add nsw X, C2), C --> icmp Pred X, (C - C2), when C - C2 does not overflow.
; Comparison with 0 doesn't need special-casing.

define i1 @slt_zero_add_nsw(i32 %a) {
; CHECK-LABEL: @slt_zero_add_nsw(
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i32 %a, -1
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %add = add nsw i32 %a, 1
  %cmp = icmp slt i32 %add, 0
  ret i1 %cmp
}

; The same fold should work with vectors.

define <2 x i1> @slt_zero_add_nsw_splat_vec(<2 x i8> %a) {
; CHECK-LABEL: @slt_zero_add_nsw_splat_vec(
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt <2 x i8> %a, <i8 -1, i8 -1>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %add = add nsw <2 x i8> %a, <i8 1, i8 1>
  %cmp = icmp slt <2 x i8> %add, zeroinitializer
  ret <2 x i1> %cmp
}

; Test the edges - instcombine should not interfere with simplification to constants.
; Constant subtraction does not overflow, but this is false.

define i1 @nsw_slt3_ov_no(i8 %a) {
; CHECK-LABEL: @nsw_slt3_ov_no(
; CHECK-NEXT:    ret i1 false
;
  %b = add nsw i8 %a, 100
  %c = icmp slt i8 %b, -28
  ret i1 %c
}

; Test the edges - instcombine should not interfere with simplification to constants.
; Constant subtraction overflows. This is false.

define i1 @nsw_slt4_ov(i8 %a) {
; CHECK-LABEL: @nsw_slt4_ov(
; CHECK-NEXT:    ret i1 false
;
  %b = add nsw i8 %a, 100
  %c = icmp slt i8 %b, -29
  ret i1 %c
}

; Test the edges - instcombine should not interfere with simplification to constants.
; Constant subtraction overflows. This is true.

define i1 @nsw_slt5_ov(i8 %a) {
; CHECK-LABEL: @nsw_slt5_ov(
; CHECK-NEXT:    ret i1 true
;
  %b = add nsw i8 %a, -100
  %c = icmp slt i8 %b, 28
  ret i1 %c
}

; InstCombine should not thwart this opportunity to simplify completely.

define i1 @slt_zero_add_nsw_signbit(i8 %x) {
; CHECK-LABEL: @slt_zero_add_nsw_signbit(
; CHECK-NEXT:    ret i1 true
;
  %y = add nsw i8 %x, -128
  %z = icmp slt i8 %y, 0
  ret i1 %z
}

; InstCombine should not thwart this opportunity to simplify completely.

define i1 @slt_zero_add_nuw_signbit(i8 %x) {
; CHECK-LABEL: @slt_zero_add_nuw_signbit(
; CHECK-NEXT:    ret i1 true
;
  %y = add nuw i8 %x, 128
  %z = icmp slt i8 %y, 0
  ret i1 %z
}

