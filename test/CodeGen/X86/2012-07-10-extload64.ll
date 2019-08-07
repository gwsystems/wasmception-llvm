; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-pc-win32 -mcpu=corei7 | FileCheck %s

define void @load_store(<4 x i16>* %in) {
; CHECK-LABEL: load_store:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    movq {{.*#+}} xmm0 = mem[0],zero
; CHECK-NEXT:    paddw %xmm0, %xmm0
; CHECK-NEXT:    movq %xmm0, (%eax)
; CHECK-NEXT:    retl
entry:
  %A27 = load <4 x i16>, <4 x i16>* %in, align 4
  %A28 = add <4 x i16> %A27, %A27
  store <4 x i16> %A28, <4 x i16>* %in, align 4
  ret void
}

; Make sure that we store a 64bit value, even on 32bit systems.
define void @store_64(<2 x i32>* %ptr) {
; CHECK-LABEL: store_64:
; CHECK:       # %bb.0: # %BB
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    xorps %xmm0, %xmm0
; CHECK-NEXT:    movlps %xmm0, (%eax)
; CHECK-NEXT:    retl
BB:
  store <2 x i32> zeroinitializer, <2 x i32>* %ptr
  ret void
}

define <2 x i32> @load_64(<2 x i32>* %ptr) {
; CHECK-LABEL: load_64:
; CHECK:       # %bb.0: # %BB
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-NEXT:    retl
BB:
  %t = load <2 x i32>, <2 x i32>* %ptr
  ret <2 x i32> %t
}
