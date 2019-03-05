; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i386-unknown-unknown -mattr=-cmov | FileCheck %s --check-prefixes=ALL,I386,I386-NOCMOV
; RUN: llc < %s -mtriple=i386-unknown-unknown -mattr=+cmov | FileCheck %s --check-prefixes=ALL,I386,I386-CMOV
; RUN: llc < %s -mtriple=i686-unknown-unknown -mattr=-cmov | FileCheck %s --check-prefixes=ALL,I686,I686-NOCMOV
; RUN: llc < %s -mtriple=i686-unknown-unknown -mattr=+cmov | FileCheck %s --check-prefixes=ALL,I686,I686-CMOV
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=-cmov | FileCheck %s --check-prefixes=ALL,X86_64,X86_64-NOCMOV
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+cmov | FileCheck %s --check-prefixes=ALL,X86_64,X86_64-CMOV

; Values don't come from regs. All good.

define i8 @t0(i32 %a1_wide_orig, i32 %a2_wide_orig, i32 %inc) nounwind {
; I386-NOCMOV-LABEL: t0:
; I386-NOCMOV:       # %bb.0:
; I386-NOCMOV-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; I386-NOCMOV-NEXT:    movl {{[0-9]+}}(%esp), %eax
; I386-NOCMOV-NEXT:    addl %ecx, %eax
; I386-NOCMOV-NEXT:    addl {{[0-9]+}}(%esp), %ecx
; I386-NOCMOV-NEXT:    cmpb %cl, %al
; I386-NOCMOV-NEXT:    jge .LBB0_2
; I386-NOCMOV-NEXT:  # %bb.1:
; I386-NOCMOV-NEXT:    movl %ecx, %eax
; I386-NOCMOV-NEXT:  .LBB0_2:
; I386-NOCMOV-NEXT:    # kill: def $al killed $al killed $eax
; I386-NOCMOV-NEXT:    retl
;
; I386-CMOV-LABEL: t0:
; I386-CMOV:       # %bb.0:
; I386-CMOV-NEXT:    movl {{[0-9]+}}(%esp), %eax
; I386-CMOV-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; I386-CMOV-NEXT:    addl %eax, %ecx
; I386-CMOV-NEXT:    addl {{[0-9]+}}(%esp), %eax
; I386-CMOV-NEXT:    cmpb %al, %cl
; I386-CMOV-NEXT:    cmovgel %ecx, %eax
; I386-CMOV-NEXT:    # kill: def $al killed $al killed $eax
; I386-CMOV-NEXT:    retl
;
; I686-NOCMOV-LABEL: t0:
; I686-NOCMOV:       # %bb.0:
; I686-NOCMOV-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; I686-NOCMOV-NEXT:    movl {{[0-9]+}}(%esp), %eax
; I686-NOCMOV-NEXT:    addl %ecx, %eax
; I686-NOCMOV-NEXT:    addl {{[0-9]+}}(%esp), %ecx
; I686-NOCMOV-NEXT:    cmpb %cl, %al
; I686-NOCMOV-NEXT:    jge .LBB0_2
; I686-NOCMOV-NEXT:  # %bb.1:
; I686-NOCMOV-NEXT:    movl %ecx, %eax
; I686-NOCMOV-NEXT:  .LBB0_2:
; I686-NOCMOV-NEXT:    # kill: def $al killed $al killed $eax
; I686-NOCMOV-NEXT:    retl
;
; I686-CMOV-LABEL: t0:
; I686-CMOV:       # %bb.0:
; I686-CMOV-NEXT:    movl {{[0-9]+}}(%esp), %eax
; I686-CMOV-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; I686-CMOV-NEXT:    addl %eax, %ecx
; I686-CMOV-NEXT:    addl {{[0-9]+}}(%esp), %eax
; I686-CMOV-NEXT:    cmpb %al, %cl
; I686-CMOV-NEXT:    cmovgel %ecx, %eax
; I686-CMOV-NEXT:    # kill: def $al killed $al killed $eax
; I686-CMOV-NEXT:    retl
;
; X86_64-LABEL: t0:
; X86_64:       # %bb.0:
; X86_64-NEXT:    movl %esi, %eax
; X86_64-NEXT:    addl %edx, %edi
; X86_64-NEXT:    addl %edx, %eax
; X86_64-NEXT:    cmpb %al, %dil
; X86_64-NEXT:    cmovgel %edi, %eax
; X86_64-NEXT:    # kill: def $al killed $al killed $eax
; X86_64-NEXT:    retq
  %a1_wide = add i32 %a1_wide_orig, %inc
  %a2_wide = add i32 %a2_wide_orig, %inc
  %a1 = trunc i32 %a1_wide to i8
  %a2 = trunc i32 %a2_wide to i8
  %t1 = icmp sgt i8 %a1, %a2
  %t2 = select i1 %t1, i8 %a1, i8 %a2
  ret i8 %t2
}

; Values don't come from regs, but there is only one truncation.

define i8 @neg_only_one_truncation(i32 %a1_wide_orig, i8 %a2_orig, i32 %inc) nounwind {
; I386-LABEL: neg_only_one_truncation:
; I386:       # %bb.0:
; I386-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; I386-NEXT:    movl {{[0-9]+}}(%esp), %eax
; I386-NEXT:    addl %ecx, %eax
; I386-NEXT:    addb {{[0-9]+}}(%esp), %cl
; I386-NEXT:    cmpb %cl, %al
; I386-NEXT:    jge .LBB1_2
; I386-NEXT:  # %bb.1:
; I386-NEXT:    movl %ecx, %eax
; I386-NEXT:  .LBB1_2:
; I386-NEXT:    # kill: def $al killed $al killed $eax
; I386-NEXT:    retl
;
; I686-LABEL: neg_only_one_truncation:
; I686:       # %bb.0:
; I686-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; I686-NEXT:    movl {{[0-9]+}}(%esp), %eax
; I686-NEXT:    addl %ecx, %eax
; I686-NEXT:    addb {{[0-9]+}}(%esp), %cl
; I686-NEXT:    cmpb %cl, %al
; I686-NEXT:    jge .LBB1_2
; I686-NEXT:  # %bb.1:
; I686-NEXT:    movl %ecx, %eax
; I686-NEXT:  .LBB1_2:
; I686-NEXT:    # kill: def $al killed $al killed $eax
; I686-NEXT:    retl
;
; X86_64-LABEL: neg_only_one_truncation:
; X86_64:       # %bb.0:
; X86_64-NEXT:    movl %edi, %eax
; X86_64-NEXT:    addl %edx, %eax
; X86_64-NEXT:    addb %sil, %dl
; X86_64-NEXT:    cmpb %dl, %al
; X86_64-NEXT:    jge .LBB1_2
; X86_64-NEXT:  # %bb.1:
; X86_64-NEXT:    movl %edx, %eax
; X86_64-NEXT:  .LBB1_2:
; X86_64-NEXT:    # kill: def $al killed $al killed $eax
; X86_64-NEXT:    retq
  %a1_wide = add i32 %a1_wide_orig, %inc
  %inc_short = trunc i32 %inc to i8
  %a2 = add i8 %a2_orig, %inc_short
  %a1 = trunc i32 %a1_wide to i8
  %t1 = icmp sgt i8 %a1, %a2
  %t2 = select i1 %t1, i8 %a1, i8 %a2
  ret i8 %t2
}

; Values don't come from regs, but truncation from different types.

define i8 @neg_type_mismatch(i32 %a1_wide_orig, i16 %a2_wide_orig, i32 %inc) nounwind {
; I386-LABEL: neg_type_mismatch:
; I386:       # %bb.0:
; I386-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; I386-NEXT:    movl {{[0-9]+}}(%esp), %eax
; I386-NEXT:    addl %ecx, %eax
; I386-NEXT:    addw {{[0-9]+}}(%esp), %cx
; I386-NEXT:    cmpb %cl, %al
; I386-NEXT:    jge .LBB2_2
; I386-NEXT:  # %bb.1:
; I386-NEXT:    movl %ecx, %eax
; I386-NEXT:  .LBB2_2:
; I386-NEXT:    # kill: def $al killed $al killed $eax
; I386-NEXT:    retl
;
; I686-LABEL: neg_type_mismatch:
; I686:       # %bb.0:
; I686-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; I686-NEXT:    movl {{[0-9]+}}(%esp), %eax
; I686-NEXT:    addl %ecx, %eax
; I686-NEXT:    addw {{[0-9]+}}(%esp), %cx
; I686-NEXT:    cmpb %cl, %al
; I686-NEXT:    jge .LBB2_2
; I686-NEXT:  # %bb.1:
; I686-NEXT:    movl %ecx, %eax
; I686-NEXT:  .LBB2_2:
; I686-NEXT:    # kill: def $al killed $al killed $eax
; I686-NEXT:    retl
;
; X86_64-LABEL: neg_type_mismatch:
; X86_64:       # %bb.0:
; X86_64-NEXT:    movl %edi, %eax
; X86_64-NEXT:    addl %edx, %eax
; X86_64-NEXT:    addl %edx, %esi
; X86_64-NEXT:    cmpb %sil, %al
; X86_64-NEXT:    jge .LBB2_2
; X86_64-NEXT:  # %bb.1:
; X86_64-NEXT:    movl %esi, %eax
; X86_64-NEXT:  .LBB2_2:
; X86_64-NEXT:    # kill: def $al killed $al killed $eax
; X86_64-NEXT:    retq
  %a1_wide = add i32 %a1_wide_orig, %inc
  %inc_short = trunc i32 %inc to i16
  %a2_wide = add i16 %a2_wide_orig, %inc_short
  %a1 = trunc i32 %a1_wide to i8
  %a2 = trunc i16 %a2_wide to i8
  %t1 = icmp sgt i8 %a1, %a2
  %t2 = select i1 %t1, i8 %a1, i8 %a2
  ret i8 %t2
}

; One value come from regs

define i8 @negative_CopyFromReg(i32 %a1_wide, i32 %a2_wide_orig, i32 %inc) nounwind {
; I386-LABEL: negative_CopyFromReg:
; I386:       # %bb.0:
; I386-NEXT:    movb {{[0-9]+}}(%esp), %al
; I386-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; I386-NEXT:    addl {{[0-9]+}}(%esp), %ecx
; I386-NEXT:    cmpb %cl, %al
; I386-NEXT:    jge .LBB3_2
; I386-NEXT:  # %bb.1:
; I386-NEXT:    movl %ecx, %eax
; I386-NEXT:  .LBB3_2:
; I386-NEXT:    retl
;
; I686-LABEL: negative_CopyFromReg:
; I686:       # %bb.0:
; I686-NEXT:    movb {{[0-9]+}}(%esp), %al
; I686-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; I686-NEXT:    addl {{[0-9]+}}(%esp), %ecx
; I686-NEXT:    cmpb %cl, %al
; I686-NEXT:    jge .LBB3_2
; I686-NEXT:  # %bb.1:
; I686-NEXT:    movl %ecx, %eax
; I686-NEXT:  .LBB3_2:
; I686-NEXT:    retl
;
; X86_64-LABEL: negative_CopyFromReg:
; X86_64:       # %bb.0:
; X86_64-NEXT:    movl %edi, %eax
; X86_64-NEXT:    addl %edx, %esi
; X86_64-NEXT:    cmpb %sil, %al
; X86_64-NEXT:    jge .LBB3_2
; X86_64-NEXT:  # %bb.1:
; X86_64-NEXT:    movl %esi, %eax
; X86_64-NEXT:  .LBB3_2:
; X86_64-NEXT:    # kill: def $al killed $al killed $eax
; X86_64-NEXT:    retq
  %a2_wide = add i32 %a2_wide_orig, %inc
  %a1 = trunc i32 %a1_wide to i8
  %a2 = trunc i32 %a2_wide to i8
  %t1 = icmp sgt i8 %a1, %a2
  %t2 = select i1 %t1, i8 %a1, i8 %a2
  ret i8 %t2
}

; Both values come from regs

define i8 @negative_CopyFromRegs(i32 %a1_wide, i32 %a2_wide) nounwind {
; I386-LABEL: negative_CopyFromRegs:
; I386:       # %bb.0:
; I386-NEXT:    movb {{[0-9]+}}(%esp), %cl
; I386-NEXT:    movb {{[0-9]+}}(%esp), %al
; I386-NEXT:    cmpb %cl, %al
; I386-NEXT:    jge .LBB4_2
; I386-NEXT:  # %bb.1:
; I386-NEXT:    movl %ecx, %eax
; I386-NEXT:  .LBB4_2:
; I386-NEXT:    retl
;
; I686-LABEL: negative_CopyFromRegs:
; I686:       # %bb.0:
; I686-NEXT:    movb {{[0-9]+}}(%esp), %cl
; I686-NEXT:    movb {{[0-9]+}}(%esp), %al
; I686-NEXT:    cmpb %cl, %al
; I686-NEXT:    jge .LBB4_2
; I686-NEXT:  # %bb.1:
; I686-NEXT:    movl %ecx, %eax
; I686-NEXT:  .LBB4_2:
; I686-NEXT:    retl
;
; X86_64-LABEL: negative_CopyFromRegs:
; X86_64:       # %bb.0:
; X86_64-NEXT:    movl %edi, %eax
; X86_64-NEXT:    cmpb %sil, %al
; X86_64-NEXT:    jge .LBB4_2
; X86_64-NEXT:  # %bb.1:
; X86_64-NEXT:    movl %esi, %eax
; X86_64-NEXT:  .LBB4_2:
; X86_64-NEXT:    # kill: def $al killed $al killed $eax
; X86_64-NEXT:    retq
  %a1 = trunc i32 %a1_wide to i8
  %a2 = trunc i32 %a2_wide to i8
  %t1 = icmp sgt i8 %a1, %a2
  %t2 = select i1 %t1, i8 %a1, i8 %a2
  ret i8 %t2
}
