; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686 -mattr=cmov | FileCheck %s --check-prefixes=CHECK,X86
; RUN: llc < %s -mtriple=x86_64-linux | FileCheck %s --check-prefixes=CHECK,X64

declare i4 @llvm.uadd.sat.i4(i4, i4)
declare i8 @llvm.uadd.sat.i8(i8, i8)
declare i16 @llvm.uadd.sat.i16(i16, i16)
declare i32 @llvm.uadd.sat.i32(i32, i32)
declare i64 @llvm.uadd.sat.i64(i64, i64)

define i32 @func32(i32 %x, i32 %y, i32 %z) nounwind {
; X86-LABEL: func32:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    imull {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    addl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl $-1, %eax
; X86-NEXT:    cmovael %ecx, %eax
; X86-NEXT:    retl
;
; X64-LABEL: func32:
; X64:       # %bb.0:
; X64-NEXT:    imull %edx, %esi
; X64-NEXT:    addl %edi, %esi
; X64-NEXT:    movl $-1, %eax
; X64-NEXT:    cmovael %esi, %eax
; X64-NEXT:    retq
  %a = mul i32 %y, %z
  %tmp = call i32 @llvm.uadd.sat.i32(i32 %x, i32 %a)
  ret i32 %tmp
}

define i64 @func64(i64 %x, i64 %y, i64 %z) nounwind {
; X86-LABEL: func64:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    addl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    adcl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movl $-1, %ecx
; X86-NEXT:    cmovbl %ecx, %edx
; X86-NEXT:    cmovbl %ecx, %eax
; X86-NEXT:    retl
;
; X64-LABEL: func64:
; X64:       # %bb.0:
; X64-NEXT:    addq %rdx, %rdi
; X64-NEXT:    movq $-1, %rax
; X64-NEXT:    cmovaeq %rdi, %rax
; X64-NEXT:    retq
  %a = mul i64 %y, %z
  %tmp = call i64 @llvm.uadd.sat.i64(i64 %x, i64 %z)
  ret i64 %tmp
}

define zeroext i16 @func16(i16 zeroext %x, i16 zeroext %y, i16 zeroext %z) nounwind {
; X86-LABEL: func16:
; X86:       # %bb.0:
; X86-NEXT:    movzwl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    imulw {{[0-9]+}}(%esp), %cx
; X86-NEXT:    addw {{[0-9]+}}(%esp), %cx
; X86-NEXT:    movl $65535, %eax # imm = 0xFFFF
; X86-NEXT:    cmovael %ecx, %eax
; X86-NEXT:    # kill: def $ax killed $ax killed $eax
; X86-NEXT:    retl
;
; X64-LABEL: func16:
; X64:       # %bb.0:
; X64-NEXT:    imull %edx, %esi
; X64-NEXT:    addw %di, %si
; X64-NEXT:    movl $65535, %eax # imm = 0xFFFF
; X64-NEXT:    cmovael %esi, %eax
; X64-NEXT:    # kill: def $ax killed $ax killed $eax
; X64-NEXT:    retq
  %a = mul i16 %y, %z
  %tmp = call i16 @llvm.uadd.sat.i16(i16 %x, i16 %a)
  ret i16 %tmp
}

define zeroext i8 @func8(i8 zeroext %x, i8 zeroext %y, i8 zeroext %z) nounwind {
; X86-LABEL: func8:
; X86:       # %bb.0:
; X86-NEXT:    movb {{[0-9]+}}(%esp), %al
; X86-NEXT:    mulb {{[0-9]+}}(%esp)
; X86-NEXT:    addb {{[0-9]+}}(%esp), %al
; X86-NEXT:    movzbl %al, %ecx
; X86-NEXT:    movl $255, %eax
; X86-NEXT:    cmovael %ecx, %eax
; X86-NEXT:    # kill: def $al killed $al killed $eax
; X86-NEXT:    retl
;
; X64-LABEL: func8:
; X64:       # %bb.0:
; X64-NEXT:    movl %esi, %eax
; X64-NEXT:    # kill: def $al killed $al killed $eax
; X64-NEXT:    mulb %dl
; X64-NEXT:    addb %dil, %al
; X64-NEXT:    movzbl %al, %ecx
; X64-NEXT:    movl $255, %eax
; X64-NEXT:    cmovael %ecx, %eax
; X64-NEXT:    # kill: def $al killed $al killed $eax
; X64-NEXT:    retq
  %a = mul i8 %y, %z
  %tmp = call i8 @llvm.uadd.sat.i8(i8 %x, i8 %a)
  ret i8 %tmp
}

define zeroext i4 @func4(i4 zeroext %x, i4 zeroext %y, i4 zeroext %z) nounwind {
; X86-LABEL: func4:
; X86:       # %bb.0:
; X86-NEXT:    movb {{[0-9]+}}(%esp), %cl
; X86-NEXT:    movb {{[0-9]+}}(%esp), %al
; X86-NEXT:    mulb {{[0-9]+}}(%esp)
; X86-NEXT:    shlb $4, %al
; X86-NEXT:    shlb $4, %cl
; X86-NEXT:    addb %al, %cl
; X86-NEXT:    movzbl %cl, %eax
; X86-NEXT:    movl $255, %ecx
; X86-NEXT:    cmovael %eax, %ecx
; X86-NEXT:    shrb $4, %cl
; X86-NEXT:    movzbl %cl, %eax
; X86-NEXT:    retl
;
; X64-LABEL: func4:
; X64:       # %bb.0:
; X64-NEXT:    movl %esi, %eax
; X64-NEXT:    # kill: def $al killed $al killed $eax
; X64-NEXT:    mulb %dl
; X64-NEXT:    shlb $4, %al
; X64-NEXT:    shlb $4, %dil
; X64-NEXT:    addb %al, %dil
; X64-NEXT:    movzbl %dil, %eax
; X64-NEXT:    movl $255, %ecx
; X64-NEXT:    cmovael %eax, %ecx
; X64-NEXT:    shrb $4, %cl
; X64-NEXT:    movzbl %cl, %eax
; X64-NEXT:    retq
  %a = mul i4 %y, %z
  %tmp = call i4 @llvm.uadd.sat.i4(i4 %x, i4 %a)
  ret i4 %tmp
}
