; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-linux-gnu | FileCheck %s --check-prefix=X86
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu | FileCheck %s --check-prefix=X64

declare {i32, i1} @llvm.umul.with.overflow.i32(i32 %a, i32 %b)

define zeroext i1 @a(i32 %x)  nounwind {
; X86-LABEL: a:
; X86:       # BB#0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl $3, %ecx
; X86-NEXT:    mull %ecx
; X86-NEXT:    seto %al
; X86-NEXT:    retl
;
; X64-LABEL: a:
; X64:       # BB#0:
; X64-NEXT:    movl $3, %ecx
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    mull %ecx
; X64-NEXT:    seto %al
; X64-NEXT:    retq
  %res = call {i32, i1} @llvm.umul.with.overflow.i32(i32 %x, i32 3)
  %obil = extractvalue {i32, i1} %res, 1
  ret i1 %obil
}

define i32 @test2(i32 %a, i32 %b) nounwind readnone {
; X86-LABEL: test2:
; X86:       # BB#0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    addl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    addl %eax, %eax
; X86-NEXT:    retl
;
; X64-LABEL: test2:
; X64:       # BB#0: # %entry
; X64-NEXT:    # kill: %edi<def> %edi<kill> %rdi<def>
; X64-NEXT:    addl %esi, %edi
; X64-NEXT:    leal (%rdi,%rdi), %eax
; X64-NEXT:    retq
entry:
	%tmp0 = add i32 %b, %a
	%tmp1 = call { i32, i1 } @llvm.umul.with.overflow.i32(i32 %tmp0, i32 2)
	%tmp2 = extractvalue { i32, i1 } %tmp1, 0
	ret i32 %tmp2
}

define i32 @test3(i32 %a, i32 %b) nounwind readnone {
; X86-LABEL: test3:
; X86:       # BB#0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    addl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl $4, %ecx
; X86-NEXT:    mull %ecx
; X86-NEXT:    retl
;
; X64-LABEL: test3:
; X64:       # BB#0: # %entry
; X64-NEXT:    # kill: %esi<def> %esi<kill> %rsi<def>
; X64-NEXT:    # kill: %edi<def> %edi<kill> %rdi<def>
; X64-NEXT:    leal (%rdi,%rsi), %eax
; X64-NEXT:    movl $4, %ecx
; X64-NEXT:    mull %ecx
; X64-NEXT:    retq
entry:
	%tmp0 = add i32 %b, %a
	%tmp1 = call { i32, i1 } @llvm.umul.with.overflow.i32(i32 %tmp0, i32 4)
	%tmp2 = extractvalue { i32, i1 } %tmp1, 0
	ret i32 %tmp2
}
