; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-unknown -mattr=+avx | FileCheck %s --check-prefix=X32
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx | FileCheck %s --check-prefix=X64

define void @knownbits_zext_in_reg(i8*) nounwind {
; X32-LABEL: knownbits_zext_in_reg:
; X32:       # BB#0: # %BB
; X32-NEXT:    pushl %ebp
; X32-NEXT:    pushl %ebx
; X32-NEXT:    pushl %edi
; X32-NEXT:    pushl %esi
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    movzbl (%eax), %eax
; X32-NEXT:    imull $101, %eax, %eax
; X32-NEXT:    andl $16384, %eax # imm = 0x4000
; X32-NEXT:    shrl $14, %eax
; X32-NEXT:    movzbl %al, %eax
; X32-NEXT:    vmovd %eax, %xmm0
; X32-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[1,0,1,1]
; X32-NEXT:    vpand {{\.LCPI.*}}, %xmm0, %xmm0
; X32-NEXT:    vpextrd $1, %xmm0, %ebp
; X32-NEXT:    vmovd %xmm0, %esi
; X32-NEXT:    vpextrd $2, %xmm0, %edi
; X32-NEXT:    vpextrd $3, %xmm0, %ebx
; X32-NEXT:    xorl %ecx, %ecx
; X32-NEXT:    .p2align 4, 0x90
; X32-NEXT:  .LBB0_1: # %CF
; X32-NEXT:    # =>This Loop Header: Depth=1
; X32-NEXT:    # Child Loop BB0_2 Depth 2
; X32-NEXT:    movl %ebp, %eax
; X32-NEXT:    cltd
; X32-NEXT:    idivl %ebp
; X32-NEXT:    movl %esi, %eax
; X32-NEXT:    cltd
; X32-NEXT:    idivl %esi
; X32-NEXT:    movl %edi, %eax
; X32-NEXT:    cltd
; X32-NEXT:    idivl %edi
; X32-NEXT:    movl %ebx, %eax
; X32-NEXT:    cltd
; X32-NEXT:    idivl %ebx
; X32-NEXT:    .p2align 4, 0x90
; X32-NEXT:  .LBB0_2: # %CF237
; X32-NEXT:    # Parent Loop BB0_1 Depth=1
; X32-NEXT:    # => This Inner Loop Header: Depth=2
; X32-NEXT:    testb %cl, %cl
; X32-NEXT:    jne .LBB0_2
; X32-NEXT:    jmp .LBB0_1
;
; X64-LABEL: knownbits_zext_in_reg:
; X64:       # BB#0: # %BB
; X64-NEXT:    movzbl (%rdi), %eax
; X64-NEXT:    imull $101, %eax, %eax
; X64-NEXT:    andl $16384, %eax # imm = 0x4000
; X64-NEXT:    shrl $14, %eax
; X64-NEXT:    movzbl %al, %eax
; X64-NEXT:    vmovd %eax, %xmm0
; X64-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[1,0,1,1]
; X64-NEXT:    vpand {{.*}}(%rip), %xmm0, %xmm0
; X64-NEXT:    vpextrd $1, %xmm0, %r8d
; X64-NEXT:    vmovd %xmm0, %r9d
; X64-NEXT:    vpextrd $2, %xmm0, %edi
; X64-NEXT:    vpextrd $3, %xmm0, %ecx
; X64-NEXT:    xorl %esi, %esi
; X64-NEXT:    .p2align 4, 0x90
; X64-NEXT:  .LBB0_1: # %CF
; X64-NEXT:    # =>This Loop Header: Depth=1
; X64-NEXT:    # Child Loop BB0_2 Depth 2
; X64-NEXT:    movl %r8d, %eax
; X64-NEXT:    cltd
; X64-NEXT:    idivl %r8d
; X64-NEXT:    movl %r9d, %eax
; X64-NEXT:    cltd
; X64-NEXT:    idivl %r9d
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    cltd
; X64-NEXT:    idivl %edi
; X64-NEXT:    movl %ecx, %eax
; X64-NEXT:    cltd
; X64-NEXT:    idivl %ecx
; X64-NEXT:    .p2align 4, 0x90
; X64-NEXT:  .LBB0_2: # %CF237
; X64-NEXT:    # Parent Loop BB0_1 Depth=1
; X64-NEXT:    # => This Inner Loop Header: Depth=2
; X64-NEXT:    testb %sil, %sil
; X64-NEXT:    jne .LBB0_2
; X64-NEXT:    jmp .LBB0_1
BB:
  %L5 = load i8, i8* %0
  %Sl9 = select i1 true, i8 %L5, i8 undef
  %B21 = udiv i8 %Sl9, -93
  br label %CF

CF:                                               ; preds = %CF246, %BB
  %I40 = insertelement <4 x i8> zeroinitializer, i8 %B21, i32 1
  %B41 = srem <4 x i8> %I40, %I40
  br label %CF237

CF237:                                            ; preds = %CF237, %CF
  %Cmp73 = icmp ne i1 undef, undef
  br i1 %Cmp73, label %CF237, label %CF246

CF246:                                            ; preds = %CF237
  %Cmp117 = icmp ult <4 x i8> %B41, undef
  %E156 = extractelement <4 x i1> %Cmp117, i32 2
  br label %CF
}
