; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-- | FileCheck %s --check-prefix=CHECK --check-prefix=FASTINCDEC
; RUN: llc < %s -mtriple=x86_64-- -mattr=slow-incdec | FileCheck %s --check-prefix=CHECK --check-prefix=SLOWINCDEC

define i32 @test_add_1_cmov_slt(i64* %p, i32 %a0, i32 %a1) #0 {
; FASTINCDEC-LABEL: test_add_1_cmov_slt:
; FASTINCDEC:       # %bb.0: # %entry
; FASTINCDEC-NEXT:    movl %esi, %eax
; FASTINCDEC-NEXT:    lock incq (%rdi)
; FASTINCDEC-NEXT:    cmovgl %edx, %eax
; FASTINCDEC-NEXT:    retq
;
; SLOWINCDEC-LABEL: test_add_1_cmov_slt:
; SLOWINCDEC:       # %bb.0: # %entry
; SLOWINCDEC-NEXT:    movl %esi, %eax
; SLOWINCDEC-NEXT:    lock addq $1, (%rdi)
; SLOWINCDEC-NEXT:    cmovgl %edx, %eax
; SLOWINCDEC-NEXT:    retq
entry:
  %tmp0 = atomicrmw add i64* %p, i64 1 seq_cst
  %tmp1 = icmp slt i64 %tmp0, 0
  %tmp2 = select i1 %tmp1, i32 %a0, i32 %a1
  ret i32 %tmp2
}

define i32 @test_add_1_cmov_sge(i64* %p, i32 %a0, i32 %a1) #0 {
; FASTINCDEC-LABEL: test_add_1_cmov_sge:
; FASTINCDEC:       # %bb.0: # %entry
; FASTINCDEC-NEXT:    movl %esi, %eax
; FASTINCDEC-NEXT:    lock incq (%rdi)
; FASTINCDEC-NEXT:    cmovlel %edx, %eax
; FASTINCDEC-NEXT:    retq
;
; SLOWINCDEC-LABEL: test_add_1_cmov_sge:
; SLOWINCDEC:       # %bb.0: # %entry
; SLOWINCDEC-NEXT:    movl %esi, %eax
; SLOWINCDEC-NEXT:    lock addq $1, (%rdi)
; SLOWINCDEC-NEXT:    cmovlel %edx, %eax
; SLOWINCDEC-NEXT:    retq
entry:
  %tmp0 = atomicrmw add i64* %p, i64 1 seq_cst
  %tmp1 = icmp sge i64 %tmp0, 0
  %tmp2 = select i1 %tmp1, i32 %a0, i32 %a1
  ret i32 %tmp2
}

define i32 @test_sub_1_cmov_sle(i64* %p, i32 %a0, i32 %a1) #0 {
; FASTINCDEC-LABEL: test_sub_1_cmov_sle:
; FASTINCDEC:       # %bb.0: # %entry
; FASTINCDEC-NEXT:    movl %esi, %eax
; FASTINCDEC-NEXT:    lock decq (%rdi)
; FASTINCDEC-NEXT:    cmovgel %edx, %eax
; FASTINCDEC-NEXT:    retq
;
; SLOWINCDEC-LABEL: test_sub_1_cmov_sle:
; SLOWINCDEC:       # %bb.0: # %entry
; SLOWINCDEC-NEXT:    movl %esi, %eax
; SLOWINCDEC-NEXT:    lock addq $-1, (%rdi)
; SLOWINCDEC-NEXT:    cmovgel %edx, %eax
; SLOWINCDEC-NEXT:    retq
entry:
  %tmp0 = atomicrmw sub i64* %p, i64 1 seq_cst
  %tmp1 = icmp sle i64 %tmp0, 0
  %tmp2 = select i1 %tmp1, i32 %a0, i32 %a1
  ret i32 %tmp2
}

define i32 @test_sub_1_cmov_sgt(i64* %p, i32 %a0, i32 %a1) #0 {
; FASTINCDEC-LABEL: test_sub_1_cmov_sgt:
; FASTINCDEC:       # %bb.0: # %entry
; FASTINCDEC-NEXT:    movl %esi, %eax
; FASTINCDEC-NEXT:    lock decq (%rdi)
; FASTINCDEC-NEXT:    cmovll %edx, %eax
; FASTINCDEC-NEXT:    retq
;
; SLOWINCDEC-LABEL: test_sub_1_cmov_sgt:
; SLOWINCDEC:       # %bb.0: # %entry
; SLOWINCDEC-NEXT:    movl %esi, %eax
; SLOWINCDEC-NEXT:    lock addq $-1, (%rdi)
; SLOWINCDEC-NEXT:    cmovll %edx, %eax
; SLOWINCDEC-NEXT:    retq
entry:
  %tmp0 = atomicrmw sub i64* %p, i64 1 seq_cst
  %tmp1 = icmp sgt i64 %tmp0, 0
  %tmp2 = select i1 %tmp1, i32 %a0, i32 %a1
  ret i32 %tmp2
}

; FIXME: (setcc slt x, 0) gets combined into shr early.
define i8 @test_add_1_setcc_slt(i64* %p) #0 {
; CHECK-LABEL: test_add_1_setcc_slt:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movl $1, %eax
; CHECK-NEXT:    lock xaddq %rax, (%rdi)
; CHECK-NEXT:    shrq $63, %rax
; CHECK-NEXT:    # kill: def $al killed $al killed $rax
; CHECK-NEXT:    retq
entry:
  %tmp0 = atomicrmw add i64* %p, i64 1 seq_cst
  %tmp1 = icmp slt i64 %tmp0, 0
  %tmp2 = zext i1 %tmp1 to i8
  ret i8 %tmp2
}

define i8 @test_sub_1_setcc_sgt(i64* %p) #0 {
; FASTINCDEC-LABEL: test_sub_1_setcc_sgt:
; FASTINCDEC:       # %bb.0: # %entry
; FASTINCDEC-NEXT:    lock decq (%rdi)
; FASTINCDEC-NEXT:    setge %al
; FASTINCDEC-NEXT:    retq
;
; SLOWINCDEC-LABEL: test_sub_1_setcc_sgt:
; SLOWINCDEC:       # %bb.0: # %entry
; SLOWINCDEC-NEXT:    lock addq $-1, (%rdi)
; SLOWINCDEC-NEXT:    setge %al
; SLOWINCDEC-NEXT:    retq
entry:
  %tmp0 = atomicrmw sub i64* %p, i64 1 seq_cst
  %tmp1 = icmp sgt i64 %tmp0, 0
  %tmp2 = zext i1 %tmp1 to i8
  ret i8 %tmp2
}

define i32 @test_add_1_brcond_sge(i64* %p, i32 %a0, i32 %a1) #0 {
; FASTINCDEC-LABEL: test_add_1_brcond_sge:
; FASTINCDEC:       # %bb.0: # %entry
; FASTINCDEC-NEXT:    lock incq (%rdi)
; FASTINCDEC-NEXT:    jle .LBB6_2
; FASTINCDEC-NEXT:  # %bb.1: # %t
; FASTINCDEC-NEXT:    movl %esi, %eax
; FASTINCDEC-NEXT:    retq
; FASTINCDEC-NEXT:  .LBB6_2: # %f
; FASTINCDEC-NEXT:    movl %edx, %eax
; FASTINCDEC-NEXT:    retq
;
; SLOWINCDEC-LABEL: test_add_1_brcond_sge:
; SLOWINCDEC:       # %bb.0: # %entry
; SLOWINCDEC-NEXT:    lock addq $1, (%rdi)
; SLOWINCDEC-NEXT:    jle .LBB6_2
; SLOWINCDEC-NEXT:  # %bb.1: # %t
; SLOWINCDEC-NEXT:    movl %esi, %eax
; SLOWINCDEC-NEXT:    retq
; SLOWINCDEC-NEXT:  .LBB6_2: # %f
; SLOWINCDEC-NEXT:    movl %edx, %eax
; SLOWINCDEC-NEXT:    retq
entry:
  %tmp0 = atomicrmw add i64* %p, i64 1 seq_cst
  %tmp1 = icmp sge i64 %tmp0, 0
  br i1 %tmp1, label %t, label %f
t:
  ret i32 %a0
f:
  ret i32 %a1
}

; Also make sure we don't muck with condition codes that we should ignore.
; No need to test unsigned comparisons, as they should all be simplified.

define i32 @test_add_1_cmov_sle(i64* %p, i32 %a0, i32 %a1) #0 {
; CHECK-LABEL: test_add_1_cmov_sle:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movl %esi, %eax
; CHECK-NEXT:    movl $1, %ecx
; CHECK-NEXT:    lock xaddq %rcx, (%rdi)
; CHECK-NEXT:    testq %rcx, %rcx
; CHECK-NEXT:    cmovgl %edx, %eax
; CHECK-NEXT:    retq
entry:
  %tmp0 = atomicrmw add i64* %p, i64 1 seq_cst
  %tmp1 = icmp sle i64 %tmp0, 0
  %tmp2 = select i1 %tmp1, i32 %a0, i32 %a1
  ret i32 %tmp2
}

define i32 @test_add_1_cmov_sgt(i64* %p, i32 %a0, i32 %a1) #0 {
; CHECK-LABEL: test_add_1_cmov_sgt:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movl %esi, %eax
; CHECK-NEXT:    movl $1, %ecx
; CHECK-NEXT:    lock xaddq %rcx, (%rdi)
; CHECK-NEXT:    testq %rcx, %rcx
; CHECK-NEXT:    cmovlel %edx, %eax
; CHECK-NEXT:    retq
entry:
  %tmp0 = atomicrmw add i64* %p, i64 1 seq_cst
  %tmp1 = icmp sgt i64 %tmp0, 0
  %tmp2 = select i1 %tmp1, i32 %a0, i32 %a1
  ret i32 %tmp2
}

; Test a result being used by more than just the comparison.

define i8 @test_add_1_setcc_sgt_reuse(i64* %p, i64* %p2) #0 {
; CHECK-LABEL: test_add_1_setcc_sgt_reuse:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movl $1, %ecx
; CHECK-NEXT:    lock xaddq %rcx, (%rdi)
; CHECK-NEXT:    testq %rcx, %rcx
; CHECK-NEXT:    setg %al
; CHECK-NEXT:    movq %rcx, (%rsi)
; CHECK-NEXT:    retq
entry:
  %tmp0 = atomicrmw add i64* %p, i64 1 seq_cst
  %tmp1 = icmp sgt i64 %tmp0, 0
  %tmp2 = zext i1 %tmp1 to i8
  store i64 %tmp0, i64* %p2
  ret i8 %tmp2
}

define i8 @test_sub_2_setcc_sgt(i64* %p) #0 {
; CHECK-LABEL: test_sub_2_setcc_sgt:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movq $-2, %rax
; CHECK-NEXT:    lock xaddq %rax, (%rdi)
; CHECK-NEXT:    testq %rax, %rax
; CHECK-NEXT:    setg %al
; CHECK-NEXT:    retq
entry:
  %tmp0 = atomicrmw sub i64* %p, i64 2 seq_cst
  %tmp1 = icmp sgt i64 %tmp0, 0
  %tmp2 = zext i1 %tmp1 to i8
  ret i8 %tmp2
}

define i8 @test_add_1_cmov_cmov(i64* %p, i8* %q) #0 {
; TODO: It's possible to use "lock inc" here, but both cmovs need to be updated.
; CHECK-LABEL: test_add_1_cmov_cmov:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movl $1, %eax
; CHECK-NEXT:    lock xaddq %rax, (%rdi)
; CHECK-NEXT:    testq   %rax, %rax
entry:
  %add = atomicrmw add i64* %p, i64 1 seq_cst
  %cmp = icmp slt i64 %add, 0
  %s1 = select i1 %cmp, i8 12, i8 34
  store i8 %s1, i8* %q
  %s2 = select i1 %cmp, i8 56, i8 78
  ret i8 %s2
}

define i8 @test_sub_1_cmp_1_setcc_eq(i64* %p) #0 {
; FASTINCDEC-LABEL: test_sub_1_cmp_1_setcc_eq:
; FASTINCDEC:       # %bb.0: # %entry
; FASTINCDEC-NEXT:    lock decq (%rdi)
; FASTINCDEC-NEXT:    sete %al
; FASTINCDEC-NEXT:    retq
;
; SLOWINCDEC-LABEL: test_sub_1_cmp_1_setcc_eq:
; SLOWINCDEC:       # %bb.0: # %entry
; SLOWINCDEC-NEXT:    lock subq $1, (%rdi)
; SLOWINCDEC-NEXT:    sete %al
; SLOWINCDEC-NEXT:    retq
entry:
  %tmp0 = atomicrmw sub i64* %p, i64 1 seq_cst
  %tmp1 = icmp eq i64 %tmp0, 1
  %tmp2 = zext i1 %tmp1 to i8
  ret i8 %tmp2
}

define i8 @test_sub_1_cmp_1_setcc_ne(i64* %p) #0 {
; FASTINCDEC-LABEL: test_sub_1_cmp_1_setcc_ne:
; FASTINCDEC:       # %bb.0: # %entry
; FASTINCDEC-NEXT:    lock decq (%rdi)
; FASTINCDEC-NEXT:    setne %al
; FASTINCDEC-NEXT:    retq
;
; SLOWINCDEC-LABEL: test_sub_1_cmp_1_setcc_ne:
; SLOWINCDEC:       # %bb.0: # %entry
; SLOWINCDEC-NEXT:    lock subq $1, (%rdi)
; SLOWINCDEC-NEXT:    setne %al
; SLOWINCDEC-NEXT:    retq
entry:
  %tmp0 = atomicrmw sub i64* %p, i64 1 seq_cst
  %tmp1 = icmp ne i64 %tmp0, 1
  %tmp2 = zext i1 %tmp1 to i8
  ret i8 %tmp2
}

define i8 @test_sub_1_cmp_1_setcc_ugt(i64* %p) #0 {
; CHECK-LABEL: test_sub_1_cmp_1_setcc_ugt:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lock subq $1, (%rdi)
; CHECK-NEXT:    seta %al
; CHECK-NEXT:    retq
entry:
  %tmp0 = atomicrmw sub i64* %p, i64 1 seq_cst
  %tmp1 = icmp ugt i64 %tmp0, 1
  %tmp2 = zext i1 %tmp1 to i8
  ret i8 %tmp2
}

; FIXME: This test canonicalizes in a way that hides the fact that the
; comparison can be folded into the atomic subtract.
define i8 @test_sub_1_cmp_1_setcc_sle(i64* %p) #0 {
; CHECK-LABEL: test_sub_1_cmp_1_setcc_sle:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movq $-1, %rax
; CHECK-NEXT:    lock xaddq %rax, (%rdi)
; CHECK-NEXT:    cmpq $2, %rax
; CHECK-NEXT:    setl %al
; CHECK-NEXT:    retq
entry:
  %tmp0 = atomicrmw sub i64* %p, i64 1 seq_cst
  %tmp1 = icmp sle i64 %tmp0, 1
  %tmp2 = zext i1 %tmp1 to i8
  ret i8 %tmp2
}

define i8 @test_sub_3_cmp_3_setcc_eq(i64* %p) #0 {
; CHECK-LABEL: test_sub_3_cmp_3_setcc_eq:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lock subq $3, (%rdi)
; CHECK-NEXT:    sete %al
; CHECK-NEXT:    retq
entry:
  %tmp0 = atomicrmw sub i64* %p, i64 3 seq_cst
  %tmp1 = icmp eq i64 %tmp0, 3
  %tmp2 = zext i1 %tmp1 to i8
  ret i8 %tmp2
}

; FIXME: This test canonicalizes in a way that hides the fact that the
; comparison can be folded into the atomic subtract.
define i8 @test_sub_3_cmp_3_setcc_uge(i64* %p) #0 {
; CHECK-LABEL: test_sub_3_cmp_3_setcc_uge:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movq $-3, %rax
; CHECK-NEXT:    lock xaddq %rax, (%rdi)
; CHECK-NEXT:    cmpq $2, %rax
; CHECK-NEXT:    seta %al
; CHECK-NEXT:    retq
entry:
  %tmp0 = atomicrmw sub i64* %p, i64 3 seq_cst
  %tmp1 = icmp uge i64 %tmp0, 3
  %tmp2 = zext i1 %tmp1 to i8
  ret i8 %tmp2
}

attributes #0 = { nounwind }
