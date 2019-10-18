; RUN: llc -O0 -march=amdgcn -mcpu=fiji -verify-machineinstrs < %s | FileCheck -check-prefix=ALL -check-prefix=VGPR %s
; RUN: llc -O0 -march=amdgcn -mcpu=fiji -amdgpu-spill-sgpr-to-vgpr=0 -verify-machineinstrs < %s | FileCheck -check-prefix=ALL -check-prefix=VMEM %s

; ALL-LABEL: {{^}}spill_sgpr_x2:

; VGPR: v_writelane_b32 v{{[0-9]+}}, s{{[0-9]+}}, 0
; VGPR: v_writelane_b32 v{{[0-9]+}}, s{{[0-9]+}}, 1
; VGPR: s_cbranch_scc1

; VGPR: v_readlane_b32 s{{[0-9]+}}, v{{[0-9]+}}, 0
; VGPR: v_readlane_b32 s{{[0-9]+}}, v{{[0-9]+}}, 1


; VMEM: buffer_store_dword
; VMEM: buffer_store_dword
; VMEM: s_cbranch_scc1

; VMEM: buffer_load_dword
; VMEM: buffer_load_dword
define amdgpu_kernel void @spill_sgpr_x2(i32 addrspace(1)* %out, i32 %in) #0 {
  %wide.sgpr = call <2 x i32>  asm sideeffect "; def $0", "=s" () #0
  %cmp = icmp eq i32 %in, 0
  br i1 %cmp, label %bb0, label %ret

bb0:
  call void asm sideeffect "; use $0", "s"(<2 x i32> %wide.sgpr) #0
  br label %ret

ret:
  ret void
}

; ALL-LABEL: {{^}}spill_sgpr_x3:

; VGPR: v_writelane_b32 v{{[0-9]+}}, s{{[0-9]+}}, 0
; VGPR: v_writelane_b32 v{{[0-9]+}}, s{{[0-9]+}}, 1
; VGPR: v_writelane_b32 v{{[0-9]+}}, s{{[0-9]+}}, 2
; VGPR: s_cbranch_scc1

; VGPR: v_readlane_b32 s{{[0-9]+}}, v{{[0-9]+}}, 0
; VGPR: v_readlane_b32 s{{[0-9]+}}, v{{[0-9]+}}, 1
; VGPR: v_readlane_b32 s{{[0-9]+}}, v{{[0-9]+}}, 2


; VMEM: buffer_store_dword
; VMEM: buffer_store_dword
; VMEM: buffer_store_dword
; VMEM: s_cbranch_scc1

; VMEM: buffer_load_dword
; VMEM: buffer_load_dword
; VMEM: buffer_load_dword
define amdgpu_kernel void @spill_sgpr_x3(i32 addrspace(1)* %out, i32 %in) #0 {
  %wide.sgpr = call <3 x i32>  asm sideeffect "; def $0", "=s" () #0
  %cmp = icmp eq i32 %in, 0
  br i1 %cmp, label %bb0, label %ret

bb0:
  call void asm sideeffect "; use $0", "s"(<3 x i32> %wide.sgpr) #0
  br label %ret

ret:
  ret void
}

; ALL-LABEL: {{^}}spill_sgpr_x4:

; VGPR: v_writelane_b32 v{{[0-9]+}}, s{{[0-9]+}}, 0
; VGPR: v_writelane_b32 v{{[0-9]+}}, s{{[0-9]+}}, 1
; VGPR: v_writelane_b32 v{{[0-9]+}}, s{{[0-9]+}}, 2
; VGPR: v_writelane_b32 v{{[0-9]+}}, s{{[0-9]+}}, 3
; VGPR: s_cbranch_scc1

; VGPR: v_readlane_b32 s{{[0-9]+}}, v{{[0-9]+}}, 0
; VGPR: v_readlane_b32 s{{[0-9]+}}, v{{[0-9]+}}, 1
; VGPR: v_readlane_b32 s{{[0-9]+}}, v{{[0-9]+}}, 2
; VGPR: v_readlane_b32 s{{[0-9]+}}, v{{[0-9]+}}, 3


; VMEM: buffer_store_dword
; VMEM: buffer_store_dword
; VMEM: buffer_store_dword
; VMEM: buffer_store_dword
; VMEM: s_cbranch_scc1

; VMEM: buffer_load_dword
; VMEM: buffer_load_dword
; VMEM: buffer_load_dword
; VMEM: buffer_load_dword
define amdgpu_kernel void @spill_sgpr_x4(i32 addrspace(1)* %out, i32 %in) #0 {
  %wide.sgpr = call <4 x i32>  asm sideeffect "; def $0", "=s" () #0
  %cmp = icmp eq i32 %in, 0
  br i1 %cmp, label %bb0, label %ret

bb0:
  call void asm sideeffect "; use $0", "s"(<4 x i32> %wide.sgpr) #0
  br label %ret

ret:
  ret void
}

; ALL-LABEL: {{^}}spill_sgpr_x5:

; VGPR: v_writelane_b32 v{{[0-9]+}}, s{{[0-9]+}}, 0
; VGPR: v_writelane_b32 v{{[0-9]+}}, s{{[0-9]+}}, 1
; VGPR: v_writelane_b32 v{{[0-9]+}}, s{{[0-9]+}}, 2
; VGPR: v_writelane_b32 v{{[0-9]+}}, s{{[0-9]+}}, 3
; VGPR: v_writelane_b32 v{{[0-9]+}}, s{{[0-9]+}}, 4
; VGPR: s_cbranch_scc1

; VGPR: v_readlane_b32 s{{[0-9]+}}, v{{[0-9]+}}, 0
; VGPR: v_readlane_b32 s{{[0-9]+}}, v{{[0-9]+}}, 1
; VGPR: v_readlane_b32 s{{[0-9]+}}, v{{[0-9]+}}, 2
; VGPR: v_readlane_b32 s{{[0-9]+}}, v{{[0-9]+}}, 3
; VGPR: v_readlane_b32 s{{[0-9]+}}, v{{[0-9]+}}, 4


; VMEM: buffer_store_dword
; VMEM: buffer_store_dword
; VMEM: buffer_store_dword
; VMEM: buffer_store_dword
; VMEM: buffer_store_dword
; VMEM: s_cbranch_scc1

; VMEM: buffer_load_dword
; VMEM: buffer_load_dword
; VMEM: buffer_load_dword
; VMEM: buffer_load_dword
; VMEM: buffer_load_dword
define amdgpu_kernel void @spill_sgpr_x5(i32 addrspace(1)* %out, i32 %in) #0 {
  %wide.sgpr = call <5 x i32>  asm sideeffect "; def $0", "=s" () #0
  %cmp = icmp eq i32 %in, 0
  br i1 %cmp, label %bb0, label %ret

bb0:
  call void asm sideeffect "; use $0", "s"(<5 x i32> %wide.sgpr) #0
  br label %ret

ret:
  ret void
}

; ALL-LABEL: {{^}}spill_sgpr_x8:

; VGPR: v_writelane_b32 v{{[0-9]+}}, s{{[0-9]+}}, 0
; VGPR: v_writelane_b32 v{{[0-9]+}}, s{{[0-9]+}}, 1
; VGPR: v_writelane_b32 v{{[0-9]+}}, s{{[0-9]+}}, 2
; VGPR: v_writelane_b32 v{{[0-9]+}}, s{{[0-9]+}}, 3
; VGPR: v_writelane_b32 v{{[0-9]+}}, s{{[0-9]+}}, 4
; VGPR: v_writelane_b32 v{{[0-9]+}}, s{{[0-9]+}}, 5
; VGPR: v_writelane_b32 v{{[0-9]+}}, s{{[0-9]+}}, 6
; VGPR: v_writelane_b32 v{{[0-9]+}}, s{{[0-9]+}}, 7
; VGPR: s_cbranch_scc1

; VGPR: v_readlane_b32 s{{[0-9]+}}, v{{[0-9]+}}, 0
; VGPR: v_readlane_b32 s{{[0-9]+}}, v{{[0-9]+}}, 1
; VGPR: v_readlane_b32 s{{[0-9]+}}, v{{[0-9]+}}, 2
; VGPR: v_readlane_b32 s{{[0-9]+}}, v{{[0-9]+}}, 3
; VGPR: v_readlane_b32 s{{[0-9]+}}, v{{[0-9]+}}, 4
; VGPR: v_readlane_b32 s{{[0-9]+}}, v{{[0-9]+}}, 5
; VGPR: v_readlane_b32 s{{[0-9]+}}, v{{[0-9]+}}, 6
; VGPR: v_readlane_b32 s{{[0-9]+}}, v{{[0-9]+}}, 7

; VMEM: buffer_store_dword
; VMEM: buffer_store_dword
; VMEM: buffer_store_dword
; VMEM: buffer_store_dword
; VMEM: buffer_store_dword
; VMEM: buffer_store_dword
; VMEM: buffer_store_dword
; VMEM: buffer_store_dword
; VMEM: s_cbranch_scc1

; VMEM: buffer_load_dword
; VMEM: buffer_load_dword
; VMEM: buffer_load_dword
; VMEM: buffer_load_dword
; VMEM: buffer_load_dword
; VMEM: buffer_load_dword
; VMEM: buffer_load_dword
; VMEM: buffer_load_dword
define amdgpu_kernel void @spill_sgpr_x8(i32 addrspace(1)* %out, i32 %in) #0 {
  %wide.sgpr = call <8 x i32>  asm sideeffect "; def $0", "=s" () #0
  %cmp = icmp eq i32 %in, 0
  br i1 %cmp, label %bb0, label %ret

bb0:
  call void asm sideeffect "; use $0", "s"(<8 x i32> %wide.sgpr) #0
  br label %ret

ret:
  ret void
}

; FIXME: x16 inlineasm seems broken
; define amdgpu_kernel void @spill_sgpr_x16(i32 addrspace(1)* %out, i32 %in) #0 {
;   %wide.sgpr = call <16 x i32>  asm sideeffect "; def $0", "=s" () #0
;   %cmp = icmp eq i32 %in, 0
;   br i1 %cmp, label %bb0, label %ret

; bb0:
;   call void asm sideeffect "; use $0", "s"(<16 x i32> %wide.sgpr) #0
;   br label %ret

; ret:
;   ret void
; }

attributes #0 = { nounwind }
