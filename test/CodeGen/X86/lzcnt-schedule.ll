; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mattr=+lzcnt | FileCheck %s --check-prefix=CHECK --check-prefix=GENERIC
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=haswell | FileCheck %s --check-prefix=CHECK --check-prefix=HASWELL
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=skylake | FileCheck %s --check-prefix=CHECK --check-prefix=HASWELL
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=knl     | FileCheck %s --check-prefix=CHECK --check-prefix=HASWELL
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=btver2  | FileCheck %s --check-prefix=CHECK --check-prefix=BTVER2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=znver1  | FileCheck %s --check-prefix=CHECK --check-prefix=ZNVER1

define i16 @test_ctlz_i16(i16 zeroext %a0, i16 *%a1) {
; GENERIC-LABEL: test_ctlz_i16:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    lzcntw (%rsi), %cx
; GENERIC-NEXT:    lzcntw %di, %ax
; GENERIC-NEXT:    orl %ecx, %eax
; GENERIC-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; GENERIC-NEXT:    retq
;
; HASWELL-LABEL: test_ctlz_i16:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    lzcntw (%rsi), %cx
; HASWELL-NEXT:    lzcntw %di, %ax
; HASWELL-NEXT:    orl %ecx, %eax # sched: [1:0.25]
; HASWELL-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; HASWELL-NEXT:    retq # sched: [1:1.00]
;
; BTVER2-LABEL: test_ctlz_i16:
; BTVER2:       # BB#0:
; BTVER2-NEXT:    lzcntw (%rsi), %cx
; BTVER2-NEXT:    lzcntw %di, %ax
; BTVER2-NEXT:    orl %ecx, %eax # sched: [1:0.50]
; BTVER2-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; ZNVER1-LABEL: test_ctlz_i16:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    lzcntw (%rsi), %cx
; ZNVER1-NEXT:    lzcntw %di, %ax
; ZNVER1-NEXT:    orl %ecx, %eax # sched: [1:0.25]
; ZNVER1-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; ZNVER1-NEXT:    retq # sched: [5:0.50]
  %1 = load i16, i16 *%a1
  %2 = tail call i16 @llvm.ctlz.i16( i16 %1, i1 false )
  %3 = tail call i16 @llvm.ctlz.i16( i16 %a0, i1 false )
  %4 = or i16 %2, %3
  ret i16 %4
}
declare i16 @llvm.ctlz.i16(i16, i1)

define i32 @test_ctlz_i32(i32 %a0, i32 *%a1) {
; GENERIC-LABEL: test_ctlz_i32:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    lzcntl (%rsi), %ecx
; GENERIC-NEXT:    lzcntl %edi, %eax
; GENERIC-NEXT:    orl %ecx, %eax
; GENERIC-NEXT:    retq
;
; HASWELL-LABEL: test_ctlz_i32:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    lzcntl (%rsi), %ecx
; HASWELL-NEXT:    lzcntl %edi, %eax
; HASWELL-NEXT:    orl %ecx, %eax # sched: [1:0.25]
; HASWELL-NEXT:    retq # sched: [1:1.00]
;
; BTVER2-LABEL: test_ctlz_i32:
; BTVER2:       # BB#0:
; BTVER2-NEXT:    lzcntl (%rsi), %ecx
; BTVER2-NEXT:    lzcntl %edi, %eax
; BTVER2-NEXT:    orl %ecx, %eax # sched: [1:0.50]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; ZNVER1-LABEL: test_ctlz_i32:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    lzcntl (%rsi), %ecx
; ZNVER1-NEXT:    lzcntl %edi, %eax
; ZNVER1-NEXT:    orl %ecx, %eax # sched: [1:0.25]
; ZNVER1-NEXT:    retq # sched: [5:0.50]
  %1 = load i32, i32 *%a1
  %2 = tail call i32 @llvm.ctlz.i32( i32 %1, i1 false )
  %3 = tail call i32 @llvm.ctlz.i32( i32 %a0, i1 false )
  %4 = or i32 %2, %3
  ret i32 %4
}
declare i32 @llvm.ctlz.i32(i32, i1)

define i64 @test_ctlz_i64(i64 %a0, i64 *%a1) {
; GENERIC-LABEL: test_ctlz_i64:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    lzcntq (%rsi), %rcx
; GENERIC-NEXT:    lzcntq %rdi, %rax
; GENERIC-NEXT:    orq %rcx, %rax
; GENERIC-NEXT:    retq
;
; HASWELL-LABEL: test_ctlz_i64:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    lzcntq (%rsi), %rcx
; HASWELL-NEXT:    lzcntq %rdi, %rax
; HASWELL-NEXT:    orq %rcx, %rax # sched: [1:0.25]
; HASWELL-NEXT:    retq # sched: [1:1.00]
;
; BTVER2-LABEL: test_ctlz_i64:
; BTVER2:       # BB#0:
; BTVER2-NEXT:    lzcntq (%rsi), %rcx
; BTVER2-NEXT:    lzcntq %rdi, %rax
; BTVER2-NEXT:    orq %rcx, %rax # sched: [1:0.50]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; ZNVER1-LABEL: test_ctlz_i64:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    lzcntq (%rsi), %rcx
; ZNVER1-NEXT:    lzcntq %rdi, %rax
; ZNVER1-NEXT:    orq %rcx, %rax # sched: [1:0.25]
; ZNVER1-NEXT:    retq # sched: [5:0.50]
  %1 = load i64, i64 *%a1
  %2 = tail call i64 @llvm.ctlz.i64( i64 %1, i1 false )
  %3 = tail call i64 @llvm.ctlz.i64( i64 %a0, i1 false )
  %4 = or i64 %2, %3
  ret i64 %4
}
declare i64 @llvm.ctlz.i64(i64, i1)
