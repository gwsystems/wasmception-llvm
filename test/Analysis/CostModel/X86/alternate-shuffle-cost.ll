; NOTE: Assertions have been autogenerated by utils/update_analyze_test_checks.py
; RUN: opt < %s -mtriple=x86_64-unknown-linux-gnu -cost-model -analyze -mattr=+sse2 | FileCheck %s -check-prefixes=CHECK,SSE,SSE2
; RUN: opt < %s -mtriple=x86_64-unknown-linux-gnu -cost-model -analyze -mattr=+ssse3 | FileCheck %s -check-prefixes=CHECK,SSE,SSSE3
; RUN: opt < %s -mtriple=x86_64-unknown-linux-gnu -cost-model -analyze -mattr=+sse4.2 | FileCheck %s -check-prefixes=CHECK,SSE,SSE42
; RUN: opt < %s -mtriple=x86_64-unknown-linux-gnu -cost-model -analyze -mattr=+avx | FileCheck %s -check-prefixes=CHECK,AVX,AVX1
; RUN: opt < %s -mtriple=x86_64-unknown-linux-gnu -cost-model -analyze -mattr=+avx2 | FileCheck %s -check-prefixes=CHECK,AVX,AVX2
; RUN: opt < %s -mtriple=x86_64-unknown-linux-gnu -cost-model -analyze -mattr=+xop,+avx | FileCheck %s -check-prefixes=CHECK,AVX,AVX1
; RUN: opt < %s -mtriple=x86_64-unknown-linux-gnu -cost-model -analyze -mattr=+xop,+avx2 | FileCheck %s -check-prefixes=CHECK,AVX,AVX2
;
; RUN: opt < %s -mtriple=x86_64-unknown-linux-gnu -cost-model -analyze -mcpu=slm | FileCheck %s --check-prefixes=CHECK,SSE,SSE42
; RUN: opt < %s -mtriple=x86_64-unknown-linux-gnu -cost-model -analyze -mcpu=goldmont | FileCheck %s --check-prefixes=CHECK,SSE,SSE42
; RUN: opt < %s -mtriple=x86_64-unknown-linux-gnu -cost-model -analyze -mcpu=btver2 | FileCheck %s --check-prefixes=CHECK,AVX,AVX1

; Verify the cost model for alternate shuffles.

; shufflevector instructions with illegal 64-bit vector types.
; 64-bit packed integer vectors (v2i32) are promoted to type v2i64.
; 64-bit packed float vectors (v2f32) are widened to type v4f32.

define <2 x i32> @test_v2i32(<2 x i32> %a, <2 x i32> %b) {
; CHECK-LABEL: 'test_v2i32'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <2 x i32> %a, <2 x i32> %b, <2 x i32> <i32 0, i32 3>
; CHECK-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <2 x i32> %1
;
  %1 = shufflevector <2 x i32> %a, <2 x i32> %b, <2 x i32> <i32 0, i32 3>
  ret <2 x i32> %1
}

define <2 x float> @test_v2f32(<2 x float> %a, <2 x float> %b) {
; SSE2-LABEL: 'test_v2f32'
; SSE2-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %1 = shufflevector <2 x float> %a, <2 x float> %b, <2 x i32> <i32 0, i32 3>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <2 x float> %1
;
; SSSE3-LABEL: 'test_v2f32'
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %1 = shufflevector <2 x float> %a, <2 x float> %b, <2 x i32> <i32 0, i32 3>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <2 x float> %1
;
; SSE42-LABEL: 'test_v2f32'
; SSE42-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <2 x float> %a, <2 x float> %b, <2 x i32> <i32 0, i32 3>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <2 x float> %1
;
; AVX-LABEL: 'test_v2f32'
; AVX-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <2 x float> %a, <2 x float> %b, <2 x i32> <i32 0, i32 3>
; AVX-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <2 x float> %1
;
  %1 = shufflevector <2 x float> %a, <2 x float> %b, <2 x i32> <i32 0, i32 3>
  ret <2 x float> %1
}

define <2 x i32> @test_v2i32_2(<2 x i32> %a, <2 x i32> %b) {
; CHECK-LABEL: 'test_v2i32_2'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <2 x i32> %a, <2 x i32> %b, <2 x i32> <i32 2, i32 1>
; CHECK-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <2 x i32> %1
;
  %1 = shufflevector <2 x i32> %a, <2 x i32> %b, <2 x i32> <i32 2, i32 1>
  ret <2 x i32> %1
}

define <2 x float> @test_v2f32_2(<2 x float> %a, <2 x float> %b) {
; SSE2-LABEL: 'test_v2f32_2'
; SSE2-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %1 = shufflevector <2 x float> %a, <2 x float> %b, <2 x i32> <i32 2, i32 1>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <2 x float> %1
;
; SSSE3-LABEL: 'test_v2f32_2'
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %1 = shufflevector <2 x float> %a, <2 x float> %b, <2 x i32> <i32 2, i32 1>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <2 x float> %1
;
; SSE42-LABEL: 'test_v2f32_2'
; SSE42-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <2 x float> %a, <2 x float> %b, <2 x i32> <i32 2, i32 1>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <2 x float> %1
;
; AVX-LABEL: 'test_v2f32_2'
; AVX-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <2 x float> %a, <2 x float> %b, <2 x i32> <i32 2, i32 1>
; AVX-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <2 x float> %1
;
  %1 = shufflevector <2 x float> %a, <2 x float> %b, <2 x i32> <i32 2, i32 1>
  ret <2 x float> %1
}

; Test shuffles on packed vectors of two elements.

define <2 x i64> @test_v2i64(<2 x i64> %a, <2 x i64> %b) {
; CHECK-LABEL: 'test_v2i64'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <2 x i64> %a, <2 x i64> %b, <2 x i32> <i32 0, i32 3>
; CHECK-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <2 x i64> %1
;
  %1 = shufflevector <2 x i64> %a, <2 x i64> %b, <2 x i32> <i32 0, i32 3>
  ret <2 x i64> %1
}

define <2 x double> @test_v2f64(<2 x double> %a, <2 x double> %b) {
; CHECK-LABEL: 'test_v2f64'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <2 x double> %a, <2 x double> %b, <2 x i32> <i32 0, i32 3>
; CHECK-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <2 x double> %1
;
  %1 = shufflevector <2 x double> %a, <2 x double> %b, <2 x i32> <i32 0, i32 3>
  ret <2 x double> %1
}

define <2 x i64> @test_v2i64_2(<2 x i64> %a, <2 x i64> %b) {
; CHECK-LABEL: 'test_v2i64_2'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <2 x i64> %a, <2 x i64> %b, <2 x i32> <i32 2, i32 1>
; CHECK-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <2 x i64> %1
;
  %1 = shufflevector <2 x i64> %a, <2 x i64> %b, <2 x i32> <i32 2, i32 1>
  ret <2 x i64> %1
}

define <2 x double> @test_v2f64_2(<2 x double> %a, <2 x double> %b) {
; CHECK-LABEL: 'test_v2f64_2'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <2 x double> %a, <2 x double> %b, <2 x i32> <i32 2, i32 1>
; CHECK-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <2 x double> %1
;
  %1 = shufflevector <2 x double> %a, <2 x double> %b, <2 x i32> <i32 2, i32 1>
  ret <2 x double> %1
}

; Test shuffles on packed vectors of four elements.

define <4 x i32> @test_v4i32(<4 x i32> %a, <4 x i32> %b) {
; SSE2-LABEL: 'test_v4i32'
; SSE2-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %1 = shufflevector <4 x i32> %a, <4 x i32> %b, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x i32> %1
;
; SSSE3-LABEL: 'test_v4i32'
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %1 = shufflevector <4 x i32> %a, <4 x i32> %b, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x i32> %1
;
; SSE42-LABEL: 'test_v4i32'
; SSE42-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <4 x i32> %a, <4 x i32> %b, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x i32> %1
;
; AVX-LABEL: 'test_v4i32'
; AVX-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <4 x i32> %a, <4 x i32> %b, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
; AVX-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x i32> %1
;
  %1 = shufflevector <4 x i32> %a, <4 x i32> %b, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
  ret <4 x i32> %1
}

define <4 x i32> @test_v4i32_2(<4 x i32> %a, <4 x i32> %b) {
; SSE2-LABEL: 'test_v4i32_2'
; SSE2-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %1 = shufflevector <4 x i32> %a, <4 x i32> %b, <4 x i32> <i32 4, i32 1, i32 6, i32 3>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x i32> %1
;
; SSSE3-LABEL: 'test_v4i32_2'
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %1 = shufflevector <4 x i32> %a, <4 x i32> %b, <4 x i32> <i32 4, i32 1, i32 6, i32 3>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x i32> %1
;
; SSE42-LABEL: 'test_v4i32_2'
; SSE42-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <4 x i32> %a, <4 x i32> %b, <4 x i32> <i32 4, i32 1, i32 6, i32 3>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x i32> %1
;
; AVX-LABEL: 'test_v4i32_2'
; AVX-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <4 x i32> %a, <4 x i32> %b, <4 x i32> <i32 4, i32 1, i32 6, i32 3>
; AVX-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x i32> %1
;
  %1 = shufflevector <4 x i32> %a, <4 x i32> %b, <4 x i32> <i32 4, i32 1, i32 6, i32 3>
  ret <4 x i32> %1
}

define <4 x float> @test_v4f32(<4 x float> %a, <4 x float> %b) {
; SSE2-LABEL: 'test_v4f32'
; SSE2-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %1 = shufflevector <4 x float> %a, <4 x float> %b, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x float> %1
;
; SSSE3-LABEL: 'test_v4f32'
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %1 = shufflevector <4 x float> %a, <4 x float> %b, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x float> %1
;
; SSE42-LABEL: 'test_v4f32'
; SSE42-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <4 x float> %a, <4 x float> %b, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x float> %1
;
; AVX-LABEL: 'test_v4f32'
; AVX-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <4 x float> %a, <4 x float> %b, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
; AVX-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x float> %1
;
  %1 = shufflevector <4 x float> %a, <4 x float> %b, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
  ret <4 x float> %1
}

define <4 x float> @test_v4f32_2(<4 x float> %a, <4 x float> %b) {
; SSE2-LABEL: 'test_v4f32_2'
; SSE2-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %1 = shufflevector <4 x float> %a, <4 x float> %b, <4 x i32> <i32 4, i32 1, i32 6, i32 3>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x float> %1
;
; SSSE3-LABEL: 'test_v4f32_2'
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %1 = shufflevector <4 x float> %a, <4 x float> %b, <4 x i32> <i32 4, i32 1, i32 6, i32 3>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x float> %1
;
; SSE42-LABEL: 'test_v4f32_2'
; SSE42-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <4 x float> %a, <4 x float> %b, <4 x i32> <i32 4, i32 1, i32 6, i32 3>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x float> %1
;
; AVX-LABEL: 'test_v4f32_2'
; AVX-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <4 x float> %a, <4 x float> %b, <4 x i32> <i32 4, i32 1, i32 6, i32 3>
; AVX-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x float> %1
;
  %1 = shufflevector <4 x float> %a, <4 x float> %b, <4 x i32> <i32 4, i32 1, i32 6, i32 3>
  ret <4 x float> %1
}

define <4 x i64> @test_v4i64(<4 x i64> %a, <4 x i64> %b) {
; SSE-LABEL: 'test_v4i64'
; SSE-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %1 = shufflevector <4 x i64> %a, <4 x i64> %b, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
; SSE-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x i64> %1
;
; AVX-LABEL: 'test_v4i64'
; AVX-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <4 x i64> %a, <4 x i64> %b, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
; AVX-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x i64> %1
;
  %1 = shufflevector <4 x i64> %a, <4 x i64> %b, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
  ret <4 x i64> %1
}

define <4 x i64> @test_v4i64_2(<4 x i64> %a, <4 x i64> %b) {
; SSE-LABEL: 'test_v4i64_2'
; SSE-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %1 = shufflevector <4 x i64> %a, <4 x i64> %b, <4 x i32> <i32 4, i32 1, i32 6, i32 3>
; SSE-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x i64> %1
;
; AVX-LABEL: 'test_v4i64_2'
; AVX-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <4 x i64> %a, <4 x i64> %b, <4 x i32> <i32 4, i32 1, i32 6, i32 3>
; AVX-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x i64> %1
;
  %1 = shufflevector <4 x i64> %a, <4 x i64> %b, <4 x i32> <i32 4, i32 1, i32 6, i32 3>
  ret <4 x i64> %1
}

define <4 x double> @test_v4f64(<4 x double> %a, <4 x double> %b) {
; SSE-LABEL: 'test_v4f64'
; SSE-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %1 = shufflevector <4 x double> %a, <4 x double> %b, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
; SSE-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x double> %1
;
; AVX-LABEL: 'test_v4f64'
; AVX-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <4 x double> %a, <4 x double> %b, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
; AVX-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x double> %1
;
  %1 = shufflevector <4 x double> %a, <4 x double> %b, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
  ret <4 x double> %1
}

define <4 x double> @test_v4f64_2(<4 x double> %a, <4 x double> %b) {
; SSE-LABEL: 'test_v4f64_2'
; SSE-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %1 = shufflevector <4 x double> %a, <4 x double> %b, <4 x i32> <i32 4, i32 1, i32 6, i32 3>
; SSE-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x double> %1
;
; AVX-LABEL: 'test_v4f64_2'
; AVX-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <4 x double> %a, <4 x double> %b, <4 x i32> <i32 4, i32 1, i32 6, i32 3>
; AVX-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x double> %1
;
  %1 = shufflevector <4 x double> %a, <4 x double> %b, <4 x i32> <i32 4, i32 1, i32 6, i32 3>
  ret <4 x double> %1
}

; Test shuffles on packed vectors of eight elements.

define <8 x i16> @test_v8i16(<8 x i16> %a, <8 x i16> %b) {
; SSE2-LABEL: 'test_v8i16'
; SSE2-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %1 = shufflevector <8 x i16> %a, <8 x i16> %b, <8 x i32> <i32 0, i32 9, i32 2, i32 11, i32 4, i32 13, i32 6, i32 15>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i16> %1
;
; SSSE3-LABEL: 'test_v8i16'
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %1 = shufflevector <8 x i16> %a, <8 x i16> %b, <8 x i32> <i32 0, i32 9, i32 2, i32 11, i32 4, i32 13, i32 6, i32 15>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i16> %1
;
; SSE42-LABEL: 'test_v8i16'
; SSE42-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <8 x i16> %a, <8 x i16> %b, <8 x i32> <i32 0, i32 9, i32 2, i32 11, i32 4, i32 13, i32 6, i32 15>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i16> %1
;
; AVX-LABEL: 'test_v8i16'
; AVX-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <8 x i16> %a, <8 x i16> %b, <8 x i32> <i32 0, i32 9, i32 2, i32 11, i32 4, i32 13, i32 6, i32 15>
; AVX-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i16> %1
;
  %1 = shufflevector <8 x i16> %a, <8 x i16> %b, <8 x i32> <i32 0, i32 9, i32 2, i32 11, i32 4, i32 13, i32 6, i32 15>
  ret <8 x i16> %1
}

define <8 x i16> @test_v8i16_2(<8 x i16> %a, <8 x i16> %b) {
; SSE2-LABEL: 'test_v8i16_2'
; SSE2-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %1 = shufflevector <8 x i16> %a, <8 x i16> %b, <8 x i32> <i32 8, i32 1, i32 10, i32 3, i32 12, i32 5, i32 14, i32 7>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i16> %1
;
; SSSE3-LABEL: 'test_v8i16_2'
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %1 = shufflevector <8 x i16> %a, <8 x i16> %b, <8 x i32> <i32 8, i32 1, i32 10, i32 3, i32 12, i32 5, i32 14, i32 7>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i16> %1
;
; SSE42-LABEL: 'test_v8i16_2'
; SSE42-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <8 x i16> %a, <8 x i16> %b, <8 x i32> <i32 8, i32 1, i32 10, i32 3, i32 12, i32 5, i32 14, i32 7>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i16> %1
;
; AVX-LABEL: 'test_v8i16_2'
; AVX-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <8 x i16> %a, <8 x i16> %b, <8 x i32> <i32 8, i32 1, i32 10, i32 3, i32 12, i32 5, i32 14, i32 7>
; AVX-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i16> %1
;
  %1 = shufflevector <8 x i16> %a, <8 x i16> %b, <8 x i32> <i32 8, i32 1, i32 10, i32 3, i32 12, i32 5, i32 14, i32 7>
  ret <8 x i16> %1
}

define <8 x i32> @test_v8i32(<8 x i32> %a, <8 x i32> %b) {
; SSE2-LABEL: 'test_v8i32'
; SSE2-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %1 = shufflevector <8 x i32> %a, <8 x i32> %b, <8 x i32> <i32 0, i32 9, i32 2, i32 11, i32 4, i32 13, i32 6, i32 15>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i32> %1
;
; SSSE3-LABEL: 'test_v8i32'
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %1 = shufflevector <8 x i32> %a, <8 x i32> %b, <8 x i32> <i32 0, i32 9, i32 2, i32 11, i32 4, i32 13, i32 6, i32 15>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i32> %1
;
; SSE42-LABEL: 'test_v8i32'
; SSE42-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %1 = shufflevector <8 x i32> %a, <8 x i32> %b, <8 x i32> <i32 0, i32 9, i32 2, i32 11, i32 4, i32 13, i32 6, i32 15>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i32> %1
;
; AVX-LABEL: 'test_v8i32'
; AVX-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <8 x i32> %a, <8 x i32> %b, <8 x i32> <i32 0, i32 9, i32 2, i32 11, i32 4, i32 13, i32 6, i32 15>
; AVX-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i32> %1
;
  %1 = shufflevector <8 x i32> %a, <8 x i32> %b, <8 x i32> <i32 0, i32 9, i32 2, i32 11, i32 4, i32 13, i32 6, i32 15>
  ret <8 x i32> %1
}

define <8 x i32> @test_v8i32_2(<8 x i32> %a, <8 x i32> %b) {
; SSE2-LABEL: 'test_v8i32_2'
; SSE2-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %1 = shufflevector <8 x i32> %a, <8 x i32> %b, <8 x i32> <i32 8, i32 1, i32 10, i32 3, i32 12, i32 5, i32 14, i32 7>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i32> %1
;
; SSSE3-LABEL: 'test_v8i32_2'
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %1 = shufflevector <8 x i32> %a, <8 x i32> %b, <8 x i32> <i32 8, i32 1, i32 10, i32 3, i32 12, i32 5, i32 14, i32 7>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i32> %1
;
; SSE42-LABEL: 'test_v8i32_2'
; SSE42-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %1 = shufflevector <8 x i32> %a, <8 x i32> %b, <8 x i32> <i32 8, i32 1, i32 10, i32 3, i32 12, i32 5, i32 14, i32 7>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i32> %1
;
; AVX-LABEL: 'test_v8i32_2'
; AVX-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <8 x i32> %a, <8 x i32> %b, <8 x i32> <i32 8, i32 1, i32 10, i32 3, i32 12, i32 5, i32 14, i32 7>
; AVX-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i32> %1
;
  %1 = shufflevector <8 x i32> %a, <8 x i32> %b, <8 x i32> <i32 8, i32 1, i32 10, i32 3, i32 12, i32 5, i32 14, i32 7>
  ret <8 x i32> %1
}

define <8 x float> @test_v8f32(<8 x float> %a, <8 x float> %b) {
; SSE2-LABEL: 'test_v8f32'
; SSE2-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %1 = shufflevector <8 x float> %a, <8 x float> %b, <8 x i32> <i32 0, i32 9, i32 2, i32 11, i32 4, i32 13, i32 6, i32 15>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x float> %1
;
; SSSE3-LABEL: 'test_v8f32'
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %1 = shufflevector <8 x float> %a, <8 x float> %b, <8 x i32> <i32 0, i32 9, i32 2, i32 11, i32 4, i32 13, i32 6, i32 15>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x float> %1
;
; SSE42-LABEL: 'test_v8f32'
; SSE42-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %1 = shufflevector <8 x float> %a, <8 x float> %b, <8 x i32> <i32 0, i32 9, i32 2, i32 11, i32 4, i32 13, i32 6, i32 15>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x float> %1
;
; AVX-LABEL: 'test_v8f32'
; AVX-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <8 x float> %a, <8 x float> %b, <8 x i32> <i32 0, i32 9, i32 2, i32 11, i32 4, i32 13, i32 6, i32 15>
; AVX-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x float> %1
;
  %1 = shufflevector <8 x float> %a, <8 x float> %b, <8 x i32> <i32 0, i32 9, i32 2, i32 11, i32 4, i32 13, i32 6, i32 15>
  ret <8 x float> %1
}

define <8 x float> @test_v8f32_2(<8 x float> %a, <8 x float> %b) {
; SSE2-LABEL: 'test_v8f32_2'
; SSE2-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %1 = shufflevector <8 x float> %a, <8 x float> %b, <8 x i32> <i32 8, i32 1, i32 10, i32 3, i32 12, i32 5, i32 14, i32 7>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x float> %1
;
; SSSE3-LABEL: 'test_v8f32_2'
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %1 = shufflevector <8 x float> %a, <8 x float> %b, <8 x i32> <i32 8, i32 1, i32 10, i32 3, i32 12, i32 5, i32 14, i32 7>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x float> %1
;
; SSE42-LABEL: 'test_v8f32_2'
; SSE42-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %1 = shufflevector <8 x float> %a, <8 x float> %b, <8 x i32> <i32 8, i32 1, i32 10, i32 3, i32 12, i32 5, i32 14, i32 7>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x float> %1
;
; AVX-LABEL: 'test_v8f32_2'
; AVX-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <8 x float> %a, <8 x float> %b, <8 x i32> <i32 8, i32 1, i32 10, i32 3, i32 12, i32 5, i32 14, i32 7>
; AVX-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x float> %1
;
  %1 = shufflevector <8 x float> %a, <8 x float> %b, <8 x i32> <i32 8, i32 1, i32 10, i32 3, i32 12, i32 5, i32 14, i32 7>
  ret <8 x float> %1
}

; Test shuffles on packed vectors of sixteen elements.

define <16 x i8> @test_v16i8(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: 'test_v16i8'
; SSE2-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %1 = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 0, i32 17, i32 2, i32 19, i32 4, i32 21, i32 6, i32 23, i32 8, i32 25, i32 10, i32 27, i32 12, i32 29, i32 14, i32 31>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i8> %1
;
; SSSE3-LABEL: 'test_v16i8'
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %1 = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 0, i32 17, i32 2, i32 19, i32 4, i32 21, i32 6, i32 23, i32 8, i32 25, i32 10, i32 27, i32 12, i32 29, i32 14, i32 31>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i8> %1
;
; SSE42-LABEL: 'test_v16i8'
; SSE42-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 0, i32 17, i32 2, i32 19, i32 4, i32 21, i32 6, i32 23, i32 8, i32 25, i32 10, i32 27, i32 12, i32 29, i32 14, i32 31>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i8> %1
;
; AVX-LABEL: 'test_v16i8'
; AVX-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 0, i32 17, i32 2, i32 19, i32 4, i32 21, i32 6, i32 23, i32 8, i32 25, i32 10, i32 27, i32 12, i32 29, i32 14, i32 31>
; AVX-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i8> %1
;
  %1 = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 0, i32 17, i32 2, i32 19, i32 4, i32 21, i32 6, i32 23, i32 8, i32 25, i32 10, i32 27, i32 12, i32 29, i32 14, i32 31>
  ret <16 x i8> %1
}

define <16 x i8> @test_v16i8_2(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: 'test_v16i8_2'
; SSE2-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %1 = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 16, i32 1, i32 18, i32 3, i32 20, i32 5, i32 22, i32 7, i32 24, i32 9, i32 26, i32 11, i32 28, i32 13, i32 30, i32 15>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i8> %1
;
; SSSE3-LABEL: 'test_v16i8_2'
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %1 = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 16, i32 1, i32 18, i32 3, i32 20, i32 5, i32 22, i32 7, i32 24, i32 9, i32 26, i32 11, i32 28, i32 13, i32 30, i32 15>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i8> %1
;
; SSE42-LABEL: 'test_v16i8_2'
; SSE42-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 16, i32 1, i32 18, i32 3, i32 20, i32 5, i32 22, i32 7, i32 24, i32 9, i32 26, i32 11, i32 28, i32 13, i32 30, i32 15>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i8> %1
;
; AVX-LABEL: 'test_v16i8_2'
; AVX-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 16, i32 1, i32 18, i32 3, i32 20, i32 5, i32 22, i32 7, i32 24, i32 9, i32 26, i32 11, i32 28, i32 13, i32 30, i32 15>
; AVX-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i8> %1
;
  %1 = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 16, i32 1, i32 18, i32 3, i32 20, i32 5, i32 22, i32 7, i32 24, i32 9, i32 26, i32 11, i32 28, i32 13, i32 30, i32 15>
  ret <16 x i8> %1
}

define <16 x i16> @test_v16i16(<16 x i16> %a, <16 x i16> %b) {
; SSE2-LABEL: 'test_v16i16'
; SSE2-NEXT:  Cost Model: Found an estimated cost of 6 for instruction: %1 = shufflevector <16 x i16> %a, <16 x i16> %b, <16 x i32> <i32 0, i32 17, i32 2, i32 19, i32 4, i32 21, i32 6, i32 23, i32 8, i32 25, i32 10, i32 27, i32 12, i32 29, i32 14, i32 31>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i16> %1
;
; SSSE3-LABEL: 'test_v16i16'
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 6 for instruction: %1 = shufflevector <16 x i16> %a, <16 x i16> %b, <16 x i32> <i32 0, i32 17, i32 2, i32 19, i32 4, i32 21, i32 6, i32 23, i32 8, i32 25, i32 10, i32 27, i32 12, i32 29, i32 14, i32 31>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i16> %1
;
; SSE42-LABEL: 'test_v16i16'
; SSE42-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %1 = shufflevector <16 x i16> %a, <16 x i16> %b, <16 x i32> <i32 0, i32 17, i32 2, i32 19, i32 4, i32 21, i32 6, i32 23, i32 8, i32 25, i32 10, i32 27, i32 12, i32 29, i32 14, i32 31>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i16> %1
;
; AVX1-LABEL: 'test_v16i16'
; AVX1-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %1 = shufflevector <16 x i16> %a, <16 x i16> %b, <16 x i32> <i32 0, i32 17, i32 2, i32 19, i32 4, i32 21, i32 6, i32 23, i32 8, i32 25, i32 10, i32 27, i32 12, i32 29, i32 14, i32 31>
; AVX1-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i16> %1
;
; AVX2-LABEL: 'test_v16i16'
; AVX2-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <16 x i16> %a, <16 x i16> %b, <16 x i32> <i32 0, i32 17, i32 2, i32 19, i32 4, i32 21, i32 6, i32 23, i32 8, i32 25, i32 10, i32 27, i32 12, i32 29, i32 14, i32 31>
; AVX2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i16> %1
;
  %1 = shufflevector <16 x i16> %a, <16 x i16> %b, <16 x i32> <i32 0, i32 17, i32 2, i32 19, i32 4, i32 21, i32 6, i32 23, i32 8, i32 25, i32 10, i32 27, i32 12, i32 29, i32 14, i32 31>
  ret <16 x i16> %1
}

define <16 x i16> @test_v16i16_2(<16 x i16> %a, <16 x i16> %b) {
; SSE2-LABEL: 'test_v16i16_2'
; SSE2-NEXT:  Cost Model: Found an estimated cost of 6 for instruction: %1 = shufflevector <16 x i16> %a, <16 x i16> %b, <16 x i32> <i32 16, i32 1, i32 18, i32 3, i32 20, i32 5, i32 22, i32 7, i32 24, i32 9, i32 26, i32 11, i32 28, i32 13, i32 30, i32 15>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i16> %1
;
; SSSE3-LABEL: 'test_v16i16_2'
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 6 for instruction: %1 = shufflevector <16 x i16> %a, <16 x i16> %b, <16 x i32> <i32 16, i32 1, i32 18, i32 3, i32 20, i32 5, i32 22, i32 7, i32 24, i32 9, i32 26, i32 11, i32 28, i32 13, i32 30, i32 15>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i16> %1
;
; SSE42-LABEL: 'test_v16i16_2'
; SSE42-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %1 = shufflevector <16 x i16> %a, <16 x i16> %b, <16 x i32> <i32 16, i32 1, i32 18, i32 3, i32 20, i32 5, i32 22, i32 7, i32 24, i32 9, i32 26, i32 11, i32 28, i32 13, i32 30, i32 15>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i16> %1
;
; AVX1-LABEL: 'test_v16i16_2'
; AVX1-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %1 = shufflevector <16 x i16> %a, <16 x i16> %b, <16 x i32> <i32 16, i32 1, i32 18, i32 3, i32 20, i32 5, i32 22, i32 7, i32 24, i32 9, i32 26, i32 11, i32 28, i32 13, i32 30, i32 15>
; AVX1-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i16> %1
;
; AVX2-LABEL: 'test_v16i16_2'
; AVX2-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <16 x i16> %a, <16 x i16> %b, <16 x i32> <i32 16, i32 1, i32 18, i32 3, i32 20, i32 5, i32 22, i32 7, i32 24, i32 9, i32 26, i32 11, i32 28, i32 13, i32 30, i32 15>
; AVX2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i16> %1
;
  %1 = shufflevector <16 x i16> %a, <16 x i16> %b, <16 x i32> <i32 16, i32 1, i32 18, i32 3, i32 20, i32 5, i32 22, i32 7, i32 24, i32 9, i32 26, i32 11, i32 28, i32 13, i32 30, i32 15>
  ret <16 x i16> %1
}

define <32 x i8> @test_v32i8(<32 x i8> %a, <32 x i8> %b) {
; SSE2-LABEL: 'test_v32i8'
; SSE2-NEXT:  Cost Model: Found an estimated cost of 6 for instruction: %1 = shufflevector <32 x i8> %a, <32 x i8> %b, <32 x i32> <i32 0, i32 33, i32 2, i32 35, i32 4, i32 37, i32 6, i32 39, i32 8, i32 41, i32 10, i32 43, i32 12, i32 45, i32 14, i32 47, i32 16, i32 49, i32 18, i32 51, i32 20, i32 53, i32 22, i32 55, i32 24, i32 57, i32 26, i32 59, i32 28, i32 61, i32 30, i32 63>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <32 x i8> %1
;
; SSSE3-LABEL: 'test_v32i8'
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 6 for instruction: %1 = shufflevector <32 x i8> %a, <32 x i8> %b, <32 x i32> <i32 0, i32 33, i32 2, i32 35, i32 4, i32 37, i32 6, i32 39, i32 8, i32 41, i32 10, i32 43, i32 12, i32 45, i32 14, i32 47, i32 16, i32 49, i32 18, i32 51, i32 20, i32 53, i32 22, i32 55, i32 24, i32 57, i32 26, i32 59, i32 28, i32 61, i32 30, i32 63>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <32 x i8> %1
;
; SSE42-LABEL: 'test_v32i8'
; SSE42-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %1 = shufflevector <32 x i8> %a, <32 x i8> %b, <32 x i32> <i32 0, i32 33, i32 2, i32 35, i32 4, i32 37, i32 6, i32 39, i32 8, i32 41, i32 10, i32 43, i32 12, i32 45, i32 14, i32 47, i32 16, i32 49, i32 18, i32 51, i32 20, i32 53, i32 22, i32 55, i32 24, i32 57, i32 26, i32 59, i32 28, i32 61, i32 30, i32 63>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <32 x i8> %1
;
; AVX1-LABEL: 'test_v32i8'
; AVX1-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %1 = shufflevector <32 x i8> %a, <32 x i8> %b, <32 x i32> <i32 0, i32 33, i32 2, i32 35, i32 4, i32 37, i32 6, i32 39, i32 8, i32 41, i32 10, i32 43, i32 12, i32 45, i32 14, i32 47, i32 16, i32 49, i32 18, i32 51, i32 20, i32 53, i32 22, i32 55, i32 24, i32 57, i32 26, i32 59, i32 28, i32 61, i32 30, i32 63>
; AVX1-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <32 x i8> %1
;
; AVX2-LABEL: 'test_v32i8'
; AVX2-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <32 x i8> %a, <32 x i8> %b, <32 x i32> <i32 0, i32 33, i32 2, i32 35, i32 4, i32 37, i32 6, i32 39, i32 8, i32 41, i32 10, i32 43, i32 12, i32 45, i32 14, i32 47, i32 16, i32 49, i32 18, i32 51, i32 20, i32 53, i32 22, i32 55, i32 24, i32 57, i32 26, i32 59, i32 28, i32 61, i32 30, i32 63>
; AVX2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <32 x i8> %1
;
  %1 = shufflevector <32 x i8> %a, <32 x i8> %b, <32 x i32> <i32 0, i32 33, i32 2, i32 35, i32 4, i32 37, i32 6, i32 39, i32 8, i32 41, i32 10, i32 43, i32 12, i32 45, i32 14, i32 47, i32 16, i32 49, i32 18, i32 51, i32 20, i32 53, i32 22, i32 55, i32 24, i32 57, i32 26, i32 59, i32 28, i32 61, i32 30, i32 63>
  ret <32 x i8> %1
}

define <32 x i8> @test_v32i8_2(<32 x i8> %a, <32 x i8> %b) {
; SSE2-LABEL: 'test_v32i8_2'
; SSE2-NEXT:  Cost Model: Found an estimated cost of 6 for instruction: %1 = shufflevector <32 x i8> %a, <32 x i8> %b, <32 x i32> <i32 32, i32 1, i32 34, i32 3, i32 36, i32 5, i32 38, i32 7, i32 40, i32 9, i32 42, i32 11, i32 44, i32 13, i32 46, i32 15, i32 48, i32 17, i32 50, i32 19, i32 52, i32 21, i32 54, i32 23, i32 56, i32 25, i32 58, i32 27, i32 60, i32 29, i32 62, i32 31>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <32 x i8> %1
;
; SSSE3-LABEL: 'test_v32i8_2'
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 6 for instruction: %1 = shufflevector <32 x i8> %a, <32 x i8> %b, <32 x i32> <i32 32, i32 1, i32 34, i32 3, i32 36, i32 5, i32 38, i32 7, i32 40, i32 9, i32 42, i32 11, i32 44, i32 13, i32 46, i32 15, i32 48, i32 17, i32 50, i32 19, i32 52, i32 21, i32 54, i32 23, i32 56, i32 25, i32 58, i32 27, i32 60, i32 29, i32 62, i32 31>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <32 x i8> %1
;
; SSE42-LABEL: 'test_v32i8_2'
; SSE42-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %1 = shufflevector <32 x i8> %a, <32 x i8> %b, <32 x i32> <i32 32, i32 1, i32 34, i32 3, i32 36, i32 5, i32 38, i32 7, i32 40, i32 9, i32 42, i32 11, i32 44, i32 13, i32 46, i32 15, i32 48, i32 17, i32 50, i32 19, i32 52, i32 21, i32 54, i32 23, i32 56, i32 25, i32 58, i32 27, i32 60, i32 29, i32 62, i32 31>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <32 x i8> %1
;
; AVX1-LABEL: 'test_v32i8_2'
; AVX1-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %1 = shufflevector <32 x i8> %a, <32 x i8> %b, <32 x i32> <i32 32, i32 1, i32 34, i32 3, i32 36, i32 5, i32 38, i32 7, i32 40, i32 9, i32 42, i32 11, i32 44, i32 13, i32 46, i32 15, i32 48, i32 17, i32 50, i32 19, i32 52, i32 21, i32 54, i32 23, i32 56, i32 25, i32 58, i32 27, i32 60, i32 29, i32 62, i32 31>
; AVX1-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <32 x i8> %1
;
; AVX2-LABEL: 'test_v32i8_2'
; AVX2-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = shufflevector <32 x i8> %a, <32 x i8> %b, <32 x i32> <i32 32, i32 1, i32 34, i32 3, i32 36, i32 5, i32 38, i32 7, i32 40, i32 9, i32 42, i32 11, i32 44, i32 13, i32 46, i32 15, i32 48, i32 17, i32 50, i32 19, i32 52, i32 21, i32 54, i32 23, i32 56, i32 25, i32 58, i32 27, i32 60, i32 29, i32 62, i32 31>
; AVX2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <32 x i8> %1
;
  %1 = shufflevector <32 x i8> %a, <32 x i8> %b, <32 x i32> <i32 32, i32 1, i32 34, i32 3, i32 36, i32 5, i32 38, i32 7, i32 40, i32 9, i32 42, i32 11, i32 44, i32 13, i32 46, i32 15, i32 48, i32 17, i32 50, i32 19, i32 52, i32 21, i32 54, i32 23, i32 56, i32 25, i32 58, i32 27, i32 60, i32 29, i32 62, i32 31>
  ret <32 x i8> %1
}
