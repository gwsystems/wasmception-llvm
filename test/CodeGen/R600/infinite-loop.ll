; RUN: llc -march=r600 -mcpu=SI -verify-machineinstrs < %s | FileCheck -check-prefix=SI %s

; SI-LABEL: @infinite_loop:
; SI: V_MOV_B32_e32 [[REG:v[0-9]+]], 999
; SI: BB0_1:
; SI: BUFFER_STORE_DWORD [[REG]]
; SI: S_WAITCNT vmcnt(0) expcnt(0)
; SI: S_BRANCH BB0_1
define void @infinite_loop(i32 addrspace(1)* %out) {
entry:
  br label %for.body

for.body:                                         ; preds = %entry, %for.body
  store i32 999, i32 addrspace(1)* %out, align 4
  br label %for.body
}

