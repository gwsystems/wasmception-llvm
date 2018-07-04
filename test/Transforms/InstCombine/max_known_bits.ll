; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -instcombine < %s | FileCheck %s

; TODO: The entire thing should be folded to and i16 %0, 255.

define i16 @foo(i16 %x)  {
; CHECK-LABEL: @foo(
; CHECK-NEXT:    [[T1:%.*]] = and i16 [[X:%.*]], 255
; CHECK-NEXT:    [[T3:%.*]] = icmp ult i16 [[T1]], 255
; CHECK-NEXT:    [[T4:%.*]] = select i1 [[T3]], i16 [[T1]], i16 255
; CHECK-NEXT:    ret i16 [[T4]]
;
  %t1 = and i16 %x, 255
  %t2 = zext i16 %t1 to i32
  %t3 = icmp ult i32 %t2, 255
  %t4 = select i1 %t3, i32 %t2, i32 255
  %t5 = trunc i32 %t4 to i16
  %t6 = and i16 %t5, 255
  ret i16 %t6
}

