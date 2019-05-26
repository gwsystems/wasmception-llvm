; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt %s -S -passes='simplify-cfg<switch-to-lookup>' | FileCheck %s
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
declare void @foo(i32)

define void @test(i1 %a) {
; CHECK-LABEL: @test(
; CHECK-NEXT:    [[A_OFF:%.*]] = add i1 [[A:%.*]], true
; CHECK-NEXT:    [[SWITCH:%.*]] = icmp ult i1 [[A_OFF]], true
; CHECK-NEXT:    br i1 [[SWITCH]], label [[TRUE:%.*]], label [[FALSE:%.*]]
; CHECK:       true:
; CHECK-NEXT:    call void @foo(i32 1)
; CHECK-NEXT:    ret void
; CHECK:       false:
; CHECK-NEXT:    call void @foo(i32 3)
; CHECK-NEXT:    ret void
;
  switch i1 %a, label %default [i1 1, label %true
  i1 0, label %false]
true:
  call void @foo(i32 1)
  ret void
false:
  call void @foo(i32 3)
  ret void
default:
  call void @foo(i32 2)
  ret void
}

define void @test2(i2 %a) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    switch i2 [[A:%.*]], label [[DEFAULT1:%.*]] [
; CHECK-NEXT:    i2 0, label [[CASE0:%.*]]
; CHECK-NEXT:    i2 1, label [[CASE1:%.*]]
; CHECK-NEXT:    i2 -2, label [[CASE2:%.*]]
; CHECK-NEXT:    i2 -1, label [[CASE3:%.*]]
; CHECK-NEXT:    ]
; CHECK:       case0:
; CHECK-NEXT:    call void @foo(i32 0)
; CHECK-NEXT:    ret void
; CHECK:       case1:
; CHECK-NEXT:    call void @foo(i32 1)
; CHECK-NEXT:    ret void
; CHECK:       case2:
; CHECK-NEXT:    call void @foo(i32 2)
; CHECK-NEXT:    ret void
; CHECK:       case3:
; CHECK-NEXT:    call void @foo(i32 3)
; CHECK-NEXT:    ret void
; CHECK:       default1:
; CHECK-NEXT:    unreachable
;
  switch i2 %a, label %default [i2 0, label %case0
  i2 1, label %case1
  i2 2, label %case2
  i2 3, label %case3]
case0:
  call void @foo(i32 0)
  ret void
case1:
  call void @foo(i32 1)
  ret void
case2:
  call void @foo(i32 2)
  ret void
case3:
  call void @foo(i32 3)
  ret void
default:
  call void @foo(i32 4)
  ret void
}

; This one is a negative test - we know the value of the default,
; but that's about it
define void @test3(i2 %a) {
; CHECK-LABEL: @test3(
; CHECK-NEXT:    switch i2 [[A:%.*]], label [[DEFAULT:%.*]] [
; CHECK-NEXT:    i2 0, label [[CASE0:%.*]]
; CHECK-NEXT:    i2 1, label [[CASE1:%.*]]
; CHECK-NEXT:    i2 -2, label [[CASE2:%.*]]
; CHECK-NEXT:    ]
; CHECK:       case0:
; CHECK-NEXT:    call void @foo(i32 0)
; CHECK-NEXT:    ret void
; CHECK:       case1:
; CHECK-NEXT:    call void @foo(i32 1)
; CHECK-NEXT:    ret void
; CHECK:       case2:
; CHECK-NEXT:    call void @foo(i32 2)
; CHECK-NEXT:    ret void
; CHECK:       default:
; CHECK-NEXT:    call void @foo(i32 0)
; CHECK-NEXT:    ret void
;
  switch i2 %a, label %default [i2 0, label %case0
  i2 1, label %case1
  i2 2, label %case2]

case0:
  call void @foo(i32 0)
  ret void
case1:
  call void @foo(i32 1)
  ret void
case2:
  call void @foo(i32 2)
  ret void
default:
  call void @foo(i32 0)
  ret void
}

; Negative test - check for possible overflow when computing
; number of possible cases.
define void @test4(i128 %a) {
; CHECK-LABEL: @test4(
; CHECK-NEXT:    switch i128 [[A:%.*]], label [[DEFAULT:%.*]] [
; CHECK-NEXT:    i128 0, label [[CASE0:%.*]]
; CHECK-NEXT:    i128 1, label [[CASE1:%.*]]
; CHECK-NEXT:    ]
; CHECK:       case0:
; CHECK-NEXT:    call void @foo(i32 0)
; CHECK-NEXT:    ret void
; CHECK:       case1:
; CHECK-NEXT:    call void @foo(i32 1)
; CHECK-NEXT:    ret void
; CHECK:       default:
; CHECK-NEXT:    call void @foo(i32 0)
; CHECK-NEXT:    ret void
;
  switch i128 %a, label %default [i128 0, label %case0
  i128 1, label %case1]

case0:
  call void @foo(i32 0)
  ret void
case1:
  call void @foo(i32 1)
  ret void
default:
  call void @foo(i32 0)
  ret void
}

; All but one bit known zero
define void @test5(i8 %a) {
; CHECK-LABEL: @test5(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult i8 [[A:%.*]], 2
; CHECK-NEXT:    call void @llvm.assume(i1 [[CMP]])
; CHECK-NEXT:    [[A_OFF:%.*]] = add i8 [[A]], -1
; CHECK-NEXT:    [[SWITCH:%.*]] = icmp ult i8 [[A_OFF]], 1
; CHECK-NEXT:    br i1 [[SWITCH]], label [[TRUE:%.*]], label [[FALSE:%.*]]
; CHECK:       true:
; CHECK-NEXT:    call void @foo(i32 1)
; CHECK-NEXT:    ret void
; CHECK:       false:
; CHECK-NEXT:    call void @foo(i32 3)
; CHECK-NEXT:    ret void
;
  %cmp = icmp ult i8 %a, 2
  call void @llvm.assume(i1 %cmp)
  switch i8 %a, label %default [i8 1, label %true
  i8 0, label %false]
true:
  call void @foo(i32 1)
  ret void
false:
  call void @foo(i32 3)
  ret void
default:
  call void @foo(i32 2)
  ret void
}

;; All but one bit known one
define void @test6(i8 %a) {
; CHECK-LABEL: @test6(
; CHECK-NEXT:    [[AND:%.*]] = and i8 [[A:%.*]], -2
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i8 [[AND]], -2
; CHECK-NEXT:    call void @llvm.assume(i1 [[CMP]])
; CHECK-NEXT:    [[A_OFF:%.*]] = add i8 [[A]], 1
; CHECK-NEXT:    [[SWITCH:%.*]] = icmp ult i8 [[A_OFF]], 1
; CHECK-NEXT:    br i1 [[SWITCH]], label [[TRUE:%.*]], label [[FALSE:%.*]]
; CHECK:       true:
; CHECK-NEXT:    call void @foo(i32 1)
; CHECK-NEXT:    ret void
; CHECK:       false:
; CHECK-NEXT:    call void @foo(i32 3)
; CHECK-NEXT:    ret void
;
  %and = and i8 %a, 254
  %cmp = icmp eq i8 %and, 254
  call void @llvm.assume(i1 %cmp)
  switch i8 %a, label %default [i8 255, label %true
  i8 254, label %false]
true:
  call void @foo(i32 1)
  ret void
false:
  call void @foo(i32 3)
  ret void
default:
  call void @foo(i32 2)
  ret void
}

; Check that we can eliminate both dead cases and dead defaults
; within a single run of simplify-cfg
define void @test7(i8 %a) {
; CHECK-LABEL: @test7(
; CHECK-NEXT:    [[AND:%.*]] = and i8 [[A:%.*]], -2
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i8 [[AND]], -2
; CHECK-NEXT:    call void @llvm.assume(i1 [[CMP]])
; CHECK-NEXT:    [[A_OFF:%.*]] = add i8 [[A]], 1
; CHECK-NEXT:    [[SWITCH:%.*]] = icmp ult i8 [[A_OFF]], 1
; CHECK-NEXT:    br i1 [[SWITCH]], label [[TRUE:%.*]], label [[FALSE:%.*]]
; CHECK:       true:
; CHECK-NEXT:    call void @foo(i32 1)
; CHECK-NEXT:    ret void
; CHECK:       false:
; CHECK-NEXT:    call void @foo(i32 3)
; CHECK-NEXT:    ret void
;
  %and = and i8 %a, 254
  %cmp = icmp eq i8 %and, 254
  call void @llvm.assume(i1 %cmp)
  switch i8 %a, label %default [i8 255, label %true
  i8 254, label %false
  i8 0, label %also_dead]
true:
  call void @foo(i32 1)
  ret void
false:
  call void @foo(i32 3)
  ret void
also_dead:
  call void @foo(i32 5)
  ret void
default:
  call void @foo(i32 2)
  ret void
}

;; All but one bit known undef
;; Note: This is currently testing an optimization which doesn't trigger. The
;; case this is protecting against is that a bit could be assumed both zero
;; *or* one given we know it's undef.  ValueTracking doesn't do this today,
;; but it doesn't hurt to confirm.
define void @test8(i8 %a) {
; CHECK-LABEL: @test8(
; CHECK-NEXT:    [[AND:%.*]] = and i8 [[A:%.*]], -2
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i8 [[AND]], undef
; CHECK-NEXT:    call void @llvm.assume(i1 [[CMP]])
; CHECK-NEXT:    switch i8 [[A]], label [[DEFAULT:%.*]] [
; CHECK-NEXT:    i8 -1, label [[TRUE:%.*]]
; CHECK-NEXT:    i8 -2, label [[FALSE:%.*]]
; CHECK-NEXT:    ]
; CHECK:       true:
; CHECK-NEXT:    call void @foo(i32 1)
; CHECK-NEXT:    ret void
; CHECK:       false:
; CHECK-NEXT:    call void @foo(i32 3)
; CHECK-NEXT:    ret void
; CHECK:       default:
; CHECK-NEXT:    call void @foo(i32 2)
; CHECK-NEXT:    ret void
;
  %and = and i8 %a, 254
  %cmp = icmp eq i8 %and, undef
  call void @llvm.assume(i1 %cmp)
  switch i8 %a, label %default [i8 255, label %true
  i8 254, label %false]
true:
  call void @foo(i32 1)
  ret void
false:
  call void @foo(i32 3)
  ret void
default:
  call void @foo(i32 2)
  ret void
}

declare void @llvm.assume(i1)
