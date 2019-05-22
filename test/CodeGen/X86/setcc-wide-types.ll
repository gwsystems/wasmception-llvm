; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=sse2     | FileCheck %s --check-prefix=ANY --check-prefix=NO512 --check-prefix=SSE2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=avx      | FileCheck %s --check-prefix=ANY --check-prefix=NO512 --check-prefix=AVXANY --check-prefix=AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=avx2     | FileCheck %s --check-prefix=ANY --check-prefix=NO512 --check-prefix=AVXANY --check-prefix=AVX256 --check-prefix=AVX2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=avx512f  | FileCheck %s --check-prefix=ANY --check-prefix=AVXANY --check-prefix=AVX256 --check-prefix=AVX512 --check-prefix=AVX512F
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=avx512bw | FileCheck %s --check-prefix=ANY --check-prefix=AVXANY --check-prefix=AVX256 --check-prefix=AVX512 --check-prefix=AVX512BW

; Equality checks of 128/256-bit values can use PMOVMSK or PTEST to avoid scalarization.

define i32 @ne_i128(<2 x i64> %x, <2 x i64> %y) {
; SSE2-LABEL: ne_i128:
; SSE2:       # %bb.0:
; SSE2-NEXT:    pcmpeqb %xmm1, %xmm0
; SSE2-NEXT:    pmovmskb %xmm0, %ecx
; SSE2-NEXT:    xorl %eax, %eax
; SSE2-NEXT:    cmpl $65535, %ecx # imm = 0xFFFF
; SSE2-NEXT:    setne %al
; SSE2-NEXT:    retq
;
; AVXANY-LABEL: ne_i128:
; AVXANY:       # %bb.0:
; AVXANY-NEXT:    vpcmpeqb %xmm1, %xmm0, %xmm0
; AVXANY-NEXT:    vpmovmskb %xmm0, %ecx
; AVXANY-NEXT:    xorl %eax, %eax
; AVXANY-NEXT:    cmpl $65535, %ecx # imm = 0xFFFF
; AVXANY-NEXT:    setne %al
; AVXANY-NEXT:    retq
  %bcx = bitcast <2 x i64> %x to i128
  %bcy = bitcast <2 x i64> %y to i128
  %cmp = icmp ne i128 %bcx, %bcy
  %zext = zext i1 %cmp to i32
  ret i32 %zext
}

define i32 @eq_i128(<2 x i64> %x, <2 x i64> %y) {
; SSE2-LABEL: eq_i128:
; SSE2:       # %bb.0:
; SSE2-NEXT:    pcmpeqb %xmm1, %xmm0
; SSE2-NEXT:    pmovmskb %xmm0, %ecx
; SSE2-NEXT:    xorl %eax, %eax
; SSE2-NEXT:    cmpl $65535, %ecx # imm = 0xFFFF
; SSE2-NEXT:    sete %al
; SSE2-NEXT:    retq
;
; AVXANY-LABEL: eq_i128:
; AVXANY:       # %bb.0:
; AVXANY-NEXT:    vpcmpeqb %xmm1, %xmm0, %xmm0
; AVXANY-NEXT:    vpmovmskb %xmm0, %ecx
; AVXANY-NEXT:    xorl %eax, %eax
; AVXANY-NEXT:    cmpl $65535, %ecx # imm = 0xFFFF
; AVXANY-NEXT:    sete %al
; AVXANY-NEXT:    retq
  %bcx = bitcast <2 x i64> %x to i128
  %bcy = bitcast <2 x i64> %y to i128
  %cmp = icmp eq i128 %bcx, %bcy
  %zext = zext i1 %cmp to i32
  ret i32 %zext
}

define i32 @ne_i256(<4 x i64> %x, <4 x i64> %y) {
; SSE2-LABEL: ne_i256:
; SSE2:       # %bb.0:
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm0[2,3,0,1]
; SSE2-NEXT:    movq %xmm4, %rax
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm1[2,3,0,1]
; SSE2-NEXT:    movq %xmm4, %rcx
; SSE2-NEXT:    movq %xmm0, %rdx
; SSE2-NEXT:    movq %xmm1, %r8
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm2[2,3,0,1]
; SSE2-NEXT:    movq %xmm0, %rdi
; SSE2-NEXT:    xorq %rax, %rdi
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm3[2,3,0,1]
; SSE2-NEXT:    movq %xmm0, %rsi
; SSE2-NEXT:    xorq %rcx, %rsi
; SSE2-NEXT:    orq %rdi, %rsi
; SSE2-NEXT:    movq %xmm2, %rax
; SSE2-NEXT:    xorq %rdx, %rax
; SSE2-NEXT:    movq %xmm3, %rcx
; SSE2-NEXT:    xorq %r8, %rcx
; SSE2-NEXT:    orq %rax, %rcx
; SSE2-NEXT:    xorl %eax, %eax
; SSE2-NEXT:    orq %rsi, %rcx
; SSE2-NEXT:    setne %al
; SSE2-NEXT:    retq
;
; AVX1-LABEL: ne_i256:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmovq %xmm0, %rax
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX1-NEXT:    vmovq %xmm2, %rcx
; AVX1-NEXT:    vpextrq $1, %xmm0, %rdx
; AVX1-NEXT:    vpextrq $1, %xmm2, %r8
; AVX1-NEXT:    vmovq %xmm1, %rdi
; AVX1-NEXT:    xorq %rax, %rdi
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm0
; AVX1-NEXT:    vmovq %xmm0, %rsi
; AVX1-NEXT:    xorq %rcx, %rsi
; AVX1-NEXT:    orq %rdi, %rsi
; AVX1-NEXT:    vpextrq $1, %xmm1, %rax
; AVX1-NEXT:    xorq %rdx, %rax
; AVX1-NEXT:    vpextrq $1, %xmm0, %rcx
; AVX1-NEXT:    xorq %r8, %rcx
; AVX1-NEXT:    orq %rax, %rcx
; AVX1-NEXT:    xorl %eax, %eax
; AVX1-NEXT:    orq %rsi, %rcx
; AVX1-NEXT:    setne %al
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX256-LABEL: ne_i256:
; AVX256:       # %bb.0:
; AVX256-NEXT:    vpcmpeqb %ymm1, %ymm0, %ymm0
; AVX256-NEXT:    vpmovmskb %ymm0, %ecx
; AVX256-NEXT:    xorl %eax, %eax
; AVX256-NEXT:    cmpl $-1, %ecx
; AVX256-NEXT:    setne %al
; AVX256-NEXT:    vzeroupper
; AVX256-NEXT:    retq
  %bcx = bitcast <4 x i64> %x to i256
  %bcy = bitcast <4 x i64> %y to i256
  %cmp = icmp ne i256 %bcx, %bcy
  %zext = zext i1 %cmp to i32
  ret i32 %zext
}

define i32 @eq_i256(<4 x i64> %x, <4 x i64> %y) {
; SSE2-LABEL: eq_i256:
; SSE2:       # %bb.0:
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm0[2,3,0,1]
; SSE2-NEXT:    movq %xmm4, %rax
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm1[2,3,0,1]
; SSE2-NEXT:    movq %xmm4, %rcx
; SSE2-NEXT:    movq %xmm0, %rdx
; SSE2-NEXT:    movq %xmm1, %r8
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm2[2,3,0,1]
; SSE2-NEXT:    movq %xmm0, %rdi
; SSE2-NEXT:    xorq %rax, %rdi
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm3[2,3,0,1]
; SSE2-NEXT:    movq %xmm0, %rsi
; SSE2-NEXT:    xorq %rcx, %rsi
; SSE2-NEXT:    orq %rdi, %rsi
; SSE2-NEXT:    movq %xmm2, %rax
; SSE2-NEXT:    xorq %rdx, %rax
; SSE2-NEXT:    movq %xmm3, %rcx
; SSE2-NEXT:    xorq %r8, %rcx
; SSE2-NEXT:    orq %rax, %rcx
; SSE2-NEXT:    xorl %eax, %eax
; SSE2-NEXT:    orq %rsi, %rcx
; SSE2-NEXT:    sete %al
; SSE2-NEXT:    retq
;
; AVX1-LABEL: eq_i256:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmovq %xmm0, %rax
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX1-NEXT:    vmovq %xmm2, %rcx
; AVX1-NEXT:    vpextrq $1, %xmm0, %rdx
; AVX1-NEXT:    vpextrq $1, %xmm2, %r8
; AVX1-NEXT:    vmovq %xmm1, %rdi
; AVX1-NEXT:    xorq %rax, %rdi
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm0
; AVX1-NEXT:    vmovq %xmm0, %rsi
; AVX1-NEXT:    xorq %rcx, %rsi
; AVX1-NEXT:    orq %rdi, %rsi
; AVX1-NEXT:    vpextrq $1, %xmm1, %rax
; AVX1-NEXT:    xorq %rdx, %rax
; AVX1-NEXT:    vpextrq $1, %xmm0, %rcx
; AVX1-NEXT:    xorq %r8, %rcx
; AVX1-NEXT:    orq %rax, %rcx
; AVX1-NEXT:    xorl %eax, %eax
; AVX1-NEXT:    orq %rsi, %rcx
; AVX1-NEXT:    sete %al
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX256-LABEL: eq_i256:
; AVX256:       # %bb.0:
; AVX256-NEXT:    vpcmpeqb %ymm1, %ymm0, %ymm0
; AVX256-NEXT:    vpmovmskb %ymm0, %ecx
; AVX256-NEXT:    xorl %eax, %eax
; AVX256-NEXT:    cmpl $-1, %ecx
; AVX256-NEXT:    sete %al
; AVX256-NEXT:    vzeroupper
; AVX256-NEXT:    retq
  %bcx = bitcast <4 x i64> %x to i256
  %bcy = bitcast <4 x i64> %y to i256
  %cmp = icmp eq i256 %bcx, %bcy
  %zext = zext i1 %cmp to i32
  ret i32 %zext
}

define i32 @ne_i512(<8 x i64> %x, <8 x i64> %y) {
; SSE2-LABEL: ne_i512:
; SSE2:       # %bb.0:
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm0[2,3,0,1]
; SSE2-NEXT:    movq %xmm8, %rax
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm2[2,3,0,1]
; SSE2-NEXT:    movq %xmm8, %rcx
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm1[2,3,0,1]
; SSE2-NEXT:    movq %xmm8, %rdx
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm3[2,3,0,1]
; SSE2-NEXT:    movq %xmm8, %rsi
; SSE2-NEXT:    movq %xmm0, %r11
; SSE2-NEXT:    movq %xmm2, %r8
; SSE2-NEXT:    movq %xmm1, %r9
; SSE2-NEXT:    movq %xmm3, %r10
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm4[2,3,0,1]
; SSE2-NEXT:    movq %xmm0, %rdi
; SSE2-NEXT:    xorq %rax, %rdi
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm6[2,3,0,1]
; SSE2-NEXT:    movq %xmm0, %rax
; SSE2-NEXT:    xorq %rcx, %rax
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm5[2,3,0,1]
; SSE2-NEXT:    movq %xmm0, %rcx
; SSE2-NEXT:    xorq %rdx, %rcx
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm7[2,3,0,1]
; SSE2-NEXT:    movq %xmm0, %rdx
; SSE2-NEXT:    xorq %rsi, %rdx
; SSE2-NEXT:    orq %rcx, %rdx
; SSE2-NEXT:    orq %rax, %rdx
; SSE2-NEXT:    orq %rdi, %rdx
; SSE2-NEXT:    movq %xmm4, %rax
; SSE2-NEXT:    xorq %r11, %rax
; SSE2-NEXT:    movq %xmm6, %rcx
; SSE2-NEXT:    xorq %r8, %rcx
; SSE2-NEXT:    movq %xmm5, %rsi
; SSE2-NEXT:    xorq %r9, %rsi
; SSE2-NEXT:    movq %xmm7, %rdi
; SSE2-NEXT:    xorq %r10, %rdi
; SSE2-NEXT:    orq %rsi, %rdi
; SSE2-NEXT:    orq %rcx, %rdi
; SSE2-NEXT:    orq %rax, %rdi
; SSE2-NEXT:    xorl %eax, %eax
; SSE2-NEXT:    orq %rdx, %rdi
; SSE2-NEXT:    setne %al
; SSE2-NEXT:    retq
;
; AVX1-LABEL: ne_i512:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmovq %xmm0, %rax
; AVX1-NEXT:    vmovq %xmm1, %rcx
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm4
; AVX1-NEXT:    vmovq %xmm4, %rdx
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm5
; AVX1-NEXT:    vmovq %xmm5, %rsi
; AVX1-NEXT:    vpextrq $1, %xmm0, %r11
; AVX1-NEXT:    vpextrq $1, %xmm1, %r8
; AVX1-NEXT:    vpextrq $1, %xmm4, %r9
; AVX1-NEXT:    vpextrq $1, %xmm5, %r10
; AVX1-NEXT:    vmovq %xmm2, %rdi
; AVX1-NEXT:    xorq %rax, %rdi
; AVX1-NEXT:    vmovq %xmm3, %rax
; AVX1-NEXT:    xorq %rcx, %rax
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm0
; AVX1-NEXT:    vmovq %xmm0, %rcx
; AVX1-NEXT:    xorq %rdx, %rcx
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm1
; AVX1-NEXT:    vmovq %xmm1, %rdx
; AVX1-NEXT:    xorq %rsi, %rdx
; AVX1-NEXT:    orq %rcx, %rdx
; AVX1-NEXT:    orq %rax, %rdx
; AVX1-NEXT:    orq %rdi, %rdx
; AVX1-NEXT:    vpextrq $1, %xmm2, %rax
; AVX1-NEXT:    xorq %r11, %rax
; AVX1-NEXT:    vpextrq $1, %xmm3, %rcx
; AVX1-NEXT:    xorq %r8, %rcx
; AVX1-NEXT:    vpextrq $1, %xmm0, %rsi
; AVX1-NEXT:    xorq %r9, %rsi
; AVX1-NEXT:    vpextrq $1, %xmm1, %rdi
; AVX1-NEXT:    xorq %r10, %rdi
; AVX1-NEXT:    orq %rsi, %rdi
; AVX1-NEXT:    orq %rcx, %rdi
; AVX1-NEXT:    orq %rax, %rdi
; AVX1-NEXT:    xorl %eax, %eax
; AVX1-NEXT:    orq %rdx, %rdi
; AVX1-NEXT:    setne %al
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: ne_i512:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vmovq %xmm0, %rax
; AVX2-NEXT:    vmovq %xmm1, %rcx
; AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm4
; AVX2-NEXT:    vmovq %xmm4, %rdx
; AVX2-NEXT:    vextracti128 $1, %ymm1, %xmm5
; AVX2-NEXT:    vmovq %xmm5, %rsi
; AVX2-NEXT:    vpextrq $1, %xmm0, %r11
; AVX2-NEXT:    vpextrq $1, %xmm1, %r8
; AVX2-NEXT:    vpextrq $1, %xmm4, %r9
; AVX2-NEXT:    vpextrq $1, %xmm5, %r10
; AVX2-NEXT:    vmovq %xmm2, %rdi
; AVX2-NEXT:    xorq %rax, %rdi
; AVX2-NEXT:    vmovq %xmm3, %rax
; AVX2-NEXT:    xorq %rcx, %rax
; AVX2-NEXT:    vextracti128 $1, %ymm2, %xmm0
; AVX2-NEXT:    vmovq %xmm0, %rcx
; AVX2-NEXT:    xorq %rdx, %rcx
; AVX2-NEXT:    vextracti128 $1, %ymm3, %xmm1
; AVX2-NEXT:    vmovq %xmm1, %rdx
; AVX2-NEXT:    xorq %rsi, %rdx
; AVX2-NEXT:    orq %rcx, %rdx
; AVX2-NEXT:    orq %rax, %rdx
; AVX2-NEXT:    orq %rdi, %rdx
; AVX2-NEXT:    vpextrq $1, %xmm2, %rax
; AVX2-NEXT:    xorq %r11, %rax
; AVX2-NEXT:    vpextrq $1, %xmm3, %rcx
; AVX2-NEXT:    xorq %r8, %rcx
; AVX2-NEXT:    vpextrq $1, %xmm0, %rsi
; AVX2-NEXT:    xorq %r9, %rsi
; AVX2-NEXT:    vpextrq $1, %xmm1, %rdi
; AVX2-NEXT:    xorq %r10, %rdi
; AVX2-NEXT:    orq %rsi, %rdi
; AVX2-NEXT:    orq %rcx, %rdi
; AVX2-NEXT:    orq %rax, %rdi
; AVX2-NEXT:    xorl %eax, %eax
; AVX2-NEXT:    orq %rdx, %rdi
; AVX2-NEXT:    setne %al
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: ne_i512:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpcmpeqd %zmm1, %zmm0, %k0
; AVX512-NEXT:    xorl %eax, %eax
; AVX512-NEXT:    kortestw %k0, %k0
; AVX512-NEXT:    setae %al
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %bcx = bitcast <8 x i64> %x to i512
  %bcy = bitcast <8 x i64> %y to i512
  %cmp = icmp ne i512 %bcx, %bcy
  %zext = zext i1 %cmp to i32
  ret i32 %zext
}

define i32 @eq_i512(<8 x i64> %x, <8 x i64> %y) {
; SSE2-LABEL: eq_i512:
; SSE2:       # %bb.0:
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm0[2,3,0,1]
; SSE2-NEXT:    movq %xmm8, %rax
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm2[2,3,0,1]
; SSE2-NEXT:    movq %xmm8, %rcx
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm1[2,3,0,1]
; SSE2-NEXT:    movq %xmm8, %rdx
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm3[2,3,0,1]
; SSE2-NEXT:    movq %xmm8, %rsi
; SSE2-NEXT:    movq %xmm0, %r11
; SSE2-NEXT:    movq %xmm2, %r8
; SSE2-NEXT:    movq %xmm1, %r9
; SSE2-NEXT:    movq %xmm3, %r10
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm4[2,3,0,1]
; SSE2-NEXT:    movq %xmm0, %rdi
; SSE2-NEXT:    xorq %rax, %rdi
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm6[2,3,0,1]
; SSE2-NEXT:    movq %xmm0, %rax
; SSE2-NEXT:    xorq %rcx, %rax
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm5[2,3,0,1]
; SSE2-NEXT:    movq %xmm0, %rcx
; SSE2-NEXT:    xorq %rdx, %rcx
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm7[2,3,0,1]
; SSE2-NEXT:    movq %xmm0, %rdx
; SSE2-NEXT:    xorq %rsi, %rdx
; SSE2-NEXT:    orq %rcx, %rdx
; SSE2-NEXT:    orq %rax, %rdx
; SSE2-NEXT:    orq %rdi, %rdx
; SSE2-NEXT:    movq %xmm4, %rax
; SSE2-NEXT:    xorq %r11, %rax
; SSE2-NEXT:    movq %xmm6, %rcx
; SSE2-NEXT:    xorq %r8, %rcx
; SSE2-NEXT:    movq %xmm5, %rsi
; SSE2-NEXT:    xorq %r9, %rsi
; SSE2-NEXT:    movq %xmm7, %rdi
; SSE2-NEXT:    xorq %r10, %rdi
; SSE2-NEXT:    orq %rsi, %rdi
; SSE2-NEXT:    orq %rcx, %rdi
; SSE2-NEXT:    orq %rax, %rdi
; SSE2-NEXT:    xorl %eax, %eax
; SSE2-NEXT:    orq %rdx, %rdi
; SSE2-NEXT:    sete %al
; SSE2-NEXT:    retq
;
; AVX1-LABEL: eq_i512:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmovq %xmm0, %rax
; AVX1-NEXT:    vmovq %xmm1, %rcx
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm4
; AVX1-NEXT:    vmovq %xmm4, %rdx
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm5
; AVX1-NEXT:    vmovq %xmm5, %rsi
; AVX1-NEXT:    vpextrq $1, %xmm0, %r11
; AVX1-NEXT:    vpextrq $1, %xmm1, %r8
; AVX1-NEXT:    vpextrq $1, %xmm4, %r9
; AVX1-NEXT:    vpextrq $1, %xmm5, %r10
; AVX1-NEXT:    vmovq %xmm2, %rdi
; AVX1-NEXT:    xorq %rax, %rdi
; AVX1-NEXT:    vmovq %xmm3, %rax
; AVX1-NEXT:    xorq %rcx, %rax
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm0
; AVX1-NEXT:    vmovq %xmm0, %rcx
; AVX1-NEXT:    xorq %rdx, %rcx
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm1
; AVX1-NEXT:    vmovq %xmm1, %rdx
; AVX1-NEXT:    xorq %rsi, %rdx
; AVX1-NEXT:    orq %rcx, %rdx
; AVX1-NEXT:    orq %rax, %rdx
; AVX1-NEXT:    orq %rdi, %rdx
; AVX1-NEXT:    vpextrq $1, %xmm2, %rax
; AVX1-NEXT:    xorq %r11, %rax
; AVX1-NEXT:    vpextrq $1, %xmm3, %rcx
; AVX1-NEXT:    xorq %r8, %rcx
; AVX1-NEXT:    vpextrq $1, %xmm0, %rsi
; AVX1-NEXT:    xorq %r9, %rsi
; AVX1-NEXT:    vpextrq $1, %xmm1, %rdi
; AVX1-NEXT:    xorq %r10, %rdi
; AVX1-NEXT:    orq %rsi, %rdi
; AVX1-NEXT:    orq %rcx, %rdi
; AVX1-NEXT:    orq %rax, %rdi
; AVX1-NEXT:    xorl %eax, %eax
; AVX1-NEXT:    orq %rdx, %rdi
; AVX1-NEXT:    sete %al
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: eq_i512:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vmovq %xmm0, %rax
; AVX2-NEXT:    vmovq %xmm1, %rcx
; AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm4
; AVX2-NEXT:    vmovq %xmm4, %rdx
; AVX2-NEXT:    vextracti128 $1, %ymm1, %xmm5
; AVX2-NEXT:    vmovq %xmm5, %rsi
; AVX2-NEXT:    vpextrq $1, %xmm0, %r11
; AVX2-NEXT:    vpextrq $1, %xmm1, %r8
; AVX2-NEXT:    vpextrq $1, %xmm4, %r9
; AVX2-NEXT:    vpextrq $1, %xmm5, %r10
; AVX2-NEXT:    vmovq %xmm2, %rdi
; AVX2-NEXT:    xorq %rax, %rdi
; AVX2-NEXT:    vmovq %xmm3, %rax
; AVX2-NEXT:    xorq %rcx, %rax
; AVX2-NEXT:    vextracti128 $1, %ymm2, %xmm0
; AVX2-NEXT:    vmovq %xmm0, %rcx
; AVX2-NEXT:    xorq %rdx, %rcx
; AVX2-NEXT:    vextracti128 $1, %ymm3, %xmm1
; AVX2-NEXT:    vmovq %xmm1, %rdx
; AVX2-NEXT:    xorq %rsi, %rdx
; AVX2-NEXT:    orq %rcx, %rdx
; AVX2-NEXT:    orq %rax, %rdx
; AVX2-NEXT:    orq %rdi, %rdx
; AVX2-NEXT:    vpextrq $1, %xmm2, %rax
; AVX2-NEXT:    xorq %r11, %rax
; AVX2-NEXT:    vpextrq $1, %xmm3, %rcx
; AVX2-NEXT:    xorq %r8, %rcx
; AVX2-NEXT:    vpextrq $1, %xmm0, %rsi
; AVX2-NEXT:    xorq %r9, %rsi
; AVX2-NEXT:    vpextrq $1, %xmm1, %rdi
; AVX2-NEXT:    xorq %r10, %rdi
; AVX2-NEXT:    orq %rsi, %rdi
; AVX2-NEXT:    orq %rcx, %rdi
; AVX2-NEXT:    orq %rax, %rdi
; AVX2-NEXT:    xorl %eax, %eax
; AVX2-NEXT:    orq %rdx, %rdi
; AVX2-NEXT:    sete %al
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: eq_i512:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpcmpeqd %zmm1, %zmm0, %k0
; AVX512-NEXT:    xorl %eax, %eax
; AVX512-NEXT:    kortestw %k0, %k0
; AVX512-NEXT:    setb %al
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %bcx = bitcast <8 x i64> %x to i512
  %bcy = bitcast <8 x i64> %y to i512
  %cmp = icmp eq i512 %bcx, %bcy
  %zext = zext i1 %cmp to i32
  ret i32 %zext
}

; This test models the expansion of 'memcmp(a, b, 32) != 0'
; if we allowed 2 pairs of 16-byte loads per block.

define i32 @ne_i128_pair(i128* %a, i128* %b) {
; SSE2-LABEL: ne_i128_pair:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movdqu (%rdi), %xmm0
; SSE2-NEXT:    movdqu 16(%rdi), %xmm1
; SSE2-NEXT:    movdqu (%rsi), %xmm2
; SSE2-NEXT:    pcmpeqb %xmm0, %xmm2
; SSE2-NEXT:    movdqu 16(%rsi), %xmm0
; SSE2-NEXT:    pcmpeqb %xmm1, %xmm0
; SSE2-NEXT:    pand %xmm2, %xmm0
; SSE2-NEXT:    pmovmskb %xmm0, %ecx
; SSE2-NEXT:    xorl %eax, %eax
; SSE2-NEXT:    cmpl $65535, %ecx # imm = 0xFFFF
; SSE2-NEXT:    setne %al
; SSE2-NEXT:    retq
;
; AVXANY-LABEL: ne_i128_pair:
; AVXANY:       # %bb.0:
; AVXANY-NEXT:    vmovdqu (%rdi), %xmm0
; AVXANY-NEXT:    vmovdqu 16(%rdi), %xmm1
; AVXANY-NEXT:    vpcmpeqb 16(%rsi), %xmm1, %xmm1
; AVXANY-NEXT:    vpcmpeqb (%rsi), %xmm0, %xmm0
; AVXANY-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVXANY-NEXT:    vpmovmskb %xmm0, %ecx
; AVXANY-NEXT:    xorl %eax, %eax
; AVXANY-NEXT:    cmpl $65535, %ecx # imm = 0xFFFF
; AVXANY-NEXT:    setne %al
; AVXANY-NEXT:    retq
  %a0 = load i128, i128* %a
  %b0 = load i128, i128* %b
  %xor1 = xor i128 %a0, %b0
  %ap1 = getelementptr i128, i128* %a, i128 1
  %bp1 = getelementptr i128, i128* %b, i128 1
  %a1 = load i128, i128* %ap1
  %b1 = load i128, i128* %bp1
  %xor2 = xor i128 %a1, %b1
  %or = or i128 %xor1, %xor2
  %cmp = icmp ne i128 %or, 0
  %z = zext i1 %cmp to i32
  ret i32 %z
}

; This test models the expansion of 'memcmp(a, b, 32) == 0'
; if we allowed 2 pairs of 16-byte loads per block.

define i32 @eq_i128_pair(i128* %a, i128* %b) {
; SSE2-LABEL: eq_i128_pair:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movdqu (%rdi), %xmm0
; SSE2-NEXT:    movdqu 16(%rdi), %xmm1
; SSE2-NEXT:    movdqu (%rsi), %xmm2
; SSE2-NEXT:    pcmpeqb %xmm0, %xmm2
; SSE2-NEXT:    movdqu 16(%rsi), %xmm0
; SSE2-NEXT:    pcmpeqb %xmm1, %xmm0
; SSE2-NEXT:    pand %xmm2, %xmm0
; SSE2-NEXT:    pmovmskb %xmm0, %ecx
; SSE2-NEXT:    xorl %eax, %eax
; SSE2-NEXT:    cmpl $65535, %ecx # imm = 0xFFFF
; SSE2-NEXT:    sete %al
; SSE2-NEXT:    retq
;
; AVXANY-LABEL: eq_i128_pair:
; AVXANY:       # %bb.0:
; AVXANY-NEXT:    vmovdqu (%rdi), %xmm0
; AVXANY-NEXT:    vmovdqu 16(%rdi), %xmm1
; AVXANY-NEXT:    vpcmpeqb 16(%rsi), %xmm1, %xmm1
; AVXANY-NEXT:    vpcmpeqb (%rsi), %xmm0, %xmm0
; AVXANY-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVXANY-NEXT:    vpmovmskb %xmm0, %ecx
; AVXANY-NEXT:    xorl %eax, %eax
; AVXANY-NEXT:    cmpl $65535, %ecx # imm = 0xFFFF
; AVXANY-NEXT:    sete %al
; AVXANY-NEXT:    retq
  %a0 = load i128, i128* %a
  %b0 = load i128, i128* %b
  %xor1 = xor i128 %a0, %b0
  %ap1 = getelementptr i128, i128* %a, i128 1
  %bp1 = getelementptr i128, i128* %b, i128 1
  %a1 = load i128, i128* %ap1
  %b1 = load i128, i128* %bp1
  %xor2 = xor i128 %a1, %b1
  %or = or i128 %xor1, %xor2
  %cmp = icmp eq i128 %or, 0
  %z = zext i1 %cmp to i32
  ret i32 %z
}

; This test models the expansion of 'memcmp(a, b, 64) != 0'
; if we allowed 2 pairs of 32-byte loads per block.

define i32 @ne_i256_pair(i256* %a, i256* %b) {
; SSE2-LABEL: ne_i256_pair:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movq 16(%rdi), %r9
; SSE2-NEXT:    movq 24(%rdi), %r11
; SSE2-NEXT:    movq (%rdi), %r8
; SSE2-NEXT:    movq 8(%rdi), %r10
; SSE2-NEXT:    xorq 8(%rsi), %r10
; SSE2-NEXT:    xorq 24(%rsi), %r11
; SSE2-NEXT:    xorq (%rsi), %r8
; SSE2-NEXT:    xorq 16(%rsi), %r9
; SSE2-NEXT:    movq 48(%rdi), %rdx
; SSE2-NEXT:    movq 32(%rdi), %rax
; SSE2-NEXT:    movq 56(%rdi), %rcx
; SSE2-NEXT:    movq 40(%rdi), %rdi
; SSE2-NEXT:    xorq 40(%rsi), %rdi
; SSE2-NEXT:    xorq 56(%rsi), %rcx
; SSE2-NEXT:    orq %r11, %rcx
; SSE2-NEXT:    orq %rdi, %rcx
; SSE2-NEXT:    orq %r10, %rcx
; SSE2-NEXT:    xorq 32(%rsi), %rax
; SSE2-NEXT:    xorq 48(%rsi), %rdx
; SSE2-NEXT:    orq %r9, %rdx
; SSE2-NEXT:    orq %rax, %rdx
; SSE2-NEXT:    orq %r8, %rdx
; SSE2-NEXT:    xorl %eax, %eax
; SSE2-NEXT:    orq %rcx, %rdx
; SSE2-NEXT:    setne %al
; SSE2-NEXT:    retq
;
; AVX1-LABEL: ne_i256_pair:
; AVX1:       # %bb.0:
; AVX1-NEXT:    movq 16(%rdi), %r9
; AVX1-NEXT:    movq 24(%rdi), %r11
; AVX1-NEXT:    movq (%rdi), %r8
; AVX1-NEXT:    movq 8(%rdi), %r10
; AVX1-NEXT:    xorq 8(%rsi), %r10
; AVX1-NEXT:    xorq 24(%rsi), %r11
; AVX1-NEXT:    xorq (%rsi), %r8
; AVX1-NEXT:    xorq 16(%rsi), %r9
; AVX1-NEXT:    movq 48(%rdi), %rdx
; AVX1-NEXT:    movq 32(%rdi), %rax
; AVX1-NEXT:    movq 56(%rdi), %rcx
; AVX1-NEXT:    movq 40(%rdi), %rdi
; AVX1-NEXT:    xorq 40(%rsi), %rdi
; AVX1-NEXT:    xorq 56(%rsi), %rcx
; AVX1-NEXT:    orq %r11, %rcx
; AVX1-NEXT:    orq %rdi, %rcx
; AVX1-NEXT:    orq %r10, %rcx
; AVX1-NEXT:    xorq 32(%rsi), %rax
; AVX1-NEXT:    xorq 48(%rsi), %rdx
; AVX1-NEXT:    orq %r9, %rdx
; AVX1-NEXT:    orq %rax, %rdx
; AVX1-NEXT:    orq %r8, %rdx
; AVX1-NEXT:    xorl %eax, %eax
; AVX1-NEXT:    orq %rcx, %rdx
; AVX1-NEXT:    setne %al
; AVX1-NEXT:    retq
;
; AVX256-LABEL: ne_i256_pair:
; AVX256:       # %bb.0:
; AVX256-NEXT:    vmovdqu (%rdi), %ymm0
; AVX256-NEXT:    vmovdqu 32(%rdi), %ymm1
; AVX256-NEXT:    vpcmpeqb 32(%rsi), %ymm1, %ymm1
; AVX256-NEXT:    vpcmpeqb (%rsi), %ymm0, %ymm0
; AVX256-NEXT:    vpand %ymm1, %ymm0, %ymm0
; AVX256-NEXT:    vpmovmskb %ymm0, %ecx
; AVX256-NEXT:    xorl %eax, %eax
; AVX256-NEXT:    cmpl $-1, %ecx
; AVX256-NEXT:    setne %al
; AVX256-NEXT:    vzeroupper
; AVX256-NEXT:    retq
  %a0 = load i256, i256* %a
  %b0 = load i256, i256* %b
  %xor1 = xor i256 %a0, %b0
  %ap1 = getelementptr i256, i256* %a, i256 1
  %bp1 = getelementptr i256, i256* %b, i256 1
  %a1 = load i256, i256* %ap1
  %b1 = load i256, i256* %bp1
  %xor2 = xor i256 %a1, %b1
  %or = or i256 %xor1, %xor2
  %cmp = icmp ne i256 %or, 0
  %z = zext i1 %cmp to i32
  ret i32 %z
}

; This test models the expansion of 'memcmp(a, b, 64) == 0'
; if we allowed 2 pairs of 32-byte loads per block.

define i32 @eq_i256_pair(i256* %a, i256* %b) {
; SSE2-LABEL: eq_i256_pair:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movq 16(%rdi), %r9
; SSE2-NEXT:    movq 24(%rdi), %r11
; SSE2-NEXT:    movq (%rdi), %r8
; SSE2-NEXT:    movq 8(%rdi), %r10
; SSE2-NEXT:    xorq 8(%rsi), %r10
; SSE2-NEXT:    xorq 24(%rsi), %r11
; SSE2-NEXT:    xorq (%rsi), %r8
; SSE2-NEXT:    xorq 16(%rsi), %r9
; SSE2-NEXT:    movq 48(%rdi), %rdx
; SSE2-NEXT:    movq 32(%rdi), %rax
; SSE2-NEXT:    movq 56(%rdi), %rcx
; SSE2-NEXT:    movq 40(%rdi), %rdi
; SSE2-NEXT:    xorq 40(%rsi), %rdi
; SSE2-NEXT:    xorq 56(%rsi), %rcx
; SSE2-NEXT:    orq %r11, %rcx
; SSE2-NEXT:    orq %rdi, %rcx
; SSE2-NEXT:    orq %r10, %rcx
; SSE2-NEXT:    xorq 32(%rsi), %rax
; SSE2-NEXT:    xorq 48(%rsi), %rdx
; SSE2-NEXT:    orq %r9, %rdx
; SSE2-NEXT:    orq %rax, %rdx
; SSE2-NEXT:    orq %r8, %rdx
; SSE2-NEXT:    xorl %eax, %eax
; SSE2-NEXT:    orq %rcx, %rdx
; SSE2-NEXT:    sete %al
; SSE2-NEXT:    retq
;
; AVX1-LABEL: eq_i256_pair:
; AVX1:       # %bb.0:
; AVX1-NEXT:    movq 16(%rdi), %r9
; AVX1-NEXT:    movq 24(%rdi), %r11
; AVX1-NEXT:    movq (%rdi), %r8
; AVX1-NEXT:    movq 8(%rdi), %r10
; AVX1-NEXT:    xorq 8(%rsi), %r10
; AVX1-NEXT:    xorq 24(%rsi), %r11
; AVX1-NEXT:    xorq (%rsi), %r8
; AVX1-NEXT:    xorq 16(%rsi), %r9
; AVX1-NEXT:    movq 48(%rdi), %rdx
; AVX1-NEXT:    movq 32(%rdi), %rax
; AVX1-NEXT:    movq 56(%rdi), %rcx
; AVX1-NEXT:    movq 40(%rdi), %rdi
; AVX1-NEXT:    xorq 40(%rsi), %rdi
; AVX1-NEXT:    xorq 56(%rsi), %rcx
; AVX1-NEXT:    orq %r11, %rcx
; AVX1-NEXT:    orq %rdi, %rcx
; AVX1-NEXT:    orq %r10, %rcx
; AVX1-NEXT:    xorq 32(%rsi), %rax
; AVX1-NEXT:    xorq 48(%rsi), %rdx
; AVX1-NEXT:    orq %r9, %rdx
; AVX1-NEXT:    orq %rax, %rdx
; AVX1-NEXT:    orq %r8, %rdx
; AVX1-NEXT:    xorl %eax, %eax
; AVX1-NEXT:    orq %rcx, %rdx
; AVX1-NEXT:    sete %al
; AVX1-NEXT:    retq
;
; AVX256-LABEL: eq_i256_pair:
; AVX256:       # %bb.0:
; AVX256-NEXT:    vmovdqu (%rdi), %ymm0
; AVX256-NEXT:    vmovdqu 32(%rdi), %ymm1
; AVX256-NEXT:    vpcmpeqb 32(%rsi), %ymm1, %ymm1
; AVX256-NEXT:    vpcmpeqb (%rsi), %ymm0, %ymm0
; AVX256-NEXT:    vpand %ymm1, %ymm0, %ymm0
; AVX256-NEXT:    vpmovmskb %ymm0, %ecx
; AVX256-NEXT:    xorl %eax, %eax
; AVX256-NEXT:    cmpl $-1, %ecx
; AVX256-NEXT:    sete %al
; AVX256-NEXT:    vzeroupper
; AVX256-NEXT:    retq
  %a0 = load i256, i256* %a
  %b0 = load i256, i256* %b
  %xor1 = xor i256 %a0, %b0
  %ap1 = getelementptr i256, i256* %a, i256 1
  %bp1 = getelementptr i256, i256* %b, i256 1
  %a1 = load i256, i256* %ap1
  %b1 = load i256, i256* %bp1
  %xor2 = xor i256 %a1, %b1
  %or = or i256 %xor1, %xor2
  %cmp = icmp eq i256 %or, 0
  %z = zext i1 %cmp to i32
  ret i32 %z
}

; This test models the expansion of 'memcmp(a, b, 64) != 0'
; if we allowed 2 pairs of 64-byte loads per block.

define i32 @ne_i512_pair(i512* %a, i512* %b) {
; NO512-LABEL: ne_i512_pair:
; NO512:       # %bb.0:
; NO512-NEXT:    movq 32(%rdi), %r8
; NO512-NEXT:    movq 48(%rdi), %r9
; NO512-NEXT:    movq 40(%rdi), %rdx
; NO512-NEXT:    movq 56(%rdi), %rcx
; NO512-NEXT:    xorq 56(%rsi), %rcx
; NO512-NEXT:    movq 120(%rdi), %rax
; NO512-NEXT:    xorq 120(%rsi), %rax
; NO512-NEXT:    orq %rcx, %rax
; NO512-NEXT:    movq 88(%rdi), %rcx
; NO512-NEXT:    xorq 88(%rsi), %rcx
; NO512-NEXT:    orq %rcx, %rax
; NO512-NEXT:    movq 24(%rdi), %rcx
; NO512-NEXT:    xorq 24(%rsi), %rcx
; NO512-NEXT:    xorq 40(%rsi), %rdx
; NO512-NEXT:    orq %rcx, %rax
; NO512-NEXT:    movq 104(%rdi), %rcx
; NO512-NEXT:    xorq 104(%rsi), %rcx
; NO512-NEXT:    orq %rdx, %rcx
; NO512-NEXT:    movq 72(%rdi), %rdx
; NO512-NEXT:    xorq 72(%rsi), %rdx
; NO512-NEXT:    orq %rdx, %rcx
; NO512-NEXT:    movq 16(%rdi), %r10
; NO512-NEXT:    orq %rax, %rcx
; NO512-NEXT:    movq 8(%rdi), %rax
; NO512-NEXT:    xorq 8(%rsi), %rax
; NO512-NEXT:    xorq 48(%rsi), %r9
; NO512-NEXT:    orq %rax, %rcx
; NO512-NEXT:    movq 112(%rdi), %rax
; NO512-NEXT:    xorq 112(%rsi), %rax
; NO512-NEXT:    orq %r9, %rax
; NO512-NEXT:    movq 80(%rdi), %rdx
; NO512-NEXT:    xorq 80(%rsi), %rdx
; NO512-NEXT:    orq %rdx, %rax
; NO512-NEXT:    movq (%rdi), %r9
; NO512-NEXT:    xorq 16(%rsi), %r10
; NO512-NEXT:    xorq (%rsi), %r9
; NO512-NEXT:    xorq 32(%rsi), %r8
; NO512-NEXT:    orq %r10, %rax
; NO512-NEXT:    movq 96(%rdi), %rdx
; NO512-NEXT:    movq 64(%rdi), %rdi
; NO512-NEXT:    xorq 64(%rsi), %rdi
; NO512-NEXT:    xorq 96(%rsi), %rdx
; NO512-NEXT:    orq %r8, %rdx
; NO512-NEXT:    orq %rdi, %rdx
; NO512-NEXT:    orq %rax, %rdx
; NO512-NEXT:    orq %r9, %rdx
; NO512-NEXT:    xorl %eax, %eax
; NO512-NEXT:    orq %rcx, %rdx
; NO512-NEXT:    setne %al
; NO512-NEXT:    retq
;
; AVX512-LABEL: ne_i512_pair:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmovdqu64 (%rdi), %zmm0
; AVX512-NEXT:    vmovdqu64 64(%rdi), %zmm1
; AVX512-NEXT:    vpcmpeqd (%rsi), %zmm0, %k1
; AVX512-NEXT:    vpcmpeqd 64(%rsi), %zmm1, %k0 {%k1}
; AVX512-NEXT:    xorl %eax, %eax
; AVX512-NEXT:    kortestw %k0, %k0
; AVX512-NEXT:    setae %al
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %a0 = load i512, i512* %a
  %b0 = load i512, i512* %b
  %xor1 = xor i512 %a0, %b0
  %ap1 = getelementptr i512, i512* %a, i512 1
  %bp1 = getelementptr i512, i512* %b, i512 1
  %a1 = load i512, i512* %ap1
  %b1 = load i512, i512* %bp1
  %xor2 = xor i512 %a1, %b1
  %or = or i512 %xor1, %xor2
  %cmp = icmp ne i512 %or, 0
  %z = zext i1 %cmp to i32
  ret i32 %z
}

; This test models the expansion of 'memcmp(a, b, 64) == 0'
; if we allowed 2 pairs of 64-byte loads per block.

define i32 @eq_i512_pair(i512* %a, i512* %b) {
; NO512-LABEL: eq_i512_pair:
; NO512:       # %bb.0:
; NO512-NEXT:    movq 32(%rdi), %r8
; NO512-NEXT:    movq 48(%rdi), %r9
; NO512-NEXT:    movq 40(%rdi), %rdx
; NO512-NEXT:    movq 56(%rdi), %rcx
; NO512-NEXT:    xorq 56(%rsi), %rcx
; NO512-NEXT:    movq 120(%rdi), %rax
; NO512-NEXT:    xorq 120(%rsi), %rax
; NO512-NEXT:    orq %rcx, %rax
; NO512-NEXT:    movq 88(%rdi), %rcx
; NO512-NEXT:    xorq 88(%rsi), %rcx
; NO512-NEXT:    orq %rcx, %rax
; NO512-NEXT:    movq 24(%rdi), %rcx
; NO512-NEXT:    xorq 24(%rsi), %rcx
; NO512-NEXT:    xorq 40(%rsi), %rdx
; NO512-NEXT:    orq %rcx, %rax
; NO512-NEXT:    movq 104(%rdi), %rcx
; NO512-NEXT:    xorq 104(%rsi), %rcx
; NO512-NEXT:    orq %rdx, %rcx
; NO512-NEXT:    movq 72(%rdi), %rdx
; NO512-NEXT:    xorq 72(%rsi), %rdx
; NO512-NEXT:    orq %rdx, %rcx
; NO512-NEXT:    movq 16(%rdi), %r10
; NO512-NEXT:    orq %rax, %rcx
; NO512-NEXT:    movq 8(%rdi), %rax
; NO512-NEXT:    xorq 8(%rsi), %rax
; NO512-NEXT:    xorq 48(%rsi), %r9
; NO512-NEXT:    orq %rax, %rcx
; NO512-NEXT:    movq 112(%rdi), %rax
; NO512-NEXT:    xorq 112(%rsi), %rax
; NO512-NEXT:    orq %r9, %rax
; NO512-NEXT:    movq 80(%rdi), %rdx
; NO512-NEXT:    xorq 80(%rsi), %rdx
; NO512-NEXT:    orq %rdx, %rax
; NO512-NEXT:    movq (%rdi), %r9
; NO512-NEXT:    xorq 16(%rsi), %r10
; NO512-NEXT:    xorq (%rsi), %r9
; NO512-NEXT:    xorq 32(%rsi), %r8
; NO512-NEXT:    orq %r10, %rax
; NO512-NEXT:    movq 96(%rdi), %rdx
; NO512-NEXT:    movq 64(%rdi), %rdi
; NO512-NEXT:    xorq 64(%rsi), %rdi
; NO512-NEXT:    xorq 96(%rsi), %rdx
; NO512-NEXT:    orq %r8, %rdx
; NO512-NEXT:    orq %rdi, %rdx
; NO512-NEXT:    orq %rax, %rdx
; NO512-NEXT:    orq %r9, %rdx
; NO512-NEXT:    xorl %eax, %eax
; NO512-NEXT:    orq %rcx, %rdx
; NO512-NEXT:    sete %al
; NO512-NEXT:    retq
;
; AVX512-LABEL: eq_i512_pair:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmovdqu64 (%rdi), %zmm0
; AVX512-NEXT:    vmovdqu64 64(%rdi), %zmm1
; AVX512-NEXT:    vpcmpeqd (%rsi), %zmm0, %k1
; AVX512-NEXT:    vpcmpeqd 64(%rsi), %zmm1, %k0 {%k1}
; AVX512-NEXT:    xorl %eax, %eax
; AVX512-NEXT:    kortestw %k0, %k0
; AVX512-NEXT:    setb %al
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %a0 = load i512, i512* %a
  %b0 = load i512, i512* %b
  %xor1 = xor i512 %a0, %b0
  %ap1 = getelementptr i512, i512* %a, i512 1
  %bp1 = getelementptr i512, i512* %b, i512 1
  %a1 = load i512, i512* %ap1
  %b1 = load i512, i512* %bp1
  %xor2 = xor i512 %a1, %b1
  %or = or i512 %xor1, %xor2
  %cmp = icmp eq i512 %or, 0
  %z = zext i1 %cmp to i32
  ret i32 %z
}

; PR41971: Comparison using vector types is not favorable here.
define i1 @eq_i128_args(i128 %a, i128 %b) {
; ANY-LABEL: eq_i128_args:
; ANY:       # %bb.0:
; ANY-NEXT:    xorq %rcx, %rsi
; ANY-NEXT:    xorq %rdx, %rdi
; ANY-NEXT:    orq %rsi, %rdi
; ANY-NEXT:    sete %al
; ANY-NEXT:    retq
  %r = icmp eq i128 %a, %b
  ret i1 %r
}

define i1 @eq_i256_args(i256 %a, i256 %b) {
; ANY-LABEL: eq_i256_args:
; ANY:       # %bb.0:
; ANY-NEXT:    xorq %r9, %rsi
; ANY-NEXT:    xorq {{[0-9]+}}(%rsp), %rcx
; ANY-NEXT:    orq %rsi, %rcx
; ANY-NEXT:    xorq %r8, %rdi
; ANY-NEXT:    xorq {{[0-9]+}}(%rsp), %rdx
; ANY-NEXT:    orq %rdi, %rdx
; ANY-NEXT:    orq %rcx, %rdx
; ANY-NEXT:    sete %al
; ANY-NEXT:    retq
  %r = icmp eq i256 %a, %b
  ret i1 %r
}

define i1 @eq_i512_args(i512 %a, i512 %b) {
; ANY-LABEL: eq_i512_args:
; ANY:       # %bb.0:
; ANY-NEXT:    movq {{[0-9]+}}(%rsp), %r10
; ANY-NEXT:    movq {{[0-9]+}}(%rsp), %rax
; ANY-NEXT:    xorq {{[0-9]+}}(%rsp), %rax
; ANY-NEXT:    xorq {{[0-9]+}}(%rsp), %rcx
; ANY-NEXT:    orq %rax, %rcx
; ANY-NEXT:    xorq {{[0-9]+}}(%rsp), %r9
; ANY-NEXT:    orq %rcx, %r9
; ANY-NEXT:    xorq {{[0-9]+}}(%rsp), %rsi
; ANY-NEXT:    orq %r9, %rsi
; ANY-NEXT:    xorq {{[0-9]+}}(%rsp), %r10
; ANY-NEXT:    xorq {{[0-9]+}}(%rsp), %rdx
; ANY-NEXT:    orq %r10, %rdx
; ANY-NEXT:    xorq {{[0-9]+}}(%rsp), %r8
; ANY-NEXT:    orq %rdx, %r8
; ANY-NEXT:    xorq {{[0-9]+}}(%rsp), %rdi
; ANY-NEXT:    orq %r8, %rdi
; ANY-NEXT:    orq %rsi, %rdi
; ANY-NEXT:    sete %al
; ANY-NEXT:    retq
  %r = icmp eq i512 %a, %b
  ret i1 %r
}

define i1 @eq_i128_op(i128 %a, i128 %b) {
; ANY-LABEL: eq_i128_op:
; ANY:       # %bb.0:
; ANY-NEXT:    addq $1, %rdi
; ANY-NEXT:    adcq $0, %rsi
; ANY-NEXT:    xorq %rdx, %rdi
; ANY-NEXT:    xorq %rcx, %rsi
; ANY-NEXT:    orq %rdi, %rsi
; ANY-NEXT:    sete %al
; ANY-NEXT:    retq
  %a2 = add i128 %a, 1
  %r = icmp eq i128 %a2, %b
  ret i1 %r
}

define i1 @eq_i256_op(i256 %a, i256 %b) {
; ANY-LABEL: eq_i256_op:
; ANY:       # %bb.0:
; ANY-NEXT:    addq $1, %rdi
; ANY-NEXT:    adcq $0, %rsi
; ANY-NEXT:    adcq $0, %rdx
; ANY-NEXT:    adcq $0, %rcx
; ANY-NEXT:    xorq %r8, %rdi
; ANY-NEXT:    xorq {{[0-9]+}}(%rsp), %rdx
; ANY-NEXT:    orq %rdi, %rdx
; ANY-NEXT:    xorq %r9, %rsi
; ANY-NEXT:    xorq {{[0-9]+}}(%rsp), %rcx
; ANY-NEXT:    orq %rsi, %rcx
; ANY-NEXT:    orq %rdx, %rcx
; ANY-NEXT:    sete %al
; ANY-NEXT:    retq
  %a2 = add i256 %a, 1
  %r = icmp eq i256 %a2, %b
  ret i1 %r
}

define i1 @eq_i512_op(i512 %a, i512 %b) {
; ANY-LABEL: eq_i512_op:
; ANY:       # %bb.0:
; ANY-NEXT:    movq {{[0-9]+}}(%rsp), %r10
; ANY-NEXT:    movq {{[0-9]+}}(%rsp), %rax
; ANY-NEXT:    addq $1, %rdi
; ANY-NEXT:    adcq $0, %rsi
; ANY-NEXT:    adcq $0, %rdx
; ANY-NEXT:    adcq $0, %rcx
; ANY-NEXT:    adcq $0, %r8
; ANY-NEXT:    adcq $0, %r9
; ANY-NEXT:    adcq $0, %r10
; ANY-NEXT:    adcq $0, %rax
; ANY-NEXT:    xorq {{[0-9]+}}(%rsp), %rsi
; ANY-NEXT:    xorq {{[0-9]+}}(%rsp), %r9
; ANY-NEXT:    xorq {{[0-9]+}}(%rsp), %rcx
; ANY-NEXT:    xorq {{[0-9]+}}(%rsp), %rax
; ANY-NEXT:    orq %rcx, %rax
; ANY-NEXT:    orq %r9, %rax
; ANY-NEXT:    orq %rsi, %rax
; ANY-NEXT:    xorq {{[0-9]+}}(%rsp), %rdx
; ANY-NEXT:    xorq {{[0-9]+}}(%rsp), %r10
; ANY-NEXT:    orq %rdx, %r10
; ANY-NEXT:    xorq {{[0-9]+}}(%rsp), %r8
; ANY-NEXT:    orq %r10, %r8
; ANY-NEXT:    xorq {{[0-9]+}}(%rsp), %rdi
; ANY-NEXT:    orq %r8, %rdi
; ANY-NEXT:    orq %rax, %rdi
; ANY-NEXT:    sete %al
; ANY-NEXT:    retq
  %a2 = add i512 %a, 1
  %r = icmp eq i512 %a2, %b
  ret i1 %r
}

define i1 @eq_i128_load_arg(i128 *%p, i128 %b) {
; ANY-LABEL: eq_i128_load_arg:
; ANY:       # %bb.0:
; ANY-NEXT:    xorq 8(%rdi), %rdx
; ANY-NEXT:    xorq (%rdi), %rsi
; ANY-NEXT:    orq %rdx, %rsi
; ANY-NEXT:    sete %al
; ANY-NEXT:    retq
  %a = load i128, i128* %p
  %r = icmp eq i128 %a, %b
  ret i1 %r
}

define i1 @eq_i256_load_arg(i256 *%p, i256 %b) {
; ANY-LABEL: eq_i256_load_arg:
; ANY:       # %bb.0:
; ANY-NEXT:    xorq 24(%rdi), %r8
; ANY-NEXT:    xorq 8(%rdi), %rdx
; ANY-NEXT:    orq %r8, %rdx
; ANY-NEXT:    xorq 16(%rdi), %rcx
; ANY-NEXT:    xorq (%rdi), %rsi
; ANY-NEXT:    orq %rcx, %rsi
; ANY-NEXT:    orq %rdx, %rsi
; ANY-NEXT:    sete %al
; ANY-NEXT:    retq
  %a = load i256, i256* %p
  %r = icmp eq i256 %a, %b
  ret i1 %r
}

define i1 @eq_i512_load_arg(i512 *%p, i512 %b) {
; ANY-LABEL: eq_i512_load_arg:
; ANY:       # %bb.0:
; ANY-NEXT:    movq 40(%rdi), %r10
; ANY-NEXT:    movq 48(%rdi), %rax
; ANY-NEXT:    movq 56(%rdi), %r11
; ANY-NEXT:    xorq 24(%rdi), %r8
; ANY-NEXT:    xorq {{[0-9]+}}(%rsp), %r11
; ANY-NEXT:    orq %r8, %r11
; ANY-NEXT:    xorq 8(%rdi), %rdx
; ANY-NEXT:    xorq {{[0-9]+}}(%rsp), %r10
; ANY-NEXT:    orq %r11, %r10
; ANY-NEXT:    orq %rdx, %r10
; ANY-NEXT:    xorq 32(%rdi), %r9
; ANY-NEXT:    xorq (%rdi), %rsi
; ANY-NEXT:    xorq 16(%rdi), %rcx
; ANY-NEXT:    xorq {{[0-9]+}}(%rsp), %rax
; ANY-NEXT:    orq %rcx, %rax
; ANY-NEXT:    orq %r9, %rax
; ANY-NEXT:    orq %rsi, %rax
; ANY-NEXT:    orq %r10, %rax
; ANY-NEXT:    sete %al
; ANY-NEXT:    retq
  %a = load i512, i512* %p
  %r = icmp eq i512 %a, %b
  ret i1 %r
}
