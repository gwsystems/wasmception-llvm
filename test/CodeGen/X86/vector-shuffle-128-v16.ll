; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=x86-64 | FileCheck %s --check-prefix=ALL --check-prefix=SSE --check-prefix=SSE2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=x86-64 -mattr=+ssse3 | FileCheck %s --check-prefix=ALL --check-prefix=SSE --check-prefix=SSSE3
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=x86-64 -mattr=+sse4.1 | FileCheck %s --check-prefix=ALL --check-prefix=SSE --check-prefix=SSE41
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=x86-64 -mattr=+avx | FileCheck %s --check-prefix=ALL --check-prefix=AVX --check-prefix=AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=x86-64 -mattr=+avx2 | FileCheck %s --check-prefix=ALL --check-prefix=AVX --check-prefix=AVX2

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-unknown"

define <16 x i8> @shuffle_v16i8_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00(<16 x i8> %a, <16 x i8> %b) {
; FIXME: SSE2 should look like the following:
; FIXME-LABEL: @shuffle_v16i8_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00
; FIXME:       # BB#0:
; FIXME-NEXT:    punpcklbw %xmm0, %xmm0
; FIXME-NEXT:    pshuflw {{.*}} # xmm0 = xmm0[0,0,0,0,4,5,6,7]
; FIXME-NEXT:    pshufd {{.*}} # xmm0 = xmm0[0,1,0,1]
; FIXME-NEXT:    retq
;
; SSE2-LABEL: shuffle_v16i8_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00:
; SSE2:       # BB#0:
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,1,0,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,0,0,0,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,4,4,4,4]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pxor %xmm1, %xmm1
; SSSE3-NEXT:    pshufb %xmm1, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00:
; SSE41:       # BB#0:
; SSE41-NEXT:    pxor %xmm1, %xmm1
; SSE41-NEXT:    pshufb %xmm1, %xmm0
; SSE41-NEXT:    retq
;
; AVX1-LABEL: shuffle_v16i8_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX1-NEXT:    vpshufb %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: shuffle_v16i8_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpbroadcastb %xmm0, %xmm0
; AVX2-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_00_00_00_00_00_00_00_00_01_01_01_01_01_01_01_01(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: shuffle_v16i8_00_00_00_00_00_00_00_00_01_01_01_01_01_01_01_01:
; SSE2:       # BB#0:
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,1,0,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,0,0,0,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,5,5,5,5]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_00_00_00_00_00_00_00_00_01_01_01_01_01_01_01_01:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_00_00_00_00_00_00_00_00_01_01_01_01_01_01_01_01:
; SSE41:       # BB#0:
; SSE41-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1]
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_00_00_00_00_00_00_00_00_01_01_01_01_01_01_01_01:
; AVX:       # BB#0:
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_00_00_00_00_00_00_00_00_08_08_08_08_08_08_08_08(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: shuffle_v16i8_00_00_00_00_00_00_00_00_08_08_08_08_08_08_08_08:
; SSE2:       # BB#0:
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,2,2,2,4,5,6,7]
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,0,0,0,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,6,6,6,6]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_00_00_00_00_00_00_00_00_08_08_08_08_08_08_08_08:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,0,0,0,0,0,0,0,8,8,8,8,8,8,8,8]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_00_00_00_00_00_00_00_00_08_08_08_08_08_08_08_08:
; SSE41:       # BB#0:
; SSE41-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,0,0,0,0,0,0,0,8,8,8,8,8,8,8,8]
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_00_00_00_00_00_00_00_00_08_08_08_08_08_08_08_08:
; AVX:       # BB#0:
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,0,0,0,0,0,0,0,8,8,8,8,8,8,8,8]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_00_00_00_00_01_01_01_01_02_02_02_02_03_03_03_03(<16 x i8> %a, <16 x i8> %b) {
; SSE-LABEL: shuffle_v16i8_00_00_00_00_01_01_01_01_02_02_02_02_03_03_03_03:
; SSE:       # BB#0:
; SSE-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3]
; SSE-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_00_00_00_00_01_01_01_01_02_02_02_02_03_03_03_03:
; AVX:       # BB#0:
; AVX-NEXT:    vpunpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; AVX-NEXT:    vpunpcklwd {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 0, i32 0, i32 0, i32 0, i32 1, i32 1, i32 1, i32 1, i32 2, i32 2, i32 2, i32 2, i32 3, i32 3, i32 3, i32 3>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_04_04_04_04_05_05_05_05_06_06_06_06_07_07_07_07(<16 x i8> %a, <16 x i8> %b) {
; SSE-LABEL: shuffle_v16i8_04_04_04_04_05_05_05_05_06_06_06_06_07_07_07_07:
; SSE:       # BB#0:
; SSE-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE-NEXT:    punpckhwd {{.*#+}} xmm0 = xmm0[4,4,5,5,6,6,7,7]
; SSE-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_04_04_04_04_05_05_05_05_06_06_06_06_07_07_07_07:
; AVX:       # BB#0:
; AVX-NEXT:    vpunpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; AVX-NEXT:    vpunpckhwd {{.*#+}} xmm0 = xmm0[4,4,5,5,6,6,7,7]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 4, i32 4, i32 4, i32 4, i32 5, i32 5, i32 5, i32 5, i32 6, i32 6, i32 6, i32 6, i32 7, i32 7, i32 7, i32 7>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_00_00_00_00_04_04_04_04_08_08_08_08_12_12_12_12(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: shuffle_v16i8_00_00_00_00_04_04_04_04_08_08_08_08_12_12_12_12:
; SSE2:       # BB#0:
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,2,2,3,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,4,6,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,0,2,2,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,4,4,6,6]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_00_00_00_00_04_04_04_04_08_08_08_08_12_12_12_12:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,0,0,0,4,4,4,4,8,8,8,8,12,12,12,12]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_00_00_00_00_04_04_04_04_08_08_08_08_12_12_12_12:
; SSE41:       # BB#0:
; SSE41-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,0,0,0,4,4,4,4,8,8,8,8,12,12,12,12]
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_00_00_00_00_04_04_04_04_08_08_08_08_12_12_12_12:
; AVX:       # BB#0:
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,0,0,0,4,4,4,4,8,8,8,8,12,12,12,12]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 0, i32 0, i32 0, i32 0, i32 4, i32 4, i32 4, i32 4, i32 8, i32 8, i32 8, i32 8, i32 12, i32 12, i32 12, i32 12>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_00_00_01_01_02_02_03_03_04_04_05_05_06_06_07_07(<16 x i8> %a, <16 x i8> %b) {
; SSE-LABEL: shuffle_v16i8_00_00_01_01_02_02_03_03_04_04_05_05_06_06_07_07:
; SSE:       # BB#0:
; SSE-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_00_00_01_01_02_02_03_03_04_04_05_05_06_06_07_07:
; AVX:       # BB#0:
; AVX-NEXT:    vpunpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 0, i32 0, i32 1, i32 1, i32 2, i32 2, i32 3, i32 3, i32 4, i32 4, i32 5, i32 5, i32 6, i32 6, i32 7, i32 7>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_0101010101010101(<16 x i8> %a, <16 x i8> %b) {
; FIXME: SSE2 should be the following:
; FIXME-LABEL: @shuffle_v16i8_0101010101010101
; FIXME:       # BB#0:
; FIXME-NEXT:    pshuflw {{.*}} # xmm0 = xmm0[0,0,0,0,4,5,6,7]
; FIXME-NEXT:    pshufd {{.*}} # xmm0 = xmm0[0,1,0,1]
; FIXME-NEXT:    retq
;
; SSE2-LABEL: shuffle_v16i8_0101010101010101:
; SSE2:       # BB#0:
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,1,0,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,0,0,0,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,4,4,4,4]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_0101010101010101:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_0101010101010101:
; SSE41:       # BB#0:
; SSE41-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1]
; SSE41-NEXT:    retq
;
; AVX1-LABEL: shuffle_v16i8_0101010101010101:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1]
; AVX1-NEXT:    retq
;
; AVX2-LABEL: shuffle_v16i8_0101010101010101:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpbroadcastw %xmm0, %xmm0
; AVX2-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 0, i32 1, i32 0, i32 1, i32 0, i32 1, i32 0, i32 1, i32 0, i32 1, i32 0, i32 1, i32 0, i32 1, i32 0, i32 1>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_00_16_01_17_02_18_03_19_04_20_05_21_06_22_07_23(<16 x i8> %a, <16 x i8> %b) {
; SSE-LABEL: shuffle_v16i8_00_16_01_17_02_18_03_19_04_20_05_21_06_22_07_23:
; SSE:       # BB#0:
; SSE-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSE-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_00_16_01_17_02_18_03_19_04_20_05_21_06_22_07_23:
; AVX:       # BB#0:
; AVX-NEXT:    vpunpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 0, i32 16, i32 1, i32 17, i32 2, i32 18, i32 3, i32 19, i32 4, i32 20, i32 5, i32 21, i32 6, i32 22, i32 7, i32 23>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_08_24_09_25_10_26_11_27_12_28_13_29_14_30_15_31(<16 x i8> %a, <16 x i8> %b) {
; SSE-LABEL: shuffle_v16i8_08_24_09_25_10_26_11_27_12_28_13_29_14_30_15_31:
; SSE:       # BB#0:
; SSE-NEXT:    punpckhbw {{.*#+}} xmm0 = xmm0[8],xmm1[8],xmm0[9],xmm1[9],xmm0[10],xmm1[10],xmm0[11],xmm1[11],xmm0[12],xmm1[12],xmm0[13],xmm1[13],xmm0[14],xmm1[14],xmm0[15],xmm1[15]
; SSE-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_08_24_09_25_10_26_11_27_12_28_13_29_14_30_15_31:
; AVX:       # BB#0:
; AVX-NEXT:    vpunpckhbw {{.*#+}} xmm0 = xmm0[8],xmm1[8],xmm0[9],xmm1[9],xmm0[10],xmm1[10],xmm0[11],xmm1[11],xmm0[12],xmm1[12],xmm0[13],xmm1[13],xmm0[14],xmm1[14],xmm0[15],xmm1[15]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 8, i32 24, i32 9, i32 25, i32 10, i32 26, i32 11, i32 27, i32 12, i32 28, i32 13, i32 29, i32 14, i32 30, i32 15, i32 31>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_16_00_16_01_16_02_16_03_16_04_16_05_16_06_16_07(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: shuffle_v16i8_16_00_16_01_16_02_16_03_16_04_16_05_16_06_16_07:
; SSE2:       # BB#0:
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [255,0,255,0,255,0,255,0,255,0,255,0,255,0,255,0]
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[0,1,0,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm1 = xmm1[0,0,0,0,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm1 = xmm1[0,1,2,3,4,4,4,4]
; SSE2-NEXT:    pand %xmm2, %xmm1
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    por %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_16_00_16_01_16_02_16_03_16_04_16_05_16_06_16_07:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    punpcklbw {{.*#+}} xmm1 = xmm1[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSSE3-NEXT:    pshuflw {{.*#+}} xmm1 = xmm1[0,0,0,0,4,5,6,7]
; SSSE3-NEXT:    punpcklbw {{.*#+}} xmm1 = xmm1[0],xmm0[0],xmm1[1],xmm0[1],xmm1[2],xmm0[2],xmm1[3],xmm0[3],xmm1[4],xmm0[4],xmm1[5],xmm0[5],xmm1[6],xmm0[6],xmm1[7],xmm0[7]
; SSSE3-NEXT:    movdqa %xmm1, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_16_00_16_01_16_02_16_03_16_04_16_05_16_06_16_07:
; SSE41:       # BB#0:
; SSE41-NEXT:    punpcklbw {{.*#+}} xmm1 = xmm1[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE41-NEXT:    pshuflw {{.*#+}} xmm1 = xmm1[0,0,0,0,4,5,6,7]
; SSE41-NEXT:    punpcklbw {{.*#+}} xmm1 = xmm1[0],xmm0[0],xmm1[1],xmm0[1],xmm1[2],xmm0[2],xmm1[3],xmm0[3],xmm1[4],xmm0[4],xmm1[5],xmm0[5],xmm1[6],xmm0[6],xmm1[7],xmm0[7]
; SSE41-NEXT:    movdqa %xmm1, %xmm0
; SSE41-NEXT:    retq
;
; AVX1-LABEL: shuffle_v16i8_16_00_16_01_16_02_16_03_16_04_16_05_16_06_16_07:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpunpcklbw {{.*#+}} xmm1 = xmm1[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; AVX1-NEXT:    vpshuflw {{.*#+}} xmm1 = xmm1[0,0,0,0,4,5,6,7]
; AVX1-NEXT:    vpunpcklbw {{.*#+}} xmm0 = xmm1[0],xmm0[0],xmm1[1],xmm0[1],xmm1[2],xmm0[2],xmm1[3],xmm0[3],xmm1[4],xmm0[4],xmm1[5],xmm0[5],xmm1[6],xmm0[6],xmm1[7],xmm0[7]
; AVX1-NEXT:    retq
;
; AVX2-LABEL: shuffle_v16i8_16_00_16_01_16_02_16_03_16_04_16_05_16_06_16_07:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpbroadcastb %xmm1, %xmm1
; AVX2-NEXT:    vpunpcklbw {{.*#+}} xmm0 = xmm1[0],xmm0[0],xmm1[1],xmm0[1],xmm1[2],xmm0[2],xmm1[3],xmm0[3],xmm1[4],xmm0[4],xmm1[5],xmm0[5],xmm1[6],xmm0[6],xmm1[7],xmm0[7]
; AVX2-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 16, i32 0, i32 16, i32 1, i32 16, i32 2, i32 16, i32 3, i32 16, i32 4, i32 16, i32 5, i32 16, i32 6, i32 16, i32 7>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_03_02_01_00_07_06_05_04_11_10_09_08_15_14_13_12(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: shuffle_v16i8_03_02_01_00_07_06_05_04_11_10_09_08_15_14_13_12:
; SSE2:       # BB#0:
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    punpckhbw {{.*#+}} xmm2 = xmm2[8],xmm1[8],xmm2[9],xmm1[9],xmm2[10],xmm1[10],xmm2[11],xmm1[11],xmm2[12],xmm1[12],xmm2[13],xmm1[13],xmm2[14],xmm1[14],xmm2[15],xmm1[15]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm2 = xmm2[3,2,1,0,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm2 = xmm2[0,1,2,3,7,6,5,4]
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[3,2,1,0,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,7,6,5,4]
; SSE2-NEXT:    packuswb %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_03_02_01_00_07_06_05_04_11_10_09_08_15_14_13_12:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_03_02_01_00_07_06_05_04_11_10_09_08_15_14_13_12:
; SSE41:       # BB#0:
; SSE41-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12]
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_03_02_01_00_07_06_05_04_11_10_09_08_15_14_13_12:
; AVX:       # BB#0:
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 3, i32 2, i32 1, i32 0, i32 7, i32 6, i32 5, i32 4, i32 11, i32 10, i32 9, i32 8, i32 15, i32 14, i32 13, i32 12>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_03_02_01_00_07_06_05_04_19_18_17_16_23_22_21_20(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: shuffle_v16i8_03_02_01_00_07_06_05_04_19_18_17_16_23_22_21_20:
; SSE2:       # BB#0:
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1],xmm1[2],xmm2[2],xmm1[3],xmm2[3],xmm1[4],xmm2[4],xmm1[5],xmm2[5],xmm1[6],xmm2[6],xmm1[7],xmm2[7]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm1 = xmm1[3,2,1,0,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm1 = xmm1[0,1,2,3,7,6,5,4]
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3],xmm0[4],xmm2[4],xmm0[5],xmm2[5],xmm0[6],xmm2[6],xmm0[7],xmm2[7]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[3,2,1,0,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,7,6,5,4]
; SSE2-NEXT:    packuswb %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_03_02_01_00_07_06_05_04_19_18_17_16_23_22_21_20:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[6,4,2,0,14,12,10,8,7,5,3,1,15,13,11,9]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_03_02_01_00_07_06_05_04_19_18_17_16_23_22_21_20:
; SSE41:       # BB#0:
; SSE41-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSE41-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[6,4,2,0,14,12,10,8,7,5,3,1,15,13,11,9]
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_03_02_01_00_07_06_05_04_19_18_17_16_23_22_21_20:
; AVX:       # BB#0:
; AVX-NEXT:    vpunpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[6,4,2,0,14,12,10,8,7,5,3,1,15,13,11,9]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 3, i32 2, i32 1, i32 0, i32 7, i32 6, i32 5, i32 4, i32 19, i32 18, i32 17, i32 16, i32 23, i32 22, i32 21, i32 20>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_03_02_01_00_31_30_29_28_11_10_09_08_23_22_21_20(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: shuffle_v16i8_03_02_01_00_31_30_29_28_11_10_09_08_23_22_21_20:
; SSE2:       # BB#0:
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[1,3,2,3]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; SSE2-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    punpckhbw {{.*#+}} xmm2 = xmm2[8],xmm1[8],xmm2[9],xmm1[9],xmm2[10],xmm1[10],xmm2[11],xmm1[11],xmm2[12],xmm1[12],xmm2[13],xmm1[13],xmm2[14],xmm1[14],xmm2[15],xmm1[15]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm3 = xmm2[3,2,1,0,4,5,6,7]
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm0[2,3,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm1 = xmm1[3,2,1,0,4,5,6,7]
; SSE2-NEXT:    punpcklqdq {{.*#+}} xmm3 = xmm3[0],xmm1[0]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[3,2,1,0,4,5,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm2[2,3,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm1 = xmm1[3,2,1,0,4,5,6,7]
; SSE2-NEXT:    punpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; SSE2-NEXT:    packuswb %xmm3, %xmm0
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_03_02_01_00_31_30_29_28_11_10_09_08_23_22_21_20:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pshufb {{.*#+}} xmm1 = xmm1[15,14,13,12,7,6,5,4,u,u,u,u,u,u,u,u]
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[3,2,1,0,11,10,9,8,u,u,u,u,u,u,u,u]
; SSSE3-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_03_02_01_00_31_30_29_28_11_10_09_08_23_22_21_20:
; SSE41:       # BB#0:
; SSE41-NEXT:    pshufb {{.*#+}} xmm1 = xmm1[15,14,13,12,7,6,5,4,u,u,u,u,u,u,u,u]
; SSE41-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[3,2,1,0,11,10,9,8,u,u,u,u,u,u,u,u]
; SSE41-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_03_02_01_00_31_30_29_28_11_10_09_08_23_22_21_20:
; AVX:       # BB#0:
; AVX-NEXT:    vpshufb {{.*#+}} xmm1 = xmm1[15,14,13,12,7,6,5,4,u,u,u,u,u,u,u,u]
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[3,2,1,0,11,10,9,8,u,u,u,u,u,u,u,u]
; AVX-NEXT:    vpunpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 3, i32 2, i32 1, i32 0, i32 31, i32 30, i32 29, i32 28, i32 11, i32 10, i32 9, i32 8, i32 23, i32 22, i32 21, i32 20>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_00_17_02_19_04_21_06_23_08_25_10_27_12_29_14_31(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: shuffle_v16i8_00_17_02_19_04_21_06_23_08_25_10_27_12_29_14_31:
; SSE2:       # BB#0:
; SSE2-NEXT:    movaps {{.*#+}} xmm2 = [255,0,255,0,255,0,255,0,255,0,255,0,255,0,255,0]
; SSE2-NEXT:    andps %xmm2, %xmm0
; SSE2-NEXT:    andnps %xmm1, %xmm2
; SSE2-NEXT:    orps %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_00_17_02_19_04_21_06_23_08_25_10_27_12_29_14_31:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pshufb {{.*#+}} xmm1 = xmm1[1,3,5,7,9,11,13,15,u,u,u,u,u,u,u,u]
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u]
; SSSE3-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_00_17_02_19_04_21_06_23_08_25_10_27_12_29_14_31:
; SSE41:       # BB#0:
; SSE41-NEXT:    movdqa %xmm0, %xmm2
; SSE41-NEXT:    movaps {{.*#+}} xmm0 = [255,0,255,0,255,0,255,0,255,0,255,0,255,0,255,0]
; SSE41-NEXT:    pblendvb %xmm2, %xmm1
; SSE41-NEXT:    movdqa %xmm1, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_00_17_02_19_04_21_06_23_08_25_10_27_12_29_14_31:
; AVX:       # BB#0:
; AVX-NEXT:    vmovdqa {{.*#+}} xmm2 = [255,0,255,0,255,0,255,0,255,0,255,0,255,0,255,0]
; AVX-NEXT:    vpblendvb %xmm2, %xmm0, %xmm1, %xmm0
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 0, i32 17, i32 2, i32 19, i32 4, i32 21, i32 6, i32 23, i32 8, i32 25, i32 10, i32 27, i32 12, i32 29, i32 14, i32 31>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_00_01_02_19_04_05_06_23_08_09_10_27_12_13_14_31(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: shuffle_v16i8_00_01_02_19_04_05_06_23_08_09_10_27_12_13_14_31:
; SSE2:       # BB#0:
; SSE2-NEXT:    movaps {{.*#+}} xmm2 = [255,255,255,0,255,255,255,0,255,255,255,0,255,255,255,0]
; SSE2-NEXT:    andps %xmm2, %xmm0
; SSE2-NEXT:    andnps %xmm1, %xmm2
; SSE2-NEXT:    orps %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_00_01_02_19_04_05_06_23_08_09_10_27_12_13_14_31:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pshufb {{.*#+}} xmm1 = zero,zero,zero,xmm1[3],zero,zero,zero,xmm1[7],zero,zero,zero,xmm1[11],zero,zero,zero,xmm1[15]
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,1,2],zero,xmm0[4,5,6],zero,xmm0[8,9,10],zero,xmm0[12,13,14],zero
; SSSE3-NEXT:    por %xmm1, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_00_01_02_19_04_05_06_23_08_09_10_27_12_13_14_31:
; SSE41:       # BB#0:
; SSE41-NEXT:    movdqa %xmm0, %xmm2
; SSE41-NEXT:    movaps {{.*#+}} xmm0 = [255,255,255,0,255,255,255,0,255,255,255,0,255,255,255,0]
; SSE41-NEXT:    pblendvb %xmm2, %xmm1
; SSE41-NEXT:    movdqa %xmm1, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_00_01_02_19_04_05_06_23_08_09_10_27_12_13_14_31:
; AVX:       # BB#0:
; AVX-NEXT:    vmovdqa {{.*#+}} xmm2 = [255,255,255,0,255,255,255,0,255,255,255,0,255,255,255,0]
; AVX-NEXT:    vpblendvb %xmm2, %xmm0, %xmm1, %xmm0
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 0, i32 1, i32 2, i32 19, i32 4, i32 5, i32 6, i32 23, i32 8, i32 9, i32 10, i32 27, i32 12, i32 13, i32 14, i32 31>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_00_01_02_zz_04_05_06_zz_08_09_10_zz_12_13_14_zz(<16 x i8> %a) {
; SSE-LABEL: shuffle_v16i8_00_01_02_zz_04_05_06_zz_08_09_10_zz_12_13_14_zz:
; SSE:       # BB#0:
; SSE-NEXT:    andps {{.*}}(%rip), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_00_01_02_zz_04_05_06_zz_08_09_10_zz_12_13_14_zz:
; AVX:       # BB#0:
; AVX-NEXT:    vandps {{.*}}(%rip), %xmm0, %xmm0
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> zeroinitializer, <16 x i32> <i32 0, i32 1, i32 2, i32 19, i32 4, i32 5, i32 6, i32 23, i32 8, i32 9, i32 10, i32 27, i32 12, i32 13, i32 14, i32 31>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_00_01_02_03_20_05_06_23_08_09_10_11_28_13_14_31(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: shuffle_v16i8_00_01_02_03_20_05_06_23_08_09_10_11_28_13_14_31:
; SSE2:       # BB#0:
; SSE2-NEXT:    movaps {{.*#+}} xmm2 = [255,255,255,255,0,255,255,0,255,255,255,255,0,255,255,0]
; SSE2-NEXT:    andps %xmm2, %xmm0
; SSE2-NEXT:    andnps %xmm1, %xmm2
; SSE2-NEXT:    orps %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_00_01_02_03_20_05_06_23_08_09_10_11_28_13_14_31:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pshufb {{.*#+}} xmm1 = zero,zero,zero,zero,xmm1[4],zero,zero,xmm1[7],zero,zero,zero,zero,xmm1[12],zero,zero,xmm1[15]
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,1,2,3],zero,xmm0[5,6],zero,xmm0[8,9,10,11],zero,xmm0[13,14],zero
; SSSE3-NEXT:    por %xmm1, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_00_01_02_03_20_05_06_23_08_09_10_11_28_13_14_31:
; SSE41:       # BB#0:
; SSE41-NEXT:    movdqa %xmm0, %xmm2
; SSE41-NEXT:    movaps {{.*#+}} xmm0 = [255,255,255,255,0,255,255,0,255,255,255,255,0,255,255,0]
; SSE41-NEXT:    pblendvb %xmm2, %xmm1
; SSE41-NEXT:    movdqa %xmm1, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_00_01_02_03_20_05_06_23_08_09_10_11_28_13_14_31:
; AVX:       # BB#0:
; AVX-NEXT:    vmovdqa {{.*#+}} xmm2 = [255,255,255,255,0,255,255,0,255,255,255,255,0,255,255,0]
; AVX-NEXT:    vpblendvb %xmm2, %xmm0, %xmm1, %xmm0
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 20, i32 5, i32 6, i32 23, i32 8, i32 9, i32 10, i32 11, i32 28, i32 13, i32 14, i32 31>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_16_17_18_19_04_05_06_07_24_25_10_11_28_13_30_15(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: shuffle_v16i8_16_17_18_19_04_05_06_07_24_25_10_11_28_13_30_15:
; SSE2:       # BB#0:
; SSE2-NEXT:    movaps {{.*#+}} xmm2 = [255,255,255,255,0,0,0,0,255,255,0,0,255,0,255,0]
; SSE2-NEXT:    andps %xmm2, %xmm1
; SSE2-NEXT:    andnps %xmm0, %xmm2
; SSE2-NEXT:    orps %xmm1, %xmm2
; SSE2-NEXT:    movaps %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_16_17_18_19_04_05_06_07_24_25_10_11_28_13_30_15:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = zero,zero,zero,zero,xmm0[4,5,6,7],zero,zero,xmm0[10,11],zero,xmm0[13],zero,xmm0[15]
; SSSE3-NEXT:    pshufb {{.*#+}} xmm1 = xmm1[0,1,2,3],zero,zero,zero,zero,xmm1[8,9],zero,zero,xmm1[12],zero,xmm1[14],zero
; SSSE3-NEXT:    por %xmm1, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_16_17_18_19_04_05_06_07_24_25_10_11_28_13_30_15:
; SSE41:       # BB#0:
; SSE41-NEXT:    movdqa %xmm0, %xmm2
; SSE41-NEXT:    movaps {{.*#+}} xmm0 = [255,255,255,255,0,0,0,0,255,255,0,0,255,0,255,0]
; SSE41-NEXT:    pblendvb %xmm1, %xmm2
; SSE41-NEXT:    movdqa %xmm2, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_16_17_18_19_04_05_06_07_24_25_10_11_28_13_30_15:
; AVX:       # BB#0:
; AVX-NEXT:    vmovdqa {{.*#+}} xmm2 = [255,255,255,255,0,0,0,0,255,255,0,0,255,0,255,0]
; AVX-NEXT:    vpblendvb %xmm2, %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 16, i32 17, i32 18, i32 19, i32 4, i32 5, i32 6, i32 7, i32 24, i32 25, i32 10, i32 11, i32 28, i32 13, i32 30, i32 15>
  ret <16 x i8> %shuffle
}

define <16 x i8> @trunc_v4i32_shuffle(<16 x i8> %a) {
; SSE2-LABEL: trunc_v4i32_shuffle:
; SSE2:       # BB#0:
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE2-NEXT:    packuswb %xmm0, %xmm0
; SSE2-NEXT:    packuswb %xmm0, %xmm0
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: trunc_v4i32_shuffle:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,4,8,12,u,u,u,u,u,u,u,u,u,u,u,u]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: trunc_v4i32_shuffle:
; SSE41:       # BB#0:
; SSE41-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,4,8,12,u,u,u,u,u,u,u,u,u,u,u,u]
; SSE41-NEXT:    retq
;
; AVX-LABEL: trunc_v4i32_shuffle:
; AVX:       # BB#0:
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,4,8,12,u,u,u,u,u,u,u,u,u,u,u,u]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> undef, <16 x i32> <i32 0, i32 4, i32 8, i32 12, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  ret <16 x i8> %shuffle
}

define <16 x i8> @stress_test0(<16 x i8> %s.0.1, <16 x i8> %s.0.2, <16 x i8> %s.0.3, <16 x i8> %s.0.4, <16 x i8> %s.0.5, <16 x i8> %s.0.6, <16 x i8> %s.0.7, <16 x i8> %s.0.8, <16 x i8> %s.0.9) {
; We don't have anything useful to check here. This generates 100s of
; instructions. Instead, just make sure we survived codegen.
; ALL-LABEL: stress_test0:
; ALL:         retq
entry:
  %s.1.4 = shufflevector <16 x i8> %s.0.4, <16 x i8> %s.0.5, <16 x i32> <i32 1, i32 22, i32 21, i32 28, i32 3, i32 16, i32 6, i32 1, i32 19, i32 29, i32 12, i32 31, i32 2, i32 3, i32 3, i32 6>
  %s.1.5 = shufflevector <16 x i8> %s.0.5, <16 x i8> %s.0.6, <16 x i32> <i32 31, i32 20, i32 12, i32 19, i32 2, i32 15, i32 12, i32 31, i32 2, i32 28, i32 2, i32 30, i32 7, i32 8, i32 17, i32 28>
  %s.1.8 = shufflevector <16 x i8> %s.0.8, <16 x i8> %s.0.9, <16 x i32> <i32 14, i32 10, i32 17, i32 5, i32 17, i32 9, i32 17, i32 21, i32 31, i32 24, i32 16, i32 6, i32 20, i32 28, i32 23, i32 8>
  %s.2.2 = shufflevector <16 x i8> %s.0.3, <16 x i8> %s.0.4, <16 x i32> <i32 20, i32 9, i32 21, i32 11, i32 11, i32 4, i32 3, i32 18, i32 3, i32 30, i32 4, i32 31, i32 11, i32 24, i32 13, i32 29>
  %s.3.2 = shufflevector <16 x i8> %s.2.2, <16 x i8> %s.1.4, <16 x i32> <i32 15, i32 13, i32 5, i32 11, i32 7, i32 17, i32 14, i32 22, i32 22, i32 16, i32 7, i32 24, i32 16, i32 22, i32 7, i32 29>
  %s.5.4 = shufflevector <16 x i8> %s.1.5, <16 x i8> %s.1.8, <16 x i32> <i32 3, i32 13, i32 19, i32 7, i32 23, i32 11, i32 1, i32 9, i32 16, i32 25, i32 2, i32 7, i32 0, i32 21, i32 23, i32 17>
  %s.6.1 = shufflevector <16 x i8> %s.3.2, <16 x i8> %s.3.2, <16 x i32> <i32 11, i32 2, i32 28, i32 31, i32 27, i32 3, i32 9, i32 27, i32 25, i32 25, i32 14, i32 7, i32 12, i32 28, i32 12, i32 23>
  %s.7.1 = shufflevector <16 x i8> %s.6.1, <16 x i8> %s.3.2, <16 x i32> <i32 15, i32 29, i32 14, i32 0, i32 29, i32 15, i32 26, i32 30, i32 6, i32 7, i32 2, i32 8, i32 12, i32 10, i32 29, i32 17>
  %s.7.2 = shufflevector <16 x i8> %s.3.2, <16 x i8> %s.5.4, <16 x i32> <i32 3, i32 29, i32 3, i32 19, i32 undef, i32 20, i32 undef, i32 3, i32 27, i32 undef, i32 undef, i32 11, i32 undef, i32 undef, i32 undef, i32 undef>
  %s.16.0 = shufflevector <16 x i8> %s.7.1, <16 x i8> %s.7.2, <16 x i32> <i32 13, i32 1, i32 16, i32 16, i32 6, i32 7, i32 29, i32 18, i32 19, i32 28, i32 undef, i32 undef, i32 31, i32 1, i32 undef, i32 10>
  ret <16 x i8> %s.16.0
}

define <16 x i8> @undef_test1(<16 x i8> %s.0.5, <16 x i8> %s.0.8, <16 x i8> %s.0.9) noinline nounwind {
; There is nothing interesting to check about these instructions other than
; that they survive codegen. However, we actually do better and delete all of
; them because the result is 'undef'.
;
; ALL-LABEL: undef_test1:
; ALL:       # BB#0: # %entry
; ALL-NEXT:    retq
entry:
  %s.1.8 = shufflevector <16 x i8> %s.0.8, <16 x i8> undef, <16 x i32> <i32 9, i32 9, i32 undef, i32 undef, i32 undef, i32 2, i32 undef, i32 6, i32 undef, i32 6, i32 undef, i32 14, i32 14, i32 undef, i32 undef, i32 0>
  %s.2.4 = shufflevector <16 x i8> undef, <16 x i8> %s.0.5, <16 x i32> <i32 21, i32 undef, i32 undef, i32 19, i32 undef, i32 undef, i32 29, i32 24, i32 21, i32 23, i32 21, i32 17, i32 19, i32 undef, i32 20, i32 22>
  %s.2.5 = shufflevector <16 x i8> %s.0.5, <16 x i8> undef, <16 x i32> <i32 3, i32 8, i32 undef, i32 7, i32 undef, i32 10, i32 8, i32 0, i32 15, i32 undef, i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 9>
  %s.2.9 = shufflevector <16 x i8> %s.0.9, <16 x i8> undef, <16 x i32> <i32 7, i32 undef, i32 14, i32 7, i32 8, i32 undef, i32 7, i32 8, i32 5, i32 15, i32 undef, i32 1, i32 11, i32 undef, i32 undef, i32 11>
  %s.3.4 = shufflevector <16 x i8> %s.2.4, <16 x i8> %s.0.5, <16 x i32> <i32 5, i32 0, i32 21, i32 6, i32 15, i32 27, i32 22, i32 21, i32 4, i32 22, i32 19, i32 26, i32 9, i32 26, i32 8, i32 29>
  %s.3.9 = shufflevector <16 x i8> %s.2.9, <16 x i8> undef, <16 x i32> <i32 8, i32 6, i32 8, i32 1, i32 undef, i32 4, i32 undef, i32 2, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 6, i32 undef>
  %s.4.7 = shufflevector <16 x i8> %s.1.8, <16 x i8> %s.2.9, <16 x i32> <i32 9, i32 0, i32 22, i32 20, i32 24, i32 7, i32 21, i32 17, i32 20, i32 12, i32 19, i32 23, i32 2, i32 9, i32 17, i32 10>
  %s.4.8 = shufflevector <16 x i8> %s.2.9, <16 x i8> %s.3.9, <16 x i32> <i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 6, i32 10, i32 undef, i32 0, i32 5, i32 undef, i32 9, i32 undef>
  %s.5.7 = shufflevector <16 x i8> %s.4.7, <16 x i8> %s.4.8, <16 x i32> <i32 16, i32 0, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %s.8.4 = shufflevector <16 x i8> %s.3.4, <16 x i8> %s.5.7, <16 x i32> <i32 undef, i32 undef, i32 undef, i32 28, i32 undef, i32 0, i32 undef, i32 undef, i32 undef, i32 undef, i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %s.9.4 = shufflevector <16 x i8> %s.8.4, <16 x i8> undef, <16 x i32> <i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 10, i32 5>
  %s.10.4 = shufflevector <16 x i8> %s.9.4, <16 x i8> undef, <16 x i32> <i32 undef, i32 7, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %s.12.4 = shufflevector <16 x i8> %s.10.4, <16 x i8> undef, <16 x i32> <i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 13, i32 undef, i32 undef, i32 undef>

  ret <16 x i8> %s.12.4
}

define <16 x i8> @PR20540(<8 x i8> %a) {
; SSE2-LABEL: PR20540:
; SSE2:       # BB#0:
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE2-NEXT:    packuswb %xmm0, %xmm0
; SSE2-NEXT:    movq {{.*#+}} xmm0 = xmm0[0],zero
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: PR20540:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,2,4,6,8,10,12,14],zero,zero,zero,zero,zero,zero,zero,zero
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: PR20540:
; SSE41:       # BB#0:
; SSE41-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,2,4,6,8,10,12,14],zero,zero,zero,zero,zero,zero,zero,zero
; SSE41-NEXT:    retq
;
; AVX-LABEL: PR20540:
; AVX:       # BB#0:
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,2,4,6,8,10,12,14],zero,zero,zero,zero,zero,zero,zero,zero
; AVX-NEXT:    retq
  %shuffle = shufflevector <8 x i8> %a, <8 x i8> zeroinitializer, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_16_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz(i8 %i) {
; SSE-LABEL: shuffle_v16i8_16_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz:
; SSE:       # BB#0:
; SSE-NEXT:    movzbl %dil, %eax
; SSE-NEXT:    movd %eax, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_16_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz:
; AVX:       # BB#0:
; AVX-NEXT:    movzbl %dil, %eax
; AVX-NEXT:    vmovd %eax, %xmm0
; AVX-NEXT:    retq
  %a = insertelement <16 x i8> undef, i8 %i, i32 0
  %shuffle = shufflevector <16 x i8> zeroinitializer, <16 x i8> %a, <16 x i32> <i32 16, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_zz_zz_zz_zz_zz_16_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz(i8 %i) {
; SSE2-LABEL: shuffle_v16i8_zz_zz_zz_zz_zz_16_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz:
; SSE2:       # BB#0:
; SSE2-NEXT:    shll $8, %edi
; SSE2-NEXT:    pxor %xmm0, %xmm0
; SSE2-NEXT:    pinsrw $2, %edi, %xmm0
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_zz_zz_zz_zz_zz_16_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    shll $8, %edi
; SSSE3-NEXT:    pxor %xmm0, %xmm0
; SSSE3-NEXT:    pinsrw $2, %edi, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_zz_zz_zz_zz_zz_16_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz:
; SSE41:       # BB#0:
; SSE41-NEXT:    pxor %xmm0, %xmm0
; SSE41-NEXT:    pinsrb $5, %edi, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_zz_zz_zz_zz_zz_16_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz:
; AVX:       # BB#0:
; AVX-NEXT:    vpxor %xmm0, %xmm0, %xmm0
; AVX-NEXT:    vpinsrb $5, %edi, %xmm0, %xmm0
; AVX-NEXT:    retq
  %a = insertelement <16 x i8> undef, i8 %i, i32 0
  %shuffle = shufflevector <16 x i8> zeroinitializer, <16 x i8> %a, <16 x i32> <i32 0, i32 0, i32 0, i32 0, i32 0, i32 16, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_zz_uu_uu_zz_uu_uu_zz_zz_zz_zz_zz_zz_zz_zz_zz_16(i8 %i) {
; SSE2-LABEL: shuffle_v16i8_zz_uu_uu_zz_uu_uu_zz_zz_zz_zz_zz_zz_zz_zz_zz_16:
; SSE2:       # BB#0:
; SSE2-NEXT:    shll $8, %edi
; SSE2-NEXT:    pxor %xmm0, %xmm0
; SSE2-NEXT:    pinsrw $7, %edi, %xmm0
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_zz_uu_uu_zz_uu_uu_zz_zz_zz_zz_zz_zz_zz_zz_zz_16:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    shll $8, %edi
; SSSE3-NEXT:    pxor %xmm0, %xmm0
; SSSE3-NEXT:    pinsrw $7, %edi, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_zz_uu_uu_zz_uu_uu_zz_zz_zz_zz_zz_zz_zz_zz_zz_16:
; SSE41:       # BB#0:
; SSE41-NEXT:    pxor %xmm0, %xmm0
; SSE41-NEXT:    pinsrb $15, %edi, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_zz_uu_uu_zz_uu_uu_zz_zz_zz_zz_zz_zz_zz_zz_zz_16:
; AVX:       # BB#0:
; AVX-NEXT:    vpxor %xmm0, %xmm0, %xmm0
; AVX-NEXT:    vpinsrb $15, %edi, %xmm0, %xmm0
; AVX-NEXT:    retq
  %a = insertelement <16 x i8> undef, i8 %i, i32 0
  %shuffle = shufflevector <16 x i8> zeroinitializer, <16 x i8> %a, <16 x i32> <i32 0, i32 undef, i32 undef, i32 3, i32 undef, i32 undef, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 16>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_zz_zz_19_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz(i8 %i) {
; SSE2-LABEL: shuffle_v16i8_zz_zz_19_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz:
; SSE2:       # BB#0:
; SSE2-NEXT:    movzbl %dil, %eax
; SSE2-NEXT:    pxor %xmm0, %xmm0
; SSE2-NEXT:    pinsrw $1, %eax, %xmm0
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_zz_zz_19_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    movzbl %dil, %eax
; SSSE3-NEXT:    pxor %xmm0, %xmm0
; SSSE3-NEXT:    pinsrw $1, %eax, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_zz_zz_19_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz:
; SSE41:       # BB#0:
; SSE41-NEXT:    pxor %xmm0, %xmm0
; SSE41-NEXT:    pinsrb $2, %edi, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_zz_zz_19_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz:
; AVX:       # BB#0:
; AVX-NEXT:    vpxor %xmm0, %xmm0, %xmm0
; AVX-NEXT:    vpinsrb $2, %edi, %xmm0, %xmm0
; AVX-NEXT:    retq
  %a = insertelement <16 x i8> undef, i8 %i, i32 3
  %shuffle = shufflevector <16 x i8> zeroinitializer, <16 x i8> %a, <16 x i32> <i32 0, i32 1, i32 19, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_16_uu_18_uu(<16 x i8> %a) {
; SSE-LABEL: shuffle_v16i8_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_16_uu_18_uu:
; SSE:       # BB#0:
; SSE-NEXT:    pslldq {{.*#+}} xmm0 = zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,xmm0[0,1,2,3]
; SSE-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_16_uu_18_uu:
; AVX:       # BB#0:
; AVX-NEXT:    vpslldq {{.*#+}} xmm0 = zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,xmm0[0,1,2,3]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> zeroinitializer, <16 x i8> %a, <16 x i32> <i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 16, i32 undef, i32 18, i32 undef>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_28_uu_30_31_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz(<16 x i8> %a) {
; SSE-LABEL: shuffle_v16i8_28_uu_30_31_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz:
; SSE:       # BB#0:
; SSE-NEXT:    psrldq {{.*#+}} xmm0 = xmm0[12,13,14,15],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; SSE-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_28_uu_30_31_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz_zz:
; AVX:       # BB#0:
; AVX-NEXT:    vpsrldq {{.*#+}} xmm0 = xmm0[12,13,14,15],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> zeroinitializer, <16 x i8> %a, <16 x i32> <i32 28, i32 undef, i32 30, i32 31, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 09, i32 0, i32 0, i32 0, i32 0, i32 0>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_31_00_01_02_03_04_05_06_07_08_09_10_11_12_13_14(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: shuffle_v16i8_31_00_01_02_03_04_05_06_07_08_09_10_11_12_13_14:
; SSE2:       # BB#0:
; SSE2-NEXT:    psrldq {{.*#+}} xmm1 = xmm1[15],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; SSE2-NEXT:    pslldq {{.*#+}} xmm0 = zero,xmm0[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]
; SSE2-NEXT:    por %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_31_00_01_02_03_04_05_06_07_08_09_10_11_12_13_14:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    palignr {{.*#+}} xmm0 = xmm1[15],xmm0[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_31_00_01_02_03_04_05_06_07_08_09_10_11_12_13_14:
; SSE41:       # BB#0:
; SSE41-NEXT:    palignr {{.*#+}} xmm0 = xmm1[15],xmm0[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_31_00_01_02_03_04_05_06_07_08_09_10_11_12_13_14:
; AVX:       # BB#0:
; AVX-NEXT:    vpalignr {{.*#+}} xmm0 = xmm1[15],xmm0[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 31, i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_15_00_01_02_03_04_05_06_07_08_09_10_11_12_13_14(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: shuffle_v16i8_15_00_01_02_03_04_05_06_07_08_09_10_11_12_13_14:
; SSE2:       # BB#0:
; SSE2-NEXT:    movdqa %xmm0, %xmm1
; SSE2-NEXT:    psrldq {{.*#+}} xmm1 = xmm1[15],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; SSE2-NEXT:    pslldq {{.*#+}} xmm0 = zero,xmm0[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]
; SSE2-NEXT:    por %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_15_00_01_02_03_04_05_06_07_08_09_10_11_12_13_14:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    palignr {{.*#+}} xmm0 = xmm0[15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_15_00_01_02_03_04_05_06_07_08_09_10_11_12_13_14:
; SSE41:       # BB#0:
; SSE41-NEXT:    palignr {{.*#+}} xmm0 = xmm0[15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_15_00_01_02_03_04_05_06_07_08_09_10_11_12_13_14:
; AVX:       # BB#0:
; AVX-NEXT:    vpalignr {{.*#+}} xmm0 = xmm0[15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 15, i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_17_18_19_20_21_22_23_24_25_26_27_28_29_30_31_00(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: shuffle_v16i8_17_18_19_20_21_22_23_24_25_26_27_28_29_30_31_00:
; SSE2:       # BB#0:
; SSE2-NEXT:    psrldq {{.*#+}} xmm1 = xmm1[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],zero
; SSE2-NEXT:    pslldq {{.*#+}} xmm0 = zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,xmm0[0]
; SSE2-NEXT:    por %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_17_18_19_20_21_22_23_24_25_26_27_28_29_30_31_00:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    palignr {{.*#+}} xmm0 = xmm1[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],xmm0[0]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_17_18_19_20_21_22_23_24_25_26_27_28_29_30_31_00:
; SSE41:       # BB#0:
; SSE41-NEXT:    palignr {{.*#+}} xmm0 = xmm1[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],xmm0[0]
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_17_18_19_20_21_22_23_24_25_26_27_28_29_30_31_00:
; AVX:       # BB#0:
; AVX-NEXT:    vpalignr {{.*#+}} xmm0 = xmm1[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],xmm0[0]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31, i32 0>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_01_02_03_04_05_06_07_08_09_10_11_12_13_14_15_16(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: shuffle_v16i8_01_02_03_04_05_06_07_08_09_10_11_12_13_14_15_16:
; SSE2:       # BB#0:
; SSE2-NEXT:    psrldq {{.*#+}} xmm0 = xmm0[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],zero
; SSE2-NEXT:    pslldq {{.*#+}} xmm1 = zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,xmm1[0]
; SSE2-NEXT:    por %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_01_02_03_04_05_06_07_08_09_10_11_12_13_14_15_16:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    palignr {{.*#+}} xmm1 = xmm0[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],xmm1[0]
; SSSE3-NEXT:    movdqa %xmm1, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_01_02_03_04_05_06_07_08_09_10_11_12_13_14_15_16:
; SSE41:       # BB#0:
; SSE41-NEXT:    palignr {{.*#+}} xmm1 = xmm0[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],xmm1[0]
; SSE41-NEXT:    movdqa %xmm1, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_01_02_03_04_05_06_07_08_09_10_11_12_13_14_15_16:
; AVX:       # BB#0:
; AVX-NEXT:    vpalignr {{.*#+}} xmm0 = xmm0[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],xmm1[0]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_01_02_03_04_05_06_07_08_09_10_11_12_13_14_15_00(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: shuffle_v16i8_01_02_03_04_05_06_07_08_09_10_11_12_13_14_15_00:
; SSE2:       # BB#0:
; SSE2-NEXT:    movdqa %xmm0, %xmm1
; SSE2-NEXT:    psrldq {{.*#+}} xmm1 = xmm1[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],zero
; SSE2-NEXT:    pslldq {{.*#+}} xmm0 = zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,xmm0[0]
; SSE2-NEXT:    por %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_01_02_03_04_05_06_07_08_09_10_11_12_13_14_15_00:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    palignr {{.*#+}} xmm0 = xmm0[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_01_02_03_04_05_06_07_08_09_10_11_12_13_14_15_00:
; SSE41:       # BB#0:
; SSE41-NEXT:    palignr {{.*#+}} xmm0 = xmm0[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0]
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_01_02_03_04_05_06_07_08_09_10_11_12_13_14_15_00:
; AVX:       # BB#0:
; AVX-NEXT:    vpalignr {{.*#+}} xmm0 = xmm0[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 0>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_15_16_17_18_19_20_21_22_23_24_25_26_27_28_29_30(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: shuffle_v16i8_15_16_17_18_19_20_21_22_23_24_25_26_27_28_29_30:
; SSE2:       # BB#0:
; SSE2-NEXT:    psrldq {{.*#+}} xmm0 = xmm0[15],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; SSE2-NEXT:    pslldq {{.*#+}} xmm1 = zero,xmm1[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]
; SSE2-NEXT:    por %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_15_16_17_18_19_20_21_22_23_24_25_26_27_28_29_30:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    palignr {{.*#+}} xmm1 = xmm0[15],xmm1[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]
; SSSE3-NEXT:    movdqa %xmm1, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_15_16_17_18_19_20_21_22_23_24_25_26_27_28_29_30:
; SSE41:       # BB#0:
; SSE41-NEXT:    palignr {{.*#+}} xmm1 = xmm0[15],xmm1[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]
; SSE41-NEXT:    movdqa %xmm1, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_15_16_17_18_19_20_21_22_23_24_25_26_27_28_29_30:
; AVX:       # BB#0:
; AVX-NEXT:    vpalignr {{.*#+}} xmm0 = xmm0[15],xmm1[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_00_uu_uu_uu_uu_uu_uu_uu_01_uu_uu_uu_uu_uu_uu_uu(<16 x i8> %a) {
; SSE2-LABEL: shuffle_v16i8_00_uu_uu_uu_uu_uu_uu_uu_01_uu_uu_uu_uu_uu_uu_uu:
; SSE2:       # BB#0:
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3]
; SSE2-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0,0,1,1]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_00_uu_uu_uu_uu_uu_uu_uu_01_uu_uu_uu_uu_uu_uu_uu:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,zero,zero,zero,zero,xmm0[1],zero,zero,zero,zero,zero,zero,zero
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_00_uu_uu_uu_uu_uu_uu_uu_01_uu_uu_uu_uu_uu_uu_uu:
; SSE41:       # BB#0:
; SSE41-NEXT:    pmovzxbq {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,zero,zero,zero,zero,xmm0[1],zero,zero,zero,zero,zero,zero,zero
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_00_uu_uu_uu_uu_uu_uu_uu_01_uu_uu_uu_uu_uu_uu_uu:
; AVX:       # BB#0:
; AVX-NEXT:    vpmovzxbq {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,zero,zero,zero,zero,xmm0[1],zero,zero,zero,zero,zero,zero,zero
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> zeroinitializer, <16 x i32> <i32 0, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_00_zz_zz_zz_zz_zz_zz_zz_01_zz_zz_zz_zz_zz_zz_zz(<16 x i8> %a) {
; SSE2-LABEL: shuffle_v16i8_00_zz_zz_zz_zz_zz_zz_zz_01_zz_zz_zz_zz_zz_zz_zz:
; SSE2:       # BB#0:
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; SSE2-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_00_zz_zz_zz_zz_zz_zz_zz_01_zz_zz_zz_zz_zz_zz_zz:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,zero,zero,zero,zero,xmm0[1],zero,zero,zero,zero,zero,zero,zero
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_00_zz_zz_zz_zz_zz_zz_zz_01_zz_zz_zz_zz_zz_zz_zz:
; SSE41:       # BB#0:
; SSE41-NEXT:    pmovzxbq {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,zero,zero,zero,zero,xmm0[1],zero,zero,zero,zero,zero,zero,zero
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_00_zz_zz_zz_zz_zz_zz_zz_01_zz_zz_zz_zz_zz_zz_zz:
; AVX:       # BB#0:
; AVX-NEXT:    vpmovzxbq {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,zero,zero,zero,zero,xmm0[1],zero,zero,zero,zero,zero,zero,zero
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> zeroinitializer, <16 x i32> <i32 0, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 1, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_00_uu_uu_uu_01_uu_uu_uu_02_uu_uu_uu_03_uu_uu_uu(<16 x i8> %a) {
; SSE2-LABEL: shuffle_v16i8_00_uu_uu_uu_01_uu_uu_uu_02_uu_uu_uu_03_uu_uu_uu:
; SSE2:       # BB#0:
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_00_uu_uu_uu_01_uu_uu_uu_02_uu_uu_uu_03_uu_uu_uu:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_00_uu_uu_uu_01_uu_uu_uu_02_uu_uu_uu_03_uu_uu_uu:
; SSE41:       # BB#0:
; SSE41-NEXT:    pmovzxbd {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_00_uu_uu_uu_01_uu_uu_uu_02_uu_uu_uu_03_uu_uu_uu:
; AVX:       # BB#0:
; AVX-NEXT:    vpmovzxbd {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> zeroinitializer, <16 x i32> <i32 0, i32 undef, i32 undef, i32 undef, i32 1, i32 undef, i32 undef, i32 undef, i32 2, i32 undef, i32 undef, i32 undef, i32 3, i32 undef, i32 undef, i32 undef>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_00_zz_zz_zz_01_zz_zz_zz_02_zz_zz_zz_03_zz_zz_zz(<16 x i8> %a) {
; SSE2-LABEL: shuffle_v16i8_00_zz_zz_zz_01_zz_zz_zz_02_zz_zz_zz_03_zz_zz_zz:
; SSE2:       # BB#0:
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSE2-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_00_zz_zz_zz_01_zz_zz_zz_02_zz_zz_zz_03_zz_zz_zz:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pxor %xmm1, %xmm1
; SSSE3-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSSE3-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_00_zz_zz_zz_01_zz_zz_zz_02_zz_zz_zz_03_zz_zz_zz:
; SSE41:       # BB#0:
; SSE41-NEXT:    pmovzxbd {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_00_zz_zz_zz_01_zz_zz_zz_02_zz_zz_zz_03_zz_zz_zz:
; AVX:       # BB#0:
; AVX-NEXT:    vpmovzxbd {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> zeroinitializer, <16 x i32> <i32 0, i32 17, i32 18, i32 19, i32 1, i32 21, i32 22, i32 23, i32 2, i32 25, i32 26, i32 27, i32 3, i32 29, i32 30, i32 31>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_00_uu_01_uu_02_uu_03_uu_04_uu_05_uu_06_uu_07_uu(<16 x i8> %a) {
; SSE2-LABEL: shuffle_v16i8_00_uu_01_uu_02_uu_03_uu_04_uu_05_uu_06_uu_07_uu:
; SSE2:       # BB#0:
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_00_uu_01_uu_02_uu_03_uu_04_uu_05_uu_06_uu_07_uu:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_00_uu_01_uu_02_uu_03_uu_04_uu_05_uu_06_uu_07_uu:
; SSE41:       # BB#0:
; SSE41-NEXT:    pmovzxbw {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_00_uu_01_uu_02_uu_03_uu_04_uu_05_uu_06_uu_07_uu:
; AVX:       # BB#0:
; AVX-NEXT:    vpmovzxbw {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> zeroinitializer, <16 x i32> <i32 0, i32 undef, i32 1, i32 undef, i32 2, i32 undef, i32 3, i32 undef, i32 4, i32 undef, i32 5, i32 undef, i32 6, i32 undef, i32 7, i32 undef>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_00_zz_01_zz_02_zz_03_zz_04_zz_05_zz_06_zz_07_zz(<16 x i8> %a) {
; SSE2-LABEL: shuffle_v16i8_00_zz_01_zz_02_zz_03_zz_04_zz_05_zz_06_zz_07_zz:
; SSE2:       # BB#0:
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_00_zz_01_zz_02_zz_03_zz_04_zz_05_zz_06_zz_07_zz:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    pxor %xmm1, %xmm1
; SSSE3-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_00_zz_01_zz_02_zz_03_zz_04_zz_05_zz_06_zz_07_zz:
; SSE41:       # BB#0:
; SSE41-NEXT:    pmovzxbw {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_00_zz_01_zz_02_zz_03_zz_04_zz_05_zz_06_zz_07_zz:
; AVX:       # BB#0:
; AVX-NEXT:    vpmovzxbw {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> zeroinitializer, <16 x i32> <i32 0, i32 17, i32 1, i32 19, i32 2, i32 21, i32 3, i32 23, i32 4, i32 25, i32 5, i32 27, i32 6, i32 29, i32 7, i32 31>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_uu_10_02_07_22_14_07_02_18_03_01_14_18_09_11_00(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: shuffle_v16i8_uu_10_02_07_22_14_07_02_18_03_01_14_18_09_11_00:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    movdqa %xmm0, %xmm3
; SSE2-NEXT:    punpckhbw {{.*#+}} xmm3 = xmm3[8],xmm2[8],xmm3[9],xmm2[9],xmm3[10],xmm2[10],xmm3[11],xmm2[11],xmm3[12],xmm2[12],xmm3[13],xmm2[13],xmm3[14],xmm2[14],xmm3[15],xmm2[15]
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm3[0,3,0,1]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm4 = xmm4[0,1,2,2,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm4 = xmm4[0,1,2,3,4,5,7,7]
; SSE2-NEXT:    movdqa {{.*#+}} xmm5 = [65535,65535,65535,0,65535,0,0,65535]
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3],xmm0[4],xmm2[4],xmm0[5],xmm2[5],xmm0[6],xmm2[6],xmm0[7],xmm2[7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm0[0,1,0,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm2 = xmm2[0,3,1,3,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm2 = xmm2[0,1,2,3,4,5,6,4]
; SSE2-NEXT:    pand %xmm5, %xmm2
; SSE2-NEXT:    pandn %xmm4, %xmm5
; SSE2-NEXT:    por %xmm2, %xmm5
; SSE2-NEXT:    psrlq $16, %xmm3
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm3[0,2,2,3]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[3,1,1,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,1,2,1,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,4,5,7,4]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,3,2,3]
; SSE2-NEXT:    punpckldq {{.*#+}} xmm2 = xmm2[0],xmm0[0],xmm2[1],xmm0[1]
; SSE2-NEXT:    packuswb %xmm5, %xmm2
; SSE2-NEXT:    movdqa {{.*#+}} xmm0 = [255,255,255,255,0,255,255,255,0,255,255,255,0,255,255,255]
; SSE2-NEXT:    pand %xmm0, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[0,1,0,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm1 = xmm1[0,1,3,3,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm1 = xmm1[0,1,2,3,5,5,5,7]
; SSE2-NEXT:    pandn %xmm1, %xmm0
; SSE2-NEXT:    por %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: shuffle_v16i8_uu_10_02_07_22_14_07_02_18_03_01_14_18_09_11_00:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    pshufb {{.*#+}} xmm1 = xmm1[u],zero,zero,zero,xmm1[6],zero,zero,zero,xmm1[2],zero,zero,zero,xmm1[2],zero,zero,zero
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[u,10,2,7],zero,xmm0[14,7,2],zero,xmm0[3,1,14],zero,xmm0[9,11,0]
; SSSE3-NEXT:    por %xmm1, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: shuffle_v16i8_uu_10_02_07_22_14_07_02_18_03_01_14_18_09_11_00:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    pshufb {{.*#+}} xmm1 = xmm1[u],zero,zero,zero,xmm1[6],zero,zero,zero,xmm1[2],zero,zero,zero,xmm1[2],zero,zero,zero
; SSE41-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[u,10,2,7],zero,xmm0[14,7,2],zero,xmm0[3,1,14],zero,xmm0[9,11,0]
; SSE41-NEXT:    por %xmm1, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_uu_10_02_07_22_14_07_02_18_03_01_14_18_09_11_00:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpshufb {{.*#+}} xmm1 = xmm1[u],zero,zero,zero,xmm1[6],zero,zero,zero,xmm1[2],zero,zero,zero,xmm1[2],zero,zero,zero
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[u,10,2,7],zero,xmm0[14,7,2],zero,xmm0[3,1,14],zero,xmm0[9,11,0]
; AVX-NEXT:    vpor %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 undef, i32 10, i32 2, i32 7, i32 22, i32 14, i32 7, i32 2, i32 18, i32 3, i32 1, i32 14, i32 18, i32 9, i32 11, i32 0>

  ret <16 x i8> %shuffle
}

define <16 x i8> @stress_test2(<16 x i8> %s.0.0, <16 x i8> %s.0.1, <16 x i8> %s.0.2) {
; Nothing interesting to test here. Just make sure we didn't crashe.
; ALL-LABEL: stress_test2:
; ALL:         retq
entry:
  %s.1.0 = shufflevector <16 x i8> %s.0.0, <16 x i8> %s.0.1, <16 x i32> <i32 29, i32 30, i32 2, i32 16, i32 26, i32 21, i32 11, i32 26, i32 26, i32 3, i32 4, i32 5, i32 30, i32 28, i32 15, i32 5>
  %s.1.1 = shufflevector <16 x i8> %s.0.1, <16 x i8> %s.0.2, <16 x i32> <i32 31, i32 1, i32 24, i32 12, i32 28, i32 5, i32 2, i32 9, i32 29, i32 1, i32 31, i32 5, i32 6, i32 17, i32 15, i32 22>
  %s.2.0 = shufflevector <16 x i8> %s.1.0, <16 x i8> %s.1.1, <16 x i32> <i32 22, i32 1, i32 12, i32 3, i32 30, i32 4, i32 30, i32 undef, i32 1, i32 10, i32 14, i32 18, i32 27, i32 13, i32 16, i32 19>

  ret <16 x i8> %s.2.0
}

define void @constant_gets_selected(<4 x i32>* %ptr1, <4 x i32>* %ptr2) {
; SSE-LABEL: constant_gets_selected:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    xorps %xmm0, %xmm0
; SSE-NEXT:    movaps %xmm0, (%rdi)
; SSE-NEXT:    movaps %xmm0, (%rsi)
; SSE-NEXT:    retq
;
; AVX-LABEL: constant_gets_selected:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vxorps %xmm0, %xmm0, %xmm0
; AVX-NEXT:    vmovaps %xmm0, (%rdi)
; AVX-NEXT:    vmovaps %xmm0, (%rsi)
; AVX-NEXT:    retq
entry:
  %weird_zero = bitcast <4 x i32> zeroinitializer to <16 x i8>
  %shuffle.i = shufflevector <16 x i8> <i8 undef, i8 undef, i8 undef, i8 undef, i8 undef, i8 undef, i8 undef, i8 undef, i8 undef, i8 undef, i8 undef, i8 undef, i8 0, i8 0, i8 0, i8 0>, <16 x i8> %weird_zero, <16 x i32> <i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27>
  %weirder_zero = bitcast <16 x i8> %shuffle.i to <4 x i32>
  store <4 x i32> %weirder_zero, <4 x i32>* %ptr1, align 16
  store <4 x i32> zeroinitializer, <4 x i32>* %ptr2, align 16
  ret void
}

;
; Shuffle to logical bit shifts
;

define <16 x i8> @shuffle_v16i8_zz_00_zz_02_zz_04_zz_06_zz_08_zz_10_zz_12_zz_14(<16 x i8> %a, <16 x i8> %b) {
; SSE-LABEL: shuffle_v16i8_zz_00_zz_02_zz_04_zz_06_zz_08_zz_10_zz_12_zz_14:
; SSE:       # BB#0:
; SSE-NEXT:    psllw $8, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_zz_00_zz_02_zz_04_zz_06_zz_08_zz_10_zz_12_zz_14:
; AVX:       # BB#0:
; AVX-NEXT:    vpsllw $8, %xmm0, %xmm0
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> zeroinitializer, <16 x i32><i32 16, i32 0, i32 16, i32 2, i32 16, i32 4, i32 16, i32 6, i32 16, i32 8, i32 16, i32 10, i32 16, i32 12, i32 16, i32 14>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_zz_zz_zz_00_zz_zz_zz_04_zz_zz_zz_08_zz_zz_zz_12(<16 x i8> %a, <16 x i8> %b) {
; SSE-LABEL: shuffle_v16i8_zz_zz_zz_00_zz_zz_zz_04_zz_zz_zz_08_zz_zz_zz_12:
; SSE:       # BB#0:
; SSE-NEXT:    pslld $24, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_zz_zz_zz_00_zz_zz_zz_04_zz_zz_zz_08_zz_zz_zz_12:
; AVX:       # BB#0:
; AVX-NEXT:    vpslld $24, %xmm0, %xmm0
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> zeroinitializer, <16 x i32><i32 16, i32 16, i32 16, i32 0, i32 16, i32 16, i32 16, i32 4, i32 16, i32 16, i32 16, i32 8, i32 16, i32 16, i32 16, i32 12>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_zz_zz_zz_zz_zz_zz_zz_00_zz_zz_zz_zz_zz_zz_zz_08(<16 x i8> %a, <16 x i8> %b) {
; SSE-LABEL: shuffle_v16i8_zz_zz_zz_zz_zz_zz_zz_00_zz_zz_zz_zz_zz_zz_zz_08:
; SSE:       # BB#0:
; SSE-NEXT:    psllq $56, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_zz_zz_zz_zz_zz_zz_zz_00_zz_zz_zz_zz_zz_zz_zz_08:
; AVX:       # BB#0:
; AVX-NEXT:    vpsllq $56, %xmm0, %xmm0
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> zeroinitializer, <16 x i32><i32 16, i32 16, i32 16, i32 16, i32 16, i32 16, i32 16, i32 0, i32 16, i32 16, i32 16, i32 16, i32 16, i32 16, i32 16, i32 8>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_zz_00_uu_02_03_uu_05_06_zz_08_09_uu_11_12_13_14(<16 x i8> %a, <16 x i8> %b) {
; SSE-LABEL: shuffle_v16i8_zz_00_uu_02_03_uu_05_06_zz_08_09_uu_11_12_13_14:
; SSE:       # BB#0:
; SSE-NEXT:    psllq $8, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_zz_00_uu_02_03_uu_05_06_zz_08_09_uu_11_12_13_14:
; AVX:       # BB#0:
; AVX-NEXT:    vpsllq $8, %xmm0, %xmm0
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> zeroinitializer, <16 x i32><i32 16, i32 0, i32 undef, i32 2, i32 3, i32 undef, i32 5, i32 6, i32 16, i32 8, i32 9, i32 undef, i32 11, i32 12, i32 13, i32 14>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_01_uu_uu_uu_uu_zz_uu_zz_uu_zz_11_zz_13_zz_15_zz(<16 x i8> %a, <16 x i8> %b) {
; SSE-LABEL: shuffle_v16i8_01_uu_uu_uu_uu_zz_uu_zz_uu_zz_11_zz_13_zz_15_zz:
; SSE:       # BB#0:
; SSE-NEXT:    psrlw $8, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_01_uu_uu_uu_uu_zz_uu_zz_uu_zz_11_zz_13_zz_15_zz:
; AVX:       # BB#0:
; AVX-NEXT:    vpsrlw $8, %xmm0, %xmm0
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> zeroinitializer, <16 x i32><i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 16, i32 undef, i32 16, i32 undef, i32 16, i32 11, i32 16, i32 13, i32 16, i32 15, i32 16>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_02_03_zz_zz_06_07_uu_uu_uu_uu_uu_uu_14_15_zz_zz(<16 x i8> %a, <16 x i8> %b) {
; SSE-LABEL: shuffle_v16i8_02_03_zz_zz_06_07_uu_uu_uu_uu_uu_uu_14_15_zz_zz:
; SSE:       # BB#0:
; SSE-NEXT:    psrld $16, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_02_03_zz_zz_06_07_uu_uu_uu_uu_uu_uu_14_15_zz_zz:
; AVX:       # BB#0:
; AVX-NEXT:    vpsrld $16, %xmm0, %xmm0
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> zeroinitializer, <16 x i32><i32 2, i32 3, i32 16, i32 16, i32 6, i32 7, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 14, i32 15, i32 16, i32 16>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_07_zz_zz_zz_zz_zz_uu_uu_15_uu_uu_uu_uu_uu_zz_zz(<16 x i8> %a, <16 x i8> %b) {
; SSE-LABEL: shuffle_v16i8_07_zz_zz_zz_zz_zz_uu_uu_15_uu_uu_uu_uu_uu_zz_zz:
; SSE:       # BB#0:
; SSE-NEXT:    psrlq $56, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_07_zz_zz_zz_zz_zz_uu_uu_15_uu_uu_uu_uu_uu_zz_zz:
; AVX:       # BB#0:
; AVX-NEXT:    vpsrlq $56, %xmm0, %xmm0
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> zeroinitializer, <16 x i32><i32 7, i32 16, i32 16, i32 16, i32 16, i32 16, i32 undef, i32 undef, i32 15, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 16, i32 16>
  ret <16 x i8> %shuffle
}

define <16 x i8> @PR12412(<16 x i8> %inval1, <16 x i8> %inval2) {
; SSE2-LABEL: PR12412:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [255,255,255,255,255,255,255,255]
; SSE2-NEXT:    pand %xmm2, %xmm1
; SSE2-NEXT:    pand %xmm2, %xmm0
; SSE2-NEXT:    packuswb %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: PR12412:
; SSSE3:       # BB#0: # %entry
; SSSE3-NEXT:    movdqa {{.*#+}} xmm2 = <0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u>
; SSSE3-NEXT:    pshufb %xmm2, %xmm1
; SSSE3-NEXT:    pshufb %xmm2, %xmm0
; SSSE3-NEXT:    punpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: PR12412:
; SSE41:       # BB#0: # %entry
; SSE41-NEXT:    movdqa {{.*#+}} xmm2 = <0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u>
; SSE41-NEXT:    pshufb %xmm2, %xmm1
; SSE41-NEXT:    pshufb %xmm2, %xmm0
; SSE41-NEXT:    punpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; SSE41-NEXT:    retq
;
; AVX-LABEL: PR12412:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vmovdqa {{.*#+}} xmm2 = <0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u>
; AVX-NEXT:    vpshufb %xmm2, %xmm1, %xmm1
; AVX-NEXT:    vpshufb %xmm2, %xmm0, %xmm0
; AVX-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; AVX-NEXT:    retq
entry:
  %0 = shufflevector <16 x i8> %inval1, <16 x i8> %inval2, <16 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14, i32 16, i32 18, i32 20, i32 22, i32 24, i32 26, i32 28, i32 30>
  ret <16 x i8> %0
}

define <16 x i8> @shuffle_v16i8_uu_02_03_zz_uu_06_07_zz_uu_10_11_zz_uu_14_15_zz(<16 x i8> %a) {
; SSE-LABEL: shuffle_v16i8_uu_02_03_zz_uu_06_07_zz_uu_10_11_zz_uu_14_15_zz:
; SSE:       # BB#0:
; SSE-NEXT:    psrld $8, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_uu_02_03_zz_uu_06_07_zz_uu_10_11_zz_uu_14_15_zz:
; AVX:       # BB#0:
; AVX-NEXT:    vpsrld $8, %xmm0, %xmm0
; AVX-NEXT:    retq
  %shuffle = shufflevector <16 x i8> %a, <16 x i8> zeroinitializer, <16 x i32> <i32 undef, i32 2, i32 3, i32 16, i32 undef, i32 6, i32 7, i32 16, i32 undef, i32 10, i32 11, i32 16, i32 undef, i32 14, i32 15, i32 16>
  ret <16 x i8> %shuffle
}

define <16 x i8> @shuffle_v16i8_bitcast_unpack(<16 x i8> %a, <16 x i8> %b) {
; SSE-LABEL: shuffle_v16i8_bitcast_unpack:
; SSE:       # BB#0:
; SSE-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; SSE-NEXT:    retq
;
; AVX-LABEL: shuffle_v16i8_bitcast_unpack:
; AVX:       # BB#0:
; AVX-NEXT:    vpunpcklbw {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1],xmm0[2],xmm1[2],xmm0[3],xmm1[3],xmm0[4],xmm1[4],xmm0[5],xmm1[5],xmm0[6],xmm1[6],xmm0[7],xmm1[7]
; AVX-NEXT:    retq
  %shuffle8  = shufflevector <16 x i8> %a, <16 x i8> %b, <16 x i32> <i32 7, i32 23, i32 6, i32 22, i32 5, i32 21, i32 4, i32 20, i32 3, i32 19, i32 2, i32 18, i32 1, i32 17, i32 0, i32 16>
  %bitcast32 = bitcast <16 x i8> %shuffle8 to <4 x float>
  %shuffle32 = shufflevector <4 x float> %bitcast32, <4 x float> undef, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
  %bitcast16 = bitcast <4 x float> %shuffle32 to <8 x i16>
  %shuffle16 = shufflevector <8 x i16> %bitcast16, <8 x i16> undef, <8 x i32> <i32 1, i32 0, i32 3, i32 2, i32 5, i32 4, i32 7, i32 6>
  %bitcast8  = bitcast <8 x i16> %shuffle16 to <16 x i8>
  ret <16 x i8> %bitcast8
}

define <16 x i8> @insert_dup_mem_v16i8_i32(i32* %ptr) {
; SSE2-LABEL: insert_dup_mem_v16i8_i32:
; SSE2:       # BB#0:
; SSE2-NEXT:    movd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,1,0,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,0,0,0,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,4,4,4,4]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: insert_dup_mem_v16i8_i32:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    movd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSSE3-NEXT:    pxor %xmm1, %xmm1
; SSSE3-NEXT:    pshufb %xmm1, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: insert_dup_mem_v16i8_i32:
; SSE41:       # BB#0:
; SSE41-NEXT:    movd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSE41-NEXT:    pxor %xmm1, %xmm1
; SSE41-NEXT:    pshufb %xmm1, %xmm0
; SSE41-NEXT:    retq
;
; AVX1-LABEL: insert_dup_mem_v16i8_i32:
; AVX1:       # BB#0:
; AVX1-NEXT:    vmovd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX1-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX1-NEXT:    vpshufb %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: insert_dup_mem_v16i8_i32:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpbroadcastb (%rdi), %xmm0
; AVX2-NEXT:    retq
  %tmp = load i32, i32* %ptr, align 4
  %tmp1 = insertelement <4 x i32> zeroinitializer, i32 %tmp, i32 0
  %tmp2 = bitcast <4 x i32> %tmp1 to <16 x i8>
  %tmp3 = shufflevector <16 x i8> %tmp2, <16 x i8> undef, <16 x i32> zeroinitializer
  ret <16 x i8> %tmp3
}

define <16 x i8> @insert_dup_mem_v16i8_sext_i8(i8* %ptr) {
; SSE2-LABEL: insert_dup_mem_v16i8_sext_i8:
; SSE2:       # BB#0:
; SSE2-NEXT:    movsbl (%rdi), %eax
; SSE2-NEXT:    movd %eax, %xmm0
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,1,0,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,0,0,0,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,4,4,4,4]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: insert_dup_mem_v16i8_sext_i8:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    movsbl (%rdi), %eax
; SSSE3-NEXT:    movd %eax, %xmm0
; SSSE3-NEXT:    pxor %xmm1, %xmm1
; SSSE3-NEXT:    pshufb %xmm1, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: insert_dup_mem_v16i8_sext_i8:
; SSE41:       # BB#0:
; SSE41-NEXT:    movsbl (%rdi), %eax
; SSE41-NEXT:    movd %eax, %xmm0
; SSE41-NEXT:    pxor %xmm1, %xmm1
; SSE41-NEXT:    pshufb %xmm1, %xmm0
; SSE41-NEXT:    retq
;
; AVX1-LABEL: insert_dup_mem_v16i8_sext_i8:
; AVX1:       # BB#0:
; AVX1-NEXT:    movsbl (%rdi), %eax
; AVX1-NEXT:    vmovd %eax, %xmm0
; AVX1-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX1-NEXT:    vpshufb %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: insert_dup_mem_v16i8_sext_i8:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpbroadcastb (%rdi), %xmm0
; AVX2-NEXT:    retq
  %tmp = load i8, i8* %ptr, align 1
  %tmp1 = sext i8 %tmp to i32
  %tmp2 = insertelement <4 x i32> zeroinitializer, i32 %tmp1, i32 0
  %tmp3 = bitcast <4 x i32> %tmp2 to <16 x i8>
  %tmp4 = shufflevector <16 x i8> %tmp3, <16 x i8> undef, <16 x i32> zeroinitializer
  ret <16 x i8> %tmp4
}

define <16 x i8> @insert_dup_elt1_mem_v16i8_i32(i32* %ptr) {
; SSE2-LABEL: insert_dup_elt1_mem_v16i8_i32:
; SSE2:       # BB#0:
; SSE2-NEXT:    movd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,1,0,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[1,1,1,1,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,5,5,5,5]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: insert_dup_elt1_mem_v16i8_i32:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    movd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: insert_dup_elt1_mem_v16i8_i32:
; SSE41:       # BB#0:
; SSE41-NEXT:    movd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSE41-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
; SSE41-NEXT:    retq
;
; AVX1-LABEL: insert_dup_elt1_mem_v16i8_i32:
; AVX1:       # BB#0:
; AVX1-NEXT:    vmovd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX1-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
; AVX1-NEXT:    retq
;
; AVX2-LABEL: insert_dup_elt1_mem_v16i8_i32:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpbroadcastb 1(%rdi), %xmm0
; AVX2-NEXT:    retq
  %tmp = load i32, i32* %ptr, align 4
  %tmp1 = insertelement <4 x i32> zeroinitializer, i32 %tmp, i32 0
  %tmp2 = bitcast <4 x i32> %tmp1 to <16 x i8>
  %tmp3 = shufflevector <16 x i8> %tmp2, <16 x i8> undef, <16 x i32> <i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
  ret <16 x i8> %tmp3
}

define <16 x i8> @insert_dup_elt2_mem_v16i8_i32(i32* %ptr) {
; SSE2-LABEL: insert_dup_elt2_mem_v16i8_i32:
; SSE2:       # BB#0:
; SSE2-NEXT:    movd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,1,2,1]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[2,2,2,2,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,6,6,6,6]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: insert_dup_elt2_mem_v16i8_i32:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    movd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: insert_dup_elt2_mem_v16i8_i32:
; SSE41:       # BB#0:
; SSE41-NEXT:    movd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; SSE41-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2]
; SSE41-NEXT:    retq
;
; AVX1-LABEL: insert_dup_elt2_mem_v16i8_i32:
; AVX1:       # BB#0:
; AVX1-NEXT:    vmovd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX1-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2]
; AVX1-NEXT:    retq
;
; AVX2-LABEL: insert_dup_elt2_mem_v16i8_i32:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpbroadcastb 2(%rdi), %xmm0
; AVX2-NEXT:    retq
  %tmp = load i32, i32* %ptr, align 4
  %tmp1 = insertelement <4 x i32> zeroinitializer, i32 %tmp, i32 0
  %tmp2 = bitcast <4 x i32> %tmp1 to <16 x i8>
  %tmp3 = shufflevector <16 x i8> %tmp2, <16 x i8> undef, <16 x i32> <i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2>
  ret <16 x i8> %tmp3
}

define <16 x i8> @insert_dup_elt1_mem_v16i8_sext_i8(i8* %ptr) {
; SSE2-LABEL: insert_dup_elt1_mem_v16i8_sext_i8:
; SSE2:       # BB#0:
; SSE2-NEXT:    movsbl (%rdi), %eax
; SSE2-NEXT:    movd %eax, %xmm0
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,1,0,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[1,1,1,1,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,5,5,5,5]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: insert_dup_elt1_mem_v16i8_sext_i8:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    movsbl (%rdi), %eax
; SSSE3-NEXT:    movd %eax, %xmm0
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: insert_dup_elt1_mem_v16i8_sext_i8:
; SSE41:       # BB#0:
; SSE41-NEXT:    movsbl (%rdi), %eax
; SSE41-NEXT:    movd %eax, %xmm0
; SSE41-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
; SSE41-NEXT:    retq
;
; AVX1-LABEL: insert_dup_elt1_mem_v16i8_sext_i8:
; AVX1:       # BB#0:
; AVX1-NEXT:    movsbl (%rdi), %eax
; AVX1-NEXT:    vmovd %eax, %xmm0
; AVX1-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
; AVX1-NEXT:    retq
;
; AVX2-LABEL: insert_dup_elt1_mem_v16i8_sext_i8:
; AVX2:       # BB#0:
; AVX2-NEXT:    movsbl (%rdi), %eax
; AVX2-NEXT:    shrl $8, %eax
; AVX2-NEXT:    vmovd %eax, %xmm0
; AVX2-NEXT:    vpbroadcastb %xmm0, %xmm0
; AVX2-NEXT:    retq
  %tmp = load i8, i8* %ptr, align 1
  %tmp1 = sext i8 %tmp to i32
  %tmp2 = insertelement <4 x i32> zeroinitializer, i32 %tmp1, i32 0
  %tmp3 = bitcast <4 x i32> %tmp2 to <16 x i8>
  %tmp4 = shufflevector <16 x i8> %tmp3, <16 x i8> undef, <16 x i32> <i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
  ret <16 x i8> %tmp4
}

define <16 x i8> @insert_dup_elt2_mem_v16i8_sext_i8(i8* %ptr) {
; SSE2-LABEL: insert_dup_elt2_mem_v16i8_sext_i8:
; SSE2:       # BB#0:
; SSE2-NEXT:    movsbl (%rdi), %eax
; SSE2-NEXT:    movd %eax, %xmm0
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,1,2,1]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[2,2,2,2,4,5,6,7]
; SSE2-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,6,6,6,6]
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: insert_dup_elt2_mem_v16i8_sext_i8:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    movsbl (%rdi), %eax
; SSSE3-NEXT:    movd %eax, %xmm0
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: insert_dup_elt2_mem_v16i8_sext_i8:
; SSE41:       # BB#0:
; SSE41-NEXT:    movsbl (%rdi), %eax
; SSE41-NEXT:    movd %eax, %xmm0
; SSE41-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2]
; SSE41-NEXT:    retq
;
; AVX1-LABEL: insert_dup_elt2_mem_v16i8_sext_i8:
; AVX1:       # BB#0:
; AVX1-NEXT:    movsbl (%rdi), %eax
; AVX1-NEXT:    vmovd %eax, %xmm0
; AVX1-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2]
; AVX1-NEXT:    retq
;
; AVX2-LABEL: insert_dup_elt2_mem_v16i8_sext_i8:
; AVX2:       # BB#0:
; AVX2-NEXT:    movsbl (%rdi), %eax
; AVX2-NEXT:    shrl $16, %eax
; AVX2-NEXT:    vmovd %eax, %xmm0
; AVX2-NEXT:    vpbroadcastb %xmm0, %xmm0
; AVX2-NEXT:    retq
  %tmp = load i8, i8* %ptr, align 1
  %tmp1 = sext i8 %tmp to i32
  %tmp2 = insertelement <4 x i32> zeroinitializer, i32 %tmp1, i32 0
  %tmp3 = bitcast <4 x i32> %tmp2 to <16 x i8>
  %tmp4 = shufflevector <16 x i8> %tmp3, <16 x i8> undef, <16 x i32> <i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2>
  ret <16 x i8> %tmp4
}
