; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

; PR1949

define i1 @test1(i32 %a) {
; CHECK-LABEL: @test1(
; CHECK-NEXT:    [[C:%.*]] = icmp ugt i32 %a, -5
; CHECK-NEXT:    ret i1 [[C]]
;
  %b = add i32 %a, 4
  %c = icmp ult i32 %b, 4
  ret i1 %c
}

define i1 @test2(i32 %a) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    [[C:%.*]] = icmp ult i32 %a, 4
; CHECK-NEXT:    ret i1 [[C]]
;
  %b = sub i32 %a, 4
  %c = icmp ugt i32 %b, -5
  ret i1 %c
}

define i1 @test3(i32 %a) {
; CHECK-LABEL: @test3(
; CHECK-NEXT:    [[C:%.*]] = icmp sgt i32 %a, 2147483643
; CHECK-NEXT:    ret i1 [[C]]
;
  %b = add i32 %a, 4
  %c = icmp slt i32 %b, 2147483652
  ret i1 %c
}

