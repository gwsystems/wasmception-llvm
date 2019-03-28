; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -lsr-complexity-limit=50 -loop-reduce -S %s | FileCheck %s

target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"

define void @overflow1(i64 %a) {
; CHECK-LABEL: @overflow1(
; CHECK-NEXT:  bb:
; CHECK-NEXT:    [[TMP0:%.*]] = add i64 [[A:%.*]], -1
; CHECK-NEXT:    [[TMP1:%.*]] = add i64 [[A]], -9223372036854775808
; CHECK-NEXT:    br label [[BB1:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    [[LSR_IV1:%.*]] = phi i64 [ [[LSR_IV_NEXT2:%.*]], [[BB1]] ], [ [[TMP1]], [[BB:%.*]] ]
; CHECK-NEXT:    [[LSR_IV:%.*]] = phi i64 [ [[LSR_IV_NEXT:%.*]], [[BB1]] ], [ [[TMP0]], [[BB]] ]
; CHECK-NEXT:    [[TMP4:%.*]] = icmp ne i64 [[LSR_IV1]], 0
; CHECK-NEXT:    [[TMP5:%.*]] = and i1 [[TMP4]], true
; CHECK-NEXT:    [[LSR_IV_NEXT]] = add i64 [[LSR_IV]], 1
; CHECK-NEXT:    [[LSR_IV_NEXT2]] = add i64 [[LSR_IV1]], 1
; CHECK-NEXT:    br i1 [[TMP5]], label [[BB1]], label [[BB7:%.*]]
; CHECK:       bb7:
; CHECK-NEXT:    [[TMP9:%.*]] = and i64 [[LSR_IV_NEXT]], 1
; CHECK-NEXT:    [[TMP10:%.*]] = icmp eq i64 [[TMP9]], 0
; CHECK-NEXT:    unreachable
;
bb:
  br label %bb1

bb1:                                              ; preds = %bb1, %bb
  %tmp = phi i64 [ %a, %bb ], [ %tmp6, %bb1 ]
  %tmp4 = icmp ne i64 %tmp, -9223372036854775808
  %tmp5 = and i1 %tmp4, 1
  %tmp6 = add i64 %tmp, 1
  br i1 %tmp5, label %bb1, label %bb7

bb7:                                              ; preds = %bb1
  %tmp9 = and i64 %tmp, 1
  %tmp10 = icmp eq i64 %tmp9, 0
  unreachable
}
