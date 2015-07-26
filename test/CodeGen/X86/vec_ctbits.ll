; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse2 | FileCheck %s

declare <2 x i64> @llvm.cttz.v2i64(<2 x i64>, i1)
declare <2 x i64> @llvm.ctlz.v2i64(<2 x i64>, i1)
declare <2 x i64> @llvm.ctpop.v2i64(<2 x i64>)

define <2 x i64> @footz(<2 x i64> %a) nounwind {
; CHECK-LABEL: footz:
; CHECK:       # BB#0:
; CHECK-NEXT:    movd %xmm0, %rax
; CHECK-NEXT:    bsfq %rax, %rax
; CHECK-NEXT:    movd %rax, %xmm1
; CHECK-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[2,3,0,1]
; CHECK-NEXT:    movd %xmm0, %rax
; CHECK-NEXT:    bsfq %rax, %rax
; CHECK-NEXT:    movd %rax, %xmm0
; CHECK-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm0[0]
; CHECK-NEXT:    movdqa %xmm1, %xmm0
; CHECK-NEXT:    retq
  %c = call <2 x i64> @llvm.cttz.v2i64(<2 x i64> %a, i1 true)
  ret <2 x i64> %c

}
define <2 x i64> @foolz(<2 x i64> %a) nounwind {
; CHECK-LABEL: foolz:
; CHECK:       # BB#0:
; CHECK-NEXT:    movd %xmm0, %rax
; CHECK-NEXT:    bsrq %rax, %rax
; CHECK-NEXT:    xorq $63, %rax
; CHECK-NEXT:    movd %rax, %xmm1
; CHECK-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[2,3,0,1]
; CHECK-NEXT:    movd %xmm0, %rax
; CHECK-NEXT:    bsrq %rax, %rax
; CHECK-NEXT:    xorq $63, %rax
; CHECK-NEXT:    movd %rax, %xmm0
; CHECK-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm0[0]
; CHECK-NEXT:    movdqa %xmm1, %xmm0
; CHECK-NEXT:    retq
  %c = call <2 x i64> @llvm.ctlz.v2i64(<2 x i64> %a, i1 true)
  ret <2 x i64> %c

}

define <2 x i64> @foopop(<2 x i64> %a) nounwind {
; CHECK-LABEL: foopop:
; CHECK:       # BB#0:
; CHECK-NEXT:    movdqa %xmm0, %xmm1
; CHECK-NEXT:    psrlq $1, %xmm1
; CHECK-NEXT:    pand {{.*}}(%rip), %xmm1
; CHECK-NEXT:    psubq %xmm1, %xmm0
; CHECK-NEXT:    movdqa {{.*#+}} xmm1 = [3689348814741910323,3689348814741910323]
; CHECK-NEXT:    movdqa %xmm0, %xmm2
; CHECK-NEXT:    pand %xmm1, %xmm2
; CHECK-NEXT:    psrlq $2, %xmm0
; CHECK-NEXT:    pand %xmm1, %xmm0
; CHECK-NEXT:    paddq %xmm2, %xmm0
; CHECK-NEXT:    movdqa %xmm0, %xmm1
; CHECK-NEXT:    psrlq $4, %xmm1
; CHECK-NEXT:    paddq %xmm0, %xmm1
; CHECK-NEXT:    pand {{.*}}(%rip), %xmm1
; CHECK-NEXT:    pxor %xmm0, %xmm0
; CHECK-NEXT:    psadbw %xmm0, %xmm1
; CHECK-NEXT:    movdqa %xmm1, %xmm0
; CHECK-NEXT:    retq
  %c = call <2 x i64> @llvm.ctpop.v2i64(<2 x i64> %a)
  ret <2 x i64> %c
}

declare <2 x i32> @llvm.cttz.v2i32(<2 x i32>, i1)
declare <2 x i32> @llvm.ctlz.v2i32(<2 x i32>, i1)
declare <2 x i32> @llvm.ctpop.v2i32(<2 x i32>)

define <2 x i32> @promtz(<2 x i32> %a) nounwind {
; CHECK-LABEL: promtz:
; CHECK:       # BB#0:
; CHECK-NEXT:    por {{.*}}(%rip), %xmm0
; CHECK-NEXT:    movd %xmm0, %rax
; CHECK-NEXT:    bsfq %rax, %rax
; CHECK-NEXT:    movl $64, %ecx
; CHECK-NEXT:    cmoveq %rcx, %rax
; CHECK-NEXT:    movd %rax, %xmm1
; CHECK-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[2,3,0,1]
; CHECK-NEXT:    movd %xmm0, %rax
; CHECK-NEXT:    bsfq %rax, %rax
; CHECK-NEXT:    cmoveq %rcx, %rax
; CHECK-NEXT:    movd %rax, %xmm0
; CHECK-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm0[0]
; CHECK-NEXT:    movdqa %xmm1, %xmm0
; CHECK-NEXT:    retq
  %c = call <2 x i32> @llvm.cttz.v2i32(<2 x i32> %a, i1 false)
  ret <2 x i32> %c

}
define <2 x i32> @promlz(<2 x i32> %a) nounwind {
; CHECK-LABEL: promlz:
; CHECK:       # BB#0:
; CHECK-NEXT:    pand {{.*}}(%rip), %xmm0
; CHECK-NEXT:    movd %xmm0, %rax
; CHECK-NEXT:    bsrq %rax, %rax
; CHECK-NEXT:    movl $127, %ecx
; CHECK-NEXT:    cmoveq %rcx, %rax
; CHECK-NEXT:    xorq $63, %rax
; CHECK-NEXT:    movd %rax, %xmm1
; CHECK-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[2,3,0,1]
; CHECK-NEXT:    movd %xmm0, %rax
; CHECK-NEXT:    bsrq %rax, %rax
; CHECK-NEXT:    cmoveq %rcx, %rax
; CHECK-NEXT:    xorq $63, %rax
; CHECK-NEXT:    movd %rax, %xmm0
; CHECK-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm0[0]
; CHECK-NEXT:    psubq {{.*}}(%rip), %xmm1
; CHECK-NEXT:    movdqa %xmm1, %xmm0
; CHECK-NEXT:    retq
  %c = call <2 x i32> @llvm.ctlz.v2i32(<2 x i32> %a, i1 false)
  ret <2 x i32> %c

}

define <2 x i32> @prompop(<2 x i32> %a) nounwind {
; CHECK-LABEL: prompop:
; CHECK:       # BB#0:
; CHECK-NEXT:    pand {{.*}}(%rip), %xmm0
; CHECK-NEXT:    movdqa %xmm0, %xmm1
; CHECK-NEXT:    psrlq $1, %xmm1
; CHECK-NEXT:    pand {{.*}}(%rip), %xmm1
; CHECK-NEXT:    psubq %xmm1, %xmm0
; CHECK-NEXT:    movdqa {{.*#+}} xmm1 = [3689348814741910323,3689348814741910323]
; CHECK-NEXT:    movdqa %xmm0, %xmm2
; CHECK-NEXT:    pand %xmm1, %xmm2
; CHECK-NEXT:    psrlq $2, %xmm0
; CHECK-NEXT:    pand %xmm1, %xmm0
; CHECK-NEXT:    paddq %xmm2, %xmm0
; CHECK-NEXT:    movdqa %xmm0, %xmm1
; CHECK-NEXT:    psrlq $4, %xmm1
; CHECK-NEXT:    paddq %xmm0, %xmm1
; CHECK-NEXT:    pand {{.*}}(%rip), %xmm1
; CHECK-NEXT:    pxor %xmm0, %xmm0
; CHECK-NEXT:    psadbw %xmm0, %xmm1
; CHECK-NEXT:    movdqa %xmm1, %xmm0
; CHECK-NEXT:    retq
  %c = call <2 x i32> @llvm.ctpop.v2i32(<2 x i32> %a)
  ret <2 x i32> %c
}
