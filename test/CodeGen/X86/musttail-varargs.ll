; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -verify-machineinstrs < %s -enable-tail-merge=0 -mtriple=x86_64-linux | FileCheck %s --check-prefix=LINUX
; RUN: llc -verify-machineinstrs < %s -enable-tail-merge=0 -mtriple=x86_64-linux-gnux32 | FileCheck %s --check-prefix=LINUX-X32
; RUN: llc -verify-machineinstrs < %s -enable-tail-merge=0 -mtriple=x86_64-windows | FileCheck %s --check-prefix=WINDOWS
; RUN: llc -verify-machineinstrs < %s -enable-tail-merge=0 -mtriple=i686-windows | FileCheck %s --check-prefix=X86 --check-prefix=X86-NOSSE
; RUN: llc -verify-machineinstrs < %s -enable-tail-merge=0 -mtriple=i686-windows -mattr=+sse2 | FileCheck %s --check-prefix=X86 --check-prefix=X86-SSE

; Test that we actually spill and reload all arguments in the variadic argument
; pack. Doing a normal call will clobber all argument registers, and we will
; spill around it. A simple adjustment should not require any XMM spills.

declare void @llvm.va_start(i8*) nounwind

declare void(i8*, ...)* @get_f(i8* %this)

define void @f_thunk(i8* %this, ...) {
  ; Use va_start so that we exercise the combination.
; LINUX-LABEL: f_thunk:
; LINUX:       # %bb.0:
; LINUX-NEXT:    pushq %rbp
; LINUX-NEXT:    .cfi_def_cfa_offset 16
; LINUX-NEXT:    pushq %r15
; LINUX-NEXT:    .cfi_def_cfa_offset 24
; LINUX-NEXT:    pushq %r14
; LINUX-NEXT:    .cfi_def_cfa_offset 32
; LINUX-NEXT:    pushq %r13
; LINUX-NEXT:    .cfi_def_cfa_offset 40
; LINUX-NEXT:    pushq %r12
; LINUX-NEXT:    .cfi_def_cfa_offset 48
; LINUX-NEXT:    pushq %rbx
; LINUX-NEXT:    .cfi_def_cfa_offset 56
; LINUX-NEXT:    subq $360, %rsp # imm = 0x168
; LINUX-NEXT:    .cfi_def_cfa_offset 416
; LINUX-NEXT:    .cfi_offset %rbx, -56
; LINUX-NEXT:    .cfi_offset %r12, -48
; LINUX-NEXT:    .cfi_offset %r13, -40
; LINUX-NEXT:    .cfi_offset %r14, -32
; LINUX-NEXT:    .cfi_offset %r15, -24
; LINUX-NEXT:    .cfi_offset %rbp, -16
; LINUX-NEXT:    movq %r9, %r15
; LINUX-NEXT:    movq %r8, %r12
; LINUX-NEXT:    movq %rcx, %r13
; LINUX-NEXT:    movq %rdx, %rbp
; LINUX-NEXT:    movq %rsi, %rbx
; LINUX-NEXT:    movq %rdi, %r14
; LINUX-NEXT:    movb %al, {{[0-9]+}}(%rsp) # 1-byte Spill
; LINUX-NEXT:    testb %al, %al
; LINUX-NEXT:    je .LBB0_2
; LINUX-NEXT:  # %bb.1:
; LINUX-NEXT:    movaps %xmm0, {{[0-9]+}}(%rsp)
; LINUX-NEXT:    movaps %xmm1, {{[0-9]+}}(%rsp)
; LINUX-NEXT:    movaps %xmm2, {{[0-9]+}}(%rsp)
; LINUX-NEXT:    movaps %xmm3, {{[0-9]+}}(%rsp)
; LINUX-NEXT:    movaps %xmm4, {{[0-9]+}}(%rsp)
; LINUX-NEXT:    movaps %xmm5, {{[0-9]+}}(%rsp)
; LINUX-NEXT:    movaps %xmm6, {{[0-9]+}}(%rsp)
; LINUX-NEXT:    movaps %xmm7, {{[0-9]+}}(%rsp)
; LINUX-NEXT:  .LBB0_2:
; LINUX-NEXT:    movq %r15, {{[0-9]+}}(%rsp)
; LINUX-NEXT:    movq %r12, {{[0-9]+}}(%rsp)
; LINUX-NEXT:    movq %r13, {{[0-9]+}}(%rsp)
; LINUX-NEXT:    movq %rbp, {{[0-9]+}}(%rsp)
; LINUX-NEXT:    movq %rbx, {{[0-9]+}}(%rsp)
; LINUX-NEXT:    leaq {{[0-9]+}}(%rsp), %rax
; LINUX-NEXT:    movq %rax, {{[0-9]+}}(%rsp)
; LINUX-NEXT:    leaq {{[0-9]+}}(%rsp), %rax
; LINUX-NEXT:    movq %rax, {{[0-9]+}}(%rsp)
; LINUX-NEXT:    movabsq $206158430216, %rax # imm = 0x3000000008
; LINUX-NEXT:    movq %rax, {{[0-9]+}}(%rsp)
; LINUX-NEXT:    movq %r14, %rdi
; LINUX-NEXT:    movaps %xmm7, {{[0-9]+}}(%rsp) # 16-byte Spill
; LINUX-NEXT:    movaps %xmm6, {{[0-9]+}}(%rsp) # 16-byte Spill
; LINUX-NEXT:    movaps %xmm5, {{[0-9]+}}(%rsp) # 16-byte Spill
; LINUX-NEXT:    movaps %xmm4, {{[0-9]+}}(%rsp) # 16-byte Spill
; LINUX-NEXT:    movaps %xmm3, {{[0-9]+}}(%rsp) # 16-byte Spill
; LINUX-NEXT:    movaps %xmm2, {{[0-9]+}}(%rsp) # 16-byte Spill
; LINUX-NEXT:    movaps %xmm1, {{[0-9]+}}(%rsp) # 16-byte Spill
; LINUX-NEXT:    movaps %xmm0, {{[0-9]+}}(%rsp) # 16-byte Spill
; LINUX-NEXT:    callq get_f
; LINUX-NEXT:    movq %rax, %r11
; LINUX-NEXT:    movq %r14, %rdi
; LINUX-NEXT:    movq %rbx, %rsi
; LINUX-NEXT:    movq %rbp, %rdx
; LINUX-NEXT:    movq %r13, %rcx
; LINUX-NEXT:    movq %r12, %r8
; LINUX-NEXT:    movq %r15, %r9
; LINUX-NEXT:    movaps {{[0-9]+}}(%rsp), %xmm0 # 16-byte Reload
; LINUX-NEXT:    movaps {{[0-9]+}}(%rsp), %xmm1 # 16-byte Reload
; LINUX-NEXT:    movaps {{[0-9]+}}(%rsp), %xmm2 # 16-byte Reload
; LINUX-NEXT:    movaps {{[0-9]+}}(%rsp), %xmm3 # 16-byte Reload
; LINUX-NEXT:    movaps {{[0-9]+}}(%rsp), %xmm4 # 16-byte Reload
; LINUX-NEXT:    movaps {{[0-9]+}}(%rsp), %xmm5 # 16-byte Reload
; LINUX-NEXT:    movaps {{[0-9]+}}(%rsp), %xmm6 # 16-byte Reload
; LINUX-NEXT:    movaps {{[0-9]+}}(%rsp), %xmm7 # 16-byte Reload
; LINUX-NEXT:    movb {{[0-9]+}}(%rsp), %al # 1-byte Reload
; LINUX-NEXT:    addq $360, %rsp # imm = 0x168
; LINUX-NEXT:    popq %rbx
; LINUX-NEXT:    popq %r12
; LINUX-NEXT:    popq %r13
; LINUX-NEXT:    popq %r14
; LINUX-NEXT:    popq %r15
; LINUX-NEXT:    popq %rbp
; LINUX-NEXT:    jmpq *%r11 # TAILCALL
;
; LINUX-X32-LABEL: f_thunk:
; LINUX-X32:       # %bb.0:
; LINUX-X32-NEXT:    pushq %rbp
; LINUX-X32-NEXT:    .cfi_def_cfa_offset 16
; LINUX-X32-NEXT:    pushq %r15
; LINUX-X32-NEXT:    .cfi_def_cfa_offset 24
; LINUX-X32-NEXT:    pushq %r14
; LINUX-X32-NEXT:    .cfi_def_cfa_offset 32
; LINUX-X32-NEXT:    pushq %r13
; LINUX-X32-NEXT:    .cfi_def_cfa_offset 40
; LINUX-X32-NEXT:    pushq %r12
; LINUX-X32-NEXT:    .cfi_def_cfa_offset 48
; LINUX-X32-NEXT:    pushq %rbx
; LINUX-X32-NEXT:    .cfi_def_cfa_offset 56
; LINUX-X32-NEXT:    subl $344, %esp # imm = 0x158
; LINUX-X32-NEXT:    .cfi_def_cfa_offset 400
; LINUX-X32-NEXT:    .cfi_offset %rbx, -56
; LINUX-X32-NEXT:    .cfi_offset %r12, -48
; LINUX-X32-NEXT:    .cfi_offset %r13, -40
; LINUX-X32-NEXT:    .cfi_offset %r14, -32
; LINUX-X32-NEXT:    .cfi_offset %r15, -24
; LINUX-X32-NEXT:    .cfi_offset %rbp, -16
; LINUX-X32-NEXT:    movq %r9, %r15
; LINUX-X32-NEXT:    movq %r8, %r12
; LINUX-X32-NEXT:    movq %rcx, %r13
; LINUX-X32-NEXT:    movq %rdx, %rbp
; LINUX-X32-NEXT:    movq %rsi, %rbx
; LINUX-X32-NEXT:    movl %edi, %r14d
; LINUX-X32-NEXT:    movb %al, {{[0-9]+}}(%esp) # 1-byte Spill
; LINUX-X32-NEXT:    testb %al, %al
; LINUX-X32-NEXT:    je .LBB0_2
; LINUX-X32-NEXT:  # %bb.1:
; LINUX-X32-NEXT:    movaps %xmm0, {{[0-9]+}}(%esp)
; LINUX-X32-NEXT:    movaps %xmm1, {{[0-9]+}}(%esp)
; LINUX-X32-NEXT:    movaps %xmm2, {{[0-9]+}}(%esp)
; LINUX-X32-NEXT:    movaps %xmm3, {{[0-9]+}}(%esp)
; LINUX-X32-NEXT:    movaps %xmm4, {{[0-9]+}}(%esp)
; LINUX-X32-NEXT:    movaps %xmm5, {{[0-9]+}}(%esp)
; LINUX-X32-NEXT:    movaps %xmm6, {{[0-9]+}}(%esp)
; LINUX-X32-NEXT:    movaps %xmm7, {{[0-9]+}}(%esp)
; LINUX-X32-NEXT:  .LBB0_2:
; LINUX-X32-NEXT:    movq %r15, {{[0-9]+}}(%esp)
; LINUX-X32-NEXT:    movq %r12, {{[0-9]+}}(%esp)
; LINUX-X32-NEXT:    movq %r13, {{[0-9]+}}(%esp)
; LINUX-X32-NEXT:    movq %rbp, {{[0-9]+}}(%esp)
; LINUX-X32-NEXT:    movq %rbx, {{[0-9]+}}(%esp)
; LINUX-X32-NEXT:    leal {{[0-9]+}}(%rsp), %eax
; LINUX-X32-NEXT:    movl %eax, {{[0-9]+}}(%esp)
; LINUX-X32-NEXT:    leal {{[0-9]+}}(%rsp), %eax
; LINUX-X32-NEXT:    movl %eax, {{[0-9]+}}(%esp)
; LINUX-X32-NEXT:    movabsq $206158430216, %rax # imm = 0x3000000008
; LINUX-X32-NEXT:    movq %rax, {{[0-9]+}}(%esp)
; LINUX-X32-NEXT:    movl %r14d, %edi
; LINUX-X32-NEXT:    movaps %xmm7, {{[0-9]+}}(%esp) # 16-byte Spill
; LINUX-X32-NEXT:    movaps %xmm6, {{[0-9]+}}(%esp) # 16-byte Spill
; LINUX-X32-NEXT:    movaps %xmm5, {{[0-9]+}}(%esp) # 16-byte Spill
; LINUX-X32-NEXT:    movaps %xmm4, {{[0-9]+}}(%esp) # 16-byte Spill
; LINUX-X32-NEXT:    movaps %xmm3, {{[0-9]+}}(%esp) # 16-byte Spill
; LINUX-X32-NEXT:    movaps %xmm2, {{[0-9]+}}(%esp) # 16-byte Spill
; LINUX-X32-NEXT:    movaps %xmm1, {{[0-9]+}}(%esp) # 16-byte Spill
; LINUX-X32-NEXT:    movaps %xmm0, {{[0-9]+}}(%esp) # 16-byte Spill
; LINUX-X32-NEXT:    callq get_f
; LINUX-X32-NEXT:    movl %eax, %r11d
; LINUX-X32-NEXT:    movl %r14d, %edi
; LINUX-X32-NEXT:    movq %rbx, %rsi
; LINUX-X32-NEXT:    movq %rbp, %rdx
; LINUX-X32-NEXT:    movq %r13, %rcx
; LINUX-X32-NEXT:    movq %r12, %r8
; LINUX-X32-NEXT:    movq %r15, %r9
; LINUX-X32-NEXT:    movaps {{[0-9]+}}(%esp), %xmm0 # 16-byte Reload
; LINUX-X32-NEXT:    movaps {{[0-9]+}}(%esp), %xmm1 # 16-byte Reload
; LINUX-X32-NEXT:    movaps {{[0-9]+}}(%esp), %xmm2 # 16-byte Reload
; LINUX-X32-NEXT:    movaps {{[0-9]+}}(%esp), %xmm3 # 16-byte Reload
; LINUX-X32-NEXT:    movaps {{[0-9]+}}(%esp), %xmm4 # 16-byte Reload
; LINUX-X32-NEXT:    movaps {{[0-9]+}}(%esp), %xmm5 # 16-byte Reload
; LINUX-X32-NEXT:    movaps {{[0-9]+}}(%esp), %xmm6 # 16-byte Reload
; LINUX-X32-NEXT:    movaps {{[0-9]+}}(%esp), %xmm7 # 16-byte Reload
; LINUX-X32-NEXT:    movb {{[0-9]+}}(%esp), %al # 1-byte Reload
; LINUX-X32-NEXT:    addl $344, %esp # imm = 0x158
; LINUX-X32-NEXT:    popq %rbx
; LINUX-X32-NEXT:    popq %r12
; LINUX-X32-NEXT:    popq %r13
; LINUX-X32-NEXT:    popq %r14
; LINUX-X32-NEXT:    popq %r15
; LINUX-X32-NEXT:    popq %rbp
; LINUX-X32-NEXT:    jmpq *%r11 # TAILCALL
;
; WINDOWS-LABEL: f_thunk:
; WINDOWS:       # %bb.0:
; WINDOWS-NEXT:    pushq %r14
; WINDOWS-NEXT:    .seh_pushreg 14
; WINDOWS-NEXT:    pushq %rsi
; WINDOWS-NEXT:    .seh_pushreg 6
; WINDOWS-NEXT:    pushq %rdi
; WINDOWS-NEXT:    .seh_pushreg 7
; WINDOWS-NEXT:    pushq %rbp
; WINDOWS-NEXT:    .seh_pushreg 5
; WINDOWS-NEXT:    pushq %rbx
; WINDOWS-NEXT:    .seh_pushreg 3
; WINDOWS-NEXT:    subq $64, %rsp
; WINDOWS-NEXT:    .seh_stackalloc 64
; WINDOWS-NEXT:    .seh_endprologue
; WINDOWS-NEXT:    movl %eax, %r14d
; WINDOWS-NEXT:    movq %r9, %rsi
; WINDOWS-NEXT:    movq %r8, %rdi
; WINDOWS-NEXT:    movq %rdx, %rbx
; WINDOWS-NEXT:    movq %rcx, %rbp
; WINDOWS-NEXT:    movq %rsi, {{[0-9]+}}(%rsp)
; WINDOWS-NEXT:    movq %rdi, {{[0-9]+}}(%rsp)
; WINDOWS-NEXT:    movq %rbx, {{[0-9]+}}(%rsp)
; WINDOWS-NEXT:    leaq {{[0-9]+}}(%rsp), %rax
; WINDOWS-NEXT:    movq %rax, {{[0-9]+}}(%rsp)
; WINDOWS-NEXT:    callq get_f
; WINDOWS-NEXT:    movq %rax, %r10
; WINDOWS-NEXT:    movq %rbp, %rcx
; WINDOWS-NEXT:    movq %rbx, %rdx
; WINDOWS-NEXT:    movq %rdi, %r8
; WINDOWS-NEXT:    movq %rsi, %r9
; WINDOWS-NEXT:    movl %r14d, %eax
; WINDOWS-NEXT:    addq $64, %rsp
; WINDOWS-NEXT:    popq %rbx
; WINDOWS-NEXT:    popq %rbp
; WINDOWS-NEXT:    popq %rdi
; WINDOWS-NEXT:    popq %rsi
; WINDOWS-NEXT:    popq %r14
; WINDOWS-NEXT:    rex64 jmpq *%r10 # TAILCALL
; WINDOWS-NEXT:    .seh_handlerdata
; WINDOWS-NEXT:    .text
; WINDOWS-NEXT:    .seh_endproc
;
; X86-NOSSE-LABEL: f_thunk:
; X86-NOSSE:       # %bb.0:
; X86-NOSSE-NEXT:    pushl %ebp
; X86-NOSSE-NEXT:    movl %esp, %ebp
; X86-NOSSE-NEXT:    pushl %esi
; X86-NOSSE-NEXT:    andl $-16, %esp
; X86-NOSSE-NEXT:    subl $48, %esp
; X86-NOSSE-NEXT:    movl 8(%ebp), %esi
; X86-NOSSE-NEXT:    leal 12(%ebp), %eax
; X86-NOSSE-NEXT:    movl %eax, {{[0-9]+}}(%esp)
; X86-NOSSE-NEXT:    movl %esi, (%esp)
; X86-NOSSE-NEXT:    calll _get_f
; X86-NOSSE-NEXT:    movl %esi, 8(%ebp)
; X86-NOSSE-NEXT:    leal -4(%ebp), %esp
; X86-NOSSE-NEXT:    popl %esi
; X86-NOSSE-NEXT:    popl %ebp
; X86-NOSSE-NEXT:    jmpl *%eax # TAILCALL
;
; X86-SSE-LABEL: f_thunk:
; X86-SSE:       # %bb.0:
; X86-SSE-NEXT:    pushl %ebp
; X86-SSE-NEXT:    movl %esp, %ebp
; X86-SSE-NEXT:    pushl %esi
; X86-SSE-NEXT:    andl $-16, %esp
; X86-SSE-NEXT:    subl $96, %esp
; X86-SSE-NEXT:    movaps %xmm2, {{[0-9]+}}(%esp) # 16-byte Spill
; X86-SSE-NEXT:    movaps %xmm1, {{[0-9]+}}(%esp) # 16-byte Spill
; X86-SSE-NEXT:    movaps %xmm0, {{[0-9]+}}(%esp) # 16-byte Spill
; X86-SSE-NEXT:    movl 8(%ebp), %esi
; X86-SSE-NEXT:    leal 12(%ebp), %eax
; X86-SSE-NEXT:    movl %eax, {{[0-9]+}}(%esp)
; X86-SSE-NEXT:    movl %esi, (%esp)
; X86-SSE-NEXT:    calll _get_f
; X86-SSE-NEXT:    movl %esi, 8(%ebp)
; X86-SSE-NEXT:    movaps {{[0-9]+}}(%esp), %xmm0 # 16-byte Reload
; X86-SSE-NEXT:    movaps {{[0-9]+}}(%esp), %xmm1 # 16-byte Reload
; X86-SSE-NEXT:    movaps {{[0-9]+}}(%esp), %xmm2 # 16-byte Reload
; X86-SSE-NEXT:    leal -4(%ebp), %esp
; X86-SSE-NEXT:    popl %esi
; X86-SSE-NEXT:    popl %ebp
; X86-SSE-NEXT:    jmpl *%eax # TAILCALL
  %ap = alloca [4 x i8*], align 16
  %ap_i8 = bitcast [4 x i8*]* %ap to i8*
  call void @llvm.va_start(i8* %ap_i8)

  %fptr = call void(i8*, ...)*(i8*) @get_f(i8* %this)
  musttail call void (i8*, ...) %fptr(i8* %this, ...)
  ret void
}

; Save and restore 6 GPRs, 8 XMMs, and AL around the call.

; No regparms on normal x86 conventions.

; This thunk shouldn't require any spills and reloads, assuming the register
; allocator knows what it's doing.

define void @g_thunk(i8* %fptr_i8, ...) {
; LINUX-LABEL: g_thunk:
; LINUX:       # %bb.0:
; LINUX-NEXT:    pushq %rax
; LINUX-NEXT:    .cfi_def_cfa_offset 16
; LINUX-NEXT:    popq %r11
; LINUX-NEXT:    jmpq *%rdi # TAILCALL
;
; LINUX-X32-LABEL: g_thunk:
; LINUX-X32:       # %bb.0:
; LINUX-X32-NEXT:    pushq %rax
; LINUX-X32-NEXT:    .cfi_def_cfa_offset 16
; LINUX-X32-NEXT:    movl %edi, %r11d
; LINUX-X32-NEXT:    addl $8, %esp
; LINUX-X32-NEXT:    jmpq *%r11 # TAILCALL
;
; WINDOWS-LABEL: g_thunk:
; WINDOWS:       # %bb.0:
; WINDOWS-NEXT:    subq $40, %rsp
; WINDOWS-NEXT:    .seh_stackalloc 40
; WINDOWS-NEXT:    .seh_endprologue
; WINDOWS-NEXT:    addq $40, %rsp
; WINDOWS-NEXT:    rex64 jmpq *%rcx # TAILCALL
; WINDOWS-NEXT:    .seh_handlerdata
; WINDOWS-NEXT:    .text
; WINDOWS-NEXT:    .seh_endproc
;
; X86-LABEL: g_thunk:
; X86:       # %bb.0:
; X86-NEXT:    pushl %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl %eax, {{[0-9]+}}(%esp)
; X86-NEXT:    popl %ecx
; X86-NEXT:    jmpl *%eax # TAILCALL
  %fptr = bitcast i8* %fptr_i8 to void (i8*, ...)*
  musttail call void (i8*, ...) %fptr(i8* %fptr_i8, ...)
  ret void
}

; Do a simple multi-exit multi-bb test.

%struct.Foo = type { i1, i8*, i8* }

@g = external global i32

define void @h_thunk(%struct.Foo* %this, ...) {
; LINUX-LABEL: h_thunk:
; LINUX:       # %bb.0:
; LINUX-NEXT:    pushq %rax
; LINUX-NEXT:    .cfi_def_cfa_offset 16
; LINUX-NEXT:    cmpb $1, (%rdi)
; LINUX-NEXT:    jne .LBB2_2
; LINUX-NEXT:  # %bb.1: # %then
; LINUX-NEXT:    movq 8(%rdi), %r11
; LINUX-NEXT:    addq $8, %rsp
; LINUX-NEXT:    jmpq *%r11 # TAILCALL
; LINUX-NEXT:  .LBB2_2: # %else
; LINUX-NEXT:    movq 16(%rdi), %r11
; LINUX-NEXT:    movl $42, {{.*}}(%rip)
; LINUX-NEXT:    addq $8, %rsp
; LINUX-NEXT:    jmpq *%r11 # TAILCALL
;
; LINUX-X32-LABEL: h_thunk:
; LINUX-X32:       # %bb.0:
; LINUX-X32-NEXT:    pushq %rax
; LINUX-X32-NEXT:    .cfi_def_cfa_offset 16
; LINUX-X32-NEXT:    cmpb $1, (%edi)
; LINUX-X32-NEXT:    jne .LBB2_2
; LINUX-X32-NEXT:  # %bb.1: # %then
; LINUX-X32-NEXT:    movl 4(%edi), %r11d
; LINUX-X32-NEXT:    addl $8, %esp
; LINUX-X32-NEXT:    jmpq *%r11 # TAILCALL
; LINUX-X32-NEXT:  .LBB2_2: # %else
; LINUX-X32-NEXT:    movl 8(%edi), %r11d
; LINUX-X32-NEXT:    movl $42, {{.*}}(%rip)
; LINUX-X32-NEXT:    addl $8, %esp
; LINUX-X32-NEXT:    jmpq *%r11 # TAILCALL
;
; WINDOWS-LABEL: h_thunk:
; WINDOWS:       # %bb.0:
; WINDOWS-NEXT:    subq $40, %rsp
; WINDOWS-NEXT:    .seh_stackalloc 40
; WINDOWS-NEXT:    .seh_endprologue
; WINDOWS-NEXT:    cmpb $1, (%rcx)
; WINDOWS-NEXT:    jne .LBB2_2
; WINDOWS-NEXT:  # %bb.1: # %then
; WINDOWS-NEXT:    movq 8(%rcx), %r10
; WINDOWS-NEXT:    addq $40, %rsp
; WINDOWS-NEXT:    rex64 jmpq *%r10 # TAILCALL
; WINDOWS-NEXT:  .LBB2_2: # %else
; WINDOWS-NEXT:    movq 16(%rcx), %r10
; WINDOWS-NEXT:    movl $42, {{.*}}(%rip)
; WINDOWS-NEXT:    addq $40, %rsp
; WINDOWS-NEXT:    rex64 jmpq *%r10 # TAILCALL
; WINDOWS-NEXT:    .seh_handlerdata
; WINDOWS-NEXT:    .text
; WINDOWS-NEXT:    .seh_endproc
;
; X86-LABEL: h_thunk:
; X86:       # %bb.0:
; X86-NEXT:    pushl %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    cmpb $1, (%eax)
; X86-NEXT:    jne LBB2_2
; X86-NEXT:  # %bb.1: # %then
; X86-NEXT:    movl 4(%eax), %ecx
; X86-NEXT:    movl %eax, {{[0-9]+}}(%esp)
; X86-NEXT:    popl %eax
; X86-NEXT:    jmpl *%ecx # TAILCALL
; X86-NEXT:  LBB2_2: # %else
; X86-NEXT:    movl 8(%eax), %ecx
; X86-NEXT:    movl $42, _g
; X86-NEXT:    movl %eax, {{[0-9]+}}(%esp)
; X86-NEXT:    popl %eax
; X86-NEXT:    jmpl *%ecx # TAILCALL
  %cond_p = getelementptr %struct.Foo, %struct.Foo* %this, i32 0, i32 0
  %cond = load i1, i1* %cond_p
  br i1 %cond, label %then, label %else

then:
  %a_p = getelementptr %struct.Foo, %struct.Foo* %this, i32 0, i32 1
  %a_i8 = load i8*, i8** %a_p
  %a = bitcast i8* %a_i8 to void (%struct.Foo*, ...)*
  musttail call void (%struct.Foo*, ...) %a(%struct.Foo* %this, ...)
  ret void

else:
  %b_p = getelementptr %struct.Foo, %struct.Foo* %this, i32 0, i32 2
  %b_i8 = load i8*, i8** %b_p
  %b = bitcast i8* %b_i8 to void (%struct.Foo*, ...)*
  store i32 42, i32* @g
  musttail call void (%struct.Foo*, ...) %b(%struct.Foo* %this, ...)
  ret void
}
