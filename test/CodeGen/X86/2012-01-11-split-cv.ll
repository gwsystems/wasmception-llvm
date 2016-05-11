; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: llc < %s -mattr=+avx -mtriple=i686-unknown-unknown | FileCheck %s

define void @add18i16(<18 x i16>* nocapture sret %ret, <18 x i16>* %bp) nounwind {
; CHECK-LABEL: add18i16:
; CHECK:       # BB#0:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; CHECK-NEXT:    vmovups (%ecx), %ymm0
; CHECK-NEXT:    movl 32(%ecx), %ecx
; CHECK-NEXT:    movl %ecx, 32(%eax)
; CHECK-NEXT:    vmovups %ymm0, (%eax)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retl $4
;
  %b = load <18 x i16>, <18 x i16>* %bp, align 16
  %x = add <18 x i16> zeroinitializer, %b
  store <18 x i16> %x, <18 x i16>* %ret, align 16
  ret void
}

