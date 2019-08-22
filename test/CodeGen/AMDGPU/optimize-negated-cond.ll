; RUN: llc -march=amdgcn -verify-machineinstrs < %s | FileCheck -check-prefix=GCN %s

; GCN-LABEL: {{^}}negated_cond:
; GCN: BB0_1:
; GCN:   v_cmp_eq_u32_e64 [[CC:[^,]+]],
; GCN: BB0_2:
; GCN-NOT: v_cndmask_b32
; GCN-NOT: v_cmp
; GCN:   s_andn2_b64 vcc, exec, [[CC]]
; GCN:   s_cbranch_vccnz BB0_4
define amdgpu_kernel void @negated_cond(i32 addrspace(1)* %arg1) {
bb:
  br label %bb1

bb1:
  %tmp1 = load i32, i32 addrspace(1)* %arg1
  %tmp2 = icmp eq i32 %tmp1, 0
  br label %bb2

bb2:
  %tmp3 = phi i32 [ 0, %bb1 ], [ %tmp6, %bb4 ]
  %tmp4 = shl i32 %tmp3, 5
  br i1 %tmp2, label %bb3, label %bb4

bb3:
  %tmp5 = add i32 %tmp4, 1
  br label %bb4

bb4:
  %tmp6 = phi i32 [ %tmp5, %bb3 ], [ %tmp4, %bb2 ]
  %gep = getelementptr inbounds i32, i32 addrspace(1)* %arg1, i32 %tmp6
  store i32 0, i32 addrspace(1)* %gep
  %tmp7 = icmp eq i32 %tmp6, 32
  br i1 %tmp7, label %bb1, label %bb2
}

; GCN-LABEL: {{^}}negated_cond_dominated_blocks:
; GCN:   v_cmp_eq_u32_e64 [[CC:[^,]+]],
; GCN: BB1_1:
; GCN-NOT: v_cndmask_b32
; GCN-NOT: v_cmp
; GCN:   s_andn2_b64 vcc, exec, [[CC]]
; GCN:   s_cbranch_vccz BB1_3
define amdgpu_kernel void @negated_cond_dominated_blocks(i32 addrspace(1)* %arg1) {
bb:
  br label %bb2

bb2:
  %tmp1 = load i32, i32 addrspace(1)* %arg1
  %tmp2 = icmp eq i32 %tmp1, 0
  br label %bb4

bb3:
  ret void

bb4:
  %tmp3 = phi i32 [ 0, %bb2 ], [ %tmp7, %bb7 ]
  %tmp4 = shl i32 %tmp3, 5
  br i1 %tmp2, label %bb5, label %bb6

bb5:
  %tmp5 = add i32 %tmp4, 1
  br label %bb7

bb6:
  %tmp6 = add i32 %tmp3, 1
  br label %bb7

bb7:
  %tmp7 = phi i32 [ %tmp5, %bb5 ], [ %tmp6, %bb6 ]
  %gep = getelementptr inbounds i32, i32 addrspace(1)* %arg1, i32 %tmp7
  store i32 0, i32 addrspace(1)* %gep
  %tmp8 = icmp eq i32 %tmp7, 32
  br i1 %tmp8, label %bb3, label %bb4
}
