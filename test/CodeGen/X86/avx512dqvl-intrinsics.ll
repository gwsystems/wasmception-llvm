; RUN: llc < %s -mtriple=x86_64-apple-darwin -mcpu=knl -mattr=+avx512dq -mattr=+avx512vl --show-mc-encoding| FileCheck %s

define <8 x i64> @test_mask_mullo_epi64_rr_512(<8 x i64> %a, <8 x i64> %b) {
  ;CHECK-LABEL: test_mask_mullo_epi64_rr_512
  ;CHECK: vpmullq %zmm1, %zmm0, %zmm0     ## encoding: [0x62,0xf2,0xfd,0x48,0x40,0xc1]
  %res = call <8 x i64> @llvm.x86.avx512.mask.pmull.q.512(<8 x i64> %a, <8 x i64> %b, <8 x i64> zeroinitializer, i8 -1)
  ret <8 x i64> %res
}

define <8 x i64> @test_mask_mullo_epi64_rrk_512(<8 x i64> %a, <8 x i64> %b, <8 x i64> %passThru, i8 %mask) {
  ;CHECK-LABEL: test_mask_mullo_epi64_rrk_512
  ;CHECK: vpmullq %zmm1, %zmm0, %zmm2 {%k1} ## encoding: [0x62,0xf2,0xfd,0x49,0x40,0xd1]
  %res = call <8 x i64> @llvm.x86.avx512.mask.pmull.q.512(<8 x i64> %a, <8 x i64> %b, <8 x i64> %passThru, i8 %mask)
  ret <8 x i64> %res
}

define <8 x i64> @test_mask_mullo_epi64_rrkz_512(<8 x i64> %a, <8 x i64> %b, i8 %mask) {
  ;CHECK-LABEL: test_mask_mullo_epi64_rrkz_512
  ;CHECK: vpmullq %zmm1, %zmm0, %zmm0 {%k1} {z} ## encoding: [0x62,0xf2,0xfd,0xc9,0x40,0xc1]
  %res = call <8 x i64> @llvm.x86.avx512.mask.pmull.q.512(<8 x i64> %a, <8 x i64> %b, <8 x i64> zeroinitializer, i8 %mask)
  ret <8 x i64> %res
}

define <8 x i64> @test_mask_mullo_epi64_rm_512(<8 x i64> %a, <8 x i64>* %ptr_b) {
  ;CHECK-LABEL: test_mask_mullo_epi64_rm_512
  ;CHECK: vpmullq (%rdi), %zmm0, %zmm0    ## encoding: [0x62,0xf2,0xfd,0x48,0x40,0x07]
  %b = load <8 x i64>, <8 x i64>* %ptr_b
  %res = call <8 x i64> @llvm.x86.avx512.mask.pmull.q.512(<8 x i64> %a, <8 x i64> %b, <8 x i64> zeroinitializer, i8 -1)
  ret <8 x i64> %res
}

define <8 x i64> @test_mask_mullo_epi64_rmk_512(<8 x i64> %a, <8 x i64>* %ptr_b, <8 x i64> %passThru, i8 %mask) {
  ;CHECK-LABEL: test_mask_mullo_epi64_rmk_512
  ;CHECK: vpmullq (%rdi), %zmm0, %zmm1 {%k1} ## encoding: [0x62,0xf2,0xfd,0x49,0x40,0x0f]
  %b = load <8 x i64>, <8 x i64>* %ptr_b
  %res = call <8 x i64> @llvm.x86.avx512.mask.pmull.q.512(<8 x i64> %a, <8 x i64> %b, <8 x i64> %passThru, i8 %mask)
  ret <8 x i64> %res
}

define <8 x i64> @test_mask_mullo_epi64_rmkz_512(<8 x i64> %a, <8 x i64>* %ptr_b, i8 %mask) {
  ;CHECK-LABEL: test_mask_mullo_epi64_rmkz_512
  ;CHECK: vpmullq (%rdi), %zmm0, %zmm0 {%k1} {z} ## encoding: [0x62,0xf2,0xfd,0xc9,0x40,0x07]
  %b = load <8 x i64>, <8 x i64>* %ptr_b
  %res = call <8 x i64> @llvm.x86.avx512.mask.pmull.q.512(<8 x i64> %a, <8 x i64> %b, <8 x i64> zeroinitializer, i8 %mask)
  ret <8 x i64> %res
}

define <8 x i64> @test_mask_mullo_epi64_rmb_512(<8 x i64> %a, i64* %ptr_b) {
  ;CHECK-LABEL: test_mask_mullo_epi64_rmb_512
  ;CHECK: vpmullq (%rdi){1to8}, %zmm0, %zmm0  ## encoding: [0x62,0xf2,0xfd,0x58,0x40,0x07]
  %q = load i64, i64* %ptr_b
  %vecinit.i = insertelement <8 x i64> undef, i64 %q, i32 0
  %b = shufflevector <8 x i64> %vecinit.i, <8 x i64> undef, <8 x i32> zeroinitializer
  %res = call <8 x i64> @llvm.x86.avx512.mask.pmull.q.512(<8 x i64> %a, <8 x i64> %b, <8 x i64> zeroinitializer, i8 -1)
  ret <8 x i64> %res
}

define <8 x i64> @test_mask_mullo_epi64_rmbk_512(<8 x i64> %a, i64* %ptr_b, <8 x i64> %passThru, i8 %mask) {
  ;CHECK-LABEL: test_mask_mullo_epi64_rmbk_512
  ;CHECK: vpmullq (%rdi){1to8}, %zmm0, %zmm1 {%k1} ## encoding: [0x62,0xf2,0xfd,0x59,0x40,0x0f]
  %q = load i64, i64* %ptr_b
  %vecinit.i = insertelement <8 x i64> undef, i64 %q, i32 0
  %b = shufflevector <8 x i64> %vecinit.i, <8 x i64> undef, <8 x i32> zeroinitializer
  %res = call <8 x i64> @llvm.x86.avx512.mask.pmull.q.512(<8 x i64> %a, <8 x i64> %b, <8 x i64> %passThru, i8 %mask)
  ret <8 x i64> %res
}

define <8 x i64> @test_mask_mullo_epi64_rmbkz_512(<8 x i64> %a, i64* %ptr_b, i8 %mask) {
  ;CHECK-LABEL: test_mask_mullo_epi64_rmbkz_512
  ;CHECK: vpmullq (%rdi){1to8}, %zmm0, %zmm0 {%k1} {z} ## encoding: [0x62,0xf2,0xfd,0xd9,0x40,0x07]
  %q = load i64, i64* %ptr_b
  %vecinit.i = insertelement <8 x i64> undef, i64 %q, i32 0
  %b = shufflevector <8 x i64> %vecinit.i, <8 x i64> undef, <8 x i32> zeroinitializer
  %res = call <8 x i64> @llvm.x86.avx512.mask.pmull.q.512(<8 x i64> %a, <8 x i64> %b, <8 x i64> zeroinitializer, i8 %mask)
  ret <8 x i64> %res
}
declare <8 x i64> @llvm.x86.avx512.mask.pmull.q.512(<8 x i64>, <8 x i64>, <8 x i64>, i8)

define <4 x i64> @test_mask_mullo_epi64_rr_256(<4 x i64> %a, <4 x i64> %b) {
  ;CHECK-LABEL: test_mask_mullo_epi64_rr_256
  ;CHECK: vpmullq %ymm1, %ymm0, %ymm0     ## encoding: [0x62,0xf2,0xfd,0x28,0x40,0xc1]
  %res = call <4 x i64> @llvm.x86.avx512.mask.pmull.q.256(<4 x i64> %a, <4 x i64> %b, <4 x i64> zeroinitializer, i8 -1)
  ret <4 x i64> %res
}

define <4 x i64> @test_mask_mullo_epi64_rrk_256(<4 x i64> %a, <4 x i64> %b, <4 x i64> %passThru, i8 %mask) {
  ;CHECK-LABEL: test_mask_mullo_epi64_rrk_256
  ;CHECK: vpmullq %ymm1, %ymm0, %ymm2 {%k1} ## encoding: [0x62,0xf2,0xfd,0x29,0x40,0xd1]
  %res = call <4 x i64> @llvm.x86.avx512.mask.pmull.q.256(<4 x i64> %a, <4 x i64> %b, <4 x i64> %passThru, i8 %mask)
  ret <4 x i64> %res
}

define <4 x i64> @test_mask_mullo_epi64_rrkz_256(<4 x i64> %a, <4 x i64> %b, i8 %mask) {
  ;CHECK-LABEL: test_mask_mullo_epi64_rrkz_256
  ;CHECK: vpmullq %ymm1, %ymm0, %ymm0 {%k1} {z} ## encoding: [0x62,0xf2,0xfd,0xa9,0x40,0xc1]
  %res = call <4 x i64> @llvm.x86.avx512.mask.pmull.q.256(<4 x i64> %a, <4 x i64> %b, <4 x i64> zeroinitializer, i8 %mask)
  ret <4 x i64> %res
}

define <4 x i64> @test_mask_mullo_epi64_rm_256(<4 x i64> %a, <4 x i64>* %ptr_b) {
  ;CHECK-LABEL: test_mask_mullo_epi64_rm_256
  ;CHECK: vpmullq (%rdi), %ymm0, %ymm0    ## encoding: [0x62,0xf2,0xfd,0x28,0x40,0x07]
  %b = load <4 x i64>, <4 x i64>* %ptr_b
  %res = call <4 x i64> @llvm.x86.avx512.mask.pmull.q.256(<4 x i64> %a, <4 x i64> %b, <4 x i64> zeroinitializer, i8 -1)
  ret <4 x i64> %res
}

define <4 x i64> @test_mask_mullo_epi64_rmk_256(<4 x i64> %a, <4 x i64>* %ptr_b, <4 x i64> %passThru, i8 %mask) {
  ;CHECK-LABEL: test_mask_mullo_epi64_rmk_256
  ;CHECK: vpmullq (%rdi), %ymm0, %ymm1 {%k1} ## encoding: [0x62,0xf2,0xfd,0x29,0x40,0x0f]
  %b = load <4 x i64>, <4 x i64>* %ptr_b
  %res = call <4 x i64> @llvm.x86.avx512.mask.pmull.q.256(<4 x i64> %a, <4 x i64> %b, <4 x i64> %passThru, i8 %mask)
  ret <4 x i64> %res
}

define <4 x i64> @test_mask_mullo_epi64_rmkz_256(<4 x i64> %a, <4 x i64>* %ptr_b, i8 %mask) {
  ;CHECK-LABEL: test_mask_mullo_epi64_rmkz_256
  ;CHECK: vpmullq (%rdi), %ymm0, %ymm0 {%k1} {z} ## encoding: [0x62,0xf2,0xfd,0xa9,0x40,0x07]
  %b = load <4 x i64>, <4 x i64>* %ptr_b
  %res = call <4 x i64> @llvm.x86.avx512.mask.pmull.q.256(<4 x i64> %a, <4 x i64> %b, <4 x i64> zeroinitializer, i8 %mask)
  ret <4 x i64> %res
}

define <4 x i64> @test_mask_mullo_epi64_rmb_256(<4 x i64> %a, i64* %ptr_b) {
  ;CHECK-LABEL: test_mask_mullo_epi64_rmb_256
  ;CHECK: vpmullq (%rdi){1to4}, %ymm0, %ymm0  ## encoding: [0x62,0xf2,0xfd,0x38,0x40,0x07]
  %q = load i64, i64* %ptr_b
  %vecinit.i = insertelement <4 x i64> undef, i64 %q, i32 0
  %b = shufflevector <4 x i64> %vecinit.i, <4 x i64> undef, <4 x i32> zeroinitializer
  %res = call <4 x i64> @llvm.x86.avx512.mask.pmull.q.256(<4 x i64> %a, <4 x i64> %b, <4 x i64> zeroinitializer, i8 -1)
  ret <4 x i64> %res
}

define <4 x i64> @test_mask_mullo_epi64_rmbk_256(<4 x i64> %a, i64* %ptr_b, <4 x i64> %passThru, i8 %mask) {
  ;CHECK-LABEL: test_mask_mullo_epi64_rmbk_256
  ;CHECK: vpmullq (%rdi){1to4}, %ymm0, %ymm1 {%k1} ## encoding: [0x62,0xf2,0xfd,0x39,0x40,0x0f]
  %q = load i64, i64* %ptr_b
  %vecinit.i = insertelement <4 x i64> undef, i64 %q, i32 0
  %b = shufflevector <4 x i64> %vecinit.i, <4 x i64> undef, <4 x i32> zeroinitializer
  %res = call <4 x i64> @llvm.x86.avx512.mask.pmull.q.256(<4 x i64> %a, <4 x i64> %b, <4 x i64> %passThru, i8 %mask)
  ret <4 x i64> %res
}

define <4 x i64> @test_mask_mullo_epi64_rmbkz_256(<4 x i64> %a, i64* %ptr_b, i8 %mask) {
  ;CHECK-LABEL: test_mask_mullo_epi64_rmbkz_256
  ;CHECK: vpmullq (%rdi){1to4}, %ymm0, %ymm0 {%k1} {z} ## encoding: [0x62,0xf2,0xfd,0xb9,0x40,0x07]
  %q = load i64, i64* %ptr_b
  %vecinit.i = insertelement <4 x i64> undef, i64 %q, i32 0
  %b = shufflevector <4 x i64> %vecinit.i, <4 x i64> undef, <4 x i32> zeroinitializer
  %res = call <4 x i64> @llvm.x86.avx512.mask.pmull.q.256(<4 x i64> %a, <4 x i64> %b, <4 x i64> zeroinitializer, i8 %mask)
  ret <4 x i64> %res
}

declare <4 x i64> @llvm.x86.avx512.mask.pmull.q.256(<4 x i64>, <4 x i64>, <4 x i64>, i8)

define <2 x i64> @test_mask_mullo_epi64_rr_128(<2 x i64> %a, <2 x i64> %b) {
  ;CHECK-LABEL: test_mask_mullo_epi64_rr_128
  ;CHECK: vpmullq %xmm1, %xmm0, %xmm0     ## encoding: [0x62,0xf2,0xfd,0x08,0x40,0xc1]
  %res = call <2 x i64> @llvm.x86.avx512.mask.pmull.q.128(<2 x i64> %a, <2 x i64> %b, <2 x i64> zeroinitializer, i8 -1)
  ret <2 x i64> %res
}

define <2 x i64> @test_mask_mullo_epi64_rrk_128(<2 x i64> %a, <2 x i64> %b, <2 x i64> %passThru, i8 %mask) {
  ;CHECK-LABEL: test_mask_mullo_epi64_rrk_128
  ;CHECK: vpmullq %xmm1, %xmm0, %xmm2 {%k1} ## encoding: [0x62,0xf2,0xfd,0x09,0x40,0xd1]
  %res = call <2 x i64> @llvm.x86.avx512.mask.pmull.q.128(<2 x i64> %a, <2 x i64> %b, <2 x i64> %passThru, i8 %mask)
  ret <2 x i64> %res
}

define <2 x i64> @test_mask_mullo_epi64_rrkz_128(<2 x i64> %a, <2 x i64> %b, i8 %mask) {
  ;CHECK-LABEL: test_mask_mullo_epi64_rrkz_128
  ;CHECK: vpmullq %xmm1, %xmm0, %xmm0 {%k1} {z} ## encoding: [0x62,0xf2,0xfd,0x89,0x40,0xc1]
  %res = call <2 x i64> @llvm.x86.avx512.mask.pmull.q.128(<2 x i64> %a, <2 x i64> %b, <2 x i64> zeroinitializer, i8 %mask)
  ret <2 x i64> %res
}

define <2 x i64> @test_mask_mullo_epi64_rm_128(<2 x i64> %a, <2 x i64>* %ptr_b) {
  ;CHECK-LABEL: test_mask_mullo_epi64_rm_128
  ;CHECK: vpmullq (%rdi), %xmm0, %xmm0    ## encoding: [0x62,0xf2,0xfd,0x08,0x40,0x07]
  %b = load <2 x i64>, <2 x i64>* %ptr_b
  %res = call <2 x i64> @llvm.x86.avx512.mask.pmull.q.128(<2 x i64> %a, <2 x i64> %b, <2 x i64> zeroinitializer, i8 -1)
  ret <2 x i64> %res
}

define <2 x i64> @test_mask_mullo_epi64_rmk_128(<2 x i64> %a, <2 x i64>* %ptr_b, <2 x i64> %passThru, i8 %mask) {
  ;CHECK-LABEL: test_mask_mullo_epi64_rmk_128
  ;CHECK: vpmullq (%rdi), %xmm0, %xmm1 {%k1} ## encoding: [0x62,0xf2,0xfd,0x09,0x40,0x0f]
  %b = load <2 x i64>, <2 x i64>* %ptr_b
  %res = call <2 x i64> @llvm.x86.avx512.mask.pmull.q.128(<2 x i64> %a, <2 x i64> %b, <2 x i64> %passThru, i8 %mask)
  ret <2 x i64> %res
}

define <2 x i64> @test_mask_mullo_epi64_rmkz_128(<2 x i64> %a, <2 x i64>* %ptr_b, i8 %mask) {
  ;CHECK-LABEL: test_mask_mullo_epi64_rmkz_128
  ;CHECK: vpmullq (%rdi), %xmm0, %xmm0 {%k1} {z} ## encoding: [0x62,0xf2,0xfd,0x89,0x40,0x07]
  %b = load <2 x i64>, <2 x i64>* %ptr_b
  %res = call <2 x i64> @llvm.x86.avx512.mask.pmull.q.128(<2 x i64> %a, <2 x i64> %b, <2 x i64> zeroinitializer, i8 %mask)
  ret <2 x i64> %res
}

define <2 x i64> @test_mask_mullo_epi64_rmb_128(<2 x i64> %a, i64* %ptr_b) {
  ;CHECK-LABEL: test_mask_mullo_epi64_rmb_128
  ;CHECK: vpmullq (%rdi){1to2}, %xmm0, %xmm0  ## encoding: [0x62,0xf2,0xfd,0x18,0x40,0x07]
  %q = load i64, i64* %ptr_b
  %vecinit.i = insertelement <2 x i64> undef, i64 %q, i32 0
  %b = shufflevector <2 x i64> %vecinit.i, <2 x i64> undef, <2 x i32> zeroinitializer
  %res = call <2 x i64> @llvm.x86.avx512.mask.pmull.q.128(<2 x i64> %a, <2 x i64> %b, <2 x i64> zeroinitializer, i8 -1)
  ret <2 x i64> %res
}

define <2 x i64> @test_mask_mullo_epi64_rmbk_128(<2 x i64> %a, i64* %ptr_b, <2 x i64> %passThru, i8 %mask) {
  ;CHECK-LABEL: test_mask_mullo_epi64_rmbk_128
  ;CHECK: vpmullq (%rdi){1to2}, %xmm0, %xmm1 {%k1} ## encoding: [0x62,0xf2,0xfd,0x19,0x40,0x0f]
  %q = load i64, i64* %ptr_b
  %vecinit.i = insertelement <2 x i64> undef, i64 %q, i32 0
  %b = shufflevector <2 x i64> %vecinit.i, <2 x i64> undef, <2 x i32> zeroinitializer
  %res = call <2 x i64> @llvm.x86.avx512.mask.pmull.q.128(<2 x i64> %a, <2 x i64> %b, <2 x i64> %passThru, i8 %mask)
  ret <2 x i64> %res
}

define <2 x i64> @test_mask_mullo_epi64_rmbkz_128(<2 x i64> %a, i64* %ptr_b, i8 %mask) {
  ;CHECK-LABEL: test_mask_mullo_epi64_rmbkz_128
  ;CHECK: vpmullq (%rdi){1to2}, %xmm0, %xmm0 {%k1} {z} ## encoding: [0x62,0xf2,0xfd,0x99,0x40,0x07]
  %q = load i64, i64* %ptr_b
  %vecinit.i = insertelement <2 x i64> undef, i64 %q, i32 0
  %b = shufflevector <2 x i64> %vecinit.i, <2 x i64> undef, <2 x i32> zeroinitializer
  %res = call <2 x i64> @llvm.x86.avx512.mask.pmull.q.128(<2 x i64> %a, <2 x i64> %b, <2 x i64> zeroinitializer, i8 %mask)
  ret <2 x i64> %res
}

declare <2 x i64> @llvm.x86.avx512.mask.pmull.q.128(<2 x i64>, <2 x i64>, <2 x i64>, i8)

define <4 x float> @test_mask_andnot_ps_rr_128(<4 x float> %a, <4 x float> %b) {
  ;CHECK-LABEL: test_mask_andnot_ps_rr_128
  ;CHECK: vandnps %xmm1, %xmm0, %xmm0     ## encoding: [0x62,0xf1,0x7c,0x08,0x55,0xc1]
  %res = call <4 x float> @llvm.x86.avx512.mask.andn.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> zeroinitializer, i8 -1)
  ret <4 x float> %res
}

define <4 x float> @test_mask_andnot_ps_rrk_128(<4 x float> %a, <4 x float> %b, <4 x float> %passThru, i8 %mask) {
  ;CHECK-LABEL: test_mask_andnot_ps_rrk_128
  ;CHECK: vandnps %xmm1, %xmm0, %xmm2 {%k1} ## encoding: [0x62,0xf1,0x7c,0x09,0x55,0xd1]
  %res = call <4 x float> @llvm.x86.avx512.mask.andn.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> %passThru, i8 %mask)
  ret <4 x float> %res
}

define <4 x float> @test_mask_andnot_ps_rrkz_128(<4 x float> %a, <4 x float> %b, i8 %mask) {
  ;CHECK-LABEL: test_mask_andnot_ps_rrkz_128
  ;CHECK: vandnps %xmm1, %xmm0, %xmm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0x89,0x55,0xc1]
  %res = call <4 x float> @llvm.x86.avx512.mask.andn.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> zeroinitializer, i8 %mask)
  ret <4 x float> %res
}

define <4 x float> @test_mask_andnot_ps_rm_128(<4 x float> %a, <4 x float>* %ptr_b) {
  ;CHECK-LABEL: test_mask_andnot_ps_rm_128
  ;CHECK: vandnps (%rdi), %xmm0, %xmm0    ## encoding: [0x62,0xf1,0x7c,0x08,0x55,0x07]
  %b = load <4 x float>, <4 x float>* %ptr_b
  %res = call <4 x float> @llvm.x86.avx512.mask.andn.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> zeroinitializer, i8 -1)
  ret <4 x float> %res
}

define <4 x float> @test_mask_andnot_ps_rmk_128(<4 x float> %a, <4 x float>* %ptr_b, <4 x float> %passThru, i8 %mask) {
  ;CHECK-LABEL: test_mask_andnot_ps_rmk_128
  ;CHECK: vandnps (%rdi), %xmm0, %xmm1 {%k1} ## encoding: [0x62,0xf1,0x7c,0x09,0x55,0x0f]
  %b = load <4 x float>, <4 x float>* %ptr_b
  %res = call <4 x float> @llvm.x86.avx512.mask.andn.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> %passThru, i8 %mask)
  ret <4 x float> %res
}

define <4 x float> @test_mask_andnot_ps_rmkz_128(<4 x float> %a, <4 x float>* %ptr_b, i8 %mask) {
  ;CHECK-LABEL: test_mask_andnot_ps_rmkz_128
  ;CHECK: vandnps (%rdi), %xmm0, %xmm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0x89,0x55,0x07]
  %b = load <4 x float>, <4 x float>* %ptr_b
  %res = call <4 x float> @llvm.x86.avx512.mask.andn.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> zeroinitializer, i8 %mask)
  ret <4 x float> %res
}

define <4 x float> @test_mask_andnot_ps_rmb_128(<4 x float> %a, float* %ptr_b) {
  ;CHECK-LABEL: test_mask_andnot_ps_rmb_128
  ;CHECK: vandnps (%rdi){1to4}, %xmm0, %xmm0  ## encoding: [0x62,0xf1,0x7c,0x18,0x55,0x07]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <4 x float> undef, float %q, i32 0
  %b = shufflevector <4 x float> %vecinit.i, <4 x float> undef, <4 x i32> zeroinitializer
  %res = call <4 x float> @llvm.x86.avx512.mask.andn.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> zeroinitializer, i8 -1)
  ret <4 x float> %res
}

define <4 x float> @test_mask_andnot_ps_rmbk_128(<4 x float> %a, float* %ptr_b, <4 x float> %passThru, i8 %mask) {
  ;CHECK-LABEL: test_mask_andnot_ps_rmbk_128
  ;CHECK: vandnps (%rdi){1to4}, %xmm0, %xmm1 {%k1} ## encoding: [0x62,0xf1,0x7c,0x19,0x55,0x0f]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <4 x float> undef, float %q, i32 0
  %b = shufflevector <4 x float> %vecinit.i, <4 x float> undef, <4 x i32> zeroinitializer
  %res = call <4 x float> @llvm.x86.avx512.mask.andn.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> %passThru, i8 %mask)
  ret <4 x float> %res
}

define <4 x float> @test_mask_andnot_ps_rmbkz_128(<4 x float> %a, float* %ptr_b, i8 %mask) {
  ;CHECK-LABEL: test_mask_andnot_ps_rmbkz_128
  ;CHECK: vandnps (%rdi){1to4}, %xmm0, %xmm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0x99,0x55,0x07]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <4 x float> undef, float %q, i32 0
  %b = shufflevector <4 x float> %vecinit.i, <4 x float> undef, <4 x i32> zeroinitializer
  %res = call <4 x float> @llvm.x86.avx512.mask.andn.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> zeroinitializer, i8 %mask)
  ret <4 x float> %res
}

declare <4 x float> @llvm.x86.avx512.mask.andn.ps.128(<4 x float>, <4 x float>, <4 x float>, i8)

define <8 x float> @test_mask_andnot_ps_rr_256(<8 x float> %a, <8 x float> %b) {
  ;CHECK-LABEL: test_mask_andnot_ps_rr_256
  ;CHECK: vandnps %ymm1, %ymm0, %ymm0     ## encoding: [0x62,0xf1,0x7c,0x28,0x55,0xc1]
  %res = call <8 x float> @llvm.x86.avx512.mask.andn.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> zeroinitializer, i8 -1)
  ret <8 x float> %res
}

define <8 x float> @test_mask_andnot_ps_rrk_256(<8 x float> %a, <8 x float> %b, <8 x float> %passThru, i8 %mask) {
  ;CHECK-LABEL: test_mask_andnot_ps_rrk_256
  ;CHECK: vandnps %ymm1, %ymm0, %ymm2 {%k1} ## encoding: [0x62,0xf1,0x7c,0x29,0x55,0xd1]
  %res = call <8 x float> @llvm.x86.avx512.mask.andn.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> %passThru, i8 %mask)
  ret <8 x float> %res
}

define <8 x float> @test_mask_andnot_ps_rrkz_256(<8 x float> %a, <8 x float> %b, i8 %mask) {
  ;CHECK-LABEL: test_mask_andnot_ps_rrkz_256
  ;CHECK: vandnps %ymm1, %ymm0, %ymm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0xa9,0x55,0xc1]
  %res = call <8 x float> @llvm.x86.avx512.mask.andn.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> zeroinitializer, i8 %mask)
  ret <8 x float> %res
}

define <8 x float> @test_mask_andnot_ps_rm_256(<8 x float> %a, <8 x float>* %ptr_b) {
  ;CHECK-LABEL: test_mask_andnot_ps_rm_256
  ;CHECK: vandnps (%rdi), %ymm0, %ymm0    ## encoding: [0x62,0xf1,0x7c,0x28,0x55,0x07]
  %b = load <8 x float>, <8 x float>* %ptr_b
  %res = call <8 x float> @llvm.x86.avx512.mask.andn.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> zeroinitializer, i8 -1)
  ret <8 x float> %res
}

define <8 x float> @test_mask_andnot_ps_rmk_256(<8 x float> %a, <8 x float>* %ptr_b, <8 x float> %passThru, i8 %mask) {
  ;CHECK-LABEL: test_mask_andnot_ps_rmk_256
  ;CHECK: vandnps (%rdi), %ymm0, %ymm1 {%k1} ## encoding: [0x62,0xf1,0x7c,0x29,0x55,0x0f]
  %b = load <8 x float>, <8 x float>* %ptr_b
  %res = call <8 x float> @llvm.x86.avx512.mask.andn.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> %passThru, i8 %mask)
  ret <8 x float> %res
}

define <8 x float> @test_mask_andnot_ps_rmkz_256(<8 x float> %a, <8 x float>* %ptr_b, i8 %mask) {
  ;CHECK-LABEL: test_mask_andnot_ps_rmkz_256
  ;CHECK: vandnps (%rdi), %ymm0, %ymm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0xa9,0x55,0x07]
  %b = load <8 x float>, <8 x float>* %ptr_b
  %res = call <8 x float> @llvm.x86.avx512.mask.andn.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> zeroinitializer, i8 %mask)
  ret <8 x float> %res
}

define <8 x float> @test_mask_andnot_ps_rmb_256(<8 x float> %a, float* %ptr_b) {
  ;CHECK-LABEL: test_mask_andnot_ps_rmb_256
  ;CHECK: vandnps (%rdi){1to8}, %ymm0, %ymm0  ## encoding: [0x62,0xf1,0x7c,0x38,0x55,0x07]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <8 x float> undef, float %q, i32 0
  %b = shufflevector <8 x float> %vecinit.i, <8 x float> undef, <8 x i32> zeroinitializer
  %res = call <8 x float> @llvm.x86.avx512.mask.andn.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> zeroinitializer, i8 -1)
  ret <8 x float> %res
}

define <8 x float> @test_mask_andnot_ps_rmbk_256(<8 x float> %a, float* %ptr_b, <8 x float> %passThru, i8 %mask) {
  ;CHECK-LABEL: test_mask_andnot_ps_rmbk_256
  ;CHECK: vandnps (%rdi){1to8}, %ymm0, %ymm1 {%k1} ## encoding: [0x62,0xf1,0x7c,0x39,0x55,0x0f]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <8 x float> undef, float %q, i32 0
  %b = shufflevector <8 x float> %vecinit.i, <8 x float> undef, <8 x i32> zeroinitializer
  %res = call <8 x float> @llvm.x86.avx512.mask.andn.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> %passThru, i8 %mask)
  ret <8 x float> %res
}

define <8 x float> @test_mask_andnot_ps_rmbkz_256(<8 x float> %a, float* %ptr_b, i8 %mask) {
  ;CHECK-LABEL: test_mask_andnot_ps_rmbkz_256
  ;CHECK: vandnps (%rdi){1to8}, %ymm0, %ymm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0xb9,0x55,0x07]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <8 x float> undef, float %q, i32 0
  %b = shufflevector <8 x float> %vecinit.i, <8 x float> undef, <8 x i32> zeroinitializer
  %res = call <8 x float> @llvm.x86.avx512.mask.andn.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> zeroinitializer, i8 %mask)
  ret <8 x float> %res
}

declare <8 x float> @llvm.x86.avx512.mask.andn.ps.256(<8 x float>, <8 x float>, <8 x float>, i8)

define <16 x float> @test_mask_andnot_ps_rr_512(<16 x float> %a, <16 x float> %b) {
  ;CHECK-LABEL: test_mask_andnot_ps_rr_512
  ;CHECK: vandnps %zmm1, %zmm0, %zmm0     ## encoding: [0x62,0xf1,0x7c,0x48,0x55,0xc1]
  %res = call <16 x float> @llvm.x86.avx512.mask.andn.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> zeroinitializer, i16 -1)
  ret <16 x float> %res
}

define <16 x float> @test_mask_andnot_ps_rrk_512(<16 x float> %a, <16 x float> %b, <16 x float> %passThru, i16 %mask) {
  ;CHECK-LABEL: test_mask_andnot_ps_rrk_512
  ;CHECK: vandnps %zmm1, %zmm0, %zmm2 {%k1} ## encoding: [0x62,0xf1,0x7c,0x49,0x55,0xd1]
  %res = call <16 x float> @llvm.x86.avx512.mask.andn.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> %passThru, i16 %mask)
  ret <16 x float> %res
}

define <16 x float> @test_mask_andnot_ps_rrkz_512(<16 x float> %a, <16 x float> %b, i16 %mask) {
  ;CHECK-LABEL: test_mask_andnot_ps_rrkz_512
  ;CHECK: vandnps %zmm1, %zmm0, %zmm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0xc9,0x55,0xc1]
  %res = call <16 x float> @llvm.x86.avx512.mask.andn.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> zeroinitializer, i16 %mask)
  ret <16 x float> %res
}

define <16 x float> @test_mask_andnot_ps_rm_512(<16 x float> %a, <16 x float>* %ptr_b) {
  ;CHECK-LABEL: test_mask_andnot_ps_rm_512
  ;CHECK: vandnps (%rdi), %zmm0, %zmm0    ## encoding: [0x62,0xf1,0x7c,0x48,0x55,0x07]
  %b = load <16 x float>, <16 x float>* %ptr_b
  %res = call <16 x float> @llvm.x86.avx512.mask.andn.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> zeroinitializer, i16 -1)
  ret <16 x float> %res
}

define <16 x float> @test_mask_andnot_ps_rmk_512(<16 x float> %a, <16 x float>* %ptr_b, <16 x float> %passThru, i16 %mask) {
  ;CHECK-LABEL: test_mask_andnot_ps_rmk_512
  ;CHECK: vandnps (%rdi), %zmm0, %zmm1 {%k1} ## encoding: [0x62,0xf1,0x7c,0x49,0x55,0x0f]
  %b = load <16 x float>, <16 x float>* %ptr_b
  %res = call <16 x float> @llvm.x86.avx512.mask.andn.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> %passThru, i16 %mask)
  ret <16 x float> %res
}

define <16 x float> @test_mask_andnot_ps_rmkz_512(<16 x float> %a, <16 x float>* %ptr_b, i16 %mask) {
  ;CHECK-LABEL: test_mask_andnot_ps_rmkz_512
  ;CHECK: vandnps (%rdi), %zmm0, %zmm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0xc9,0x55,0x07]
  %b = load <16 x float>, <16 x float>* %ptr_b
  %res = call <16 x float> @llvm.x86.avx512.mask.andn.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> zeroinitializer, i16 %mask)
  ret <16 x float> %res
}

define <16 x float> @test_mask_andnot_ps_rmb_512(<16 x float> %a, float* %ptr_b) {
  ;CHECK-LABEL: test_mask_andnot_ps_rmb_512
  ;CHECK: vandnps (%rdi){1to16}, %zmm0, %zmm0  ## encoding: [0x62,0xf1,0x7c,0x58,0x55,0x07]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <16 x float> undef, float %q, i32 0
  %b = shufflevector <16 x float> %vecinit.i, <16 x float> undef, <16 x i32> zeroinitializer
  %res = call <16 x float> @llvm.x86.avx512.mask.andn.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> zeroinitializer, i16 -1)
  ret <16 x float> %res
}

define <16 x float> @test_mask_andnot_ps_rmbk_512(<16 x float> %a, float* %ptr_b, <16 x float> %passThru, i16 %mask) {
  ;CHECK-LABEL: test_mask_andnot_ps_rmbk_512
  ;CHECK: vandnps (%rdi){1to16}, %zmm0, %zmm1 {%k1} ## encoding: [0x62,0xf1,0x7c,0x59,0x55,0x0f]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <16 x float> undef, float %q, i32 0
  %b = shufflevector <16 x float> %vecinit.i, <16 x float> undef, <16 x i32> zeroinitializer
  %res = call <16 x float> @llvm.x86.avx512.mask.andn.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> %passThru, i16 %mask)
  ret <16 x float> %res
}

define <16 x float> @test_mask_andnot_ps_rmbkz_512(<16 x float> %a, float* %ptr_b, i16 %mask) {
  ;CHECK-LABEL: test_mask_andnot_ps_rmbkz_512
  ;CHECK: vandnps (%rdi){1to16}, %zmm0, %zmm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0xd9,0x55,0x07]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <16 x float> undef, float %q, i32 0
  %b = shufflevector <16 x float> %vecinit.i, <16 x float> undef, <16 x i32> zeroinitializer
  %res = call <16 x float> @llvm.x86.avx512.mask.andn.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> zeroinitializer, i16 %mask)
  ret <16 x float> %res
}

declare <16 x float> @llvm.x86.avx512.mask.andn.ps.512(<16 x float>, <16 x float>, <16 x float>, i16)

define <4 x float> @test_mask_and_ps_rr_128(<4 x float> %a, <4 x float> %b) {
  ;CHECK-LABEL: test_mask_and_ps_rr_128
  ;CHECK: vandps  %xmm1, %xmm0, %xmm0     ## encoding: [0x62,0xf1,0x7c,0x08,0x54,0xc1]
  %res = call <4 x float> @llvm.x86.avx512.mask.and.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> zeroinitializer, i8 -1)
  ret <4 x float> %res
}

define <4 x float> @test_mask_and_ps_rrk_128(<4 x float> %a, <4 x float> %b, <4 x float> %passThru, i8 %mask) {
  ;CHECK-LABEL: test_mask_and_ps_rrk_128
  ;CHECK: vandps %xmm1, %xmm0, %xmm2 {%k1} ## encoding: [0x62,0xf1,0x7c,0x09,0x54,0xd1]
  %res = call <4 x float> @llvm.x86.avx512.mask.and.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> %passThru, i8 %mask)
  ret <4 x float> %res
}

define <4 x float> @test_mask_and_ps_rrkz_128(<4 x float> %a, <4 x float> %b, i8 %mask) {
  ;CHECK-LABEL: test_mask_and_ps_rrkz_128
  ;CHECK: vandps %xmm1, %xmm0, %xmm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0x89,0x54,0xc1]
  %res = call <4 x float> @llvm.x86.avx512.mask.and.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> zeroinitializer, i8 %mask)
  ret <4 x float> %res
}

define <4 x float> @test_mask_and_ps_rm_128(<4 x float> %a, <4 x float>* %ptr_b) {
  ;CHECK-LABEL: test_mask_and_ps_rm_128
  ;CHECK: vandps (%rdi), %xmm0, %xmm0    ## encoding: [0x62,0xf1,0x7c,0x08,0x54,0x07]
  %b = load <4 x float>, <4 x float>* %ptr_b
  %res = call <4 x float> @llvm.x86.avx512.mask.and.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> zeroinitializer, i8 -1)
  ret <4 x float> %res
}

define <4 x float> @test_mask_and_ps_rmk_128(<4 x float> %a, <4 x float>* %ptr_b, <4 x float> %passThru, i8 %mask) {
  ;CHECK-LABEL: test_mask_and_ps_rmk_128
  ;CHECK: vandps (%rdi), %xmm0, %xmm1 {%k1} ## encoding: [0x62,0xf1,0x7c,0x09,0x54,0x0f]
  %b = load <4 x float>, <4 x float>* %ptr_b
  %res = call <4 x float> @llvm.x86.avx512.mask.and.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> %passThru, i8 %mask)
  ret <4 x float> %res
}

define <4 x float> @test_mask_and_ps_rmkz_128(<4 x float> %a, <4 x float>* %ptr_b, i8 %mask) {
  ;CHECK-LABEL: test_mask_and_ps_rmkz_128
  ;CHECK: vandps (%rdi), %xmm0, %xmm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0x89,0x54,0x07]
  %b = load <4 x float>, <4 x float>* %ptr_b
  %res = call <4 x float> @llvm.x86.avx512.mask.and.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> zeroinitializer, i8 %mask)
  ret <4 x float> %res
}

define <4 x float> @test_mask_and_ps_rmb_128(<4 x float> %a, float* %ptr_b) {
  ;CHECK-LABEL: test_mask_and_ps_rmb_128
  ;CHECK: vandps (%rdi){1to4}, %xmm0, %xmm0  ## encoding: [0x62,0xf1,0x7c,0x18,0x54,0x07]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <4 x float> undef, float %q, i32 0
  %b = shufflevector <4 x float> %vecinit.i, <4 x float> undef, <4 x i32> zeroinitializer
  %res = call <4 x float> @llvm.x86.avx512.mask.and.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> zeroinitializer, i8 -1)
  ret <4 x float> %res
}

define <4 x float> @test_mask_and_ps_rmbk_128(<4 x float> %a, float* %ptr_b, <4 x float> %passThru, i8 %mask) {
  ;CHECK-LABEL: test_mask_and_ps_rmbk_128
  ;CHECK: vandps (%rdi){1to4}, %xmm0, %xmm1 {%k1} ## encoding: [0x62,0xf1,0x7c,0x19,0x54,0x0f]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <4 x float> undef, float %q, i32 0
  %b = shufflevector <4 x float> %vecinit.i, <4 x float> undef, <4 x i32> zeroinitializer
  %res = call <4 x float> @llvm.x86.avx512.mask.and.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> %passThru, i8 %mask)
  ret <4 x float> %res
}

define <4 x float> @test_mask_and_ps_rmbkz_128(<4 x float> %a, float* %ptr_b, i8 %mask) {
  ;CHECK-LABEL: test_mask_and_ps_rmbkz_128
  ;CHECK: vandps (%rdi){1to4}, %xmm0, %xmm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0x99,0x54,0x07]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <4 x float> undef, float %q, i32 0
  %b = shufflevector <4 x float> %vecinit.i, <4 x float> undef, <4 x i32> zeroinitializer
  %res = call <4 x float> @llvm.x86.avx512.mask.and.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> zeroinitializer, i8 %mask)
  ret <4 x float> %res
}

declare <4 x float> @llvm.x86.avx512.mask.and.ps.128(<4 x float>, <4 x float>, <4 x float>, i8)

define <8 x float> @test_mask_and_ps_rr_256(<8 x float> %a, <8 x float> %b) {
  ;CHECK-LABEL: test_mask_and_ps_rr_256
  ;CHECK: vandps %ymm1, %ymm0, %ymm0     ## encoding: [0x62,0xf1,0x7c,0x28,0x54,0xc1]
  %res = call <8 x float> @llvm.x86.avx512.mask.and.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> zeroinitializer, i8 -1)
  ret <8 x float> %res
}

define <8 x float> @test_mask_and_ps_rrk_256(<8 x float> %a, <8 x float> %b, <8 x float> %passThru, i8 %mask) {
  ;CHECK-LABEL: test_mask_and_ps_rrk_256
  ;CHECK: vandps %ymm1, %ymm0, %ymm2 {%k1} ## encoding: [0x62,0xf1,0x7c,0x29,0x54,0xd1]
  %res = call <8 x float> @llvm.x86.avx512.mask.and.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> %passThru, i8 %mask)
  ret <8 x float> %res
}

define <8 x float> @test_mask_and_ps_rrkz_256(<8 x float> %a, <8 x float> %b, i8 %mask) {
  ;CHECK-LABEL: test_mask_and_ps_rrkz_256
  ;CHECK: vandps %ymm1, %ymm0, %ymm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0xa9,0x54,0xc1]
  %res = call <8 x float> @llvm.x86.avx512.mask.and.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> zeroinitializer, i8 %mask)
  ret <8 x float> %res
}

define <8 x float> @test_mask_and_ps_rm_256(<8 x float> %a, <8 x float>* %ptr_b) {
  ;CHECK-LABEL: test_mask_and_ps_rm_256
  ;CHECK: vandps (%rdi), %ymm0, %ymm0    ## encoding: [0x62,0xf1,0x7c,0x28,0x54,0x07]
  %b = load <8 x float>, <8 x float>* %ptr_b
  %res = call <8 x float> @llvm.x86.avx512.mask.and.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> zeroinitializer, i8 -1)
  ret <8 x float> %res
}

define <8 x float> @test_mask_and_ps_rmk_256(<8 x float> %a, <8 x float>* %ptr_b, <8 x float> %passThru, i8 %mask) {
  ;CHECK-LABEL: test_mask_and_ps_rmk_256
  ;CHECK: vandps (%rdi), %ymm0, %ymm1 {%k1} ## encoding: [0x62,0xf1,0x7c,0x29,0x54,0x0f]
  %b = load <8 x float>, <8 x float>* %ptr_b
  %res = call <8 x float> @llvm.x86.avx512.mask.and.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> %passThru, i8 %mask)
  ret <8 x float> %res
}

define <8 x float> @test_mask_and_ps_rmkz_256(<8 x float> %a, <8 x float>* %ptr_b, i8 %mask) {
  ;CHECK-LABEL: test_mask_and_ps_rmkz_256
  ;CHECK: vandps (%rdi), %ymm0, %ymm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0xa9,0x54,0x07]
  %b = load <8 x float>, <8 x float>* %ptr_b
  %res = call <8 x float> @llvm.x86.avx512.mask.and.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> zeroinitializer, i8 %mask)
  ret <8 x float> %res
}

define <8 x float> @test_mask_and_ps_rmb_256(<8 x float> %a, float* %ptr_b) {
  ;CHECK-LABEL: test_mask_and_ps_rmb_256
  ;CHECK: vandps (%rdi){1to8}, %ymm0, %ymm0  ## encoding: [0x62,0xf1,0x7c,0x38,0x54,0x07]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <8 x float> undef, float %q, i32 0
  %b = shufflevector <8 x float> %vecinit.i, <8 x float> undef, <8 x i32> zeroinitializer
  %res = call <8 x float> @llvm.x86.avx512.mask.and.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> zeroinitializer, i8 -1)
  ret <8 x float> %res
}

define <8 x float> @test_mask_and_ps_rmbk_256(<8 x float> %a, float* %ptr_b, <8 x float> %passThru, i8 %mask) {
  ;CHECK-LABEL: test_mask_and_ps_rmbk_256
  ;CHECK: vandps (%rdi){1to8}, %ymm0, %ymm1 {%k1} ## encoding: [0x62,0xf1,0x7c,0x39,0x54,0x0f]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <8 x float> undef, float %q, i32 0
  %b = shufflevector <8 x float> %vecinit.i, <8 x float> undef, <8 x i32> zeroinitializer
  %res = call <8 x float> @llvm.x86.avx512.mask.and.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> %passThru, i8 %mask)
  ret <8 x float> %res
}

define <8 x float> @test_mask_and_ps_rmbkz_256(<8 x float> %a, float* %ptr_b, i8 %mask) {
  ;CHECK-LABEL: test_mask_and_ps_rmbkz_256
  ;CHECK: vandps (%rdi){1to8}, %ymm0, %ymm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0xb9,0x54,0x07]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <8 x float> undef, float %q, i32 0
  %b = shufflevector <8 x float> %vecinit.i, <8 x float> undef, <8 x i32> zeroinitializer
  %res = call <8 x float> @llvm.x86.avx512.mask.and.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> zeroinitializer, i8 %mask)
  ret <8 x float> %res
}

declare <8 x float> @llvm.x86.avx512.mask.and.ps.256(<8 x float>, <8 x float>, <8 x float>, i8)

define <16 x float> @test_mask_and_ps_rr_512(<16 x float> %a, <16 x float> %b) {
  ;CHECK-LABEL: test_mask_and_ps_rr_512
  ;CHECK: vandps %zmm1, %zmm0, %zmm0     ## encoding: [0x62,0xf1,0x7c,0x48,0x54,0xc1]
  %res = call <16 x float> @llvm.x86.avx512.mask.and.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> zeroinitializer, i16 -1)
  ret <16 x float> %res
}

define <16 x float> @test_mask_and_ps_rrk_512(<16 x float> %a, <16 x float> %b, <16 x float> %passThru, i16 %mask) {
  ;CHECK-LABEL: test_mask_and_ps_rrk_512
  ;CHECK: vandps %zmm1, %zmm0, %zmm2 {%k1} ## encoding: [0x62,0xf1,0x7c,0x49,0x54,0xd1]
  %res = call <16 x float> @llvm.x86.avx512.mask.and.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> %passThru, i16 %mask)
  ret <16 x float> %res
}

define <16 x float> @test_mask_and_ps_rrkz_512(<16 x float> %a, <16 x float> %b, i16 %mask) {
  ;CHECK-LABEL: test_mask_and_ps_rrkz_512
  ;CHECK: vandps %zmm1, %zmm0, %zmm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0xc9,0x54,0xc1]
  %res = call <16 x float> @llvm.x86.avx512.mask.and.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> zeroinitializer, i16 %mask)
  ret <16 x float> %res
}

define <16 x float> @test_mask_and_ps_rm_512(<16 x float> %a, <16 x float>* %ptr_b) {
  ;CHECK-LABEL: test_mask_and_ps_rm_512
  ;CHECK: vandps (%rdi), %zmm0, %zmm0    ## encoding: [0x62,0xf1,0x7c,0x48,0x54,0x07]
  %b = load <16 x float>, <16 x float>* %ptr_b
  %res = call <16 x float> @llvm.x86.avx512.mask.and.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> zeroinitializer, i16 -1)
  ret <16 x float> %res
}

define <16 x float> @test_mask_and_ps_rmk_512(<16 x float> %a, <16 x float>* %ptr_b, <16 x float> %passThru, i16 %mask) {
  ;CHECK-LABEL: test_mask_and_ps_rmk_512
  ;CHECK: vandps (%rdi), %zmm0, %zmm1 {%k1} ## encoding: [0x62,0xf1,0x7c,0x49,0x54,0x0f]
  %b = load <16 x float>, <16 x float>* %ptr_b
  %res = call <16 x float> @llvm.x86.avx512.mask.and.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> %passThru, i16 %mask)
  ret <16 x float> %res
}

define <16 x float> @test_mask_and_ps_rmkz_512(<16 x float> %a, <16 x float>* %ptr_b, i16 %mask) {
  ;CHECK-LABEL: test_mask_and_ps_rmkz_512
  ;CHECK: vandps (%rdi), %zmm0, %zmm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0xc9,0x54,0x07]
  %b = load <16 x float>, <16 x float>* %ptr_b
  %res = call <16 x float> @llvm.x86.avx512.mask.and.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> zeroinitializer, i16 %mask)
  ret <16 x float> %res
}

define <16 x float> @test_mask_and_ps_rmb_512(<16 x float> %a, float* %ptr_b) {
  ;CHECK-LABEL: test_mask_and_ps_rmb_512
  ;CHECK: vandps (%rdi){1to16}, %zmm0, %zmm0  ## encoding: [0x62,0xf1,0x7c,0x58,0x54,0x07]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <16 x float> undef, float %q, i32 0
  %b = shufflevector <16 x float> %vecinit.i, <16 x float> undef, <16 x i32> zeroinitializer
  %res = call <16 x float> @llvm.x86.avx512.mask.and.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> zeroinitializer, i16 -1)
  ret <16 x float> %res
}

define <16 x float> @test_mask_and_ps_rmbk_512(<16 x float> %a, float* %ptr_b, <16 x float> %passThru, i16 %mask) {
  ;CHECK-LABEL: test_mask_and_ps_rmbk_512
  ;CHECK: vandps (%rdi){1to16}, %zmm0, %zmm1 {%k1} ## encoding: [0x62,0xf1,0x7c,0x59,0x54,0x0f]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <16 x float> undef, float %q, i32 0
  %b = shufflevector <16 x float> %vecinit.i, <16 x float> undef, <16 x i32> zeroinitializer
  %res = call <16 x float> @llvm.x86.avx512.mask.and.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> %passThru, i16 %mask)
  ret <16 x float> %res
}

define <16 x float> @test_mask_and_ps_rmbkz_512(<16 x float> %a, float* %ptr_b, i16 %mask) {
  ;CHECK-LABEL: test_mask_and_ps_rmbkz_512
  ;CHECK: vandps (%rdi){1to16}, %zmm0, %zmm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0xd9,0x54,0x07]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <16 x float> undef, float %q, i32 0
  %b = shufflevector <16 x float> %vecinit.i, <16 x float> undef, <16 x i32> zeroinitializer
  %res = call <16 x float> @llvm.x86.avx512.mask.and.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> zeroinitializer, i16 %mask)
  ret <16 x float> %res
}

declare <16 x float> @llvm.x86.avx512.mask.and.ps.512(<16 x float>, <16 x float>, <16 x float>, i16)

define <4 x float> @test_mask_or_ps_rr_128(<4 x float> %a, <4 x float> %b) {
  ;CHECK-LABEL: test_mask_or_ps_rr_128
  ;CHECK: vorps  %xmm1, %xmm0, %xmm0     ## encoding: [0x62,0xf1,0x7c,0x08,0x56,0xc1]
  %res = call <4 x float> @llvm.x86.avx512.mask.or.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> zeroinitializer, i8 -1)
  ret <4 x float> %res
}

define <4 x float> @test_mask_or_ps_rrk_128(<4 x float> %a, <4 x float> %b, <4 x float> %passThru, i8 %mask) {
  ;CHECK-LABEL: test_mask_or_ps_rrk_128
  ;CHECK: vorps %xmm1, %xmm0, %xmm2 {%k1} ## encoding: [0x62,0xf1,0x7c,0x09,0x56,0xd1]
  %res = call <4 x float> @llvm.x86.avx512.mask.or.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> %passThru, i8 %mask)
  ret <4 x float> %res
}

define <4 x float> @test_mask_or_ps_rrkz_128(<4 x float> %a, <4 x float> %b, i8 %mask) {
  ;CHECK-LABEL: test_mask_or_ps_rrkz_128
  ;CHECK: vorps %xmm1, %xmm0, %xmm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0x89,0x56,0xc1]
  %res = call <4 x float> @llvm.x86.avx512.mask.or.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> zeroinitializer, i8 %mask)
  ret <4 x float> %res
}

define <4 x float> @test_mask_or_ps_rm_128(<4 x float> %a, <4 x float>* %ptr_b) {
  ;CHECK-LABEL: test_mask_or_ps_rm_128
  ;CHECK: vorps (%rdi), %xmm0, %xmm0    ## encoding: [0x62,0xf1,0x7c,0x08,0x56,0x07]
  %b = load <4 x float>, <4 x float>* %ptr_b
  %res = call <4 x float> @llvm.x86.avx512.mask.or.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> zeroinitializer, i8 -1)
  ret <4 x float> %res
}

define <4 x float> @test_mask_or_ps_rmk_128(<4 x float> %a, <4 x float>* %ptr_b, <4 x float> %passThru, i8 %mask) {
  ;CHECK-LABEL: test_mask_or_ps_rmk_128
  ;CHECK: vorps (%rdi), %xmm0, %xmm1 {%k1} ## encoding: [0x62,0xf1,0x7c,0x09,0x56,0x0f]
  %b = load <4 x float>, <4 x float>* %ptr_b
  %res = call <4 x float> @llvm.x86.avx512.mask.or.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> %passThru, i8 %mask)
  ret <4 x float> %res
}

define <4 x float> @test_mask_or_ps_rmkz_128(<4 x float> %a, <4 x float>* %ptr_b, i8 %mask) {
  ;CHECK-LABEL: test_mask_or_ps_rmkz_128
  ;CHECK: vorps (%rdi), %xmm0, %xmm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0x89,0x56,0x07]
  %b = load <4 x float>, <4 x float>* %ptr_b
  %res = call <4 x float> @llvm.x86.avx512.mask.or.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> zeroinitializer, i8 %mask)
  ret <4 x float> %res
}

define <4 x float> @test_mask_or_ps_rmb_128(<4 x float> %a, float* %ptr_b) {
  ;CHECK-LABEL: test_mask_or_ps_rmb_128
  ;CHECK: vorps (%rdi){1to4}, %xmm0, %xmm0  ## encoding: [0x62,0xf1,0x7c,0x18,0x56,0x07]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <4 x float> undef, float %q, i32 0
  %b = shufflevector <4 x float> %vecinit.i, <4 x float> undef, <4 x i32> zeroinitializer
  %res = call <4 x float> @llvm.x86.avx512.mask.or.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> zeroinitializer, i8 -1)
  ret <4 x float> %res
}

define <4 x float> @test_mask_or_ps_rmbk_128(<4 x float> %a, float* %ptr_b, <4 x float> %passThru, i8 %mask) {
  ;CHECK-LABEL: test_mask_or_ps_rmbk_128
  ;CHECK: vorps (%rdi){1to4}, %xmm0, %xmm1 {%k1} ## encoding: [0x62,0xf1,0x7c,0x19,0x56,0x0f]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <4 x float> undef, float %q, i32 0
  %b = shufflevector <4 x float> %vecinit.i, <4 x float> undef, <4 x i32> zeroinitializer
  %res = call <4 x float> @llvm.x86.avx512.mask.or.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> %passThru, i8 %mask)
  ret <4 x float> %res
}

define <4 x float> @test_mask_or_ps_rmbkz_128(<4 x float> %a, float* %ptr_b, i8 %mask) {
  ;CHECK-LABEL: test_mask_or_ps_rmbkz_128
  ;CHECK: vorps (%rdi){1to4}, %xmm0, %xmm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0x99,0x56,0x07]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <4 x float> undef, float %q, i32 0
  %b = shufflevector <4 x float> %vecinit.i, <4 x float> undef, <4 x i32> zeroinitializer
  %res = call <4 x float> @llvm.x86.avx512.mask.or.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> zeroinitializer, i8 %mask)
  ret <4 x float> %res
}

declare <4 x float> @llvm.x86.avx512.mask.or.ps.128(<4 x float>, <4 x float>, <4 x float>, i8)

define <8 x float> @test_mask_or_ps_rr_256(<8 x float> %a, <8 x float> %b) {
  ;CHECK-LABEL: test_mask_or_ps_rr_256
  ;CHECK: vorps %ymm1, %ymm0, %ymm0     ## encoding: [0x62,0xf1,0x7c,0x28,0x56,0xc1]
  %res = call <8 x float> @llvm.x86.avx512.mask.or.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> zeroinitializer, i8 -1)
  ret <8 x float> %res
}

define <8 x float> @test_mask_or_ps_rrk_256(<8 x float> %a, <8 x float> %b, <8 x float> %passThru, i8 %mask) {
  ;CHECK-LABEL: test_mask_or_ps_rrk_256
  ;CHECK: vorps %ymm1, %ymm0, %ymm2 {%k1} ## encoding: [0x62,0xf1,0x7c,0x29,0x56,0xd1]
  %res = call <8 x float> @llvm.x86.avx512.mask.or.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> %passThru, i8 %mask)
  ret <8 x float> %res
}

define <8 x float> @test_mask_or_ps_rrkz_256(<8 x float> %a, <8 x float> %b, i8 %mask) {
  ;CHECK-LABEL: test_mask_or_ps_rrkz_256
  ;CHECK: vorps %ymm1, %ymm0, %ymm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0xa9,0x56,0xc1]
  %res = call <8 x float> @llvm.x86.avx512.mask.or.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> zeroinitializer, i8 %mask)
  ret <8 x float> %res
}

define <8 x float> @test_mask_or_ps_rm_256(<8 x float> %a, <8 x float>* %ptr_b) {
  ;CHECK-LABEL: test_mask_or_ps_rm_256
  ;CHECK: vorps (%rdi), %ymm0, %ymm0    ## encoding: [0x62,0xf1,0x7c,0x28,0x56,0x07]
  %b = load <8 x float>, <8 x float>* %ptr_b
  %res = call <8 x float> @llvm.x86.avx512.mask.or.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> zeroinitializer, i8 -1)
  ret <8 x float> %res
}

define <8 x float> @test_mask_or_ps_rmk_256(<8 x float> %a, <8 x float>* %ptr_b, <8 x float> %passThru, i8 %mask) {
  ;CHECK-LABEL: test_mask_or_ps_rmk_256
  ;CHECK: vorps (%rdi), %ymm0, %ymm1 {%k1} ## encoding: [0x62,0xf1,0x7c,0x29,0x56,0x0f]
  %b = load <8 x float>, <8 x float>* %ptr_b
  %res = call <8 x float> @llvm.x86.avx512.mask.or.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> %passThru, i8 %mask)
  ret <8 x float> %res
}

define <8 x float> @test_mask_or_ps_rmkz_256(<8 x float> %a, <8 x float>* %ptr_b, i8 %mask) {
  ;CHECK-LABEL: test_mask_or_ps_rmkz_256
  ;CHECK: vorps (%rdi), %ymm0, %ymm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0xa9,0x56,0x07]
  %b = load <8 x float>, <8 x float>* %ptr_b
  %res = call <8 x float> @llvm.x86.avx512.mask.or.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> zeroinitializer, i8 %mask)
  ret <8 x float> %res
}

define <8 x float> @test_mask_or_ps_rmb_256(<8 x float> %a, float* %ptr_b) {
  ;CHECK-LABEL: test_mask_or_ps_rmb_256
  ;CHECK: vorps (%rdi){1to8}, %ymm0, %ymm0  ## encoding: [0x62,0xf1,0x7c,0x38,0x56,0x07]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <8 x float> undef, float %q, i32 0
  %b = shufflevector <8 x float> %vecinit.i, <8 x float> undef, <8 x i32> zeroinitializer
  %res = call <8 x float> @llvm.x86.avx512.mask.or.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> zeroinitializer, i8 -1)
  ret <8 x float> %res
}

define <8 x float> @test_mask_or_ps_rmbk_256(<8 x float> %a, float* %ptr_b, <8 x float> %passThru, i8 %mask) {
  ;CHECK-LABEL: test_mask_or_ps_rmbk_256
  ;CHECK: vorps (%rdi){1to8}, %ymm0, %ymm1 {%k1} ## encoding: [0x62,0xf1,0x7c,0x39,0x56,0x0f]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <8 x float> undef, float %q, i32 0
  %b = shufflevector <8 x float> %vecinit.i, <8 x float> undef, <8 x i32> zeroinitializer
  %res = call <8 x float> @llvm.x86.avx512.mask.or.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> %passThru, i8 %mask)
  ret <8 x float> %res
}

define <8 x float> @test_mask_or_ps_rmbkz_256(<8 x float> %a, float* %ptr_b, i8 %mask) {
  ;CHECK-LABEL: test_mask_or_ps_rmbkz_256
  ;CHECK: vorps (%rdi){1to8}, %ymm0, %ymm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0xb9,0x56,0x07]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <8 x float> undef, float %q, i32 0
  %b = shufflevector <8 x float> %vecinit.i, <8 x float> undef, <8 x i32> zeroinitializer
  %res = call <8 x float> @llvm.x86.avx512.mask.or.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> zeroinitializer, i8 %mask)
  ret <8 x float> %res
}

declare <8 x float> @llvm.x86.avx512.mask.or.ps.256(<8 x float>, <8 x float>, <8 x float>, i8)

define <16 x float> @test_mask_or_ps_rr_512(<16 x float> %a, <16 x float> %b) {
  ;CHECK-LABEL: test_mask_or_ps_rr_512
  ;CHECK: vorps %zmm1, %zmm0, %zmm0     ## encoding: [0x62,0xf1,0x7c,0x48,0x56,0xc1]
  %res = call <16 x float> @llvm.x86.avx512.mask.or.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> zeroinitializer, i16 -1)
  ret <16 x float> %res
}

define <16 x float> @test_mask_or_ps_rrk_512(<16 x float> %a, <16 x float> %b, <16 x float> %passThru, i16 %mask) {
  ;CHECK-LABEL: test_mask_or_ps_rrk_512
  ;CHECK: vorps %zmm1, %zmm0, %zmm2 {%k1} ## encoding: [0x62,0xf1,0x7c,0x49,0x56,0xd1]
  %res = call <16 x float> @llvm.x86.avx512.mask.or.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> %passThru, i16 %mask)
  ret <16 x float> %res
}

define <16 x float> @test_mask_or_ps_rrkz_512(<16 x float> %a, <16 x float> %b, i16 %mask) {
  ;CHECK-LABEL: test_mask_or_ps_rrkz_512
  ;CHECK: vorps %zmm1, %zmm0, %zmm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0xc9,0x56,0xc1]
  %res = call <16 x float> @llvm.x86.avx512.mask.or.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> zeroinitializer, i16 %mask)
  ret <16 x float> %res
}

define <16 x float> @test_mask_or_ps_rm_512(<16 x float> %a, <16 x float>* %ptr_b) {
  ;CHECK-LABEL: test_mask_or_ps_rm_512
  ;CHECK: vorps (%rdi), %zmm0, %zmm0    ## encoding: [0x62,0xf1,0x7c,0x48,0x56,0x07]
  %b = load <16 x float>, <16 x float>* %ptr_b
  %res = call <16 x float> @llvm.x86.avx512.mask.or.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> zeroinitializer, i16 -1)
  ret <16 x float> %res
}

define <16 x float> @test_mask_or_ps_rmk_512(<16 x float> %a, <16 x float>* %ptr_b, <16 x float> %passThru, i16 %mask) {
  ;CHECK-LABEL: test_mask_or_ps_rmk_512
  ;CHECK: vorps (%rdi), %zmm0, %zmm1 {%k1} ## encoding: [0x62,0xf1,0x7c,0x49,0x56,0x0f]
  %b = load <16 x float>, <16 x float>* %ptr_b
  %res = call <16 x float> @llvm.x86.avx512.mask.or.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> %passThru, i16 %mask)
  ret <16 x float> %res
}

define <16 x float> @test_mask_or_ps_rmkz_512(<16 x float> %a, <16 x float>* %ptr_b, i16 %mask) {
  ;CHECK-LABEL: test_mask_or_ps_rmkz_512
  ;CHECK: vorps (%rdi), %zmm0, %zmm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0xc9,0x56,0x07]
  %b = load <16 x float>, <16 x float>* %ptr_b
  %res = call <16 x float> @llvm.x86.avx512.mask.or.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> zeroinitializer, i16 %mask)
  ret <16 x float> %res
}

define <16 x float> @test_mask_or_ps_rmb_512(<16 x float> %a, float* %ptr_b) {
  ;CHECK-LABEL: test_mask_or_ps_rmb_512
  ;CHECK: vorps (%rdi){1to16}, %zmm0, %zmm0  ## encoding: [0x62,0xf1,0x7c,0x58,0x56,0x07]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <16 x float> undef, float %q, i32 0
  %b = shufflevector <16 x float> %vecinit.i, <16 x float> undef, <16 x i32> zeroinitializer
  %res = call <16 x float> @llvm.x86.avx512.mask.or.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> zeroinitializer, i16 -1)
  ret <16 x float> %res
}

define <16 x float> @test_mask_or_ps_rmbk_512(<16 x float> %a, float* %ptr_b, <16 x float> %passThru, i16 %mask) {
  ;CHECK-LABEL: test_mask_or_ps_rmbk_512
  ;CHECK: vorps (%rdi){1to16}, %zmm0, %zmm1 {%k1} ## encoding: [0x62,0xf1,0x7c,0x59,0x56,0x0f]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <16 x float> undef, float %q, i32 0
  %b = shufflevector <16 x float> %vecinit.i, <16 x float> undef, <16 x i32> zeroinitializer
  %res = call <16 x float> @llvm.x86.avx512.mask.or.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> %passThru, i16 %mask)
  ret <16 x float> %res
}

define <16 x float> @test_mask_or_ps_rmbkz_512(<16 x float> %a, float* %ptr_b, i16 %mask) {
  ;CHECK-LABEL: test_mask_or_ps_rmbkz_512
  ;CHECK: vorps (%rdi){1to16}, %zmm0, %zmm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0xd9,0x56,0x07]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <16 x float> undef, float %q, i32 0
  %b = shufflevector <16 x float> %vecinit.i, <16 x float> undef, <16 x i32> zeroinitializer
  %res = call <16 x float> @llvm.x86.avx512.mask.or.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> zeroinitializer, i16 %mask)
  ret <16 x float> %res
}

declare <16 x float> @llvm.x86.avx512.mask.or.ps.512(<16 x float>, <16 x float>, <16 x float>, i16)

define <4 x float> @test_mask_xor_ps_rr_128(<4 x float> %a, <4 x float> %b) {
  ;CHECK-LABEL: test_mask_xor_ps_rr_128
  ;CHECK: vxorps  %xmm1, %xmm0, %xmm0     ## encoding: [0x62,0xf1,0x7c,0x08,0x57,0xc1]
  %res = call <4 x float> @llvm.x86.avx512.mask.xor.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> zeroinitializer, i8 -1)
  ret <4 x float> %res
}

define <4 x float> @test_mask_xor_ps_rrk_128(<4 x float> %a, <4 x float> %b, <4 x float> %passThru, i8 %mask) {
  ;CHECK-LABEL: test_mask_xor_ps_rrk_128
  ;CHECK: vxorps %xmm1, %xmm0, %xmm2 {%k1} ## encoding: [0x62,0xf1,0x7c,0x09,0x57,0xd1]
  %res = call <4 x float> @llvm.x86.avx512.mask.xor.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> %passThru, i8 %mask)
  ret <4 x float> %res
}

define <4 x float> @test_mask_xor_ps_rrkz_128(<4 x float> %a, <4 x float> %b, i8 %mask) {
  ;CHECK-LABEL: test_mask_xor_ps_rrkz_128
  ;CHECK: vxorps %xmm1, %xmm0, %xmm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0x89,0x57,0xc1]
  %res = call <4 x float> @llvm.x86.avx512.mask.xor.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> zeroinitializer, i8 %mask)
  ret <4 x float> %res
}

define <4 x float> @test_mask_xor_ps_rm_128(<4 x float> %a, <4 x float>* %ptr_b) {
  ;CHECK-LABEL: test_mask_xor_ps_rm_128
  ;CHECK: vxorps (%rdi), %xmm0, %xmm0    ## encoding: [0x62,0xf1,0x7c,0x08,0x57,0x07]
  %b = load <4 x float>, <4 x float>* %ptr_b
  %res = call <4 x float> @llvm.x86.avx512.mask.xor.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> zeroinitializer, i8 -1)
  ret <4 x float> %res
}

define <4 x float> @test_mask_xor_ps_rmk_128(<4 x float> %a, <4 x float>* %ptr_b, <4 x float> %passThru, i8 %mask) {
  ;CHECK-LABEL: test_mask_xor_ps_rmk_128
  ;CHECK: vxorps (%rdi), %xmm0, %xmm1 {%k1} ## encoding: [0x62,0xf1,0x7c,0x09,0x57,0x0f]
  %b = load <4 x float>, <4 x float>* %ptr_b
  %res = call <4 x float> @llvm.x86.avx512.mask.xor.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> %passThru, i8 %mask)
  ret <4 x float> %res
}

define <4 x float> @test_mask_xor_ps_rmkz_128(<4 x float> %a, <4 x float>* %ptr_b, i8 %mask) {
  ;CHECK-LABEL: test_mask_xor_ps_rmkz_128
  ;CHECK: vxorps (%rdi), %xmm0, %xmm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0x89,0x57,0x07]
  %b = load <4 x float>, <4 x float>* %ptr_b
  %res = call <4 x float> @llvm.x86.avx512.mask.xor.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> zeroinitializer, i8 %mask)
  ret <4 x float> %res
}

define <4 x float> @test_mask_xor_ps_rmb_128(<4 x float> %a, float* %ptr_b) {
  ;CHECK-LABEL: test_mask_xor_ps_rmb_128
  ;CHECK: vxorps (%rdi){1to4}, %xmm0, %xmm0  ## encoding: [0x62,0xf1,0x7c,0x18,0x57,0x07]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <4 x float> undef, float %q, i32 0
  %b = shufflevector <4 x float> %vecinit.i, <4 x float> undef, <4 x i32> zeroinitializer
  %res = call <4 x float> @llvm.x86.avx512.mask.xor.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> zeroinitializer, i8 -1)
  ret <4 x float> %res
}

define <4 x float> @test_mask_xor_ps_rmbk_128(<4 x float> %a, float* %ptr_b, <4 x float> %passThru, i8 %mask) {
  ;CHECK-LABEL: test_mask_xor_ps_rmbk_128
  ;CHECK: vxorps (%rdi){1to4}, %xmm0, %xmm1 {%k1} ## encoding: [0x62,0xf1,0x7c,0x19,0x57,0x0f]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <4 x float> undef, float %q, i32 0
  %b = shufflevector <4 x float> %vecinit.i, <4 x float> undef, <4 x i32> zeroinitializer
  %res = call <4 x float> @llvm.x86.avx512.mask.xor.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> %passThru, i8 %mask)
  ret <4 x float> %res
}

define <4 x float> @test_mask_xor_ps_rmbkz_128(<4 x float> %a, float* %ptr_b, i8 %mask) {
  ;CHECK-LABEL: test_mask_xor_ps_rmbkz_128
  ;CHECK: vxorps (%rdi){1to4}, %xmm0, %xmm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0x99,0x57,0x07]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <4 x float> undef, float %q, i32 0
  %b = shufflevector <4 x float> %vecinit.i, <4 x float> undef, <4 x i32> zeroinitializer
  %res = call <4 x float> @llvm.x86.avx512.mask.xor.ps.128(<4 x float> %a, <4 x float> %b, <4 x float> zeroinitializer, i8 %mask)
  ret <4 x float> %res
}

declare <4 x float> @llvm.x86.avx512.mask.xor.ps.128(<4 x float>, <4 x float>, <4 x float>, i8)

define <8 x float> @test_mask_xor_ps_rr_256(<8 x float> %a, <8 x float> %b) {
  ;CHECK-LABEL: test_mask_xor_ps_rr_256
  ;CHECK: vxorps %ymm1, %ymm0, %ymm0     ## encoding: [0x62,0xf1,0x7c,0x28,0x57,0xc1]
  %res = call <8 x float> @llvm.x86.avx512.mask.xor.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> zeroinitializer, i8 -1)
  ret <8 x float> %res
}

define <8 x float> @test_mask_xor_ps_rrk_256(<8 x float> %a, <8 x float> %b, <8 x float> %passThru, i8 %mask) {
  ;CHECK-LABEL: test_mask_xor_ps_rrk_256
  ;CHECK: vxorps %ymm1, %ymm0, %ymm2 {%k1} ## encoding: [0x62,0xf1,0x7c,0x29,0x57,0xd1]
  %res = call <8 x float> @llvm.x86.avx512.mask.xor.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> %passThru, i8 %mask)
  ret <8 x float> %res
}

define <8 x float> @test_mask_xor_ps_rrkz_256(<8 x float> %a, <8 x float> %b, i8 %mask) {
  ;CHECK-LABEL: test_mask_xor_ps_rrkz_256
  ;CHECK: vxorps %ymm1, %ymm0, %ymm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0xa9,0x57,0xc1]
  %res = call <8 x float> @llvm.x86.avx512.mask.xor.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> zeroinitializer, i8 %mask)
  ret <8 x float> %res
}

define <8 x float> @test_mask_xor_ps_rm_256(<8 x float> %a, <8 x float>* %ptr_b) {
  ;CHECK-LABEL: test_mask_xor_ps_rm_256
  ;CHECK: vxorps (%rdi), %ymm0, %ymm0    ## encoding: [0x62,0xf1,0x7c,0x28,0x57,0x07]
  %b = load <8 x float>, <8 x float>* %ptr_b
  %res = call <8 x float> @llvm.x86.avx512.mask.xor.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> zeroinitializer, i8 -1)
  ret <8 x float> %res
}

define <8 x float> @test_mask_xor_ps_rmk_256(<8 x float> %a, <8 x float>* %ptr_b, <8 x float> %passThru, i8 %mask) {
  ;CHECK-LABEL: test_mask_xor_ps_rmk_256
  ;CHECK: vxorps (%rdi), %ymm0, %ymm1 {%k1} ## encoding: [0x62,0xf1,0x7c,0x29,0x57,0x0f]
  %b = load <8 x float>, <8 x float>* %ptr_b
  %res = call <8 x float> @llvm.x86.avx512.mask.xor.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> %passThru, i8 %mask)
  ret <8 x float> %res
}

define <8 x float> @test_mask_xor_ps_rmkz_256(<8 x float> %a, <8 x float>* %ptr_b, i8 %mask) {
  ;CHECK-LABEL: test_mask_xor_ps_rmkz_256
  ;CHECK: vxorps (%rdi), %ymm0, %ymm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0xa9,0x57,0x07]
  %b = load <8 x float>, <8 x float>* %ptr_b
  %res = call <8 x float> @llvm.x86.avx512.mask.xor.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> zeroinitializer, i8 %mask)
  ret <8 x float> %res
}

define <8 x float> @test_mask_xor_ps_rmb_256(<8 x float> %a, float* %ptr_b) {
  ;CHECK-LABEL: test_mask_xor_ps_rmb_256
  ;CHECK: vxorps (%rdi){1to8}, %ymm0, %ymm0  ## encoding: [0x62,0xf1,0x7c,0x38,0x57,0x07]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <8 x float> undef, float %q, i32 0
  %b = shufflevector <8 x float> %vecinit.i, <8 x float> undef, <8 x i32> zeroinitializer
  %res = call <8 x float> @llvm.x86.avx512.mask.xor.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> zeroinitializer, i8 -1)
  ret <8 x float> %res
}

define <8 x float> @test_mask_xor_ps_rmbk_256(<8 x float> %a, float* %ptr_b, <8 x float> %passThru, i8 %mask) {
  ;CHECK-LABEL: test_mask_xor_ps_rmbk_256
  ;CHECK: vxorps (%rdi){1to8}, %ymm0, %ymm1 {%k1} ## encoding: [0x62,0xf1,0x7c,0x39,0x57,0x0f]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <8 x float> undef, float %q, i32 0
  %b = shufflevector <8 x float> %vecinit.i, <8 x float> undef, <8 x i32> zeroinitializer
  %res = call <8 x float> @llvm.x86.avx512.mask.xor.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> %passThru, i8 %mask)
  ret <8 x float> %res
}

define <8 x float> @test_mask_xor_ps_rmbkz_256(<8 x float> %a, float* %ptr_b, i8 %mask) {
  ;CHECK-LABEL: test_mask_xor_ps_rmbkz_256
  ;CHECK: vxorps (%rdi){1to8}, %ymm0, %ymm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0xb9,0x57,0x07]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <8 x float> undef, float %q, i32 0
  %b = shufflevector <8 x float> %vecinit.i, <8 x float> undef, <8 x i32> zeroinitializer
  %res = call <8 x float> @llvm.x86.avx512.mask.xor.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> zeroinitializer, i8 %mask)
  ret <8 x float> %res
}

declare <8 x float> @llvm.x86.avx512.mask.xor.ps.256(<8 x float>, <8 x float>, <8 x float>, i8)

define <16 x float> @test_mask_xor_ps_rr_512(<16 x float> %a, <16 x float> %b) {
  ;CHECK-LABEL: test_mask_xor_ps_rr_512
  ;CHECK: vxorps %zmm1, %zmm0, %zmm0     ## encoding: [0x62,0xf1,0x7c,0x48,0x57,0xc1]
  %res = call <16 x float> @llvm.x86.avx512.mask.xor.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> zeroinitializer, i16 -1)
  ret <16 x float> %res
}

define <16 x float> @test_mask_xor_ps_rrk_512(<16 x float> %a, <16 x float> %b, <16 x float> %passThru, i16 %mask) {
  ;CHECK-LABEL: test_mask_xor_ps_rrk_512
  ;CHECK: vxorps %zmm1, %zmm0, %zmm2 {%k1} ## encoding: [0x62,0xf1,0x7c,0x49,0x57,0xd1]
  %res = call <16 x float> @llvm.x86.avx512.mask.xor.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> %passThru, i16 %mask)
  ret <16 x float> %res
}

define <16 x float> @test_mask_xor_ps_rrkz_512(<16 x float> %a, <16 x float> %b, i16 %mask) {
  ;CHECK-LABEL: test_mask_xor_ps_rrkz_512
  ;CHECK: vxorps %zmm1, %zmm0, %zmm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0xc9,0x57,0xc1]
  %res = call <16 x float> @llvm.x86.avx512.mask.xor.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> zeroinitializer, i16 %mask)
  ret <16 x float> %res
}

define <16 x float> @test_mask_xor_ps_rm_512(<16 x float> %a, <16 x float>* %ptr_b) {
  ;CHECK-LABEL: test_mask_xor_ps_rm_512
  ;CHECK: vxorps (%rdi), %zmm0, %zmm0    ## encoding: [0x62,0xf1,0x7c,0x48,0x57,0x07]
  %b = load <16 x float>, <16 x float>* %ptr_b
  %res = call <16 x float> @llvm.x86.avx512.mask.xor.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> zeroinitializer, i16 -1)
  ret <16 x float> %res
}

define <16 x float> @test_mask_xor_ps_rmk_512(<16 x float> %a, <16 x float>* %ptr_b, <16 x float> %passThru, i16 %mask) {
  ;CHECK-LABEL: test_mask_xor_ps_rmk_512
  ;CHECK: vxorps (%rdi), %zmm0, %zmm1 {%k1} ## encoding: [0x62,0xf1,0x7c,0x49,0x57,0x0f]
  %b = load <16 x float>, <16 x float>* %ptr_b
  %res = call <16 x float> @llvm.x86.avx512.mask.xor.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> %passThru, i16 %mask)
  ret <16 x float> %res
}

define <16 x float> @test_mask_xor_ps_rmkz_512(<16 x float> %a, <16 x float>* %ptr_b, i16 %mask) {
  ;CHECK-LABEL: test_mask_xor_ps_rmkz_512
  ;CHECK: vxorps (%rdi), %zmm0, %zmm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0xc9,0x57,0x07]
  %b = load <16 x float>, <16 x float>* %ptr_b
  %res = call <16 x float> @llvm.x86.avx512.mask.xor.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> zeroinitializer, i16 %mask)
  ret <16 x float> %res
}

define <16 x float> @test_mask_xor_ps_rmb_512(<16 x float> %a, float* %ptr_b) {
  ;CHECK-LABEL: test_mask_xor_ps_rmb_512
  ;CHECK: vxorps (%rdi){1to16}, %zmm0, %zmm0  ## encoding: [0x62,0xf1,0x7c,0x58,0x57,0x07]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <16 x float> undef, float %q, i32 0
  %b = shufflevector <16 x float> %vecinit.i, <16 x float> undef, <16 x i32> zeroinitializer
  %res = call <16 x float> @llvm.x86.avx512.mask.xor.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> zeroinitializer, i16 -1)
  ret <16 x float> %res
}

define <16 x float> @test_mask_xor_ps_rmbk_512(<16 x float> %a, float* %ptr_b, <16 x float> %passThru, i16 %mask) {
  ;CHECK-LABEL: test_mask_xor_ps_rmbk_512
  ;CHECK: vxorps (%rdi){1to16}, %zmm0, %zmm1 {%k1} ## encoding: [0x62,0xf1,0x7c,0x59,0x57,0x0f]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <16 x float> undef, float %q, i32 0
  %b = shufflevector <16 x float> %vecinit.i, <16 x float> undef, <16 x i32> zeroinitializer
  %res = call <16 x float> @llvm.x86.avx512.mask.xor.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> %passThru, i16 %mask)
  ret <16 x float> %res
}

define <16 x float> @test_mask_xor_ps_rmbkz_512(<16 x float> %a, float* %ptr_b, i16 %mask) {
  ;CHECK-LABEL: test_mask_xor_ps_rmbkz_512
  ;CHECK: vxorps (%rdi){1to16}, %zmm0, %zmm0 {%k1} {z} ## encoding: [0x62,0xf1,0x7c,0xd9,0x57,0x07]
  %q = load float, float* %ptr_b
  %vecinit.i = insertelement <16 x float> undef, float %q, i32 0
  %b = shufflevector <16 x float> %vecinit.i, <16 x float> undef, <16 x i32> zeroinitializer
  %res = call <16 x float> @llvm.x86.avx512.mask.xor.ps.512(<16 x float> %a, <16 x float> %b, <16 x float> zeroinitializer, i16 %mask)
  ret <16 x float> %res
}

declare <16 x float> @llvm.x86.avx512.mask.xor.ps.512(<16 x float>, <16 x float>, <16 x float>, i16)