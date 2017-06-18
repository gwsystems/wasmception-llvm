; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse4.2 | FileCheck %s

; Widen a v5i16 to v8i16 to do a vector sub and multiple

define void @update(<5 x i16>* %dst, <5 x i16>* %src, i32 %n) nounwind {
; CHECK-LABEL: update:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    movq %rdi, -{{[0-9]+}}(%rsp)
; CHECK-NEXT:    movq %rsi, -{{[0-9]+}}(%rsp)
; CHECK-NEXT:    movl %edx, -{{[0-9]+}}(%rsp)
; CHECK-NEXT:    movq {{.*}}(%rip), %rax
; CHECK-NEXT:    movq %rax, -{{[0-9]+}}(%rsp)
; CHECK-NEXT:    movw $0, -{{[0-9]+}}(%rsp)
; CHECK-NEXT:    movl $0, -{{[0-9]+}}(%rsp)
; CHECK-NEXT:    movdqa {{.*#+}} xmm0 = <271,271,271,271,271,u,u,u>
; CHECK-NEXT:    movdqa {{.*#+}} xmm1 = <2,4,2,2,2,u,u,u>
; CHECK-NEXT:    jmp .LBB0_1
; CHECK-NEXT:    .p2align 4, 0x90
; CHECK-NEXT:  .LBB0_2: # %forbody
; CHECK-NEXT:    # in Loop: Header=BB0_1 Depth=1
; CHECK-NEXT:    movq -{{[0-9]+}}(%rsp), %rax
; CHECK-NEXT:    movslq -{{[0-9]+}}(%rsp), %rcx
; CHECK-NEXT:    shlq $4, %rcx
; CHECK-NEXT:    movq -{{[0-9]+}}(%rsp), %rdx
; CHECK-NEXT:    movdqa (%rdx,%rcx), %xmm2
; CHECK-NEXT:    psubw %xmm0, %xmm2
; CHECK-NEXT:    pmullw %xmm1, %xmm2
; CHECK-NEXT:    pextrw $4, %xmm2, 8(%rax,%rcx)
; CHECK-NEXT:    movq %xmm2, (%rax,%rcx)
; CHECK-NEXT:    incl -{{[0-9]+}}(%rsp)
; CHECK-NEXT:  .LBB0_1: # %forcond
; CHECK-NEXT:    # =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    movl -{{[0-9]+}}(%rsp), %eax
; CHECK-NEXT:    cmpl -{{[0-9]+}}(%rsp), %eax
; CHECK-NEXT:    jl .LBB0_2
; CHECK-NEXT:  # BB#3: # %afterfor
; CHECK-NEXT:    retq
entry:
	%dst.addr = alloca <5 x i16>*
	%src.addr = alloca <5 x i16>*
	%n.addr = alloca i32
	%v = alloca <5 x i16>, align 16
	%i = alloca i32, align 4
	store <5 x i16>* %dst, <5 x i16>** %dst.addr
	store <5 x i16>* %src, <5 x i16>** %src.addr
	store i32 %n, i32* %n.addr
	store <5 x i16> < i16 1, i16 1, i16 1, i16 0, i16 0 >, <5 x i16>* %v
	store i32 0, i32* %i
	br label %forcond

forcond:
	%tmp = load i32, i32* %i
	%tmp1 = load i32, i32* %n.addr
	%cmp = icmp slt i32 %tmp, %tmp1
	br i1 %cmp, label %forbody, label %afterfor

forbody:
	%tmp2 = load i32, i32* %i
	%tmp3 = load <5 x i16>*, <5 x i16>** %dst.addr
	%arrayidx = getelementptr <5 x i16>, <5 x i16>* %tmp3, i32 %tmp2
	%tmp4 = load i32, i32* %i
	%tmp5 = load <5 x i16>*, <5 x i16>** %src.addr
	%arrayidx6 = getelementptr <5 x i16>, <5 x i16>* %tmp5, i32 %tmp4
	%tmp7 = load <5 x i16>, <5 x i16>* %arrayidx6
	%sub = sub <5 x i16> %tmp7, < i16 271, i16 271, i16 271, i16 271, i16 271 >
	%mul = mul <5 x i16> %sub, < i16 2, i16 4, i16 2, i16 2, i16 2 >
	store <5 x i16> %mul, <5 x i16>* %arrayidx
	br label %forinc

forinc:
	%tmp8 = load i32, i32* %i
	%inc = add i32 %tmp8, 1
	store i32 %inc, i32* %i
	br label %forcond

afterfor:
	ret void
}

