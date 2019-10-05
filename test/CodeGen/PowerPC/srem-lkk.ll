; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -verify-machineinstrs -mtriple=powerpc-unknown-linux-gnu -mcpu=ppc64 < %s | FileCheck -check-prefixes=CHECK,CHECK64 %s
; RUN: llc -verify-machineinstrs -mtriple=powerpc-unknown-linux-gnu -mcpu=ppc < %s | FileCheck -check-prefixes=CHECK,CHECK32 %s

define i32 @fold_srem_positive_odd(i32 %x) {
; CHECK-LABEL: fold_srem_positive_odd:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lis 4, -21386
; CHECK-NEXT:    ori 4, 4, 37253
; CHECK-NEXT:    mulhw 4, 3, 4
; CHECK-NEXT:    add 4, 4, 3
; CHECK-NEXT:    srwi 5, 4, 31
; CHECK-NEXT:    srawi 4, 4, 6
; CHECK-NEXT:    add 4, 4, 5
; CHECK-NEXT:    mulli 4, 4, 95
; CHECK-NEXT:    subf 3, 4, 3
; CHECK-NEXT:    blr
  %1 = srem i32 %x, 95
  ret i32 %1
}


define i32 @fold_srem_positive_even(i32 %x) {
; CHECK-LABEL: fold_srem_positive_even:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lis 4, 15827
; CHECK-NEXT:    ori 4, 4, 36849
; CHECK-NEXT:    mulhw 4, 3, 4
; CHECK-NEXT:    srwi 5, 4, 31
; CHECK-NEXT:    srawi 4, 4, 8
; CHECK-NEXT:    add 4, 4, 5
; CHECK-NEXT:    mulli 4, 4, 1060
; CHECK-NEXT:    subf 3, 4, 3
; CHECK-NEXT:    blr
  %1 = srem i32 %x, 1060
  ret i32 %1
}


define i32 @fold_srem_negative_odd(i32 %x) {
; CHECK-LABEL: fold_srem_negative_odd:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lis 4, -23206
; CHECK-NEXT:    ori 4, 4, 65445
; CHECK-NEXT:    mulhw 4, 3, 4
; CHECK-NEXT:    srwi 5, 4, 31
; CHECK-NEXT:    srawi 4, 4, 8
; CHECK-NEXT:    add 4, 4, 5
; CHECK-NEXT:    mulli 4, 4, -723
; CHECK-NEXT:    subf 3, 4, 3
; CHECK-NEXT:    blr
  %1 = srem i32 %x, -723
  ret i32 %1
}


define i32 @fold_srem_negative_even(i32 %x) {
; CHECK-LABEL: fold_srem_negative_even:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lis 4, -731
; CHECK-NEXT:    ori 4, 4, 62439
; CHECK-NEXT:    mulhw 4, 3, 4
; CHECK-NEXT:    srwi 5, 4, 31
; CHECK-NEXT:    srawi 4, 4, 8
; CHECK-NEXT:    add 4, 4, 5
; CHECK-NEXT:    mulli 4, 4, -22981
; CHECK-NEXT:    subf 3, 4, 3
; CHECK-NEXT:    blr
  %1 = srem i32 %x, -22981
  ret i32 %1
}


; Don't fold if we can combine srem with sdiv.
define i32 @combine_srem_sdiv(i32 %x) {
; CHECK-LABEL: combine_srem_sdiv:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lis 4, -21386
; CHECK-NEXT:    ori 4, 4, 37253
; CHECK-NEXT:    mulhw 4, 3, 4
; CHECK-NEXT:    add 4, 4, 3
; CHECK-NEXT:    srwi 5, 4, 31
; CHECK-NEXT:    srawi 4, 4, 6
; CHECK-NEXT:    add 4, 4, 5
; CHECK-NEXT:    mulli 5, 4, 95
; CHECK-NEXT:    subf 3, 5, 3
; CHECK-NEXT:    add 3, 3, 4
; CHECK-NEXT:    blr
  %1 = srem i32 %x, 95
  %2 = sdiv i32 %x, 95
  %3 = add i32 %1, %2
  ret i32 %3
}

; Don't fold for divisors that are a power of two.
define i32 @dont_fold_srem_power_of_two(i32 %x) {
; CHECK-LABEL: dont_fold_srem_power_of_two:
; CHECK:       # %bb.0:
; CHECK-NEXT:    srawi 4, 3, 6
; CHECK-NEXT:    addze 4, 4
; CHECK-NEXT:    slwi 4, 4, 6
; CHECK-NEXT:    subf 3, 4, 3
; CHECK-NEXT:    blr
  %1 = srem i32 %x, 64
  ret i32 %1
}

; Don't fold if the divisor is one.
define i32 @dont_fold_srem_one(i32 %x) {
; CHECK-LABEL: dont_fold_srem_one:
; CHECK:       # %bb.0:
; CHECK-NEXT:    li 3, 0
; CHECK-NEXT:    blr
  %1 = srem i32 %x, 1
  ret i32 %1
}

; Don't fold if the divisor is 2^31.
define i32 @dont_fold_srem_i32_smax(i32 %x) {
; CHECK-LABEL: dont_fold_srem_i32_smax:
; CHECK:       # %bb.0:
; CHECK-NEXT:    srawi 4, 3, 31
; CHECK-NEXT:    addze 4, 4
; CHECK-NEXT:    slwi 4, 4, 31
; CHECK-NEXT:    add 3, 3, 4
; CHECK-NEXT:    blr
  %1 = srem i32 %x, 2147483648
  ret i32 %1
}

; Don't fold i64 srem
define i64 @dont_fold_srem_i64(i64 %x) {
; CHECK-LABEL: dont_fold_srem_i64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    mflr 0
; CHECK-NEXT:    stw 0, 4(1)
; CHECK-NEXT:    stwu 1, -16(1)
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    .cfi_offset lr, 4
; CHECK-NEXT:    li 5, 0
; CHECK-NEXT:    li 6, 98
; CHECK-NEXT:    bl __moddi3@PLT
; CHECK-NEXT:    lwz 0, 20(1)
; CHECK-NEXT:    addi 1, 1, 16
; CHECK-NEXT:    mtlr 0
; CHECK-NEXT:    blr
  %1 = srem i64 %x, 98
  ret i64 %1
}
