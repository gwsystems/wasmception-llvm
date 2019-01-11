; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -basicaa -slp-vectorizer -S -mtriple=x86_64-apple-macosx10.8.0 -mcpu=corei7 | FileCheck %s

; Check if the SLPVectorizer does not crash when handling
; unreachable blocks with unscheduleable instructions.

target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.9.0"

define void @foo(i32* nocapture %x) #0 {
; CHECK-LABEL: @foo(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[BB2:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    [[T3:%.*]] = getelementptr inbounds i32, i32* [[X:%.*]], i64 4
; CHECK-NEXT:    [[T4:%.*]] = load i32, i32* [[T3]], align 4
; CHECK-NEXT:    [[T5:%.*]] = getelementptr inbounds i32, i32* [[X]], i64 5
; CHECK-NEXT:    [[T6:%.*]] = load i32, i32* [[T5]], align 4
; CHECK-NEXT:    [[BAD:%.*]] = fadd float [[BAD]], 0.000000e+00
; CHECK-NEXT:    [[T7:%.*]] = getelementptr inbounds i32, i32* [[X]], i64 6
; CHECK-NEXT:    [[T8:%.*]] = load i32, i32* [[T7]], align 4
; CHECK-NEXT:    [[T9:%.*]] = getelementptr inbounds i32, i32* [[X]], i64 7
; CHECK-NEXT:    [[T10:%.*]] = load i32, i32* [[T9]], align 4
; CHECK-NEXT:    br label [[BB2]]
; CHECK:       bb2:
; CHECK-NEXT:    [[T1_0:%.*]] = phi i32 [ [[T4]], [[BB1:%.*]] ], [ 2, [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[T2_0:%.*]] = phi i32 [ [[T6]], [[BB1]] ], [ 2, [[ENTRY]] ]
; CHECK-NEXT:    [[T3_0:%.*]] = phi i32 [ [[T8]], [[BB1]] ], [ 2, [[ENTRY]] ]
; CHECK-NEXT:    [[T4_0:%.*]] = phi i32 [ [[T10]], [[BB1]] ], [ 2, [[ENTRY]] ]
; CHECK-NEXT:    store i32 [[T1_0]], i32* [[X]], align 4
; CHECK-NEXT:    [[T12:%.*]] = getelementptr inbounds i32, i32* [[X]], i64 1
; CHECK-NEXT:    store i32 [[T2_0]], i32* [[T12]], align 4
; CHECK-NEXT:    [[T13:%.*]] = getelementptr inbounds i32, i32* [[X]], i64 2
; CHECK-NEXT:    store i32 [[T3_0]], i32* [[T13]], align 4
; CHECK-NEXT:    [[T14:%.*]] = getelementptr inbounds i32, i32* [[X]], i64 3
; CHECK-NEXT:    store i32 [[T4_0]], i32* [[T14]], align 4
; CHECK-NEXT:    ret void
;
entry:
  br label %bb2

bb1:                                    ; an unreachable block
  %t3 = getelementptr inbounds i32, i32* %x, i64 4
  %t4 = load i32, i32* %t3, align 4
  %t5 = getelementptr inbounds i32, i32* %x, i64 5
  %t6 = load i32, i32* %t5, align 4
  %bad = fadd float %bad, 0.000000e+00  ; <- an instruction with self dependency,
  ;    but legal in unreachable code
  %t7 = getelementptr inbounds i32, i32* %x, i64 6
  %t8 = load i32, i32* %t7, align 4
  %t9 = getelementptr inbounds i32, i32* %x, i64 7
  %t10 = load i32, i32* %t9, align 4
  br label %bb2

bb2:
  %t1.0 = phi i32 [ %t4, %bb1 ], [ 2, %entry ]
  %t2.0 = phi i32 [ %t6, %bb1 ], [ 2, %entry ]
  %t3.0 = phi i32 [ %t8, %bb1 ], [ 2, %entry ]
  %t4.0 = phi i32 [ %t10, %bb1 ], [ 2, %entry ]
  store i32 %t1.0, i32* %x, align 4
  %t12 = getelementptr inbounds i32, i32* %x, i64 1
  store i32 %t2.0, i32* %t12, align 4
  %t13 = getelementptr inbounds i32, i32* %x, i64 2
  store i32 %t3.0, i32* %t13, align 4
  %t14 = getelementptr inbounds i32, i32* %x, i64 3
  store i32 %t4.0, i32* %t14, align 4
  ret void
}

