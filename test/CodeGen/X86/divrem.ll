; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown | FileCheck %s --check-prefix=X32
; RUN: llc < %s -mtriple=x86_64-unknown | FileCheck %s --check-prefix=X64

define void @si64(i64 %x, i64 %y, i64* %p, i64* %q) nounwind {
; X32-LABEL: si64:
; X32:       # %bb.0:
; X32-NEXT:    pushl %ebp
; X32-NEXT:    pushl %ebx
; X32-NEXT:    pushl %edi
; X32-NEXT:    pushl %esi
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ebx
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ebp
; X32-NEXT:    pushl %ebp
; X32-NEXT:    pushl %ebx
; X32-NEXT:    pushl {{[0-9]+}}(%esp)
; X32-NEXT:    pushl {{[0-9]+}}(%esp)
; X32-NEXT:    calll __divdi3
; X32-NEXT:    addl $16, %esp
; X32-NEXT:    movl %eax, %esi
; X32-NEXT:    movl %edx, %edi
; X32-NEXT:    pushl %ebp
; X32-NEXT:    pushl %ebx
; X32-NEXT:    pushl {{[0-9]+}}(%esp)
; X32-NEXT:    pushl {{[0-9]+}}(%esp)
; X32-NEXT:    calll __moddi3
; X32-NEXT:    addl $16, %esp
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-NEXT:    movl %edi, 4(%ecx)
; X32-NEXT:    movl %esi, (%ecx)
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-NEXT:    movl %edx, 4(%ecx)
; X32-NEXT:    movl %eax, (%ecx)
; X32-NEXT:    popl %esi
; X32-NEXT:    popl %edi
; X32-NEXT:    popl %ebx
; X32-NEXT:    popl %ebp
; X32-NEXT:    retl
;
; X64-LABEL: si64:
; X64:       # %bb.0:
; X64-NEXT:    movq %rdx, %r8
; X64-NEXT:    movq %rdi, %rax
; X64-NEXT:    cqto
; X64-NEXT:    idivq %rsi
; X64-NEXT:    movq %rax, (%r8)
; X64-NEXT:    movq %rdx, (%rcx)
; X64-NEXT:    retq
	%r = sdiv i64 %x, %y
	%t = srem i64 %x, %y
	store i64 %r, i64* %p
	store i64 %t, i64* %q
	ret void
}

define void @si32(i32 %x, i32 %y, i32* %p, i32* %q) nounwind {
; X32-LABEL: si32:
; X32:       # %bb.0:
; X32-NEXT:    pushl %esi
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    cltd
; X32-NEXT:    idivl {{[0-9]+}}(%esp)
; X32-NEXT:    movl %eax, (%esi)
; X32-NEXT:    movl %edx, (%ecx)
; X32-NEXT:    popl %esi
; X32-NEXT:    retl
;
; X64-LABEL: si32:
; X64:       # %bb.0:
; X64-NEXT:    movq %rdx, %r8
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    cltd
; X64-NEXT:    idivl %esi
; X64-NEXT:    movl %eax, (%r8)
; X64-NEXT:    movl %edx, (%rcx)
; X64-NEXT:    retq
	%r = sdiv i32 %x, %y
	%t = srem i32 %x, %y
	store i32 %r, i32* %p
	store i32 %t, i32* %q
	ret void
}

define void @si16(i16 %x, i16 %y, i16* %p, i16* %q) nounwind {
; X32-LABEL: si16:
; X32:       # %bb.0:
; X32-NEXT:    pushl %esi
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X32-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    cwtd
; X32-NEXT:    idivw {{[0-9]+}}(%esp)
; X32-NEXT:    movw %ax, (%esi)
; X32-NEXT:    movw %dx, (%ecx)
; X32-NEXT:    popl %esi
; X32-NEXT:    retl
;
; X64-LABEL: si16:
; X64:       # %bb.0:
; X64-NEXT:    movq %rdx, %r8
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    cwtd
; X64-NEXT:    idivw %si
; X64-NEXT:    movw %ax, (%r8)
; X64-NEXT:    movw %dx, (%rcx)
; X64-NEXT:    retq
	%r = sdiv i16 %x, %y
	%t = srem i16 %x, %y
	store i16 %r, i16* %p
	store i16 %t, i16* %q
	ret void
}

define void @si8(i8 %x, i8 %y, i8* %p, i8* %q) nounwind {
; X32-LABEL: si8:
; X32:       # %bb.0:
; X32-NEXT:    pushl %ebx
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X32-NEXT:    movb {{[0-9]+}}(%esp), %al
; X32-NEXT:    cbtw
; X32-NEXT:    idivb {{[0-9]+}}(%esp)
; X32-NEXT:    movsbl %ah, %ebx # NOREX
; X32-NEXT:    movb %al, (%edx)
; X32-NEXT:    movb %bl, (%ecx)
; X32-NEXT:    popl %ebx
; X32-NEXT:    retl
;
; X64-LABEL: si8:
; X64:       # %bb.0:
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    cbtw
; X64-NEXT:    idivb %sil
; X64-NEXT:    movsbl %ah, %esi # NOREX
; X64-NEXT:    movb %al, (%rdx)
; X64-NEXT:    movb %sil, (%rcx)
; X64-NEXT:    retq
	%r = sdiv i8 %x, %y
	%t = srem i8 %x, %y
	store i8 %r, i8* %p
	store i8 %t, i8* %q
	ret void
}

define void @ui64(i64 %x, i64 %y, i64* %p, i64* %q) nounwind {
; X32-LABEL: ui64:
; X32:       # %bb.0:
; X32-NEXT:    pushl %ebp
; X32-NEXT:    pushl %ebx
; X32-NEXT:    pushl %edi
; X32-NEXT:    pushl %esi
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ebx
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ebp
; X32-NEXT:    pushl %ebp
; X32-NEXT:    pushl %ebx
; X32-NEXT:    pushl {{[0-9]+}}(%esp)
; X32-NEXT:    pushl {{[0-9]+}}(%esp)
; X32-NEXT:    calll __udivdi3
; X32-NEXT:    addl $16, %esp
; X32-NEXT:    movl %eax, %esi
; X32-NEXT:    movl %edx, %edi
; X32-NEXT:    pushl %ebp
; X32-NEXT:    pushl %ebx
; X32-NEXT:    pushl {{[0-9]+}}(%esp)
; X32-NEXT:    pushl {{[0-9]+}}(%esp)
; X32-NEXT:    calll __umoddi3
; X32-NEXT:    addl $16, %esp
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-NEXT:    movl %edi, 4(%ecx)
; X32-NEXT:    movl %esi, (%ecx)
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-NEXT:    movl %edx, 4(%ecx)
; X32-NEXT:    movl %eax, (%ecx)
; X32-NEXT:    popl %esi
; X32-NEXT:    popl %edi
; X32-NEXT:    popl %ebx
; X32-NEXT:    popl %ebp
; X32-NEXT:    retl
;
; X64-LABEL: ui64:
; X64:       # %bb.0:
; X64-NEXT:    movq %rdx, %r8
; X64-NEXT:    xorl %edx, %edx
; X64-NEXT:    movq %rdi, %rax
; X64-NEXT:    divq %rsi
; X64-NEXT:    movq %rax, (%r8)
; X64-NEXT:    movq %rdx, (%rcx)
; X64-NEXT:    retq
	%r = udiv i64 %x, %y
	%t = urem i64 %x, %y
	store i64 %r, i64* %p
	store i64 %t, i64* %q
	ret void
}

define void @ui32(i32 %x, i32 %y, i32* %p, i32* %q) nounwind {
; X32-LABEL: ui32:
; X32:       # %bb.0:
; X32-NEXT:    pushl %esi
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    xorl %edx, %edx
; X32-NEXT:    divl {{[0-9]+}}(%esp)
; X32-NEXT:    movl %eax, (%esi)
; X32-NEXT:    movl %edx, (%ecx)
; X32-NEXT:    popl %esi
; X32-NEXT:    retl
;
; X64-LABEL: ui32:
; X64:       # %bb.0:
; X64-NEXT:    movq %rdx, %r8
; X64-NEXT:    xorl %edx, %edx
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    divl %esi
; X64-NEXT:    movl %eax, (%r8)
; X64-NEXT:    movl %edx, (%rcx)
; X64-NEXT:    retq
	%r = udiv i32 %x, %y
	%t = urem i32 %x, %y
	store i32 %r, i32* %p
	store i32 %t, i32* %q
	ret void
}

define void @ui16(i16 %x, i16 %y, i16* %p, i16* %q) nounwind {
; X32-LABEL: ui16:
; X32:       # %bb.0:
; X32-NEXT:    pushl %esi
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X32-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    xorl %edx, %edx
; X32-NEXT:    divw {{[0-9]+}}(%esp)
; X32-NEXT:    movw %ax, (%esi)
; X32-NEXT:    movw %dx, (%ecx)
; X32-NEXT:    popl %esi
; X32-NEXT:    retl
;
; X64-LABEL: ui16:
; X64:       # %bb.0:
; X64-NEXT:    movq %rdx, %r8
; X64-NEXT:    xorl %edx, %edx
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    divw %si
; X64-NEXT:    movw %ax, (%r8)
; X64-NEXT:    movw %dx, (%rcx)
; X64-NEXT:    retq
	%r = udiv i16 %x, %y
	%t = urem i16 %x, %y
	store i16 %r, i16* %p
	store i16 %t, i16* %q
	ret void
}

define void @ui8(i8 %x, i8 %y, i8* %p, i8* %q) nounwind {
; X32-LABEL: ui8:
; X32:       # %bb.0:
; X32-NEXT:    pushl %ebx
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X32-NEXT:    movzbl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    # kill: %eax<def> %eax<kill> %ax<def>
; X32-NEXT:    divb {{[0-9]+}}(%esp)
; X32-NEXT:    movzbl %ah, %ebx # NOREX
; X32-NEXT:    movb %al, (%edx)
; X32-NEXT:    movb %bl, (%ecx)
; X32-NEXT:    popl %ebx
; X32-NEXT:    retl
;
; X64-LABEL: ui8:
; X64:       # %bb.0:
; X64-NEXT:    movzbl %dil, %eax
; X64-NEXT:    # kill: %eax<def> %eax<kill> %ax<def>
; X64-NEXT:    divb %sil
; X64-NEXT:    movzbl %ah, %esi # NOREX
; X64-NEXT:    movb %al, (%rdx)
; X64-NEXT:    movb %sil, (%rcx)
; X64-NEXT:    retq
	%r = udiv i8 %x, %y
	%t = urem i8 %x, %y
	store i8 %r, i8* %p
	store i8 %t, i8* %q
	ret void
}
