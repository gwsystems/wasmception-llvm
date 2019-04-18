; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=aarch64-- | FileCheck %s

; Each pair of tests should be logically equivalent,
; so codegen should be the same and optimal for each pair.

define <4 x float> @splat0_before_fmul_constant(<4 x float> %a) {
; CHECK-LABEL: splat0_before_fmul_constant:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fmov v1.4s, #3.00000000
; CHECK-NEXT:    fmul v0.4s, v1.4s, v0.s[0]
; CHECK-NEXT:    ret
  %splat = shufflevector <4 x float> %a, <4 x float> undef, <4 x i32> zeroinitializer
  %mul = fmul <4 x float> %splat, <float 3.0, float 3.0, float 3.0, float 3.0>
  ret <4 x float> %mul
}

define <4 x float> @splat0_after_fmul_constant(<4 x float> %a) {
; CHECK-LABEL: splat0_after_fmul_constant:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fmov v1.4s, #3.00000000
; CHECK-NEXT:    fmul v0.4s, v0.4s, v1.4s
; CHECK-NEXT:    dup v0.4s, v0.s[0]
; CHECK-NEXT:    ret
  %mul = fmul <4 x float> %a, <float 3.0, float 42.0, float 3.0, float 3.0>
  %splat = shufflevector <4 x float> %mul, <4 x float> undef, <4 x i32> zeroinitializer
  ret <4 x float> %splat
}

; Try different type and splat lane.

define <2 x double> @splat1_before_fmul_constant(<2 x double> %a) {
; CHECK-LABEL: splat1_before_fmul_constant:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fmov v1.2d, #5.00000000
; CHECK-NEXT:    fmul v0.2d, v1.2d, v0.d[1]
; CHECK-NEXT:    ret
  %splat = shufflevector <2 x double> %a, <2 x double> undef, <2 x i32> <i32 1, i32 1>
  %mul = fmul <2 x double> %splat, <double 5.0, double 5.0>
  ret <2 x double> %mul
}

define <2 x double> @splat1_after_fmul_constant(<2 x double> %a) {
; CHECK-LABEL: splat1_after_fmul_constant:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fmov v1.2d, #5.00000000
; CHECK-NEXT:    fmul v0.2d, v0.2d, v1.2d
; CHECK-NEXT:    dup v0.2d, v0.d[1]
; CHECK-NEXT:    ret
  %mul = fmul <2 x double> %a, <double -1.0, double 5.0>
  %splat = shufflevector <2 x double> %mul, <2 x double> undef, <2 x i32> <i32 1, i32 1>
  ret <2 x double> %splat
}

; 2 variable operands

define <2 x double> @splat1_before_fmul(<2 x double> %a, <2 x double> %b) {
; CHECK-LABEL: splat1_before_fmul:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fmul v0.2d, v0.2d, v1.2d
; CHECK-NEXT:    dup v0.2d, v0.d[1]
; CHECK-NEXT:    ret
  %splata = shufflevector <2 x double> %a, <2 x double> undef, <2 x i32> <i32 1, i32 1>
  %splatb = shufflevector <2 x double> %b, <2 x double> undef, <2 x i32> <i32 1, i32 1>
  %mul = fmul <2 x double> %splata, %splatb
  ret <2 x double> %mul
}

define <2 x double> @splat1_after_fmul(<2 x double> %a, <2 x double> %b) {
; CHECK-LABEL: splat1_after_fmul:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fmul v0.2d, v0.2d, v1.2d
; CHECK-NEXT:    dup v0.2d, v0.d[1]
; CHECK-NEXT:    ret
  %mul = fmul <2 x double> %a, %b
  %splat = shufflevector <2 x double> %mul, <2 x double> undef, <2 x i32> <i32 1, i32 1>
  ret <2 x double> %splat
}

; Integer multiply

define <4 x i32> @splat2_before_mul_constant(<4 x i32> %a) {
; CHECK-LABEL: splat2_before_mul_constant:
; CHECK:       // %bb.0:
; CHECK-NEXT:    movi v1.4s, #3
; CHECK-NEXT:    mul v0.4s, v1.4s, v0.s[2]
; CHECK-NEXT:    ret
  %splat = shufflevector <4 x i32> %a, <4 x i32> undef, <4 x i32> <i32 2, i32 undef, i32 2, i32 undef>
  %mul = mul <4 x i32> %splat, <i32 3, i32 3, i32 3, i32 3>
  ret <4 x i32> %mul
}

define <4 x i32> @splat2_after_mul_constant(<4 x i32> %a) {
; CHECK-LABEL: splat2_after_mul_constant:
; CHECK:       // %bb.0:
; CHECK-NEXT:    movi v1.4s, #3
; CHECK-NEXT:    mul v0.4s, v0.4s, v1.4s
; CHECK-NEXT:    dup v0.4s, v0.s[2]
; CHECK-NEXT:    ret
  %mul = mul <4 x i32> %a, <i32 3, i32 3, i32 3, i32 3>
  %splat = shufflevector <4 x i32> %mul, <4 x i32> undef, <4 x i32> <i32 2, i32 undef, i32 2, i32 undef>
  ret <4 x i32> %splat
}

define <8 x i16> @splat1_before_mul(<8 x i16> %a, <8 x i16> %b) {
; CHECK-LABEL: splat1_before_mul:
; CHECK:       // %bb.0:
; CHECK-NEXT:    mul v0.8h, v0.8h, v1.8h
; CHECK-NEXT:    dup v0.8h, v0.h[1]
; CHECK-NEXT:    ret
  %splata = shufflevector <8 x i16> %a, <8 x i16> undef, <8 x i32> <i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
  %splatb = shufflevector <8 x i16> %b, <8 x i16> undef, <8 x i32> <i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
  %mul = mul <8 x i16> %splata, %splatb
  ret <8 x i16> %mul
}

define <8 x i16> @splat1_after_mul(<8 x i16> %a, <8 x i16> %b) {
; CHECK-LABEL: splat1_after_mul:
; CHECK:       // %bb.0:
; CHECK-NEXT:    mul v0.8h, v0.8h, v1.8h
; CHECK-NEXT:    dup v0.8h, v0.h[1]
; CHECK-NEXT:    ret
  %mul = mul <8 x i16> %a, %b
  %splat = shufflevector <8 x i16> %mul, <8 x i16> undef, <8 x i32> <i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
  ret <8 x i16> %splat
}

