; XFAIL: *
; This will fail until i64 add is enabled

; RUN: llc < %s -march=r600 -mcpu=SI | FileCheck --check-prefix=SI %s


declare i32 @llvm.SI.tid() readnone

; SI-LABEL: @test_i64_vreg:
define void @test_i64_vreg(i64 addrspace(1)* noalias %out, i64 addrspace(1)* noalias %inA, i64 addrspace(1)* noalias %inB) {
  %tid = call i32 @llvm.SI.tid() readnone
  %a_ptr = getelementptr i64 addrspace(1)* %inA, i32 %tid
  %b_ptr = getelementptr i64 addrspace(1)* %inB, i32 %tid
  %a = load i64 addrspace(1)* %a_ptr
  %b = load i64 addrspace(1)* %b_ptr
  %result = add i64 %a, %b
  store i64 %result, i64 addrspace(1)* %out
  ret void
}

; SI-LABEL: @one_sgpr:
define void @one_sgpr(i64 addrspace(1)* noalias %out, i64 addrspace(1)* noalias %in, i64 addrspace(1)* noalias %in_bar, i64 %a) {
  %foo = load i64 addrspace(1)* %in, align 8
  %result = add i64 %foo, %a
  store i64 %result, i64 addrspace(1)* %out
  ret void
}

; FIXME: This case is broken
;
; Swap the arguments. Check that the SGPR -> VGPR copy works with the
; SGPR as other operand.
;
; XXXSI-LABEL: @one_sgpr_reversed:
; define void @one_sgpr_reversed(i64 addrspace(1)* noalias %out, i64 addrspace(1)* noalias %in, i64 %a) {
;   %foo = load i64 addrspace(1)* %in, align 8
;   %result = add i64 %a, %foo
;   store i64 %result, i64 addrspace(1)* %out
;   ret void
; }


; SI-LABEL: @test_v2i64_sreg:
define void @test_v2i64_sreg(<2 x i64> addrspace(1)* noalias %out, <2 x i64> %a, <2 x i64> %b) {
  %result = add <2 x i64> %a, %b
  store <2 x i64> %result, <2 x i64> addrspace(1)* %out
  ret void
}

; SI-LABEL: @test_v2i64_vreg:
define void @test_v2i64_vreg(<2 x i64> addrspace(1)* noalias %out, <2 x i64> addrspace(1)* noalias %inA, <2 x i64> addrspace(1)* noalias %inB) {
  %tid = call i32 @llvm.SI.tid() readnone
  %a_ptr = getelementptr <2 x i64> addrspace(1)* %inA, i32 %tid
  %b_ptr = getelementptr <2 x i64> addrspace(1)* %inB, i32 %tid
  %a = load <2 x i64> addrspace(1)* %a_ptr
  %b = load <2 x i64> addrspace(1)* %b_ptr
  %result = add <2 x i64> %a, %b
  store <2 x i64> %result, <2 x i64> addrspace(1)* %out
  ret void
}
