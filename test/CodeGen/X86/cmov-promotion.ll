; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+cmov | FileCheck %s --check-prefix=CMOV
; RUN: llc < %s -mtriple=i686-unknown-unknown   -mattr=-cmov | FileCheck %s --check-prefix=NO_CMOV

define i16 @cmov_zpromotion_8_to_16(i1 %c) {
; CMOV-LABEL: cmov_zpromotion_8_to_16:
; CMOV:       # BB#0:
; CMOV-NEXT:    testb $1, %dil
; CMOV-NEXT:    movb $117, %al
; CMOV-NEXT:    jne .LBB0_2
; CMOV-NEXT:  # BB#1:
; CMOV-NEXT:    movb $-19, %al
; CMOV-NEXT:  .LBB0_2:
; CMOV-NEXT:    movzbl %al, %eax
; CMOV-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; CMOV-NEXT:    retq
;
; NO_CMOV-LABEL: cmov_zpromotion_8_to_16:
; NO_CMOV:       # BB#0:
; NO_CMOV-NEXT:    testb $1, {{[0-9]+}}(%esp)
; NO_CMOV-NEXT:    movb $117, %al
; NO_CMOV-NEXT:    jne .LBB0_2
; NO_CMOV-NEXT:  # BB#1:
; NO_CMOV-NEXT:    movb $-19, %al
; NO_CMOV-NEXT:  .LBB0_2:
; NO_CMOV-NEXT:    movzbl %al, %eax
; NO_CMOV-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; NO_CMOV-NEXT:    retl
  %t0 = select i1 %c, i8 117, i8 -19
  %ret = zext i8 %t0 to i16
  ret i16 %ret
}

define i32 @cmov_zpromotion_8_to_32(i1 %c) {
; CMOV-LABEL: cmov_zpromotion_8_to_32:
; CMOV:       # BB#0:
; CMOV-NEXT:    testb $1, %dil
; CMOV-NEXT:    movb $126, %al
; CMOV-NEXT:    jne .LBB1_2
; CMOV-NEXT:  # BB#1:
; CMOV-NEXT:    movb $-1, %al
; CMOV-NEXT:  .LBB1_2:
; CMOV-NEXT:    movzbl %al, %eax
; CMOV-NEXT:    retq
;
; NO_CMOV-LABEL: cmov_zpromotion_8_to_32:
; NO_CMOV:       # BB#0:
; NO_CMOV-NEXT:    testb $1, {{[0-9]+}}(%esp)
; NO_CMOV-NEXT:    movb $126, %al
; NO_CMOV-NEXT:    jne .LBB1_2
; NO_CMOV-NEXT:  # BB#1:
; NO_CMOV-NEXT:    movb $-1, %al
; NO_CMOV-NEXT:  .LBB1_2:
; NO_CMOV-NEXT:    movzbl %al, %eax
; NO_CMOV-NEXT:    retl
  %t0 = select i1 %c, i8 12414, i8 -1
  %ret = zext i8 %t0 to i32
  ret i32 %ret
}

define i64 @cmov_zpromotion_8_to_64(i1 %c) {
; CMOV-LABEL: cmov_zpromotion_8_to_64:
; CMOV:       # BB#0:
; CMOV-NEXT:    testb $1, %dil
; CMOV-NEXT:    movb $126, %al
; CMOV-NEXT:    jne .LBB2_2
; CMOV-NEXT:  # BB#1:
; CMOV-NEXT:    movb $-1, %al
; CMOV-NEXT:  .LBB2_2:
; CMOV-NEXT:    movzbl %al, %eax
; CMOV-NEXT:    retq
;
; NO_CMOV-LABEL: cmov_zpromotion_8_to_64:
; NO_CMOV:       # BB#0:
; NO_CMOV-NEXT:    testb $1, {{[0-9]+}}(%esp)
; NO_CMOV-NEXT:    movb $126, %al
; NO_CMOV-NEXT:    jne .LBB2_2
; NO_CMOV-NEXT:  # BB#1:
; NO_CMOV-NEXT:    movb $-1, %al
; NO_CMOV-NEXT:  .LBB2_2:
; NO_CMOV-NEXT:    movzbl %al, %eax
; NO_CMOV-NEXT:    xorl %edx, %edx
; NO_CMOV-NEXT:    retl
  %t0 = select i1 %c, i8 12414, i8 -1
  %ret = zext i8 %t0 to i64
  ret i64 %ret
}

define i32 @cmov_zpromotion_16_to_32(i1 %c) {
; CMOV-LABEL: cmov_zpromotion_16_to_32:
; CMOV:       # BB#0:
; CMOV-NEXT:    testb $1, %dil
; CMOV-NEXT:    movw $12414, %ax # imm = 0x307E
; CMOV-NEXT:    movw $-1, %cx
; CMOV-NEXT:    cmovnew %ax, %cx
; CMOV-NEXT:    movzwl %cx, %eax
; CMOV-NEXT:    retq
;
; NO_CMOV-LABEL: cmov_zpromotion_16_to_32:
; NO_CMOV:       # BB#0:
; NO_CMOV-NEXT:    testb $1, {{[0-9]+}}(%esp)
; NO_CMOV-NEXT:    movw $12414, %ax # imm = 0x307E
; NO_CMOV-NEXT:    jne .LBB3_2
; NO_CMOV-NEXT:  # BB#1:
; NO_CMOV-NEXT:    movw $-1, %ax
; NO_CMOV-NEXT:  .LBB3_2:
; NO_CMOV-NEXT:    movzwl %ax, %eax
; NO_CMOV-NEXT:    retl
  %t0 = select i1 %c, i16 12414, i16 -1
  %ret = zext i16 %t0 to i32
  ret i32 %ret
}

define i64 @cmov_zpromotion_16_to_64(i1 %c) {
; CMOV-LABEL: cmov_zpromotion_16_to_64:
; CMOV:       # BB#0:
; CMOV-NEXT:    testb $1, %dil
; CMOV-NEXT:    movw $12414, %ax # imm = 0x307E
; CMOV-NEXT:    movw $-1, %cx
; CMOV-NEXT:    cmovnew %ax, %cx
; CMOV-NEXT:    movzwl %cx, %eax
; CMOV-NEXT:    retq
;
; NO_CMOV-LABEL: cmov_zpromotion_16_to_64:
; NO_CMOV:       # BB#0:
; NO_CMOV-NEXT:    testb $1, {{[0-9]+}}(%esp)
; NO_CMOV-NEXT:    movw $12414, %ax # imm = 0x307E
; NO_CMOV-NEXT:    jne .LBB4_2
; NO_CMOV-NEXT:  # BB#1:
; NO_CMOV-NEXT:    movw $-1, %ax
; NO_CMOV-NEXT:  .LBB4_2:
; NO_CMOV-NEXT:    movzwl %ax, %eax
; NO_CMOV-NEXT:    xorl %edx, %edx
; NO_CMOV-NEXT:    retl
  %t0 = select i1 %c, i16 12414, i16 -1
  %ret = zext i16 %t0 to i64
  ret i64 %ret
}

define i64 @cmov_zpromotion_32_to_64(i1 %c) {
; CMOV-LABEL: cmov_zpromotion_32_to_64:
; CMOV:       # BB#0:
; CMOV-NEXT:    testb $1, %dil
; CMOV-NEXT:    movl $12414, %ecx # imm = 0x307E
; CMOV-NEXT:    movl $-1, %eax
; CMOV-NEXT:    cmovnel %ecx, %eax
; CMOV-NEXT:    retq
;
; NO_CMOV-LABEL: cmov_zpromotion_32_to_64:
; NO_CMOV:       # BB#0:
; NO_CMOV-NEXT:    testb $1, {{[0-9]+}}(%esp)
; NO_CMOV-NEXT:    movl $12414, %eax # imm = 0x307E
; NO_CMOV-NEXT:    jne .LBB5_2
; NO_CMOV-NEXT:  # BB#1:
; NO_CMOV-NEXT:    movl $-1, %eax
; NO_CMOV-NEXT:  .LBB5_2:
; NO_CMOV-NEXT:    xorl %edx, %edx
; NO_CMOV-NEXT:    retl
  %t0 = select i1 %c, i32 12414, i32 -1
  %ret = zext i32 %t0 to i64
  ret i64 %ret
}

define i16 @cmov_spromotion_8_to_16(i1 %c) {
; CMOV-LABEL: cmov_spromotion_8_to_16:
; CMOV:       # BB#0:
; CMOV-NEXT:    testb $1, %dil
; CMOV-NEXT:    movb $117, %al
; CMOV-NEXT:    jne .LBB6_2
; CMOV-NEXT:  # BB#1:
; CMOV-NEXT:    movb $-19, %al
; CMOV-NEXT:  .LBB6_2:
; CMOV-NEXT:    movsbl %al, %eax
; CMOV-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; CMOV-NEXT:    retq
;
; NO_CMOV-LABEL: cmov_spromotion_8_to_16:
; NO_CMOV:       # BB#0:
; NO_CMOV-NEXT:    testb $1, {{[0-9]+}}(%esp)
; NO_CMOV-NEXT:    movb $117, %al
; NO_CMOV-NEXT:    jne .LBB6_2
; NO_CMOV-NEXT:  # BB#1:
; NO_CMOV-NEXT:    movb $-19, %al
; NO_CMOV-NEXT:  .LBB6_2:
; NO_CMOV-NEXT:    movsbl %al, %eax
; NO_CMOV-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; NO_CMOV-NEXT:    retl
  %t0 = select i1 %c, i8 117, i8 -19
  %ret = sext i8 %t0 to i16
  ret i16 %ret
}

define i32 @cmov_spromotion_8_to_32(i1 %c) {
; CMOV-LABEL: cmov_spromotion_8_to_32:
; CMOV:       # BB#0:
; CMOV-NEXT:    testb $1, %dil
; CMOV-NEXT:    movb $126, %al
; CMOV-NEXT:    jne .LBB7_2
; CMOV-NEXT:  # BB#1:
; CMOV-NEXT:    movb $-1, %al
; CMOV-NEXT:  .LBB7_2:
; CMOV-NEXT:    movsbl %al, %eax
; CMOV-NEXT:    retq
;
; NO_CMOV-LABEL: cmov_spromotion_8_to_32:
; NO_CMOV:       # BB#0:
; NO_CMOV-NEXT:    testb $1, {{[0-9]+}}(%esp)
; NO_CMOV-NEXT:    movb $126, %al
; NO_CMOV-NEXT:    jne .LBB7_2
; NO_CMOV-NEXT:  # BB#1:
; NO_CMOV-NEXT:    movb $-1, %al
; NO_CMOV-NEXT:  .LBB7_2:
; NO_CMOV-NEXT:    movsbl %al, %eax
; NO_CMOV-NEXT:    retl
  %t0 = select i1 %c, i8 12414, i8 -1
  %ret = sext i8 %t0 to i32
  ret i32 %ret
}

define i64 @cmov_spromotion_8_to_64(i1 %c) {
; CMOV-LABEL: cmov_spromotion_8_to_64:
; CMOV:       # BB#0:
; CMOV-NEXT:    testb $1, %dil
; CMOV-NEXT:    movb $126, %al
; CMOV-NEXT:    jne .LBB8_2
; CMOV-NEXT:  # BB#1:
; CMOV-NEXT:    movb $-1, %al
; CMOV-NEXT:  .LBB8_2:
; CMOV-NEXT:    movsbq %al, %rax
; CMOV-NEXT:    retq
;
; NO_CMOV-LABEL: cmov_spromotion_8_to_64:
; NO_CMOV:       # BB#0:
; NO_CMOV-NEXT:    testb $1, {{[0-9]+}}(%esp)
; NO_CMOV-NEXT:    movb $126, %al
; NO_CMOV-NEXT:    jne .LBB8_2
; NO_CMOV-NEXT:  # BB#1:
; NO_CMOV-NEXT:    movb $-1, %al
; NO_CMOV-NEXT:  .LBB8_2:
; NO_CMOV-NEXT:    movsbl %al, %eax
; NO_CMOV-NEXT:    movl %eax, %edx
; NO_CMOV-NEXT:    sarl $31, %edx
; NO_CMOV-NEXT:    retl
  %t0 = select i1 %c, i8 12414, i8 -1
  %ret = sext i8 %t0 to i64
  ret i64 %ret
}

define i32 @cmov_spromotion_16_to_32(i1 %c) {
; CMOV-LABEL: cmov_spromotion_16_to_32:
; CMOV:       # BB#0:
; CMOV-NEXT:    testb $1, %dil
; CMOV-NEXT:    movw $12414, %ax # imm = 0x307E
; CMOV-NEXT:    movw $-1, %cx
; CMOV-NEXT:    cmovnew %ax, %cx
; CMOV-NEXT:    movswl %cx, %eax
; CMOV-NEXT:    retq
;
; NO_CMOV-LABEL: cmov_spromotion_16_to_32:
; NO_CMOV:       # BB#0:
; NO_CMOV-NEXT:    testb $1, {{[0-9]+}}(%esp)
; NO_CMOV-NEXT:    movw $12414, %ax # imm = 0x307E
; NO_CMOV-NEXT:    jne .LBB9_2
; NO_CMOV-NEXT:  # BB#1:
; NO_CMOV-NEXT:    movw $-1, %ax
; NO_CMOV-NEXT:  .LBB9_2:
; NO_CMOV-NEXT:    cwtl
; NO_CMOV-NEXT:    retl
  %t0 = select i1 %c, i16 12414, i16 -1
  %ret = sext i16 %t0 to i32
  ret i32 %ret
}

define i64 @cmov_spromotion_16_to_64(i1 %c) {
; CMOV-LABEL: cmov_spromotion_16_to_64:
; CMOV:       # BB#0:
; CMOV-NEXT:    testb $1, %dil
; CMOV-NEXT:    movw $12414, %ax # imm = 0x307E
; CMOV-NEXT:    movw $-1, %cx
; CMOV-NEXT:    cmovnew %ax, %cx
; CMOV-NEXT:    movswq %cx, %rax
; CMOV-NEXT:    retq
;
; NO_CMOV-LABEL: cmov_spromotion_16_to_64:
; NO_CMOV:       # BB#0:
; NO_CMOV-NEXT:    testb $1, {{[0-9]+}}(%esp)
; NO_CMOV-NEXT:    movw $12414, %ax # imm = 0x307E
; NO_CMOV-NEXT:    jne .LBB10_2
; NO_CMOV-NEXT:  # BB#1:
; NO_CMOV-NEXT:    movw $-1, %ax
; NO_CMOV-NEXT:  .LBB10_2:
; NO_CMOV-NEXT:    cwtl
; NO_CMOV-NEXT:    movl %eax, %edx
; NO_CMOV-NEXT:    sarl $31, %edx
; NO_CMOV-NEXT:    retl
  %t0 = select i1 %c, i16 12414, i16 -1
  %ret = sext i16 %t0 to i64
  ret i64 %ret
}

define i64 @cmov_spromotion_32_to_64(i1 %c) {
; CMOV-LABEL: cmov_spromotion_32_to_64:
; CMOV:       # BB#0:
; CMOV-NEXT:    testb $1, %dil
; CMOV-NEXT:    movl $12414, %eax # imm = 0x307E
; CMOV-NEXT:    movl $-1, %ecx
; CMOV-NEXT:    cmovnel %eax, %ecx
; CMOV-NEXT:    movslq %ecx, %rax
; CMOV-NEXT:    retq
;
; NO_CMOV-LABEL: cmov_spromotion_32_to_64:
; NO_CMOV:       # BB#0:
; NO_CMOV-NEXT:    testb $1, {{[0-9]+}}(%esp)
; NO_CMOV-NEXT:    movl $12414, %eax # imm = 0x307E
; NO_CMOV-NEXT:    jne .LBB11_2
; NO_CMOV-NEXT:  # BB#1:
; NO_CMOV-NEXT:    movl $-1, %eax
; NO_CMOV-NEXT:  .LBB11_2:
; NO_CMOV-NEXT:    movl %eax, %edx
; NO_CMOV-NEXT:    sarl $31, %edx
; NO_CMOV-NEXT:    retl
  %t0 = select i1 %c, i32 12414, i32 -1
  %ret = sext i32 %t0 to i64
  ret i64 %ret
}
