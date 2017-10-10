; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-linux -mcpu=corei7 | FileCheck %s

; This fixes a missing cases in the MI scheduler's constrainLocalCopy exposed by
; PR21792

@stuff = external constant [256 x double], align 16

define void @func(<4 x float> %vx) {
; CHECK-LABEL: func:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    pushq %rax
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    pand {{.*}}(%rip), %xmm0
; CHECK-NEXT:    pextrq $1, %xmm0, %rdx
; CHECK-NEXT:    movq %rdx, %rcx
; CHECK-NEXT:    shrq $32, %rcx
; CHECK-NEXT:    movq %xmm0, %rax
; CHECK-NEXT:    movq %rax, %r9
; CHECK-NEXT:    shrq $32, %r9
; CHECK-NEXT:    andl $2032, %eax # imm = 0x7F0
; CHECK-NEXT:    leaq stuff(%rax), %rdi
; CHECK-NEXT:    leaq stuff(%r9), %rsi
; CHECK-NEXT:    andl $2032, %edx # imm = 0x7F0
; CHECK-NEXT:    leaq stuff(%rdx), %rdx
; CHECK-NEXT:    leaq stuff(%rcx), %rcx
; CHECK-NEXT:    leaq stuff+8(%rax), %r8
; CHECK-NEXT:    leaq stuff+8(%r9), %r9
; CHECK-NEXT:    callq toto
; CHECK-NEXT:    popq %rax
; CHECK-NEXT:    retq
entry:
  %tmp2 = bitcast <4 x float> %vx to <2 x i64>
  %and.i = and <2 x i64> %tmp2, <i64 8727373547504, i64 8727373547504>
  %tmp3 = bitcast <2 x i64> %and.i to <4 x i32>
  %index.sroa.0.0.vec.extract = extractelement <4 x i32> %tmp3, i32 0
  %idx.ext = sext i32 %index.sroa.0.0.vec.extract to i64
  %add.ptr = getelementptr inbounds i8, i8* bitcast ([256 x double]* @stuff to i8*), i64 %idx.ext
  %tmp4 = bitcast i8* %add.ptr to double*
  %index.sroa.0.4.vec.extract = extractelement <4 x i32> %tmp3, i32 1
  %idx.ext5 = sext i32 %index.sroa.0.4.vec.extract to i64
  %add.ptr6 = getelementptr inbounds i8, i8* bitcast ([256 x double]* @stuff to i8*), i64 %idx.ext5
  %tmp5 = bitcast i8* %add.ptr6 to double*
  %index.sroa.0.8.vec.extract = extractelement <4 x i32> %tmp3, i32 2
  %idx.ext14 = sext i32 %index.sroa.0.8.vec.extract to i64
  %add.ptr15 = getelementptr inbounds i8, i8* bitcast ([256 x double]* @stuff to i8*), i64 %idx.ext14
  %tmp6 = bitcast i8* %add.ptr15 to double*
  %index.sroa.0.12.vec.extract = extractelement <4 x i32> %tmp3, i32 3
  %idx.ext19 = sext i32 %index.sroa.0.12.vec.extract to i64
  %add.ptr20 = getelementptr inbounds i8, i8* bitcast ([256 x double]* @stuff to i8*), i64 %idx.ext19
  %tmp7 = bitcast i8* %add.ptr20 to double*
  %add.ptr46 = getelementptr inbounds i8, i8* bitcast (double* getelementptr inbounds ([256 x double], [256 x double]* @stuff, i64 0, i64 1) to i8*), i64 %idx.ext
  %tmp16 = bitcast i8* %add.ptr46 to double*
  %add.ptr51 = getelementptr inbounds i8, i8* bitcast (double* getelementptr inbounds ([256 x double], [256 x double]* @stuff, i64 0, i64 1) to i8*), i64 %idx.ext5
  %tmp17 = bitcast i8* %add.ptr51 to double*
  call void @toto(double* %tmp4, double* %tmp5, double* %tmp6, double* %tmp7, double* %tmp16, double* %tmp17)
  ret void
}

declare void @toto(double*, double*, double*, double*, double*, double*)
