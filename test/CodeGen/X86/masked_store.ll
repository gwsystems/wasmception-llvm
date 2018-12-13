; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mattr=sse2    | FileCheck %s --check-prefixes=SSE,SSE2
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mattr=sse4.2  | FileCheck %s --check-prefixes=SSE,SSE4
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mattr=avx     | FileCheck %s --check-prefixes=AVX,AVX1OR2,AVX1
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mattr=avx2    | FileCheck %s --check-prefixes=AVX,AVX1OR2,AVX2
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mattr=avx512f | FileCheck %s --check-prefixes=AVX,AVX512,AVX512F
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mattr=avx512f,avx512bw,avx512vl | FileCheck %s --check-prefixes=AVX,AVX512,AVX512VLBW

define void @store_v1i32_v1i32(<1 x i32> %trigger, <1 x i32>* %addr, <1 x i32> %val) {
; SSE-LABEL: store_v1i32_v1i32:
; SSE:       ## %bb.0:
; SSE-NEXT:    testl %edi, %edi
; SSE-NEXT:    jne LBB0_2
; SSE-NEXT:  ## %bb.1: ## %cond.store
; SSE-NEXT:    movl %edx, (%rsi)
; SSE-NEXT:  LBB0_2: ## %else
; SSE-NEXT:    retq
;
; AVX-LABEL: store_v1i32_v1i32:
; AVX:       ## %bb.0:
; AVX-NEXT:    testl %edi, %edi
; AVX-NEXT:    jne LBB0_2
; AVX-NEXT:  ## %bb.1: ## %cond.store
; AVX-NEXT:    movl %edx, (%rsi)
; AVX-NEXT:  LBB0_2: ## %else
; AVX-NEXT:    retq
  %mask = icmp eq <1 x i32> %trigger, zeroinitializer
  call void @llvm.masked.store.v1i32.p0v1i32(<1 x i32>%val, <1 x i32>* %addr, i32 4, <1 x i1>%mask)
  ret void
}

define void @store_v4i32_v4i32(<4 x i32> %trigger, <4 x i32>* %addr, <4 x i32> %val) {
; SSE2-LABEL: store_v4i32_v4i32:
; SSE2:       ## %bb.0:
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    pcmpeqd %xmm0, %xmm2
; SSE2-NEXT:    movd %xmm2, %eax
; SSE2-NEXT:    testb $1, %al
; SSE2-NEXT:    je LBB1_2
; SSE2-NEXT:  ## %bb.1: ## %cond.store
; SSE2-NEXT:    movd %xmm1, (%rdi)
; SSE2-NEXT:  LBB1_2: ## %else
; SSE2-NEXT:    pextrw $2, %xmm2, %eax
; SSE2-NEXT:    testb $1, %al
; SSE2-NEXT:    je LBB1_4
; SSE2-NEXT:  ## %bb.3: ## %cond.store1
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm1[1,1,2,3]
; SSE2-NEXT:    movd %xmm2, 4(%rdi)
; SSE2-NEXT:  LBB1_4: ## %else2
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    pcmpeqd %xmm2, %xmm0
; SSE2-NEXT:    pextrw $4, %xmm0, %eax
; SSE2-NEXT:    testb $1, %al
; SSE2-NEXT:    je LBB1_6
; SSE2-NEXT:  ## %bb.5: ## %cond.store3
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm1[2,3,0,1]
; SSE2-NEXT:    movd %xmm2, 8(%rdi)
; SSE2-NEXT:  LBB1_6: ## %else4
; SSE2-NEXT:    pextrw $6, %xmm0, %eax
; SSE2-NEXT:    testb $1, %al
; SSE2-NEXT:    je LBB1_8
; SSE2-NEXT:  ## %bb.7: ## %cond.store5
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm1[3,1,2,3]
; SSE2-NEXT:    movd %xmm0, 12(%rdi)
; SSE2-NEXT:  LBB1_8: ## %else6
; SSE2-NEXT:    retq
;
; SSE4-LABEL: store_v4i32_v4i32:
; SSE4:       ## %bb.0:
; SSE4-NEXT:    pxor %xmm2, %xmm2
; SSE4-NEXT:    pcmpeqd %xmm0, %xmm2
; SSE4-NEXT:    pextrb $0, %xmm2, %eax
; SSE4-NEXT:    testb $1, %al
; SSE4-NEXT:    je LBB1_2
; SSE4-NEXT:  ## %bb.1: ## %cond.store
; SSE4-NEXT:    movss %xmm1, (%rdi)
; SSE4-NEXT:  LBB1_2: ## %else
; SSE4-NEXT:    pextrb $4, %xmm2, %eax
; SSE4-NEXT:    testb $1, %al
; SSE4-NEXT:    je LBB1_4
; SSE4-NEXT:  ## %bb.3: ## %cond.store1
; SSE4-NEXT:    extractps $1, %xmm1, 4(%rdi)
; SSE4-NEXT:  LBB1_4: ## %else2
; SSE4-NEXT:    pxor %xmm2, %xmm2
; SSE4-NEXT:    pcmpeqd %xmm2, %xmm0
; SSE4-NEXT:    pextrb $8, %xmm0, %eax
; SSE4-NEXT:    testb $1, %al
; SSE4-NEXT:    je LBB1_6
; SSE4-NEXT:  ## %bb.5: ## %cond.store3
; SSE4-NEXT:    extractps $2, %xmm1, 8(%rdi)
; SSE4-NEXT:  LBB1_6: ## %else4
; SSE4-NEXT:    pextrb $12, %xmm0, %eax
; SSE4-NEXT:    testb $1, %al
; SSE4-NEXT:    je LBB1_8
; SSE4-NEXT:  ## %bb.7: ## %cond.store5
; SSE4-NEXT:    extractps $3, %xmm1, 12(%rdi)
; SSE4-NEXT:  LBB1_8: ## %else6
; SSE4-NEXT:    retq
;
; AVX1-LABEL: store_v4i32_v4i32:
; AVX1:       ## %bb.0:
; AVX1-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; AVX1-NEXT:    vpcmpeqd %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vmaskmovps %xmm1, %xmm0, (%rdi)
; AVX1-NEXT:    retq
;
; AVX2-LABEL: store_v4i32_v4i32:
; AVX2:       ## %bb.0:
; AVX2-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; AVX2-NEXT:    vpcmpeqd %xmm2, %xmm0, %xmm0
; AVX2-NEXT:    vpmaskmovd %xmm1, %xmm0, (%rdi)
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: store_v4i32_v4i32:
; AVX512F:       ## %bb.0:
; AVX512F-NEXT:    ## kill: def $xmm1 killed $xmm1 def $zmm1
; AVX512F-NEXT:    ## kill: def $xmm0 killed $xmm0 def $zmm0
; AVX512F-NEXT:    vptestnmd %zmm0, %zmm0, %k0
; AVX512F-NEXT:    kshiftlw $12, %k0, %k0
; AVX512F-NEXT:    kshiftrw $12, %k0, %k1
; AVX512F-NEXT:    vmovdqu32 %zmm1, (%rdi) {%k1}
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512VLBW-LABEL: store_v4i32_v4i32:
; AVX512VLBW:       ## %bb.0:
; AVX512VLBW-NEXT:    vptestnmd %xmm0, %xmm0, %k1
; AVX512VLBW-NEXT:    vmovdqu32 %xmm1, (%rdi) {%k1}
; AVX512VLBW-NEXT:    retq
  %mask = icmp eq <4 x i32> %trigger, zeroinitializer
  call void @llvm.masked.store.v4i32.p0v4i32(<4 x i32>%val, <4 x i32>* %addr, i32 4, <4 x i1>%mask)
  ret void
}

define void @store_v8i32_v8i32(<8 x i32> %trigger, <8 x i32>* %addr, <8 x i32> %val) {
; SSE2-LABEL: store_v8i32_v8i32:
; SSE2:       ## %bb.0:
; SSE2-NEXT:    pxor %xmm4, %xmm4
; SSE2-NEXT:    pcmpeqd %xmm0, %xmm4
; SSE2-NEXT:    movdqa %xmm4, %xmm5
; SSE2-NEXT:    packssdw %xmm0, %xmm5
; SSE2-NEXT:    movd %xmm5, %eax
; SSE2-NEXT:    testb $1, %al
; SSE2-NEXT:    je LBB2_2
; SSE2-NEXT:  ## %bb.1: ## %cond.store
; SSE2-NEXT:    movd %xmm2, (%rdi)
; SSE2-NEXT:  LBB2_2: ## %else
; SSE2-NEXT:    packssdw %xmm0, %xmm4
; SSE2-NEXT:    movd %xmm4, %eax
; SSE2-NEXT:    shrl $16, %eax
; SSE2-NEXT:    testb $1, %al
; SSE2-NEXT:    je LBB2_4
; SSE2-NEXT:  ## %bb.3: ## %cond.store1
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm2[1,1,2,3]
; SSE2-NEXT:    movd %xmm4, 4(%rdi)
; SSE2-NEXT:  LBB2_4: ## %else2
; SSE2-NEXT:    pxor %xmm4, %xmm4
; SSE2-NEXT:    pcmpeqd %xmm4, %xmm0
; SSE2-NEXT:    pextrw $4, %xmm0, %eax
; SSE2-NEXT:    testb $1, %al
; SSE2-NEXT:    je LBB2_6
; SSE2-NEXT:  ## %bb.5: ## %cond.store3
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm2[2,3,0,1]
; SSE2-NEXT:    movd %xmm4, 8(%rdi)
; SSE2-NEXT:  LBB2_6: ## %else4
; SSE2-NEXT:    pextrw $6, %xmm0, %eax
; SSE2-NEXT:    testb $1, %al
; SSE2-NEXT:    je LBB2_8
; SSE2-NEXT:  ## %bb.7: ## %cond.store5
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm2[3,1,2,3]
; SSE2-NEXT:    movd %xmm0, 12(%rdi)
; SSE2-NEXT:  LBB2_8: ## %else6
; SSE2-NEXT:    pxor %xmm0, %xmm0
; SSE2-NEXT:    pcmpeqd %xmm1, %xmm0
; SSE2-NEXT:    pextrw $0, %xmm0, %eax
; SSE2-NEXT:    testb $1, %al
; SSE2-NEXT:    je LBB2_10
; SSE2-NEXT:  ## %bb.9: ## %cond.store7
; SSE2-NEXT:    movd %xmm3, 16(%rdi)
; SSE2-NEXT:  LBB2_10: ## %else8
; SSE2-NEXT:    pextrw $2, %xmm0, %eax
; SSE2-NEXT:    testb $1, %al
; SSE2-NEXT:    je LBB2_12
; SSE2-NEXT:  ## %bb.11: ## %cond.store9
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm3[1,1,2,3]
; SSE2-NEXT:    movd %xmm0, 20(%rdi)
; SSE2-NEXT:  LBB2_12: ## %else10
; SSE2-NEXT:    pxor %xmm0, %xmm0
; SSE2-NEXT:    pcmpeqd %xmm0, %xmm1
; SSE2-NEXT:    pextrw $4, %xmm1, %eax
; SSE2-NEXT:    testb $1, %al
; SSE2-NEXT:    je LBB2_14
; SSE2-NEXT:  ## %bb.13: ## %cond.store11
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm3[2,3,0,1]
; SSE2-NEXT:    movd %xmm0, 24(%rdi)
; SSE2-NEXT:  LBB2_14: ## %else12
; SSE2-NEXT:    pextrw $6, %xmm1, %eax
; SSE2-NEXT:    testb $1, %al
; SSE2-NEXT:    je LBB2_16
; SSE2-NEXT:  ## %bb.15: ## %cond.store13
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm3[3,1,2,3]
; SSE2-NEXT:    movd %xmm0, 28(%rdi)
; SSE2-NEXT:  LBB2_16: ## %else14
; SSE2-NEXT:    retq
;
; SSE4-LABEL: store_v8i32_v8i32:
; SSE4:       ## %bb.0:
; SSE4-NEXT:    pxor %xmm4, %xmm4
; SSE4-NEXT:    pcmpeqd %xmm0, %xmm4
; SSE4-NEXT:    pextrb $0, %xmm4, %eax
; SSE4-NEXT:    testb $1, %al
; SSE4-NEXT:    je LBB2_2
; SSE4-NEXT:  ## %bb.1: ## %cond.store
; SSE4-NEXT:    movss %xmm2, (%rdi)
; SSE4-NEXT:  LBB2_2: ## %else
; SSE4-NEXT:    pextrb $4, %xmm4, %eax
; SSE4-NEXT:    testb $1, %al
; SSE4-NEXT:    je LBB2_4
; SSE4-NEXT:  ## %bb.3: ## %cond.store1
; SSE4-NEXT:    extractps $1, %xmm2, 4(%rdi)
; SSE4-NEXT:  LBB2_4: ## %else2
; SSE4-NEXT:    pxor %xmm4, %xmm4
; SSE4-NEXT:    pcmpeqd %xmm4, %xmm0
; SSE4-NEXT:    pextrb $8, %xmm0, %eax
; SSE4-NEXT:    testb $1, %al
; SSE4-NEXT:    je LBB2_6
; SSE4-NEXT:  ## %bb.5: ## %cond.store3
; SSE4-NEXT:    extractps $2, %xmm2, 8(%rdi)
; SSE4-NEXT:  LBB2_6: ## %else4
; SSE4-NEXT:    pextrb $12, %xmm0, %eax
; SSE4-NEXT:    testb $1, %al
; SSE4-NEXT:    je LBB2_8
; SSE4-NEXT:  ## %bb.7: ## %cond.store5
; SSE4-NEXT:    extractps $3, %xmm2, 12(%rdi)
; SSE4-NEXT:  LBB2_8: ## %else6
; SSE4-NEXT:    pxor %xmm0, %xmm0
; SSE4-NEXT:    pcmpeqd %xmm1, %xmm0
; SSE4-NEXT:    pextrb $0, %xmm0, %eax
; SSE4-NEXT:    testb $1, %al
; SSE4-NEXT:    je LBB2_10
; SSE4-NEXT:  ## %bb.9: ## %cond.store7
; SSE4-NEXT:    movss %xmm3, 16(%rdi)
; SSE4-NEXT:  LBB2_10: ## %else8
; SSE4-NEXT:    pextrb $4, %xmm0, %eax
; SSE4-NEXT:    testb $1, %al
; SSE4-NEXT:    je LBB2_12
; SSE4-NEXT:  ## %bb.11: ## %cond.store9
; SSE4-NEXT:    extractps $1, %xmm3, 20(%rdi)
; SSE4-NEXT:  LBB2_12: ## %else10
; SSE4-NEXT:    pxor %xmm0, %xmm0
; SSE4-NEXT:    pcmpeqd %xmm0, %xmm1
; SSE4-NEXT:    pextrb $8, %xmm1, %eax
; SSE4-NEXT:    testb $1, %al
; SSE4-NEXT:    je LBB2_14
; SSE4-NEXT:  ## %bb.13: ## %cond.store11
; SSE4-NEXT:    extractps $2, %xmm3, 24(%rdi)
; SSE4-NEXT:  LBB2_14: ## %else12
; SSE4-NEXT:    pextrb $12, %xmm1, %eax
; SSE4-NEXT:    testb $1, %al
; SSE4-NEXT:    je LBB2_16
; SSE4-NEXT:  ## %bb.15: ## %cond.store13
; SSE4-NEXT:    extractps $3, %xmm3, 28(%rdi)
; SSE4-NEXT:  LBB2_16: ## %else14
; SSE4-NEXT:    retq
;
; AVX1-LABEL: store_v8i32_v8i32:
; AVX1:       ## %bb.0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX1-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX1-NEXT:    vpcmpeqd %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpcmpeqd %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    vmaskmovps %ymm1, %ymm0, (%rdi)
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: store_v8i32_v8i32:
; AVX2:       ## %bb.0:
; AVX2-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; AVX2-NEXT:    vpcmpeqd %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpmaskmovd %ymm1, %ymm0, (%rdi)
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: store_v8i32_v8i32:
; AVX512F:       ## %bb.0:
; AVX512F-NEXT:    ## kill: def $ymm1 killed $ymm1 def $zmm1
; AVX512F-NEXT:    ## kill: def $ymm0 killed $ymm0 def $zmm0
; AVX512F-NEXT:    vptestnmd %zmm0, %zmm0, %k0
; AVX512F-NEXT:    kshiftlw $8, %k0, %k0
; AVX512F-NEXT:    kshiftrw $8, %k0, %k1
; AVX512F-NEXT:    vmovdqu32 %zmm1, (%rdi) {%k1}
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512VLBW-LABEL: store_v8i32_v8i32:
; AVX512VLBW:       ## %bb.0:
; AVX512VLBW-NEXT:    vptestnmd %ymm0, %ymm0, %k1
; AVX512VLBW-NEXT:    vmovdqu32 %ymm1, (%rdi) {%k1}
; AVX512VLBW-NEXT:    vzeroupper
; AVX512VLBW-NEXT:    retq
  %mask = icmp eq <8 x i32> %trigger, zeroinitializer
  call void @llvm.masked.store.v8i32.p0v8i32(<8 x i32>%val, <8 x i32>* %addr, i32 4, <8 x i1>%mask)
  ret void
}

define void @store_v2f32_v2i32(<2 x i32> %trigger, <2 x float>* %addr, <2 x float> %val) {
; SSE2-LABEL: store_v2f32_v2i32:
; SSE2:       ## %bb.0:
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    pcmpeqd %xmm0, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm2[1,0,3,2]
; SSE2-NEXT:    pand %xmm2, %xmm0
; SSE2-NEXT:    movd %xmm0, %eax
; SSE2-NEXT:    testb $1, %al
; SSE2-NEXT:    je LBB3_2
; SSE2-NEXT:  ## %bb.1: ## %cond.store
; SSE2-NEXT:    movss %xmm1, (%rdi)
; SSE2-NEXT:  LBB3_2: ## %else
; SSE2-NEXT:    pextrw $4, %xmm0, %eax
; SSE2-NEXT:    testb $1, %al
; SSE2-NEXT:    je LBB3_4
; SSE2-NEXT:  ## %bb.3: ## %cond.store1
; SSE2-NEXT:    shufps {{.*#+}} xmm1 = xmm1[1,1,2,3]
; SSE2-NEXT:    movss %xmm1, 4(%rdi)
; SSE2-NEXT:  LBB3_4: ## %else2
; SSE2-NEXT:    retq
;
; SSE4-LABEL: store_v2f32_v2i32:
; SSE4:       ## %bb.0:
; SSE4-NEXT:    pxor %xmm2, %xmm2
; SSE4-NEXT:    movdqa %xmm0, %xmm3
; SSE4-NEXT:    pblendw {{.*#+}} xmm3 = xmm3[0,1],xmm2[2,3],xmm3[4,5],xmm2[6,7]
; SSE4-NEXT:    pcmpeqq %xmm2, %xmm3
; SSE4-NEXT:    pextrb $0, %xmm3, %eax
; SSE4-NEXT:    testb $1, %al
; SSE4-NEXT:    je LBB3_2
; SSE4-NEXT:  ## %bb.1: ## %cond.store
; SSE4-NEXT:    movss %xmm1, (%rdi)
; SSE4-NEXT:  LBB3_2: ## %else
; SSE4-NEXT:    pblendw {{.*#+}} xmm0 = xmm0[0,1],xmm2[2,3],xmm0[4,5],xmm2[6,7]
; SSE4-NEXT:    pcmpeqq %xmm2, %xmm0
; SSE4-NEXT:    pextrb $8, %xmm0, %eax
; SSE4-NEXT:    testb $1, %al
; SSE4-NEXT:    je LBB3_4
; SSE4-NEXT:  ## %bb.3: ## %cond.store1
; SSE4-NEXT:    extractps $1, %xmm1, 4(%rdi)
; SSE4-NEXT:  LBB3_4: ## %else2
; SSE4-NEXT:    retq
;
; AVX1-LABEL: store_v2f32_v2i32:
; AVX1:       ## %bb.0:
; AVX1-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; AVX1-NEXT:    vpblendw {{.*#+}} xmm0 = xmm0[0,1],xmm2[2,3],xmm0[4,5],xmm2[6,7]
; AVX1-NEXT:    vpcmpeqq %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0,2],zero,zero
; AVX1-NEXT:    vmaskmovps %xmm1, %xmm0, (%rdi)
; AVX1-NEXT:    retq
;
; AVX2-LABEL: store_v2f32_v2i32:
; AVX2:       ## %bb.0:
; AVX2-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; AVX2-NEXT:    vpblendd {{.*#+}} xmm0 = xmm0[0],xmm2[1],xmm0[2],xmm2[3]
; AVX2-NEXT:    vpcmpeqq %xmm2, %xmm0, %xmm0
; AVX2-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0,2],zero,zero
; AVX2-NEXT:    vmaskmovps %xmm1, %xmm0, (%rdi)
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: store_v2f32_v2i32:
; AVX512F:       ## %bb.0:
; AVX512F-NEXT:    ## kill: def $xmm1 killed $xmm1 def $zmm1
; AVX512F-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; AVX512F-NEXT:    vpblendd {{.*#+}} xmm0 = xmm0[0],xmm2[1],xmm0[2],xmm2[3]
; AVX512F-NEXT:    vptestnmq %zmm0, %zmm0, %k0
; AVX512F-NEXT:    kshiftlw $14, %k0, %k0
; AVX512F-NEXT:    kshiftrw $14, %k0, %k1
; AVX512F-NEXT:    vmovups %zmm1, (%rdi) {%k1}
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512VLBW-LABEL: store_v2f32_v2i32:
; AVX512VLBW:       ## %bb.0:
; AVX512VLBW-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; AVX512VLBW-NEXT:    vpblendd {{.*#+}} xmm0 = xmm0[0],xmm2[1],xmm0[2],xmm2[3]
; AVX512VLBW-NEXT:    vptestnmq %xmm0, %xmm0, %k1
; AVX512VLBW-NEXT:    vmovups %xmm1, (%rdi) {%k1}
; AVX512VLBW-NEXT:    retq
  %mask = icmp eq <2 x i32> %trigger, zeroinitializer
  call void @llvm.masked.store.v2f32.p0v2f32(<2 x float>%val, <2 x float>* %addr, i32 4, <2 x i1>%mask)
  ret void
}

define void @store_v2i32_v2i32(<2 x i32> %trigger, <2 x i32>* %addr, <2 x i32> %val) {
; SSE2-LABEL: store_v2i32_v2i32:
; SSE2:       ## %bb.0:
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    pcmpeqd %xmm0, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm2[1,0,3,2]
; SSE2-NEXT:    pand %xmm2, %xmm0
; SSE2-NEXT:    movd %xmm0, %eax
; SSE2-NEXT:    testb $1, %al
; SSE2-NEXT:    je LBB4_2
; SSE2-NEXT:  ## %bb.1: ## %cond.store
; SSE2-NEXT:    movd %xmm1, (%rdi)
; SSE2-NEXT:  LBB4_2: ## %else
; SSE2-NEXT:    pextrw $4, %xmm0, %eax
; SSE2-NEXT:    testb $1, %al
; SSE2-NEXT:    je LBB4_4
; SSE2-NEXT:  ## %bb.3: ## %cond.store1
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm1[2,3,0,1]
; SSE2-NEXT:    movd %xmm0, 4(%rdi)
; SSE2-NEXT:  LBB4_4: ## %else2
; SSE2-NEXT:    retq
;
; SSE4-LABEL: store_v2i32_v2i32:
; SSE4:       ## %bb.0:
; SSE4-NEXT:    pxor %xmm2, %xmm2
; SSE4-NEXT:    movdqa %xmm0, %xmm3
; SSE4-NEXT:    pblendw {{.*#+}} xmm3 = xmm3[0,1],xmm2[2,3],xmm3[4,5],xmm2[6,7]
; SSE4-NEXT:    pcmpeqq %xmm2, %xmm3
; SSE4-NEXT:    pextrb $0, %xmm3, %eax
; SSE4-NEXT:    testb $1, %al
; SSE4-NEXT:    je LBB4_2
; SSE4-NEXT:  ## %bb.1: ## %cond.store
; SSE4-NEXT:    movss %xmm1, (%rdi)
; SSE4-NEXT:  LBB4_2: ## %else
; SSE4-NEXT:    pblendw {{.*#+}} xmm0 = xmm0[0,1],xmm2[2,3],xmm0[4,5],xmm2[6,7]
; SSE4-NEXT:    pcmpeqq %xmm2, %xmm0
; SSE4-NEXT:    pextrb $8, %xmm0, %eax
; SSE4-NEXT:    testb $1, %al
; SSE4-NEXT:    je LBB4_4
; SSE4-NEXT:  ## %bb.3: ## %cond.store1
; SSE4-NEXT:    extractps $2, %xmm1, 4(%rdi)
; SSE4-NEXT:  LBB4_4: ## %else2
; SSE4-NEXT:    retq
;
; AVX1-LABEL: store_v2i32_v2i32:
; AVX1:       ## %bb.0:
; AVX1-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; AVX1-NEXT:    vpblendw {{.*#+}} xmm0 = xmm0[0,1],xmm2[2,3],xmm0[4,5],xmm2[6,7]
; AVX1-NEXT:    vpcmpeqq %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0,2],zero,zero
; AVX1-NEXT:    vpermilps {{.*#+}} xmm1 = xmm1[0,2,2,3]
; AVX1-NEXT:    vmaskmovps %xmm1, %xmm0, (%rdi)
; AVX1-NEXT:    retq
;
; AVX2-LABEL: store_v2i32_v2i32:
; AVX2:       ## %bb.0:
; AVX2-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; AVX2-NEXT:    vpblendd {{.*#+}} xmm0 = xmm0[0],xmm2[1],xmm0[2],xmm2[3]
; AVX2-NEXT:    vpcmpeqq %xmm2, %xmm0, %xmm0
; AVX2-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0,2],zero,zero
; AVX2-NEXT:    vpshufd {{.*#+}} xmm1 = xmm1[0,2,2,3]
; AVX2-NEXT:    vpmaskmovd %xmm1, %xmm0, (%rdi)
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: store_v2i32_v2i32:
; AVX512F:       ## %bb.0:
; AVX512F-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; AVX512F-NEXT:    vpblendd {{.*#+}} xmm0 = xmm0[0],xmm2[1],xmm0[2],xmm2[3]
; AVX512F-NEXT:    vptestnmq %zmm0, %zmm0, %k0
; AVX512F-NEXT:    vpshufd {{.*#+}} xmm0 = xmm1[0,2,2,3]
; AVX512F-NEXT:    kshiftlw $14, %k0, %k0
; AVX512F-NEXT:    kshiftrw $14, %k0, %k1
; AVX512F-NEXT:    vmovdqu32 %zmm0, (%rdi) {%k1}
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512VLBW-LABEL: store_v2i32_v2i32:
; AVX512VLBW:       ## %bb.0:
; AVX512VLBW-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; AVX512VLBW-NEXT:    vpblendd {{.*#+}} xmm0 = xmm0[0],xmm2[1],xmm0[2],xmm2[3]
; AVX512VLBW-NEXT:    vptestnmq %xmm0, %xmm0, %k1
; AVX512VLBW-NEXT:    vpmovqd %xmm1, (%rdi) {%k1}
; AVX512VLBW-NEXT:    retq
  %mask = icmp eq <2 x i32> %trigger, zeroinitializer
  call void @llvm.masked.store.v2i32.p0v2i32(<2 x i32>%val, <2 x i32>* %addr, i32 4, <2 x i1>%mask)
  ret void
}

define void @const_store_v4i32_v4i32(<4 x i32> %trigger, <4 x i32>* %addr, <4 x i32> %val) {
; SSE-LABEL: const_store_v4i32_v4i32:
; SSE:       ## %bb.0:
; SSE-NEXT:    movups %xmm1, (%rdi)
; SSE-NEXT:    retq
;
; AVX1-LABEL: const_store_v4i32_v4i32:
; AVX1:       ## %bb.0:
; AVX1-NEXT:    vpcmpeqd %xmm0, %xmm0, %xmm0
; AVX1-NEXT:    vmaskmovps %xmm1, %xmm0, (%rdi)
; AVX1-NEXT:    retq
;
; AVX2-LABEL: const_store_v4i32_v4i32:
; AVX2:       ## %bb.0:
; AVX2-NEXT:    vpcmpeqd %xmm0, %xmm0, %xmm0
; AVX2-NEXT:    vpmaskmovd %xmm1, %xmm0, (%rdi)
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: const_store_v4i32_v4i32:
; AVX512F:       ## %bb.0:
; AVX512F-NEXT:    ## kill: def $xmm1 killed $xmm1 def $zmm1
; AVX512F-NEXT:    movw $15, %ax
; AVX512F-NEXT:    kmovw %eax, %k1
; AVX512F-NEXT:    vmovdqu32 %zmm1, (%rdi) {%k1}
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512VLBW-LABEL: const_store_v4i32_v4i32:
; AVX512VLBW:       ## %bb.0:
; AVX512VLBW-NEXT:    kxnorw %k0, %k0, %k1
; AVX512VLBW-NEXT:    vmovdqu32 %xmm1, (%rdi) {%k1}
; AVX512VLBW-NEXT:    retq
  %mask = icmp eq <4 x i32> %trigger, zeroinitializer
  call void @llvm.masked.store.v4i32.p0v4i32(<4 x i32>%val, <4 x i32>* %addr, i32 4, <4 x i1><i1 true, i1 true, i1 true, i1 true>)
  ret void
}

;  When only one element of the mask is set, reduce to a scalar store.

define void @one_mask_bit_set1(<4 x i32>* %addr, <4 x i32> %val) {
; SSE-LABEL: one_mask_bit_set1:
; SSE:       ## %bb.0:
; SSE-NEXT:    movss %xmm0, (%rdi)
; SSE-NEXT:    retq
;
; AVX-LABEL: one_mask_bit_set1:
; AVX:       ## %bb.0:
; AVX-NEXT:    vmovss %xmm0, (%rdi)
; AVX-NEXT:    retq
  call void @llvm.masked.store.v4i32.p0v4i32(<4 x i32> %val, <4 x i32>* %addr, i32 4, <4 x i1><i1 true, i1 false, i1 false, i1 false>)
  ret void
}

; Choose a different element to show that the correct address offset is produced.

define void @one_mask_bit_set2(<4 x float>* %addr, <4 x float> %val) {
; SSE2-LABEL: one_mask_bit_set2:
; SSE2:       ## %bb.0:
; SSE2-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; SSE2-NEXT:    movss %xmm0, 8(%rdi)
; SSE2-NEXT:    retq
;
; SSE4-LABEL: one_mask_bit_set2:
; SSE4:       ## %bb.0:
; SSE4-NEXT:    extractps $2, %xmm0, 8(%rdi)
; SSE4-NEXT:    retq
;
; AVX-LABEL: one_mask_bit_set2:
; AVX:       ## %bb.0:
; AVX-NEXT:    vextractps $2, %xmm0, 8(%rdi)
; AVX-NEXT:    retq
  call void @llvm.masked.store.v4f32.p0v4f32(<4 x float> %val, <4 x float>* %addr, i32 4, <4 x i1><i1 false, i1 false, i1 true, i1 false>)
  ret void
}

; Choose a different scalar type and a high element of a 256-bit vector because AVX doesn't support those evenly.

define void @one_mask_bit_set3(<4 x i64>* %addr, <4 x i64> %val) {
; SSE-LABEL: one_mask_bit_set3:
; SSE:       ## %bb.0:
; SSE-NEXT:    movlps %xmm1, 16(%rdi)
; SSE-NEXT:    retq
;
; AVX-LABEL: one_mask_bit_set3:
; AVX:       ## %bb.0:
; AVX-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX-NEXT:    vmovlps %xmm0, 16(%rdi)
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
  call void @llvm.masked.store.v4i64.p0v4i64(<4 x i64> %val, <4 x i64>* %addr, i32 4, <4 x i1><i1 false, i1 false, i1 true, i1 false>)
  ret void
}

; Choose a different scalar type and a high element of a 256-bit vector because AVX doesn't support those evenly.

define void @one_mask_bit_set4(<4 x double>* %addr, <4 x double> %val) {
; SSE-LABEL: one_mask_bit_set4:
; SSE:       ## %bb.0:
; SSE-NEXT:    movhpd %xmm1, 24(%rdi)
; SSE-NEXT:    retq
;
; AVX-LABEL: one_mask_bit_set4:
; AVX:       ## %bb.0:
; AVX-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX-NEXT:    vmovhpd %xmm0, 24(%rdi)
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
  call void @llvm.masked.store.v4f64.p0v4f64(<4 x double> %val, <4 x double>* %addr, i32 4, <4 x i1><i1 false, i1 false, i1 false, i1 true>)
  ret void
}

; Try a 512-bit vector to make sure AVX doesn't die and AVX512 works as expected.

define void @one_mask_bit_set5(<8 x double>* %addr, <8 x double> %val) {
; SSE-LABEL: one_mask_bit_set5:
; SSE:       ## %bb.0:
; SSE-NEXT:    movlps %xmm3, 48(%rdi)
; SSE-NEXT:    retq
;
; AVX1OR2-LABEL: one_mask_bit_set5:
; AVX1OR2:       ## %bb.0:
; AVX1OR2-NEXT:    vextractf128 $1, %ymm1, %xmm0
; AVX1OR2-NEXT:    vmovlps %xmm0, 48(%rdi)
; AVX1OR2-NEXT:    vzeroupper
; AVX1OR2-NEXT:    retq
;
; AVX512-LABEL: one_mask_bit_set5:
; AVX512:       ## %bb.0:
; AVX512-NEXT:    vextractf32x4 $3, %zmm0, %xmm0
; AVX512-NEXT:    vmovlps %xmm0, 48(%rdi)
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  call void @llvm.masked.store.v8f64.p0v8f64(<8 x double> %val, <8 x double>* %addr, i32 4, <8 x i1><i1 false, i1 false, i1 false, i1 false, i1 false, i1 false, i1 true, i1 false>)
  ret void
}

; The mask bit for each data element is the most significant bit of the mask operand, so a compare isn't needed.
; FIXME: The AVX512 code should be improved to use 'vpmovd2m'. Add tests for 512-bit vectors when implementing that.

define void @trunc_mask(<4 x float> %x, <4 x float>* %ptr, <4 x float> %y, <4 x i32> %mask) {
; SSE2-LABEL: trunc_mask:
; SSE2:       ## %bb.0:
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    pcmpgtd %xmm2, %xmm1
; SSE2-NEXT:    movd %xmm1, %eax
; SSE2-NEXT:    testb $1, %al
; SSE2-NEXT:    je LBB11_2
; SSE2-NEXT:  ## %bb.1: ## %cond.store
; SSE2-NEXT:    movss %xmm0, (%rdi)
; SSE2-NEXT:  LBB11_2: ## %else
; SSE2-NEXT:    pextrw $2, %xmm1, %eax
; SSE2-NEXT:    testb $1, %al
; SSE2-NEXT:    je LBB11_4
; SSE2-NEXT:  ## %bb.3: ## %cond.store1
; SSE2-NEXT:    movaps %xmm0, %xmm1
; SSE2-NEXT:    shufps {{.*#+}} xmm1 = xmm1[1,1],xmm0[2,3]
; SSE2-NEXT:    movss %xmm1, 4(%rdi)
; SSE2-NEXT:  LBB11_4: ## %else2
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    pcmpgtd %xmm2, %xmm1
; SSE2-NEXT:    pextrw $4, %xmm1, %eax
; SSE2-NEXT:    testb $1, %al
; SSE2-NEXT:    je LBB11_6
; SSE2-NEXT:  ## %bb.5: ## %cond.store3
; SSE2-NEXT:    movaps %xmm0, %xmm2
; SSE2-NEXT:    unpckhpd {{.*#+}} xmm2 = xmm2[1],xmm0[1]
; SSE2-NEXT:    movss %xmm2, 8(%rdi)
; SSE2-NEXT:  LBB11_6: ## %else4
; SSE2-NEXT:    pextrw $6, %xmm1, %eax
; SSE2-NEXT:    testb $1, %al
; SSE2-NEXT:    je LBB11_8
; SSE2-NEXT:  ## %bb.7: ## %cond.store5
; SSE2-NEXT:    shufps {{.*#+}} xmm0 = xmm0[3,1,2,3]
; SSE2-NEXT:    movss %xmm0, 12(%rdi)
; SSE2-NEXT:  LBB11_8: ## %else6
; SSE2-NEXT:    retq
;
; SSE4-LABEL: trunc_mask:
; SSE4:       ## %bb.0:
; SSE4-NEXT:    pxor %xmm1, %xmm1
; SSE4-NEXT:    pcmpgtd %xmm2, %xmm1
; SSE4-NEXT:    pextrb $0, %xmm1, %eax
; SSE4-NEXT:    testb $1, %al
; SSE4-NEXT:    je LBB11_2
; SSE4-NEXT:  ## %bb.1: ## %cond.store
; SSE4-NEXT:    movss %xmm0, (%rdi)
; SSE4-NEXT:  LBB11_2: ## %else
; SSE4-NEXT:    pextrb $4, %xmm1, %eax
; SSE4-NEXT:    testb $1, %al
; SSE4-NEXT:    je LBB11_4
; SSE4-NEXT:  ## %bb.3: ## %cond.store1
; SSE4-NEXT:    extractps $1, %xmm0, 4(%rdi)
; SSE4-NEXT:  LBB11_4: ## %else2
; SSE4-NEXT:    pxor %xmm1, %xmm1
; SSE4-NEXT:    pcmpgtd %xmm2, %xmm1
; SSE4-NEXT:    pextrb $8, %xmm1, %eax
; SSE4-NEXT:    testb $1, %al
; SSE4-NEXT:    je LBB11_6
; SSE4-NEXT:  ## %bb.5: ## %cond.store3
; SSE4-NEXT:    extractps $2, %xmm0, 8(%rdi)
; SSE4-NEXT:  LBB11_6: ## %else4
; SSE4-NEXT:    pextrb $12, %xmm1, %eax
; SSE4-NEXT:    testb $1, %al
; SSE4-NEXT:    je LBB11_8
; SSE4-NEXT:  ## %bb.7: ## %cond.store5
; SSE4-NEXT:    extractps $3, %xmm0, 12(%rdi)
; SSE4-NEXT:  LBB11_8: ## %else6
; SSE4-NEXT:    retq
;
; AVX1OR2-LABEL: trunc_mask:
; AVX1OR2:       ## %bb.0:
; AVX1OR2-NEXT:    vmaskmovps %xmm0, %xmm2, (%rdi)
; AVX1OR2-NEXT:    retq
;
; AVX512F-LABEL: trunc_mask:
; AVX512F:       ## %bb.0:
; AVX512F-NEXT:    ## kill: def $xmm2 killed $xmm2 def $zmm2
; AVX512F-NEXT:    ## kill: def $xmm0 killed $xmm0 def $zmm0
; AVX512F-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX512F-NEXT:    vpcmpgtd %zmm2, %zmm1, %k0
; AVX512F-NEXT:    kshiftlw $12, %k0, %k0
; AVX512F-NEXT:    kshiftrw $12, %k0, %k1
; AVX512F-NEXT:    vmovups %zmm0, (%rdi) {%k1}
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512VLBW-LABEL: trunc_mask:
; AVX512VLBW:       ## %bb.0:
; AVX512VLBW-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX512VLBW-NEXT:    vpcmpgtd %xmm2, %xmm1, %k1
; AVX512VLBW-NEXT:    vmovups %xmm0, (%rdi) {%k1}
; AVX512VLBW-NEXT:    retq
  %bool_mask = icmp slt <4 x i32> %mask, zeroinitializer
  call void @llvm.masked.store.v4f32.p0v4f32(<4 x float> %x, <4 x float>* %ptr, i32 1, <4 x i1> %bool_mask)
  ret void
}

; SimplifyDemandedBits eliminates an ashr here.

define void @masked_store_bool_mask_demand_trunc_sext(<4 x double> %x, <4 x double>* %p, <4 x i32> %masksrc) {
; SSE2-LABEL: masked_store_bool_mask_demand_trunc_sext:
; SSE2:       ## %bb.0:
; SSE2-NEXT:    movd %xmm2, %eax
; SSE2-NEXT:    testb $1, %al
; SSE2-NEXT:    je LBB12_2
; SSE2-NEXT:  ## %bb.1: ## %cond.store
; SSE2-NEXT:    movlpd %xmm0, (%rdi)
; SSE2-NEXT:  LBB12_2: ## %else
; SSE2-NEXT:    pextrw $2, %xmm2, %eax
; SSE2-NEXT:    testb $1, %al
; SSE2-NEXT:    je LBB12_4
; SSE2-NEXT:  ## %bb.3: ## %cond.store1
; SSE2-NEXT:    movhpd %xmm0, 8(%rdi)
; SSE2-NEXT:  LBB12_4: ## %else2
; SSE2-NEXT:    pextrw $4, %xmm2, %eax
; SSE2-NEXT:    testb $1, %al
; SSE2-NEXT:    je LBB12_6
; SSE2-NEXT:  ## %bb.5: ## %cond.store3
; SSE2-NEXT:    movlpd %xmm1, 16(%rdi)
; SSE2-NEXT:  LBB12_6: ## %else4
; SSE2-NEXT:    pextrw $6, %xmm2, %eax
; SSE2-NEXT:    testb $1, %al
; SSE2-NEXT:    je LBB12_8
; SSE2-NEXT:  ## %bb.7: ## %cond.store5
; SSE2-NEXT:    movhpd %xmm1, 24(%rdi)
; SSE2-NEXT:  LBB12_8: ## %else6
; SSE2-NEXT:    retq
;
; SSE4-LABEL: masked_store_bool_mask_demand_trunc_sext:
; SSE4:       ## %bb.0:
; SSE4-NEXT:    pextrb $0, %xmm2, %eax
; SSE4-NEXT:    testb $1, %al
; SSE4-NEXT:    je LBB12_2
; SSE4-NEXT:  ## %bb.1: ## %cond.store
; SSE4-NEXT:    movlpd %xmm0, (%rdi)
; SSE4-NEXT:  LBB12_2: ## %else
; SSE4-NEXT:    pextrb $4, %xmm2, %eax
; SSE4-NEXT:    testb $1, %al
; SSE4-NEXT:    je LBB12_4
; SSE4-NEXT:  ## %bb.3: ## %cond.store1
; SSE4-NEXT:    movhpd %xmm0, 8(%rdi)
; SSE4-NEXT:  LBB12_4: ## %else2
; SSE4-NEXT:    pextrb $8, %xmm2, %eax
; SSE4-NEXT:    testb $1, %al
; SSE4-NEXT:    je LBB12_6
; SSE4-NEXT:  ## %bb.5: ## %cond.store3
; SSE4-NEXT:    movlpd %xmm1, 16(%rdi)
; SSE4-NEXT:  LBB12_6: ## %else4
; SSE4-NEXT:    pextrb $12, %xmm2, %eax
; SSE4-NEXT:    testb $1, %al
; SSE4-NEXT:    je LBB12_8
; SSE4-NEXT:  ## %bb.7: ## %cond.store5
; SSE4-NEXT:    movhpd %xmm1, 24(%rdi)
; SSE4-NEXT:  LBB12_8: ## %else6
; SSE4-NEXT:    retq
;
; AVX1-LABEL: masked_store_bool_mask_demand_trunc_sext:
; AVX1:       ## %bb.0:
; AVX1-NEXT:    vpslld $31, %xmm1, %xmm1
; AVX1-NEXT:    vpmovsxdq %xmm1, %xmm2
; AVX1-NEXT:    vpshufd {{.*#+}} xmm1 = xmm1[2,3,0,1]
; AVX1-NEXT:    vpmovsxdq %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm2, %ymm1
; AVX1-NEXT:    vmaskmovpd %ymm0, %ymm1, (%rdi)
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: masked_store_bool_mask_demand_trunc_sext:
; AVX2:       ## %bb.0:
; AVX2-NEXT:    vpslld $31, %xmm1, %xmm1
; AVX2-NEXT:    vpmovsxdq %xmm1, %ymm1
; AVX2-NEXT:    vmaskmovpd %ymm0, %ymm1, (%rdi)
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: masked_store_bool_mask_demand_trunc_sext:
; AVX512F:       ## %bb.0:
; AVX512F-NEXT:    ## kill: def $ymm0 killed $ymm0 def $zmm0
; AVX512F-NEXT:    vpslld $31, %xmm1, %xmm1
; AVX512F-NEXT:    vptestmd %zmm1, %zmm1, %k0
; AVX512F-NEXT:    kshiftlw $12, %k0, %k0
; AVX512F-NEXT:    kshiftrw $12, %k0, %k1
; AVX512F-NEXT:    vmovupd %zmm0, (%rdi) {%k1}
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512VLBW-LABEL: masked_store_bool_mask_demand_trunc_sext:
; AVX512VLBW:       ## %bb.0:
; AVX512VLBW-NEXT:    vpslld $31, %xmm1, %xmm1
; AVX512VLBW-NEXT:    vptestmd %xmm1, %xmm1, %k1
; AVX512VLBW-NEXT:    vmovupd %ymm0, (%rdi) {%k1}
; AVX512VLBW-NEXT:    vzeroupper
; AVX512VLBW-NEXT:    retq
  %sext = sext <4 x i32> %masksrc to <4 x i64>
  %boolmask = trunc <4 x i64> %sext to <4 x i1>
  call void @llvm.masked.store.v4f64.p0v4f64(<4 x double> %x, <4 x double>* %p, i32 4, <4 x i1> %boolmask)
  ret void
}

; This needs to be widened to v4i32.
; This used to assert in type legalization. PR38436
; FIXME: The codegen for AVX512 should use KSHIFT to zero the upper bits of the mask.
define void @widen_masked_store(<3 x i32> %v, <3 x i32>* %p, <3 x i1> %mask) {
; SSE2-LABEL: widen_masked_store:
; SSE2:       ## %bb.0:
; SSE2-NEXT:    testb $1, %sil
; SSE2-NEXT:    jne LBB13_1
; SSE2-NEXT:  ## %bb.2: ## %else
; SSE2-NEXT:    testb $1, %dl
; SSE2-NEXT:    jne LBB13_3
; SSE2-NEXT:  LBB13_4: ## %else2
; SSE2-NEXT:    testb $1, %cl
; SSE2-NEXT:    jne LBB13_5
; SSE2-NEXT:  LBB13_6: ## %else4
; SSE2-NEXT:    retq
; SSE2-NEXT:  LBB13_1: ## %cond.store
; SSE2-NEXT:    movd %xmm0, (%rdi)
; SSE2-NEXT:    testb $1, %dl
; SSE2-NEXT:    je LBB13_4
; SSE2-NEXT:  LBB13_3: ## %cond.store1
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm0[1,1,2,3]
; SSE2-NEXT:    movd %xmm1, 4(%rdi)
; SSE2-NEXT:    testb $1, %cl
; SSE2-NEXT:    je LBB13_6
; SSE2-NEXT:  LBB13_5: ## %cond.store3
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[2,3,0,1]
; SSE2-NEXT:    movd %xmm0, 8(%rdi)
; SSE2-NEXT:    retq
;
; SSE4-LABEL: widen_masked_store:
; SSE4:       ## %bb.0:
; SSE4-NEXT:    testb $1, %sil
; SSE4-NEXT:    jne LBB13_1
; SSE4-NEXT:  ## %bb.2: ## %else
; SSE4-NEXT:    testb $1, %dl
; SSE4-NEXT:    jne LBB13_3
; SSE4-NEXT:  LBB13_4: ## %else2
; SSE4-NEXT:    testb $1, %cl
; SSE4-NEXT:    jne LBB13_5
; SSE4-NEXT:  LBB13_6: ## %else4
; SSE4-NEXT:    retq
; SSE4-NEXT:  LBB13_1: ## %cond.store
; SSE4-NEXT:    movss %xmm0, (%rdi)
; SSE4-NEXT:    testb $1, %dl
; SSE4-NEXT:    je LBB13_4
; SSE4-NEXT:  LBB13_3: ## %cond.store1
; SSE4-NEXT:    extractps $1, %xmm0, 4(%rdi)
; SSE4-NEXT:    testb $1, %cl
; SSE4-NEXT:    je LBB13_6
; SSE4-NEXT:  LBB13_5: ## %cond.store3
; SSE4-NEXT:    extractps $2, %xmm0, 8(%rdi)
; SSE4-NEXT:    retq
;
; AVX1-LABEL: widen_masked_store:
; AVX1:       ## %bb.0:
; AVX1-NEXT:    vmovd %edx, %xmm1
; AVX1-NEXT:    vmovd %esi, %xmm2
; AVX1-NEXT:    vpunpckldq {{.*#+}} xmm1 = xmm2[0],xmm1[0],xmm2[1],xmm1[1]
; AVX1-NEXT:    vmovd %ecx, %xmm2
; AVX1-NEXT:    vpunpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm2[0]
; AVX1-NEXT:    vpslld $31, %xmm1, %xmm1
; AVX1-NEXT:    vmaskmovps %xmm0, %xmm1, (%rdi)
; AVX1-NEXT:    retq
;
; AVX2-LABEL: widen_masked_store:
; AVX2:       ## %bb.0:
; AVX2-NEXT:    vmovd %edx, %xmm1
; AVX2-NEXT:    vmovd %esi, %xmm2
; AVX2-NEXT:    vpunpckldq {{.*#+}} xmm1 = xmm2[0],xmm1[0],xmm2[1],xmm1[1]
; AVX2-NEXT:    vmovd %ecx, %xmm2
; AVX2-NEXT:    vpunpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm2[0]
; AVX2-NEXT:    vpslld $31, %xmm1, %xmm1
; AVX2-NEXT:    vpmaskmovd %xmm0, %xmm1, (%rdi)
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: widen_masked_store:
; AVX512F:       ## %bb.0:
; AVX512F-NEXT:    ## kill: def $xmm0 killed $xmm0 def $zmm0
; AVX512F-NEXT:    vpslld $31, %xmm1, %xmm1
; AVX512F-NEXT:    vptestmd %zmm1, %zmm1, %k1
; AVX512F-NEXT:    vpternlogd $255, %zmm1, %zmm1, %zmm1 {%k1} {z}
; AVX512F-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; AVX512F-NEXT:    vpblendd {{.*#+}} xmm1 = xmm1[0,1,2],xmm2[3]
; AVX512F-NEXT:    vptestmd %zmm1, %zmm1, %k0
; AVX512F-NEXT:    kshiftlw $12, %k0, %k0
; AVX512F-NEXT:    kshiftrw $12, %k0, %k1
; AVX512F-NEXT:    vmovdqu32 %zmm0, (%rdi) {%k1}
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512VLBW-LABEL: widen_masked_store:
; AVX512VLBW:       ## %bb.0:
; AVX512VLBW-NEXT:    vpslld $31, %xmm1, %xmm1
; AVX512VLBW-NEXT:    vptestmd %xmm1, %xmm1, %k1
; AVX512VLBW-NEXT:    vpcmpeqd %xmm1, %xmm1, %xmm1
; AVX512VLBW-NEXT:    vmovdqa32 %xmm1, %xmm1 {%k1} {z}
; AVX512VLBW-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; AVX512VLBW-NEXT:    vpblendd {{.*#+}} xmm1 = xmm1[0,1,2],xmm2[3]
; AVX512VLBW-NEXT:    vptestmd %xmm1, %xmm1, %k1
; AVX512VLBW-NEXT:    vmovdqa32 %xmm0, (%rdi) {%k1}
; AVX512VLBW-NEXT:    retq
  call void @llvm.masked.store.v3i32(<3 x i32> %v, <3 x i32>* %p, i32 16, <3 x i1> %mask)
  ret void
}
declare void @llvm.masked.store.v3i32(<3 x i32>, <3 x i32>*, i32, <3 x i1>)

declare void @llvm.masked.store.v8i32.p0v8i32(<8 x i32>, <8 x i32>*, i32, <8 x i1>)
declare void @llvm.masked.store.v4i32.p0v4i32(<4 x i32>, <4 x i32>*, i32, <4 x i1>)
declare void @llvm.masked.store.v4i64.p0v4i64(<4 x i64>, <4 x i64>*, i32, <4 x i1>)
declare void @llvm.masked.store.v2f32.p0v2f32(<2 x float>, <2 x float>*, i32, <2 x i1>)
declare void @llvm.masked.store.v2i32.p0v2i32(<2 x i32>, <2 x i32>*, i32, <2 x i1>)
declare void @llvm.masked.store.v1i32.p0v1i32(<1 x i32>, <1 x i32>*, i32, <1 x i1>)
declare void @llvm.masked.store.v4f32.p0v4f32(<4 x float>, <4 x float>*, i32, <4 x i1>)
declare void @llvm.masked.store.v8f64.p0v8f64(<8 x double>, <8 x double>*, i32, <8 x i1>)
declare void @llvm.masked.store.v4f64.p0v4f64(<4 x double>, <4 x double>*, i32, <4 x i1>)
declare void @llvm.masked.store.v2f64.p0v2f64(<2 x double>, <2 x double>*, i32, <2 x i1>)
declare void @llvm.masked.store.v2i64.p0v2i64(<2 x i64>, <2 x i64>*, i32, <2 x i1>)

