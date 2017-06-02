; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -march=x86    | FileCheck %s -check-prefix=X32
; RUN: llc < %s -march=x86-64 | FileCheck %s -check-prefix=X64
; rdar://7367229

define i32 @t(i32 %a, i32 %b) nounwind ssp {
; X32-LABEL: t:
; X32:       # BB#0: # %entry
; X32-NEXT:    movb {{[0-9]+}}(%esp), %al
; X32-NEXT:    xorb {{[0-9]+}}(%esp), %al
; X32-NEXT:    testb $64, %al
; X32-NEXT:    je .LBB0_1
; X32-NEXT:  # BB#2: # %bb1
; X32-NEXT:    jmp bar # TAILCALL
; X32-NEXT:  .LBB0_1: # %bb
; X32-NEXT:    jmp foo # TAILCALL
;
; X64-LABEL: t:
; X64:       # BB#0: # %entry
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    xorl %esi, %eax
; X64-NEXT:    testb $64, %ah
; X64-NEXT:    je .LBB0_1
; X64-NEXT:  # BB#2: # %bb1
; X64-NEXT:    xorl %eax, %eax
; X64-NEXT:    jmp bar # TAILCALL
; X64-NEXT:  .LBB0_1: # %bb
; X64-NEXT:    xorl %eax, %eax
; X64-NEXT:    jmp foo # TAILCALL
entry:

  %0 = and i32 %a, 16384
  %1 = icmp ne i32 %0, 0
  %2 = and i32 %b, 16384
  %3 = icmp ne i32 %2, 0
  %4 = xor i1 %1, %3
  br i1 %4, label %bb1, label %bb

bb:                                               ; preds = %entry
  %5 = tail call i32 (...) @foo() nounwind       ; <i32> [#uses=1]
  ret i32 %5

bb1:                                              ; preds = %entry
  %6 = tail call i32 (...) @bar() nounwind       ; <i32> [#uses=1]
  ret i32 %6
}

declare i32 @foo(...)

declare i32 @bar(...)

define i32 @t2(i32 %x, i32 %y) nounwind ssp {
; X32-LABEL: t2:
; X32:       # BB#0: # %entry
; X32-NEXT:    cmpl $0, {{[0-9]+}}(%esp)
; X32-NEXT:    sete %al
; X32-NEXT:    cmpl $0, {{[0-9]+}}(%esp)
; X32-NEXT:    sete %cl
; X32-NEXT:    cmpb %al, %cl
; X32-NEXT:    je .LBB1_1
; X32-NEXT:  # BB#2: # %bb
; X32-NEXT:    jmp foo # TAILCALL
; X32-NEXT:  .LBB1_1: # %return
; X32-NEXT:    retl
;
; X64-LABEL: t2:
; X64:       # BB#0: # %entry
; X64-NEXT:    testl %edi, %edi
; X64-NEXT:    sete %al
; X64-NEXT:    testl %esi, %esi
; X64-NEXT:    sete %cl
; X64-NEXT:    cmpb %al, %cl
; X64-NEXT:    je .LBB1_1
; X64-NEXT:  # BB#2: # %bb
; X64-NEXT:    xorl %eax, %eax
; X64-NEXT:    jmp foo # TAILCALL
; X64-NEXT:  .LBB1_1: # %return
; X64-NEXT:    retq

entry:
  %0 = icmp eq i32 %x, 0                          ; <i1> [#uses=1]
  %1 = icmp eq i32 %y, 0                          ; <i1> [#uses=1]
  %2 = xor i1 %1, %0                              ; <i1> [#uses=1]
  br i1 %2, label %bb, label %return

bb:                                               ; preds = %entry
  %3 = tail call i32 (...) @foo() nounwind       ; <i32> [#uses=0]
  ret i32 undef

return:                                           ; preds = %entry
  ret i32 undef
}
