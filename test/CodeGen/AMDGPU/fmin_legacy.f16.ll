; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=amdgcn-- -mcpu=gfx900 -verify-machineinstrs < %s | FileCheck -enable-var-scope -check-prefixes=GFX9-SAFE %s
; RUN: llc -enable-no-nans-fp-math -enable-no-signed-zeros-fp-math -mtriple=amdgcn-- -mcpu=gfx900 -verify-machineinstrs < %s | FileCheck -enable-var-scope -check-prefixes=GFX9-NNAN %s

; RUN: llc -mtriple=amdgcn-- -mcpu=fiji -verify-machineinstrs < %s | FileCheck -enable-var-scope -check-prefix=VI-SAFE %s
; RUN: llc -enable-no-nans-fp-math -enable-no-signed-zeros-fp-math -mtriple=amdgcn-- -mcpu=fiji -verify-machineinstrs < %s | FileCheck -enable-var-scope -check-prefixes=VI-NNAN %s

; RUN: llc -mtriple=amdgcn-- -verify-machineinstrs < %s | FileCheck -enable-var-scope -check-prefix=SI-SAFE %s
; RUN: llc -enable-no-nans-fp-math -enable-no-signed-zeros-fp-math -mtriple=amdgcn-- -verify-machineinstrs < %s | FileCheck -enable-var-scope -check-prefixes=SI-NNAN %s


define half @test_fmin_legacy_ule_f16(half %a, half %b) #0 {
; GFX9-SAFE-LABEL: test_fmin_legacy_ule_f16:
; GFX9-SAFE:       ; %bb.0:
; GFX9-SAFE-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v0, v1
; GFX9-SAFE-NEXT:    v_cndmask_b32_e32 v0, v1, v0, vcc
; GFX9-SAFE-NEXT:    s_setpc_b64 s[30:31]
;
; GFX9-NNAN-LABEL: test_fmin_legacy_ule_f16:
; GFX9-NNAN:       ; %bb.0:
; GFX9-NNAN-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NNAN-NEXT:    v_min_f16_e32 v0, v0, v1
; GFX9-NNAN-NEXT:    s_setpc_b64 s[30:31]
;
; VI-SAFE-LABEL: test_fmin_legacy_ule_f16:
; VI-SAFE:       ; %bb.0:
; VI-SAFE-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; VI-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v0, v1
; VI-SAFE-NEXT:    v_cndmask_b32_e32 v0, v1, v0, vcc
; VI-SAFE-NEXT:    s_setpc_b64 s[30:31]
;
; VI-NNAN-LABEL: test_fmin_legacy_ule_f16:
; VI-NNAN:       ; %bb.0:
; VI-NNAN-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; VI-NNAN-NEXT:    v_min_f16_e32 v0, v0, v1
; VI-NNAN-NEXT:    s_setpc_b64 s[30:31]
;
; SI-SAFE-LABEL: test_fmin_legacy_ule_f16:
; SI-SAFE:       ; %bb.0:
; SI-SAFE-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v0, v0
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v1, v1
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v0, v0
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v1, v1
; SI-SAFE-NEXT:    v_min_legacy_f32_e32 v0, v1, v0
; SI-SAFE-NEXT:    s_setpc_b64 s[30:31]
;
; SI-NNAN-LABEL: test_fmin_legacy_ule_f16:
; SI-NNAN:       ; %bb.0:
; SI-NNAN-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v1, v1
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v0, v0
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v1, v1
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v0, v0
; SI-NNAN-NEXT:    v_min_f32_e32 v0, v0, v1
; SI-NNAN-NEXT:    s_setpc_b64 s[30:31]
  %cmp = fcmp ule half %a, %b
  %val = select i1 %cmp, half %a, half %b
  ret half %val
}

define <2 x half> @test_fmin_legacy_ule_v2f16(<2 x half> %a, <2 x half> %b) #0 {
; GFX9-SAFE-LABEL: test_fmin_legacy_ule_v2f16:
; GFX9-SAFE:       ; %bb.0:
; GFX9-SAFE-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-SAFE-NEXT:    v_lshrrev_b32_e32 v2, 16, v1
; GFX9-SAFE-NEXT:    v_lshrrev_b32_e32 v3, 16, v0
; GFX9-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v3, v2
; GFX9-SAFE-NEXT:    v_cndmask_b32_e32 v2, v2, v3, vcc
; GFX9-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v0, v1
; GFX9-SAFE-NEXT:    v_cndmask_b32_e32 v0, v1, v0, vcc
; GFX9-SAFE-NEXT:    v_and_b32_e32 v0, 0xffff, v0
; GFX9-SAFE-NEXT:    v_lshl_or_b32 v0, v2, 16, v0
; GFX9-SAFE-NEXT:    s_setpc_b64 s[30:31]
;
; GFX9-NNAN-LABEL: test_fmin_legacy_ule_v2f16:
; GFX9-NNAN:       ; %bb.0:
; GFX9-NNAN-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NNAN-NEXT:    v_pk_min_f16 v0, v0, v1
; GFX9-NNAN-NEXT:    s_setpc_b64 s[30:31]
;
; VI-SAFE-LABEL: test_fmin_legacy_ule_v2f16:
; VI-SAFE:       ; %bb.0:
; VI-SAFE-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; VI-SAFE-NEXT:    v_lshrrev_b32_e32 v2, 16, v1
; VI-SAFE-NEXT:    v_lshrrev_b32_e32 v3, 16, v0
; VI-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v3, v2
; VI-SAFE-NEXT:    v_cndmask_b32_e32 v2, v2, v3, vcc
; VI-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v0, v1
; VI-SAFE-NEXT:    v_lshlrev_b32_e32 v2, 16, v2
; VI-SAFE-NEXT:    v_cndmask_b32_e32 v0, v1, v0, vcc
; VI-SAFE-NEXT:    v_or_b32_sdwa v0, v0, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
; VI-SAFE-NEXT:    s_setpc_b64 s[30:31]
;
; VI-NNAN-LABEL: test_fmin_legacy_ule_v2f16:
; VI-NNAN:       ; %bb.0:
; VI-NNAN-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; VI-NNAN-NEXT:    v_min_f16_sdwa v2, v0, v1 dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:WORD_1
; VI-NNAN-NEXT:    v_min_f16_e32 v0, v0, v1
; VI-NNAN-NEXT:    v_or_b32_sdwa v0, v0, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
; VI-NNAN-NEXT:    s_setpc_b64 s[30:31]
;
; SI-SAFE-LABEL: test_fmin_legacy_ule_v2f16:
; SI-SAFE:       ; %bb.0:
; SI-SAFE-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v1, v1
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v3, v3
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v0, v0
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v2, v2
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v1, v1
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v3, v3
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v0, v0
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v2, v2
; SI-SAFE-NEXT:    v_min_legacy_f32_e32 v0, v2, v0
; SI-SAFE-NEXT:    v_min_legacy_f32_e32 v1, v3, v1
; SI-SAFE-NEXT:    s_setpc_b64 s[30:31]
;
; SI-NNAN-LABEL: test_fmin_legacy_ule_v2f16:
; SI-NNAN:       ; %bb.0:
; SI-NNAN-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v3, v3
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v1, v1
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v2, v2
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v0, v0
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v3, v3
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v1, v1
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v2, v2
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v0, v0
; SI-NNAN-NEXT:    v_min_f32_e32 v0, v0, v2
; SI-NNAN-NEXT:    v_min_f32_e32 v1, v1, v3
; SI-NNAN-NEXT:    s_setpc_b64 s[30:31]
  %cmp = fcmp ule <2 x half> %a, %b
  %val = select <2 x i1> %cmp, <2 x half> %a, <2 x half> %b
  ret <2 x half> %val
}

define <3 x half> @test_fmin_legacy_ule_v3f16(<3 x half> %a, <3 x half> %b) #0 {
; GFX9-SAFE-LABEL: test_fmin_legacy_ule_v3f16:
; GFX9-SAFE:       ; %bb.0:
; GFX9-SAFE-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-SAFE-NEXT:    v_lshrrev_b32_e32 v4, 16, v2
; GFX9-SAFE-NEXT:    v_lshrrev_b32_e32 v5, 16, v0
; GFX9-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v5, v4
; GFX9-SAFE-NEXT:    v_cndmask_b32_e32 v4, v4, v5, vcc
; GFX9-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v1, v3
; GFX9-SAFE-NEXT:    v_cndmask_b32_e32 v1, v3, v1, vcc
; GFX9-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v0, v2
; GFX9-SAFE-NEXT:    v_cndmask_b32_e32 v0, v2, v0, vcc
; GFX9-SAFE-NEXT:    v_and_b32_e32 v0, 0xffff, v0
; GFX9-SAFE-NEXT:    v_lshl_or_b32 v0, v4, 16, v0
; GFX9-SAFE-NEXT:    s_setpc_b64 s[30:31]
;
; GFX9-NNAN-LABEL: test_fmin_legacy_ule_v3f16:
; GFX9-NNAN:       ; %bb.0:
; GFX9-NNAN-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NNAN-NEXT:    v_pk_min_f16 v1, v1, v3
; GFX9-NNAN-NEXT:    v_pk_min_f16 v0, v0, v2
; GFX9-NNAN-NEXT:    s_setpc_b64 s[30:31]
;
; VI-SAFE-LABEL: test_fmin_legacy_ule_v3f16:
; VI-SAFE:       ; %bb.0:
; VI-SAFE-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; VI-SAFE-NEXT:    v_lshrrev_b32_e32 v4, 16, v2
; VI-SAFE-NEXT:    v_lshrrev_b32_e32 v5, 16, v0
; VI-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v5, v4
; VI-SAFE-NEXT:    v_cndmask_b32_e32 v4, v4, v5, vcc
; VI-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v1, v3
; VI-SAFE-NEXT:    v_cndmask_b32_e32 v1, v3, v1, vcc
; VI-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v0, v2
; VI-SAFE-NEXT:    v_cndmask_b32_e32 v0, v2, v0, vcc
; VI-SAFE-NEXT:    v_lshlrev_b32_e32 v2, 16, v4
; VI-SAFE-NEXT:    v_or_b32_sdwa v0, v0, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
; VI-SAFE-NEXT:    s_setpc_b64 s[30:31]
;
; VI-NNAN-LABEL: test_fmin_legacy_ule_v3f16:
; VI-NNAN:       ; %bb.0:
; VI-NNAN-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; VI-NNAN-NEXT:    v_min_f16_sdwa v4, v0, v2 dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:WORD_1
; VI-NNAN-NEXT:    v_min_f16_e32 v0, v0, v2
; VI-NNAN-NEXT:    v_min_f16_e32 v1, v1, v3
; VI-NNAN-NEXT:    v_or_b32_sdwa v0, v0, v4 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
; VI-NNAN-NEXT:    s_setpc_b64 s[30:31]
;
; SI-SAFE-LABEL: test_fmin_legacy_ule_v3f16:
; SI-SAFE:       ; %bb.0:
; SI-SAFE-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v2, v2
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v5, v5
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v1, v1
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v4, v4
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v0, v0
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v3, v3
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v2, v2
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v5, v5
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v1, v1
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v4, v4
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v0, v0
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v3, v3
; SI-SAFE-NEXT:    v_min_legacy_f32_e32 v0, v3, v0
; SI-SAFE-NEXT:    v_min_legacy_f32_e32 v1, v4, v1
; SI-SAFE-NEXT:    v_min_legacy_f32_e32 v2, v5, v2
; SI-SAFE-NEXT:    s_setpc_b64 s[30:31]
;
; SI-NNAN-LABEL: test_fmin_legacy_ule_v3f16:
; SI-NNAN:       ; %bb.0:
; SI-NNAN-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v5, v5
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v2, v2
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v4, v4
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v1, v1
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v3, v3
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v0, v0
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v5, v5
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v2, v2
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v4, v4
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v1, v1
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v3, v3
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v0, v0
; SI-NNAN-NEXT:    v_min_f32_e32 v0, v0, v3
; SI-NNAN-NEXT:    v_min_f32_e32 v1, v1, v4
; SI-NNAN-NEXT:    v_min_f32_e32 v2, v2, v5
; SI-NNAN-NEXT:    s_setpc_b64 s[30:31]
  %cmp = fcmp ule <3 x half> %a, %b
  %val = select <3 x i1> %cmp, <3 x half> %a, <3 x half> %b
  ret <3 x half> %val
}

define <4 x half> @test_fmin_legacy_ule_v4f16(<4 x half> %a, <4 x half> %b) #0 {
; GFX9-SAFE-LABEL: test_fmin_legacy_ule_v4f16:
; GFX9-SAFE:       ; %bb.0:
; GFX9-SAFE-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-SAFE-NEXT:    v_lshrrev_b32_e32 v6, 16, v3
; GFX9-SAFE-NEXT:    v_lshrrev_b32_e32 v7, 16, v1
; GFX9-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v7, v6
; GFX9-SAFE-NEXT:    v_lshrrev_b32_e32 v4, 16, v2
; GFX9-SAFE-NEXT:    v_lshrrev_b32_e32 v5, 16, v0
; GFX9-SAFE-NEXT:    v_cndmask_b32_e32 v6, v6, v7, vcc
; GFX9-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v5, v4
; GFX9-SAFE-NEXT:    v_cndmask_b32_e32 v4, v4, v5, vcc
; GFX9-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v1, v3
; GFX9-SAFE-NEXT:    v_cndmask_b32_e32 v1, v3, v1, vcc
; GFX9-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v0, v2
; GFX9-SAFE-NEXT:    v_cndmask_b32_e32 v0, v2, v0, vcc
; GFX9-SAFE-NEXT:    v_mov_b32_e32 v2, 0xffff
; GFX9-SAFE-NEXT:    v_and_b32_e32 v0, v2, v0
; GFX9-SAFE-NEXT:    v_and_b32_e32 v1, v2, v1
; GFX9-SAFE-NEXT:    v_lshl_or_b32 v0, v4, 16, v0
; GFX9-SAFE-NEXT:    v_lshl_or_b32 v1, v6, 16, v1
; GFX9-SAFE-NEXT:    s_setpc_b64 s[30:31]
;
; GFX9-NNAN-LABEL: test_fmin_legacy_ule_v4f16:
; GFX9-NNAN:       ; %bb.0:
; GFX9-NNAN-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NNAN-NEXT:    v_pk_min_f16 v0, v0, v2
; GFX9-NNAN-NEXT:    v_pk_min_f16 v1, v1, v3
; GFX9-NNAN-NEXT:    s_setpc_b64 s[30:31]
;
; VI-SAFE-LABEL: test_fmin_legacy_ule_v4f16:
; VI-SAFE:       ; %bb.0:
; VI-SAFE-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; VI-SAFE-NEXT:    v_lshrrev_b32_e32 v6, 16, v3
; VI-SAFE-NEXT:    v_lshrrev_b32_e32 v7, 16, v1
; VI-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v7, v6
; VI-SAFE-NEXT:    v_lshrrev_b32_e32 v4, 16, v2
; VI-SAFE-NEXT:    v_lshrrev_b32_e32 v5, 16, v0
; VI-SAFE-NEXT:    v_cndmask_b32_e32 v6, v6, v7, vcc
; VI-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v5, v4
; VI-SAFE-NEXT:    v_cndmask_b32_e32 v4, v4, v5, vcc
; VI-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v1, v3
; VI-SAFE-NEXT:    v_cndmask_b32_e32 v1, v3, v1, vcc
; VI-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v0, v2
; VI-SAFE-NEXT:    v_cndmask_b32_e32 v0, v2, v0, vcc
; VI-SAFE-NEXT:    v_lshlrev_b32_e32 v2, 16, v4
; VI-SAFE-NEXT:    v_or_b32_sdwa v0, v0, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
; VI-SAFE-NEXT:    v_lshlrev_b32_e32 v2, 16, v6
; VI-SAFE-NEXT:    v_or_b32_sdwa v1, v1, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
; VI-SAFE-NEXT:    s_setpc_b64 s[30:31]
;
; VI-NNAN-LABEL: test_fmin_legacy_ule_v4f16:
; VI-NNAN:       ; %bb.0:
; VI-NNAN-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; VI-NNAN-NEXT:    v_min_f16_sdwa v4, v1, v3 dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:WORD_1
; VI-NNAN-NEXT:    v_min_f16_e32 v1, v1, v3
; VI-NNAN-NEXT:    v_min_f16_sdwa v5, v0, v2 dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:WORD_1
; VI-NNAN-NEXT:    v_min_f16_e32 v0, v0, v2
; VI-NNAN-NEXT:    v_or_b32_sdwa v0, v0, v5 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
; VI-NNAN-NEXT:    v_or_b32_sdwa v1, v1, v4 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
; VI-NNAN-NEXT:    s_setpc_b64 s[30:31]
;
; SI-SAFE-LABEL: test_fmin_legacy_ule_v4f16:
; SI-SAFE:       ; %bb.0:
; SI-SAFE-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v3, v3
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v7, v7
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v2, v2
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v6, v6
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v1, v1
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v5, v5
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v0, v0
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v4, v4
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v3, v3
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v7, v7
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v2, v2
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v6, v6
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v1, v1
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v5, v5
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v0, v0
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v4, v4
; SI-SAFE-NEXT:    v_min_legacy_f32_e32 v0, v4, v0
; SI-SAFE-NEXT:    v_min_legacy_f32_e32 v1, v5, v1
; SI-SAFE-NEXT:    v_min_legacy_f32_e32 v2, v6, v2
; SI-SAFE-NEXT:    v_min_legacy_f32_e32 v3, v7, v3
; SI-SAFE-NEXT:    s_setpc_b64 s[30:31]
;
; SI-NNAN-LABEL: test_fmin_legacy_ule_v4f16:
; SI-NNAN:       ; %bb.0:
; SI-NNAN-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v7, v7
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v3, v3
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v6, v6
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v2, v2
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v5, v5
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v1, v1
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v4, v4
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v0, v0
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v7, v7
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v3, v3
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v6, v6
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v2, v2
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v5, v5
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v1, v1
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v4, v4
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v0, v0
; SI-NNAN-NEXT:    v_min_f32_e32 v0, v0, v4
; SI-NNAN-NEXT:    v_min_f32_e32 v1, v1, v5
; SI-NNAN-NEXT:    v_min_f32_e32 v2, v2, v6
; SI-NNAN-NEXT:    v_min_f32_e32 v3, v3, v7
; SI-NNAN-NEXT:    s_setpc_b64 s[30:31]
  %cmp = fcmp ule <4 x half> %a, %b
  %val = select <4 x i1> %cmp, <4 x half> %a, <4 x half> %b
  ret <4 x half> %val
}

define <8 x half> @test_fmin_legacy_ule_v8f16(<8 x half> %a, <8 x half> %b) #0 {
; GFX9-SAFE-LABEL: test_fmin_legacy_ule_v8f16:
; GFX9-SAFE:       ; %bb.0:
; GFX9-SAFE-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-SAFE-NEXT:    v_lshrrev_b32_e32 v14, 16, v7
; GFX9-SAFE-NEXT:    v_lshrrev_b32_e32 v15, 16, v3
; GFX9-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v15, v14
; GFX9-SAFE-NEXT:    v_lshrrev_b32_e32 v12, 16, v6
; GFX9-SAFE-NEXT:    v_lshrrev_b32_e32 v13, 16, v2
; GFX9-SAFE-NEXT:    v_cndmask_b32_e32 v14, v14, v15, vcc
; GFX9-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v13, v12
; GFX9-SAFE-NEXT:    v_lshrrev_b32_e32 v10, 16, v5
; GFX9-SAFE-NEXT:    v_lshrrev_b32_e32 v11, 16, v1
; GFX9-SAFE-NEXT:    v_cndmask_b32_e32 v12, v12, v13, vcc
; GFX9-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v11, v10
; GFX9-SAFE-NEXT:    v_lshrrev_b32_e32 v8, 16, v4
; GFX9-SAFE-NEXT:    v_lshrrev_b32_e32 v9, 16, v0
; GFX9-SAFE-NEXT:    v_cndmask_b32_e32 v10, v10, v11, vcc
; GFX9-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v9, v8
; GFX9-SAFE-NEXT:    v_cndmask_b32_e32 v8, v8, v9, vcc
; GFX9-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v3, v7
; GFX9-SAFE-NEXT:    v_cndmask_b32_e32 v3, v7, v3, vcc
; GFX9-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v2, v6
; GFX9-SAFE-NEXT:    v_cndmask_b32_e32 v2, v6, v2, vcc
; GFX9-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v1, v5
; GFX9-SAFE-NEXT:    v_cndmask_b32_e32 v1, v5, v1, vcc
; GFX9-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v0, v4
; GFX9-SAFE-NEXT:    v_cndmask_b32_e32 v0, v4, v0, vcc
; GFX9-SAFE-NEXT:    v_mov_b32_e32 v4, 0xffff
; GFX9-SAFE-NEXT:    v_and_b32_e32 v0, v4, v0
; GFX9-SAFE-NEXT:    v_and_b32_e32 v1, v4, v1
; GFX9-SAFE-NEXT:    v_and_b32_e32 v2, v4, v2
; GFX9-SAFE-NEXT:    v_and_b32_e32 v3, v4, v3
; GFX9-SAFE-NEXT:    v_lshl_or_b32 v0, v8, 16, v0
; GFX9-SAFE-NEXT:    v_lshl_or_b32 v1, v10, 16, v1
; GFX9-SAFE-NEXT:    v_lshl_or_b32 v2, v12, 16, v2
; GFX9-SAFE-NEXT:    v_lshl_or_b32 v3, v14, 16, v3
; GFX9-SAFE-NEXT:    s_setpc_b64 s[30:31]
;
; GFX9-NNAN-LABEL: test_fmin_legacy_ule_v8f16:
; GFX9-NNAN:       ; %bb.0:
; GFX9-NNAN-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NNAN-NEXT:    v_pk_min_f16 v0, v0, v4
; GFX9-NNAN-NEXT:    v_pk_min_f16 v1, v1, v5
; GFX9-NNAN-NEXT:    v_pk_min_f16 v2, v2, v6
; GFX9-NNAN-NEXT:    v_pk_min_f16 v3, v3, v7
; GFX9-NNAN-NEXT:    s_setpc_b64 s[30:31]
;
; VI-SAFE-LABEL: test_fmin_legacy_ule_v8f16:
; VI-SAFE:       ; %bb.0:
; VI-SAFE-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; VI-SAFE-NEXT:    v_lshrrev_b32_e32 v14, 16, v7
; VI-SAFE-NEXT:    v_lshrrev_b32_e32 v15, 16, v3
; VI-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v15, v14
; VI-SAFE-NEXT:    v_lshrrev_b32_e32 v12, 16, v6
; VI-SAFE-NEXT:    v_lshrrev_b32_e32 v13, 16, v2
; VI-SAFE-NEXT:    v_cndmask_b32_e32 v14, v14, v15, vcc
; VI-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v13, v12
; VI-SAFE-NEXT:    v_lshrrev_b32_e32 v10, 16, v5
; VI-SAFE-NEXT:    v_lshrrev_b32_e32 v11, 16, v1
; VI-SAFE-NEXT:    v_cndmask_b32_e32 v12, v12, v13, vcc
; VI-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v11, v10
; VI-SAFE-NEXT:    v_lshrrev_b32_e32 v8, 16, v4
; VI-SAFE-NEXT:    v_lshrrev_b32_e32 v9, 16, v0
; VI-SAFE-NEXT:    v_cndmask_b32_e32 v10, v10, v11, vcc
; VI-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v9, v8
; VI-SAFE-NEXT:    v_cndmask_b32_e32 v8, v8, v9, vcc
; VI-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v3, v7
; VI-SAFE-NEXT:    v_cndmask_b32_e32 v3, v7, v3, vcc
; VI-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v2, v6
; VI-SAFE-NEXT:    v_cndmask_b32_e32 v2, v6, v2, vcc
; VI-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v1, v5
; VI-SAFE-NEXT:    v_cndmask_b32_e32 v1, v5, v1, vcc
; VI-SAFE-NEXT:    v_cmp_ngt_f16_e32 vcc, v0, v4
; VI-SAFE-NEXT:    v_cndmask_b32_e32 v0, v4, v0, vcc
; VI-SAFE-NEXT:    v_lshlrev_b32_e32 v4, 16, v8
; VI-SAFE-NEXT:    v_or_b32_sdwa v0, v0, v4 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
; VI-SAFE-NEXT:    v_lshlrev_b32_e32 v4, 16, v10
; VI-SAFE-NEXT:    v_or_b32_sdwa v1, v1, v4 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
; VI-SAFE-NEXT:    v_lshlrev_b32_e32 v4, 16, v12
; VI-SAFE-NEXT:    v_or_b32_sdwa v2, v2, v4 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
; VI-SAFE-NEXT:    v_lshlrev_b32_e32 v4, 16, v14
; VI-SAFE-NEXT:    v_or_b32_sdwa v3, v3, v4 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
; VI-SAFE-NEXT:    s_setpc_b64 s[30:31]
;
; VI-NNAN-LABEL: test_fmin_legacy_ule_v8f16:
; VI-NNAN:       ; %bb.0:
; VI-NNAN-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; VI-NNAN-NEXT:    v_min_f16_sdwa v8, v3, v7 dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:WORD_1
; VI-NNAN-NEXT:    v_min_f16_e32 v3, v3, v7
; VI-NNAN-NEXT:    v_min_f16_sdwa v9, v2, v6 dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:WORD_1
; VI-NNAN-NEXT:    v_min_f16_e32 v2, v2, v6
; VI-NNAN-NEXT:    v_min_f16_sdwa v10, v1, v5 dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:WORD_1
; VI-NNAN-NEXT:    v_min_f16_e32 v1, v1, v5
; VI-NNAN-NEXT:    v_min_f16_sdwa v11, v0, v4 dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:WORD_1
; VI-NNAN-NEXT:    v_min_f16_e32 v0, v0, v4
; VI-NNAN-NEXT:    v_or_b32_sdwa v0, v0, v11 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
; VI-NNAN-NEXT:    v_or_b32_sdwa v1, v1, v10 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
; VI-NNAN-NEXT:    v_or_b32_sdwa v2, v2, v9 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
; VI-NNAN-NEXT:    v_or_b32_sdwa v3, v3, v8 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
; VI-NNAN-NEXT:    s_setpc_b64 s[30:31]
;
; SI-SAFE-LABEL: test_fmin_legacy_ule_v8f16:
; SI-SAFE:       ; %bb.0:
; SI-SAFE-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v7, v7
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v15, v15
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v6, v6
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v14, v14
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v5, v5
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v13, v13
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v4, v4
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v12, v12
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v3, v3
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v11, v11
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v2, v2
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v10, v10
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v1, v1
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v9, v9
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v0, v0
; SI-SAFE-NEXT:    v_cvt_f16_f32_e32 v8, v8
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v7, v7
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v15, v15
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v6, v6
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v14, v14
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v5, v5
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v13, v13
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v4, v4
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v12, v12
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v3, v3
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v11, v11
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v2, v2
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v10, v10
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v1, v1
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v9, v9
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v0, v0
; SI-SAFE-NEXT:    v_cvt_f32_f16_e32 v8, v8
; SI-SAFE-NEXT:    v_min_legacy_f32_e32 v0, v8, v0
; SI-SAFE-NEXT:    v_min_legacy_f32_e32 v1, v9, v1
; SI-SAFE-NEXT:    v_min_legacy_f32_e32 v2, v10, v2
; SI-SAFE-NEXT:    v_min_legacy_f32_e32 v3, v11, v3
; SI-SAFE-NEXT:    v_min_legacy_f32_e32 v4, v12, v4
; SI-SAFE-NEXT:    v_min_legacy_f32_e32 v5, v13, v5
; SI-SAFE-NEXT:    v_min_legacy_f32_e32 v6, v14, v6
; SI-SAFE-NEXT:    v_min_legacy_f32_e32 v7, v15, v7
; SI-SAFE-NEXT:    s_setpc_b64 s[30:31]
;
; SI-NNAN-LABEL: test_fmin_legacy_ule_v8f16:
; SI-NNAN:       ; %bb.0:
; SI-NNAN-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v15, v15
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v7, v7
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v14, v14
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v6, v6
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v13, v13
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v5, v5
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v12, v12
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v4, v4
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v11, v11
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v3, v3
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v10, v10
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v2, v2
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v9, v9
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v1, v1
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v8, v8
; SI-NNAN-NEXT:    v_cvt_f16_f32_e32 v0, v0
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v15, v15
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v7, v7
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v14, v14
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v6, v6
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v13, v13
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v5, v5
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v12, v12
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v4, v4
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v11, v11
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v3, v3
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v10, v10
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v2, v2
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v9, v9
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v1, v1
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v8, v8
; SI-NNAN-NEXT:    v_cvt_f32_f16_e32 v0, v0
; SI-NNAN-NEXT:    v_min_f32_e32 v0, v0, v8
; SI-NNAN-NEXT:    v_min_f32_e32 v1, v1, v9
; SI-NNAN-NEXT:    v_min_f32_e32 v2, v2, v10
; SI-NNAN-NEXT:    v_min_f32_e32 v3, v3, v11
; SI-NNAN-NEXT:    v_min_f32_e32 v4, v4, v12
; SI-NNAN-NEXT:    v_min_f32_e32 v5, v5, v13
; SI-NNAN-NEXT:    v_min_f32_e32 v6, v6, v14
; SI-NNAN-NEXT:    v_min_f32_e32 v7, v7, v15
; SI-NNAN-NEXT:    s_setpc_b64 s[30:31]
  %cmp = fcmp ule <8 x half> %a, %b
  %val = select <8 x i1> %cmp, <8 x half> %a, <8 x half> %b
  ret <8 x half> %val
}

attributes #0 = { nounwind }
