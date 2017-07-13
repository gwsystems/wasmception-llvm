; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-unknown -mcpu=i686 | FileCheck %s --check-prefix=X86
; RUN: llc < %s -mtriple=x86_64-unknown-unknown | FileCheck %s --check-prefix=X64

; Combine BSWAP (lowered to rolw 8) with a second rotate.
; This test checks for combining rotates with inconsistent constant value types.

define i16 @combine_bswap_rotate(i16 %a0) {
; X86-LABEL: combine_bswap_rotate:
; X86:       # BB#0:
; X86-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    rolw $9, %ax
; X86-NEXT:    retl
;
; X64-LABEL: combine_bswap_rotate:
; X64:       # BB#0:
; X64-NEXT:    rolw $9, %di
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    retq
  %1 = call i16 @llvm.bswap.i16(i16 %a0)
  %2 = shl i16 %1, 1
  %3 = lshr i16 %1, 15
  %4 = or i16 %2, %3
  ret i16 %4
}

declare i16 @llvm.bswap.i16(i16)
