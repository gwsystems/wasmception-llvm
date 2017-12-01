; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=i386-linux-gnu -mattr=+sse2  -global-isel -verify-machineinstrs < %s -o - | FileCheck %s --check-prefix=ALL --check-prefix=X32
; RUN: llc -mtriple=x86_64-linux-gnu             -global-isel -verify-machineinstrs < %s -o - | FileCheck %s --check-prefix=ALL --check-prefix=X64

define i32 @test_ret_i32() {
; X32-LABEL: test_ret_i32:
; X32:       # BB#0:
; X32-NEXT:    movl $20, %eax
; X32-NEXT:    retl
;
; X64-LABEL: test_ret_i32:
; X64:       # BB#0:
; X64-NEXT:    movl $20, %eax
; X64-NEXT:    retq
  ret i32 20
}

define i64 @test_ret_i64() {
; X32-LABEL: test_ret_i64:
; X32:       # BB#0:
; X32-NEXT:    movl $4294967295, %eax # imm = 0xFFFFFFFF
; X32-NEXT:    movl $15, %edx
; X32-NEXT:    retl
;
; X64-LABEL: test_ret_i64:
; X64:       # BB#0:
; X64-NEXT:    movabsq $68719476735, %rax # imm = 0xFFFFFFFFF
; X64-NEXT:    retq
  ret i64 68719476735
}

define i8 @test_arg_i8(i8 %a) {
; X32-LABEL: test_arg_i8:
; X32:       # BB#0:
; X32-NEXT:    movb 4(%esp), %al
; X32-NEXT:    retl
;
; X64-LABEL: test_arg_i8:
; X64:       # BB#0:
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    retq
  ret i8 %a
}

define i16 @test_arg_i16(i16 %a) {
; X32-LABEL: test_arg_i16:
; X32:       # BB#0:
; X32-NEXT:    movzwl 4(%esp), %eax
; X32-NEXT:    retl
;
; X64-LABEL: test_arg_i16:
; X64:       # BB#0:
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    retq
  ret i16 %a
}

define i32 @test_arg_i32(i32 %a) {
; X32-LABEL: test_arg_i32:
; X32:       # BB#0:
; X32-NEXT:    movl 4(%esp), %eax
; X32-NEXT:    retl
;
; X64-LABEL: test_arg_i32:
; X64:       # BB#0:
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    retq
  ret i32 %a
}

define i64 @test_arg_i64(i64 %a) {
; X32-LABEL: test_arg_i64:
; X32:       # BB#0:
; X32-NEXT:    movl 4(%esp), %eax
; X32-NEXT:    movl 8(%esp), %edx
; X32-NEXT:    retl
;
; X64-LABEL: test_arg_i64:
; X64:       # BB#0:
; X64-NEXT:    movq %rdi, %rax
; X64-NEXT:    retq
  ret i64 %a
}

define i64 @test_i64_args_8(i64 %arg1, i64 %arg2, i64 %arg3, i64 %arg4, i64 %arg5, i64 %arg6, i64 %arg7, i64 %arg8) {
; X32-LABEL: test_i64_args_8:
; X32:       # BB#0:
; X32-NEXT:    movl 60(%esp), %eax
; X32-NEXT:    movl 64(%esp), %edx
; X32-NEXT:    retl
;
; X64-LABEL: test_i64_args_8:
; X64:       # BB#0:
; X64-NEXT:    movq 16(%rsp), %rax
; X64-NEXT:    retq
  ret i64 %arg8
}

define <4 x i32> @test_v4i32_args(<4 x i32> %arg1, <4 x i32> %arg2) {
; X32-LABEL: test_v4i32_args:
; X32:       # BB#0:
; X32-NEXT:    movaps %xmm1, %xmm0
; X32-NEXT:    retl
;
; X64-LABEL: test_v4i32_args:
; X64:       # BB#0:
; X64-NEXT:    movaps %xmm1, %xmm0
; X64-NEXT:    retq
  ret <4 x i32> %arg2
}

define <8 x i32> @test_v8i32_args(<8 x i32> %arg1, <8 x i32> %arg2) {
; X32-LABEL: test_v8i32_args:
; X32:       # BB#0:
; X32-NEXT:    subl $12, %esp
; X32-NEXT:    .cfi_def_cfa_offset 16
; X32-NEXT:    movups 16(%esp), %xmm1
; X32-NEXT:    movaps %xmm2, %xmm0
; X32-NEXT:    addl $12, %esp
; X32-NEXT:    retl
;
; X64-LABEL: test_v8i32_args:
; X64:       # BB#0:
; X64-NEXT:    movaps %xmm2, %xmm0
; X64-NEXT:    movaps %xmm3, %xmm1
; X64-NEXT:    retq
  ret <8 x i32> %arg2
}

declare void @trivial_callee()
define void @test_trivial_call() {
; X32-LABEL: test_trivial_call:
; X32:       # BB#0:
; X32-NEXT:    subl $12, %esp
; X32-NEXT:    .cfi_def_cfa_offset 16
; X32-NEXT:    calll trivial_callee
; X32-NEXT:    addl $12, %esp
; X32-NEXT:    retl
;
; X64-LABEL: test_trivial_call:
; X64:       # BB#0:
; X64-NEXT:    pushq %rax
; X64-NEXT:    .cfi_def_cfa_offset 16
; X64-NEXT:    callq trivial_callee
; X64-NEXT:    popq %rax
; X64-NEXT:    retq
  call void @trivial_callee()
  ret void
}

declare void @simple_arg_callee(i32 %in0, i32 %in1)
define void @test_simple_arg_call(i32 %in0, i32 %in1) {
; X32-LABEL: test_simple_arg_call:
; X32:       # BB#0:
; X32-NEXT:    subl $12, %esp
; X32-NEXT:    .cfi_def_cfa_offset 16
; X32-NEXT:    movl 16(%esp), %eax
; X32-NEXT:    movl 20(%esp), %ecx
; X32-NEXT:    movl %ecx, (%esp)
; X32-NEXT:    movl %eax, 4(%esp)
; X32-NEXT:    calll simple_arg_callee
; X32-NEXT:    addl $12, %esp
; X32-NEXT:    retl
;
; X64-LABEL: test_simple_arg_call:
; X64:       # BB#0:
; X64-NEXT:    pushq %rax
; X64-NEXT:    .cfi_def_cfa_offset 16
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    movl %esi, %edi
; X64-NEXT:    movl %eax, %esi
; X64-NEXT:    callq simple_arg_callee
; X64-NEXT:    popq %rax
; X64-NEXT:    retq
  call void @simple_arg_callee(i32 %in1, i32 %in0)
  ret void
}

declare void @simple_arg8_callee(i32 %arg1, i32 %arg2, i32 %arg3, i32 %arg4, i32 %arg5, i32 %arg6, i32 %arg7, i32 %arg8)
define void @test_simple_arg8_call(i32 %in0) {
; X32-LABEL: test_simple_arg8_call:
; X32:       # BB#0:
; X32-NEXT:    subl $44, %esp
; X32-NEXT:    .cfi_def_cfa_offset 48
; X32-NEXT:    movl 48(%esp), %eax
; X32-NEXT:    movl %eax, (%esp)
; X32-NEXT:    movl %eax, 4(%esp)
; X32-NEXT:    movl %eax, 8(%esp)
; X32-NEXT:    movl %eax, 12(%esp)
; X32-NEXT:    movl %eax, 16(%esp)
; X32-NEXT:    movl %eax, 20(%esp)
; X32-NEXT:    movl %eax, 24(%esp)
; X32-NEXT:    movl %eax, 28(%esp)
; X32-NEXT:    calll simple_arg8_callee
; X32-NEXT:    addl $44, %esp
; X32-NEXT:    retl
;
; X64-LABEL: test_simple_arg8_call:
; X64:       # BB#0:
; X64-NEXT:    subq $24, %rsp
; X64-NEXT:    .cfi_def_cfa_offset 32
; X64-NEXT:    movl %edi, (%rsp)
; X64-NEXT:    movl %edi, 8(%rsp)
; X64-NEXT:    movl %edi, %esi
; X64-NEXT:    movl %edi, %edx
; X64-NEXT:    movl %edi, %ecx
; X64-NEXT:    movl %edi, %r8d
; X64-NEXT:    movl %edi, %r9d
; X64-NEXT:    callq simple_arg8_callee
; X64-NEXT:    addq $24, %rsp
; X64-NEXT:    retq
  call void @simple_arg8_callee(i32 %in0, i32 %in0, i32 %in0, i32 %in0,i32 %in0, i32 %in0, i32 %in0, i32 %in0)
  ret void
}

declare i32 @simple_return_callee(i32 %in0)
define i32 @test_simple_return_callee() {
; X32-LABEL: test_simple_return_callee:
; X32:       # BB#0:
; X32-NEXT:    subl $12, %esp
; X32-NEXT:    .cfi_def_cfa_offset 16
; X32-NEXT:    movl $5, %eax
; X32-NEXT:    movl %eax, (%esp)
; X32-NEXT:    calll simple_return_callee
; X32-NEXT:    addl %eax, %eax
; X32-NEXT:    addl $12, %esp
; X32-NEXT:    retl
;
; X64-LABEL: test_simple_return_callee:
; X64:       # BB#0:
; X64-NEXT:    pushq %rax
; X64-NEXT:    .cfi_def_cfa_offset 16
; X64-NEXT:    movl $5, %edi
; X64-NEXT:    callq simple_return_callee
; X64-NEXT:    addl %eax, %eax
; X64-NEXT:    popq %rcx
; X64-NEXT:    retq
  %call = call i32 @simple_return_callee(i32 5)
  %r = add i32 %call, %call
  ret i32 %r
}

declare <8 x i32> @split_return_callee(<8 x i32> %in0)
define <8 x i32> @test_split_return_callee(<8 x i32> %arg1, <8 x i32> %arg2) {
; X32-LABEL: test_split_return_callee:
; X32:       # BB#0:
; X32-NEXT:    subl $44, %esp
; X32-NEXT:    .cfi_def_cfa_offset 48
; X32-NEXT:    movaps %xmm0, (%esp) # 16-byte Spill
; X32-NEXT:    movaps %xmm1, 16(%esp) # 16-byte Spill
; X32-NEXT:    movdqu 48(%esp), %xmm1
; X32-NEXT:    movdqa %xmm2, %xmm0
; X32-NEXT:    calll split_return_callee
; X32-NEXT:    paddd (%esp), %xmm0 # 16-byte Folded Reload
; X32-NEXT:    paddd 16(%esp), %xmm1 # 16-byte Folded Reload
; X32-NEXT:    addl $44, %esp
; X32-NEXT:    retl
;
; X64-LABEL: test_split_return_callee:
; X64:       # BB#0:
; X64-NEXT:    subq $40, %rsp
; X64-NEXT:    .cfi_def_cfa_offset 48
; X64-NEXT:    movaps %xmm0, (%rsp) # 16-byte Spill
; X64-NEXT:    movaps %xmm1, 16(%rsp) # 16-byte Spill
; X64-NEXT:    movdqa %xmm2, %xmm0
; X64-NEXT:    movdqa %xmm3, %xmm1
; X64-NEXT:    callq split_return_callee
; X64-NEXT:    paddd (%rsp), %xmm0 # 16-byte Folded Reload
; X64-NEXT:    paddd 16(%rsp), %xmm1 # 16-byte Folded Reload
; X64-NEXT:    addq $40, %rsp
; X64-NEXT:    retq
  %call = call <8 x i32> @split_return_callee(<8 x i32> %arg2)
  %r = add <8 x i32> %arg1, %call
  ret  <8 x i32> %r
}

define void @test_indirect_call(void()* %func) {
; X32-LABEL: test_indirect_call:
; X32:       # BB#0:
; X32-NEXT:    subl $12, %esp
; X32-NEXT:    .cfi_def_cfa_offset 16
; X32-NEXT:    calll *16(%esp)
; X32-NEXT:    addl $12, %esp
; X32-NEXT:    retl
;
; X64-LABEL: test_indirect_call:
; X64:       # BB#0:
; X64-NEXT:    pushq %rax
; X64-NEXT:    .cfi_def_cfa_offset 16
; X64-NEXT:    callq *%rdi
; X64-NEXT:    popq %rax
; X64-NEXT:    retq
  call void %func()
  ret void
}

declare void @take_char(i8)
define void @test_abi_exts_call(i8* %addr) {
; X32-LABEL: test_abi_exts_call:
; X32:       # BB#0:
; X32-NEXT:    pushl %ebx
; X32-NEXT:    .cfi_def_cfa_offset 8
; X32-NEXT:    pushl %esi
; X32-NEXT:    .cfi_def_cfa_offset 12
; X32-NEXT:    pushl %eax
; X32-NEXT:    .cfi_def_cfa_offset 16
; X32-NEXT:    .cfi_offset %esi, -12
; X32-NEXT:    .cfi_offset %ebx, -8
; X32-NEXT:    movl 16(%esp), %eax
; X32-NEXT:    movb (%eax), %bl
; X32-NEXT:    movzbl %bl, %esi
; X32-NEXT:    movl %esi, (%esp)
; X32-NEXT:    calll take_char
; X32-NEXT:    movsbl %bl, %eax
; X32-NEXT:    movl %eax, (%esp)
; X32-NEXT:    calll take_char
; X32-NEXT:    movl %esi, (%esp)
; X32-NEXT:    calll take_char
; X32-NEXT:    addl $4, %esp
; X32-NEXT:    popl %esi
; X32-NEXT:    popl %ebx
; X32-NEXT:    retl
;
; X64-LABEL: test_abi_exts_call:
; X64:       # BB#0:
; X64-NEXT:    pushq %rbx
; X64-NEXT:    .cfi_def_cfa_offset 16
; X64-NEXT:    .cfi_offset %rbx, -16
; X64-NEXT:    movb (%rdi), %al
; X64-NEXT:    movzbl %al, %ebx
; X64-NEXT:    movl %ebx, %edi
; X64-NEXT:    callq take_char
; X64-NEXT:    movsbl %bl, %edi
; X64-NEXT:    callq take_char
; X64-NEXT:    movl %ebx, %edi
; X64-NEXT:    callq take_char
; X64-NEXT:    popq %rbx
; X64-NEXT:    retq
  %val = load i8, i8* %addr
  call void @take_char(i8 %val)
  call void @take_char(i8 signext %val)
  call void @take_char(i8 zeroext %val)
 ret void
}

declare void @variadic_callee(i8*, ...)
define void @test_variadic_call_1(i8** %addr_ptr, i32* %val_ptr) {
; X32-LABEL: test_variadic_call_1:
; X32:       # BB#0:
; X32-NEXT:    subl $12, %esp
; X32-NEXT:    .cfi_def_cfa_offset 16
; X32-NEXT:    movl 16(%esp), %eax
; X32-NEXT:    movl 20(%esp), %ecx
; X32-NEXT:    movl (%eax), %eax
; X32-NEXT:    movl (%ecx), %ecx
; X32-NEXT:    movl %eax, (%esp)
; X32-NEXT:    movl %ecx, 4(%esp)
; X32-NEXT:    calll variadic_callee
; X32-NEXT:    addl $12, %esp
; X32-NEXT:    retl
;
; X64-LABEL: test_variadic_call_1:
; X64:       # BB#0:
; X64-NEXT:    pushq %rax
; X64-NEXT:    .cfi_def_cfa_offset 16
; X64-NEXT:    movq (%rdi), %rdi
; X64-NEXT:    movl (%rsi), %esi
; X64-NEXT:    movb $0, %al
; X64-NEXT:    callq variadic_callee
; X64-NEXT:    popq %rax
; X64-NEXT:    retq

  %addr = load i8*, i8** %addr_ptr
  %val = load i32, i32* %val_ptr
  call void (i8*, ...) @variadic_callee(i8* %addr, i32 %val)
  ret void
}

define void @test_variadic_call_2(i8** %addr_ptr, double* %val_ptr) {
; X32-LABEL: test_variadic_call_2:
; X32:       # BB#0:
; X32-NEXT:    subl $12, %esp
; X32-NEXT:    .cfi_def_cfa_offset 16
; X32-NEXT:    movl 16(%esp), %eax
; X32-NEXT:    movl 20(%esp), %ecx
; X32-NEXT:    movl (%eax), %eax
; X32-NEXT:    movl (%ecx), %edx
; X32-NEXT:    movl 4(%ecx), %ecx
; X32-NEXT:    movl %eax, (%esp)
; X32-NEXT:    movl $4, %eax
; X32-NEXT:    addl %esp, %eax
; X32-NEXT:    movl %edx, 4(%esp)
; X32-NEXT:    movl %ecx, 4(%eax)
; X32-NEXT:    calll variadic_callee
; X32-NEXT:    addl $12, %esp
; X32-NEXT:    retl
;
; X64-LABEL: test_variadic_call_2:
; X64:       # BB#0:
; X64-NEXT:    pushq %rax
; X64-NEXT:    .cfi_def_cfa_offset 16
; X64-NEXT:    movq (%rdi), %rdi
; X64-NEXT:    movq (%rsi), %rcx
; X64-NEXT:    movb $1, %al
; X64-NEXT:    movq %rcx, %xmm0
; X64-NEXT:    callq variadic_callee
; X64-NEXT:    popq %rax
; X64-NEXT:    retq

  %addr = load i8*, i8** %addr_ptr
  %val = load double, double* %val_ptr
  call void (i8*, ...) @variadic_callee(i8* %addr, double %val)
  ret void
}
