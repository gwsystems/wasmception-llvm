; RUN: llc -march=r600 -mcpu=SI -verify-machineinstrs < %s | FileCheck -check-prefix=SI -check-prefix=FUNC %s

declare i64 @llvm.ctpop.i64(i64) nounwind readnone
declare <2 x i64> @llvm.ctpop.v2i64(<2 x i64>) nounwind readnone
declare <4 x i64> @llvm.ctpop.v4i64(<4 x i64>) nounwind readnone
declare <8 x i64> @llvm.ctpop.v8i64(<8 x i64>) nounwind readnone
declare <16 x i64> @llvm.ctpop.v16i64(<16 x i64>) nounwind readnone

; FUNC-LABEL: @s_ctpop_i64:
; SI: S_LOAD_DWORDX2 [[SVAL:s\[[0-9]+:[0-9]+\]]],
; SI: S_BCNT1_I32_B64 [[SRESULT:s[0-9]+]], [[SVAL]]
; SI: V_MOV_B32_e32 [[VRESULT:v[0-9]+]], [[SRESULT]]
; SI: BUFFER_STORE_DWORD [[VRESULT]],
; SI: S_ENDPGM
define void @s_ctpop_i64(i32 addrspace(1)* noalias %out, i64 %val) nounwind {
  %ctpop = call i64 @llvm.ctpop.i64(i64 %val) nounwind readnone
  %truncctpop = trunc i64 %ctpop to i32
  store i32 %truncctpop, i32 addrspace(1)* %out, align 4
  ret void
}

; FUNC-LABEL: @v_ctpop_i64:
; SI: BUFFER_LOAD_DWORDX2 v{{\[}}[[LOVAL:[0-9]+]]:[[HIVAL:[0-9]+]]{{\]}},
; SI: V_MOV_B32_e32 [[VZERO:v[0-9]+]], 0
; SI: V_BCNT_U32_B32_e32 [[MIDRESULT:v[0-9]+]], v[[LOVAL]], [[VZERO]]
; SI-NEXT: V_BCNT_U32_B32_e32 [[RESULT:v[0-9]+]], v[[HIVAL]], [[MIDRESULT]]
; SI: BUFFER_STORE_DWORD [[RESULT]],
; SI: S_ENDPGM
define void @v_ctpop_i64(i32 addrspace(1)* noalias %out, i64 addrspace(1)* noalias %in) nounwind {
  %val = load i64 addrspace(1)* %in, align 8
  %ctpop = call i64 @llvm.ctpop.i64(i64 %val) nounwind readnone
  %truncctpop = trunc i64 %ctpop to i32
  store i32 %truncctpop, i32 addrspace(1)* %out, align 4
  ret void
}

; FUNC-LABEL: @s_ctpop_v2i64:
; SI: S_BCNT1_I32_B64
; SI: S_BCNT1_I32_B64
; SI: S_ENDPGM
define void @s_ctpop_v2i64(<2 x i32> addrspace(1)* noalias %out, <2 x i64> %val) nounwind {
  %ctpop = call <2 x i64> @llvm.ctpop.v2i64(<2 x i64> %val) nounwind readnone
  %truncctpop = trunc <2 x i64> %ctpop to <2 x i32>
  store <2 x i32> %truncctpop, <2 x i32> addrspace(1)* %out, align 8
  ret void
}

; FUNC-LABEL: @s_ctpop_v4i64:
; SI: S_BCNT1_I32_B64
; SI: S_BCNT1_I32_B64
; SI: S_BCNT1_I32_B64
; SI: S_BCNT1_I32_B64
; SI: S_ENDPGM
define void @s_ctpop_v4i64(<4 x i32> addrspace(1)* noalias %out, <4 x i64> %val) nounwind {
  %ctpop = call <4 x i64> @llvm.ctpop.v4i64(<4 x i64> %val) nounwind readnone
  %truncctpop = trunc <4 x i64> %ctpop to <4 x i32>
  store <4 x i32> %truncctpop, <4 x i32> addrspace(1)* %out, align 16
  ret void
}

; FUNC-LABEL: @v_ctpop_v2i64:
; SI: V_BCNT_U32_B32
; SI: V_BCNT_U32_B32
; SI: V_BCNT_U32_B32
; SI: V_BCNT_U32_B32
; SI: S_ENDPGM
define void @v_ctpop_v2i64(<2 x i32> addrspace(1)* noalias %out, <2 x i64> addrspace(1)* noalias %in) nounwind {
  %val = load <2 x i64> addrspace(1)* %in, align 16
  %ctpop = call <2 x i64> @llvm.ctpop.v2i64(<2 x i64> %val) nounwind readnone
  %truncctpop = trunc <2 x i64> %ctpop to <2 x i32>
  store <2 x i32> %truncctpop, <2 x i32> addrspace(1)* %out, align 8
  ret void
}

; FUNC-LABEL: @v_ctpop_v4i64:
; SI: V_BCNT_U32_B32
; SI: V_BCNT_U32_B32
; SI: V_BCNT_U32_B32
; SI: V_BCNT_U32_B32
; SI: V_BCNT_U32_B32
; SI: V_BCNT_U32_B32
; SI: V_BCNT_U32_B32
; SI: V_BCNT_U32_B32
; SI: S_ENDPGM
define void @v_ctpop_v4i64(<4 x i32> addrspace(1)* noalias %out, <4 x i64> addrspace(1)* noalias %in) nounwind {
  %val = load <4 x i64> addrspace(1)* %in, align 32
  %ctpop = call <4 x i64> @llvm.ctpop.v4i64(<4 x i64> %val) nounwind readnone
  %truncctpop = trunc <4 x i64> %ctpop to <4 x i32>
  store <4 x i32> %truncctpop, <4 x i32> addrspace(1)* %out, align 16
  ret void
}
