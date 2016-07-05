; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mcpu=knl | FileCheck %s

declare <16 x float> @llvm.x86.avx512.mask.broadcast.ss.ps.512(<4 x float>, <16 x float>, i16) nounwind readonly

define <16 x float> @test_x86_vbroadcast_ss_ps_512(<4 x float> %a0, <16 x float> %a1, i16 %mask ) {
; CHECK-LABEL: test_x86_vbroadcast_ss_ps_512:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vbroadcastss %xmm0, %zmm2
; CHECK-NEXT:    kmovw %edi, %k1
; CHECK-NEXT:    vbroadcastss %xmm0, %zmm1 {%k1}
; CHECK-NEXT:    vbroadcastss %xmm0, %zmm0 {%k1} {z}
; CHECK-NEXT:    vaddps %zmm1, %zmm2, %zmm1
; CHECK-NEXT:    vaddps %zmm1, %zmm0, %zmm0
; CHECK-NEXT:    retq

  %res = call <16 x float> @llvm.x86.avx512.mask.broadcast.ss.ps.512(<4 x float> %a0, <16 x float> zeroinitializer, i16 -1)
  %res1 = call <16 x float> @llvm.x86.avx512.mask.broadcast.ss.ps.512(<4 x float> %a0, <16 x float> %a1, i16 %mask)
  %res2 = call <16 x float> @llvm.x86.avx512.mask.broadcast.ss.ps.512(<4 x float> %a0, <16 x float> zeroinitializer, i16 %mask)
  %res3 = fadd <16 x float> %res, %res1
  %res4 = fadd <16 x float> %res2, %res3
  ret <16 x float> %res4
}

declare <8 x double> @llvm.x86.avx512.mask.broadcast.sd.pd.512(<2 x double>, <8 x double>, i8) nounwind readonly

define <8 x double> @test_x86_vbroadcast_sd_pd_512(<2 x double> %a0, <8 x double> %a1, i8 %mask ) {
; CHECK-LABEL: test_x86_vbroadcast_sd_pd_512:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vbroadcastsd %xmm0, %zmm2
; CHECK-NEXT:    kmovw %edi, %k1
; CHECK-NEXT:    vbroadcastsd %xmm0, %zmm1 {%k1}
; CHECK-NEXT:    vbroadcastsd %xmm0, %zmm0 {%k1} {z}
; CHECK-NEXT:    vaddpd %zmm1, %zmm2, %zmm1
; CHECK-NEXT:    vaddpd %zmm1, %zmm0, %zmm0
; CHECK-NEXT:    retq

  %res = call <8 x double> @llvm.x86.avx512.mask.broadcast.sd.pd.512(<2 x double> %a0, <8 x double> zeroinitializer, i8 -1)
  %res1 = call <8 x double> @llvm.x86.avx512.mask.broadcast.sd.pd.512(<2 x double> %a0, <8 x double> %a1, i8 %mask)
  %res2 = call <8 x double> @llvm.x86.avx512.mask.broadcast.sd.pd.512(<2 x double> %a0, <8 x double> zeroinitializer, i8 %mask)
  %res3 = fadd <8 x double> %res, %res1
  %res4 = fadd <8 x double> %res2, %res3
  ret <8 x double> %res4
}

declare <16 x i32> @llvm.x86.avx512.pbroadcastd.512(<4 x i32>, <16 x i32>, i16)

define <16 x i32>@test_int_x86_avx512_pbroadcastd_512(<4 x i32> %x0, <16 x i32> %x1, i16 %mask) {
; CHECK-LABEL: test_int_x86_avx512_pbroadcastd_512:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpbroadcastd %xmm0, %zmm2
; CHECK-NEXT:    kmovw %edi, %k1
; CHECK-NEXT:    vpbroadcastd %xmm0, %zmm1 {%k1}
; CHECK-NEXT:    vpbroadcastd %xmm0, %zmm0 {%k1} {z}
; CHECK-NEXT:    vpaddd %zmm1, %zmm2, %zmm1
; CHECK-NEXT:    vpaddd %zmm1, %zmm0, %zmm0
; CHECK-NEXT:    retq
  %res = call <16 x i32> @llvm.x86.avx512.pbroadcastd.512(<4 x i32> %x0, <16 x i32> %x1, i16 -1)
  %res1 = call <16 x i32> @llvm.x86.avx512.pbroadcastd.512(<4 x i32> %x0, <16 x i32> %x1, i16 %mask)
  %res2 = call <16 x i32> @llvm.x86.avx512.pbroadcastd.512(<4 x i32> %x0, <16 x i32> zeroinitializer, i16 %mask)
  %res3 = add <16 x i32> %res, %res1
  %res4 = add <16 x i32> %res2, %res3
  ret <16 x i32> %res4
}

declare <8 x i64> @llvm.x86.avx512.pbroadcastq.512(<2 x i64>, <8 x i64>, i8)

define <8 x i64>@test_int_x86_avx512_pbroadcastq_512(<2 x i64> %x0, <8 x i64> %x1, i8 %mask) {
; CHECK-LABEL: test_int_x86_avx512_pbroadcastq_512:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpbroadcastq %xmm0, %zmm2
; CHECK-NEXT:    kmovw %edi, %k1
; CHECK-NEXT:    vpbroadcastq %xmm0, %zmm1 {%k1}
; CHECK-NEXT:    vpbroadcastq %xmm0, %zmm0 {%k1} {z}
; CHECK-NEXT:    vpaddq %zmm1, %zmm2, %zmm1
; CHECK-NEXT:    vpaddq %zmm1, %zmm0, %zmm0
; CHECK-NEXT:    retq
  %res = call <8 x i64> @llvm.x86.avx512.pbroadcastq.512(<2 x i64> %x0, <8 x i64> %x1,i8 -1)
  %res1 = call <8 x i64> @llvm.x86.avx512.pbroadcastq.512(<2 x i64> %x0, <8 x i64> %x1,i8 %mask)
  %res2 = call <8 x i64> @llvm.x86.avx512.pbroadcastq.512(<2 x i64> %x0, <8 x i64> zeroinitializer,i8 %mask)
  %res3 = add <8 x i64> %res, %res1
  %res4 = add <8 x i64> %res2, %res3
  ret <8 x i64> %res4
}

declare <16 x float> @llvm.x86.avx512.mask.movsldup.512(<16 x float>, <16 x float>, i16)

define <16 x float>@test_int_x86_avx512_mask_movsldup_512(<16 x float> %x0, <16 x float> %x1, i16 %x2) {
; CHECK-LABEL: test_int_x86_avx512_mask_movsldup_512:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vmovsldup {{.*#+}} zmm2 = zmm0[0,0,2,2,4,4,6,6,8,8,10,10,12,12,14,14]
; CHECK-NEXT:    kmovw %edi, %k1
; CHECK-NEXT:    vmovsldup {{.*#+}} zmm1 {%k1} = zmm0[0,0,2,2,4,4,6,6,8,8,10,10,12,12,14,14]
; CHECK-NEXT:    vmovsldup {{.*#+}} zmm0 {%k1} {z} = zmm0[0,0,2,2,4,4,6,6,8,8,10,10,12,12,14,14]
; CHECK-NEXT:    vaddps %zmm2, %zmm1, %zmm1
; CHECK-NEXT:    vaddps %zmm1, %zmm0, %zmm0
; CHECK-NEXT:    retq
  %res = call <16 x float> @llvm.x86.avx512.mask.movsldup.512(<16 x float> %x0, <16 x float> %x1, i16 %x2)
  %res1 = call <16 x float> @llvm.x86.avx512.mask.movsldup.512(<16 x float> %x0, <16 x float> %x1, i16 -1)
  %res2 = call <16 x float> @llvm.x86.avx512.mask.movsldup.512(<16 x float> %x0, <16 x float> zeroinitializer, i16 %x2)
  %res3 = fadd <16 x float> %res, %res1
  %res4 = fadd <16 x float> %res2, %res3
  ret <16 x float> %res4
}

declare <16 x float> @llvm.x86.avx512.mask.movshdup.512(<16 x float>, <16 x float>, i16)

define <16 x float>@test_int_x86_avx512_mask_movshdup_512(<16 x float> %x0, <16 x float> %x1, i16 %x2) {
; CHECK-LABEL: test_int_x86_avx512_mask_movshdup_512:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vmovshdup {{.*#+}} zmm2 = zmm0[1,1,3,3,5,5,7,7,9,9,11,11,13,13,15,15]
; CHECK-NEXT:    kmovw %edi, %k1
; CHECK-NEXT:    vmovshdup {{.*#+}} zmm1 {%k1} = zmm0[1,1,3,3,5,5,7,7,9,9,11,11,13,13,15,15]
; CHECK-NEXT:    vmovshdup {{.*#+}} zmm0 {%k1} {z} = zmm0[1,1,3,3,5,5,7,7,9,9,11,11,13,13,15,15]
; CHECK-NEXT:    vaddps %zmm2, %zmm1, %zmm1
; CHECK-NEXT:    vaddps %zmm1, %zmm0, %zmm0
; CHECK-NEXT:    retq
  %res = call <16 x float> @llvm.x86.avx512.mask.movshdup.512(<16 x float> %x0, <16 x float> %x1, i16 %x2)
  %res1 = call <16 x float> @llvm.x86.avx512.mask.movshdup.512(<16 x float> %x0, <16 x float> %x1, i16 -1)
  %res2 = call <16 x float> @llvm.x86.avx512.mask.movshdup.512(<16 x float> %x0, <16 x float> zeroinitializer, i16 %x2)
  %res3 = fadd <16 x float> %res, %res1
  %res4 = fadd <16 x float> %res2, %res3
  ret <16 x float> %res4
}

declare <8 x double> @llvm.x86.avx512.mask.movddup.512(<8 x double>, <8 x double>, i8)

define <8 x double>@test_int_x86_avx512_mask_movddup_512(<8 x double> %x0, <8 x double> %x1, i8 %x2) {
; CHECK-LABEL: test_int_x86_avx512_mask_movddup_512:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vmovddup {{.*#+}} zmm2 = zmm0[0,0,2,2,4,4,6,6]
; CHECK-NEXT:    kmovw %edi, %k1
; CHECK-NEXT:    vmovddup {{.*#+}} zmm1 {%k1} = zmm0[0,0,2,2,4,4,6,6]
; CHECK-NEXT:    vmovddup {{.*#+}} zmm0 {%k1} {z} = zmm0[0,0,2,2,4,4,6,6]
; CHECK-NEXT:    vaddpd %zmm2, %zmm1, %zmm1
; CHECK-NEXT:    vaddpd %zmm1, %zmm0, %zmm0
; CHECK-NEXT:    retq
  %res = call <8 x double> @llvm.x86.avx512.mask.movddup.512(<8 x double> %x0, <8 x double> %x1, i8 %x2)
  %res1 = call <8 x double> @llvm.x86.avx512.mask.movddup.512(<8 x double> %x0, <8 x double> %x1, i8 -1)
  %res2 = call <8 x double> @llvm.x86.avx512.mask.movddup.512(<8 x double> %x0, <8 x double> zeroinitializer, i8 %x2)
  %res3 = fadd <8 x double> %res, %res1
  %res4 = fadd <8 x double> %res2, %res3
  ret <8 x double> %res4
}

declare <8 x double> @llvm.x86.avx512.mask.perm.df.512(<8 x double>, i32, <8 x double>, i8)

define <8 x double>@test_int_x86_avx512_mask_perm_df_512(<8 x double> %x0, i32 %x1, <8 x double> %x2, i8 %x3) {
; CHECK-LABEL: test_int_x86_avx512_mask_perm_df_512:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpermpd {{.*#+}} zmm2 = zmm0[3,0,0,0,7,4,4,4]
; CHECK-NEXT:    kmovw %esi, %k1
; CHECK-NEXT:    vpermpd {{.*#+}} zmm1 {%k1} = zmm0[3,0,0,0,7,4,4,4]
; CHECK-NEXT:    vpermpd {{.*#+}} zmm0 {%k1} {z} = zmm0[3,0,0,0,7,4,4,4]
; CHECK-NEXT:    vaddpd %zmm0, %zmm1, %zmm0
; CHECK-NEXT:    vaddpd %zmm2, %zmm0, %zmm0
; CHECK-NEXT:    retq
  %res = call <8 x double> @llvm.x86.avx512.mask.perm.df.512(<8 x double> %x0, i32 3, <8 x double> %x2, i8 %x3)
  %res1 = call <8 x double> @llvm.x86.avx512.mask.perm.df.512(<8 x double> %x0, i32 3, <8 x double> zeroinitializer, i8 %x3)
  %res2 = call <8 x double> @llvm.x86.avx512.mask.perm.df.512(<8 x double> %x0, i32 3, <8 x double> %x2, i8 -1)
  %res3 = fadd <8 x double> %res, %res1
  %res4 = fadd <8 x double> %res3, %res2
  ret <8 x double> %res4
}

declare <8 x i64> @llvm.x86.avx512.mask.perm.di.512(<8 x i64>, i32, <8 x i64>, i8)

define <8 x i64>@test_int_x86_avx512_mask_perm_di_512(<8 x i64> %x0, i32 %x1, <8 x i64> %x2, i8 %x3) {
; CHECK-LABEL: test_int_x86_avx512_mask_perm_di_512:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpermq {{.*#+}} zmm2 = zmm0[3,0,0,0,7,4,4,4]
; CHECK-NEXT:    kmovw %esi, %k1
; CHECK-NEXT:    vpermq {{.*#+}} zmm1 {%k1} = zmm0[3,0,0,0,7,4,4,4]
; CHECK-NEXT:    vpermq {{.*#+}} zmm0 {%k1} {z} = zmm0[3,0,0,0,7,4,4,4]
; CHECK-NEXT:    vpaddq %zmm0, %zmm1, %zmm0
; CHECK-NEXT:    vpaddq %zmm2, %zmm0, %zmm0
; CHECK-NEXT:    retq
  %res = call <8 x i64> @llvm.x86.avx512.mask.perm.di.512(<8 x i64> %x0, i32 3, <8 x i64> %x2, i8 %x3)
  %res1 = call <8 x i64> @llvm.x86.avx512.mask.perm.di.512(<8 x i64> %x0, i32 3, <8 x i64> zeroinitializer, i8 %x3)
  %res2 = call <8 x i64> @llvm.x86.avx512.mask.perm.di.512(<8 x i64> %x0, i32 3, <8 x i64> %x2, i8 -1)
  %res3 = add <8 x i64> %res, %res1
  %res4 = add <8 x i64> %res3, %res2
  ret <8 x i64> %res4
}

define void @test_store1(<16 x float> %data, i8* %ptr, i8* %ptr2, i16 %mask) {
; CHECK-LABEL: test_store1:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1
; CHECK-NEXT:    vmovups %zmm0, (%rdi) {%k1}
; CHECK-NEXT:    vmovups %zmm0, (%rsi)
; CHECK-NEXT:    retq
  call void @llvm.x86.avx512.mask.storeu.ps.512(i8* %ptr, <16 x float> %data, i16 %mask)
  call void @llvm.x86.avx512.mask.storeu.ps.512(i8* %ptr2, <16 x float> %data, i16 -1)
  ret void
}

declare void @llvm.x86.avx512.mask.storeu.ps.512(i8*, <16 x float>, i16 )

define void @test_store2(<8 x double> %data, i8* %ptr, i8* %ptr2, i8 %mask) {
; CHECK-LABEL: test_store2:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1
; CHECK-NEXT:    vmovupd %zmm0, (%rdi) {%k1}
; CHECK-NEXT:    vmovupd %zmm0, (%rsi)
; CHECK-NEXT:    retq
  call void @llvm.x86.avx512.mask.storeu.pd.512(i8* %ptr, <8 x double> %data, i8 %mask)
  call void @llvm.x86.avx512.mask.storeu.pd.512(i8* %ptr2, <8 x double> %data, i8 -1)
  ret void
}

declare void @llvm.x86.avx512.mask.storeu.pd.512(i8*, <8 x double>, i8)

define void @test_mask_store_aligned_ps(<16 x float> %data, i8* %ptr, i8* %ptr2, i16 %mask) {
; CHECK-LABEL: test_mask_store_aligned_ps:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1
; CHECK-NEXT:    vmovaps %zmm0, (%rdi) {%k1}
; CHECK-NEXT:    vmovaps %zmm0, (%rsi)
; CHECK-NEXT:    retq
  call void @llvm.x86.avx512.mask.store.ps.512(i8* %ptr, <16 x float> %data, i16 %mask)
  call void @llvm.x86.avx512.mask.store.ps.512(i8* %ptr2, <16 x float> %data, i16 -1)
  ret void
}

declare void @llvm.x86.avx512.mask.store.ps.512(i8*, <16 x float>, i16 )

define void @test_mask_store_aligned_pd(<8 x double> %data, i8* %ptr, i8* %ptr2, i8 %mask) {
; CHECK-LABEL: test_mask_store_aligned_pd:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1
; CHECK-NEXT:    vmovapd %zmm0, (%rdi) {%k1}
; CHECK-NEXT:    vmovapd %zmm0, (%rsi)
; CHECK-NEXT:    retq
  call void @llvm.x86.avx512.mask.store.pd.512(i8* %ptr, <8 x double> %data, i8 %mask)
  call void @llvm.x86.avx512.mask.store.pd.512(i8* %ptr2, <8 x double> %data, i8 -1)
  ret void
}

declare void @llvm.x86.avx512.mask.store.pd.512(i8*, <8 x double>, i8)

define void@test_int_x86_avx512_mask_storeu_q_512(i8* %ptr1, i8* %ptr2, <8 x i64> %x1, i8 %x2) {
; CHECK-LABEL: test_int_x86_avx512_mask_storeu_q_512:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1
; CHECK-NEXT:    vmovdqu64 %zmm0, (%rdi) {%k1}
; CHECK-NEXT:    vmovdqu64 %zmm0, (%rsi)
; CHECK-NEXT:    retq
  call void @llvm.x86.avx512.mask.storeu.q.512(i8* %ptr1, <8 x i64> %x1, i8 %x2)
  call void @llvm.x86.avx512.mask.storeu.q.512(i8* %ptr2, <8 x i64> %x1, i8 -1)
  ret void
}

declare void @llvm.x86.avx512.mask.storeu.q.512(i8*, <8 x i64>, i8)

define void@test_int_x86_avx512_mask_storeu_d_512(i8* %ptr1, i8* %ptr2, <16 x i32> %x1, i16 %x2) {
; CHECK-LABEL: test_int_x86_avx512_mask_storeu_d_512:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1
; CHECK-NEXT:    vmovdqu32 %zmm0, (%rdi) {%k1}
; CHECK-NEXT:    vmovdqu32 %zmm0, (%rsi)
; CHECK-NEXT:    retq
  call void @llvm.x86.avx512.mask.storeu.d.512(i8* %ptr1, <16 x i32> %x1, i16 %x2)
  call void @llvm.x86.avx512.mask.storeu.d.512(i8* %ptr2, <16 x i32> %x1, i16 -1)
  ret void
}

declare void @llvm.x86.avx512.mask.storeu.d.512(i8*, <16 x i32>, i16)

define void@test_int_x86_avx512_mask_store_q_512(i8* %ptr1, i8* %ptr2, <8 x i64> %x1, i8 %x2) {
; CHECK-LABEL: test_int_x86_avx512_mask_store_q_512:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1
; CHECK-NEXT:    vmovdqa64 %zmm0, (%rdi) {%k1}
; CHECK-NEXT:    vmovdqa64 %zmm0, (%rsi)
; CHECK-NEXT:    retq
  call void @llvm.x86.avx512.mask.store.q.512(i8* %ptr1, <8 x i64> %x1, i8 %x2)
  call void @llvm.x86.avx512.mask.store.q.512(i8* %ptr2, <8 x i64> %x1, i8 -1)
  ret void
}

declare void @llvm.x86.avx512.mask.store.q.512(i8*, <8 x i64>, i8)

define void@test_int_x86_avx512_mask_store_d_512(i8* %ptr1, i8* %ptr2, <16 x i32> %x1, i16 %x2) {
; CHECK-LABEL: test_int_x86_avx512_mask_store_d_512:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1
; CHECK-NEXT:    vmovdqa32 %zmm0, (%rdi) {%k1}
; CHECK-NEXT:    vmovdqa32 %zmm0, (%rsi)
; CHECK-NEXT:    retq
  call void @llvm.x86.avx512.mask.store.d.512(i8* %ptr1, <16 x i32> %x1, i16 %x2)
  call void @llvm.x86.avx512.mask.store.d.512(i8* %ptr2, <16 x i32> %x1, i16 -1)
  ret void
}

declare void @llvm.x86.avx512.mask.store.d.512(i8*, <16 x i32>, i16)

define <16 x float> @test_mask_load_aligned_ps(<16 x float> %data, i8* %ptr, i16 %mask) {
; CHECK-LABEL: test_mask_load_aligned_ps:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vmovaps (%rdi), %zmm0
; CHECK-NEXT:    kmovw %esi, %k1
; CHECK-NEXT:    vmovaps (%rdi), %zmm0 {%k1}
; CHECK-NEXT:    vmovaps (%rdi), %zmm1 {%k1} {z}
; CHECK-NEXT:    vaddps %zmm0, %zmm1, %zmm0
; CHECK-NEXT:    retq
  %res = call <16 x float> @llvm.x86.avx512.mask.load.ps.512(i8* %ptr, <16 x float> zeroinitializer, i16 -1)
  %res1 = call <16 x float> @llvm.x86.avx512.mask.load.ps.512(i8* %ptr, <16 x float> %res, i16 %mask)
  %res2 = call <16 x float> @llvm.x86.avx512.mask.load.ps.512(i8* %ptr, <16 x float> zeroinitializer, i16 %mask)
  %res4 = fadd <16 x float> %res2, %res1
  ret <16 x float> %res4
}

declare <16 x float> @llvm.x86.avx512.mask.load.ps.512(i8*, <16 x float>, i16)

define <16 x float> @test_mask_load_unaligned_ps(<16 x float> %data, i8* %ptr, i16 %mask) {
; CHECK-LABEL: test_mask_load_unaligned_ps:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vmovups (%rdi), %zmm0
; CHECK-NEXT:    kmovw %esi, %k1
; CHECK-NEXT:    vmovups (%rdi), %zmm0 {%k1}
; CHECK-NEXT:    vmovups (%rdi), %zmm1 {%k1} {z}
; CHECK-NEXT:    vaddps %zmm0, %zmm1, %zmm0
; CHECK-NEXT:    retq
  %res = call <16 x float> @llvm.x86.avx512.mask.loadu.ps.512(i8* %ptr, <16 x float> zeroinitializer, i16 -1)
  %res1 = call <16 x float> @llvm.x86.avx512.mask.loadu.ps.512(i8* %ptr, <16 x float> %res, i16 %mask)
  %res2 = call <16 x float> @llvm.x86.avx512.mask.loadu.ps.512(i8* %ptr, <16 x float> zeroinitializer, i16 %mask)
  %res4 = fadd <16 x float> %res2, %res1
  ret <16 x float> %res4
}

declare <16 x float> @llvm.x86.avx512.mask.loadu.ps.512(i8*, <16 x float>, i16)

define <8 x double> @test_mask_load_aligned_pd(<8 x double> %data, i8* %ptr, i8 %mask) {
; CHECK-LABEL: test_mask_load_aligned_pd:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vmovapd (%rdi), %zmm0
; CHECK-NEXT:    kmovw %esi, %k1
; CHECK-NEXT:    vmovapd (%rdi), %zmm0 {%k1}
; CHECK-NEXT:    vmovapd (%rdi), %zmm1 {%k1} {z}
; CHECK-NEXT:    vaddpd %zmm0, %zmm1, %zmm0
; CHECK-NEXT:    retq
  %res = call <8 x double> @llvm.x86.avx512.mask.load.pd.512(i8* %ptr, <8 x double> zeroinitializer, i8 -1)
  %res1 = call <8 x double> @llvm.x86.avx512.mask.load.pd.512(i8* %ptr, <8 x double> %res, i8 %mask)
  %res2 = call <8 x double> @llvm.x86.avx512.mask.load.pd.512(i8* %ptr, <8 x double> zeroinitializer, i8 %mask)
  %res4 = fadd <8 x double> %res2, %res1
  ret <8 x double> %res4
}

declare <8 x double> @llvm.x86.avx512.mask.load.pd.512(i8*, <8 x double>, i8)

define <8 x double> @test_mask_load_unaligned_pd(<8 x double> %data, i8* %ptr, i8 %mask) {
; CHECK-LABEL: test_mask_load_unaligned_pd:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vmovupd (%rdi), %zmm0
; CHECK-NEXT:    kmovw %esi, %k1
; CHECK-NEXT:    vmovupd (%rdi), %zmm0 {%k1}
; CHECK-NEXT:    vmovupd (%rdi), %zmm1 {%k1} {z}
; CHECK-NEXT:    vaddpd %zmm0, %zmm1, %zmm0
; CHECK-NEXT:    retq
  %res = call <8 x double> @llvm.x86.avx512.mask.loadu.pd.512(i8* %ptr, <8 x double> zeroinitializer, i8 -1)
  %res1 = call <8 x double> @llvm.x86.avx512.mask.loadu.pd.512(i8* %ptr, <8 x double> %res, i8 %mask)
  %res2 = call <8 x double> @llvm.x86.avx512.mask.loadu.pd.512(i8* %ptr, <8 x double> zeroinitializer, i8 %mask)
  %res4 = fadd <8 x double> %res2, %res1
  ret <8 x double> %res4
}

declare <8 x double> @llvm.x86.avx512.mask.loadu.pd.512(i8*, <8 x double>, i8)

declare <16 x i32> @llvm.x86.avx512.mask.loadu.d.512(i8*, <16 x i32>, i16)

define <16 x i32> @test_mask_load_unaligned_d(i8* %ptr, i8* %ptr2, <16 x i32> %data, i16 %mask) {
; CHECK-LABEL: test_mask_load_unaligned_d:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vmovdqu32 (%rdi), %zmm0
; CHECK-NEXT:    kmovw %edx, %k1
; CHECK-NEXT:    vmovdqu32 (%rsi), %zmm0 {%k1}
; CHECK-NEXT:    vmovdqu32 (%rdi), %zmm1 {%k1} {z}
; CHECK-NEXT:    vpaddd %zmm0, %zmm1, %zmm0
; CHECK-NEXT:    retq
  %res = call <16 x i32> @llvm.x86.avx512.mask.loadu.d.512(i8* %ptr, <16 x i32> zeroinitializer, i16 -1)
  %res1 = call <16 x i32> @llvm.x86.avx512.mask.loadu.d.512(i8* %ptr2, <16 x i32> %res, i16 %mask)
  %res2 = call <16 x i32> @llvm.x86.avx512.mask.loadu.d.512(i8* %ptr, <16 x i32> zeroinitializer, i16 %mask)
  %res4 = add <16 x i32> %res2, %res1
  ret <16 x i32> %res4
}

declare <8 x i64> @llvm.x86.avx512.mask.loadu.q.512(i8*, <8 x i64>, i8)

define <8 x i64> @test_mask_load_unaligned_q(i8* %ptr, i8* %ptr2, <8 x i64> %data, i8 %mask) {
; CHECK-LABEL: test_mask_load_unaligned_q:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vmovdqu64 (%rdi), %zmm0
; CHECK-NEXT:    kmovw %edx, %k1
; CHECK-NEXT:    vmovdqu64 (%rsi), %zmm0 {%k1}
; CHECK-NEXT:    vmovdqu64 (%rdi), %zmm1 {%k1} {z}
; CHECK-NEXT:    vpaddq %zmm0, %zmm1, %zmm0
; CHECK-NEXT:    retq
  %res = call <8 x i64> @llvm.x86.avx512.mask.loadu.q.512(i8* %ptr, <8 x i64> zeroinitializer, i8 -1)
  %res1 = call <8 x i64> @llvm.x86.avx512.mask.loadu.q.512(i8* %ptr2, <8 x i64> %res, i8 %mask)
  %res2 = call <8 x i64> @llvm.x86.avx512.mask.loadu.q.512(i8* %ptr, <8 x i64> zeroinitializer, i8 %mask)
  %res4 = add <8 x i64> %res2, %res1
  ret <8 x i64> %res4
}

declare <16 x i32> @llvm.x86.avx512.mask.load.d.512(i8*, <16 x i32>, i16)

define <16 x i32> @test_mask_load_aligned_d(<16 x i32> %data, i8* %ptr, i16 %mask) {
; CHECK-LABEL: test_mask_load_aligned_d:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vmovdqa32 (%rdi), %zmm0
; CHECK-NEXT:    kmovw %esi, %k1
; CHECK-NEXT:    vmovdqa32 (%rdi), %zmm0 {%k1}
; CHECK-NEXT:    vmovdqa32 (%rdi), %zmm1 {%k1} {z}
; CHECK-NEXT:    vpaddd %zmm0, %zmm1, %zmm0
; CHECK-NEXT:    retq
  %res = call <16 x i32> @llvm.x86.avx512.mask.load.d.512(i8* %ptr, <16 x i32> zeroinitializer, i16 -1)
  %res1 = call <16 x i32> @llvm.x86.avx512.mask.load.d.512(i8* %ptr, <16 x i32> %res, i16 %mask)
  %res2 = call <16 x i32> @llvm.x86.avx512.mask.load.d.512(i8* %ptr, <16 x i32> zeroinitializer, i16 %mask)
  %res4 = add <16 x i32> %res2, %res1
  ret <16 x i32> %res4
}

declare <8 x i64> @llvm.x86.avx512.mask.load.q.512(i8*, <8 x i64>, i8)

define <8 x i64> @test_mask_load_aligned_q(<8 x i64> %data, i8* %ptr, i8 %mask) {
; CHECK-LABEL: test_mask_load_aligned_q:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vmovdqa64 (%rdi), %zmm0
; CHECK-NEXT:    kmovw %esi, %k1
; CHECK-NEXT:    vmovdqa64 (%rdi), %zmm0 {%k1}
; CHECK-NEXT:    vmovdqa64 (%rdi), %zmm1 {%k1} {z}
; CHECK-NEXT:    vpaddq %zmm0, %zmm1, %zmm0
; CHECK-NEXT:    retq
  %res = call <8 x i64> @llvm.x86.avx512.mask.load.q.512(i8* %ptr, <8 x i64> zeroinitializer, i8 -1)
  %res1 = call <8 x i64> @llvm.x86.avx512.mask.load.q.512(i8* %ptr, <8 x i64> %res, i8 %mask)
  %res2 = call <8 x i64> @llvm.x86.avx512.mask.load.q.512(i8* %ptr, <8 x i64> zeroinitializer, i8 %mask)
  %res4 = add <8 x i64> %res2, %res1
  ret <8 x i64> %res4
}

declare <8 x double> @llvm.x86.avx512.mask.vpermil.pd.512(<8 x double>, i32, <8 x double>, i8)

define <8 x double>@test_int_x86_avx512_mask_vpermil_pd_512(<8 x double> %x0, <8 x double> %x2, i8 %x3) {
; CHECK-LABEL: test_int_x86_avx512_mask_vpermil_pd_512:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpermilpd {{.*#+}} zmm2 = zmm0[0,1,3,2,5,4,6,6]
; CHECK-NEXT:    kmovw %edi, %k1
; CHECK-NEXT:    vpermilpd {{.*#+}} zmm1 {%k1} = zmm0[0,1,3,2,5,4,6,6]
; CHECK-NEXT:    vpermilpd {{.*#+}} zmm0 {%k1} {z} = zmm0[0,1,3,2,5,4,6,6]
; CHECK-NEXT:    vaddpd %zmm0, %zmm1, %zmm0
; CHECK-NEXT:    vaddpd %zmm2, %zmm0, %zmm0
; CHECK-NEXT:    retq
  %res = call <8 x double> @llvm.x86.avx512.mask.vpermil.pd.512(<8 x double> %x0, i32 22, <8 x double> %x2, i8 %x3)
  %res1 = call <8 x double> @llvm.x86.avx512.mask.vpermil.pd.512(<8 x double> %x0, i32 22, <8 x double> zeroinitializer, i8 %x3)
  %res2 = call <8 x double> @llvm.x86.avx512.mask.vpermil.pd.512(<8 x double> %x0, i32 22, <8 x double> %x2, i8 -1)
  %res3 = fadd <8 x double> %res, %res1
  %res4 = fadd <8 x double> %res3, %res2
  ret <8 x double> %res4
}

declare <16 x float> @llvm.x86.avx512.mask.vpermil.ps.512(<16 x float>, i32, <16 x float>, i16)

define <16 x float>@test_int_x86_avx512_mask_vpermil_ps_512(<16 x float> %x0, <16 x float> %x2, i16 %x3) {
; CHECK-LABEL: test_int_x86_avx512_mask_vpermil_ps_512:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpermilps {{.*#+}} zmm2 = zmm0[2,1,1,0,6,5,5,4,10,9,9,8,14,13,13,12]
; CHECK-NEXT:    kmovw %edi, %k1
; CHECK-NEXT:    vpermilps {{.*#+}} zmm1 {%k1} = zmm0[2,1,1,0,6,5,5,4,10,9,9,8,14,13,13,12]
; CHECK-NEXT:    vpermilps {{.*#+}} zmm0 {%k1} {z} = zmm0[2,1,1,0,6,5,5,4,10,9,9,8,14,13,13,12]
; CHECK-NEXT:    vaddps %zmm0, %zmm1, %zmm0
; CHECK-NEXT:    vaddps %zmm2, %zmm0, %zmm0
; CHECK-NEXT:    retq
  %res = call <16 x float> @llvm.x86.avx512.mask.vpermil.ps.512(<16 x float> %x0, i32 22, <16 x float> %x2, i16 %x3)
  %res1 = call <16 x float> @llvm.x86.avx512.mask.vpermil.ps.512(<16 x float> %x0, i32 22, <16 x float> zeroinitializer, i16 %x3)
  %res2 = call <16 x float> @llvm.x86.avx512.mask.vpermil.ps.512(<16 x float> %x0, i32 22, <16 x float> %x2, i16 -1)
  %res3 = fadd <16 x float> %res, %res1
  %res4 = fadd <16 x float> %res3, %res2
  ret <16 x float> %res4
}

declare <16 x i32> @llvm.x86.avx512.mask.pshuf.d.512(<16 x i32>, i32, <16 x i32>, i16)

define <16 x i32>@test_int_x86_avx512_mask_pshuf_d_512(<16 x i32> %x0, i32 %x1, <16 x i32> %x2, i16 %x3) {
; CHECK-LABEL: test_int_x86_avx512_mask_pshuf_d_512:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpshufd {{.*#+}} zmm2 = zmm0[3,0,0,0,7,4,4,4,11,8,8,8,15,12,12,12]
; CHECK-NEXT:    kmovw %esi, %k1
; CHECK-NEXT:    vpshufd {{.*#+}} zmm1 {%k1} = zmm0[3,0,0,0,7,4,4,4,11,8,8,8,15,12,12,12]
; CHECK-NEXT:    vpshufd {{.*#+}} zmm0 {%k1} {z} = zmm0[3,0,0,0,7,4,4,4,11,8,8,8,15,12,12,12]
; CHECK-NEXT:    vpaddd %zmm0, %zmm1, %zmm0
; CHECK-NEXT:    vpaddd %zmm2, %zmm0, %zmm0
; CHECK-NEXT:    retq
	%res = call <16 x i32> @llvm.x86.avx512.mask.pshuf.d.512(<16 x i32> %x0, i32 3, <16 x i32> %x2, i16 %x3)
	%res1 = call <16 x i32> @llvm.x86.avx512.mask.pshuf.d.512(<16 x i32> %x0, i32 3, <16 x i32> zeroinitializer, i16 %x3)
	%res2 = call <16 x i32> @llvm.x86.avx512.mask.pshuf.d.512(<16 x i32> %x0, i32 3, <16 x i32> %x2, i16 -1)
	%res3 = add <16 x i32> %res, %res1
	%res4 = add <16 x i32> %res3, %res2
	ret <16 x i32> %res4
}

define i16 @test_pcmpeq_d(<16 x i32> %a, <16 x i32> %b) {
; CHECK-LABEL: test_pcmpeq_d:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpeqd %zmm1, %zmm0, %k0
; CHECK-NEXT:    kmovw %k0, %eax
; CHECK-NEXT:    retq
  %res = call i16 @llvm.x86.avx512.mask.pcmpeq.d.512(<16 x i32> %a, <16 x i32> %b, i16 -1)
  ret i16 %res
}

define i16 @test_mask_pcmpeq_d(<16 x i32> %a, <16 x i32> %b, i16 %mask) {
; CHECK-LABEL: test_mask_pcmpeq_d:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edi, %k1
; CHECK-NEXT:    vpcmpeqd %zmm1, %zmm0, %k0 {%k1}
; CHECK-NEXT:    kmovw %k0, %eax
; CHECK-NEXT:    retq
  %res = call i16 @llvm.x86.avx512.mask.pcmpeq.d.512(<16 x i32> %a, <16 x i32> %b, i16 %mask)
  ret i16 %res
}

declare i16 @llvm.x86.avx512.mask.pcmpeq.d.512(<16 x i32>, <16 x i32>, i16)

define i8 @test_pcmpeq_q(<8 x i64> %a, <8 x i64> %b) {
; CHECK-LABEL: test_pcmpeq_q:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpeqq %zmm1, %zmm0, %k0
; CHECK-NEXT:    kmovw %k0, %eax
; CHECK-NEXT:    retq
  %res = call i8 @llvm.x86.avx512.mask.pcmpeq.q.512(<8 x i64> %a, <8 x i64> %b, i8 -1)
  ret i8 %res
}

define i8 @test_mask_pcmpeq_q(<8 x i64> %a, <8 x i64> %b, i8 %mask) {
; CHECK-LABEL: test_mask_pcmpeq_q:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edi, %k1
; CHECK-NEXT:    vpcmpeqq %zmm1, %zmm0, %k0 {%k1}
; CHECK-NEXT:    kmovw %k0, %eax
; CHECK-NEXT:    retq
  %res = call i8 @llvm.x86.avx512.mask.pcmpeq.q.512(<8 x i64> %a, <8 x i64> %b, i8 %mask)
  ret i8 %res
}

declare i8 @llvm.x86.avx512.mask.pcmpeq.q.512(<8 x i64>, <8 x i64>, i8)

define i16 @test_pcmpgt_d(<16 x i32> %a, <16 x i32> %b) {
; CHECK-LABEL: test_pcmpgt_d:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpgtd %zmm1, %zmm0, %k0
; CHECK-NEXT:    kmovw %k0, %eax
; CHECK-NEXT:    retq
  %res = call i16 @llvm.x86.avx512.mask.pcmpgt.d.512(<16 x i32> %a, <16 x i32> %b, i16 -1)
  ret i16 %res
}

define i16 @test_mask_pcmpgt_d(<16 x i32> %a, <16 x i32> %b, i16 %mask) {
; CHECK-LABEL: test_mask_pcmpgt_d:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edi, %k1
; CHECK-NEXT:    vpcmpgtd %zmm1, %zmm0, %k0 {%k1}
; CHECK-NEXT:    kmovw %k0, %eax
; CHECK-NEXT:    retq
  %res = call i16 @llvm.x86.avx512.mask.pcmpgt.d.512(<16 x i32> %a, <16 x i32> %b, i16 %mask)
  ret i16 %res
}

declare i16 @llvm.x86.avx512.mask.pcmpgt.d.512(<16 x i32>, <16 x i32>, i16)

define i8 @test_pcmpgt_q(<8 x i64> %a, <8 x i64> %b) {
; CHECK-LABEL: test_pcmpgt_q:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpgtq %zmm1, %zmm0, %k0
; CHECK-NEXT:    kmovw %k0, %eax
; CHECK-NEXT:    retq
  %res = call i8 @llvm.x86.avx512.mask.pcmpgt.q.512(<8 x i64> %a, <8 x i64> %b, i8 -1)
  ret i8 %res
}

define i8 @test_mask_pcmpgt_q(<8 x i64> %a, <8 x i64> %b, i8 %mask) {
; CHECK-LABEL: test_mask_pcmpgt_q:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edi, %k1
; CHECK-NEXT:    vpcmpgtq %zmm1, %zmm0, %k0 {%k1}
; CHECK-NEXT:    kmovw %k0, %eax
; CHECK-NEXT:    retq
  %res = call i8 @llvm.x86.avx512.mask.pcmpgt.q.512(<8 x i64> %a, <8 x i64> %b, i8 %mask)
  ret i8 %res
}

declare i8 @llvm.x86.avx512.mask.pcmpgt.q.512(<8 x i64>, <8 x i64>, i8)

declare <8 x double> @llvm.x86.avx512.mask.unpckh.pd.512(<8 x double>, <8 x double>, <8 x double>, i8)

define <8 x double>@test_int_x86_avx512_mask_unpckh_pd_512(<8 x double> %x0, <8 x double> %x1, <8 x double> %x2, i8 %x3) {
; CHECK-LABEL: test_int_x86_avx512_mask_unpckh_pd_512:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vunpckhpd {{.*#+}} zmm3 = zmm0[1],zmm1[1],zmm0[3],zmm1[3],zmm0[5],zmm1[5],zmm0[7],zmm1[7]
; CHECK-NEXT:    kmovw %edi, %k1
; CHECK-NEXT:    vunpckhpd {{.*#+}} zmm2 {%k1} = zmm0[1],zmm1[1],zmm0[3],zmm1[3],zmm0[5],zmm1[5],zmm0[7],zmm1[7]
; CHECK-NEXT:    vaddpd %zmm3, %zmm2, %zmm0
; CHECK-NEXT:    retq
  %res = call <8 x double> @llvm.x86.avx512.mask.unpckh.pd.512(<8 x double> %x0, <8 x double> %x1, <8 x double> %x2, i8 %x3)
  %res1 = call <8 x double> @llvm.x86.avx512.mask.unpckh.pd.512(<8 x double> %x0, <8 x double> %x1, <8 x double> %x2, i8 -1)
  %res2 = fadd <8 x double> %res, %res1
  ret <8 x double> %res2
}

declare <16 x float> @llvm.x86.avx512.mask.unpckh.ps.512(<16 x float>, <16 x float>, <16 x float>, i16)

define <16 x float>@test_int_x86_avx512_mask_unpckh_ps_512(<16 x float> %x0, <16 x float> %x1, <16 x float> %x2, i16 %x3) {
; CHECK-LABEL: test_int_x86_avx512_mask_unpckh_ps_512:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vunpckhps {{.*#+}} zmm3 = zmm0[2],zmm1[2],zmm0[3],zmm1[3],zmm0[6],zmm1[6],zmm0[7],zmm1[7],zmm0[10],zmm1[10],zmm0[11],zmm1[11],zmm0[14],zmm1[14],zmm0[15],zmm1[15]
; CHECK-NEXT:    kmovw %edi, %k1
; CHECK-NEXT:    vunpckhps {{.*#+}} zmm2 {%k1} = zmm0[2],zmm1[2],zmm0[3],zmm1[3],zmm0[6],zmm1[6],zmm0[7],zmm1[7],zmm0[10],zmm1[10],zmm0[11],zmm1[11],zmm0[14],zmm1[14],zmm0[15],zmm1[15]
; CHECK-NEXT:    vaddps %zmm3, %zmm2, %zmm0
; CHECK-NEXT:    retq
  %res = call <16 x float> @llvm.x86.avx512.mask.unpckh.ps.512(<16 x float> %x0, <16 x float> %x1, <16 x float> %x2, i16 %x3)
  %res1 = call <16 x float> @llvm.x86.avx512.mask.unpckh.ps.512(<16 x float> %x0, <16 x float> %x1, <16 x float> %x2, i16 -1)
  %res2 = fadd <16 x float> %res, %res1
  ret <16 x float> %res2
}

declare <8 x double> @llvm.x86.avx512.mask.unpckl.pd.512(<8 x double>, <8 x double>, <8 x double>, i8)

define <8 x double>@test_int_x86_avx512_mask_unpckl_pd_512(<8 x double> %x0, <8 x double> %x1, <8 x double> %x2, i8 %x3) {
; CHECK-LABEL: test_int_x86_avx512_mask_unpckl_pd_512:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vunpcklpd {{.*#+}} zmm3 = zmm0[0],zmm1[0],zmm0[2],zmm1[2],zmm0[4],zmm1[4],zmm0[6],zmm1[6]
; CHECK-NEXT:    kmovw %edi, %k1
; CHECK-NEXT:    vunpcklpd {{.*#+}} zmm2 {%k1} = zmm0[0],zmm1[0],zmm0[2],zmm1[2],zmm0[4],zmm1[4],zmm0[6],zmm1[6]
; CHECK-NEXT:    vaddpd %zmm3, %zmm2, %zmm0
; CHECK-NEXT:    retq
  %res = call <8 x double> @llvm.x86.avx512.mask.unpckl.pd.512(<8 x double> %x0, <8 x double> %x1, <8 x double> %x2, i8 %x3)
  %res1 = call <8 x double> @llvm.x86.avx512.mask.unpckl.pd.512(<8 x double> %x0, <8 x double> %x1, <8 x double> %x2, i8 -1)
  %res2 = fadd <8 x double> %res, %res1
  ret <8 x double> %res2
}

declare <16 x float> @llvm.x86.avx512.mask.unpckl.ps.512(<16 x float>, <16 x float>, <16 x float>, i16)

define <16 x float>@test_int_x86_avx512_mask_unpckl_ps_512(<16 x float> %x0, <16 x float> %x1, <16 x float> %x2, i16 %x3) {
; CHECK-LABEL: test_int_x86_avx512_mask_unpckl_ps_512:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vunpcklps {{.*#+}} zmm3 = zmm0[0],zmm1[0],zmm0[1],zmm1[1],zmm0[4],zmm1[4],zmm0[5],zmm1[5],zmm0[8],zmm1[8],zmm0[9],zmm1[9],zmm0[12],zmm1[12],zmm0[13],zmm1[13]
; CHECK-NEXT:    kmovw %edi, %k1
; CHECK-NEXT:    vunpcklps {{.*#+}} zmm2 {%k1} = zmm0[0],zmm1[0],zmm0[1],zmm1[1],zmm0[4],zmm1[4],zmm0[5],zmm1[5],zmm0[8],zmm1[8],zmm0[9],zmm1[9],zmm0[12],zmm1[12],zmm0[13],zmm1[13]
; CHECK-NEXT:    vaddps %zmm3, %zmm2, %zmm0
; CHECK-NEXT:    retq
  %res = call <16 x float> @llvm.x86.avx512.mask.unpckl.ps.512(<16 x float> %x0, <16 x float> %x1, <16 x float> %x2, i16 %x3)
  %res1 = call <16 x float> @llvm.x86.avx512.mask.unpckl.ps.512(<16 x float> %x0, <16 x float> %x1, <16 x float> %x2, i16 -1)
  %res2 = fadd <16 x float> %res, %res1
  ret <16 x float> %res2
}

declare <8 x i64> @llvm.x86.avx512.mask.punpcklqd.q.512(<8 x i64>, <8 x i64>, <8 x i64>, i8)

define <8 x i64>@test_int_x86_avx512_mask_punpcklqd_q_512(<8 x i64> %x0, <8 x i64> %x1, <8 x i64> %x2, i8 %x3) {
; CHECK-LABEL: test_int_x86_avx512_mask_punpcklqd_q_512:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpunpcklqdq {{.*#+}} zmm3 = zmm0[0],zmm1[0],zmm0[2],zmm1[2],zmm0[4],zmm1[4],zmm0[6],zmm1[6]
; CHECK-NEXT:    kmovw %edi, %k1
; CHECK-NEXT:    vpunpcklqdq {{.*#+}} zmm2 = zmm0[0],zmm1[0],zmm0[2],zmm1[2],zmm0[4],zmm1[4],zmm0[6],zmm1[6]
; CHECK-NEXT:    vpunpcklqdq {{.*#+}} zmm0 = zmm0[0],zmm1[0],zmm0[2],zmm1[2],zmm0[4],zmm1[4],zmm0[6],zmm1[6]
; CHECK-NEXT:    vpaddq %zmm3, %zmm2, %zmm1
; CHECK-NEXT:    vpaddq %zmm1, %zmm0, %zmm0
; CHECK-NEXT:    retq
  %res = call <8 x i64> @llvm.x86.avx512.mask.punpcklqd.q.512(<8 x i64> %x0, <8 x i64> %x1, <8 x i64> %x2, i8 %x3)
  %res1 = call <8 x i64> @llvm.x86.avx512.mask.punpcklqd.q.512(<8 x i64> %x0, <8 x i64> %x1, <8 x i64> %x2, i8 -1)
  %res2 = call <8 x i64> @llvm.x86.avx512.mask.punpcklqd.q.512(<8 x i64> %x0, <8 x i64> %x1, <8 x i64> zeroinitializer,i8 %x3)
  %res3 = add <8 x i64> %res, %res1
  %res4 = add <8 x i64> %res2, %res3
  ret <8 x i64> %res4
}

declare <8 x i64> @llvm.x86.avx512.mask.punpckhqd.q.512(<8 x i64>, <8 x i64>, <8 x i64>, i8)

define <8 x i64>@test_int_x86_avx512_mask_punpckhqd_q_512(<8 x i64> %x0, <8 x i64> %x1, <8 x i64> %x2, i8 %x3) {
; CHECK-LABEL: test_int_x86_avx512_mask_punpckhqd_q_512:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpunpckhqdq {{.*#+}} zmm3 = zmm0[1],zmm1[1],zmm0[3],zmm1[3],zmm0[5],zmm1[5],zmm0[7],zmm1[7]
; CHECK-NEXT:    kmovw %edi, %k1
; CHECK-NEXT:    vpunpckhqdq {{.*#+}} zmm2 = zmm0[1],zmm1[1],zmm0[3],zmm1[3],zmm0[5],zmm1[5],zmm0[7],zmm1[7]
; CHECK-NEXT:    vpaddq %zmm3, %zmm2, %zmm0
; CHECK-NEXT:    retq
  %res = call <8 x i64> @llvm.x86.avx512.mask.punpckhqd.q.512(<8 x i64> %x0, <8 x i64> %x1, <8 x i64> %x2, i8 %x3)
  %res1 = call <8 x i64> @llvm.x86.avx512.mask.punpckhqd.q.512(<8 x i64> %x0, <8 x i64> %x1, <8 x i64> %x2, i8 -1)
  %res2 = add <8 x i64> %res, %res1
  ret <8 x i64> %res2
}

declare <16 x i32> @llvm.x86.avx512.mask.punpckhd.q.512(<16 x i32>, <16 x i32>, <16 x i32>, i16)

define <16 x i32>@test_int_x86_avx512_mask_punpckhd_q_512(<16 x i32> %x0, <16 x i32> %x1, <16 x i32> %x2, i16 %x3) {
; CHECK-LABEL: test_int_x86_avx512_mask_punpckhd_q_512:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpunpckhdq {{.*#+}} zmm3 = zmm0[2],zmm1[2],zmm0[3],zmm1[3],zmm0[6],zmm1[6],zmm0[7],zmm1[7],zmm0[10],zmm1[10],zmm0[11],zmm1[11],zmm0[14],zmm1[14],zmm0[15],zmm1[15]
; CHECK-NEXT:    kmovw %edi, %k1
; CHECK-NEXT:    vpunpckhdq {{.*#+}} zmm2 {%k1} = zmm0[2],zmm1[2],zmm0[3],zmm1[3],zmm0[6],zmm1[6],zmm0[7],zmm1[7],zmm0[10],zmm1[10],zmm0[11],zmm1[11],zmm0[14],zmm1[14],zmm0[15],zmm1[15]
; CHECK-NEXT:    vpaddd %zmm3, %zmm2, %zmm0
; CHECK-NEXT:    retq
  %res = call <16 x i32> @llvm.x86.avx512.mask.punpckhd.q.512(<16 x i32> %x0, <16 x i32> %x1, <16 x i32> %x2, i16 %x3)
  %res1 = call <16 x i32> @llvm.x86.avx512.mask.punpckhd.q.512(<16 x i32> %x0, <16 x i32> %x1, <16 x i32> %x2, i16 -1)
  %res2 = add <16 x i32> %res, %res1
  ret <16 x i32> %res2
}

declare <16 x i32> @llvm.x86.avx512.mask.punpckld.q.512(<16 x i32>, <16 x i32>, <16 x i32>, i16)

define <16 x i32>@test_int_x86_avx512_mask_punpckld_q_512(<16 x i32> %x0, <16 x i32> %x1, <16 x i32> %x2, i16 %x3) {
; CHECK-LABEL: test_int_x86_avx512_mask_punpckld_q_512:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpunpckldq {{.*#+}} zmm3 = zmm0[0],zmm1[0],zmm0[1],zmm1[1],zmm0[4],zmm1[4],zmm0[5],zmm1[5],zmm0[8],zmm1[8],zmm0[9],zmm1[9],zmm0[12],zmm1[12],zmm0[13],zmm1[13]
; CHECK-NEXT:    kmovw %edi, %k1
; CHECK-NEXT:    vpunpckldq {{.*#+}} zmm2 {%k1} = zmm0[0],zmm1[0],zmm0[1],zmm1[1],zmm0[4],zmm1[4],zmm0[5],zmm1[5],zmm0[8],zmm1[8],zmm0[9],zmm1[9],zmm0[12],zmm1[12],zmm0[13],zmm1[13]
; CHECK-NEXT:    vpaddd %zmm3, %zmm2, %zmm0
; CHECK-NEXT:    retq
  %res = call <16 x i32> @llvm.x86.avx512.mask.punpckld.q.512(<16 x i32> %x0, <16 x i32> %x1, <16 x i32> %x2, i16 %x3)
  %res1 = call <16 x i32> @llvm.x86.avx512.mask.punpckld.q.512(<16 x i32> %x0, <16 x i32> %x1, <16 x i32> %x2, i16 -1)
  %res2 = add <16 x i32> %res, %res1
  ret <16 x i32> %res2
}

