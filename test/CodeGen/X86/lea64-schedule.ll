; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=x86-64      | FileCheck %s --check-prefix=CHECK --check-prefix=GENERIC
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=atom        | FileCheck %s --check-prefix=CHECK --check-prefix=ATOM
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=slm         | FileCheck %s --check-prefix=CHECK --check-prefix=SLM
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=sandybridge | FileCheck %s --check-prefix=CHECK --check-prefix=SANDY
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=ivybridge   | FileCheck %s --check-prefix=CHECK --check-prefix=SANDY
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=haswell     | FileCheck %s --check-prefix=CHECK --check-prefix=HASWELL
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=broadwell   | FileCheck %s --check-prefix=CHECK --check-prefix=BROADWELL
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=skylake     | FileCheck %s --check-prefix=CHECK --check-prefix=SKYLAKE
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=knl         | FileCheck %s --check-prefix=CHECK --check-prefix=HASWELL
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=btver2      | FileCheck %s --check-prefix=CHECK --check-prefix=BTVER2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=znver1      | FileCheck %s --check-prefix=CHECK --check-prefix=ZNVER1

define i64 @test_lea_offset(i64) {
; GENERIC-LABEL: test_lea_offset:
; GENERIC:       # %bb.0:
; GENERIC-NEXT:    leaq -24(%rdi), %rax # sched: [1:0.50]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; ATOM-LABEL: test_lea_offset:
; ATOM:       # %bb.0:
; ATOM-NEXT:    leaq -24(%rdi), %rax # sched: [1:1.00]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    retq # sched: [79:39.50]
;
; SLM-LABEL: test_lea_offset:
; SLM:       # %bb.0:
; SLM-NEXT:    leaq -24(%rdi), %rax # sched: [1:1.00]
; SLM-NEXT:    retq # sched: [4:1.00]
;
; SANDY-LABEL: test_lea_offset:
; SANDY:       # %bb.0:
; SANDY-NEXT:    leaq -24(%rdi), %rax # sched: [1:0.50]
; SANDY-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_lea_offset:
; HASWELL:       # %bb.0:
; HASWELL-NEXT:    leaq -24(%rdi), %rax # sched: [1:0.50]
; HASWELL-NEXT:    retq # sched: [7:1.00]
;
; BROADWELL-LABEL: test_lea_offset:
; BROADWELL:       # %bb.0:
; BROADWELL-NEXT:    leaq -24(%rdi), %rax # sched: [1:0.50]
; BROADWELL-NEXT:    retq # sched: [7:1.00]
;
; SKYLAKE-LABEL: test_lea_offset:
; SKYLAKE:       # %bb.0:
; SKYLAKE-NEXT:    leaq -24(%rdi), %rax # sched: [1:0.50]
; SKYLAKE-NEXT:    retq # sched: [7:1.00]
;
; BTVER2-LABEL: test_lea_offset:
; BTVER2:       # %bb.0:
; BTVER2-NEXT:    leaq -24(%rdi), %rax # sched: [1:0.50]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; ZNVER1-LABEL: test_lea_offset:
; ZNVER1:       # %bb.0:
; ZNVER1-NEXT:    leaq -24(%rdi), %rax # sched: [1:0.25]
; ZNVER1-NEXT:    retq # sched: [1:0.50]
  %2 = add nsw i64 %0, -24
  ret i64 %2
}

define i64 @test_lea_offset_big(i64) {
; GENERIC-LABEL: test_lea_offset_big:
; GENERIC:       # %bb.0:
; GENERIC-NEXT:    leaq 1024(%rdi), %rax # sched: [1:0.50]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; ATOM-LABEL: test_lea_offset_big:
; ATOM:       # %bb.0:
; ATOM-NEXT:    leaq 1024(%rdi), %rax # sched: [1:1.00]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    retq # sched: [79:39.50]
;
; SLM-LABEL: test_lea_offset_big:
; SLM:       # %bb.0:
; SLM-NEXT:    leaq 1024(%rdi), %rax # sched: [1:1.00]
; SLM-NEXT:    retq # sched: [4:1.00]
;
; SANDY-LABEL: test_lea_offset_big:
; SANDY:       # %bb.0:
; SANDY-NEXT:    leaq 1024(%rdi), %rax # sched: [1:0.50]
; SANDY-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_lea_offset_big:
; HASWELL:       # %bb.0:
; HASWELL-NEXT:    leaq 1024(%rdi), %rax # sched: [1:0.50]
; HASWELL-NEXT:    retq # sched: [7:1.00]
;
; BROADWELL-LABEL: test_lea_offset_big:
; BROADWELL:       # %bb.0:
; BROADWELL-NEXT:    leaq 1024(%rdi), %rax # sched: [1:0.50]
; BROADWELL-NEXT:    retq # sched: [7:1.00]
;
; SKYLAKE-LABEL: test_lea_offset_big:
; SKYLAKE:       # %bb.0:
; SKYLAKE-NEXT:    leaq 1024(%rdi), %rax # sched: [1:0.50]
; SKYLAKE-NEXT:    retq # sched: [7:1.00]
;
; BTVER2-LABEL: test_lea_offset_big:
; BTVER2:       # %bb.0:
; BTVER2-NEXT:    leaq 1024(%rdi), %rax # sched: [1:0.50]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; ZNVER1-LABEL: test_lea_offset_big:
; ZNVER1:       # %bb.0:
; ZNVER1-NEXT:    leaq 1024(%rdi), %rax # sched: [1:0.25]
; ZNVER1-NEXT:    retq # sched: [1:0.50]
  %2 = add nsw i64 %0, 1024
  ret i64 %2
}

; Function Attrs: norecurse nounwind readnone uwtable
define i64 @test_lea_add(i64, i64) {
; GENERIC-LABEL: test_lea_add:
; GENERIC:       # %bb.0:
; GENERIC-NEXT:    leaq (%rdi,%rsi), %rax # sched: [1:0.50]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; ATOM-LABEL: test_lea_add:
; ATOM:       # %bb.0:
; ATOM-NEXT:    leaq (%rdi,%rsi), %rax # sched: [1:1.00]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    retq # sched: [79:39.50]
;
; SLM-LABEL: test_lea_add:
; SLM:       # %bb.0:
; SLM-NEXT:    leaq (%rdi,%rsi), %rax # sched: [1:1.00]
; SLM-NEXT:    retq # sched: [4:1.00]
;
; SANDY-LABEL: test_lea_add:
; SANDY:       # %bb.0:
; SANDY-NEXT:    leaq (%rdi,%rsi), %rax # sched: [1:0.50]
; SANDY-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_lea_add:
; HASWELL:       # %bb.0:
; HASWELL-NEXT:    leaq (%rdi,%rsi), %rax # sched: [1:0.50]
; HASWELL-NEXT:    retq # sched: [7:1.00]
;
; BROADWELL-LABEL: test_lea_add:
; BROADWELL:       # %bb.0:
; BROADWELL-NEXT:    leaq (%rdi,%rsi), %rax # sched: [1:0.50]
; BROADWELL-NEXT:    retq # sched: [7:1.00]
;
; SKYLAKE-LABEL: test_lea_add:
; SKYLAKE:       # %bb.0:
; SKYLAKE-NEXT:    leaq (%rdi,%rsi), %rax # sched: [1:0.50]
; SKYLAKE-NEXT:    retq # sched: [7:1.00]
;
; BTVER2-LABEL: test_lea_add:
; BTVER2:       # %bb.0:
; BTVER2-NEXT:    leaq (%rdi,%rsi), %rax # sched: [1:0.50]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; ZNVER1-LABEL: test_lea_add:
; ZNVER1:       # %bb.0:
; ZNVER1-NEXT:    leaq (%rdi,%rsi), %rax # sched: [1:0.25]
; ZNVER1-NEXT:    retq # sched: [1:0.50]
  %3 = add nsw i64 %1, %0
  ret i64 %3
}

define i64 @test_lea_add_offset(i64, i64) {
; GENERIC-LABEL: test_lea_add_offset:
; GENERIC:       # %bb.0:
; GENERIC-NEXT:    leaq (%rdi,%rsi), %rax # sched: [1:0.50]
; GENERIC-NEXT:    addq $16, %rax # sched: [1:0.33]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; ATOM-LABEL: test_lea_add_offset:
; ATOM:       # %bb.0:
; ATOM-NEXT:    leaq 16(%rdi,%rsi), %rax # sched: [1:1.00]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    retq # sched: [79:39.50]
;
; SLM-LABEL: test_lea_add_offset:
; SLM:       # %bb.0:
; SLM-NEXT:    leaq 16(%rdi,%rsi), %rax # sched: [1:1.00]
; SLM-NEXT:    retq # sched: [4:1.00]
;
; SANDY-LABEL: test_lea_add_offset:
; SANDY:       # %bb.0:
; SANDY-NEXT:    leaq (%rdi,%rsi), %rax # sched: [1:0.50]
; SANDY-NEXT:    addq $16, %rax # sched: [1:0.33]
; SANDY-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_lea_add_offset:
; HASWELL:       # %bb.0:
; HASWELL-NEXT:    leaq (%rdi,%rsi), %rax # sched: [1:0.50]
; HASWELL-NEXT:    addq $16, %rax # sched: [1:0.25]
; HASWELL-NEXT:    retq # sched: [7:1.00]
;
; BROADWELL-LABEL: test_lea_add_offset:
; BROADWELL:       # %bb.0:
; BROADWELL-NEXT:    leaq (%rdi,%rsi), %rax # sched: [1:0.50]
; BROADWELL-NEXT:    addq $16, %rax # sched: [1:0.25]
; BROADWELL-NEXT:    retq # sched: [7:1.00]
;
; SKYLAKE-LABEL: test_lea_add_offset:
; SKYLAKE:       # %bb.0:
; SKYLAKE-NEXT:    leaq (%rdi,%rsi), %rax # sched: [1:0.50]
; SKYLAKE-NEXT:    addq $16, %rax # sched: [1:0.25]
; SKYLAKE-NEXT:    retq # sched: [7:1.00]
;
; BTVER2-LABEL: test_lea_add_offset:
; BTVER2:       # %bb.0:
; BTVER2-NEXT:    leaq 16(%rdi,%rsi), %rax # sched: [1:0.50]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; ZNVER1-LABEL: test_lea_add_offset:
; ZNVER1:       # %bb.0:
; ZNVER1-NEXT:    leaq 16(%rdi,%rsi), %rax # sched: [1:0.25]
; ZNVER1-NEXT:    retq # sched: [1:0.50]
  %3 = add i64 %0, 16
  %4 = add i64 %3, %1
  ret i64 %4
}

define i64 @test_lea_add_offset_big(i64, i64) {
; GENERIC-LABEL: test_lea_add_offset_big:
; GENERIC:       # %bb.0:
; GENERIC-NEXT:    leaq (%rdi,%rsi), %rax # sched: [1:0.50]
; GENERIC-NEXT:    addq $-4096, %rax # imm = 0xF000
; GENERIC-NEXT:    # sched: [1:0.33]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; ATOM-LABEL: test_lea_add_offset_big:
; ATOM:       # %bb.0:
; ATOM-NEXT:    leaq -4096(%rdi,%rsi), %rax # sched: [1:1.00]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    retq # sched: [79:39.50]
;
; SLM-LABEL: test_lea_add_offset_big:
; SLM:       # %bb.0:
; SLM-NEXT:    leaq -4096(%rdi,%rsi), %rax # sched: [1:1.00]
; SLM-NEXT:    retq # sched: [4:1.00]
;
; SANDY-LABEL: test_lea_add_offset_big:
; SANDY:       # %bb.0:
; SANDY-NEXT:    leaq (%rdi,%rsi), %rax # sched: [1:0.50]
; SANDY-NEXT:    addq $-4096, %rax # imm = 0xF000
; SANDY-NEXT:    # sched: [1:0.33]
; SANDY-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_lea_add_offset_big:
; HASWELL:       # %bb.0:
; HASWELL-NEXT:    leaq (%rdi,%rsi), %rax # sched: [1:0.50]
; HASWELL-NEXT:    addq $-4096, %rax # imm = 0xF000
; HASWELL-NEXT:    # sched: [1:0.25]
; HASWELL-NEXT:    retq # sched: [7:1.00]
;
; BROADWELL-LABEL: test_lea_add_offset_big:
; BROADWELL:       # %bb.0:
; BROADWELL-NEXT:    leaq (%rdi,%rsi), %rax # sched: [1:0.50]
; BROADWELL-NEXT:    addq $-4096, %rax # imm = 0xF000
; BROADWELL-NEXT:    # sched: [1:0.25]
; BROADWELL-NEXT:    retq # sched: [7:1.00]
;
; SKYLAKE-LABEL: test_lea_add_offset_big:
; SKYLAKE:       # %bb.0:
; SKYLAKE-NEXT:    leaq (%rdi,%rsi), %rax # sched: [1:0.50]
; SKYLAKE-NEXT:    addq $-4096, %rax # imm = 0xF000
; SKYLAKE-NEXT:    # sched: [1:0.25]
; SKYLAKE-NEXT:    retq # sched: [7:1.00]
;
; BTVER2-LABEL: test_lea_add_offset_big:
; BTVER2:       # %bb.0:
; BTVER2-NEXT:    leaq -4096(%rdi,%rsi), %rax # sched: [1:0.50]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; ZNVER1-LABEL: test_lea_add_offset_big:
; ZNVER1:       # %bb.0:
; ZNVER1-NEXT:    leaq -4096(%rdi,%rsi), %rax # sched: [1:0.25]
; ZNVER1-NEXT:    retq # sched: [1:0.50]
  %3 = add i64 %0, -4096
  %4 = add i64 %3, %1
  ret i64 %4
}

define i64 @test_lea_mul(i64) {
; GENERIC-LABEL: test_lea_mul:
; GENERIC:       # %bb.0:
; GENERIC-NEXT:    leaq (%rdi,%rdi,2), %rax # sched: [1:0.50]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; ATOM-LABEL: test_lea_mul:
; ATOM:       # %bb.0:
; ATOM-NEXT:    leaq (%rdi,%rdi,2), %rax # sched: [1:1.00]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    retq # sched: [79:39.50]
;
; SLM-LABEL: test_lea_mul:
; SLM:       # %bb.0:
; SLM-NEXT:    leaq (%rdi,%rdi,2), %rax # sched: [1:1.00]
; SLM-NEXT:    retq # sched: [4:1.00]
;
; SANDY-LABEL: test_lea_mul:
; SANDY:       # %bb.0:
; SANDY-NEXT:    leaq (%rdi,%rdi,2), %rax # sched: [1:0.50]
; SANDY-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_lea_mul:
; HASWELL:       # %bb.0:
; HASWELL-NEXT:    leaq (%rdi,%rdi,2), %rax # sched: [1:0.50]
; HASWELL-NEXT:    retq # sched: [7:1.00]
;
; BROADWELL-LABEL: test_lea_mul:
; BROADWELL:       # %bb.0:
; BROADWELL-NEXT:    leaq (%rdi,%rdi,2), %rax # sched: [1:0.50]
; BROADWELL-NEXT:    retq # sched: [7:1.00]
;
; SKYLAKE-LABEL: test_lea_mul:
; SKYLAKE:       # %bb.0:
; SKYLAKE-NEXT:    leaq (%rdi,%rdi,2), %rax # sched: [1:0.50]
; SKYLAKE-NEXT:    retq # sched: [7:1.00]
;
; BTVER2-LABEL: test_lea_mul:
; BTVER2:       # %bb.0:
; BTVER2-NEXT:    leaq (%rdi,%rdi,2), %rax # sched: [1:0.50]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; ZNVER1-LABEL: test_lea_mul:
; ZNVER1:       # %bb.0:
; ZNVER1-NEXT:    leaq (%rdi,%rdi,2), %rax # sched: [1:0.25]
; ZNVER1-NEXT:    retq # sched: [1:0.50]
  %2 = mul nsw i64 %0, 3
  ret i64 %2
}

define i64 @test_lea_mul_offset(i64) {
; GENERIC-LABEL: test_lea_mul_offset:
; GENERIC:       # %bb.0:
; GENERIC-NEXT:    leaq (%rdi,%rdi,2), %rax # sched: [1:0.50]
; GENERIC-NEXT:    addq $-32, %rax # sched: [1:0.33]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; ATOM-LABEL: test_lea_mul_offset:
; ATOM:       # %bb.0:
; ATOM-NEXT:    leaq -32(%rdi,%rdi,2), %rax # sched: [1:1.00]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    retq # sched: [79:39.50]
;
; SLM-LABEL: test_lea_mul_offset:
; SLM:       # %bb.0:
; SLM-NEXT:    leaq -32(%rdi,%rdi,2), %rax # sched: [1:1.00]
; SLM-NEXT:    retq # sched: [4:1.00]
;
; SANDY-LABEL: test_lea_mul_offset:
; SANDY:       # %bb.0:
; SANDY-NEXT:    leaq (%rdi,%rdi,2), %rax # sched: [1:0.50]
; SANDY-NEXT:    addq $-32, %rax # sched: [1:0.33]
; SANDY-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_lea_mul_offset:
; HASWELL:       # %bb.0:
; HASWELL-NEXT:    leaq (%rdi,%rdi,2), %rax # sched: [1:0.50]
; HASWELL-NEXT:    addq $-32, %rax # sched: [1:0.25]
; HASWELL-NEXT:    retq # sched: [7:1.00]
;
; BROADWELL-LABEL: test_lea_mul_offset:
; BROADWELL:       # %bb.0:
; BROADWELL-NEXT:    leaq (%rdi,%rdi,2), %rax # sched: [1:0.50]
; BROADWELL-NEXT:    addq $-32, %rax # sched: [1:0.25]
; BROADWELL-NEXT:    retq # sched: [7:1.00]
;
; SKYLAKE-LABEL: test_lea_mul_offset:
; SKYLAKE:       # %bb.0:
; SKYLAKE-NEXT:    leaq (%rdi,%rdi,2), %rax # sched: [1:0.50]
; SKYLAKE-NEXT:    addq $-32, %rax # sched: [1:0.25]
; SKYLAKE-NEXT:    retq # sched: [7:1.00]
;
; BTVER2-LABEL: test_lea_mul_offset:
; BTVER2:       # %bb.0:
; BTVER2-NEXT:    leaq -32(%rdi,%rdi,2), %rax # sched: [1:0.50]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; ZNVER1-LABEL: test_lea_mul_offset:
; ZNVER1:       # %bb.0:
; ZNVER1-NEXT:    leaq -32(%rdi,%rdi,2), %rax # sched: [1:0.25]
; ZNVER1-NEXT:    retq # sched: [1:0.50]
  %2 = mul nsw i64 %0, 3
  %3 = add nsw i64 %2, -32
  ret i64 %3
}

define i64 @test_lea_mul_offset_big(i64) {
; GENERIC-LABEL: test_lea_mul_offset_big:
; GENERIC:       # %bb.0:
; GENERIC-NEXT:    leaq (%rdi,%rdi,8), %rax # sched: [1:0.50]
; GENERIC-NEXT:    addq $10000, %rax # imm = 0x2710
; GENERIC-NEXT:    # sched: [1:0.33]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; ATOM-LABEL: test_lea_mul_offset_big:
; ATOM:       # %bb.0:
; ATOM-NEXT:    leaq 10000(%rdi,%rdi,8), %rax # sched: [1:1.00]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    retq # sched: [79:39.50]
;
; SLM-LABEL: test_lea_mul_offset_big:
; SLM:       # %bb.0:
; SLM-NEXT:    leaq 10000(%rdi,%rdi,8), %rax # sched: [1:1.00]
; SLM-NEXT:    retq # sched: [4:1.00]
;
; SANDY-LABEL: test_lea_mul_offset_big:
; SANDY:       # %bb.0:
; SANDY-NEXT:    leaq (%rdi,%rdi,8), %rax # sched: [1:0.50]
; SANDY-NEXT:    addq $10000, %rax # imm = 0x2710
; SANDY-NEXT:    # sched: [1:0.33]
; SANDY-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_lea_mul_offset_big:
; HASWELL:       # %bb.0:
; HASWELL-NEXT:    leaq (%rdi,%rdi,8), %rax # sched: [1:0.50]
; HASWELL-NEXT:    addq $10000, %rax # imm = 0x2710
; HASWELL-NEXT:    # sched: [1:0.25]
; HASWELL-NEXT:    retq # sched: [7:1.00]
;
; BROADWELL-LABEL: test_lea_mul_offset_big:
; BROADWELL:       # %bb.0:
; BROADWELL-NEXT:    leaq (%rdi,%rdi,8), %rax # sched: [1:0.50]
; BROADWELL-NEXT:    addq $10000, %rax # imm = 0x2710
; BROADWELL-NEXT:    # sched: [1:0.25]
; BROADWELL-NEXT:    retq # sched: [7:1.00]
;
; SKYLAKE-LABEL: test_lea_mul_offset_big:
; SKYLAKE:       # %bb.0:
; SKYLAKE-NEXT:    leaq (%rdi,%rdi,8), %rax # sched: [1:0.50]
; SKYLAKE-NEXT:    addq $10000, %rax # imm = 0x2710
; SKYLAKE-NEXT:    # sched: [1:0.25]
; SKYLAKE-NEXT:    retq # sched: [7:1.00]
;
; BTVER2-LABEL: test_lea_mul_offset_big:
; BTVER2:       # %bb.0:
; BTVER2-NEXT:    leaq 10000(%rdi,%rdi,8), %rax # sched: [1:0.50]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; ZNVER1-LABEL: test_lea_mul_offset_big:
; ZNVER1:       # %bb.0:
; ZNVER1-NEXT:    leaq 10000(%rdi,%rdi,8), %rax # sched: [1:0.25]
; ZNVER1-NEXT:    retq # sched: [1:0.50]
  %2 = mul nsw i64 %0, 9
  %3 = add nsw i64 %2, 10000
  ret i64 %3
}

define i64 @test_lea_add_scale(i64, i64) {
; GENERIC-LABEL: test_lea_add_scale:
; GENERIC:       # %bb.0:
; GENERIC-NEXT:    leaq (%rdi,%rsi,2), %rax # sched: [1:0.50]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; ATOM-LABEL: test_lea_add_scale:
; ATOM:       # %bb.0:
; ATOM-NEXT:    leaq (%rdi,%rsi,2), %rax # sched: [1:1.00]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    retq # sched: [79:39.50]
;
; SLM-LABEL: test_lea_add_scale:
; SLM:       # %bb.0:
; SLM-NEXT:    leaq (%rdi,%rsi,2), %rax # sched: [1:1.00]
; SLM-NEXT:    retq # sched: [4:1.00]
;
; SANDY-LABEL: test_lea_add_scale:
; SANDY:       # %bb.0:
; SANDY-NEXT:    leaq (%rdi,%rsi,2), %rax # sched: [1:0.50]
; SANDY-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_lea_add_scale:
; HASWELL:       # %bb.0:
; HASWELL-NEXT:    leaq (%rdi,%rsi,2), %rax # sched: [1:0.50]
; HASWELL-NEXT:    retq # sched: [7:1.00]
;
; BROADWELL-LABEL: test_lea_add_scale:
; BROADWELL:       # %bb.0:
; BROADWELL-NEXT:    leaq (%rdi,%rsi,2), %rax # sched: [1:0.50]
; BROADWELL-NEXT:    retq # sched: [7:1.00]
;
; SKYLAKE-LABEL: test_lea_add_scale:
; SKYLAKE:       # %bb.0:
; SKYLAKE-NEXT:    leaq (%rdi,%rsi,2), %rax # sched: [1:0.50]
; SKYLAKE-NEXT:    retq # sched: [7:1.00]
;
; BTVER2-LABEL: test_lea_add_scale:
; BTVER2:       # %bb.0:
; BTVER2-NEXT:    leaq (%rdi,%rsi,2), %rax # sched: [1:0.50]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; ZNVER1-LABEL: test_lea_add_scale:
; ZNVER1:       # %bb.0:
; ZNVER1-NEXT:    leaq (%rdi,%rsi,2), %rax # sched: [1:0.25]
; ZNVER1-NEXT:    retq # sched: [1:0.50]
  %3 = shl i64 %1, 1
  %4 = add nsw i64 %3, %0
  ret i64 %4
}

define i64 @test_lea_add_scale_offset(i64, i64) {
; GENERIC-LABEL: test_lea_add_scale_offset:
; GENERIC:       # %bb.0:
; GENERIC-NEXT:    leaq (%rdi,%rsi,4), %rax # sched: [1:0.50]
; GENERIC-NEXT:    addq $96, %rax # sched: [1:0.33]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; ATOM-LABEL: test_lea_add_scale_offset:
; ATOM:       # %bb.0:
; ATOM-NEXT:    leaq 96(%rdi,%rsi,4), %rax # sched: [1:1.00]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    retq # sched: [79:39.50]
;
; SLM-LABEL: test_lea_add_scale_offset:
; SLM:       # %bb.0:
; SLM-NEXT:    leaq 96(%rdi,%rsi,4), %rax # sched: [1:1.00]
; SLM-NEXT:    retq # sched: [4:1.00]
;
; SANDY-LABEL: test_lea_add_scale_offset:
; SANDY:       # %bb.0:
; SANDY-NEXT:    leaq (%rdi,%rsi,4), %rax # sched: [1:0.50]
; SANDY-NEXT:    addq $96, %rax # sched: [1:0.33]
; SANDY-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_lea_add_scale_offset:
; HASWELL:       # %bb.0:
; HASWELL-NEXT:    leaq (%rdi,%rsi,4), %rax # sched: [1:0.50]
; HASWELL-NEXT:    addq $96, %rax # sched: [1:0.25]
; HASWELL-NEXT:    retq # sched: [7:1.00]
;
; BROADWELL-LABEL: test_lea_add_scale_offset:
; BROADWELL:       # %bb.0:
; BROADWELL-NEXT:    leaq (%rdi,%rsi,4), %rax # sched: [1:0.50]
; BROADWELL-NEXT:    addq $96, %rax # sched: [1:0.25]
; BROADWELL-NEXT:    retq # sched: [7:1.00]
;
; SKYLAKE-LABEL: test_lea_add_scale_offset:
; SKYLAKE:       # %bb.0:
; SKYLAKE-NEXT:    leaq (%rdi,%rsi,4), %rax # sched: [1:0.50]
; SKYLAKE-NEXT:    addq $96, %rax # sched: [1:0.25]
; SKYLAKE-NEXT:    retq # sched: [7:1.00]
;
; BTVER2-LABEL: test_lea_add_scale_offset:
; BTVER2:       # %bb.0:
; BTVER2-NEXT:    leaq 96(%rdi,%rsi,4), %rax # sched: [1:0.50]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; ZNVER1-LABEL: test_lea_add_scale_offset:
; ZNVER1:       # %bb.0:
; ZNVER1-NEXT:    leaq 96(%rdi,%rsi,4), %rax # sched: [1:0.25]
; ZNVER1-NEXT:    retq # sched: [1:0.50]
  %3 = shl i64 %1, 2
  %4 = add i64 %0, 96
  %5 = add i64 %4, %3
  ret i64 %5
}

define i64 @test_lea_add_scale_offset_big(i64, i64) {
; GENERIC-LABEL: test_lea_add_scale_offset_big:
; GENERIC:       # %bb.0:
; GENERIC-NEXT:    leaq (%rdi,%rsi,8), %rax # sched: [1:0.50]
; GENERIC-NEXT:    addq $-1200, %rax # imm = 0xFB50
; GENERIC-NEXT:    # sched: [1:0.33]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; ATOM-LABEL: test_lea_add_scale_offset_big:
; ATOM:       # %bb.0:
; ATOM-NEXT:    leaq -1200(%rdi,%rsi,8), %rax # sched: [1:1.00]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    retq # sched: [79:39.50]
;
; SLM-LABEL: test_lea_add_scale_offset_big:
; SLM:       # %bb.0:
; SLM-NEXT:    leaq -1200(%rdi,%rsi,8), %rax # sched: [1:1.00]
; SLM-NEXT:    retq # sched: [4:1.00]
;
; SANDY-LABEL: test_lea_add_scale_offset_big:
; SANDY:       # %bb.0:
; SANDY-NEXT:    leaq (%rdi,%rsi,8), %rax # sched: [1:0.50]
; SANDY-NEXT:    addq $-1200, %rax # imm = 0xFB50
; SANDY-NEXT:    # sched: [1:0.33]
; SANDY-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_lea_add_scale_offset_big:
; HASWELL:       # %bb.0:
; HASWELL-NEXT:    leaq (%rdi,%rsi,8), %rax # sched: [1:0.50]
; HASWELL-NEXT:    addq $-1200, %rax # imm = 0xFB50
; HASWELL-NEXT:    # sched: [1:0.25]
; HASWELL-NEXT:    retq # sched: [7:1.00]
;
; BROADWELL-LABEL: test_lea_add_scale_offset_big:
; BROADWELL:       # %bb.0:
; BROADWELL-NEXT:    leaq (%rdi,%rsi,8), %rax # sched: [1:0.50]
; BROADWELL-NEXT:    addq $-1200, %rax # imm = 0xFB50
; BROADWELL-NEXT:    # sched: [1:0.25]
; BROADWELL-NEXT:    retq # sched: [7:1.00]
;
; SKYLAKE-LABEL: test_lea_add_scale_offset_big:
; SKYLAKE:       # %bb.0:
; SKYLAKE-NEXT:    leaq (%rdi,%rsi,8), %rax # sched: [1:0.50]
; SKYLAKE-NEXT:    addq $-1200, %rax # imm = 0xFB50
; SKYLAKE-NEXT:    # sched: [1:0.25]
; SKYLAKE-NEXT:    retq # sched: [7:1.00]
;
; BTVER2-LABEL: test_lea_add_scale_offset_big:
; BTVER2:       # %bb.0:
; BTVER2-NEXT:    leaq -1200(%rdi,%rsi,8), %rax # sched: [1:0.50]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; ZNVER1-LABEL: test_lea_add_scale_offset_big:
; ZNVER1:       # %bb.0:
; ZNVER1-NEXT:    leaq -1200(%rdi,%rsi,8), %rax # sched: [1:0.25]
; ZNVER1-NEXT:    retq # sched: [1:0.50]
  %3 = shl i64 %1, 3
  %4 = add i64 %0, -1200
  %5 = add i64 %4, %3
  ret i64 %5
}
