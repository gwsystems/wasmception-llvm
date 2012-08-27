; RUN: llc < %s -mtriple=x86_64-apple-darwin -mcpu=core-avx2 -mattr=avx2,+fma -fp-contract=fast | FileCheck %s
; RUN: llc < %s -mcpu=bdver2 -mattr=-fma4 -fp-contract=fast | FileCheck %s

; CHECK: test_x86_fmadd_ps
; CHECK: vfmadd213ps     %xmm2, %xmm0, %xmm1
; CHECK: ret
define <4 x float> @test_x86_fmadd_ps(<4 x float> %a0, <4 x float> %a1, <4 x float> %a2) {
  %x = fmul <4 x float> %a0, %a1
  %res = fadd <4 x float> %x, %a2
  ret <4 x float> %res
}

; CHECK: test_x86_fmsub_ps
; CHECK: fmsub213ps     %xmm2, %xmm0, %xmm1
; CHECK: ret
define <4 x float> @test_x86_fmsub_ps(<4 x float> %a0, <4 x float> %a1, <4 x float> %a2) {
  %x = fmul <4 x float> %a0, %a1
  %res = fsub <4 x float> %x, %a2
  ret <4 x float> %res
}

; CHECK: test_x86_fnmadd_ps
; CHECK: fnmadd213ps     %xmm2, %xmm0, %xmm1
; CHECK: ret
define <4 x float> @test_x86_fnmadd_ps(<4 x float> %a0, <4 x float> %a1, <4 x float> %a2) {
  %x = fmul <4 x float> %a0, %a1
  %res = fsub <4 x float> %a2, %x
  ret <4 x float> %res
}

; CHECK: test_x86_fnmsub_ps
; CHECK: fnmsub213ps     %xmm2, %xmm0, %xmm1
; CHECK: ret
define <4 x float> @test_x86_fnmsub_ps(<4 x float> %a0, <4 x float> %a1, <4 x float> %a2) {
  %x = fmul <4 x float> %a0, %a1
  %y = fsub <4 x float> <float -0.000000e+00, float -0.000000e+00, float -0.000000e+00, float -0.000000e+00>, %x
  %res = fsub <4 x float> %y, %a2
  ret <4 x float> %res
}

; CHECK: test_x86_fmadd_ps_y
; CHECK: vfmadd213ps     %ymm2, %ymm0, %ymm1
; CHECK: ret
define <8 x float> @test_x86_fmadd_ps_y(<8 x float> %a0, <8 x float> %a1, <8 x float> %a2) {
  %x = fmul <8 x float> %a0, %a1
  %res = fadd <8 x float> %x, %a2
  ret <8 x float> %res
}

; CHECK: test_x86_fmsub_ps_y
; CHECK: vfmsub213ps     %ymm2, %ymm0, %ymm1
; CHECK: ret
define <8 x float> @test_x86_fmsub_ps_y(<8 x float> %a0, <8 x float> %a1, <8 x float> %a2) {
  %x = fmul <8 x float> %a0, %a1
  %res = fsub <8 x float> %x, %a2
  ret <8 x float> %res
}

; CHECK: test_x86_fnmadd_ps_y
; CHECK: vfnmadd213ps     %ymm2, %ymm0, %ymm1
; CHECK: ret
define <8 x float> @test_x86_fnmadd_ps_y(<8 x float> %a0, <8 x float> %a1, <8 x float> %a2) {
  %x = fmul <8 x float> %a0, %a1
  %res = fsub <8 x float> %a2, %x
  ret <8 x float> %res
}

; CHECK: test_x86_fnmsub_ps_y
; CHECK: vfnmsub213ps     %ymm2, %ymm0, %ymm1
; CHECK: ret
define <8 x float> @test_x86_fnmsub_ps_y(<8 x float> %a0, <8 x float> %a1, <8 x float> %a2) {
  %x = fmul <8 x float> %a0, %a1
  %y = fsub <8 x float> <float -0.000000e+00, float -0.000000e+00, float -0.000000e+00, float -0.000000e+00, float -0.000000e+00, float -0.000000e+00, float -0.000000e+00, float -0.000000e+00>, %x
  %res = fsub <8 x float> %y, %a2
  ret <8 x float> %res
}

; CHECK: test_x86_fmadd_pd_y
; CHECK: vfmadd213pd     %ymm2, %ymm0, %ymm1
; CHECK: ret
define <4 x double> @test_x86_fmadd_pd_y(<4 x double> %a0, <4 x double> %a1, <4 x double> %a2) {
  %x = fmul <4 x double> %a0, %a1
  %res = fadd <4 x double> %x, %a2
  ret <4 x double> %res
}

; CHECK: test_x86_fmsub_pd_y
; CHECK: vfmsub213pd     %ymm2, %ymm0, %ymm1
; CHECK: ret
define <4 x double> @test_x86_fmsub_pd_y(<4 x double> %a0, <4 x double> %a1, <4 x double> %a2) {
  %x = fmul <4 x double> %a0, %a1
  %res = fsub <4 x double> %x, %a2
  ret <4 x double> %res
}

; CHECK: test_x86_fmsub_pd
; CHECK: vfmsub213pd     %xmm2, %xmm0, %xmm1
; CHECK: ret
define <2 x double> @test_x86_fmsub_pd(<2 x double> %a0, <2 x double> %a1, <2 x double> %a2) {
  %x = fmul <2 x double> %a0, %a1
  %res = fsub <2 x double> %x, %a2
  ret <2 x double> %res
}

; CHECK: test_x86_fnmadd_ss
; CHECK: vfnmadd213ss    %xmm2, %xmm0, %xmm1
; CHECK: ret
define float @test_x86_fnmadd_ss(float %a0, float %a1, float %a2) {
  %x = fmul float %a0, %a1
  %res = fsub float %a2, %x
  ret float %res
}

; CHECK: test_x86_fnmadd_sd
; CHECK: vfnmadd213sd     %xmm2, %xmm0, %xmm1
; CHECK: ret
define double @test_x86_fnmadd_sd(double %a0, double %a1, double %a2) {
  %x = fmul double %a0, %a1
  %res = fsub double %a2, %x
  ret double %res
}

; CHECK: test_x86_fmsub_sd
; CHECK: vfmsub213sd     %xmm2, %xmm0, %xmm1
; CHECK: ret
define double @test_x86_fmsub_sd(double %a0, double %a1, double %a2) {
  %x = fmul double %a0, %a1
  %res = fsub double %x, %a2
  ret double %res
}

; CHECK: test_x86_fnmsub_ss
; CHECK: vfnmsub213ss     %xmm2, %xmm0, %xmm1
; CHECK: ret
define float @test_x86_fnmsub_ss(float %a0, float %a1, float %a2) {
  %x = fsub float -0.000000e+00, %a0
  %y = fmul float %x, %a1
  %res = fsub float %y, %a2
  ret float %res
}
