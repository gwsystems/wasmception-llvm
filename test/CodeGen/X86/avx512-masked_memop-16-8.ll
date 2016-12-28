; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=x86_64-apple-darwin -mattr=avx512f,avx512bw,avx512vl < %s | FileCheck %s

; Skylake-avx512 target supports masked load/store for i8 and i16 vectors

define <16 x i8> @test_mask_load_16xi8(<16 x i1> %mask, <16 x i8>* %addr, <16 x i8> %val) {
; CHECK-LABEL: test_mask_load_16xi8:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpsllw $7, %xmm0, %xmm0
; CHECK-NEXT:    vpmovb2m %xmm0, %k1
; CHECK-NEXT:    vmovdqu8 (%rdi), %xmm0 {%k1} {z}
; CHECK-NEXT:    retq
  %res = call <16 x i8> @llvm.masked.load.v16i8.p0v16i8(<16 x i8>* %addr, i32 4, <16 x i1>%mask, <16 x i8> undef)
  ret <16 x i8> %res
}
declare <16 x i8> @llvm.masked.load.v16i8.p0v16i8(<16 x i8>*, i32, <16 x i1>, <16 x i8>)

define <32 x i8> @test_mask_load_32xi8(<32 x i1> %mask, <32 x i8>* %addr, <32 x i8> %val) {
; CHECK-LABEL: test_mask_load_32xi8:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpsllw $7, %ymm0, %ymm0
; CHECK-NEXT:    vpmovb2m %ymm0, %k1
; CHECK-NEXT:    vmovdqu8 (%rdi), %ymm1 {%k1}
; CHECK-NEXT:    vmovdqa %ymm1, %ymm0
; CHECK-NEXT:    retq
  %res = call <32 x i8> @llvm.masked.load.v32i8.p0v32i8(<32 x i8>* %addr, i32 4, <32 x i1>%mask, <32 x i8> %val)
  ret <32 x i8> %res
}
declare <32 x i8> @llvm.masked.load.v32i8.p0v32i8(<32 x i8>*, i32, <32 x i1>, <32 x i8>)

define <64 x i8> @test_mask_load_64xi8(<64 x i1> %mask, <64 x i8>* %addr, <64 x i8> %val) {
; CHECK-LABEL: test_mask_load_64xi8:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpsllw $7, %zmm0, %zmm0
; CHECK-NEXT:    vpmovb2m %zmm0, %k1
; CHECK-NEXT:    vmovdqu8 (%rdi), %zmm1 {%k1}
; CHECK-NEXT:    vmovdqa64 %zmm1, %zmm0
; CHECK-NEXT:    retq
  %res = call <64 x i8> @llvm.masked.load.v64i8.p0v64i8(<64 x i8>* %addr, i32 4, <64 x i1>%mask, <64 x i8> %val)
  ret <64 x i8> %res
}
declare <64 x i8> @llvm.masked.load.v64i8.p0v64i8(<64 x i8>*, i32, <64 x i1>, <64 x i8>)

define <8 x i16> @test_mask_load_8xi16(<8 x i1> %mask, <8 x i16>* %addr, <8 x i16> %val) {
; CHECK-LABEL: test_mask_load_8xi16:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpsllw $15, %xmm0, %xmm0
; CHECK-NEXT:    vpmovw2m %xmm0, %k1
; CHECK-NEXT:    vmovdqu16 (%rdi), %xmm0 {%k1} {z}
; CHECK-NEXT:    retq
  %res = call <8 x i16> @llvm.masked.load.v8i16.p0v8i16(<8 x i16>* %addr, i32 4, <8 x i1>%mask, <8 x i16> undef)
  ret <8 x i16> %res
}
declare <8 x i16> @llvm.masked.load.v8i16.p0v8i16(<8 x i16>*, i32, <8 x i1>, <8 x i16>)

define <16 x i16> @test_mask_load_16xi16(<16 x i1> %mask, <16 x i16>* %addr, <16 x i16> %val) {
; CHECK-LABEL: test_mask_load_16xi16:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpsllw $7, %xmm0, %xmm0
; CHECK-NEXT:    vpmovb2m %xmm0, %k1
; CHECK-NEXT:    vmovdqu16 (%rdi), %ymm0 {%k1} {z}
; CHECK-NEXT:    retq
  %res = call <16 x i16> @llvm.masked.load.v16i16.p0v16i16(<16 x i16>* %addr, i32 4, <16 x i1>%mask, <16 x i16> zeroinitializer)
  ret <16 x i16> %res
}
declare <16 x i16> @llvm.masked.load.v16i16.p0v16i16(<16 x i16>*, i32, <16 x i1>, <16 x i16>)

define <32 x i16> @test_mask_load_32xi16(<32 x i1> %mask, <32 x i16>* %addr, <32 x i16> %val) {
; CHECK-LABEL: test_mask_load_32xi16:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpsllw $7, %ymm0, %ymm0
; CHECK-NEXT:    vpmovb2m %ymm0, %k1
; CHECK-NEXT:    vmovdqu16 (%rdi), %zmm1 {%k1}
; CHECK-NEXT:    vmovdqa64 %zmm1, %zmm0
; CHECK-NEXT:    retq
  %res = call <32 x i16> @llvm.masked.load.v32i16.p0v32i16(<32 x i16>* %addr, i32 4, <32 x i1>%mask, <32 x i16> %val)
  ret <32 x i16> %res
}
declare <32 x i16> @llvm.masked.load.v32i16.p0v32i16(<32 x i16>*, i32, <32 x i1>, <32 x i16>)

define void @test_mask_store_16xi8(<16 x i1> %mask, <16 x i8>* %addr, <16 x i8> %val) {
; CHECK-LABEL: test_mask_store_16xi8:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpsllw $7, %xmm0, %xmm0
; CHECK-NEXT:    vpmovb2m %xmm0, %k1
; CHECK-NEXT:    vmovdqu8 %xmm1, (%rdi) {%k1}
; CHECK-NEXT:    retq
  call void @llvm.masked.store.v16i8.p0v16i8(<16 x i8> %val, <16 x i8>* %addr, i32 4, <16 x i1>%mask)
  ret void
}
declare void @llvm.masked.store.v16i8.p0v16i8(<16 x i8>, <16 x i8>*, i32, <16 x i1>)

define void @test_mask_store_32xi8(<32 x i1> %mask, <32 x i8>* %addr, <32 x i8> %val) {
; CHECK-LABEL: test_mask_store_32xi8:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpsllw $7, %ymm0, %ymm0
; CHECK-NEXT:    vpmovb2m %ymm0, %k1
; CHECK-NEXT:    vmovdqu8 %ymm1, (%rdi) {%k1}
; CHECK-NEXT:    retq
  call void @llvm.masked.store.v32i8.p0v32i8(<32 x i8> %val, <32 x i8>* %addr, i32 4, <32 x i1>%mask)
  ret void
}
declare void @llvm.masked.store.v32i8.p0v32i8(<32 x i8>, <32 x i8>*, i32, <32 x i1>)

define void @test_mask_store_64xi8(<64 x i1> %mask, <64 x i8>* %addr, <64 x i8> %val) {
; CHECK-LABEL: test_mask_store_64xi8:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpsllw $7, %zmm0, %zmm0
; CHECK-NEXT:    vpmovb2m %zmm0, %k1
; CHECK-NEXT:    vmovdqu8 %zmm1, (%rdi) {%k1}
; CHECK-NEXT:    retq
  call void @llvm.masked.store.v64i8.p0v64i8(<64 x i8> %val, <64 x i8>* %addr, i32 4, <64 x i1>%mask)
  ret void
}
declare void @llvm.masked.store.v64i8.p0v64i8(<64 x i8>, <64 x i8>*, i32, <64 x i1>)

define void @test_mask_store_8xi16(<8 x i1> %mask, <8 x i16>* %addr, <8 x i16> %val) {
; CHECK-LABEL: test_mask_store_8xi16:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpsllw $15, %xmm0, %xmm0
; CHECK-NEXT:    vpmovw2m %xmm0, %k1
; CHECK-NEXT:    vmovdqu16 %xmm1, (%rdi) {%k1}
; CHECK-NEXT:    retq
  call void @llvm.masked.store.v8i16.p0v8i16(<8 x i16> %val, <8 x i16>* %addr, i32 4, <8 x i1>%mask)
  ret void
}
declare void @llvm.masked.store.v8i16.p0v8i16(<8 x i16>, <8 x i16>*, i32, <8 x i1>)

define void @test_mask_store_16xi16(<16 x i1> %mask, <16 x i16>* %addr, <16 x i16> %val) {
; CHECK-LABEL: test_mask_store_16xi16:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpsllw $7, %xmm0, %xmm0
; CHECK-NEXT:    vpmovb2m %xmm0, %k1
; CHECK-NEXT:    vmovdqu16 %ymm1, (%rdi) {%k1}
; CHECK-NEXT:    retq
  call void @llvm.masked.store.v16i16.p0v16i16(<16 x i16> %val, <16 x i16>* %addr, i32 4, <16 x i1>%mask)
  ret void
}
declare void @llvm.masked.store.v16i16.p0v16i16(<16 x i16>, <16 x i16>*, i32, <16 x i1>)

define void @test_mask_store_32xi16(<32 x i1> %mask, <32 x i16>* %addr, <32 x i16> %val) {
; CHECK-LABEL: test_mask_store_32xi16:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpsllw $7, %ymm0, %ymm0
; CHECK-NEXT:    vpmovb2m %ymm0, %k1
; CHECK-NEXT:    vmovdqu16 %zmm1, (%rdi) {%k1}
; CHECK-NEXT:    retq
  call void @llvm.masked.store.v32i16.p0v32i16(<32 x i16> %val, <32 x i16>* %addr, i32 4, <32 x i1>%mask)
  ret void
}

declare void @llvm.masked.store.v32i16.p0v32i16(<32 x i16>, <32 x i16>*, i32, <32 x i1>)
