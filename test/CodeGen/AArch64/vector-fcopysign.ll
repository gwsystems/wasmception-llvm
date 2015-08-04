; RUN: llc < %s -mtriple aarch64-apple-darwin | FileCheck %s

target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"

;============ v1f32

; WidenVecRes same
define <1 x float> @test_copysign_v1f32_v1f32(<1 x float> %a, <1 x float> %b) #0 {
; CHECK-LABEL: test_copysign_v1f32_v1f32:
; CHECK:       ; BB#0:
; CHECK-NEXT:    mov s2, v1[1]
; CHECK-NEXT:    mov s3, v0[1]
; CHECK-NEXT:    movi.4s v4, #0x80, lsl #24
; CHECK-NEXT:    bit.16b v3, v2, v4
; CHECK-NEXT:    bit.16b v0, v1, v4
; CHECK-NEXT:    ins.s v0[1], v3[0]
; CHECK-NEXT:    ret
  %r = call <1 x float> @llvm.copysign.v1f32(<1 x float> %a, <1 x float> %b)
  ret <1 x float> %r
}

; WidenVecRes mismatched
define <1 x float> @test_copysign_v1f32_v1f64(<1 x float> %a, <1 x double> %b) #0 {
; CHECK-LABEL: test_copysign_v1f32_v1f64:
; CHECK:       ; BB#0:
; CHECK-NEXT:    fcvt s1, d1
; CHECK-NEXT:    movi.4s v2, #0x80, lsl #24
; CHECK-NEXT:    bit.16b v0, v1, v2
; CHECK-NEXT:    ret
  %tmp0 = fptrunc <1 x double> %b to <1 x float>
  %r = call <1 x float> @llvm.copysign.v1f32(<1 x float> %a, <1 x float> %tmp0)
  ret <1 x float> %r
}

declare <1 x float> @llvm.copysign.v1f32(<1 x float> %a, <1 x float> %b) #0

;============ v1f64

; WidenVecOp #1
define <1 x double> @test_copysign_v1f64_v1f32(<1 x double> %a, <1 x float> %b) #0 {
; CHECK-LABEL: test_copysign_v1f64_v1f32:
; CHECK:       ; BB#0:
; CHECK-NEXT:    fcvt d1, s1
; CHECK-NEXT:    movi.2d v2, #0000000000000000
; CHECK-NEXT:    fneg.2d v2, v2
; CHECK-NEXT:    bit.16b v0, v1, v2
; CHECK-NEXT:    ret
  %tmp0 = fpext <1 x float> %b to <1 x double>
  %r = call <1 x double> @llvm.copysign.v1f64(<1 x double> %a, <1 x double> %tmp0)
  ret <1 x double> %r
}

define <1 x double> @test_copysign_v1f64_v1f64(<1 x double> %a, <1 x double> %b) #0 {
; CHECK-LABEL: test_copysign_v1f64_v1f64:
; CHECK:       ; BB#0:
; CHECK-NEXT:    movi.2d v2, #0000000000000000
; CHECK-NEXT:    fneg.2d v2, v2
; CHECK-NEXT:    bit.16b v0, v1, v2
; CHECK-NEXT:    ret
  %r = call <1 x double> @llvm.copysign.v1f64(<1 x double> %a, <1 x double> %b)
  ret <1 x double> %r
}

declare <1 x double> @llvm.copysign.v1f64(<1 x double> %a, <1 x double> %b) #0

;============ v2f32

define <2 x float> @test_copysign_v2f32_v2f32(<2 x float> %a, <2 x float> %b) #0 {
; CHECK-LABEL: test_copysign_v2f32_v2f32:
; CHECK:       ; BB#0:
; CHECK-NEXT:    mov s2, v1[1]
; CHECK-NEXT:    mov s3, v0[1]
; CHECK-NEXT:    movi.4s v4, #0x80, lsl #24
; CHECK-NEXT:    bit.16b v3, v2, v4
; CHECK-NEXT:    bit.16b v0, v1, v4
; CHECK-NEXT:    ins.s v0[1], v3[0]
; CHECK-NEXT:    ret
  %r = call <2 x float> @llvm.copysign.v2f32(<2 x float> %a, <2 x float> %b)
  ret <2 x float> %r
}

define <2 x float> @test_copysign_v2f32_v2f64(<2 x float> %a, <2 x double> %b) #0 {
; CHECK-LABEL: test_copysign_v2f32_v2f64:
; CHECK:       ; BB#0:
; CHECK-NEXT:    mov d2, v1[1]
; CHECK-NEXT:    mov s3, v0[1]
; CHECK-NEXT:    movi.4s v4, #0x80, lsl #24
; CHECK-NEXT:    fcvt s1, d1
; CHECK-NEXT:    fcvt s2, d2
; CHECK-NEXT:    bit.16b v3, v2, v4
; CHECK-NEXT:    bit.16b v0, v1, v4
; CHECK-NEXT:    ins.s v0[1], v3[0]
; CHECK-NEXT:    ret
  %tmp0 = fptrunc <2 x double> %b to <2 x float>
  %r = call <2 x float> @llvm.copysign.v2f32(<2 x float> %a, <2 x float> %tmp0)
  ret <2 x float> %r
}

declare <2 x float> @llvm.copysign.v2f32(<2 x float> %a, <2 x float> %b) #0

;============ v4f32

define <4 x float> @test_copysign_v4f32_v4f32(<4 x float> %a, <4 x float> %b) #0 {
; CHECK-LABEL: test_copysign_v4f32_v4f32:
; CHECK:       ; BB#0:
; CHECK-NEXT:    mov s2, v1[1]
; CHECK-NEXT:    mov s3, v0[1]
; CHECK-NEXT:    movi.4s v4, #0x80, lsl #24
; CHECK-NEXT:    mov s5, v0[2]
; CHECK-NEXT:    bit.16b v3, v2, v4
; CHECK-NEXT:    mov s2, v0[3]
; CHECK-NEXT:    mov s6, v1[2]
; CHECK-NEXT:    bit.16b v0, v1, v4
; CHECK-NEXT:    bit.16b v5, v6, v4
; CHECK-NEXT:    mov s1, v1[3]
; CHECK-NEXT:    ins.s v0[1], v3[0]
; CHECK-NEXT:    ins.s v0[2], v5[0]
; CHECK-NEXT:    bit.16b v2, v1, v4
; CHECK-NEXT:    ins.s v0[3], v2[0]
; CHECK-NEXT:    ret
  %r = call <4 x float> @llvm.copysign.v4f32(<4 x float> %a, <4 x float> %b)
  ret <4 x float> %r
}

; SplitVecOp #1
define <4 x float> @test_copysign_v4f32_v4f64(<4 x float> %a, <4 x double> %b) #0 {
; CHECK-LABEL: test_copysign_v4f32_v4f64:
; CHECK:       ; BB#0:
; CHECK-NEXT:    mov s3, v0[1]
; CHECK-NEXT:    mov d4, v1[1]
; CHECK-NEXT:    movi.4s v5, #0x80, lsl #24
; CHECK-NEXT:    fcvt s1, d1
; CHECK-NEXT:    mov s6, v0[2]
; CHECK-NEXT:    mov s7, v0[3]
; CHECK-NEXT:    fcvt s16, d2
; CHECK-NEXT:    bit.16b v0, v1, v5
; CHECK-NEXT:    bit.16b v6, v16, v5
; CHECK-NEXT:    fcvt s1, d4
; CHECK-NEXT:    bit.16b v3, v1, v5
; CHECK-NEXT:    mov d1, v2[1]
; CHECK-NEXT:    fcvt s1, d1
; CHECK-NEXT:    ins.s v0[1], v3[0]
; CHECK-NEXT:    ins.s v0[2], v6[0]
; CHECK-NEXT:    bit.16b v7, v1, v5
; CHECK-NEXT:    ins.s v0[3], v7[0]
; CHECK-NEXT:    ret
  %tmp0 = fptrunc <4 x double> %b to <4 x float>
  %r = call <4 x float> @llvm.copysign.v4f32(<4 x float> %a, <4 x float> %tmp0)
  ret <4 x float> %r
}

declare <4 x float> @llvm.copysign.v4f32(<4 x float> %a, <4 x float> %b) #0

;============ v2f64

define <2 x double> @test_copysign_v2f64_v232(<2 x double> %a, <2 x float> %b) #0 {
; CHECK-LABEL: test_copysign_v2f64_v232:
; CHECK:       ; BB#0:
; CHECK-NEXT:    mov d2, v0[1]
; CHECK-NEXT:    mov s3, v1[1]
; CHECK-NEXT:    movi.2d v4, #0000000000000000
; CHECK-NEXT:    fcvt d1, s1
; CHECK-NEXT:    fcvt d3, s3
; CHECK-NEXT:    fneg.2d v4, v4
; CHECK-NEXT:    bit.16b v2, v3, v4
; CHECK-NEXT:    bit.16b v0, v1, v4
; CHECK-NEXT:    ins.d v0[1], v2[0]
; CHECK-NEXT:    ret
  %tmp0 = fpext <2 x float> %b to <2 x double>
  %r = call <2 x double> @llvm.copysign.v2f64(<2 x double> %a, <2 x double> %tmp0)
  ret <2 x double> %r
}

define <2 x double> @test_copysign_v2f64_v2f64(<2 x double> %a, <2 x double> %b) #0 {
; CHECK-LABEL: test_copysign_v2f64_v2f64:
; CHECK:       ; BB#0:
; CHECK-NEXT:    mov d2, v1[1]
; CHECK-NEXT:    mov d3, v0[1]
; CHECK-NEXT:    movi.2d v4, #0000000000000000
; CHECK-NEXT:    fneg.2d v4, v4
; CHECK-NEXT:    bit.16b v3, v2, v4
; CHECK-NEXT:    bit.16b v0, v1, v4
; CHECK-NEXT:    ins.d v0[1], v3[0]
; CHECK-NEXT:    ret
  %r = call <2 x double> @llvm.copysign.v2f64(<2 x double> %a, <2 x double> %b)
  ret <2 x double> %r
}

declare <2 x double> @llvm.copysign.v2f64(<2 x double> %a, <2 x double> %b) #0

;============ v4f64

; SplitVecRes mismatched
define <4 x double> @test_copysign_v4f64_v4f32(<4 x double> %a, <4 x float> %b) #0 {
; CHECK-LABEL: test_copysign_v4f64_v4f32:
; CHECK:       ; BB#0:
; CHECK-NEXT:    ext.16b v3, v2, v2, #8
; CHECK-NEXT:    mov d4, v0[1]
; CHECK-NEXT:    mov s5, v2[1]
; CHECK-NEXT:    movi.2d v6, #0000000000000000
; CHECK-NEXT:    fcvt d2, s2
; CHECK-NEXT:    fcvt d5, s5
; CHECK-NEXT:    fneg.2d v6, v6
; CHECK-NEXT:    bit.16b v4, v5, v6
; CHECK-NEXT:    mov d5, v1[1]
; CHECK-NEXT:    bit.16b v0, v2, v6
; CHECK-NEXT:    mov s2, v3[1]
; CHECK-NEXT:    fcvt d3, s3
; CHECK-NEXT:    fcvt d2, s2
; CHECK-NEXT:    ins.d v0[1], v4[0]
; CHECK-NEXT:    bit.16b v5, v2, v6
; CHECK-NEXT:    bit.16b v1, v3, v6
; CHECK-NEXT:    ins.d v1[1], v5[0]
; CHECK-NEXT:    ret
  %tmp0 = fpext <4 x float> %b to <4 x double>
  %r = call <4 x double> @llvm.copysign.v4f64(<4 x double> %a, <4 x double> %tmp0)
  ret <4 x double> %r
}

; SplitVecRes same
define <4 x double> @test_copysign_v4f64_v4f64(<4 x double> %a, <4 x double> %b) #0 {
; CHECK-LABEL: test_copysign_v4f64_v4f64:
; CHECK:       ; BB#0:
; CHECK-NEXT:    mov d4, v2[1]
; CHECK-NEXT:    mov d5, v0[1]
; CHECK-NEXT:    movi.2d v6, #0000000000000000
; CHECK-NEXT:    fneg.2d v6, v6
; CHECK-NEXT:    bit.16b v5, v4, v6
; CHECK-NEXT:    mov d4, v3[1]
; CHECK-NEXT:    bit.16b v0, v2, v6
; CHECK-NEXT:    mov d2, v1[1]
; CHECK-NEXT:    bit.16b v2, v4, v6
; CHECK-NEXT:    bit.16b v1, v3, v6
; CHECK-NEXT:    ins.d v0[1], v5[0]
; CHECK-NEXT:    ins.d v1[1], v2[0]
; CHECK-NEXT:    ret
  %r = call <4 x double> @llvm.copysign.v4f64(<4 x double> %a, <4 x double> %b)
  ret <4 x double> %r
}

declare <4 x double> @llvm.copysign.v4f64(<4 x double> %a, <4 x double> %b) #0

attributes #0 = { nounwind }
