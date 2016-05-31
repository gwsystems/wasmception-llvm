; NOTE: Assertions have been autogenerated by update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mcpu=knl -mattr=+avx512vl --show-mc-encoding| FileCheck %s

declare void @llvm.x86.avx512.mask.store.pd.128(i8*, <2 x double>, i8)

define void@test_int_x86_avx512_mask_store_pd_128(i8* %ptr1, i8* %ptr2, <2 x double> %x1, i8 %x2) {
; CHECK-LABEL: test_int_x86_avx512_mask_store_pd_128:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1 ## encoding: [0xc5,0xf8,0x92,0xca]
; CHECK-NEXT:    vmovapd %xmm0, (%rdi) {%k1} ## encoding: [0x62,0xf1,0xfd,0x09,0x29,0x07]
; CHECK-NEXT:    vmovapd %xmm0, (%rsi) ## encoding: [0x62,0xf1,0xfd,0x08,0x29,0x06]
; CHECK-NEXT:    retq ## encoding: [0xc3]
  call void @llvm.x86.avx512.mask.store.pd.128(i8* %ptr1, <2 x double> %x1, i8 %x2)
  call void @llvm.x86.avx512.mask.store.pd.128(i8* %ptr2, <2 x double> %x1, i8 -1)
  ret void
}

declare void @llvm.x86.avx512.mask.store.pd.256(i8*, <4 x double>, i8)

define void@test_int_x86_avx512_mask_store_pd_256(i8* %ptr1, i8* %ptr2, <4 x double> %x1, i8 %x2) {
; CHECK-LABEL: test_int_x86_avx512_mask_store_pd_256:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1 ## encoding: [0xc5,0xf8,0x92,0xca]
; CHECK-NEXT:    vmovapd %ymm0, (%rdi) {%k1} ## encoding: [0x62,0xf1,0xfd,0x29,0x29,0x07]
; CHECK-NEXT:    vmovapd %ymm0, (%rsi) ## encoding: [0x62,0xf1,0xfd,0x28,0x29,0x06]
; CHECK-NEXT:    retq ## encoding: [0xc3]
  call void @llvm.x86.avx512.mask.store.pd.256(i8* %ptr1, <4 x double> %x1, i8 %x2)
  call void @llvm.x86.avx512.mask.store.pd.256(i8* %ptr2, <4 x double> %x1, i8 -1)
  ret void
}

declare void @llvm.x86.avx512.mask.storeu.pd.128(i8*, <2 x double>, i8)

define void@test_int_x86_avx512_mask_storeu_pd_128(i8* %ptr1, i8* %ptr2, <2 x double> %x1, i8 %x2) {
; CHECK-LABEL: test_int_x86_avx512_mask_storeu_pd_128:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1 ## encoding: [0xc5,0xf8,0x92,0xca]
; CHECK-NEXT:    vmovupd %xmm0, (%rdi) {%k1} ## encoding: [0x62,0xf1,0xfd,0x09,0x11,0x07]
; CHECK-NEXT:    vmovupd %xmm0, (%rsi) ## encoding: [0x62,0xf1,0xfd,0x08,0x11,0x06]
; CHECK-NEXT:    retq ## encoding: [0xc3]
  call void @llvm.x86.avx512.mask.storeu.pd.128(i8* %ptr1, <2 x double> %x1, i8 %x2)
  call void @llvm.x86.avx512.mask.storeu.pd.128(i8* %ptr2, <2 x double> %x1, i8 -1)
  ret void
}

declare void @llvm.x86.avx512.mask.storeu.pd.256(i8*, <4 x double>, i8)

define void@test_int_x86_avx512_mask_storeu_pd_256(i8* %ptr1, i8* %ptr2, <4 x double> %x1, i8 %x2) {
; CHECK-LABEL: test_int_x86_avx512_mask_storeu_pd_256:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1 ## encoding: [0xc5,0xf8,0x92,0xca]
; CHECK-NEXT:    vmovupd %ymm0, (%rdi) {%k1} ## encoding: [0x62,0xf1,0xfd,0x29,0x11,0x07]
; CHECK-NEXT:    vmovupd %ymm0, (%rsi) ## encoding: [0x62,0xf1,0xfd,0x28,0x11,0x06]
; CHECK-NEXT:    retq ## encoding: [0xc3]
  call void @llvm.x86.avx512.mask.storeu.pd.256(i8* %ptr1, <4 x double> %x1, i8 %x2)
  call void @llvm.x86.avx512.mask.storeu.pd.256(i8* %ptr2, <4 x double> %x1, i8 -1)
  ret void
}

declare void @llvm.x86.avx512.mask.store.ps.128(i8*, <4 x float>, i8)

define void@test_int_x86_avx512_mask_store_ps_128(i8* %ptr1, i8* %ptr2, <4 x float> %x1, i8 %x2) {
; CHECK-LABEL: test_int_x86_avx512_mask_store_ps_128:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1 ## encoding: [0xc5,0xf8,0x92,0xca]
; CHECK-NEXT:    vmovaps %xmm0, (%rdi) {%k1} ## encoding: [0x62,0xf1,0x7c,0x09,0x29,0x07]
; CHECK-NEXT:    vmovaps %xmm0, (%rsi) ## encoding: [0x62,0xf1,0x7c,0x08,0x29,0x06]
; CHECK-NEXT:    retq ## encoding: [0xc3]
    call void @llvm.x86.avx512.mask.store.ps.128(i8* %ptr1, <4 x float> %x1, i8 %x2)
    call void @llvm.x86.avx512.mask.store.ps.128(i8* %ptr2, <4 x float> %x1, i8 -1)
    ret void
}

declare void @llvm.x86.avx512.mask.store.ps.256(i8*, <8 x float>, i8)

define void@test_int_x86_avx512_mask_store_ps_256(i8* %ptr1, i8* %ptr2, <8 x float> %x1, i8 %x2) {
; CHECK-LABEL: test_int_x86_avx512_mask_store_ps_256:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1 ## encoding: [0xc5,0xf8,0x92,0xca]
; CHECK-NEXT:    vmovaps %ymm0, (%rdi) {%k1} ## encoding: [0x62,0xf1,0x7c,0x29,0x29,0x07]
; CHECK-NEXT:    vmovaps %ymm0, (%rsi) ## encoding: [0x62,0xf1,0x7c,0x28,0x29,0x06]
; CHECK-NEXT:    retq ## encoding: [0xc3]
    call void @llvm.x86.avx512.mask.store.ps.256(i8* %ptr1, <8 x float> %x1, i8 %x2)
    call void @llvm.x86.avx512.mask.store.ps.256(i8* %ptr2, <8 x float> %x1, i8 -1)
    ret void
}

declare void @llvm.x86.avx512.mask.storeu.ps.128(i8*, <4 x float>, i8)

define void@test_int_x86_avx512_mask_storeu_ps_128(i8* %ptr1, i8* %ptr2, <4 x float> %x1, i8 %x2) {
; CHECK-LABEL: test_int_x86_avx512_mask_storeu_ps_128:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1 ## encoding: [0xc5,0xf8,0x92,0xca]
; CHECK-NEXT:    vmovups %xmm0, (%rdi) {%k1} ## encoding: [0x62,0xf1,0x7c,0x09,0x11,0x07]
; CHECK-NEXT:    vmovups %xmm0, (%rsi) ## encoding: [0x62,0xf1,0x7c,0x08,0x11,0x06]
; CHECK-NEXT:    retq ## encoding: [0xc3]
    call void @llvm.x86.avx512.mask.storeu.ps.128(i8* %ptr1, <4 x float> %x1, i8 %x2)
    call void @llvm.x86.avx512.mask.storeu.ps.128(i8* %ptr2, <4 x float> %x1, i8 -1)
    ret void
}

declare void @llvm.x86.avx512.mask.storeu.ps.256(i8*, <8 x float>, i8)

define void@test_int_x86_avx512_mask_storeu_ps_256(i8* %ptr1, i8* %ptr2, <8 x float> %x1, i8 %x2) {
; CHECK-LABEL: test_int_x86_avx512_mask_storeu_ps_256:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1 ## encoding: [0xc5,0xf8,0x92,0xca]
; CHECK-NEXT:    vmovups %ymm0, (%rdi) {%k1} ## encoding: [0x62,0xf1,0x7c,0x29,0x11,0x07]
; CHECK-NEXT:    vmovups %ymm0, (%rsi) ## encoding: [0x62,0xf1,0x7c,0x28,0x11,0x06]
; CHECK-NEXT:    retq ## encoding: [0xc3]
    call void @llvm.x86.avx512.mask.storeu.ps.256(i8* %ptr1, <8 x float> %x1, i8 %x2)
    call void @llvm.x86.avx512.mask.storeu.ps.256(i8* %ptr2, <8 x float> %x1, i8 -1)
    ret void
}

declare void @llvm.x86.avx512.mask.storeu.q.128(i8*, <2 x i64>, i8)

define void@test_int_x86_avx512_mask_storeu_q_128(i8* %ptr1, i8* %ptr2, <2 x i64> %x1, i8 %x2) {
; CHECK-LABEL: test_int_x86_avx512_mask_storeu_q_128:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1 ## encoding: [0xc5,0xf8,0x92,0xca]
; CHECK-NEXT:    vmovdqu64 %xmm0, (%rdi) {%k1} ## encoding: [0x62,0xf1,0xfe,0x09,0x7f,0x07]
; CHECK-NEXT:    vmovdqu64 %xmm0, (%rsi) ## encoding: [0x62,0xf1,0xfe,0x08,0x7f,0x06]
; CHECK-NEXT:    retq ## encoding: [0xc3]
  call void @llvm.x86.avx512.mask.storeu.q.128(i8* %ptr1, <2 x i64> %x1, i8 %x2)
  call void @llvm.x86.avx512.mask.storeu.q.128(i8* %ptr2, <2 x i64> %x1, i8 -1)
  ret void
}

declare void @llvm.x86.avx512.mask.storeu.q.256(i8*, <4 x i64>, i8)

define void@test_int_x86_avx512_mask_storeu_q_256(i8* %ptr1, i8* %ptr2, <4 x i64> %x1, i8 %x2) {
; CHECK-LABEL: test_int_x86_avx512_mask_storeu_q_256:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1 ## encoding: [0xc5,0xf8,0x92,0xca]
; CHECK-NEXT:    vmovdqu64 %ymm0, (%rdi) {%k1} ## encoding: [0x62,0xf1,0xfe,0x29,0x7f,0x07]
; CHECK-NEXT:    vmovdqu64 %ymm0, (%rsi) ## encoding: [0x62,0xf1,0xfe,0x28,0x7f,0x06]
; CHECK-NEXT:    retq ## encoding: [0xc3]
  call void @llvm.x86.avx512.mask.storeu.q.256(i8* %ptr1, <4 x i64> %x1, i8 %x2)
  call void @llvm.x86.avx512.mask.storeu.q.256(i8* %ptr2, <4 x i64> %x1, i8 -1)
  ret void
}

declare void @llvm.x86.avx512.mask.storeu.d.128(i8*, <4 x i32>, i8)

define void@test_int_x86_avx512_mask_storeu_d_128(i8* %ptr1, i8* %ptr2, <4 x i32> %x1, i8 %x2) {
; CHECK-LABEL: test_int_x86_avx512_mask_storeu_d_128:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1 ## encoding: [0xc5,0xf8,0x92,0xca]
; CHECK-NEXT:    vmovdqu32 %xmm0, (%rdi) {%k1} ## encoding: [0x62,0xf1,0x7e,0x09,0x7f,0x07]
; CHECK-NEXT:    vmovdqu32 %xmm0, (%rsi) ## encoding: [0x62,0xf1,0x7e,0x08,0x7f,0x06]
; CHECK-NEXT:    retq ## encoding: [0xc3]
  call void @llvm.x86.avx512.mask.storeu.d.128(i8* %ptr1, <4 x i32> %x1, i8 %x2)
  call void @llvm.x86.avx512.mask.storeu.d.128(i8* %ptr2, <4 x i32> %x1, i8 -1)
  ret void
}

declare void @llvm.x86.avx512.mask.storeu.d.256(i8*, <8 x i32>, i8)

define void@test_int_x86_avx512_mask_storeu_d_256(i8* %ptr1, i8* %ptr2, <8 x i32> %x1, i8 %x2) {
; CHECK-LABEL: test_int_x86_avx512_mask_storeu_d_256:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1 ## encoding: [0xc5,0xf8,0x92,0xca]
; CHECK-NEXT:    vmovdqu32 %ymm0, (%rdi) {%k1} ## encoding: [0x62,0xf1,0x7e,0x29,0x7f,0x07]
; CHECK-NEXT:    vmovdqu32 %ymm0, (%rsi) ## encoding: [0x62,0xf1,0x7e,0x28,0x7f,0x06]
; CHECK-NEXT:    retq ## encoding: [0xc3]
  call void @llvm.x86.avx512.mask.storeu.d.256(i8* %ptr1, <8 x i32> %x1, i8 %x2)
  call void @llvm.x86.avx512.mask.storeu.d.256(i8* %ptr2, <8 x i32> %x1, i8 -1)
  ret void
}

declare void @llvm.x86.avx512.mask.store.q.128(i8*, <2 x i64>, i8)

define void@test_int_x86_avx512_mask_store_q_128(i8* %ptr1, i8* %ptr2, <2 x i64> %x1, i8 %x2) {
; CHECK-LABEL: test_int_x86_avx512_mask_store_q_128:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1 ## encoding: [0xc5,0xf8,0x92,0xca]
; CHECK-NEXT:    vmovdqa64 %xmm0, (%rdi) {%k1} ## encoding: [0x62,0xf1,0xfd,0x09,0x7f,0x07]
; CHECK-NEXT:    vmovdqa64 %xmm0, (%rsi) ## encoding: [0x62,0xf1,0xfd,0x08,0x7f,0x06]
; CHECK-NEXT:    retq ## encoding: [0xc3]
  call void @llvm.x86.avx512.mask.store.q.128(i8* %ptr1, <2 x i64> %x1, i8 %x2)
  call void @llvm.x86.avx512.mask.store.q.128(i8* %ptr2, <2 x i64> %x1, i8 -1)
  ret void
}

declare void @llvm.x86.avx512.mask.store.q.256(i8*, <4 x i64>, i8)

define void@test_int_x86_avx512_mask_store_q_256(i8* %ptr1, i8* %ptr2, <4 x i64> %x1, i8 %x2) {
; CHECK-LABEL: test_int_x86_avx512_mask_store_q_256:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1 ## encoding: [0xc5,0xf8,0x92,0xca]
; CHECK-NEXT:    vmovdqa64 %ymm0, (%rdi) {%k1} ## encoding: [0x62,0xf1,0xfd,0x29,0x7f,0x07]
; CHECK-NEXT:    vmovdqa64 %ymm0, (%rsi) ## encoding: [0x62,0xf1,0xfd,0x28,0x7f,0x06]
; CHECK-NEXT:    retq ## encoding: [0xc3]
  call void @llvm.x86.avx512.mask.store.q.256(i8* %ptr1, <4 x i64> %x1, i8 %x2)
  call void @llvm.x86.avx512.mask.store.q.256(i8* %ptr2, <4 x i64> %x1, i8 -1)
  ret void
}

declare void @llvm.x86.avx512.mask.store.d.128(i8*, <4 x i32>, i8)

define void@test_int_x86_avx512_mask_store_d_128(i8* %ptr1, i8* %ptr2, <4 x i32> %x1, i8 %x2) {
; CHECK-LABEL: test_int_x86_avx512_mask_store_d_128:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1 ## encoding: [0xc5,0xf8,0x92,0xca]
; CHECK-NEXT:    vmovdqa32 %xmm0, (%rdi) {%k1} ## encoding: [0x62,0xf1,0x7d,0x09,0x7f,0x07]
; CHECK-NEXT:    vmovdqa32 %xmm0, (%rsi) ## encoding: [0x62,0xf1,0x7d,0x08,0x7f,0x06]
; CHECK-NEXT:    retq ## encoding: [0xc3]
  call void @llvm.x86.avx512.mask.store.d.128(i8* %ptr1, <4 x i32> %x1, i8 %x2)
  call void @llvm.x86.avx512.mask.store.d.128(i8* %ptr2, <4 x i32> %x1, i8 -1)
  ret void
}

declare void @llvm.x86.avx512.mask.store.d.256(i8*, <8 x i32>, i8)

define void@test_int_x86_avx512_mask_store_d_256(i8* %ptr1, i8* %ptr2, <8 x i32> %x1, i8 %x2) {
; CHECK-LABEL: test_int_x86_avx512_mask_store_d_256:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1 ## encoding: [0xc5,0xf8,0x92,0xca]
; CHECK-NEXT:    vmovdqa32 %ymm0, (%rdi) {%k1} ## encoding: [0x62,0xf1,0x7d,0x29,0x7f,0x07]
; CHECK-NEXT:    vmovdqa32 %ymm0, (%rsi) ## encoding: [0x62,0xf1,0x7d,0x28,0x7f,0x06]
; CHECK-NEXT:    retq ## encoding: [0xc3]
  call void @llvm.x86.avx512.mask.store.d.256(i8* %ptr1, <8 x i32> %x1, i8 %x2)
  call void @llvm.x86.avx512.mask.store.d.256(i8* %ptr2, <8 x i32> %x1, i8 -1)
  ret void
}
