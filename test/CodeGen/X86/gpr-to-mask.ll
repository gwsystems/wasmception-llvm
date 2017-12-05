; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=x86_64-unknown-unknown -mattr=+avx512f,+avx512bw,+avx512dq < %s | FileCheck %s --check-prefix=X86-64
; RUN: llc -mtriple=i386-unknown-unknown -mattr=+avx512f,+avx512bw,+avx512dq < %s | FileCheck %s --check-prefix=X86-32

define void @test_fcmp_storefloat(i1 %cond, float* %fptr, float %f1, float %f2, float %f3, float %f4, float %f5, float %f6) {
; X86-64-LABEL: test_fcmp_storefloat:
; X86-64:       # %bb.0: # %entry
; X86-64-NEXT:    testb $1, %dil
; X86-64-NEXT:    je .LBB0_2
; X86-64-NEXT:  # %bb.1: # %if
; X86-64-NEXT:    vcmpeqss %xmm3, %xmm2, %k1
; X86-64-NEXT:    jmp .LBB0_3
; X86-64-NEXT:  .LBB0_2: # %else
; X86-64-NEXT:    vcmpeqss %xmm5, %xmm4, %k1
; X86-64-NEXT:  .LBB0_3: # %exit
; X86-64-NEXT:    vmovss %xmm0, %xmm0, %xmm1 {%k1}
; X86-64-NEXT:    vmovss %xmm1, (%rsi)
; X86-64-NEXT:    retq
;
; X86-32-LABEL: test_fcmp_storefloat:
; X86-32:       # %bb.0: # %entry
; X86-32-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; X86-32-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; X86-32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-32-NEXT:    testb $1, {{[0-9]+}}(%esp)
; X86-32-NEXT:    je .LBB0_2
; X86-32-NEXT:  # %bb.1: # %if
; X86-32-NEXT:    vmovss {{.*#+}} xmm2 = mem[0],zero,zero,zero
; X86-32-NEXT:    vcmpeqss {{[0-9]+}}(%esp), %xmm2, %k1
; X86-32-NEXT:    jmp .LBB0_3
; X86-32-NEXT:  .LBB0_2: # %else
; X86-32-NEXT:    vmovss {{.*#+}} xmm2 = mem[0],zero,zero,zero
; X86-32-NEXT:    vcmpeqss {{[0-9]+}}(%esp), %xmm2, %k1
; X86-32-NEXT:  .LBB0_3: # %exit
; X86-32-NEXT:    vmovss %xmm1, %xmm0, %xmm0 {%k1}
; X86-32-NEXT:    vmovss %xmm0, (%eax)
; X86-32-NEXT:    retl
entry:
  br i1 %cond, label %if, label %else

if:
  %cmp1 = fcmp oeq float %f3, %f4
  br label %exit

else:
  %cmp2 = fcmp oeq float %f5, %f6
  br label %exit

exit:
  %val = phi i1 [%cmp1, %if], [%cmp2, %else]
  %selected = select i1 %val, float %f1, float %f2
  store float %selected, float* %fptr
  ret void
}

define void @test_fcmp_storei1(i1 %cond, float* %fptr, i1* %iptr, float %f1, float %f2, float %f3, float %f4) {
; X86-64-LABEL: test_fcmp_storei1:
; X86-64:       # %bb.0: # %entry
; X86-64-NEXT:    testb $1, %dil
; X86-64-NEXT:    je .LBB1_2
; X86-64-NEXT:  # %bb.1: # %if
; X86-64-NEXT:    vcmpeqss %xmm1, %xmm0, %k0
; X86-64-NEXT:    jmp .LBB1_3
; X86-64-NEXT:  .LBB1_2: # %else
; X86-64-NEXT:    vcmpeqss %xmm3, %xmm2, %k0
; X86-64-NEXT:  .LBB1_3: # %exit
; X86-64-NEXT:    kmovd %k0, %eax
; X86-64-NEXT:    andb $1, %al
; X86-64-NEXT:    movb %al, (%rdx)
; X86-64-NEXT:    retq
;
; X86-32-LABEL: test_fcmp_storei1:
; X86-32:       # %bb.0: # %entry
; X86-32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-32-NEXT:    testb $1, {{[0-9]+}}(%esp)
; X86-32-NEXT:    je .LBB1_2
; X86-32-NEXT:  # %bb.1: # %if
; X86-32-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; X86-32-NEXT:    vcmpeqss {{[0-9]+}}(%esp), %xmm0, %k0
; X86-32-NEXT:    jmp .LBB1_3
; X86-32-NEXT:  .LBB1_2: # %else
; X86-32-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; X86-32-NEXT:    vcmpeqss {{[0-9]+}}(%esp), %xmm0, %k0
; X86-32-NEXT:  .LBB1_3: # %exit
; X86-32-NEXT:    kmovd %k0, %ecx
; X86-32-NEXT:    andb $1, %cl
; X86-32-NEXT:    movb %cl, (%eax)
; X86-32-NEXT:    retl
entry:
  br i1 %cond, label %if, label %else

if:
  %cmp1 = fcmp oeq float %f1, %f2
  br label %exit

else:
  %cmp2 = fcmp oeq float %f3, %f4
  br label %exit

exit:
  %val = phi i1 [%cmp1, %if], [%cmp2, %else]
  store i1 %val, i1* %iptr
  ret void
}

define void @test_load_add(i1 %cond, float* %fptr, i1* %iptr1, i1* %iptr2, float %f1, float %f2)  {
; X86-64-LABEL: test_load_add:
; X86-64:       # %bb.0: # %entry
; X86-64-NEXT:    testb $1, %dil
; X86-64-NEXT:    je .LBB2_2
; X86-64-NEXT:  # %bb.1: # %if
; X86-64-NEXT:    kmovb (%rdx), %k0
; X86-64-NEXT:    kmovb (%rcx), %k1
; X86-64-NEXT:    kaddb %k1, %k0, %k1
; X86-64-NEXT:    jmp .LBB2_3
; X86-64-NEXT:  .LBB2_2: # %else
; X86-64-NEXT:    kmovb (%rcx), %k1
; X86-64-NEXT:  .LBB2_3: # %exit
; X86-64-NEXT:    vmovss %xmm0, %xmm0, %xmm1 {%k1}
; X86-64-NEXT:    vmovss %xmm1, (%rsi)
; X86-64-NEXT:    retq
;
; X86-32-LABEL: test_load_add:
; X86-32:       # %bb.0: # %entry
; X86-32-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; X86-32-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; X86-32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-32-NEXT:    testb $1, {{[0-9]+}}(%esp)
; X86-32-NEXT:    je .LBB2_2
; X86-32-NEXT:  # %bb.1: # %if
; X86-32-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-32-NEXT:    kmovb (%edx), %k0
; X86-32-NEXT:    kmovb (%ecx), %k1
; X86-32-NEXT:    kaddb %k1, %k0, %k1
; X86-32-NEXT:    jmp .LBB2_3
; X86-32-NEXT:  .LBB2_2: # %else
; X86-32-NEXT:    kmovb (%ecx), %k1
; X86-32-NEXT:  .LBB2_3: # %exit
; X86-32-NEXT:    vmovss %xmm1, %xmm0, %xmm0 {%k1}
; X86-32-NEXT:    vmovss %xmm0, (%eax)
; X86-32-NEXT:    retl
entry:
  br i1 %cond, label %if, label %else

if:
  %loaded1 = load i1, i1* %iptr1
  %loaded2if = load i1, i1* %iptr2
  %added = add i1 %loaded1, %loaded2if
  br label %exit

else:
  %loaded2else = load i1, i1* %iptr2
  br label %exit

exit:
  %val = phi i1 [%added, %if], [%loaded2else, %else]
  %selected = select i1 %val, float %f1, float %f2
  store float %selected, float* %fptr
  ret void
}

define void @test_load_i1(i1 %cond, float* %fptr, i1* %iptr1, i1* %iptr2, float %f1, float %f2)  {
; X86-64-LABEL: test_load_i1:
; X86-64:       # %bb.0: # %entry
; X86-64-NEXT:    testb $1, %dil
; X86-64-NEXT:    je .LBB3_2
; X86-64-NEXT:  # %bb.1: # %if
; X86-64-NEXT:    kmovb (%rdx), %k1
; X86-64-NEXT:    jmp .LBB3_3
; X86-64-NEXT:  .LBB3_2: # %else
; X86-64-NEXT:    kmovb (%rcx), %k1
; X86-64-NEXT:  .LBB3_3: # %exit
; X86-64-NEXT:    vmovss %xmm0, %xmm0, %xmm1 {%k1}
; X86-64-NEXT:    vmovss %xmm1, (%rsi)
; X86-64-NEXT:    retq
;
; X86-32-LABEL: test_load_i1:
; X86-32:       # %bb.0: # %entry
; X86-32-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; X86-32-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; X86-32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-32-NEXT:    testb $1, {{[0-9]+}}(%esp)
; X86-32-NEXT:    je .LBB3_2
; X86-32-NEXT:  # %bb.1: # %if
; X86-32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-32-NEXT:    jmp .LBB3_3
; X86-32-NEXT:  .LBB3_2: # %else
; X86-32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-32-NEXT:  .LBB3_3: # %exit
; X86-32-NEXT:    kmovb (%ecx), %k1
; X86-32-NEXT:    vmovss %xmm1, %xmm0, %xmm0 {%k1}
; X86-32-NEXT:    vmovss %xmm0, (%eax)
; X86-32-NEXT:    retl
entry:
  br i1 %cond, label %if, label %else

if:
  %loaded1 = load i1, i1* %iptr1
  br label %exit

else:
  %loaded2 = load i1, i1* %iptr2
  br label %exit

exit:
  %val = phi i1 [%loaded1, %if], [%loaded2, %else]
  %selected = select i1 %val, float %f1, float %f2
  store float %selected, float* %fptr
  ret void
}

define void @test_loadi1_storei1(i1 %cond, i1* %iptr1, i1* %iptr2, i1* %iptr3)  {
; X86-64-LABEL: test_loadi1_storei1:
; X86-64:       # %bb.0: # %entry
; X86-64-NEXT:    testb $1, %dil
; X86-64-NEXT:    je .LBB4_2
; X86-64-NEXT:  # %bb.1: # %if
; X86-64-NEXT:    movb (%rsi), %al
; X86-64-NEXT:    jmp .LBB4_3
; X86-64-NEXT:  .LBB4_2: # %else
; X86-64-NEXT:    movb (%rdx), %al
; X86-64-NEXT:  .LBB4_3: # %exit
; X86-64-NEXT:    andb $1, %al
; X86-64-NEXT:    movb %al, (%rcx)
; X86-64-NEXT:    retq
;
; X86-32-LABEL: test_loadi1_storei1:
; X86-32:       # %bb.0: # %entry
; X86-32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-32-NEXT:    testb $1, {{[0-9]+}}(%esp)
; X86-32-NEXT:    je .LBB4_2
; X86-32-NEXT:  # %bb.1: # %if
; X86-32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-32-NEXT:    jmp .LBB4_3
; X86-32-NEXT:  .LBB4_2: # %else
; X86-32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-32-NEXT:  .LBB4_3: # %exit
; X86-32-NEXT:    movb (%ecx), %cl
; X86-32-NEXT:    andb $1, %cl
; X86-32-NEXT:    movb %cl, (%eax)
; X86-32-NEXT:    retl
entry:
  br i1 %cond, label %if, label %else

if:
  %loaded1 = load i1, i1* %iptr1
  br label %exit

else:
  %loaded2 = load i1, i1* %iptr2
  br label %exit

exit:
  %val = phi i1 [%loaded1, %if], [%loaded2, %else]
  store i1 %val, i1* %iptr3
  ret void
}

define void @test_shl1(i1 %cond, i8* %ptr1, i8* %ptr2, <8 x float> %fvec1, <8 x float> %fvec2, <8 x float>* %fptrvec) {
; X86-64-LABEL: test_shl1:
; X86-64:       # %bb.0: # %entry
; X86-64-NEXT:    # kill: %ymm1<def> %ymm1<kill> %zmm1<def>
; X86-64-NEXT:    # kill: %ymm0<def> %ymm0<kill> %zmm0<def>
; X86-64-NEXT:    testb $1, %dil
; X86-64-NEXT:    je .LBB5_2
; X86-64-NEXT:  # %bb.1: # %if
; X86-64-NEXT:    kmovb (%rsi), %k0
; X86-64-NEXT:    kaddb %k0, %k0, %k1
; X86-64-NEXT:    jmp .LBB5_3
; X86-64-NEXT:  .LBB5_2: # %else
; X86-64-NEXT:    kmovb (%rdx), %k1
; X86-64-NEXT:  .LBB5_3: # %exit
; X86-64-NEXT:    vmovaps %zmm0, %zmm1 {%k1}
; X86-64-NEXT:    vmovaps %ymm1, (%rcx)
; X86-64-NEXT:    vzeroupper
; X86-64-NEXT:    retq
;
; X86-32-LABEL: test_shl1:
; X86-32:       # %bb.0: # %entry
; X86-32-NEXT:    # kill: %ymm1<def> %ymm1<kill> %zmm1<def>
; X86-32-NEXT:    # kill: %ymm0<def> %ymm0<kill> %zmm0<def>
; X86-32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-32-NEXT:    testb $1, {{[0-9]+}}(%esp)
; X86-32-NEXT:    je .LBB5_2
; X86-32-NEXT:  # %bb.1: # %if
; X86-32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-32-NEXT:    kmovb (%ecx), %k0
; X86-32-NEXT:    kaddb %k0, %k0, %k1
; X86-32-NEXT:    jmp .LBB5_3
; X86-32-NEXT:  .LBB5_2: # %else
; X86-32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-32-NEXT:    kmovb (%ecx), %k1
; X86-32-NEXT:  .LBB5_3: # %exit
; X86-32-NEXT:    vmovaps %zmm0, %zmm1 {%k1}
; X86-32-NEXT:    vmovaps %ymm1, (%eax)
; X86-32-NEXT:    vzeroupper
; X86-32-NEXT:    retl
entry:
  br i1 %cond, label %if, label %else

if:
  %loaded1 = load i8, i8* %ptr1
  %shifted = shl i8 %loaded1, 1
  br label %exit

else:
  %loaded2 = load i8, i8* %ptr2
  br label %exit

exit:
  %val = phi i8 [%shifted, %if], [%loaded2, %else]
  %mask = bitcast i8 %val to <8 x i1>
  %selected = select <8 x i1> %mask, <8 x float> %fvec1, <8 x float> %fvec2
  store <8 x float> %selected, <8 x float>* %fptrvec
  ret void
}

define void @test_shr1(i1 %cond, i8* %ptr1, i8* %ptr2, <8 x float> %fvec1, <8 x float> %fvec2, <8 x float>* %fptrvec) {
; X86-64-LABEL: test_shr1:
; X86-64:       # %bb.0: # %entry
; X86-64-NEXT:    # kill: %ymm1<def> %ymm1<kill> %zmm1<def>
; X86-64-NEXT:    # kill: %ymm0<def> %ymm0<kill> %zmm0<def>
; X86-64-NEXT:    testb $1, %dil
; X86-64-NEXT:    je .LBB6_2
; X86-64-NEXT:  # %bb.1: # %if
; X86-64-NEXT:    movb (%rsi), %al
; X86-64-NEXT:    shrb %al
; X86-64-NEXT:    jmp .LBB6_3
; X86-64-NEXT:  .LBB6_2: # %else
; X86-64-NEXT:    movb (%rdx), %al
; X86-64-NEXT:  .LBB6_3: # %exit
; X86-64-NEXT:    kmovd %eax, %k1
; X86-64-NEXT:    vmovaps %zmm0, %zmm1 {%k1}
; X86-64-NEXT:    vmovaps %ymm1, (%rcx)
; X86-64-NEXT:    vzeroupper
; X86-64-NEXT:    retq
;
; X86-32-LABEL: test_shr1:
; X86-32:       # %bb.0: # %entry
; X86-32-NEXT:    # kill: %ymm1<def> %ymm1<kill> %zmm1<def>
; X86-32-NEXT:    # kill: %ymm0<def> %ymm0<kill> %zmm0<def>
; X86-32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-32-NEXT:    testb $1, {{[0-9]+}}(%esp)
; X86-32-NEXT:    je .LBB6_2
; X86-32-NEXT:  # %bb.1: # %if
; X86-32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-32-NEXT:    movb (%ecx), %cl
; X86-32-NEXT:    shrb %cl
; X86-32-NEXT:    jmp .LBB6_3
; X86-32-NEXT:  .LBB6_2: # %else
; X86-32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-32-NEXT:    movb (%ecx), %cl
; X86-32-NEXT:  .LBB6_3: # %exit
; X86-32-NEXT:    kmovd %ecx, %k1
; X86-32-NEXT:    vmovaps %zmm0, %zmm1 {%k1}
; X86-32-NEXT:    vmovaps %ymm1, (%eax)
; X86-32-NEXT:    vzeroupper
; X86-32-NEXT:    retl
entry:
  br i1 %cond, label %if, label %else

if:
  %loaded1 = load i8, i8* %ptr1
  %shifted = lshr i8 %loaded1, 1
  br label %exit

else:
  %loaded2 = load i8, i8* %ptr2
  br label %exit

exit:
  %val = phi i8 [%shifted, %if], [%loaded2, %else]
  %mask = bitcast i8 %val to <8 x i1>
  %selected = select <8 x i1> %mask, <8 x float> %fvec1, <8 x float> %fvec2
  store <8 x float> %selected, <8 x float>* %fptrvec
  ret void
}

define void @test_shr2(i1 %cond, i8* %ptr1, i8* %ptr2, <8 x float> %fvec1, <8 x float> %fvec2, <8 x float>* %fptrvec) {
; X86-64-LABEL: test_shr2:
; X86-64:       # %bb.0: # %entry
; X86-64-NEXT:    # kill: %ymm1<def> %ymm1<kill> %zmm1<def>
; X86-64-NEXT:    # kill: %ymm0<def> %ymm0<kill> %zmm0<def>
; X86-64-NEXT:    testb $1, %dil
; X86-64-NEXT:    je .LBB7_2
; X86-64-NEXT:  # %bb.1: # %if
; X86-64-NEXT:    kmovb (%rsi), %k0
; X86-64-NEXT:    kshiftrb $2, %k0, %k1
; X86-64-NEXT:    jmp .LBB7_3
; X86-64-NEXT:  .LBB7_2: # %else
; X86-64-NEXT:    kmovb (%rdx), %k1
; X86-64-NEXT:  .LBB7_3: # %exit
; X86-64-NEXT:    vmovaps %zmm0, %zmm1 {%k1}
; X86-64-NEXT:    vmovaps %ymm1, (%rcx)
; X86-64-NEXT:    vzeroupper
; X86-64-NEXT:    retq
;
; X86-32-LABEL: test_shr2:
; X86-32:       # %bb.0: # %entry
; X86-32-NEXT:    # kill: %ymm1<def> %ymm1<kill> %zmm1<def>
; X86-32-NEXT:    # kill: %ymm0<def> %ymm0<kill> %zmm0<def>
; X86-32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-32-NEXT:    testb $1, {{[0-9]+}}(%esp)
; X86-32-NEXT:    je .LBB7_2
; X86-32-NEXT:  # %bb.1: # %if
; X86-32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-32-NEXT:    kmovb (%ecx), %k0
; X86-32-NEXT:    kshiftrb $2, %k0, %k1
; X86-32-NEXT:    jmp .LBB7_3
; X86-32-NEXT:  .LBB7_2: # %else
; X86-32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-32-NEXT:    kmovb (%ecx), %k1
; X86-32-NEXT:  .LBB7_3: # %exit
; X86-32-NEXT:    vmovaps %zmm0, %zmm1 {%k1}
; X86-32-NEXT:    vmovaps %ymm1, (%eax)
; X86-32-NEXT:    vzeroupper
; X86-32-NEXT:    retl
entry:
  br i1 %cond, label %if, label %else

if:
  %loaded1 = load i8, i8* %ptr1
  %shifted = lshr i8 %loaded1, 2
  br label %exit

else:
  %loaded2 = load i8, i8* %ptr2
  br label %exit

exit:
  %val = phi i8 [%shifted, %if], [%loaded2, %else]
  %mask = bitcast i8 %val to <8 x i1>
  %selected = select <8 x i1> %mask, <8 x float> %fvec1, <8 x float> %fvec2
  store <8 x float> %selected, <8 x float>* %fptrvec
  ret void
}

define void @test_shl(i1 %cond, i8* %ptr1, i8* %ptr2, <8 x float> %fvec1, <8 x float> %fvec2, <8 x float>* %fptrvec) {
; X86-64-LABEL: test_shl:
; X86-64:       # %bb.0: # %entry
; X86-64-NEXT:    # kill: %ymm1<def> %ymm1<kill> %zmm1<def>
; X86-64-NEXT:    # kill: %ymm0<def> %ymm0<kill> %zmm0<def>
; X86-64-NEXT:    testb $1, %dil
; X86-64-NEXT:    je .LBB8_2
; X86-64-NEXT:  # %bb.1: # %if
; X86-64-NEXT:    kmovb (%rsi), %k0
; X86-64-NEXT:    kshiftlb $6, %k0, %k1
; X86-64-NEXT:    jmp .LBB8_3
; X86-64-NEXT:  .LBB8_2: # %else
; X86-64-NEXT:    kmovb (%rdx), %k1
; X86-64-NEXT:  .LBB8_3: # %exit
; X86-64-NEXT:    vmovaps %zmm0, %zmm1 {%k1}
; X86-64-NEXT:    vmovaps %ymm1, (%rcx)
; X86-64-NEXT:    vzeroupper
; X86-64-NEXT:    retq
;
; X86-32-LABEL: test_shl:
; X86-32:       # %bb.0: # %entry
; X86-32-NEXT:    # kill: %ymm1<def> %ymm1<kill> %zmm1<def>
; X86-32-NEXT:    # kill: %ymm0<def> %ymm0<kill> %zmm0<def>
; X86-32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-32-NEXT:    testb $1, {{[0-9]+}}(%esp)
; X86-32-NEXT:    je .LBB8_2
; X86-32-NEXT:  # %bb.1: # %if
; X86-32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-32-NEXT:    kmovb (%ecx), %k0
; X86-32-NEXT:    kshiftlb $6, %k0, %k1
; X86-32-NEXT:    jmp .LBB8_3
; X86-32-NEXT:  .LBB8_2: # %else
; X86-32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-32-NEXT:    kmovb (%ecx), %k1
; X86-32-NEXT:  .LBB8_3: # %exit
; X86-32-NEXT:    vmovaps %zmm0, %zmm1 {%k1}
; X86-32-NEXT:    vmovaps %ymm1, (%eax)
; X86-32-NEXT:    vzeroupper
; X86-32-NEXT:    retl
entry:
  br i1 %cond, label %if, label %else

if:
  %loaded1 = load i8, i8* %ptr1
  %shifted = shl i8 %loaded1, 6
  br label %exit

else:
  %loaded2 = load i8, i8* %ptr2
  br label %exit

exit:
  %val = phi i8 [%shifted, %if], [%loaded2, %else]
  %mask = bitcast i8 %val to <8 x i1>
  %selected = select <8 x i1> %mask, <8 x float> %fvec1, <8 x float> %fvec2
  store <8 x float> %selected, <8 x float>* %fptrvec
  ret void
}

define void @test_add(i1 %cond, i8* %ptr1, i8* %ptr2, <8 x float> %fvec1, <8 x float> %fvec2, <8 x float>* %fptrvec) {
; X86-64-LABEL: test_add:
; X86-64:       # %bb.0: # %entry
; X86-64-NEXT:    # kill: %ymm1<def> %ymm1<kill> %zmm1<def>
; X86-64-NEXT:    # kill: %ymm0<def> %ymm0<kill> %zmm0<def>
; X86-64-NEXT:    kmovb (%rsi), %k0
; X86-64-NEXT:    kmovb (%rdx), %k1
; X86-64-NEXT:    testb $1, %dil
; X86-64-NEXT:    je .LBB9_2
; X86-64-NEXT:  # %bb.1: # %if
; X86-64-NEXT:    kandb %k1, %k0, %k1
; X86-64-NEXT:    jmp .LBB9_3
; X86-64-NEXT:  .LBB9_2: # %else
; X86-64-NEXT:    kaddb %k1, %k0, %k1
; X86-64-NEXT:  .LBB9_3: # %exit
; X86-64-NEXT:    vmovaps %zmm0, %zmm1 {%k1}
; X86-64-NEXT:    vmovaps %ymm1, (%rcx)
; X86-64-NEXT:    vzeroupper
; X86-64-NEXT:    retq
;
; X86-32-LABEL: test_add:
; X86-32:       # %bb.0: # %entry
; X86-32-NEXT:    # kill: %ymm1<def> %ymm1<kill> %zmm1<def>
; X86-32-NEXT:    # kill: %ymm0<def> %ymm0<kill> %zmm0<def>
; X86-32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-32-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-32-NEXT:    kmovb (%edx), %k0
; X86-32-NEXT:    kmovb (%ecx), %k1
; X86-32-NEXT:    testb $1, {{[0-9]+}}(%esp)
; X86-32-NEXT:    je .LBB9_2
; X86-32-NEXT:  # %bb.1: # %if
; X86-32-NEXT:    kandb %k1, %k0, %k1
; X86-32-NEXT:    jmp .LBB9_3
; X86-32-NEXT:  .LBB9_2: # %else
; X86-32-NEXT:    kaddb %k1, %k0, %k1
; X86-32-NEXT:  .LBB9_3: # %exit
; X86-32-NEXT:    vmovaps %zmm0, %zmm1 {%k1}
; X86-32-NEXT:    vmovaps %ymm1, (%eax)
; X86-32-NEXT:    vzeroupper
; X86-32-NEXT:    retl
entry:
  %loaded1 = load i8, i8* %ptr1
  %loaded2 = load i8, i8* %ptr2
  br i1 %cond, label %if, label %else

if:
  %and = and i8 %loaded1, %loaded2
  br label %exit

else:
  %add = add i8 %loaded1, %loaded2
  br label %exit

exit:
  %val = phi i8 [%and, %if], [%add, %else]
  %mask = bitcast i8 %val to <8 x i1>
  %selected = select <8 x i1> %mask, <8 x float> %fvec1, <8 x float> %fvec2
  store <8 x float> %selected, <8 x float>* %fptrvec
  ret void
}
