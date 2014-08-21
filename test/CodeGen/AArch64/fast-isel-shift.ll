; RUN: llc -fast-isel -fast-isel-abort -mtriple=arm64-apple-darwin -verify-machineinstrs < %s | FileCheck %s

; CHECK-LABEL: lslv_i8
; CHECK:       and [[REG1:w[0-9]+]], w1, #0xff
; CHECK-NEXT:  lsl [[REG2:w[0-9]+]], w0, [[REG1]]
; CHECK-NEXT:  and {{w[0-9]+}}, [[REG2]], #0xff
define zeroext i8 @lslv_i8(i8 %a, i8 %b) {
  %1 = shl i8 %a, %b
  ret i8 %1
}

; CHECK-LABEL: lsl_i8
; CHECK:       ubfiz {{w[0-9]*}}, {{w[0-9]*}}, #4, #4
define zeroext i8 @lsl_i8(i8 %a) {
  %1 = shl i8 %a, 4
  ret i8 %1
}

; CHECK-LABEL: lslv_i16
; CHECK:       and [[REG1:w[0-9]+]], w1, #0xffff
; CHECK-NEXT:  lsl [[REG2:w[0-9]+]], w0, [[REG1]]
; CHECK-NEXT:  and {{w[0-9]+}}, [[REG2]], #0xffff
define zeroext i16 @lslv_i16(i16 %a, i16 %b) {
  %1 = shl i16 %a, %b
  ret i16 %1
}

; CHECK-LABEL: lsl_i16
; CHECK:       ubfiz {{w[0-9]*}}, {{w[0-9]*}}, #8, #8
define zeroext i16 @lsl_i16(i16 %a) {
  %1 = shl i16 %a, 8
  ret i16 %1
}

; CHECK-LABEL: lslv_i32
; CHECK:       lsl {{w[0-9]*}}, w0, w1
define zeroext i32 @lslv_i32(i32 %a, i32 %b) {
  %1 = shl i32 %a, %b
  ret i32 %1
}

; CHECK-LABEL: lsl_i32
; CHECK:       lsl {{w[0-9]*}}, {{w[0-9]*}}, #16
define zeroext i32 @lsl_i32(i32 %a) {
  %1 = shl i32 %a, 16
  ret i32 %1
}

; CHECK-LABEL: lslv_i64
; CHECK:       lsl {{x[0-9]*}}, x0, x1
define i64 @lslv_i64(i64 %a, i64 %b) {
  %1 = shl i64 %a, %b
  ret i64 %1
}

; FIXME: This shouldn't use the variable shift version.
; CHECK-LABEL: lsl_i64
; CHECK:       lsl {{x[0-9]*}}, {{x[0-9]*}}, {{x[0-9]*}}
define i64 @lsl_i64(i64 %a) {
  %1 = shl i64 %a, 32
  ret i64 %1
}

; CHECK-LABEL: lsrv_i8
; CHECK:       and [[REG1:w[0-9]+]], w0, #0xff
; CHECK-NEXT:  and [[REG2:w[0-9]+]], w1, #0xff
; CHECK-NEXT:  lsr [[REG3:w[0-9]+]], [[REG1]], [[REG2]]
; CHECK-NEXT:  and {{w[0-9]+}}, [[REG3]], #0xff
define zeroext i8 @lsrv_i8(i8 %a, i8 %b) {
  %1 = lshr i8 %a, %b
  ret i8 %1
}

; CHECK-LABEL: lsr_i8
; CHECK:       ubfx {{w[0-9]*}}, {{w[0-9]*}}, #4, #4
define zeroext i8 @lsr_i8(i8 %a) {
  %1 = lshr i8 %a, 4
  ret i8 %1
}

; CHECK-LABEL: lsrv_i16
; CHECK:       and [[REG1:w[0-9]+]], w0, #0xffff
; CHECK-NEXT:  and [[REG2:w[0-9]+]], w1, #0xffff
; CHECK-NEXT:  lsr [[REG3:w[0-9]+]], [[REG1]], [[REG2]]
; CHECK-NEXT:  and {{w[0-9]+}}, [[REG3]], #0xffff
define zeroext i16 @lsrv_i16(i16 %a, i16 %b) {
  %1 = lshr i16 %a, %b
  ret i16 %1
}

; CHECK-LABEL: lsr_i16
; CHECK:       ubfx {{w[0-9]*}}, {{w[0-9]*}}, #8, #8
define zeroext i16 @lsr_i16(i16 %a) {
  %1 = lshr i16 %a, 8
  ret i16 %1
}

; CHECK-LABEL: lsrv_i32
; CHECK:       lsr {{w[0-9]*}}, w0, w1
define zeroext i32 @lsrv_i32(i32 %a, i32 %b) {
  %1 = lshr i32 %a, %b
  ret i32 %1
}

; CHECK-LABEL: lsr_i32
; CHECK:       lsr {{w[0-9]*}}, {{w[0-9]*}}, #16
define zeroext i32 @lsr_i32(i32 %a) {
  %1 = lshr i32 %a, 16
  ret i32 %1
}

; CHECK-LABEL: lsrv_i64
; CHECK:       lsr {{x[0-9]*}}, x0, x1
define i64 @lsrv_i64(i64 %a, i64 %b) {
  %1 = lshr i64 %a, %b
  ret i64 %1
}

; FIXME: This shouldn't use the variable shift version.
; CHECK-LABEL: lsr_i64
; CHECK:       lsr {{x[0-9]*}}, {{x[0-9]*}}, {{x[0-9]*}}
define i64 @lsr_i64(i64 %a) {
  %1 = lshr i64 %a, 32
  ret i64 %1
}

; CHECK-LABEL: asrv_i8
; CHECK:       sxtb [[REG1:w[0-9]+]], w0
; CHECK-NEXT:  and  [[REG2:w[0-9]+]], w1, #0xff
; CHECK-NEXT:  asr  [[REG3:w[0-9]+]], [[REG1]], [[REG2]]
; CHECK-NEXT:  and  {{w[0-9]+}}, [[REG3]], #0xff
define zeroext i8 @asrv_i8(i8 %a, i8 %b) {
  %1 = ashr i8 %a, %b
  ret i8 %1
}

; CHECK-LABEL: asr_i8
; CHECK:       sbfx {{w[0-9]*}}, {{w[0-9]*}}, #4, #4
define zeroext i8 @asr_i8(i8 %a) {
  %1 = ashr i8 %a, 4
  ret i8 %1
}

; CHECK-LABEL: asrv_i16
; CHECK:       sxth [[REG1:w[0-9]+]], w0
; CHECK-NEXT:  and  [[REG2:w[0-9]+]], w1, #0xffff
; CHECK-NEXT:  asr  [[REG3:w[0-9]+]], [[REG1]], [[REG2]]
; CHECK-NEXT:  and  {{w[0-9]+}}, [[REG3]], #0xffff
define zeroext i16 @asrv_i16(i16 %a, i16 %b) {
  %1 = ashr i16 %a, %b
  ret i16 %1
}

; CHECK-LABEL: asr_i16
; CHECK:       sbfx {{w[0-9]*}}, {{w[0-9]*}}, #8, #8
define zeroext i16 @asr_i16(i16 %a) {
  %1 = ashr i16 %a, 8
  ret i16 %1
}

; CHECK-LABEL: asrv_i32
; CHECK:       asr {{w[0-9]*}}, w0, w1
define zeroext i32 @asrv_i32(i32 %a, i32 %b) {
  %1 = ashr i32 %a, %b
  ret i32 %1
}

; CHECK-LABEL: asr_i32
; CHECK:       asr {{w[0-9]*}}, {{w[0-9]*}}, #16
define zeroext i32 @asr_i32(i32 %a) {
  %1 = ashr i32 %a, 16
  ret i32 %1
}

; CHECK-LABEL: asrv_i64
; CHECK:       asr {{x[0-9]*}}, x0, x1
define i64 @asrv_i64(i64 %a, i64 %b) {
  %1 = ashr i64 %a, %b
  ret i64 %1
}

; FIXME: This shouldn't use the variable shift version.
; CHECK-LABEL: asr_i64
; CHECK:       asr {{x[0-9]*}}, {{x[0-9]*}}, {{x[0-9]*}}
define i64 @asr_i64(i64 %a) {
  %1 = ashr i64 %a, 32
  ret i64 %1
}

; CHECK-LABEL: shift_test1
; CHECK:       ubfiz {{w[0-9]*}}, {{w[0-9]*}}, #4, #4
; CHECK-NEXT:  sbfx  {{w[0-9]*}}, {{w[0-9]*}}, #4, #4
define i32 @shift_test1(i8 %a) {
  %1 = shl i8 %a, 4
  %2 = ashr i8 %1, 4
  %3 = sext i8 %2 to i32
  ret i32 %3
}

