; RUN: opt -S -codegenprepare < %s | FileCheck %s
target datalayout = "E-m:e-i64:64-n32:64"
target triple = "powerpc64-unknown-linux-gnu"

define i64 @test1(i64 %A) {
; CHECK-LABEL: @test1(
; CHECK: [[CTLZ:%[A-Za-z0-9]+]] = call i64 @llvm.ctlz.i64(i64 %A, i1 false)
; CHECK-NEXT: ret i64 [[CTLZ]]
entry:
  %tobool = icmp eq i64 %A, 0
  br i1 %tobool, label %cond.end, label %cond.true

cond.true:                                        ; preds = %entry
  %0 = tail call i64 @llvm.ctlz.i64(i64 %A, i1 true)
  br label %cond.end

cond.end:                                         ; preds = %entry, %cond.true
  %cond = phi i64 [ %0, %cond.true ], [ 64, %entry ]
  ret i64 %cond
}

define i64 @test1b(i64 %A) {
; CHECK-LABEL: @test1b(
; CHECK: [[CTTZ:%[A-Za-z0-9]+]] = call i64 @llvm.cttz.i64(i64 %A, i1 false)
; CHECK-NEXT: ret i64 [[CTTZ]]
entry:
  %tobool = icmp eq i64 %A, 0
  br i1 %tobool, label %cond.end, label %cond.true

cond.true:                                        ; preds = %entry
  %0 = tail call i64 @llvm.cttz.i64(i64 %A, i1 true)
  br label %cond.end

cond.end:                                         ; preds = %entry, %cond.true
  %cond = phi i64 [ %0, %cond.true ], [ 64, %entry ]
  ret i64 %cond
}

declare i64 @llvm.ctlz.i64(i64, i1)
declare i64 @llvm.cttz.i64(i64, i1)

