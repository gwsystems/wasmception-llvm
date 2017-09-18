; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse2 | FileCheck %s --check-prefix=SSE --check-prefix=SSE2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse4.2 | FileCheck %s --check-prefix=SSE --check-prefix=SSE42
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx | FileCheck %s --check-prefix=AVX --check-prefix=AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx2 | FileCheck %s --check-prefix=AVX --check-prefix=AVX2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f | FileCheck %s --check-prefix=AVX512 --check-prefix=AVX512F
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512vl | FileCheck %s --check-prefix=AVX512 --check-prefix=AVX512VL
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512bw | FileCheck %s --check-prefix=AVX512 --check-prefix=AVX512BW
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512bw,+avx512vl | FileCheck %s --check-prefix=AVX512 --check-prefix=AVX512BWVL

; PR31551
; Pairs of shufflevector:trunc functions with functional equivalence.
; Ideally, the shuffles should be lowered to code with the same quality as the truncates.

define void @shuffle_v16i8_to_v8i8(<16 x i8>* %L, <8 x i8>* %S) nounwind {
; SSE2-LABEL: shuffle_v16i8_to_v8i8:
; SSE2:       # BB#0:
; SSE2-NEXT:    movdqa (%rdi), %xmm0
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE2-NEXT:    packuswb %xmm0, %xmm0
; SSE2-NEXT:    movq %xmm0, (%rsi)
; SSE2-NEXT:    retq
;
; SSE42-LABEL: shuffle_v16i8_to_v8i8:
; SSE42:       # BB#0:
; SSE42-NEXT:    movdqa (%rdi), %xmm0
; SSE42-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u]
; SSE42-NEXT:    movq %xmm0, (%rsi)
; SSE42-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_to_v8i8:
; AVX:       # BB#0:
; AVX-NEXT:    vmovdqa (%rdi), %xmm0
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u]
; AVX-NEXT:    vmovq %xmm0, (%rsi)
; AVX-NEXT:    retq
;
; AVX512F-LABEL: shuffle_v16i8_to_v8i8:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512F-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u]
; AVX512F-NEXT:    vmovq %xmm0, (%rsi)
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: shuffle_v16i8_to_v8i8:
; AVX512VL:       # BB#0:
; AVX512VL-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512VL-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u]
; AVX512VL-NEXT:    vmovq %xmm0, (%rsi)
; AVX512VL-NEXT:    retq
;
; AVX512BW-LABEL: shuffle_v16i8_to_v8i8:
; AVX512BW:       # BB#0:
; AVX512BW-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512BW-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u]
; AVX512BW-NEXT:    vmovq %xmm0, (%rsi)
; AVX512BW-NEXT:    retq
;
; AVX512BWVL-LABEL: shuffle_v16i8_to_v8i8:
; AVX512BWVL:       # BB#0:
; AVX512BWVL-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512BWVL-NEXT:    vpmovwb %xmm0, (%rsi)
; AVX512BWVL-NEXT:    retq
  %vec = load <16 x i8>, <16 x i8>* %L
  %strided.vec = shufflevector <16 x i8> %vec, <16 x i8> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  store <8 x i8> %strided.vec, <8 x i8>* %S
  ret void
}

define void @trunc_v8i16_to_v8i8(<16 x i8>* %L, <8 x i8>* %S) nounwind {
; SSE2-LABEL: trunc_v8i16_to_v8i8:
; SSE2:       # BB#0:
; SSE2-NEXT:    movdqa (%rdi), %xmm0
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE2-NEXT:    packuswb %xmm0, %xmm0
; SSE2-NEXT:    movq %xmm0, (%rsi)
; SSE2-NEXT:    retq
;
; SSE42-LABEL: trunc_v8i16_to_v8i8:
; SSE42:       # BB#0:
; SSE42-NEXT:    movdqa (%rdi), %xmm0
; SSE42-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u]
; SSE42-NEXT:    movq %xmm0, (%rsi)
; SSE42-NEXT:    retq
;
; AVX-LABEL: trunc_v8i16_to_v8i8:
; AVX:       # BB#0:
; AVX-NEXT:    vmovdqa (%rdi), %xmm0
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u]
; AVX-NEXT:    vmovq %xmm0, (%rsi)
; AVX-NEXT:    retq
;
; AVX512F-LABEL: trunc_v8i16_to_v8i8:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512F-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u]
; AVX512F-NEXT:    vmovq %xmm0, (%rsi)
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: trunc_v8i16_to_v8i8:
; AVX512VL:       # BB#0:
; AVX512VL-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512VL-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u]
; AVX512VL-NEXT:    vmovq %xmm0, (%rsi)
; AVX512VL-NEXT:    retq
;
; AVX512BW-LABEL: trunc_v8i16_to_v8i8:
; AVX512BW:       # BB#0:
; AVX512BW-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512BW-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u]
; AVX512BW-NEXT:    vmovq %xmm0, (%rsi)
; AVX512BW-NEXT:    retq
;
; AVX512BWVL-LABEL: trunc_v8i16_to_v8i8:
; AVX512BWVL:       # BB#0:
; AVX512BWVL-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512BWVL-NEXT:    vpmovwb %xmm0, (%rsi)
; AVX512BWVL-NEXT:    retq
  %vec = load <16 x i8>, <16 x i8>* %L
  %bc = bitcast <16 x i8> %vec to <8 x i16>
  %strided.vec = trunc <8 x i16> %bc to <8 x i8>
  store <8 x i8> %strided.vec, <8 x i8>* %S
  ret void
}

define void @shuffle_v8i16_to_v4i16(<8 x i16>* %L, <4 x i16>* %S) nounwind {
; SSE2-LABEL: shuffle_v8i16_to_v4i16:
; SSE2:       # BB#0:
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = mem[0,2,2,3,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,4,6,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; SSE2-NEXT:    movq %xmm0, (%rsi)
; SSE2-NEXT:    retq
;
; SSE42-LABEL: shuffle_v8i16_to_v4i16:
; SSE42:       # BB#0:
; SSE42-NEXT:    movdqa (%rdi), %xmm0
; SSE42-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,1,4,5,8,9,12,13,8,9,12,13,12,13,14,15]
; SSE42-NEXT:    movq %xmm0, (%rsi)
; SSE42-NEXT:    retq
;
; AVX-LABEL: shuffle_v8i16_to_v4i16:
; AVX:       # BB#0:
; AVX-NEXT:    vmovdqa (%rdi), %xmm0
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,1,4,5,8,9,12,13,8,9,12,13,12,13,14,15]
; AVX-NEXT:    vmovq %xmm0, (%rsi)
; AVX-NEXT:    retq
;
; AVX512F-LABEL: shuffle_v8i16_to_v4i16:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512F-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,1,4,5,8,9,12,13,8,9,12,13,12,13,14,15]
; AVX512F-NEXT:    vmovq %xmm0, (%rsi)
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: shuffle_v8i16_to_v4i16:
; AVX512VL:       # BB#0:
; AVX512VL-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512VL-NEXT:    vpmovdw %xmm0, (%rsi)
; AVX512VL-NEXT:    retq
;
; AVX512BW-LABEL: shuffle_v8i16_to_v4i16:
; AVX512BW:       # BB#0:
; AVX512BW-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512BW-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,1,4,5,8,9,12,13,8,9,12,13,12,13,14,15]
; AVX512BW-NEXT:    vmovq %xmm0, (%rsi)
; AVX512BW-NEXT:    retq
;
; AVX512BWVL-LABEL: shuffle_v8i16_to_v4i16:
; AVX512BWVL:       # BB#0:
; AVX512BWVL-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512BWVL-NEXT:    vpmovdw %xmm0, (%rsi)
; AVX512BWVL-NEXT:    retq
  %vec = load <8 x i16>, <8 x i16>* %L
  %strided.vec = shufflevector <8 x i16> %vec, <8 x i16> undef, <4 x i32> <i32 0, i32 2, i32 4, i32 6>
  store <4 x i16> %strided.vec, <4 x i16>* %S
  ret void
}

define void @trunc_v4i32_to_v4i16(<8 x i16>* %L, <4 x i16>* %S) nounwind {
; SSE2-LABEL: trunc_v4i32_to_v4i16:
; SSE2:       # BB#0:
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = mem[0,2,2,3,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,4,6,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; SSE2-NEXT:    movq %xmm0, (%rsi)
; SSE2-NEXT:    retq
;
; SSE42-LABEL: trunc_v4i32_to_v4i16:
; SSE42:       # BB#0:
; SSE42-NEXT:    movdqa (%rdi), %xmm0
; SSE42-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,1,4,5,8,9,12,13,8,9,12,13,12,13,14,15]
; SSE42-NEXT:    movq %xmm0, (%rsi)
; SSE42-NEXT:    retq
;
; AVX-LABEL: trunc_v4i32_to_v4i16:
; AVX:       # BB#0:
; AVX-NEXT:    vmovdqa (%rdi), %xmm0
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,1,4,5,8,9,12,13,8,9,12,13,12,13,14,15]
; AVX-NEXT:    vmovq %xmm0, (%rsi)
; AVX-NEXT:    retq
;
; AVX512F-LABEL: trunc_v4i32_to_v4i16:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512F-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,1,4,5,8,9,12,13,8,9,12,13,12,13,14,15]
; AVX512F-NEXT:    vmovq %xmm0, (%rsi)
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: trunc_v4i32_to_v4i16:
; AVX512VL:       # BB#0:
; AVX512VL-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512VL-NEXT:    vpmovdw %xmm0, (%rsi)
; AVX512VL-NEXT:    retq
;
; AVX512BW-LABEL: trunc_v4i32_to_v4i16:
; AVX512BW:       # BB#0:
; AVX512BW-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512BW-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,1,4,5,8,9,12,13,8,9,12,13,12,13,14,15]
; AVX512BW-NEXT:    vmovq %xmm0, (%rsi)
; AVX512BW-NEXT:    retq
;
; AVX512BWVL-LABEL: trunc_v4i32_to_v4i16:
; AVX512BWVL:       # BB#0:
; AVX512BWVL-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512BWVL-NEXT:    vpmovdw %xmm0, (%rsi)
; AVX512BWVL-NEXT:    retq
  %vec = load <8 x i16>, <8 x i16>* %L
  %bc = bitcast <8 x i16> %vec to <4 x i32>
  %strided.vec = trunc <4 x i32> %bc to <4 x i16>
  store <4 x i16> %strided.vec, <4 x i16>* %S
  ret void
}

define void @shuffle_v4i32_to_v2i32(<4 x i32>* %L, <2 x i32>* %S) nounwind {
; SSE-LABEL: shuffle_v4i32_to_v2i32:
; SSE:       # BB#0:
; SSE-NEXT:    pshufd {{.*#+}} xmm0 = mem[0,2,2,3]
; SSE-NEXT:    movq %xmm0, (%rsi)
; SSE-NEXT:    retq
;
; AVX-LABEL: shuffle_v4i32_to_v2i32:
; AVX:       # BB#0:
; AVX-NEXT:    vpermilps {{.*#+}} xmm0 = mem[0,2,2,3]
; AVX-NEXT:    vmovlps %xmm0, (%rsi)
; AVX-NEXT:    retq
;
; AVX512F-LABEL: shuffle_v4i32_to_v2i32:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vpermilps {{.*#+}} xmm0 = mem[0,2,2,3]
; AVX512F-NEXT:    vmovlps %xmm0, (%rsi)
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: shuffle_v4i32_to_v2i32:
; AVX512VL:       # BB#0:
; AVX512VL-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512VL-NEXT:    vpmovqd %xmm0, (%rsi)
; AVX512VL-NEXT:    retq
;
; AVX512BW-LABEL: shuffle_v4i32_to_v2i32:
; AVX512BW:       # BB#0:
; AVX512BW-NEXT:    vpermilps {{.*#+}} xmm0 = mem[0,2,2,3]
; AVX512BW-NEXT:    vmovlps %xmm0, (%rsi)
; AVX512BW-NEXT:    retq
;
; AVX512BWVL-LABEL: shuffle_v4i32_to_v2i32:
; AVX512BWVL:       # BB#0:
; AVX512BWVL-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512BWVL-NEXT:    vpmovqd %xmm0, (%rsi)
; AVX512BWVL-NEXT:    retq
  %vec = load <4 x i32>, <4 x i32>* %L
  %strided.vec = shufflevector <4 x i32> %vec, <4 x i32> undef, <2 x i32> <i32 0, i32 2>
  store <2 x i32> %strided.vec, <2 x i32>* %S
  ret void
}

define void @trunc_v2i64_to_v2i32(<4 x i32>* %L, <2 x i32>* %S) nounwind {
; SSE-LABEL: trunc_v2i64_to_v2i32:
; SSE:       # BB#0:
; SSE-NEXT:    pshufd {{.*#+}} xmm0 = mem[0,2,2,3]
; SSE-NEXT:    movq %xmm0, (%rsi)
; SSE-NEXT:    retq
;
; AVX-LABEL: trunc_v2i64_to_v2i32:
; AVX:       # BB#0:
; AVX-NEXT:    vpermilps {{.*#+}} xmm0 = mem[0,2,2,3]
; AVX-NEXT:    vmovlps %xmm0, (%rsi)
; AVX-NEXT:    retq
;
; AVX512F-LABEL: trunc_v2i64_to_v2i32:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vpermilps {{.*#+}} xmm0 = mem[0,2,2,3]
; AVX512F-NEXT:    vmovlps %xmm0, (%rsi)
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: trunc_v2i64_to_v2i32:
; AVX512VL:       # BB#0:
; AVX512VL-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512VL-NEXT:    vpmovqd %xmm0, (%rsi)
; AVX512VL-NEXT:    retq
;
; AVX512BW-LABEL: trunc_v2i64_to_v2i32:
; AVX512BW:       # BB#0:
; AVX512BW-NEXT:    vpermilps {{.*#+}} xmm0 = mem[0,2,2,3]
; AVX512BW-NEXT:    vmovlps %xmm0, (%rsi)
; AVX512BW-NEXT:    retq
;
; AVX512BWVL-LABEL: trunc_v2i64_to_v2i32:
; AVX512BWVL:       # BB#0:
; AVX512BWVL-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512BWVL-NEXT:    vpmovqd %xmm0, (%rsi)
; AVX512BWVL-NEXT:    retq
  %vec = load <4 x i32>, <4 x i32>* %L
  %bc = bitcast <4 x i32> %vec to <2 x i64>
  %strided.vec = trunc <2 x i64> %bc to <2 x i32>
  store <2 x i32> %strided.vec, <2 x i32>* %S
  ret void
}

define void @shuffle_v16i8_to_v4i8(<16 x i8>* %L, <4 x i8>* %S) nounwind {
; SSE2-LABEL: shuffle_v16i8_to_v4i8:
; SSE2:       # BB#0:
; SSE2-NEXT:    movdqa (%rdi), %xmm0
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE2-NEXT:    packuswb %xmm0, %xmm0
; SSE2-NEXT:    packuswb %xmm0, %xmm0
; SSE2-NEXT:    movd %xmm0, (%rsi)
; SSE2-NEXT:    retq
;
; SSE42-LABEL: shuffle_v16i8_to_v4i8:
; SSE42:       # BB#0:
; SSE42-NEXT:    movdqa (%rdi), %xmm0
; SSE42-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,4,8,12,u,u,u,u,u,u,u,u,u,u,u,u]
; SSE42-NEXT:    movd %xmm0, (%rsi)
; SSE42-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_to_v4i8:
; AVX:       # BB#0:
; AVX-NEXT:    vmovdqa (%rdi), %xmm0
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,4,8,12,u,u,u,u,u,u,u,u,u,u,u,u]
; AVX-NEXT:    vmovd %xmm0, (%rsi)
; AVX-NEXT:    retq
;
; AVX512F-LABEL: shuffle_v16i8_to_v4i8:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512F-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,4,8,12,u,u,u,u,u,u,u,u,u,u,u,u]
; AVX512F-NEXT:    vmovd %xmm0, (%rsi)
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: shuffle_v16i8_to_v4i8:
; AVX512VL:       # BB#0:
; AVX512VL-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512VL-NEXT:    vpmovdb %xmm0, (%rsi)
; AVX512VL-NEXT:    retq
;
; AVX512BW-LABEL: shuffle_v16i8_to_v4i8:
; AVX512BW:       # BB#0:
; AVX512BW-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512BW-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,4,8,12,u,u,u,u,u,u,u,u,u,u,u,u]
; AVX512BW-NEXT:    vmovd %xmm0, (%rsi)
; AVX512BW-NEXT:    retq
;
; AVX512BWVL-LABEL: shuffle_v16i8_to_v4i8:
; AVX512BWVL:       # BB#0:
; AVX512BWVL-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512BWVL-NEXT:    vpmovdb %xmm0, (%rsi)
; AVX512BWVL-NEXT:    retq
  %vec = load <16 x i8>, <16 x i8>* %L
  %strided.vec = shufflevector <16 x i8> %vec, <16 x i8> undef, <4 x i32> <i32 0, i32 4, i32 8, i32 12>
  store <4 x i8> %strided.vec, <4 x i8>* %S
  ret void
}

define void @trunc_v4i32_to_v4i8(<16 x i8>* %L, <4 x i8>* %S) nounwind {
; SSE2-LABEL: trunc_v4i32_to_v4i8:
; SSE2:       # BB#0:
; SSE2-NEXT:    movdqa (%rdi), %xmm0
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE2-NEXT:    packuswb %xmm0, %xmm0
; SSE2-NEXT:    packuswb %xmm0, %xmm0
; SSE2-NEXT:    movd %xmm0, (%rsi)
; SSE2-NEXT:    retq
;
; SSE42-LABEL: trunc_v4i32_to_v4i8:
; SSE42:       # BB#0:
; SSE42-NEXT:    movdqa (%rdi), %xmm0
; SSE42-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,4,8,12,u,u,u,u,u,u,u,u,u,u,u,u]
; SSE42-NEXT:    movd %xmm0, (%rsi)
; SSE42-NEXT:    retq
;
; AVX-LABEL: trunc_v4i32_to_v4i8:
; AVX:       # BB#0:
; AVX-NEXT:    vmovdqa (%rdi), %xmm0
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,4,8,12,u,u,u,u,u,u,u,u,u,u,u,u]
; AVX-NEXT:    vmovd %xmm0, (%rsi)
; AVX-NEXT:    retq
;
; AVX512F-LABEL: trunc_v4i32_to_v4i8:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512F-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,4,8,12,u,u,u,u,u,u,u,u,u,u,u,u]
; AVX512F-NEXT:    vmovd %xmm0, (%rsi)
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: trunc_v4i32_to_v4i8:
; AVX512VL:       # BB#0:
; AVX512VL-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512VL-NEXT:    vpmovdb %xmm0, (%rsi)
; AVX512VL-NEXT:    retq
;
; AVX512BW-LABEL: trunc_v4i32_to_v4i8:
; AVX512BW:       # BB#0:
; AVX512BW-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512BW-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,4,8,12,u,u,u,u,u,u,u,u,u,u,u,u]
; AVX512BW-NEXT:    vmovd %xmm0, (%rsi)
; AVX512BW-NEXT:    retq
;
; AVX512BWVL-LABEL: trunc_v4i32_to_v4i8:
; AVX512BWVL:       # BB#0:
; AVX512BWVL-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512BWVL-NEXT:    vpmovdb %xmm0, (%rsi)
; AVX512BWVL-NEXT:    retq
  %vec = load <16 x i8>, <16 x i8>* %L
  %bc = bitcast <16 x i8> %vec to <4 x i32>
  %strided.vec = trunc <4 x i32> %bc to <4 x i8>
  store <4 x i8> %strided.vec, <4 x i8>* %S
  ret void
}

define void @shuffle_v8i16_to_v2i16(<8 x i16>* %L, <2 x i16>* %S) nounwind {
; SSE-LABEL: shuffle_v8i16_to_v2i16:
; SSE:       # BB#0:
; SSE-NEXT:    pshufd {{.*#+}} xmm0 = mem[0,2,2,3]
; SSE-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,2,2,3,4,5,6,7]
; SSE-NEXT:    movd %xmm0, (%rsi)
; SSE-NEXT:    retq
;
; AVX-LABEL: shuffle_v8i16_to_v2i16:
; AVX:       # BB#0:
; AVX-NEXT:    vpshufd {{.*#+}} xmm0 = mem[0,2,2,3]
; AVX-NEXT:    vpshuflw {{.*#+}} xmm0 = xmm0[0,2,2,3,4,5,6,7]
; AVX-NEXT:    vmovd %xmm0, (%rsi)
; AVX-NEXT:    retq
;
; AVX512F-LABEL: shuffle_v8i16_to_v2i16:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vpshufd {{.*#+}} xmm0 = mem[0,2,2,3]
; AVX512F-NEXT:    vpshuflw {{.*#+}} xmm0 = xmm0[0,2,2,3,4,5,6,7]
; AVX512F-NEXT:    vmovd %xmm0, (%rsi)
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: shuffle_v8i16_to_v2i16:
; AVX512VL:       # BB#0:
; AVX512VL-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512VL-NEXT:    vpmovqw %xmm0, (%rsi)
; AVX512VL-NEXT:    retq
;
; AVX512BW-LABEL: shuffle_v8i16_to_v2i16:
; AVX512BW:       # BB#0:
; AVX512BW-NEXT:    vpshufd {{.*#+}} xmm0 = mem[0,2,2,3]
; AVX512BW-NEXT:    vpshuflw {{.*#+}} xmm0 = xmm0[0,2,2,3,4,5,6,7]
; AVX512BW-NEXT:    vmovd %xmm0, (%rsi)
; AVX512BW-NEXT:    retq
;
; AVX512BWVL-LABEL: shuffle_v8i16_to_v2i16:
; AVX512BWVL:       # BB#0:
; AVX512BWVL-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512BWVL-NEXT:    vpmovqw %xmm0, (%rsi)
; AVX512BWVL-NEXT:    retq
  %vec = load <8 x i16>, <8 x i16>* %L
  %strided.vec = shufflevector <8 x i16> %vec, <8 x i16> undef, <2 x i32> <i32 0, i32 4>
  store <2 x i16> %strided.vec, <2 x i16>* %S
  ret void
}

define void @trunc_v2i64_to_v2i16(<8 x i16>* %L, <2 x i16>* %S) nounwind {
; SSE-LABEL: trunc_v2i64_to_v2i16:
; SSE:       # BB#0:
; SSE-NEXT:    pshufd {{.*#+}} xmm0 = mem[0,2,2,3]
; SSE-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,2,2,3,4,5,6,7]
; SSE-NEXT:    movd %xmm0, (%rsi)
; SSE-NEXT:    retq
;
; AVX-LABEL: trunc_v2i64_to_v2i16:
; AVX:       # BB#0:
; AVX-NEXT:    vpshufd {{.*#+}} xmm0 = mem[0,2,2,3]
; AVX-NEXT:    vpshuflw {{.*#+}} xmm0 = xmm0[0,2,2,3,4,5,6,7]
; AVX-NEXT:    vmovd %xmm0, (%rsi)
; AVX-NEXT:    retq
;
; AVX512F-LABEL: trunc_v2i64_to_v2i16:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vpshufd {{.*#+}} xmm0 = mem[0,2,2,3]
; AVX512F-NEXT:    vpshuflw {{.*#+}} xmm0 = xmm0[0,2,2,3,4,5,6,7]
; AVX512F-NEXT:    vmovd %xmm0, (%rsi)
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: trunc_v2i64_to_v2i16:
; AVX512VL:       # BB#0:
; AVX512VL-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512VL-NEXT:    vpmovqw %xmm0, (%rsi)
; AVX512VL-NEXT:    retq
;
; AVX512BW-LABEL: trunc_v2i64_to_v2i16:
; AVX512BW:       # BB#0:
; AVX512BW-NEXT:    vpshufd {{.*#+}} xmm0 = mem[0,2,2,3]
; AVX512BW-NEXT:    vpshuflw {{.*#+}} xmm0 = xmm0[0,2,2,3,4,5,6,7]
; AVX512BW-NEXT:    vmovd %xmm0, (%rsi)
; AVX512BW-NEXT:    retq
;
; AVX512BWVL-LABEL: trunc_v2i64_to_v2i16:
; AVX512BWVL:       # BB#0:
; AVX512BWVL-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512BWVL-NEXT:    vpmovqw %xmm0, (%rsi)
; AVX512BWVL-NEXT:    retq
  %vec = load <8 x i16>, <8 x i16>* %L
  %bc = bitcast <8 x i16> %vec to <2 x i64>
  %strided.vec = trunc <2 x i64> %bc to <2 x i16>
  store <2 x i16> %strided.vec, <2 x i16>* %S
  ret void
}

define void @shuffle_v16i8_to_v2i8(<16 x i8>* %L, <2 x i8>* %S) nounwind {
; SSE2-LABEL: shuffle_v16i8_to_v2i8:
; SSE2:       # BB#0:
; SSE2-NEXT:    movdqa (%rdi), %xmm0
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE2-NEXT:    packuswb %xmm0, %xmm0
; SSE2-NEXT:    packuswb %xmm0, %xmm0
; SSE2-NEXT:    packuswb %xmm0, %xmm0
; SSE2-NEXT:    movd %xmm0, %eax
; SSE2-NEXT:    movw %ax, (%rsi)
; SSE2-NEXT:    retq
;
; SSE42-LABEL: shuffle_v16i8_to_v2i8:
; SSE42:       # BB#0:
; SSE42-NEXT:    movdqa (%rdi), %xmm0
; SSE42-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,8,u,u,u,u,u,u,u,u,u,u,u,u,u,u]
; SSE42-NEXT:    pextrw $0, %xmm0, (%rsi)
; SSE42-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_to_v2i8:
; AVX:       # BB#0:
; AVX-NEXT:    vmovdqa (%rdi), %xmm0
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,8,u,u,u,u,u,u,u,u,u,u,u,u,u,u]
; AVX-NEXT:    vpextrw $0, %xmm0, (%rsi)
; AVX-NEXT:    retq
;
; AVX512F-LABEL: shuffle_v16i8_to_v2i8:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512F-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,8,u,u,u,u,u,u,u,u,u,u,u,u,u,u]
; AVX512F-NEXT:    vpextrw $0, %xmm0, (%rsi)
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: shuffle_v16i8_to_v2i8:
; AVX512VL:       # BB#0:
; AVX512VL-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512VL-NEXT:    vpmovqb %xmm0, (%rsi)
; AVX512VL-NEXT:    retq
;
; AVX512BW-LABEL: shuffle_v16i8_to_v2i8:
; AVX512BW:       # BB#0:
; AVX512BW-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512BW-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,8,u,u,u,u,u,u,u,u,u,u,u,u,u,u]
; AVX512BW-NEXT:    vpextrw $0, %xmm0, (%rsi)
; AVX512BW-NEXT:    retq
;
; AVX512BWVL-LABEL: shuffle_v16i8_to_v2i8:
; AVX512BWVL:       # BB#0:
; AVX512BWVL-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512BWVL-NEXT:    vpmovqb %xmm0, (%rsi)
; AVX512BWVL-NEXT:    retq
  %vec = load <16 x i8>, <16 x i8>* %L
  %strided.vec = shufflevector <16 x i8> %vec, <16 x i8> undef, <2 x i32> <i32 0, i32 8>
  store <2 x i8> %strided.vec, <2 x i8>* %S
  ret void
}

define void @trunc_v2i64_to_v2i8(<16 x i8>* %L, <2 x i8>* %S) nounwind {
; SSE2-LABEL: trunc_v2i64_to_v2i8:
; SSE2:       # BB#0:
; SSE2-NEXT:    movdqa (%rdi), %xmm0
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE2-NEXT:    packuswb %xmm0, %xmm0
; SSE2-NEXT:    packuswb %xmm0, %xmm0
; SSE2-NEXT:    packuswb %xmm0, %xmm0
; SSE2-NEXT:    movd %xmm0, %eax
; SSE2-NEXT:    movw %ax, (%rsi)
; SSE2-NEXT:    retq
;
; SSE42-LABEL: trunc_v2i64_to_v2i8:
; SSE42:       # BB#0:
; SSE42-NEXT:    movdqa (%rdi), %xmm0
; SSE42-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,8,u,u,u,u,u,u,u,u,u,u,u,u,u,u]
; SSE42-NEXT:    pextrw $0, %xmm0, (%rsi)
; SSE42-NEXT:    retq
;
; AVX-LABEL: trunc_v2i64_to_v2i8:
; AVX:       # BB#0:
; AVX-NEXT:    vmovdqa (%rdi), %xmm0
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,8,u,u,u,u,u,u,u,u,u,u,u,u,u,u]
; AVX-NEXT:    vpextrw $0, %xmm0, (%rsi)
; AVX-NEXT:    retq
;
; AVX512F-LABEL: trunc_v2i64_to_v2i8:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512F-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,8,u,u,u,u,u,u,u,u,u,u,u,u,u,u]
; AVX512F-NEXT:    vpextrw $0, %xmm0, (%rsi)
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: trunc_v2i64_to_v2i8:
; AVX512VL:       # BB#0:
; AVX512VL-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512VL-NEXT:    vpmovqb %xmm0, (%rsi)
; AVX512VL-NEXT:    retq
;
; AVX512BW-LABEL: trunc_v2i64_to_v2i8:
; AVX512BW:       # BB#0:
; AVX512BW-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512BW-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,8,u,u,u,u,u,u,u,u,u,u,u,u,u,u]
; AVX512BW-NEXT:    vpextrw $0, %xmm0, (%rsi)
; AVX512BW-NEXT:    retq
;
; AVX512BWVL-LABEL: trunc_v2i64_to_v2i8:
; AVX512BWVL:       # BB#0:
; AVX512BWVL-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512BWVL-NEXT:    vpmovqb %xmm0, (%rsi)
; AVX512BWVL-NEXT:    retq
  %vec = load <16 x i8>, <16 x i8>* %L
  %bc = bitcast <16 x i8> %vec to <2 x i64>
  %strided.vec = trunc <2 x i64> %bc to <2 x i8>
  store <2 x i8> %strided.vec, <2 x i8>* %S
  ret void
}
