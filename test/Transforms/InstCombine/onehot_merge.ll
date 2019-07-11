; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

define i1 @and_consts(i32 %k, i32 %c1, i32 %c2) {
; CHECK-LABEL: @and_consts(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[K:%.*]], 12
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ne i32 [[TMP1]], 12
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %t1 = and i32 4, %k
  %t2 = icmp eq i32 %t1, 0
  %t5 = and i32 8, %k
  %t6 = icmp eq i32 %t5, 0
  %or = or i1 %t2, %t6
  ret i1 %or
}

define i1 @foo1_and(i32 %k, i32 %c1, i32 %c2) {
; CHECK-LABEL: @foo1_and(
; CHECK-NEXT:    [[T:%.*]] = shl i32 1, [[C1:%.*]]
; CHECK-NEXT:    [[T4:%.*]] = shl i32 1, [[C2:%.*]]
; CHECK-NEXT:    [[TMP1:%.*]] = or i32 [[T]], [[T4]]
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], [[K:%.*]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ne i32 [[TMP2]], [[TMP1]]
; CHECK-NEXT:    ret i1 [[TMP3]]
;
  %t = shl i32 1, %c1
  %t4 = shl i32 1, %c2
  %t1 = and i32 %t, %k
  %t2 = icmp eq i32 %t1, 0
  %t5 = and i32 %t4, %k
  %t6 = icmp eq i32 %t5, 0
  %or = or i1 %t2, %t6
  ret i1 %or
}

; Same as above but with operands commuted one of the ands, but not the other.
define i1 @foo1_and_commuted(i32 %k, i32 %c1, i32 %c2) {
; CHECK-LABEL: @foo1_and_commuted(
; CHECK-NEXT:    [[K2:%.*]] = mul i32 [[K:%.*]], [[K]]
; CHECK-NEXT:    [[T:%.*]] = shl i32 1, [[C1:%.*]]
; CHECK-NEXT:    [[T4:%.*]] = shl i32 1, [[C2:%.*]]
; CHECK-NEXT:    [[TMP1:%.*]] = or i32 [[T]], [[T4]]
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[K2]], [[TMP1]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ne i32 [[TMP2]], [[TMP1]]
; CHECK-NEXT:    ret i1 [[TMP3]]
;
  %k2 = mul i32 %k, %k ; to trick the complexity sorting
  %t = shl i32 1, %c1
  %t4 = shl i32 1, %c2
  %t1 = and i32 %k2, %t
  %t2 = icmp eq i32 %t1, 0
  %t5 = and i32 %t4, %k2
  %t6 = icmp eq i32 %t5, 0
  %or = or i1 %t2, %t6
  ret i1 %or
}

define i1 @or_consts(i32 %k, i32 %c1, i32 %c2) {
; CHECK-LABEL: @or_consts(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[K:%.*]], 12
; CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i32 [[TMP1]], 12
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %t1 = and i32 4, %k
  %t2 = icmp ne i32 %t1, 0
  %t5 = and i32 8, %k
  %t6 = icmp ne i32 %t5, 0
  %or = and i1 %t2, %t6
  ret i1 %or
}

define i1 @foo1_or(i32 %k, i32 %c1, i32 %c2) {
; CHECK-LABEL: @foo1_or(
; CHECK-NEXT:    [[T:%.*]] = shl i32 1, [[C1:%.*]]
; CHECK-NEXT:    [[T4:%.*]] = shl i32 1, [[C2:%.*]]
; CHECK-NEXT:    [[TMP1:%.*]] = or i32 [[T]], [[T4]]
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], [[K:%.*]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp eq i32 [[TMP2]], [[TMP1]]
; CHECK-NEXT:    ret i1 [[TMP3]]
;
  %t = shl i32 1, %c1
  %t4 = shl i32 1, %c2
  %t1 = and i32 %t, %k
  %t2 = icmp ne i32 %t1, 0
  %t5 = and i32 %t4, %k
  %t6 = icmp ne i32 %t5, 0
  %or = and i1 %t2, %t6
  ret i1 %or
}

; Same as above but with operands commuted one of the ors, but not the other.
define i1 @foo1_or_commuted(i32 %k, i32 %c1, i32 %c2) {
; CHECK-LABEL: @foo1_or_commuted(
; CHECK-NEXT:    [[K2:%.*]] = mul i32 [[K:%.*]], [[K]]
; CHECK-NEXT:    [[T:%.*]] = shl i32 1, [[C1:%.*]]
; CHECK-NEXT:    [[T4:%.*]] = shl i32 1, [[C2:%.*]]
; CHECK-NEXT:    [[TMP1:%.*]] = or i32 [[T]], [[T4]]
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[K2]], [[TMP1]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp eq i32 [[TMP2]], [[TMP1]]
; CHECK-NEXT:    ret i1 [[TMP3]]
;
  %k2 = mul i32 %k, %k ; to trick the complexity sorting
  %t = shl i32 1, %c1
  %t4 = shl i32 1, %c2
  %t1 = and i32 %k2, %t
  %t2 = icmp ne i32 %t1, 0
  %t5 = and i32 %t4, %k2
  %t6 = icmp ne i32 %t5, 0
  %or = and i1 %t2, %t6
  ret i1 %or
}

define i1 @foo1_and_signbit_lshr(i32 %k, i32 %c1, i32 %c2) {
; CHECK-LABEL: @foo1_and_signbit_lshr(
; CHECK-NEXT:    [[T:%.*]] = shl i32 1, [[C1:%.*]]
; CHECK-NEXT:    [[T4:%.*]] = lshr i32 -2147483648, [[C2:%.*]]
; CHECK-NEXT:    [[TMP1:%.*]] = or i32 [[T]], [[T4]]
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], [[K:%.*]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ne i32 [[TMP2]], [[TMP1]]
; CHECK-NEXT:    ret i1 [[TMP3]]
;
  %t = shl i32 1, %c1
  %t4 = lshr i32 -2147483648, %c2
  %t1 = and i32 %t, %k
  %t2 = icmp eq i32 %t1, 0
  %t5 = and i32 %t4, %k
  %t6 = icmp eq i32 %t5, 0
  %or = or i1 %t2, %t6
  ret i1 %or
}

define i1 @foo1_or_signbit_lshr(i32 %k, i32 %c1, i32 %c2) {
; CHECK-LABEL: @foo1_or_signbit_lshr(
; CHECK-NEXT:    [[T:%.*]] = shl i32 1, [[C1:%.*]]
; CHECK-NEXT:    [[T4:%.*]] = lshr i32 -2147483648, [[C2:%.*]]
; CHECK-NEXT:    [[TMP1:%.*]] = or i32 [[T]], [[T4]]
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], [[K:%.*]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp eq i32 [[TMP2]], [[TMP1]]
; CHECK-NEXT:    ret i1 [[TMP3]]
;
  %t = shl i32 1, %c1
  %t4 = lshr i32 -2147483648, %c2
  %t1 = and i32 %t, %k
  %t2 = icmp ne i32 %t1, 0
  %t5 = and i32 %t4, %k
  %t6 = icmp ne i32 %t5, 0
  %or = and i1 %t2, %t6
  ret i1 %or
}

; Same as last two, but shift-of-signbit replaced with 'icmp s*'
define i1 @foo1_and_signbit_lshr_without_shifting_signbit(i32 %k, i32 %c1, i32 %c2) {
; CHECK-LABEL: @foo1_and_signbit_lshr_without_shifting_signbit(
; CHECK-NEXT:    [[T0:%.*]] = shl i32 1, [[C1:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = and i32 [[T0]], [[K:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = icmp eq i32 [[T1]], 0
; CHECK-NEXT:    [[T3:%.*]] = shl i32 [[K]], [[C2:%.*]]
; CHECK-NEXT:    [[T4:%.*]] = icmp sgt i32 [[T3]], -1
; CHECK-NEXT:    [[OR:%.*]] = or i1 [[T2]], [[T4]]
; CHECK-NEXT:    ret i1 [[OR]]
;
  %t0 = shl i32 1, %c1
  %t1 = and i32 %t0, %k
  %t2 = icmp eq i32 %t1, 0
  %t3 = shl i32 %k, %c2
  %t4 = icmp sgt i32 %t3, -1
  %or = or i1 %t2, %t4
  ret i1 %or
}

define i1 @foo1_or_signbit_lshr_without_shifting_signbit(i32 %k, i32 %c1, i32 %c2) {
; CHECK-LABEL: @foo1_or_signbit_lshr_without_shifting_signbit(
; CHECK-NEXT:    [[T0:%.*]] = shl i32 1, [[C1:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = and i32 [[T0]], [[K:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = icmp ne i32 [[T1]], 0
; CHECK-NEXT:    [[T3:%.*]] = shl i32 [[K]], [[C2:%.*]]
; CHECK-NEXT:    [[T4:%.*]] = icmp slt i32 [[T3]], 0
; CHECK-NEXT:    [[OR:%.*]] = and i1 [[T2]], [[T4]]
; CHECK-NEXT:    ret i1 [[OR]]
;
  %t0 = shl i32 1, %c1
  %t1 = and i32 %t0, %k
  %t2 = icmp ne i32 %t1, 0
  %t3 = shl i32 %k, %c2
  %t4 = icmp slt i32 %t3, 0
  %or = and i1 %t2, %t4
  ret i1 %or
}

; Shift-of-signbit replaced with 'icmp s*' for both sides
define i1 @foo1_and_signbit_lshr_without_shifting_signbit_both_sides(i32 %k, i32 %c1, i32 %c2) {
; CHECK-LABEL: @foo1_and_signbit_lshr_without_shifting_signbit_both_sides(
; CHECK-NEXT:    [[T0:%.*]] = shl i32 [[K:%.*]], [[C1:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = shl i32 [[K]], [[C2:%.*]]
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[T0]], [[T2]]
; CHECK-NEXT:    [[TMP2:%.*]] = icmp sgt i32 [[TMP1]], -1
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %t0 = shl i32 %k, %c1
  %t1 = icmp sgt i32 %t0, -1
  %t2 = shl i32 %k, %c2
  %t3 = icmp sgt i32 %t2, -1
  %or = or i1 %t1, %t3
  ret i1 %or
}

define i1 @foo1_or_signbit_lshr_without_shifting_signbit_both_sides(i32 %k, i32 %c1, i32 %c2) {
; CHECK-LABEL: @foo1_or_signbit_lshr_without_shifting_signbit_both_sides(
; CHECK-NEXT:    [[T0:%.*]] = shl i32 [[K:%.*]], [[C1:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = shl i32 [[K]], [[C2:%.*]]
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[T0]], [[T2]]
; CHECK-NEXT:    [[TMP2:%.*]] = icmp slt i32 [[TMP1]], 0
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %t0 = shl i32 %k, %c1
  %t1 = icmp slt i32 %t0, 0
  %t2 = shl i32 %k, %c2
  %t3 = icmp slt i32 %t2, 0
  %or = and i1 %t1, %t3
  ret i1 %or
}

; Extra use

; Expect to fold
define i1 @foo1_and_extra_use_shl(i32 %k, i32 %c1, i32 %c2, i32* %p) {
; CHECK-LABEL: @foo1_and_extra_use_shl(
; CHECK-NEXT:    [[T0:%.*]] = shl i32 1, [[C1:%.*]]
; CHECK-NEXT:    store i32 [[T0]], i32* [[P:%.*]], align 4
; CHECK-NEXT:    [[T1:%.*]] = shl i32 1, [[C2:%.*]]
; CHECK-NEXT:    [[TMP1:%.*]] = or i32 [[T0]], [[T1]]
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], [[K:%.*]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ne i32 [[TMP2]], [[TMP1]]
; CHECK-NEXT:    ret i1 [[TMP3]]
;
  %t0 = shl i32 1, %c1
  store i32 %t0, i32* %p  ; extra use of shl
  %t1 = shl i32 1, %c2
  %t2 = and i32 %t0, %k
  %t3 = icmp eq i32 %t2, 0
  %t4 = and i32 %t1, %k
  %t5 = icmp eq i32 %t4, 0
  %or = or i1 %t3, %t5
  ret i1 %or
}

; Should not fold
define i1 @foo1_and_extra_use_and(i32 %k, i32 %c1, i32 %c2, i32* %p) {
; CHECK-LABEL: @foo1_and_extra_use_and(
; CHECK-NEXT:    [[T0:%.*]] = shl i32 1, [[C1:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = shl i32 1, [[C2:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = and i32 [[T0]], [[K:%.*]]
; CHECK-NEXT:    store i32 [[T2]], i32* [[P:%.*]], align 4
; CHECK-NEXT:    [[TMP1:%.*]] = or i32 [[T0]], [[T1]]
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], [[K]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ne i32 [[TMP2]], [[TMP1]]
; CHECK-NEXT:    ret i1 [[TMP3]]
;
  %t0 = shl i32 1, %c1
  %t1 = shl i32 1, %c2
  %t2 = and i32 %t0, %k
  store i32 %t2, i32* %p  ; extra use of and
  %t3 = icmp eq i32 %t2, 0
  %t4 = and i32 %t1, %k
  %t5 = icmp eq i32 %t4, 0
  %or = or i1 %t3, %t5
  ret i1 %or
}

; Should not fold
define i1 @foo1_and_extra_use_cmp(i32 %k, i32 %c1, i32 %c2, i1* %p) {
; CHECK-LABEL: @foo1_and_extra_use_cmp(
; CHECK-NEXT:    [[T0:%.*]] = shl i32 1, [[C1:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = shl i32 1, [[C2:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = and i32 [[T0]], [[K:%.*]]
; CHECK-NEXT:    [[T3:%.*]] = icmp eq i32 [[T2]], 0
; CHECK-NEXT:    store i1 [[T3]], i1* [[P:%.*]], align 1
; CHECK-NEXT:    [[TMP1:%.*]] = or i32 [[T0]], [[T1]]
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], [[K]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ne i32 [[TMP2]], [[TMP1]]
; CHECK-NEXT:    ret i1 [[TMP3]]
;
  %t0 = shl i32 1, %c1
  %t1 = shl i32 1, %c2
  %t2 = and i32 %t0, %k
  %t3 = icmp eq i32 %t2, 0
  store i1 %t3, i1* %p  ; extra use of cmp
  %t4 = and i32 %t1, %k
  %t5 = icmp eq i32 %t4, 0
  %or = or i1 %t3, %t5
  ret i1 %or
}

; Expect to fold
define i1 @foo1_and_extra_use_shl2(i32 %k, i32 %c1, i32 %c2, i32* %p) {
; CHECK-LABEL: @foo1_and_extra_use_shl2(
; CHECK-NEXT:    [[T0:%.*]] = shl i32 1, [[C1:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = shl i32 1, [[C2:%.*]]
; CHECK-NEXT:    store i32 [[T1]], i32* [[P:%.*]], align 4
; CHECK-NEXT:    [[TMP1:%.*]] = or i32 [[T0]], [[T1]]
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], [[K:%.*]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ne i32 [[TMP2]], [[TMP1]]
; CHECK-NEXT:    ret i1 [[TMP3]]
;
  %t0 = shl i32 1, %c1
  %t1 = shl i32 1, %c2
  store i32 %t1, i32* %p  ; extra use of shl
  %t2 = and i32 %t0, %k
  %t3 = icmp eq i32 %t2, 0
  %t4 = and i32 %t1, %k
  %t5 = icmp eq i32 %t4, 0
  %or = or i1 %t3, %t5
  ret i1 %or
}

; Should not fold
define i1 @foo1_and_extra_use_and2(i32 %k, i32 %c1, i32 %c2, i32* %p) {
; CHECK-LABEL: @foo1_and_extra_use_and2(
; CHECK-NEXT:    [[T0:%.*]] = shl i32 1, [[C1:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = shl i32 1, [[C2:%.*]]
; CHECK-NEXT:    [[T4:%.*]] = and i32 [[T1]], [[K:%.*]]
; CHECK-NEXT:    store i32 [[T4]], i32* [[P:%.*]], align 4
; CHECK-NEXT:    [[TMP1:%.*]] = or i32 [[T0]], [[T1]]
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], [[K]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ne i32 [[TMP2]], [[TMP1]]
; CHECK-NEXT:    ret i1 [[TMP3]]
;
  %t0 = shl i32 1, %c1
  %t1 = shl i32 1, %c2
  %t2 = and i32 %t0, %k
  %t3 = icmp eq i32 %t2, 0
  %t4 = and i32 %t1, %k
  store i32 %t4, i32* %p  ; extra use of and
  %t5 = icmp eq i32 %t4, 0
  %or = or i1 %t3, %t5
  ret i1 %or
}

; Should not fold
define i1 @foo1_and_extra_use_cmp2(i32 %k, i32 %c1, i32 %c2, i1* %p) {
; CHECK-LABEL: @foo1_and_extra_use_cmp2(
; CHECK-NEXT:    [[T0:%.*]] = shl i32 1, [[C1:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = shl i32 1, [[C2:%.*]]
; CHECK-NEXT:    [[T4:%.*]] = and i32 [[T1]], [[K:%.*]]
; CHECK-NEXT:    [[T5:%.*]] = icmp eq i32 [[T4]], 0
; CHECK-NEXT:    store i1 [[T5]], i1* [[P:%.*]], align 1
; CHECK-NEXT:    [[TMP1:%.*]] = or i32 [[T0]], [[T1]]
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], [[K]]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ne i32 [[TMP2]], [[TMP1]]
; CHECK-NEXT:    ret i1 [[TMP3]]
;
  %t0 = shl i32 1, %c1
  %t1 = shl i32 1, %c2
  %t2 = and i32 %t0, %k
  %t3 = icmp eq i32 %t2, 0
  %t4 = and i32 %t1, %k
  %t5 = icmp eq i32 %t4, 0
  store i1 %t5, i1* %p  ; extra use of cmp
  %or = or i1 %t3, %t5
  ret i1 %or
}

; Shift-of-signbit replaced with 'icmp s*'
; Expect to fold
define i1 @foo1_and_signbit_lshr_without_shifting_signbit_extra_use_shl1(i32 %k, i32 %c1, i32 %c2, i32* %p) {
; CHECK-LABEL: @foo1_and_signbit_lshr_without_shifting_signbit_extra_use_shl1(
; CHECK-NEXT:    [[T0:%.*]] = shl i32 1, [[C1:%.*]]
; CHECK-NEXT:    store i32 [[T0]], i32* [[P:%.*]], align 4
; CHECK-NEXT:    [[T1:%.*]] = and i32 [[T0]], [[K:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = icmp eq i32 [[T1]], 0
; CHECK-NEXT:    [[T3:%.*]] = shl i32 [[K]], [[C2:%.*]]
; CHECK-NEXT:    [[T4:%.*]] = icmp sgt i32 [[T3]], -1
; CHECK-NEXT:    [[OR:%.*]] = or i1 [[T2]], [[T4]]
; CHECK-NEXT:    ret i1 [[OR]]
;
  %t0 = shl i32 1, %c1
  store i32 %t0, i32* %p  ; extra use of shl
  %t1 = and i32 %t0, %k
  %t2 = icmp eq i32 %t1, 0
  %t3 = shl i32 %k, %c2
  %t4 = icmp sgt i32 %t3, -1
  %or = or i1 %t2, %t4
  ret i1 %or
}

; Not fold
define i1 @foo1_and_signbit_lshr_without_shifting_signbit_extra_use_and(i32 %k, i32 %c1, i32 %c2, i32* %p) {
; CHECK-LABEL: @foo1_and_signbit_lshr_without_shifting_signbit_extra_use_and(
; CHECK-NEXT:    [[T0:%.*]] = shl i32 1, [[C1:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = and i32 [[T0]], [[K:%.*]]
; CHECK-NEXT:    store i32 [[T1]], i32* [[P:%.*]], align 4
; CHECK-NEXT:    [[T2:%.*]] = icmp eq i32 [[T1]], 0
; CHECK-NEXT:    [[T3:%.*]] = shl i32 [[K]], [[C2:%.*]]
; CHECK-NEXT:    [[T4:%.*]] = icmp sgt i32 [[T3]], -1
; CHECK-NEXT:    [[OR:%.*]] = or i1 [[T2]], [[T4]]
; CHECK-NEXT:    ret i1 [[OR]]
;
  %t0 = shl i32 1, %c1
  %t1 = and i32 %t0, %k
  store i32 %t1, i32* %p  ; extra use of and
  %t2 = icmp eq i32 %t1, 0
  %t3 = shl i32 %k, %c2
  %t4 = icmp sgt i32 %t3, -1
  %or = or i1 %t2, %t4
  ret i1 %or
}

; Not fold
define i1 @foo1_and_signbit_lshr_without_shifting_signbit_extra_use_cmp1(i32 %k, i32 %c1, i32 %c2, i1* %p) {
; CHECK-LABEL: @foo1_and_signbit_lshr_without_shifting_signbit_extra_use_cmp1(
; CHECK-NEXT:    [[T0:%.*]] = shl i32 1, [[C1:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = and i32 [[T0]], [[K:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = icmp eq i32 [[T1]], 0
; CHECK-NEXT:    store i1 [[T2]], i1* [[P:%.*]], align 1
; CHECK-NEXT:    [[T3:%.*]] = shl i32 [[K]], [[C2:%.*]]
; CHECK-NEXT:    [[T4:%.*]] = icmp sgt i32 [[T3]], -1
; CHECK-NEXT:    [[OR:%.*]] = or i1 [[T2]], [[T4]]
; CHECK-NEXT:    ret i1 [[OR]]
;
  %t0 = shl i32 1, %c1
  %t1 = and i32 %t0, %k
  %t2 = icmp eq i32 %t1, 0
  store i1 %t2, i1* %p  ; extra use of cmp
  %t3 = shl i32 %k, %c2
  %t4 = icmp sgt i32 %t3, -1
  %or = or i1 %t2, %t4
  ret i1 %or
}

; Not fold
define i1 @foo1_and_signbit_lshr_without_shifting_signbit_extra_use_shl2(i32 %k, i32 %c1, i32 %c2, i32* %p) {
; CHECK-LABEL: @foo1_and_signbit_lshr_without_shifting_signbit_extra_use_shl2(
; CHECK-NEXT:    [[T0:%.*]] = shl i32 1, [[C1:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = and i32 [[T0]], [[K:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = icmp eq i32 [[T1]], 0
; CHECK-NEXT:    [[T3:%.*]] = shl i32 [[K]], [[C2:%.*]]
; CHECK-NEXT:    store i32 [[T3]], i32* [[P:%.*]], align 4
; CHECK-NEXT:    [[T4:%.*]] = icmp sgt i32 [[T3]], -1
; CHECK-NEXT:    [[OR:%.*]] = or i1 [[T2]], [[T4]]
; CHECK-NEXT:    ret i1 [[OR]]
;
  %t0 = shl i32 1, %c1
  %t1 = and i32 %t0, %k
  %t2 = icmp eq i32 %t1, 0
  %t3 = shl i32 %k, %c2
  store i32 %t3, i32* %p  ; extra use of shl
  %t4 = icmp sgt i32 %t3, -1
  %or = or i1 %t2, %t4
  ret i1 %or
}

; Not fold
define i1 @foo1_and_signbit_lshr_without_shifting_signbit_extra_use_cmp2(i32 %k, i32 %c1, i32 %c2, i1* %p) {
; CHECK-LABEL: @foo1_and_signbit_lshr_without_shifting_signbit_extra_use_cmp2(
; CHECK-NEXT:    [[T0:%.*]] = shl i32 1, [[C1:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = and i32 [[T0]], [[K:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = icmp eq i32 [[T1]], 0
; CHECK-NEXT:    [[T3:%.*]] = shl i32 [[K]], [[C2:%.*]]
; CHECK-NEXT:    [[T4:%.*]] = icmp sgt i32 [[T3]], -1
; CHECK-NEXT:    store i1 [[T4]], i1* [[P:%.*]], align 1
; CHECK-NEXT:    [[OR:%.*]] = or i1 [[T2]], [[T4]]
; CHECK-NEXT:    ret i1 [[OR]]
;
  %t0 = shl i32 1, %c1
  %t1 = and i32 %t0, %k
  %t2 = icmp eq i32 %t1, 0
  %t3 = shl i32 %k, %c2
  %t4 = icmp sgt i32 %t3, -1
  store i1 %t4, i1* %p  ; extra use of cmp
  %or = or i1 %t2, %t4
  ret i1 %or
}

; Negative tests

; This test checks that we are not creating additional shift instruction when fold fails.
define i1 @foo1_and_signbit_lshr_without_shifting_signbit_not_pwr2(i32 %k, i32 %c1, i32 %c2) {
; CHECK-LABEL: @foo1_and_signbit_lshr_without_shifting_signbit_not_pwr2(
; CHECK-NEXT:    [[T0:%.*]] = shl i32 3, [[C1:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = and i32 [[T0]], [[K:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = icmp eq i32 [[T1]], 0
; CHECK-NEXT:    [[T3:%.*]] = shl i32 [[K]], [[C2:%.*]]
; CHECK-NEXT:    [[T4:%.*]] = icmp sgt i32 [[T3]], -1
; CHECK-NEXT:    [[OR:%.*]] = or i1 [[T2]], [[T4]]
; CHECK-NEXT:    ret i1 [[OR]]
;
  %t0 = shl i32 3, %c1
  %t1 = and i32 %t0, %k
  %t2 = icmp eq i32 %t1, 0
  %t3 = shl i32 %k, %c2
  %t4 = icmp sgt i32 %t3, -1
  %or = or i1 %t2, %t4
  ret i1 %or
}
