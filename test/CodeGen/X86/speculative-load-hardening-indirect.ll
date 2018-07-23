; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu -x86-speculative-load-hardening -data-sections | FileCheck %s --check-prefix=X64
;
; FIXME: Add support for 32-bit.

@global_fnptr = external global i32 ()*

@global_blockaddrs = constant [4 x i8*] [
  i8* blockaddress(@test_indirectbr_global, %bb0),
  i8* blockaddress(@test_indirectbr_global, %bb1),
  i8* blockaddress(@test_indirectbr_global, %bb2),
  i8* blockaddress(@test_indirectbr_global, %bb3)
]

define i32 @test_indirect_call(i32 ()** %ptr) nounwind {
; X64-LABEL: test_indirect_call:
; X64:       # %bb.0: # %entry
; X64-NEXT:    pushq %rbx
; X64-NEXT:    movq %rsp, %rbx
; X64-NEXT:    movq $-1, %rax
; X64-NEXT:    sarq $63, %rbx
; X64-NEXT:    orq %rbx, %rdi
; X64-NEXT:    callq *(%rdi)
; X64-NEXT:    shlq $47, %rbx
; X64-NEXT:    orq %rbx, %rsp
; X64-NEXT:    popq %rbx
; X64-NEXT:    retq
entry:
  %fp = load i32 ()*, i32 ()** %ptr
  %v = call i32 %fp()
  ret i32 %v
}

define i32 @test_indirect_tail_call(i32 ()** %ptr) nounwind {
; X64-LABEL: test_indirect_tail_call:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movq %rsp, %rax
; X64-NEXT:    movq $-1, %rcx
; X64-NEXT:    sarq $63, %rax
; X64-NEXT:    movq %rax, %rcx
; X64-NEXT:    shlq $47, %rcx
; X64-NEXT:    orq %rcx, %rsp
; X64-NEXT:    shlq $47, %rax
; X64-NEXT:    orq %rax, %rsp
; X64-NEXT:    jmpq *(%rdi) # TAILCALL
entry:
  %fp = load i32 ()*, i32 ()** %ptr
  %v = tail call i32 %fp()
  ret i32 %v
}

define i32 @test_indirect_call_global() nounwind {
; X64-LABEL: test_indirect_call_global:
; X64:       # %bb.0: # %entry
; X64-NEXT:    pushq %rax
; X64-NEXT:    movq %rsp, %rax
; X64-NEXT:    movq $-1, %rcx
; X64-NEXT:    sarq $63, %rax
; X64-NEXT:    shlq $47, %rax
; X64-NEXT:    orq %rax, %rsp
; X64-NEXT:    callq *{{.*}}(%rip)
; X64-NEXT:    movq %rsp, %rcx
; X64-NEXT:    sarq $63, %rcx
; X64-NEXT:    shlq $47, %rcx
; X64-NEXT:    orq %rcx, %rsp
; X64-NEXT:    popq %rcx
; X64-NEXT:    retq
entry:
  %fp = load i32 ()*, i32 ()** @global_fnptr
  %v = call i32 %fp()
  ret i32 %v
}

define i32 @test_indirect_tail_call_global() nounwind {
; X64-LABEL: test_indirect_tail_call_global:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movq %rsp, %rax
; X64-NEXT:    movq $-1, %rcx
; X64-NEXT:    sarq $63, %rax
; X64-NEXT:    movq %rax, %rcx
; X64-NEXT:    shlq $47, %rcx
; X64-NEXT:    orq %rcx, %rsp
; X64-NEXT:    shlq $47, %rax
; X64-NEXT:    orq %rax, %rsp
; X64-NEXT:    jmpq *{{.*}}(%rip) # TAILCALL
entry:
  %fp = load i32 ()*, i32 ()** @global_fnptr
  %v = tail call i32 %fp()
  ret i32 %v
}

define i32 @test_indirectbr(i8** %ptr) nounwind {
; X64-LABEL: test_indirectbr:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movq %rsp, %rcx
; X64-NEXT:    movq $-1, %rax
; X64-NEXT:    sarq $63, %rcx
; X64-NEXT:    orq %rcx, %rdi
; X64-NEXT:    jmpq *(%rdi)
; X64-NEXT:  .LBB4_1: # %bb0
; X64-NEXT:    movl $2, %eax
; X64-NEXT:    jmp .LBB4_2
; X64-NEXT:  .LBB4_4: # %bb2
; X64-NEXT:    movl $13, %eax
; X64-NEXT:    jmp .LBB4_2
; X64-NEXT:  .LBB4_5: # %bb3
; X64-NEXT:    movl $42, %eax
; X64-NEXT:    jmp .LBB4_2
; X64-NEXT:  .LBB4_3: # %bb1
; X64-NEXT:    movl $7, %eax
; X64-NEXT:  .LBB4_2: # %bb0
; X64-NEXT:    shlq $47, %rcx
; X64-NEXT:    orq %rcx, %rsp
; X64-NEXT:    retq
entry:
  %a = load i8*, i8** %ptr
  indirectbr i8* %a, [ label %bb0, label %bb1, label %bb2, label %bb3 ]

bb0:
  ret i32 2

bb1:
  ret i32 7

bb2:
  ret i32 13

bb3:
  ret i32 42
}

define i32 @test_indirectbr_global(i32 %idx) nounwind {
; X64-LABEL: test_indirectbr_global:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movq %rsp, %rcx
; X64-NEXT:    movq $-1, %rax
; X64-NEXT:    sarq $63, %rcx
; X64-NEXT:    movslq %edi, %rax
; X64-NEXT:    orq %rcx, %rax
; X64-NEXT:    jmpq *global_blockaddrs(,%rax,8)
; X64-NEXT:  .Ltmp0: # Block address taken
; X64-NEXT:  .LBB5_1: # %bb0
; X64-NEXT:    movl $2, %eax
; X64-NEXT:    jmp .LBB5_2
; X64-NEXT:  .Ltmp1: # Block address taken
; X64-NEXT:  .LBB5_4: # %bb2
; X64-NEXT:    movl $13, %eax
; X64-NEXT:    jmp .LBB5_2
; X64-NEXT:  .Ltmp2: # Block address taken
; X64-NEXT:  .LBB5_5: # %bb3
; X64-NEXT:    movl $42, %eax
; X64-NEXT:    jmp .LBB5_2
; X64-NEXT:  .Ltmp3: # Block address taken
; X64-NEXT:  .LBB5_3: # %bb1
; X64-NEXT:    movl $7, %eax
; X64-NEXT:  .LBB5_2: # %bb0
; X64-NEXT:    shlq $47, %rcx
; X64-NEXT:    orq %rcx, %rsp
; X64-NEXT:    retq
entry:
  %ptr = getelementptr [4 x i8*], [4 x i8*]* @global_blockaddrs, i32 0, i32 %idx
  %a = load i8*, i8** %ptr
  indirectbr i8* %a, [ label %bb0, label %bb1, label %bb2, label %bb3 ]

bb0:
  ret i32 2

bb1:
  ret i32 7

bb2:
  ret i32 13

bb3:
  ret i32 42
}

; This function's switch is crafted to trigger jump-table lowering in the x86
; backend so that we can test how the exact jump table lowering behaves.
define i32 @test_switch_jumptable(i32 %idx) nounwind {
; X64-LABEL: test_switch_jumptable:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movq %rsp, %rcx
; X64-NEXT:    movq $-1, %rax
; X64-NEXT:    sarq $63, %rcx
; X64-NEXT:    cmpl $3, %edi
; X64-NEXT:    ja .LBB6_2
; X64-NEXT:  # %bb.1: # %entry
; X64-NEXT:    cmovaq %rax, %rcx
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    orq %rcx, %rax
; X64-NEXT:    jmpq *.LJTI6_0(,%rax,8)
; X64-NEXT:  .LBB6_3: # %bb1
; X64-NEXT:    movl $7, %eax
; X64-NEXT:    jmp .LBB6_4
; X64-NEXT:  .LBB6_2: # %bb0
; X64-NEXT:    cmovbeq %rax, %rcx
; X64-NEXT:    movl $2, %eax
; X64-NEXT:    jmp .LBB6_4
; X64-NEXT:  .LBB6_5: # %bb2
; X64-NEXT:    movl $13, %eax
; X64-NEXT:    jmp .LBB6_4
; X64-NEXT:  .LBB6_6: # %bb3
; X64-NEXT:    movl $42, %eax
; X64-NEXT:    jmp .LBB6_4
; X64-NEXT:  .LBB6_7: # %bb5
; X64-NEXT:    movl $11, %eax
; X64-NEXT:  .LBB6_4: # %bb1
; X64-NEXT:    shlq $47, %rcx
; X64-NEXT:    orq %rcx, %rsp
; X64-NEXT:    retq
entry:
  switch i32 %idx, label %bb0 [
    i32 0, label %bb1
    i32 1, label %bb2
    i32 2, label %bb3
    i32 3, label %bb5
  ]

bb0:
  ret i32 2

bb1:
  ret i32 7

bb2:
  ret i32 13

bb3:
  ret i32 42

bb5:
  ret i32 11
}
