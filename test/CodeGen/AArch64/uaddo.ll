; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=aarch64-- | FileCheck %s

; PR31754

; The overflow check may be against the input rather than the sum.

define i1 @uaddo_i64_increment_alt(i64 %x, i64* %p) {
; CHECK-LABEL: uaddo_i64_increment_alt:
; CHECK:       // %bb.0:
; CHECK-NEXT:    cmn x0, #1 // =1
; CHECK-NEXT:    add x8, x0, #1 // =1
; CHECK-NEXT:    cset w0, eq
; CHECK-NEXT:    str x8, [x1]
; CHECK-NEXT:    ret
  %a = add i64 %x, 1
  store i64 %a, i64* %p
  %ov = icmp eq i64 %x, -1
  ret i1 %ov
}

; Make sure insertion is done correctly based on dominance.

define i1 @uaddo_i64_increment_alt_dom(i64 %x, i64* %p) {
; CHECK-LABEL: uaddo_i64_increment_alt_dom:
; CHECK:       // %bb.0:
; CHECK-NEXT:    cmn x0, #1 // =1
; CHECK-NEXT:    cset w8, eq
; CHECK-NEXT:    add x9, x0, #1 // =1
; CHECK-NEXT:    mov w0, w8
; CHECK-NEXT:    str x9, [x1]
; CHECK-NEXT:    ret
  %ov = icmp eq i64 %x, -1
  %a = add i64 %x, 1
  store i64 %a, i64* %p
  ret i1 %ov
}

; The overflow check may be against the input rather than the sum.

define i1 @uaddo_i64_decrement_alt(i64 %x, i64* %p) {
; CHECK-LABEL: uaddo_i64_decrement_alt:
; CHECK:       // %bb.0:
; CHECK-NEXT:    cmp x0, #0 // =0
; CHECK-NEXT:    sub x8, x0, #1 // =1
; CHECK-NEXT:    cset w0, ne
; CHECK-NEXT:    str x8, [x1]
; CHECK-NEXT:    ret
  %a = add i64 %x, -1
  store i64 %a, i64* %p
  %ov = icmp ne i64 %x, 0
  ret i1 %ov
}

; Make sure insertion is done correctly based on dominance.

define i1 @uaddo_i64_decrement_alt_dom(i64 %x, i64* %p) {
; CHECK-LABEL: uaddo_i64_decrement_alt_dom:
; CHECK:       // %bb.0:
; CHECK-NEXT:    cmp x0, #0 // =0
; CHECK-NEXT:    cset w8, ne
; CHECK-NEXT:    sub x9, x0, #1 // =1
; CHECK-NEXT:    mov w0, w8
; CHECK-NEXT:    str x9, [x1]
; CHECK-NEXT:    ret
  %ov = icmp ne i64 %x, 0
  %a = add i64 %x, -1
  store i64 %a, i64* %p
  ret i1 %ov
}

