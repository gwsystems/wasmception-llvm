; NOTE: Assertions have been autogenerated by update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mcpu=knl -mattr=+avx512bw -mattr=+avx512vl --show-mc-encoding| FileCheck %s

declare void @llvm.x86.avx512.mask.storeu.b.128(i8*, <16 x i8>, i16)

define void@test_int_x86_avx512_mask_storeu_b_128(i8* %ptr1, i8* %ptr2, <16 x i8> %x1, i16 %x2) {
; CHECK-LABEL: test_int_x86_avx512_mask_storeu_b_128:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1 ## encoding: [0xc5,0xf8,0x92,0xca]
; CHECK-NEXT:    vmovdqu8 %xmm0, (%rdi) {%k1} ## encoding: [0x62,0xf1,0x7f,0x09,0x7f,0x07]
; CHECK-NEXT:    vmovdqu8 %xmm0, (%rsi) ## encoding: [0x62,0xf1,0x7f,0x08,0x7f,0x06]
; CHECK-NEXT:    retq ## encoding: [0xc3]
  call void @llvm.x86.avx512.mask.storeu.b.128(i8* %ptr1, <16 x i8> %x1, i16 %x2)
  call void @llvm.x86.avx512.mask.storeu.b.128(i8* %ptr2, <16 x i8> %x1, i16 -1)
  ret void
}

declare void @llvm.x86.avx512.mask.storeu.b.256(i8*, <32 x i8>, i32)

define void@test_int_x86_avx512_mask_storeu_b_256(i8* %ptr1, i8* %ptr2, <32 x i8> %x1, i32 %x2) {
; CHECK-LABEL: test_int_x86_avx512_mask_storeu_b_256:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovd %edx, %k1 ## encoding: [0xc5,0xfb,0x92,0xca]
; CHECK-NEXT:    vmovdqu8 %ymm0, (%rdi) {%k1} ## encoding: [0x62,0xf1,0x7f,0x29,0x7f,0x07]
; CHECK-NEXT:    vmovdqu8 %ymm0, (%rsi) ## encoding: [0x62,0xf1,0x7f,0x28,0x7f,0x06]
; CHECK-NEXT:    retq ## encoding: [0xc3]
  call void @llvm.x86.avx512.mask.storeu.b.256(i8* %ptr1, <32 x i8> %x1, i32 %x2)
  call void @llvm.x86.avx512.mask.storeu.b.256(i8* %ptr2, <32 x i8> %x1, i32 -1)
  ret void
}

declare void @llvm.x86.avx512.mask.storeu.w.128(i8*, <8 x i16>, i8)

define void@test_int_x86_avx512_mask_storeu_w_128(i8* %ptr1, i8* %ptr2, <8 x i16> %x1, i8 %x2) {
; CHECK-LABEL: test_int_x86_avx512_mask_storeu_w_128:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1 ## encoding: [0xc5,0xf8,0x92,0xca]
; CHECK-NEXT:    vmovdqu16 %xmm0, (%rdi) {%k1} ## encoding: [0x62,0xf1,0xff,0x09,0x7f,0x07]
; CHECK-NEXT:    vmovdqu16 %xmm0, (%rsi) ## encoding: [0x62,0xf1,0xff,0x08,0x7f,0x06]
; CHECK-NEXT:    retq ## encoding: [0xc3]
  call void @llvm.x86.avx512.mask.storeu.w.128(i8* %ptr1, <8 x i16> %x1, i8 %x2)
  call void @llvm.x86.avx512.mask.storeu.w.128(i8* %ptr2, <8 x i16> %x1, i8 -1)
  ret void
}

declare void @llvm.x86.avx512.mask.storeu.w.256(i8*, <16 x i16>, i16)

define void@test_int_x86_avx512_mask_storeu_w_256(i8* %ptr1, i8* %ptr2, <16 x i16> %x1, i16 %x2) {
; CHECK-LABEL: test_int_x86_avx512_mask_storeu_w_256:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1 ## encoding: [0xc5,0xf8,0x92,0xca]
; CHECK-NEXT:    vmovdqu16 %ymm0, (%rdi) {%k1} ## encoding: [0x62,0xf1,0xff,0x29,0x7f,0x07]
; CHECK-NEXT:    vmovdqu16 %ymm0, (%rsi) ## encoding: [0x62,0xf1,0xff,0x28,0x7f,0x06]
; CHECK-NEXT:    retq ## encoding: [0xc3]
  call void @llvm.x86.avx512.mask.storeu.w.256(i8* %ptr1, <16 x i16> %x1, i16 %x2)
  call void @llvm.x86.avx512.mask.storeu.w.256(i8* %ptr2, <16 x i16> %x1, i16 -1)
  ret void
}

declare <8 x i16> @llvm.x86.avx512.mask.loadu.w.128(i8*, <8 x i16>, i8)

define <8 x i16>@test_int_x86_avx512_mask_loadu_w_128(i8* %ptr, i8* %ptr2, <8 x i16> %x1, i8 %mask) {
; CHECK-LABEL: test_int_x86_avx512_mask_loadu_w_128:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vmovdqu16 (%rdi), %xmm0 ## encoding: [0x62,0xf1,0xff,0x08,0x6f,0x07]
; CHECK-NEXT:    kmovw %edx, %k1 ## encoding: [0xc5,0xf8,0x92,0xca]
; CHECK-NEXT:    vmovdqu16 (%rsi), %xmm0 {%k1} ## encoding: [0x62,0xf1,0xff,0x09,0x6f,0x06]
; CHECK-NEXT:    vmovdqu16 (%rdi), %xmm1 {%k1} {z} ## encoding: [0x62,0xf1,0xff,0x89,0x6f,0x0f]
; CHECK-NEXT:    vpaddw %xmm1, %xmm0, %xmm0 ## encoding: [0x62,0xf1,0x7d,0x08,0xfd,0xc1]
; CHECK-NEXT:    retq ## encoding: [0xc3]
    %res0 = call <8 x i16> @llvm.x86.avx512.mask.loadu.w.128(i8* %ptr, <8 x i16> %x1, i8 -1)
    %res = call <8 x i16> @llvm.x86.avx512.mask.loadu.w.128(i8* %ptr2, <8 x i16> %res0, i8 %mask)
    %res1 = call <8 x i16> @llvm.x86.avx512.mask.loadu.w.128(i8* %ptr, <8 x i16> zeroinitializer, i8 %mask)
    %res2 = add <8 x i16> %res, %res1
    ret <8 x i16> %res2
}

declare <16 x i16> @llvm.x86.avx512.mask.loadu.w.256(i8*, <16 x i16>, i16)

define <16 x i16>@test_int_x86_avx512_mask_loadu_w_256(i8* %ptr, i8* %ptr2, <16 x i16> %x1, i16 %mask) {
; CHECK-LABEL: test_int_x86_avx512_mask_loadu_w_256:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vmovdqu16 (%rdi), %ymm0 ## encoding: [0x62,0xf1,0xff,0x28,0x6f,0x07]
; CHECK-NEXT:    kmovw %edx, %k1 ## encoding: [0xc5,0xf8,0x92,0xca]
; CHECK-NEXT:    vmovdqu16 (%rsi), %ymm0 {%k1} ## encoding: [0x62,0xf1,0xff,0x29,0x6f,0x06]
; CHECK-NEXT:    vmovdqu16 (%rdi), %ymm1 {%k1} {z} ## encoding: [0x62,0xf1,0xff,0xa9,0x6f,0x0f]
; CHECK-NEXT:    vpaddw %ymm1, %ymm0, %ymm0 ## encoding: [0x62,0xf1,0x7d,0x28,0xfd,0xc1]
; CHECK-NEXT:    retq ## encoding: [0xc3]
    %res0 = call <16 x i16> @llvm.x86.avx512.mask.loadu.w.256(i8* %ptr, <16 x i16> %x1, i16 -1)
    %res = call <16 x i16> @llvm.x86.avx512.mask.loadu.w.256(i8* %ptr2, <16 x i16> %res0, i16 %mask)
    %res1 = call <16 x i16> @llvm.x86.avx512.mask.loadu.w.256(i8* %ptr, <16 x i16> zeroinitializer, i16 %mask)
    %res2 = add <16 x i16> %res, %res1
    ret <16 x i16> %res2
}

declare <16 x i8> @llvm.x86.avx512.mask.loadu.b.128(i8*, <16 x i8>, i16)

define <16 x i8>@test_int_x86_avx512_mask_loadu_b_128(i8* %ptr, i8* %ptr2, <16 x i8> %x1, i16 %mask) {
; CHECK-LABEL: test_int_x86_avx512_mask_loadu_b_128:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vmovdqu8 (%rdi), %xmm0 ## encoding: [0x62,0xf1,0x7f,0x08,0x6f,0x07]
; CHECK-NEXT:    kmovw %edx, %k1 ## encoding: [0xc5,0xf8,0x92,0xca]
; CHECK-NEXT:    vmovdqu8 (%rsi), %xmm0 {%k1} ## encoding: [0x62,0xf1,0x7f,0x09,0x6f,0x06]
; CHECK-NEXT:    vmovdqu8 (%rdi), %xmm1 {%k1} {z} ## encoding: [0x62,0xf1,0x7f,0x89,0x6f,0x0f]
; CHECK-NEXT:    vpaddb %xmm1, %xmm0, %xmm0 ## encoding: [0x62,0xf1,0x7d,0x08,0xfc,0xc1]
; CHECK-NEXT:    retq ## encoding: [0xc3]
    %res0 = call <16 x i8> @llvm.x86.avx512.mask.loadu.b.128(i8* %ptr, <16 x i8> %x1, i16 -1)
    %res = call <16 x i8> @llvm.x86.avx512.mask.loadu.b.128(i8* %ptr2, <16 x i8> %res0, i16 %mask)
    %res1 = call <16 x i8> @llvm.x86.avx512.mask.loadu.b.128(i8* %ptr, <16 x i8> zeroinitializer, i16 %mask)
    %res2 = add <16 x i8> %res, %res1
    ret <16 x i8> %res2
}

declare <32 x i8> @llvm.x86.avx512.mask.loadu.b.256(i8*, <32 x i8>, i32)

define <32 x i8>@test_int_x86_avx512_mask_loadu_b_256(i8* %ptr, i8* %ptr2, <32 x i8> %x1, i32 %mask) {
; CHECK-LABEL: test_int_x86_avx512_mask_loadu_b_256:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vmovdqu8 (%rdi), %ymm0 ## encoding: [0x62,0xf1,0x7f,0x28,0x6f,0x07]
; CHECK-NEXT:    kmovd %edx, %k1 ## encoding: [0xc5,0xfb,0x92,0xca]
; CHECK-NEXT:    vmovdqu8 (%rsi), %ymm0 {%k1} ## encoding: [0x62,0xf1,0x7f,0x29,0x6f,0x06]
; CHECK-NEXT:    vmovdqu8 (%rdi), %ymm1 {%k1} {z} ## encoding: [0x62,0xf1,0x7f,0xa9,0x6f,0x0f]
; CHECK-NEXT:    vpaddb %ymm1, %ymm0, %ymm0 ## encoding: [0x62,0xf1,0x7d,0x28,0xfc,0xc1]
; CHECK-NEXT:    retq ## encoding: [0xc3]
    %res0 = call <32 x i8> @llvm.x86.avx512.mask.loadu.b.256(i8* %ptr, <32 x i8> %x1, i32 -1)
    %res = call <32 x i8> @llvm.x86.avx512.mask.loadu.b.256(i8* %ptr2, <32 x i8> %res0, i32 %mask)
    %res1 = call <32 x i8> @llvm.x86.avx512.mask.loadu.b.256(i8* %ptr, <32 x i8> zeroinitializer, i32 %mask)
    %res2 = add <32 x i8> %res, %res1
    ret <32 x i8> %res2
}

declare <16 x i8> @llvm.x86.avx512.mask.palignr.128(<16 x i8>, <16 x i8>, i32, <16 x i8>, i16)

define <16 x i8>@test_int_x86_avx512_mask_palignr_128(<16 x i8> %x0, <16 x i8> %x1, <16 x i8> %x3, i16 %x4) {
; CHECK-LABEL: test_int_x86_avx512_mask_palignr_128:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpalignr $2, %xmm1, %xmm0, %xmm3 ## encoding: [0x62,0xf3,0x7d,0x08,0x0f,0xd9,0x02]
; CHECK-NEXT:    kmovw %edi, %k1 ## encoding: [0xc5,0xf8,0x92,0xcf]
; CHECK-NEXT:    vpalignr $2, %xmm1, %xmm0, %xmm2 {%k1} ## encoding: [0x62,0xf3,0x7d,0x09,0x0f,0xd1,0x02]
; CHECK-NEXT:    vpalignr $2, %xmm1, %xmm0, %xmm0 {%k1} {z} ## encoding: [0x62,0xf3,0x7d,0x89,0x0f,0xc1,0x02]
; CHECK-NEXT:    vpaddb %xmm0, %xmm2, %xmm0 ## encoding: [0x62,0xf1,0x6d,0x08,0xfc,0xc0]
; CHECK-NEXT:    vpaddb %xmm3, %xmm0, %xmm0 ## encoding: [0x62,0xf1,0x7d,0x08,0xfc,0xc3]
; CHECK-NEXT:    retq ## encoding: [0xc3]
  %res = call <16 x i8> @llvm.x86.avx512.mask.palignr.128(<16 x i8> %x0, <16 x i8> %x1, i32 2, <16 x i8> %x3, i16 %x4)
  %res1 = call <16 x i8> @llvm.x86.avx512.mask.palignr.128(<16 x i8> %x0, <16 x i8> %x1, i32 2, <16 x i8> zeroinitializer, i16 %x4)
  %res2 = call <16 x i8> @llvm.x86.avx512.mask.palignr.128(<16 x i8> %x0, <16 x i8> %x1, i32 2, <16 x i8> %x3, i16 -1)
  %res3 = add <16 x i8> %res, %res1
  %res4 = add <16 x i8> %res3, %res2
  ret <16 x i8> %res4
}

declare <32 x i8> @llvm.x86.avx512.mask.palignr.256(<32 x i8>, <32 x i8>, i32, <32 x i8>, i32)

define <32 x i8>@test_int_x86_avx512_mask_palignr_256(<32 x i8> %x0, <32 x i8> %x1, <32 x i8> %x3, i32 %x4) {
; CHECK-LABEL: test_int_x86_avx512_mask_palignr_256:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpalignr $2, %ymm1, %ymm0, %ymm3 ## encoding: [0x62,0xf3,0x7d,0x28,0x0f,0xd9,0x02]
; CHECK-NEXT:    kmovd %edi, %k1 ## encoding: [0xc5,0xfb,0x92,0xcf]
; CHECK-NEXT:    vpalignr $2, %ymm1, %ymm0, %ymm2 {%k1} ## encoding: [0x62,0xf3,0x7d,0x29,0x0f,0xd1,0x02]
; CHECK-NEXT:    vpalignr $2, %ymm1, %ymm0, %ymm0 {%k1} {z} ## encoding: [0x62,0xf3,0x7d,0xa9,0x0f,0xc1,0x02]
; CHECK-NEXT:    vpaddb %ymm0, %ymm2, %ymm0 ## encoding: [0x62,0xf1,0x6d,0x28,0xfc,0xc0]
; CHECK-NEXT:    vpaddb %ymm3, %ymm0, %ymm0 ## encoding: [0x62,0xf1,0x7d,0x28,0xfc,0xc3]
; CHECK-NEXT:    retq ## encoding: [0xc3]
  %res = call <32 x i8> @llvm.x86.avx512.mask.palignr.256(<32 x i8> %x0, <32 x i8> %x1, i32 2, <32 x i8> %x3, i32 %x4)
  %res1 = call <32 x i8> @llvm.x86.avx512.mask.palignr.256(<32 x i8> %x0, <32 x i8> %x1, i32 2, <32 x i8> zeroinitializer, i32 %x4)
  %res2 = call <32 x i8> @llvm.x86.avx512.mask.palignr.256(<32 x i8> %x0, <32 x i8> %x1, i32 2, <32 x i8> %x3, i32 -1)
  %res3 = add <32 x i8> %res, %res1
  %res4 = add <32 x i8> %res3, %res2
  ret <32 x i8> %res4
}
