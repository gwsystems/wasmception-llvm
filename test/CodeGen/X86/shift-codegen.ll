; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -relocation-model=static -mtriple=i686-unknown-unknown | FileCheck %s

; This should produce two shll instructions, not any lea's.

target triple = "i686-apple-darwin8"
@Y = weak global i32 0
@X = weak global i32 0

define void @fn1() {
; CHECK-LABEL: fn1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl Y, %eax
; CHECK-NEXT:    shll $3, %eax
; CHECK-NEXT:    orl %eax, X
; CHECK-NEXT:    retl
  %tmp = load i32, i32* @Y
  %tmp1 = shl i32 %tmp, 3
  %tmp2 = load i32, i32* @X
  %tmp3 = or i32 %tmp1, %tmp2
  store i32 %tmp3, i32* @X
  ret void
}

define i32 @fn2(i32 %X, i32 %Y) {
; CHECK-LABEL: fn2:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    shll $3, %eax
; CHECK-NEXT:    orl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    retl
  %tmp2 = shl i32 %Y, 3
  %tmp4 = or i32 %tmp2, %X
  ret i32 %tmp4
}

