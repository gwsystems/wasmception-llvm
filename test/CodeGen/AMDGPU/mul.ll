; RUN: llc -march=amdgcn -mcpu=verde -verify-machineinstrs < %s | FileCheck -check-prefix=SI -check-prefix=FUNC %s
; RUN: llc -march=amdgcn -mcpu=tonga -mattr=-flat-for-global -verify-machineinstrs < %s | FileCheck -check-prefix=SI -check-prefix=FUNC %s
; RUN: llc -march=r600 -mcpu=redwood < %s | FileCheck -check-prefix=EG %s -check-prefix=FUNC

; mul24 and mad24 are affected

; FUNC-LABEL: {{^}}test_mul_v2i32:
; EG: MULLO_INT {{\*? *}}T{{[0-9]+\.[XYZW], T[0-9]+\.[XYZW], T[0-9]+\.[XYZW]}}
; EG: MULLO_INT {{\*? *}}T{{[0-9]+\.[XYZW], T[0-9]+\.[XYZW], T[0-9]+\.[XYZW]}}

; SI: v_mul_lo_i32 v{{[0-9]+, v[0-9]+, v[0-9]+}}
; SI: v_mul_lo_i32 v{{[0-9]+, v[0-9]+, v[0-9]+}}

define void @test_mul_v2i32(<2 x i32> addrspace(1)* %out, <2 x i32> addrspace(1)* %in) {
  %b_ptr = getelementptr <2 x i32>, <2 x i32> addrspace(1)* %in, i32 1
  %a = load <2 x i32>, <2 x i32> addrspace(1) * %in
  %b = load <2 x i32>, <2 x i32> addrspace(1) * %b_ptr
  %result = mul <2 x i32> %a, %b
  store <2 x i32> %result, <2 x i32> addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}v_mul_v4i32:
; EG: MULLO_INT {{\*? *}}T{{[0-9]+\.[XYZW], T[0-9]+\.[XYZW], T[0-9]+\.[XYZW]}}
; EG: MULLO_INT {{\*? *}}T{{[0-9]+\.[XYZW], T[0-9]+\.[XYZW], T[0-9]+\.[XYZW]}}
; EG: MULLO_INT {{\*? *}}T{{[0-9]+\.[XYZW], T[0-9]+\.[XYZW], T[0-9]+\.[XYZW]}}
; EG: MULLO_INT {{\*? *}}T{{[0-9]+\.[XYZW], T[0-9]+\.[XYZW], T[0-9]+\.[XYZW]}}

; SI: v_mul_lo_i32 v{{[0-9]+, v[0-9]+, v[0-9]+}}
; SI: v_mul_lo_i32 v{{[0-9]+, v[0-9]+, v[0-9]+}}
; SI: v_mul_lo_i32 v{{[0-9]+, v[0-9]+, v[0-9]+}}
; SI: v_mul_lo_i32 v{{[0-9]+, v[0-9]+, v[0-9]+}}

define void @v_mul_v4i32(<4 x i32> addrspace(1)* %out, <4 x i32> addrspace(1)* %in) {
  %b_ptr = getelementptr <4 x i32>, <4 x i32> addrspace(1)* %in, i32 1
  %a = load <4 x i32>, <4 x i32> addrspace(1) * %in
  %b = load <4 x i32>, <4 x i32> addrspace(1) * %b_ptr
  %result = mul <4 x i32> %a, %b
  store <4 x i32> %result, <4 x i32> addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}s_trunc_i64_mul_to_i32:
; SI: s_load_dword
; SI: s_load_dword
; SI: s_mul_i32
; SI: buffer_store_dword
define void @s_trunc_i64_mul_to_i32(i32 addrspace(1)* %out, i64 %a, i64 %b) {
  %mul = mul i64 %b, %a
  %trunc = trunc i64 %mul to i32
  store i32 %trunc, i32 addrspace(1)* %out, align 8
  ret void
}

; FUNC-LABEL: {{^}}v_trunc_i64_mul_to_i32:
; SI: s_load_dword
; SI: s_load_dword
; SI: v_mul_lo_i32
; SI: buffer_store_dword
define void @v_trunc_i64_mul_to_i32(i32 addrspace(1)* %out, i64 addrspace(1)* %aptr, i64 addrspace(1)* %bptr) nounwind {
  %a = load i64, i64 addrspace(1)* %aptr, align 8
  %b = load i64, i64 addrspace(1)* %bptr, align 8
  %mul = mul i64 %b, %a
  %trunc = trunc i64 %mul to i32
  store i32 %trunc, i32 addrspace(1)* %out, align 8
  ret void
}

; This 64-bit multiply should just use MUL_HI and MUL_LO, since the top
; 32-bits of both arguments are sign bits.
; FUNC-LABEL: {{^}}mul64_sext_c:
; EG-DAG: MULLO_INT
; EG-DAG: MULHI_INT
; SI-DAG: s_mul_i32
; SI-DAG: v_mul_hi_i32
define void @mul64_sext_c(i64 addrspace(1)* %out, i32 %in) {
entry:
  %0 = sext i32 %in to i64
  %1 = mul i64 %0, 80
  store i64 %1, i64 addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}v_mul64_sext_c:
; EG-DAG: MULLO_INT
; EG-DAG: MULHI_INT
; SI-DAG: v_mul_lo_i32
; SI-DAG: v_mul_hi_i32
; SI: s_endpgm
define void @v_mul64_sext_c(i64 addrspace(1)* %out, i32 addrspace(1)* %in) {
  %val = load i32, i32 addrspace(1)* %in, align 4
  %ext = sext i32 %val to i64
  %mul = mul i64 %ext, 80
  store i64 %mul, i64 addrspace(1)* %out, align 8
  ret void
}

; FUNC-LABEL: {{^}}v_mul64_sext_inline_imm:
; SI-DAG: v_mul_lo_i32 v{{[0-9]+}}, v{{[0-9]+}}, 9
; SI-DAG: v_mul_hi_i32 v{{[0-9]+}}, v{{[0-9]+}}, 9
; SI: s_endpgm
define void @v_mul64_sext_inline_imm(i64 addrspace(1)* %out, i32 addrspace(1)* %in) {
  %val = load i32, i32 addrspace(1)* %in, align 4
  %ext = sext i32 %val to i64
  %mul = mul i64 %ext, 9
  store i64 %mul, i64 addrspace(1)* %out, align 8
  ret void
}

; FUNC-LABEL: {{^}}s_mul_i32:
; SI: s_load_dword [[SRC0:s[0-9]+]],
; SI: s_load_dword [[SRC1:s[0-9]+]],
; SI: s_mul_i32 [[SRESULT:s[0-9]+]], [[SRC0]], [[SRC1]]
; SI: v_mov_b32_e32 [[VRESULT:v[0-9]+]], [[SRESULT]]
; SI: buffer_store_dword [[VRESULT]],
; SI: s_endpgm
define void @s_mul_i32(i32 addrspace(1)* %out, i32 %a, i32 %b) nounwind {
  %mul = mul i32 %a, %b
  store i32 %mul, i32 addrspace(1)* %out, align 4
  ret void
}

; FUNC-LABEL: {{^}}v_mul_i32:
; SI: v_mul_lo_i32 v{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
define void @v_mul_i32(i32 addrspace(1)* %out, i32 addrspace(1)* %in) {
  %b_ptr = getelementptr i32, i32 addrspace(1)* %in, i32 1
  %a = load i32, i32 addrspace(1)* %in
  %b = load i32, i32 addrspace(1)* %b_ptr
  %result = mul i32 %a, %b
  store i32 %result, i32 addrspace(1)* %out
  ret void
}

; A standard 64-bit multiply.  The expansion should be around 6 instructions.
; It would be difficult to match the expansion correctly without writing
; a really complicated list of FileCheck expressions.  I don't want
; to confuse people who may 'break' this test with a correct optimization,
; so this test just uses FUNC-LABEL to make sure the compiler does not
; crash with a 'failed to select' error.

; FUNC-LABEL: {{^}}s_mul_i64:
define void @s_mul_i64(i64 addrspace(1)* %out, i64 %a, i64 %b) nounwind {
  %mul = mul i64 %a, %b
  store i64 %mul, i64 addrspace(1)* %out, align 8
  ret void
}

; FUNC-LABEL: {{^}}v_mul_i64:
; SI: v_mul_lo_i32
define void @v_mul_i64(i64 addrspace(1)* %out, i64 addrspace(1)* %aptr, i64 addrspace(1)* %bptr) {
  %a = load i64, i64 addrspace(1)* %aptr, align 8
  %b = load i64, i64 addrspace(1)* %bptr, align 8
  %mul = mul i64 %a, %b
  store i64 %mul, i64 addrspace(1)* %out, align 8
  ret void
}

; FUNC-LABEL: {{^}}mul32_in_branch:
; SI: s_mul_i32
define void @mul32_in_branch(i32 addrspace(1)* %out, i32 addrspace(1)* %in, i32 %a, i32 %b, i32 %c) {
entry:
  %0 = icmp eq i32 %a, 0
  br i1 %0, label %if, label %else

if:
  %1 = load i32, i32 addrspace(1)* %in
  br label %endif

else:
  %2 = mul i32 %a, %b
  br label %endif

endif:
  %3 = phi i32 [%1, %if], [%2, %else]
  store i32 %3, i32 addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}mul64_in_branch:
; SI-DAG: s_mul_i32
; SI-DAG: v_mul_hi_u32
; SI: s_endpgm
define void @mul64_in_branch(i64 addrspace(1)* %out, i64 addrspace(1)* %in, i64 %a, i64 %b, i64 %c) {
entry:
  %0 = icmp eq i64 %a, 0
  br i1 %0, label %if, label %else

if:
  %1 = load i64, i64 addrspace(1)* %in
  br label %endif

else:
  %2 = mul i64 %a, %b
  br label %endif

endif:
  %3 = phi i64 [%1, %if], [%2, %else]
  store i64 %3, i64 addrspace(1)* %out
  ret void
}

; FIXME: Load dwordx4
; FUNC-LABEL: {{^}}s_mul_i128:
; SI: s_load_dwordx2
; SI: s_load_dwordx2
; SI: s_load_dwordx2
; SI: s_load_dwordx2

; SI: v_mul_hi_u32
; SI: v_mul_hi_u32
; SI: s_mul_i32
; SI: v_mul_hi_u32
; SI: s_mul_i32
; SI: s_mul_i32
; SI: v_mul_hi_u32
; SI: v_mul_hi_u32
; SI: s_mul_i32
; SI-DAG: s_mul_i32
; SI-DAG: v_mul_hi_u32
; SI: s_mul_i32
; SI: s_mul_i32
; SI: s_mul_i32
; SI: s_mul_i32
; SI: s_mul_i32

; SI: buffer_store_dwordx4
define void @s_mul_i128(i128 addrspace(1)* %out, i128 %a, i128 %b) nounwind #0 {
  %mul = mul i128 %a, %b
  store i128 %mul, i128 addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}v_mul_i128:
; SI: {{buffer|flat}}_load_dwordx4
; SI: {{buffer|flat}}_load_dwordx4

; SI: v_mul_lo_i32
; SI: v_mul_hi_u32
; SI: v_mul_hi_u32
; SI: v_mul_lo_i32
; SI: v_mul_hi_u32
; SI: v_mul_hi_u32
; SI: v_mul_lo_i32
; SI: v_mul_lo_i32
; SI: v_add_i32_e32
; SI: v_mul_hi_u32
; SI: v_mul_lo_i32
; SI: v_mul_hi_u32
; SI: v_mul_lo_i32
; SI: v_mul_lo_i32
; SI: v_mul_lo_i32
; SI: v_mul_lo_i32
; SI: v_mul_lo_i32

; SI: {{buffer|flat}}_store_dwordx4
define void @v_mul_i128(i128 addrspace(1)* %out, i128 addrspace(1)* %aptr, i128 addrspace(1)* %bptr) #0 {
  %tid = call i32 @llvm.r600.read.tidig.x()
  %gep.a = getelementptr inbounds i128, i128 addrspace(1)* %aptr, i32 %tid
  %gep.b = getelementptr inbounds i128, i128 addrspace(1)* %bptr, i32 %tid
  %gep.out = getelementptr inbounds i128, i128 addrspace(1)* %bptr, i32 %tid
  %a = load i128, i128 addrspace(1)* %gep.a
  %b = load i128, i128 addrspace(1)* %gep.b
  %mul = mul i128 %a, %b
  store i128 %mul, i128 addrspace(1)* %gep.out
  ret void
}

declare i32 @llvm.r600.read.tidig.x() #1

attributes #0 = { nounwind }
attributes #1 = { nounwind readnone}
