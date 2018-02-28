; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mattr=+avx512f | FileCheck %s --check-prefix=ALL --check-prefix=KNL
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mattr=+avx512f,+avx512bw,+avx512vl,+avx512dq | FileCheck %s --check-prefix=ALL --check-prefix=SKX

define double @test1(double %a, double %b) nounwind {
; ALL-LABEL: test1:
; ALL:       ## %bb.0:
; ALL-NEXT:    vucomisd %xmm1, %xmm0
; ALL-NEXT:    jne LBB0_1
; ALL-NEXT:    jnp LBB0_2
; ALL-NEXT:  LBB0_1: ## %l1
; ALL-NEXT:    vsubsd %xmm1, %xmm0, %xmm0
; ALL-NEXT:    retq
; ALL-NEXT:  LBB0_2: ## %l2
; ALL-NEXT:    vaddsd %xmm1, %xmm0, %xmm0
; ALL-NEXT:    retq
  %tobool = fcmp une double %a, %b
  br i1 %tobool, label %l1, label %l2

l1:
  %c = fsub double %a, %b
  ret double %c
l2:
  %c1 = fadd double %a, %b
  ret double %c1
}

define float @test2(float %a, float %b) nounwind {
; ALL-LABEL: test2:
; ALL:       ## %bb.0:
; ALL-NEXT:    vucomiss %xmm0, %xmm1
; ALL-NEXT:    jbe LBB1_2
; ALL-NEXT:  ## %bb.1: ## %l1
; ALL-NEXT:    vsubss %xmm1, %xmm0, %xmm0
; ALL-NEXT:    retq
; ALL-NEXT:  LBB1_2: ## %l2
; ALL-NEXT:    vaddss %xmm1, %xmm0, %xmm0
; ALL-NEXT:    retq
  %tobool = fcmp olt float %a, %b
  br i1 %tobool, label %l1, label %l2

l1:
  %c = fsub float %a, %b
  ret float %c
l2:
  %c1 = fadd float %a, %b
  ret float %c1
}

define i32 @test3(float %a, float %b) {
; ALL-LABEL: test3:
; ALL:       ## %bb.0:
; ALL-NEXT:    vcmpeqss %xmm1, %xmm0, %k0
; ALL-NEXT:    kmovw %k0, %eax
; ALL-NEXT:    retq

  %cmp10.i = fcmp oeq float %a, %b
  %conv11.i = zext i1 %cmp10.i to i32
  ret i32 %conv11.i
}

define float @test5(float %p) #0 {
; ALL-LABEL: test5:
; ALL:       ## %bb.0: ## %entry
; ALL-NEXT:    vxorps %xmm1, %xmm1, %xmm1
; ALL-NEXT:    vucomiss %xmm1, %xmm0
; ALL-NEXT:    jne LBB3_1
; ALL-NEXT:    jp LBB3_1
; ALL-NEXT:  ## %bb.2: ## %return
; ALL-NEXT:    retq
; ALL-NEXT:  LBB3_1: ## %if.end
; ALL-NEXT:    seta %al
; ALL-NEXT:    movzbl %al, %eax
; ALL-NEXT:    leaq {{.*}}(%rip), %rcx
; ALL-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; ALL-NEXT:    retq
entry:
  %cmp = fcmp oeq float %p, 0.000000e+00
  br i1 %cmp, label %return, label %if.end

if.end:                                           ; preds = %entry
  %cmp1 = fcmp ogt float %p, 0.000000e+00
  %cond = select i1 %cmp1, float 1.000000e+00, float -1.000000e+00
  br label %return

return:                                           ; preds = %if.end, %entry
  %retval.0 = phi float [ %cond, %if.end ], [ %p, %entry ]
  ret float %retval.0
}

define i32 @test6(i32 %a, i32 %b) {
; ALL-LABEL: test6:
; ALL:       ## %bb.0:
; ALL-NEXT:    xorl %eax, %eax
; ALL-NEXT:    cmpl %esi, %edi
; ALL-NEXT:    sete %al
; ALL-NEXT:    retq
  %cmp = icmp eq i32 %a, %b
  %res = zext i1 %cmp to i32
  ret i32 %res
}

define i32 @test7(double %x, double %y) #2 {
; ALL-LABEL: test7:
; ALL:       ## %bb.0: ## %entry
; ALL-NEXT:    xorl %eax, %eax
; ALL-NEXT:    vucomisd %xmm1, %xmm0
; ALL-NEXT:    setne %al
; ALL-NEXT:    retq
entry:
  %0 = fcmp one double %x, %y
  %or = zext i1 %0 to i32
  ret i32 %or
}

define i32 @test8(i32 %a1, i32 %a2, i32 %a3) {
; ALL-LABEL: test8:
; ALL:       ## %bb.0:
; ALL-NEXT:    notl %edi
; ALL-NEXT:    xorl $-2147483648, %esi ## imm = 0x80000000
; ALL-NEXT:    testl %edx, %edx
; ALL-NEXT:    movl $1, %eax
; ALL-NEXT:    cmovel %eax, %edx
; ALL-NEXT:    orl %edi, %esi
; ALL-NEXT:    cmovnel %edx, %eax
; ALL-NEXT:    retq
  %tmp1 = icmp eq i32 %a1, -1
  %tmp2 = icmp eq i32 %a2, -2147483648
  %tmp3 = and i1 %tmp1, %tmp2
  %tmp4 = icmp eq i32 %a3, 0
  %tmp5 = or i1 %tmp3, %tmp4
  %res = select i1 %tmp5, i32 1, i32 %a3
  ret i32 %res
}

define i32 @test9(i64 %a) {
; ALL-LABEL: test9:
; ALL:       ## %bb.0:
; ALL-NEXT:    testb $1, %dil
; ALL-NEXT:    jne LBB7_2
; ALL-NEXT:  ## %bb.1: ## %A
; ALL-NEXT:    movl $6, %eax
; ALL-NEXT:    retq
; ALL-NEXT:  LBB7_2: ## %B
; ALL-NEXT:    movl $7, %eax
; ALL-NEXT:    retq
 %b = and i64 %a, 1
 %cmp10.i = icmp eq i64 %b, 0
 br i1 %cmp10.i, label %A, label %B
A:
 ret i32 6
B:
 ret i32 7
}

define i32 @test10(i64 %b, i64 %c, i1 %d) {
; ALL-LABEL: test10:
; ALL:       ## %bb.0:
; ALL-NEXT:    movl %edx, %eax
; ALL-NEXT:    andb $1, %al
; ALL-NEXT:    cmpq %rsi, %rdi
; ALL-NEXT:    sete %cl
; ALL-NEXT:    orb %dl, %cl
; ALL-NEXT:    andb $1, %cl
; ALL-NEXT:    cmpb %cl, %al
; ALL-NEXT:    je LBB8_1
; ALL-NEXT:  ## %bb.2: ## %if.end.i
; ALL-NEXT:    movl $6, %eax
; ALL-NEXT:    retq
; ALL-NEXT:  LBB8_1: ## %if.then.i
; ALL-NEXT:    movl $5, %eax
; ALL-NEXT:    retq

  %cmp8.i = icmp eq i64 %b, %c
  %or1 = or i1 %d, %cmp8.i
  %xor1 = xor i1 %d, %or1
  br i1 %xor1, label %if.end.i, label %if.then.i

if.then.i:
 ret i32 5

if.end.i:
  ret i32 6
}
