; RUN: llc -O0 -fast-isel-abort=1 -verify-machineinstrs -mtriple=arm64-apple-darwin < %s | FileCheck %s

; Materialize using fmov
define float @fmov_float1() {
; CHECK-LABEL: fmov_float1
; CHECK:       fmov s0, #1.25000000
  ret float 1.250000e+00
}

define float @fmov_float2() {
; CHECK-LABEL: fmov_float2
; CHECK:       fmov s0, wzr
  ret float 0.0e+00
}

define double @fmov_double1() {
; CHECK-LABEL: fmov_double1
; CHECK:       fmov d0, #1.25000000
  ret double 1.250000e+00
}

define double @fmov_double2() {
; CHECK-LABEL: fmov_double2
; CHECK:       fmov d0, xzr
  ret double 0.0e+00
}

; Materialize from constant pool
define float @cp_float() {
; CHECK-LABEL: cp_float
; CHECK:       adrp [[REG:x[0-9]+]], {{lCPI[0-9]+_0}}@PAGE
; CHECK-NEXT:  ldr s0, {{\[}}[[REG]], {{lCPI[0-9]+_0}}@PAGEOFF{{\]}}
  ret float 0x400921FB60000000
}

define double @cp_double() {
; CHECK-LABEL: cp_double
; CHECK:       adrp [[REG:x[0-9]+]], {{lCPI[0-9]+_0}}@PAGE
; CHECK-NEXT:  ldr d0, {{\[}}[[REG]], {{lCPI[0-9]+_0}}@PAGEOFF{{\]}}
  ret double 0x400921FB54442D18
}
