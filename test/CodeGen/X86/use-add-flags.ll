; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-linux | FileCheck %s --check-prefix=LNX
; RUN: llc < %s -mtriple=x86_64-win32 | FileCheck %s --check-prefix=WIN

; Reuse the flags value from the add instructions instead of emitting separate
; testl instructions.

; Use the flags on the add.

define i32 @test1(i32* %x, i32 %y, i32 %a, i32 %b) nounwind {
; LNX-LABEL: test1:
; LNX:       # BB#0:
; LNX-NEXT:    addl (%rdi), %esi
; LNX-NEXT:    cmovnsl %ecx, %edx
; LNX-NEXT:    movl %edx, %eax
; LNX-NEXT:    retq
;
; WIN-LABEL: test1:
; WIN:       # BB#0:
; WIN-NEXT:    addl (%rcx), %edx
; WIN-NEXT:    cmovnsl %r9d, %r8d
; WIN-NEXT:    movl %r8d, %eax
; WIN-NEXT:    retq
	%tmp2 = load i32, i32* %x, align 4		; <i32> [#uses=1]
	%tmp4 = add i32 %tmp2, %y		; <i32> [#uses=1]
	%tmp5 = icmp slt i32 %tmp4, 0		; <i1> [#uses=1]
	%tmp.0 = select i1 %tmp5, i32 %a, i32 %b		; <i32> [#uses=1]
	ret i32 %tmp.0
}

declare void @foo(i32)

; Don't use the flags result of the and here, since the and has no
; other use. A simple test is better.

define void @test2(i32 %x) nounwind {
; LNX-LABEL: test2:
; LNX:       # BB#0:
; LNX-NEXT:    testb $16, %dil
; LNX-NEXT:    jne .LBB1_2
; LNX-NEXT:  # BB#1: # %true
; LNX-NEXT:    pushq %rax
; LNX-NEXT:    callq foo
; LNX-NEXT:    popq %rax
; LNX-NEXT:  .LBB1_2: # %false
; LNX-NEXT:    retq
;
; WIN-LABEL: test2:
; WIN:       # BB#0:
; WIN-NEXT:    subq $40, %rsp
; WIN-NEXT:    testb $16, %cl
; WIN-NEXT:    jne .LBB1_2
; WIN-NEXT:  # BB#1: # %true
; WIN-NEXT:    callq foo
; WIN-NEXT:  .LBB1_2: # %false
; WIN-NEXT:    addq $40, %rsp
; WIN-NEXT:    retq
  %y = and i32 %x, 16
  %t = icmp eq i32 %y, 0
  br i1 %t, label %true, label %false
true:
  call void @foo(i32 %x)
  ret void
false:
  ret void
}

; Do use the flags result of the and here, since the and has another use.

define void @test3(i32 %x) nounwind {
; LNX-LABEL: test3:
; LNX:       # BB#0:
; LNX-NEXT:    andl $16, %edi
; LNX-NEXT:    jne .LBB2_2
; LNX-NEXT:  # BB#1: # %true
; LNX-NEXT:    pushq %rax
; LNX-NEXT:    callq foo
; LNX-NEXT:    popq %rax
; LNX-NEXT:  .LBB2_2: # %false
; LNX-NEXT:    retq
;
; WIN-LABEL: test3:
; WIN:       # BB#0:
; WIN-NEXT:    subq $40, %rsp
; WIN-NEXT:    andl $16, %ecx
; WIN-NEXT:    jne .LBB2_2
; WIN-NEXT:  # BB#1: # %true
; WIN-NEXT:    callq foo
; WIN-NEXT:  .LBB2_2: # %false
; WIN-NEXT:    addq $40, %rsp
; WIN-NEXT:    retq
  %y = and i32 %x, 16
  %t = icmp eq i32 %y, 0
  br i1 %t, label %true, label %false
true:
  call void @foo(i32 %y)
  ret void
false:
  ret void
}

