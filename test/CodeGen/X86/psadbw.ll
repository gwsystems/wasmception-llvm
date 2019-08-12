; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-unknown -mattr=+sse2 | FileCheck %s --check-prefixes=CHECK,X86
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse2 | FileCheck %s --check-prefixes=CHECK,X64

; Only bottom 16 bits are set - upper 48 bits are zero.
define <2 x i64> @combine_psadbw_shift(<16 x i8> %0, <16 x i8> %1) {
; CHECK-LABEL: combine_psadbw_shift:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xorps %xmm0, %xmm0
; CHECK-NEXT:    ret{{[l|q]}}
  %3 = tail call <2 x i64> @llvm.x86.sse2.psad.bw(<16 x i8> %0, <16 x i8> %1)
  %4 = lshr <2 x i64> %3, <i64 48, i64 48>
  ret <2 x i64> %4
}

declare <2 x i64> @llvm.x86.sse2.psad.bw(<16 x i8>, <16 x i8>)

