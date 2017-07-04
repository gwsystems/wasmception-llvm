; RUN: llc -march=amdgcn -mcpu=verde -verify-machineinstrs < %s | FileCheck -check-prefix=SI -check-prefix=FUNC %s
; RUN: llc -march=amdgcn -mcpu=tonga -mattr=-flat-for-global -verify-machineinstrs < %s | FileCheck -check-prefix=SI -check-prefix=FUNC %s
; RUN: llc -march=r600 -mcpu=redwood < %s | FileCheck -check-prefix=EG -check-prefix=FUNC %s

; The code generated by urem is long and complex and may frequently
; change.  The goal of this test is to make sure the ISel doesn't fail
; when it gets a v2i32/v4i32 urem

; FUNC-LABEL: {{^}}test_urem_i32:
; SI: s_endpgm
; EG: CF_END
define amdgpu_kernel void @test_urem_i32(i32 addrspace(1)* %out, i32 addrspace(1)* %in) {
  %b_ptr = getelementptr i32, i32 addrspace(1)* %in, i32 1
  %a = load i32, i32 addrspace(1)* %in
  %b = load i32, i32 addrspace(1)* %b_ptr
  %result = urem i32 %a, %b
  store i32 %result, i32 addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}test_urem_i32_7:
; SI: v_mov_b32_e32 [[MAGIC:v[0-9]+]], 0x24924925
; SI: v_mul_hi_u32 [[MAGIC]], {{v[0-9]+}}
; SI: v_subrev_i32
; SI: v_mul_lo_i32
; SI: v_sub_i32
; SI: buffer_store_dword
; SI: s_endpgm
define amdgpu_kernel void @test_urem_i32_7(i32 addrspace(1)* %out, i32 addrspace(1)* %in) {
  %num = load i32, i32 addrspace(1) * %in
  %result = urem i32 %num, 7
  store i32 %result, i32 addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}test_urem_v2i32:
; SI: s_endpgm
; EG: CF_END
define amdgpu_kernel void @test_urem_v2i32(<2 x i32> addrspace(1)* %out, <2 x i32> addrspace(1)* %in) {
  %b_ptr = getelementptr <2 x i32>, <2 x i32> addrspace(1)* %in, i32 1
  %a = load <2 x i32>, <2 x i32> addrspace(1)* %in
  %b = load <2 x i32>, <2 x i32> addrspace(1)* %b_ptr
  %result = urem <2 x i32> %a, %b
  store <2 x i32> %result, <2 x i32> addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}test_urem_v4i32:
; SI: s_endpgm
; EG: CF_END
define amdgpu_kernel void @test_urem_v4i32(<4 x i32> addrspace(1)* %out, <4 x i32> addrspace(1)* %in) {
  %b_ptr = getelementptr <4 x i32>, <4 x i32> addrspace(1)* %in, i32 1
  %a = load <4 x i32>, <4 x i32> addrspace(1)* %in
  %b = load <4 x i32>, <4 x i32> addrspace(1)* %b_ptr
  %result = urem <4 x i32> %a, %b
  store <4 x i32> %result, <4 x i32> addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}test_urem_i64:
; SI: s_endpgm
; EG: CF_END
define amdgpu_kernel void @test_urem_i64(i64 addrspace(1)* %out, i64 addrspace(1)* %in) {
  %b_ptr = getelementptr i64, i64 addrspace(1)* %in, i64 1
  %a = load i64, i64 addrspace(1)* %in
  %b = load i64, i64 addrspace(1)* %b_ptr
  %result = urem i64 %a, %b
  store i64 %result, i64 addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}test_urem_v2i64:
; SI: s_endpgm
; EG: CF_END
define amdgpu_kernel void @test_urem_v2i64(<2 x i64> addrspace(1)* %out, <2 x i64> addrspace(1)* %in) {
  %b_ptr = getelementptr <2 x i64>, <2 x i64> addrspace(1)* %in, i64 1
  %a = load <2 x i64>, <2 x i64> addrspace(1)* %in
  %b = load <2 x i64>, <2 x i64> addrspace(1)* %b_ptr
  %result = urem <2 x i64> %a, %b
  store <2 x i64> %result, <2 x i64> addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}test_urem_v4i64:
; SI: s_endpgm
; EG: CF_END
define amdgpu_kernel void @test_urem_v4i64(<4 x i64> addrspace(1)* %out, <4 x i64> addrspace(1)* %in) {
  %b_ptr = getelementptr <4 x i64>, <4 x i64> addrspace(1)* %in, i64 1
  %a = load <4 x i64>, <4 x i64> addrspace(1)* %in
  %b = load <4 x i64>, <4 x i64> addrspace(1)* %b_ptr
  %result = urem <4 x i64> %a, %b
  store <4 x i64> %result, <4 x i64> addrspace(1)* %out
  ret void
}
