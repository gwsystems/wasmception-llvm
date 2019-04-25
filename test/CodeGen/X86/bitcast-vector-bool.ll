; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse2 | FileCheck %s --check-prefixes=SSE2-SSSE3,SSE2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+ssse3 | FileCheck %s --check-prefixes=SSE2-SSSE3,SSSE3
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx | FileCheck %s --check-prefixes=AVX12,AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx2 | FileCheck %s --check-prefixes=AVX12,AVX2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f,+avx512vl,+avx512bw | FileCheck %s --check-prefixes=AVX512

;
; 128-bit vectors
;

define i1 @bitcast_v2i64_to_v2i1(<2 x i64> %a0) nounwind {
; SSE2-SSSE3-LABEL: bitcast_v2i64_to_v2i1:
; SSE2-SSSE3:       # %bb.0:
; SSE2-SSSE3-NEXT:    movdqa {{.*#+}} xmm1 = [2147483648,2147483648]
; SSE2-SSSE3-NEXT:    pxor %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    movdqa %xmm1, %xmm2
; SSE2-SSSE3-NEXT:    pcmpgtd %xmm0, %xmm2
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm3 = xmm2[0,0,2,2]
; SSE2-SSSE3-NEXT:    pcmpeqd %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,1,3,3]
; SSE2-SSSE3-NEXT:    pand %xmm3, %xmm0
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm1 = xmm2[1,1,3,3]
; SSE2-SSSE3-NEXT:    por %xmm0, %xmm1
; SSE2-SSSE3-NEXT:    movdqa %xmm1, -{{[0-9]+}}(%rsp)
; SSE2-SSSE3-NEXT:    movb -{{[0-9]+}}(%rsp), %al
; SSE2-SSSE3-NEXT:    addb -{{[0-9]+}}(%rsp), %al
; SSE2-SSSE3-NEXT:    retq
;
; AVX12-LABEL: bitcast_v2i64_to_v2i1:
; AVX12:       # %bb.0:
; AVX12-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX12-NEXT:    vpcmpgtq %xmm0, %xmm1, %xmm0
; AVX12-NEXT:    vpextrb $0, %xmm0, %ecx
; AVX12-NEXT:    vpextrb $8, %xmm0, %eax
; AVX12-NEXT:    addb %cl, %al
; AVX12-NEXT:    # kill: def $al killed $al killed $eax
; AVX12-NEXT:    retq
;
; AVX512-LABEL: bitcast_v2i64_to_v2i1:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX512-NEXT:    vpcmpgtq %xmm0, %xmm1, %k0
; AVX512-NEXT:    kshiftrw $1, %k0, %k1
; AVX512-NEXT:    kmovd %k1, %ecx
; AVX512-NEXT:    kmovd %k0, %eax
; AVX512-NEXT:    addb %cl, %al
; AVX512-NEXT:    # kill: def $al killed $al killed $eax
; AVX512-NEXT:    retq
  %1 = icmp slt <2 x i64> %a0, zeroinitializer
  %2 = bitcast <2 x i1> %1 to <2 x i1>
  %3 = extractelement <2 x i1> %2, i32 0
  %4 = extractelement <2 x i1> %2, i32 1
  %5 = add i1 %3, %4
  ret i1 %5
}

define i2 @bitcast_v4i32_to_v2i2(<4 x i32> %a0) nounwind {
; SSE2-SSSE3-LABEL: bitcast_v4i32_to_v2i2:
; SSE2-SSSE3:       # %bb.0:
; SSE2-SSSE3-NEXT:    movmskps %xmm0, %eax
; SSE2-SSSE3-NEXT:    movl %eax, %ecx
; SSE2-SSSE3-NEXT:    andl $3, %ecx
; SSE2-SSSE3-NEXT:    movq %rcx, %xmm0
; SSE2-SSSE3-NEXT:    shrl $2, %eax
; SSE2-SSSE3-NEXT:    movq %rax, %xmm1
; SSE2-SSSE3-NEXT:    punpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; SSE2-SSSE3-NEXT:    movdqa %xmm0, -{{[0-9]+}}(%rsp)
; SSE2-SSSE3-NEXT:    movb -{{[0-9]+}}(%rsp), %al
; SSE2-SSSE3-NEXT:    addb -{{[0-9]+}}(%rsp), %al
; SSE2-SSSE3-NEXT:    retq
;
; AVX12-LABEL: bitcast_v4i32_to_v2i2:
; AVX12:       # %bb.0:
; AVX12-NEXT:    vmovmskps %xmm0, %eax
; AVX12-NEXT:    movl %eax, %ecx
; AVX12-NEXT:    shrl $2, %ecx
; AVX12-NEXT:    vmovd %ecx, %xmm0
; AVX12-NEXT:    andl $3, %eax
; AVX12-NEXT:    vmovd %eax, %xmm1
; AVX12-NEXT:    vpextrb $0, %xmm1, %ecx
; AVX12-NEXT:    vpextrb $0, %xmm0, %eax
; AVX12-NEXT:    addb %cl, %al
; AVX12-NEXT:    # kill: def $al killed $al killed $eax
; AVX12-NEXT:    retq
;
; AVX512-LABEL: bitcast_v4i32_to_v2i2:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX512-NEXT:    vpcmpgtd %xmm0, %xmm1, %k0
; AVX512-NEXT:    kmovd %k0, %eax
; AVX512-NEXT:    movzbl %al, %ecx
; AVX512-NEXT:    shrl $2, %ecx
; AVX512-NEXT:    andl $3, %ecx
; AVX512-NEXT:    vmovd %ecx, %xmm0
; AVX512-NEXT:    andl $3, %eax
; AVX512-NEXT:    vmovd %eax, %xmm1
; AVX512-NEXT:    vpextrb $0, %xmm1, %ecx
; AVX512-NEXT:    vpextrb $0, %xmm0, %eax
; AVX512-NEXT:    addb %cl, %al
; AVX512-NEXT:    # kill: def $al killed $al killed $eax
; AVX512-NEXT:    retq
  %1 = icmp slt <4 x i32> %a0, zeroinitializer
  %2 = bitcast <4 x i1> %1 to <2 x i2>
  %3 = extractelement <2 x i2> %2, i32 0
  %4 = extractelement <2 x i2> %2, i32 1
  %5 = add i2 %3, %4
  ret i2 %5
}

define i4 @bitcast_v8i16_to_v2i4(<8 x i16> %a0) nounwind {
; SSE2-SSSE3-LABEL: bitcast_v8i16_to_v2i4:
; SSE2-SSSE3:       # %bb.0:
; SSE2-SSSE3-NEXT:    packsswb %xmm0, %xmm0
; SSE2-SSSE3-NEXT:    pmovmskb %xmm0, %eax
; SSE2-SSSE3-NEXT:    movzbl %al, %ecx
; SSE2-SSSE3-NEXT:    shrl $4, %ecx
; SSE2-SSSE3-NEXT:    movq %rcx, %xmm0
; SSE2-SSSE3-NEXT:    andl $15, %eax
; SSE2-SSSE3-NEXT:    movq %rax, %xmm1
; SSE2-SSSE3-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm0[0]
; SSE2-SSSE3-NEXT:    movdqa %xmm1, -{{[0-9]+}}(%rsp)
; SSE2-SSSE3-NEXT:    movb -{{[0-9]+}}(%rsp), %al
; SSE2-SSSE3-NEXT:    addb -{{[0-9]+}}(%rsp), %al
; SSE2-SSSE3-NEXT:    retq
;
; AVX12-LABEL: bitcast_v8i16_to_v2i4:
; AVX12:       # %bb.0:
; AVX12-NEXT:    vpacksswb %xmm0, %xmm0, %xmm0
; AVX12-NEXT:    vpmovmskb %xmm0, %eax
; AVX12-NEXT:    movzbl %al, %ecx
; AVX12-NEXT:    shrl $4, %ecx
; AVX12-NEXT:    vmovd %ecx, %xmm0
; AVX12-NEXT:    andl $15, %eax
; AVX12-NEXT:    vmovd %eax, %xmm1
; AVX12-NEXT:    vpextrb $0, %xmm1, %ecx
; AVX12-NEXT:    vpextrb $0, %xmm0, %eax
; AVX12-NEXT:    addb %cl, %al
; AVX12-NEXT:    # kill: def $al killed $al killed $eax
; AVX12-NEXT:    retq
;
; AVX512-LABEL: bitcast_v8i16_to_v2i4:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpmovw2m %xmm0, %k0
; AVX512-NEXT:    kmovd %k0, %eax
; AVX512-NEXT:    movzbl %al, %ecx
; AVX512-NEXT:    shrl $4, %ecx
; AVX512-NEXT:    vmovd %ecx, %xmm0
; AVX512-NEXT:    andl $15, %eax
; AVX512-NEXT:    vmovd %eax, %xmm1
; AVX512-NEXT:    vpextrb $0, %xmm1, %ecx
; AVX512-NEXT:    vpextrb $0, %xmm0, %eax
; AVX512-NEXT:    addb %cl, %al
; AVX512-NEXT:    # kill: def $al killed $al killed $eax
; AVX512-NEXT:    retq
  %1 = icmp slt <8 x i16> %a0, zeroinitializer
  %2 = bitcast <8 x i1> %1 to <2 x i4>
  %3 = extractelement <2 x i4> %2, i32 0
  %4 = extractelement <2 x i4> %2, i32 1
  %5 = add i4 %3, %4
  ret i4 %5
}

define i8 @bitcast_v16i8_to_v2i8(<16 x i8> %a0) nounwind {
; SSE2-LABEL: bitcast_v16i8_to_v2i8:
; SSE2:       # %bb.0:
; SSE2-NEXT:    pmovmskb %xmm0, %eax
; SSE2-NEXT:    movd %eax, %xmm0
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,1,1,3]
; SSE2-NEXT:    movdqa %xmm0, -{{[0-9]+}}(%rsp)
; SSE2-NEXT:    movb -{{[0-9]+}}(%rsp), %al
; SSE2-NEXT:    addb -{{[0-9]+}}(%rsp), %al
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: bitcast_v16i8_to_v2i8:
; SSSE3:       # %bb.0:
; SSSE3-NEXT:    pmovmskb %xmm0, %eax
; SSSE3-NEXT:    movd %eax, %xmm0
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,zero,zero,zero,zero,xmm0[1],zero,zero,zero,zero,zero,zero,zero
; SSSE3-NEXT:    movdqa %xmm0, -{{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movb -{{[0-9]+}}(%rsp), %al
; SSSE3-NEXT:    addb -{{[0-9]+}}(%rsp), %al
; SSSE3-NEXT:    retq
;
; AVX12-LABEL: bitcast_v16i8_to_v2i8:
; AVX12:       # %bb.0:
; AVX12-NEXT:    vpmovmskb %xmm0, %eax
; AVX12-NEXT:    vmovd %eax, %xmm0
; AVX12-NEXT:    vpextrb $0, %xmm0, %ecx
; AVX12-NEXT:    vpextrb $1, %xmm0, %eax
; AVX12-NEXT:    addb %cl, %al
; AVX12-NEXT:    # kill: def $al killed $al killed $eax
; AVX12-NEXT:    retq
;
; AVX512-LABEL: bitcast_v16i8_to_v2i8:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpmovb2m %xmm0, %k0
; AVX512-NEXT:    kmovw %k0, -{{[0-9]+}}(%rsp)
; AVX512-NEXT:    vmovd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX512-NEXT:    vpextrb $0, %xmm0, %ecx
; AVX512-NEXT:    vpextrb $1, %xmm0, %eax
; AVX512-NEXT:    addb %cl, %al
; AVX512-NEXT:    # kill: def $al killed $al killed $eax
; AVX512-NEXT:    retq
  %1 = icmp slt <16 x i8> %a0, zeroinitializer
  %2 = bitcast <16 x i1> %1 to <2 x i8>
  %3 = extractelement <2 x i8> %2, i32 0
  %4 = extractelement <2 x i8> %2, i32 1
  %5 = add i8 %3, %4
  ret i8 %5
}

;
; 256-bit vectors
;

define i2 @bitcast_v4i64_to_v2i2(<4 x i64> %a0) nounwind {
; SSE2-SSSE3-LABEL: bitcast_v4i64_to_v2i2:
; SSE2-SSSE3:       # %bb.0:
; SSE2-SSSE3-NEXT:    packssdw %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    movmskps %xmm0, %eax
; SSE2-SSSE3-NEXT:    movl %eax, %ecx
; SSE2-SSSE3-NEXT:    shrl $2, %ecx
; SSE2-SSSE3-NEXT:    movq %rcx, %xmm0
; SSE2-SSSE3-NEXT:    andl $3, %eax
; SSE2-SSSE3-NEXT:    movq %rax, %xmm1
; SSE2-SSSE3-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm0[0]
; SSE2-SSSE3-NEXT:    movdqa %xmm1, -{{[0-9]+}}(%rsp)
; SSE2-SSSE3-NEXT:    movb -{{[0-9]+}}(%rsp), %al
; SSE2-SSSE3-NEXT:    addb -{{[0-9]+}}(%rsp), %al
; SSE2-SSSE3-NEXT:    retq
;
; AVX12-LABEL: bitcast_v4i64_to_v2i2:
; AVX12:       # %bb.0:
; AVX12-NEXT:    vmovmskpd %ymm0, %eax
; AVX12-NEXT:    movl %eax, %ecx
; AVX12-NEXT:    shrl $2, %ecx
; AVX12-NEXT:    vmovd %ecx, %xmm0
; AVX12-NEXT:    andl $3, %eax
; AVX12-NEXT:    vmovd %eax, %xmm1
; AVX12-NEXT:    vpextrb $0, %xmm1, %ecx
; AVX12-NEXT:    vpextrb $0, %xmm0, %eax
; AVX12-NEXT:    addb %cl, %al
; AVX12-NEXT:    # kill: def $al killed $al killed $eax
; AVX12-NEXT:    vzeroupper
; AVX12-NEXT:    retq
;
; AVX512-LABEL: bitcast_v4i64_to_v2i2:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX512-NEXT:    vpcmpgtq %ymm0, %ymm1, %k0
; AVX512-NEXT:    kmovd %k0, %eax
; AVX512-NEXT:    movzbl %al, %ecx
; AVX512-NEXT:    shrl $2, %ecx
; AVX512-NEXT:    andl $3, %ecx
; AVX512-NEXT:    vmovd %ecx, %xmm0
; AVX512-NEXT:    andl $3, %eax
; AVX512-NEXT:    vmovd %eax, %xmm1
; AVX512-NEXT:    vpextrb $0, %xmm1, %ecx
; AVX512-NEXT:    vpextrb $0, %xmm0, %eax
; AVX512-NEXT:    addb %cl, %al
; AVX512-NEXT:    # kill: def $al killed $al killed $eax
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = icmp slt <4 x i64> %a0, zeroinitializer
  %2 = bitcast <4 x i1> %1 to <2 x i2>
  %3 = extractelement <2 x i2> %2, i32 0
  %4 = extractelement <2 x i2> %2, i32 1
  %5 = add i2 %3, %4
  ret i2 %5
}

define i4 @bitcast_v8i32_to_v2i4(<8 x i32> %a0) nounwind {
; SSE2-SSSE3-LABEL: bitcast_v8i32_to_v2i4:
; SSE2-SSSE3:       # %bb.0:
; SSE2-SSSE3-NEXT:    packssdw %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    packsswb %xmm0, %xmm0
; SSE2-SSSE3-NEXT:    pmovmskb %xmm0, %eax
; SSE2-SSSE3-NEXT:    movzbl %al, %ecx
; SSE2-SSSE3-NEXT:    shrl $4, %ecx
; SSE2-SSSE3-NEXT:    movq %rcx, %xmm0
; SSE2-SSSE3-NEXT:    andl $15, %eax
; SSE2-SSSE3-NEXT:    movq %rax, %xmm1
; SSE2-SSSE3-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm0[0]
; SSE2-SSSE3-NEXT:    movdqa %xmm1, -{{[0-9]+}}(%rsp)
; SSE2-SSSE3-NEXT:    movb -{{[0-9]+}}(%rsp), %al
; SSE2-SSSE3-NEXT:    addb -{{[0-9]+}}(%rsp), %al
; SSE2-SSSE3-NEXT:    retq
;
; AVX12-LABEL: bitcast_v8i32_to_v2i4:
; AVX12:       # %bb.0:
; AVX12-NEXT:    vmovmskps %ymm0, %eax
; AVX12-NEXT:    movl %eax, %ecx
; AVX12-NEXT:    shrl $4, %ecx
; AVX12-NEXT:    vmovd %ecx, %xmm0
; AVX12-NEXT:    andl $15, %eax
; AVX12-NEXT:    vmovd %eax, %xmm1
; AVX12-NEXT:    vpextrb $0, %xmm1, %ecx
; AVX12-NEXT:    vpextrb $0, %xmm0, %eax
; AVX12-NEXT:    addb %cl, %al
; AVX12-NEXT:    # kill: def $al killed $al killed $eax
; AVX12-NEXT:    vzeroupper
; AVX12-NEXT:    retq
;
; AVX512-LABEL: bitcast_v8i32_to_v2i4:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX512-NEXT:    vpcmpgtd %ymm0, %ymm1, %k0
; AVX512-NEXT:    kmovd %k0, %eax
; AVX512-NEXT:    movzbl %al, %ecx
; AVX512-NEXT:    shrl $4, %ecx
; AVX512-NEXT:    vmovd %ecx, %xmm0
; AVX512-NEXT:    andl $15, %eax
; AVX512-NEXT:    vmovd %eax, %xmm1
; AVX512-NEXT:    vpextrb $0, %xmm1, %ecx
; AVX512-NEXT:    vpextrb $0, %xmm0, %eax
; AVX512-NEXT:    addb %cl, %al
; AVX512-NEXT:    # kill: def $al killed $al killed $eax
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = icmp slt <8 x i32> %a0, zeroinitializer
  %2 = bitcast <8 x i1> %1 to <2 x i4>
  %3 = extractelement <2 x i4> %2, i32 0
  %4 = extractelement <2 x i4> %2, i32 1
  %5 = add i4 %3, %4
  ret i4 %5
}

define i8 @bitcast_v16i16_to_v2i8(<16 x i16> %a0) nounwind {
; SSE2-LABEL: bitcast_v16i16_to_v2i8:
; SSE2:       # %bb.0:
; SSE2-NEXT:    packsswb %xmm1, %xmm0
; SSE2-NEXT:    pmovmskb %xmm0, %eax
; SSE2-NEXT:    movd %eax, %xmm0
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,1,1,3]
; SSE2-NEXT:    movdqa %xmm0, -{{[0-9]+}}(%rsp)
; SSE2-NEXT:    movb -{{[0-9]+}}(%rsp), %al
; SSE2-NEXT:    addb -{{[0-9]+}}(%rsp), %al
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: bitcast_v16i16_to_v2i8:
; SSSE3:       # %bb.0:
; SSSE3-NEXT:    packsswb %xmm1, %xmm0
; SSSE3-NEXT:    pmovmskb %xmm0, %eax
; SSSE3-NEXT:    movd %eax, %xmm0
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,zero,zero,zero,zero,xmm0[1],zero,zero,zero,zero,zero,zero,zero
; SSSE3-NEXT:    movdqa %xmm0, -{{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movb -{{[0-9]+}}(%rsp), %al
; SSSE3-NEXT:    addb -{{[0-9]+}}(%rsp), %al
; SSSE3-NEXT:    retq
;
; AVX1-LABEL: bitcast_v16i16_to_v2i8:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX1-NEXT:    vpacksswb %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpmovmskb %xmm0, %eax
; AVX1-NEXT:    vmovd %eax, %xmm0
; AVX1-NEXT:    vpextrb $0, %xmm0, %ecx
; AVX1-NEXT:    vpextrb $1, %xmm0, %eax
; AVX1-NEXT:    addb %cl, %al
; AVX1-NEXT:    # kill: def $al killed $al killed $eax
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: bitcast_v16i16_to_v2i8:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX2-NEXT:    vpcmpgtw %ymm0, %ymm1, %ymm0
; AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX2-NEXT:    vpacksswb %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpmovmskb %xmm0, %eax
; AVX2-NEXT:    vmovd %eax, %xmm0
; AVX2-NEXT:    vpextrb $0, %xmm0, %ecx
; AVX2-NEXT:    vpextrb $1, %xmm0, %eax
; AVX2-NEXT:    addb %cl, %al
; AVX2-NEXT:    # kill: def $al killed $al killed $eax
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: bitcast_v16i16_to_v2i8:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpmovw2m %ymm0, %k0
; AVX512-NEXT:    kmovw %k0, -{{[0-9]+}}(%rsp)
; AVX512-NEXT:    vmovd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX512-NEXT:    vpextrb $0, %xmm0, %ecx
; AVX512-NEXT:    vpextrb $1, %xmm0, %eax
; AVX512-NEXT:    addb %cl, %al
; AVX512-NEXT:    # kill: def $al killed $al killed $eax
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = icmp slt <16 x i16> %a0, zeroinitializer
  %2 = bitcast <16 x i1> %1 to <2 x i8>
  %3 = extractelement <2 x i8> %2, i32 0
  %4 = extractelement <2 x i8> %2, i32 1
  %5 = add i8 %3, %4
  ret i8 %5
}

define i16 @bitcast_v32i8_to_v2i16(<32 x i8> %a0) nounwind {
; SSE2-SSSE3-LABEL: bitcast_v32i8_to_v2i16:
; SSE2-SSSE3:       # %bb.0:
; SSE2-SSSE3-NEXT:    pmovmskb %xmm0, %eax
; SSE2-SSSE3-NEXT:    pmovmskb %xmm1, %ecx
; SSE2-SSSE3-NEXT:    shll $16, %ecx
; SSE2-SSSE3-NEXT:    orl %eax, %ecx
; SSE2-SSSE3-NEXT:    movd %ecx, %xmm0
; SSE2-SSSE3-NEXT:    pextrw $0, %xmm0, %ecx
; SSE2-SSSE3-NEXT:    pextrw $1, %xmm0, %eax
; SSE2-SSSE3-NEXT:    addl %ecx, %eax
; SSE2-SSSE3-NEXT:    # kill: def $ax killed $ax killed $eax
; SSE2-SSSE3-NEXT:    retq
;
; AVX1-LABEL: bitcast_v32i8_to_v2i16:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vpmovmskb %xmm0, %eax
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX1-NEXT:    vpmovmskb %xmm0, %ecx
; AVX1-NEXT:    shll $16, %ecx
; AVX1-NEXT:    orl %eax, %ecx
; AVX1-NEXT:    vmovd %ecx, %xmm0
; AVX1-NEXT:    vpextrw $0, %xmm0, %ecx
; AVX1-NEXT:    vpextrw $1, %xmm0, %eax
; AVX1-NEXT:    addl %ecx, %eax
; AVX1-NEXT:    # kill: def $ax killed $ax killed $eax
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: bitcast_v32i8_to_v2i16:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpmovmskb %ymm0, %eax
; AVX2-NEXT:    vmovd %eax, %xmm0
; AVX2-NEXT:    vpextrw $0, %xmm0, %ecx
; AVX2-NEXT:    vpextrw $1, %xmm0, %eax
; AVX2-NEXT:    addl %ecx, %eax
; AVX2-NEXT:    # kill: def $ax killed $ax killed $eax
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: bitcast_v32i8_to_v2i16:
; AVX512:       # %bb.0:
; AVX512-NEXT:    pushq %rbp
; AVX512-NEXT:    movq %rsp, %rbp
; AVX512-NEXT:    andq $-32, %rsp
; AVX512-NEXT:    subq $32, %rsp
; AVX512-NEXT:    vpmovb2m %ymm0, %k0
; AVX512-NEXT:    kmovd %k0, (%rsp)
; AVX512-NEXT:    vmovd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX512-NEXT:    vpextrw $0, %xmm0, %ecx
; AVX512-NEXT:    vpextrw $1, %xmm0, %eax
; AVX512-NEXT:    addl %ecx, %eax
; AVX512-NEXT:    # kill: def $ax killed $ax killed $eax
; AVX512-NEXT:    movq %rbp, %rsp
; AVX512-NEXT:    popq %rbp
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = icmp slt <32 x i8> %a0, zeroinitializer
  %2 = bitcast <32 x i1> %1 to <2 x i16>
  %3 = extractelement <2 x i16> %2, i32 0
  %4 = extractelement <2 x i16> %2, i32 1
  %5 = add i16 %3, %4
  ret i16 %5
}

;
; 512-bit vectors
;

define i4 @bitcast_v8i64_to_v2i4(<8 x i64> %a0) nounwind {
; SSE2-SSSE3-LABEL: bitcast_v8i64_to_v2i4:
; SSE2-SSSE3:       # %bb.0:
; SSE2-SSSE3-NEXT:    movdqa {{.*#+}} xmm4 = [2147483648,2147483648]
; SSE2-SSSE3-NEXT:    pxor %xmm4, %xmm3
; SSE2-SSSE3-NEXT:    movdqa %xmm4, %xmm5
; SSE2-SSSE3-NEXT:    pcmpgtd %xmm3, %xmm5
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm6 = xmm5[0,0,2,2]
; SSE2-SSSE3-NEXT:    pcmpeqd %xmm4, %xmm3
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm3 = xmm3[1,1,3,3]
; SSE2-SSSE3-NEXT:    pand %xmm6, %xmm3
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm5 = xmm5[1,1,3,3]
; SSE2-SSSE3-NEXT:    por %xmm3, %xmm5
; SSE2-SSSE3-NEXT:    pxor %xmm4, %xmm2
; SSE2-SSSE3-NEXT:    movdqa %xmm4, %xmm3
; SSE2-SSSE3-NEXT:    pcmpgtd %xmm2, %xmm3
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm6 = xmm3[0,0,2,2]
; SSE2-SSSE3-NEXT:    pcmpeqd %xmm4, %xmm2
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm7 = xmm2[1,1,3,3]
; SSE2-SSSE3-NEXT:    pand %xmm6, %xmm7
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm2 = xmm3[1,1,3,3]
; SSE2-SSSE3-NEXT:    por %xmm7, %xmm2
; SSE2-SSSE3-NEXT:    packssdw %xmm5, %xmm2
; SSE2-SSSE3-NEXT:    pxor %xmm4, %xmm1
; SSE2-SSSE3-NEXT:    movdqa %xmm4, %xmm3
; SSE2-SSSE3-NEXT:    pcmpgtd %xmm1, %xmm3
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm5 = xmm3[0,0,2,2]
; SSE2-SSSE3-NEXT:    pcmpeqd %xmm4, %xmm1
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[1,1,3,3]
; SSE2-SSSE3-NEXT:    pand %xmm5, %xmm1
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm3 = xmm3[1,1,3,3]
; SSE2-SSSE3-NEXT:    por %xmm1, %xmm3
; SSE2-SSSE3-NEXT:    pxor %xmm4, %xmm0
; SSE2-SSSE3-NEXT:    movdqa %xmm4, %xmm1
; SSE2-SSSE3-NEXT:    pcmpgtd %xmm0, %xmm1
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm5 = xmm1[0,0,2,2]
; SSE2-SSSE3-NEXT:    pcmpeqd %xmm4, %xmm0
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,1,3,3]
; SSE2-SSSE3-NEXT:    pand %xmm5, %xmm0
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[1,1,3,3]
; SSE2-SSSE3-NEXT:    por %xmm0, %xmm1
; SSE2-SSSE3-NEXT:    packssdw %xmm3, %xmm1
; SSE2-SSSE3-NEXT:    packssdw %xmm2, %xmm1
; SSE2-SSSE3-NEXT:    packsswb %xmm0, %xmm1
; SSE2-SSSE3-NEXT:    pmovmskb %xmm1, %eax
; SSE2-SSSE3-NEXT:    movzbl %al, %ecx
; SSE2-SSSE3-NEXT:    shrl $4, %ecx
; SSE2-SSSE3-NEXT:    movq %rcx, %xmm0
; SSE2-SSSE3-NEXT:    andl $15, %eax
; SSE2-SSSE3-NEXT:    movq %rax, %xmm1
; SSE2-SSSE3-NEXT:    punpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm0[0]
; SSE2-SSSE3-NEXT:    movdqa %xmm1, -{{[0-9]+}}(%rsp)
; SSE2-SSSE3-NEXT:    movb -{{[0-9]+}}(%rsp), %al
; SSE2-SSSE3-NEXT:    addb -{{[0-9]+}}(%rsp), %al
; SSE2-SSSE3-NEXT:    retq
;
; AVX1-LABEL: bitcast_v8i64_to_v2i4:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX1-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX1-NEXT:    vpcmpgtq %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpcmpgtq %xmm0, %xmm3, %xmm0
; AVX1-NEXT:    vpackssdw %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vpackssdw %xmm2, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    vmovmskps %ymm0, %eax
; AVX1-NEXT:    movl %eax, %ecx
; AVX1-NEXT:    shrl $4, %ecx
; AVX1-NEXT:    vmovd %ecx, %xmm0
; AVX1-NEXT:    andl $15, %eax
; AVX1-NEXT:    vmovd %eax, %xmm1
; AVX1-NEXT:    vpextrb $0, %xmm1, %ecx
; AVX1-NEXT:    vpextrb $0, %xmm0, %eax
; AVX1-NEXT:    addb %cl, %al
; AVX1-NEXT:    # kill: def $al killed $al killed $eax
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: bitcast_v8i64_to_v2i4:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; AVX2-NEXT:    vpcmpgtq %ymm1, %ymm2, %ymm1
; AVX2-NEXT:    vpcmpgtq %ymm0, %ymm2, %ymm0
; AVX2-NEXT:    vpackssdw %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpermq {{.*#+}} ymm0 = ymm0[0,2,1,3]
; AVX2-NEXT:    vmovmskps %ymm0, %eax
; AVX2-NEXT:    movl %eax, %ecx
; AVX2-NEXT:    shrl $4, %ecx
; AVX2-NEXT:    vmovd %ecx, %xmm0
; AVX2-NEXT:    andl $15, %eax
; AVX2-NEXT:    vmovd %eax, %xmm1
; AVX2-NEXT:    vpextrb $0, %xmm1, %ecx
; AVX2-NEXT:    vpextrb $0, %xmm0, %eax
; AVX2-NEXT:    addb %cl, %al
; AVX2-NEXT:    # kill: def $al killed $al killed $eax
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: bitcast_v8i64_to_v2i4:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX512-NEXT:    vpcmpgtq %zmm0, %zmm1, %k0
; AVX512-NEXT:    kmovd %k0, %eax
; AVX512-NEXT:    movzbl %al, %ecx
; AVX512-NEXT:    shrl $4, %ecx
; AVX512-NEXT:    vmovd %ecx, %xmm0
; AVX512-NEXT:    andl $15, %eax
; AVX512-NEXT:    vmovd %eax, %xmm1
; AVX512-NEXT:    vpextrb $0, %xmm1, %ecx
; AVX512-NEXT:    vpextrb $0, %xmm0, %eax
; AVX512-NEXT:    addb %cl, %al
; AVX512-NEXT:    # kill: def $al killed $al killed $eax
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = icmp slt <8 x i64> %a0, zeroinitializer
  %2 = bitcast <8 x i1> %1 to <2 x i4>
  %3 = extractelement <2 x i4> %2, i32 0
  %4 = extractelement <2 x i4> %2, i32 1
  %5 = add i4 %3, %4
  ret i4 %5
}

define i8 @bitcast_v16i32_to_v2i8(<16 x i32> %a0) nounwind {
; SSE2-LABEL: bitcast_v16i32_to_v2i8:
; SSE2:       # %bb.0:
; SSE2-NEXT:    packssdw %xmm3, %xmm2
; SSE2-NEXT:    packssdw %xmm1, %xmm0
; SSE2-NEXT:    packsswb %xmm2, %xmm0
; SSE2-NEXT:    pmovmskb %xmm0, %eax
; SSE2-NEXT:    movd %eax, %xmm0
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,1,1,3]
; SSE2-NEXT:    movdqa %xmm0, -{{[0-9]+}}(%rsp)
; SSE2-NEXT:    movb -{{[0-9]+}}(%rsp), %al
; SSE2-NEXT:    addb -{{[0-9]+}}(%rsp), %al
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: bitcast_v16i32_to_v2i8:
; SSSE3:       # %bb.0:
; SSSE3-NEXT:    packssdw %xmm3, %xmm2
; SSSE3-NEXT:    packssdw %xmm1, %xmm0
; SSSE3-NEXT:    packsswb %xmm2, %xmm0
; SSSE3-NEXT:    pmovmskb %xmm0, %eax
; SSSE3-NEXT:    movd %eax, %xmm0
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,zero,zero,zero,zero,xmm0[1],zero,zero,zero,zero,zero,zero,zero
; SSSE3-NEXT:    movdqa %xmm0, -{{[0-9]+}}(%rsp)
; SSSE3-NEXT:    movb -{{[0-9]+}}(%rsp), %al
; SSSE3-NEXT:    addb -{{[0-9]+}}(%rsp), %al
; SSSE3-NEXT:    retq
;
; AVX1-LABEL: bitcast_v16i32_to_v2i8:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vpackssdw %xmm2, %xmm1, %xmm1
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX1-NEXT:    vpackssdw %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vpacksswb %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpmovmskb %xmm0, %eax
; AVX1-NEXT:    vmovd %eax, %xmm0
; AVX1-NEXT:    vpextrb $0, %xmm0, %ecx
; AVX1-NEXT:    vpextrb $1, %xmm0, %eax
; AVX1-NEXT:    addb %cl, %al
; AVX1-NEXT:    # kill: def $al killed $al killed $eax
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: bitcast_v16i32_to_v2i8:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; AVX2-NEXT:    vpcmpgtd %ymm1, %ymm2, %ymm1
; AVX2-NEXT:    vpcmpgtd %ymm0, %ymm2, %ymm0
; AVX2-NEXT:    vpackssdw %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpermq {{.*#+}} ymm0 = ymm0[0,2,1,3]
; AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX2-NEXT:    vpacksswb %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpmovmskb %xmm0, %eax
; AVX2-NEXT:    vmovd %eax, %xmm0
; AVX2-NEXT:    vpextrb $0, %xmm0, %ecx
; AVX2-NEXT:    vpextrb $1, %xmm0, %eax
; AVX2-NEXT:    addb %cl, %al
; AVX2-NEXT:    # kill: def $al killed $al killed $eax
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: bitcast_v16i32_to_v2i8:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX512-NEXT:    vpcmpgtd %zmm0, %zmm1, %k0
; AVX512-NEXT:    kmovw %k0, -{{[0-9]+}}(%rsp)
; AVX512-NEXT:    vmovd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX512-NEXT:    vpextrb $0, %xmm0, %ecx
; AVX512-NEXT:    vpextrb $1, %xmm0, %eax
; AVX512-NEXT:    addb %cl, %al
; AVX512-NEXT:    # kill: def $al killed $al killed $eax
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = icmp slt <16 x i32> %a0, zeroinitializer
  %2 = bitcast <16 x i1> %1 to <2 x i8>
  %3 = extractelement <2 x i8> %2, i32 0
  %4 = extractelement <2 x i8> %2, i32 1
  %5 = add i8 %3, %4
  ret i8 %5
}

define i16 @bitcast_v32i16_to_v2i16(<32 x i16> %a0) nounwind {
; SSE2-SSSE3-LABEL: bitcast_v32i16_to_v2i16:
; SSE2-SSSE3:       # %bb.0:
; SSE2-SSSE3-NEXT:    packsswb %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    pmovmskb %xmm0, %eax
; SSE2-SSSE3-NEXT:    packsswb %xmm3, %xmm2
; SSE2-SSSE3-NEXT:    pmovmskb %xmm2, %ecx
; SSE2-SSSE3-NEXT:    shll $16, %ecx
; SSE2-SSSE3-NEXT:    orl %eax, %ecx
; SSE2-SSSE3-NEXT:    movd %ecx, %xmm0
; SSE2-SSSE3-NEXT:    pextrw $0, %xmm0, %ecx
; SSE2-SSSE3-NEXT:    pextrw $1, %xmm0, %eax
; SSE2-SSSE3-NEXT:    addl %ecx, %eax
; SSE2-SSSE3-NEXT:    # kill: def $ax killed $ax killed $eax
; SSE2-SSSE3-NEXT:    retq
;
; AVX1-LABEL: bitcast_v32i16_to_v2i16:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX1-NEXT:    vpacksswb %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vpmovmskb %xmm0, %eax
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm0
; AVX1-NEXT:    vpacksswb %xmm0, %xmm1, %xmm0
; AVX1-NEXT:    vpmovmskb %xmm0, %ecx
; AVX1-NEXT:    shll $16, %ecx
; AVX1-NEXT:    orl %eax, %ecx
; AVX1-NEXT:    vmovd %ecx, %xmm0
; AVX1-NEXT:    vpextrw $0, %xmm0, %ecx
; AVX1-NEXT:    vpextrw $1, %xmm0, %eax
; AVX1-NEXT:    addl %ecx, %eax
; AVX1-NEXT:    # kill: def $ax killed $ax killed $eax
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: bitcast_v32i16_to_v2i16:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpacksswb %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpermq {{.*#+}} ymm0 = ymm0[0,2,1,3]
; AVX2-NEXT:    vpmovmskb %ymm0, %eax
; AVX2-NEXT:    vmovd %eax, %xmm0
; AVX2-NEXT:    vpextrw $0, %xmm0, %ecx
; AVX2-NEXT:    vpextrw $1, %xmm0, %eax
; AVX2-NEXT:    addl %ecx, %eax
; AVX2-NEXT:    # kill: def $ax killed $ax killed $eax
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: bitcast_v32i16_to_v2i16:
; AVX512:       # %bb.0:
; AVX512-NEXT:    pushq %rbp
; AVX512-NEXT:    movq %rsp, %rbp
; AVX512-NEXT:    andq $-32, %rsp
; AVX512-NEXT:    subq $32, %rsp
; AVX512-NEXT:    vpmovw2m %zmm0, %k0
; AVX512-NEXT:    kmovd %k0, (%rsp)
; AVX512-NEXT:    vmovd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX512-NEXT:    vpextrw $0, %xmm0, %ecx
; AVX512-NEXT:    vpextrw $1, %xmm0, %eax
; AVX512-NEXT:    addl %ecx, %eax
; AVX512-NEXT:    # kill: def $ax killed $ax killed $eax
; AVX512-NEXT:    movq %rbp, %rsp
; AVX512-NEXT:    popq %rbp
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = icmp slt <32 x i16> %a0, zeroinitializer
  %2 = bitcast <32 x i1> %1 to <2 x i16>
  %3 = extractelement <2 x i16> %2, i32 0
  %4 = extractelement <2 x i16> %2, i32 1
  %5 = add i16 %3, %4
  ret i16 %5
}

define i32 @bitcast_v64i8_to_v2i32(<64 x i8> %a0) nounwind {
; SSE2-SSSE3-LABEL: bitcast_v64i8_to_v2i32:
; SSE2-SSSE3:       # %bb.0:
; SSE2-SSSE3-NEXT:    retq
;
; AVX12-LABEL: bitcast_v64i8_to_v2i32:
; AVX12:       # %bb.0:
; AVX12-NEXT:    retq
;
; AVX512-LABEL: bitcast_v64i8_to_v2i32:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpmovb2m %zmm0, %k0
; AVX512-NEXT:    kmovq %k0, -{{[0-9]+}}(%rsp)
; AVX512-NEXT:    vmovq {{.*#+}} xmm0 = mem[0],zero
; AVX512-NEXT:    vmovd %xmm0, %ecx
; AVX512-NEXT:    vpextrd $1, %xmm0, %eax
; AVX512-NEXT:    addl %ecx, %eax
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = icmp slt <64 x i8> %a0, zeroinitializer
  %2 = bitcast <64 x i1> %1 to <2 x i32>
  %3 = extractelement <2 x i32> %2, i32 0
  %4 = extractelement <2 x i32> %2, i32 1
  %5 = add i32 %3, %4
  ret i32 %5
}
