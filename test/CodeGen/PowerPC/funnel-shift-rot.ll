; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=powerpc64le-- | FileCheck %s

declare i8 @llvm.fshl.i8(i8, i8, i8)
declare i16 @llvm.fshl.i16(i16, i16, i16)
declare i32 @llvm.fshl.i32(i32, i32, i32)
declare i64 @llvm.fshl.i64(i64, i64, i64)
declare <4 x i32> @llvm.fshl.v4i32(<4 x i32>, <4 x i32>, <4 x i32>)

declare i8 @llvm.fshr.i8(i8, i8, i8)
declare i16 @llvm.fshr.i16(i16, i16, i16)
declare i32 @llvm.fshr.i32(i32, i32, i32)
declare i64 @llvm.fshr.i64(i64, i64, i64)
declare <4 x i32> @llvm.fshr.v4i32(<4 x i32>, <4 x i32>, <4 x i32>)

; When first 2 operands match, it's a rotate.

define i8 @rotl_i8_const_shift(i8 %x) {
; CHECK-LABEL: rotl_i8_const_shift:
; CHECK:       # %bb.0:
; CHECK-NEXT:    rlwinm 4, 3, 27, 0, 31
; CHECK-NEXT:    rlwimi 4, 3, 3, 0, 28
; CHECK-NEXT:    mr 3, 4
; CHECK-NEXT:    blr
  %f = call i8 @llvm.fshl.i8(i8 %x, i8 %x, i8 3)
  ret i8 %f
}

define i64 @rotl_i64_const_shift(i64 %x) {
; CHECK-LABEL: rotl_i64_const_shift:
; CHECK:       # %bb.0:
; CHECK-NEXT:    rotldi 3, 3, 3
; CHECK-NEXT:    blr
  %f = call i64 @llvm.fshl.i64(i64 %x, i64 %x, i64 3)
  ret i64 %f
}

; When first 2 operands match, it's a rotate (by variable amount).

define i16 @rotl_i16(i16 %x, i16 %z) {
; CHECK-LABEL: rotl_i16:
; CHECK:       # %bb.0:
; CHECK-NEXT:    neg 5, 4
; CHECK-NEXT:    clrlwi 6, 3, 16
; CHECK-NEXT:    rlwinm 4, 4, 0, 28, 31
; CHECK-NEXT:    clrlwi 5, 5, 28
; CHECK-NEXT:    slw 3, 3, 4
; CHECK-NEXT:    srw 4, 6, 5
; CHECK-NEXT:    or 3, 3, 4
; CHECK-NEXT:    blr
  %f = call i16 @llvm.fshl.i16(i16 %x, i16 %x, i16 %z)
  ret i16 %f
}

define i32 @rotl_i32(i32 %x, i32 %z) {
; CHECK-LABEL: rotl_i32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    rlwnm 3, 3, 4, 0, 31
; CHECK-NEXT:    blr
  %f = call i32 @llvm.fshl.i32(i32 %x, i32 %x, i32 %z)
  ret i32 %f
}

define i64 @rotl_i64(i64 %x, i64 %z) {
; CHECK-LABEL: rotl_i64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    rldcl 3, 3, 4, 0
; CHECK-NEXT:    blr
  %f = call i64 @llvm.fshl.i64(i64 %x, i64 %x, i64 %z)
  ret i64 %f
}

; Vector rotate.

define <4 x i32> @rotl_v4i32(<4 x i32> %x, <4 x i32> %z) {
; CHECK-LABEL: rotl_v4i32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xxlxor 36, 36, 36
; CHECK-NEXT:    vslw 5, 2, 3
; CHECK-NEXT:    vsubuwm 3, 4, 3
; CHECK-NEXT:    vsrw 2, 2, 3
; CHECK-NEXT:    xxlor 34, 37, 34
; CHECK-NEXT:    blr
  %f = call <4 x i32> @llvm.fshl.v4i32(<4 x i32> %x, <4 x i32> %x, <4 x i32> %z)
  ret <4 x i32> %f
}

; Vector rotate by constant splat amount.

define <4 x i32> @rotl_v4i32_const_shift(<4 x i32> %x) {
; CHECK-LABEL: rotl_v4i32_const_shift:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vspltisw 3, -16
; CHECK-NEXT:    vspltisw 4, 13
; CHECK-NEXT:    vspltisw 5, 3
; CHECK-NEXT:    vsubuwm 3, 4, 3
; CHECK-NEXT:    vslw 4, 2, 5
; CHECK-NEXT:    vsrw 2, 2, 3
; CHECK-NEXT:    xxlor 34, 36, 34
; CHECK-NEXT:    blr
  %f = call <4 x i32> @llvm.fshl.v4i32(<4 x i32> %x, <4 x i32> %x, <4 x i32> <i32 3, i32 3, i32 3, i32 3>)
  ret <4 x i32> %f
}

; Repeat everything for funnel shift right.

define i8 @rotr_i8_const_shift(i8 %x) {
; CHECK-LABEL: rotr_i8_const_shift:
; CHECK:       # %bb.0:
; CHECK-NEXT:    rlwinm 4, 3, 29, 0, 31
; CHECK-NEXT:    rlwimi 4, 3, 5, 0, 26
; CHECK-NEXT:    mr 3, 4
; CHECK-NEXT:    blr
  %f = call i8 @llvm.fshr.i8(i8 %x, i8 %x, i8 3)
  ret i8 %f
}

define i32 @rotr_i32_const_shift(i32 %x) {
; CHECK-LABEL: rotr_i32_const_shift:
; CHECK:       # %bb.0:
; CHECK-NEXT:    rlwinm 3, 3, 29, 0, 31
; CHECK-NEXT:    blr
  %f = call i32 @llvm.fshr.i32(i32 %x, i32 %x, i32 3)
  ret i32 %f
}

; When first 2 operands match, it's a rotate (by variable amount).

define i16 @rotr_i16(i16 %x, i16 %z) {
; CHECK-LABEL: rotr_i16:
; CHECK:       # %bb.0:
; CHECK-NEXT:    neg 5, 4
; CHECK-NEXT:    clrlwi 6, 3, 16
; CHECK-NEXT:    rlwinm 4, 4, 0, 28, 31
; CHECK-NEXT:    clrlwi 5, 5, 28
; CHECK-NEXT:    srw 4, 6, 4
; CHECK-NEXT:    slw 3, 3, 5
; CHECK-NEXT:    or 3, 3, 4
; CHECK-NEXT:    blr
  %f = call i16 @llvm.fshr.i16(i16 %x, i16 %x, i16 %z)
  ret i16 %f
}

define i32 @rotr_i32(i32 %x, i32 %z) {
; CHECK-LABEL: rotr_i32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    neg 4, 4
; CHECK-NEXT:    clrlwi 4, 4, 27
; CHECK-NEXT:    rlwnm 3, 3, 4, 0, 31
; CHECK-NEXT:    blr
  %f = call i32 @llvm.fshr.i32(i32 %x, i32 %x, i32 %z)
  ret i32 %f
}

define i64 @rotr_i64(i64 %x, i64 %z) {
; CHECK-LABEL: rotr_i64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    neg 4, 4
; CHECK-NEXT:    rlwinm 4, 4, 0, 26, 31
; CHECK-NEXT:    rotld 3, 3, 4
; CHECK-NEXT:    blr
  %f = call i64 @llvm.fshr.i64(i64 %x, i64 %x, i64 %z)
  ret i64 %f
}

; Vector rotate.

define <4 x i32> @rotr_v4i32(<4 x i32> %x, <4 x i32> %z) {
; CHECK-LABEL: rotr_v4i32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xxlxor 36, 36, 36
; CHECK-NEXT:    vsrw 5, 2, 3
; CHECK-NEXT:    vsubuwm 3, 4, 3
; CHECK-NEXT:    vslw 2, 2, 3
; CHECK-NEXT:    xxlor 34, 34, 37
; CHECK-NEXT:    blr
  %f = call <4 x i32> @llvm.fshr.v4i32(<4 x i32> %x, <4 x i32> %x, <4 x i32> %z)
  ret <4 x i32> %f
}

; Vector rotate by constant splat amount.

define <4 x i32> @rotr_v4i32_const_shift(<4 x i32> %x) {
; CHECK-LABEL: rotr_v4i32_const_shift:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vspltisw 3, -16
; CHECK-NEXT:    vspltisw 4, 13
; CHECK-NEXT:    vspltisw 5, 3
; CHECK-NEXT:    vsubuwm 3, 4, 3
; CHECK-NEXT:    vsrw 4, 2, 5
; CHECK-NEXT:    vslw 2, 2, 3
; CHECK-NEXT:    xxlor 34, 34, 36
; CHECK-NEXT:    blr
  %f = call <4 x i32> @llvm.fshr.v4i32(<4 x i32> %x, <4 x i32> %x, <4 x i32> <i32 3, i32 3, i32 3, i32 3>)
  ret <4 x i32> %f
}

define i32 @rotl_i32_shift_by_bitwidth(i32 %x) {
; CHECK-LABEL: rotl_i32_shift_by_bitwidth:
; CHECK:       # %bb.0:
; CHECK-NEXT:    blr
  %f = call i32 @llvm.fshl.i32(i32 %x, i32 %x, i32 32)
  ret i32 %f
}

define i32 @rotr_i32_shift_by_bitwidth(i32 %x) {
; CHECK-LABEL: rotr_i32_shift_by_bitwidth:
; CHECK:       # %bb.0:
; CHECK-NEXT:    blr
  %f = call i32 @llvm.fshr.i32(i32 %x, i32 %x, i32 32)
  ret i32 %f
}

define <4 x i32> @rotl_v4i32_shift_by_bitwidth(<4 x i32> %x) {
; CHECK-LABEL: rotl_v4i32_shift_by_bitwidth:
; CHECK:       # %bb.0:
; CHECK-NEXT:    blr
  %f = call <4 x i32> @llvm.fshl.v4i32(<4 x i32> %x, <4 x i32> %x, <4 x i32> <i32 32, i32 32, i32 32, i32 32>)
  ret <4 x i32> %f
}

define <4 x i32> @rotr_v4i32_shift_by_bitwidth(<4 x i32> %x) {
; CHECK-LABEL: rotr_v4i32_shift_by_bitwidth:
; CHECK:       # %bb.0:
; CHECK-NEXT:    blr
  %f = call <4 x i32> @llvm.fshr.v4i32(<4 x i32> %x, <4 x i32> %x, <4 x i32> <i32 32, i32 32, i32 32, i32 32>)
  ret <4 x i32> %f
}

