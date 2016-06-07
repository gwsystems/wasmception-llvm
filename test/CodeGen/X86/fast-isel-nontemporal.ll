; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -verify-machineinstrs -mtriple=x86_64-unknown-unknown -mattr=+sse2 -fast-isel -O0 < %s | FileCheck %s --check-prefix=ALL --check-prefix=SSE --check-prefix=SSE2
; RUN: llc -verify-machineinstrs -mtriple=x86_64-unknown-unknown -mattr=+sse4a -fast-isel -O0 < %s | FileCheck %s --check-prefix=ALL --check-prefix=SSE --check-prefix=SSE4A
; RUN: llc -verify-machineinstrs -mtriple=x86_64-unknown-unknown -mattr=+sse4.1 -fast-isel -O0 < %s | FileCheck %s --check-prefix=ALL --check-prefix=SSE --check-prefix=SSE41
; RUN: llc -verify-machineinstrs -mtriple=x86_64-unknown-unknown -mattr=+avx -fast-isel -O0 < %s | FileCheck %s --check-prefix=ALL --check-prefix=AVX --check-prefix=AVX1
; RUN: llc -verify-machineinstrs -mtriple=x86_64-unknown-unknown -mattr=+avx2 -fast-isel -O0 < %s | FileCheck %s --check-prefix=ALL --check-prefix=AVX --check-prefix=AVX2
; RUN: llc -verify-machineinstrs -mtriple=x86_64-unknown-unknown -mattr=+avx512f -fast-isel -O0 < %s | FileCheck %s --check-prefix=ALL --check-prefix=AVX512 --check-prefix=AVX512F
; RUN: llc -verify-machineinstrs -mtriple=x86_64-unknown-unknown -mattr=+avx512bw -fast-isel -O0 < %s | FileCheck %s --check-prefix=ALL --check-prefix=AVX512 --check-prefix=AVX512BW

;
; Scalar Stores
;

define void @test_nti32(i32* nocapture %ptr, i32 %X) {
; ALL-LABEL: test_nti32:
; ALL:       # BB#0: # %entry
; ALL-NEXT:    movntil %esi, (%rdi)
; ALL-NEXT:    retq
entry:
  store i32 %X, i32* %ptr, align 4, !nontemporal !1
  ret void
}

define void @test_nti64(i64* nocapture %ptr, i64 %X) {
; ALL-LABEL: test_nti64:
; ALL:       # BB#0: # %entry
; ALL-NEXT:    movntiq %rsi, (%rdi)
; ALL-NEXT:    retq
entry:
  store i64 %X, i64* %ptr, align 8, !nontemporal !1
  ret void
}

define void @test_ntfloat(float* nocapture %ptr, float %X) {
; SSE2-LABEL: test_ntfloat:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movss %xmm0, (%rdi)
; SSE2-NEXT:    retq
;
; SSE4A-LABEL: test_ntfloat:
; SSE4A:       # BB#0: # %entry
; SSE4A-NEXT:    movntss %xmm0, (%rdi)
; SSE4A-NEXT:    retq
;
; SSE41-LABEL: test_ntfloat:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    movss %xmm0, (%rdi)
; SSE41-NEXT:    retq
;
; AVX-LABEL: test_ntfloat:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vmovss %xmm0, (%rdi)
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_ntfloat:
; AVX512:       # BB#0: # %entry
; AVX512-NEXT:    vmovss %xmm0, (%rdi)
; AVX512-NEXT:    retq
entry:
  store float %X, float* %ptr, align 4, !nontemporal !1
  ret void
}

define void @test_ntdouble(double* nocapture %ptr, double %X) {
; SSE2-LABEL: test_ntdouble:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movsd %xmm0, (%rdi)
; SSE2-NEXT:    retq
;
; SSE4A-LABEL: test_ntdouble:
; SSE4A:       # BB#0: # %entry
; SSE4A-NEXT:    movntsd %xmm0, (%rdi)
; SSE4A-NEXT:    retq
;
; SSE41-LABEL: test_ntdouble:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    movsd %xmm0, (%rdi)
; SSE41-NEXT:    retq
;
; AVX-LABEL: test_ntdouble:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vmovsd %xmm0, (%rdi)
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_ntdouble:
; AVX512:       # BB#0: # %entry
; AVX512-NEXT:    vmovsd %xmm0, (%rdi)
; AVX512-NEXT:    retq
entry:
  store double %X, double* %ptr, align 8, !nontemporal !1
  ret void
}

;
; 128-bit Vector Stores
;

define void @test_nt4xfloat(<4 x float>* nocapture %ptr, <4 x float> %X) {
; SSE-LABEL: test_nt4xfloat:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    movntps %xmm0, (%rdi)
; SSE-NEXT:    retq
;
; AVX-LABEL: test_nt4xfloat:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vmovntps %xmm0, (%rdi)
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_nt4xfloat:
; AVX512:       # BB#0: # %entry
; AVX512-NEXT:    vmovntps %xmm0, (%rdi)
; AVX512-NEXT:    retq
entry:
  store <4 x float> %X, <4 x float>* %ptr, align 16, !nontemporal !1
  ret void
}

define void @test_nt2xdouble(<2 x double>* nocapture %ptr, <2 x double> %X) {
; SSE-LABEL: test_nt2xdouble:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    movntpd %xmm0, (%rdi)
; SSE-NEXT:    retq
;
; AVX-LABEL: test_nt2xdouble:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vmovntpd %xmm0, (%rdi)
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_nt2xdouble:
; AVX512:       # BB#0: # %entry
; AVX512-NEXT:    vmovntpd %xmm0, (%rdi)
; AVX512-NEXT:    retq
entry:
  store <2 x double> %X, <2 x double>* %ptr, align 16, !nontemporal !1
  ret void
}

define void @test_nt16xi8(<16 x i8>* nocapture %ptr, <16 x i8> %X) {
; SSE-LABEL: test_nt16xi8:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    movntdq %xmm0, (%rdi)
; SSE-NEXT:    retq
;
; AVX-LABEL: test_nt16xi8:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vmovntdq %xmm0, (%rdi)
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_nt16xi8:
; AVX512:       # BB#0: # %entry
; AVX512-NEXT:    vmovntdq %xmm0, (%rdi)
; AVX512-NEXT:    retq
entry:
  store <16 x i8> %X, <16 x i8>* %ptr, align 16, !nontemporal !1
  ret void
}

define void @test_nt8xi16(<8 x i16>* nocapture %ptr, <8 x i16> %X) {
; SSE-LABEL: test_nt8xi16:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    movntdq %xmm0, (%rdi)
; SSE-NEXT:    retq
;
; AVX-LABEL: test_nt8xi16:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vmovntdq %xmm0, (%rdi)
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_nt8xi16:
; AVX512:       # BB#0: # %entry
; AVX512-NEXT:    vmovntdq %xmm0, (%rdi)
; AVX512-NEXT:    retq
entry:
  store <8 x i16> %X, <8 x i16>* %ptr, align 16, !nontemporal !1
  ret void
}

define void @test_nt4xi32(<4 x i32>* nocapture %ptr, <4 x i32> %X) {
; SSE-LABEL: test_nt4xi32:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    movntdq %xmm0, (%rdi)
; SSE-NEXT:    retq
;
; AVX-LABEL: test_nt4xi32:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vmovntdq %xmm0, (%rdi)
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_nt4xi32:
; AVX512:       # BB#0: # %entry
; AVX512-NEXT:    vmovntdq %xmm0, (%rdi)
; AVX512-NEXT:    retq
entry:
  store <4 x i32> %X, <4 x i32>* %ptr, align 16, !nontemporal !1
  ret void
}

define void @test_nt2xi64(<2 x i64>* nocapture %ptr, <2 x i64> %X) {
; SSE-LABEL: test_nt2xi64:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    movntdq %xmm0, (%rdi)
; SSE-NEXT:    retq
;
; AVX-LABEL: test_nt2xi64:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vmovntdq %xmm0, (%rdi)
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_nt2xi64:
; AVX512:       # BB#0: # %entry
; AVX512-NEXT:    vmovntdq %xmm0, (%rdi)
; AVX512-NEXT:    retq
entry:
  store <2 x i64> %X, <2 x i64>* %ptr, align 16, !nontemporal !1
  ret void
}

;
; 128-bit Vector Loads
;

define <4 x float> @test_load_nt4xfloat(<4 x float>* nocapture %ptr) {
; SSE2-LABEL: test_load_nt4xfloat:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movaps (%rdi), %xmm0
; SSE2-NEXT:    retq
;
; SSE4A-LABEL: test_load_nt4xfloat:
; SSE4A:       # BB#0: # %entry
; SSE4A-NEXT:    movaps (%rdi), %xmm0
; SSE4A-NEXT:    retq
;
; SSE41-LABEL: test_load_nt4xfloat:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    movntdqa (%rdi), %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: test_load_nt4xfloat:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vmovntdqa (%rdi), %xmm0
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_load_nt4xfloat:
; AVX512:       # BB#0: # %entry
; AVX512-NEXT:    vmovntdqa (%rdi), %xmm0
; AVX512-NEXT:    retq
entry:
  %0 = load <4 x float>, <4 x float>* %ptr, align 16, !nontemporal !1
  ret <4 x float> %0
}

define <2 x double> @test_load_nt2xdouble(<2 x double>* nocapture %ptr) {
; SSE2-LABEL: test_load_nt2xdouble:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movapd (%rdi), %xmm0
; SSE2-NEXT:    retq
;
; SSE4A-LABEL: test_load_nt2xdouble:
; SSE4A:       # BB#0: # %entry
; SSE4A-NEXT:    movapd (%rdi), %xmm0
; SSE4A-NEXT:    retq
;
; SSE41-LABEL: test_load_nt2xdouble:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    movntdqa (%rdi), %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: test_load_nt2xdouble:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vmovntdqa (%rdi), %xmm0
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_load_nt2xdouble:
; AVX512:       # BB#0: # %entry
; AVX512-NEXT:    vmovntdqa (%rdi), %xmm0
; AVX512-NEXT:    retq
entry:
  %0 = load <2 x double>, <2 x double>* %ptr, align 16, !nontemporal !1
  ret <2 x double> %0
}

define <16 x i8> @test_load_nt16xi8(<16 x i8>* nocapture %ptr) {
; SSE-LABEL: test_load_nt16xi8:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    movntdqa (%rdi), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: test_load_nt16xi8:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vmovntdqa (%rdi), %xmm0
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_load_nt16xi8:
; AVX512:       # BB#0: # %entry
; AVX512-NEXT:    vmovntdqa (%rdi), %xmm0
; AVX512-NEXT:    retq
entry:
  %0 = load <16 x i8>, <16 x i8>* %ptr, align 16, !nontemporal !1
  ret <16 x i8> %0
}

define <8 x i16> @test_load_nt8xi16(<8 x i16>* nocapture %ptr) {
; SSE-LABEL: test_load_nt8xi16:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    movntdqa (%rdi), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: test_load_nt8xi16:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vmovntdqa (%rdi), %xmm0
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_load_nt8xi16:
; AVX512:       # BB#0: # %entry
; AVX512-NEXT:    vmovntdqa (%rdi), %xmm0
; AVX512-NEXT:    retq
entry:
  %0 = load <8 x i16>, <8 x i16>* %ptr, align 16, !nontemporal !1
  ret <8 x i16> %0
}

define <4 x i32> @test_load_nt4xi32(<4 x i32>* nocapture %ptr) {
; SSE-LABEL: test_load_nt4xi32:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    movntdqa (%rdi), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: test_load_nt4xi32:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vmovntdqa (%rdi), %xmm0
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_load_nt4xi32:
; AVX512:       # BB#0: # %entry
; AVX512-NEXT:    vmovntdqa (%rdi), %xmm0
; AVX512-NEXT:    retq
entry:
  %0 = load <4 x i32>, <4 x i32>* %ptr, align 16, !nontemporal !1
  ret <4 x i32> %0
}

define <2 x i64> @test_load_nt2xi64(<2 x i64>* nocapture %ptr) {
; SSE-LABEL: test_load_nt2xi64:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    movntdqa (%rdi), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: test_load_nt2xi64:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vmovntdqa (%rdi), %xmm0
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_load_nt2xi64:
; AVX512:       # BB#0: # %entry
; AVX512-NEXT:    vmovntdqa (%rdi), %xmm0
; AVX512-NEXT:    retq
entry:
  %0 = load <2 x i64>, <2 x i64>* %ptr, align 16, !nontemporal !1
  ret <2 x i64> %0
}

;
; 256-bit Vector Stores
;

define void @test_nt8xfloat(<8 x float>* nocapture %ptr, <8 x float> %X) {
; SSE-LABEL: test_nt8xfloat:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    movntps %xmm0, (%rdi)
; SSE-NEXT:    movntps %xmm1, 16(%rdi)
; SSE-NEXT:    retq
;
; AVX-LABEL: test_nt8xfloat:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vmovntps %ymm0, (%rdi)
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_nt8xfloat:
; AVX512:       # BB#0: # %entry
; AVX512-NEXT:    vmovntps %ymm0, (%rdi)
; AVX512-NEXT:    retq
entry:
  store <8 x float> %X, <8 x float>* %ptr, align 32, !nontemporal !1
  ret void
}

define void @test_nt4xdouble(<4 x double>* nocapture %ptr, <4 x double> %X) {
; SSE-LABEL: test_nt4xdouble:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    movntpd %xmm0, (%rdi)
; SSE-NEXT:    movntpd %xmm1, 16(%rdi)
; SSE-NEXT:    retq
;
; AVX-LABEL: test_nt4xdouble:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vmovntpd %ymm0, (%rdi)
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_nt4xdouble:
; AVX512:       # BB#0: # %entry
; AVX512-NEXT:    vmovntpd %ymm0, (%rdi)
; AVX512-NEXT:    retq
entry:
  store <4 x double> %X, <4 x double>* %ptr, align 32, !nontemporal !1
  ret void
}

define void @test_nt32xi8(<32 x i8>* nocapture %ptr, <32 x i8> %X) {
; SSE-LABEL: test_nt32xi8:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    movntdq %xmm0, (%rdi)
; SSE-NEXT:    movntdq %xmm1, 16(%rdi)
; SSE-NEXT:    retq
;
; AVX-LABEL: test_nt32xi8:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vmovntdq %ymm0, (%rdi)
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_nt32xi8:
; AVX512:       # BB#0: # %entry
; AVX512-NEXT:    vmovntdq %ymm0, (%rdi)
; AVX512-NEXT:    retq
entry:
  store <32 x i8> %X, <32 x i8>* %ptr, align 32, !nontemporal !1
  ret void
}

define void @test_nt16xi16(<16 x i16>* nocapture %ptr, <16 x i16> %X) {
; SSE-LABEL: test_nt16xi16:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    movntdq %xmm0, (%rdi)
; SSE-NEXT:    movntdq %xmm1, 16(%rdi)
; SSE-NEXT:    retq
;
; AVX-LABEL: test_nt16xi16:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vmovntdq %ymm0, (%rdi)
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_nt16xi16:
; AVX512:       # BB#0: # %entry
; AVX512-NEXT:    vmovntdq %ymm0, (%rdi)
; AVX512-NEXT:    retq
entry:
  store <16 x i16> %X, <16 x i16>* %ptr, align 32, !nontemporal !1
  ret void
}

define void @test_nt8xi32(<8 x i32>* nocapture %ptr, <8 x i32> %X) {
; SSE-LABEL: test_nt8xi32:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    movntdq %xmm0, (%rdi)
; SSE-NEXT:    movntdq %xmm1, 16(%rdi)
; SSE-NEXT:    retq
;
; AVX-LABEL: test_nt8xi32:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vmovntdq %ymm0, (%rdi)
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_nt8xi32:
; AVX512:       # BB#0: # %entry
; AVX512-NEXT:    vmovntdq %ymm0, (%rdi)
; AVX512-NEXT:    retq
entry:
  store <8 x i32> %X, <8 x i32>* %ptr, align 32, !nontemporal !1
  ret void
}

define void @test_nt4xi64(<4 x i64>* nocapture %ptr, <4 x i64> %X) {
; SSE-LABEL: test_nt4xi64:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    movntdq %xmm0, (%rdi)
; SSE-NEXT:    movntdq %xmm1, 16(%rdi)
; SSE-NEXT:    retq
;
; AVX-LABEL: test_nt4xi64:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vmovntdq %ymm0, (%rdi)
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_nt4xi64:
; AVX512:       # BB#0: # %entry
; AVX512-NEXT:    vmovntdq %ymm0, (%rdi)
; AVX512-NEXT:    retq
entry:
  store <4 x i64> %X, <4 x i64>* %ptr, align 32, !nontemporal !1
  ret void
}

;
; 256-bit Vector Loads
;

define <8 x float> @test_load_nt8xfloat(<8 x float>* nocapture %ptr) {
; SSE2-LABEL: test_load_nt8xfloat:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movaps (%rdi), %xmm0
; SSE2-NEXT:    movaps 16(%rdi), %xmm1
; SSE2-NEXT:    retq
;
; SSE4A-LABEL: test_load_nt8xfloat:
; SSE4A:       # BB#0: # %entry
; SSE4A-NEXT:    movaps (%rdi), %xmm0
; SSE4A-NEXT:    movaps 16(%rdi), %xmm1
; SSE4A-NEXT:    retq
;
; SSE41-LABEL: test_load_nt8xfloat:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    movntdqa (%rdi), %xmm0
; SSE41-NEXT:    movntdqa 16(%rdi), %xmm1
; SSE41-NEXT:    retq
;
; AVX1-LABEL: test_load_nt8xfloat:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vmovaps (%rdi), %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test_load_nt8xfloat:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vmovntdqa (%rdi), %ymm0
; AVX2-NEXT:    retq
;
; AVX512-LABEL: test_load_nt8xfloat:
; AVX512:       # BB#0: # %entry
; AVX512-NEXT:    vmovntdqa (%rdi), %ymm0
; AVX512-NEXT:    retq
entry:
  %0 = load <8 x float>, <8 x float>* %ptr, align 32, !nontemporal !1
  ret <8 x float> %0
}

define <4 x double> @test_load_nt4xdouble(<4 x double>* nocapture %ptr) {
; SSE2-LABEL: test_load_nt4xdouble:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movapd (%rdi), %xmm0
; SSE2-NEXT:    movapd 16(%rdi), %xmm1
; SSE2-NEXT:    retq
;
; SSE4A-LABEL: test_load_nt4xdouble:
; SSE4A:       # BB#0: # %entry
; SSE4A-NEXT:    movapd (%rdi), %xmm0
; SSE4A-NEXT:    movapd 16(%rdi), %xmm1
; SSE4A-NEXT:    retq
;
; SSE41-LABEL: test_load_nt4xdouble:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    movntdqa (%rdi), %xmm0
; SSE41-NEXT:    movntdqa 16(%rdi), %xmm1
; SSE41-NEXT:    retq
;
; AVX1-LABEL: test_load_nt4xdouble:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vmovapd (%rdi), %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test_load_nt4xdouble:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vmovntdqa (%rdi), %ymm0
; AVX2-NEXT:    retq
;
; AVX512-LABEL: test_load_nt4xdouble:
; AVX512:       # BB#0: # %entry
; AVX512-NEXT:    vmovntdqa (%rdi), %ymm0
; AVX512-NEXT:    retq
entry:
  %0 = load <4 x double>, <4 x double>* %ptr, align 32, !nontemporal !1
  ret <4 x double> %0
}

define <32 x i8> @test_load_nt32xi8(<32 x i8>* nocapture %ptr) {
; SSE2-LABEL: test_load_nt32xi8:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movaps (%rdi), %xmm0
; SSE2-NEXT:    movaps 16(%rdi), %xmm1
; SSE2-NEXT:    retq
;
; SSE4A-LABEL: test_load_nt32xi8:
; SSE4A:       # BB#0: # %entry
; SSE4A-NEXT:    movaps (%rdi), %xmm0
; SSE4A-NEXT:    movaps 16(%rdi), %xmm1
; SSE4A-NEXT:    retq
;
; SSE41-LABEL: test_load_nt32xi8:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    movntdqa (%rdi), %xmm0
; SSE41-NEXT:    movntdqa 16(%rdi), %xmm1
; SSE41-NEXT:    retq
;
; AVX1-LABEL: test_load_nt32xi8:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vmovdqa (%rdi), %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test_load_nt32xi8:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vmovntdqa (%rdi), %ymm0
; AVX2-NEXT:    retq
;
; AVX512-LABEL: test_load_nt32xi8:
; AVX512:       # BB#0: # %entry
; AVX512-NEXT:    vmovntdqa (%rdi), %ymm0
; AVX512-NEXT:    retq
entry:
  %0 = load <32 x i8>, <32 x i8>* %ptr, align 32, !nontemporal !1
  ret <32 x i8> %0
}

define <16 x i16> @test_load_nt16xi16(<16 x i16>* nocapture %ptr) {
; SSE2-LABEL: test_load_nt16xi16:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movaps (%rdi), %xmm0
; SSE2-NEXT:    movaps 16(%rdi), %xmm1
; SSE2-NEXT:    retq
;
; SSE4A-LABEL: test_load_nt16xi16:
; SSE4A:       # BB#0: # %entry
; SSE4A-NEXT:    movaps (%rdi), %xmm0
; SSE4A-NEXT:    movaps 16(%rdi), %xmm1
; SSE4A-NEXT:    retq
;
; SSE41-LABEL: test_load_nt16xi16:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    movntdqa (%rdi), %xmm0
; SSE41-NEXT:    movntdqa 16(%rdi), %xmm1
; SSE41-NEXT:    retq
;
; AVX1-LABEL: test_load_nt16xi16:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vmovdqa (%rdi), %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test_load_nt16xi16:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vmovntdqa (%rdi), %ymm0
; AVX2-NEXT:    retq
;
; AVX512-LABEL: test_load_nt16xi16:
; AVX512:       # BB#0: # %entry
; AVX512-NEXT:    vmovntdqa (%rdi), %ymm0
; AVX512-NEXT:    retq
entry:
  %0 = load <16 x i16>, <16 x i16>* %ptr, align 32, !nontemporal !1
  ret <16 x i16> %0
}

define <8 x i32> @test_load_nt8xi32(<8 x i32>* nocapture %ptr) {
; SSE2-LABEL: test_load_nt8xi32:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movaps (%rdi), %xmm0
; SSE2-NEXT:    movaps 16(%rdi), %xmm1
; SSE2-NEXT:    retq
;
; SSE4A-LABEL: test_load_nt8xi32:
; SSE4A:       # BB#0: # %entry
; SSE4A-NEXT:    movaps (%rdi), %xmm0
; SSE4A-NEXT:    movaps 16(%rdi), %xmm1
; SSE4A-NEXT:    retq
;
; SSE41-LABEL: test_load_nt8xi32:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    movntdqa (%rdi), %xmm0
; SSE41-NEXT:    movntdqa 16(%rdi), %xmm1
; SSE41-NEXT:    retq
;
; AVX1-LABEL: test_load_nt8xi32:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vmovdqa (%rdi), %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test_load_nt8xi32:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vmovntdqa (%rdi), %ymm0
; AVX2-NEXT:    retq
;
; AVX512-LABEL: test_load_nt8xi32:
; AVX512:       # BB#0: # %entry
; AVX512-NEXT:    vmovntdqa (%rdi), %ymm0
; AVX512-NEXT:    retq
entry:
  %0 = load <8 x i32>, <8 x i32>* %ptr, align 32, !nontemporal !1
  ret <8 x i32> %0
}

define <4 x i64> @test_load_nt4xi64(<4 x i64>* nocapture %ptr) {
; SSE2-LABEL: test_load_nt4xi64:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movaps (%rdi), %xmm0
; SSE2-NEXT:    movaps 16(%rdi), %xmm1
; SSE2-NEXT:    retq
;
; SSE4A-LABEL: test_load_nt4xi64:
; SSE4A:       # BB#0: # %entry
; SSE4A-NEXT:    movaps (%rdi), %xmm0
; SSE4A-NEXT:    movaps 16(%rdi), %xmm1
; SSE4A-NEXT:    retq
;
; SSE41-LABEL: test_load_nt4xi64:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    movntdqa (%rdi), %xmm0
; SSE41-NEXT:    movntdqa 16(%rdi), %xmm1
; SSE41-NEXT:    retq
;
; AVX1-LABEL: test_load_nt4xi64:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vmovdqa (%rdi), %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test_load_nt4xi64:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vmovntdqa (%rdi), %ymm0
; AVX2-NEXT:    retq
;
; AVX512-LABEL: test_load_nt4xi64:
; AVX512:       # BB#0: # %entry
; AVX512-NEXT:    vmovntdqa (%rdi), %ymm0
; AVX512-NEXT:    retq
entry:
  %0 = load <4 x i64>, <4 x i64>* %ptr, align 32, !nontemporal !1
  ret <4 x i64> %0
}

;
; 512-bit Vector Stores
;

define void @test_nt16xfloat(<16 x float>* nocapture %ptr, <16 x float> %X) {
; SSE-LABEL: test_nt16xfloat:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    movntps %xmm0, (%rdi)
; SSE-NEXT:    movntps %xmm1, 16(%rdi)
; SSE-NEXT:    movntps %xmm2, 32(%rdi)
; SSE-NEXT:    movntps %xmm3, 48(%rdi)
; SSE-NEXT:    retq
;
; AVX-LABEL: test_nt16xfloat:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vmovntps %ymm0, (%rdi)
; AVX-NEXT:    vmovntps %ymm1, 32(%rdi)
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_nt16xfloat:
; AVX512:       # BB#0: # %entry
; AVX512-NEXT:    vmovntps %zmm0, (%rdi)
; AVX512-NEXT:    retq
entry:
  store <16 x float> %X, <16 x float>* %ptr, align 64, !nontemporal !1
  ret void
}

define void @test_nt8xdouble(<8 x double>* nocapture %ptr, <8 x double> %X) {
; SSE-LABEL: test_nt8xdouble:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    movntpd %xmm0, (%rdi)
; SSE-NEXT:    movntpd %xmm1, 16(%rdi)
; SSE-NEXT:    movntpd %xmm2, 32(%rdi)
; SSE-NEXT:    movntpd %xmm3, 48(%rdi)
; SSE-NEXT:    retq
;
; AVX-LABEL: test_nt8xdouble:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vmovntpd %ymm0, (%rdi)
; AVX-NEXT:    vmovntpd %ymm1, 32(%rdi)
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_nt8xdouble:
; AVX512:       # BB#0: # %entry
; AVX512-NEXT:    vmovntpd %zmm0, (%rdi)
; AVX512-NEXT:    retq
entry:
  store <8 x double> %X, <8 x double>* %ptr, align 64, !nontemporal !1
  ret void
}

define void @test_nt64xi8(<64 x i8>* nocapture %ptr, <64 x i8> %X) {
; SSE-LABEL: test_nt64xi8:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    movntdq %xmm0, (%rdi)
; SSE-NEXT:    movntdq %xmm1, 16(%rdi)
; SSE-NEXT:    movntdq %xmm2, 32(%rdi)
; SSE-NEXT:    movntdq %xmm3, 48(%rdi)
; SSE-NEXT:    retq
;
; AVX-LABEL: test_nt64xi8:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vmovntdq %ymm0, (%rdi)
; AVX-NEXT:    vmovntdq %ymm1, 32(%rdi)
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
;
; AVX512F-LABEL: test_nt64xi8:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vmovntdq %ymm0, (%rdi)
; AVX512F-NEXT:    vmovntdq %ymm1, 32(%rdi)
; AVX512F-NEXT:    retq
;
; AVX512BW-LABEL: test_nt64xi8:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vmovntdq %zmm0, (%rdi)
; AVX512BW-NEXT:    retq
entry:
  store <64 x i8> %X, <64 x i8>* %ptr, align 64, !nontemporal !1
  ret void
}

define void @test_nt32xi16(<32 x i16>* nocapture %ptr, <32 x i16> %X) {
; SSE-LABEL: test_nt32xi16:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    movntdq %xmm0, (%rdi)
; SSE-NEXT:    movntdq %xmm1, 16(%rdi)
; SSE-NEXT:    movntdq %xmm2, 32(%rdi)
; SSE-NEXT:    movntdq %xmm3, 48(%rdi)
; SSE-NEXT:    retq
;
; AVX-LABEL: test_nt32xi16:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vmovntdq %ymm0, (%rdi)
; AVX-NEXT:    vmovntdq %ymm1, 32(%rdi)
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
;
; AVX512F-LABEL: test_nt32xi16:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vmovntdq %ymm0, (%rdi)
; AVX512F-NEXT:    vmovntdq %ymm1, 32(%rdi)
; AVX512F-NEXT:    retq
;
; AVX512BW-LABEL: test_nt32xi16:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vmovntdq %zmm0, (%rdi)
; AVX512BW-NEXT:    retq
entry:
  store <32 x i16> %X, <32 x i16>* %ptr, align 64, !nontemporal !1
  ret void
}

define void @test_nt16xi32(<16 x i32>* nocapture %ptr, <16 x i32> %X) {
; SSE-LABEL: test_nt16xi32:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    movntdq %xmm0, (%rdi)
; SSE-NEXT:    movntdq %xmm1, 16(%rdi)
; SSE-NEXT:    movntdq %xmm2, 32(%rdi)
; SSE-NEXT:    movntdq %xmm3, 48(%rdi)
; SSE-NEXT:    retq
;
; AVX-LABEL: test_nt16xi32:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vmovntdq %ymm0, (%rdi)
; AVX-NEXT:    vmovntdq %ymm1, 32(%rdi)
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_nt16xi32:
; AVX512:       # BB#0: # %entry
; AVX512-NEXT:    vmovntdq %zmm0, (%rdi)
; AVX512-NEXT:    retq
entry:
  store <16 x i32> %X, <16 x i32>* %ptr, align 64, !nontemporal !1
  ret void
}

define void @test_nt8xi64(<8 x i64>* nocapture %ptr, <8 x i64> %X) {
; SSE-LABEL: test_nt8xi64:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    movntdq %xmm0, (%rdi)
; SSE-NEXT:    movntdq %xmm1, 16(%rdi)
; SSE-NEXT:    movntdq %xmm2, 32(%rdi)
; SSE-NEXT:    movntdq %xmm3, 48(%rdi)
; SSE-NEXT:    retq
;
; AVX-LABEL: test_nt8xi64:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vmovntdq %ymm0, (%rdi)
; AVX-NEXT:    vmovntdq %ymm1, 32(%rdi)
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_nt8xi64:
; AVX512:       # BB#0: # %entry
; AVX512-NEXT:    vmovntdq %zmm0, (%rdi)
; AVX512-NEXT:    retq
entry:
  store <8 x i64> %X, <8 x i64>* %ptr, align 64, !nontemporal !1
  ret void
}

;
; 512-bit Vector Loads
;

define <16 x float> @test_load_nt16xfloat(<16 x float>* nocapture %ptr) {
; SSE2-LABEL: test_load_nt16xfloat:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movaps (%rdi), %xmm0
; SSE2-NEXT:    movaps 16(%rdi), %xmm1
; SSE2-NEXT:    movaps 32(%rdi), %xmm2
; SSE2-NEXT:    movaps 48(%rdi), %xmm3
; SSE2-NEXT:    retq
;
; SSE4A-LABEL: test_load_nt16xfloat:
; SSE4A:       # BB#0: # %entry
; SSE4A-NEXT:    movaps (%rdi), %xmm0
; SSE4A-NEXT:    movaps 16(%rdi), %xmm1
; SSE4A-NEXT:    movaps 32(%rdi), %xmm2
; SSE4A-NEXT:    movaps 48(%rdi), %xmm3
; SSE4A-NEXT:    retq
;
; SSE41-LABEL: test_load_nt16xfloat:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    movntdqa (%rdi), %xmm0
; SSE41-NEXT:    movntdqa 16(%rdi), %xmm1
; SSE41-NEXT:    movntdqa 32(%rdi), %xmm2
; SSE41-NEXT:    movntdqa 48(%rdi), %xmm3
; SSE41-NEXT:    retq
;
; AVX1-LABEL: test_load_nt16xfloat:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vmovaps (%rdi), %ymm0
; AVX1-NEXT:    vmovaps 32(%rdi), %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test_load_nt16xfloat:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vmovntdqa (%rdi), %ymm0
; AVX2-NEXT:    vmovntdqa 32(%rdi), %ymm1
; AVX2-NEXT:    retq
;
; AVX512-LABEL: test_load_nt16xfloat:
; AVX512:       # BB#0: # %entry
; AVX512-NEXT:    vmovntdqa (%rdi), %zmm0
; AVX512-NEXT:    retq
entry:
  %0 = load <16 x float>, <16 x float>* %ptr, align 64, !nontemporal !1
  ret <16 x float> %0
}

define <8 x double> @test_load_nt8xdouble(<8 x double>* nocapture %ptr) {
; SSE2-LABEL: test_load_nt8xdouble:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movapd (%rdi), %xmm0
; SSE2-NEXT:    movapd 16(%rdi), %xmm1
; SSE2-NEXT:    movapd 32(%rdi), %xmm2
; SSE2-NEXT:    movapd 48(%rdi), %xmm3
; SSE2-NEXT:    retq
;
; SSE4A-LABEL: test_load_nt8xdouble:
; SSE4A:       # BB#0: # %entry
; SSE4A-NEXT:    movapd (%rdi), %xmm0
; SSE4A-NEXT:    movapd 16(%rdi), %xmm1
; SSE4A-NEXT:    movapd 32(%rdi), %xmm2
; SSE4A-NEXT:    movapd 48(%rdi), %xmm3
; SSE4A-NEXT:    retq
;
; SSE41-LABEL: test_load_nt8xdouble:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    movntdqa (%rdi), %xmm0
; SSE41-NEXT:    movntdqa 16(%rdi), %xmm1
; SSE41-NEXT:    movntdqa 32(%rdi), %xmm2
; SSE41-NEXT:    movntdqa 48(%rdi), %xmm3
; SSE41-NEXT:    retq
;
; AVX1-LABEL: test_load_nt8xdouble:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vmovapd (%rdi), %ymm0
; AVX1-NEXT:    vmovapd 32(%rdi), %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test_load_nt8xdouble:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vmovntdqa (%rdi), %ymm0
; AVX2-NEXT:    vmovntdqa 32(%rdi), %ymm1
; AVX2-NEXT:    retq
;
; AVX512-LABEL: test_load_nt8xdouble:
; AVX512:       # BB#0: # %entry
; AVX512-NEXT:    vmovntdqa (%rdi), %zmm0
; AVX512-NEXT:    retq
entry:
  %0 = load <8 x double>, <8 x double>* %ptr, align 64, !nontemporal !1
  ret <8 x double> %0
}

; TODO - 512-bit integer vector loads

!1 = !{i32 1}
