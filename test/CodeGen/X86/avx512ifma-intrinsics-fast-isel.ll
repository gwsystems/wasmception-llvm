; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -fast-isel -mtriple=i386-unknown-unknown -mattr=+avx512ifma | FileCheck %s --check-prefix=ALL --check-prefix=X32
; RUN: llc < %s -fast-isel -mtriple=x86_64-unknown-unknown -mattr=+avx512ifma | FileCheck %s --check-prefix=ALL --check-prefix=X64

; NOTE: This should use IR equivalent to what is generated by clang/test/CodeGen/avx512ifma-builtins.c

define <8 x i64> @test_mm512_madd52hi_epu64(<8 x i64> %__X, <8 x i64> %__Y, <8 x i64> %__Z) {
; X32-LABEL: test_mm512_madd52hi_epu64:
; X32:       # %bb.0: # %entry
; X32-NEXT:    vpmadd52huq %zmm2, %zmm1, %zmm0
; X32-NEXT:    retl
;
; X64-LABEL: test_mm512_madd52hi_epu64:
; X64:       # %bb.0: # %entry
; X64-NEXT:    vpmadd52huq %zmm2, %zmm1, %zmm0
; X64-NEXT:    retq
entry:
  %0 = tail call <8 x i64> @llvm.x86.avx512.vpmadd52h.uq.512(<8 x i64> %__X, <8 x i64> %__Y, <8 x i64> %__Z)
  ret <8 x i64> %0
}

define <8 x i64> @test_mm512_mask_madd52hi_epu64(<8 x i64> %__W, i8 zeroext %__M, <8 x i64> %__X, <8 x i64> %__Y) {
; X32-LABEL: test_mm512_mask_madd52hi_epu64:
; X32:       # %bb.0: # %entry
; X32-NEXT:    movb {{[0-9]+}}(%esp), %al
; X32-NEXT:    kmovw %eax, %k1
; X32-NEXT:    vpmadd52huq %zmm2, %zmm1, %zmm0 {%k1}
; X32-NEXT:    retl
;
; X64-LABEL: test_mm512_mask_madd52hi_epu64:
; X64:       # %bb.0: # %entry
; X64-NEXT:    kmovw %edi, %k1
; X64-NEXT:    vpmadd52huq %zmm2, %zmm1, %zmm0 {%k1}
; X64-NEXT:    retq
entry:
  %0 = tail call <8 x i64> @llvm.x86.avx512.vpmadd52h.uq.512(<8 x i64> %__W, <8 x i64> %__X, <8 x i64> %__Y)
  %1 = bitcast i8 %__M to <8 x i1>
  %2 = select <8 x i1> %1, <8 x i64> %0, <8 x i64> %__W
  ret <8 x i64> %2
}

define <8 x i64> @test_mm512_maskz_madd52hi_epu64(i8 zeroext %__M, <8 x i64> %__X, <8 x i64> %__Y, <8 x i64> %__Z) {
; X32-LABEL: test_mm512_maskz_madd52hi_epu64:
; X32:       # %bb.0: # %entry
; X32-NEXT:    movb {{[0-9]+}}(%esp), %al
; X32-NEXT:    kmovw %eax, %k1
; X32-NEXT:    vpmadd52huq %zmm2, %zmm1, %zmm0 {%k1} {z}
; X32-NEXT:    retl
;
; X64-LABEL: test_mm512_maskz_madd52hi_epu64:
; X64:       # %bb.0: # %entry
; X64-NEXT:    kmovw %edi, %k1
; X64-NEXT:    vpmadd52huq %zmm2, %zmm1, %zmm0 {%k1} {z}
; X64-NEXT:    retq
entry:
  %0 = tail call <8 x i64> @llvm.x86.avx512.vpmadd52h.uq.512(<8 x i64> %__X, <8 x i64> %__Y, <8 x i64> %__Z)
  %1 = bitcast i8 %__M to <8 x i1>
  %2 = select <8 x i1> %1, <8 x i64> %0, <8 x i64> zeroinitializer
  ret <8 x i64> %2
}

define <8 x i64> @test_mm512_madd52lo_epu64(<8 x i64> %__X, <8 x i64> %__Y, <8 x i64> %__Z) {
; X32-LABEL: test_mm512_madd52lo_epu64:
; X32:       # %bb.0: # %entry
; X32-NEXT:    vpmadd52luq %zmm2, %zmm1, %zmm0
; X32-NEXT:    retl
;
; X64-LABEL: test_mm512_madd52lo_epu64:
; X64:       # %bb.0: # %entry
; X64-NEXT:    vpmadd52luq %zmm2, %zmm1, %zmm0
; X64-NEXT:    retq
entry:
  %0 = tail call <8 x i64> @llvm.x86.avx512.vpmadd52l.uq.512(<8 x i64> %__X, <8 x i64> %__Y, <8 x i64> %__Z)
  ret <8 x i64> %0
}

define <8 x i64> @test_mm512_mask_madd52lo_epu64(<8 x i64> %__W, i8 zeroext %__M, <8 x i64> %__X, <8 x i64> %__Y) {
; X32-LABEL: test_mm512_mask_madd52lo_epu64:
; X32:       # %bb.0: # %entry
; X32-NEXT:    movb {{[0-9]+}}(%esp), %al
; X32-NEXT:    kmovw %eax, %k1
; X32-NEXT:    vpmadd52luq %zmm2, %zmm1, %zmm0 {%k1}
; X32-NEXT:    retl
;
; X64-LABEL: test_mm512_mask_madd52lo_epu64:
; X64:       # %bb.0: # %entry
; X64-NEXT:    kmovw %edi, %k1
; X64-NEXT:    vpmadd52luq %zmm2, %zmm1, %zmm0 {%k1}
; X64-NEXT:    retq
entry:
  %0 = tail call <8 x i64> @llvm.x86.avx512.vpmadd52l.uq.512(<8 x i64> %__W, <8 x i64> %__X, <8 x i64> %__Y)
  %1 = bitcast i8 %__M to <8 x i1>
  %2 = select <8 x i1> %1, <8 x i64> %0, <8 x i64> %__W
  ret <8 x i64> %2
}

define <8 x i64> @test_mm512_maskz_madd52lo_epu64(i8 zeroext %__M, <8 x i64> %__X, <8 x i64> %__Y, <8 x i64> %__Z) {
; X32-LABEL: test_mm512_maskz_madd52lo_epu64:
; X32:       # %bb.0: # %entry
; X32-NEXT:    movb {{[0-9]+}}(%esp), %al
; X32-NEXT:    kmovw %eax, %k1
; X32-NEXT:    vpmadd52luq %zmm2, %zmm1, %zmm0 {%k1} {z}
; X32-NEXT:    retl
;
; X64-LABEL: test_mm512_maskz_madd52lo_epu64:
; X64:       # %bb.0: # %entry
; X64-NEXT:    kmovw %edi, %k1
; X64-NEXT:    vpmadd52luq %zmm2, %zmm1, %zmm0 {%k1} {z}
; X64-NEXT:    retq
entry:
  %0 = tail call <8 x i64> @llvm.x86.avx512.vpmadd52l.uq.512(<8 x i64> %__X, <8 x i64> %__Y, <8 x i64> %__Z)
  %1 = bitcast i8 %__M to <8 x i1>
  %2 = select <8 x i1> %1, <8 x i64> %0, <8 x i64> zeroinitializer
  ret <8 x i64> %2
}

declare <8 x i64> @llvm.x86.avx512.vpmadd52h.uq.512(<8 x i64>, <8 x i64>, <8 x i64>)
declare <8 x i64> @llvm.x86.avx512.vpmadd52l.uq.512(<8 x i64>, <8 x i64>, <8 x i64>)
