; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mcpu=bdver2 -mtriple=x86_64-pc-win32 | FileCheck %s --check-prefix=FMA4 --check-prefix=FMA

attributes #0 = { nounwind }

declare <4 x float> @llvm.x86.fma4.vfmadd.ss(<4 x float>, <4 x float>, <4 x float>) nounwind readnone
define <4 x float> @test_x86_fmadd_baa_ss(<4 x float> %a, <4 x float> %b) #0 {
; FMA4-LABEL: test_x86_fmadd_baa_ss:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovaps (%rcx), %xmm0
; FMA4-NEXT:    vfmaddss %xmm0, (%rdx), %xmm0, %xmm0
; FMA4-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma4.vfmadd.ss(<4 x float> %b, <4 x float> %a, <4 x float> %a) nounwind
  ret <4 x float> %res
}

define <4 x float> @test_x86_fmadd_aba_ss(<4 x float> %a, <4 x float> %b) #0 {
; FMA4-LABEL: test_x86_fmadd_aba_ss:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovaps (%rcx), %xmm0
; FMA4-NEXT:    vfmaddss %xmm0, (%rdx), %xmm0, %xmm0
; FMA4-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma4.vfmadd.ss(<4 x float> %a, <4 x float> %b, <4 x float> %a) nounwind
  ret <4 x float> %res
}

define <4 x float> @test_x86_fmadd_bba_ss(<4 x float> %a, <4 x float> %b) #0 {
; FMA4-LABEL: test_x86_fmadd_bba_ss:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovaps (%rdx), %xmm0
; FMA4-NEXT:    vfmaddss (%rcx), %xmm0, %xmm0, %xmm0
; FMA4-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma4.vfmadd.ss(<4 x float> %b, <4 x float> %b, <4 x float> %a) nounwind
  ret <4 x float> %res
}

declare <4 x float> @llvm.x86.fma.vfmadd.ps(<4 x float>, <4 x float>, <4 x float>) nounwind readnone
define <4 x float> @test_x86_fmadd_baa_ps(<4 x float> %a, <4 x float> %b) #0 {
; FMA4-LABEL: test_x86_fmadd_baa_ps:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovaps (%rcx), %xmm0
; FMA4-NEXT:    vfmaddps %xmm0, (%rdx), %xmm0, %xmm0
; FMA4-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfmadd.ps(<4 x float> %b, <4 x float> %a, <4 x float> %a) nounwind
  ret <4 x float> %res
}

define <4 x float> @test_x86_fmadd_aba_ps(<4 x float> %a, <4 x float> %b) #0 {
; FMA4-LABEL: test_x86_fmadd_aba_ps:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovaps (%rcx), %xmm0
; FMA4-NEXT:    vfmaddps %xmm0, (%rdx), %xmm0, %xmm0
; FMA4-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfmadd.ps(<4 x float> %a, <4 x float> %b, <4 x float> %a) nounwind
  ret <4 x float> %res
}

define <4 x float> @test_x86_fmadd_bba_ps(<4 x float> %a, <4 x float> %b) #0 {
; FMA4-LABEL: test_x86_fmadd_bba_ps:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovaps (%rdx), %xmm0
; FMA4-NEXT:    vfmaddps (%rcx), %xmm0, %xmm0, %xmm0
; FMA4-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfmadd.ps(<4 x float> %b, <4 x float> %b, <4 x float> %a) nounwind
  ret <4 x float> %res
}

declare <8 x float> @llvm.x86.fma.vfmadd.ps.256(<8 x float>, <8 x float>, <8 x float>) nounwind readnone
define <8 x float> @test_x86_fmadd_baa_ps_y(<8 x float> %a, <8 x float> %b) #0 {
; FMA4-LABEL: test_x86_fmadd_baa_ps_y:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovaps (%rcx), %ymm0
; FMA4-NEXT:    vfmaddps %ymm0, (%rdx), %ymm0, %ymm0
; FMA4-NEXT:    retq
  %res = call <8 x float> @llvm.x86.fma.vfmadd.ps.256(<8 x float> %b, <8 x float> %a, <8 x float> %a) nounwind
  ret <8 x float> %res
}

define <8 x float> @test_x86_fmadd_aba_ps_y(<8 x float> %a, <8 x float> %b) #0 {
; FMA4-LABEL: test_x86_fmadd_aba_ps_y:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovaps (%rcx), %ymm0
; FMA4-NEXT:    vfmaddps %ymm0, (%rdx), %ymm0, %ymm0
; FMA4-NEXT:    retq
  %res = call <8 x float> @llvm.x86.fma.vfmadd.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> %a) nounwind
  ret <8 x float> %res
}

define <8 x float> @test_x86_fmadd_bba_ps_y(<8 x float> %a, <8 x float> %b) #0 {
; FMA4-LABEL: test_x86_fmadd_bba_ps_y:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovaps (%rdx), %ymm0
; FMA4-NEXT:    vfmaddps (%rcx), %ymm0, %ymm0, %ymm0
; FMA4-NEXT:    retq
  %res = call <8 x float> @llvm.x86.fma.vfmadd.ps.256(<8 x float> %b, <8 x float> %b, <8 x float> %a) nounwind
  ret <8 x float> %res
}

declare <2 x double> @llvm.x86.fma4.vfmadd.sd(<2 x double>, <2 x double>, <2 x double>) nounwind readnone
define <2 x double> @test_x86_fmadd_baa_sd(<2 x double> %a, <2 x double> %b) #0 {
; FMA4-LABEL: test_x86_fmadd_baa_sd:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovapd (%rcx), %xmm0
; FMA4-NEXT:    vfmaddsd %xmm0, (%rdx), %xmm0, %xmm0
; FMA4-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma4.vfmadd.sd(<2 x double> %b, <2 x double> %a, <2 x double> %a) nounwind
  ret <2 x double> %res
}

define <2 x double> @test_x86_fmadd_aba_sd(<2 x double> %a, <2 x double> %b) #0 {
; FMA4-LABEL: test_x86_fmadd_aba_sd:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovapd (%rcx), %xmm0
; FMA4-NEXT:    vfmaddsd %xmm0, (%rdx), %xmm0, %xmm0
; FMA4-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma4.vfmadd.sd(<2 x double> %a, <2 x double> %b, <2 x double> %a) nounwind
  ret <2 x double> %res
}

define <2 x double> @test_x86_fmadd_bba_sd(<2 x double> %a, <2 x double> %b) #0 {
; FMA4-LABEL: test_x86_fmadd_bba_sd:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovapd (%rdx), %xmm0
; FMA4-NEXT:    vfmaddsd (%rcx), %xmm0, %xmm0, %xmm0
; FMA4-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma4.vfmadd.sd(<2 x double> %b, <2 x double> %b, <2 x double> %a) nounwind
  ret <2 x double> %res
}

declare <2 x double> @llvm.x86.fma.vfmadd.pd(<2 x double>, <2 x double>, <2 x double>) nounwind readnone
define <2 x double> @test_x86_fmadd_baa_pd(<2 x double> %a, <2 x double> %b) #0 {
; FMA4-LABEL: test_x86_fmadd_baa_pd:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovapd (%rcx), %xmm0
; FMA4-NEXT:    vfmaddpd %xmm0, (%rdx), %xmm0, %xmm0
; FMA4-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfmadd.pd(<2 x double> %b, <2 x double> %a, <2 x double> %a) nounwind
  ret <2 x double> %res
}

define <2 x double> @test_x86_fmadd_aba_pd(<2 x double> %a, <2 x double> %b) #0 {
; FMA4-LABEL: test_x86_fmadd_aba_pd:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovapd (%rcx), %xmm0
; FMA4-NEXT:    vfmaddpd %xmm0, (%rdx), %xmm0, %xmm0
; FMA4-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfmadd.pd(<2 x double> %a, <2 x double> %b, <2 x double> %a) nounwind
  ret <2 x double> %res
}

define <2 x double> @test_x86_fmadd_bba_pd(<2 x double> %a, <2 x double> %b) #0 {
; FMA4-LABEL: test_x86_fmadd_bba_pd:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovapd (%rdx), %xmm0
; FMA4-NEXT:    vfmaddpd (%rcx), %xmm0, %xmm0, %xmm0
; FMA4-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfmadd.pd(<2 x double> %b, <2 x double> %b, <2 x double> %a) nounwind
  ret <2 x double> %res
}

declare <4 x double> @llvm.x86.fma.vfmadd.pd.256(<4 x double>, <4 x double>, <4 x double>) nounwind readnone
define <4 x double> @test_x86_fmadd_baa_pd_y(<4 x double> %a, <4 x double> %b) #0 {
; FMA4-LABEL: test_x86_fmadd_baa_pd_y:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovapd (%rcx), %ymm0
; FMA4-NEXT:    vfmaddpd %ymm0, (%rdx), %ymm0, %ymm0
; FMA4-NEXT:    retq
  %res = call <4 x double> @llvm.x86.fma.vfmadd.pd.256(<4 x double> %b, <4 x double> %a, <4 x double> %a) nounwind
  ret <4 x double> %res
}

define <4 x double> @test_x86_fmadd_aba_pd_y(<4 x double> %a, <4 x double> %b) #0 {
; FMA4-LABEL: test_x86_fmadd_aba_pd_y:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovapd (%rcx), %ymm0
; FMA4-NEXT:    vfmaddpd %ymm0, (%rdx), %ymm0, %ymm0
; FMA4-NEXT:    retq
  %res = call <4 x double> @llvm.x86.fma.vfmadd.pd.256(<4 x double> %a, <4 x double> %b, <4 x double> %a) nounwind
  ret <4 x double> %res
}

define <4 x double> @test_x86_fmadd_bba_pd_y(<4 x double> %a, <4 x double> %b) #0 {
; FMA4-LABEL: test_x86_fmadd_bba_pd_y:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovapd (%rdx), %ymm0
; FMA4-NEXT:    vfmaddpd (%rcx), %ymm0, %ymm0, %ymm0
; FMA4-NEXT:    retq
  %res = call <4 x double> @llvm.x86.fma.vfmadd.pd.256(<4 x double> %b, <4 x double> %b, <4 x double> %a) nounwind
  ret <4 x double> %res
}

declare <4 x float> @llvm.x86.fma.vfnmadd.ps(<4 x float>, <4 x float>, <4 x float>) nounwind readnone
define <4 x float> @test_x86_fnmadd_baa_ps(<4 x float> %a, <4 x float> %b) #0 {
; FMA4-LABEL: test_x86_fnmadd_baa_ps:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovaps (%rcx), %xmm0
; FMA4-NEXT:    vfnmaddps %xmm0, (%rdx), %xmm0, %xmm0
; FMA4-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfnmadd.ps(<4 x float> %b, <4 x float> %a, <4 x float> %a) nounwind
  ret <4 x float> %res
}

define <4 x float> @test_x86_fnmadd_aba_ps(<4 x float> %a, <4 x float> %b) #0 {
; FMA4-LABEL: test_x86_fnmadd_aba_ps:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovaps (%rcx), %xmm0
; FMA4-NEXT:    vfnmaddps %xmm0, (%rdx), %xmm0, %xmm0
; FMA4-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfnmadd.ps(<4 x float> %a, <4 x float> %b, <4 x float> %a) nounwind
  ret <4 x float> %res
}

define <4 x float> @test_x86_fnmadd_bba_ps(<4 x float> %a, <4 x float> %b) #0 {
; FMA4-LABEL: test_x86_fnmadd_bba_ps:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovaps (%rdx), %xmm0
; FMA4-NEXT:    vfnmaddps (%rcx), %xmm0, %xmm0, %xmm0
; FMA4-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfnmadd.ps(<4 x float> %b, <4 x float> %b, <4 x float> %a) nounwind
  ret <4 x float> %res
}

declare <8 x float> @llvm.x86.fma.vfnmadd.ps.256(<8 x float>, <8 x float>, <8 x float>) nounwind readnone
define <8 x float> @test_x86_fnmadd_baa_ps_y(<8 x float> %a, <8 x float> %b) #0 {
; FMA4-LABEL: test_x86_fnmadd_baa_ps_y:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovaps (%rcx), %ymm0
; FMA4-NEXT:    vfnmaddps %ymm0, (%rdx), %ymm0, %ymm0
; FMA4-NEXT:    retq
  %res = call <8 x float> @llvm.x86.fma.vfnmadd.ps.256(<8 x float> %b, <8 x float> %a, <8 x float> %a) nounwind
  ret <8 x float> %res
}

define <8 x float> @test_x86_fnmadd_aba_ps_y(<8 x float> %a, <8 x float> %b) #0 {
; FMA4-LABEL: test_x86_fnmadd_aba_ps_y:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovaps (%rcx), %ymm0
; FMA4-NEXT:    vfnmaddps %ymm0, (%rdx), %ymm0, %ymm0
; FMA4-NEXT:    retq
  %res = call <8 x float> @llvm.x86.fma.vfnmadd.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> %a) nounwind
  ret <8 x float> %res
}

define <8 x float> @test_x86_fnmadd_bba_ps_y(<8 x float> %a, <8 x float> %b) #0 {
; FMA4-LABEL: test_x86_fnmadd_bba_ps_y:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovaps (%rdx), %ymm0
; FMA4-NEXT:    vfnmaddps (%rcx), %ymm0, %ymm0, %ymm0
; FMA4-NEXT:    retq
  %res = call <8 x float> @llvm.x86.fma.vfnmadd.ps.256(<8 x float> %b, <8 x float> %b, <8 x float> %a) nounwind
  ret <8 x float> %res
}

declare <2 x double> @llvm.x86.fma.vfnmadd.pd(<2 x double>, <2 x double>, <2 x double>) nounwind readnone
define <2 x double> @test_x86_fnmadd_baa_pd(<2 x double> %a, <2 x double> %b) #0 {
; FMA4-LABEL: test_x86_fnmadd_baa_pd:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovapd (%rcx), %xmm0
; FMA4-NEXT:    vfnmaddpd %xmm0, (%rdx), %xmm0, %xmm0
; FMA4-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfnmadd.pd(<2 x double> %b, <2 x double> %a, <2 x double> %a) nounwind
  ret <2 x double> %res
}

define <2 x double> @test_x86_fnmadd_aba_pd(<2 x double> %a, <2 x double> %b) #0 {
; FMA4-LABEL: test_x86_fnmadd_aba_pd:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovapd (%rcx), %xmm0
; FMA4-NEXT:    vfnmaddpd %xmm0, (%rdx), %xmm0, %xmm0
; FMA4-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfnmadd.pd(<2 x double> %a, <2 x double> %b, <2 x double> %a) nounwind
  ret <2 x double> %res
}

define <2 x double> @test_x86_fnmadd_bba_pd(<2 x double> %a, <2 x double> %b) #0 {
; FMA4-LABEL: test_x86_fnmadd_bba_pd:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovapd (%rdx), %xmm0
; FMA4-NEXT:    vfnmaddpd (%rcx), %xmm0, %xmm0, %xmm0
; FMA4-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfnmadd.pd(<2 x double> %b, <2 x double> %b, <2 x double> %a) nounwind
  ret <2 x double> %res
}

declare <4 x double> @llvm.x86.fma.vfnmadd.pd.256(<4 x double>, <4 x double>, <4 x double>) nounwind readnone
define <4 x double> @test_x86_fnmadd_baa_pd_y(<4 x double> %a, <4 x double> %b) #0 {
; FMA4-LABEL: test_x86_fnmadd_baa_pd_y:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovapd (%rcx), %ymm0
; FMA4-NEXT:    vfnmaddpd %ymm0, (%rdx), %ymm0, %ymm0
; FMA4-NEXT:    retq
  %res = call <4 x double> @llvm.x86.fma.vfnmadd.pd.256(<4 x double> %b, <4 x double> %a, <4 x double> %a) nounwind
  ret <4 x double> %res
}

define <4 x double> @test_x86_fnmadd_aba_pd_y(<4 x double> %a, <4 x double> %b) #0 {
; FMA4-LABEL: test_x86_fnmadd_aba_pd_y:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovapd (%rcx), %ymm0
; FMA4-NEXT:    vfnmaddpd %ymm0, (%rdx), %ymm0, %ymm0
; FMA4-NEXT:    retq
  %res = call <4 x double> @llvm.x86.fma.vfnmadd.pd.256(<4 x double> %a, <4 x double> %b, <4 x double> %a) nounwind
  ret <4 x double> %res
}

define <4 x double> @test_x86_fnmadd_bba_pd_y(<4 x double> %a, <4 x double> %b) #0 {
; FMA4-LABEL: test_x86_fnmadd_bba_pd_y:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovapd (%rdx), %ymm0
; FMA4-NEXT:    vfnmaddpd (%rcx), %ymm0, %ymm0, %ymm0
; FMA4-NEXT:    retq
  %res = call <4 x double> @llvm.x86.fma.vfnmadd.pd.256(<4 x double> %b, <4 x double> %b, <4 x double> %a) nounwind
  ret <4 x double> %res
}

declare <4 x float> @llvm.x86.fma.vfmsub.ps(<4 x float>, <4 x float>, <4 x float>) nounwind readnone
define <4 x float> @test_x86_fmsub_baa_ps(<4 x float> %a, <4 x float> %b) #0 {
; FMA4-LABEL: test_x86_fmsub_baa_ps:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovaps (%rcx), %xmm0
; FMA4-NEXT:    vfmsubps %xmm0, (%rdx), %xmm0, %xmm0
; FMA4-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfmsub.ps(<4 x float> %b, <4 x float> %a, <4 x float> %a) nounwind
  ret <4 x float> %res
}

define <4 x float> @test_x86_fmsub_aba_ps(<4 x float> %a, <4 x float> %b) #0 {
; FMA4-LABEL: test_x86_fmsub_aba_ps:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovaps (%rcx), %xmm0
; FMA4-NEXT:    vfmsubps %xmm0, (%rdx), %xmm0, %xmm0
; FMA4-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfmsub.ps(<4 x float> %a, <4 x float> %b, <4 x float> %a) nounwind
  ret <4 x float> %res
}

define <4 x float> @test_x86_fmsub_bba_ps(<4 x float> %a, <4 x float> %b) #0 {
; FMA4-LABEL: test_x86_fmsub_bba_ps:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovaps (%rdx), %xmm0
; FMA4-NEXT:    vfmsubps (%rcx), %xmm0, %xmm0, %xmm0
; FMA4-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfmsub.ps(<4 x float> %b, <4 x float> %b, <4 x float> %a) nounwind
  ret <4 x float> %res
}

declare <8 x float> @llvm.x86.fma.vfmsub.ps.256(<8 x float>, <8 x float>, <8 x float>) nounwind readnone
define <8 x float> @test_x86_fmsub_baa_ps_y(<8 x float> %a, <8 x float> %b) #0 {
; FMA4-LABEL: test_x86_fmsub_baa_ps_y:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovaps (%rcx), %ymm0
; FMA4-NEXT:    vfmsubps %ymm0, (%rdx), %ymm0, %ymm0
; FMA4-NEXT:    retq
  %res = call <8 x float> @llvm.x86.fma.vfmsub.ps.256(<8 x float> %b, <8 x float> %a, <8 x float> %a) nounwind
  ret <8 x float> %res
}

define <8 x float> @test_x86_fmsub_aba_ps_y(<8 x float> %a, <8 x float> %b) #0 {
; FMA4-LABEL: test_x86_fmsub_aba_ps_y:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovaps (%rcx), %ymm0
; FMA4-NEXT:    vfmsubps %ymm0, (%rdx), %ymm0, %ymm0
; FMA4-NEXT:    retq
  %res = call <8 x float> @llvm.x86.fma.vfmsub.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> %a) nounwind
  ret <8 x float> %res
}

define <8 x float> @test_x86_fmsub_bba_ps_y(<8 x float> %a, <8 x float> %b) #0 {
; FMA4-LABEL: test_x86_fmsub_bba_ps_y:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovaps (%rdx), %ymm0
; FMA4-NEXT:    vfmsubps (%rcx), %ymm0, %ymm0, %ymm0
; FMA4-NEXT:    retq
  %res = call <8 x float> @llvm.x86.fma.vfmsub.ps.256(<8 x float> %b, <8 x float> %b, <8 x float> %a) nounwind
  ret <8 x float> %res
}

declare <2 x double> @llvm.x86.fma.vfmsub.pd(<2 x double>, <2 x double>, <2 x double>) nounwind readnone
define <2 x double> @test_x86_fmsub_baa_pd(<2 x double> %a, <2 x double> %b) #0 {
; FMA4-LABEL: test_x86_fmsub_baa_pd:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovapd (%rcx), %xmm0
; FMA4-NEXT:    vfmsubpd %xmm0, (%rdx), %xmm0, %xmm0
; FMA4-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfmsub.pd(<2 x double> %b, <2 x double> %a, <2 x double> %a) nounwind
  ret <2 x double> %res
}

define <2 x double> @test_x86_fmsub_aba_pd(<2 x double> %a, <2 x double> %b) #0 {
; FMA4-LABEL: test_x86_fmsub_aba_pd:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovapd (%rcx), %xmm0
; FMA4-NEXT:    vfmsubpd %xmm0, (%rdx), %xmm0, %xmm0
; FMA4-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfmsub.pd(<2 x double> %a, <2 x double> %b, <2 x double> %a) nounwind
  ret <2 x double> %res
}

define <2 x double> @test_x86_fmsub_bba_pd(<2 x double> %a, <2 x double> %b) #0 {
; FMA4-LABEL: test_x86_fmsub_bba_pd:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovapd (%rdx), %xmm0
; FMA4-NEXT:    vfmsubpd (%rcx), %xmm0, %xmm0, %xmm0
; FMA4-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfmsub.pd(<2 x double> %b, <2 x double> %b, <2 x double> %a) nounwind
  ret <2 x double> %res
}

declare <4 x double> @llvm.x86.fma.vfmsub.pd.256(<4 x double>, <4 x double>, <4 x double>) nounwind readnone
define <4 x double> @test_x86_fmsub_baa_pd_y(<4 x double> %a, <4 x double> %b) #0 {
; FMA4-LABEL: test_x86_fmsub_baa_pd_y:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovapd (%rcx), %ymm0
; FMA4-NEXT:    vfmsubpd %ymm0, (%rdx), %ymm0, %ymm0
; FMA4-NEXT:    retq
  %res = call <4 x double> @llvm.x86.fma.vfmsub.pd.256(<4 x double> %b, <4 x double> %a, <4 x double> %a) nounwind
  ret <4 x double> %res
}

define <4 x double> @test_x86_fmsub_aba_pd_y(<4 x double> %a, <4 x double> %b) #0 {
; FMA4-LABEL: test_x86_fmsub_aba_pd_y:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovapd (%rcx), %ymm0
; FMA4-NEXT:    vfmsubpd %ymm0, (%rdx), %ymm0, %ymm0
; FMA4-NEXT:    retq
  %res = call <4 x double> @llvm.x86.fma.vfmsub.pd.256(<4 x double> %a, <4 x double> %b, <4 x double> %a) nounwind
  ret <4 x double> %res
}

define <4 x double> @test_x86_fmsub_bba_pd_y(<4 x double> %a, <4 x double> %b) #0 {
; FMA4-LABEL: test_x86_fmsub_bba_pd_y:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovapd (%rdx), %ymm0
; FMA4-NEXT:    vfmsubpd (%rcx), %ymm0, %ymm0, %ymm0
; FMA4-NEXT:    retq
  %res = call <4 x double> @llvm.x86.fma.vfmsub.pd.256(<4 x double> %b, <4 x double> %b, <4 x double> %a) nounwind
  ret <4 x double> %res
}

declare <4 x float> @llvm.x86.fma.vfnmsub.ps(<4 x float>, <4 x float>, <4 x float>) nounwind readnone
define <4 x float> @test_x86_fnmsub_baa_ps(<4 x float> %a, <4 x float> %b) #0 {
; FMA4-LABEL: test_x86_fnmsub_baa_ps:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovaps (%rcx), %xmm0
; FMA4-NEXT:    vfnmsubps %xmm0, (%rdx), %xmm0, %xmm0
; FMA4-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfnmsub.ps(<4 x float> %b, <4 x float> %a, <4 x float> %a) nounwind
  ret <4 x float> %res
}

define <4 x float> @test_x86_fnmsub_aba_ps(<4 x float> %a, <4 x float> %b) #0 {
; FMA4-LABEL: test_x86_fnmsub_aba_ps:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovaps (%rcx), %xmm0
; FMA4-NEXT:    vfnmsubps %xmm0, (%rdx), %xmm0, %xmm0
; FMA4-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfnmsub.ps(<4 x float> %a, <4 x float> %b, <4 x float> %a) nounwind
  ret <4 x float> %res
}

define <4 x float> @test_x86_fnmsub_bba_ps(<4 x float> %a, <4 x float> %b) #0 {
; FMA4-LABEL: test_x86_fnmsub_bba_ps:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovaps (%rdx), %xmm0
; FMA4-NEXT:    vfnmsubps (%rcx), %xmm0, %xmm0, %xmm0
; FMA4-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfnmsub.ps(<4 x float> %b, <4 x float> %b, <4 x float> %a) nounwind
  ret <4 x float> %res
}

declare <8 x float> @llvm.x86.fma.vfnmsub.ps.256(<8 x float>, <8 x float>, <8 x float>) nounwind readnone
define <8 x float> @test_x86_fnmsub_baa_ps_y(<8 x float> %a, <8 x float> %b) #0 {
; FMA4-LABEL: test_x86_fnmsub_baa_ps_y:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovaps (%rcx), %ymm0
; FMA4-NEXT:    vfnmsubps %ymm0, (%rdx), %ymm0, %ymm0
; FMA4-NEXT:    retq
  %res = call <8 x float> @llvm.x86.fma.vfnmsub.ps.256(<8 x float> %b, <8 x float> %a, <8 x float> %a) nounwind
  ret <8 x float> %res
}

define <8 x float> @test_x86_fnmsub_aba_ps_y(<8 x float> %a, <8 x float> %b) #0 {
; FMA4-LABEL: test_x86_fnmsub_aba_ps_y:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovaps (%rcx), %ymm0
; FMA4-NEXT:    vfnmsubps %ymm0, (%rdx), %ymm0, %ymm0
; FMA4-NEXT:    retq
  %res = call <8 x float> @llvm.x86.fma.vfnmsub.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> %a) nounwind
  ret <8 x float> %res
}

define <8 x float> @test_x86_fnmsub_bba_ps_y(<8 x float> %a, <8 x float> %b) #0 {
; FMA4-LABEL: test_x86_fnmsub_bba_ps_y:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovaps (%rdx), %ymm0
; FMA4-NEXT:    vfnmsubps (%rcx), %ymm0, %ymm0, %ymm0
; FMA4-NEXT:    retq
  %res = call <8 x float> @llvm.x86.fma.vfnmsub.ps.256(<8 x float> %b, <8 x float> %b, <8 x float> %a) nounwind
  ret <8 x float> %res
}

declare <2 x double> @llvm.x86.fma.vfnmsub.pd(<2 x double>, <2 x double>, <2 x double>) nounwind readnone
define <2 x double> @test_x86_fnmsub_baa_pd(<2 x double> %a, <2 x double> %b) #0 {
; FMA4-LABEL: test_x86_fnmsub_baa_pd:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovapd (%rcx), %xmm0
; FMA4-NEXT:    vfnmsubpd %xmm0, (%rdx), %xmm0, %xmm0
; FMA4-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfnmsub.pd(<2 x double> %b, <2 x double> %a, <2 x double> %a) nounwind
  ret <2 x double> %res
}

define <2 x double> @test_x86_fnmsub_aba_pd(<2 x double> %a, <2 x double> %b) #0 {
; FMA4-LABEL: test_x86_fnmsub_aba_pd:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovapd (%rcx), %xmm0
; FMA4-NEXT:    vfnmsubpd %xmm0, (%rdx), %xmm0, %xmm0
; FMA4-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfnmsub.pd(<2 x double> %a, <2 x double> %b, <2 x double> %a) nounwind
  ret <2 x double> %res
}

define <2 x double> @test_x86_fnmsub_bba_pd(<2 x double> %a, <2 x double> %b) #0 {
; FMA4-LABEL: test_x86_fnmsub_bba_pd:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovapd (%rdx), %xmm0
; FMA4-NEXT:    vfnmsubpd (%rcx), %xmm0, %xmm0, %xmm0
; FMA4-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfnmsub.pd(<2 x double> %b, <2 x double> %b, <2 x double> %a) nounwind
  ret <2 x double> %res
}

declare <4 x double> @llvm.x86.fma.vfnmsub.pd.256(<4 x double>, <4 x double>, <4 x double>) nounwind readnone
define <4 x double> @test_x86_fnmsub_baa_pd_y(<4 x double> %a, <4 x double> %b) #0 {
; FMA4-LABEL: test_x86_fnmsub_baa_pd_y:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovapd (%rcx), %ymm0
; FMA4-NEXT:    vfnmsubpd %ymm0, (%rdx), %ymm0, %ymm0
; FMA4-NEXT:    retq
  %res = call <4 x double> @llvm.x86.fma.vfnmsub.pd.256(<4 x double> %b, <4 x double> %a, <4 x double> %a) nounwind
  ret <4 x double> %res
}

define <4 x double> @test_x86_fnmsub_aba_pd_y(<4 x double> %a, <4 x double> %b) #0 {
; FMA4-LABEL: test_x86_fnmsub_aba_pd_y:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovapd (%rcx), %ymm0
; FMA4-NEXT:    vfnmsubpd %ymm0, (%rdx), %ymm0, %ymm0
; FMA4-NEXT:    retq
  %res = call <4 x double> @llvm.x86.fma.vfnmsub.pd.256(<4 x double> %a, <4 x double> %b, <4 x double> %a) nounwind
  ret <4 x double> %res
}

define <4 x double> @test_x86_fnmsub_bba_pd_y(<4 x double> %a, <4 x double> %b) #0 {
; FMA4-LABEL: test_x86_fnmsub_bba_pd_y:
; FMA4:       # %bb.0:
; FMA4-NEXT:    vmovapd (%rdx), %ymm0
; FMA4-NEXT:    vfnmsubpd (%rcx), %ymm0, %ymm0, %ymm0
; FMA4-NEXT:    retq
  %res = call <4 x double> @llvm.x86.fma.vfnmsub.pd.256(<4 x double> %b, <4 x double> %b, <4 x double> %a) nounwind
  ret <4 x double> %res
}

