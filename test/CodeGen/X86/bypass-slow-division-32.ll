; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; Check that 32-bit division is bypassed correctly.
; RUN: llc < %s -mattr=+idivl-to-divb -mtriple=i686-linux | FileCheck %s

define i32 @Test_get_quotient(i32 %a, i32 %b) nounwind {
; CHECK-LABEL: Test_get_quotient:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    movl %eax, %edx
; CHECK-NEXT:    orl %ecx, %edx
; CHECK-NEXT:    testl $-256, %edx
; CHECK-NEXT:    je .LBB0_1
; CHECK-NEXT:  # %bb.2:
; CHECK-NEXT:    cltd
; CHECK-NEXT:    idivl %ecx
; CHECK-NEXT:    retl
; CHECK-NEXT:  .LBB0_1:
; CHECK-NEXT:    movzbl %al, %eax
; CHECK-NEXT:    # kill: def %eax killed %eax def %ax
; CHECK-NEXT:    divb %cl
; CHECK-NEXT:    movzbl %al, %eax
; CHECK-NEXT:    retl
  %result = sdiv i32 %a, %b
  ret i32 %result
}

define i32 @Test_get_remainder(i32 %a, i32 %b) nounwind {
; CHECK-LABEL: Test_get_remainder:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    movl %eax, %edx
; CHECK-NEXT:    orl %ecx, %edx
; CHECK-NEXT:    testl $-256, %edx
; CHECK-NEXT:    je .LBB1_1
; CHECK-NEXT:  # %bb.2:
; CHECK-NEXT:    cltd
; CHECK-NEXT:    idivl %ecx
; CHECK-NEXT:    movl %edx, %eax
; CHECK-NEXT:    retl
; CHECK-NEXT:  .LBB1_1:
; CHECK-NEXT:    movzbl %al, %eax
; CHECK-NEXT:    # kill: def %eax killed %eax def %ax
; CHECK-NEXT:    divb %cl
; CHECK-NEXT:    movzbl %ah, %eax # NOREX
; CHECK-NEXT:    retl
  %result = srem i32 %a, %b
  ret i32 %result
}

define i32 @Test_get_quotient_and_remainder(i32 %a, i32 %b) nounwind {
; CHECK-LABEL: Test_get_quotient_and_remainder:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    movl %eax, %edx
; CHECK-NEXT:    orl %ecx, %edx
; CHECK-NEXT:    testl $-256, %edx
; CHECK-NEXT:    je .LBB2_1
; CHECK-NEXT:  # %bb.2:
; CHECK-NEXT:    cltd
; CHECK-NEXT:    idivl %ecx
; CHECK-NEXT:    addl %edx, %eax
; CHECK-NEXT:    retl
; CHECK-NEXT:  .LBB2_1:
; CHECK-NEXT:    movzbl %al, %eax
; CHECK-NEXT:    # kill: def %eax killed %eax def %ax
; CHECK-NEXT:    divb %cl
; CHECK-NEXT:    movzbl %ah, %edx # NOREX
; CHECK-NEXT:    movzbl %al, %eax
; CHECK-NEXT:    addl %edx, %eax
; CHECK-NEXT:    retl
  %resultdiv = sdiv i32 %a, %b
  %resultrem = srem i32 %a, %b
  %result = add i32 %resultdiv, %resultrem
  ret i32 %result
}

define i32 @Test_use_div_and_idiv(i32 %a, i32 %b) nounwind {
; CHECK-LABEL: Test_use_div_and_idiv:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pushl %ebx
; CHECK-NEXT:    pushl %edi
; CHECK-NEXT:    pushl %esi
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %ebx
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; CHECK-NEXT:    movl %ecx, %edi
; CHECK-NEXT:    orl %ebx, %edi
; CHECK-NEXT:    testl $-256, %edi
; CHECK-NEXT:    je .LBB3_1
; CHECK-NEXT:  # %bb.2:
; CHECK-NEXT:    movl %ecx, %eax
; CHECK-NEXT:    cltd
; CHECK-NEXT:    idivl %ebx
; CHECK-NEXT:    movl %eax, %esi
; CHECK-NEXT:    testl $-256, %edi
; CHECK-NEXT:    je .LBB3_4
; CHECK-NEXT:  .LBB3_5:
; CHECK-NEXT:    xorl %edx, %edx
; CHECK-NEXT:    movl %ecx, %eax
; CHECK-NEXT:    divl %ebx
; CHECK-NEXT:    jmp .LBB3_6
; CHECK-NEXT:  .LBB3_1:
; CHECK-NEXT:    movzbl %cl, %eax
; CHECK-NEXT:    # kill: def %eax killed %eax def %ax
; CHECK-NEXT:    divb %bl
; CHECK-NEXT:    movzbl %al, %esi
; CHECK-NEXT:    testl $-256, %edi
; CHECK-NEXT:    jne .LBB3_5
; CHECK-NEXT:  .LBB3_4:
; CHECK-NEXT:    movzbl %cl, %eax
; CHECK-NEXT:    # kill: def %eax killed %eax def %ax
; CHECK-NEXT:    divb %bl
; CHECK-NEXT:    movzbl %al, %eax
; CHECK-NEXT:  .LBB3_6:
; CHECK-NEXT:    addl %eax, %esi
; CHECK-NEXT:    movl %esi, %eax
; CHECK-NEXT:    popl %esi
; CHECK-NEXT:    popl %edi
; CHECK-NEXT:    popl %ebx
; CHECK-NEXT:    retl
  %resultidiv = sdiv i32 %a, %b
  %resultdiv = udiv i32 %a, %b
  %result = add i32 %resultidiv, %resultdiv
  ret i32 %result
}

define i32 @Test_use_div_imm_imm() nounwind {
; CHECK-LABEL: Test_use_div_imm_imm:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl $64, %eax
; CHECK-NEXT:    retl
  %resultdiv = sdiv i32 256, 4
  ret i32 %resultdiv
}

define i32 @Test_use_div_reg_imm(i32 %a) nounwind {
; CHECK-LABEL: Test_use_div_reg_imm:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl $1041204193, %eax # imm = 0x3E0F83E1
; CHECK-NEXT:    imull {{[0-9]+}}(%esp)
; CHECK-NEXT:    movl %edx, %eax
; CHECK-NEXT:    shrl $31, %eax
; CHECK-NEXT:    sarl $3, %edx
; CHECK-NEXT:    leal (%edx,%eax), %eax
; CHECK-NEXT:    retl
  %resultdiv = sdiv i32 %a, 33
  ret i32 %resultdiv
}

define i32 @Test_use_rem_reg_imm(i32 %a) nounwind {
; CHECK-LABEL: Test_use_rem_reg_imm:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; CHECK-NEXT:    movl $1041204193, %edx # imm = 0x3E0F83E1
; CHECK-NEXT:    movl %ecx, %eax
; CHECK-NEXT:    imull %edx
; CHECK-NEXT:    movl %edx, %eax
; CHECK-NEXT:    shrl $31, %eax
; CHECK-NEXT:    sarl $3, %edx
; CHECK-NEXT:    addl %eax, %edx
; CHECK-NEXT:    movl %edx, %eax
; CHECK-NEXT:    shll $5, %eax
; CHECK-NEXT:    addl %edx, %eax
; CHECK-NEXT:    subl %eax, %ecx
; CHECK-NEXT:    movl %ecx, %eax
; CHECK-NEXT:    retl
  %resultrem = srem i32 %a, 33
  ret i32 %resultrem
}

define i32 @Test_use_divrem_reg_imm(i32 %a) nounwind {
; CHECK-LABEL: Test_use_divrem_reg_imm:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; CHECK-NEXT:    movl $1041204193, %edx # imm = 0x3E0F83E1
; CHECK-NEXT:    movl %ecx, %eax
; CHECK-NEXT:    imull %edx
; CHECK-NEXT:    movl %edx, %eax
; CHECK-NEXT:    shrl $31, %eax
; CHECK-NEXT:    sarl $3, %edx
; CHECK-NEXT:    addl %eax, %edx
; CHECK-NEXT:    movl %edx, %eax
; CHECK-NEXT:    shll $5, %eax
; CHECK-NEXT:    addl %edx, %eax
; CHECK-NEXT:    subl %eax, %ecx
; CHECK-NEXT:    addl %edx, %ecx
; CHECK-NEXT:    movl %ecx, %eax
; CHECK-NEXT:    retl
  %resultdiv = sdiv i32 %a, 33
  %resultrem = srem i32 %a, 33
  %result = add i32 %resultdiv, %resultrem
  ret i32 %result
}

define i32 @Test_use_div_imm_reg(i32 %a) nounwind {
; CHECK-LABEL: Test_use_div_imm_reg:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; CHECK-NEXT:    testl $-256, %ecx
; CHECK-NEXT:    je .LBB8_1
; CHECK-NEXT:  # %bb.2:
; CHECK-NEXT:    movl $4, %eax
; CHECK-NEXT:    xorl %edx, %edx
; CHECK-NEXT:    idivl %ecx
; CHECK-NEXT:    retl
; CHECK-NEXT:  .LBB8_1:
; CHECK-NEXT:    movb $4, %al
; CHECK-NEXT:    movzbl %al, %eax
; CHECK-NEXT:    # kill: def %eax killed %eax def %ax
; CHECK-NEXT:    divb %cl
; CHECK-NEXT:    movzbl %al, %eax
; CHECK-NEXT:    retl
  %resultdiv = sdiv i32 4, %a
  ret i32 %resultdiv
}

define i32 @Test_use_rem_imm_reg(i32 %a) nounwind {
; CHECK-LABEL: Test_use_rem_imm_reg:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; CHECK-NEXT:    testl $-256, %ecx
; CHECK-NEXT:    je .LBB9_1
; CHECK-NEXT:  # %bb.2:
; CHECK-NEXT:    movl $4, %eax
; CHECK-NEXT:    xorl %edx, %edx
; CHECK-NEXT:    idivl %ecx
; CHECK-NEXT:    retl
; CHECK-NEXT:  .LBB9_1:
; CHECK-NEXT:    movb $4, %al
; CHECK-NEXT:    movzbl %al, %eax
; CHECK-NEXT:    # kill: def %eax killed %eax def %ax
; CHECK-NEXT:    divb %cl
; CHECK-NEXT:    movzbl %al, %eax
; CHECK-NEXT:    retl
  %resultdiv = sdiv i32 4, %a
  ret i32 %resultdiv
}
