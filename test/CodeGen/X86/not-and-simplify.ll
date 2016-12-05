; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=-bmi | FileCheck %s --check-prefix=ALL --check-prefix=NO_BMI
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+bmi | FileCheck %s --check-prefix=ALL --check-prefix=BMI

; Clear high bits via shift, set them with xor (not), then mask them off.

define i32 @shrink_xor_constant1(i32 %x) {
; ALL-LABEL: shrink_xor_constant1:
; ALL:       # BB#0:
; ALL-NEXT:    shrl $31, %edi
; ALL-NEXT:    xorl $1, %edi
; ALL-NEXT:    movl %edi, %eax
; ALL-NEXT:    retq
;
  %sh = lshr i32 %x, 31
  %not = xor i32 %sh, -1
  %and = and i32 %not, 1
  ret i32 %and
}

; Clear low bits via shift, set them with xor (not), then mask them off.

define i8 @shrink_xor_constant2(i8 %x) {
; ALL-LABEL: shrink_xor_constant2:
; ALL:       # BB#0:
; ALL-NEXT:    shlb $5, %dil
; ALL-NEXT:    xorb $-32, %dil
; ALL-NEXT:    movl %edi, %eax
; ALL-NEXT:    retq
;
  %sh = shl i8 %x, 5
  %not = xor i8 %sh, -1
  %and = and i8 %not, 224 ; 0xE0
  ret i8 %and
}

