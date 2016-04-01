; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-apple-darwin9 -mattr=+mmx,+sse4.2 | FileCheck %s --check-prefix=X32
; RUN: llc < %s -mtriple=x86_64-apple-darwin9 -mattr=+mmx,+sse4.2 | FileCheck %s --check-prefix=X64

; MMX insertelement is not available; these are promoted to XMM.
; (Without SSE they are split to two ints, and the code is much better.)

define x86_mmx @mmx_movzl(x86_mmx %x) nounwind {
; X32-LABEL: mmx_movzl:
; X32:       ## BB#0:
; X32-NEXT:    subl $20, %esp
; X32-NEXT:    movq %mm0, {{[0-9]+}}(%esp)
; X32-NEXT:    pmovzxdq {{.*#+}} xmm0 = mem[0],zero,mem[1],zero
; X32-NEXT:    movl $32, %eax
; X32-NEXT:    pinsrd $0, %eax, %xmm0
; X32-NEXT:    pxor %xmm1, %xmm1
; X32-NEXT:    pblendw {{.*#+}} xmm1 = xmm0[0,1],xmm1[2,3,4,5,6,7]
; X32-NEXT:    movq %xmm1, (%esp)
; X32-NEXT:    movq (%esp), %mm0
; X32-NEXT:    addl $20, %esp
; X32-NEXT:    retl
;
; X64-LABEL: mmx_movzl:
; X64:       ## BB#0:
; X64-NEXT:    movdq2q %xmm0, %mm0
; X64-NEXT:    movq %mm0, -{{[0-9]+}}(%rsp)
; X64-NEXT:    pmovzxdq {{.*#+}} xmm1 = mem[0],zero,mem[1],zero
; X64-NEXT:    movl $32, %eax
; X64-NEXT:    pinsrq $0, %rax, %xmm1
; X64-NEXT:    pxor %xmm0, %xmm0
; X64-NEXT:    pblendw {{.*#+}} xmm0 = xmm1[0,1],xmm0[2,3,4,5,6,7]
; X64-NEXT:    retq
  %tmp = bitcast x86_mmx %x to <2 x i32>
  %tmp3 = insertelement <2 x i32> %tmp, i32 32, i32 0
  %tmp8 = insertelement <2 x i32> %tmp3, i32 0, i32 1
  %tmp9 = bitcast <2 x i32> %tmp8 to x86_mmx
  ret x86_mmx %tmp9
}
