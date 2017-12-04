; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i386-unknown -mattr=+sse2 | FileCheck %s --check-prefix=X86
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+sse2 | FileCheck %s --check-prefix=X64

define <2 x i64> @test1() nounwind {
; X86-LABEL: test1:
; X86:       # %bb.0:
; X86-NEXT:    movl $1, %eax
; X86-NEXT:    movd %eax, %xmm0
; X86-NEXT:    retl
;
; X64-LABEL: test1:
; X64:       # %bb.0:
; X64-NEXT:    movl $1, %eax
; X64-NEXT:    movq %rax, %xmm0
; X64-NEXT:    retq
  ret <2 x i64> < i64 1, i64 0 >
}

