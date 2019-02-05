; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i386-unknown | FileCheck %s --check-prefixes=X86,X86-X87
; RUN: llc < %s -mtriple=x86_64-unknown | FileCheck %s --check-prefixes=X64,X64-X87
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+ssse3 | FileCheck %s --check-prefixes=X64,X64-SSSE3

;
; fptosi
;

define i16 @fptosi_i16_fp80(x86_fp80 %a0) nounwind {
; X86-LABEL: fptosi_i16_fp80:
; X86:       # %bb.0:
; X86-NEXT:    pushl %eax
; X86-NEXT:    fldt {{[0-9]+}}(%esp)
; X86-NEXT:    fnstcw (%esp)
; X86-NEXT:    movzwl (%esp), %eax
; X86-NEXT:    movw $3199, (%esp) # imm = 0xC7F
; X86-NEXT:    fldcw (%esp)
; X86-NEXT:    movw %ax, (%esp)
; X86-NEXT:    fistps {{[0-9]+}}(%esp)
; X86-NEXT:    fldcw (%esp)
; X86-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    popl %ecx
; X86-NEXT:    retl
;
; X64-X87-LABEL: fptosi_i16_fp80:
; X64-X87:       # %bb.0:
; X64-X87-NEXT:    fldt {{[0-9]+}}(%rsp)
; X64-X87-NEXT:    fnstcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    movzwl -{{[0-9]+}}(%rsp), %eax
; X64-X87-NEXT:    movw $3199, -{{[0-9]+}}(%rsp) # imm = 0xC7F
; X64-X87-NEXT:    fldcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    movw %ax, -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    fistpl -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    fldcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    movl -{{[0-9]+}}(%rsp), %eax
; X64-X87-NEXT:    # kill: def $ax killed $ax killed $eax
; X64-X87-NEXT:    retq
;
; X64-SSSE3-LABEL: fptosi_i16_fp80:
; X64-SSSE3:       # %bb.0:
; X64-SSSE3-NEXT:    fldt {{[0-9]+}}(%rsp)
; X64-SSSE3-NEXT:    fisttpl -{{[0-9]+}}(%rsp)
; X64-SSSE3-NEXT:    movl -{{[0-9]+}}(%rsp), %eax
; X64-SSSE3-NEXT:    # kill: def $ax killed $ax killed $eax
; X64-SSSE3-NEXT:    retq
  %1 = fptosi x86_fp80 %a0 to i16
  ret i16  %1
}

define i16 @fptosi_i16_fp80_ld(x86_fp80 *%a0) nounwind {
; X86-LABEL: fptosi_i16_fp80_ld:
; X86:       # %bb.0:
; X86-NEXT:    pushl %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    fldt (%eax)
; X86-NEXT:    fnstcw (%esp)
; X86-NEXT:    movzwl (%esp), %eax
; X86-NEXT:    movw $3199, (%esp) # imm = 0xC7F
; X86-NEXT:    fldcw (%esp)
; X86-NEXT:    movw %ax, (%esp)
; X86-NEXT:    fistps {{[0-9]+}}(%esp)
; X86-NEXT:    fldcw (%esp)
; X86-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    popl %ecx
; X86-NEXT:    retl
;
; X64-X87-LABEL: fptosi_i16_fp80_ld:
; X64-X87:       # %bb.0:
; X64-X87-NEXT:    fldt (%rdi)
; X64-X87-NEXT:    fnstcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    movzwl -{{[0-9]+}}(%rsp), %eax
; X64-X87-NEXT:    movw $3199, -{{[0-9]+}}(%rsp) # imm = 0xC7F
; X64-X87-NEXT:    fldcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    movw %ax, -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    fistpl -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    fldcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    movl -{{[0-9]+}}(%rsp), %eax
; X64-X87-NEXT:    # kill: def $ax killed $ax killed $eax
; X64-X87-NEXT:    retq
;
; X64-SSSE3-LABEL: fptosi_i16_fp80_ld:
; X64-SSSE3:       # %bb.0:
; X64-SSSE3-NEXT:    fldt (%rdi)
; X64-SSSE3-NEXT:    fisttpl -{{[0-9]+}}(%rsp)
; X64-SSSE3-NEXT:    movl -{{[0-9]+}}(%rsp), %eax
; X64-SSSE3-NEXT:    # kill: def $ax killed $ax killed $eax
; X64-SSSE3-NEXT:    retq
  %1 = load x86_fp80, x86_fp80 *%a0
  %2 = fptosi x86_fp80 %1 to i16
  ret i16  %2
}

define i32 @fptosi_i32_fp80(x86_fp80 %a0) nounwind {
; X86-LABEL: fptosi_i32_fp80:
; X86:       # %bb.0:
; X86-NEXT:    subl $8, %esp
; X86-NEXT:    fldt {{[0-9]+}}(%esp)
; X86-NEXT:    fnstcw {{[0-9]+}}(%esp)
; X86-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movw $3199, {{[0-9]+}}(%esp) # imm = 0xC7F
; X86-NEXT:    fldcw {{[0-9]+}}(%esp)
; X86-NEXT:    movw %ax, {{[0-9]+}}(%esp)
; X86-NEXT:    fistpl {{[0-9]+}}(%esp)
; X86-NEXT:    fldcw {{[0-9]+}}(%esp)
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    addl $8, %esp
; X86-NEXT:    retl
;
; X64-X87-LABEL: fptosi_i32_fp80:
; X64-X87:       # %bb.0:
; X64-X87-NEXT:    fldt {{[0-9]+}}(%rsp)
; X64-X87-NEXT:    fnstcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    movzwl -{{[0-9]+}}(%rsp), %eax
; X64-X87-NEXT:    movw $3199, -{{[0-9]+}}(%rsp) # imm = 0xC7F
; X64-X87-NEXT:    fldcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    movw %ax, -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    fistpl -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    fldcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    movl -{{[0-9]+}}(%rsp), %eax
; X64-X87-NEXT:    retq
;
; X64-SSSE3-LABEL: fptosi_i32_fp80:
; X64-SSSE3:       # %bb.0:
; X64-SSSE3-NEXT:    fldt {{[0-9]+}}(%rsp)
; X64-SSSE3-NEXT:    fisttpl -{{[0-9]+}}(%rsp)
; X64-SSSE3-NEXT:    movl -{{[0-9]+}}(%rsp), %eax
; X64-SSSE3-NEXT:    retq
  %1 = fptosi x86_fp80 %a0 to i32
  ret i32  %1
}

define i32 @fptosi_i32_fp80_ld(x86_fp80 *%a0) nounwind {
; X86-LABEL: fptosi_i32_fp80_ld:
; X86:       # %bb.0:
; X86-NEXT:    subl $8, %esp
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    fldt (%eax)
; X86-NEXT:    fnstcw {{[0-9]+}}(%esp)
; X86-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movw $3199, {{[0-9]+}}(%esp) # imm = 0xC7F
; X86-NEXT:    fldcw {{[0-9]+}}(%esp)
; X86-NEXT:    movw %ax, {{[0-9]+}}(%esp)
; X86-NEXT:    fistpl {{[0-9]+}}(%esp)
; X86-NEXT:    fldcw {{[0-9]+}}(%esp)
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    addl $8, %esp
; X86-NEXT:    retl
;
; X64-X87-LABEL: fptosi_i32_fp80_ld:
; X64-X87:       # %bb.0:
; X64-X87-NEXT:    fldt (%rdi)
; X64-X87-NEXT:    fnstcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    movzwl -{{[0-9]+}}(%rsp), %eax
; X64-X87-NEXT:    movw $3199, -{{[0-9]+}}(%rsp) # imm = 0xC7F
; X64-X87-NEXT:    fldcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    movw %ax, -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    fistpl -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    fldcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    movl -{{[0-9]+}}(%rsp), %eax
; X64-X87-NEXT:    retq
;
; X64-SSSE3-LABEL: fptosi_i32_fp80_ld:
; X64-SSSE3:       # %bb.0:
; X64-SSSE3-NEXT:    fldt (%rdi)
; X64-SSSE3-NEXT:    fisttpl -{{[0-9]+}}(%rsp)
; X64-SSSE3-NEXT:    movl -{{[0-9]+}}(%rsp), %eax
; X64-SSSE3-NEXT:    retq
  %1 = load x86_fp80, x86_fp80 *%a0
  %2 = fptosi x86_fp80 %1 to i32
  ret i32  %2
}

define i64 @fptosi_i64_fp80(x86_fp80 %a0) nounwind {
; X86-LABEL: fptosi_i64_fp80:
; X86:       # %bb.0:
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $16, %esp
; X86-NEXT:    fldt 8(%ebp)
; X86-NEXT:    fnstcw {{[0-9]+}}(%esp)
; X86-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movw $3199, {{[0-9]+}}(%esp) # imm = 0xC7F
; X86-NEXT:    fldcw {{[0-9]+}}(%esp)
; X86-NEXT:    movw %ax, {{[0-9]+}}(%esp)
; X86-NEXT:    fistpll {{[0-9]+}}(%esp)
; X86-NEXT:    fldcw {{[0-9]+}}(%esp)
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
;
; X64-X87-LABEL: fptosi_i64_fp80:
; X64-X87:       # %bb.0:
; X64-X87-NEXT:    fldt {{[0-9]+}}(%rsp)
; X64-X87-NEXT:    fnstcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    movzwl -{{[0-9]+}}(%rsp), %eax
; X64-X87-NEXT:    movw $3199, -{{[0-9]+}}(%rsp) # imm = 0xC7F
; X64-X87-NEXT:    fldcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    movw %ax, -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    fistpll -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    fldcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    movq -{{[0-9]+}}(%rsp), %rax
; X64-X87-NEXT:    retq
;
; X64-SSSE3-LABEL: fptosi_i64_fp80:
; X64-SSSE3:       # %bb.0:
; X64-SSSE3-NEXT:    fldt {{[0-9]+}}(%rsp)
; X64-SSSE3-NEXT:    fisttpll -{{[0-9]+}}(%rsp)
; X64-SSSE3-NEXT:    movq -{{[0-9]+}}(%rsp), %rax
; X64-SSSE3-NEXT:    retq
  %1 = fptosi x86_fp80 %a0 to i64
  ret i64  %1
}

define i64 @fptosi_i64_fp80_ld(x86_fp80 *%a0) nounwind {
; X86-LABEL: fptosi_i64_fp80_ld:
; X86:       # %bb.0:
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $16, %esp
; X86-NEXT:    movl 8(%ebp), %eax
; X86-NEXT:    fldt (%eax)
; X86-NEXT:    fnstcw {{[0-9]+}}(%esp)
; X86-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movw $3199, {{[0-9]+}}(%esp) # imm = 0xC7F
; X86-NEXT:    fldcw {{[0-9]+}}(%esp)
; X86-NEXT:    movw %ax, {{[0-9]+}}(%esp)
; X86-NEXT:    fistpll {{[0-9]+}}(%esp)
; X86-NEXT:    fldcw {{[0-9]+}}(%esp)
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
;
; X64-X87-LABEL: fptosi_i64_fp80_ld:
; X64-X87:       # %bb.0:
; X64-X87-NEXT:    fldt (%rdi)
; X64-X87-NEXT:    fnstcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    movzwl -{{[0-9]+}}(%rsp), %eax
; X64-X87-NEXT:    movw $3199, -{{[0-9]+}}(%rsp) # imm = 0xC7F
; X64-X87-NEXT:    fldcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    movw %ax, -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    fistpll -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    fldcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    movq -{{[0-9]+}}(%rsp), %rax
; X64-X87-NEXT:    retq
;
; X64-SSSE3-LABEL: fptosi_i64_fp80_ld:
; X64-SSSE3:       # %bb.0:
; X64-SSSE3-NEXT:    fldt (%rdi)
; X64-SSSE3-NEXT:    fisttpll -{{[0-9]+}}(%rsp)
; X64-SSSE3-NEXT:    movq -{{[0-9]+}}(%rsp), %rax
; X64-SSSE3-NEXT:    retq
  %1 = load x86_fp80, x86_fp80 *%a0
  %2 = fptosi x86_fp80 %1 to i64
  ret i64  %2
}

;
; fptoui
;

define i16 @fptoui_i16_fp80(x86_fp80 %a0) nounwind {
; X86-LABEL: fptoui_i16_fp80:
; X86:       # %bb.0:
; X86-NEXT:    subl $8, %esp
; X86-NEXT:    fldt {{[0-9]+}}(%esp)
; X86-NEXT:    fnstcw {{[0-9]+}}(%esp)
; X86-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movw $3199, {{[0-9]+}}(%esp) # imm = 0xC7F
; X86-NEXT:    fldcw {{[0-9]+}}(%esp)
; X86-NEXT:    movw %ax, {{[0-9]+}}(%esp)
; X86-NEXT:    fistpl {{[0-9]+}}(%esp)
; X86-NEXT:    fldcw {{[0-9]+}}(%esp)
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    # kill: def $ax killed $ax killed $eax
; X86-NEXT:    addl $8, %esp
; X86-NEXT:    retl
;
; X64-X87-LABEL: fptoui_i16_fp80:
; X64-X87:       # %bb.0:
; X64-X87-NEXT:    fldt {{[0-9]+}}(%rsp)
; X64-X87-NEXT:    fnstcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    movzwl -{{[0-9]+}}(%rsp), %eax
; X64-X87-NEXT:    movw $3199, -{{[0-9]+}}(%rsp) # imm = 0xC7F
; X64-X87-NEXT:    fldcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    movw %ax, -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    fistpl -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    fldcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    movl -{{[0-9]+}}(%rsp), %eax
; X64-X87-NEXT:    # kill: def $ax killed $ax killed $eax
; X64-X87-NEXT:    retq
;
; X64-SSSE3-LABEL: fptoui_i16_fp80:
; X64-SSSE3:       # %bb.0:
; X64-SSSE3-NEXT:    fldt {{[0-9]+}}(%rsp)
; X64-SSSE3-NEXT:    fisttpl -{{[0-9]+}}(%rsp)
; X64-SSSE3-NEXT:    movl -{{[0-9]+}}(%rsp), %eax
; X64-SSSE3-NEXT:    # kill: def $ax killed $ax killed $eax
; X64-SSSE3-NEXT:    retq
  %1 = fptoui x86_fp80 %a0 to i16
  ret i16  %1
}

define i16 @fptoui_i16_fp80_ld(x86_fp80 *%a0) nounwind {
; X86-LABEL: fptoui_i16_fp80_ld:
; X86:       # %bb.0:
; X86-NEXT:    subl $8, %esp
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    fldt (%eax)
; X86-NEXT:    fnstcw {{[0-9]+}}(%esp)
; X86-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movw $3199, {{[0-9]+}}(%esp) # imm = 0xC7F
; X86-NEXT:    fldcw {{[0-9]+}}(%esp)
; X86-NEXT:    movw %ax, {{[0-9]+}}(%esp)
; X86-NEXT:    fistpl {{[0-9]+}}(%esp)
; X86-NEXT:    fldcw {{[0-9]+}}(%esp)
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    # kill: def $ax killed $ax killed $eax
; X86-NEXT:    addl $8, %esp
; X86-NEXT:    retl
;
; X64-X87-LABEL: fptoui_i16_fp80_ld:
; X64-X87:       # %bb.0:
; X64-X87-NEXT:    fldt (%rdi)
; X64-X87-NEXT:    fnstcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    movzwl -{{[0-9]+}}(%rsp), %eax
; X64-X87-NEXT:    movw $3199, -{{[0-9]+}}(%rsp) # imm = 0xC7F
; X64-X87-NEXT:    fldcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    movw %ax, -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    fistpl -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    fldcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    movl -{{[0-9]+}}(%rsp), %eax
; X64-X87-NEXT:    # kill: def $ax killed $ax killed $eax
; X64-X87-NEXT:    retq
;
; X64-SSSE3-LABEL: fptoui_i16_fp80_ld:
; X64-SSSE3:       # %bb.0:
; X64-SSSE3-NEXT:    fldt (%rdi)
; X64-SSSE3-NEXT:    fisttpl -{{[0-9]+}}(%rsp)
; X64-SSSE3-NEXT:    movl -{{[0-9]+}}(%rsp), %eax
; X64-SSSE3-NEXT:    # kill: def $ax killed $ax killed $eax
; X64-SSSE3-NEXT:    retq
  %1 = load x86_fp80, x86_fp80 *%a0
  %2 = fptoui x86_fp80 %1 to i16
  ret i16  %2
}

define i32 @fptoui_i32_fp80(x86_fp80 %a0) nounwind {
; X86-LABEL: fptoui_i32_fp80:
; X86:       # %bb.0:
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $16, %esp
; X86-NEXT:    fldt 8(%ebp)
; X86-NEXT:    fnstcw {{[0-9]+}}(%esp)
; X86-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movw $3199, {{[0-9]+}}(%esp) # imm = 0xC7F
; X86-NEXT:    fldcw {{[0-9]+}}(%esp)
; X86-NEXT:    movw %ax, {{[0-9]+}}(%esp)
; X86-NEXT:    fistpll {{[0-9]+}}(%esp)
; X86-NEXT:    fldcw {{[0-9]+}}(%esp)
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
;
; X64-X87-LABEL: fptoui_i32_fp80:
; X64-X87:       # %bb.0:
; X64-X87-NEXT:    fldt {{[0-9]+}}(%rsp)
; X64-X87-NEXT:    fnstcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    movzwl -{{[0-9]+}}(%rsp), %eax
; X64-X87-NEXT:    movw $3199, -{{[0-9]+}}(%rsp) # imm = 0xC7F
; X64-X87-NEXT:    fldcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    movw %ax, -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    fistpll -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    fldcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    movl -{{[0-9]+}}(%rsp), %eax
; X64-X87-NEXT:    retq
;
; X64-SSSE3-LABEL: fptoui_i32_fp80:
; X64-SSSE3:       # %bb.0:
; X64-SSSE3-NEXT:    fldt {{[0-9]+}}(%rsp)
; X64-SSSE3-NEXT:    fisttpll -{{[0-9]+}}(%rsp)
; X64-SSSE3-NEXT:    movl -{{[0-9]+}}(%rsp), %eax
; X64-SSSE3-NEXT:    retq
  %1 = fptoui x86_fp80 %a0 to i32
  ret i32  %1
}

define i32 @fptoui_i32_fp80_ld(x86_fp80 *%a0) nounwind {
; X86-LABEL: fptoui_i32_fp80_ld:
; X86:       # %bb.0:
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $16, %esp
; X86-NEXT:    movl 8(%ebp), %eax
; X86-NEXT:    fldt (%eax)
; X86-NEXT:    fnstcw {{[0-9]+}}(%esp)
; X86-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movw $3199, {{[0-9]+}}(%esp) # imm = 0xC7F
; X86-NEXT:    fldcw {{[0-9]+}}(%esp)
; X86-NEXT:    movw %ax, {{[0-9]+}}(%esp)
; X86-NEXT:    fistpll {{[0-9]+}}(%esp)
; X86-NEXT:    fldcw {{[0-9]+}}(%esp)
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
;
; X64-X87-LABEL: fptoui_i32_fp80_ld:
; X64-X87:       # %bb.0:
; X64-X87-NEXT:    fldt (%rdi)
; X64-X87-NEXT:    fnstcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    movzwl -{{[0-9]+}}(%rsp), %eax
; X64-X87-NEXT:    movw $3199, -{{[0-9]+}}(%rsp) # imm = 0xC7F
; X64-X87-NEXT:    fldcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    movw %ax, -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    fistpll -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    fldcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    movl -{{[0-9]+}}(%rsp), %eax
; X64-X87-NEXT:    retq
;
; X64-SSSE3-LABEL: fptoui_i32_fp80_ld:
; X64-SSSE3:       # %bb.0:
; X64-SSSE3-NEXT:    fldt (%rdi)
; X64-SSSE3-NEXT:    fisttpll -{{[0-9]+}}(%rsp)
; X64-SSSE3-NEXT:    movl -{{[0-9]+}}(%rsp), %eax
; X64-SSSE3-NEXT:    retq
  %1 = load x86_fp80, x86_fp80 *%a0
  %2 = fptoui x86_fp80 %1 to i32
  ret i32  %2
}

define i64 @fptoui_i64_fp80(x86_fp80 %a0) nounwind {
; X86-LABEL: fptoui_i64_fp80:
; X86:       # %bb.0:
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $16, %esp
; X86-NEXT:    fldt 8(%ebp)
; X86-NEXT:    flds {{\.LCPI.*}}
; X86-NEXT:    fld %st(1)
; X86-NEXT:    fsub %st(1), %st
; X86-NEXT:    fxch %st(1)
; X86-NEXT:    fucomp %st(2)
; X86-NEXT:    fnstsw %ax
; X86-NEXT:    # kill: def $ah killed $ah killed $ax
; X86-NEXT:    sahf
; X86-NEXT:    ja .LBB10_2
; X86-NEXT:  # %bb.1:
; X86-NEXT:    fstp %st(1)
; X86-NEXT:    fldz
; X86-NEXT:  .LBB10_2:
; X86-NEXT:    fstp %st(0)
; X86-NEXT:    fnstcw {{[0-9]+}}(%esp)
; X86-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movw $3199, {{[0-9]+}}(%esp) # imm = 0xC7F
; X86-NEXT:    fldcw {{[0-9]+}}(%esp)
; X86-NEXT:    movw %ax, {{[0-9]+}}(%esp)
; X86-NEXT:    fistpll {{[0-9]+}}(%esp)
; X86-NEXT:    fldcw {{[0-9]+}}(%esp)
; X86-NEXT:    setbe %al
; X86-NEXT:    movzbl %al, %edx
; X86-NEXT:    shll $31, %edx
; X86-NEXT:    xorl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
;
; X64-X87-LABEL: fptoui_i64_fp80:
; X64-X87:       # %bb.0:
; X64-X87-NEXT:    fldt {{[0-9]+}}(%rsp)
; X64-X87-NEXT:    flds {{.*}}(%rip)
; X64-X87-NEXT:    fld %st(1)
; X64-X87-NEXT:    fsub %st(1), %st
; X64-X87-NEXT:    xorl %eax, %eax
; X64-X87-NEXT:    fxch %st(1)
; X64-X87-NEXT:    fucompi %st(2), %st
; X64-X87-NEXT:    fcmovnbe %st(1), %st
; X64-X87-NEXT:    fstp %st(1)
; X64-X87-NEXT:    fnstcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    movzwl -{{[0-9]+}}(%rsp), %ecx
; X64-X87-NEXT:    movw $3199, -{{[0-9]+}}(%rsp) # imm = 0xC7F
; X64-X87-NEXT:    fldcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    movw %cx, -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    fistpll -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    fldcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    setbe %al
; X64-X87-NEXT:    shlq $63, %rax
; X64-X87-NEXT:    xorq -{{[0-9]+}}(%rsp), %rax
; X64-X87-NEXT:    retq
;
; X64-SSSE3-LABEL: fptoui_i64_fp80:
; X64-SSSE3:       # %bb.0:
; X64-SSSE3-NEXT:    fldt {{[0-9]+}}(%rsp)
; X64-SSSE3-NEXT:    flds {{.*}}(%rip)
; X64-SSSE3-NEXT:    fld %st(1)
; X64-SSSE3-NEXT:    fsub %st(1), %st
; X64-SSSE3-NEXT:    xorl %eax, %eax
; X64-SSSE3-NEXT:    fxch %st(1)
; X64-SSSE3-NEXT:    fucompi %st(2), %st
; X64-SSSE3-NEXT:    fcmovnbe %st(1), %st
; X64-SSSE3-NEXT:    fstp %st(1)
; X64-SSSE3-NEXT:    fisttpll -{{[0-9]+}}(%rsp)
; X64-SSSE3-NEXT:    setbe %al
; X64-SSSE3-NEXT:    shlq $63, %rax
; X64-SSSE3-NEXT:    xorq -{{[0-9]+}}(%rsp), %rax
; X64-SSSE3-NEXT:    retq
  %1 = fptoui x86_fp80 %a0 to i64
  ret i64  %1
}

define i64 @fptoui_i64_fp80_ld(x86_fp80 *%a0) nounwind {
; X86-LABEL: fptoui_i64_fp80_ld:
; X86:       # %bb.0:
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $16, %esp
; X86-NEXT:    movl 8(%ebp), %eax
; X86-NEXT:    fldt (%eax)
; X86-NEXT:    flds {{\.LCPI.*}}
; X86-NEXT:    fld %st(1)
; X86-NEXT:    fsub %st(1), %st
; X86-NEXT:    fxch %st(1)
; X86-NEXT:    fucomp %st(2)
; X86-NEXT:    fnstsw %ax
; X86-NEXT:    # kill: def $ah killed $ah killed $ax
; X86-NEXT:    sahf
; X86-NEXT:    ja .LBB11_2
; X86-NEXT:  # %bb.1:
; X86-NEXT:    fstp %st(1)
; X86-NEXT:    fldz
; X86-NEXT:  .LBB11_2:
; X86-NEXT:    fstp %st(0)
; X86-NEXT:    fnstcw {{[0-9]+}}(%esp)
; X86-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movw $3199, {{[0-9]+}}(%esp) # imm = 0xC7F
; X86-NEXT:    fldcw {{[0-9]+}}(%esp)
; X86-NEXT:    movw %ax, {{[0-9]+}}(%esp)
; X86-NEXT:    fistpll {{[0-9]+}}(%esp)
; X86-NEXT:    fldcw {{[0-9]+}}(%esp)
; X86-NEXT:    setbe %al
; X86-NEXT:    movzbl %al, %edx
; X86-NEXT:    shll $31, %edx
; X86-NEXT:    xorl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
;
; X64-X87-LABEL: fptoui_i64_fp80_ld:
; X64-X87:       # %bb.0:
; X64-X87-NEXT:    fldt (%rdi)
; X64-X87-NEXT:    flds {{.*}}(%rip)
; X64-X87-NEXT:    fld %st(1)
; X64-X87-NEXT:    fsub %st(1), %st
; X64-X87-NEXT:    xorl %eax, %eax
; X64-X87-NEXT:    fxch %st(1)
; X64-X87-NEXT:    fucompi %st(2), %st
; X64-X87-NEXT:    fcmovnbe %st(1), %st
; X64-X87-NEXT:    fstp %st(1)
; X64-X87-NEXT:    fnstcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    movzwl -{{[0-9]+}}(%rsp), %ecx
; X64-X87-NEXT:    movw $3199, -{{[0-9]+}}(%rsp) # imm = 0xC7F
; X64-X87-NEXT:    fldcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    movw %cx, -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    fistpll -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    fldcw -{{[0-9]+}}(%rsp)
; X64-X87-NEXT:    setbe %al
; X64-X87-NEXT:    shlq $63, %rax
; X64-X87-NEXT:    xorq -{{[0-9]+}}(%rsp), %rax
; X64-X87-NEXT:    retq
;
; X64-SSSE3-LABEL: fptoui_i64_fp80_ld:
; X64-SSSE3:       # %bb.0:
; X64-SSSE3-NEXT:    fldt (%rdi)
; X64-SSSE3-NEXT:    flds {{.*}}(%rip)
; X64-SSSE3-NEXT:    fld %st(1)
; X64-SSSE3-NEXT:    fsub %st(1), %st
; X64-SSSE3-NEXT:    xorl %eax, %eax
; X64-SSSE3-NEXT:    fxch %st(1)
; X64-SSSE3-NEXT:    fucompi %st(2), %st
; X64-SSSE3-NEXT:    fcmovnbe %st(1), %st
; X64-SSSE3-NEXT:    fstp %st(1)
; X64-SSSE3-NEXT:    fisttpll -{{[0-9]+}}(%rsp)
; X64-SSSE3-NEXT:    setbe %al
; X64-SSSE3-NEXT:    shlq $63, %rax
; X64-SSSE3-NEXT:    xorq -{{[0-9]+}}(%rsp), %rax
; X64-SSSE3-NEXT:    retq
  %1 = load x86_fp80, x86_fp80 *%a0
  %2 = fptoui x86_fp80 %1 to i64
  ret i64  %2
}

;
; sitofp
;

define x86_fp80 @sitofp_fp80_i16(i16 %a0) nounwind {
; X86-LABEL: sitofp_fp80_i16:
; X86:       # %bb.0:
; X86-NEXT:    pushl %eax
; X86-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movw %ax, {{[0-9]+}}(%esp)
; X86-NEXT:    filds {{[0-9]+}}(%esp)
; X86-NEXT:    popl %eax
; X86-NEXT:    retl
;
; X64-LABEL: sitofp_fp80_i16:
; X64:       # %bb.0:
; X64-NEXT:    movswl %di, %eax
; X64-NEXT:    movl %eax, -{{[0-9]+}}(%rsp)
; X64-NEXT:    fildl -{{[0-9]+}}(%rsp)
; X64-NEXT:    retq
  %1 = sitofp i16 %a0 to x86_fp80
  ret x86_fp80 %1
}

define x86_fp80 @sitofp_fp80_i16_ld(i16 *%a0) nounwind {
; X86-LABEL: sitofp_fp80_i16_ld:
; X86:       # %bb.0:
; X86-NEXT:    pushl %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movzwl (%eax), %eax
; X86-NEXT:    movw %ax, {{[0-9]+}}(%esp)
; X86-NEXT:    filds {{[0-9]+}}(%esp)
; X86-NEXT:    popl %eax
; X86-NEXT:    retl
;
; X64-LABEL: sitofp_fp80_i16_ld:
; X64:       # %bb.0:
; X64-NEXT:    movswl (%rdi), %eax
; X64-NEXT:    movl %eax, -{{[0-9]+}}(%rsp)
; X64-NEXT:    fildl -{{[0-9]+}}(%rsp)
; X64-NEXT:    retq
  %1 = load i16, i16 *%a0
  %2 = sitofp i16 %1 to x86_fp80
  ret x86_fp80 %2
}

define x86_fp80 @sitofp_fp80_i32(i32 %a0) nounwind {
; X86-LABEL: sitofp_fp80_i32:
; X86:       # %bb.0:
; X86-NEXT:    pushl %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl %eax, (%esp)
; X86-NEXT:    fildl (%esp)
; X86-NEXT:    popl %eax
; X86-NEXT:    retl
;
; X64-LABEL: sitofp_fp80_i32:
; X64:       # %bb.0:
; X64-NEXT:    movl %edi, -{{[0-9]+}}(%rsp)
; X64-NEXT:    fildl -{{[0-9]+}}(%rsp)
; X64-NEXT:    retq
  %1 = sitofp i32 %a0 to x86_fp80
  ret x86_fp80 %1
}

define x86_fp80 @sitofp_fp80_i32_ld(i32 *%a0) nounwind {
; X86-LABEL: sitofp_fp80_i32_ld:
; X86:       # %bb.0:
; X86-NEXT:    pushl %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl (%eax), %eax
; X86-NEXT:    movl %eax, (%esp)
; X86-NEXT:    fildl (%esp)
; X86-NEXT:    popl %eax
; X86-NEXT:    retl
;
; X64-LABEL: sitofp_fp80_i32_ld:
; X64:       # %bb.0:
; X64-NEXT:    movl (%rdi), %eax
; X64-NEXT:    movl %eax, -{{[0-9]+}}(%rsp)
; X64-NEXT:    fildl -{{[0-9]+}}(%rsp)
; X64-NEXT:    retq
  %1 = load i32, i32 *%a0
  %2 = sitofp i32 %1 to x86_fp80
  ret x86_fp80 %2
}

define x86_fp80 @sitofp_fp80_i64(i64 %a0) nounwind {
; X86-LABEL: sitofp_fp80_i64:
; X86:       # %bb.0:
; X86-NEXT:    fildll {{[0-9]+}}(%esp)
; X86-NEXT:    retl
;
; X64-LABEL: sitofp_fp80_i64:
; X64:       # %bb.0:
; X64-NEXT:    movq %rdi, -{{[0-9]+}}(%rsp)
; X64-NEXT:    fildll -{{[0-9]+}}(%rsp)
; X64-NEXT:    retq
  %1 = sitofp i64 %a0 to x86_fp80
  ret x86_fp80 %1
}

define x86_fp80 @sitofp_fp80_i64_ld(i64 *%a0) nounwind {
; X86-LABEL: sitofp_fp80_i64_ld:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    fildll (%eax)
; X86-NEXT:    retl
;
; X64-LABEL: sitofp_fp80_i64_ld:
; X64:       # %bb.0:
; X64-NEXT:    movq (%rdi), %rax
; X64-NEXT:    movq %rax, -{{[0-9]+}}(%rsp)
; X64-NEXT:    fildll -{{[0-9]+}}(%rsp)
; X64-NEXT:    retq
  %1 = load i64, i64 *%a0
  %2 = sitofp i64 %1 to x86_fp80
  ret x86_fp80 %2
}

;
; uitofp
;

define x86_fp80 @uitofp_fp80_i16(i16 %a0) nounwind {
; X86-LABEL: uitofp_fp80_i16:
; X86:       # %bb.0:
; X86-NEXT:    pushl %eax
; X86-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl %eax, (%esp)
; X86-NEXT:    fildl (%esp)
; X86-NEXT:    popl %eax
; X86-NEXT:    retl
;
; X64-LABEL: uitofp_fp80_i16:
; X64:       # %bb.0:
; X64-NEXT:    movzwl %di, %eax
; X64-NEXT:    movl %eax, -{{[0-9]+}}(%rsp)
; X64-NEXT:    fildl -{{[0-9]+}}(%rsp)
; X64-NEXT:    retq
  %1 = uitofp i16 %a0 to x86_fp80
  ret x86_fp80 %1
}

define x86_fp80 @uitofp_fp80_i16_ld(i16 *%a0) nounwind {
; X86-LABEL: uitofp_fp80_i16_ld:
; X86:       # %bb.0:
; X86-NEXT:    pushl %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movzwl (%eax), %eax
; X86-NEXT:    movl %eax, (%esp)
; X86-NEXT:    fildl (%esp)
; X86-NEXT:    popl %eax
; X86-NEXT:    retl
;
; X64-LABEL: uitofp_fp80_i16_ld:
; X64:       # %bb.0:
; X64-NEXT:    movzwl (%rdi), %eax
; X64-NEXT:    movl %eax, -{{[0-9]+}}(%rsp)
; X64-NEXT:    fildl -{{[0-9]+}}(%rsp)
; X64-NEXT:    retq
  %1 = load i16, i16 *%a0
  %2 = uitofp i16 %1 to x86_fp80
  ret x86_fp80 %2
}

define x86_fp80 @uitofp_fp80_i32(i32 %a0) nounwind {
; X86-LABEL: uitofp_fp80_i32:
; X86:       # %bb.0:
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $8, %esp
; X86-NEXT:    movl 8(%ebp), %eax
; X86-NEXT:    movl %eax, (%esp)
; X86-NEXT:    movl $0, {{[0-9]+}}(%esp)
; X86-NEXT:    fildll (%esp)
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
;
; X64-LABEL: uitofp_fp80_i32:
; X64:       # %bb.0:
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    movq %rax, -{{[0-9]+}}(%rsp)
; X64-NEXT:    fildll -{{[0-9]+}}(%rsp)
; X64-NEXT:    retq
  %1 = uitofp i32 %a0 to x86_fp80
  ret x86_fp80 %1
}

define x86_fp80 @uitofp_fp80_i32_ld(i32 *%a0) nounwind {
; X86-LABEL: uitofp_fp80_i32_ld:
; X86:       # %bb.0:
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $8, %esp
; X86-NEXT:    movl 8(%ebp), %eax
; X86-NEXT:    movl (%eax), %eax
; X86-NEXT:    movl %eax, (%esp)
; X86-NEXT:    movl $0, {{[0-9]+}}(%esp)
; X86-NEXT:    fildll (%esp)
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
;
; X64-LABEL: uitofp_fp80_i32_ld:
; X64:       # %bb.0:
; X64-NEXT:    movl (%rdi), %eax
; X64-NEXT:    movq %rax, -{{[0-9]+}}(%rsp)
; X64-NEXT:    fildll -{{[0-9]+}}(%rsp)
; X64-NEXT:    retq
  %1 = load i32, i32 *%a0
  %2 = uitofp i32 %1 to x86_fp80
  ret x86_fp80 %2
}

define x86_fp80 @uitofp_fp80_i64(i64 %a0) nounwind {
; X86-LABEL: uitofp_fp80_i64:
; X86:       # %bb.0:
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $8, %esp
; X86-NEXT:    movl 8(%ebp), %eax
; X86-NEXT:    movl 12(%ebp), %ecx
; X86-NEXT:    movl %ecx, {{[0-9]+}}(%esp)
; X86-NEXT:    movl %eax, (%esp)
; X86-NEXT:    xorl %eax, %eax
; X86-NEXT:    testl %ecx, %ecx
; X86-NEXT:    setns %al
; X86-NEXT:    fildll (%esp)
; X86-NEXT:    fadds {{\.LCPI.*}}(,%eax,4)
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
;
; X64-LABEL: uitofp_fp80_i64:
; X64:       # %bb.0:
; X64-NEXT:    movq %rdi, -{{[0-9]+}}(%rsp)
; X64-NEXT:    xorl %eax, %eax
; X64-NEXT:    testq %rdi, %rdi
; X64-NEXT:    setns %al
; X64-NEXT:    fildll -{{[0-9]+}}(%rsp)
; X64-NEXT:    fadds {{\.LCPI.*}}(,%rax,4)
; X64-NEXT:    retq
  %1 = uitofp i64 %a0 to x86_fp80
  ret x86_fp80 %1
}

define x86_fp80 @uitofp_fp80_i64_ld(i64 *%a0) nounwind {
; X86-LABEL: uitofp_fp80_i64_ld:
; X86:       # %bb.0:
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $8, %esp
; X86-NEXT:    movl 8(%ebp), %eax
; X86-NEXT:    movl (%eax), %ecx
; X86-NEXT:    movl 4(%eax), %eax
; X86-NEXT:    movl %eax, {{[0-9]+}}(%esp)
; X86-NEXT:    movl %ecx, (%esp)
; X86-NEXT:    xorl %ecx, %ecx
; X86-NEXT:    testl %eax, %eax
; X86-NEXT:    setns %cl
; X86-NEXT:    fildll (%esp)
; X86-NEXT:    fadds {{\.LCPI.*}}(,%ecx,4)
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
;
; X64-LABEL: uitofp_fp80_i64_ld:
; X64:       # %bb.0:
; X64-NEXT:    movq (%rdi), %rax
; X64-NEXT:    movq %rax, -{{[0-9]+}}(%rsp)
; X64-NEXT:    xorl %ecx, %ecx
; X64-NEXT:    testq %rax, %rax
; X64-NEXT:    setns %cl
; X64-NEXT:    fildll -{{[0-9]+}}(%rsp)
; X64-NEXT:    fadds {{\.LCPI.*}}(,%rcx,4)
; X64-NEXT:    retq
  %1 = load i64, i64 *%a0
  %2 = uitofp i64 %1 to x86_fp80
  ret x86_fp80 %2
}

;
; floor
;

define x86_fp80 @floor_fp80(x86_fp80 %a0) nounwind {
; X86-LABEL: floor_fp80:
; X86:       # %bb.0:
; X86-NEXT:    subl $12, %esp
; X86-NEXT:    fldt {{[0-9]+}}(%esp)
; X86-NEXT:    fstpt (%esp)
; X86-NEXT:    calll floorl
; X86-NEXT:    addl $12, %esp
; X86-NEXT:    retl
;
; X64-LABEL: floor_fp80:
; X64:       # %bb.0:
; X64-NEXT:    subq $24, %rsp
; X64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X64-NEXT:    fstpt (%rsp)
; X64-NEXT:    callq floorl
; X64-NEXT:    addq $24, %rsp
; X64-NEXT:    retq
  %1 = call x86_fp80 @llvm.floor.f80(x86_fp80 %a0)
  ret x86_fp80 %1
}

define x86_fp80 @floor_fp80_ld(x86_fp80 *%a0) nounwind {
; X86-LABEL: floor_fp80_ld:
; X86:       # %bb.0:
; X86-NEXT:    subl $12, %esp
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    fldt (%eax)
; X86-NEXT:    fstpt (%esp)
; X86-NEXT:    calll floorl
; X86-NEXT:    addl $12, %esp
; X86-NEXT:    retl
;
; X64-LABEL: floor_fp80_ld:
; X64:       # %bb.0:
; X64-NEXT:    subq $24, %rsp
; X64-NEXT:    fldt (%rdi)
; X64-NEXT:    fstpt (%rsp)
; X64-NEXT:    callq floorl
; X64-NEXT:    addq $24, %rsp
; X64-NEXT:    retq
  %1 = load x86_fp80, x86_fp80 *%a0
  %2 = call x86_fp80 @llvm.floor.f80(x86_fp80 %1)
  ret x86_fp80 %2
}

declare x86_fp80 @llvm.floor.f80(x86_fp80 %p)

;
; ceil
;

define x86_fp80 @ceil_fp80(x86_fp80 %a0) nounwind {
; X86-LABEL: ceil_fp80:
; X86:       # %bb.0:
; X86-NEXT:    subl $12, %esp
; X86-NEXT:    fldt {{[0-9]+}}(%esp)
; X86-NEXT:    fstpt (%esp)
; X86-NEXT:    calll ceill
; X86-NEXT:    addl $12, %esp
; X86-NEXT:    retl
;
; X64-LABEL: ceil_fp80:
; X64:       # %bb.0:
; X64-NEXT:    subq $24, %rsp
; X64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X64-NEXT:    fstpt (%rsp)
; X64-NEXT:    callq ceill
; X64-NEXT:    addq $24, %rsp
; X64-NEXT:    retq
  %1 = call x86_fp80 @llvm.ceil.f80(x86_fp80 %a0)
  ret x86_fp80 %1
}

define x86_fp80 @ceil_fp80_ld(x86_fp80 *%a0) nounwind {
; X86-LABEL: ceil_fp80_ld:
; X86:       # %bb.0:
; X86-NEXT:    subl $12, %esp
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    fldt (%eax)
; X86-NEXT:    fstpt (%esp)
; X86-NEXT:    calll ceill
; X86-NEXT:    addl $12, %esp
; X86-NEXT:    retl
;
; X64-LABEL: ceil_fp80_ld:
; X64:       # %bb.0:
; X64-NEXT:    subq $24, %rsp
; X64-NEXT:    fldt (%rdi)
; X64-NEXT:    fstpt (%rsp)
; X64-NEXT:    callq ceill
; X64-NEXT:    addq $24, %rsp
; X64-NEXT:    retq
  %1 = load x86_fp80, x86_fp80 *%a0
  %2 = call x86_fp80 @llvm.ceil.f80(x86_fp80 %1)
  ret x86_fp80 %2
}

declare x86_fp80 @llvm.ceil.f80(x86_fp80 %p)

;
; trunc
;

define x86_fp80 @trunc_fp80(x86_fp80 %a0) nounwind {
; X86-LABEL: trunc_fp80:
; X86:       # %bb.0:
; X86-NEXT:    subl $12, %esp
; X86-NEXT:    fldt {{[0-9]+}}(%esp)
; X86-NEXT:    fstpt (%esp)
; X86-NEXT:    calll truncl
; X86-NEXT:    addl $12, %esp
; X86-NEXT:    retl
;
; X64-LABEL: trunc_fp80:
; X64:       # %bb.0:
; X64-NEXT:    subq $24, %rsp
; X64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X64-NEXT:    fstpt (%rsp)
; X64-NEXT:    callq truncl
; X64-NEXT:    addq $24, %rsp
; X64-NEXT:    retq
  %1 = call x86_fp80 @llvm.trunc.f80(x86_fp80 %a0)
  ret x86_fp80 %1
}

define x86_fp80 @trunc_fp80_ld(x86_fp80 *%a0) nounwind {
; X86-LABEL: trunc_fp80_ld:
; X86:       # %bb.0:
; X86-NEXT:    subl $12, %esp
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    fldt (%eax)
; X86-NEXT:    fstpt (%esp)
; X86-NEXT:    calll truncl
; X86-NEXT:    addl $12, %esp
; X86-NEXT:    retl
;
; X64-LABEL: trunc_fp80_ld:
; X64:       # %bb.0:
; X64-NEXT:    subq $24, %rsp
; X64-NEXT:    fldt (%rdi)
; X64-NEXT:    fstpt (%rsp)
; X64-NEXT:    callq truncl
; X64-NEXT:    addq $24, %rsp
; X64-NEXT:    retq
  %1 = load x86_fp80, x86_fp80 *%a0
  %2 = call x86_fp80 @llvm.trunc.f80(x86_fp80 %1)
  ret x86_fp80 %2
}

declare x86_fp80 @llvm.trunc.f80(x86_fp80 %p)

;
; rint
;

define x86_fp80 @rint_fp80(x86_fp80 %a0) nounwind {
; X86-LABEL: rint_fp80:
; X86:       # %bb.0:
; X86-NEXT:    subl $12, %esp
; X86-NEXT:    fldt {{[0-9]+}}(%esp)
; X86-NEXT:    fstpt (%esp)
; X86-NEXT:    calll rintl
; X86-NEXT:    addl $12, %esp
; X86-NEXT:    retl
;
; X64-LABEL: rint_fp80:
; X64:       # %bb.0:
; X64-NEXT:    subq $24, %rsp
; X64-NEXT:    fldt {{[0-9]+}}(%rsp)
; X64-NEXT:    fstpt (%rsp)
; X64-NEXT:    callq rintl
; X64-NEXT:    addq $24, %rsp
; X64-NEXT:    retq
  %1 = call x86_fp80 @llvm.rint.f80(x86_fp80 %a0)
  ret x86_fp80 %1
}

define x86_fp80 @rint_fp80_ld(x86_fp80 *%a0) nounwind {
; X86-LABEL: rint_fp80_ld:
; X86:       # %bb.0:
; X86-NEXT:    subl $12, %esp
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    fldt (%eax)
; X86-NEXT:    fstpt (%esp)
; X86-NEXT:    calll rintl
; X86-NEXT:    addl $12, %esp
; X86-NEXT:    retl
;
; X64-LABEL: rint_fp80_ld:
; X64:       # %bb.0:
; X64-NEXT:    subq $24, %rsp
; X64-NEXT:    fldt (%rdi)
; X64-NEXT:    fstpt (%rsp)
; X64-NEXT:    callq rintl
; X64-NEXT:    addq $24, %rsp
; X64-NEXT:    retq
  %1 = load x86_fp80, x86_fp80 *%a0
  %2 = call x86_fp80 @llvm.rint.f80(x86_fp80 %1)
  ret x86_fp80 %2
}

declare x86_fp80 @llvm.rint.f80(x86_fp80 %p)
