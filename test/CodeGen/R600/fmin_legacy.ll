; RUN: llc -march=r600 -mcpu=SI < %s | FileCheck -check-prefix=SI -check-prefix=FUNC %s
; RUN: llc -march=r600 -mcpu=redwood < %s | FileCheck -check-prefix=EG -check-prefix=FUNC %s

declare i32 @llvm.r600.read.tidig.x() #1

; FUNC-LABEL: @test_fmin_legacy_f32
; EG: MIN *
; SI: v_min_legacy_f32_e32
define void @test_fmin_legacy_f32(<4 x float> addrspace(1)* %out, <4 x float> inreg %reg0) #0 {
   %r0 = extractelement <4 x float> %reg0, i32 0
   %r1 = extractelement <4 x float> %reg0, i32 1
   %r2 = fcmp uge float %r0, %r1
   %r3 = select i1 %r2, float %r1, float %r0
   %vec = insertelement <4 x float> undef, float %r3, i32 0
   store <4 x float> %vec, <4 x float> addrspace(1)* %out, align 16
   ret void
}

; FUNC-LABEL: @test_fmin_legacy_ule_f32
; SI: buffer_load_dword [[A:v[0-9]+]], {{v\[[0-9]+:[0-9]+\]}}, {{s\[[0-9]+:[0-9]+\]}}, 0 addr64{{$}}
; SI: buffer_load_dword [[B:v[0-9]+]], {{v\[[0-9]+:[0-9]+\]}}, {{s\[[0-9]+:[0-9]+\]}}, 0 addr64 offset:4
; SI: v_min_legacy_f32_e32 {{v[0-9]+}}, [[A]], [[B]]
define void @test_fmin_legacy_ule_f32(float addrspace(1)* %out, float addrspace(1)* %in) #0 {
  %tid = call i32 @llvm.r600.read.tidig.x() #1
  %gep.0 = getelementptr float addrspace(1)* %in, i32 %tid
  %gep.1 = getelementptr float addrspace(1)* %gep.0, i32 1

  %a = load float addrspace(1)* %gep.0, align 4
  %b = load float addrspace(1)* %gep.1, align 4

  %cmp = fcmp ule float %a, %b
  %val = select i1 %cmp, float %a, float %b
  store float %val, float addrspace(1)* %out, align 4
  ret void
}

; FUNC-LABEL: @test_fmin_legacy_ole_f32
; SI: buffer_load_dword [[A:v[0-9]+]], {{v\[[0-9]+:[0-9]+\]}}, {{s\[[0-9]+:[0-9]+\]}}, 0 addr64{{$}}
; SI: buffer_load_dword [[B:v[0-9]+]], {{v\[[0-9]+:[0-9]+\]}}, {{s\[[0-9]+:[0-9]+\]}}, 0 addr64 offset:4
; SI: v_min_legacy_f32_e32 {{v[0-9]+}}, [[A]], [[B]]
define void @test_fmin_legacy_ole_f32(float addrspace(1)* %out, float addrspace(1)* %in) #0 {
  %tid = call i32 @llvm.r600.read.tidig.x() #1
  %gep.0 = getelementptr float addrspace(1)* %in, i32 %tid
  %gep.1 = getelementptr float addrspace(1)* %gep.0, i32 1

  %a = load float addrspace(1)* %gep.0, align 4
  %b = load float addrspace(1)* %gep.1, align 4

  %cmp = fcmp ole float %a, %b
  %val = select i1 %cmp, float %a, float %b
  store float %val, float addrspace(1)* %out, align 4
  ret void
}

; FUNC-LABEL: @test_fmin_legacy_olt_f32
; SI: buffer_load_dword [[A:v[0-9]+]], {{v\[[0-9]+:[0-9]+\]}}, {{s\[[0-9]+:[0-9]+\]}}, 0 addr64{{$}}
; SI: buffer_load_dword [[B:v[0-9]+]], {{v\[[0-9]+:[0-9]+\]}}, {{s\[[0-9]+:[0-9]+\]}}, 0 addr64 offset:4
; SI: v_min_legacy_f32_e32 {{v[0-9]+}}, [[A]], [[B]]
define void @test_fmin_legacy_olt_f32(float addrspace(1)* %out, float addrspace(1)* %in) #0 {
  %tid = call i32 @llvm.r600.read.tidig.x() #1
  %gep.0 = getelementptr float addrspace(1)* %in, i32 %tid
  %gep.1 = getelementptr float addrspace(1)* %gep.0, i32 1

  %a = load float addrspace(1)* %gep.0, align 4
  %b = load float addrspace(1)* %gep.1, align 4

  %cmp = fcmp olt float %a, %b
  %val = select i1 %cmp, float %a, float %b
  store float %val, float addrspace(1)* %out, align 4
  ret void
}

; FUNC-LABEL: @test_fmin_legacy_ult_f32
; SI: buffer_load_dword [[A:v[0-9]+]], {{v\[[0-9]+:[0-9]+\]}}, {{s\[[0-9]+:[0-9]+\]}}, 0 addr64{{$}}
; SI: buffer_load_dword [[B:v[0-9]+]], {{v\[[0-9]+:[0-9]+\]}}, {{s\[[0-9]+:[0-9]+\]}}, 0 addr64 offset:4
; SI: v_min_legacy_f32_e32 {{v[0-9]+}}, [[A]], [[B]]
define void @test_fmin_legacy_ult_f32(float addrspace(1)* %out, float addrspace(1)* %in) #0 {
  %tid = call i32 @llvm.r600.read.tidig.x() #1
  %gep.0 = getelementptr float addrspace(1)* %in, i32 %tid
  %gep.1 = getelementptr float addrspace(1)* %gep.0, i32 1

  %a = load float addrspace(1)* %gep.0, align 4
  %b = load float addrspace(1)* %gep.1, align 4

  %cmp = fcmp ult float %a, %b
  %val = select i1 %cmp, float %a, float %b
  store float %val, float addrspace(1)* %out, align 4
  ret void
}

attributes #0 = { nounwind }
attributes #1 = { nounwind readnone }
