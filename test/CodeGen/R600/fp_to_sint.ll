; RUN: llc < %s -march=r600 -mcpu=redwood | FileCheck %s --check-prefix=R600-CHECK
; RUN: llc < %s -march=r600 -mcpu=SI | FileCheck %s --check-prefix=SI-CHECK

; R600-CHECK: @fp_to_sint_v4i32
; R600-CHECK: FLT_TO_INT {{[* ]*}}T{{[0-9]+\.[XYZW], PV\.[XYZW]}}
; R600-CHECK: FLT_TO_INT {{[* ]*}}T{{[0-9]+\.[XYZW], PV\.[XYZW]}}
; R600-CHECK: FLT_TO_INT {{[* ]*}}T{{[0-9]+\.[XYZW], PV\.[XYZW]}}
; R600-CHECK: FLT_TO_INT {{[* ]*}}T{{[0-9]+\.[XYZW], PV\.[XYZW]}}
; SI-CHECK: @fp_to_sint_v4i32
; SI-CHECK: V_CVT_I32_F32_e32
; SI-CHECK: V_CVT_I32_F32_e32
; SI-CHECK: V_CVT_I32_F32_e32
; SI-CHECK: V_CVT_I32_F32_e32

define void @fp_to_sint_v4i32(<4 x i32> addrspace(1)* %out, <4 x float> addrspace(1)* %in) {
  %value = load <4 x float> addrspace(1) * %in
  %result = fptosi <4 x float> %value to <4 x i32>
  store <4 x i32> %result, <4 x i32> addrspace(1)* %out
  ret void
}
