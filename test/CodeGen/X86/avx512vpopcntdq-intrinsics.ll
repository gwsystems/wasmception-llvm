; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512vpopcntdq --show-mc-encoding | FileCheck %s --check-prefix=X86_64
; RUN: llc < %s -mtriple=i686-unknown-unknown -mattr=+avx512vpopcntdq --show-mc-encoding | FileCheck %s --check-prefix=X86

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The following tests check that patterns that includes      ;;
;; ctpop intrinsic + select are translated to the vpopcntd/q  ;;
;; instruction in a correct way.                              ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define <16 x i32> @test_mask_vpopcnt_d(<16 x i32> %a, i16 %mask, <16 x i32> %b) {
; X86_64-LABEL: test_mask_vpopcnt_d:
; X86_64:       # BB#0:
; X86_64-NEXT:    kmovw %edi, %k1 # encoding: [0xc5,0xf8,0x92,0xcf]
; X86_64-NEXT:    vpopcntd %zmm1, %zmm0 {%k1} # encoding: [0x62,0xf2,0x7d,0x49,0x55,0xc1]
; X86_64-NEXT:    retq # encoding: [0xc3]
;
; X86-LABEL: test_mask_vpopcnt_d:
; X86:       # BB#0:
; X86-NEXT:    kmovw {{[0-9]+}}(%esp), %k1 # encoding: [0xc5,0xf8,0x90,0x4c,0x24,0x04]
; X86-NEXT:    vpopcntd %zmm1, %zmm0 {%k1} # encoding: [0x62,0xf2,0x7d,0x49,0x55,0xc1]
; X86-NEXT:    retl # encoding: [0xc3]
  %1 = tail call <16 x i32> @llvm.ctpop.v16i32(<16 x i32> %b)
  %2 = bitcast i16 %mask to <16 x i1>
  %3 = select <16 x i1> %2, <16 x i32> %1, <16 x i32> %a
  ret <16 x i32> %3
}

define <16 x i32> @test_maskz_vpopcnt_d(i16 %mask, <16 x i32> %a) {
; X86_64-LABEL: test_maskz_vpopcnt_d:
; X86_64:       # BB#0:
; X86_64-NEXT:    kmovw %edi, %k1 # encoding: [0xc5,0xf8,0x92,0xcf]
; X86_64-NEXT:    vpopcntd %zmm0, %zmm0 {%k1} {z} # encoding: [0x62,0xf2,0x7d,0xc9,0x55,0xc0]
; X86_64-NEXT:    retq # encoding: [0xc3]
;
; X86-LABEL: test_maskz_vpopcnt_d:
; X86:       # BB#0:
; X86-NEXT:    kmovw {{[0-9]+}}(%esp), %k1 # encoding: [0xc5,0xf8,0x90,0x4c,0x24,0x04]
; X86-NEXT:    vpopcntd %zmm0, %zmm0 {%k1} {z} # encoding: [0x62,0xf2,0x7d,0xc9,0x55,0xc0]
; X86-NEXT:    retl # encoding: [0xc3]
  %1 = tail call <16 x i32> @llvm.ctpop.v16i32(<16 x i32> %a)
  %2 = bitcast i16 %mask to <16 x i1>
  %3 = select <16 x i1> %2, <16 x i32> %1, <16 x i32> zeroinitializer
  ret <16 x i32> %3
}

define <8 x i64> @test_mask_vpopcnt_q(<8 x i64> %a, <8 x i64> %b, i8 %mask) {
; X86_64-LABEL: test_mask_vpopcnt_q:
; X86_64:       # BB#0:
; X86_64-NEXT:    kmovw %edi, %k1 # encoding: [0xc5,0xf8,0x92,0xcf]
; X86_64-NEXT:    vpopcntq %zmm0, %zmm1 {%k1} # encoding: [0x62,0xf2,0xfd,0x49,0x55,0xc8]
; X86_64-NEXT:    vmovdqa64 %zmm1, %zmm0 # encoding: [0x62,0xf1,0xfd,0x48,0x6f,0xc1]
; X86_64-NEXT:    retq # encoding: [0xc3]
;
; X86-LABEL: test_mask_vpopcnt_q:
; X86:       # BB#0:
; X86-NEXT:    movzbl {{[0-9]+}}(%esp), %eax # encoding: [0x0f,0xb6,0x44,0x24,0x04]
; X86-NEXT:    kmovw %eax, %k1 # encoding: [0xc5,0xf8,0x92,0xc8]
; X86-NEXT:    vpopcntq %zmm0, %zmm1 {%k1} # encoding: [0x62,0xf2,0xfd,0x49,0x55,0xc8]
; X86-NEXT:    vmovdqa64 %zmm1, %zmm0 # encoding: [0x62,0xf1,0xfd,0x48,0x6f,0xc1]
; X86-NEXT:    retl # encoding: [0xc3]
  %1 = tail call <8 x i64> @llvm.ctpop.v8i64(<8 x i64> %a)
  %2 = bitcast i8 %mask to <8 x i1>
  %3 = select <8 x i1> %2, <8 x i64> %1, <8 x i64> %b
  ret <8 x i64> %3
}

define <8 x i64> @test_maskz_vpopcnt_q(<8 x i64> %a, i8 %mask) {
; X86_64-LABEL: test_maskz_vpopcnt_q:
; X86_64:       # BB#0:
; X86_64-NEXT:    kmovw %edi, %k1 # encoding: [0xc5,0xf8,0x92,0xcf]
; X86_64-NEXT:    vpopcntq %zmm0, %zmm0 {%k1} {z} # encoding: [0x62,0xf2,0xfd,0xc9,0x55,0xc0]
; X86_64-NEXT:    retq # encoding: [0xc3]
;
; X86-LABEL: test_maskz_vpopcnt_q:
; X86:       # BB#0:
; X86-NEXT:    movzbl {{[0-9]+}}(%esp), %eax # encoding: [0x0f,0xb6,0x44,0x24,0x04]
; X86-NEXT:    kmovw %eax, %k1 # encoding: [0xc5,0xf8,0x92,0xc8]
; X86-NEXT:    vpopcntq %zmm0, %zmm0 {%k1} {z} # encoding: [0x62,0xf2,0xfd,0xc9,0x55,0xc0]
; X86-NEXT:    retl # encoding: [0xc3]
  %1 = tail call <8 x i64> @llvm.ctpop.v8i64(<8 x i64> %a)
  %2 = bitcast i8 %mask to <8 x i1>
  %3 = select <8 x i1> %2, <8 x i64> %1, <8 x i64> zeroinitializer
  ret <8 x i64> %3
}

declare <16 x i32> @llvm.ctpop.v16i32(<16 x i32>)
declare <8 x i64> @llvm.ctpop.v8i64(<8 x i64>)
