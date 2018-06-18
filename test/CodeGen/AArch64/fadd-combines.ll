; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=aarch64-none-linux-gnu -verify-machineinstrs | FileCheck %s

define double @test1(double %a, double %b) {
; CHECK-LABEL: test1:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fadd d1, d1, d1
; CHECK-NEXT:    fsub d0, d0, d1
; CHECK-NEXT:    ret
  %mul = fmul double %b, -2.000000e+00
  %add1 = fadd double %a, %mul
  ret double %add1
}

; DAGCombine will canonicalize 'a - 2.0*b' to 'a + -2.0*b'

define double @test2(double %a, double %b) {
; CHECK-LABEL: test2:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fadd d1, d1, d1
; CHECK-NEXT:    fsub d0, d0, d1
; CHECK-NEXT:    ret
  %mul = fmul double %b, 2.000000e+00
  %add1 = fsub double %a, %mul
  ret double %add1
}

define double @test3(double %a, double %b, double %c) {
; CHECK-LABEL: test3:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fmul d0, d0, d1
; CHECK-NEXT:    fadd d1, d2, d2
; CHECK-NEXT:    fsub d0, d0, d1
; CHECK-NEXT:    ret
  %mul = fmul double %a, %b
  %mul1 = fmul double %c, 2.000000e+00
  %sub = fsub double %mul, %mul1
  ret double %sub
}

define double @test4(double %a, double %b, double %c) {
; CHECK-LABEL: test4:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fmul d0, d0, d1
; CHECK-NEXT:    fadd d1, d2, d2
; CHECK-NEXT:    fsub d0, d0, d1
; CHECK-NEXT:    ret
  %mul = fmul double %a, %b
  %mul1 = fmul double %c, -2.000000e+00
  %add2 = fadd double %mul, %mul1
  ret double %add2
}

define <4 x float> @test5(<4 x float> %a, <4 x float> %b) {
; CHECK-LABEL: test5:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fadd v1.4s, v1.4s, v1.4s
; CHECK-NEXT:    fsub v0.4s, v0.4s, v1.4s
; CHECK-NEXT:    ret
  %mul = fmul <4 x float> %b, <float -2.0, float -2.0, float -2.0, float -2.0>
  %add = fadd <4 x float> %a, %mul
  ret <4 x float> %add
}

define <4 x float> @test6(<4 x float> %a, <4 x float> %b) {
; CHECK-LABEL: test6:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fadd v1.4s, v1.4s, v1.4s
; CHECK-NEXT:    fsub v0.4s, v0.4s, v1.4s
; CHECK-NEXT:    ret
  %mul = fmul <4 x float> %b, <float 2.0, float 2.0, float 2.0, float 2.0>
  %add = fsub <4 x float> %a, %mul
  ret <4 x float> %add
}

; Don't fold (fadd A, (fmul B, -2.0)) -> (fsub A, (fadd B, B)) if the fmul has
; multiple uses.

define double @test7(double %a, double %b) nounwind {
; CHECK-LABEL: test7:
; CHECK:       // %bb.0:
; CHECK-NEXT:    str d8, [sp, #-16]! // 8-byte Folded Spill
; CHECK-NEXT:    fmov d2, #-2.00000000
; CHECK-NEXT:    fmul d1, d1, d2
; CHECK-NEXT:    fadd d8, d0, d1
; CHECK-NEXT:    mov v0.16b, v1.16b
; CHECK-NEXT:    str x30, [sp, #8] // 8-byte Folded Spill
; CHECK-NEXT:    bl use
; CHECK-NEXT:    ldr x30, [sp, #8] // 8-byte Folded Reload
; CHECK-NEXT:    mov v0.16b, v8.16b
; CHECK-NEXT:    ldr d8, [sp], #16 // 8-byte Folded Reload
; CHECK-NEXT:    ret
  %mul = fmul double %b, -2.000000e+00
  %add1 = fadd double %a, %mul
  call void @use(double %mul)
  ret double %add1
}

define float @fadd_const_multiuse_fmf(float %x) {
; CHECK-LABEL: fadd_const_multiuse_fmf:
; CHECK:       // %bb.0:
; CHECK-NEXT:    adrp x8, .LCPI7_0
; CHECK-NEXT:    adrp x9, .LCPI7_1
; CHECK-NEXT:    ldr s1, [x8, :lo12:.LCPI7_0]
; CHECK-NEXT:    ldr s2, [x9, :lo12:.LCPI7_1]
; CHECK-NEXT:    fadd s1, s0, s1
; CHECK-NEXT:    fadd s0, s0, s2
; CHECK-NEXT:    fadd s0, s1, s0
; CHECK-NEXT:    ret
  %a1 = fadd float %x, 42.0
  %a2 = fadd nsz reassoc float %a1, 17.0
  %a3 = fadd float %a1, %a2
  ret float %a3
}

; DAGCombiner transforms this into: (x + 59.0) + (x + 17.0).
; The machine combiner transforms this into a chain of 3 dependent adds:
; ((x + 59.0) + 17.0) + x

define float @fadd_const_multiuse_attr(float %x) #0 {
; CHECK-LABEL: fadd_const_multiuse_attr:
; CHECK:       // %bb.0:
; CHECK-NEXT:    adrp x9, .LCPI8_1
; CHECK-NEXT:    adrp x8, .LCPI8_0
; CHECK-NEXT:    ldr s1, [x9, :lo12:.LCPI8_1]
; CHECK-NEXT:    ldr s2, [x8, :lo12:.LCPI8_0]
; CHECK-NEXT:    fadd s1, s0, s1
; CHECK-NEXT:    fadd s1, s2, s1
; CHECK-NEXT:    fadd s0, s0, s1
; CHECK-NEXT:    ret
  %a1 = fadd float %x, 42.0
  %a2 = fadd float %a1, 17.0
  %a3 = fadd float %a1, %a2
  ret float %a3
}

attributes #0 = { "unsafe-fp-math"="true" }

declare void @use(double)

