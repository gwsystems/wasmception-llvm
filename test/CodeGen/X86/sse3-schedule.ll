; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=x86-64 -mattr=+sse3 | FileCheck %s --check-prefix=CHECK --check-prefix=GENERIC
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=atom | FileCheck %s --check-prefix=CHECK --check-prefix=ATOM
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=slm | FileCheck %s --check-prefix=CHECK --check-prefix=SLM
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=sandybridge | FileCheck %s --check-prefix=CHECK --check-prefix=SANDY
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=ivybridge | FileCheck %s --check-prefix=CHECK --check-prefix=SANDY
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=haswell | FileCheck %s --check-prefix=CHECK --check-prefix=HASWELL
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=skylake | FileCheck %s --check-prefix=CHECK --check-prefix=SKYLAKE
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=btver2 | FileCheck %s --check-prefix=CHECK --check-prefix=BTVER2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=znver1 | FileCheck %s --check-prefix=CHECK --check-prefix=ZNVER1

define <2 x double> @test_addsubpd(<2 x double> %a0, <2 x double> %a1, <2 x double> *%a2) {
; GENERIC-LABEL: test_addsubpd:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    addsubpd %xmm1, %xmm0 # sched: [3:1.00]
; GENERIC-NEXT:    addsubpd (%rdi), %xmm0 # sched: [9:1.00]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; ATOM-LABEL: test_addsubpd:
; ATOM:       # BB#0:
; ATOM-NEXT:    addsubpd %xmm1, %xmm0 # sched: [6:3.00]
; ATOM-NEXT:    addsubpd (%rdi), %xmm0 # sched: [6:3.00]
; ATOM-NEXT:    retq # sched: [79:39.50]
;
; SLM-LABEL: test_addsubpd:
; SLM:       # BB#0:
; SLM-NEXT:    addsubpd %xmm1, %xmm0 # sched: [3:1.00]
; SLM-NEXT:    addsubpd (%rdi), %xmm0 # sched: [6:1.00]
; SLM-NEXT:    retq # sched: [4:1.00]
;
; SANDY-LABEL: test_addsubpd:
; SANDY:       # BB#0:
; SANDY-NEXT:    vaddsubpd %xmm1, %xmm0, %xmm0 # sched: [3:1.00]
; SANDY-NEXT:    vaddsubpd (%rdi), %xmm0, %xmm0 # sched: [9:1.00]
; SANDY-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_addsubpd:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    vaddsubpd %xmm1, %xmm0, %xmm0 # sched: [3:1.00]
; HASWELL-NEXT:    vaddsubpd (%rdi), %xmm0, %xmm0 # sched: [3:1.00]
; HASWELL-NEXT:    retq # sched: [2:1.00]
;
; SKYLAKE-LABEL: test_addsubpd:
; SKYLAKE:       # BB#0:
; SKYLAKE-NEXT:    vaddsubpd %xmm1, %xmm0, %xmm0 # sched: [4:0.50]
; SKYLAKE-NEXT:    vaddsubpd (%rdi), %xmm0, %xmm0 # sched: [4:0.50]
; SKYLAKE-NEXT:    retq # sched: [2:1.00]
;
; BTVER2-LABEL: test_addsubpd:
; BTVER2:       # BB#0:
; BTVER2-NEXT:    vaddsubpd %xmm1, %xmm0, %xmm0 # sched: [3:1.00]
; BTVER2-NEXT:    vaddsubpd (%rdi), %xmm0, %xmm0 # sched: [8:1.00]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; ZNVER1-LABEL: test_addsubpd:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    vaddsubpd %xmm1, %xmm0, %xmm0 # sched: [3:1.00]
; ZNVER1-NEXT:    vaddsubpd (%rdi), %xmm0, %xmm0 # sched: [10:1.00]
; ZNVER1-NEXT:    retq # sched: [1:0.50]
  %1 = call <2 x double> @llvm.x86.sse3.addsub.pd(<2 x double> %a0, <2 x double> %a1)
  %2 = load <2 x double>, <2 x double> *%a2, align 16
  %3 = call <2 x double> @llvm.x86.sse3.addsub.pd(<2 x double> %1, <2 x double> %2)
  ret <2 x double> %3
}
declare <2 x double> @llvm.x86.sse3.addsub.pd(<2 x double>, <2 x double>) nounwind readnone

define <4 x float> @test_addsubps(<4 x float> %a0, <4 x float> %a1, <4 x float> *%a2) {
; GENERIC-LABEL: test_addsubps:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    addsubps %xmm1, %xmm0 # sched: [3:1.00]
; GENERIC-NEXT:    addsubps (%rdi), %xmm0 # sched: [9:1.00]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; ATOM-LABEL: test_addsubps:
; ATOM:       # BB#0:
; ATOM-NEXT:    addsubps %xmm1, %xmm0 # sched: [5:5.00]
; ATOM-NEXT:    addsubps (%rdi), %xmm0 # sched: [5:5.00]
; ATOM-NEXT:    retq # sched: [79:39.50]
;
; SLM-LABEL: test_addsubps:
; SLM:       # BB#0:
; SLM-NEXT:    addsubps %xmm1, %xmm0 # sched: [3:1.00]
; SLM-NEXT:    addsubps (%rdi), %xmm0 # sched: [6:1.00]
; SLM-NEXT:    retq # sched: [4:1.00]
;
; SANDY-LABEL: test_addsubps:
; SANDY:       # BB#0:
; SANDY-NEXT:    vaddsubps %xmm1, %xmm0, %xmm0 # sched: [3:1.00]
; SANDY-NEXT:    vaddsubps (%rdi), %xmm0, %xmm0 # sched: [9:1.00]
; SANDY-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_addsubps:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    vaddsubps %xmm1, %xmm0, %xmm0 # sched: [3:1.00]
; HASWELL-NEXT:    vaddsubps (%rdi), %xmm0, %xmm0 # sched: [3:1.00]
; HASWELL-NEXT:    retq # sched: [2:1.00]
;
; SKYLAKE-LABEL: test_addsubps:
; SKYLAKE:       # BB#0:
; SKYLAKE-NEXT:    vaddsubps %xmm1, %xmm0, %xmm0 # sched: [4:0.50]
; SKYLAKE-NEXT:    vaddsubps (%rdi), %xmm0, %xmm0 # sched: [4:0.50]
; SKYLAKE-NEXT:    retq # sched: [2:1.00]
;
; BTVER2-LABEL: test_addsubps:
; BTVER2:       # BB#0:
; BTVER2-NEXT:    vaddsubps %xmm1, %xmm0, %xmm0 # sched: [3:1.00]
; BTVER2-NEXT:    vaddsubps (%rdi), %xmm0, %xmm0 # sched: [8:1.00]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; ZNVER1-LABEL: test_addsubps:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    vaddsubps %xmm1, %xmm0, %xmm0 # sched: [3:1.00]
; ZNVER1-NEXT:    vaddsubps (%rdi), %xmm0, %xmm0 # sched: [10:1.00]
; ZNVER1-NEXT:    retq # sched: [1:0.50]
  %1 = call <4 x float> @llvm.x86.sse3.addsub.ps(<4 x float> %a0, <4 x float> %a1)
  %2 = load <4 x float>, <4 x float> *%a2, align 16
  %3 = call <4 x float> @llvm.x86.sse3.addsub.ps(<4 x float> %1, <4 x float> %2)
  ret <4 x float> %3
}
declare <4 x float> @llvm.x86.sse3.addsub.ps(<4 x float>, <4 x float>) nounwind readnone

define <2 x double> @test_haddpd(<2 x double> %a0, <2 x double> %a1, <2 x double> *%a2) {
; GENERIC-LABEL: test_haddpd:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    haddpd %xmm1, %xmm0 # sched: [5:2.00]
; GENERIC-NEXT:    haddpd (%rdi), %xmm0 # sched: [11:2.00]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; ATOM-LABEL: test_haddpd:
; ATOM:       # BB#0:
; ATOM-NEXT:    haddpd %xmm1, %xmm0 # sched: [8:4.00]
; ATOM-NEXT:    haddpd (%rdi), %xmm0 # sched: [9:4.50]
; ATOM-NEXT:    retq # sched: [79:39.50]
;
; SLM-LABEL: test_haddpd:
; SLM:       # BB#0:
; SLM-NEXT:    haddpd %xmm1, %xmm0 # sched: [3:1.00]
; SLM-NEXT:    haddpd (%rdi), %xmm0 # sched: [6:1.00]
; SLM-NEXT:    retq # sched: [4:1.00]
;
; SANDY-LABEL: test_haddpd:
; SANDY:       # BB#0:
; SANDY-NEXT:    vhaddpd %xmm1, %xmm0, %xmm0 # sched: [5:2.00]
; SANDY-NEXT:    vhaddpd (%rdi), %xmm0, %xmm0 # sched: [11:2.00]
; SANDY-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_haddpd:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    vhaddpd %xmm1, %xmm0, %xmm0 # sched: [5:2.00]
; HASWELL-NEXT:    vhaddpd (%rdi), %xmm0, %xmm0 # sched: [5:2.00]
; HASWELL-NEXT:    retq # sched: [2:1.00]
;
; SKYLAKE-LABEL: test_haddpd:
; SKYLAKE:       # BB#0:
; SKYLAKE-NEXT:    vhaddpd %xmm1, %xmm0, %xmm0 # sched: [6:2.00]
; SKYLAKE-NEXT:    vhaddpd (%rdi), %xmm0, %xmm0 # sched: [6:2.00]
; SKYLAKE-NEXT:    retq # sched: [2:1.00]
;
; BTVER2-LABEL: test_haddpd:
; BTVER2:       # BB#0:
; BTVER2-NEXT:    vhaddpd %xmm1, %xmm0, %xmm0 # sched: [3:1.00]
; BTVER2-NEXT:    vhaddpd (%rdi), %xmm0, %xmm0 # sched: [8:1.00]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; ZNVER1-LABEL: test_haddpd:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    vhaddpd %xmm1, %xmm0, %xmm0 # sched: [100:?]
; ZNVER1-NEXT:    vhaddpd (%rdi), %xmm0, %xmm0 # sched: [100:?]
; ZNVER1-NEXT:    retq # sched: [1:0.50]
  %1 = call <2 x double> @llvm.x86.sse3.hadd.pd(<2 x double> %a0, <2 x double> %a1)
  %2 = load <2 x double>, <2 x double> *%a2, align 16
  %3 = call <2 x double> @llvm.x86.sse3.hadd.pd(<2 x double> %1, <2 x double> %2)
  ret <2 x double> %3
}
declare <2 x double> @llvm.x86.sse3.hadd.pd(<2 x double>, <2 x double>) nounwind readnone

define <4 x float> @test_haddps(<4 x float> %a0, <4 x float> %a1, <4 x float> *%a2) {
; GENERIC-LABEL: test_haddps:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    haddps %xmm1, %xmm0 # sched: [5:2.00]
; GENERIC-NEXT:    haddps (%rdi), %xmm0 # sched: [11:2.00]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; ATOM-LABEL: test_haddps:
; ATOM:       # BB#0:
; ATOM-NEXT:    haddps %xmm1, %xmm0 # sched: [8:4.00]
; ATOM-NEXT:    haddps (%rdi), %xmm0 # sched: [9:4.50]
; ATOM-NEXT:    retq # sched: [79:39.50]
;
; SLM-LABEL: test_haddps:
; SLM:       # BB#0:
; SLM-NEXT:    haddps %xmm1, %xmm0 # sched: [3:1.00]
; SLM-NEXT:    haddps (%rdi), %xmm0 # sched: [6:1.00]
; SLM-NEXT:    retq # sched: [4:1.00]
;
; SANDY-LABEL: test_haddps:
; SANDY:       # BB#0:
; SANDY-NEXT:    vhaddps %xmm1, %xmm0, %xmm0 # sched: [5:2.00]
; SANDY-NEXT:    vhaddps (%rdi), %xmm0, %xmm0 # sched: [11:2.00]
; SANDY-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_haddps:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    vhaddps %xmm1, %xmm0, %xmm0 # sched: [5:2.00]
; HASWELL-NEXT:    vhaddps (%rdi), %xmm0, %xmm0 # sched: [5:2.00]
; HASWELL-NEXT:    retq # sched: [2:1.00]
;
; SKYLAKE-LABEL: test_haddps:
; SKYLAKE:       # BB#0:
; SKYLAKE-NEXT:    vhaddps %xmm1, %xmm0, %xmm0 # sched: [6:2.00]
; SKYLAKE-NEXT:    vhaddps (%rdi), %xmm0, %xmm0 # sched: [6:2.00]
; SKYLAKE-NEXT:    retq # sched: [2:1.00]
;
; BTVER2-LABEL: test_haddps:
; BTVER2:       # BB#0:
; BTVER2-NEXT:    vhaddps %xmm1, %xmm0, %xmm0 # sched: [3:1.00]
; BTVER2-NEXT:    vhaddps (%rdi), %xmm0, %xmm0 # sched: [8:1.00]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; ZNVER1-LABEL: test_haddps:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    vhaddps %xmm1, %xmm0, %xmm0 # sched: [100:?]
; ZNVER1-NEXT:    vhaddps (%rdi), %xmm0, %xmm0 # sched: [100:?]
; ZNVER1-NEXT:    retq # sched: [1:0.50]
  %1 = call <4 x float> @llvm.x86.sse3.hadd.ps(<4 x float> %a0, <4 x float> %a1)
  %2 = load <4 x float>, <4 x float> *%a2, align 16
  %3 = call <4 x float> @llvm.x86.sse3.hadd.ps(<4 x float> %1, <4 x float> %2)
  ret <4 x float> %3
}
declare <4 x float> @llvm.x86.sse3.hadd.ps(<4 x float>, <4 x float>) nounwind readnone

define <2 x double> @test_hsubpd(<2 x double> %a0, <2 x double> %a1, <2 x double> *%a2) {
; GENERIC-LABEL: test_hsubpd:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    hsubpd %xmm1, %xmm0 # sched: [5:2.00]
; GENERIC-NEXT:    hsubpd (%rdi), %xmm0 # sched: [11:2.00]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; ATOM-LABEL: test_hsubpd:
; ATOM:       # BB#0:
; ATOM-NEXT:    hsubpd %xmm1, %xmm0 # sched: [8:4.00]
; ATOM-NEXT:    hsubpd (%rdi), %xmm0 # sched: [9:4.50]
; ATOM-NEXT:    retq # sched: [79:39.50]
;
; SLM-LABEL: test_hsubpd:
; SLM:       # BB#0:
; SLM-NEXT:    hsubpd %xmm1, %xmm0 # sched: [3:1.00]
; SLM-NEXT:    hsubpd (%rdi), %xmm0 # sched: [6:1.00]
; SLM-NEXT:    retq # sched: [4:1.00]
;
; SANDY-LABEL: test_hsubpd:
; SANDY:       # BB#0:
; SANDY-NEXT:    vhsubpd %xmm1, %xmm0, %xmm0 # sched: [5:2.00]
; SANDY-NEXT:    vhsubpd (%rdi), %xmm0, %xmm0 # sched: [11:2.00]
; SANDY-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_hsubpd:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    vhsubpd %xmm1, %xmm0, %xmm0 # sched: [5:2.00]
; HASWELL-NEXT:    vhsubpd (%rdi), %xmm0, %xmm0 # sched: [5:2.00]
; HASWELL-NEXT:    retq # sched: [2:1.00]
;
; SKYLAKE-LABEL: test_hsubpd:
; SKYLAKE:       # BB#0:
; SKYLAKE-NEXT:    vhsubpd %xmm1, %xmm0, %xmm0 # sched: [6:2.00]
; SKYLAKE-NEXT:    vhsubpd (%rdi), %xmm0, %xmm0 # sched: [6:2.00]
; SKYLAKE-NEXT:    retq # sched: [2:1.00]
;
; BTVER2-LABEL: test_hsubpd:
; BTVER2:       # BB#0:
; BTVER2-NEXT:    vhsubpd %xmm1, %xmm0, %xmm0 # sched: [3:1.00]
; BTVER2-NEXT:    vhsubpd (%rdi), %xmm0, %xmm0 # sched: [8:1.00]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; ZNVER1-LABEL: test_hsubpd:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    vhsubpd %xmm1, %xmm0, %xmm0 # sched: [100:?]
; ZNVER1-NEXT:    vhsubpd (%rdi), %xmm0, %xmm0 # sched: [100:?]
; ZNVER1-NEXT:    retq # sched: [1:0.50]
  %1 = call <2 x double> @llvm.x86.sse3.hsub.pd(<2 x double> %a0, <2 x double> %a1)
  %2 = load <2 x double>, <2 x double> *%a2, align 16
  %3 = call <2 x double> @llvm.x86.sse3.hsub.pd(<2 x double> %1, <2 x double> %2)
  ret <2 x double> %3
}
declare <2 x double> @llvm.x86.sse3.hsub.pd(<2 x double>, <2 x double>) nounwind readnone

define <4 x float> @test_hsubps(<4 x float> %a0, <4 x float> %a1, <4 x float> *%a2) {
; GENERIC-LABEL: test_hsubps:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    hsubps %xmm1, %xmm0 # sched: [5:2.00]
; GENERIC-NEXT:    hsubps (%rdi), %xmm0 # sched: [11:2.00]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; ATOM-LABEL: test_hsubps:
; ATOM:       # BB#0:
; ATOM-NEXT:    hsubps %xmm1, %xmm0 # sched: [8:4.00]
; ATOM-NEXT:    hsubps (%rdi), %xmm0 # sched: [9:4.50]
; ATOM-NEXT:    retq # sched: [79:39.50]
;
; SLM-LABEL: test_hsubps:
; SLM:       # BB#0:
; SLM-NEXT:    hsubps %xmm1, %xmm0 # sched: [3:1.00]
; SLM-NEXT:    hsubps (%rdi), %xmm0 # sched: [6:1.00]
; SLM-NEXT:    retq # sched: [4:1.00]
;
; SANDY-LABEL: test_hsubps:
; SANDY:       # BB#0:
; SANDY-NEXT:    vhsubps %xmm1, %xmm0, %xmm0 # sched: [5:2.00]
; SANDY-NEXT:    vhsubps (%rdi), %xmm0, %xmm0 # sched: [11:2.00]
; SANDY-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_hsubps:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    vhsubps %xmm1, %xmm0, %xmm0 # sched: [5:2.00]
; HASWELL-NEXT:    vhsubps (%rdi), %xmm0, %xmm0 # sched: [5:2.00]
; HASWELL-NEXT:    retq # sched: [2:1.00]
;
; SKYLAKE-LABEL: test_hsubps:
; SKYLAKE:       # BB#0:
; SKYLAKE-NEXT:    vhsubps %xmm1, %xmm0, %xmm0 # sched: [6:2.00]
; SKYLAKE-NEXT:    vhsubps (%rdi), %xmm0, %xmm0 # sched: [6:2.00]
; SKYLAKE-NEXT:    retq # sched: [2:1.00]
;
; BTVER2-LABEL: test_hsubps:
; BTVER2:       # BB#0:
; BTVER2-NEXT:    vhsubps %xmm1, %xmm0, %xmm0 # sched: [3:1.00]
; BTVER2-NEXT:    vhsubps (%rdi), %xmm0, %xmm0 # sched: [8:1.00]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; ZNVER1-LABEL: test_hsubps:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    vhsubps %xmm1, %xmm0, %xmm0 # sched: [100:?]
; ZNVER1-NEXT:    vhsubps (%rdi), %xmm0, %xmm0 # sched: [100:?]
; ZNVER1-NEXT:    retq # sched: [1:0.50]
  %1 = call <4 x float> @llvm.x86.sse3.hsub.ps(<4 x float> %a0, <4 x float> %a1)
  %2 = load <4 x float>, <4 x float> *%a2, align 16
  %3 = call <4 x float> @llvm.x86.sse3.hsub.ps(<4 x float> %1, <4 x float> %2)
  ret <4 x float> %3
}
declare <4 x float> @llvm.x86.sse3.hsub.ps(<4 x float>, <4 x float>) nounwind readnone

define <16 x i8> @test_lddqu(i8* %a0) {
; GENERIC-LABEL: test_lddqu:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    lddqu (%rdi), %xmm0 # sched: [6:0.50]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; ATOM-LABEL: test_lddqu:
; ATOM:       # BB#0:
; ATOM-NEXT:    lddqu (%rdi), %xmm0 # sched: [3:1.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    nop # sched: [1:0.50]
; ATOM-NEXT:    retq # sched: [79:39.50]
;
; SLM-LABEL: test_lddqu:
; SLM:       # BB#0:
; SLM-NEXT:    lddqu (%rdi), %xmm0 # sched: [3:1.00]
; SLM-NEXT:    retq # sched: [4:1.00]
;
; SANDY-LABEL: test_lddqu:
; SANDY:       # BB#0:
; SANDY-NEXT:    vlddqu (%rdi), %xmm0 # sched: [6:0.50]
; SANDY-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_lddqu:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    vlddqu (%rdi), %xmm0 # sched: [1:0.50]
; HASWELL-NEXT:    retq # sched: [2:1.00]
;
; SKYLAKE-LABEL: test_lddqu:
; SKYLAKE:       # BB#0:
; SKYLAKE-NEXT:    vlddqu (%rdi), %xmm0 # sched: [1:0.50]
; SKYLAKE-NEXT:    retq # sched: [2:1.00]
;
; BTVER2-LABEL: test_lddqu:
; BTVER2:       # BB#0:
; BTVER2-NEXT:    vlddqu (%rdi), %xmm0 # sched: [5:1.00]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; ZNVER1-LABEL: test_lddqu:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    vlddqu (%rdi), %xmm0 # sched: [8:0.50]
; ZNVER1-NEXT:    retq # sched: [1:0.50]
  %1 = call <16 x i8> @llvm.x86.sse3.ldu.dq(i8* %a0)
  ret <16 x i8> %1
}
declare <16 x i8> @llvm.x86.sse3.ldu.dq(i8*) nounwind readonly

define void @test_monitor(i8* %a0, i32 %a1, i32 %a2) {
; GENERIC-LABEL: test_monitor:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    leaq (%rdi), %rax # sched: [1:0.50]
; GENERIC-NEXT:    movl %esi, %ecx # sched: [1:0.33]
; GENERIC-NEXT:    monitor # sched: [100:0.33]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; ATOM-LABEL: test_monitor:
; ATOM:       # BB#0:
; ATOM-NEXT:    leaq (%rdi), %rax # sched: [1:1.00]
; ATOM-NEXT:    movl %esi, %ecx # sched: [1:0.50]
; ATOM-NEXT:    monitor # sched: [45:22.50]
; ATOM-NEXT:    retq # sched: [79:39.50]
;
; SLM-LABEL: test_monitor:
; SLM:       # BB#0:
; SLM-NEXT:    leaq (%rdi), %rax # sched: [1:1.00]
; SLM-NEXT:    movl %esi, %ecx # sched: [1:0.50]
; SLM-NEXT:    monitor # sched: [100:1.00]
; SLM-NEXT:    retq # sched: [4:1.00]
;
; SANDY-LABEL: test_monitor:
; SANDY:       # BB#0:
; SANDY-NEXT:    leaq (%rdi), %rax # sched: [1:0.50]
; SANDY-NEXT:    movl %esi, %ecx # sched: [1:0.33]
; SANDY-NEXT:    monitor # sched: [100:0.33]
; SANDY-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_monitor:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    leaq (%rdi), %rax # sched: [1:0.50]
; HASWELL-NEXT:    movl %esi, %ecx # sched: [1:0.25]
; HASWELL-NEXT:    monitor # sched: [100:0.25]
; HASWELL-NEXT:    retq # sched: [2:1.00]
;
; SKYLAKE-LABEL: test_monitor:
; SKYLAKE:       # BB#0:
; SKYLAKE-NEXT:    leaq (%rdi), %rax # sched: [1:0.50]
; SKYLAKE-NEXT:    movl %esi, %ecx # sched: [1:0.25]
; SKYLAKE-NEXT:    monitor # sched: [100:0.25]
; SKYLAKE-NEXT:    retq # sched: [2:1.00]
;
; BTVER2-LABEL: test_monitor:
; BTVER2:       # BB#0:
; BTVER2-NEXT:    leaq (%rdi), %rax # sched: [1:0.50]
; BTVER2-NEXT:    movl %esi, %ecx # sched: [1:0.17]
; BTVER2-NEXT:    monitor # sched: [100:0.17]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; ZNVER1-LABEL: test_monitor:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    leaq (%rdi), %rax # sched: [1:0.25]
; ZNVER1-NEXT:    movl %esi, %ecx # sched: [1:0.25]
; ZNVER1-NEXT:    monitor # sched: [100:?]
; ZNVER1-NEXT:    retq # sched: [1:0.50]
  tail call void @llvm.x86.sse3.monitor(i8* %a0, i32 %a1, i32 %a2)
  ret void
}
declare void @llvm.x86.sse3.monitor(i8*, i32, i32)

define <2 x double> @test_movddup(<2 x double> %a0, <2 x double> *%a1) {
; GENERIC-LABEL: test_movddup:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    movddup {{.*#+}} xmm1 = xmm0[0,0] sched: [1:1.00]
; GENERIC-NEXT:    movddup {{.*#+}} xmm0 = mem[0,0] sched: [6:0.50]
; GENERIC-NEXT:    addpd %xmm1, %xmm0 # sched: [3:1.00]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; ATOM-LABEL: test_movddup:
; ATOM:       # BB#0:
; ATOM-NEXT:    movddup {{.*#+}} xmm1 = mem[0,0] sched: [1:1.00]
; ATOM-NEXT:    movddup {{.*#+}} xmm0 = xmm0[0,0] sched: [1:1.00]
; ATOM-NEXT:    addpd %xmm0, %xmm1 # sched: [6:3.00]
; ATOM-NEXT:    movapd %xmm1, %xmm0 # sched: [1:0.50]
; ATOM-NEXT:    retq # sched: [79:39.50]
;
; SLM-LABEL: test_movddup:
; SLM:       # BB#0:
; SLM-NEXT:    movddup {{.*#+}} xmm1 = xmm0[0,0] sched: [1:1.00]
; SLM-NEXT:    movddup {{.*#+}} xmm0 = mem[0,0] sched: [3:1.00]
; SLM-NEXT:    addpd %xmm1, %xmm0 # sched: [3:1.00]
; SLM-NEXT:    retq # sched: [4:1.00]
;
; SANDY-LABEL: test_movddup:
; SANDY:       # BB#0:
; SANDY-NEXT:    vmovddup {{.*#+}} xmm0 = xmm0[0,0] sched: [1:1.00]
; SANDY-NEXT:    vmovddup {{.*#+}} xmm1 = mem[0,0] sched: [6:0.50]
; SANDY-NEXT:    vaddpd %xmm1, %xmm0, %xmm0 # sched: [3:1.00]
; SANDY-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_movddup:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    vmovddup {{.*#+}} xmm0 = xmm0[0,0] sched: [1:1.00]
; HASWELL-NEXT:    vmovddup {{.*#+}} xmm1 = mem[0,0] sched: [1:0.50]
; HASWELL-NEXT:    vaddpd %xmm1, %xmm0, %xmm0 # sched: [3:1.00]
; HASWELL-NEXT:    retq # sched: [2:1.00]
;
; SKYLAKE-LABEL: test_movddup:
; SKYLAKE:       # BB#0:
; SKYLAKE-NEXT:    vmovddup {{.*#+}} xmm0 = xmm0[0,0] sched: [1:1.00]
; SKYLAKE-NEXT:    vmovddup {{.*#+}} xmm1 = mem[0,0] sched: [1:0.50]
; SKYLAKE-NEXT:    vaddpd %xmm1, %xmm0, %xmm0 # sched: [4:0.50]
; SKYLAKE-NEXT:    retq # sched: [2:1.00]
;
; BTVER2-LABEL: test_movddup:
; BTVER2:       # BB#0:
; BTVER2-NEXT:    vmovddup {{.*#+}} xmm1 = mem[0,0] sched: [5:1.00]
; BTVER2-NEXT:    vmovddup {{.*#+}} xmm0 = xmm0[0,0] sched: [1:0.50]
; BTVER2-NEXT:    vaddpd %xmm1, %xmm0, %xmm0 # sched: [3:1.00]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; ZNVER1-LABEL: test_movddup:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    vmovddup {{.*#+}} xmm1 = mem[0,0] sched: [8:0.50]
; ZNVER1-NEXT:    vmovddup {{.*#+}} xmm0 = xmm0[0,0] sched: [1:0.50]
; ZNVER1-NEXT:    vaddpd %xmm1, %xmm0, %xmm0 # sched: [3:1.00]
; ZNVER1-NEXT:    retq # sched: [1:0.50]
  %1 = shufflevector <2 x double> %a0, <2 x double> undef, <2 x i32> zeroinitializer
  %2 = load <2 x double>, <2 x double> *%a1, align 16
  %3 = shufflevector <2 x double> %2, <2 x double> undef, <2 x i32> zeroinitializer
  %4 = fadd <2 x double> %1, %3
  ret <2 x double> %4
}

define <4 x float> @test_movshdup(<4 x float> %a0, <4 x float> *%a1) {
; GENERIC-LABEL: test_movshdup:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    movshdup {{.*#+}} xmm1 = xmm0[1,1,3,3] sched: [1:1.00]
; GENERIC-NEXT:    movshdup {{.*#+}} xmm0 = mem[1,1,3,3] sched: [6:0.50]
; GENERIC-NEXT:    addps %xmm1, %xmm0 # sched: [3:1.00]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; ATOM-LABEL: test_movshdup:
; ATOM:       # BB#0:
; ATOM-NEXT:    movshdup {{.*#+}} xmm1 = mem[1,1,3,3] sched: [1:1.00]
; ATOM-NEXT:    movshdup {{.*#+}} xmm0 = xmm0[1,1,3,3] sched: [1:1.00]
; ATOM-NEXT:    addps %xmm0, %xmm1 # sched: [5:5.00]
; ATOM-NEXT:    movaps %xmm1, %xmm0 # sched: [1:0.50]
; ATOM-NEXT:    retq # sched: [79:39.50]
;
; SLM-LABEL: test_movshdup:
; SLM:       # BB#0:
; SLM-NEXT:    movshdup {{.*#+}} xmm1 = xmm0[1,1,3,3] sched: [1:1.00]
; SLM-NEXT:    movshdup {{.*#+}} xmm0 = mem[1,1,3,3] sched: [3:1.00]
; SLM-NEXT:    addps %xmm1, %xmm0 # sched: [3:1.00]
; SLM-NEXT:    retq # sched: [4:1.00]
;
; SANDY-LABEL: test_movshdup:
; SANDY:       # BB#0:
; SANDY-NEXT:    vmovshdup {{.*#+}} xmm0 = xmm0[1,1,3,3] sched: [1:1.00]
; SANDY-NEXT:    vmovshdup {{.*#+}} xmm1 = mem[1,1,3,3] sched: [6:0.50]
; SANDY-NEXT:    vaddps %xmm1, %xmm0, %xmm0 # sched: [3:1.00]
; SANDY-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_movshdup:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    vmovshdup {{.*#+}} xmm0 = xmm0[1,1,3,3] sched: [1:1.00]
; HASWELL-NEXT:    vmovshdup {{.*#+}} xmm1 = mem[1,1,3,3] sched: [1:0.50]
; HASWELL-NEXT:    vaddps %xmm1, %xmm0, %xmm0 # sched: [3:1.00]
; HASWELL-NEXT:    retq # sched: [2:1.00]
;
; SKYLAKE-LABEL: test_movshdup:
; SKYLAKE:       # BB#0:
; SKYLAKE-NEXT:    vmovshdup {{.*#+}} xmm0 = xmm0[1,1,3,3] sched: [1:1.00]
; SKYLAKE-NEXT:    vmovshdup {{.*#+}} xmm1 = mem[1,1,3,3] sched: [1:0.50]
; SKYLAKE-NEXT:    vaddps %xmm1, %xmm0, %xmm0 # sched: [4:0.50]
; SKYLAKE-NEXT:    retq # sched: [2:1.00]
;
; BTVER2-LABEL: test_movshdup:
; BTVER2:       # BB#0:
; BTVER2-NEXT:    vmovshdup {{.*#+}} xmm1 = mem[1,1,3,3] sched: [5:1.00]
; BTVER2-NEXT:    vmovshdup {{.*#+}} xmm0 = xmm0[1,1,3,3] sched: [1:0.50]
; BTVER2-NEXT:    vaddps %xmm1, %xmm0, %xmm0 # sched: [3:1.00]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; ZNVER1-LABEL: test_movshdup:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    vmovshdup {{.*#+}} xmm1 = mem[1,1,3,3] sched: [8:0.50]
; ZNVER1-NEXT:    vmovshdup {{.*#+}} xmm0 = xmm0[1,1,3,3] sched: [1:0.50]
; ZNVER1-NEXT:    vaddps %xmm1, %xmm0, %xmm0 # sched: [3:1.00]
; ZNVER1-NEXT:    retq # sched: [1:0.50]
  %1 = shufflevector <4 x float> %a0, <4 x float> undef, <4 x i32> <i32 1, i32 1, i32 3, i32 3>
  %2 = load <4 x float>, <4 x float> *%a1, align 16
  %3 = shufflevector <4 x float> %2, <4 x float> undef, <4 x i32> <i32 1, i32 1, i32 3, i32 3>
  %4 = fadd <4 x float> %1, %3
  ret <4 x float> %4
}

define <4 x float> @test_movsldup(<4 x float> %a0, <4 x float> *%a1) {
; GENERIC-LABEL: test_movsldup:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    movsldup {{.*#+}} xmm1 = xmm0[0,0,2,2] sched: [1:1.00]
; GENERIC-NEXT:    movsldup {{.*#+}} xmm0 = mem[0,0,2,2] sched: [6:0.50]
; GENERIC-NEXT:    addps %xmm1, %xmm0 # sched: [3:1.00]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; ATOM-LABEL: test_movsldup:
; ATOM:       # BB#0:
; ATOM-NEXT:    movsldup {{.*#+}} xmm1 = mem[0,0,2,2] sched: [1:1.00]
; ATOM-NEXT:    movsldup {{.*#+}} xmm0 = xmm0[0,0,2,2] sched: [1:1.00]
; ATOM-NEXT:    addps %xmm0, %xmm1 # sched: [5:5.00]
; ATOM-NEXT:    movaps %xmm1, %xmm0 # sched: [1:0.50]
; ATOM-NEXT:    retq # sched: [79:39.50]
;
; SLM-LABEL: test_movsldup:
; SLM:       # BB#0:
; SLM-NEXT:    movsldup {{.*#+}} xmm1 = xmm0[0,0,2,2] sched: [1:1.00]
; SLM-NEXT:    movsldup {{.*#+}} xmm0 = mem[0,0,2,2] sched: [3:1.00]
; SLM-NEXT:    addps %xmm1, %xmm0 # sched: [3:1.00]
; SLM-NEXT:    retq # sched: [4:1.00]
;
; SANDY-LABEL: test_movsldup:
; SANDY:       # BB#0:
; SANDY-NEXT:    vmovsldup {{.*#+}} xmm0 = xmm0[0,0,2,2] sched: [1:1.00]
; SANDY-NEXT:    vmovsldup {{.*#+}} xmm1 = mem[0,0,2,2] sched: [6:0.50]
; SANDY-NEXT:    vaddps %xmm1, %xmm0, %xmm0 # sched: [3:1.00]
; SANDY-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_movsldup:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    vmovsldup {{.*#+}} xmm0 = xmm0[0,0,2,2] sched: [1:1.00]
; HASWELL-NEXT:    vmovsldup {{.*#+}} xmm1 = mem[0,0,2,2] sched: [1:0.50]
; HASWELL-NEXT:    vaddps %xmm1, %xmm0, %xmm0 # sched: [3:1.00]
; HASWELL-NEXT:    retq # sched: [2:1.00]
;
; SKYLAKE-LABEL: test_movsldup:
; SKYLAKE:       # BB#0:
; SKYLAKE-NEXT:    vmovsldup {{.*#+}} xmm0 = xmm0[0,0,2,2] sched: [1:1.00]
; SKYLAKE-NEXT:    vmovsldup {{.*#+}} xmm1 = mem[0,0,2,2] sched: [1:0.50]
; SKYLAKE-NEXT:    vaddps %xmm1, %xmm0, %xmm0 # sched: [4:0.50]
; SKYLAKE-NEXT:    retq # sched: [2:1.00]
;
; BTVER2-LABEL: test_movsldup:
; BTVER2:       # BB#0:
; BTVER2-NEXT:    vmovsldup {{.*#+}} xmm1 = mem[0,0,2,2] sched: [5:1.00]
; BTVER2-NEXT:    vmovsldup {{.*#+}} xmm0 = xmm0[0,0,2,2] sched: [1:0.50]
; BTVER2-NEXT:    vaddps %xmm1, %xmm0, %xmm0 # sched: [3:1.00]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; ZNVER1-LABEL: test_movsldup:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    vmovsldup {{.*#+}} xmm1 = mem[0,0,2,2] sched: [8:0.50]
; ZNVER1-NEXT:    vmovsldup {{.*#+}} xmm0 = xmm0[0,0,2,2] sched: [1:0.50]
; ZNVER1-NEXT:    vaddps %xmm1, %xmm0, %xmm0 # sched: [3:1.00]
; ZNVER1-NEXT:    retq # sched: [1:0.50]
  %1 = shufflevector <4 x float> %a0, <4 x float> undef, <4 x i32> <i32 0, i32 0, i32 2, i32 2>
  %2 = load <4 x float>, <4 x float> *%a1, align 16
  %3 = shufflevector <4 x float> %2, <4 x float> undef, <4 x i32> <i32 0, i32 0, i32 2, i32 2>
  %4 = fadd <4 x float> %1, %3
  ret <4 x float> %4
}

define void @test_mwait(i32 %a0, i32 %a1) {
; GENERIC-LABEL: test_mwait:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    movl %edi, %ecx # sched: [1:0.33]
; GENERIC-NEXT:    movl %esi, %eax # sched: [1:0.33]
; GENERIC-NEXT:    mwait # sched: [100:0.33]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; ATOM-LABEL: test_mwait:
; ATOM:       # BB#0:
; ATOM-NEXT:    movl %edi, %ecx # sched: [1:0.50]
; ATOM-NEXT:    movl %esi, %eax # sched: [1:0.50]
; ATOM-NEXT:    mwait # sched: [46:23.00]
; ATOM-NEXT:    retq # sched: [79:39.50]
;
; SLM-LABEL: test_mwait:
; SLM:       # BB#0:
; SLM-NEXT:    movl %edi, %ecx # sched: [1:0.50]
; SLM-NEXT:    movl %esi, %eax # sched: [1:0.50]
; SLM-NEXT:    mwait # sched: [100:1.00]
; SLM-NEXT:    retq # sched: [4:1.00]
;
; SANDY-LABEL: test_mwait:
; SANDY:       # BB#0:
; SANDY-NEXT:    movl %edi, %ecx # sched: [1:0.33]
; SANDY-NEXT:    movl %esi, %eax # sched: [1:0.33]
; SANDY-NEXT:    mwait # sched: [100:0.33]
; SANDY-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_mwait:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    movl %edi, %ecx # sched: [1:0.25]
; HASWELL-NEXT:    movl %esi, %eax # sched: [1:0.25]
; HASWELL-NEXT:    mwait # sched: [20:2.50]
; HASWELL-NEXT:    retq # sched: [2:1.00]
;
; SKYLAKE-LABEL: test_mwait:
; SKYLAKE:       # BB#0:
; SKYLAKE-NEXT:    movl %edi, %ecx # sched: [1:0.25]
; SKYLAKE-NEXT:    movl %esi, %eax # sched: [1:0.25]
; SKYLAKE-NEXT:    mwait # sched: [20:2.50]
; SKYLAKE-NEXT:    retq # sched: [2:1.00]
;
; BTVER2-LABEL: test_mwait:
; BTVER2:       # BB#0:
; BTVER2-NEXT:    movl %edi, %ecx # sched: [1:0.17]
; BTVER2-NEXT:    movl %esi, %eax # sched: [1:0.17]
; BTVER2-NEXT:    mwait # sched: [100:0.17]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; ZNVER1-LABEL: test_mwait:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    movl %edi, %ecx # sched: [1:0.25]
; ZNVER1-NEXT:    movl %esi, %eax # sched: [1:0.25]
; ZNVER1-NEXT:    mwait # sched: [100:?]
; ZNVER1-NEXT:    retq # sched: [1:0.50]
  tail call void @llvm.x86.sse3.mwait(i32 %a0, i32 %a1)
  ret void
}
declare void @llvm.x86.sse3.mwait(i32, i32)
