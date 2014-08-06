; RUN: llc -march=r600 -mcpu=SI -verify-machineinstrs< %s | FileCheck -check-prefix=SI -check-prefix=FUNC %s

; FUNC-LABEL: @extract_vector_elt_v2i16
; SI: BUFFER_LOAD_USHORT
; SI: BUFFER_LOAD_USHORT
; SI: BUFFER_STORE_SHORT
; SI: BUFFER_STORE_SHORT
define void @extract_vector_elt_v2i16(i16 addrspace(1)* %out, <2 x i16> %foo) nounwind {
  %p0 = extractelement <2 x i16> %foo, i32 0
  %p1 = extractelement <2 x i16> %foo, i32 1
  %out1 = getelementptr i16 addrspace(1)* %out, i32 1
  store i16 %p1, i16 addrspace(1)* %out, align 2
  store i16 %p0, i16 addrspace(1)* %out1, align 2
  ret void
}

; FUNC-LABEL: @extract_vector_elt_v4i16
; SI: BUFFER_LOAD_USHORT
; SI: BUFFER_LOAD_USHORT
; SI: BUFFER_STORE_SHORT
; SI: BUFFER_STORE_SHORT
define void @extract_vector_elt_v4i16(i16 addrspace(1)* %out, <4 x i16> %foo) nounwind {
  %p0 = extractelement <4 x i16> %foo, i32 0
  %p1 = extractelement <4 x i16> %foo, i32 2
  %out1 = getelementptr i16 addrspace(1)* %out, i32 1
  store i16 %p1, i16 addrspace(1)* %out, align 2
  store i16 %p0, i16 addrspace(1)* %out1, align 2
  ret void
}
