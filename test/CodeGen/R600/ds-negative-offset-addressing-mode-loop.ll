; RUN: llc -march=r600 -mcpu=SI -verify-machineinstrs -mattr=+load-store-opt -enable-misched < %s | FileCheck -check-prefix=SI --check-prefix=CHECK %s
; RUN: llc -march=r600 -mcpu=bonaire -verify-machineinstrs -mattr=+load-store-opt -enable-misched < %s | FileCheck -check-prefix=CI --check-prefix=CHECK %s

declare i32 @llvm.r600.read.tidig.x() #0
declare void @llvm.AMDGPU.barrier.local() #1

; Function Attrs: nounwind
; CHECK-LABEL: {{^}}signed_ds_offset_addressing_loop:
; CHECK: BB0_1:
; CHECK: v_add_i32_e32 [[VADDR:v[0-9]+]],
; SI-DAG: ds_read_b32 v{{[0-9]+}}, [[VADDR]]
; SI-DAG: v_add_i32_e32 [[VADDR4:v[0-9]+]], 4, [[VADDR]]
; SI-DAG: ds_read_b32 v{{[0-9]+}}, [[VADDR4]]
; SI-DAG: v_add_i32_e32 [[VADDR0x80:v[0-9]+]], 0x80, [[VADDR]]
; SI-DAG: ds_read_b32 v{{[0-9]+}}, [[VADDR0x80]]
; SI-DAG: v_add_i32_e32 [[VADDR0x84:v[0-9]+]], 0x84, [[VADDR]]
; SI-DAG: ds_read_b32 v{{[0-9]+}}, [[VADDR0x84]]
; SI-DAG: v_add_i32_e32 [[VADDR0x100:v[0-9]+]], 0x100, [[VADDR]]
; SI-DAG: ds_read_b32 v{{[0-9]+}}, [[VADDR0x100]]

; CI-DAG: ds_read2_b32 v{{\[[0-9]+:[0-9]+\]}}, [[VADDR]] offset0:0 offset1:1
; CI-DAG: ds_read2_b32 v{{\[[0-9]+:[0-9]+\]}}, [[VADDR]] offset0:32 offset1:33
; CI-DAG: ds_read_b32 v{{[0-9]+}}, [[VADDR]] offset:256
; CHECK: s_endpgm
define void @signed_ds_offset_addressing_loop(float addrspace(1)* noalias nocapture %out, float addrspace(3)* noalias nocapture readonly %lptr, i32 %n) #2 {
entry:
  %x.i = tail call i32 @llvm.r600.read.tidig.x() #0
  %mul = shl nsw i32 %x.i, 1
  br label %for.body

for.body:                                         ; preds = %for.body, %entry
  %sum.03 = phi float [ 0.000000e+00, %entry ], [ %add13, %for.body ]
  %offset.02 = phi i32 [ %mul, %entry ], [ %add14, %for.body ]
  %k.01 = phi i32 [ 0, %entry ], [ %inc, %for.body ]
  tail call void @llvm.AMDGPU.barrier.local() #1
  %arrayidx = getelementptr inbounds float addrspace(3)* %lptr, i32 %offset.02
  %tmp = load float addrspace(3)* %arrayidx, align 4
  %add1 = add nsw i32 %offset.02, 1
  %arrayidx2 = getelementptr inbounds float addrspace(3)* %lptr, i32 %add1
  %tmp1 = load float addrspace(3)* %arrayidx2, align 4
  %add3 = add nsw i32 %offset.02, 32
  %arrayidx4 = getelementptr inbounds float addrspace(3)* %lptr, i32 %add3
  %tmp2 = load float addrspace(3)* %arrayidx4, align 4
  %add5 = add nsw i32 %offset.02, 33
  %arrayidx6 = getelementptr inbounds float addrspace(3)* %lptr, i32 %add5
  %tmp3 = load float addrspace(3)* %arrayidx6, align 4
  %add7 = add nsw i32 %offset.02, 64
  %arrayidx8 = getelementptr inbounds float addrspace(3)* %lptr, i32 %add7
  %tmp4 = load float addrspace(3)* %arrayidx8, align 4
  %add9 = fadd float %tmp, %tmp1
  %add10 = fadd float %add9, %tmp2
  %add11 = fadd float %add10, %tmp3
  %add12 = fadd float %add11, %tmp4
  %add13 = fadd float %sum.03, %add12
  %inc = add nsw i32 %k.01, 1
  %add14 = add nsw i32 %offset.02, 97
  %exitcond = icmp eq i32 %inc, 8
  br i1 %exitcond, label %for.end, label %for.body

for.end:                                          ; preds = %for.body
  %tmp5 = sext i32 %x.i to i64
  %arrayidx15 = getelementptr inbounds float addrspace(1)* %out, i64 %tmp5
  store float %add13, float addrspace(1)* %arrayidx15, align 4
  ret void
}

attributes #0 = { nounwind readnone }
attributes #1 = { noduplicate nounwind }
attributes #2 = { nounwind "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
