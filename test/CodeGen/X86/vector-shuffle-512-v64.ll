; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mcpu=x86-64 -mattr=+avx512f | FileCheck %s --check-prefix=ALL --check-prefix=AVX512 --check-prefix=AVX512F
; RUN: llc < %s -mcpu=x86-64 -mattr=+avx512bw | FileCheck %s --check-prefix=ALL --check-prefix=AVX512 --check-prefix=AVX512BW
; RUN: llc < %s -mcpu=x86-64 -mattr=+avx512dq | FileCheck %s --check-prefix=ALL --check-prefix=AVX512 --check-prefix=AVX512DQ

target triple = "x86_64-unknown-unknown"

define <64 x i8> @shuffle_v64i8_02_03_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u(<64 x i8> %a)  {
; AVX512F-LABEL: shuffle_v64i8_02_03_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vpsrld $16, %xmm0, %xmm0
; AVX512F-NEXT:    retq
;
; AVX512BW-LABEL: shuffle_v64i8_02_03_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u:
; AVX512BW:       # BB#0:
; AVX512BW-NEXT:    vpsrld $16, %zmm0, %zmm0
; AVX512BW-NEXT:    retq
;
; AVX512DQ-LABEL: shuffle_v64i8_02_03_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u_u:
; AVX512DQ:       # BB#0:
; AVX512DQ-NEXT:    vpsrld $16, %xmm0, %xmm0
; AVX512DQ-NEXT:    retq
  %b = shufflevector <64 x i8> %a, <64 x i8> undef, <64 x i32> <i32 2, i32 3, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  ret <64 x i8> %b
}

define <64 x i8> @shuffle_v64i8_zz_00_01_02_03_04_05_06_07_08_09_10_11_12_13_14_zz_16_17_18_19_20_21_22_23_24_25_26_27_28_29_30_zz_32_33_34_35_36_37_38_39_40_41_42_43_44_45_46_zz_48_49_50_51_52_53_54_55_56_57_58_59_60_61_62(<64 x i8> %a, <64 x i8> %b) {
; AVX512F-LABEL: shuffle_v64i8_zz_00_01_02_03_04_05_06_07_08_09_10_11_12_13_14_zz_16_17_18_19_20_21_22_23_24_25_26_27_28_29_30_zz_32_33_34_35_36_37_38_39_40_41_42_43_44_45_46_zz_48_49_50_51_52_53_54_55_56_57_58_59_60_61_62:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vpslldq {{.*#+}} ymm0 = zero,ymm0[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14],zero,ymm0[16,17,18,19,20,21,22,23,24,25,26,27,28,29,30]
; AVX512F-NEXT:    vpslldq {{.*#+}} ymm1 = zero,ymm1[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14],zero,ymm1[16,17,18,19,20,21,22,23,24,25,26,27,28,29,30]
; AVX512F-NEXT:    retq
;
; AVX512BW-LABEL: shuffle_v64i8_zz_00_01_02_03_04_05_06_07_08_09_10_11_12_13_14_zz_16_17_18_19_20_21_22_23_24_25_26_27_28_29_30_zz_32_33_34_35_36_37_38_39_40_41_42_43_44_45_46_zz_48_49_50_51_52_53_54_55_56_57_58_59_60_61_62:
; AVX512BW:       # BB#0:
; AVX512BW-NEXT:    vpslldq {{.*#+}} zmm0 = zero,zmm0[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14],zero,zmm0[16,17,18,19,20,21,22,23,24,25,26,27,28,29,30],zero,zmm0[32,33,34,35,36,37,38,39,40,41,42,43,44,45,46],zero,zmm0[48,49,50,51,52,53,54,55,56,57,58,59,60,61,62]
; AVX512BW-NEXT:    retq
;
; AVX512DQ-LABEL: shuffle_v64i8_zz_00_01_02_03_04_05_06_07_08_09_10_11_12_13_14_zz_16_17_18_19_20_21_22_23_24_25_26_27_28_29_30_zz_32_33_34_35_36_37_38_39_40_41_42_43_44_45_46_zz_48_49_50_51_52_53_54_55_56_57_58_59_60_61_62:
; AVX512DQ:       # BB#0:
; AVX512DQ-NEXT:    vpslldq {{.*#+}} ymm0 = zero,ymm0[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14],zero,ymm0[16,17,18,19,20,21,22,23,24,25,26,27,28,29,30]
; AVX512DQ-NEXT:    vpslldq {{.*#+}} ymm1 = zero,ymm1[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14],zero,ymm1[16,17,18,19,20,21,22,23,24,25,26,27,28,29,30]
; AVX512DQ-NEXT:    retq
  %shuffle = shufflevector <64 x i8> %a, <64 x i8> zeroinitializer, <64 x i32> <i32 79, i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 95, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 111, i32 32, i32 33, i32 34, i32 35, i32 36, i32 37, i32 38, i32 39, i32 40, i32 41, i32 42, i32 43, i32 44, i32 45, i32 46, i32 127, i32 48, i32 49, i32 50, i32 51, i32 52, i32 53, i32 54, i32 55, i32 56, i32 57, i32 58, i32 59, i32 60, i32 61, i32 62>
  ret <64 x i8> %shuffle
}

define <64 x i8> @shuffle_v64i8_02_03_04_05_06_07_08_09_10_11_12_13_14_15_zz_zz_18_19_20_21_22_23_24_25_26_27_28_29_30_31_zz_zz_34_35_36_37_38_39_40_41_42_43_44_45_46_47_zz_zz_50_51_52_53_54_55_56_57_58_59_60_61_62_63_zz_zz(<64 x i8> %a, <64 x i8> %b) {
; AVX512F-LABEL: shuffle_v64i8_02_03_04_05_06_07_08_09_10_11_12_13_14_15_zz_zz_18_19_20_21_22_23_24_25_26_27_28_29_30_31_zz_zz_34_35_36_37_38_39_40_41_42_43_44_45_46_47_zz_zz_50_51_52_53_54_55_56_57_58_59_60_61_62_63_zz_zz:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vpsrldq {{.*#+}} ymm0 = ymm0[2,3,4,5,6,7,8,9,10,11,12,13,14,15],zero,zero,ymm0[18,19,20,21,22,23,24,25,26,27,28,29,30,31],zero,zero
; AVX512F-NEXT:    vpsrldq {{.*#+}} ymm1 = ymm1[2,3,4,5,6,7,8,9,10,11,12,13,14,15],zero,zero,ymm1[18,19,20,21,22,23,24,25,26,27,28,29,30,31],zero,zero
; AVX512F-NEXT:    retq
;
; AVX512BW-LABEL: shuffle_v64i8_02_03_04_05_06_07_08_09_10_11_12_13_14_15_zz_zz_18_19_20_21_22_23_24_25_26_27_28_29_30_31_zz_zz_34_35_36_37_38_39_40_41_42_43_44_45_46_47_zz_zz_50_51_52_53_54_55_56_57_58_59_60_61_62_63_zz_zz:
; AVX512BW:       # BB#0:
; AVX512BW-NEXT:    vpsrldq {{.*#+}} zmm0 = zmm0[2,3,4,5,6,7,8,9,10,11,12,13,14,15],zero,zero,zmm0[18,19,20,21,22,23,24,25,26,27,28,29,30,31],zero,zero,zmm0[34,35,36,37,38,39,40,41,42,43,44,45,46,47],zero,zero,zmm0[50,51,52,53,54,55,56,57,58,59,60,61,62,63],zero,zero
; AVX512BW-NEXT:    retq
;
; AVX512DQ-LABEL: shuffle_v64i8_02_03_04_05_06_07_08_09_10_11_12_13_14_15_zz_zz_18_19_20_21_22_23_24_25_26_27_28_29_30_31_zz_zz_34_35_36_37_38_39_40_41_42_43_44_45_46_47_zz_zz_50_51_52_53_54_55_56_57_58_59_60_61_62_63_zz_zz:
; AVX512DQ:       # BB#0:
; AVX512DQ-NEXT:    vpsrldq {{.*#+}} ymm0 = ymm0[2,3,4,5,6,7,8,9,10,11,12,13,14,15],zero,zero,ymm0[18,19,20,21,22,23,24,25,26,27,28,29,30,31],zero,zero
; AVX512DQ-NEXT:    vpsrldq {{.*#+}} ymm1 = ymm1[2,3,4,5,6,7,8,9,10,11,12,13,14,15],zero,zero,ymm1[18,19,20,21,22,23,24,25,26,27,28,29,30,31],zero,zero
; AVX512DQ-NEXT:    retq
  %shuffle = shufflevector <64 x i8> %a, <64 x i8> zeroinitializer, <64 x i32> <i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 64, i32 64, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31, i32 64, i32 64, i32 34, i32 35, i32 36, i32 37, i32 38, i32 39, i32 40, i32 41, i32 42, i32 43, i32 44, i32 45, i32 46, i32 47, i32 64, i32 64, i32 50, i32 51, i32 52, i32 53, i32 54, i32 55, i32 56, i32 57, i32 58, i32 59, i32 60, i32 61, i32 62, i32 63, i32 64, i32 64>
  ret <64 x i8> %shuffle
}

define <64 x i8> @shuffle_v64i8_79_00_01_02_03_04_05_06_07_08_09_10_11_12_13_14_95_16_17_18_19_20_21_22_23_24_25_26_27_28_29_30_111_32_33_34_35_36_37_38_39_40_41_42_43_44_45_46_127_48_49_50_51_52_53_54_55_56_57_58_59_60_61_62(<64 x i8> %a, <64 x i8> %b) {
; AVX512F-LABEL: shuffle_v64i8_79_00_01_02_03_04_05_06_07_08_09_10_11_12_13_14_95_16_17_18_19_20_21_22_23_24_25_26_27_28_29_30_111_32_33_34_35_36_37_38_39_40_41_42_43_44_45_46_127_48_49_50_51_52_53_54_55_56_57_58_59_60_61_62:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vpalignr {{.*#+}} ymm0 = ymm2[15],ymm0[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14],ymm2[31],ymm0[16,17,18,19,20,21,22,23,24,25,26,27,28,29,30]
; AVX512F-NEXT:    vpalignr {{.*#+}} ymm1 = ymm3[15],ymm1[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14],ymm3[31],ymm1[16,17,18,19,20,21,22,23,24,25,26,27,28,29,30]
; AVX512F-NEXT:    retq
;
; AVX512BW-LABEL: shuffle_v64i8_79_00_01_02_03_04_05_06_07_08_09_10_11_12_13_14_95_16_17_18_19_20_21_22_23_24_25_26_27_28_29_30_111_32_33_34_35_36_37_38_39_40_41_42_43_44_45_46_127_48_49_50_51_52_53_54_55_56_57_58_59_60_61_62:
; AVX512BW:       # BB#0:
; AVX512BW-NEXT:    vpalignr {{.*#+}} zmm0 = zmm1[15],zmm0[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14],zmm1[31],zmm0[16,17,18,19,20,21,22,23,24,25,26,27,28,29,30],zmm1[47],zmm0[32,33,34,35,36,37,38,39,40,41,42,43,44,45,46],zmm1[63],zmm0[48,49,50,51,52,53,54,55,56,57,58,59,60,61,62]
; AVX512BW-NEXT:    retq
;
; AVX512DQ-LABEL: shuffle_v64i8_79_00_01_02_03_04_05_06_07_08_09_10_11_12_13_14_95_16_17_18_19_20_21_22_23_24_25_26_27_28_29_30_111_32_33_34_35_36_37_38_39_40_41_42_43_44_45_46_127_48_49_50_51_52_53_54_55_56_57_58_59_60_61_62:
; AVX512DQ:       # BB#0:
; AVX512DQ-NEXT:    vpalignr {{.*#+}} ymm0 = ymm2[15],ymm0[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14],ymm2[31],ymm0[16,17,18,19,20,21,22,23,24,25,26,27,28,29,30]
; AVX512DQ-NEXT:    vpalignr {{.*#+}} ymm1 = ymm3[15],ymm1[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14],ymm3[31],ymm1[16,17,18,19,20,21,22,23,24,25,26,27,28,29,30]
; AVX512DQ-NEXT:    retq
  %shuffle = shufflevector <64 x i8> %a, <64 x i8> %b, <64 x i32> <i32 79, i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 95, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 111, i32 32, i32 33, i32 34, i32 35, i32 36, i32 37, i32 38, i32 39, i32 40, i32 41, i32 42, i32 43, i32 44, i32 45, i32 46, i32 127, i32 48, i32 49, i32 50, i32 51, i32 52, i32 53, i32 54, i32 55, i32 56, i32 57, i32 58, i32 59, i32 60, i32 61, i32 62>
  ret <64 x i8> %shuffle
}


define <64 x i8> @shuffle_v64i8_0zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz(<64 x i8> %a) {
; AVX512F-LABEL: shuffle_v64i8_0zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    movl $255, %eax
; AVX512F-NEXT:    vmovd %eax, %xmm1
; AVX512F-NEXT:    vxorps %xmm2, %xmm2, %xmm2
; AVX512F-NEXT:    vmovss {{.*#+}} xmm1 = xmm1[0],xmm2[1,2,3]
; AVX512F-NEXT:    vandps %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    vxorps %ymm1, %ymm1, %ymm1
; AVX512F-NEXT:    retq
;
; AVX512BW-LABEL: shuffle_v64i8_0zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz:
; AVX512BW:       # BB#0:
; AVX512BW-NEXT:    movl $255, %eax
; AVX512BW-NEXT:    vmovd %eax, %xmm1
; AVX512BW-NEXT:    vxorps %xmm2, %xmm2, %xmm2
; AVX512BW-NEXT:    vmovss {{.*#+}} xmm1 = xmm1[0],xmm2[1,2,3]
; AVX512BW-NEXT:    vandps %ymm1, %ymm0, %ymm0
; AVX512BW-NEXT:    vxorps %ymm1, %ymm1, %ymm1
; AVX512BW-NEXT:    vinserti64x4 $1, %ymm1, %zmm0, %zmm0
; AVX512BW-NEXT:    retq
;
; AVX512DQ-LABEL: shuffle_v64i8_0zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz:
; AVX512DQ:       # BB#0:
; AVX512DQ-NEXT:    movl $255, %eax
; AVX512DQ-NEXT:    vmovd %eax, %xmm1
; AVX512DQ-NEXT:    vxorps %xmm2, %xmm2, %xmm2
; AVX512DQ-NEXT:    vmovss {{.*#+}} xmm1 = xmm1[0],xmm2[1,2,3]
; AVX512DQ-NEXT:    vandps %ymm1, %ymm0, %ymm0
; AVX512DQ-NEXT:    vxorps %ymm1, %ymm1, %ymm1
; AVX512DQ-NEXT:    retq
  %shuffle = shufflevector <64 x i8> %a, <64 x i8> zeroinitializer, <64 x i32> <i32 0, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64>
  ret <64 x i8> %shuffle
}
