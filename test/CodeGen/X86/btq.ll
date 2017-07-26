; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown | FileCheck %s

declare void @bar()

define void @test1(i64 %foo) nounwind {
; CHECK-LABEL: test1:
; CHECK:       # BB#0:
; CHECK-NEXT:    btq $32, %rdi
; CHECK-NEXT:    jb .LBB0_2
; CHECK-NEXT:  # BB#1: # %if.end
; CHECK-NEXT:    retq
; CHECK-NEXT:  .LBB0_2: # %if.then
; CHECK-NEXT:    jmp bar # TAILCALL
  %and = and i64 %foo, 4294967296
  %tobool = icmp eq i64 %and, 0
  br i1 %tobool, label %if.end, label %if.then

if.then:
  tail call void @bar() nounwind
  br label %if.end

if.end:
  ret void
}

define void @test2(i64 %foo) nounwind {
; CHECK-LABEL: test2:
; CHECK:       # BB#0:
; CHECK-NEXT:    testl $-2147483648, %edi # imm = 0x80000000
; CHECK-NEXT:    jne .LBB1_2
; CHECK-NEXT:  # BB#1: # %if.end
; CHECK-NEXT:    retq
; CHECK-NEXT:  .LBB1_2: # %if.then
; CHECK-NEXT:    jmp bar # TAILCALL
  %and = and i64 %foo, 2147483648
  %tobool = icmp eq i64 %and, 0
  br i1 %tobool, label %if.end, label %if.then

if.then:
  tail call void @bar() nounwind
  br label %if.end

if.end:
  ret void
}
