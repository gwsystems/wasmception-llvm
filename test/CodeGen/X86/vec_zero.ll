; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-- -mattr=+sse2 | FileCheck %s --check-prefix=X86
; RUN: llc < %s -mtriple=x86_64-- -mattr=+sse2 | FileCheck %s --check-prefix=X64

define void @foo(<4 x float>* %P) {
; X86-LABEL: foo:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    xorps %xmm0, %xmm0
; X86-NEXT:    addps (%eax), %xmm0
; X86-NEXT:    movaps %xmm0, (%eax)
; X86-NEXT:    retl
;
; X64-LABEL: foo:
; X64:       # %bb.0:
; X64-NEXT:    xorps %xmm0, %xmm0
; X64-NEXT:    addps (%rdi), %xmm0
; X64-NEXT:    movaps %xmm0, (%rdi)
; X64-NEXT:    retq
  %T = load <4 x float>, <4 x float>* %P
  %S = fadd <4 x float> zeroinitializer, %T
  store <4 x float> %S, <4 x float>* %P
  ret void
}

define void @bar(<4 x i32>* %P) {
; X86-LABEL: bar:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    pxor %xmm0, %xmm0
; X86-NEXT:    psubd (%eax), %xmm0
; X86-NEXT:    movdqa %xmm0, (%eax)
; X86-NEXT:    retl
;
; X64-LABEL: bar:
; X64:       # %bb.0:
; X64-NEXT:    pxor %xmm0, %xmm0
; X64-NEXT:    psubd (%rdi), %xmm0
; X64-NEXT:    movdqa %xmm0, (%rdi)
; X64-NEXT:    retq
  %T = load <4 x i32>, <4 x i32>* %P
  %S = sub <4 x i32> zeroinitializer, %T
  store <4 x i32> %S, <4 x i32>* %P
  ret void
}

; Without any type hints from operations, we fall back to the smaller xorps.
; The IR type <4 x i32> is ignored.
define void @untyped_zero(<4 x i32>* %p) {
; X86-LABEL: untyped_zero:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    xorps %xmm0, %xmm0
; X86-NEXT:    movaps %xmm0, (%eax)
; X86-NEXT:    retl
;
; X64-LABEL: untyped_zero:
; X64:       # %bb.0: # %entry
; X64-NEXT:    xorps %xmm0, %xmm0
; X64-NEXT:    movaps %xmm0, (%rdi)
; X64-NEXT:    retq
entry:
  store <4 x i32> zeroinitializer, <4 x i32>* %p, align 16
  ret void
}
