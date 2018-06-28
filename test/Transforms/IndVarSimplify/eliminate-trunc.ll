; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -indvars -S < %s | FileCheck %s

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; General case: without extra knowledge, trunc cannot be eliminated.
define void @test_00(i64 %start, i32 %n) {
;
; CHECK-LABEL: @test_00(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[START:%.*]], [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[IV_NEXT]] = add i64 [[IV]], 1
; CHECK-NEXT:    [[NARROW_IV:%.*]] = trunc i64 [[IV]] to i32
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i32 [[NARROW_IV]], [[N:%.*]]
; CHECK-NEXT:    br i1 [[CMP]], label [[LOOP]], label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop
loop:
  %iv = phi i64 [ %start, %entry ], [ %iv.next, %loop ]
  %iv.next = add i64 %iv, 1
  %narrow.iv = trunc i64 %iv to i32
  %cmp = icmp slt i32 %narrow.iv, %n
  br i1 %cmp, label %loop, label %exit
exit:
  ret void
}


define void @test_01(i32 %n) {
;
; CHECK-LABEL: @test_01(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[SEXT:%.*]] = sext i32 [[N:%.*]] to i64
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ 0, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 1
; CHECK-NEXT:    [[TMP0:%.*]] = icmp slt i64 [[IV]], [[SEXT]]
; CHECK-NEXT:    br i1 [[TMP0]], label [[LOOP]], label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop
loop:
  %iv = phi i64 [ 0, %entry ], [ %iv.next, %loop ]
  %iv.next = add i64 %iv, 1
  %narrow.iv = trunc i64 %iv to i32
  %cmp = icmp slt i32 %narrow.iv, %n
  br i1 %cmp, label %loop, label %exit
exit:
  ret void
}

; Max value at which we can eliminate trunc: SINT_MAX - 1.
define void @test_02(i32 %n) {
;
; CHECK-LABEL: @test_02(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[SEXT:%.*]] = sext i32 [[N:%.*]] to i64
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ 2147483646, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 1
; CHECK-NEXT:    [[TMP0:%.*]] = icmp slt i64 [[IV]], [[SEXT]]
; CHECK-NEXT:    br i1 [[TMP0]], label [[LOOP]], label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop
loop:
  %iv = phi i64 [ 2147483646, %entry ], [ %iv.next, %loop ]
  %iv.next = add i64 %iv, 1
  %narrow.iv = trunc i64 %iv to i32
  %cmp = icmp slt i32 %narrow.iv, %n
  br i1 %cmp, label %loop, label %exit
exit:
  ret void
}

; If we start from SINT_MAX then the predicate is always false.
define void @test_03(i32 %n) {
;
; CHECK-LABEL: @test_03(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    br i1 false, label [[LOOP]], label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop
loop:
  %iv = phi i64 [2147483647, %entry], [%iv.next, %loop]
  %iv.next = add i64 %iv, 1
  %narrow.iv = trunc i64 %iv to i32
  %cmp = icmp slt i32 %narrow.iv, %n
  br i1 %cmp, label %loop, label %exit
exit:
  ret void
}

; Minimum value at which we can apply the transform: SINT_MIN + 1.
define void @test_04(i32 %n) {
;
; CHECK-LABEL: @test_04(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[SEXT:%.*]] = sext i32 [[N:%.*]] to i64
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ -2147483647, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[IV_NEXT]] = add nsw i64 [[IV]], 1
; CHECK-NEXT:    [[TMP0:%.*]] = icmp slt i64 [[IV]], [[SEXT]]
; CHECK-NEXT:    br i1 [[TMP0]], label [[LOOP]], label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop
loop:
  %iv = phi i64 [ -2147483647, %entry ], [ %iv.next, %loop ]
  %iv.next = add i64 %iv, 1
  %narrow.iv = trunc i64 %iv to i32
  %cmp = icmp slt i32 %narrow.iv, %n
  br i1 %cmp, label %loop, label %exit
exit:
  ret void
}

; FIXME: Harmful LFTR should be thrown away.
define void @test_05(i32 %n) {
;
; CHECK-LABEL: @test_05(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = add i32 [[N:%.*]], 1
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ -2147483648, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[IV_NEXT]] = add nsw i64 [[IV]], 1
; CHECK-NEXT:    [[LFTR_WIDEIV:%.*]] = trunc i64 [[IV_NEXT]] to i32
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp ne i32 [[LFTR_WIDEIV]], [[TMP0]]
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[LOOP]], label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop
loop:
  %iv = phi i64 [ -2147483648, %entry ], [ %iv.next, %loop ]
  %iv.next = add i64 %iv, 1
  %narrow.iv = trunc i64 %iv to i32
  %cmp = icmp slt i32 %narrow.iv, %n
  br i1 %cmp, label %loop, label %exit
exit:
  ret void
}

; Trunc changes the actual value of the IV, so it is invalid to remove it: SINT_MIN - 1.
define void @test_06(i32 %n) {
;
; CHECK-LABEL: @test_06(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ -2147483649, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 1
; CHECK-NEXT:    [[NARROW_IV:%.*]] = trunc i64 [[IV]] to i32
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i32 [[NARROW_IV]], [[N:%.*]]
; CHECK-NEXT:    br i1 [[CMP]], label [[LOOP]], label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop
loop:
  %iv = phi i64 [ -2147483649, %entry ], [ %iv.next, %loop ]
  %iv.next = add i64 %iv, 1
  %narrow.iv = trunc i64 %iv to i32
  %cmp = icmp slt i32 %narrow.iv, %n
  br i1 %cmp, label %loop, label %exit
exit:
  ret void
}

; General case: without extra knowledge, trunc cannot be eliminated.
define void @test_00_unsigned(i64 %start, i32 %n) {
; CHECK-LABEL: @test_00_unsigned(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[START:%.*]], [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[IV_NEXT]] = add i64 [[IV]], 1
; CHECK-NEXT:    [[NARROW_IV:%.*]] = trunc i64 [[IV]] to i32
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult i32 [[NARROW_IV]], [[N:%.*]]
; CHECK-NEXT:    br i1 [[CMP]], label [[LOOP]], label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop
loop:
  %iv = phi i64 [ %start, %entry ], [ %iv.next, %loop ]
  %iv.next = add i64 %iv, 1
  %narrow.iv = trunc i64 %iv to i32
  %cmp = icmp ult i32 %narrow.iv, %n
  br i1 %cmp, label %loop, label %exit
exit:
  ret void
}

; FIXME: Harmful LFTR should be thrown away.
define void @test_01_unsigned(i32 %n) {
; CHECK-LABEL: @test_01_unsigned(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = add i32 [[N:%.*]], 1
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ 0, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 1
; CHECK-NEXT:    [[LFTR_WIDEIV:%.*]] = trunc i64 [[IV_NEXT]] to i32
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp ne i32 [[LFTR_WIDEIV]], [[TMP0]]
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[LOOP]], label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop
loop:
  %iv = phi i64 [ 0, %entry ], [ %iv.next, %loop ]
  %iv.next = add i64 %iv, 1
  %narrow.iv = trunc i64 %iv to i32
  %cmp = icmp ult i32 %narrow.iv, %n
  br i1 %cmp, label %loop, label %exit
exit:
  ret void
}

; Max value at which we can eliminate trunc: UINT_MAX - 1.
define void @test_02_unsigned(i32 %n) {
; CHECK-LABEL: @test_02_unsigned(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[ZEXT:%.*]] = zext i32 [[N:%.*]] to i64
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ 4294967294, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 1
; CHECK-NEXT:    [[TMP0:%.*]] = icmp ult i64 [[IV]], [[ZEXT]]
; CHECK-NEXT:    br i1 [[TMP0]], label [[LOOP]], label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop
loop:
  %iv = phi i64 [ 4294967294, %entry ], [ %iv.next, %loop ]
  %iv.next = add i64 %iv, 1
  %narrow.iv = trunc i64 %iv to i32
  %cmp = icmp ult i32 %narrow.iv, %n
  br i1 %cmp, label %loop, label %exit
exit:
  ret void
}

; If we start from UINT_MAX then the predicate is always false.
define void @test_03_unsigned(i32 %n) {
; CHECK-LABEL: @test_03_unsigned(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    br i1 false, label [[LOOP]], label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop
loop:
  %iv = phi i64 [ 4294967295, %entry ], [ %iv.next, %loop ]
  %iv.next = add i64 %iv, 1
  %narrow.iv = trunc i64 %iv to i32
  %cmp = icmp ult i32 %narrow.iv, %n
  br i1 %cmp, label %loop, label %exit
exit:
  ret void
}

; Minimum value at which we can apply the transform: UINT_MIN.
define void @test_04_unsigned(i32 %n) {
; CHECK-LABEL: @test_04_unsigned(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = add i32 [[N:%.*]], 1
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ 0, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 1
; CHECK-NEXT:    [[LFTR_WIDEIV:%.*]] = trunc i64 [[IV_NEXT]] to i32
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp ne i32 [[LFTR_WIDEIV]], [[TMP0]]
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[LOOP]], label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop
loop:
  %iv = phi i64 [ 0, %entry ], [ %iv.next, %loop ]
  %iv.next = add i64 %iv, 1
  %narrow.iv = trunc i64 %iv to i32
  %cmp = icmp ult i32 %narrow.iv, %n
  br i1 %cmp, label %loop, label %exit
exit:
  ret void
}

; Start from 1.
define void @test_05_unsigned(i32 %n) {
; CHECK-LABEL: @test_05_unsigned(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[ZEXT:%.*]] = zext i32 [[N:%.*]] to i64
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ 1, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 1
; CHECK-NEXT:    [[TMP0:%.*]] = icmp ult i64 [[IV]], [[ZEXT]]
; CHECK-NEXT:    br i1 [[TMP0]], label [[LOOP]], label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop
loop:
  %iv = phi i64 [ 1, %entry ], [ %iv.next, %loop ]
  %iv.next = add i64 %iv, 1
  %narrow.iv = trunc i64 %iv to i32
  %cmp = icmp ult i32 %narrow.iv, %n
  br i1 %cmp, label %loop, label %exit
exit:
  ret void
}

; Trunc changes the actual value of the IV, so it is invalid to remove it: UINT_MIN - 1.
define void @test_06_unsigned(i32 %n) {
; CHECK-LABEL: @test_06_unsigned(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ -1, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[IV_NEXT]] = add nsw i64 [[IV]], 1
; CHECK-NEXT:    [[NARROW_IV:%.*]] = trunc i64 [[IV]] to i32
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult i32 [[NARROW_IV]], [[N:%.*]]
; CHECK-NEXT:    br i1 [[CMP]], label [[LOOP]], label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop
loop:
  %iv = phi i64 [ -1, %entry ], [ %iv.next, %loop ]
  %iv.next = add i64 %iv, 1
  %narrow.iv = trunc i64 %iv to i32
  %cmp = icmp ult i32 %narrow.iv, %n
  br i1 %cmp, label %loop, label %exit
exit:
  ret void
}

; Do not eliminate trunc if it is used by something different from icmp.
define void @test_07(i32* %p, i32 %n) {
; CHECK-LABEL: @test_07(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ 0, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 1
; CHECK-NEXT:    [[NARROW_IV:%.*]] = trunc i64 [[IV]] to i32
; CHECK-NEXT:    store i32 [[NARROW_IV]], i32* [[P:%.*]]
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i32 [[NARROW_IV]], [[N:%.*]]
; CHECK-NEXT:    br i1 [[CMP]], label [[LOOP]], label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop
loop:
  %iv = phi i64 [ 0, %entry ], [ %iv.next, %loop ]
  %iv.next = add i64 %iv, 1
  %narrow.iv = trunc i64 %iv to i32
  store i32 %narrow.iv, i32* %p
  %cmp = icmp slt i32 %narrow.iv, %n
  br i1 %cmp, label %loop, label %exit
exit:
  ret void
}

; Check that we can eliminate both signed and unsigned compare.
define void @test_08(i32 %n) {
; CHECK-LABEL: @test_08(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[ZEXT:%.*]] = zext i32 [[N:%.*]] to i64
; CHECK-NEXT:    [[SEXT:%.*]] = sext i32 [[N]] to i64
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ 1, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 1
; CHECK-NEXT:    [[TMP0:%.*]] = icmp slt i64 [[IV]], [[SEXT]]
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ult i64 [[IV]], [[ZEXT]]
; CHECK-NEXT:    [[CMP:%.*]] = and i1 [[TMP0]], [[TMP1]]
; CHECK-NEXT:    br i1 [[CMP]], label [[LOOP]], label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop
loop:
  %iv = phi i64 [ 1, %entry ], [ %iv.next, %loop ]
  %iv.next = add i64 %iv, 1
  %narrow.iv = trunc i64 %iv to i32
  %cmp1 = icmp slt i32 %narrow.iv, %n
  %cmp2 = icmp ult i32 %narrow.iv, %n
  %cmp = and i1 %cmp1, %cmp2
  br i1 %cmp, label %loop, label %exit
exit:
  ret void
}

; Widen NE as unsigned.
define void @test_09(i32 %n) {
; CHECK-LABEL: @test_09(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[ZEXT:%.*]] = zext i32 [[N:%.*]] to i64
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ 0, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 1
; CHECK-NEXT:    [[TMP0:%.*]] = icmp ne i64 [[IV]], [[ZEXT]]
; CHECK-NEXT:    br i1 [[TMP0]], label [[LOOP]], label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop
loop:
  %iv = phi i64 [ 0, %entry ], [ %iv.next, %loop ]
  %iv.next = add i64 %iv, 1
  %narrow.iv = trunc i64 %iv to i32
  %cmp = icmp ne i32 %narrow.iv, %n
  br i1 %cmp, label %loop, label %exit
exit:
  ret void
}

; Widen NE as signed.
define void @test_10(i32 %n) {
; CHECK-LABEL: @test_10(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[SEXT:%.*]] = sext i32 [[N:%.*]] to i64
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ -100, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 1
; CHECK-NEXT:    [[TMP0:%.*]] = icmp ne i64 [[IV]], [[SEXT]]
; CHECK-NEXT:    [[NEGCMP:%.*]] = icmp slt i64 [[IV]], -10
; CHECK-NEXT:    [[CMP:%.*]] = and i1 [[TMP0]], [[NEGCMP]]
; CHECK-NEXT:    br i1 [[CMP]], label [[LOOP]], label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop
loop:
  %iv = phi i64 [ -100, %entry ], [ %iv.next, %loop ]
  %iv.next = add i64 %iv, 1
  %narrow.iv = trunc i64 %iv to i32
  %trunccmp = icmp ne i32 %narrow.iv, %n
  %negcmp = icmp slt i64 %iv, -10
  %cmp = and i1 %trunccmp, %negcmp
  br i1 %cmp, label %loop, label %exit
exit:
  ret void
}

define void @test_11() {
; CHECK-LABEL: @test_11(
; CHECK-NEXT:    br label [[BB1:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    br i1 undef, label [[BB2:%.*]], label [[BB6:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    br i1 undef, label [[BB3:%.*]], label [[BB4:%.*]]
; CHECK:       bb3:
; CHECK-NEXT:    br label [[BB4]]
; CHECK:       bb4:
; CHECK-NEXT:    br label [[BB6]]
; CHECK:       bb5:
; CHECK-NEXT:    [[_TMP24:%.*]] = icmp slt i16 undef, 0
; CHECK-NEXT:    br i1 [[_TMP24]], label [[BB5:%.*]], label [[BB5]]
; CHECK:       bb6:
; CHECK-NEXT:    br i1 false, label [[BB1]], label [[BB7:%.*]]
; CHECK:       bb7:
; CHECK-NEXT:    ret void
;
  br label %bb1

bb1:                                              ; preds = %bb6, %0
  %e.5.0 = phi i32 [ 0, %0 ], [ %_tmp32, %bb6 ]
  br i1 undef, label %bb2, label %bb6

bb2:                                              ; preds = %bb1
  %_tmp15 = trunc i32 %e.5.0 to i16
  br i1 undef, label %bb3, label %bb4

bb3:                                              ; preds = %bb2
  br label %bb4

bb4:                                              ; preds = %bb3, %bb2
  br label %bb6

bb5:                                              ; preds = %bb5, %bb5
  %_tmp24 = icmp slt i16 %_tmp15, 0
  br i1 %_tmp24, label %bb5, label %bb5

bb6:                                              ; preds = %bb4, %bb1
  %_tmp32 = add nuw nsw i32 %e.5.0, 1
  br i1 false, label %bb1, label %bb7

bb7:                                             ; preds = %bb6
  ret void
}
