; NOTE: Assertions have been autogenerated by utils/update_analyze_test_checks.py
; RUN: opt < %s  -cost-model -analyze -mtriple=x86_64-apple-macosx10.8.0 -mattr=+sse2 | FileCheck %s --check-prefixes=CHECK,SSE,SSE2
; RUN: opt < %s  -cost-model -analyze -mtriple=x86_64-apple-macosx10.8.0 -mattr=+ssse3 | FileCheck %s --check-prefixes=CHECK,SSE,SSSE3
; RUN: opt < %s  -cost-model -analyze -mtriple=x86_64-apple-macosx10.8.0 -mattr=+sse4.2 | FileCheck %s --check-prefixes=CHECK,SSE,SSE42
; RUN: opt < %s  -cost-model -analyze -mtriple=x86_64-apple-macosx10.8.0 -mattr=+avx | FileCheck %s --check-prefixes=CHECK,AVX,AVX1
; RUN: opt < %s  -cost-model -analyze -mtriple=x86_64-apple-macosx10.8.0 -mattr=+avx2 | FileCheck %s --check-prefixes=CHECK,AVX,AVX2
; RUN: opt < %s  -cost-model -analyze -mtriple=x86_64-apple-macosx10.8.0 -mattr=+avx512f | FileCheck %s --check-prefixes=CHECK,AVX512,AVX512F
; RUN: opt < %s  -cost-model -analyze -mtriple=x86_64-apple-macosx10.8.0 -mattr=+avx512f,+avx512bw | FileCheck %s --check-prefixes=CHECK,AVX512,AVX512BW

define i32 @trunc_vXi32() {
; SSE-LABEL: 'trunc_vXi32'
; SSE-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V2i64 = trunc <2 x i64> undef to <2 x i32>
; SSE-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V4i64 = trunc <4 x i64> undef to <4 x i32>
; SSE-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %V8i64 = trunc <8 x i64> undef to <8 x i32>
; SSE-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret i32 undef
;
; AVX1-LABEL: 'trunc_vXi32'
; AVX1-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V2i64 = trunc <2 x i64> undef to <2 x i32>
; AVX1-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %V4i64 = trunc <4 x i64> undef to <4 x i32>
; AVX1-NEXT:  Cost Model: Found an estimated cost of 9 for instruction: %V8i64 = trunc <8 x i64> undef to <8 x i32>
; AVX1-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret i32 undef
;
; AVX2-LABEL: 'trunc_vXi32'
; AVX2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V2i64 = trunc <2 x i64> undef to <2 x i32>
; AVX2-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %V4i64 = trunc <4 x i64> undef to <4 x i32>
; AVX2-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %V8i64 = trunc <8 x i64> undef to <8 x i32>
; AVX2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret i32 undef
;
; AVX512-LABEL: 'trunc_vXi32'
; AVX512-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V2i64 = trunc <2 x i64> undef to <2 x i32>
; AVX512-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %V4i64 = trunc <4 x i64> undef to <4 x i32>
; AVX512-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V8i64 = trunc <8 x i64> undef to <8 x i32>
; AVX512-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret i32 undef
;
  %V2i64 = trunc <2 x i64> undef to <2 x i32>
  %V4i64 = trunc <4 x i64> undef to <4 x i32>
  %V8i64 = trunc <8 x i64> undef to <8 x i32>
  ret i32 undef
}

define i32 @trunc_vXi16() {
; SSE2-LABEL: 'trunc_vXi16'
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V2i64 = trunc <2 x i64> undef to <2 x i16>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V4i64 = trunc <4 x i64> undef to <4 x i16>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %V8i64 = trunc <8 x i64> undef to <8 x i16>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %V4i32 = trunc <4 x i32> undef to <4 x i16>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 5 for instruction: %V8i32 = trunc <8 x i32> undef to <8 x i16>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 10 for instruction: %V16i32 = trunc <16 x i32> undef to <16 x i16>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret i32 undef
;
; SSSE3-LABEL: 'trunc_vXi16'
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V2i64 = trunc <2 x i64> undef to <2 x i16>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V4i64 = trunc <4 x i64> undef to <4 x i16>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %V8i64 = trunc <8 x i64> undef to <8 x i16>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %V4i32 = trunc <4 x i32> undef to <4 x i16>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 5 for instruction: %V8i32 = trunc <8 x i32> undef to <8 x i16>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 10 for instruction: %V16i32 = trunc <16 x i32> undef to <16 x i16>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret i32 undef
;
; SSE42-LABEL: 'trunc_vXi16'
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V2i64 = trunc <2 x i64> undef to <2 x i16>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V4i64 = trunc <4 x i64> undef to <4 x i16>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %V8i64 = trunc <8 x i64> undef to <8 x i16>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V4i32 = trunc <4 x i32> undef to <4 x i16>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %V8i32 = trunc <8 x i32> undef to <8 x i16>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 6 for instruction: %V16i32 = trunc <16 x i32> undef to <16 x i16>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret i32 undef
;
; AVX1-LABEL: 'trunc_vXi16'
; AVX1-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V2i64 = trunc <2 x i64> undef to <2 x i16>
; AVX1-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %V4i64 = trunc <4 x i64> undef to <4 x i16>
; AVX1-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V8i64 = trunc <8 x i64> undef to <8 x i16>
; AVX1-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V4i32 = trunc <4 x i32> undef to <4 x i16>
; AVX1-NEXT:  Cost Model: Found an estimated cost of 5 for instruction: %V8i32 = trunc <8 x i32> undef to <8 x i16>
; AVX1-NEXT:  Cost Model: Found an estimated cost of 6 for instruction: %V16i32 = trunc <16 x i32> undef to <16 x i16>
; AVX1-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret i32 undef
;
; AVX2-LABEL: 'trunc_vXi16'
; AVX2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V2i64 = trunc <2 x i64> undef to <2 x i16>
; AVX2-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %V4i64 = trunc <4 x i64> undef to <4 x i16>
; AVX2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V8i64 = trunc <8 x i64> undef to <8 x i16>
; AVX2-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V4i32 = trunc <4 x i32> undef to <4 x i16>
; AVX2-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %V8i32 = trunc <8 x i32> undef to <8 x i16>
; AVX2-NEXT:  Cost Model: Found an estimated cost of 6 for instruction: %V16i32 = trunc <16 x i32> undef to <16 x i16>
; AVX2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret i32 undef
;
; AVX512-LABEL: 'trunc_vXi16'
; AVX512-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V2i64 = trunc <2 x i64> undef to <2 x i16>
; AVX512-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %V4i64 = trunc <4 x i64> undef to <4 x i16>
; AVX512-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V8i64 = trunc <8 x i64> undef to <8 x i16>
; AVX512-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V4i32 = trunc <4 x i32> undef to <4 x i16>
; AVX512-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %V8i32 = trunc <8 x i32> undef to <8 x i16>
; AVX512-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V16i32 = trunc <16 x i32> undef to <16 x i16>
; AVX512-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret i32 undef
;
  %V2i64 = trunc <2 x i64> undef to <2 x i16>
  %V4i64 = trunc <4 x i64> undef to <4 x i16>
  %V8i64 = trunc <8 x i64> undef to <8 x i16>
  %V4i32 = trunc <4 x i32> undef to <4 x i16>
  %V8i32 = trunc <8 x i32> undef to <8 x i16>
  %V16i32 = trunc <16 x i32> undef to <16 x i16>
  ret i32 undef
}

define i32 @trunc_vXi8() {
; SSE2-LABEL: 'trunc_vXi8'
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V2i64 = trunc <2 x i64> undef to <2 x i8>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V4i64 = trunc <4 x i64> undef to <4 x i8>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %V8i64 = trunc <8 x i64> undef to <8 x i8>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V2i32 = trunc <2 x i32> undef to <2 x i8>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %V4i32 = trunc <4 x i32> undef to <4 x i8>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %V8i32 = trunc <8 x i32> undef to <8 x i8>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 7 for instruction: %V16i32 = trunc <16 x i32> undef to <16 x i8>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V2i16 = trunc <2 x i16> undef to <2 x i8>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %V4i16 = trunc <4 x i16> undef to <4 x i8>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %V8i16 = trunc <8 x i16> undef to <8 x i8>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %V16i16 = trunc <16 x i16> undef to <16 x i8>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 7 for instruction: %V32i16 = trunc <32 x i16> undef to <32 x i8>
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret i32 undef
;
; SSSE3-LABEL: 'trunc_vXi8'
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V2i64 = trunc <2 x i64> undef to <2 x i8>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V4i64 = trunc <4 x i64> undef to <4 x i8>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %V8i64 = trunc <8 x i64> undef to <8 x i8>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V2i32 = trunc <2 x i32> undef to <2 x i8>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %V4i32 = trunc <4 x i32> undef to <4 x i8>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %V8i32 = trunc <8 x i32> undef to <8 x i8>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 7 for instruction: %V16i32 = trunc <16 x i32> undef to <16 x i8>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V2i16 = trunc <2 x i16> undef to <2 x i8>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %V4i16 = trunc <4 x i16> undef to <4 x i8>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %V8i16 = trunc <8 x i16> undef to <8 x i8>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %V16i16 = trunc <16 x i16> undef to <16 x i8>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 7 for instruction: %V32i16 = trunc <32 x i16> undef to <32 x i8>
; SSSE3-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret i32 undef
;
; SSE42-LABEL: 'trunc_vXi8'
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V2i64 = trunc <2 x i64> undef to <2 x i8>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V4i64 = trunc <4 x i64> undef to <4 x i8>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %V8i64 = trunc <8 x i64> undef to <8 x i8>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V2i32 = trunc <2 x i32> undef to <2 x i8>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V4i32 = trunc <4 x i32> undef to <4 x i8>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %V8i32 = trunc <8 x i32> undef to <8 x i8>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 7 for instruction: %V16i32 = trunc <16 x i32> undef to <16 x i8>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V2i16 = trunc <2 x i16> undef to <2 x i8>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %V4i16 = trunc <4 x i16> undef to <4 x i8>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V8i16 = trunc <8 x i16> undef to <8 x i8>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %V16i16 = trunc <16 x i16> undef to <16 x i8>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 7 for instruction: %V32i16 = trunc <32 x i16> undef to <32 x i8>
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret i32 undef
;
; AVX1-LABEL: 'trunc_vXi8'
; AVX1-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V2i64 = trunc <2 x i64> undef to <2 x i8>
; AVX1-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %V4i64 = trunc <4 x i64> undef to <4 x i8>
; AVX1-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V8i64 = trunc <8 x i64> undef to <8 x i8>
; AVX1-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V2i32 = trunc <2 x i32> undef to <2 x i8>
; AVX1-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V4i32 = trunc <4 x i32> undef to <4 x i8>
; AVX1-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %V8i32 = trunc <8 x i32> undef to <8 x i8>
; AVX1-NEXT:  Cost Model: Found an estimated cost of 7 for instruction: %V16i32 = trunc <16 x i32> undef to <16 x i8>
; AVX1-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V2i16 = trunc <2 x i16> undef to <2 x i8>
; AVX1-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %V4i16 = trunc <4 x i16> undef to <4 x i8>
; AVX1-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V8i16 = trunc <8 x i16> undef to <8 x i8>
; AVX1-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %V16i16 = trunc <16 x i16> undef to <16 x i8>
; AVX1-NEXT:  Cost Model: Found an estimated cost of 9 for instruction: %V32i16 = trunc <32 x i16> undef to <32 x i8>
; AVX1-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret i32 undef
;
; AVX2-LABEL: 'trunc_vXi8'
; AVX2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V2i64 = trunc <2 x i64> undef to <2 x i8>
; AVX2-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %V4i64 = trunc <4 x i64> undef to <4 x i8>
; AVX2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V8i64 = trunc <8 x i64> undef to <8 x i8>
; AVX2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V2i32 = trunc <2 x i32> undef to <2 x i8>
; AVX2-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V4i32 = trunc <4 x i32> undef to <4 x i8>
; AVX2-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %V8i32 = trunc <8 x i32> undef to <8 x i8>
; AVX2-NEXT:  Cost Model: Found an estimated cost of 7 for instruction: %V16i32 = trunc <16 x i32> undef to <16 x i8>
; AVX2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V2i16 = trunc <2 x i16> undef to <2 x i8>
; AVX2-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %V4i16 = trunc <4 x i16> undef to <4 x i8>
; AVX2-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V8i16 = trunc <8 x i16> undef to <8 x i8>
; AVX2-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %V16i16 = trunc <16 x i16> undef to <16 x i8>
; AVX2-NEXT:  Cost Model: Found an estimated cost of 9 for instruction: %V32i16 = trunc <32 x i16> undef to <32 x i8>
; AVX2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret i32 undef
;
; AVX512F-LABEL: 'trunc_vXi8'
; AVX512F-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V2i64 = trunc <2 x i64> undef to <2 x i8>
; AVX512F-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %V4i64 = trunc <4 x i64> undef to <4 x i8>
; AVX512F-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V8i64 = trunc <8 x i64> undef to <8 x i8>
; AVX512F-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V2i32 = trunc <2 x i32> undef to <2 x i8>
; AVX512F-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V4i32 = trunc <4 x i32> undef to <4 x i8>
; AVX512F-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %V8i32 = trunc <8 x i32> undef to <8 x i8>
; AVX512F-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V16i32 = trunc <16 x i32> undef to <16 x i8>
; AVX512F-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V2i16 = trunc <2 x i16> undef to <2 x i8>
; AVX512F-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %V4i16 = trunc <4 x i16> undef to <4 x i8>
; AVX512F-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V8i16 = trunc <8 x i16> undef to <8 x i8>
; AVX512F-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %V16i16 = trunc <16 x i16> undef to <16 x i8>
; AVX512F-NEXT:  Cost Model: Found an estimated cost of 9 for instruction: %V32i16 = trunc <32 x i16> undef to <32 x i8>
; AVX512F-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret i32 undef
;
; AVX512BW-LABEL: 'trunc_vXi8'
; AVX512BW-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V2i64 = trunc <2 x i64> undef to <2 x i8>
; AVX512BW-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %V4i64 = trunc <4 x i64> undef to <4 x i8>
; AVX512BW-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V8i64 = trunc <8 x i64> undef to <8 x i8>
; AVX512BW-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V2i32 = trunc <2 x i32> undef to <2 x i8>
; AVX512BW-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V4i32 = trunc <4 x i32> undef to <4 x i8>
; AVX512BW-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %V8i32 = trunc <8 x i32> undef to <8 x i8>
; AVX512BW-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V16i32 = trunc <16 x i32> undef to <16 x i8>
; AVX512BW-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V2i16 = trunc <2 x i16> undef to <2 x i8>
; AVX512BW-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %V4i16 = trunc <4 x i16> undef to <4 x i8>
; AVX512BW-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V8i16 = trunc <8 x i16> undef to <8 x i8>
; AVX512BW-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %V16i16 = trunc <16 x i16> undef to <16 x i8>
; AVX512BW-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %V32i16 = trunc <32 x i16> undef to <32 x i8>
; AVX512BW-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret i32 undef
;
  %V2i64 = trunc <2 x i64> undef to <2 x i8>
  %V4i64 = trunc <4 x i64> undef to <4 x i8>
  %V8i64 = trunc <8 x i64> undef to <8 x i8>

  %V2i32 = trunc <2 x i32> undef to <2 x i8>
  %V4i32 = trunc <4 x i32> undef to <4 x i8>
  %V8i32 = trunc <8 x i32> undef to <8 x i8>
  %V16i32 = trunc <16 x i32> undef to <16 x i8>

  %V2i16 = trunc <2 x i16> undef to <2 x i8>
  %V4i16 = trunc <4 x i16> undef to <4 x i8>
  %V8i16 = trunc <8 x i16> undef to <8 x i8>
  %V16i16 = trunc <16 x i16> undef to <16 x i8>
  %V32i16 = trunc <32 x i16> undef to <32 x i8>

  ret i32 undef
}
