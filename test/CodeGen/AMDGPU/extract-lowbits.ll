; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -march=amdgcn -mtriple=amdgcn-- -verify-machineinstrs < %s | FileCheck -check-prefix=GCN -check-prefix=SI %s
; RUN: llc -march=amdgcn -mtriple=amdgcn-- -mcpu=tonga -verify-machineinstrs < %s | FileCheck -check-prefix=GCN -check-prefix=VI %s

; Loosely based on test/CodeGen/{X86,AArch64}/extract-lowbits.ll,
; but with all 64-bit tests, and tests with loads dropped.

; Patterns:
;   a) x &  (1 << nbits) - 1
;   b) x & ~(-1 << nbits)
;   c) x &  (-1 >> (32 - y))
;   d) x << (32 - y) >> (32 - y)
; are equivalent.

; ---------------------------------------------------------------------------- ;
; Pattern a. 32-bit
; ---------------------------------------------------------------------------- ;

define i32 @bzhi32_a0(i32 %val, i32 %numlowbits) nounwind {
; SI-LABEL: bzhi32_a0:
; SI:       ; %bb.0:
; SI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SI-NEXT:    v_bfm_b32_e64 v1, v1, 0
; SI-NEXT:    v_and_b32_e32 v0, v1, v0
; SI-NEXT:    s_setpc_b64 s[30:31]
;
; VI-LABEL: bzhi32_a0:
; VI:       ; %bb.0:
; VI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; VI-NEXT:    v_bfm_b32 v1, v1, 0
; VI-NEXT:    v_and_b32_e32 v0, v1, v0
; VI-NEXT:    s_setpc_b64 s[30:31]
  %onebit = shl i32 1, %numlowbits
  %mask = add nsw i32 %onebit, -1
  %masked = and i32 %mask, %val
  ret i32 %masked
}

define i32 @bzhi32_a1_indexzext(i32 %val, i8 zeroext %numlowbits) nounwind {
; SI-LABEL: bzhi32_a1_indexzext:
; SI:       ; %bb.0:
; SI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SI-NEXT:    v_bfm_b32_e64 v1, v1, 0
; SI-NEXT:    v_and_b32_e32 v0, v1, v0
; SI-NEXT:    s_setpc_b64 s[30:31]
;
; VI-LABEL: bzhi32_a1_indexzext:
; VI:       ; %bb.0:
; VI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; VI-NEXT:    v_bfm_b32 v1, v1, 0
; VI-NEXT:    v_and_b32_e32 v0, v1, v0
; VI-NEXT:    s_setpc_b64 s[30:31]
  %conv = zext i8 %numlowbits to i32
  %onebit = shl i32 1, %conv
  %mask = add nsw i32 %onebit, -1
  %masked = and i32 %mask, %val
  ret i32 %masked
}

define i32 @bzhi32_a4_commutative(i32 %val, i32 %numlowbits) nounwind {
; SI-LABEL: bzhi32_a4_commutative:
; SI:       ; %bb.0:
; SI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SI-NEXT:    v_bfm_b32_e64 v1, v1, 0
; SI-NEXT:    v_and_b32_e32 v0, v0, v1
; SI-NEXT:    s_setpc_b64 s[30:31]
;
; VI-LABEL: bzhi32_a4_commutative:
; VI:       ; %bb.0:
; VI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; VI-NEXT:    v_bfm_b32 v1, v1, 0
; VI-NEXT:    v_and_b32_e32 v0, v0, v1
; VI-NEXT:    s_setpc_b64 s[30:31]
  %onebit = shl i32 1, %numlowbits
  %mask = add nsw i32 %onebit, -1
  %masked = and i32 %val, %mask ; swapped order
  ret i32 %masked
}

; ---------------------------------------------------------------------------- ;
; Pattern b. 32-bit
; ---------------------------------------------------------------------------- ;

define i32 @bzhi32_b0(i32 %val, i32 %numlowbits) nounwind {
; SI-LABEL: bzhi32_b0:
; SI:       ; %bb.0:
; SI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SI-NEXT:    v_lshl_b32_e32 v1, -1, v1
; SI-NEXT:    v_not_b32_e32 v1, v1
; SI-NEXT:    v_and_b32_e32 v0, v1, v0
; SI-NEXT:    s_setpc_b64 s[30:31]
;
; VI-LABEL: bzhi32_b0:
; VI:       ; %bb.0:
; VI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; VI-NEXT:    v_lshlrev_b32_e64 v1, v1, -1
; VI-NEXT:    v_not_b32_e32 v1, v1
; VI-NEXT:    v_and_b32_e32 v0, v1, v0
; VI-NEXT:    s_setpc_b64 s[30:31]
  %notmask = shl i32 -1, %numlowbits
  %mask = xor i32 %notmask, -1
  %masked = and i32 %mask, %val
  ret i32 %masked
}

define i32 @bzhi32_b1_indexzext(i32 %val, i8 zeroext %numlowbits) nounwind {
; SI-LABEL: bzhi32_b1_indexzext:
; SI:       ; %bb.0:
; SI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SI-NEXT:    v_lshl_b32_e32 v1, -1, v1
; SI-NEXT:    v_not_b32_e32 v1, v1
; SI-NEXT:    v_and_b32_e32 v0, v1, v0
; SI-NEXT:    s_setpc_b64 s[30:31]
;
; VI-LABEL: bzhi32_b1_indexzext:
; VI:       ; %bb.0:
; VI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; VI-NEXT:    v_lshlrev_b32_e64 v1, v1, -1
; VI-NEXT:    v_not_b32_e32 v1, v1
; VI-NEXT:    v_and_b32_e32 v0, v1, v0
; VI-NEXT:    s_setpc_b64 s[30:31]
  %conv = zext i8 %numlowbits to i32
  %notmask = shl i32 -1, %conv
  %mask = xor i32 %notmask, -1
  %masked = and i32 %mask, %val
  ret i32 %masked
}

define i32 @bzhi32_b4_commutative(i32 %val, i32 %numlowbits) nounwind {
; SI-LABEL: bzhi32_b4_commutative:
; SI:       ; %bb.0:
; SI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SI-NEXT:    v_lshl_b32_e32 v1, -1, v1
; SI-NEXT:    v_not_b32_e32 v1, v1
; SI-NEXT:    v_and_b32_e32 v0, v0, v1
; SI-NEXT:    s_setpc_b64 s[30:31]
;
; VI-LABEL: bzhi32_b4_commutative:
; VI:       ; %bb.0:
; VI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; VI-NEXT:    v_lshlrev_b32_e64 v1, v1, -1
; VI-NEXT:    v_not_b32_e32 v1, v1
; VI-NEXT:    v_and_b32_e32 v0, v0, v1
; VI-NEXT:    s_setpc_b64 s[30:31]
  %notmask = shl i32 -1, %numlowbits
  %mask = xor i32 %notmask, -1
  %masked = and i32 %val, %mask ; swapped order
  ret i32 %masked
}

; ---------------------------------------------------------------------------- ;
; Pattern c. 32-bit
; ---------------------------------------------------------------------------- ;

define i32 @bzhi32_c0(i32 %val, i32 %numlowbits) nounwind {
; SI-LABEL: bzhi32_c0:
; SI:       ; %bb.0:
; SI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SI-NEXT:    v_sub_i32_e32 v1, vcc, 32, v1
; SI-NEXT:    v_lshr_b32_e32 v1, -1, v1
; SI-NEXT:    v_and_b32_e32 v0, v1, v0
; SI-NEXT:    s_setpc_b64 s[30:31]
;
; VI-LABEL: bzhi32_c0:
; VI:       ; %bb.0:
; VI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; VI-NEXT:    v_sub_u32_e32 v1, vcc, 32, v1
; VI-NEXT:    v_lshrrev_b32_e64 v1, v1, -1
; VI-NEXT:    v_and_b32_e32 v0, v1, v0
; VI-NEXT:    s_setpc_b64 s[30:31]
  %numhighbits = sub i32 32, %numlowbits
  %mask = lshr i32 -1, %numhighbits
  %masked = and i32 %mask, %val
  ret i32 %masked
}

define i32 @bzhi32_c1_indexzext(i32 %val, i8 %numlowbits) nounwind {
; SI-LABEL: bzhi32_c1_indexzext:
; SI:       ; %bb.0:
; SI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SI-NEXT:    v_sub_i32_e32 v1, vcc, 32, v1
; SI-NEXT:    v_and_b32_e32 v1, 0xff, v1
; SI-NEXT:    v_lshr_b32_e32 v1, -1, v1
; SI-NEXT:    v_and_b32_e32 v0, v1, v0
; SI-NEXT:    s_setpc_b64 s[30:31]
;
; VI-LABEL: bzhi32_c1_indexzext:
; VI:       ; %bb.0:
; VI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; VI-NEXT:    v_sub_u16_e32 v1, 32, v1
; VI-NEXT:    v_mov_b32_e32 v2, -1
; VI-NEXT:    v_lshrrev_b32_sdwa v1, v1, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
; VI-NEXT:    v_and_b32_e32 v0, v1, v0
; VI-NEXT:    s_setpc_b64 s[30:31]
  %numhighbits = sub i8 32, %numlowbits
  %sh_prom = zext i8 %numhighbits to i32
  %mask = lshr i32 -1, %sh_prom
  %masked = and i32 %mask, %val
  ret i32 %masked
}

define i32 @bzhi32_c4_commutative(i32 %val, i32 %numlowbits) nounwind {
; SI-LABEL: bzhi32_c4_commutative:
; SI:       ; %bb.0:
; SI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SI-NEXT:    v_sub_i32_e32 v1, vcc, 32, v1
; SI-NEXT:    v_lshr_b32_e32 v1, -1, v1
; SI-NEXT:    v_and_b32_e32 v0, v0, v1
; SI-NEXT:    s_setpc_b64 s[30:31]
;
; VI-LABEL: bzhi32_c4_commutative:
; VI:       ; %bb.0:
; VI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; VI-NEXT:    v_sub_u32_e32 v1, vcc, 32, v1
; VI-NEXT:    v_lshrrev_b32_e64 v1, v1, -1
; VI-NEXT:    v_and_b32_e32 v0, v0, v1
; VI-NEXT:    s_setpc_b64 s[30:31]
  %numhighbits = sub i32 32, %numlowbits
  %mask = lshr i32 -1, %numhighbits
  %masked = and i32 %val, %mask ; swapped order
  ret i32 %masked
}

; ---------------------------------------------------------------------------- ;
; Pattern d. 32-bit.
; ---------------------------------------------------------------------------- ;

define i32 @bzhi32_d0(i32 %val, i32 %numlowbits) nounwind {
; GCN-LABEL: bzhi32_d0:
; GCN:       ; %bb.0:
; GCN-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GCN-NEXT:    v_bfe_u32 v0, v0, 0, v1
; GCN-NEXT:    s_setpc_b64 s[30:31]
  %numhighbits = sub i32 32, %numlowbits
  %highbitscleared = shl i32 %val, %numhighbits
  %masked = lshr i32 %highbitscleared, %numhighbits
  ret i32 %masked
}

define i32 @bzhi32_d1_indexzext(i32 %val, i8 %numlowbits) nounwind {
; SI-LABEL: bzhi32_d1_indexzext:
; SI:       ; %bb.0:
; SI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SI-NEXT:    v_sub_i32_e32 v1, vcc, 32, v1
; SI-NEXT:    v_and_b32_e32 v1, 0xff, v1
; SI-NEXT:    v_lshl_b32_e32 v0, v0, v1
; SI-NEXT:    v_lshr_b32_e32 v0, v0, v1
; SI-NEXT:    s_setpc_b64 s[30:31]
;
; VI-LABEL: bzhi32_d1_indexzext:
; VI:       ; %bb.0:
; VI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; VI-NEXT:    v_sub_u16_e32 v1, 32, v1
; VI-NEXT:    v_and_b32_e32 v1, 0xff, v1
; VI-NEXT:    v_lshlrev_b32_e32 v0, v1, v0
; VI-NEXT:    v_lshrrev_b32_e32 v0, v1, v0
; VI-NEXT:    s_setpc_b64 s[30:31]
  %numhighbits = sub i8 32, %numlowbits
  %sh_prom = zext i8 %numhighbits to i32
  %highbitscleared = shl i32 %val, %sh_prom
  %masked = lshr i32 %highbitscleared, %sh_prom
  ret i32 %masked
}
