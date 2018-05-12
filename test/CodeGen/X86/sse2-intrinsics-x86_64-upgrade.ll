; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -disable-peephole -mtriple=x86_64-apple-darwin -mattr=-avx,+sse2 -show-mc-encoding | FileCheck %s --check-prefix=SSE
; RUN: llc < %s -disable-peephole -mtriple=x86_64-apple-darwin -mattr=+avx2 -show-mc-encoding | FileCheck %s --check-prefix=VCHECK --check-prefix=AVX2
; RUN: llc < %s -disable-peephole -mtriple=x86_64-apple-darwin -mcpu=skx -show-mc-encoding | FileCheck %s --check-prefix=VCHECK --check-prefix=SKX

define <2 x double> @test_x86_sse2_cvtsi642sd(<2 x double> %a0, i64 %a1) {
; CHECK-LABEL: test_x86_sse2_cvtsi642sd:
; CHECK:       ## %bb.0:
; CHECK-NEXT:    vcvtsi2sdq %rdi, %xmm0, %xmm0
; CHECK-NEXT:    retq
; SSE-LABEL: test_x86_sse2_cvtsi642sd:
; SSE:       ## %bb.0:
; SSE-NEXT:    cvtsi2sdq %rdi, %xmm0 ## encoding: [0xf2,0x48,0x0f,0x2a,0xc7]
; SSE-NEXT:    retq ## encoding: [0xc3]
;
; AVX2-LABEL: test_x86_sse2_cvtsi642sd:
; AVX2:       ## %bb.0:
; AVX2-NEXT:    vcvtsi2sdq %rdi, %xmm0, %xmm0 ## encoding: [0xc4,0xe1,0xfb,0x2a,0xc7]
; AVX2-NEXT:    retq ## encoding: [0xc3]
;
; SKX-LABEL: test_x86_sse2_cvtsi642sd:
; SKX:       ## %bb.0:
; SKX-NEXT:    vcvtsi2sdq %rdi, %xmm0, %xmm0 ## EVEX TO VEX Compression encoding: [0xc4,0xe1,0xfb,0x2a,0xc7]
; SKX-NEXT:    retq ## encoding: [0xc3]
  %res = call <2 x double> @llvm.x86.sse2.cvtsi642sd(<2 x double> %a0, i64 %a1) ; <<2 x double>> [#uses=1]
  ret <2 x double> %res
}
declare <2 x double> @llvm.x86.sse2.cvtsi642sd(<2 x double>, i64) nounwind readnone
