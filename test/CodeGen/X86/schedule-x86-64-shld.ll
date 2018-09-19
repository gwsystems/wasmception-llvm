; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=x86-64 | FileCheck %s --check-prefix=CHECK --check-prefix=GENERIC
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=btver2 | FileCheck %s --check-prefix=CHECK --check-prefix=BTVER2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=bdver1 | FileCheck %s --check-prefix=CHECK --check-prefix=BDVER1


; uint64_t lshift10(uint64_t a, uint64_t b)
; {
;     return (a << 10) | (b >> 54);
; }

define i64 @lshift10_optsize(i64 %a, i64 %b) nounwind readnone optsize {
; GENERIC-LABEL: lshift10_optsize:
; GENERIC:       # %bb.0: # %entry
; GENERIC-NEXT:    movq %rdi, %rax # sched: [1:0.33]
; GENERIC-NEXT:    shldq $10, %rsi, %rax # sched: [2:0.67]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; BTVER2-LABEL: lshift10_optsize:
; BTVER2:       # %bb.0: # %entry
; BTVER2-NEXT:    movq %rdi, %rax # sched: [1:0.50]
; BTVER2-NEXT:    shldq $10, %rsi, %rax # sched: [3:3.00]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; BDVER1-LABEL: lshift10_optsize:
; BDVER1:       # %bb.0: # %entry
; BDVER1-NEXT:    movq %rdi, %rax
; BDVER1-NEXT:    shldq $10, %rsi, %rax
; BDVER1-NEXT:    retq
entry:
  %shl = shl i64 %a, 10
  %shr = lshr i64 %b, 54
  %or = or i64 %shr, %shl
  ret i64 %or
}

define i64 @lshift10(i64 %a, i64 %b) nounwind readnone {
; GENERIC-LABEL: lshift10:
; GENERIC:       # %bb.0: # %entry
; GENERIC-NEXT:    movq %rdi, %rax # sched: [1:0.33]
; GENERIC-NEXT:    shldq $10, %rsi, %rax # sched: [2:0.67]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; BTVER2-LABEL: lshift10:
; BTVER2:       # %bb.0: # %entry
; BTVER2-NEXT:    shlq $10, %rdi # sched: [1:0.50]
; BTVER2-NEXT:    shrq $54, %rsi # sched: [1:0.50]
; BTVER2-NEXT:    leaq (%rsi,%rdi), %rax # sched: [1:0.50]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; BDVER1-LABEL: lshift10:
; BDVER1:       # %bb.0: # %entry
; BDVER1-NEXT:    shlq $10, %rdi
; BDVER1-NEXT:    shrq $54, %rsi
; BDVER1-NEXT:    leaq (%rsi,%rdi), %rax
; BDVER1-NEXT:    retq
entry:
  %shl = shl i64 %a, 10
  %shr = lshr i64 %b, 54
  %or = or i64 %shr, %shl
  ret i64 %or
}

; uint64_t rshift10(uint64_t a, uint64_t b)
; {
;     return (a >> 62) | (b << 2);
; }

; Should be done via shld
define i64 @rshift10_optsize(i64 %a, i64 %b) nounwind readnone optsize {
; GENERIC-LABEL: rshift10_optsize:
; GENERIC:       # %bb.0: # %entry
; GENERIC-NEXT:    movq %rdi, %rax # sched: [1:0.33]
; GENERIC-NEXT:    shrdq $62, %rsi, %rax # sched: [2:0.67]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; BTVER2-LABEL: rshift10_optsize:
; BTVER2:       # %bb.0: # %entry
; BTVER2-NEXT:    movq %rdi, %rax # sched: [1:0.50]
; BTVER2-NEXT:    shrdq $62, %rsi, %rax # sched: [3:3.00]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; BDVER1-LABEL: rshift10_optsize:
; BDVER1:       # %bb.0: # %entry
; BDVER1-NEXT:    movq %rdi, %rax
; BDVER1-NEXT:    shrdq $62, %rsi, %rax
; BDVER1-NEXT:    retq
entry:
  %shl = lshr i64 %a, 62
  %shr = shl i64 %b, 2
  %or = or i64 %shr, %shl
  ret i64 %or
}

; Should be done via lea (x,y,4),z
define i64 @rshift10(i64 %a, i64 %b) nounwind readnone {
; GENERIC-LABEL: rshift10:
; GENERIC:       # %bb.0: # %entry
; GENERIC-NEXT:    movq %rdi, %rax # sched: [1:0.33]
; GENERIC-NEXT:    shrdq $62, %rsi, %rax # sched: [2:0.67]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; BTVER2-LABEL: rshift10:
; BTVER2:       # %bb.0: # %entry
; BTVER2-NEXT:    shrq $62, %rdi # sched: [1:0.50]
; BTVER2-NEXT:    leaq (%rdi,%rsi,4), %rax # sched: [2:1.00]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; BDVER1-LABEL: rshift10:
; BDVER1:       # %bb.0: # %entry
; BDVER1-NEXT:    shrq $62, %rdi
; BDVER1-NEXT:    leaq (%rdi,%rsi,4), %rax
; BDVER1-NEXT:    retq
entry:
  %shl = lshr i64 %a, 62
  %shr = shl i64 %b, 2
  %or = or i64 %shr, %shl
  ret i64 %or
}

;uint64_t lshift(uint64_t a, uint64_t b, uint64_t c)
;{
;    return (a << c) | (b >> (64-c));
;}

define i64 @lshift_cl_optsize(i64 %a, i64 %b, i64 %c) nounwind readnone optsize {
; GENERIC-LABEL: lshift_cl_optsize:
; GENERIC:       # %bb.0: # %entry
; GENERIC-NEXT:    movq %rdx, %rcx # sched: [1:0.33]
; GENERIC-NEXT:    movq %rdi, %rax # sched: [1:0.33]
; GENERIC-NEXT:    # kill: def $cl killed $cl killed $rcx
; GENERIC-NEXT:    shldq %cl, %rsi, %rax # sched: [4:1.50]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; BTVER2-LABEL: lshift_cl_optsize:
; BTVER2:       # %bb.0: # %entry
; BTVER2-NEXT:    movq %rdx, %rcx # sched: [1:0.50]
; BTVER2-NEXT:    movq %rdi, %rax # sched: [1:0.50]
; BTVER2-NEXT:    # kill: def $cl killed $cl killed $rcx
; BTVER2-NEXT:    shldq %cl, %rsi, %rax # sched: [4:4.00]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; BDVER1-LABEL: lshift_cl_optsize:
; BDVER1:       # %bb.0: # %entry
; BDVER1-NEXT:    movq %rdx, %rcx
; BDVER1-NEXT:    movq %rdi, %rax
; BDVER1-NEXT:    # kill: def $cl killed $cl killed $rcx
; BDVER1-NEXT:    shldq %cl, %rsi, %rax
; BDVER1-NEXT:    retq
entry:
  %shl = shl i64 %a, %c
  %sub = sub nsw i64 64, %c
  %shr = lshr i64 %b, %sub
  %or = or i64 %shr, %shl
  ret i64 %or
}

define i64 @lshift_cl(i64 %a, i64 %b, i64 %c) nounwind readnone {
; GENERIC-LABEL: lshift_cl:
; GENERIC:       # %bb.0: # %entry
; GENERIC-NEXT:    movq %rdx, %rcx # sched: [1:0.33]
; GENERIC-NEXT:    movq %rdi, %rax # sched: [1:0.33]
; GENERIC-NEXT:    # kill: def $cl killed $cl killed $rcx
; GENERIC-NEXT:    shldq %cl, %rsi, %rax # sched: [4:1.50]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; BTVER2-LABEL: lshift_cl:
; BTVER2:       # %bb.0: # %entry
; BTVER2-NEXT:    movq %rdx, %rcx # sched: [1:0.50]
; BTVER2-NEXT:    movq %rsi, %rax # sched: [1:0.50]
; BTVER2-NEXT:    shlq %cl, %rdi # sched: [1:0.50]
; BTVER2-NEXT:    negl %ecx # sched: [1:0.50]
; BTVER2-NEXT:    # kill: def $cl killed $cl killed $rcx
; BTVER2-NEXT:    shrq %cl, %rax # sched: [1:0.50]
; BTVER2-NEXT:    orq %rdi, %rax # sched: [1:0.50]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; BDVER1-LABEL: lshift_cl:
; BDVER1:       # %bb.0: # %entry
; BDVER1-NEXT:    movq %rdx, %rcx
; BDVER1-NEXT:    movq %rsi, %rax
; BDVER1-NEXT:    shlq %cl, %rdi
; BDVER1-NEXT:    negl %ecx
; BDVER1-NEXT:    # kill: def $cl killed $cl killed $rcx
; BDVER1-NEXT:    shrq %cl, %rax
; BDVER1-NEXT:    orq %rdi, %rax
; BDVER1-NEXT:    retq
entry:
  %shl = shl i64 %a, %c
  %sub = sub nsw i64 64, %c
  %shr = lshr i64 %b, %sub
  %or = or i64 %shr, %shl
  ret i64 %or
}


;uint64_t rshift(uint64_t a, uint64_t b, int c)
;{
;    return (a >> c) | (b << (64-c));
;}

define i64 @rshift_cl_optsize(i64 %a, i64 %b, i64 %c) nounwind readnone optsize {
; GENERIC-LABEL: rshift_cl_optsize:
; GENERIC:       # %bb.0: # %entry
; GENERIC-NEXT:    movq %rdx, %rcx # sched: [1:0.33]
; GENERIC-NEXT:    movq %rdi, %rax # sched: [1:0.33]
; GENERIC-NEXT:    # kill: def $cl killed $cl killed $rcx
; GENERIC-NEXT:    shrdq %cl, %rsi, %rax # sched: [4:1.50]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; BTVER2-LABEL: rshift_cl_optsize:
; BTVER2:       # %bb.0: # %entry
; BTVER2-NEXT:    movq %rdx, %rcx # sched: [1:0.50]
; BTVER2-NEXT:    movq %rdi, %rax # sched: [1:0.50]
; BTVER2-NEXT:    # kill: def $cl killed $cl killed $rcx
; BTVER2-NEXT:    shrdq %cl, %rsi, %rax # sched: [4:4.00]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; BDVER1-LABEL: rshift_cl_optsize:
; BDVER1:       # %bb.0: # %entry
; BDVER1-NEXT:    movq %rdx, %rcx
; BDVER1-NEXT:    movq %rdi, %rax
; BDVER1-NEXT:    # kill: def $cl killed $cl killed $rcx
; BDVER1-NEXT:    shrdq %cl, %rsi, %rax
; BDVER1-NEXT:    retq
entry:
  %shr = lshr i64 %a, %c
  %sub = sub nsw i64 64, %c
  %shl = shl i64 %b, %sub
  %or = or i64 %shr, %shl
  ret i64 %or
}

define i64 @rshift_cl(i64 %a, i64 %b, i64 %c) nounwind readnone {
; GENERIC-LABEL: rshift_cl:
; GENERIC:       # %bb.0: # %entry
; GENERIC-NEXT:    movq %rdx, %rcx # sched: [1:0.33]
; GENERIC-NEXT:    movq %rdi, %rax # sched: [1:0.33]
; GENERIC-NEXT:    # kill: def $cl killed $cl killed $rcx
; GENERIC-NEXT:    shrdq %cl, %rsi, %rax # sched: [4:1.50]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; BTVER2-LABEL: rshift_cl:
; BTVER2:       # %bb.0: # %entry
; BTVER2-NEXT:    movq %rdx, %rcx # sched: [1:0.50]
; BTVER2-NEXT:    movq %rsi, %rax # sched: [1:0.50]
; BTVER2-NEXT:    shrq %cl, %rdi # sched: [1:0.50]
; BTVER2-NEXT:    negl %ecx # sched: [1:0.50]
; BTVER2-NEXT:    # kill: def $cl killed $cl killed $rcx
; BTVER2-NEXT:    shlq %cl, %rax # sched: [1:0.50]
; BTVER2-NEXT:    orq %rdi, %rax # sched: [1:0.50]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; BDVER1-LABEL: rshift_cl:
; BDVER1:       # %bb.0: # %entry
; BDVER1-NEXT:    movq %rdx, %rcx
; BDVER1-NEXT:    movq %rsi, %rax
; BDVER1-NEXT:    shrq %cl, %rdi
; BDVER1-NEXT:    negl %ecx
; BDVER1-NEXT:    # kill: def $cl killed $cl killed $rcx
; BDVER1-NEXT:    shlq %cl, %rax
; BDVER1-NEXT:    orq %rdi, %rax
; BDVER1-NEXT:    retq
entry:
  %shr = lshr i64 %a, %c
  %sub = sub nsw i64 64, %c
  %shl = shl i64 %b, %sub
  %or = or i64 %shr, %shl
  ret i64 %or
}

; extern uint64_t x;
;void lshift(uint64_t a, uint64_t b, uint_64_t c)
;{
;    x = (x << c) | (a >> (64-c));
;}
@x = global i64 0, align 4

define void @lshift_mem_cl_optsize(i64 %a, i64 %c) nounwind readnone optsize {
; GENERIC-LABEL: lshift_mem_cl_optsize:
; GENERIC:       # %bb.0: # %entry
; GENERIC-NEXT:    movq %rsi, %rcx # sched: [1:0.33]
; GENERIC-NEXT:    # kill: def $cl killed $cl killed $rcx
; GENERIC-NEXT:    shldq %cl, %rdi, {{.*}}(%rip) # sched: [10:1.50]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; BTVER2-LABEL: lshift_mem_cl_optsize:
; BTVER2:       # %bb.0: # %entry
; BTVER2-NEXT:    movq %rsi, %rcx # sched: [1:0.50]
; BTVER2-NEXT:    # kill: def $cl killed $cl killed $rcx
; BTVER2-NEXT:    shldq %cl, %rdi, {{.*}}(%rip) # sched: [9:11.00]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; BDVER1-LABEL: lshift_mem_cl_optsize:
; BDVER1:       # %bb.0: # %entry
; BDVER1-NEXT:    movq %rsi, %rcx
; BDVER1-NEXT:    # kill: def $cl killed $cl killed $rcx
; BDVER1-NEXT:    shldq %cl, %rdi, {{.*}}(%rip)
; BDVER1-NEXT:    retq
entry:
  %b = load i64, i64* @x
  %shl = shl i64 %b, %c
  %sub = sub nsw i64 64, %c
  %shr = lshr i64 %a, %sub
  %or = or i64 %shl, %shr
  store i64 %or, i64* @x
  ret void
}

define void @lshift_mem_cl(i64 %a, i64 %c) nounwind readnone {
; GENERIC-LABEL: lshift_mem_cl:
; GENERIC:       # %bb.0: # %entry
; GENERIC-NEXT:    movq %rsi, %rcx # sched: [1:0.33]
; GENERIC-NEXT:    # kill: def $cl killed $cl killed $rcx
; GENERIC-NEXT:    shldq %cl, %rdi, {{.*}}(%rip) # sched: [10:1.50]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; BTVER2-LABEL: lshift_mem_cl:
; BTVER2:       # %bb.0: # %entry
; BTVER2-NEXT:    movq {{.*}}(%rip), %rax # sched: [5:1.00]
; BTVER2-NEXT:    movq %rsi, %rcx # sched: [1:0.50]
; BTVER2-NEXT:    shlq %cl, %rax # sched: [1:0.50]
; BTVER2-NEXT:    negl %ecx # sched: [1:0.50]
; BTVER2-NEXT:    # kill: def $cl killed $cl killed $rcx
; BTVER2-NEXT:    shrq %cl, %rdi # sched: [1:0.50]
; BTVER2-NEXT:    orq %rax, %rdi # sched: [1:0.50]
; BTVER2-NEXT:    movq %rdi, {{.*}}(%rip) # sched: [1:1.00]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; BDVER1-LABEL: lshift_mem_cl:
; BDVER1:       # %bb.0: # %entry
; BDVER1-NEXT:    movq %rsi, %rcx
; BDVER1-NEXT:    movq {{.*}}(%rip), %rax
; BDVER1-NEXT:    shlq %cl, %rax
; BDVER1-NEXT:    negl %ecx
; BDVER1-NEXT:    # kill: def $cl killed $cl killed $rcx
; BDVER1-NEXT:    shrq %cl, %rdi
; BDVER1-NEXT:    orq %rax, %rdi
; BDVER1-NEXT:    movq %rdi, {{.*}}(%rip)
; BDVER1-NEXT:    retq
entry:
  %b = load i64, i64* @x
  %shl = shl i64 %b, %c
  %sub = sub nsw i64 64, %c
  %shr = lshr i64 %a, %sub
  %or = or i64 %shl, %shr
  store i64 %or, i64* @x
  ret void
}

define void @lshift_mem(i64 %a) nounwind readnone {
; GENERIC-LABEL: lshift_mem:
; GENERIC:       # %bb.0: # %entry
; GENERIC-NEXT:    shldq $10, %rdi, {{.*}}(%rip) # sched: [8:1.00]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; BTVER2-LABEL: lshift_mem:
; BTVER2:       # %bb.0: # %entry
; BTVER2-NEXT:    movq {{.*}}(%rip), %rax # sched: [5:1.00]
; BTVER2-NEXT:    shrq $54, %rdi # sched: [1:0.50]
; BTVER2-NEXT:    shlq $10, %rax # sched: [1:0.50]
; BTVER2-NEXT:    orq %rax, %rdi # sched: [1:0.50]
; BTVER2-NEXT:    movq %rdi, {{.*}}(%rip) # sched: [1:1.00]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; BDVER1-LABEL: lshift_mem:
; BDVER1:       # %bb.0: # %entry
; BDVER1-NEXT:    movq {{.*}}(%rip), %rax
; BDVER1-NEXT:    shlq $10, %rax
; BDVER1-NEXT:    shrq $54, %rdi
; BDVER1-NEXT:    orq %rax, %rdi
; BDVER1-NEXT:    movq %rdi, {{.*}}(%rip)
; BDVER1-NEXT:    retq
entry:
  %b = load i64, i64* @x
  %shl = shl i64 %b, 10
  %shr = lshr i64 %a, 54
  %or = or i64 %shr, %shl
  store i64 %or, i64* @x
  ret void
}

define void @lshift_mem_optsize(i64 %a) nounwind readnone optsize {
; GENERIC-LABEL: lshift_mem_optsize:
; GENERIC:       # %bb.0: # %entry
; GENERIC-NEXT:    shldq $10, %rdi, {{.*}}(%rip) # sched: [8:1.00]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; BTVER2-LABEL: lshift_mem_optsize:
; BTVER2:       # %bb.0: # %entry
; BTVER2-NEXT:    shldq $10, %rdi, {{.*}}(%rip) # sched: [9:11.00]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; BDVER1-LABEL: lshift_mem_optsize:
; BDVER1:       # %bb.0: # %entry
; BDVER1-NEXT:    shldq $10, %rdi, {{.*}}(%rip)
; BDVER1-NEXT:    retq
entry:
  %b = load i64, i64* @x
  %shl = shl i64 %b, 10
  %shr = lshr i64 %a, 54
  %or = or i64 %shr, %shl
  store i64 %or, i64* @x
  ret void
}

define void @lshift_mem_b(i64 %b) nounwind readnone {
; GENERIC-LABEL: lshift_mem_b:
; GENERIC:       # %bb.0: # %entry
; GENERIC-NEXT:    movq {{.*}}(%rip), %rax # sched: [5:0.50]
; GENERIC-NEXT:    shrdq $54, %rdi, %rax # sched: [2:0.67]
; GENERIC-NEXT:    movq %rax, {{.*}}(%rip) # sched: [1:1.00]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; BTVER2-LABEL: lshift_mem_b:
; BTVER2:       # %bb.0: # %entry
; BTVER2-NEXT:    movq {{.*}}(%rip), %rax # sched: [5:1.00]
; BTVER2-NEXT:    shlq $10, %rdi # sched: [1:0.50]
; BTVER2-NEXT:    shrq $54, %rax # sched: [1:0.50]
; BTVER2-NEXT:    orq %rdi, %rax # sched: [1:0.50]
; BTVER2-NEXT:    movq %rax, {{.*}}(%rip) # sched: [1:1.00]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; BDVER1-LABEL: lshift_mem_b:
; BDVER1:       # %bb.0: # %entry
; BDVER1-NEXT:    movq {{.*}}(%rip), %rax
; BDVER1-NEXT:    shlq $10, %rdi
; BDVER1-NEXT:    shrq $54, %rax
; BDVER1-NEXT:    orq %rdi, %rax
; BDVER1-NEXT:    movq %rax, {{.*}}(%rip)
; BDVER1-NEXT:    retq
entry:
  %a = load i64, i64* @x
  %shl = shl i64 %b, 10
  %shr = lshr i64 %a, 54
  %or = or i64 %shr, %shl
  store i64 %or, i64* @x
  ret void
}

define void @lshift_mem_b_optsize(i64 %b) nounwind readnone optsize {
; GENERIC-LABEL: lshift_mem_b_optsize:
; GENERIC:       # %bb.0: # %entry
; GENERIC-NEXT:    movq {{.*}}(%rip), %rax # sched: [5:0.50]
; GENERIC-NEXT:    shrdq $54, %rdi, %rax # sched: [2:0.67]
; GENERIC-NEXT:    movq %rax, {{.*}}(%rip) # sched: [1:1.00]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; BTVER2-LABEL: lshift_mem_b_optsize:
; BTVER2:       # %bb.0: # %entry
; BTVER2-NEXT:    movq {{.*}}(%rip), %rax # sched: [5:1.00]
; BTVER2-NEXT:    shrdq $54, %rdi, %rax # sched: [3:3.00]
; BTVER2-NEXT:    movq %rax, {{.*}}(%rip) # sched: [1:1.00]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; BDVER1-LABEL: lshift_mem_b_optsize:
; BDVER1:       # %bb.0: # %entry
; BDVER1-NEXT:    movq {{.*}}(%rip), %rax
; BDVER1-NEXT:    shrdq $54, %rdi, %rax
; BDVER1-NEXT:    movq %rax, {{.*}}(%rip)
; BDVER1-NEXT:    retq
entry:
  %a = load i64, i64* @x
  %shl = shl i64 %b, 10
  %shr = lshr i64 %a, 54
  %or = or i64 %shr, %shl
  store i64 %or, i64* @x
  ret void
}

