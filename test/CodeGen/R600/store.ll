; RUN: llc < %s -march=r600 -mcpu=redwood | FileCheck --check-prefix=EG-CHECK %s
; RUN: llc < %s -march=r600 -mcpu=cayman | FileCheck --check-prefix=CM-CHECK %s
; RUN: llc < %s -march=r600 -mcpu=verde | FileCheck --check-prefix=SI-CHECK %s

;===------------------------------------------------------------------------===;
; Global Address Space
;===------------------------------------------------------------------------===;

; i8 store
; EG-CHECK: @store_i8
; EG-CHECK: MEM_RAT MSKOR T[[RW_GPR:[0-9]]].XW, T{{[0-9]}}.X
; EG-CHECK: VTX_READ_8 [[VAL:T[0-9]\.X]], [[VAL]]
; IG 0: Get the byte index
; EG-CHECK: AND_INT * T{{[0-9]}}.[[BI_CHAN:[XYZW]]], KC0[2].Y, literal.x
; EG-CHECK-NEXT: 3
; IG 1: Truncate the value and calculated the shift amount for the mask
; EG-CHECK: AND_INT T{{[0-9]}}.[[TRUNC_CHAN:[XYZW]]], [[VAL]], literal.x
; EG-CHECK: LSHL * T{{[0-9]}}.[[SHIFT_CHAN:[XYZW]]], PV.[[BI_CHAN]], literal.y
; EG-CHECK: 255(3.573311e-43), 3
; IG 2: Shift the value and the mask
; EG-CHECK: LSHL T[[RW_GPR]].X, PV.[[TRUNC_CHAN]], PV.[[SHIFT_CHAN]]
; EG-CHECK: LSHL * T[[RW_GPR]].W, literal.x, PV.[[SHIFT_CHAN]]
; EG-CHECK-NEXT: 255
; IG 3: Initialize the Y and Z channels to zero
;       XXX: An optimal scheduler should merge this into one of the prevous IGs.
; EG-CHECK: MOV T[[RW_GPR]].Y, 0.0
; EG-CHECK: MOV * T[[RW_GPR]].Z, 0.0

; SI-CHECK: @store_i8
; SI-CHECK: BUFFER_STORE_BYTE

define void @store_i8(i8 addrspace(1)* %out, i8 %in) {
entry:
  store i8 %in, i8 addrspace(1)* %out
  ret void
}

; i16 store
; EG-CHECK: @store_i16
; EG-CHECK: MEM_RAT MSKOR T[[RW_GPR:[0-9]]].XW, T{{[0-9]}}.X
; EG-CHECK: VTX_READ_16 [[VAL:T[0-9]\.X]], [[VAL]]
; IG 0: Get the byte index
; EG-CHECK: AND_INT * T{{[0-9]}}.[[BI_CHAN:[XYZW]]], KC0[2].Y, literal.x
; EG-CHECK-NEXT: 3
; IG 1: Truncate the value and calculated the shift amount for the mask
; EG-CHECK: AND_INT T{{[0-9]}}.[[TRUNC_CHAN:[XYZW]]], [[VAL]], literal.x
; EG-CHECK: LSHL * T{{[0-9]}}.[[SHIFT_CHAN:[XYZW]]], PV.[[BI_CHAN]], literal.y
; EG-CHECK: 65535(9.183409e-41), 3
; IG 2: Shift the value and the mask
; EG-CHECK: LSHL T[[RW_GPR]].X, PV.[[TRUNC_CHAN]], PV.[[SHIFT_CHAN]]
; EG-CHECK: LSHL * T[[RW_GPR]].W, literal.x, PV.[[SHIFT_CHAN]]
; EG-CHECK-NEXT: 65535
; IG 3: Initialize the Y and Z channels to zero
;       XXX: An optimal scheduler should merge this into one of the prevous IGs.
; EG-CHECK: MOV T[[RW_GPR]].Y, 0.0
; EG-CHECK: MOV * T[[RW_GPR]].Z, 0.0

; SI-CHECK: @store_i16
; SI-CHECK: BUFFER_STORE_SHORT
define void @store_i16(i16 addrspace(1)* %out, i16 %in) {
entry:
  store i16 %in, i16 addrspace(1)* %out
  ret void
}

; floating-point store
; EG-CHECK: @store_f32
; EG-CHECK: MEM_RAT_CACHELESS STORE_RAW T{{[0-9]+\.X, T[0-9]+\.X}}, 1
; CM-CHECK: @store_f32
; CM-CHECK: MEM_RAT_CACHELESS STORE_DWORD T{{[0-9]+\.X, T[0-9]+\.X}}
; SI-CHECK: @store_f32
; SI-CHECK: BUFFER_STORE_DWORD

define void @store_f32(float addrspace(1)* %out, float %in) {
  store float %in, float addrspace(1)* %out
  ret void
}

; vec2 floating-point stores
; EG-CHECK: @store_v2f32
; EG-CHECK: MEM_RAT_CACHELESS STORE_RAW
; CM-CHECK: @store_v2f32
; CM-CHECK: MEM_RAT_CACHELESS STORE_DWORD
; SI-CHECK: @store_v2f32
; SI-CHECK: BUFFER_STORE_DWORDX2

define void @store_v2f32(<2 x float> addrspace(1)* %out, float %a, float %b) {
entry:
  %0 = insertelement <2 x float> <float 0.0, float 0.0>, float %a, i32 0
  %1 = insertelement <2 x float> %0, float %b, i32 1
  store <2 x float> %1, <2 x float> addrspace(1)* %out
  ret void
}

; EG-CHECK: @store_v4i32
; EG-CHECK: MEM_RAT_CACHELESS STORE_RAW
; EG-CHECK-NOT: MEM_RAT_CACHELESS STORE_RAW
; CM-CHECK: @store_v4i32
; CM-CHECK: MEM_RAT_CACHELESS STORE_DWORD
; CM-CHECK-NOT: MEM_RAT_CACHELESS STORE_DWORD
; SI-CHECK: @store_v4i32
; SI-CHECK: BUFFER_STORE_DWORDX4
define void @store_v4i32(<4 x i32> addrspace(1)* %out, <4 x i32> %in) {
entry:
  store <4 x i32> %in, <4 x i32> addrspace(1)* %out
  ret void
}

; The stores in this function are combined by the optimizer to create a
; 64-bit store with 32-bit alignment.  This is legal for SI and the legalizer
; should not try to split the 64-bit store back into 2 32-bit stores.
;
; Evergreen / Northern Islands don't support 64-bit stores yet, so there should
; be two 32-bit stores.

; EG-CHECK: @vecload2
; EG-CHECK: MEM_RAT_CACHELESS STORE_RAW
; CM-CHECK: @vecload2
; CM-CHECK: MEM_RAT_CACHELESS STORE_DWORD
; SI-CHECK: @vecload2
; SI-CHECK: BUFFER_STORE_DWORDX2
define void @vecload2(i32 addrspace(1)* nocapture %out, i32 addrspace(2)* nocapture %mem) #0 {
entry:
  %0 = load i32 addrspace(2)* %mem, align 4, !tbaa !5
  %arrayidx1.i = getelementptr inbounds i32 addrspace(2)* %mem, i64 1
  %1 = load i32 addrspace(2)* %arrayidx1.i, align 4, !tbaa !5
  store i32 %0, i32 addrspace(1)* %out, align 4, !tbaa !5
  %arrayidx1 = getelementptr inbounds i32 addrspace(1)* %out, i64 1
  store i32 %1, i32 addrspace(1)* %arrayidx1, align 4, !tbaa !5
  ret void
}

attributes #0 = { nounwind "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-frame-pointer-elim-non-leaf"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }

!5 = metadata !{metadata !"int", metadata !6}
!6 = metadata !{metadata !"omnipotent char", metadata !7}
!7 = metadata !{metadata !"Simple C/C++ TBAA"}
