; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown -mattr=+sse2 | FileCheck %s --check-prefix=X86 --check-prefix=X86-SSE2
; RUN: llc < %s -mtriple=i686-unknown -mattr=+sse4.2 | FileCheck %s --check-prefix=X86 --check-prefix=X86-SSE42
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+sse2 | FileCheck %s --check-prefix=X64 --check-prefix=X64-SSE2
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+sse4.2 | FileCheck %s --check-prefix=X64 --check-prefix=X64-SSE42

; unsigned to float v7i16 to v7f32

define void @convert_v7i16_v7f32(<7 x float>* %dst.addr, <7 x i16> %src) nounwind {
; X86-SSE2-LABEL: convert_v7i16_v7f32:
; X86-SSE2:       # BB#0: # %entry
; X86-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-SSE2-NEXT:    pxor %xmm1, %xmm1
; X86-SSE2-NEXT:    movdqa %xmm0, %xmm2
; X86-SSE2-NEXT:    punpckhwd {{.*#+}} xmm2 = xmm2[4],xmm1[4],xmm2[5],xmm1[5],xmm2[6],xmm1[6],xmm2[7],xmm1[7]
; X86-SSE2-NEXT:    cvtdq2ps %xmm2, %xmm2
; X86-SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; X86-SSE2-NEXT:    cvtdq2ps %xmm0, %xmm0
; X86-SSE2-NEXT:    movups %xmm0, (%eax)
; X86-SSE2-NEXT:    movss %xmm2, 16(%eax)
; X86-SSE2-NEXT:    movaps %xmm2, %xmm0
; X86-SSE2-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; X86-SSE2-NEXT:    movss %xmm0, 24(%eax)
; X86-SSE2-NEXT:    shufps {{.*#+}} xmm2 = xmm2[1,1,2,3]
; X86-SSE2-NEXT:    movss %xmm2, 20(%eax)
; X86-SSE2-NEXT:    retl
;
; X86-SSE42-LABEL: convert_v7i16_v7f32:
; X86-SSE42:       # BB#0: # %entry
; X86-SSE42-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-SSE42-NEXT:    pxor %xmm1, %xmm1
; X86-SSE42-NEXT:    pmovzxwd {{.*#+}} xmm2 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero
; X86-SSE42-NEXT:    punpckhwd {{.*#+}} xmm0 = xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; X86-SSE42-NEXT:    cvtdq2ps %xmm0, %xmm0
; X86-SSE42-NEXT:    cvtdq2ps %xmm2, %xmm1
; X86-SSE42-NEXT:    extractps $2, %xmm0, 24(%eax)
; X86-SSE42-NEXT:    extractps $1, %xmm0, 20(%eax)
; X86-SSE42-NEXT:    movups %xmm1, (%eax)
; X86-SSE42-NEXT:    movss %xmm0, 16(%eax)
; X86-SSE42-NEXT:    retl
;
; X64-SSE2-LABEL: convert_v7i16_v7f32:
; X64-SSE2:       # BB#0: # %entry
; X64-SSE2-NEXT:    pxor %xmm1, %xmm1
; X64-SSE2-NEXT:    movdqa %xmm0, %xmm2
; X64-SSE2-NEXT:    punpcklwd {{.*#+}} xmm2 = xmm2[0],xmm1[0],xmm2[1],xmm1[1],xmm2[2],xmm1[2],xmm2[3],xmm1[3]
; X64-SSE2-NEXT:    cvtdq2ps %xmm2, %xmm2
; X64-SSE2-NEXT:    punpckhwd {{.*#+}} xmm0 = xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; X64-SSE2-NEXT:    cvtdq2ps %xmm0, %xmm0
; X64-SSE2-NEXT:    movlps %xmm0, 16(%rdi)
; X64-SSE2-NEXT:    movups %xmm2, (%rdi)
; X64-SSE2-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; X64-SSE2-NEXT:    movss %xmm0, 24(%rdi)
; X64-SSE2-NEXT:    retq
;
; X64-SSE42-LABEL: convert_v7i16_v7f32:
; X64-SSE42:       # BB#0: # %entry
; X64-SSE42-NEXT:    pxor %xmm1, %xmm1
; X64-SSE42-NEXT:    pmovzxwd {{.*#+}} xmm2 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero
; X64-SSE42-NEXT:    punpckhwd {{.*#+}} xmm0 = xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; X64-SSE42-NEXT:    cvtdq2ps %xmm0, %xmm0
; X64-SSE42-NEXT:    cvtdq2ps %xmm2, %xmm1
; X64-SSE42-NEXT:    extractps $2, %xmm0, 24(%rdi)
; X64-SSE42-NEXT:    movlps %xmm0, 16(%rdi)
; X64-SSE42-NEXT:    movups %xmm1, (%rdi)
; X64-SSE42-NEXT:    retq
entry:
	%val = uitofp <7 x i16> %src to <7 x float>
	store <7 x float> %val, <7 x float>* %dst.addr, align 4
	ret void
}

; unsigned to float v3i8 to v3f32

define void @convert_v3i8_to_v3f32(<3 x float>* %dst.addr, <3 x i8>* %src.addr) nounwind {
; X86-SSE2-LABEL: convert_v3i8_to_v3f32:
; X86-SSE2:       # BB#0: # %entry
; X86-SSE2-NEXT:    pushl %ebp
; X86-SSE2-NEXT:    movl %esp, %ebp
; X86-SSE2-NEXT:    pushl %esi
; X86-SSE2-NEXT:    andl $-16, %esp
; X86-SSE2-NEXT:    subl $32, %esp
; X86-SSE2-NEXT:    movl 8(%ebp), %eax
; X86-SSE2-NEXT:    movl 12(%ebp), %ecx
; X86-SSE2-NEXT:    movzwl (%ecx), %edx
; X86-SSE2-NEXT:    movd %edx, %xmm0
; X86-SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; X86-SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3]
; X86-SSE2-NEXT:    movdqa %xmm0, (%esp)
; X86-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-SSE2-NEXT:    shll $8, %edx
; X86-SSE2-NEXT:    movzbl (%esp), %esi
; X86-SSE2-NEXT:    orl %edx, %esi
; X86-SSE2-NEXT:    pinsrw $0, %esi, %xmm0
; X86-SSE2-NEXT:    movzbl 2(%ecx), %ecx
; X86-SSE2-NEXT:    pinsrw $1, %ecx, %xmm0
; X86-SSE2-NEXT:    pxor %xmm1, %xmm1
; X86-SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; X86-SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; X86-SSE2-NEXT:    cvtdq2ps %xmm0, %xmm0
; X86-SSE2-NEXT:    movss %xmm0, (%eax)
; X86-SSE2-NEXT:    movaps %xmm0, %xmm1
; X86-SSE2-NEXT:    movhlps {{.*#+}} xmm1 = xmm1[1,1]
; X86-SSE2-NEXT:    movss %xmm1, 8(%eax)
; X86-SSE2-NEXT:    shufps {{.*#+}} xmm0 = xmm0[1,1,2,3]
; X86-SSE2-NEXT:    movss %xmm0, 4(%eax)
; X86-SSE2-NEXT:    leal -4(%ebp), %esp
; X86-SSE2-NEXT:    popl %esi
; X86-SSE2-NEXT:    popl %ebp
; X86-SSE2-NEXT:    retl
;
; X86-SSE42-LABEL: convert_v3i8_to_v3f32:
; X86-SSE42:       # BB#0: # %entry
; X86-SSE42-NEXT:    pushl %eax
; X86-SSE42-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-SSE42-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-SSE42-NEXT:    movzbl 2(%ecx), %edx
; X86-SSE42-NEXT:    movzwl (%ecx), %ecx
; X86-SSE42-NEXT:    movd %ecx, %xmm0
; X86-SSE42-NEXT:    pmovzxbd {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero
; X86-SSE42-NEXT:    pinsrd $2, %edx, %xmm0
; X86-SSE42-NEXT:    pand {{\.LCPI.*}}, %xmm0
; X86-SSE42-NEXT:    cvtdq2ps %xmm0, %xmm0
; X86-SSE42-NEXT:    extractps $2, %xmm0, 8(%eax)
; X86-SSE42-NEXT:    extractps $1, %xmm0, 4(%eax)
; X86-SSE42-NEXT:    movss %xmm0, (%eax)
; X86-SSE42-NEXT:    popl %eax
; X86-SSE42-NEXT:    retl
;
; X64-SSE2-LABEL: convert_v3i8_to_v3f32:
; X64-SSE2:       # BB#0: # %entry
; X64-SSE2-NEXT:    movzwl (%rsi), %eax
; X64-SSE2-NEXT:    movd %rax, %xmm0
; X64-SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; X64-SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,2,2,3,4,5,6,7]
; X64-SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; X64-SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3]
; X64-SSE2-NEXT:    movdqa %xmm0, -{{[0-9]+}}(%rsp)
; X64-SSE2-NEXT:    movl -{{[0-9]+}}(%rsp), %eax
; X64-SSE2-NEXT:    shll $8, %eax
; X64-SSE2-NEXT:    movzbl -{{[0-9]+}}(%rsp), %ecx
; X64-SSE2-NEXT:    orl %eax, %ecx
; X64-SSE2-NEXT:    pinsrw $0, %ecx, %xmm0
; X64-SSE2-NEXT:    movzbl 2(%rsi), %eax
; X64-SSE2-NEXT:    pinsrw $1, %eax, %xmm0
; X64-SSE2-NEXT:    pxor %xmm1, %xmm1
; X64-SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; X64-SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; X64-SSE2-NEXT:    cvtdq2ps %xmm0, %xmm0
; X64-SSE2-NEXT:    movlps %xmm0, (%rdi)
; X64-SSE2-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; X64-SSE2-NEXT:    movss %xmm0, 8(%rdi)
; X64-SSE2-NEXT:    retq
;
; X64-SSE42-LABEL: convert_v3i8_to_v3f32:
; X64-SSE42:       # BB#0: # %entry
; X64-SSE42-NEXT:    movzbl 2(%rsi), %eax
; X64-SSE42-NEXT:    movzwl (%rsi), %ecx
; X64-SSE42-NEXT:    movd %rcx, %xmm0
; X64-SSE42-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; X64-SSE42-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,2,2,3,4,5,6,7]
; X64-SSE42-NEXT:    pmovzxbd {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero
; X64-SSE42-NEXT:    pinsrd $2, %eax, %xmm0
; X64-SSE42-NEXT:    pand {{.*}}(%rip), %xmm0
; X64-SSE42-NEXT:    cvtdq2ps %xmm0, %xmm0
; X64-SSE42-NEXT:    extractps $2, %xmm0, 8(%rdi)
; X64-SSE42-NEXT:    movlps %xmm0, (%rdi)
; X64-SSE42-NEXT:    retq
entry:
	%load = load <3 x i8>, <3 x i8>* %src.addr, align 1
	%cvt = uitofp <3 x i8> %load to <3 x float>
	store <3 x float> %cvt, <3 x float>* %dst.addr, align 4
	ret void
}
