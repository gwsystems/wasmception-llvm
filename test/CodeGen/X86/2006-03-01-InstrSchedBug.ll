; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-unknown | FileCheck %s

define i32 @f(i32 %a, i32 %b) {
; CHECK-LABEL: f:
; CHECK:       # BB#0:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; CHECK-NEXT:    movl %ecx, %edx
; CHECK-NEXT:    imull %edx, %edx
; CHECK-NEXT:    imull %eax, %ecx
; CHECK-NEXT:    imull %eax, %eax
; CHECK-NEXT:    addl %edx, %eax
; CHECK-NEXT:    leal (%eax,%ecx,2), %eax
; CHECK-NEXT:    retl
  %tmp.2 = mul i32 %a, %a
  %tmp.5 = shl i32 %a, 1
  %tmp.6 = mul i32 %tmp.5, %b
  %tmp.10 = mul i32 %b, %b
  %tmp.7 = add i32 %tmp.10, %tmp.2
  %tmp.11 = add i32 %tmp.7, %tmp.6
  ret i32 %tmp.11
}

