; RUN: llc -march=amdgcn -mcpu=tonga -verify-machineinstrs -show-mc-encoding < %s | FileCheck -check-prefix=VI %s

; VI-LABEL: {{^}}dpp_test:
; VI: v_mov_b32_dpp v0, v0 quad_perm:1 row_mask:0x1 bank_mask:0x1 bound_ctrl:0 ; encoding: [0xfa,0x02,0x00,0x7e,0x00,0x01,0x08,0x11]
define void @dpp_test(i32 addrspace(1)* %out, i32 %in) {
  %tmp0 = call i32 @llvm.amdgcn.mov.dpp.i32(i32 %in, i32 1, i32 1, i32 1, i1 1) #0
  store i32 %tmp0, i32 addrspace(1)* %out
  ret void
}

declare i32 @llvm.amdgcn.mov.dpp.i32(i32, i32, i32, i32, i1) #0

attributes #0 = { nounwind readnone convergent }
