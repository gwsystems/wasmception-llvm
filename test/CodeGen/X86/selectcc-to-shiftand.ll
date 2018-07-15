; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=x86_64-unknown-linux-gnu -mattr=-bmi < %s | FileCheck %s --check-prefix=CHECK-NOBMI
; RUN: llc -mtriple=x86_64-unknown-linux-gnu -mattr=+bmi < %s | FileCheck %s --check-prefix=CHECK-BMI

; Compare if negative and select of constants where one constant is zero.

define i32 @neg_sel_constants(i32 %a) {
; CHECK-NOBMI-LABEL: neg_sel_constants:
; CHECK-NOBMI:       # %bb.0:
; CHECK-NOBMI-NEXT:    sarl $31, %edi
; CHECK-NOBMI-NEXT:    andl $5, %edi
; CHECK-NOBMI-NEXT:    movl %edi, %eax
; CHECK-NOBMI-NEXT:    retq
;
; CHECK-BMI-LABEL: neg_sel_constants:
; CHECK-BMI:       # %bb.0:
; CHECK-BMI-NEXT:    sarl $31, %edi
; CHECK-BMI-NEXT:    andl $5, %edi
; CHECK-BMI-NEXT:    movl %edi, %eax
; CHECK-BMI-NEXT:    retq
  %tmp.1 = icmp slt i32 %a, 0
  %retval = select i1 %tmp.1, i32 5, i32 0
  ret i32 %retval
}

; Compare if negative and select of constants where one constant is zero and the other is a single bit.

define i32 @neg_sel_special_constant(i32 %a) {
; CHECK-NOBMI-LABEL: neg_sel_special_constant:
; CHECK-NOBMI:       # %bb.0:
; CHECK-NOBMI-NEXT:    shrl $22, %edi
; CHECK-NOBMI-NEXT:    andl $512, %edi # imm = 0x200
; CHECK-NOBMI-NEXT:    movl %edi, %eax
; CHECK-NOBMI-NEXT:    retq
;
; CHECK-BMI-LABEL: neg_sel_special_constant:
; CHECK-BMI:       # %bb.0:
; CHECK-BMI-NEXT:    shrl $22, %edi
; CHECK-BMI-NEXT:    andl $512, %edi # imm = 0x200
; CHECK-BMI-NEXT:    movl %edi, %eax
; CHECK-BMI-NEXT:    retq
  %tmp.1 = icmp slt i32 %a, 0
  %retval = select i1 %tmp.1, i32 512, i32 0
  ret i32 %retval
}

; Compare if negative and select variable or zero.

define i32 @neg_sel_variable_and_zero(i32 %a, i32 %b) {
; CHECK-NOBMI-LABEL: neg_sel_variable_and_zero:
; CHECK-NOBMI:       # %bb.0:
; CHECK-NOBMI-NEXT:    sarl $31, %edi
; CHECK-NOBMI-NEXT:    andl %esi, %edi
; CHECK-NOBMI-NEXT:    movl %edi, %eax
; CHECK-NOBMI-NEXT:    retq
;
; CHECK-BMI-LABEL: neg_sel_variable_and_zero:
; CHECK-BMI:       # %bb.0:
; CHECK-BMI-NEXT:    sarl $31, %edi
; CHECK-BMI-NEXT:    andl %esi, %edi
; CHECK-BMI-NEXT:    movl %edi, %eax
; CHECK-BMI-NEXT:    retq
  %tmp.1 = icmp slt i32 %a, 0
  %retval = select i1 %tmp.1, i32 %b, i32 0
  ret i32 %retval
}

; Compare if not positive and select the same variable as being compared: smin(a, 0).

define i32 @not_pos_sel_same_variable(i32 %a) {
; CHECK-NOBMI-LABEL: not_pos_sel_same_variable:
; CHECK-NOBMI:       # %bb.0:
; CHECK-NOBMI-NEXT:    movl %edi, %eax
; CHECK-NOBMI-NEXT:    sarl $31, %eax
; CHECK-NOBMI-NEXT:    andl %edi, %eax
; CHECK-NOBMI-NEXT:    retq
;
; CHECK-BMI-LABEL: not_pos_sel_same_variable:
; CHECK-BMI:       # %bb.0:
; CHECK-BMI-NEXT:    movl %edi, %eax
; CHECK-BMI-NEXT:    sarl $31, %eax
; CHECK-BMI-NEXT:    andl %edi, %eax
; CHECK-BMI-NEXT:    retq
  %tmp = icmp slt i32 %a, 1
  %min = select i1 %tmp, i32 %a, i32 0
  ret i32 %min
}

; Flipping the comparison condition can be handled by getting the bitwise not of the sign mask.

; Compare if positive and select of constants where one constant is zero.

define i32 @pos_sel_constants(i32 %a) {
; CHECK-NOBMI-LABEL: pos_sel_constants:
; CHECK-NOBMI:       # %bb.0:
; CHECK-NOBMI-NEXT:    # kill: def $edi killed $edi def $rdi
; CHECK-NOBMI-NEXT:    notl %edi
; CHECK-NOBMI-NEXT:    shrl $31, %edi
; CHECK-NOBMI-NEXT:    leal (%rdi,%rdi,4), %eax
; CHECK-NOBMI-NEXT:    retq
;
; CHECK-BMI-LABEL: pos_sel_constants:
; CHECK-BMI:       # %bb.0:
; CHECK-BMI-NEXT:    # kill: def $edi killed $edi def $rdi
; CHECK-BMI-NEXT:    notl %edi
; CHECK-BMI-NEXT:    shrl $31, %edi
; CHECK-BMI-NEXT:    leal (%rdi,%rdi,4), %eax
; CHECK-BMI-NEXT:    retq
  %tmp.1 = icmp sgt i32 %a, -1
  %retval = select i1 %tmp.1, i32 5, i32 0
  ret i32 %retval
}

; Compare if positive and select of constants where one constant is zero and the other is a single bit.

define i32 @pos_sel_special_constant(i32 %a) {
; CHECK-NOBMI-LABEL: pos_sel_special_constant:
; CHECK-NOBMI:       # %bb.0:
; CHECK-NOBMI-NEXT:    notl %edi
; CHECK-NOBMI-NEXT:    shrl $22, %edi
; CHECK-NOBMI-NEXT:    andl $512, %edi # imm = 0x200
; CHECK-NOBMI-NEXT:    movl %edi, %eax
; CHECK-NOBMI-NEXT:    retq
;
; CHECK-BMI-LABEL: pos_sel_special_constant:
; CHECK-BMI:       # %bb.0:
; CHECK-BMI-NEXT:    notl %edi
; CHECK-BMI-NEXT:    shrl $22, %edi
; CHECK-BMI-NEXT:    andl $512, %edi # imm = 0x200
; CHECK-BMI-NEXT:    movl %edi, %eax
; CHECK-BMI-NEXT:    retq
  %tmp.1 = icmp sgt i32 %a, -1
  %retval = select i1 %tmp.1, i32 512, i32 0
  ret i32 %retval
}

; Compare if positive and select variable or zero.

define i32 @pos_sel_variable_and_zero(i32 %a, i32 %b) {
; CHECK-NOBMI-LABEL: pos_sel_variable_and_zero:
; CHECK-NOBMI:       # %bb.0:
; CHECK-NOBMI-NEXT:    xorl %eax, %eax
; CHECK-NOBMI-NEXT:    testl %edi, %edi
; CHECK-NOBMI-NEXT:    cmovnsl %esi, %eax
; CHECK-NOBMI-NEXT:    retq
;
; CHECK-BMI-LABEL: pos_sel_variable_and_zero:
; CHECK-BMI:       # %bb.0:
; CHECK-BMI-NEXT:    sarl $31, %edi
; CHECK-BMI-NEXT:    andnl %esi, %edi, %eax
; CHECK-BMI-NEXT:    retq
  %tmp.1 = icmp sgt i32 %a, -1
  %retval = select i1 %tmp.1, i32 %b, i32 0
  ret i32 %retval
}

; Compare if not negative or zero and select the same variable as being compared: smax(a, 0).

define i32 @not_neg_sel_same_variable(i32 %a) {
; CHECK-NOBMI-LABEL: not_neg_sel_same_variable:
; CHECK-NOBMI:       # %bb.0:
; CHECK-NOBMI-NEXT:    xorl %eax, %eax
; CHECK-NOBMI-NEXT:    testl %edi, %edi
; CHECK-NOBMI-NEXT:    cmovnsl %edi, %eax
; CHECK-NOBMI-NEXT:    retq
;
; CHECK-BMI-LABEL: not_neg_sel_same_variable:
; CHECK-BMI:       # %bb.0:
; CHECK-BMI-NEXT:    movl %edi, %eax
; CHECK-BMI-NEXT:    sarl $31, %eax
; CHECK-BMI-NEXT:    andnl %edi, %eax, %eax
; CHECK-BMI-NEXT:    retq
  %tmp = icmp sgt i32 %a, 0
  %min = select i1 %tmp, i32 %a, i32 0
  ret i32 %min
}

; https://llvm.org/bugs/show_bug.cgi?id=31175

; ret = (x-y) > 0 ? x-y : 0
define i32 @PR31175(i32 %x, i32 %y) {
; CHECK-NOBMI-LABEL: PR31175:
; CHECK-NOBMI:       # %bb.0:
; CHECK-NOBMI-NEXT:    xorl %eax, %eax
; CHECK-NOBMI-NEXT:    subl %esi, %edi
; CHECK-NOBMI-NEXT:    cmovnsl %edi, %eax
; CHECK-NOBMI-NEXT:    retq
;
; CHECK-BMI-LABEL: PR31175:
; CHECK-BMI:       # %bb.0:
; CHECK-BMI-NEXT:    subl %esi, %edi
; CHECK-BMI-NEXT:    movl %edi, %eax
; CHECK-BMI-NEXT:    sarl $31, %eax
; CHECK-BMI-NEXT:    andnl %edi, %eax, %eax
; CHECK-BMI-NEXT:    retq
  %sub = sub nsw i32 %x, %y
  %cmp = icmp sgt i32 %sub, 0
  %sel = select i1 %cmp, i32 %sub, i32 0
  ret i32 %sel
}
