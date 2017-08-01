; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=x86-64 -mattr=+avx2 | FileCheck %s --check-prefix=CHECK --check-prefix=GENERIC
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=haswell | FileCheck %s --check-prefix=CHECK --check-prefix=HASWELL
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=skylake | FileCheck %s --check-prefix=CHECK --check-prefix=HASWELL
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=znver1 | FileCheck %s --check-prefix=CHECK --check-prefix=ZNVER1

define <32 x i8> @test_pabsb(<32 x i8> %a0, <32 x i8> *%a1) {
; GENERIC-LABEL: test_pabsb:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    vpabsb %ymm0, %ymm0 # sched: [3:1.00]
; GENERIC-NEXT:    vpabsb (%rdi), %ymm1 # sched: [7:1.00]
; GENERIC-NEXT:    vpor %ymm1, %ymm0, %ymm0 # sched: [1:1.00]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_pabsb:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    vpabsb %ymm0, %ymm0 # sched: [1:0.50]
; HASWELL-NEXT:    vpabsb (%rdi), %ymm1 # sched: [5:0.50]
; HASWELL-NEXT:    vpor %ymm1, %ymm0, %ymm0 # sched: [1:0.33]
; HASWELL-NEXT:    retq # sched: [1:1.00]
;
; ZNVER1-LABEL: test_pabsb:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    vpabsb (%rdi), %ymm1 # sched: [8:0.50]
; ZNVER1-NEXT:    vpabsb %ymm0, %ymm0 # sched: [1:0.25]
; ZNVER1-NEXT:    vpor %ymm1, %ymm0, %ymm0 # sched: [1:0.25]
; ZNVER1-NEXT:    retq # sched: [5:0.50]
  %1 = call <32 x i8> @llvm.x86.avx2.pabs.b(<32 x i8> %a0)
  %2 = load <32 x i8>, <32 x i8> *%a1, align 32
  %3 = call <32 x i8> @llvm.x86.avx2.pabs.b(<32 x i8> %2)
  %4 = or <32 x i8> %1, %3
  ret <32 x i8> %4
}
declare <32 x i8> @llvm.x86.avx2.pabs.b(<32 x i8>) nounwind readnone

define <8 x i32> @test_pabsd(<8 x i32> %a0, <8 x i32> *%a1) {
; GENERIC-LABEL: test_pabsd:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    vpabsd %ymm0, %ymm0 # sched: [3:1.00]
; GENERIC-NEXT:    vpabsd (%rdi), %ymm1 # sched: [7:1.00]
; GENERIC-NEXT:    vpor %ymm1, %ymm0, %ymm0 # sched: [1:1.00]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_pabsd:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    vpabsd %ymm0, %ymm0 # sched: [1:0.50]
; HASWELL-NEXT:    vpabsd (%rdi), %ymm1 # sched: [5:0.50]
; HASWELL-NEXT:    vpor %ymm1, %ymm0, %ymm0 # sched: [1:0.33]
; HASWELL-NEXT:    retq # sched: [1:1.00]
;
; ZNVER1-LABEL: test_pabsd:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    vpabsd (%rdi), %ymm1 # sched: [8:0.50]
; ZNVER1-NEXT:    vpabsd %ymm0, %ymm0 # sched: [1:0.25]
; ZNVER1-NEXT:    vpor %ymm1, %ymm0, %ymm0 # sched: [1:0.25]
; ZNVER1-NEXT:    retq # sched: [5:0.50]
  %1 = call <8 x i32> @llvm.x86.avx2.pabs.d(<8 x i32> %a0)
  %2 = load <8 x i32>, <8 x i32> *%a1, align 32
  %3 = call <8 x i32> @llvm.x86.avx2.pabs.d(<8 x i32> %2)
  %4 = or <8 x i32> %1, %3
  ret <8 x i32> %4
}
declare <8 x i32> @llvm.x86.avx2.pabs.d(<8 x i32>) nounwind readnone

define <16 x i16> @test_pabsw(<16 x i16> %a0, <16 x i16> *%a1) {
; GENERIC-LABEL: test_pabsw:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    vpabsw %ymm0, %ymm0 # sched: [3:1.00]
; GENERIC-NEXT:    vpabsw (%rdi), %ymm1 # sched: [7:1.00]
; GENERIC-NEXT:    vpor %ymm1, %ymm0, %ymm0 # sched: [1:1.00]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_pabsw:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    vpabsw %ymm0, %ymm0 # sched: [1:0.50]
; HASWELL-NEXT:    vpabsw (%rdi), %ymm1 # sched: [5:0.50]
; HASWELL-NEXT:    vpor %ymm1, %ymm0, %ymm0 # sched: [1:0.33]
; HASWELL-NEXT:    retq # sched: [1:1.00]
;
; ZNVER1-LABEL: test_pabsw:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    vpabsw (%rdi), %ymm1 # sched: [8:0.50]
; ZNVER1-NEXT:    vpabsw %ymm0, %ymm0 # sched: [1:0.25]
; ZNVER1-NEXT:    vpor %ymm1, %ymm0, %ymm0 # sched: [1:0.25]
; ZNVER1-NEXT:    retq # sched: [5:0.50]
  %1 = call <16 x i16> @llvm.x86.avx2.pabs.w(<16 x i16> %a0)
  %2 = load <16 x i16>, <16 x i16> *%a1, align 32
  %3 = call <16 x i16> @llvm.x86.avx2.pabs.w(<16 x i16> %2)
  %4 = or <16 x i16> %1, %3
  ret <16 x i16> %4
}
declare <16 x i16> @llvm.x86.avx2.pabs.w(<16 x i16>) nounwind readnone

define <32 x i8> @test_paddb(<32 x i8> %a0, <32 x i8> %a1, <32 x i8> *%a2) {
; GENERIC-LABEL: test_paddb:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    vpaddb %ymm1, %ymm0, %ymm0 # sched: [3:1.00]
; GENERIC-NEXT:    vpaddb (%rdi), %ymm0, %ymm0 # sched: [7:1.00]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_paddb:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    vpaddb %ymm1, %ymm0, %ymm0 # sched: [1:0.50]
; HASWELL-NEXT:    vpaddb (%rdi), %ymm0, %ymm0 # sched: [5:0.50]
; HASWELL-NEXT:    retq # sched: [1:1.00]
;
; ZNVER1-LABEL: test_paddb:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    vpaddb %ymm1, %ymm0, %ymm0 # sched: [1:0.25]
; ZNVER1-NEXT:    vpaddb (%rdi), %ymm0, %ymm0 # sched: [8:0.50]
; ZNVER1-NEXT:    retq # sched: [5:0.50]
  %1 = add <32 x i8> %a0, %a1
  %2 = load <32 x i8>, <32 x i8> *%a2, align 32
  %3 = add <32 x i8> %1, %2
  ret <32 x i8> %3
}

define <8 x i32> @test_paddd(<8 x i32> %a0, <8 x i32> %a1, <8 x i32> *%a2) {
; GENERIC-LABEL: test_paddd:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    vpaddd %ymm1, %ymm0, %ymm0 # sched: [3:1.00]
; GENERIC-NEXT:    vpaddd (%rdi), %ymm0, %ymm0 # sched: [7:1.00]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_paddd:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    vpaddd %ymm1, %ymm0, %ymm0 # sched: [1:0.50]
; HASWELL-NEXT:    vpaddd (%rdi), %ymm0, %ymm0 # sched: [5:0.50]
; HASWELL-NEXT:    retq # sched: [1:1.00]
;
; ZNVER1-LABEL: test_paddd:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    vpaddd %ymm1, %ymm0, %ymm0 # sched: [1:0.25]
; ZNVER1-NEXT:    vpaddd (%rdi), %ymm0, %ymm0 # sched: [8:0.50]
; ZNVER1-NEXT:    retq # sched: [5:0.50]
  %1 = add <8 x i32> %a0, %a1
  %2 = load <8 x i32>, <8 x i32> *%a2, align 32
  %3 = add <8 x i32> %1, %2
  ret <8 x i32> %3
}

define <4 x i64> @test_paddq(<4 x i64> %a0, <4 x i64> %a1, <4 x i64> *%a2) {
; GENERIC-LABEL: test_paddq:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    vpaddq %ymm1, %ymm0, %ymm0 # sched: [3:1.00]
; GENERIC-NEXT:    vpaddq (%rdi), %ymm0, %ymm0 # sched: [7:1.00]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_paddq:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    vpaddq %ymm1, %ymm0, %ymm0 # sched: [1:0.50]
; HASWELL-NEXT:    vpaddq (%rdi), %ymm0, %ymm0 # sched: [5:0.50]
; HASWELL-NEXT:    retq # sched: [1:1.00]
;
; ZNVER1-LABEL: test_paddq:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    vpaddq %ymm1, %ymm0, %ymm0 # sched: [1:0.25]
; ZNVER1-NEXT:    vpaddq (%rdi), %ymm0, %ymm0 # sched: [8:0.50]
; ZNVER1-NEXT:    retq # sched: [5:0.50]
  %1 = add <4 x i64> %a0, %a1
  %2 = load <4 x i64>, <4 x i64> *%a2, align 32
  %3 = add <4 x i64> %1, %2
  ret <4 x i64> %3
}

define <16 x i16> @test_paddw(<16 x i16> %a0, <16 x i16> %a1, <16 x i16> *%a2) {
; GENERIC-LABEL: test_paddw:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    vpaddw %ymm1, %ymm0, %ymm0 # sched: [3:1.00]
; GENERIC-NEXT:    vpaddw (%rdi), %ymm0, %ymm0 # sched: [7:1.00]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_paddw:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    vpaddw %ymm1, %ymm0, %ymm0 # sched: [1:0.50]
; HASWELL-NEXT:    vpaddw (%rdi), %ymm0, %ymm0 # sched: [5:0.50]
; HASWELL-NEXT:    retq # sched: [1:1.00]
;
; ZNVER1-LABEL: test_paddw:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    vpaddw %ymm1, %ymm0, %ymm0 # sched: [1:0.25]
; ZNVER1-NEXT:    vpaddw (%rdi), %ymm0, %ymm0 # sched: [8:0.50]
; ZNVER1-NEXT:    retq # sched: [5:0.50]
  %1 = add <16 x i16> %a0, %a1
  %2 = load <16 x i16>, <16 x i16> *%a2, align 32
  %3 = add <16 x i16> %1, %2
  ret <16 x i16> %3
}

define <4 x i64> @test_pand(<4 x i64> %a0, <4 x i64> %a1, <4 x i64> *%a2) {
; GENERIC-LABEL: test_pand:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    vpand %ymm1, %ymm0, %ymm0 # sched: [1:1.00]
; GENERIC-NEXT:    vpand (%rdi), %ymm0, %ymm0 # sched: [5:1.00]
; GENERIC-NEXT:    vpaddq %ymm1, %ymm0, %ymm0 # sched: [3:1.00]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_pand:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    vpand %ymm1, %ymm0, %ymm0 # sched: [1:0.33]
; HASWELL-NEXT:    vpand (%rdi), %ymm0, %ymm0 # sched: [5:0.50]
; HASWELL-NEXT:    vpaddq %ymm1, %ymm0, %ymm0 # sched: [1:0.50]
; HASWELL-NEXT:    retq # sched: [1:1.00]
;
; ZNVER1-LABEL: test_pand:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    vpand %ymm1, %ymm0, %ymm0 # sched: [1:0.25]
; ZNVER1-NEXT:    vpand (%rdi), %ymm0, %ymm0 # sched: [8:0.50]
; ZNVER1-NEXT:    vpaddq %ymm1, %ymm0, %ymm0 # sched: [1:0.25]
; ZNVER1-NEXT:    retq # sched: [5:0.50]
  %1 = and <4 x i64> %a0, %a1
  %2 = load <4 x i64>, <4 x i64> *%a2, align 32
  %3 = and <4 x i64> %1, %2
  %4 = add <4 x i64> %3, %a1
  ret <4 x i64> %4
}

define <4 x i64> @test_pandn(<4 x i64> %a0, <4 x i64> %a1, <4 x i64> *%a2) {
; GENERIC-LABEL: test_pandn:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    vpandn %ymm1, %ymm0, %ymm0 # sched: [1:1.00]
; GENERIC-NEXT:    vpandn (%rdi), %ymm0, %ymm1 # sched: [5:1.00]
; GENERIC-NEXT:    vpaddq %ymm1, %ymm0, %ymm0 # sched: [3:1.00]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_pandn:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    vpandn %ymm1, %ymm0, %ymm0 # sched: [1:0.33]
; HASWELL-NEXT:    vpandn (%rdi), %ymm0, %ymm1 # sched: [5:0.50]
; HASWELL-NEXT:    vpaddq %ymm1, %ymm0, %ymm0 # sched: [1:0.50]
; HASWELL-NEXT:    retq # sched: [1:1.00]
;
; ZNVER1-LABEL: test_pandn:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    vpandn %ymm1, %ymm0, %ymm0 # sched: [1:0.25]
; ZNVER1-NEXT:    vpandn (%rdi), %ymm0, %ymm1 # sched: [8:0.50]
; ZNVER1-NEXT:    vpaddq %ymm1, %ymm0, %ymm0 # sched: [1:0.25]
; ZNVER1-NEXT:    retq # sched: [5:0.50]
  %1 = xor <4 x i64> %a0, <i64 -1, i64 -1, i64 -1, i64 -1>
  %2 = and <4 x i64> %a1, %1
  %3 = load <4 x i64>, <4 x i64> *%a2, align 32
  %4 = xor <4 x i64> %2, <i64 -1, i64 -1, i64 -1, i64 -1>
  %5 = and <4 x i64> %3, %4
  %6 = add <4 x i64> %2, %5
  ret <4 x i64> %6
}

define <8 x i32> @test_pmulld(<8 x i32> %a0, <8 x i32> %a1, <8 x i32> *%a2) {
; GENERIC-LABEL: test_pmulld:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    vpmulld %ymm1, %ymm0, %ymm0 # sched: [5:1.00]
; GENERIC-NEXT:    vpmulld (%rdi), %ymm0, %ymm0 # sched: [9:1.00]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_pmulld:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    vpmulld %ymm1, %ymm0, %ymm0 # sched: [10:2.00]
; HASWELL-NEXT:    vpmulld (%rdi), %ymm0, %ymm0 # sched: [10:2.00]
; HASWELL-NEXT:    retq # sched: [1:1.00]
;
; ZNVER1-LABEL: test_pmulld:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    vpmulld %ymm1, %ymm0, %ymm0 # sched: [4:1.00]
; ZNVER1-NEXT:    vpmulld (%rdi), %ymm0, %ymm0 # sched: [11:1.00]
; ZNVER1-NEXT:    retq # sched: [5:0.50]
  %1 = mul <8 x i32> %a0, %a1
  %2 = load <8 x i32>, <8 x i32> *%a2, align 32
  %3 = mul <8 x i32> %1, %2
  ret <8 x i32> %3
}

define <16 x i16> @test_pmullw(<16 x i16> %a0, <16 x i16> %a1, <16 x i16> *%a2) {
; GENERIC-LABEL: test_pmullw:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    vpmullw %ymm1, %ymm0, %ymm0 # sched: [5:1.00]
; GENERIC-NEXT:    vpmullw (%rdi), %ymm0, %ymm0 # sched: [9:1.00]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_pmullw:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    vpmullw %ymm1, %ymm0, %ymm0 # sched: [5:1.00]
; HASWELL-NEXT:    vpmullw (%rdi), %ymm0, %ymm0 # sched: [9:1.00]
; HASWELL-NEXT:    retq # sched: [1:1.00]
;
; ZNVER1-LABEL: test_pmullw:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    vpmullw %ymm1, %ymm0, %ymm0 # sched: [4:1.00]
; ZNVER1-NEXT:    vpmullw (%rdi), %ymm0, %ymm0 # sched: [11:1.00]
; ZNVER1-NEXT:    retq # sched: [5:0.50]
  %1 = mul <16 x i16> %a0, %a1
  %2 = load <16 x i16>, <16 x i16> *%a2, align 32
  %3 = mul <16 x i16> %1, %2
  ret <16 x i16> %3
}

define <4 x i64> @test_por(<4 x i64> %a0, <4 x i64> %a1, <4 x i64> *%a2) {
; GENERIC-LABEL: test_por:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    vpor %ymm1, %ymm0, %ymm0 # sched: [1:1.00]
; GENERIC-NEXT:    vpor (%rdi), %ymm0, %ymm0 # sched: [5:1.00]
; GENERIC-NEXT:    vpaddq %ymm1, %ymm0, %ymm0 # sched: [3:1.00]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_por:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    vpor %ymm1, %ymm0, %ymm0 # sched: [1:0.33]
; HASWELL-NEXT:    vpor (%rdi), %ymm0, %ymm0 # sched: [5:0.50]
; HASWELL-NEXT:    vpaddq %ymm1, %ymm0, %ymm0 # sched: [1:0.50]
; HASWELL-NEXT:    retq # sched: [1:1.00]
;
; ZNVER1-LABEL: test_por:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    vpor %ymm1, %ymm0, %ymm0 # sched: [1:0.25]
; ZNVER1-NEXT:    vpor (%rdi), %ymm0, %ymm0 # sched: [8:0.50]
; ZNVER1-NEXT:    vpaddq %ymm1, %ymm0, %ymm0 # sched: [1:0.25]
; ZNVER1-NEXT:    retq # sched: [5:0.50]
  %1 = or <4 x i64> %a0, %a1
  %2 = load <4 x i64>, <4 x i64> *%a2, align 32
  %3 = or <4 x i64> %1, %2
  %4 = add <4 x i64> %3, %a1
  ret <4 x i64> %4
}

define <32 x i8> @test_psubb(<32 x i8> %a0, <32 x i8> %a1, <32 x i8> *%a2) {
; GENERIC-LABEL: test_psubb:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    vpsubb %ymm1, %ymm0, %ymm0 # sched: [3:1.00]
; GENERIC-NEXT:    vpsubb (%rdi), %ymm0, %ymm0 # sched: [7:1.00]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_psubb:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    vpsubb %ymm1, %ymm0, %ymm0 # sched: [1:0.50]
; HASWELL-NEXT:    vpsubb (%rdi), %ymm0, %ymm0 # sched: [5:0.50]
; HASWELL-NEXT:    retq # sched: [1:1.00]
;
; ZNVER1-LABEL: test_psubb:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    vpsubb %ymm1, %ymm0, %ymm0 # sched: [1:0.25]
; ZNVER1-NEXT:    vpsubb (%rdi), %ymm0, %ymm0 # sched: [8:0.50]
; ZNVER1-NEXT:    retq # sched: [5:0.50]
  %1 = sub <32 x i8> %a0, %a1
  %2 = load <32 x i8>, <32 x i8> *%a2, align 32
  %3 = sub <32 x i8> %1, %2
  ret <32 x i8> %3
}

define <8 x i32> @test_psubd(<8 x i32> %a0, <8 x i32> %a1, <8 x i32> *%a2) {
; GENERIC-LABEL: test_psubd:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    vpsubd %ymm1, %ymm0, %ymm0 # sched: [3:1.00]
; GENERIC-NEXT:    vpsubd (%rdi), %ymm0, %ymm0 # sched: [7:1.00]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_psubd:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    vpsubd %ymm1, %ymm0, %ymm0 # sched: [1:0.50]
; HASWELL-NEXT:    vpsubd (%rdi), %ymm0, %ymm0 # sched: [5:0.50]
; HASWELL-NEXT:    retq # sched: [1:1.00]
;
; ZNVER1-LABEL: test_psubd:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    vpsubd %ymm1, %ymm0, %ymm0 # sched: [1:0.25]
; ZNVER1-NEXT:    vpsubd (%rdi), %ymm0, %ymm0 # sched: [8:0.50]
; ZNVER1-NEXT:    retq # sched: [5:0.50]
  %1 = sub <8 x i32> %a0, %a1
  %2 = load <8 x i32>, <8 x i32> *%a2, align 32
  %3 = sub <8 x i32> %1, %2
  ret <8 x i32> %3
}

define <4 x i64> @test_psubq(<4 x i64> %a0, <4 x i64> %a1, <4 x i64> *%a2) {
; GENERIC-LABEL: test_psubq:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    vpsubq %ymm1, %ymm0, %ymm0 # sched: [3:1.00]
; GENERIC-NEXT:    vpsubq (%rdi), %ymm0, %ymm0 # sched: [7:1.00]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_psubq:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    vpsubq %ymm1, %ymm0, %ymm0 # sched: [1:0.50]
; HASWELL-NEXT:    vpsubq (%rdi), %ymm0, %ymm0 # sched: [5:0.50]
; HASWELL-NEXT:    retq # sched: [1:1.00]
;
; ZNVER1-LABEL: test_psubq:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    vpsubq %ymm1, %ymm0, %ymm0 # sched: [1:0.25]
; ZNVER1-NEXT:    vpsubq (%rdi), %ymm0, %ymm0 # sched: [8:0.50]
; ZNVER1-NEXT:    retq # sched: [5:0.50]
  %1 = sub <4 x i64> %a0, %a1
  %2 = load <4 x i64>, <4 x i64> *%a2, align 32
  %3 = sub <4 x i64> %1, %2
  ret <4 x i64> %3
}

define <16 x i16> @test_psubw(<16 x i16> %a0, <16 x i16> %a1, <16 x i16> *%a2) {
; GENERIC-LABEL: test_psubw:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    vpsubw %ymm1, %ymm0, %ymm0 # sched: [3:1.00]
; GENERIC-NEXT:    vpsubw (%rdi), %ymm0, %ymm0 # sched: [7:1.00]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_psubw:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    vpsubw %ymm1, %ymm0, %ymm0 # sched: [1:0.50]
; HASWELL-NEXT:    vpsubw (%rdi), %ymm0, %ymm0 # sched: [5:0.50]
; HASWELL-NEXT:    retq # sched: [1:1.00]
;
; ZNVER1-LABEL: test_psubw:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    vpsubw %ymm1, %ymm0, %ymm0 # sched: [1:0.25]
; ZNVER1-NEXT:    vpsubw (%rdi), %ymm0, %ymm0 # sched: [8:0.50]
; ZNVER1-NEXT:    retq # sched: [5:0.50]
  %1 = sub <16 x i16> %a0, %a1
  %2 = load <16 x i16>, <16 x i16> *%a2, align 32
  %3 = sub <16 x i16> %1, %2
  ret <16 x i16> %3
}

define <4 x i64> @test_pxor(<4 x i64> %a0, <4 x i64> %a1, <4 x i64> *%a2) {
; GENERIC-LABEL: test_pxor:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    vpxor %ymm1, %ymm0, %ymm0 # sched: [1:1.00]
; GENERIC-NEXT:    vpxor (%rdi), %ymm0, %ymm0 # sched: [5:1.00]
; GENERIC-NEXT:    vpaddq %ymm1, %ymm0, %ymm0 # sched: [3:1.00]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_pxor:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    vpxor %ymm1, %ymm0, %ymm0 # sched: [1:0.33]
; HASWELL-NEXT:    vpxor (%rdi), %ymm0, %ymm0 # sched: [5:0.50]
; HASWELL-NEXT:    vpaddq %ymm1, %ymm0, %ymm0 # sched: [1:0.50]
; HASWELL-NEXT:    retq # sched: [1:1.00]
;
; ZNVER1-LABEL: test_pxor:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    vpxor %ymm1, %ymm0, %ymm0 # sched: [1:0.25]
; ZNVER1-NEXT:    vpxor (%rdi), %ymm0, %ymm0 # sched: [8:0.50]
; ZNVER1-NEXT:    vpaddq %ymm1, %ymm0, %ymm0 # sched: [1:0.25]
; ZNVER1-NEXT:    retq # sched: [5:0.50]
  %1 = xor <4 x i64> %a0, %a1
  %2 = load <4 x i64>, <4 x i64> *%a2, align 32
  %3 = xor <4 x i64> %1, %2
  %4 = add <4 x i64> %3, %a1
  ret <4 x i64> %4
}

!0 = !{i32 1}
