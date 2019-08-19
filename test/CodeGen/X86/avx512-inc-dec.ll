; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mcpu=knl | FileCheck %s

define i32 @test(i32 %a, i32 %b) {
; CHECK-LABEL: test:
; CHECK:       ## %bb.0:
; CHECK-NEXT:    ## kill: def $edi killed $edi def $rdi
; CHECK-NEXT:    leal -1(%rdi), %eax
; CHECK-NEXT:    addl $1, %esi
; CHECK-NEXT:    imull %esi, %eax
; CHECK-NEXT:    retq
 %a1 = add i32 %a, -1
 %b1 = add i32 %b, 1
 %res = mul i32 %a1, %b1
 ret i32 %res
}

