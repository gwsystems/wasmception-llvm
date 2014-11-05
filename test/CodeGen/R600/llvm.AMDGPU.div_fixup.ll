; RUN: llc -march=r600 -mcpu=SI -verify-machineinstrs < %s | FileCheck -check-prefix=SI %s

declare float @llvm.AMDGPU.div.fixup.f32(float, float, float) nounwind readnone
declare double @llvm.AMDGPU.div.fixup.f64(double, double, double) nounwind readnone

; SI-LABEL: {{^}}test_div_fixup_f32:
; SI-DAG: s_load_dword [[SA:s[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0xb
; SI-DAG: s_load_dword [[SC:s[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0xd
; SI-DAG: s_load_dword [[SB:s[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0xc
; SI-DAG: v_mov_b32_e32 [[VC:v[0-9]+]], [[SC]]
; SI-DAG: v_mov_b32_e32 [[VB:v[0-9]+]], [[SB]]
; SI: v_div_fixup_f32 [[RESULT:v[0-9]+]], [[SA]], [[VB]], [[VC]]
; SI: buffer_store_dword [[RESULT]],
; SI: s_endpgm
define void @test_div_fixup_f32(float addrspace(1)* %out, float %a, float %b, float %c) nounwind {
  %result = call float @llvm.AMDGPU.div.fixup.f32(float %a, float %b, float %c) nounwind readnone
  store float %result, float addrspace(1)* %out, align 4
  ret void
}

; SI-LABEL: {{^}}test_div_fixup_f64:
; SI: v_div_fixup_f64
define void @test_div_fixup_f64(double addrspace(1)* %out, double %a, double %b, double %c) nounwind {
  %result = call double @llvm.AMDGPU.div.fixup.f64(double %a, double %b, double %c) nounwind readnone
  store double %result, double addrspace(1)* %out, align 8
  ret void
}
