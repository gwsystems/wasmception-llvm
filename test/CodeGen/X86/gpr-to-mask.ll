; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=x86_64-unknown-unknown -mattr=+avx512f,+avx512bw,+avx512dq < %s | FileCheck %s

define void @test_fcmp_storefloat(i1 %cond, float* %fptr, float %f1, float %f2, float %f3, float %f4, float %f5, float %f6) {
; CHECK-LABEL: test_fcmp_storefloat:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    testb $1, %dil
; CHECK-NEXT:    je .LBB0_2
; CHECK-NEXT:  # BB#1: # %if
; CHECK-NEXT:    vcmpeqss %xmm3, %xmm2, %k1
; CHECK-NEXT:    jmp .LBB0_3
; CHECK-NEXT:  .LBB0_2: # %else
; CHECK-NEXT:    vcmpeqss %xmm5, %xmm4, %k1
; CHECK-NEXT:  .LBB0_3: # %exit
; CHECK-NEXT:    vmovss %xmm0, %xmm0, %xmm1 {%k1}
; CHECK-NEXT:    vmovss %xmm1, (%rsi)
; CHECK-NEXT:    retq
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
; CHECK-LABEL: test_fcmp_storei1:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    testb $1, %dil
; CHECK-NEXT:    je .LBB1_2
; CHECK-NEXT:  # BB#1: # %if
; CHECK-NEXT:    vcmpeqss %xmm1, %xmm0, %k0
; CHECK-NEXT:    jmp .LBB1_3
; CHECK-NEXT:  .LBB1_2: # %else
; CHECK-NEXT:    vcmpeqss %xmm3, %xmm2, %k0
; CHECK-NEXT:  .LBB1_3: # %exit
; CHECK-NEXT:    kmovd %k0, %eax
; CHECK-NEXT:    andb $1, %al
; CHECK-NEXT:    movb %al, (%rdx)
; CHECK-NEXT:    retq
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
; CHECK-LABEL: test_load_add:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    testb $1, %dil
; CHECK-NEXT:    je .LBB2_2
; CHECK-NEXT:  # BB#1: # %if
; CHECK-NEXT:    kmovb (%rdx), %k0
; CHECK-NEXT:    kmovb (%rcx), %k1
; CHECK-NEXT:    kaddb %k1, %k0, %k1
; CHECK-NEXT:    jmp .LBB2_3
; CHECK-NEXT:  .LBB2_2: # %else
; CHECK-NEXT:    kmovb (%rcx), %k1
; CHECK-NEXT:  .LBB2_3: # %exit
; CHECK-NEXT:    vmovss %xmm0, %xmm0, %xmm1 {%k1}
; CHECK-NEXT:    vmovss %xmm1, (%rsi)
; CHECK-NEXT:    retq
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
; CHECK-LABEL: test_load_i1:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    testb $1, %dil
; CHECK-NEXT:    je .LBB3_2
; CHECK-NEXT:  # BB#1: # %if
; CHECK-NEXT:    kmovb (%rdx), %k1
; CHECK-NEXT:    jmp .LBB3_3
; CHECK-NEXT:  .LBB3_2: # %else
; CHECK-NEXT:    kmovb (%rcx), %k1
; CHECK-NEXT:  .LBB3_3: # %exit
; CHECK-NEXT:    vmovss %xmm0, %xmm0, %xmm1 {%k1}
; CHECK-NEXT:    vmovss %xmm1, (%rsi)
; CHECK-NEXT:    retq
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
; CHECK-LABEL: test_loadi1_storei1:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    testb $1, %dil
; CHECK-NEXT:    je .LBB4_2
; CHECK-NEXT:  # BB#1: # %if
; CHECK-NEXT:    movb (%rsi), %al
; CHECK-NEXT:    jmp .LBB4_3
; CHECK-NEXT:  .LBB4_2: # %else
; CHECK-NEXT:    movb (%rdx), %al
; CHECK-NEXT:  .LBB4_3: # %exit
; CHECK-NEXT:    andb $1, %al
; CHECK-NEXT:    movb %al, (%rcx)
; CHECK-NEXT:    retq
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
; CHECK-LABEL: test_shl1:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    # kill: %YMM1<def> %YMM1<kill> %ZMM1<def>
; CHECK-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<def>
; CHECK-NEXT:    testb $1, %dil
; CHECK-NEXT:    je .LBB5_2
; CHECK-NEXT:  # BB#1: # %if
; CHECK-NEXT:    kmovb (%rsi), %k0
; CHECK-NEXT:    kaddb %k0, %k0, %k1
; CHECK-NEXT:    jmp .LBB5_3
; CHECK-NEXT:  .LBB5_2: # %else
; CHECK-NEXT:    kmovb (%rdx), %k1
; CHECK-NEXT:  .LBB5_3: # %exit
; CHECK-NEXT:    vmovaps %zmm0, %zmm1 {%k1}
; CHECK-NEXT:    vmovaps %ymm1, (%rcx)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
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
; CHECK-LABEL: test_shr1:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    # kill: %YMM1<def> %YMM1<kill> %ZMM1<def>
; CHECK-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<def>
; CHECK-NEXT:    testb $1, %dil
; CHECK-NEXT:    je .LBB6_2
; CHECK-NEXT:  # BB#1: # %if
; CHECK-NEXT:    movb (%rsi), %al
; CHECK-NEXT:    shrb %al
; CHECK-NEXT:    jmp .LBB6_3
; CHECK-NEXT:  .LBB6_2: # %else
; CHECK-NEXT:    movb (%rdx), %al
; CHECK-NEXT:  .LBB6_3: # %exit
; CHECK-NEXT:    kmovd %eax, %k1
; CHECK-NEXT:    vmovaps %zmm0, %zmm1 {%k1}
; CHECK-NEXT:    vmovaps %ymm1, (%rcx)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
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
; CHECK-LABEL: test_shr2:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    # kill: %YMM1<def> %YMM1<kill> %ZMM1<def>
; CHECK-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<def>
; CHECK-NEXT:    testb $1, %dil
; CHECK-NEXT:    je .LBB7_2
; CHECK-NEXT:  # BB#1: # %if
; CHECK-NEXT:    kmovb (%rsi), %k0
; CHECK-NEXT:    kshiftrb $2, %k0, %k1
; CHECK-NEXT:    jmp .LBB7_3
; CHECK-NEXT:  .LBB7_2: # %else
; CHECK-NEXT:    kmovb (%rdx), %k1
; CHECK-NEXT:  .LBB7_3: # %exit
; CHECK-NEXT:    vmovaps %zmm0, %zmm1 {%k1}
; CHECK-NEXT:    vmovaps %ymm1, (%rcx)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
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
; CHECK-LABEL: test_shl:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    # kill: %YMM1<def> %YMM1<kill> %ZMM1<def>
; CHECK-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<def>
; CHECK-NEXT:    testb $1, %dil
; CHECK-NEXT:    je .LBB8_2
; CHECK-NEXT:  # BB#1: # %if
; CHECK-NEXT:    kmovb (%rsi), %k0
; CHECK-NEXT:    kshiftlb $6, %k0, %k1
; CHECK-NEXT:    jmp .LBB8_3
; CHECK-NEXT:  .LBB8_2: # %else
; CHECK-NEXT:    kmovb (%rdx), %k1
; CHECK-NEXT:  .LBB8_3: # %exit
; CHECK-NEXT:    vmovaps %zmm0, %zmm1 {%k1}
; CHECK-NEXT:    vmovaps %ymm1, (%rcx)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
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
; CHECK-LABEL: test_add:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    # kill: %YMM1<def> %YMM1<kill> %ZMM1<def>
; CHECK-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<def>
; CHECK-NEXT:    kmovb (%rsi), %k0
; CHECK-NEXT:    kmovb (%rdx), %k1
; CHECK-NEXT:    testb $1, %dil
; CHECK-NEXT:    je .LBB9_2
; CHECK-NEXT:  # BB#1: # %if
; CHECK-NEXT:    kandb %k1, %k0, %k1
; CHECK-NEXT:    jmp .LBB9_3
; CHECK-NEXT:  .LBB9_2: # %else
; CHECK-NEXT:    kaddb %k1, %k0, %k1
; CHECK-NEXT:  .LBB9_3: # %exit
; CHECK-NEXT:    vmovaps %zmm0, %zmm1 {%k1}
; CHECK-NEXT:    vmovaps %ymm1, (%rcx)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
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
