; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown | FileCheck %s

define i32 @negate_nuw(i32 %x) {
; CHECK-LABEL: negate_nuw:
; CHECK:       # BB#0:
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    retq
;
  %neg = sub nuw i32 0, %x
  ret i32 %neg
}

define <4 x i32> @negate_nuw_vec(<4 x i32> %x) {
; CHECK-LABEL: negate_nuw_vec:
; CHECK:       # BB#0:
; CHECK-NEXT:    xorps %xmm0, %xmm0
; CHECK-NEXT:    retq
;
  %neg = sub nuw <4 x i32> zeroinitializer, %x
  ret <4 x i32> %neg
}

define i8 @negate_zero_or_minsigned_nsw(i8 %x) {
; CHECK-LABEL: negate_zero_or_minsigned_nsw:
; CHECK:       # BB#0:
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    retq
;
  %signbit = and i8 %x, 128
  %neg = sub nsw i8 0, %signbit
  ret i8 %neg
}

define <4 x i32> @negate_zero_or_minsigned_nsw_vec(<4 x i32> %x) {
; CHECK-LABEL: negate_zero_or_minsigned_nsw_vec:
; CHECK:       # BB#0:
; CHECK-NEXT:    xorps %xmm0, %xmm0
; CHECK-NEXT:    retq
;
  %signbit = shl <4 x i32> %x, <i32 31, i32 31, i32 31, i32 31>
  %neg = sub nsw <4 x i32> zeroinitializer, %signbit
  ret <4 x i32> %neg
}

define i8 @negate_zero_or_minsigned(i8 %x) {
; CHECK-LABEL: negate_zero_or_minsigned:
; CHECK:       # BB#0:
; CHECK-NEXT:    shlb $7, %dil
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    retq
;
  %signbit = shl i8 %x, 7
  %neg = sub i8 0, %signbit
  ret i8 %neg
}

define <4 x i32> @negate_zero_or_minsigned_vec(<4 x i32> %x) {
; CHECK-LABEL: negate_zero_or_minsigned_vec:
; CHECK:       # BB#0:
; CHECK-NEXT:    andps {{.*}}(%rip), %xmm0
; CHECK-NEXT:    retq
;
  %signbit = and <4 x i32> %x, <i32 2147483648, i32 2147483648, i32 2147483648, i32 2147483648>
  %neg = sub <4 x i32> zeroinitializer, %signbit
  ret <4 x i32> %neg
}

