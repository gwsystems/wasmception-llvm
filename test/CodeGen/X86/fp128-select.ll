; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -O2 -mtriple=x86_64-linux-android -mattr=+mmx \
; RUN:     -enable-legalize-types-checking | FileCheck %s --check-prefix=MMX
; RUN: llc < %s -O2 -mtriple=x86_64-linux-gnu -mattr=+mmx \
; RUN:     -enable-legalize-types-checking | FileCheck %s --check-prefix=MMX
; RUN: llc < %s -O2 -mtriple=x86_64-linux-android \
; RUN:     -enable-legalize-types-checking | FileCheck %s
; RUN: llc < %s -O2 -mtriple=x86_64-linux-gnu \
; RUN:     -enable-legalize-types-checking | FileCheck %s

define void @test_select(fp128* %p, fp128* %q, i1 zeroext %c) {
; MMX-LABEL: test_select:
; MMX:       # BB#0:
; MMX-NEXT:    testl %edx, %edx
; MMX-NEXT:    jne .LBB0_1
; MMX-NEXT:  # BB#2:
; MMX-NEXT:    movaps {{.*}}(%rip), %xmm0
; MMX-NEXT:    movaps %xmm0, (%rsi)
; MMX-NEXT:    retq
; MMX-NEXT:  .LBB0_1:
; MMX-NEXT:    movaps (%rdi), %xmm0
; MMX-NEXT:    movaps %xmm0, (%rsi)
; MMX-NEXT:    retq
;
; CHECK-LABEL: test_select:
; CHECK:       # BB#0:
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    testl %edx, %edx
; CHECK-NEXT:    cmovneq (%rdi), %rax
; CHECK-NEXT:    movabsq $9223231299366420480, %rcx # imm = 0x7FFF800000000000
; CHECK-NEXT:    cmovneq 8(%rdi), %rcx
; CHECK-NEXT:    movq %rcx, 8(%rsi)
; CHECK-NEXT:    movq %rax, (%rsi)
; CHECK-NEXT:    retq
  %a = load fp128, fp128* %p, align 2
  %r = select i1 %c, fp128 %a, fp128 0xL00000000000000007FFF800000000000
  store fp128 %r, fp128* %q
  ret void
}
