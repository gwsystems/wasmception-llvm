; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mattr=+avx512vl,+avx512dq,+avx512bw < %s | FileCheck %s --check-prefix=ALL --check-prefix=SKX
; RUN: llc -mattr=+avx512f < %s | FileCheck %s --check-prefix=ALL --check-prefix=KNL

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"



define <16 x float> @test1(float* %base) {
; ALL-LABEL: test1:
; ALL:       # BB#0:
; ALL-NEXT:    movw $-2049, %ax # imm = 0xF7FF
; ALL-NEXT:    kmovw %eax, %k1
; ALL-NEXT:    vexpandps (%rdi), %zmm0 {%k1} {z}
; ALL-NEXT:    retq
  %res = call <16 x float> @llvm.masked.expandload.v16f32(float* %base, <16 x i1> <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 false, i1 true, i1 true, i1 true, i1 true>, <16 x float> undef)
  ret <16 x float>%res
}

define <16 x float> @test2(float* %base, <16 x float> %src0) {
; ALL-LABEL: test2:
; ALL:       # BB#0:
; ALL-NEXT:    movw $30719, %ax # imm = 0x77FF
; ALL-NEXT:    kmovw %eax, %k1
; ALL-NEXT:    vexpandps (%rdi), %zmm0 {%k1}
; ALL-NEXT:    retq
  %res = call <16 x float> @llvm.masked.expandload.v16f32(float* %base, <16 x i1> <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 false, i1 true, i1 true, i1 true, i1 false>, <16 x float> %src0)
  ret <16 x float>%res
}

define <8 x double> @test3(double* %base, <8 x double> %src0, <8 x i1> %mask) {
; SKX-LABEL: test3:
; SKX:       # BB#0:
; SKX-NEXT:    vpsllw $15, %xmm1, %xmm1
; SKX-NEXT:    vpmovw2m %xmm1, %k1
; SKX-NEXT:    vexpandpd (%rdi), %zmm0 {%k1}
; SKX-NEXT:    retq
;
; KNL-LABEL: test3:
; KNL:       # BB#0:
; KNL-NEXT:    vpmovsxwq %xmm1, %zmm1
; KNL-NEXT:    vpsllq $63, %zmm1, %zmm1
; KNL-NEXT:    vptestmq %zmm1, %zmm1, %k1
; KNL-NEXT:    vexpandpd (%rdi), %zmm0 {%k1}
; KNL-NEXT:    retq
  %res = call <8 x double> @llvm.masked.expandload.v8f64(double* %base, <8 x i1> %mask, <8 x double> %src0)
  ret <8 x double>%res
}

define <4 x float> @test4(float* %base, <4 x float> %src0) {
; SKX-LABEL: test4:
; SKX:       # BB#0:
; SKX-NEXT:    movb $7, %al
; SKX-NEXT:    kmovb %eax, %k1
; SKX-NEXT:    vexpandps (%rdi), %xmm0 {%k1}
; SKX-NEXT:    retq
;
; KNL-LABEL: test4:
; KNL:       # BB#0:
; KNL-NEXT:    # kill: %XMM0<def> %XMM0<kill> %ZMM0<def>
; KNL-NEXT:    movw $7, %ax
; KNL-NEXT:    kmovw %eax, %k1
; KNL-NEXT:    vexpandps (%rdi), %zmm0 {%k1}
; KNL-NEXT:    # kill: %XMM0<def> %XMM0<kill> %ZMM0<kill>
; KNL-NEXT:    retq
  %res = call <4 x float> @llvm.masked.expandload.v4f32(float* %base, <4 x i1> <i1 true, i1 true, i1 true, i1 false>, <4 x float> %src0)
  ret <4 x float>%res
}

define <2 x i64> @test5(i64* %base, <2 x i64> %src0) {
; SKX-LABEL: test5:
; SKX:       # BB#0:
; SKX-NEXT:    movb $2, %al
; SKX-NEXT:    kmovb %eax, %k1
; SKX-NEXT:    vpexpandq (%rdi), %xmm0 {%k1}
; SKX-NEXT:    retq
;
; KNL-LABEL: test5:
; KNL:       # BB#0:
; KNL-NEXT:    # kill: %XMM0<def> %XMM0<kill> %ZMM0<def>
; KNL-NEXT:    movb $2, %al
; KNL-NEXT:    kmovw %eax, %k1
; KNL-NEXT:    vpexpandq (%rdi), %zmm0 {%k1}
; KNL-NEXT:    # kill: %XMM0<def> %XMM0<kill> %ZMM0<kill>
; KNL-NEXT:    retq
  %res = call <2 x i64> @llvm.masked.expandload.v2i64(i64* %base, <2 x i1> <i1 false, i1 true>, <2 x i64> %src0)
  ret <2 x i64>%res
}

declare <16 x float> @llvm.masked.expandload.v16f32(float*, <16 x i1>, <16 x float>)
declare <8 x double> @llvm.masked.expandload.v8f64(double*, <8 x i1>, <8 x double>)
declare <4 x float>  @llvm.masked.expandload.v4f32(float*, <4 x i1>, <4 x float>)
declare <2 x i64>    @llvm.masked.expandload.v2i64(i64*, <2 x i1>, <2 x i64>)

define void @test6(float* %base, <16 x float> %V) {
; ALL-LABEL: test6:
; ALL:       # BB#0:
; ALL-NEXT:    movw $-2049, %ax # imm = 0xF7FF
; ALL-NEXT:    kmovw %eax, %k1
; ALL-NEXT:    vcompressps %zmm0, (%rdi) {%k1}
; ALL-NEXT:    retq
  call void @llvm.masked.compressstore.v16f32(<16 x float> %V, float* %base, <16 x i1> <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 false, i1 true, i1 true, i1 true, i1 true>)
  ret void
}

define void @test7(float* %base, <8 x float> %V, <8 x i1> %mask) {
; SKX-LABEL: test7:
; SKX:       # BB#0:
; SKX-NEXT:    vpsllw $15, %xmm1, %xmm1
; SKX-NEXT:    vpmovw2m %xmm1, %k1
; SKX-NEXT:    vcompressps %ymm0, (%rdi) {%k1}
; SKX-NEXT:    retq
;
; KNL-LABEL: test7:
; KNL:       # BB#0:
; KNL-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<def>
; KNL-NEXT:    vpmovsxwq %xmm1, %zmm1
; KNL-NEXT:    vpsllq $63, %zmm1, %zmm1
; KNL-NEXT:    vptestmq %zmm1, %zmm1, %k0
; KNL-NEXT:    kshiftlw $8, %k0, %k0
; KNL-NEXT:    kshiftrw $8, %k0, %k1
; KNL-NEXT:    vcompressps %zmm0, (%rdi) {%k1}
; KNL-NEXT:    retq
  call void @llvm.masked.compressstore.v8f32(<8 x float> %V, float* %base, <8 x i1> %mask)
  ret void
}

define void @test8(double* %base, <8 x double> %V, <8 x i1> %mask) {
; SKX-LABEL: test8:
; SKX:       # BB#0:
; SKX-NEXT:    vpsllw $15, %xmm1, %xmm1
; SKX-NEXT:    vpmovw2m %xmm1, %k1
; SKX-NEXT:    vcompresspd %zmm0, (%rdi) {%k1}
; SKX-NEXT:    retq
;
; KNL-LABEL: test8:
; KNL:       # BB#0:
; KNL-NEXT:    vpmovsxwq %xmm1, %zmm1
; KNL-NEXT:    vpsllq $63, %zmm1, %zmm1
; KNL-NEXT:    vptestmq %zmm1, %zmm1, %k1
; KNL-NEXT:    vcompresspd %zmm0, (%rdi) {%k1}
; KNL-NEXT:    retq
  call void @llvm.masked.compressstore.v8f64(<8 x double> %V, double* %base, <8 x i1> %mask)
  ret void
}

define void @test9(i64* %base, <8 x i64> %V, <8 x i1> %mask) {
; SKX-LABEL: test9:
; SKX:       # BB#0:
; SKX-NEXT:    vpsllw $15, %xmm1, %xmm1
; SKX-NEXT:    vpmovw2m %xmm1, %k1
; SKX-NEXT:    vpcompressq %zmm0, (%rdi) {%k1}
; SKX-NEXT:    retq
;
; KNL-LABEL: test9:
; KNL:       # BB#0:
; KNL-NEXT:    vpmovsxwq %xmm1, %zmm1
; KNL-NEXT:    vpsllq $63, %zmm1, %zmm1
; KNL-NEXT:    vptestmq %zmm1, %zmm1, %k1
; KNL-NEXT:    vpcompressq %zmm0, (%rdi) {%k1}
; KNL-NEXT:    retq
    call void @llvm.masked.compressstore.v8i64(<8 x i64> %V, i64* %base, <8 x i1> %mask)
  ret void
}

define void @test10(i64* %base, <4 x i64> %V, <4 x i1> %mask) {
; SKX-LABEL: test10:
; SKX:       # BB#0:
; SKX-NEXT:    vpslld $31, %xmm1, %xmm1
; SKX-NEXT:    vptestmd %xmm1, %xmm1, %k1
; SKX-NEXT:    vpcompressq %ymm0, (%rdi) {%k1}
; SKX-NEXT:    retq
;
; KNL-LABEL: test10:
; KNL:       # BB#0:
; KNL-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<def>
; KNL-NEXT:    vpslld $31, %xmm1, %xmm1
; KNL-NEXT:    vpsrad $31, %xmm1, %xmm1
; KNL-NEXT:    vpmovsxdq %xmm1, %ymm1
; KNL-NEXT:    vpxord %zmm2, %zmm2, %zmm2
; KNL-NEXT:    vinserti64x4 $0, %ymm1, %zmm2, %zmm1
; KNL-NEXT:    vpsllq $63, %zmm1, %zmm1
; KNL-NEXT:    vptestmq %zmm1, %zmm1, %k1
; KNL-NEXT:    vpcompressq %zmm0, (%rdi) {%k1}
; KNL-NEXT:    retq
    call void @llvm.masked.compressstore.v4i64(<4 x i64> %V, i64* %base, <4 x i1> %mask)
  ret void
}

define void @test11(i64* %base, <2 x i64> %V, <2 x i1> %mask) {
; SKX-LABEL: test11:
; SKX:       # BB#0:
; SKX-NEXT:    vpsllq $63, %xmm1, %xmm1
; SKX-NEXT:    vptestmq %xmm1, %xmm1, %k1
; SKX-NEXT:    vpcompressq %xmm0, (%rdi) {%k1}
; SKX-NEXT:    retq
;
; KNL-LABEL: test11:
; KNL:       # BB#0:
; KNL-NEXT:    # kill: %XMM0<def> %XMM0<kill> %ZMM0<def>
; KNL-NEXT:    vpsllq $63, %xmm1, %xmm1
; KNL-NEXT:    vpsrad $31, %xmm1, %xmm1
; KNL-NEXT:    vpshufd {{.*#+}} xmm1 = xmm1[1,1,3,3]
; KNL-NEXT:    vpxord %zmm2, %zmm2, %zmm2
; KNL-NEXT:    vinserti32x4 $0, %xmm1, %zmm2, %zmm1
; KNL-NEXT:    vpsllq $63, %zmm1, %zmm1
; KNL-NEXT:    vptestmq %zmm1, %zmm1, %k1
; KNL-NEXT:    vpcompressq %zmm0, (%rdi) {%k1}
; KNL-NEXT:    retq
    call void @llvm.masked.compressstore.v2i64(<2 x i64> %V, i64* %base, <2 x i1> %mask)
  ret void
}

define void @test12(float* %base, <4 x float> %V, <4 x i1> %mask) {
; SKX-LABEL: test12:
; SKX:       # BB#0:
; SKX-NEXT:    vpslld $31, %xmm1, %xmm1
; SKX-NEXT:    vptestmd %xmm1, %xmm1, %k1
; SKX-NEXT:    vcompressps %xmm0, (%rdi) {%k1}
; SKX-NEXT:    retq
;
; KNL-LABEL: test12:
; KNL:       # BB#0:
; KNL-NEXT:    # kill: %XMM0<def> %XMM0<kill> %ZMM0<def>
; KNL-NEXT:    vpslld $31, %xmm1, %xmm1
; KNL-NEXT:    vpsrad $31, %xmm1, %xmm1
; KNL-NEXT:    vpxord %zmm2, %zmm2, %zmm2
; KNL-NEXT:    vinserti32x4 $0, %xmm1, %zmm2, %zmm1
; KNL-NEXT:    vpslld $31, %zmm1, %zmm1
; KNL-NEXT:    vptestmd %zmm1, %zmm1, %k1
; KNL-NEXT:    vcompressps %zmm0, (%rdi) {%k1}
; KNL-NEXT:    retq
    call void @llvm.masked.compressstore.v4f32(<4 x float> %V, float* %base, <4 x i1> %mask)
  ret void
}

declare void @llvm.masked.compressstore.v16f32(<16 x float>, float* , <16 x i1>)
declare void @llvm.masked.compressstore.v8f32(<8 x float>, float* , <8 x i1>)
declare void @llvm.masked.compressstore.v8f64(<8 x double>, double* , <8 x i1>)
declare void @llvm.masked.compressstore.v16i32(<16 x i32>, i32* , <16 x i1>)
declare void @llvm.masked.compressstore.v8i32(<8 x i32>, i32* , <8 x i1>)
declare void @llvm.masked.compressstore.v8i64(<8 x i64>, i64* , <8 x i1>)
declare void @llvm.masked.compressstore.v4i32(<4 x i32>, i32* , <4 x i1>)
declare void @llvm.masked.compressstore.v4f32(<4 x float>, float* , <4 x i1>)
declare void @llvm.masked.compressstore.v4i64(<4 x i64>, i64* , <4 x i1>)
declare void @llvm.masked.compressstore.v2i64(<2 x i64>, i64* , <2 x i1>)
