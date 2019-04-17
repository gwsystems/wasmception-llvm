; NOTE: Assertions have been autogenerated by update_test_checks.py
; RUN: opt < %s -simplifycfg -S | FileCheck %s

@b = extern_weak global i32

define i32 @foo(i1 %y) {
; CHECK-LABEL: @foo(
; CHECK:         [[COND_I:%.*]] = phi i32 [ srem (i32 1, i32 zext (i1 icmp eq (i32* @b, i32* null) to i32)), %bb2 ], [ 0, %0 ]
; CHECK-NEXT:    ret i32 [[COND_I]]
;
  br i1 %y, label %bb1, label %bb2
bb1:
  br label %bb3
bb2:
  br label %bb3
bb3:
  %cond.i = phi i32 [ 0, %bb1 ], [ srem (i32 1, i32 zext (i1 icmp eq (i32* @b, i32* null) to i32)), %bb2 ]
  ret i32 %cond.i
}

define i32 @foo2(i1 %x) {
; CHECK-LABEL: @foo2(
; CHECK:         [[COND:%.*]] = phi i32 [ 0, %bb1 ], [ srem (i32 1, i32 zext (i1 icmp eq (i32* @b, i32* null) to i32)), %bb0 ]
; CHECK-NEXT:    ret i32 [[COND]]
;
bb0:
  br i1 %x, label %bb1, label %bb2
bb1:
  br label %bb2
bb2:
  %cond = phi i32 [ 0, %bb1 ], [ srem (i32 1, i32 zext (i1 icmp eq (i32* @b, i32* null) to i32)), %bb0 ]
  ret i32 %cond
}
