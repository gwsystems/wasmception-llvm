; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=amdgcn-- -mattr=-fp64-fp16-denormals -verify-machineinstrs | FileCheck %s -check-prefixes=GCN,SI
; RUN: llc < %s -mtriple=amdgcn-- -mcpu=fiji -mattr=-fp64-fp16-denormals,-flat-for-global -verify-machineinstrs | FileCheck %s -check-prefixes=GCN,VI

define amdgpu_kernel void @madak_f16(
; SI-LABEL: madak_f16:
; SI:       ; %bb.0: ; %entry
; SI-NEXT:    s_load_dwordx4 s[4:7], s[0:1], 0x9
; SI-NEXT:    s_load_dwordx2 s[0:1], s[0:1], 0xd
; SI-NEXT:    s_mov_b32 s11, 0xf000
; SI-NEXT:    s_mov_b32 s10, -1
; SI-NEXT:    s_mov_b32 s2, s10
; SI-NEXT:    s_mov_b32 s3, s11
; SI-NEXT:    s_mov_b32 s14, s10
; SI-NEXT:    s_mov_b32 s15, s11
; SI-NEXT:    s_waitcnt lgkmcnt(0)
; SI-NEXT:    s_mov_b32 s12, s6
; SI-NEXT:    s_mov_b32 s13, s7
; SI-NEXT:    buffer_load_ushort v0, off, s[12:15], 0
; SI-NEXT:    buffer_load_ushort v1, off, s[0:3], 0
; SI-NEXT:    s_mov_b32 s8, s4
; SI-NEXT:    s_mov_b32 s9, s5
; SI-NEXT:    s_waitcnt vmcnt(1)
; SI-NEXT:    v_cvt_f32_f16_e32 v0, v0
; SI-NEXT:    s_waitcnt vmcnt(0)
; SI-NEXT:    v_cvt_f32_f16_e32 v1, v1
; SI-NEXT:    v_madak_f32 v0, v0, v1, 0x41200000
; SI-NEXT:    v_cvt_f16_f32_e32 v0, v0
; SI-NEXT:    buffer_store_short v0, off, s[8:11], 0
; SI-NEXT:    s_endpgm
;
; VI-LABEL: madak_f16:
; VI:       ; %bb.0: ; %entry
; VI-NEXT:    s_load_dwordx4 s[4:7], s[0:1], 0x24
; VI-NEXT:    s_load_dwordx2 s[8:9], s[0:1], 0x34
; VI-NEXT:    s_mov_b32 s3, 0xf000
; VI-NEXT:    s_mov_b32 s2, -1
; VI-NEXT:    s_mov_b32 s10, s2
; VI-NEXT:    s_waitcnt lgkmcnt(0)
; VI-NEXT:    s_mov_b32 s0, s4
; VI-NEXT:    s_mov_b32 s1, s5
; VI-NEXT:    s_mov_b32 s4, s6
; VI-NEXT:    s_mov_b32 s5, s7
; VI-NEXT:    s_mov_b32 s11, s3
; VI-NEXT:    s_mov_b32 s6, s2
; VI-NEXT:    s_mov_b32 s7, s3
; VI-NEXT:    buffer_load_ushort v0, off, s[4:7], 0
; VI-NEXT:    buffer_load_ushort v1, off, s[8:11], 0
; VI-NEXT:    s_waitcnt vmcnt(0)
; VI-NEXT:    v_madak_f16 v0, v0, v1, 0x4900
; VI-NEXT:    buffer_store_short v0, off, s[0:3], 0
; VI-NEXT:    s_endpgm
    half addrspace(1)* %r,
    half addrspace(1)* %a,
    half addrspace(1)* %b) {
entry:
  %a.val = load half, half addrspace(1)* %a
  %b.val = load half, half addrspace(1)* %b

  %t.val = fmul half %a.val, %b.val
  %r.val = fadd half %t.val, 10.0

  store half %r.val, half addrspace(1)* %r
  ret void
}

define amdgpu_kernel void @madak_f16_use_2(
; SI-LABEL: madak_f16_use_2:
; SI:       ; %bb.0: ; %entry
; SI-NEXT:    s_load_dwordx8 s[4:11], s[0:1], 0x9
; SI-NEXT:    s_load_dwordx2 s[0:1], s[0:1], 0x11
; SI-NEXT:    s_mov_b32 s15, 0xf000
; SI-NEXT:    s_mov_b32 s14, -1
; SI-NEXT:    s_mov_b32 s2, s14
; SI-NEXT:    s_mov_b32 s3, s15
; SI-NEXT:    s_mov_b32 s18, s14
; SI-NEXT:    s_mov_b32 s19, s15
; SI-NEXT:    s_waitcnt lgkmcnt(0)
; SI-NEXT:    s_mov_b32 s16, s10
; SI-NEXT:    s_mov_b32 s17, s11
; SI-NEXT:    s_mov_b32 s10, s14
; SI-NEXT:    s_mov_b32 s11, s15
; SI-NEXT:    buffer_load_ushort v0, off, s[8:11], 0
; SI-NEXT:    buffer_load_ushort v1, off, s[16:19], 0
; SI-NEXT:    buffer_load_ushort v2, off, s[0:3], 0
; SI-NEXT:    v_mov_b32_e32 v3, 0x41200000
; SI-NEXT:    s_mov_b32 s12, s6
; SI-NEXT:    s_mov_b32 s13, s7
; SI-NEXT:    s_mov_b32 s6, s14
; SI-NEXT:    s_mov_b32 s7, s15
; SI-NEXT:    s_waitcnt vmcnt(2)
; SI-NEXT:    v_cvt_f32_f16_e32 v0, v0
; SI-NEXT:    s_waitcnt vmcnt(1)
; SI-NEXT:    v_cvt_f32_f16_e32 v1, v1
; SI-NEXT:    s_waitcnt vmcnt(0)
; SI-NEXT:    v_cvt_f32_f16_e32 v2, v2
; SI-NEXT:    v_madak_f32 v1, v0, v1, 0x41200000
; SI-NEXT:    v_mac_f32_e32 v3, v0, v2
; SI-NEXT:    v_cvt_f16_f32_e32 v0, v1
; SI-NEXT:    v_cvt_f16_f32_e32 v1, v3
; SI-NEXT:    buffer_store_short v0, off, s[4:7], 0
; SI-NEXT:    buffer_store_short v1, off, s[12:15], 0
; SI-NEXT:    s_endpgm
;
; VI-LABEL: madak_f16_use_2:
; VI:       ; %bb.0: ; %entry
; VI-NEXT:    s_load_dwordx8 s[4:11], s[0:1], 0x24
; VI-NEXT:    s_load_dwordx2 s[12:13], s[0:1], 0x44
; VI-NEXT:    s_mov_b32 s3, 0xf000
; VI-NEXT:    s_mov_b32 s2, -1
; VI-NEXT:    s_mov_b32 s14, s2
; VI-NEXT:    s_waitcnt lgkmcnt(0)
; VI-NEXT:    s_mov_b32 s16, s10
; VI-NEXT:    s_mov_b32 s17, s11
; VI-NEXT:    s_mov_b32 s15, s3
; VI-NEXT:    s_mov_b32 s18, s2
; VI-NEXT:    s_mov_b32 s19, s3
; VI-NEXT:    s_mov_b32 s10, s2
; VI-NEXT:    s_mov_b32 s11, s3
; VI-NEXT:    buffer_load_ushort v0, off, s[8:11], 0
; VI-NEXT:    buffer_load_ushort v1, off, s[16:19], 0
; VI-NEXT:    buffer_load_ushort v3, off, s[12:15], 0
; VI-NEXT:    v_mov_b32_e32 v2, 0x4900
; VI-NEXT:    s_mov_b32 s0, s6
; VI-NEXT:    s_mov_b32 s1, s7
; VI-NEXT:    s_mov_b32 s6, s2
; VI-NEXT:    s_mov_b32 s7, s3
; VI-NEXT:    s_waitcnt vmcnt(1)
; VI-NEXT:    v_madak_f16 v1, v0, v1, 0x4900
; VI-NEXT:    s_waitcnt vmcnt(0)
; VI-NEXT:    v_mac_f16_e32 v2, v0, v3
; VI-NEXT:    buffer_store_short v1, off, s[4:7], 0
; VI-NEXT:    buffer_store_short v2, off, s[0:3], 0
; VI-NEXT:    s_endpgm
    half addrspace(1)* %r0,
    half addrspace(1)* %r1,
    half addrspace(1)* %a,
    half addrspace(1)* %b,
    half addrspace(1)* %c) {
entry:
  %a.val = load volatile half, half addrspace(1)* %a
  %b.val = load volatile half, half addrspace(1)* %b
  %c.val = load volatile half, half addrspace(1)* %c

  %t0.val = fmul half %a.val, %b.val
  %t1.val = fmul half %a.val, %c.val
  %r0.val = fadd half %t0.val, 10.0
  %r1.val = fadd half %t1.val, 10.0

  store half %r0.val, half addrspace(1)* %r0
  store half %r1.val, half addrspace(1)* %r1
  ret void
}
