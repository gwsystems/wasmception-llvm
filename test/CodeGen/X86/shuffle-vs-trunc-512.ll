; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f | FileCheck %s --check-prefix=AVX512 --check-prefix=AVX512F
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512vl,+fast-variable-shuffle | FileCheck %s --check-prefixes=AVX512,AVX512VL
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512bw,+fast-variable-shuffle | FileCheck %s --check-prefixes=AVX512,AVX512BW
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512bw,+avx512vl,+fast-variable-shuffle | FileCheck %s --check-prefixes=AVX512,AVX512BWVL

; PR31551
; Pairs of shufflevector:trunc functions with functional equivalence.
; Ideally, the shuffles should be lowered to code with the same quality as the truncates.

define void @shuffle_v64i8_to_v32i8(<64 x i8>* %L, <32 x i8>* %S) nounwind {
; AVX512F-LABEL: shuffle_v64i8_to_v32i8:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    vmovdqa (%rdi), %ymm0
; AVX512F-NEXT:    vmovdqa 32(%rdi), %ymm1
; AVX512F-NEXT:    vpshufb {{.*#+}} ymm1 = ymm1[u,u,u,u,u,u,u,u,0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u,16,18,20,22,24,26,28,30]
; AVX512F-NEXT:    vpshufb {{.*#+}} ymm0 = ymm0[0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u,16,18,20,22,24,26,28,30,u,u,u,u,u,u,u,u]
; AVX512F-NEXT:    vpblendd {{.*#+}} ymm0 = ymm0[0,1],ymm1[2,3],ymm0[4,5],ymm1[6,7]
; AVX512F-NEXT:    vpermq {{.*#+}} ymm0 = ymm0[0,2,1,3]
; AVX512F-NEXT:    vmovdqa %ymm0, (%rsi)
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: shuffle_v64i8_to_v32i8:
; AVX512VL:       # %bb.0:
; AVX512VL-NEXT:    vmovdqa (%rdi), %ymm0
; AVX512VL-NEXT:    vmovdqa 32(%rdi), %ymm1
; AVX512VL-NEXT:    vpshufb {{.*#+}} ymm1 = ymm1[u,u,u,u,u,u,u,u,0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u,16,18,20,22,24,26,28,30]
; AVX512VL-NEXT:    vpshufb {{.*#+}} ymm0 = ymm0[0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u,16,18,20,22,24,26,28,30,u,u,u,u,u,u,u,u]
; AVX512VL-NEXT:    vmovdqa {{.*#+}} ymm2 = [0,2,5,7]
; AVX512VL-NEXT:    vpermi2q %ymm1, %ymm0, %ymm2
; AVX512VL-NEXT:    vmovdqa %ymm2, (%rsi)
; AVX512VL-NEXT:    vzeroupper
; AVX512VL-NEXT:    retq
;
; AVX512BW-LABEL: shuffle_v64i8_to_v32i8:
; AVX512BW:       # %bb.0:
; AVX512BW-NEXT:    vmovdqa64 (%rdi), %zmm0
; AVX512BW-NEXT:    vextracti64x4 $1, %zmm0, %ymm1
; AVX512BW-NEXT:    vpshufb {{.*#+}} ymm1 = ymm1[u,u,u,u,u,u,u,u,0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u,16,18,20,22,24,26,28,30]
; AVX512BW-NEXT:    vpshufb {{.*#+}} ymm0 = ymm0[0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u,16,18,20,22,24,26,28,30,u,u,u,u,u,u,u,u]
; AVX512BW-NEXT:    vpblendd {{.*#+}} ymm0 = ymm0[0,1],ymm1[2,3],ymm0[4,5],ymm1[6,7]
; AVX512BW-NEXT:    vpermq {{.*#+}} ymm0 = ymm0[0,2,1,3]
; AVX512BW-NEXT:    vmovdqa %ymm0, (%rsi)
; AVX512BW-NEXT:    vzeroupper
; AVX512BW-NEXT:    retq
;
; AVX512BWVL-LABEL: shuffle_v64i8_to_v32i8:
; AVX512BWVL:       # %bb.0:
; AVX512BWVL-NEXT:    vmovdqa64 (%rdi), %zmm0
; AVX512BWVL-NEXT:    vextracti64x4 $1, %zmm0, %ymm1
; AVX512BWVL-NEXT:    vpshufb {{.*#+}} ymm1 = ymm1[u,u,u,u,u,u,u,u,0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u,16,18,20,22,24,26,28,30]
; AVX512BWVL-NEXT:    vpshufb {{.*#+}} ymm0 = ymm0[0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u,16,18,20,22,24,26,28,30,u,u,u,u,u,u,u,u]
; AVX512BWVL-NEXT:    vmovdqa {{.*#+}} ymm2 = [0,2,5,7]
; AVX512BWVL-NEXT:    vpermi2q %ymm1, %ymm0, %ymm2
; AVX512BWVL-NEXT:    vmovdqa %ymm2, (%rsi)
; AVX512BWVL-NEXT:    vzeroupper
; AVX512BWVL-NEXT:    retq
  %vec = load <64 x i8>, <64 x i8>* %L
  %strided.vec = shufflevector <64 x i8> %vec, <64 x i8> undef, <32 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14, i32 16, i32 18, i32 20, i32 22, i32 24, i32 26, i32 28, i32 30, i32 32, i32 34, i32 36, i32 38, i32 40, i32 42, i32 44, i32 46, i32 48, i32 50, i32 52, i32 54, i32 56, i32 58, i32 60, i32 62>
  store <32 x i8> %strided.vec, <32 x i8>* %S
  ret void
}

define void @trunc_v32i16_to_v32i8(<64 x i8>* %L, <32 x i8>* %S) nounwind {
; AVX512F-LABEL: trunc_v32i16_to_v32i8:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    vpmovsxwd (%rdi), %zmm0
; AVX512F-NEXT:    vpmovdb %zmm0, %xmm0
; AVX512F-NEXT:    vpmovsxwd 32(%rdi), %zmm1
; AVX512F-NEXT:    vpmovdb %zmm1, %xmm1
; AVX512F-NEXT:    vinserti128 $1, %xmm1, %ymm0, %ymm0
; AVX512F-NEXT:    vmovdqa %ymm0, (%rsi)
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: trunc_v32i16_to_v32i8:
; AVX512VL:       # %bb.0:
; AVX512VL-NEXT:    vpmovsxwd (%rdi), %zmm0
; AVX512VL-NEXT:    vpmovdb %zmm0, %xmm0
; AVX512VL-NEXT:    vpmovsxwd 32(%rdi), %zmm1
; AVX512VL-NEXT:    vpmovdb %zmm1, %xmm1
; AVX512VL-NEXT:    vinserti128 $1, %xmm1, %ymm0, %ymm0
; AVX512VL-NEXT:    vmovdqa %ymm0, (%rsi)
; AVX512VL-NEXT:    vzeroupper
; AVX512VL-NEXT:    retq
;
; AVX512BW-LABEL: trunc_v32i16_to_v32i8:
; AVX512BW:       # %bb.0:
; AVX512BW-NEXT:    vmovdqa64 (%rdi), %zmm0
; AVX512BW-NEXT:    vpmovwb %zmm0, (%rsi)
; AVX512BW-NEXT:    vzeroupper
; AVX512BW-NEXT:    retq
;
; AVX512BWVL-LABEL: trunc_v32i16_to_v32i8:
; AVX512BWVL:       # %bb.0:
; AVX512BWVL-NEXT:    vmovdqa64 (%rdi), %zmm0
; AVX512BWVL-NEXT:    vpmovwb %zmm0, (%rsi)
; AVX512BWVL-NEXT:    vzeroupper
; AVX512BWVL-NEXT:    retq
  %vec = load <64 x i8>, <64 x i8>* %L
  %bc = bitcast <64 x i8> %vec to <32 x i16>
  %strided.vec = trunc <32 x i16> %bc to <32 x i8>
  store <32 x i8> %strided.vec, <32 x i8>* %S
  ret void
}

define void @shuffle_v32i16_to_v16i16(<32 x i16>* %L, <16 x i16>* %S) nounwind {
; AVX512F-LABEL: shuffle_v32i16_to_v16i16:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    vpshuflw {{.*#+}} ymm0 = mem[0,2,2,3,4,5,6,7,8,10,10,11,12,13,14,15]
; AVX512F-NEXT:    vpshufhw {{.*#+}} ymm0 = ymm0[0,1,2,3,4,6,6,7,8,9,10,11,12,14,14,15]
; AVX512F-NEXT:    vpshuflw {{.*#+}} ymm1 = mem[0,2,2,3,4,5,6,7,8,10,10,11,12,13,14,15]
; AVX512F-NEXT:    vpshufhw {{.*#+}} ymm1 = ymm1[0,1,2,3,4,6,6,7,8,9,10,11,12,14,14,15]
; AVX512F-NEXT:    vshufps {{.*#+}} ymm0 = ymm1[0,2],ymm0[0,2],ymm1[4,6],ymm0[4,6]
; AVX512F-NEXT:    vpermpd {{.*#+}} ymm0 = ymm0[0,2,1,3]
; AVX512F-NEXT:    vmovaps %ymm0, (%rsi)
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: shuffle_v32i16_to_v16i16:
; AVX512VL:       # %bb.0:
; AVX512VL-NEXT:    vmovdqa (%rdi), %ymm0
; AVX512VL-NEXT:    vmovdqa 32(%rdi), %ymm1
; AVX512VL-NEXT:    vmovdqa {{.*#+}} ymm2 = [0,1,4,5,4,5,6,7,8,9,12,13,12,13,14,15,16,17,20,21,20,21,22,23,24,25,28,29,28,29,30,31]
; AVX512VL-NEXT:    vpshufb %ymm2, %ymm1, %ymm1
; AVX512VL-NEXT:    vpshufb %ymm2, %ymm0, %ymm0
; AVX512VL-NEXT:    vmovdqa {{.*#+}} ymm2 = [0,2,4,6,8,10,12,14]
; AVX512VL-NEXT:    vpermi2d %ymm1, %ymm0, %ymm2
; AVX512VL-NEXT:    vmovdqa %ymm2, (%rsi)
; AVX512VL-NEXT:    vzeroupper
; AVX512VL-NEXT:    retq
;
; AVX512BW-LABEL: shuffle_v32i16_to_v16i16:
; AVX512BW:       # %bb.0:
; AVX512BW-NEXT:    vmovdqa64 (%rdi), %zmm0
; AVX512BW-NEXT:    vextracti64x4 $1, %zmm0, %ymm1
; AVX512BW-NEXT:    vmovdqa {{.*#+}} ymm2 = [0,1,4,5,4,5,6,7,8,9,12,13,12,13,14,15,16,17,20,21,20,21,22,23,24,25,28,29,28,29,30,31]
; AVX512BW-NEXT:    vpshufb %ymm2, %ymm1, %ymm1
; AVX512BW-NEXT:    vpshufb %ymm2, %ymm0, %ymm0
; AVX512BW-NEXT:    vshufps {{.*#+}} ymm0 = ymm0[0,2],ymm1[0,2],ymm0[4,6],ymm1[4,6]
; AVX512BW-NEXT:    vpermpd {{.*#+}} ymm0 = ymm0[0,2,1,3]
; AVX512BW-NEXT:    vmovaps %ymm0, (%rsi)
; AVX512BW-NEXT:    vzeroupper
; AVX512BW-NEXT:    retq
;
; AVX512BWVL-LABEL: shuffle_v32i16_to_v16i16:
; AVX512BWVL:       # %bb.0:
; AVX512BWVL-NEXT:    vmovdqa64 (%rdi), %zmm0
; AVX512BWVL-NEXT:    vextracti64x4 $1, %zmm0, %ymm1
; AVX512BWVL-NEXT:    vmovdqa {{.*#+}} ymm2 = [0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30]
; AVX512BWVL-NEXT:    vpermi2w %ymm1, %ymm0, %ymm2
; AVX512BWVL-NEXT:    vmovdqa %ymm2, (%rsi)
; AVX512BWVL-NEXT:    vzeroupper
; AVX512BWVL-NEXT:    retq
  %vec = load <32 x i16>, <32 x i16>* %L
  %strided.vec = shufflevector <32 x i16> %vec, <32 x i16> undef, <16 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14, i32 16, i32 18, i32 20, i32 22, i32 24, i32 26, i32 28, i32 30>
  store <16 x i16> %strided.vec, <16 x i16>* %S
  ret void
}

define void @trunc_v16i32_to_v16i16(<32 x i16>* %L, <16 x i16>* %S) nounwind {
; AVX512-LABEL: trunc_v16i32_to_v16i16:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmovdqa32 (%rdi), %zmm0
; AVX512-NEXT:    vpmovdw %zmm0, (%rsi)
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %vec = load <32 x i16>, <32 x i16>* %L
  %bc = bitcast <32 x i16> %vec to <16 x i32>
  %strided.vec = trunc <16 x i32> %bc to <16 x i16>
  store <16 x i16> %strided.vec, <16 x i16>* %S
  ret void
}

define void @shuffle_v16i32_to_v8i32(<16 x i32>* %L, <8 x i32>* %S) nounwind {
; AVX512F-LABEL: shuffle_v16i32_to_v8i32:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    vmovaps (%rdi), %zmm0
; AVX512F-NEXT:    vextractf64x4 $1, %zmm0, %ymm1
; AVX512F-NEXT:    vshufps {{.*#+}} ymm0 = ymm0[0,2],ymm1[0,2],ymm0[4,6],ymm1[4,6]
; AVX512F-NEXT:    vpermpd {{.*#+}} ymm0 = ymm0[0,2,1,3]
; AVX512F-NEXT:    vmovaps %ymm0, (%rsi)
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: shuffle_v16i32_to_v8i32:
; AVX512VL:       # %bb.0:
; AVX512VL-NEXT:    vmovdqa32 (%rdi), %zmm0
; AVX512VL-NEXT:    vextracti64x4 $1, %zmm0, %ymm1
; AVX512VL-NEXT:    vmovdqa {{.*#+}} ymm2 = [0,2,4,6,8,10,12,14]
; AVX512VL-NEXT:    vpermi2d %ymm1, %ymm0, %ymm2
; AVX512VL-NEXT:    vmovdqa %ymm2, (%rsi)
; AVX512VL-NEXT:    vzeroupper
; AVX512VL-NEXT:    retq
;
; AVX512BW-LABEL: shuffle_v16i32_to_v8i32:
; AVX512BW:       # %bb.0:
; AVX512BW-NEXT:    vmovaps (%rdi), %zmm0
; AVX512BW-NEXT:    vextractf64x4 $1, %zmm0, %ymm1
; AVX512BW-NEXT:    vshufps {{.*#+}} ymm0 = ymm0[0,2],ymm1[0,2],ymm0[4,6],ymm1[4,6]
; AVX512BW-NEXT:    vpermpd {{.*#+}} ymm0 = ymm0[0,2,1,3]
; AVX512BW-NEXT:    vmovaps %ymm0, (%rsi)
; AVX512BW-NEXT:    vzeroupper
; AVX512BW-NEXT:    retq
;
; AVX512BWVL-LABEL: shuffle_v16i32_to_v8i32:
; AVX512BWVL:       # %bb.0:
; AVX512BWVL-NEXT:    vmovdqa32 (%rdi), %zmm0
; AVX512BWVL-NEXT:    vextracti64x4 $1, %zmm0, %ymm1
; AVX512BWVL-NEXT:    vmovdqa {{.*#+}} ymm2 = [0,2,4,6,8,10,12,14]
; AVX512BWVL-NEXT:    vpermi2d %ymm1, %ymm0, %ymm2
; AVX512BWVL-NEXT:    vmovdqa %ymm2, (%rsi)
; AVX512BWVL-NEXT:    vzeroupper
; AVX512BWVL-NEXT:    retq
  %vec = load <16 x i32>, <16 x i32>* %L
  %strided.vec = shufflevector <16 x i32> %vec, <16 x i32> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  store <8 x i32> %strided.vec, <8 x i32>* %S
  ret void
}

define void @trunc_v8i64_to_v8i32(<16 x i32>* %L, <8 x i32>* %S) nounwind {
; AVX512-LABEL: trunc_v8i64_to_v8i32:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmovdqa64 (%rdi), %zmm0
; AVX512-NEXT:    vpmovqd %zmm0, (%rsi)
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %vec = load <16 x i32>, <16 x i32>* %L
  %bc = bitcast <16 x i32> %vec to <8 x i64>
  %strided.vec = trunc <8 x i64> %bc to <8 x i32>
  store <8 x i32> %strided.vec, <8 x i32>* %S
  ret void
}

define void @shuffle_v64i8_to_v16i8(<64 x i8>* %L, <16 x i8>* %S) nounwind {
; AVX512F-LABEL: shuffle_v64i8_to_v16i8:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    vmovdqa (%rdi), %ymm0
; AVX512F-NEXT:    vmovdqa 32(%rdi), %ymm1
; AVX512F-NEXT:    vextracti128 $1, %ymm1, %xmm2
; AVX512F-NEXT:    vmovdqa {{.*#+}} xmm3 = <u,u,u,u,0,4,8,12,u,u,u,u,u,u,u,u>
; AVX512F-NEXT:    vpshufb %xmm3, %xmm2, %xmm2
; AVX512F-NEXT:    vpshufb %xmm3, %xmm1, %xmm1
; AVX512F-NEXT:    vpunpckldq {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
; AVX512F-NEXT:    vextracti128 $1, %ymm0, %xmm2
; AVX512F-NEXT:    vmovdqa {{.*#+}} xmm3 = <0,4,8,12,u,u,u,u,u,u,u,u,u,u,u,u>
; AVX512F-NEXT:    vpshufb %xmm3, %xmm2, %xmm2
; AVX512F-NEXT:    vpshufb %xmm3, %xmm0, %xmm0
; AVX512F-NEXT:    vpunpckldq {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; AVX512F-NEXT:    vpblendd {{.*#+}} xmm0 = xmm0[0,1],xmm1[2,3]
; AVX512F-NEXT:    vmovdqa %xmm0, (%rsi)
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: shuffle_v64i8_to_v16i8:
; AVX512VL:       # %bb.0:
; AVX512VL-NEXT:    vmovdqa (%rdi), %ymm0
; AVX512VL-NEXT:    vmovdqa 32(%rdi), %ymm1
; AVX512VL-NEXT:    vextracti128 $1, %ymm1, %xmm2
; AVX512VL-NEXT:    vmovdqa {{.*#+}} xmm3 = <u,u,u,u,0,4,8,12,u,u,u,u,u,u,u,u>
; AVX512VL-NEXT:    vpshufb %xmm3, %xmm2, %xmm2
; AVX512VL-NEXT:    vpshufb %xmm3, %xmm1, %xmm1
; AVX512VL-NEXT:    vpunpckldq {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
; AVX512VL-NEXT:    vextracti128 $1, %ymm0, %xmm2
; AVX512VL-NEXT:    vmovdqa {{.*#+}} xmm3 = <0,4,8,12,u,u,u,u,u,u,u,u,u,u,u,u>
; AVX512VL-NEXT:    vpshufb %xmm3, %xmm2, %xmm2
; AVX512VL-NEXT:    vpshufb %xmm3, %xmm0, %xmm0
; AVX512VL-NEXT:    vpunpckldq {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; AVX512VL-NEXT:    vpblendd {{.*#+}} xmm0 = xmm0[0,1],xmm1[2,3]
; AVX512VL-NEXT:    vmovdqa %xmm0, (%rsi)
; AVX512VL-NEXT:    vzeroupper
; AVX512VL-NEXT:    retq
;
; AVX512BW-LABEL: shuffle_v64i8_to_v16i8:
; AVX512BW:       # %bb.0:
; AVX512BW-NEXT:    vmovdqa64 (%rdi), %zmm0
; AVX512BW-NEXT:    vextracti64x4 $1, %zmm0, %ymm1
; AVX512BW-NEXT:    vextracti128 $1, %ymm1, %xmm2
; AVX512BW-NEXT:    vmovdqa {{.*#+}} xmm3 = <u,u,u,u,0,4,8,12,u,u,u,u,u,u,u,u>
; AVX512BW-NEXT:    vpshufb %xmm3, %xmm2, %xmm2
; AVX512BW-NEXT:    vpshufb %xmm3, %xmm1, %xmm1
; AVX512BW-NEXT:    vpunpckldq {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
; AVX512BW-NEXT:    vextracti128 $1, %ymm0, %xmm2
; AVX512BW-NEXT:    vmovdqa {{.*#+}} xmm3 = <0,4,8,12,u,u,u,u,u,u,u,u,u,u,u,u>
; AVX512BW-NEXT:    vpshufb %xmm3, %xmm2, %xmm2
; AVX512BW-NEXT:    vpshufb %xmm3, %xmm0, %xmm0
; AVX512BW-NEXT:    vpunpckldq {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; AVX512BW-NEXT:    vpblendd {{.*#+}} xmm0 = xmm0[0,1],xmm1[2,3]
; AVX512BW-NEXT:    vmovdqa %xmm0, (%rsi)
; AVX512BW-NEXT:    vzeroupper
; AVX512BW-NEXT:    retq
;
; AVX512BWVL-LABEL: shuffle_v64i8_to_v16i8:
; AVX512BWVL:       # %bb.0:
; AVX512BWVL-NEXT:    vmovdqa64 (%rdi), %zmm0
; AVX512BWVL-NEXT:    vextracti64x4 $1, %zmm0, %ymm1
; AVX512BWVL-NEXT:    vextracti128 $1, %ymm1, %xmm2
; AVX512BWVL-NEXT:    vmovdqa {{.*#+}} xmm3 = <u,u,u,u,0,4,8,12,u,u,u,u,u,u,u,u>
; AVX512BWVL-NEXT:    vpshufb %xmm3, %xmm2, %xmm2
; AVX512BWVL-NEXT:    vpshufb %xmm3, %xmm1, %xmm1
; AVX512BWVL-NEXT:    vpunpckldq {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
; AVX512BWVL-NEXT:    vextracti128 $1, %ymm0, %xmm2
; AVX512BWVL-NEXT:    vmovdqa {{.*#+}} xmm3 = <0,4,8,12,u,u,u,u,u,u,u,u,u,u,u,u>
; AVX512BWVL-NEXT:    vpshufb %xmm3, %xmm2, %xmm2
; AVX512BWVL-NEXT:    vpshufb %xmm3, %xmm0, %xmm0
; AVX512BWVL-NEXT:    vpunpckldq {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; AVX512BWVL-NEXT:    vpblendd {{.*#+}} xmm0 = xmm0[0,1],xmm1[2,3]
; AVX512BWVL-NEXT:    vmovdqa %xmm0, (%rsi)
; AVX512BWVL-NEXT:    vzeroupper
; AVX512BWVL-NEXT:    retq
  %vec = load <64 x i8>, <64 x i8>* %L
  %strided.vec = shufflevector <64 x i8> %vec, <64 x i8> undef, <16 x i32> <i32 0, i32 4, i32 8, i32 12, i32 16, i32 20, i32 24, i32 28, i32 32, i32 36, i32 40, i32 44, i32 48, i32 52, i32 56, i32 60>
  store <16 x i8> %strided.vec, <16 x i8>* %S
  ret void
}

define void @trunc_v16i32_to_v16i8(<64 x i8>* %L, <16 x i8>* %S) nounwind {
; AVX512-LABEL: trunc_v16i32_to_v16i8:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmovdqa32 (%rdi), %zmm0
; AVX512-NEXT:    vpmovdb %zmm0, (%rsi)
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %vec = load <64 x i8>, <64 x i8>* %L
  %bc = bitcast <64 x i8> %vec to <16 x i32>
  %strided.vec = trunc <16 x i32> %bc to <16 x i8>
  store <16 x i8> %strided.vec, <16 x i8>* %S
  ret void
}

define void @shuffle_v32i16_to_v8i16(<32 x i16>* %L, <8 x i16>* %S) nounwind {
; AVX512F-LABEL: shuffle_v32i16_to_v8i16:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    vmovdqa (%rdi), %ymm0
; AVX512F-NEXT:    vmovdqa 32(%rdi), %ymm1
; AVX512F-NEXT:    vextracti128 $1, %ymm1, %xmm2
; AVX512F-NEXT:    vpshufd {{.*#+}} xmm2 = xmm2[0,2,2,3]
; AVX512F-NEXT:    vpshuflw {{.*#+}} xmm2 = xmm2[0,1,0,2,4,5,6,7]
; AVX512F-NEXT:    vpshufd {{.*#+}} xmm1 = xmm1[0,2,2,3]
; AVX512F-NEXT:    vpshuflw {{.*#+}} xmm1 = xmm1[0,1,0,2,4,5,6,7]
; AVX512F-NEXT:    vpunpckldq {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
; AVX512F-NEXT:    vextracti128 $1, %ymm0, %xmm2
; AVX512F-NEXT:    vpshufd {{.*#+}} xmm2 = xmm2[0,2,2,3]
; AVX512F-NEXT:    vpshuflw {{.*#+}} xmm2 = xmm2[0,2,2,3,4,5,6,7]
; AVX512F-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; AVX512F-NEXT:    vpshuflw {{.*#+}} xmm0 = xmm0[0,2,2,3,4,5,6,7]
; AVX512F-NEXT:    vpunpckldq {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; AVX512F-NEXT:    vpblendd {{.*#+}} xmm0 = xmm0[0,1],xmm1[2,3]
; AVX512F-NEXT:    vmovdqa %xmm0, (%rsi)
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: shuffle_v32i16_to_v8i16:
; AVX512VL:       # %bb.0:
; AVX512VL-NEXT:    vmovdqa (%rdi), %ymm0
; AVX512VL-NEXT:    vmovdqa 32(%rdi), %ymm1
; AVX512VL-NEXT:    vextracti128 $1, %ymm1, %xmm2
; AVX512VL-NEXT:    vmovdqa {{.*#+}} xmm3 = [0,1,2,3,0,1,8,9,8,9,10,11,12,13,14,15]
; AVX512VL-NEXT:    vpshufb %xmm3, %xmm2, %xmm2
; AVX512VL-NEXT:    vpshufb %xmm3, %xmm1, %xmm1
; AVX512VL-NEXT:    vpunpckldq {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
; AVX512VL-NEXT:    vextracti128 $1, %ymm0, %xmm2
; AVX512VL-NEXT:    vmovdqa {{.*#+}} xmm3 = [0,1,8,9,8,9,10,11,8,9,10,11,12,13,14,15]
; AVX512VL-NEXT:    vpshufb %xmm3, %xmm2, %xmm2
; AVX512VL-NEXT:    vpshufb %xmm3, %xmm0, %xmm0
; AVX512VL-NEXT:    vpunpckldq {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; AVX512VL-NEXT:    vpblendd {{.*#+}} xmm0 = xmm0[0,1],xmm1[2,3]
; AVX512VL-NEXT:    vmovdqa %xmm0, (%rsi)
; AVX512VL-NEXT:    vzeroupper
; AVX512VL-NEXT:    retq
;
; AVX512BW-LABEL: shuffle_v32i16_to_v8i16:
; AVX512BW:       # %bb.0:
; AVX512BW-NEXT:    vmovdqa64 (%rdi), %zmm0
; AVX512BW-NEXT:    vextracti64x4 $1, %zmm0, %ymm1
; AVX512BW-NEXT:    vextracti128 $1, %ymm1, %xmm2
; AVX512BW-NEXT:    vmovdqa {{.*#+}} xmm3 = [0,1,2,3,0,1,8,9,8,9,10,11,12,13,14,15]
; AVX512BW-NEXT:    vpshufb %xmm3, %xmm2, %xmm2
; AVX512BW-NEXT:    vpshufb %xmm3, %xmm1, %xmm1
; AVX512BW-NEXT:    vpunpckldq {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
; AVX512BW-NEXT:    vextracti128 $1, %ymm0, %xmm2
; AVX512BW-NEXT:    vmovdqa {{.*#+}} xmm3 = [0,1,8,9,8,9,10,11,8,9,10,11,12,13,14,15]
; AVX512BW-NEXT:    vpshufb %xmm3, %xmm2, %xmm2
; AVX512BW-NEXT:    vpshufb %xmm3, %xmm0, %xmm0
; AVX512BW-NEXT:    vpunpckldq {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; AVX512BW-NEXT:    vpblendd {{.*#+}} xmm0 = xmm0[0,1],xmm1[2,3]
; AVX512BW-NEXT:    vmovdqa %xmm0, (%rsi)
; AVX512BW-NEXT:    vzeroupper
; AVX512BW-NEXT:    retq
;
; AVX512BWVL-LABEL: shuffle_v32i16_to_v8i16:
; AVX512BWVL:       # %bb.0:
; AVX512BWVL-NEXT:    vmovdqa64 (%rdi), %zmm0
; AVX512BWVL-NEXT:    vextracti64x4 $1, %zmm0, %ymm1
; AVX512BWVL-NEXT:    vmovdqa {{.*#+}} ymm2 = <0,4,8,12,16,20,24,28,u,u,u,u,u,u,u,u>
; AVX512BWVL-NEXT:    vpermi2w %ymm1, %ymm0, %ymm2
; AVX512BWVL-NEXT:    vmovdqa %xmm2, (%rsi)
; AVX512BWVL-NEXT:    vzeroupper
; AVX512BWVL-NEXT:    retq
  %vec = load <32 x i16>, <32 x i16>* %L
  %strided.vec = shufflevector <32 x i16> %vec, <32 x i16> undef, <8 x i32> <i32 0, i32 4, i32 8, i32 12, i32 16, i32 20, i32 24, i32 28>
  store <8 x i16> %strided.vec, <8 x i16>* %S
  ret void
}

define void @trunc_v8i64_to_v8i16(<32 x i16>* %L, <8 x i16>* %S) nounwind {
; AVX512-LABEL: trunc_v8i64_to_v8i16:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmovdqa64 (%rdi), %zmm0
; AVX512-NEXT:    vpmovqw %zmm0, (%rsi)
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %vec = load <32 x i16>, <32 x i16>* %L
  %bc = bitcast <32 x i16> %vec to <8 x i64>
  %strided.vec = trunc <8 x i64> %bc to <8 x i16>
  store <8 x i16> %strided.vec, <8 x i16>* %S
  ret void
}

define void @shuffle_v64i8_to_v8i8(<64 x i8>* %L, <8 x i8>* %S) nounwind {
; AVX512F-LABEL: shuffle_v64i8_to_v8i8:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    vmovdqa (%rdi), %ymm0
; AVX512F-NEXT:    vmovdqa 32(%rdi), %ymm1
; AVX512F-NEXT:    vextracti128 $1, %ymm1, %xmm2
; AVX512F-NEXT:    vmovdqa {{.*#+}} xmm3 = <u,u,0,8,u,u,u,u,u,u,u,u,u,u,u,u>
; AVX512F-NEXT:    vpshufb %xmm3, %xmm2, %xmm2
; AVX512F-NEXT:    vpshufb %xmm3, %xmm1, %xmm1
; AVX512F-NEXT:    vpunpcklwd {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1],xmm1[2],xmm2[2],xmm1[3],xmm2[3]
; AVX512F-NEXT:    vextracti128 $1, %ymm0, %xmm2
; AVX512F-NEXT:    vmovdqa {{.*#+}} xmm3 = <0,8,u,u,u,u,u,u,u,u,u,u,u,u,u,u>
; AVX512F-NEXT:    vpshufb %xmm3, %xmm2, %xmm2
; AVX512F-NEXT:    vpshufb %xmm3, %xmm0, %xmm0
; AVX512F-NEXT:    vpunpcklwd {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3]
; AVX512F-NEXT:    vpblendd {{.*#+}} xmm0 = xmm0[0],xmm1[1],xmm0[2,3]
; AVX512F-NEXT:    vmovq %xmm0, (%rsi)
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: shuffle_v64i8_to_v8i8:
; AVX512VL:       # %bb.0:
; AVX512VL-NEXT:    vmovdqa (%rdi), %ymm0
; AVX512VL-NEXT:    vmovdqa 32(%rdi), %ymm1
; AVX512VL-NEXT:    vextracti128 $1, %ymm1, %xmm2
; AVX512VL-NEXT:    vmovdqa {{.*#+}} xmm3 = <u,u,0,8,u,u,u,u,u,u,u,u,u,u,u,u>
; AVX512VL-NEXT:    vpshufb %xmm3, %xmm2, %xmm2
; AVX512VL-NEXT:    vpshufb %xmm3, %xmm1, %xmm1
; AVX512VL-NEXT:    vpunpcklwd {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1],xmm1[2],xmm2[2],xmm1[3],xmm2[3]
; AVX512VL-NEXT:    vextracti128 $1, %ymm0, %xmm2
; AVX512VL-NEXT:    vmovdqa {{.*#+}} xmm3 = <0,8,u,u,u,u,u,u,u,u,u,u,u,u,u,u>
; AVX512VL-NEXT:    vpshufb %xmm3, %xmm2, %xmm2
; AVX512VL-NEXT:    vpshufb %xmm3, %xmm0, %xmm0
; AVX512VL-NEXT:    vpunpcklwd {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3]
; AVX512VL-NEXT:    vpblendd {{.*#+}} xmm0 = xmm0[0],xmm1[1],xmm0[2,3]
; AVX512VL-NEXT:    vmovq %xmm0, (%rsi)
; AVX512VL-NEXT:    vzeroupper
; AVX512VL-NEXT:    retq
;
; AVX512BW-LABEL: shuffle_v64i8_to_v8i8:
; AVX512BW:       # %bb.0:
; AVX512BW-NEXT:    vmovdqa64 (%rdi), %zmm0
; AVX512BW-NEXT:    vextracti64x4 $1, %zmm0, %ymm1
; AVX512BW-NEXT:    vextracti128 $1, %ymm1, %xmm2
; AVX512BW-NEXT:    vmovdqa {{.*#+}} xmm3 = <u,u,0,8,u,u,u,u,u,u,u,u,u,u,u,u>
; AVX512BW-NEXT:    vpshufb %xmm3, %xmm2, %xmm2
; AVX512BW-NEXT:    vpshufb %xmm3, %xmm1, %xmm1
; AVX512BW-NEXT:    vpunpcklwd {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1],xmm1[2],xmm2[2],xmm1[3],xmm2[3]
; AVX512BW-NEXT:    vextracti128 $1, %ymm0, %xmm2
; AVX512BW-NEXT:    vmovdqa {{.*#+}} xmm3 = <0,8,u,u,u,u,u,u,u,u,u,u,u,u,u,u>
; AVX512BW-NEXT:    vpshufb %xmm3, %xmm2, %xmm2
; AVX512BW-NEXT:    vpshufb %xmm3, %xmm0, %xmm0
; AVX512BW-NEXT:    vpunpcklwd {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3]
; AVX512BW-NEXT:    vpblendd {{.*#+}} xmm0 = xmm0[0],xmm1[1],xmm0[2,3]
; AVX512BW-NEXT:    vmovq %xmm0, (%rsi)
; AVX512BW-NEXT:    vzeroupper
; AVX512BW-NEXT:    retq
;
; AVX512BWVL-LABEL: shuffle_v64i8_to_v8i8:
; AVX512BWVL:       # %bb.0:
; AVX512BWVL-NEXT:    vmovdqa64 (%rdi), %zmm0
; AVX512BWVL-NEXT:    vextracti64x4 $1, %zmm0, %ymm1
; AVX512BWVL-NEXT:    vmovdqa {{.*#+}} ymm2 = <0,4,8,12,16,20,24,28,u,u,u,u,u,u,u,u>
; AVX512BWVL-NEXT:    vpermi2w %ymm1, %ymm0, %ymm2
; AVX512BWVL-NEXT:    vpmovwb %xmm2, (%rsi)
; AVX512BWVL-NEXT:    vzeroupper
; AVX512BWVL-NEXT:    retq
  %vec = load <64 x i8>, <64 x i8>* %L
  %strided.vec = shufflevector <64 x i8> %vec, <64 x i8> undef, <8 x i32> <i32 0, i32 8, i32 16, i32 24, i32 32, i32 40, i32 48, i32 56>
  store <8 x i8> %strided.vec, <8 x i8>* %S
  ret void
}

define void @trunc_v8i64_to_v8i8(<64 x i8>* %L, <8 x i8>* %S) nounwind {
; AVX512-LABEL: trunc_v8i64_to_v8i8:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmovdqa64 (%rdi), %zmm0
; AVX512-NEXT:    vpmovqb %zmm0, (%rsi)
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %vec = load <64 x i8>, <64 x i8>* %L
  %bc = bitcast <64 x i8> %vec to <8 x i64>
  %strided.vec = trunc <8 x i64> %bc to <8 x i8>
  store <8 x i8> %strided.vec, <8 x i8>* %S
  ret void
}

define <16 x i8> @trunc_shuffle_v64i8_01_05_09_13_17_21_25_29_33_37_41_45_49_53_57_61(<64 x i8> %x) {
; AVX512F-LABEL: trunc_shuffle_v64i8_01_05_09_13_17_21_25_29_33_37_41_45_49_53_57_61:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    vextracti128 $1, %ymm1, %xmm2
; AVX512F-NEXT:    vmovdqa {{.*#+}} xmm3 = <u,u,u,u,1,5,9,13,u,u,u,u,u,u,u,u>
; AVX512F-NEXT:    vpshufb %xmm3, %xmm2, %xmm2
; AVX512F-NEXT:    vpshufb %xmm3, %xmm1, %xmm1
; AVX512F-NEXT:    vpunpckldq {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
; AVX512F-NEXT:    vextracti128 $1, %ymm0, %xmm2
; AVX512F-NEXT:    vmovdqa {{.*#+}} xmm3 = <1,5,9,13,u,u,u,u,u,u,u,u,u,u,u,u>
; AVX512F-NEXT:    vpshufb %xmm3, %xmm2, %xmm2
; AVX512F-NEXT:    vpshufb %xmm3, %xmm0, %xmm0
; AVX512F-NEXT:    vpunpckldq {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; AVX512F-NEXT:    vpblendd {{.*#+}} xmm0 = xmm0[0,1],xmm1[2,3]
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: trunc_shuffle_v64i8_01_05_09_13_17_21_25_29_33_37_41_45_49_53_57_61:
; AVX512VL:       # %bb.0:
; AVX512VL-NEXT:    vextracti128 $1, %ymm1, %xmm2
; AVX512VL-NEXT:    vmovdqa {{.*#+}} xmm3 = <u,u,u,u,1,5,9,13,u,u,u,u,u,u,u,u>
; AVX512VL-NEXT:    vpshufb %xmm3, %xmm2, %xmm2
; AVX512VL-NEXT:    vpshufb %xmm3, %xmm1, %xmm1
; AVX512VL-NEXT:    vpunpckldq {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
; AVX512VL-NEXT:    vextracti128 $1, %ymm0, %xmm2
; AVX512VL-NEXT:    vmovdqa {{.*#+}} xmm3 = <1,5,9,13,u,u,u,u,u,u,u,u,u,u,u,u>
; AVX512VL-NEXT:    vpshufb %xmm3, %xmm2, %xmm2
; AVX512VL-NEXT:    vpshufb %xmm3, %xmm0, %xmm0
; AVX512VL-NEXT:    vpunpckldq {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; AVX512VL-NEXT:    vpblendd {{.*#+}} xmm0 = xmm0[0,1],xmm1[2,3]
; AVX512VL-NEXT:    vzeroupper
; AVX512VL-NEXT:    retq
;
; AVX512BW-LABEL: trunc_shuffle_v64i8_01_05_09_13_17_21_25_29_33_37_41_45_49_53_57_61:
; AVX512BW:       # %bb.0:
; AVX512BW-NEXT:    vextracti64x4 $1, %zmm0, %ymm1
; AVX512BW-NEXT:    vextracti128 $1, %ymm1, %xmm2
; AVX512BW-NEXT:    vmovdqa {{.*#+}} xmm3 = <u,u,u,u,1,5,9,13,u,u,u,u,u,u,u,u>
; AVX512BW-NEXT:    vpshufb %xmm3, %xmm2, %xmm2
; AVX512BW-NEXT:    vpshufb %xmm3, %xmm1, %xmm1
; AVX512BW-NEXT:    vpunpckldq {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
; AVX512BW-NEXT:    vextracti128 $1, %ymm0, %xmm2
; AVX512BW-NEXT:    vmovdqa {{.*#+}} xmm3 = <1,5,9,13,u,u,u,u,u,u,u,u,u,u,u,u>
; AVX512BW-NEXT:    vpshufb %xmm3, %xmm2, %xmm2
; AVX512BW-NEXT:    vpshufb %xmm3, %xmm0, %xmm0
; AVX512BW-NEXT:    vpunpckldq {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; AVX512BW-NEXT:    vpblendd {{.*#+}} xmm0 = xmm0[0,1],xmm1[2,3]
; AVX512BW-NEXT:    vzeroupper
; AVX512BW-NEXT:    retq
;
; AVX512BWVL-LABEL: trunc_shuffle_v64i8_01_05_09_13_17_21_25_29_33_37_41_45_49_53_57_61:
; AVX512BWVL:       # %bb.0:
; AVX512BWVL-NEXT:    vextracti64x4 $1, %zmm0, %ymm1
; AVX512BWVL-NEXT:    vextracti128 $1, %ymm1, %xmm2
; AVX512BWVL-NEXT:    vmovdqa {{.*#+}} xmm3 = <u,u,u,u,1,5,9,13,u,u,u,u,u,u,u,u>
; AVX512BWVL-NEXT:    vpshufb %xmm3, %xmm2, %xmm2
; AVX512BWVL-NEXT:    vpshufb %xmm3, %xmm1, %xmm1
; AVX512BWVL-NEXT:    vpunpckldq {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
; AVX512BWVL-NEXT:    vextracti128 $1, %ymm0, %xmm2
; AVX512BWVL-NEXT:    vmovdqa {{.*#+}} xmm3 = <1,5,9,13,u,u,u,u,u,u,u,u,u,u,u,u>
; AVX512BWVL-NEXT:    vpshufb %xmm3, %xmm2, %xmm2
; AVX512BWVL-NEXT:    vpshufb %xmm3, %xmm0, %xmm0
; AVX512BWVL-NEXT:    vpunpckldq {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; AVX512BWVL-NEXT:    vpblendd {{.*#+}} xmm0 = xmm0[0,1],xmm1[2,3]
; AVX512BWVL-NEXT:    vzeroupper
; AVX512BWVL-NEXT:    retq
  %res = shufflevector <64 x i8> %x, <64 x i8> %x, <16 x i32> <i32 1, i32 5, i32 9, i32 13, i32 17, i32 21, i32 25, i32 29, i32 33, i32 37, i32 41, i32 45, i32 49, i32 53, i32 57, i32 61>
  ret <16 x i8> %res
}

define <16 x i8> @trunc_shuffle_v64i8_01_05_09_13_17_21_25_29_33_37_41_45_49_53_57_62(<64 x i8> %x) {
; AVX512F-LABEL: trunc_shuffle_v64i8_01_05_09_13_17_21_25_29_33_37_41_45_49_53_57_62:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    vextracti128 $1, %ymm0, %xmm2
; AVX512F-NEXT:    vmovdqa {{.*#+}} xmm3 = <1,5,9,13,u,u,u,u,u,u,u,u,u,u,u,u>
; AVX512F-NEXT:    vpshufb %xmm3, %xmm2, %xmm2
; AVX512F-NEXT:    vpshufb %xmm3, %xmm0, %xmm0
; AVX512F-NEXT:    vpunpckldq {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; AVX512F-NEXT:    vextracti128 $1, %ymm1, %xmm2
; AVX512F-NEXT:    vpshufb {{.*#+}} xmm2 = xmm2[u,u,u,u,1,5,9,14,u,u,u,u,u,u,u,u]
; AVX512F-NEXT:    vpshufb {{.*#+}} xmm1 = xmm1[u,u,u,u,1,5,9,13,u,u,u,u,u,u,u,u]
; AVX512F-NEXT:    vpunpckldq {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
; AVX512F-NEXT:    vpblendd {{.*#+}} xmm0 = xmm0[0,1],xmm1[2,3]
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: trunc_shuffle_v64i8_01_05_09_13_17_21_25_29_33_37_41_45_49_53_57_62:
; AVX512VL:       # %bb.0:
; AVX512VL-NEXT:    vextracti128 $1, %ymm0, %xmm2
; AVX512VL-NEXT:    vmovdqa {{.*#+}} xmm3 = <1,5,9,13,u,u,u,u,u,u,u,u,u,u,u,u>
; AVX512VL-NEXT:    vpshufb %xmm3, %xmm2, %xmm2
; AVX512VL-NEXT:    vpshufb %xmm3, %xmm0, %xmm0
; AVX512VL-NEXT:    vpunpckldq {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; AVX512VL-NEXT:    vextracti128 $1, %ymm1, %xmm2
; AVX512VL-NEXT:    vpshufb {{.*#+}} xmm2 = xmm2[u,u,u,u,1,5,9,14,u,u,u,u,u,u,u,u]
; AVX512VL-NEXT:    vpshufb {{.*#+}} xmm1 = xmm1[u,u,u,u,1,5,9,13,u,u,u,u,u,u,u,u]
; AVX512VL-NEXT:    vpunpckldq {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
; AVX512VL-NEXT:    vpblendd {{.*#+}} xmm0 = xmm0[0,1],xmm1[2,3]
; AVX512VL-NEXT:    vzeroupper
; AVX512VL-NEXT:    retq
;
; AVX512BW-LABEL: trunc_shuffle_v64i8_01_05_09_13_17_21_25_29_33_37_41_45_49_53_57_62:
; AVX512BW:       # %bb.0:
; AVX512BW-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX512BW-NEXT:    vmovdqa {{.*#+}} xmm2 = <1,5,9,13,u,u,u,u,u,u,u,u,u,u,u,u>
; AVX512BW-NEXT:    vpshufb %xmm2, %xmm1, %xmm1
; AVX512BW-NEXT:    vpshufb %xmm2, %xmm0, %xmm2
; AVX512BW-NEXT:    vpunpckldq {{.*#+}} xmm1 = xmm2[0],xmm1[0],xmm2[1],xmm1[1]
; AVX512BW-NEXT:    vextracti64x4 $1, %zmm0, %ymm0
; AVX512BW-NEXT:    vextracti128 $1, %ymm0, %xmm2
; AVX512BW-NEXT:    vpshufb {{.*#+}} xmm2 = xmm2[u,u,u,u,1,5,9,14,u,u,u,u,u,u,u,u]
; AVX512BW-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[u,u,u,u,1,5,9,13,u,u,u,u,u,u,u,u]
; AVX512BW-NEXT:    vpunpckldq {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; AVX512BW-NEXT:    vpblendd {{.*#+}} xmm0 = xmm1[0,1],xmm0[2,3]
; AVX512BW-NEXT:    vzeroupper
; AVX512BW-NEXT:    retq
;
; AVX512BWVL-LABEL: trunc_shuffle_v64i8_01_05_09_13_17_21_25_29_33_37_41_45_49_53_57_62:
; AVX512BWVL:       # %bb.0:
; AVX512BWVL-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX512BWVL-NEXT:    vmovdqa {{.*#+}} xmm2 = <1,5,9,13,u,u,u,u,u,u,u,u,u,u,u,u>
; AVX512BWVL-NEXT:    vpshufb %xmm2, %xmm1, %xmm1
; AVX512BWVL-NEXT:    vpshufb %xmm2, %xmm0, %xmm2
; AVX512BWVL-NEXT:    vpunpckldq {{.*#+}} xmm1 = xmm2[0],xmm1[0],xmm2[1],xmm1[1]
; AVX512BWVL-NEXT:    vextracti64x4 $1, %zmm0, %ymm0
; AVX512BWVL-NEXT:    vextracti128 $1, %ymm0, %xmm2
; AVX512BWVL-NEXT:    vpshufb {{.*#+}} xmm2 = xmm2[u,u,u,u,1,5,9,14,u,u,u,u,u,u,u,u]
; AVX512BWVL-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[u,u,u,u,1,5,9,13,u,u,u,u,u,u,u,u]
; AVX512BWVL-NEXT:    vpunpckldq {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; AVX512BWVL-NEXT:    vpblendd {{.*#+}} xmm0 = xmm1[0,1],xmm0[2,3]
; AVX512BWVL-NEXT:    vzeroupper
; AVX512BWVL-NEXT:    retq
  %res = shufflevector <64 x i8> %x, <64 x i8> %x, <16 x i32> <i32 1, i32 5, i32 9, i32 13, i32 17, i32 21, i32 25, i32 29, i32 33, i32 37, i32 41, i32 45, i32 49, i32 53, i32 57, i32 62>
  ret <16 x i8> %res
}

define <4 x double> @PR34175(<32 x i16>* %p) {
; AVX512F-LABEL: PR34175:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    vmovdqu (%rdi), %ymm0
; AVX512F-NEXT:    vmovdqu 32(%rdi), %ymm1
; AVX512F-NEXT:    vextracti128 $1, %ymm0, %xmm2
; AVX512F-NEXT:    vpunpcklwd {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3]
; AVX512F-NEXT:    vextracti128 $1, %ymm1, %xmm2
; AVX512F-NEXT:    vpunpcklwd {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1],xmm1[2],xmm2[2],xmm1[3],xmm2[3]
; AVX512F-NEXT:    vpbroadcastd %xmm1, %xmm1
; AVX512F-NEXT:    vpblendd {{.*#+}} xmm0 = xmm0[0],xmm1[1],xmm0[2,3]
; AVX512F-NEXT:    vpmovzxwd {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero
; AVX512F-NEXT:    vcvtdq2pd %xmm0, %ymm0
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: PR34175:
; AVX512VL:       # %bb.0:
; AVX512VL-NEXT:    vmovdqu (%rdi), %ymm0
; AVX512VL-NEXT:    vmovdqu 32(%rdi), %ymm1
; AVX512VL-NEXT:    vextracti128 $1, %ymm0, %xmm2
; AVX512VL-NEXT:    vpunpcklwd {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3]
; AVX512VL-NEXT:    vextracti128 $1, %ymm1, %xmm2
; AVX512VL-NEXT:    vpunpcklwd {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1],xmm1[2],xmm2[2],xmm1[3],xmm2[3]
; AVX512VL-NEXT:    vpbroadcastd %xmm1, %xmm1
; AVX512VL-NEXT:    vpblendd {{.*#+}} xmm0 = xmm0[0],xmm1[1],xmm0[2,3]
; AVX512VL-NEXT:    vpmovzxwd {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero
; AVX512VL-NEXT:    vcvtdq2pd %xmm0, %ymm0
; AVX512VL-NEXT:    retq
;
; AVX512BW-LABEL: PR34175:
; AVX512BW:       # %bb.0:
; AVX512BW-NEXT:    vmovdqu64 (%rdi), %zmm0
; AVX512BW-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX512BW-NEXT:    vpunpcklwd {{.*#+}} xmm1 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; AVX512BW-NEXT:    vextracti64x4 $1, %zmm0, %ymm0
; AVX512BW-NEXT:    vextracti128 $1, %ymm0, %xmm2
; AVX512BW-NEXT:    vpunpcklwd {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3]
; AVX512BW-NEXT:    vpbroadcastd %xmm0, %xmm0
; AVX512BW-NEXT:    vpblendd {{.*#+}} xmm0 = xmm1[0],xmm0[1],xmm1[2,3]
; AVX512BW-NEXT:    vpmovzxwd {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero
; AVX512BW-NEXT:    vcvtdq2pd %xmm0, %ymm0
; AVX512BW-NEXT:    retq
;
; AVX512BWVL-LABEL: PR34175:
; AVX512BWVL:       # %bb.0:
; AVX512BWVL-NEXT:    vmovdqu64 (%rdi), %zmm0
; AVX512BWVL-NEXT:    vextracti64x4 $1, %zmm0, %ymm1
; AVX512BWVL-NEXT:    vmovdqa {{.*#+}} ymm2 = <0,8,16,24,u,u,u,u,u,u,u,u,u,u,u,u>
; AVX512BWVL-NEXT:    vpermi2w %ymm1, %ymm0, %ymm2
; AVX512BWVL-NEXT:    vpmovzxwd {{.*#+}} xmm0 = xmm2[0],zero,xmm2[1],zero,xmm2[2],zero,xmm2[3],zero
; AVX512BWVL-NEXT:    vcvtdq2pd %xmm0, %ymm0
; AVX512BWVL-NEXT:    retq
  %v = load <32 x i16>, <32 x i16>* %p, align 2
  %shuf = shufflevector <32 x i16> %v, <32 x i16> undef, <4 x i32> <i32 0, i32 8, i32 16, i32 24>
  %tofp = uitofp <4 x i16> %shuf to <4 x double>
  ret <4 x double> %tofp
}
