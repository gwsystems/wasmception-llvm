; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instsimplify -S | FileCheck %s

define i32 @select_or_icmp(i32 %x, i32 %y, i32 %z) {
; CHECK-LABEL: @select_or_icmp(
; CHECK-NEXT:    ret i32 [[Z:%.*]]
;
  %A = icmp ne i32 %x, %z
  %B = icmp ne i32 %y, %z
  %C = or i1 %A, %B
  %D = select i1 %C, i32 %z, i32 %x
  ret i32 %D
}

define <2 x i8> @select_or_icmp_vec(<2 x i8> %x, <2 x i8> %y, <2 x i8> %z) {
; CHECK-LABEL: @select_or_icmp_vec(
; CHECK-NEXT:    ret <2 x i8> [[Z:%.*]]
;
  %A = icmp ne <2 x i8> %x, %z
  %B = icmp ne <2 x i8> %y, %z
  %C = or <2 x i1> %A, %B
  %D = select <2 x i1> %C, <2 x i8> %z, <2 x i8> %x
  ret <2 x i8> %D
}

define i32 @select_or_icmp2(i32 %x, i32 %y, i32 %z) {
; CHECK-LABEL: @select_or_icmp2(
; CHECK-NEXT:    ret i32 [[Z:%.*]]
;
  %A = icmp ne i32 %x, %z
  %B = icmp ne i32 %y, %z
  %C = or i1 %A, %B
  %D = select i1 %C, i32 %z, i32 %y
  ret i32 %D
}

define i32 @select_or_icmp_alt(i32 %x, i32 %y, i32 %z) {
; CHECK-LABEL: @select_or_icmp_alt(
; CHECK-NEXT:    ret i32 [[X:%.*]]
;
  %A = icmp ne i32 %x, %z
  %B = icmp ne i32 %y, %z
  %C = or i1 %A, %B
  %D = select i1 %C, i32 %x, i32 %z
  ret i32 %D
}

define i32 @select_or_icmp_alt2(i32 %x, i32 %y, i32 %z) {
; CHECK-LABEL: @select_or_icmp_alt2(
; CHECK-NEXT:    ret i32 [[Y:%.*]]
;
  %A = icmp ne i32 %x, %z
  %B = icmp ne i32 %y, %z
  %C = or i1 %A, %B
  %D = select i1 %C, i32 %y, i32 %z
  ret i32 %D
}

define i32 @select_or_icmp_inv_alt(i32 %x, i32 %y, i32 %z) {
; CHECK-LABEL: @select_or_icmp_inv_alt(
; CHECK-NEXT:    ret i32 [[X:%.*]]
;
  %A = icmp ne i32 %z, %x
  %B = icmp ne i32 %z, %y
  %C = or i1 %A, %B
  %D = select i1 %C, i32 %x, i32 %z
  ret i32 %D
}

define i32 @select_or_inv_icmp_alt(i32 %x, i32 %y, i32 %z) {
; CHECK-LABEL: @select_or_inv_icmp_alt(
; CHECK-NEXT:    ret i32 [[X:%.*]]
;
  %A = icmp ne i32 %z, %x
  %B = icmp ne i32 %z, %y
  %C = or i1 %B, %A
  %D = select i1 %C, i32 %x, i32 %z
  ret i32 %D
}

define <2 x i8> @select_or_icmp_alt_vec(<2 x i8> %x, <2 x i8> %y, <2 x i8> %z) {
; CHECK-LABEL: @select_or_icmp_alt_vec(
; CHECK-NEXT:    ret <2 x i8> [[X:%.*]]
;
  %A = icmp ne <2 x i8> %x, %z
  %B = icmp ne <2 x i8> %y, %z
  %C = or <2 x i1> %A, %B
  %D = select <2 x i1> %C, <2 x i8> %x, <2 x i8> %z
  ret <2 x i8> %D
}

define i32 @select_or_inv_icmp(i32 %x, i32 %y, i32 %z) {
; CHECK-LABEL: @select_or_inv_icmp(
; CHECK-NEXT:    ret i32 [[Z:%.*]]
;
  %A = icmp ne i32 %x, %z
  %B = icmp ne i32 %y, %z
  %C = or i1 %B , %A
  %D = select i1 %C, i32 %z, i32 %x
  ret i32 %D
}

define i32 @select_or_icmp_inv(i32 %x, i32 %y, i32 %z) {
; CHECK-LABEL: @select_or_icmp_inv(
; CHECK-NEXT:    ret i32 [[Z:%.*]]
;
  %A = icmp ne i32 %z, %x
  %B = icmp ne i32 %z, %y
  %C = or i1 %A, %B
  %D = select i1 %C, i32 %z, i32 %x
  ret i32 %D
}

; Negative tests
define i32 @select_and_icmp_pred_bad_1(i32 %x, i32 %y, i32 %z) {
; CHECK-LABEL: @select_and_icmp_pred_bad_1(
; CHECK-NEXT:    [[A:%.*]] = icmp eq i32 [[X:%.*]], [[Z:%.*]]
; CHECK-NEXT:    [[B:%.*]] = icmp ne i32 [[Y:%.*]], [[Z]]
; CHECK-NEXT:    [[C:%.*]] = or i1 [[A]], [[B]]
; CHECK-NEXT:    [[D:%.*]] = select i1 [[C]], i32 [[Z]], i32 [[X]]
; CHECK-NEXT:    ret i32 [[D]]
;
  %A = icmp eq i32 %x, %z
  %B = icmp ne i32 %y, %z
  %C = or i1 %A, %B
  %D = select i1 %C, i32 %z, i32 %x
  ret i32 %D
}

define i32 @select_and_icmp_pred_bad_2(i32 %x, i32 %y, i32 %z) {
; CHECK-LABEL: @select_and_icmp_pred_bad_2(
; CHECK-NEXT:    [[A:%.*]] = icmp ne i32 [[X:%.*]], [[Z:%.*]]
; CHECK-NEXT:    [[B:%.*]] = icmp eq i32 [[Y:%.*]], [[Z]]
; CHECK-NEXT:    [[C:%.*]] = or i1 [[A]], [[B]]
; CHECK-NEXT:    [[D:%.*]] = select i1 [[C]], i32 [[Z]], i32 [[X]]
; CHECK-NEXT:    ret i32 [[D]]
;
  %A = icmp ne i32 %x, %z
  %B = icmp eq i32 %y, %z
  %C = or i1 %A, %B
  %D = select i1 %C, i32 %z, i32 %x
  ret i32 %D
}

define i32 @select_and_icmp_pred_bad_3(i32 %x, i32 %y, i32 %z) {
; CHECK-LABEL: @select_and_icmp_pred_bad_3(
; CHECK-NEXT:    [[A:%.*]] = icmp eq i32 [[X:%.*]], [[Z:%.*]]
; CHECK-NEXT:    [[B:%.*]] = icmp eq i32 [[Y:%.*]], [[Z]]
; CHECK-NEXT:    [[C:%.*]] = or i1 [[A]], [[B]]
; CHECK-NEXT:    [[D:%.*]] = select i1 [[C]], i32 [[Z]], i32 [[X]]
; CHECK-NEXT:    ret i32 [[D]]
;
  %A = icmp eq i32 %x, %z
  %B = icmp eq i32 %y, %z
  %C = or i1 %A, %B
  %D = select i1 %C, i32 %z, i32 %x
  ret i32 %D
}

define i32 @select_and_icmp_pred_bad_4(i32 %x, i32 %y, i32 %z) {
; CHECK-LABEL: @select_and_icmp_pred_bad_4(
; CHECK-NEXT:    [[A:%.*]] = icmp ne i32 [[X:%.*]], [[Z:%.*]]
; CHECK-NEXT:    [[B:%.*]] = icmp ne i32 [[Y:%.*]], [[Z]]
; CHECK-NEXT:    [[C:%.*]] = and i1 [[A]], [[B]]
; CHECK-NEXT:    [[D:%.*]] = select i1 [[C]], i32 [[Z]], i32 [[X]]
; CHECK-NEXT:    ret i32 [[D]]
;
  %A = icmp ne i32 %x, %z
  %B = icmp ne i32 %y, %z
  %C = and i1 %A, %B
  %D = select i1 %C, i32 %z, i32 %x
  ret i32 %D
}

define i32 @select_or_icmp_bad_true_val(i32 %x, i32 %y, i32 %z, i32 %k) {
; CHECK-LABEL: @select_or_icmp_bad_true_val(
; CHECK-NEXT:    [[A:%.*]] = icmp ne i32 [[X:%.*]], [[Z:%.*]]
; CHECK-NEXT:    [[B:%.*]] = icmp ne i32 [[Y:%.*]], [[Z]]
; CHECK-NEXT:    [[C:%.*]] = or i1 [[A]], [[B]]
; CHECK-NEXT:    [[D:%.*]] = select i1 [[C]], i32 [[K:%.*]], i32 [[X]]
; CHECK-NEXT:    ret i32 [[D]]
;
  %A = icmp ne i32 %x, %z
  %B = icmp ne i32 %y, %z
  %C = or i1 %A, %B
  %D = select i1 %C, i32 %k, i32 %x
  ret i32 %D
}

define i32 @select_or_icmp_bad_false_val(i32 %x, i32 %y, i32 %z, i32 %k) {
; CHECK-LABEL: @select_or_icmp_bad_false_val(
; CHECK-NEXT:    [[A:%.*]] = icmp ne i32 [[X:%.*]], [[Z:%.*]]
; CHECK-NEXT:    [[B:%.*]] = icmp ne i32 [[Y:%.*]], [[Z]]
; CHECK-NEXT:    [[C:%.*]] = or i1 [[A]], [[B]]
; CHECK-NEXT:    [[D:%.*]] = select i1 [[C]], i32 [[Z]], i32 [[K:%.*]]
; CHECK-NEXT:    ret i32 [[D]]
;
  %A = icmp ne i32 %x, %z
  %B = icmp ne i32 %y, %z
  %C = or i1 %A, %B
  %D = select i1 %C, i32 %z, i32 %k
  ret i32 %D
}

define i32 @select_or_icmp_bad_op(i32 %x, i32 %y, i32 %z, i32 %k) {
; CHECK-LABEL: @select_or_icmp_bad_op(
; CHECK-NEXT:    [[A:%.*]] = icmp ne i32 [[K:%.*]], [[Z:%.*]]
; CHECK-NEXT:    [[B:%.*]] = icmp ne i32 [[Y:%.*]], [[Z]]
; CHECK-NEXT:    [[C:%.*]] = or i1 [[A]], [[B]]
; CHECK-NEXT:    [[D:%.*]] = select i1 [[C]], i32 [[Z]], i32 [[X:%.*]]
; CHECK-NEXT:    ret i32 [[D]]
;
  %A = icmp ne i32 %k, %z
  %B = icmp ne i32 %y, %z
  %C = or i1 %A, %B
  %D = select i1 %C, i32 %z, i32 %x
  ret i32 %D
}


define i32 @select_or_icmp_bad_op_2(i32 %x, i32 %y, i32 %z, i32 %k) {
; CHECK-LABEL: @select_or_icmp_bad_op_2(
; CHECK-NEXT:    [[A:%.*]] = icmp ne i32 [[X:%.*]], [[K:%.*]]
; CHECK-NEXT:    [[B:%.*]] = icmp ne i32 [[Y:%.*]], [[Z:%.*]]
; CHECK-NEXT:    [[C:%.*]] = or i1 [[A]], [[B]]
; CHECK-NEXT:    [[D:%.*]] = select i1 [[C]], i32 [[Z]], i32 [[X]]
; CHECK-NEXT:    ret i32 [[D]]
;
  %A = icmp ne i32 %x, %k
  %B = icmp ne i32 %y, %z
  %C = or i1 %A, %B
  %D = select i1 %C, i32 %z, i32 %x
  ret i32 %D
}

define i32 @select_or_icmp_alt_bad_1(i32 %x, i32 %y, i32 %z) {
; CHECK-LABEL: @select_or_icmp_alt_bad_1(
; CHECK-NEXT:    [[A:%.*]] = icmp eq i32 [[X:%.*]], [[Z:%.*]]
; CHECK-NEXT:    [[B:%.*]] = icmp ne i32 [[Y:%.*]], [[Z]]
; CHECK-NEXT:    [[C:%.*]] = or i1 [[A]], [[B]]
; CHECK-NEXT:    [[D:%.*]] = select i1 [[C]], i32 [[X]], i32 [[Z]]
; CHECK-NEXT:    ret i32 [[D]]
;
  %A = icmp eq i32 %x, %z
  %B = icmp ne i32 %y, %z
  %C = or i1 %A, %B
  %D = select i1 %C, i32 %x, i32 %z
  ret i32 %D
}

define i32 @select_or_icmp_alt_bad_2(i32 %x, i32 %y, i32 %z) {
; CHECK-LABEL: @select_or_icmp_alt_bad_2(
; CHECK-NEXT:    [[A:%.*]] = icmp ne i32 [[X:%.*]], [[Z:%.*]]
; CHECK-NEXT:    [[B:%.*]] = icmp eq i32 [[Y:%.*]], [[Z]]
; CHECK-NEXT:    [[C:%.*]] = or i1 [[A]], [[B]]
; CHECK-NEXT:    [[D:%.*]] = select i1 [[C]], i32 [[X]], i32 [[Z]]
; CHECK-NEXT:    ret i32 [[D]]
;
  %A = icmp ne i32 %x, %z
  %B = icmp eq i32 %y, %z
  %C = or i1 %A, %B
  %D = select i1 %C, i32 %x, i32 %z
  ret i32 %D
}

define i32 @select_or_icmp_alt_bad_3(i32 %x, i32 %y, i32 %z) {
; CHECK-LABEL: @select_or_icmp_alt_bad_3(
; CHECK-NEXT:    [[A:%.*]] = icmp eq i32 [[X:%.*]], [[Z:%.*]]
; CHECK-NEXT:    [[B:%.*]] = icmp eq i32 [[Y:%.*]], [[Z]]
; CHECK-NEXT:    [[C:%.*]] = or i1 [[A]], [[B]]
; CHECK-NEXT:    [[D:%.*]] = select i1 [[C]], i32 [[X]], i32 [[Z]]
; CHECK-NEXT:    ret i32 [[D]]
;
  %A = icmp eq i32 %x, %z
  %B = icmp eq i32 %y, %z
  %C = or i1 %A, %B
  %D = select i1 %C, i32 %x, i32 %z
  ret i32 %D
}

define i32 @select_or_icmp_alt_bad_4(i32 %x, i32 %y, i32 %z) {
; CHECK-LABEL: @select_or_icmp_alt_bad_4(
; CHECK-NEXT:    [[A:%.*]] = icmp ne i32 [[X:%.*]], [[Z:%.*]]
; CHECK-NEXT:    [[B:%.*]] = icmp ne i32 [[Y:%.*]], [[Z]]
; CHECK-NEXT:    [[C:%.*]] = and i1 [[A]], [[B]]
; CHECK-NEXT:    [[D:%.*]] = select i1 [[C]], i32 [[X]], i32 [[Z]]
; CHECK-NEXT:    ret i32 [[D]]
;
  %A = icmp ne i32 %x, %z
  %B = icmp ne i32 %y, %z
  %C = and i1 %A, %B
  %D = select i1 %C, i32 %x, i32 %z
  ret i32 %D
}

define i32 @select_or_icmp_alt_bad_5(i32 %x, i32 %y, i32 %z, i32 %k) {
; CHECK-LABEL: @select_or_icmp_alt_bad_5(
; CHECK-NEXT:    [[A:%.*]] = icmp ne i32 [[X:%.*]], [[K:%.*]]
; CHECK-NEXT:    [[B:%.*]] = icmp ne i32 [[Y:%.*]], [[Z:%.*]]
; CHECK-NEXT:    [[C:%.*]] = or i1 [[A]], [[B]]
; CHECK-NEXT:    [[D:%.*]] = select i1 [[C]], i32 [[X]], i32 [[Z]]
; CHECK-NEXT:    ret i32 [[D]]
;
  %A = icmp ne i32 %x, %k
  %B = icmp ne i32 %y, %z
  %C = or i1 %A, %B
  %D = select i1 %C, i32 %x, i32 %z
  ret i32 %D
}

define i32 @select_or_icmp_alt_bad_true_val(i32 %x, i32 %y, i32 %z, i32 %k) {
; CHECK-LABEL: @select_or_icmp_alt_bad_true_val(
; CHECK-NEXT:    [[A:%.*]] = icmp ne i32 [[X:%.*]], [[Z:%.*]]
; CHECK-NEXT:    [[B:%.*]] = icmp ne i32 [[Y:%.*]], [[Z]]
; CHECK-NEXT:    [[C:%.*]] = or i1 [[A]], [[B]]
; CHECK-NEXT:    [[D:%.*]] = select i1 [[C]], i32 [[K:%.*]], i32 [[Z]]
; CHECK-NEXT:    ret i32 [[D]]
;
  %A = icmp ne i32 %x, %z
  %B = icmp ne i32 %y, %z
  %C = or i1 %A, %B
  %D = select i1 %C, i32 %k, i32 %z
  ret i32 %D
}

define i32 @select_or_icmp_alt_bad_false_val(i32 %x, i32 %y, i32 %z, i32 %k) {
; CHECK-LABEL: @select_or_icmp_alt_bad_false_val(
; CHECK-NEXT:    [[A:%.*]] = icmp ne i32 [[X:%.*]], [[Z:%.*]]
; CHECK-NEXT:    [[B:%.*]] = icmp ne i32 [[Y:%.*]], [[Z]]
; CHECK-NEXT:    [[C:%.*]] = or i1 [[A]], [[B]]
; CHECK-NEXT:    [[D:%.*]] = select i1 [[C]], i32 [[X]], i32 [[K:%.*]]
; CHECK-NEXT:    ret i32 [[D]]
;
  %A = icmp ne i32 %x, %z
  %B = icmp ne i32 %y, %z
  %C = or i1 %A, %B
  %D = select i1 %C, i32 %x, i32 %k
  ret i32 %D
}
