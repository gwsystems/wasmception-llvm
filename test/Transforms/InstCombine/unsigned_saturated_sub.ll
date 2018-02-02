; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -instcombine -S < %s | FileCheck %s

; Transforms for unsigned saturated subtraction idioms are tested here.
; In all cases, we want to form a canonical min/max op (the compare and
; select operands are the same), so that is recognized by the backend.
; The backend recognition is tested in test/CodeGen/X86/psubus.ll.

; (a > b) ? a - b : 0 -> ((a > b) ? a : b) - b)

define i64 @max_sub_ugt(i64 %lhs, i64 %rhs) {
; CHECK-LABEL: @max_sub_ugt(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt i64 [[LHS:%.*]], [[RHS:%.*]]
; CHECK-NEXT:    [[SUB:%.*]] = sub i64 [[LHS]], [[RHS]]
; CHECK-NEXT:    [[SEL:%.*]] = select i1 [[CMP]], i64 [[SUB]], i64 0
; CHECK-NEXT:    ret i64 [[SEL]]
;
  %cmp = icmp ugt i64 %lhs, %rhs
  %sub = sub i64 %lhs, %rhs
  %sel = select i1 %cmp, i64 %sub ,i64 0
  ret i64 %sel
}

; (a >= b) ? a - b : 0 -> ((a >= b) ? a : b) - b)

define <4 x i32> @max_sub_uge_128(<4 x i32> %lhs, <4 x i32> %rhs) {
; CHECK-LABEL: @max_sub_uge_128(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult <4 x i32> [[LHS:%.*]], [[RHS:%.*]]
; CHECK-NEXT:    [[SUB:%.*]] = sub <4 x i32> [[LHS]], [[RHS]]
; CHECK-NEXT:    [[SEL:%.*]] = select <4 x i1> [[CMP]], <4 x i32> zeroinitializer, <4 x i32> [[SUB]]
; CHECK-NEXT:    ret <4 x i32> [[SEL]]
;
  %cmp = icmp uge <4 x i32> %lhs, %rhs
  %sub = sub <4 x i32> %lhs, %rhs
  %sel = select <4 x i1> %cmp, <4 x i32> %sub, <4 x i32> zeroinitializer
  ret <4 x i32> %sel
}

; (b < a) ? a - b : 0 -> ((a > b) ? a : b) - b)

define i64 @max_sub_ult(i64 %lhs, i64 %rhs) {
; CHECK-LABEL: @max_sub_ult(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt i64 [[LHS:%.*]], [[RHS:%.*]]
; CHECK-NEXT:    [[SUB:%.*]] = sub i64 [[LHS]], [[RHS]]
; CHECK-NEXT:    [[SEL:%.*]] = select i1 [[CMP]], i64 [[SUB]], i64 0
; CHECK-NEXT:    ret i64 [[SEL]]
;
  %cmp = icmp ult i64 %rhs, %lhs
  %sub = sub i64 %lhs, %rhs
  %sel = select i1 %cmp, i64 %sub ,i64 0
  ret i64 %sel
}

; (b > a) ? 0 : a - b -> ((a > b) ? a : b) - b)

define i64 @max_sub_ugt_sel_swapped(i64 %lhs, i64 %rhs) {
; CHECK-LABEL: @max_sub_ugt_sel_swapped(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult i64 [[LHS:%.*]], [[RHS:%.*]]
; CHECK-NEXT:    [[SUB:%.*]] = sub i64 [[LHS]], [[RHS]]
; CHECK-NEXT:    [[SEL:%.*]] = select i1 [[CMP]], i64 0, i64 [[SUB]]
; CHECK-NEXT:    ret i64 [[SEL]]
;
  %cmp = icmp ugt i64 %rhs, %lhs
  %sub = sub i64 %lhs, %rhs
  %sel = select i1 %cmp, i64 0 ,i64 %sub
  ret i64 %sel
}

; (a < b) ? 0 : a - b -> ((a > b) ? a : b) - b)

define i64 @max_sub_ult_sel_swapped(i64 %lhs, i64 %rhs) {
; CHECK-LABEL: @max_sub_ult_sel_swapped(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult i64 [[LHS:%.*]], [[RHS:%.*]]
; CHECK-NEXT:    [[SUB:%.*]] = sub i64 [[LHS]], [[RHS]]
; CHECK-NEXT:    [[SEL:%.*]] = select i1 [[CMP]], i64 0, i64 [[SUB]]
; CHECK-NEXT:    ret i64 [[SEL]]
;
  %cmp = icmp ult i64 %lhs, %rhs
  %sub = sub i64 %lhs, %rhs
  %sel = select i1 %cmp, i64 0 ,i64 %sub
  ret i64 %sel
}

; ((a > b) ? b - a : 0) -> (b - ((a > b) ? a : b))

define i64 @neg_max_sub_ugt(i64 %lhs, i64 %rhs) {
; CHECK-LABEL: @neg_max_sub_ugt(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult i64 [[RHS:%.*]], [[LHS:%.*]]
; CHECK-NEXT:    [[SUB:%.*]] = sub i64 [[RHS]], [[LHS]]
; CHECK-NEXT:    [[SEL:%.*]] = select i1 [[CMP]], i64 [[SUB]], i64 0
; CHECK-NEXT:    ret i64 [[SEL]]
;
  %cmp = icmp ugt i64 %lhs, %rhs
  %sub = sub i64 %rhs, %lhs
  %sel = select i1 %cmp, i64 %sub ,i64 0
  ret i64 %sel
}

; ((b < a) ? b - a : 0) -> - ((a > b) ? a : b) - b)

define i64 @neg_max_sub_ult(i64 %lhs, i64 %rhs) {
; CHECK-LABEL: @neg_max_sub_ult(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult i64 [[RHS:%.*]], [[LHS:%.*]]
; CHECK-NEXT:    [[SUB:%.*]] = sub i64 [[RHS]], [[LHS]]
; CHECK-NEXT:    [[SEL:%.*]] = select i1 [[CMP]], i64 [[SUB]], i64 0
; CHECK-NEXT:    ret i64 [[SEL]]
;
  %cmp = icmp ult i64 %rhs, %lhs
  %sub = sub i64 %rhs, %lhs
  %sel = select i1 %cmp, i64 %sub ,i64 0
  ret i64 %sel
}

; ((b > a) ? 0 : b - a) -> - ((a > b) ? a : b) - b)

define i64 @neg_max_sub_ugt_sel_swapped(i64 %lhs, i64 %rhs) {
; CHECK-LABEL: @neg_max_sub_ugt_sel_swapped(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt i64 [[RHS:%.*]], [[LHS:%.*]]
; CHECK-NEXT:    [[SUB:%.*]] = sub i64 [[RHS]], [[LHS]]
; CHECK-NEXT:    [[SEL:%.*]] = select i1 [[CMP]], i64 0, i64 [[SUB]]
; CHECK-NEXT:    ret i64 [[SEL]]
;
  %cmp = icmp ugt i64 %rhs, %lhs
  %sub = sub i64 %rhs, %lhs
  %sel = select i1 %cmp, i64 0 ,i64 %sub
  ret i64 %sel
}

; ((a < b) ? 0 : b - a) -> - ((a > b) ? a : b) - b)

define i64 @neg_max_sub_ult_sel_swapped(i64 %lhs, i64 %rhs) {
; CHECK-LABEL: @neg_max_sub_ult_sel_swapped(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt i64 [[RHS:%.*]], [[LHS:%.*]]
; CHECK-NEXT:    [[SUB:%.*]] = sub i64 [[RHS]], [[LHS]]
; CHECK-NEXT:    [[SEL:%.*]] = select i1 [[CMP]], i64 0, i64 [[SUB]]
; CHECK-NEXT:    ret i64 [[SEL]]
;
  %cmp = icmp ult i64 %lhs, %rhs
  %sub = sub i64 %rhs, %lhs
  %sel = select i1 %cmp, i64 0 ,i64 %sub
  ret i64 %sel
}

