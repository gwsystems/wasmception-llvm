; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -fast-isel -mtriple=x86_64-unknown-linux-gnu -mattr=+avx512f  | FileCheck %s

define i1 @test_i1(i1* %b) {
; CHECK-LABEL: test_i1:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    movzbl (%rdi), %eax
; CHECK-NEXT:    andl $1, %eax
; CHECK-NEXT:    testb $1, %al
; CHECK-NEXT:    je .LBB0_2
; CHECK-NEXT:  # BB#1: # %in
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    retq
; CHECK-NEXT:  .LBB0_2: # %out
; CHECK-NEXT:    movb $1, %al
; CHECK-NEXT:    retq
entry:
  %0 = load i1, i1* %b, align 1
  br i1 %0, label %in, label %out
in:
  ret i1 0
out:
  ret i1 1
}

