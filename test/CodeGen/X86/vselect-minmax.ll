; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse2 | FileCheck %s --check-prefix=SSE --check-prefix=SSE2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse4.2 | FileCheck %s --check-prefix=SSE --check-prefix=SSE4
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx | FileCheck %s --check-prefix=AVX --check-prefix=AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx2 -mattr=+avx2 | FileCheck %s --check-prefix=AVX --check-prefix=AVX2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=knl | FileCheck %s --check-prefix=AVX --check-prefix=AVX512F
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=skx | FileCheck %s --check-prefix=AVX --check-prefix=AVX512F --check-prefix=AVX512BW --check-prefix=AVX512VL

define <16 x i8> @test1(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: test1:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm1, %xmm2
; SSE2-NEXT:    pcmpgtb %xmm0, %xmm2
; SSE2-NEXT:    pand %xmm2, %xmm0
; SSE2-NEXT:    pandn %xmm1, %xmm2
; SSE2-NEXT:    por %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test1:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminsb %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test1:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpminsb %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp slt <16 x i8> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i8> %a, <16 x i8> %b
  ret <16 x i8> %sel
}

define <16 x i8> @test2(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: test2:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    pcmpgtb %xmm1, %xmm2
; SSE2-NEXT:    pcmpeqd %xmm3, %xmm3
; SSE2-NEXT:    pxor %xmm2, %xmm3
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    pandn %xmm1, %xmm3
; SSE2-NEXT:    por %xmm3, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test2:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminsb %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test2:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpminsb %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp sle <16 x i8> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i8> %a, <16 x i8> %b
  ret <16 x i8> %sel
}

define <16 x i8> @test3(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: test3:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    pcmpgtb %xmm1, %xmm2
; SSE2-NEXT:    pand %xmm2, %xmm0
; SSE2-NEXT:    pandn %xmm1, %xmm2
; SSE2-NEXT:    por %xmm0, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test3:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxsb %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test3:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmaxsb %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp sgt <16 x i8> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i8> %a, <16 x i8> %b
  ret <16 x i8> %sel
}

define <16 x i8> @test4(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: test4:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm1, %xmm3
; SSE2-NEXT:    pcmpgtb %xmm0, %xmm3
; SSE2-NEXT:    pcmpeqd %xmm2, %xmm2
; SSE2-NEXT:    pxor %xmm3, %xmm2
; SSE2-NEXT:    pandn %xmm0, %xmm3
; SSE2-NEXT:    pandn %xmm1, %xmm2
; SSE2-NEXT:    por %xmm3, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test4:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxsb %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test4:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmaxsb %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp sge <16 x i8> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i8> %a, <16 x i8> %b
  ret <16 x i8> %sel
}

define <16 x i8> @test5(<16 x i8> %a, <16 x i8> %b) {
; SSE-LABEL: test5:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pminub %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: test5:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpminub %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp ult <16 x i8> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i8> %a, <16 x i8> %b
  ret <16 x i8> %sel
}

define <16 x i8> @test6(<16 x i8> %a, <16 x i8> %b) {
; SSE-LABEL: test6:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pminub %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: test6:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpminub %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp ule <16 x i8> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i8> %a, <16 x i8> %b
  ret <16 x i8> %sel
}

define <16 x i8> @test7(<16 x i8> %a, <16 x i8> %b) {
; SSE-LABEL: test7:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pmaxub %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: test7:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmaxub %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp ugt <16 x i8> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i8> %a, <16 x i8> %b
  ret <16 x i8> %sel
}

define <16 x i8> @test8(<16 x i8> %a, <16 x i8> %b) {
; SSE-LABEL: test8:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pmaxub %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: test8:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmaxub %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp uge <16 x i8> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i8> %a, <16 x i8> %b
  ret <16 x i8> %sel
}

define <8 x i16> @test9(<8 x i16> %a, <8 x i16> %b) {
; SSE-LABEL: test9:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pminsw %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: test9:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpminsw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp slt <8 x i16> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i16> %a, <8 x i16> %b
  ret <8 x i16> %sel
}

define <8 x i16> @test10(<8 x i16> %a, <8 x i16> %b) {
; SSE-LABEL: test10:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pminsw %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: test10:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpminsw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp sle <8 x i16> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i16> %a, <8 x i16> %b
  ret <8 x i16> %sel
}

define <8 x i16> @test11(<8 x i16> %a, <8 x i16> %b) {
; SSE-LABEL: test11:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pmaxsw %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: test11:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmaxsw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp sgt <8 x i16> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i16> %a, <8 x i16> %b
  ret <8 x i16> %sel
}

define <8 x i16> @test12(<8 x i16> %a, <8 x i16> %b) {
; SSE-LABEL: test12:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pmaxsw %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: test12:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmaxsw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp sge <8 x i16> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i16> %a, <8 x i16> %b
  ret <8 x i16> %sel
}

define <8 x i16> @test13(<8 x i16> %a, <8 x i16> %b) {
; SSE2-LABEL: test13:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [32768,32768,32768,32768,32768,32768,32768,32768]
; SSE2-NEXT:    movdqa %xmm0, %xmm3
; SSE2-NEXT:    pxor %xmm2, %xmm3
; SSE2-NEXT:    pxor %xmm1, %xmm2
; SSE2-NEXT:    pcmpgtw %xmm3, %xmm2
; SSE2-NEXT:    pand %xmm2, %xmm0
; SSE2-NEXT:    pandn %xmm1, %xmm2
; SSE2-NEXT:    por %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test13:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminuw %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test13:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpminuw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp ult <8 x i16> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i16> %a, <8 x i16> %b
  ret <8 x i16> %sel
}

define <8 x i16> @test14(<8 x i16> %a, <8 x i16> %b) {
; SSE2-LABEL: test14:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    psubusw %xmm1, %xmm2
; SSE2-NEXT:    pxor %xmm3, %xmm3
; SSE2-NEXT:    pcmpeqw %xmm2, %xmm3
; SSE2-NEXT:    pand %xmm3, %xmm0
; SSE2-NEXT:    pandn %xmm1, %xmm3
; SSE2-NEXT:    por %xmm3, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test14:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminuw %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test14:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpminuw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp ule <8 x i16> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i16> %a, <8 x i16> %b
  ret <8 x i16> %sel
}

define <8 x i16> @test15(<8 x i16> %a, <8 x i16> %b) {
; SSE2-LABEL: test15:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [32768,32768,32768,32768,32768,32768,32768,32768]
; SSE2-NEXT:    movdqa %xmm1, %xmm3
; SSE2-NEXT:    pxor %xmm2, %xmm3
; SSE2-NEXT:    pxor %xmm0, %xmm2
; SSE2-NEXT:    pcmpgtw %xmm3, %xmm2
; SSE2-NEXT:    pand %xmm2, %xmm0
; SSE2-NEXT:    pandn %xmm1, %xmm2
; SSE2-NEXT:    por %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test15:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxuw %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test15:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmaxuw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp ugt <8 x i16> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i16> %a, <8 x i16> %b
  ret <8 x i16> %sel
}

define <8 x i16> @test16(<8 x i16> %a, <8 x i16> %b) {
; SSE2-LABEL: test16:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm1, %xmm2
; SSE2-NEXT:    psubusw %xmm0, %xmm2
; SSE2-NEXT:    pxor %xmm3, %xmm3
; SSE2-NEXT:    pcmpeqw %xmm2, %xmm3
; SSE2-NEXT:    pand %xmm3, %xmm0
; SSE2-NEXT:    pandn %xmm1, %xmm3
; SSE2-NEXT:    por %xmm3, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test16:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxuw %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test16:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmaxuw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp uge <8 x i16> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i16> %a, <8 x i16> %b
  ret <8 x i16> %sel
}

define <4 x i32> @test17(<4 x i32> %a, <4 x i32> %b) {
; SSE2-LABEL: test17:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm1, %xmm2
; SSE2-NEXT:    pcmpgtd %xmm0, %xmm2
; SSE2-NEXT:    pand %xmm2, %xmm0
; SSE2-NEXT:    pandn %xmm1, %xmm2
; SSE2-NEXT:    por %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test17:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminsd %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test17:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpminsd %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp slt <4 x i32> %a, %b
  %sel = select <4 x i1> %cmp, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %sel
}

define <4 x i32> @test18(<4 x i32> %a, <4 x i32> %b) {
; SSE2-LABEL: test18:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    pcmpgtd %xmm1, %xmm2
; SSE2-NEXT:    pcmpeqd %xmm3, %xmm3
; SSE2-NEXT:    pxor %xmm2, %xmm3
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    pandn %xmm1, %xmm3
; SSE2-NEXT:    por %xmm3, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test18:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminsd %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test18:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpminsd %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp sle <4 x i32> %a, %b
  %sel = select <4 x i1> %cmp, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %sel
}

define <4 x i32> @test19(<4 x i32> %a, <4 x i32> %b) {
; SSE2-LABEL: test19:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    pcmpgtd %xmm1, %xmm2
; SSE2-NEXT:    pand %xmm2, %xmm0
; SSE2-NEXT:    pandn %xmm1, %xmm2
; SSE2-NEXT:    por %xmm0, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test19:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxsd %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test19:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmaxsd %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp sgt <4 x i32> %a, %b
  %sel = select <4 x i1> %cmp, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %sel
}

define <4 x i32> @test20(<4 x i32> %a, <4 x i32> %b) {
; SSE2-LABEL: test20:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm1, %xmm3
; SSE2-NEXT:    pcmpgtd %xmm0, %xmm3
; SSE2-NEXT:    pcmpeqd %xmm2, %xmm2
; SSE2-NEXT:    pxor %xmm3, %xmm2
; SSE2-NEXT:    pandn %xmm0, %xmm3
; SSE2-NEXT:    pandn %xmm1, %xmm2
; SSE2-NEXT:    por %xmm3, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test20:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxsd %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test20:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmaxsd %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp sge <4 x i32> %a, %b
  %sel = select <4 x i1> %cmp, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %sel
}

define <4 x i32> @test21(<4 x i32> %a, <4 x i32> %b) {
; SSE2-LABEL: test21:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm0, %xmm3
; SSE2-NEXT:    pxor %xmm2, %xmm3
; SSE2-NEXT:    pxor %xmm1, %xmm2
; SSE2-NEXT:    pcmpgtd %xmm3, %xmm2
; SSE2-NEXT:    pand %xmm2, %xmm0
; SSE2-NEXT:    pandn %xmm1, %xmm2
; SSE2-NEXT:    por %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test21:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminud %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test21:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpminud %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp ult <4 x i32> %a, %b
  %sel = select <4 x i1> %cmp, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %sel
}

define <4 x i32> @test22(<4 x i32> %a, <4 x i32> %b) {
; SSE2-LABEL: test22:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm3 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm1, %xmm2
; SSE2-NEXT:    pxor %xmm3, %xmm2
; SSE2-NEXT:    pxor %xmm0, %xmm3
; SSE2-NEXT:    pcmpgtd %xmm2, %xmm3
; SSE2-NEXT:    pcmpeqd %xmm2, %xmm2
; SSE2-NEXT:    pxor %xmm3, %xmm2
; SSE2-NEXT:    pandn %xmm0, %xmm3
; SSE2-NEXT:    pandn %xmm1, %xmm2
; SSE2-NEXT:    por %xmm3, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test22:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminud %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test22:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpminud %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp ule <4 x i32> %a, %b
  %sel = select <4 x i1> %cmp, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %sel
}

define <4 x i32> @test23(<4 x i32> %a, <4 x i32> %b) {
; SSE2-LABEL: test23:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm1, %xmm3
; SSE2-NEXT:    pxor %xmm2, %xmm3
; SSE2-NEXT:    pxor %xmm0, %xmm2
; SSE2-NEXT:    pcmpgtd %xmm3, %xmm2
; SSE2-NEXT:    pand %xmm2, %xmm0
; SSE2-NEXT:    pandn %xmm1, %xmm2
; SSE2-NEXT:    por %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test23:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxud %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test23:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmaxud %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp ugt <4 x i32> %a, %b
  %sel = select <4 x i1> %cmp, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %sel
}

define <4 x i32> @test24(<4 x i32> %a, <4 x i32> %b) {
; SSE2-LABEL: test24:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm3 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    pxor %xmm3, %xmm2
; SSE2-NEXT:    pxor %xmm1, %xmm3
; SSE2-NEXT:    pcmpgtd %xmm2, %xmm3
; SSE2-NEXT:    pcmpeqd %xmm2, %xmm2
; SSE2-NEXT:    pxor %xmm3, %xmm2
; SSE2-NEXT:    pandn %xmm0, %xmm3
; SSE2-NEXT:    pandn %xmm1, %xmm2
; SSE2-NEXT:    por %xmm3, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test24:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxud %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test24:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmaxud %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp uge <4 x i32> %a, %b
  %sel = select <4 x i1> %cmp, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %sel
}

define <32 x i8> @test25(<32 x i8> %a, <32 x i8> %b) {
; SSE2-LABEL: test25:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm3, %xmm4
; SSE2-NEXT:    pcmpgtb %xmm1, %xmm4
; SSE2-NEXT:    movdqa %xmm2, %xmm5
; SSE2-NEXT:    pcmpgtb %xmm0, %xmm5
; SSE2-NEXT:    pand %xmm5, %xmm0
; SSE2-NEXT:    pandn %xmm2, %xmm5
; SSE2-NEXT:    por %xmm5, %xmm0
; SSE2-NEXT:    pand %xmm4, %xmm1
; SSE2-NEXT:    pandn %xmm3, %xmm4
; SSE2-NEXT:    por %xmm4, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test25:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminsb %xmm2, %xmm0
; SSE4-NEXT:    pminsb %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test25:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpminsb %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpminsb %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test25:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminsb %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test25:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminsb %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp slt <32 x i8> %a, %b
  %sel = select <32 x i1> %cmp, <32 x i8> %a, <32 x i8> %b
  ret <32 x i8> %sel
}

define <32 x i8> @test26(<32 x i8> %a, <32 x i8> %b) {
; SSE2-LABEL: test26:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm1, %xmm6
; SSE2-NEXT:    pcmpgtb %xmm3, %xmm6
; SSE2-NEXT:    pcmpeqd %xmm7, %xmm7
; SSE2-NEXT:    movdqa %xmm6, %xmm4
; SSE2-NEXT:    pxor %xmm7, %xmm4
; SSE2-NEXT:    movdqa %xmm0, %xmm5
; SSE2-NEXT:    pcmpgtb %xmm2, %xmm5
; SSE2-NEXT:    pxor %xmm5, %xmm7
; SSE2-NEXT:    pandn %xmm0, %xmm5
; SSE2-NEXT:    pandn %xmm2, %xmm7
; SSE2-NEXT:    por %xmm7, %xmm5
; SSE2-NEXT:    pandn %xmm1, %xmm6
; SSE2-NEXT:    pandn %xmm3, %xmm4
; SSE2-NEXT:    por %xmm6, %xmm4
; SSE2-NEXT:    movdqa %xmm5, %xmm0
; SSE2-NEXT:    movdqa %xmm4, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test26:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminsb %xmm2, %xmm0
; SSE4-NEXT:    pminsb %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test26:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpminsb %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpminsb %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test26:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminsb %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test26:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminsb %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp sle <32 x i8> %a, %b
  %sel = select <32 x i1> %cmp, <32 x i8> %a, <32 x i8> %b
  ret <32 x i8> %sel
}

define <32 x i8> @test27(<32 x i8> %a, <32 x i8> %b) {
; SSE2-LABEL: test27:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm1, %xmm4
; SSE2-NEXT:    pcmpgtb %xmm3, %xmm4
; SSE2-NEXT:    movdqa %xmm0, %xmm5
; SSE2-NEXT:    pcmpgtb %xmm2, %xmm5
; SSE2-NEXT:    pand %xmm5, %xmm0
; SSE2-NEXT:    pandn %xmm2, %xmm5
; SSE2-NEXT:    por %xmm0, %xmm5
; SSE2-NEXT:    pand %xmm4, %xmm1
; SSE2-NEXT:    pandn %xmm3, %xmm4
; SSE2-NEXT:    por %xmm1, %xmm4
; SSE2-NEXT:    movdqa %xmm5, %xmm0
; SSE2-NEXT:    movdqa %xmm4, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test27:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxsb %xmm2, %xmm0
; SSE4-NEXT:    pmaxsb %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test27:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpmaxsb %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpmaxsb %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test27:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxsb %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test27:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxsb %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp sgt <32 x i8> %a, %b
  %sel = select <32 x i1> %cmp, <32 x i8> %a, <32 x i8> %b
  ret <32 x i8> %sel
}

define <32 x i8> @test28(<32 x i8> %a, <32 x i8> %b) {
; SSE2-LABEL: test28:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm3, %xmm6
; SSE2-NEXT:    pcmpgtb %xmm1, %xmm6
; SSE2-NEXT:    pcmpeqd %xmm4, %xmm4
; SSE2-NEXT:    movdqa %xmm6, %xmm5
; SSE2-NEXT:    pxor %xmm4, %xmm5
; SSE2-NEXT:    movdqa %xmm2, %xmm7
; SSE2-NEXT:    pcmpgtb %xmm0, %xmm7
; SSE2-NEXT:    pxor %xmm7, %xmm4
; SSE2-NEXT:    pandn %xmm0, %xmm7
; SSE2-NEXT:    pandn %xmm2, %xmm4
; SSE2-NEXT:    por %xmm7, %xmm4
; SSE2-NEXT:    pandn %xmm1, %xmm6
; SSE2-NEXT:    pandn %xmm3, %xmm5
; SSE2-NEXT:    por %xmm6, %xmm5
; SSE2-NEXT:    movdqa %xmm4, %xmm0
; SSE2-NEXT:    movdqa %xmm5, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test28:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxsb %xmm2, %xmm0
; SSE4-NEXT:    pmaxsb %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test28:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpmaxsb %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpmaxsb %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test28:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxsb %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test28:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxsb %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp sge <32 x i8> %a, %b
  %sel = select <32 x i1> %cmp, <32 x i8> %a, <32 x i8> %b
  ret <32 x i8> %sel
}

define <32 x i8> @test29(<32 x i8> %a, <32 x i8> %b) {
; SSE-LABEL: test29:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pminub %xmm2, %xmm0
; SSE-NEXT:    pminub %xmm3, %xmm1
; SSE-NEXT:    retq
;
; AVX1-LABEL: test29:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpminub %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpminub %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test29:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminub %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test29:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminub %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp ult <32 x i8> %a, %b
  %sel = select <32 x i1> %cmp, <32 x i8> %a, <32 x i8> %b
  ret <32 x i8> %sel
}

define <32 x i8> @test30(<32 x i8> %a, <32 x i8> %b) {
; SSE-LABEL: test30:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pminub %xmm2, %xmm0
; SSE-NEXT:    pminub %xmm3, %xmm1
; SSE-NEXT:    retq
;
; AVX1-LABEL: test30:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpminub %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpminub %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test30:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminub %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test30:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminub %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp ule <32 x i8> %a, %b
  %sel = select <32 x i1> %cmp, <32 x i8> %a, <32 x i8> %b
  ret <32 x i8> %sel
}

define <32 x i8> @test31(<32 x i8> %a, <32 x i8> %b) {
; SSE-LABEL: test31:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pmaxub %xmm2, %xmm0
; SSE-NEXT:    pmaxub %xmm3, %xmm1
; SSE-NEXT:    retq
;
; AVX1-LABEL: test31:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpmaxub %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpmaxub %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test31:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxub %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test31:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxub %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp ugt <32 x i8> %a, %b
  %sel = select <32 x i1> %cmp, <32 x i8> %a, <32 x i8> %b
  ret <32 x i8> %sel
}

define <32 x i8> @test32(<32 x i8> %a, <32 x i8> %b) {
; SSE-LABEL: test32:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pmaxub %xmm2, %xmm0
; SSE-NEXT:    pmaxub %xmm3, %xmm1
; SSE-NEXT:    retq
;
; AVX1-LABEL: test32:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpmaxub %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpmaxub %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test32:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxub %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test32:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxub %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp uge <32 x i8> %a, %b
  %sel = select <32 x i1> %cmp, <32 x i8> %a, <32 x i8> %b
  ret <32 x i8> %sel
}

define <16 x i16> @test33(<16 x i16> %a, <16 x i16> %b) {
; SSE-LABEL: test33:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pminsw %xmm2, %xmm0
; SSE-NEXT:    pminsw %xmm3, %xmm1
; SSE-NEXT:    retq
;
; AVX1-LABEL: test33:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpminsw %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpminsw %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test33:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminsw %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test33:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminsw %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp slt <16 x i16> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i16> %a, <16 x i16> %b
  ret <16 x i16> %sel
}

define <16 x i16> @test34(<16 x i16> %a, <16 x i16> %b) {
; SSE-LABEL: test34:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pminsw %xmm2, %xmm0
; SSE-NEXT:    pminsw %xmm3, %xmm1
; SSE-NEXT:    retq
;
; AVX1-LABEL: test34:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpminsw %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpminsw %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test34:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminsw %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test34:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminsw %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp sle <16 x i16> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i16> %a, <16 x i16> %b
  ret <16 x i16> %sel
}

define <16 x i16> @test35(<16 x i16> %a, <16 x i16> %b) {
; SSE-LABEL: test35:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pmaxsw %xmm2, %xmm0
; SSE-NEXT:    pmaxsw %xmm3, %xmm1
; SSE-NEXT:    retq
;
; AVX1-LABEL: test35:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpmaxsw %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpmaxsw %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test35:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxsw %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test35:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxsw %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp sgt <16 x i16> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i16> %a, <16 x i16> %b
  ret <16 x i16> %sel
}

define <16 x i16> @test36(<16 x i16> %a, <16 x i16> %b) {
; SSE-LABEL: test36:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pmaxsw %xmm2, %xmm0
; SSE-NEXT:    pmaxsw %xmm3, %xmm1
; SSE-NEXT:    retq
;
; AVX1-LABEL: test36:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpmaxsw %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpmaxsw %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test36:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxsw %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test36:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxsw %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp sge <16 x i16> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i16> %a, <16 x i16> %b
  ret <16 x i16> %sel
}

define <16 x i16> @test37(<16 x i16> %a, <16 x i16> %b) {
; SSE2-LABEL: test37:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm4 = [32768,32768,32768,32768,32768,32768,32768,32768]
; SSE2-NEXT:    movdqa %xmm1, %xmm5
; SSE2-NEXT:    pxor %xmm4, %xmm5
; SSE2-NEXT:    movdqa %xmm3, %xmm6
; SSE2-NEXT:    pxor %xmm4, %xmm6
; SSE2-NEXT:    pcmpgtw %xmm5, %xmm6
; SSE2-NEXT:    movdqa %xmm0, %xmm5
; SSE2-NEXT:    pxor %xmm4, %xmm5
; SSE2-NEXT:    pxor %xmm2, %xmm4
; SSE2-NEXT:    pcmpgtw %xmm5, %xmm4
; SSE2-NEXT:    pand %xmm4, %xmm0
; SSE2-NEXT:    pandn %xmm2, %xmm4
; SSE2-NEXT:    por %xmm4, %xmm0
; SSE2-NEXT:    pand %xmm6, %xmm1
; SSE2-NEXT:    pandn %xmm3, %xmm6
; SSE2-NEXT:    por %xmm6, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test37:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminuw %xmm2, %xmm0
; SSE4-NEXT:    pminuw %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test37:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpminuw %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpminuw %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test37:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminuw %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test37:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminuw %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp ult <16 x i16> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i16> %a, <16 x i16> %b
  ret <16 x i16> %sel
}

define <16 x i16> @test38(<16 x i16> %a, <16 x i16> %b) {
; SSE2-LABEL: test38:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm1, %xmm4
; SSE2-NEXT:    psubusw %xmm3, %xmm4
; SSE2-NEXT:    pxor %xmm6, %xmm6
; SSE2-NEXT:    pcmpeqw %xmm6, %xmm4
; SSE2-NEXT:    movdqa %xmm0, %xmm5
; SSE2-NEXT:    psubusw %xmm2, %xmm5
; SSE2-NEXT:    pcmpeqw %xmm6, %xmm5
; SSE2-NEXT:    pand %xmm5, %xmm0
; SSE2-NEXT:    pandn %xmm2, %xmm5
; SSE2-NEXT:    por %xmm0, %xmm5
; SSE2-NEXT:    pand %xmm4, %xmm1
; SSE2-NEXT:    pandn %xmm3, %xmm4
; SSE2-NEXT:    por %xmm1, %xmm4
; SSE2-NEXT:    movdqa %xmm5, %xmm0
; SSE2-NEXT:    movdqa %xmm4, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test38:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminuw %xmm2, %xmm0
; SSE4-NEXT:    pminuw %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test38:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpminuw %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpminuw %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test38:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminuw %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test38:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminuw %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp ule <16 x i16> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i16> %a, <16 x i16> %b
  ret <16 x i16> %sel
}

define <16 x i16> @test39(<16 x i16> %a, <16 x i16> %b) {
; SSE2-LABEL: test39:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm5 = [32768,32768,32768,32768,32768,32768,32768,32768]
; SSE2-NEXT:    movdqa %xmm3, %xmm6
; SSE2-NEXT:    pxor %xmm5, %xmm6
; SSE2-NEXT:    movdqa %xmm1, %xmm4
; SSE2-NEXT:    pxor %xmm5, %xmm4
; SSE2-NEXT:    pcmpgtw %xmm6, %xmm4
; SSE2-NEXT:    movdqa %xmm2, %xmm6
; SSE2-NEXT:    pxor %xmm5, %xmm6
; SSE2-NEXT:    pxor %xmm0, %xmm5
; SSE2-NEXT:    pcmpgtw %xmm6, %xmm5
; SSE2-NEXT:    pand %xmm5, %xmm0
; SSE2-NEXT:    pandn %xmm2, %xmm5
; SSE2-NEXT:    por %xmm5, %xmm0
; SSE2-NEXT:    pand %xmm4, %xmm1
; SSE2-NEXT:    pandn %xmm3, %xmm4
; SSE2-NEXT:    por %xmm1, %xmm4
; SSE2-NEXT:    movdqa %xmm4, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test39:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxuw %xmm2, %xmm0
; SSE4-NEXT:    pmaxuw %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test39:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpmaxuw %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpmaxuw %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test39:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxuw %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test39:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxuw %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp ugt <16 x i16> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i16> %a, <16 x i16> %b
  ret <16 x i16> %sel
}

define <16 x i16> @test40(<16 x i16> %a, <16 x i16> %b) {
; SSE2-LABEL: test40:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm3, %xmm4
; SSE2-NEXT:    psubusw %xmm1, %xmm4
; SSE2-NEXT:    pxor %xmm5, %xmm5
; SSE2-NEXT:    pcmpeqw %xmm5, %xmm4
; SSE2-NEXT:    movdqa %xmm2, %xmm6
; SSE2-NEXT:    psubusw %xmm0, %xmm6
; SSE2-NEXT:    pcmpeqw %xmm5, %xmm6
; SSE2-NEXT:    pand %xmm6, %xmm0
; SSE2-NEXT:    pandn %xmm2, %xmm6
; SSE2-NEXT:    por %xmm6, %xmm0
; SSE2-NEXT:    pand %xmm4, %xmm1
; SSE2-NEXT:    pandn %xmm3, %xmm4
; SSE2-NEXT:    por %xmm4, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test40:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxuw %xmm2, %xmm0
; SSE4-NEXT:    pmaxuw %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test40:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpmaxuw %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpmaxuw %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test40:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxuw %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test40:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxuw %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp uge <16 x i16> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i16> %a, <16 x i16> %b
  ret <16 x i16> %sel
}

define <8 x i32> @test41(<8 x i32> %a, <8 x i32> %b) {
; SSE2-LABEL: test41:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm3, %xmm4
; SSE2-NEXT:    pcmpgtd %xmm1, %xmm4
; SSE2-NEXT:    movdqa %xmm2, %xmm5
; SSE2-NEXT:    pcmpgtd %xmm0, %xmm5
; SSE2-NEXT:    pand %xmm5, %xmm0
; SSE2-NEXT:    pandn %xmm2, %xmm5
; SSE2-NEXT:    por %xmm5, %xmm0
; SSE2-NEXT:    pand %xmm4, %xmm1
; SSE2-NEXT:    pandn %xmm3, %xmm4
; SSE2-NEXT:    por %xmm4, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test41:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminsd %xmm2, %xmm0
; SSE4-NEXT:    pminsd %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test41:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpminsd %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpminsd %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test41:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminsd %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test41:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminsd %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp slt <8 x i32> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i32> %a, <8 x i32> %b
  ret <8 x i32> %sel
}

define <8 x i32> @test42(<8 x i32> %a, <8 x i32> %b) {
; SSE2-LABEL: test42:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm1, %xmm6
; SSE2-NEXT:    pcmpgtd %xmm3, %xmm6
; SSE2-NEXT:    pcmpeqd %xmm7, %xmm7
; SSE2-NEXT:    movdqa %xmm6, %xmm4
; SSE2-NEXT:    pxor %xmm7, %xmm4
; SSE2-NEXT:    movdqa %xmm0, %xmm5
; SSE2-NEXT:    pcmpgtd %xmm2, %xmm5
; SSE2-NEXT:    pxor %xmm5, %xmm7
; SSE2-NEXT:    pandn %xmm0, %xmm5
; SSE2-NEXT:    pandn %xmm2, %xmm7
; SSE2-NEXT:    por %xmm7, %xmm5
; SSE2-NEXT:    pandn %xmm1, %xmm6
; SSE2-NEXT:    pandn %xmm3, %xmm4
; SSE2-NEXT:    por %xmm6, %xmm4
; SSE2-NEXT:    movdqa %xmm5, %xmm0
; SSE2-NEXT:    movdqa %xmm4, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test42:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminsd %xmm2, %xmm0
; SSE4-NEXT:    pminsd %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test42:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpminsd %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpminsd %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test42:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminsd %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test42:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminsd %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp sle <8 x i32> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i32> %a, <8 x i32> %b
  ret <8 x i32> %sel
}

define <8 x i32> @test43(<8 x i32> %a, <8 x i32> %b) {
; SSE2-LABEL: test43:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm1, %xmm4
; SSE2-NEXT:    pcmpgtd %xmm3, %xmm4
; SSE2-NEXT:    movdqa %xmm0, %xmm5
; SSE2-NEXT:    pcmpgtd %xmm2, %xmm5
; SSE2-NEXT:    pand %xmm5, %xmm0
; SSE2-NEXT:    pandn %xmm2, %xmm5
; SSE2-NEXT:    por %xmm0, %xmm5
; SSE2-NEXT:    pand %xmm4, %xmm1
; SSE2-NEXT:    pandn %xmm3, %xmm4
; SSE2-NEXT:    por %xmm1, %xmm4
; SSE2-NEXT:    movdqa %xmm5, %xmm0
; SSE2-NEXT:    movdqa %xmm4, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test43:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxsd %xmm2, %xmm0
; SSE4-NEXT:    pmaxsd %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test43:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpmaxsd %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpmaxsd %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test43:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxsd %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test43:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxsd %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp sgt <8 x i32> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i32> %a, <8 x i32> %b
  ret <8 x i32> %sel
}

define <8 x i32> @test44(<8 x i32> %a, <8 x i32> %b) {
; SSE2-LABEL: test44:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm3, %xmm6
; SSE2-NEXT:    pcmpgtd %xmm1, %xmm6
; SSE2-NEXT:    pcmpeqd %xmm4, %xmm4
; SSE2-NEXT:    movdqa %xmm6, %xmm5
; SSE2-NEXT:    pxor %xmm4, %xmm5
; SSE2-NEXT:    movdqa %xmm2, %xmm7
; SSE2-NEXT:    pcmpgtd %xmm0, %xmm7
; SSE2-NEXT:    pxor %xmm7, %xmm4
; SSE2-NEXT:    pandn %xmm0, %xmm7
; SSE2-NEXT:    pandn %xmm2, %xmm4
; SSE2-NEXT:    por %xmm7, %xmm4
; SSE2-NEXT:    pandn %xmm1, %xmm6
; SSE2-NEXT:    pandn %xmm3, %xmm5
; SSE2-NEXT:    por %xmm6, %xmm5
; SSE2-NEXT:    movdqa %xmm4, %xmm0
; SSE2-NEXT:    movdqa %xmm5, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test44:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxsd %xmm2, %xmm0
; SSE4-NEXT:    pmaxsd %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test44:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpmaxsd %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpmaxsd %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test44:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxsd %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test44:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxsd %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp sge <8 x i32> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i32> %a, <8 x i32> %b
  ret <8 x i32> %sel
}

define <8 x i32> @test45(<8 x i32> %a, <8 x i32> %b) {
; SSE2-LABEL: test45:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm4 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm1, %xmm5
; SSE2-NEXT:    pxor %xmm4, %xmm5
; SSE2-NEXT:    movdqa %xmm3, %xmm6
; SSE2-NEXT:    pxor %xmm4, %xmm6
; SSE2-NEXT:    pcmpgtd %xmm5, %xmm6
; SSE2-NEXT:    movdqa %xmm0, %xmm5
; SSE2-NEXT:    pxor %xmm4, %xmm5
; SSE2-NEXT:    pxor %xmm2, %xmm4
; SSE2-NEXT:    pcmpgtd %xmm5, %xmm4
; SSE2-NEXT:    pand %xmm4, %xmm0
; SSE2-NEXT:    pandn %xmm2, %xmm4
; SSE2-NEXT:    por %xmm4, %xmm0
; SSE2-NEXT:    pand %xmm6, %xmm1
; SSE2-NEXT:    pandn %xmm3, %xmm6
; SSE2-NEXT:    por %xmm6, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test45:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminud %xmm2, %xmm0
; SSE4-NEXT:    pminud %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test45:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpminud %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpminud %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test45:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminud %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test45:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminud %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp ult <8 x i32> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i32> %a, <8 x i32> %b
  ret <8 x i32> %sel
}

define <8 x i32> @test46(<8 x i32> %a, <8 x i32> %b) {
; SSE2-LABEL: test46:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm6 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm3, %xmm4
; SSE2-NEXT:    pxor %xmm6, %xmm4
; SSE2-NEXT:    movdqa %xmm1, %xmm7
; SSE2-NEXT:    pxor %xmm6, %xmm7
; SSE2-NEXT:    pcmpgtd %xmm4, %xmm7
; SSE2-NEXT:    pcmpeqd %xmm4, %xmm4
; SSE2-NEXT:    movdqa %xmm7, %xmm5
; SSE2-NEXT:    pxor %xmm4, %xmm5
; SSE2-NEXT:    movdqa %xmm2, %xmm8
; SSE2-NEXT:    pxor %xmm6, %xmm8
; SSE2-NEXT:    pxor %xmm0, %xmm6
; SSE2-NEXT:    pcmpgtd %xmm8, %xmm6
; SSE2-NEXT:    pxor %xmm6, %xmm4
; SSE2-NEXT:    pandn %xmm0, %xmm6
; SSE2-NEXT:    pandn %xmm2, %xmm4
; SSE2-NEXT:    por %xmm6, %xmm4
; SSE2-NEXT:    pandn %xmm1, %xmm7
; SSE2-NEXT:    pandn %xmm3, %xmm5
; SSE2-NEXT:    por %xmm7, %xmm5
; SSE2-NEXT:    movdqa %xmm4, %xmm0
; SSE2-NEXT:    movdqa %xmm5, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test46:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminud %xmm2, %xmm0
; SSE4-NEXT:    pminud %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test46:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpminud %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpminud %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test46:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminud %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test46:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminud %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp ule <8 x i32> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i32> %a, <8 x i32> %b
  ret <8 x i32> %sel
}

define <8 x i32> @test47(<8 x i32> %a, <8 x i32> %b) {
; SSE2-LABEL: test47:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm5 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm3, %xmm6
; SSE2-NEXT:    pxor %xmm5, %xmm6
; SSE2-NEXT:    movdqa %xmm1, %xmm4
; SSE2-NEXT:    pxor %xmm5, %xmm4
; SSE2-NEXT:    pcmpgtd %xmm6, %xmm4
; SSE2-NEXT:    movdqa %xmm2, %xmm6
; SSE2-NEXT:    pxor %xmm5, %xmm6
; SSE2-NEXT:    pxor %xmm0, %xmm5
; SSE2-NEXT:    pcmpgtd %xmm6, %xmm5
; SSE2-NEXT:    pand %xmm5, %xmm0
; SSE2-NEXT:    pandn %xmm2, %xmm5
; SSE2-NEXT:    por %xmm5, %xmm0
; SSE2-NEXT:    pand %xmm4, %xmm1
; SSE2-NEXT:    pandn %xmm3, %xmm4
; SSE2-NEXT:    por %xmm1, %xmm4
; SSE2-NEXT:    movdqa %xmm4, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test47:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxud %xmm2, %xmm0
; SSE4-NEXT:    pmaxud %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test47:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpmaxud %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpmaxud %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test47:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxud %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test47:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxud %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp ugt <8 x i32> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i32> %a, <8 x i32> %b
  ret <8 x i32> %sel
}

define <8 x i32> @test48(<8 x i32> %a, <8 x i32> %b) {
; SSE2-LABEL: test48:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm6 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm1, %xmm4
; SSE2-NEXT:    pxor %xmm6, %xmm4
; SSE2-NEXT:    movdqa %xmm3, %xmm7
; SSE2-NEXT:    pxor %xmm6, %xmm7
; SSE2-NEXT:    pcmpgtd %xmm4, %xmm7
; SSE2-NEXT:    pcmpeqd %xmm4, %xmm4
; SSE2-NEXT:    movdqa %xmm7, %xmm5
; SSE2-NEXT:    pxor %xmm4, %xmm5
; SSE2-NEXT:    movdqa %xmm0, %xmm8
; SSE2-NEXT:    pxor %xmm6, %xmm8
; SSE2-NEXT:    pxor %xmm2, %xmm6
; SSE2-NEXT:    pcmpgtd %xmm8, %xmm6
; SSE2-NEXT:    pxor %xmm6, %xmm4
; SSE2-NEXT:    pandn %xmm0, %xmm6
; SSE2-NEXT:    pandn %xmm2, %xmm4
; SSE2-NEXT:    por %xmm6, %xmm4
; SSE2-NEXT:    pandn %xmm1, %xmm7
; SSE2-NEXT:    pandn %xmm3, %xmm5
; SSE2-NEXT:    por %xmm7, %xmm5
; SSE2-NEXT:    movdqa %xmm4, %xmm0
; SSE2-NEXT:    movdqa %xmm5, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test48:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxud %xmm2, %xmm0
; SSE4-NEXT:    pmaxud %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test48:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpmaxud %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpmaxud %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test48:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxud %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test48:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxud %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp uge <8 x i32> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i32> %a, <8 x i32> %b
  ret <8 x i32> %sel
}

define <16 x i8> @test49(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: test49:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm1, %xmm2
; SSE2-NEXT:    pcmpgtb %xmm0, %xmm2
; SSE2-NEXT:    pand %xmm2, %xmm1
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    por %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test49:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxsb %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test49:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmaxsb %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp slt <16 x i8> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i8> %b, <16 x i8> %a
  ret <16 x i8> %sel
}

define <16 x i8> @test50(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: test50:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    pcmpgtb %xmm1, %xmm2
; SSE2-NEXT:    pcmpeqd %xmm3, %xmm3
; SSE2-NEXT:    pxor %xmm2, %xmm3
; SSE2-NEXT:    pandn %xmm1, %xmm2
; SSE2-NEXT:    pandn %xmm0, %xmm3
; SSE2-NEXT:    por %xmm3, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test50:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxsb %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test50:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmaxsb %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp sle <16 x i8> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i8> %b, <16 x i8> %a
  ret <16 x i8> %sel
}

define <16 x i8> @test51(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: test51:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    pcmpgtb %xmm1, %xmm2
; SSE2-NEXT:    pand %xmm2, %xmm1
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    por %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test51:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminsb %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test51:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpminsb %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp sgt <16 x i8> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i8> %b, <16 x i8> %a
  ret <16 x i8> %sel
}

define <16 x i8> @test52(<16 x i8> %a, <16 x i8> %b) {
; SSE2-LABEL: test52:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm1, %xmm3
; SSE2-NEXT:    pcmpgtb %xmm0, %xmm3
; SSE2-NEXT:    pcmpeqd %xmm2, %xmm2
; SSE2-NEXT:    pxor %xmm3, %xmm2
; SSE2-NEXT:    pandn %xmm1, %xmm3
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    por %xmm3, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test52:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminsb %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test52:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpminsb %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp sge <16 x i8> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i8> %b, <16 x i8> %a
  ret <16 x i8> %sel
}

define <16 x i8> @test53(<16 x i8> %a, <16 x i8> %b) {
; SSE-LABEL: test53:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pmaxub %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: test53:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmaxub %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp ult <16 x i8> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i8> %b, <16 x i8> %a
  ret <16 x i8> %sel
}

define <16 x i8> @test54(<16 x i8> %a, <16 x i8> %b) {
; SSE-LABEL: test54:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pmaxub %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: test54:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmaxub %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp ule <16 x i8> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i8> %b, <16 x i8> %a
  ret <16 x i8> %sel
}

define <16 x i8> @test55(<16 x i8> %a, <16 x i8> %b) {
; SSE-LABEL: test55:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pminub %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: test55:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpminub %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp ugt <16 x i8> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i8> %b, <16 x i8> %a
  ret <16 x i8> %sel
}

define <16 x i8> @test56(<16 x i8> %a, <16 x i8> %b) {
; SSE-LABEL: test56:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pminub %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: test56:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpminub %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp uge <16 x i8> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i8> %b, <16 x i8> %a
  ret <16 x i8> %sel
}

define <8 x i16> @test57(<8 x i16> %a, <8 x i16> %b) {
; SSE-LABEL: test57:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pmaxsw %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: test57:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmaxsw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp slt <8 x i16> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i16> %b, <8 x i16> %a
  ret <8 x i16> %sel
}

define <8 x i16> @test58(<8 x i16> %a, <8 x i16> %b) {
; SSE-LABEL: test58:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pmaxsw %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: test58:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmaxsw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp sle <8 x i16> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i16> %b, <8 x i16> %a
  ret <8 x i16> %sel
}

define <8 x i16> @test59(<8 x i16> %a, <8 x i16> %b) {
; SSE-LABEL: test59:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pminsw %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: test59:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpminsw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp sgt <8 x i16> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i16> %b, <8 x i16> %a
  ret <8 x i16> %sel
}

define <8 x i16> @test60(<8 x i16> %a, <8 x i16> %b) {
; SSE-LABEL: test60:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pminsw %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: test60:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpminsw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp sge <8 x i16> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i16> %b, <8 x i16> %a
  ret <8 x i16> %sel
}

define <8 x i16> @test61(<8 x i16> %a, <8 x i16> %b) {
; SSE2-LABEL: test61:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [32768,32768,32768,32768,32768,32768,32768,32768]
; SSE2-NEXT:    movdqa %xmm0, %xmm3
; SSE2-NEXT:    pxor %xmm2, %xmm3
; SSE2-NEXT:    pxor %xmm1, %xmm2
; SSE2-NEXT:    pcmpgtw %xmm3, %xmm2
; SSE2-NEXT:    pand %xmm2, %xmm1
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    por %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test61:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxuw %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test61:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmaxuw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp ult <8 x i16> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i16> %b, <8 x i16> %a
  ret <8 x i16> %sel
}

define <8 x i16> @test62(<8 x i16> %a, <8 x i16> %b) {
; SSE2-LABEL: test62:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm0, %xmm3
; SSE2-NEXT:    psubusw %xmm1, %xmm3
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    pcmpeqw %xmm3, %xmm2
; SSE2-NEXT:    pand %xmm2, %xmm1
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    por %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test62:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxuw %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test62:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmaxuw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp ule <8 x i16> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i16> %b, <8 x i16> %a
  ret <8 x i16> %sel
}

define <8 x i16> @test63(<8 x i16> %a, <8 x i16> %b) {
; SSE2-LABEL: test63:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [32768,32768,32768,32768,32768,32768,32768,32768]
; SSE2-NEXT:    movdqa %xmm1, %xmm3
; SSE2-NEXT:    pxor %xmm2, %xmm3
; SSE2-NEXT:    pxor %xmm0, %xmm2
; SSE2-NEXT:    pcmpgtw %xmm3, %xmm2
; SSE2-NEXT:    pand %xmm2, %xmm1
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    por %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test63:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminuw %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test63:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpminuw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp ugt <8 x i16> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i16> %b, <8 x i16> %a
  ret <8 x i16> %sel
}

define <8 x i16> @test64(<8 x i16> %a, <8 x i16> %b) {
; SSE2-LABEL: test64:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm1, %xmm3
; SSE2-NEXT:    psubusw %xmm0, %xmm3
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    pcmpeqw %xmm3, %xmm2
; SSE2-NEXT:    pand %xmm2, %xmm1
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    por %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test64:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminuw %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test64:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpminuw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp uge <8 x i16> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i16> %b, <8 x i16> %a
  ret <8 x i16> %sel
}

define <4 x i32> @test65(<4 x i32> %a, <4 x i32> %b) {
; SSE2-LABEL: test65:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm1, %xmm2
; SSE2-NEXT:    pcmpgtd %xmm0, %xmm2
; SSE2-NEXT:    pand %xmm2, %xmm1
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    por %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test65:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxsd %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test65:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmaxsd %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp slt <4 x i32> %a, %b
  %sel = select <4 x i1> %cmp, <4 x i32> %b, <4 x i32> %a
  ret <4 x i32> %sel
}

define <4 x i32> @test66(<4 x i32> %a, <4 x i32> %b) {
; SSE2-LABEL: test66:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    pcmpgtd %xmm1, %xmm2
; SSE2-NEXT:    pcmpeqd %xmm3, %xmm3
; SSE2-NEXT:    pxor %xmm2, %xmm3
; SSE2-NEXT:    pandn %xmm1, %xmm2
; SSE2-NEXT:    pandn %xmm0, %xmm3
; SSE2-NEXT:    por %xmm3, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test66:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxsd %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test66:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmaxsd %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp sle <4 x i32> %a, %b
  %sel = select <4 x i1> %cmp, <4 x i32> %b, <4 x i32> %a
  ret <4 x i32> %sel
}

define <4 x i32> @test67(<4 x i32> %a, <4 x i32> %b) {
; SSE2-LABEL: test67:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    pcmpgtd %xmm1, %xmm2
; SSE2-NEXT:    pand %xmm2, %xmm1
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    por %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test67:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminsd %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test67:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpminsd %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp sgt <4 x i32> %a, %b
  %sel = select <4 x i1> %cmp, <4 x i32> %b, <4 x i32> %a
  ret <4 x i32> %sel
}

define <4 x i32> @test68(<4 x i32> %a, <4 x i32> %b) {
; SSE2-LABEL: test68:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm1, %xmm3
; SSE2-NEXT:    pcmpgtd %xmm0, %xmm3
; SSE2-NEXT:    pcmpeqd %xmm2, %xmm2
; SSE2-NEXT:    pxor %xmm3, %xmm2
; SSE2-NEXT:    pandn %xmm1, %xmm3
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    por %xmm3, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test68:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminsd %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test68:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpminsd %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp sge <4 x i32> %a, %b
  %sel = select <4 x i1> %cmp, <4 x i32> %b, <4 x i32> %a
  ret <4 x i32> %sel
}

define <4 x i32> @test69(<4 x i32> %a, <4 x i32> %b) {
; SSE2-LABEL: test69:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm0, %xmm3
; SSE2-NEXT:    pxor %xmm2, %xmm3
; SSE2-NEXT:    pxor %xmm1, %xmm2
; SSE2-NEXT:    pcmpgtd %xmm3, %xmm2
; SSE2-NEXT:    pand %xmm2, %xmm1
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    por %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test69:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxud %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test69:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmaxud %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp ult <4 x i32> %a, %b
  %sel = select <4 x i1> %cmp, <4 x i32> %b, <4 x i32> %a
  ret <4 x i32> %sel
}

define <4 x i32> @test70(<4 x i32> %a, <4 x i32> %b) {
; SSE2-LABEL: test70:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm3 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm1, %xmm2
; SSE2-NEXT:    pxor %xmm3, %xmm2
; SSE2-NEXT:    pxor %xmm0, %xmm3
; SSE2-NEXT:    pcmpgtd %xmm2, %xmm3
; SSE2-NEXT:    pcmpeqd %xmm2, %xmm2
; SSE2-NEXT:    pxor %xmm3, %xmm2
; SSE2-NEXT:    pandn %xmm1, %xmm3
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    por %xmm3, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test70:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxud %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test70:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpmaxud %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp ule <4 x i32> %a, %b
  %sel = select <4 x i1> %cmp, <4 x i32> %b, <4 x i32> %a
  ret <4 x i32> %sel
}

define <4 x i32> @test71(<4 x i32> %a, <4 x i32> %b) {
; SSE2-LABEL: test71:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm1, %xmm3
; SSE2-NEXT:    pxor %xmm2, %xmm3
; SSE2-NEXT:    pxor %xmm0, %xmm2
; SSE2-NEXT:    pcmpgtd %xmm3, %xmm2
; SSE2-NEXT:    pand %xmm2, %xmm1
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    por %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test71:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminud %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test71:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpminud %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp ugt <4 x i32> %a, %b
  %sel = select <4 x i1> %cmp, <4 x i32> %b, <4 x i32> %a
  ret <4 x i32> %sel
}

define <4 x i32> @test72(<4 x i32> %a, <4 x i32> %b) {
; SSE2-LABEL: test72:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm3 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    pxor %xmm3, %xmm2
; SSE2-NEXT:    pxor %xmm1, %xmm3
; SSE2-NEXT:    pcmpgtd %xmm2, %xmm3
; SSE2-NEXT:    pcmpeqd %xmm2, %xmm2
; SSE2-NEXT:    pxor %xmm3, %xmm2
; SSE2-NEXT:    pandn %xmm1, %xmm3
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    por %xmm3, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test72:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminud %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test72:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpminud %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %cmp = icmp uge <4 x i32> %a, %b
  %sel = select <4 x i1> %cmp, <4 x i32> %b, <4 x i32> %a
  ret <4 x i32> %sel
}

define <32 x i8> @test73(<32 x i8> %a, <32 x i8> %b) {
; SSE2-LABEL: test73:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm3, %xmm4
; SSE2-NEXT:    pcmpgtb %xmm1, %xmm4
; SSE2-NEXT:    movdqa %xmm2, %xmm5
; SSE2-NEXT:    pcmpgtb %xmm0, %xmm5
; SSE2-NEXT:    pand %xmm5, %xmm2
; SSE2-NEXT:    pandn %xmm0, %xmm5
; SSE2-NEXT:    por %xmm2, %xmm5
; SSE2-NEXT:    pand %xmm4, %xmm3
; SSE2-NEXT:    pandn %xmm1, %xmm4
; SSE2-NEXT:    por %xmm3, %xmm4
; SSE2-NEXT:    movdqa %xmm5, %xmm0
; SSE2-NEXT:    movdqa %xmm4, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test73:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxsb %xmm2, %xmm0
; SSE4-NEXT:    pmaxsb %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test73:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpmaxsb %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpmaxsb %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test73:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxsb %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test73:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxsb %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp slt <32 x i8> %a, %b
  %sel = select <32 x i1> %cmp, <32 x i8> %b, <32 x i8> %a
  ret <32 x i8> %sel
}

define <32 x i8> @test74(<32 x i8> %a, <32 x i8> %b) {
; SSE2-LABEL: test74:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm1, %xmm6
; SSE2-NEXT:    pcmpgtb %xmm3, %xmm6
; SSE2-NEXT:    pcmpeqd %xmm7, %xmm7
; SSE2-NEXT:    movdqa %xmm6, %xmm4
; SSE2-NEXT:    pxor %xmm7, %xmm4
; SSE2-NEXT:    movdqa %xmm0, %xmm5
; SSE2-NEXT:    pcmpgtb %xmm2, %xmm5
; SSE2-NEXT:    pxor %xmm5, %xmm7
; SSE2-NEXT:    pandn %xmm2, %xmm5
; SSE2-NEXT:    pandn %xmm0, %xmm7
; SSE2-NEXT:    por %xmm7, %xmm5
; SSE2-NEXT:    pandn %xmm3, %xmm6
; SSE2-NEXT:    pandn %xmm1, %xmm4
; SSE2-NEXT:    por %xmm6, %xmm4
; SSE2-NEXT:    movdqa %xmm5, %xmm0
; SSE2-NEXT:    movdqa %xmm4, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test74:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxsb %xmm2, %xmm0
; SSE4-NEXT:    pmaxsb %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test74:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpmaxsb %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpmaxsb %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test74:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxsb %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test74:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxsb %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp sle <32 x i8> %a, %b
  %sel = select <32 x i1> %cmp, <32 x i8> %b, <32 x i8> %a
  ret <32 x i8> %sel
}

define <32 x i8> @test75(<32 x i8> %a, <32 x i8> %b) {
; SSE2-LABEL: test75:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm1, %xmm4
; SSE2-NEXT:    pcmpgtb %xmm3, %xmm4
; SSE2-NEXT:    movdqa %xmm0, %xmm5
; SSE2-NEXT:    pcmpgtb %xmm2, %xmm5
; SSE2-NEXT:    pand %xmm5, %xmm2
; SSE2-NEXT:    pandn %xmm0, %xmm5
; SSE2-NEXT:    por %xmm2, %xmm5
; SSE2-NEXT:    pand %xmm4, %xmm3
; SSE2-NEXT:    pandn %xmm1, %xmm4
; SSE2-NEXT:    por %xmm3, %xmm4
; SSE2-NEXT:    movdqa %xmm5, %xmm0
; SSE2-NEXT:    movdqa %xmm4, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test75:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminsb %xmm2, %xmm0
; SSE4-NEXT:    pminsb %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test75:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpminsb %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpminsb %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test75:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminsb %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test75:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminsb %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp sgt <32 x i8> %a, %b
  %sel = select <32 x i1> %cmp, <32 x i8> %b, <32 x i8> %a
  ret <32 x i8> %sel
}

define <32 x i8> @test76(<32 x i8> %a, <32 x i8> %b) {
; SSE2-LABEL: test76:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm3, %xmm6
; SSE2-NEXT:    pcmpgtb %xmm1, %xmm6
; SSE2-NEXT:    pcmpeqd %xmm4, %xmm4
; SSE2-NEXT:    movdqa %xmm6, %xmm5
; SSE2-NEXT:    pxor %xmm4, %xmm5
; SSE2-NEXT:    movdqa %xmm2, %xmm7
; SSE2-NEXT:    pcmpgtb %xmm0, %xmm7
; SSE2-NEXT:    pxor %xmm7, %xmm4
; SSE2-NEXT:    pandn %xmm2, %xmm7
; SSE2-NEXT:    pandn %xmm0, %xmm4
; SSE2-NEXT:    por %xmm7, %xmm4
; SSE2-NEXT:    pandn %xmm3, %xmm6
; SSE2-NEXT:    pandn %xmm1, %xmm5
; SSE2-NEXT:    por %xmm6, %xmm5
; SSE2-NEXT:    movdqa %xmm4, %xmm0
; SSE2-NEXT:    movdqa %xmm5, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test76:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminsb %xmm2, %xmm0
; SSE4-NEXT:    pminsb %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test76:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpminsb %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpminsb %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test76:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminsb %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test76:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminsb %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp sge <32 x i8> %a, %b
  %sel = select <32 x i1> %cmp, <32 x i8> %b, <32 x i8> %a
  ret <32 x i8> %sel
}

define <32 x i8> @test77(<32 x i8> %a, <32 x i8> %b) {
; SSE-LABEL: test77:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pmaxub %xmm2, %xmm0
; SSE-NEXT:    pmaxub %xmm3, %xmm1
; SSE-NEXT:    retq
;
; AVX1-LABEL: test77:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpmaxub %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpmaxub %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test77:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxub %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test77:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxub %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp ult <32 x i8> %a, %b
  %sel = select <32 x i1> %cmp, <32 x i8> %b, <32 x i8> %a
  ret <32 x i8> %sel
}

define <32 x i8> @test78(<32 x i8> %a, <32 x i8> %b) {
; SSE-LABEL: test78:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pmaxub %xmm2, %xmm0
; SSE-NEXT:    pmaxub %xmm3, %xmm1
; SSE-NEXT:    retq
;
; AVX1-LABEL: test78:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpmaxub %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpmaxub %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test78:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxub %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test78:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxub %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp ule <32 x i8> %a, %b
  %sel = select <32 x i1> %cmp, <32 x i8> %b, <32 x i8> %a
  ret <32 x i8> %sel
}

define <32 x i8> @test79(<32 x i8> %a, <32 x i8> %b) {
; SSE-LABEL: test79:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pminub %xmm2, %xmm0
; SSE-NEXT:    pminub %xmm3, %xmm1
; SSE-NEXT:    retq
;
; AVX1-LABEL: test79:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpminub %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpminub %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test79:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminub %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test79:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminub %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp ugt <32 x i8> %a, %b
  %sel = select <32 x i1> %cmp, <32 x i8> %b, <32 x i8> %a
  ret <32 x i8> %sel
}

define <32 x i8> @test80(<32 x i8> %a, <32 x i8> %b) {
; SSE-LABEL: test80:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pminub %xmm2, %xmm0
; SSE-NEXT:    pminub %xmm3, %xmm1
; SSE-NEXT:    retq
;
; AVX1-LABEL: test80:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpminub %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpminub %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test80:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminub %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test80:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminub %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp uge <32 x i8> %a, %b
  %sel = select <32 x i1> %cmp, <32 x i8> %b, <32 x i8> %a
  ret <32 x i8> %sel
}

define <16 x i16> @test81(<16 x i16> %a, <16 x i16> %b) {
; SSE-LABEL: test81:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pmaxsw %xmm2, %xmm0
; SSE-NEXT:    pmaxsw %xmm3, %xmm1
; SSE-NEXT:    retq
;
; AVX1-LABEL: test81:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpmaxsw %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpmaxsw %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test81:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxsw %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test81:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxsw %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp slt <16 x i16> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i16> %b, <16 x i16> %a
  ret <16 x i16> %sel
}

define <16 x i16> @test82(<16 x i16> %a, <16 x i16> %b) {
; SSE-LABEL: test82:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pmaxsw %xmm2, %xmm0
; SSE-NEXT:    pmaxsw %xmm3, %xmm1
; SSE-NEXT:    retq
;
; AVX1-LABEL: test82:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpmaxsw %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpmaxsw %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test82:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxsw %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test82:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxsw %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp sle <16 x i16> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i16> %b, <16 x i16> %a
  ret <16 x i16> %sel
}

define <16 x i16> @test83(<16 x i16> %a, <16 x i16> %b) {
; SSE-LABEL: test83:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pminsw %xmm2, %xmm0
; SSE-NEXT:    pminsw %xmm3, %xmm1
; SSE-NEXT:    retq
;
; AVX1-LABEL: test83:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpminsw %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpminsw %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test83:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminsw %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test83:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminsw %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp sgt <16 x i16> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i16> %b, <16 x i16> %a
  ret <16 x i16> %sel
}

define <16 x i16> @test84(<16 x i16> %a, <16 x i16> %b) {
; SSE-LABEL: test84:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pminsw %xmm2, %xmm0
; SSE-NEXT:    pminsw %xmm3, %xmm1
; SSE-NEXT:    retq
;
; AVX1-LABEL: test84:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpminsw %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpminsw %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test84:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminsw %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test84:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminsw %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp sge <16 x i16> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i16> %b, <16 x i16> %a
  ret <16 x i16> %sel
}

define <16 x i16> @test85(<16 x i16> %a, <16 x i16> %b) {
; SSE2-LABEL: test85:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm4 = [32768,32768,32768,32768,32768,32768,32768,32768]
; SSE2-NEXT:    movdqa %xmm1, %xmm6
; SSE2-NEXT:    pxor %xmm4, %xmm6
; SSE2-NEXT:    movdqa %xmm3, %xmm5
; SSE2-NEXT:    pxor %xmm4, %xmm5
; SSE2-NEXT:    pcmpgtw %xmm6, %xmm5
; SSE2-NEXT:    movdqa %xmm0, %xmm6
; SSE2-NEXT:    pxor %xmm4, %xmm6
; SSE2-NEXT:    pxor %xmm2, %xmm4
; SSE2-NEXT:    pcmpgtw %xmm6, %xmm4
; SSE2-NEXT:    pand %xmm4, %xmm2
; SSE2-NEXT:    pandn %xmm0, %xmm4
; SSE2-NEXT:    por %xmm2, %xmm4
; SSE2-NEXT:    pand %xmm5, %xmm3
; SSE2-NEXT:    pandn %xmm1, %xmm5
; SSE2-NEXT:    por %xmm3, %xmm5
; SSE2-NEXT:    movdqa %xmm4, %xmm0
; SSE2-NEXT:    movdqa %xmm5, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test85:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxuw %xmm2, %xmm0
; SSE4-NEXT:    pmaxuw %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test85:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpmaxuw %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpmaxuw %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test85:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxuw %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test85:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxuw %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp ult <16 x i16> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i16> %b, <16 x i16> %a
  ret <16 x i16> %sel
}

define <16 x i16> @test86(<16 x i16> %a, <16 x i16> %b) {
; SSE2-LABEL: test86:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm1, %xmm4
; SSE2-NEXT:    psubusw %xmm3, %xmm4
; SSE2-NEXT:    pxor %xmm6, %xmm6
; SSE2-NEXT:    pcmpeqw %xmm6, %xmm4
; SSE2-NEXT:    movdqa %xmm0, %xmm5
; SSE2-NEXT:    psubusw %xmm2, %xmm5
; SSE2-NEXT:    pcmpeqw %xmm6, %xmm5
; SSE2-NEXT:    pand %xmm5, %xmm2
; SSE2-NEXT:    pandn %xmm0, %xmm5
; SSE2-NEXT:    por %xmm2, %xmm5
; SSE2-NEXT:    pand %xmm4, %xmm3
; SSE2-NEXT:    pandn %xmm1, %xmm4
; SSE2-NEXT:    por %xmm3, %xmm4
; SSE2-NEXT:    movdqa %xmm5, %xmm0
; SSE2-NEXT:    movdqa %xmm4, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test86:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxuw %xmm2, %xmm0
; SSE4-NEXT:    pmaxuw %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test86:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpmaxuw %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpmaxuw %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test86:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxuw %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test86:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxuw %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp ule <16 x i16> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i16> %b, <16 x i16> %a
  ret <16 x i16> %sel
}

define <16 x i16> @test87(<16 x i16> %a, <16 x i16> %b) {
; SSE2-LABEL: test87:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm4 = [32768,32768,32768,32768,32768,32768,32768,32768]
; SSE2-NEXT:    movdqa %xmm3, %xmm6
; SSE2-NEXT:    pxor %xmm4, %xmm6
; SSE2-NEXT:    movdqa %xmm1, %xmm5
; SSE2-NEXT:    pxor %xmm4, %xmm5
; SSE2-NEXT:    pcmpgtw %xmm6, %xmm5
; SSE2-NEXT:    movdqa %xmm2, %xmm6
; SSE2-NEXT:    pxor %xmm4, %xmm6
; SSE2-NEXT:    pxor %xmm0, %xmm4
; SSE2-NEXT:    pcmpgtw %xmm6, %xmm4
; SSE2-NEXT:    pand %xmm4, %xmm2
; SSE2-NEXT:    pandn %xmm0, %xmm4
; SSE2-NEXT:    por %xmm2, %xmm4
; SSE2-NEXT:    pand %xmm5, %xmm3
; SSE2-NEXT:    pandn %xmm1, %xmm5
; SSE2-NEXT:    por %xmm3, %xmm5
; SSE2-NEXT:    movdqa %xmm4, %xmm0
; SSE2-NEXT:    movdqa %xmm5, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test87:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminuw %xmm2, %xmm0
; SSE4-NEXT:    pminuw %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test87:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpminuw %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpminuw %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test87:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminuw %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test87:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminuw %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp ugt <16 x i16> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i16> %b, <16 x i16> %a
  ret <16 x i16> %sel
}

define <16 x i16> @test88(<16 x i16> %a, <16 x i16> %b) {
; SSE2-LABEL: test88:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm3, %xmm4
; SSE2-NEXT:    psubusw %xmm1, %xmm4
; SSE2-NEXT:    pxor %xmm6, %xmm6
; SSE2-NEXT:    pcmpeqw %xmm6, %xmm4
; SSE2-NEXT:    movdqa %xmm2, %xmm5
; SSE2-NEXT:    psubusw %xmm0, %xmm5
; SSE2-NEXT:    pcmpeqw %xmm6, %xmm5
; SSE2-NEXT:    pand %xmm5, %xmm2
; SSE2-NEXT:    pandn %xmm0, %xmm5
; SSE2-NEXT:    por %xmm2, %xmm5
; SSE2-NEXT:    pand %xmm4, %xmm3
; SSE2-NEXT:    pandn %xmm1, %xmm4
; SSE2-NEXT:    por %xmm3, %xmm4
; SSE2-NEXT:    movdqa %xmm5, %xmm0
; SSE2-NEXT:    movdqa %xmm4, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test88:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminuw %xmm2, %xmm0
; SSE4-NEXT:    pminuw %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test88:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpminuw %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpminuw %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test88:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminuw %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test88:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminuw %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp uge <16 x i16> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i16> %b, <16 x i16> %a
  ret <16 x i16> %sel
}

define <8 x i32> @test89(<8 x i32> %a, <8 x i32> %b) {
; SSE2-LABEL: test89:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm3, %xmm4
; SSE2-NEXT:    pcmpgtd %xmm1, %xmm4
; SSE2-NEXT:    movdqa %xmm2, %xmm5
; SSE2-NEXT:    pcmpgtd %xmm0, %xmm5
; SSE2-NEXT:    pand %xmm5, %xmm2
; SSE2-NEXT:    pandn %xmm0, %xmm5
; SSE2-NEXT:    por %xmm2, %xmm5
; SSE2-NEXT:    pand %xmm4, %xmm3
; SSE2-NEXT:    pandn %xmm1, %xmm4
; SSE2-NEXT:    por %xmm3, %xmm4
; SSE2-NEXT:    movdqa %xmm5, %xmm0
; SSE2-NEXT:    movdqa %xmm4, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test89:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxsd %xmm2, %xmm0
; SSE4-NEXT:    pmaxsd %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test89:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpmaxsd %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpmaxsd %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test89:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxsd %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test89:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxsd %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp slt <8 x i32> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i32> %b, <8 x i32> %a
  ret <8 x i32> %sel
}

define <8 x i32> @test90(<8 x i32> %a, <8 x i32> %b) {
; SSE2-LABEL: test90:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm1, %xmm6
; SSE2-NEXT:    pcmpgtd %xmm3, %xmm6
; SSE2-NEXT:    pcmpeqd %xmm7, %xmm7
; SSE2-NEXT:    movdqa %xmm6, %xmm4
; SSE2-NEXT:    pxor %xmm7, %xmm4
; SSE2-NEXT:    movdqa %xmm0, %xmm5
; SSE2-NEXT:    pcmpgtd %xmm2, %xmm5
; SSE2-NEXT:    pxor %xmm5, %xmm7
; SSE2-NEXT:    pandn %xmm2, %xmm5
; SSE2-NEXT:    pandn %xmm0, %xmm7
; SSE2-NEXT:    por %xmm7, %xmm5
; SSE2-NEXT:    pandn %xmm3, %xmm6
; SSE2-NEXT:    pandn %xmm1, %xmm4
; SSE2-NEXT:    por %xmm6, %xmm4
; SSE2-NEXT:    movdqa %xmm5, %xmm0
; SSE2-NEXT:    movdqa %xmm4, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test90:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxsd %xmm2, %xmm0
; SSE4-NEXT:    pmaxsd %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test90:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpmaxsd %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpmaxsd %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test90:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxsd %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test90:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxsd %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp sle <8 x i32> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i32> %b, <8 x i32> %a
  ret <8 x i32> %sel
}

define <8 x i32> @test91(<8 x i32> %a, <8 x i32> %b) {
; SSE2-LABEL: test91:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm1, %xmm4
; SSE2-NEXT:    pcmpgtd %xmm3, %xmm4
; SSE2-NEXT:    movdqa %xmm0, %xmm5
; SSE2-NEXT:    pcmpgtd %xmm2, %xmm5
; SSE2-NEXT:    pand %xmm5, %xmm2
; SSE2-NEXT:    pandn %xmm0, %xmm5
; SSE2-NEXT:    por %xmm2, %xmm5
; SSE2-NEXT:    pand %xmm4, %xmm3
; SSE2-NEXT:    pandn %xmm1, %xmm4
; SSE2-NEXT:    por %xmm3, %xmm4
; SSE2-NEXT:    movdqa %xmm5, %xmm0
; SSE2-NEXT:    movdqa %xmm4, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test91:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminsd %xmm2, %xmm0
; SSE4-NEXT:    pminsd %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test91:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpminsd %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpminsd %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test91:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminsd %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test91:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminsd %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp sgt <8 x i32> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i32> %b, <8 x i32> %a
  ret <8 x i32> %sel
}

define <8 x i32> @test92(<8 x i32> %a, <8 x i32> %b) {
; SSE2-LABEL: test92:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm3, %xmm6
; SSE2-NEXT:    pcmpgtd %xmm1, %xmm6
; SSE2-NEXT:    pcmpeqd %xmm4, %xmm4
; SSE2-NEXT:    movdqa %xmm6, %xmm5
; SSE2-NEXT:    pxor %xmm4, %xmm5
; SSE2-NEXT:    movdqa %xmm2, %xmm7
; SSE2-NEXT:    pcmpgtd %xmm0, %xmm7
; SSE2-NEXT:    pxor %xmm7, %xmm4
; SSE2-NEXT:    pandn %xmm2, %xmm7
; SSE2-NEXT:    pandn %xmm0, %xmm4
; SSE2-NEXT:    por %xmm7, %xmm4
; SSE2-NEXT:    pandn %xmm3, %xmm6
; SSE2-NEXT:    pandn %xmm1, %xmm5
; SSE2-NEXT:    por %xmm6, %xmm5
; SSE2-NEXT:    movdqa %xmm4, %xmm0
; SSE2-NEXT:    movdqa %xmm5, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test92:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminsd %xmm2, %xmm0
; SSE4-NEXT:    pminsd %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test92:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpminsd %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpminsd %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test92:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminsd %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test92:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminsd %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp sge <8 x i32> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i32> %b, <8 x i32> %a
  ret <8 x i32> %sel
}

define <8 x i32> @test93(<8 x i32> %a, <8 x i32> %b) {
; SSE2-LABEL: test93:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm4 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm1, %xmm6
; SSE2-NEXT:    pxor %xmm4, %xmm6
; SSE2-NEXT:    movdqa %xmm3, %xmm5
; SSE2-NEXT:    pxor %xmm4, %xmm5
; SSE2-NEXT:    pcmpgtd %xmm6, %xmm5
; SSE2-NEXT:    movdqa %xmm0, %xmm6
; SSE2-NEXT:    pxor %xmm4, %xmm6
; SSE2-NEXT:    pxor %xmm2, %xmm4
; SSE2-NEXT:    pcmpgtd %xmm6, %xmm4
; SSE2-NEXT:    pand %xmm4, %xmm2
; SSE2-NEXT:    pandn %xmm0, %xmm4
; SSE2-NEXT:    por %xmm2, %xmm4
; SSE2-NEXT:    pand %xmm5, %xmm3
; SSE2-NEXT:    pandn %xmm1, %xmm5
; SSE2-NEXT:    por %xmm3, %xmm5
; SSE2-NEXT:    movdqa %xmm4, %xmm0
; SSE2-NEXT:    movdqa %xmm5, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test93:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxud %xmm2, %xmm0
; SSE4-NEXT:    pmaxud %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test93:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpmaxud %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpmaxud %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test93:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxud %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test93:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxud %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp ult <8 x i32> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i32> %b, <8 x i32> %a
  ret <8 x i32> %sel
}

define <8 x i32> @test94(<8 x i32> %a, <8 x i32> %b) {
; SSE2-LABEL: test94:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm6 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm3, %xmm4
; SSE2-NEXT:    pxor %xmm6, %xmm4
; SSE2-NEXT:    movdqa %xmm1, %xmm7
; SSE2-NEXT:    pxor %xmm6, %xmm7
; SSE2-NEXT:    pcmpgtd %xmm4, %xmm7
; SSE2-NEXT:    pcmpeqd %xmm4, %xmm4
; SSE2-NEXT:    movdqa %xmm7, %xmm5
; SSE2-NEXT:    pxor %xmm4, %xmm5
; SSE2-NEXT:    movdqa %xmm2, %xmm8
; SSE2-NEXT:    pxor %xmm6, %xmm8
; SSE2-NEXT:    pxor %xmm0, %xmm6
; SSE2-NEXT:    pcmpgtd %xmm8, %xmm6
; SSE2-NEXT:    pxor %xmm6, %xmm4
; SSE2-NEXT:    pandn %xmm2, %xmm6
; SSE2-NEXT:    pandn %xmm0, %xmm4
; SSE2-NEXT:    por %xmm6, %xmm4
; SSE2-NEXT:    pandn %xmm3, %xmm7
; SSE2-NEXT:    pandn %xmm1, %xmm5
; SSE2-NEXT:    por %xmm7, %xmm5
; SSE2-NEXT:    movdqa %xmm4, %xmm0
; SSE2-NEXT:    movdqa %xmm5, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test94:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxud %xmm2, %xmm0
; SSE4-NEXT:    pmaxud %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test94:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpmaxud %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpmaxud %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test94:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxud %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test94:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxud %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp ule <8 x i32> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i32> %b, <8 x i32> %a
  ret <8 x i32> %sel
}

define <8 x i32> @test95(<8 x i32> %a, <8 x i32> %b) {
; SSE2-LABEL: test95:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm4 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm3, %xmm6
; SSE2-NEXT:    pxor %xmm4, %xmm6
; SSE2-NEXT:    movdqa %xmm1, %xmm5
; SSE2-NEXT:    pxor %xmm4, %xmm5
; SSE2-NEXT:    pcmpgtd %xmm6, %xmm5
; SSE2-NEXT:    movdqa %xmm2, %xmm6
; SSE2-NEXT:    pxor %xmm4, %xmm6
; SSE2-NEXT:    pxor %xmm0, %xmm4
; SSE2-NEXT:    pcmpgtd %xmm6, %xmm4
; SSE2-NEXT:    pand %xmm4, %xmm2
; SSE2-NEXT:    pandn %xmm0, %xmm4
; SSE2-NEXT:    por %xmm2, %xmm4
; SSE2-NEXT:    pand %xmm5, %xmm3
; SSE2-NEXT:    pandn %xmm1, %xmm5
; SSE2-NEXT:    por %xmm3, %xmm5
; SSE2-NEXT:    movdqa %xmm4, %xmm0
; SSE2-NEXT:    movdqa %xmm5, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test95:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminud %xmm2, %xmm0
; SSE4-NEXT:    pminud %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test95:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpminud %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpminud %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test95:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminud %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test95:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminud %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp ugt <8 x i32> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i32> %b, <8 x i32> %a
  ret <8 x i32> %sel
}

define <8 x i32> @test96(<8 x i32> %a, <8 x i32> %b) {
; SSE2-LABEL: test96:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm6 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm1, %xmm4
; SSE2-NEXT:    pxor %xmm6, %xmm4
; SSE2-NEXT:    movdqa %xmm3, %xmm7
; SSE2-NEXT:    pxor %xmm6, %xmm7
; SSE2-NEXT:    pcmpgtd %xmm4, %xmm7
; SSE2-NEXT:    pcmpeqd %xmm4, %xmm4
; SSE2-NEXT:    movdqa %xmm7, %xmm5
; SSE2-NEXT:    pxor %xmm4, %xmm5
; SSE2-NEXT:    movdqa %xmm0, %xmm8
; SSE2-NEXT:    pxor %xmm6, %xmm8
; SSE2-NEXT:    pxor %xmm2, %xmm6
; SSE2-NEXT:    pcmpgtd %xmm8, %xmm6
; SSE2-NEXT:    pxor %xmm6, %xmm4
; SSE2-NEXT:    pandn %xmm2, %xmm6
; SSE2-NEXT:    pandn %xmm0, %xmm4
; SSE2-NEXT:    por %xmm6, %xmm4
; SSE2-NEXT:    pandn %xmm3, %xmm7
; SSE2-NEXT:    pandn %xmm1, %xmm5
; SSE2-NEXT:    por %xmm7, %xmm5
; SSE2-NEXT:    movdqa %xmm4, %xmm0
; SSE2-NEXT:    movdqa %xmm5, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test96:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminud %xmm2, %xmm0
; SSE4-NEXT:    pminud %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test96:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpminud %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpminud %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test96:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminud %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test96:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminud %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp uge <8 x i32> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i32> %b, <8 x i32> %a
  ret <8 x i32> %sel
}

; ----------------------------

define <64 x i8> @test97(<64 x i8> %a, <64 x i8> %b) {
; SSE2-LABEL: test97:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm7, %xmm8
; SSE2-NEXT:    pcmpgtb %xmm3, %xmm8
; SSE2-NEXT:    movdqa %xmm6, %xmm9
; SSE2-NEXT:    pcmpgtb %xmm2, %xmm9
; SSE2-NEXT:    movdqa %xmm5, %xmm10
; SSE2-NEXT:    pcmpgtb %xmm1, %xmm10
; SSE2-NEXT:    movdqa %xmm4, %xmm11
; SSE2-NEXT:    pcmpgtb %xmm0, %xmm11
; SSE2-NEXT:    pand %xmm11, %xmm0
; SSE2-NEXT:    pandn %xmm4, %xmm11
; SSE2-NEXT:    por %xmm11, %xmm0
; SSE2-NEXT:    pand %xmm10, %xmm1
; SSE2-NEXT:    pandn %xmm5, %xmm10
; SSE2-NEXT:    por %xmm10, %xmm1
; SSE2-NEXT:    pand %xmm9, %xmm2
; SSE2-NEXT:    pandn %xmm6, %xmm9
; SSE2-NEXT:    por %xmm9, %xmm2
; SSE2-NEXT:    pand %xmm8, %xmm3
; SSE2-NEXT:    pandn %xmm7, %xmm8
; SSE2-NEXT:    por %xmm8, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test97:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminsb %xmm4, %xmm0
; SSE4-NEXT:    pminsb %xmm5, %xmm1
; SSE4-NEXT:    pminsb %xmm6, %xmm2
; SSE4-NEXT:    pminsb %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test97:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpminsb %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpminsb %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpminsb %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpminsb %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test97:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminsb %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpminsb %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test97:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpminsb %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp slt <64 x i8> %a, %b
  %sel = select <64 x i1> %cmp, <64 x i8> %a, <64 x i8> %b
  ret <64 x i8> %sel
}

define <64 x i8> @test98(<64 x i8> %a, <64 x i8> %b) {
; SSE2-LABEL: test98:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm3, %xmm8
; SSE2-NEXT:    movdqa %xmm2, %xmm9
; SSE2-NEXT:    movdqa %xmm8, %xmm12
; SSE2-NEXT:    pcmpgtb %xmm7, %xmm12
; SSE2-NEXT:    pcmpeqd %xmm13, %xmm13
; SSE2-NEXT:    movdqa %xmm12, %xmm3
; SSE2-NEXT:    pxor %xmm13, %xmm3
; SSE2-NEXT:    movdqa %xmm9, %xmm14
; SSE2-NEXT:    pcmpgtb %xmm6, %xmm14
; SSE2-NEXT:    movdqa %xmm14, %xmm2
; SSE2-NEXT:    pxor %xmm13, %xmm2
; SSE2-NEXT:    movdqa %xmm1, %xmm15
; SSE2-NEXT:    pcmpgtb %xmm5, %xmm15
; SSE2-NEXT:    movdqa %xmm15, %xmm10
; SSE2-NEXT:    pxor %xmm13, %xmm10
; SSE2-NEXT:    movdqa %xmm0, %xmm11
; SSE2-NEXT:    pcmpgtb %xmm4, %xmm11
; SSE2-NEXT:    pxor %xmm11, %xmm13
; SSE2-NEXT:    pandn %xmm0, %xmm11
; SSE2-NEXT:    pandn %xmm4, %xmm13
; SSE2-NEXT:    por %xmm13, %xmm11
; SSE2-NEXT:    pandn %xmm1, %xmm15
; SSE2-NEXT:    pandn %xmm5, %xmm10
; SSE2-NEXT:    por %xmm15, %xmm10
; SSE2-NEXT:    pandn %xmm9, %xmm14
; SSE2-NEXT:    pandn %xmm6, %xmm2
; SSE2-NEXT:    por %xmm14, %xmm2
; SSE2-NEXT:    pandn %xmm8, %xmm12
; SSE2-NEXT:    pandn %xmm7, %xmm3
; SSE2-NEXT:    por %xmm12, %xmm3
; SSE2-NEXT:    movdqa %xmm11, %xmm0
; SSE2-NEXT:    movdqa %xmm10, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test98:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminsb %xmm4, %xmm0
; SSE4-NEXT:    pminsb %xmm5, %xmm1
; SSE4-NEXT:    pminsb %xmm6, %xmm2
; SSE4-NEXT:    pminsb %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test98:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpminsb %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpminsb %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpminsb %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpminsb %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test98:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminsb %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpminsb %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test98:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpminsb %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp sle <64 x i8> %a, %b
  %sel = select <64 x i1> %cmp, <64 x i8> %a, <64 x i8> %b
  ret <64 x i8> %sel
}

define <64 x i8> @test99(<64 x i8> %a, <64 x i8> %b) {
; SSE2-LABEL: test99:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm3, %xmm8
; SSE2-NEXT:    pcmpgtb %xmm7, %xmm3
; SSE2-NEXT:    movdqa %xmm2, %xmm9
; SSE2-NEXT:    pcmpgtb %xmm6, %xmm9
; SSE2-NEXT:    movdqa %xmm1, %xmm10
; SSE2-NEXT:    pcmpgtb %xmm5, %xmm10
; SSE2-NEXT:    movdqa %xmm0, %xmm11
; SSE2-NEXT:    pcmpgtb %xmm4, %xmm11
; SSE2-NEXT:    pand %xmm11, %xmm0
; SSE2-NEXT:    pandn %xmm4, %xmm11
; SSE2-NEXT:    por %xmm0, %xmm11
; SSE2-NEXT:    pand %xmm10, %xmm1
; SSE2-NEXT:    pandn %xmm5, %xmm10
; SSE2-NEXT:    por %xmm1, %xmm10
; SSE2-NEXT:    pand %xmm9, %xmm2
; SSE2-NEXT:    pandn %xmm6, %xmm9
; SSE2-NEXT:    por %xmm2, %xmm9
; SSE2-NEXT:    pand %xmm3, %xmm8
; SSE2-NEXT:    pandn %xmm7, %xmm3
; SSE2-NEXT:    por %xmm8, %xmm3
; SSE2-NEXT:    movdqa %xmm11, %xmm0
; SSE2-NEXT:    movdqa %xmm10, %xmm1
; SSE2-NEXT:    movdqa %xmm9, %xmm2
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test99:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxsb %xmm4, %xmm0
; SSE4-NEXT:    pmaxsb %xmm5, %xmm1
; SSE4-NEXT:    pmaxsb %xmm6, %xmm2
; SSE4-NEXT:    pmaxsb %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test99:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpmaxsb %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpmaxsb %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpmaxsb %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpmaxsb %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test99:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxsb %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpmaxsb %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test99:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpmaxsb %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp sgt <64 x i8> %a, %b
  %sel = select <64 x i1> %cmp, <64 x i8> %a, <64 x i8> %b
  ret <64 x i8> %sel
}

define <64 x i8> @test100(<64 x i8> %a, <64 x i8> %b) {
; SSE2-LABEL: test100:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm3, %xmm8
; SSE2-NEXT:    movdqa %xmm2, %xmm9
; SSE2-NEXT:    movdqa %xmm0, %xmm10
; SSE2-NEXT:    movdqa %xmm7, %xmm12
; SSE2-NEXT:    pcmpgtb %xmm8, %xmm12
; SSE2-NEXT:    pcmpeqd %xmm0, %xmm0
; SSE2-NEXT:    movdqa %xmm12, %xmm3
; SSE2-NEXT:    pxor %xmm0, %xmm3
; SSE2-NEXT:    movdqa %xmm6, %xmm13
; SSE2-NEXT:    pcmpgtb %xmm9, %xmm13
; SSE2-NEXT:    movdqa %xmm13, %xmm2
; SSE2-NEXT:    pxor %xmm0, %xmm2
; SSE2-NEXT:    movdqa %xmm5, %xmm14
; SSE2-NEXT:    pcmpgtb %xmm1, %xmm14
; SSE2-NEXT:    movdqa %xmm14, %xmm11
; SSE2-NEXT:    pxor %xmm0, %xmm11
; SSE2-NEXT:    movdqa %xmm4, %xmm15
; SSE2-NEXT:    pcmpgtb %xmm10, %xmm15
; SSE2-NEXT:    pxor %xmm15, %xmm0
; SSE2-NEXT:    pandn %xmm10, %xmm15
; SSE2-NEXT:    pandn %xmm4, %xmm0
; SSE2-NEXT:    por %xmm15, %xmm0
; SSE2-NEXT:    pandn %xmm1, %xmm14
; SSE2-NEXT:    pandn %xmm5, %xmm11
; SSE2-NEXT:    por %xmm14, %xmm11
; SSE2-NEXT:    pandn %xmm9, %xmm13
; SSE2-NEXT:    pandn %xmm6, %xmm2
; SSE2-NEXT:    por %xmm13, %xmm2
; SSE2-NEXT:    pandn %xmm8, %xmm12
; SSE2-NEXT:    pandn %xmm7, %xmm3
; SSE2-NEXT:    por %xmm12, %xmm3
; SSE2-NEXT:    movdqa %xmm11, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test100:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxsb %xmm4, %xmm0
; SSE4-NEXT:    pmaxsb %xmm5, %xmm1
; SSE4-NEXT:    pmaxsb %xmm6, %xmm2
; SSE4-NEXT:    pmaxsb %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test100:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpmaxsb %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpmaxsb %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpmaxsb %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpmaxsb %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test100:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxsb %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpmaxsb %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test100:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpmaxsb %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp sge <64 x i8> %a, %b
  %sel = select <64 x i1> %cmp, <64 x i8> %a, <64 x i8> %b
  ret <64 x i8> %sel
}

define <64 x i8> @test101(<64 x i8> %a, <64 x i8> %b) {
; SSE-LABEL: test101:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pminub %xmm4, %xmm0
; SSE-NEXT:    pminub %xmm5, %xmm1
; SSE-NEXT:    pminub %xmm6, %xmm2
; SSE-NEXT:    pminub %xmm7, %xmm3
; SSE-NEXT:    retq
;
; AVX1-LABEL: test101:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpminub %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpminub %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpminub %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpminub %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test101:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminub %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpminub %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test101:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpminub %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp ult <64 x i8> %a, %b
  %sel = select <64 x i1> %cmp, <64 x i8> %a, <64 x i8> %b
  ret <64 x i8> %sel
}

define <64 x i8> @test102(<64 x i8> %a, <64 x i8> %b) {
; SSE-LABEL: test102:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pminub %xmm4, %xmm0
; SSE-NEXT:    pminub %xmm5, %xmm1
; SSE-NEXT:    pminub %xmm6, %xmm2
; SSE-NEXT:    pminub %xmm7, %xmm3
; SSE-NEXT:    retq
;
; AVX1-LABEL: test102:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpminub %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpminub %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpminub %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpminub %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test102:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminub %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpminub %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test102:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpminub %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp ule <64 x i8> %a, %b
  %sel = select <64 x i1> %cmp, <64 x i8> %a, <64 x i8> %b
  ret <64 x i8> %sel
}

define <64 x i8> @test103(<64 x i8> %a, <64 x i8> %b) {
; SSE-LABEL: test103:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pmaxub %xmm4, %xmm0
; SSE-NEXT:    pmaxub %xmm5, %xmm1
; SSE-NEXT:    pmaxub %xmm6, %xmm2
; SSE-NEXT:    pmaxub %xmm7, %xmm3
; SSE-NEXT:    retq
;
; AVX1-LABEL: test103:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpmaxub %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpmaxub %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpmaxub %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpmaxub %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test103:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxub %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpmaxub %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test103:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpmaxub %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp ugt <64 x i8> %a, %b
  %sel = select <64 x i1> %cmp, <64 x i8> %a, <64 x i8> %b
  ret <64 x i8> %sel
}

define <64 x i8> @test104(<64 x i8> %a, <64 x i8> %b) {
; SSE-LABEL: test104:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pmaxub %xmm4, %xmm0
; SSE-NEXT:    pmaxub %xmm5, %xmm1
; SSE-NEXT:    pmaxub %xmm6, %xmm2
; SSE-NEXT:    pmaxub %xmm7, %xmm3
; SSE-NEXT:    retq
;
; AVX1-LABEL: test104:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpmaxub %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpmaxub %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpmaxub %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpmaxub %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test104:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxub %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpmaxub %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test104:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpmaxub %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp uge <64 x i8> %a, %b
  %sel = select <64 x i1> %cmp, <64 x i8> %a, <64 x i8> %b
  ret <64 x i8> %sel
}

define <32 x i16> @test105(<32 x i16> %a, <32 x i16> %b) {
; SSE-LABEL: test105:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pminsw %xmm4, %xmm0
; SSE-NEXT:    pminsw %xmm5, %xmm1
; SSE-NEXT:    pminsw %xmm6, %xmm2
; SSE-NEXT:    pminsw %xmm7, %xmm3
; SSE-NEXT:    retq
;
; AVX1-LABEL: test105:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpminsw %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpminsw %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpminsw %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpminsw %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test105:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminsw %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpminsw %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test105:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpminsw %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp slt <32 x i16> %a, %b
  %sel = select <32 x i1> %cmp, <32 x i16> %a, <32 x i16> %b
  ret <32 x i16> %sel
}

define <32 x i16> @test106(<32 x i16> %a, <32 x i16> %b) {
; SSE-LABEL: test106:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pminsw %xmm4, %xmm0
; SSE-NEXT:    pminsw %xmm5, %xmm1
; SSE-NEXT:    pminsw %xmm6, %xmm2
; SSE-NEXT:    pminsw %xmm7, %xmm3
; SSE-NEXT:    retq
;
; AVX1-LABEL: test106:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpminsw %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpminsw %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpminsw %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpminsw %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test106:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminsw %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpminsw %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test106:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpminsw %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp sle <32 x i16> %a, %b
  %sel = select <32 x i1> %cmp, <32 x i16> %a, <32 x i16> %b
  ret <32 x i16> %sel
}

define <32 x i16> @test107(<32 x i16> %a, <32 x i16> %b) {
; SSE-LABEL: test107:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pmaxsw %xmm4, %xmm0
; SSE-NEXT:    pmaxsw %xmm5, %xmm1
; SSE-NEXT:    pmaxsw %xmm6, %xmm2
; SSE-NEXT:    pmaxsw %xmm7, %xmm3
; SSE-NEXT:    retq
;
; AVX1-LABEL: test107:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpmaxsw %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpmaxsw %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpmaxsw %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpmaxsw %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test107:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxsw %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpmaxsw %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test107:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpmaxsw %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp sgt <32 x i16> %a, %b
  %sel = select <32 x i1> %cmp, <32 x i16> %a, <32 x i16> %b
  ret <32 x i16> %sel
}

define <32 x i16> @test108(<32 x i16> %a, <32 x i16> %b) {
; SSE-LABEL: test108:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pmaxsw %xmm4, %xmm0
; SSE-NEXT:    pmaxsw %xmm5, %xmm1
; SSE-NEXT:    pmaxsw %xmm6, %xmm2
; SSE-NEXT:    pmaxsw %xmm7, %xmm3
; SSE-NEXT:    retq
;
; AVX1-LABEL: test108:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpmaxsw %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpmaxsw %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpmaxsw %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpmaxsw %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test108:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxsw %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpmaxsw %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test108:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpmaxsw %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp sge <32 x i16> %a, %b
  %sel = select <32 x i1> %cmp, <32 x i16> %a, <32 x i16> %b
  ret <32 x i16> %sel
}

define <32 x i16> @test109(<32 x i16> %a, <32 x i16> %b) {
; SSE2-LABEL: test109:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm10 = [32768,32768,32768,32768,32768,32768,32768,32768]
; SSE2-NEXT:    movdqa %xmm3, %xmm9
; SSE2-NEXT:    pxor %xmm10, %xmm9
; SSE2-NEXT:    movdqa %xmm7, %xmm8
; SSE2-NEXT:    pxor %xmm10, %xmm8
; SSE2-NEXT:    pcmpgtw %xmm9, %xmm8
; SSE2-NEXT:    movdqa %xmm2, %xmm11
; SSE2-NEXT:    pxor %xmm10, %xmm11
; SSE2-NEXT:    movdqa %xmm6, %xmm9
; SSE2-NEXT:    pxor %xmm10, %xmm9
; SSE2-NEXT:    pcmpgtw %xmm11, %xmm9
; SSE2-NEXT:    movdqa %xmm1, %xmm11
; SSE2-NEXT:    pxor %xmm10, %xmm11
; SSE2-NEXT:    movdqa %xmm5, %xmm12
; SSE2-NEXT:    pxor %xmm10, %xmm12
; SSE2-NEXT:    pcmpgtw %xmm11, %xmm12
; SSE2-NEXT:    movdqa %xmm0, %xmm11
; SSE2-NEXT:    pxor %xmm10, %xmm11
; SSE2-NEXT:    pxor %xmm4, %xmm10
; SSE2-NEXT:    pcmpgtw %xmm11, %xmm10
; SSE2-NEXT:    pand %xmm10, %xmm0
; SSE2-NEXT:    pandn %xmm4, %xmm10
; SSE2-NEXT:    por %xmm10, %xmm0
; SSE2-NEXT:    pand %xmm12, %xmm1
; SSE2-NEXT:    pandn %xmm5, %xmm12
; SSE2-NEXT:    por %xmm12, %xmm1
; SSE2-NEXT:    pand %xmm9, %xmm2
; SSE2-NEXT:    pandn %xmm6, %xmm9
; SSE2-NEXT:    por %xmm9, %xmm2
; SSE2-NEXT:    pand %xmm8, %xmm3
; SSE2-NEXT:    pandn %xmm7, %xmm8
; SSE2-NEXT:    por %xmm8, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test109:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminuw %xmm4, %xmm0
; SSE4-NEXT:    pminuw %xmm5, %xmm1
; SSE4-NEXT:    pminuw %xmm6, %xmm2
; SSE4-NEXT:    pminuw %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test109:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpminuw %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpminuw %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpminuw %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpminuw %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test109:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminuw %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpminuw %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test109:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpminuw %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp ult <32 x i16> %a, %b
  %sel = select <32 x i1> %cmp, <32 x i16> %a, <32 x i16> %b
  ret <32 x i16> %sel
}

define <32 x i16> @test110(<32 x i16> %a, <32 x i16> %b) {
; SSE2-LABEL: test110:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm3, %xmm8
; SSE2-NEXT:    movdqa %xmm2, %xmm9
; SSE2-NEXT:    movdqa %xmm1, %xmm10
; SSE2-NEXT:    psubusw %xmm7, %xmm3
; SSE2-NEXT:    pxor %xmm12, %xmm12
; SSE2-NEXT:    pcmpeqw %xmm12, %xmm3
; SSE2-NEXT:    psubusw %xmm6, %xmm2
; SSE2-NEXT:    pcmpeqw %xmm12, %xmm2
; SSE2-NEXT:    psubusw %xmm5, %xmm1
; SSE2-NEXT:    pcmpeqw %xmm12, %xmm1
; SSE2-NEXT:    movdqa %xmm0, %xmm11
; SSE2-NEXT:    psubusw %xmm4, %xmm11
; SSE2-NEXT:    pcmpeqw %xmm12, %xmm11
; SSE2-NEXT:    pand %xmm11, %xmm0
; SSE2-NEXT:    pandn %xmm4, %xmm11
; SSE2-NEXT:    por %xmm0, %xmm11
; SSE2-NEXT:    pand %xmm1, %xmm10
; SSE2-NEXT:    pandn %xmm5, %xmm1
; SSE2-NEXT:    por %xmm10, %xmm1
; SSE2-NEXT:    pand %xmm2, %xmm9
; SSE2-NEXT:    pandn %xmm6, %xmm2
; SSE2-NEXT:    por %xmm9, %xmm2
; SSE2-NEXT:    pand %xmm3, %xmm8
; SSE2-NEXT:    pandn %xmm7, %xmm3
; SSE2-NEXT:    por %xmm8, %xmm3
; SSE2-NEXT:    movdqa %xmm11, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test110:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminuw %xmm4, %xmm0
; SSE4-NEXT:    pminuw %xmm5, %xmm1
; SSE4-NEXT:    pminuw %xmm6, %xmm2
; SSE4-NEXT:    pminuw %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test110:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpminuw %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpminuw %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpminuw %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpminuw %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test110:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminuw %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpminuw %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test110:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpminuw %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp ule <32 x i16> %a, %b
  %sel = select <32 x i1> %cmp, <32 x i16> %a, <32 x i16> %b
  ret <32 x i16> %sel
}

define <32 x i16> @test111(<32 x i16> %a, <32 x i16> %b) {
; SSE2-LABEL: test111:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm11 = [32768,32768,32768,32768,32768,32768,32768,32768]
; SSE2-NEXT:    movdqa %xmm7, %xmm9
; SSE2-NEXT:    pxor %xmm11, %xmm9
; SSE2-NEXT:    movdqa %xmm3, %xmm8
; SSE2-NEXT:    pxor %xmm11, %xmm8
; SSE2-NEXT:    pcmpgtw %xmm9, %xmm8
; SSE2-NEXT:    movdqa %xmm6, %xmm10
; SSE2-NEXT:    pxor %xmm11, %xmm10
; SSE2-NEXT:    movdqa %xmm2, %xmm9
; SSE2-NEXT:    pxor %xmm11, %xmm9
; SSE2-NEXT:    pcmpgtw %xmm10, %xmm9
; SSE2-NEXT:    movdqa %xmm5, %xmm12
; SSE2-NEXT:    pxor %xmm11, %xmm12
; SSE2-NEXT:    movdqa %xmm1, %xmm10
; SSE2-NEXT:    pxor %xmm11, %xmm10
; SSE2-NEXT:    pcmpgtw %xmm12, %xmm10
; SSE2-NEXT:    movdqa %xmm4, %xmm12
; SSE2-NEXT:    pxor %xmm11, %xmm12
; SSE2-NEXT:    pxor %xmm0, %xmm11
; SSE2-NEXT:    pcmpgtw %xmm12, %xmm11
; SSE2-NEXT:    pand %xmm11, %xmm0
; SSE2-NEXT:    pandn %xmm4, %xmm11
; SSE2-NEXT:    por %xmm11, %xmm0
; SSE2-NEXT:    pand %xmm10, %xmm1
; SSE2-NEXT:    pandn %xmm5, %xmm10
; SSE2-NEXT:    por %xmm1, %xmm10
; SSE2-NEXT:    pand %xmm9, %xmm2
; SSE2-NEXT:    pandn %xmm6, %xmm9
; SSE2-NEXT:    por %xmm2, %xmm9
; SSE2-NEXT:    pand %xmm8, %xmm3
; SSE2-NEXT:    pandn %xmm7, %xmm8
; SSE2-NEXT:    por %xmm3, %xmm8
; SSE2-NEXT:    movdqa %xmm10, %xmm1
; SSE2-NEXT:    movdqa %xmm9, %xmm2
; SSE2-NEXT:    movdqa %xmm8, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test111:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxuw %xmm4, %xmm0
; SSE4-NEXT:    pmaxuw %xmm5, %xmm1
; SSE4-NEXT:    pmaxuw %xmm6, %xmm2
; SSE4-NEXT:    pmaxuw %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test111:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpmaxuw %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpmaxuw %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpmaxuw %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpmaxuw %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test111:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxuw %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpmaxuw %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test111:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpmaxuw %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp ugt <32 x i16> %a, %b
  %sel = select <32 x i1> %cmp, <32 x i16> %a, <32 x i16> %b
  ret <32 x i16> %sel
}

define <32 x i16> @test112(<32 x i16> %a, <32 x i16> %b) {
; SSE2-LABEL: test112:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm7, %xmm8
; SSE2-NEXT:    psubusw %xmm3, %xmm8
; SSE2-NEXT:    pxor %xmm9, %xmm9
; SSE2-NEXT:    pcmpeqw %xmm9, %xmm8
; SSE2-NEXT:    movdqa %xmm6, %xmm10
; SSE2-NEXT:    psubusw %xmm2, %xmm10
; SSE2-NEXT:    pcmpeqw %xmm9, %xmm10
; SSE2-NEXT:    movdqa %xmm5, %xmm11
; SSE2-NEXT:    psubusw %xmm1, %xmm11
; SSE2-NEXT:    pcmpeqw %xmm9, %xmm11
; SSE2-NEXT:    movdqa %xmm4, %xmm12
; SSE2-NEXT:    psubusw %xmm0, %xmm12
; SSE2-NEXT:    pcmpeqw %xmm9, %xmm12
; SSE2-NEXT:    pand %xmm12, %xmm0
; SSE2-NEXT:    pandn %xmm4, %xmm12
; SSE2-NEXT:    por %xmm12, %xmm0
; SSE2-NEXT:    pand %xmm11, %xmm1
; SSE2-NEXT:    pandn %xmm5, %xmm11
; SSE2-NEXT:    por %xmm11, %xmm1
; SSE2-NEXT:    pand %xmm10, %xmm2
; SSE2-NEXT:    pandn %xmm6, %xmm10
; SSE2-NEXT:    por %xmm10, %xmm2
; SSE2-NEXT:    pand %xmm8, %xmm3
; SSE2-NEXT:    pandn %xmm7, %xmm8
; SSE2-NEXT:    por %xmm8, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test112:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxuw %xmm4, %xmm0
; SSE4-NEXT:    pmaxuw %xmm5, %xmm1
; SSE4-NEXT:    pmaxuw %xmm6, %xmm2
; SSE4-NEXT:    pmaxuw %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test112:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpmaxuw %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpmaxuw %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpmaxuw %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpmaxuw %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test112:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxuw %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpmaxuw %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test112:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpmaxuw %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp uge <32 x i16> %a, %b
  %sel = select <32 x i1> %cmp, <32 x i16> %a, <32 x i16> %b
  ret <32 x i16> %sel
}

define <16 x i32> @test113(<16 x i32> %a, <16 x i32> %b) {
; SSE2-LABEL: test113:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm7, %xmm8
; SSE2-NEXT:    pcmpgtd %xmm3, %xmm8
; SSE2-NEXT:    movdqa %xmm6, %xmm9
; SSE2-NEXT:    pcmpgtd %xmm2, %xmm9
; SSE2-NEXT:    movdqa %xmm5, %xmm10
; SSE2-NEXT:    pcmpgtd %xmm1, %xmm10
; SSE2-NEXT:    movdqa %xmm4, %xmm11
; SSE2-NEXT:    pcmpgtd %xmm0, %xmm11
; SSE2-NEXT:    pand %xmm11, %xmm0
; SSE2-NEXT:    pandn %xmm4, %xmm11
; SSE2-NEXT:    por %xmm11, %xmm0
; SSE2-NEXT:    pand %xmm10, %xmm1
; SSE2-NEXT:    pandn %xmm5, %xmm10
; SSE2-NEXT:    por %xmm10, %xmm1
; SSE2-NEXT:    pand %xmm9, %xmm2
; SSE2-NEXT:    pandn %xmm6, %xmm9
; SSE2-NEXT:    por %xmm9, %xmm2
; SSE2-NEXT:    pand %xmm8, %xmm3
; SSE2-NEXT:    pandn %xmm7, %xmm8
; SSE2-NEXT:    por %xmm8, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test113:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminsd %xmm4, %xmm0
; SSE4-NEXT:    pminsd %xmm5, %xmm1
; SSE4-NEXT:    pminsd %xmm6, %xmm2
; SSE4-NEXT:    pminsd %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test113:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpminsd %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpminsd %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpminsd %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpminsd %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test113:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminsd %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpminsd %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test113:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminsd %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp slt <16 x i32> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i32> %a, <16 x i32> %b
  ret <16 x i32> %sel
}

define <16 x i32> @test114(<16 x i32> %a, <16 x i32> %b) {
; SSE2-LABEL: test114:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm3, %xmm8
; SSE2-NEXT:    movdqa %xmm2, %xmm9
; SSE2-NEXT:    movdqa %xmm8, %xmm12
; SSE2-NEXT:    pcmpgtd %xmm7, %xmm12
; SSE2-NEXT:    pcmpeqd %xmm13, %xmm13
; SSE2-NEXT:    movdqa %xmm12, %xmm3
; SSE2-NEXT:    pxor %xmm13, %xmm3
; SSE2-NEXT:    movdqa %xmm9, %xmm14
; SSE2-NEXT:    pcmpgtd %xmm6, %xmm14
; SSE2-NEXT:    movdqa %xmm14, %xmm2
; SSE2-NEXT:    pxor %xmm13, %xmm2
; SSE2-NEXT:    movdqa %xmm1, %xmm15
; SSE2-NEXT:    pcmpgtd %xmm5, %xmm15
; SSE2-NEXT:    movdqa %xmm15, %xmm10
; SSE2-NEXT:    pxor %xmm13, %xmm10
; SSE2-NEXT:    movdqa %xmm0, %xmm11
; SSE2-NEXT:    pcmpgtd %xmm4, %xmm11
; SSE2-NEXT:    pxor %xmm11, %xmm13
; SSE2-NEXT:    pandn %xmm0, %xmm11
; SSE2-NEXT:    pandn %xmm4, %xmm13
; SSE2-NEXT:    por %xmm13, %xmm11
; SSE2-NEXT:    pandn %xmm1, %xmm15
; SSE2-NEXT:    pandn %xmm5, %xmm10
; SSE2-NEXT:    por %xmm15, %xmm10
; SSE2-NEXT:    pandn %xmm9, %xmm14
; SSE2-NEXT:    pandn %xmm6, %xmm2
; SSE2-NEXT:    por %xmm14, %xmm2
; SSE2-NEXT:    pandn %xmm8, %xmm12
; SSE2-NEXT:    pandn %xmm7, %xmm3
; SSE2-NEXT:    por %xmm12, %xmm3
; SSE2-NEXT:    movdqa %xmm11, %xmm0
; SSE2-NEXT:    movdqa %xmm10, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test114:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminsd %xmm4, %xmm0
; SSE4-NEXT:    pminsd %xmm5, %xmm1
; SSE4-NEXT:    pminsd %xmm6, %xmm2
; SSE4-NEXT:    pminsd %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test114:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpminsd %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpminsd %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpminsd %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpminsd %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test114:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminsd %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpminsd %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test114:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminsd %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp sle <16 x i32> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i32> %a, <16 x i32> %b
  ret <16 x i32> %sel
}

define <16 x i32> @test115(<16 x i32> %a, <16 x i32> %b) {
; SSE2-LABEL: test115:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm3, %xmm8
; SSE2-NEXT:    pcmpgtd %xmm7, %xmm3
; SSE2-NEXT:    movdqa %xmm2, %xmm9
; SSE2-NEXT:    pcmpgtd %xmm6, %xmm9
; SSE2-NEXT:    movdqa %xmm1, %xmm10
; SSE2-NEXT:    pcmpgtd %xmm5, %xmm10
; SSE2-NEXT:    movdqa %xmm0, %xmm11
; SSE2-NEXT:    pcmpgtd %xmm4, %xmm11
; SSE2-NEXT:    pand %xmm11, %xmm0
; SSE2-NEXT:    pandn %xmm4, %xmm11
; SSE2-NEXT:    por %xmm0, %xmm11
; SSE2-NEXT:    pand %xmm10, %xmm1
; SSE2-NEXT:    pandn %xmm5, %xmm10
; SSE2-NEXT:    por %xmm1, %xmm10
; SSE2-NEXT:    pand %xmm9, %xmm2
; SSE2-NEXT:    pandn %xmm6, %xmm9
; SSE2-NEXT:    por %xmm2, %xmm9
; SSE2-NEXT:    pand %xmm3, %xmm8
; SSE2-NEXT:    pandn %xmm7, %xmm3
; SSE2-NEXT:    por %xmm8, %xmm3
; SSE2-NEXT:    movdqa %xmm11, %xmm0
; SSE2-NEXT:    movdqa %xmm10, %xmm1
; SSE2-NEXT:    movdqa %xmm9, %xmm2
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test115:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxsd %xmm4, %xmm0
; SSE4-NEXT:    pmaxsd %xmm5, %xmm1
; SSE4-NEXT:    pmaxsd %xmm6, %xmm2
; SSE4-NEXT:    pmaxsd %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test115:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpmaxsd %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpmaxsd %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpmaxsd %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpmaxsd %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test115:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxsd %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpmaxsd %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test115:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxsd %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp sgt <16 x i32> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i32> %a, <16 x i32> %b
  ret <16 x i32> %sel
}

define <16 x i32> @test116(<16 x i32> %a, <16 x i32> %b) {
; SSE2-LABEL: test116:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm3, %xmm8
; SSE2-NEXT:    movdqa %xmm2, %xmm9
; SSE2-NEXT:    movdqa %xmm0, %xmm10
; SSE2-NEXT:    movdqa %xmm7, %xmm12
; SSE2-NEXT:    pcmpgtd %xmm8, %xmm12
; SSE2-NEXT:    pcmpeqd %xmm0, %xmm0
; SSE2-NEXT:    movdqa %xmm12, %xmm3
; SSE2-NEXT:    pxor %xmm0, %xmm3
; SSE2-NEXT:    movdqa %xmm6, %xmm13
; SSE2-NEXT:    pcmpgtd %xmm9, %xmm13
; SSE2-NEXT:    movdqa %xmm13, %xmm2
; SSE2-NEXT:    pxor %xmm0, %xmm2
; SSE2-NEXT:    movdqa %xmm5, %xmm14
; SSE2-NEXT:    pcmpgtd %xmm1, %xmm14
; SSE2-NEXT:    movdqa %xmm14, %xmm11
; SSE2-NEXT:    pxor %xmm0, %xmm11
; SSE2-NEXT:    movdqa %xmm4, %xmm15
; SSE2-NEXT:    pcmpgtd %xmm10, %xmm15
; SSE2-NEXT:    pxor %xmm15, %xmm0
; SSE2-NEXT:    pandn %xmm10, %xmm15
; SSE2-NEXT:    pandn %xmm4, %xmm0
; SSE2-NEXT:    por %xmm15, %xmm0
; SSE2-NEXT:    pandn %xmm1, %xmm14
; SSE2-NEXT:    pandn %xmm5, %xmm11
; SSE2-NEXT:    por %xmm14, %xmm11
; SSE2-NEXT:    pandn %xmm9, %xmm13
; SSE2-NEXT:    pandn %xmm6, %xmm2
; SSE2-NEXT:    por %xmm13, %xmm2
; SSE2-NEXT:    pandn %xmm8, %xmm12
; SSE2-NEXT:    pandn %xmm7, %xmm3
; SSE2-NEXT:    por %xmm12, %xmm3
; SSE2-NEXT:    movdqa %xmm11, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test116:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxsd %xmm4, %xmm0
; SSE4-NEXT:    pmaxsd %xmm5, %xmm1
; SSE4-NEXT:    pmaxsd %xmm6, %xmm2
; SSE4-NEXT:    pmaxsd %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test116:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpmaxsd %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpmaxsd %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpmaxsd %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpmaxsd %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test116:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxsd %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpmaxsd %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test116:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxsd %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp sge <16 x i32> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i32> %a, <16 x i32> %b
  ret <16 x i32> %sel
}

define <16 x i32> @test117(<16 x i32> %a, <16 x i32> %b) {
; SSE2-LABEL: test117:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm10 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm3, %xmm9
; SSE2-NEXT:    pxor %xmm10, %xmm9
; SSE2-NEXT:    movdqa %xmm7, %xmm8
; SSE2-NEXT:    pxor %xmm10, %xmm8
; SSE2-NEXT:    pcmpgtd %xmm9, %xmm8
; SSE2-NEXT:    movdqa %xmm2, %xmm11
; SSE2-NEXT:    pxor %xmm10, %xmm11
; SSE2-NEXT:    movdqa %xmm6, %xmm9
; SSE2-NEXT:    pxor %xmm10, %xmm9
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm9
; SSE2-NEXT:    movdqa %xmm1, %xmm11
; SSE2-NEXT:    pxor %xmm10, %xmm11
; SSE2-NEXT:    movdqa %xmm5, %xmm12
; SSE2-NEXT:    pxor %xmm10, %xmm12
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm12
; SSE2-NEXT:    movdqa %xmm0, %xmm11
; SSE2-NEXT:    pxor %xmm10, %xmm11
; SSE2-NEXT:    pxor %xmm4, %xmm10
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm10
; SSE2-NEXT:    pand %xmm10, %xmm0
; SSE2-NEXT:    pandn %xmm4, %xmm10
; SSE2-NEXT:    por %xmm10, %xmm0
; SSE2-NEXT:    pand %xmm12, %xmm1
; SSE2-NEXT:    pandn %xmm5, %xmm12
; SSE2-NEXT:    por %xmm12, %xmm1
; SSE2-NEXT:    pand %xmm9, %xmm2
; SSE2-NEXT:    pandn %xmm6, %xmm9
; SSE2-NEXT:    por %xmm9, %xmm2
; SSE2-NEXT:    pand %xmm8, %xmm3
; SSE2-NEXT:    pandn %xmm7, %xmm8
; SSE2-NEXT:    por %xmm8, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test117:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminud %xmm4, %xmm0
; SSE4-NEXT:    pminud %xmm5, %xmm1
; SSE4-NEXT:    pminud %xmm6, %xmm2
; SSE4-NEXT:    pminud %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test117:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpminud %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpminud %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpminud %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpminud %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test117:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminud %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpminud %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test117:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminud %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp ult <16 x i32> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i32> %a, <16 x i32> %b
  ret <16 x i32> %sel
}

define <16 x i32> @test118(<16 x i32> %a, <16 x i32> %b) {
; SSE2-LABEL: test118:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm0, %xmm10
; SSE2-NEXT:    movdqa {{.*#+}} xmm14 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm7, %xmm0
; SSE2-NEXT:    pxor %xmm14, %xmm0
; SSE2-NEXT:    movdqa %xmm3, %xmm12
; SSE2-NEXT:    pxor %xmm14, %xmm12
; SSE2-NEXT:    pcmpgtd %xmm0, %xmm12
; SSE2-NEXT:    pcmpeqd %xmm0, %xmm0
; SSE2-NEXT:    movdqa %xmm12, %xmm8
; SSE2-NEXT:    pxor %xmm0, %xmm8
; SSE2-NEXT:    movdqa %xmm6, %xmm9
; SSE2-NEXT:    pxor %xmm14, %xmm9
; SSE2-NEXT:    movdqa %xmm2, %xmm13
; SSE2-NEXT:    pxor %xmm14, %xmm13
; SSE2-NEXT:    pcmpgtd %xmm9, %xmm13
; SSE2-NEXT:    movdqa %xmm13, %xmm9
; SSE2-NEXT:    pxor %xmm0, %xmm9
; SSE2-NEXT:    movdqa %xmm5, %xmm11
; SSE2-NEXT:    pxor %xmm14, %xmm11
; SSE2-NEXT:    movdqa %xmm1, %xmm15
; SSE2-NEXT:    pxor %xmm14, %xmm15
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm15
; SSE2-NEXT:    movdqa %xmm4, %xmm11
; SSE2-NEXT:    pxor %xmm14, %xmm11
; SSE2-NEXT:    pxor %xmm10, %xmm14
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm14
; SSE2-NEXT:    movdqa %xmm15, %xmm11
; SSE2-NEXT:    pxor %xmm0, %xmm11
; SSE2-NEXT:    pxor %xmm14, %xmm0
; SSE2-NEXT:    pandn %xmm10, %xmm14
; SSE2-NEXT:    pandn %xmm4, %xmm0
; SSE2-NEXT:    por %xmm14, %xmm0
; SSE2-NEXT:    pandn %xmm1, %xmm15
; SSE2-NEXT:    pandn %xmm5, %xmm11
; SSE2-NEXT:    por %xmm15, %xmm11
; SSE2-NEXT:    pandn %xmm2, %xmm13
; SSE2-NEXT:    pandn %xmm6, %xmm9
; SSE2-NEXT:    por %xmm13, %xmm9
; SSE2-NEXT:    pandn %xmm3, %xmm12
; SSE2-NEXT:    pandn %xmm7, %xmm8
; SSE2-NEXT:    por %xmm12, %xmm8
; SSE2-NEXT:    movdqa %xmm11, %xmm1
; SSE2-NEXT:    movdqa %xmm9, %xmm2
; SSE2-NEXT:    movdqa %xmm8, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test118:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminud %xmm4, %xmm0
; SSE4-NEXT:    pminud %xmm5, %xmm1
; SSE4-NEXT:    pminud %xmm6, %xmm2
; SSE4-NEXT:    pminud %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test118:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpminud %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpminud %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpminud %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpminud %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test118:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminud %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpminud %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test118:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminud %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp ule <16 x i32> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i32> %a, <16 x i32> %b
  ret <16 x i32> %sel
}

define <16 x i32> @test119(<16 x i32> %a, <16 x i32> %b) {
; SSE2-LABEL: test119:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm11 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm7, %xmm9
; SSE2-NEXT:    pxor %xmm11, %xmm9
; SSE2-NEXT:    movdqa %xmm3, %xmm8
; SSE2-NEXT:    pxor %xmm11, %xmm8
; SSE2-NEXT:    pcmpgtd %xmm9, %xmm8
; SSE2-NEXT:    movdqa %xmm6, %xmm10
; SSE2-NEXT:    pxor %xmm11, %xmm10
; SSE2-NEXT:    movdqa %xmm2, %xmm9
; SSE2-NEXT:    pxor %xmm11, %xmm9
; SSE2-NEXT:    pcmpgtd %xmm10, %xmm9
; SSE2-NEXT:    movdqa %xmm5, %xmm12
; SSE2-NEXT:    pxor %xmm11, %xmm12
; SSE2-NEXT:    movdqa %xmm1, %xmm10
; SSE2-NEXT:    pxor %xmm11, %xmm10
; SSE2-NEXT:    pcmpgtd %xmm12, %xmm10
; SSE2-NEXT:    movdqa %xmm4, %xmm12
; SSE2-NEXT:    pxor %xmm11, %xmm12
; SSE2-NEXT:    pxor %xmm0, %xmm11
; SSE2-NEXT:    pcmpgtd %xmm12, %xmm11
; SSE2-NEXT:    pand %xmm11, %xmm0
; SSE2-NEXT:    pandn %xmm4, %xmm11
; SSE2-NEXT:    por %xmm11, %xmm0
; SSE2-NEXT:    pand %xmm10, %xmm1
; SSE2-NEXT:    pandn %xmm5, %xmm10
; SSE2-NEXT:    por %xmm1, %xmm10
; SSE2-NEXT:    pand %xmm9, %xmm2
; SSE2-NEXT:    pandn %xmm6, %xmm9
; SSE2-NEXT:    por %xmm2, %xmm9
; SSE2-NEXT:    pand %xmm8, %xmm3
; SSE2-NEXT:    pandn %xmm7, %xmm8
; SSE2-NEXT:    por %xmm3, %xmm8
; SSE2-NEXT:    movdqa %xmm10, %xmm1
; SSE2-NEXT:    movdqa %xmm9, %xmm2
; SSE2-NEXT:    movdqa %xmm8, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test119:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxud %xmm4, %xmm0
; SSE4-NEXT:    pmaxud %xmm5, %xmm1
; SSE4-NEXT:    pmaxud %xmm6, %xmm2
; SSE4-NEXT:    pmaxud %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test119:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpmaxud %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpmaxud %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpmaxud %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpmaxud %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test119:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxud %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpmaxud %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test119:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxud %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp ugt <16 x i32> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i32> %a, <16 x i32> %b
  ret <16 x i32> %sel
}

define <16 x i32> @test120(<16 x i32> %a, <16 x i32> %b) {
; SSE2-LABEL: test120:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm0, %xmm10
; SSE2-NEXT:    movdqa {{.*#+}} xmm14 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm3, %xmm0
; SSE2-NEXT:    pxor %xmm14, %xmm0
; SSE2-NEXT:    movdqa %xmm7, %xmm12
; SSE2-NEXT:    pxor %xmm14, %xmm12
; SSE2-NEXT:    pcmpgtd %xmm0, %xmm12
; SSE2-NEXT:    pcmpeqd %xmm0, %xmm0
; SSE2-NEXT:    movdqa %xmm12, %xmm8
; SSE2-NEXT:    pxor %xmm0, %xmm8
; SSE2-NEXT:    movdqa %xmm2, %xmm9
; SSE2-NEXT:    pxor %xmm14, %xmm9
; SSE2-NEXT:    movdqa %xmm6, %xmm13
; SSE2-NEXT:    pxor %xmm14, %xmm13
; SSE2-NEXT:    pcmpgtd %xmm9, %xmm13
; SSE2-NEXT:    movdqa %xmm13, %xmm9
; SSE2-NEXT:    pxor %xmm0, %xmm9
; SSE2-NEXT:    movdqa %xmm1, %xmm11
; SSE2-NEXT:    pxor %xmm14, %xmm11
; SSE2-NEXT:    movdqa %xmm5, %xmm15
; SSE2-NEXT:    pxor %xmm14, %xmm15
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm15
; SSE2-NEXT:    movdqa %xmm10, %xmm11
; SSE2-NEXT:    pxor %xmm14, %xmm11
; SSE2-NEXT:    pxor %xmm4, %xmm14
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm14
; SSE2-NEXT:    movdqa %xmm15, %xmm11
; SSE2-NEXT:    pxor %xmm0, %xmm11
; SSE2-NEXT:    pxor %xmm14, %xmm0
; SSE2-NEXT:    pandn %xmm10, %xmm14
; SSE2-NEXT:    pandn %xmm4, %xmm0
; SSE2-NEXT:    por %xmm14, %xmm0
; SSE2-NEXT:    pandn %xmm1, %xmm15
; SSE2-NEXT:    pandn %xmm5, %xmm11
; SSE2-NEXT:    por %xmm15, %xmm11
; SSE2-NEXT:    pandn %xmm2, %xmm13
; SSE2-NEXT:    pandn %xmm6, %xmm9
; SSE2-NEXT:    por %xmm13, %xmm9
; SSE2-NEXT:    pandn %xmm3, %xmm12
; SSE2-NEXT:    pandn %xmm7, %xmm8
; SSE2-NEXT:    por %xmm12, %xmm8
; SSE2-NEXT:    movdqa %xmm11, %xmm1
; SSE2-NEXT:    movdqa %xmm9, %xmm2
; SSE2-NEXT:    movdqa %xmm8, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test120:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxud %xmm4, %xmm0
; SSE4-NEXT:    pmaxud %xmm5, %xmm1
; SSE4-NEXT:    pmaxud %xmm6, %xmm2
; SSE4-NEXT:    pmaxud %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test120:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpmaxud %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpmaxud %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpmaxud %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpmaxud %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test120:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxud %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpmaxud %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test120:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxud %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp uge <16 x i32> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i32> %a, <16 x i32> %b
  ret <16 x i32> %sel
}

define <8 x i64> @test121(<8 x i64> %a, <8 x i64> %b) {
; SSE2-LABEL: test121:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm9 = [2147483648,0,2147483648,0]
; SSE2-NEXT:    movdqa %xmm3, %xmm8
; SSE2-NEXT:    pxor %xmm9, %xmm8
; SSE2-NEXT:    movdqa %xmm7, %xmm10
; SSE2-NEXT:    pxor %xmm9, %xmm10
; SSE2-NEXT:    movdqa %xmm10, %xmm11
; SSE2-NEXT:    pcmpgtd %xmm8, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm11[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm8, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm10 = xmm10[1,1,3,3]
; SSE2-NEXT:    pand %xmm12, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm11[1,1,3,3]
; SSE2-NEXT:    por %xmm10, %xmm8
; SSE2-NEXT:    movdqa %xmm2, %xmm10
; SSE2-NEXT:    pxor %xmm9, %xmm10
; SSE2-NEXT:    movdqa %xmm6, %xmm11
; SSE2-NEXT:    pxor %xmm9, %xmm11
; SSE2-NEXT:    movdqa %xmm11, %xmm12
; SSE2-NEXT:    pcmpgtd %xmm10, %xmm12
; SSE2-NEXT:    pshufd {{.*#+}} xmm13 = xmm12[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm10, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm11[1,1,3,3]
; SSE2-NEXT:    pand %xmm13, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm10 = xmm12[1,1,3,3]
; SSE2-NEXT:    por %xmm11, %xmm10
; SSE2-NEXT:    movdqa %xmm1, %xmm11
; SSE2-NEXT:    pxor %xmm9, %xmm11
; SSE2-NEXT:    movdqa %xmm5, %xmm12
; SSE2-NEXT:    pxor %xmm9, %xmm12
; SSE2-NEXT:    movdqa %xmm12, %xmm13
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm13
; SSE2-NEXT:    pshufd {{.*#+}} xmm14 = xmm13[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm11, %xmm12
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm12[1,1,3,3]
; SSE2-NEXT:    pand %xmm14, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm13[1,1,3,3]
; SSE2-NEXT:    por %xmm11, %xmm12
; SSE2-NEXT:    movdqa %xmm0, %xmm11
; SSE2-NEXT:    pxor %xmm9, %xmm11
; SSE2-NEXT:    pxor %xmm4, %xmm9
; SSE2-NEXT:    movdqa %xmm9, %xmm13
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm13
; SSE2-NEXT:    pshufd {{.*#+}} xmm14 = xmm13[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm11, %xmm9
; SSE2-NEXT:    pshufd {{.*#+}} xmm9 = xmm9[1,1,3,3]
; SSE2-NEXT:    pand %xmm14, %xmm9
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm13[1,1,3,3]
; SSE2-NEXT:    por %xmm9, %xmm11
; SSE2-NEXT:    pand %xmm11, %xmm0
; SSE2-NEXT:    pandn %xmm4, %xmm11
; SSE2-NEXT:    por %xmm11, %xmm0
; SSE2-NEXT:    pand %xmm12, %xmm1
; SSE2-NEXT:    pandn %xmm5, %xmm12
; SSE2-NEXT:    por %xmm12, %xmm1
; SSE2-NEXT:    pand %xmm10, %xmm2
; SSE2-NEXT:    pandn %xmm6, %xmm10
; SSE2-NEXT:    por %xmm10, %xmm2
; SSE2-NEXT:    pand %xmm8, %xmm3
; SSE2-NEXT:    pandn %xmm7, %xmm8
; SSE2-NEXT:    por %xmm8, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test121:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm8
; SSE4-NEXT:    movdqa %xmm7, %xmm9
; SSE4-NEXT:    pcmpgtq %xmm3, %xmm9
; SSE4-NEXT:    movdqa %xmm6, %xmm10
; SSE4-NEXT:    pcmpgtq %xmm2, %xmm10
; SSE4-NEXT:    movdqa %xmm5, %xmm11
; SSE4-NEXT:    pcmpgtq %xmm1, %xmm11
; SSE4-NEXT:    movdqa %xmm4, %xmm0
; SSE4-NEXT:    pcmpgtq %xmm8, %xmm0
; SSE4-NEXT:    blendvpd %xmm8, %xmm4
; SSE4-NEXT:    movdqa %xmm11, %xmm0
; SSE4-NEXT:    blendvpd %xmm1, %xmm5
; SSE4-NEXT:    movdqa %xmm10, %xmm0
; SSE4-NEXT:    blendvpd %xmm2, %xmm6
; SSE4-NEXT:    movdqa %xmm9, %xmm0
; SSE4-NEXT:    blendvpd %xmm3, %xmm7
; SSE4-NEXT:    movapd %xmm4, %xmm0
; SSE4-NEXT:    movapd %xmm5, %xmm1
; SSE4-NEXT:    movapd %xmm6, %xmm2
; SSE4-NEXT:    movapd %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test121:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm5
; AVX1-NEXT:    vpcmpgtq %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpcmpgtq %xmm1, %xmm3, %xmm5
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm5, %ymm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm6
; AVX1-NEXT:    vpcmpgtq %xmm5, %xmm6, %xmm5
; AVX1-NEXT:    vpcmpgtq %xmm0, %xmm2, %xmm6
; AVX1-NEXT:    vinsertf128 $1, %xmm5, %ymm6, %ymm5
; AVX1-NEXT:    vblendvpd %ymm5, %ymm0, %ymm2, %ymm0
; AVX1-NEXT:    vblendvpd %ymm4, %ymm1, %ymm3, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test121:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpcmpgtq %ymm1, %ymm3, %ymm4
; AVX2-NEXT:    vpcmpgtq %ymm0, %ymm2, %ymm5
; AVX2-NEXT:    vblendvpd %ymm5, %ymm0, %ymm2, %ymm0
; AVX2-NEXT:    vblendvpd %ymm4, %ymm1, %ymm3, %ymm1
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test121:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminsq %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp slt <8 x i64> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i64> %a, <8 x i64> %b
  ret <8 x i64> %sel
}

define <8 x i64> @test122(<8 x i64> %a, <8 x i64> %b) {
; SSE2-LABEL: test122:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm7, %xmm8
; SSE2-NEXT:    movdqa %xmm8, -{{[0-9]+}}(%rsp) # 16-byte Spill
; SSE2-NEXT:    movdqa %xmm3, %xmm7
; SSE2-NEXT:    movdqa %xmm2, %xmm3
; SSE2-NEXT:    movdqa %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm0, %xmm9
; SSE2-NEXT:    movdqa {{.*#+}} xmm10 = [2147483648,0,2147483648,0]
; SSE2-NEXT:    pxor %xmm10, %xmm8
; SSE2-NEXT:    movdqa %xmm7, %xmm0
; SSE2-NEXT:    pxor %xmm10, %xmm0
; SSE2-NEXT:    movdqa %xmm0, %xmm11
; SSE2-NEXT:    pcmpgtd %xmm8, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm11[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm8, %xmm0
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,1,3,3]
; SSE2-NEXT:    pand %xmm12, %xmm0
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm11[1,1,3,3]
; SSE2-NEXT:    por %xmm0, %xmm12
; SSE2-NEXT:    pcmpeqd %xmm1, %xmm1
; SSE2-NEXT:    movdqa %xmm12, %xmm8
; SSE2-NEXT:    pxor %xmm1, %xmm8
; SSE2-NEXT:    movdqa %xmm6, %xmm11
; SSE2-NEXT:    pxor %xmm10, %xmm11
; SSE2-NEXT:    movdqa %xmm3, %xmm13
; SSE2-NEXT:    pxor %xmm10, %xmm13
; SSE2-NEXT:    movdqa %xmm13, %xmm14
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm14
; SSE2-NEXT:    pshufd {{.*#+}} xmm15 = xmm14[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm11, %xmm13
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm13[1,1,3,3]
; SSE2-NEXT:    pand %xmm15, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm13 = xmm14[1,1,3,3]
; SSE2-NEXT:    por %xmm11, %xmm13
; SSE2-NEXT:    movdqa %xmm5, %xmm11
; SSE2-NEXT:    pxor %xmm10, %xmm11
; SSE2-NEXT:    movdqa %xmm2, %xmm14
; SSE2-NEXT:    pxor %xmm10, %xmm14
; SSE2-NEXT:    movdqa %xmm14, %xmm15
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm15
; SSE2-NEXT:    pcmpeqd %xmm11, %xmm14
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm15[0,0,2,2]
; SSE2-NEXT:    pshufd {{.*#+}} xmm14 = xmm14[1,1,3,3]
; SSE2-NEXT:    pand %xmm11, %xmm14
; SSE2-NEXT:    pshufd {{.*#+}} xmm15 = xmm15[1,1,3,3]
; SSE2-NEXT:    por %xmm14, %xmm15
; SSE2-NEXT:    movdqa %xmm4, %xmm11
; SSE2-NEXT:    pxor %xmm10, %xmm11
; SSE2-NEXT:    pxor %xmm9, %xmm10
; SSE2-NEXT:    movdqa %xmm10, %xmm14
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm14
; SSE2-NEXT:    pcmpeqd %xmm11, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm14[0,0,2,2]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm10[1,1,3,3]
; SSE2-NEXT:    pand %xmm11, %xmm0
; SSE2-NEXT:    movdqa %xmm13, %xmm10
; SSE2-NEXT:    pxor %xmm1, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm14 = xmm14[1,1,3,3]
; SSE2-NEXT:    por %xmm0, %xmm14
; SSE2-NEXT:    movdqa %xmm15, %xmm11
; SSE2-NEXT:    pxor %xmm1, %xmm11
; SSE2-NEXT:    pxor %xmm14, %xmm1
; SSE2-NEXT:    pandn %xmm9, %xmm14
; SSE2-NEXT:    pandn %xmm4, %xmm1
; SSE2-NEXT:    por %xmm14, %xmm1
; SSE2-NEXT:    pandn %xmm2, %xmm15
; SSE2-NEXT:    pandn %xmm5, %xmm11
; SSE2-NEXT:    por %xmm15, %xmm11
; SSE2-NEXT:    pandn %xmm3, %xmm13
; SSE2-NEXT:    pandn %xmm6, %xmm10
; SSE2-NEXT:    por %xmm13, %xmm10
; SSE2-NEXT:    pandn %xmm7, %xmm12
; SSE2-NEXT:    pandn -{{[0-9]+}}(%rsp), %xmm8 # 16-byte Folded Reload
; SSE2-NEXT:    por %xmm12, %xmm8
; SSE2-NEXT:    movdqa %xmm1, %xmm0
; SSE2-NEXT:    movdqa %xmm11, %xmm1
; SSE2-NEXT:    movdqa %xmm10, %xmm2
; SSE2-NEXT:    movdqa %xmm8, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test122:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm8
; SSE4-NEXT:    movdqa %xmm3, %xmm9
; SSE4-NEXT:    pcmpgtq %xmm7, %xmm9
; SSE4-NEXT:    pcmpeqd %xmm12, %xmm12
; SSE4-NEXT:    pxor %xmm12, %xmm9
; SSE4-NEXT:    movdqa %xmm2, %xmm10
; SSE4-NEXT:    pcmpgtq %xmm6, %xmm10
; SSE4-NEXT:    pxor %xmm12, %xmm10
; SSE4-NEXT:    movdqa %xmm1, %xmm11
; SSE4-NEXT:    pcmpgtq %xmm5, %xmm11
; SSE4-NEXT:    pxor %xmm12, %xmm11
; SSE4-NEXT:    pcmpgtq %xmm4, %xmm0
; SSE4-NEXT:    pxor %xmm12, %xmm0
; SSE4-NEXT:    blendvpd %xmm8, %xmm4
; SSE4-NEXT:    movdqa %xmm11, %xmm0
; SSE4-NEXT:    blendvpd %xmm1, %xmm5
; SSE4-NEXT:    movdqa %xmm10, %xmm0
; SSE4-NEXT:    blendvpd %xmm2, %xmm6
; SSE4-NEXT:    movdqa %xmm9, %xmm0
; SSE4-NEXT:    blendvpd %xmm3, %xmm7
; SSE4-NEXT:    movapd %xmm4, %xmm0
; SSE4-NEXT:    movapd %xmm5, %xmm1
; SSE4-NEXT:    movapd %xmm6, %xmm2
; SSE4-NEXT:    movapd %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test122:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm5
; AVX1-NEXT:    vpcmpgtq %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpcmpeqd %xmm5, %xmm5, %xmm5
; AVX1-NEXT:    vpxor %xmm5, %xmm4, %xmm4
; AVX1-NEXT:    vpcmpgtq %xmm3, %xmm1, %xmm6
; AVX1-NEXT:    vpxor %xmm5, %xmm6, %xmm6
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm6, %ymm4
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm6
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm7
; AVX1-NEXT:    vpcmpgtq %xmm6, %xmm7, %xmm6
; AVX1-NEXT:    vpxor %xmm5, %xmm6, %xmm6
; AVX1-NEXT:    vpcmpgtq %xmm2, %xmm0, %xmm7
; AVX1-NEXT:    vpxor %xmm5, %xmm7, %xmm5
; AVX1-NEXT:    vinsertf128 $1, %xmm6, %ymm5, %ymm5
; AVX1-NEXT:    vblendvpd %ymm5, %ymm0, %ymm2, %ymm0
; AVX1-NEXT:    vblendvpd %ymm4, %ymm1, %ymm3, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test122:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpcmpgtq %ymm3, %ymm1, %ymm4
; AVX2-NEXT:    vpcmpeqd %ymm5, %ymm5, %ymm5
; AVX2-NEXT:    vpxor %ymm5, %ymm4, %ymm4
; AVX2-NEXT:    vpcmpgtq %ymm2, %ymm0, %ymm6
; AVX2-NEXT:    vpxor %ymm5, %ymm6, %ymm5
; AVX2-NEXT:    vblendvpd %ymm5, %ymm0, %ymm2, %ymm0
; AVX2-NEXT:    vblendvpd %ymm4, %ymm1, %ymm3, %ymm1
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test122:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminsq %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp sle <8 x i64> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i64> %a, <8 x i64> %b
  ret <8 x i64> %sel
}

define <8 x i64> @test123(<8 x i64> %a, <8 x i64> %b) {
; SSE2-LABEL: test123:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm9 = [2147483648,0,2147483648,0]
; SSE2-NEXT:    movdqa %xmm7, %xmm8
; SSE2-NEXT:    pxor %xmm9, %xmm8
; SSE2-NEXT:    movdqa %xmm3, %xmm10
; SSE2-NEXT:    pxor %xmm9, %xmm10
; SSE2-NEXT:    movdqa %xmm10, %xmm11
; SSE2-NEXT:    pcmpgtd %xmm8, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm11[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm8, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm10 = xmm10[1,1,3,3]
; SSE2-NEXT:    pand %xmm12, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm11[1,1,3,3]
; SSE2-NEXT:    por %xmm10, %xmm8
; SSE2-NEXT:    movdqa %xmm6, %xmm10
; SSE2-NEXT:    pxor %xmm9, %xmm10
; SSE2-NEXT:    movdqa %xmm2, %xmm11
; SSE2-NEXT:    pxor %xmm9, %xmm11
; SSE2-NEXT:    movdqa %xmm11, %xmm12
; SSE2-NEXT:    pcmpgtd %xmm10, %xmm12
; SSE2-NEXT:    pshufd {{.*#+}} xmm13 = xmm12[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm10, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm11[1,1,3,3]
; SSE2-NEXT:    pand %xmm13, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm10 = xmm12[1,1,3,3]
; SSE2-NEXT:    por %xmm11, %xmm10
; SSE2-NEXT:    movdqa %xmm5, %xmm11
; SSE2-NEXT:    pxor %xmm9, %xmm11
; SSE2-NEXT:    movdqa %xmm1, %xmm12
; SSE2-NEXT:    pxor %xmm9, %xmm12
; SSE2-NEXT:    movdqa %xmm12, %xmm13
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm13
; SSE2-NEXT:    pshufd {{.*#+}} xmm14 = xmm13[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm11, %xmm12
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm12[1,1,3,3]
; SSE2-NEXT:    pand %xmm14, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm13[1,1,3,3]
; SSE2-NEXT:    por %xmm11, %xmm12
; SSE2-NEXT:    movdqa %xmm4, %xmm11
; SSE2-NEXT:    pxor %xmm9, %xmm11
; SSE2-NEXT:    pxor %xmm0, %xmm9
; SSE2-NEXT:    movdqa %xmm9, %xmm13
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm13
; SSE2-NEXT:    pshufd {{.*#+}} xmm14 = xmm13[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm11, %xmm9
; SSE2-NEXT:    pshufd {{.*#+}} xmm9 = xmm9[1,1,3,3]
; SSE2-NEXT:    pand %xmm14, %xmm9
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm13[1,1,3,3]
; SSE2-NEXT:    por %xmm9, %xmm11
; SSE2-NEXT:    pand %xmm11, %xmm0
; SSE2-NEXT:    pandn %xmm4, %xmm11
; SSE2-NEXT:    por %xmm11, %xmm0
; SSE2-NEXT:    pand %xmm12, %xmm1
; SSE2-NEXT:    pandn %xmm5, %xmm12
; SSE2-NEXT:    por %xmm12, %xmm1
; SSE2-NEXT:    pand %xmm10, %xmm2
; SSE2-NEXT:    pandn %xmm6, %xmm10
; SSE2-NEXT:    por %xmm10, %xmm2
; SSE2-NEXT:    pand %xmm8, %xmm3
; SSE2-NEXT:    pandn %xmm7, %xmm8
; SSE2-NEXT:    por %xmm8, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test123:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm8
; SSE4-NEXT:    movdqa %xmm3, %xmm9
; SSE4-NEXT:    pcmpgtq %xmm7, %xmm9
; SSE4-NEXT:    movdqa %xmm2, %xmm10
; SSE4-NEXT:    pcmpgtq %xmm6, %xmm10
; SSE4-NEXT:    movdqa %xmm1, %xmm11
; SSE4-NEXT:    pcmpgtq %xmm5, %xmm11
; SSE4-NEXT:    pcmpgtq %xmm4, %xmm0
; SSE4-NEXT:    blendvpd %xmm8, %xmm4
; SSE4-NEXT:    movdqa %xmm11, %xmm0
; SSE4-NEXT:    blendvpd %xmm1, %xmm5
; SSE4-NEXT:    movdqa %xmm10, %xmm0
; SSE4-NEXT:    blendvpd %xmm2, %xmm6
; SSE4-NEXT:    movdqa %xmm9, %xmm0
; SSE4-NEXT:    blendvpd %xmm3, %xmm7
; SSE4-NEXT:    movapd %xmm4, %xmm0
; SSE4-NEXT:    movapd %xmm5, %xmm1
; SSE4-NEXT:    movapd %xmm6, %xmm2
; SSE4-NEXT:    movapd %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test123:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm5
; AVX1-NEXT:    vpcmpgtq %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpcmpgtq %xmm3, %xmm1, %xmm5
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm5, %ymm4
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm5
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm6
; AVX1-NEXT:    vpcmpgtq %xmm5, %xmm6, %xmm5
; AVX1-NEXT:    vpcmpgtq %xmm2, %xmm0, %xmm6
; AVX1-NEXT:    vinsertf128 $1, %xmm5, %ymm6, %ymm5
; AVX1-NEXT:    vblendvpd %ymm5, %ymm0, %ymm2, %ymm0
; AVX1-NEXT:    vblendvpd %ymm4, %ymm1, %ymm3, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test123:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpcmpgtq %ymm3, %ymm1, %ymm4
; AVX2-NEXT:    vpcmpgtq %ymm2, %ymm0, %ymm5
; AVX2-NEXT:    vblendvpd %ymm5, %ymm0, %ymm2, %ymm0
; AVX2-NEXT:    vblendvpd %ymm4, %ymm1, %ymm3, %ymm1
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test123:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxsq %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp sgt <8 x i64> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i64> %a, <8 x i64> %b
  ret <8 x i64> %sel
}

define <8 x i64> @test124(<8 x i64> %a, <8 x i64> %b) {
; SSE2-LABEL: test124:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm7, %xmm11
; SSE2-NEXT:    movdqa %xmm11, -{{[0-9]+}}(%rsp) # 16-byte Spill
; SSE2-NEXT:    movdqa %xmm3, %xmm7
; SSE2-NEXT:    movdqa %xmm2, %xmm3
; SSE2-NEXT:    movdqa %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm0, %xmm9
; SSE2-NEXT:    movdqa {{.*#+}} xmm10 = [2147483648,0,2147483648,0]
; SSE2-NEXT:    movdqa %xmm7, %xmm8
; SSE2-NEXT:    pxor %xmm10, %xmm8
; SSE2-NEXT:    movdqa %xmm11, %xmm0
; SSE2-NEXT:    pxor %xmm10, %xmm0
; SSE2-NEXT:    movdqa %xmm0, %xmm11
; SSE2-NEXT:    pcmpgtd %xmm8, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm11[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm8, %xmm0
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,1,3,3]
; SSE2-NEXT:    pand %xmm12, %xmm0
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm11[1,1,3,3]
; SSE2-NEXT:    por %xmm0, %xmm12
; SSE2-NEXT:    pcmpeqd %xmm1, %xmm1
; SSE2-NEXT:    movdqa %xmm12, %xmm8
; SSE2-NEXT:    pxor %xmm1, %xmm8
; SSE2-NEXT:    movdqa %xmm3, %xmm11
; SSE2-NEXT:    pxor %xmm10, %xmm11
; SSE2-NEXT:    movdqa %xmm6, %xmm13
; SSE2-NEXT:    pxor %xmm10, %xmm13
; SSE2-NEXT:    movdqa %xmm13, %xmm14
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm14
; SSE2-NEXT:    pshufd {{.*#+}} xmm15 = xmm14[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm11, %xmm13
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm13[1,1,3,3]
; SSE2-NEXT:    pand %xmm15, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm13 = xmm14[1,1,3,3]
; SSE2-NEXT:    por %xmm11, %xmm13
; SSE2-NEXT:    movdqa %xmm2, %xmm11
; SSE2-NEXT:    pxor %xmm10, %xmm11
; SSE2-NEXT:    movdqa %xmm5, %xmm14
; SSE2-NEXT:    pxor %xmm10, %xmm14
; SSE2-NEXT:    movdqa %xmm14, %xmm15
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm15
; SSE2-NEXT:    pcmpeqd %xmm11, %xmm14
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm15[0,0,2,2]
; SSE2-NEXT:    pshufd {{.*#+}} xmm14 = xmm14[1,1,3,3]
; SSE2-NEXT:    pand %xmm11, %xmm14
; SSE2-NEXT:    pshufd {{.*#+}} xmm15 = xmm15[1,1,3,3]
; SSE2-NEXT:    por %xmm14, %xmm15
; SSE2-NEXT:    movdqa %xmm9, %xmm11
; SSE2-NEXT:    pxor %xmm10, %xmm11
; SSE2-NEXT:    pxor %xmm4, %xmm10
; SSE2-NEXT:    movdqa %xmm10, %xmm14
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm14
; SSE2-NEXT:    pcmpeqd %xmm11, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm14[0,0,2,2]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm10[1,1,3,3]
; SSE2-NEXT:    pand %xmm11, %xmm0
; SSE2-NEXT:    movdqa %xmm13, %xmm10
; SSE2-NEXT:    pxor %xmm1, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm14 = xmm14[1,1,3,3]
; SSE2-NEXT:    por %xmm0, %xmm14
; SSE2-NEXT:    movdqa %xmm15, %xmm11
; SSE2-NEXT:    pxor %xmm1, %xmm11
; SSE2-NEXT:    pxor %xmm14, %xmm1
; SSE2-NEXT:    pandn %xmm9, %xmm14
; SSE2-NEXT:    pandn %xmm4, %xmm1
; SSE2-NEXT:    por %xmm14, %xmm1
; SSE2-NEXT:    pandn %xmm2, %xmm15
; SSE2-NEXT:    pandn %xmm5, %xmm11
; SSE2-NEXT:    por %xmm15, %xmm11
; SSE2-NEXT:    pandn %xmm3, %xmm13
; SSE2-NEXT:    pandn %xmm6, %xmm10
; SSE2-NEXT:    por %xmm13, %xmm10
; SSE2-NEXT:    pandn %xmm7, %xmm12
; SSE2-NEXT:    pandn -{{[0-9]+}}(%rsp), %xmm8 # 16-byte Folded Reload
; SSE2-NEXT:    por %xmm12, %xmm8
; SSE2-NEXT:    movdqa %xmm1, %xmm0
; SSE2-NEXT:    movdqa %xmm11, %xmm1
; SSE2-NEXT:    movdqa %xmm10, %xmm2
; SSE2-NEXT:    movdqa %xmm8, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test124:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm8
; SSE4-NEXT:    movdqa %xmm7, %xmm9
; SSE4-NEXT:    pcmpgtq %xmm3, %xmm9
; SSE4-NEXT:    pcmpeqd %xmm0, %xmm0
; SSE4-NEXT:    pxor %xmm0, %xmm9
; SSE4-NEXT:    movdqa %xmm6, %xmm10
; SSE4-NEXT:    pcmpgtq %xmm2, %xmm10
; SSE4-NEXT:    pxor %xmm0, %xmm10
; SSE4-NEXT:    movdqa %xmm5, %xmm11
; SSE4-NEXT:    pcmpgtq %xmm1, %xmm11
; SSE4-NEXT:    pxor %xmm0, %xmm11
; SSE4-NEXT:    movdqa %xmm4, %xmm12
; SSE4-NEXT:    pcmpgtq %xmm8, %xmm12
; SSE4-NEXT:    pxor %xmm12, %xmm0
; SSE4-NEXT:    blendvpd %xmm8, %xmm4
; SSE4-NEXT:    movdqa %xmm11, %xmm0
; SSE4-NEXT:    blendvpd %xmm1, %xmm5
; SSE4-NEXT:    movdqa %xmm10, %xmm0
; SSE4-NEXT:    blendvpd %xmm2, %xmm6
; SSE4-NEXT:    movdqa %xmm9, %xmm0
; SSE4-NEXT:    blendvpd %xmm3, %xmm7
; SSE4-NEXT:    movapd %xmm4, %xmm0
; SSE4-NEXT:    movapd %xmm5, %xmm1
; SSE4-NEXT:    movapd %xmm6, %xmm2
; SSE4-NEXT:    movapd %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test124:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm5
; AVX1-NEXT:    vpcmpgtq %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpcmpeqd %xmm5, %xmm5, %xmm5
; AVX1-NEXT:    vpxor %xmm5, %xmm4, %xmm4
; AVX1-NEXT:    vpcmpgtq %xmm1, %xmm3, %xmm6
; AVX1-NEXT:    vpxor %xmm5, %xmm6, %xmm6
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm6, %ymm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm6
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm7
; AVX1-NEXT:    vpcmpgtq %xmm6, %xmm7, %xmm6
; AVX1-NEXT:    vpxor %xmm5, %xmm6, %xmm6
; AVX1-NEXT:    vpcmpgtq %xmm0, %xmm2, %xmm7
; AVX1-NEXT:    vpxor %xmm5, %xmm7, %xmm5
; AVX1-NEXT:    vinsertf128 $1, %xmm6, %ymm5, %ymm5
; AVX1-NEXT:    vblendvpd %ymm5, %ymm0, %ymm2, %ymm0
; AVX1-NEXT:    vblendvpd %ymm4, %ymm1, %ymm3, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test124:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpcmpgtq %ymm1, %ymm3, %ymm4
; AVX2-NEXT:    vpcmpeqd %ymm5, %ymm5, %ymm5
; AVX2-NEXT:    vpxor %ymm5, %ymm4, %ymm4
; AVX2-NEXT:    vpcmpgtq %ymm0, %ymm2, %ymm6
; AVX2-NEXT:    vpxor %ymm5, %ymm6, %ymm5
; AVX2-NEXT:    vblendvpd %ymm5, %ymm0, %ymm2, %ymm0
; AVX2-NEXT:    vblendvpd %ymm4, %ymm1, %ymm3, %ymm1
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test124:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxsq %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp sge <8 x i64> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i64> %a, <8 x i64> %b
  ret <8 x i64> %sel
}

define <8 x i64> @test125(<8 x i64> %a, <8 x i64> %b) {
; SSE2-LABEL: test125:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm9 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm3, %xmm8
; SSE2-NEXT:    pxor %xmm9, %xmm8
; SSE2-NEXT:    movdqa %xmm7, %xmm10
; SSE2-NEXT:    pxor %xmm9, %xmm10
; SSE2-NEXT:    movdqa %xmm10, %xmm11
; SSE2-NEXT:    pcmpgtd %xmm8, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm11[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm8, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm10 = xmm10[1,1,3,3]
; SSE2-NEXT:    pand %xmm12, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm11[1,1,3,3]
; SSE2-NEXT:    por %xmm10, %xmm8
; SSE2-NEXT:    movdqa %xmm2, %xmm10
; SSE2-NEXT:    pxor %xmm9, %xmm10
; SSE2-NEXT:    movdqa %xmm6, %xmm11
; SSE2-NEXT:    pxor %xmm9, %xmm11
; SSE2-NEXT:    movdqa %xmm11, %xmm12
; SSE2-NEXT:    pcmpgtd %xmm10, %xmm12
; SSE2-NEXT:    pshufd {{.*#+}} xmm13 = xmm12[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm10, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm11[1,1,3,3]
; SSE2-NEXT:    pand %xmm13, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm10 = xmm12[1,1,3,3]
; SSE2-NEXT:    por %xmm11, %xmm10
; SSE2-NEXT:    movdqa %xmm1, %xmm11
; SSE2-NEXT:    pxor %xmm9, %xmm11
; SSE2-NEXT:    movdqa %xmm5, %xmm12
; SSE2-NEXT:    pxor %xmm9, %xmm12
; SSE2-NEXT:    movdqa %xmm12, %xmm13
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm13
; SSE2-NEXT:    pshufd {{.*#+}} xmm14 = xmm13[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm11, %xmm12
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm12[1,1,3,3]
; SSE2-NEXT:    pand %xmm14, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm13[1,1,3,3]
; SSE2-NEXT:    por %xmm11, %xmm12
; SSE2-NEXT:    movdqa %xmm0, %xmm11
; SSE2-NEXT:    pxor %xmm9, %xmm11
; SSE2-NEXT:    pxor %xmm4, %xmm9
; SSE2-NEXT:    movdqa %xmm9, %xmm13
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm13
; SSE2-NEXT:    pshufd {{.*#+}} xmm14 = xmm13[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm11, %xmm9
; SSE2-NEXT:    pshufd {{.*#+}} xmm9 = xmm9[1,1,3,3]
; SSE2-NEXT:    pand %xmm14, %xmm9
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm13[1,1,3,3]
; SSE2-NEXT:    por %xmm9, %xmm11
; SSE2-NEXT:    pand %xmm11, %xmm0
; SSE2-NEXT:    pandn %xmm4, %xmm11
; SSE2-NEXT:    por %xmm11, %xmm0
; SSE2-NEXT:    pand %xmm12, %xmm1
; SSE2-NEXT:    pandn %xmm5, %xmm12
; SSE2-NEXT:    por %xmm12, %xmm1
; SSE2-NEXT:    pand %xmm10, %xmm2
; SSE2-NEXT:    pandn %xmm6, %xmm10
; SSE2-NEXT:    por %xmm10, %xmm2
; SSE2-NEXT:    pand %xmm8, %xmm3
; SSE2-NEXT:    pandn %xmm7, %xmm8
; SSE2-NEXT:    por %xmm8, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test125:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm8
; SSE4-NEXT:    movdqa {{.*#+}} xmm0 = [9223372036854775808,9223372036854775808]
; SSE4-NEXT:    movdqa %xmm3, %xmm10
; SSE4-NEXT:    pxor %xmm0, %xmm10
; SSE4-NEXT:    movdqa %xmm7, %xmm9
; SSE4-NEXT:    pxor %xmm0, %xmm9
; SSE4-NEXT:    pcmpgtq %xmm10, %xmm9
; SSE4-NEXT:    movdqa %xmm2, %xmm11
; SSE4-NEXT:    pxor %xmm0, %xmm11
; SSE4-NEXT:    movdqa %xmm6, %xmm10
; SSE4-NEXT:    pxor %xmm0, %xmm10
; SSE4-NEXT:    pcmpgtq %xmm11, %xmm10
; SSE4-NEXT:    movdqa %xmm1, %xmm12
; SSE4-NEXT:    pxor %xmm0, %xmm12
; SSE4-NEXT:    movdqa %xmm5, %xmm11
; SSE4-NEXT:    pxor %xmm0, %xmm11
; SSE4-NEXT:    pcmpgtq %xmm12, %xmm11
; SSE4-NEXT:    movdqa %xmm8, %xmm12
; SSE4-NEXT:    pxor %xmm0, %xmm12
; SSE4-NEXT:    pxor %xmm4, %xmm0
; SSE4-NEXT:    pcmpgtq %xmm12, %xmm0
; SSE4-NEXT:    blendvpd %xmm8, %xmm4
; SSE4-NEXT:    movdqa %xmm11, %xmm0
; SSE4-NEXT:    blendvpd %xmm1, %xmm5
; SSE4-NEXT:    movdqa %xmm10, %xmm0
; SSE4-NEXT:    blendvpd %xmm2, %xmm6
; SSE4-NEXT:    movdqa %xmm9, %xmm0
; SSE4-NEXT:    blendvpd %xmm3, %xmm7
; SSE4-NEXT:    movapd %xmm4, %xmm0
; SSE4-NEXT:    movapd %xmm5, %xmm1
; SSE4-NEXT:    movapd %xmm6, %xmm2
; SSE4-NEXT:    movapd %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test125:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vmovaps {{.*#+}} xmm5 = [9223372036854775808,9223372036854775808]
; AVX1-NEXT:    vxorps %xmm5, %xmm4, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm6
; AVX1-NEXT:    vxorps %xmm5, %xmm6, %xmm6
; AVX1-NEXT:    vpcmpgtq %xmm4, %xmm6, %xmm4
; AVX1-NEXT:    vxorps %xmm5, %xmm1, %xmm6
; AVX1-NEXT:    vxorps %xmm5, %xmm3, %xmm7
; AVX1-NEXT:    vpcmpgtq %xmm6, %xmm7, %xmm6
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm6, %ymm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm6
; AVX1-NEXT:    vxorps %xmm5, %xmm6, %xmm6
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm7
; AVX1-NEXT:    vxorps %xmm5, %xmm7, %xmm7
; AVX1-NEXT:    vpcmpgtq %xmm6, %xmm7, %xmm6
; AVX1-NEXT:    vxorps %xmm5, %xmm0, %xmm7
; AVX1-NEXT:    vxorps %xmm5, %xmm2, %xmm5
; AVX1-NEXT:    vpcmpgtq %xmm7, %xmm5, %xmm5
; AVX1-NEXT:    vinsertf128 $1, %xmm6, %ymm5, %ymm5
; AVX1-NEXT:    vblendvpd %ymm5, %ymm0, %ymm2, %ymm0
; AVX1-NEXT:    vblendvpd %ymm4, %ymm1, %ymm3, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test125:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpbroadcastq {{.*}}(%rip), %ymm4
; AVX2-NEXT:    vpxor %ymm4, %ymm1, %ymm5
; AVX2-NEXT:    vpxor %ymm4, %ymm3, %ymm6
; AVX2-NEXT:    vpcmpgtq %ymm5, %ymm6, %ymm5
; AVX2-NEXT:    vpxor %ymm4, %ymm0, %ymm6
; AVX2-NEXT:    vpxor %ymm4, %ymm2, %ymm4
; AVX2-NEXT:    vpcmpgtq %ymm6, %ymm4, %ymm4
; AVX2-NEXT:    vblendvpd %ymm4, %ymm0, %ymm2, %ymm0
; AVX2-NEXT:    vblendvpd %ymm5, %ymm1, %ymm3, %ymm1
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test125:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminuq %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp ult <8 x i64> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i64> %a, <8 x i64> %b
  ret <8 x i64> %sel
}

define <8 x i64> @test126(<8 x i64> %a, <8 x i64> %b) {
; SSE2-LABEL: test126:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm7, %xmm8
; SSE2-NEXT:    movdqa %xmm8, -{{[0-9]+}}(%rsp) # 16-byte Spill
; SSE2-NEXT:    movdqa %xmm3, %xmm7
; SSE2-NEXT:    movdqa %xmm2, %xmm3
; SSE2-NEXT:    movdqa %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm0, %xmm9
; SSE2-NEXT:    movdqa {{.*#+}} xmm10 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    pxor %xmm10, %xmm8
; SSE2-NEXT:    movdqa %xmm7, %xmm0
; SSE2-NEXT:    pxor %xmm10, %xmm0
; SSE2-NEXT:    movdqa %xmm0, %xmm11
; SSE2-NEXT:    pcmpgtd %xmm8, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm11[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm8, %xmm0
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,1,3,3]
; SSE2-NEXT:    pand %xmm12, %xmm0
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm11[1,1,3,3]
; SSE2-NEXT:    por %xmm0, %xmm12
; SSE2-NEXT:    pcmpeqd %xmm1, %xmm1
; SSE2-NEXT:    movdqa %xmm12, %xmm8
; SSE2-NEXT:    pxor %xmm1, %xmm8
; SSE2-NEXT:    movdqa %xmm6, %xmm11
; SSE2-NEXT:    pxor %xmm10, %xmm11
; SSE2-NEXT:    movdqa %xmm3, %xmm13
; SSE2-NEXT:    pxor %xmm10, %xmm13
; SSE2-NEXT:    movdqa %xmm13, %xmm14
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm14
; SSE2-NEXT:    pshufd {{.*#+}} xmm15 = xmm14[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm11, %xmm13
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm13[1,1,3,3]
; SSE2-NEXT:    pand %xmm15, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm13 = xmm14[1,1,3,3]
; SSE2-NEXT:    por %xmm11, %xmm13
; SSE2-NEXT:    movdqa %xmm5, %xmm11
; SSE2-NEXT:    pxor %xmm10, %xmm11
; SSE2-NEXT:    movdqa %xmm2, %xmm14
; SSE2-NEXT:    pxor %xmm10, %xmm14
; SSE2-NEXT:    movdqa %xmm14, %xmm15
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm15
; SSE2-NEXT:    pcmpeqd %xmm11, %xmm14
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm15[0,0,2,2]
; SSE2-NEXT:    pshufd {{.*#+}} xmm14 = xmm14[1,1,3,3]
; SSE2-NEXT:    pand %xmm11, %xmm14
; SSE2-NEXT:    pshufd {{.*#+}} xmm15 = xmm15[1,1,3,3]
; SSE2-NEXT:    por %xmm14, %xmm15
; SSE2-NEXT:    movdqa %xmm4, %xmm11
; SSE2-NEXT:    pxor %xmm10, %xmm11
; SSE2-NEXT:    pxor %xmm9, %xmm10
; SSE2-NEXT:    movdqa %xmm10, %xmm14
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm14
; SSE2-NEXT:    pcmpeqd %xmm11, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm14[0,0,2,2]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm10[1,1,3,3]
; SSE2-NEXT:    pand %xmm11, %xmm0
; SSE2-NEXT:    movdqa %xmm13, %xmm10
; SSE2-NEXT:    pxor %xmm1, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm14 = xmm14[1,1,3,3]
; SSE2-NEXT:    por %xmm0, %xmm14
; SSE2-NEXT:    movdqa %xmm15, %xmm11
; SSE2-NEXT:    pxor %xmm1, %xmm11
; SSE2-NEXT:    pxor %xmm14, %xmm1
; SSE2-NEXT:    pandn %xmm9, %xmm14
; SSE2-NEXT:    pandn %xmm4, %xmm1
; SSE2-NEXT:    por %xmm14, %xmm1
; SSE2-NEXT:    pandn %xmm2, %xmm15
; SSE2-NEXT:    pandn %xmm5, %xmm11
; SSE2-NEXT:    por %xmm15, %xmm11
; SSE2-NEXT:    pandn %xmm3, %xmm13
; SSE2-NEXT:    pandn %xmm6, %xmm10
; SSE2-NEXT:    por %xmm13, %xmm10
; SSE2-NEXT:    pandn %xmm7, %xmm12
; SSE2-NEXT:    pandn -{{[0-9]+}}(%rsp), %xmm8 # 16-byte Folded Reload
; SSE2-NEXT:    por %xmm12, %xmm8
; SSE2-NEXT:    movdqa %xmm1, %xmm0
; SSE2-NEXT:    movdqa %xmm11, %xmm1
; SSE2-NEXT:    movdqa %xmm10, %xmm2
; SSE2-NEXT:    movdqa %xmm8, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test126:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm9
; SSE4-NEXT:    movdqa {{.*#+}} xmm0 = [9223372036854775808,9223372036854775808]
; SSE4-NEXT:    movdqa %xmm7, %xmm10
; SSE4-NEXT:    pxor %xmm0, %xmm10
; SSE4-NEXT:    movdqa %xmm3, %xmm8
; SSE4-NEXT:    pxor %xmm0, %xmm8
; SSE4-NEXT:    pcmpgtq %xmm10, %xmm8
; SSE4-NEXT:    pcmpeqd %xmm12, %xmm12
; SSE4-NEXT:    pxor %xmm12, %xmm8
; SSE4-NEXT:    movdqa %xmm6, %xmm11
; SSE4-NEXT:    pxor %xmm0, %xmm11
; SSE4-NEXT:    movdqa %xmm2, %xmm10
; SSE4-NEXT:    pxor %xmm0, %xmm10
; SSE4-NEXT:    pcmpgtq %xmm11, %xmm10
; SSE4-NEXT:    pxor %xmm12, %xmm10
; SSE4-NEXT:    movdqa %xmm5, %xmm13
; SSE4-NEXT:    pxor %xmm0, %xmm13
; SSE4-NEXT:    movdqa %xmm1, %xmm11
; SSE4-NEXT:    pxor %xmm0, %xmm11
; SSE4-NEXT:    pcmpgtq %xmm13, %xmm11
; SSE4-NEXT:    pxor %xmm12, %xmm11
; SSE4-NEXT:    movdqa %xmm4, %xmm13
; SSE4-NEXT:    pxor %xmm0, %xmm13
; SSE4-NEXT:    pxor %xmm9, %xmm0
; SSE4-NEXT:    pcmpgtq %xmm13, %xmm0
; SSE4-NEXT:    pxor %xmm12, %xmm0
; SSE4-NEXT:    blendvpd %xmm9, %xmm4
; SSE4-NEXT:    movdqa %xmm11, %xmm0
; SSE4-NEXT:    blendvpd %xmm1, %xmm5
; SSE4-NEXT:    movdqa %xmm10, %xmm0
; SSE4-NEXT:    blendvpd %xmm2, %xmm6
; SSE4-NEXT:    movdqa %xmm8, %xmm0
; SSE4-NEXT:    blendvpd %xmm3, %xmm7
; SSE4-NEXT:    movapd %xmm4, %xmm0
; SSE4-NEXT:    movapd %xmm5, %xmm1
; SSE4-NEXT:    movapd %xmm6, %xmm2
; SSE4-NEXT:    movapd %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test126:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm4
; AVX1-NEXT:    vmovaps {{.*#+}} xmm5 = [9223372036854775808,9223372036854775808]
; AVX1-NEXT:    vxorps %xmm5, %xmm4, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm6
; AVX1-NEXT:    vxorps %xmm5, %xmm6, %xmm6
; AVX1-NEXT:    vpcmpgtq %xmm4, %xmm6, %xmm4
; AVX1-NEXT:    vpcmpeqd %xmm8, %xmm8, %xmm8
; AVX1-NEXT:    vpxor %xmm8, %xmm4, %xmm4
; AVX1-NEXT:    vxorps %xmm5, %xmm3, %xmm7
; AVX1-NEXT:    vxorps %xmm5, %xmm1, %xmm6
; AVX1-NEXT:    vpcmpgtq %xmm7, %xmm6, %xmm6
; AVX1-NEXT:    vpxor %xmm8, %xmm6, %xmm6
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm6, %ymm4
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm6
; AVX1-NEXT:    vxorps %xmm5, %xmm6, %xmm6
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm7
; AVX1-NEXT:    vxorps %xmm5, %xmm7, %xmm7
; AVX1-NEXT:    vpcmpgtq %xmm6, %xmm7, %xmm6
; AVX1-NEXT:    vpxor %xmm8, %xmm6, %xmm6
; AVX1-NEXT:    vxorps %xmm5, %xmm2, %xmm7
; AVX1-NEXT:    vxorps %xmm5, %xmm0, %xmm5
; AVX1-NEXT:    vpcmpgtq %xmm7, %xmm5, %xmm5
; AVX1-NEXT:    vpxor %xmm8, %xmm5, %xmm5
; AVX1-NEXT:    vinsertf128 $1, %xmm6, %ymm5, %ymm5
; AVX1-NEXT:    vblendvpd %ymm5, %ymm0, %ymm2, %ymm0
; AVX1-NEXT:    vblendvpd %ymm4, %ymm1, %ymm3, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test126:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpbroadcastq {{.*}}(%rip), %ymm4
; AVX2-NEXT:    vpxor %ymm4, %ymm3, %ymm5
; AVX2-NEXT:    vpxor %ymm4, %ymm1, %ymm6
; AVX2-NEXT:    vpcmpgtq %ymm5, %ymm6, %ymm5
; AVX2-NEXT:    vpcmpeqd %ymm6, %ymm6, %ymm6
; AVX2-NEXT:    vpxor %ymm6, %ymm5, %ymm5
; AVX2-NEXT:    vpxor %ymm4, %ymm2, %ymm7
; AVX2-NEXT:    vpxor %ymm4, %ymm0, %ymm4
; AVX2-NEXT:    vpcmpgtq %ymm7, %ymm4, %ymm4
; AVX2-NEXT:    vpxor %ymm6, %ymm4, %ymm4
; AVX2-NEXT:    vblendvpd %ymm4, %ymm0, %ymm2, %ymm0
; AVX2-NEXT:    vblendvpd %ymm5, %ymm1, %ymm3, %ymm1
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test126:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminuq %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp ule <8 x i64> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i64> %a, <8 x i64> %b
  ret <8 x i64> %sel
}

define <8 x i64> @test127(<8 x i64> %a, <8 x i64> %b) {
; SSE2-LABEL: test127:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm9 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm7, %xmm8
; SSE2-NEXT:    pxor %xmm9, %xmm8
; SSE2-NEXT:    movdqa %xmm3, %xmm10
; SSE2-NEXT:    pxor %xmm9, %xmm10
; SSE2-NEXT:    movdqa %xmm10, %xmm11
; SSE2-NEXT:    pcmpgtd %xmm8, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm11[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm8, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm10 = xmm10[1,1,3,3]
; SSE2-NEXT:    pand %xmm12, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm11[1,1,3,3]
; SSE2-NEXT:    por %xmm10, %xmm8
; SSE2-NEXT:    movdqa %xmm6, %xmm10
; SSE2-NEXT:    pxor %xmm9, %xmm10
; SSE2-NEXT:    movdqa %xmm2, %xmm11
; SSE2-NEXT:    pxor %xmm9, %xmm11
; SSE2-NEXT:    movdqa %xmm11, %xmm12
; SSE2-NEXT:    pcmpgtd %xmm10, %xmm12
; SSE2-NEXT:    pshufd {{.*#+}} xmm13 = xmm12[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm10, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm11[1,1,3,3]
; SSE2-NEXT:    pand %xmm13, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm10 = xmm12[1,1,3,3]
; SSE2-NEXT:    por %xmm11, %xmm10
; SSE2-NEXT:    movdqa %xmm5, %xmm11
; SSE2-NEXT:    pxor %xmm9, %xmm11
; SSE2-NEXT:    movdqa %xmm1, %xmm12
; SSE2-NEXT:    pxor %xmm9, %xmm12
; SSE2-NEXT:    movdqa %xmm12, %xmm13
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm13
; SSE2-NEXT:    pshufd {{.*#+}} xmm14 = xmm13[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm11, %xmm12
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm12[1,1,3,3]
; SSE2-NEXT:    pand %xmm14, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm13[1,1,3,3]
; SSE2-NEXT:    por %xmm11, %xmm12
; SSE2-NEXT:    movdqa %xmm4, %xmm11
; SSE2-NEXT:    pxor %xmm9, %xmm11
; SSE2-NEXT:    pxor %xmm0, %xmm9
; SSE2-NEXT:    movdqa %xmm9, %xmm13
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm13
; SSE2-NEXT:    pshufd {{.*#+}} xmm14 = xmm13[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm11, %xmm9
; SSE2-NEXT:    pshufd {{.*#+}} xmm9 = xmm9[1,1,3,3]
; SSE2-NEXT:    pand %xmm14, %xmm9
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm13[1,1,3,3]
; SSE2-NEXT:    por %xmm9, %xmm11
; SSE2-NEXT:    pand %xmm11, %xmm0
; SSE2-NEXT:    pandn %xmm4, %xmm11
; SSE2-NEXT:    por %xmm11, %xmm0
; SSE2-NEXT:    pand %xmm12, %xmm1
; SSE2-NEXT:    pandn %xmm5, %xmm12
; SSE2-NEXT:    por %xmm12, %xmm1
; SSE2-NEXT:    pand %xmm10, %xmm2
; SSE2-NEXT:    pandn %xmm6, %xmm10
; SSE2-NEXT:    por %xmm10, %xmm2
; SSE2-NEXT:    pand %xmm8, %xmm3
; SSE2-NEXT:    pandn %xmm7, %xmm8
; SSE2-NEXT:    por %xmm8, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test127:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm8
; SSE4-NEXT:    movdqa {{.*#+}} xmm0 = [9223372036854775808,9223372036854775808]
; SSE4-NEXT:    movdqa %xmm7, %xmm10
; SSE4-NEXT:    pxor %xmm0, %xmm10
; SSE4-NEXT:    movdqa %xmm3, %xmm9
; SSE4-NEXT:    pxor %xmm0, %xmm9
; SSE4-NEXT:    pcmpgtq %xmm10, %xmm9
; SSE4-NEXT:    movdqa %xmm6, %xmm11
; SSE4-NEXT:    pxor %xmm0, %xmm11
; SSE4-NEXT:    movdqa %xmm2, %xmm10
; SSE4-NEXT:    pxor %xmm0, %xmm10
; SSE4-NEXT:    pcmpgtq %xmm11, %xmm10
; SSE4-NEXT:    movdqa %xmm5, %xmm12
; SSE4-NEXT:    pxor %xmm0, %xmm12
; SSE4-NEXT:    movdqa %xmm1, %xmm11
; SSE4-NEXT:    pxor %xmm0, %xmm11
; SSE4-NEXT:    pcmpgtq %xmm12, %xmm11
; SSE4-NEXT:    movdqa %xmm4, %xmm12
; SSE4-NEXT:    pxor %xmm0, %xmm12
; SSE4-NEXT:    pxor %xmm8, %xmm0
; SSE4-NEXT:    pcmpgtq %xmm12, %xmm0
; SSE4-NEXT:    blendvpd %xmm8, %xmm4
; SSE4-NEXT:    movdqa %xmm11, %xmm0
; SSE4-NEXT:    blendvpd %xmm1, %xmm5
; SSE4-NEXT:    movdqa %xmm10, %xmm0
; SSE4-NEXT:    blendvpd %xmm2, %xmm6
; SSE4-NEXT:    movdqa %xmm9, %xmm0
; SSE4-NEXT:    blendvpd %xmm3, %xmm7
; SSE4-NEXT:    movapd %xmm4, %xmm0
; SSE4-NEXT:    movapd %xmm5, %xmm1
; SSE4-NEXT:    movapd %xmm6, %xmm2
; SSE4-NEXT:    movapd %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test127:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm4
; AVX1-NEXT:    vmovaps {{.*#+}} xmm5 = [9223372036854775808,9223372036854775808]
; AVX1-NEXT:    vxorps %xmm5, %xmm4, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm6
; AVX1-NEXT:    vxorps %xmm5, %xmm6, %xmm6
; AVX1-NEXT:    vpcmpgtq %xmm4, %xmm6, %xmm4
; AVX1-NEXT:    vxorps %xmm5, %xmm3, %xmm6
; AVX1-NEXT:    vxorps %xmm5, %xmm1, %xmm7
; AVX1-NEXT:    vpcmpgtq %xmm6, %xmm7, %xmm6
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm6, %ymm4
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm6
; AVX1-NEXT:    vxorps %xmm5, %xmm6, %xmm6
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm7
; AVX1-NEXT:    vxorps %xmm5, %xmm7, %xmm7
; AVX1-NEXT:    vpcmpgtq %xmm6, %xmm7, %xmm6
; AVX1-NEXT:    vxorps %xmm5, %xmm2, %xmm7
; AVX1-NEXT:    vxorps %xmm5, %xmm0, %xmm5
; AVX1-NEXT:    vpcmpgtq %xmm7, %xmm5, %xmm5
; AVX1-NEXT:    vinsertf128 $1, %xmm6, %ymm5, %ymm5
; AVX1-NEXT:    vblendvpd %ymm5, %ymm0, %ymm2, %ymm0
; AVX1-NEXT:    vblendvpd %ymm4, %ymm1, %ymm3, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test127:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpbroadcastq {{.*}}(%rip), %ymm4
; AVX2-NEXT:    vpxor %ymm4, %ymm3, %ymm5
; AVX2-NEXT:    vpxor %ymm4, %ymm1, %ymm6
; AVX2-NEXT:    vpcmpgtq %ymm5, %ymm6, %ymm5
; AVX2-NEXT:    vpxor %ymm4, %ymm2, %ymm6
; AVX2-NEXT:    vpxor %ymm4, %ymm0, %ymm4
; AVX2-NEXT:    vpcmpgtq %ymm6, %ymm4, %ymm4
; AVX2-NEXT:    vblendvpd %ymm4, %ymm0, %ymm2, %ymm0
; AVX2-NEXT:    vblendvpd %ymm5, %ymm1, %ymm3, %ymm1
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test127:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxuq %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp ugt <8 x i64> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i64> %a, <8 x i64> %b
  ret <8 x i64> %sel
}

define <8 x i64> @test128(<8 x i64> %a, <8 x i64> %b) {
; SSE2-LABEL: test128:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm7, %xmm11
; SSE2-NEXT:    movdqa %xmm11, -{{[0-9]+}}(%rsp) # 16-byte Spill
; SSE2-NEXT:    movdqa %xmm3, %xmm7
; SSE2-NEXT:    movdqa %xmm2, %xmm3
; SSE2-NEXT:    movdqa %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm0, %xmm9
; SSE2-NEXT:    movdqa {{.*#+}} xmm10 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm7, %xmm8
; SSE2-NEXT:    pxor %xmm10, %xmm8
; SSE2-NEXT:    movdqa %xmm11, %xmm0
; SSE2-NEXT:    pxor %xmm10, %xmm0
; SSE2-NEXT:    movdqa %xmm0, %xmm11
; SSE2-NEXT:    pcmpgtd %xmm8, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm11[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm8, %xmm0
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,1,3,3]
; SSE2-NEXT:    pand %xmm12, %xmm0
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm11[1,1,3,3]
; SSE2-NEXT:    por %xmm0, %xmm12
; SSE2-NEXT:    pcmpeqd %xmm1, %xmm1
; SSE2-NEXT:    movdqa %xmm12, %xmm8
; SSE2-NEXT:    pxor %xmm1, %xmm8
; SSE2-NEXT:    movdqa %xmm3, %xmm11
; SSE2-NEXT:    pxor %xmm10, %xmm11
; SSE2-NEXT:    movdqa %xmm6, %xmm13
; SSE2-NEXT:    pxor %xmm10, %xmm13
; SSE2-NEXT:    movdqa %xmm13, %xmm14
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm14
; SSE2-NEXT:    pshufd {{.*#+}} xmm15 = xmm14[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm11, %xmm13
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm13[1,1,3,3]
; SSE2-NEXT:    pand %xmm15, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm13 = xmm14[1,1,3,3]
; SSE2-NEXT:    por %xmm11, %xmm13
; SSE2-NEXT:    movdqa %xmm2, %xmm11
; SSE2-NEXT:    pxor %xmm10, %xmm11
; SSE2-NEXT:    movdqa %xmm5, %xmm14
; SSE2-NEXT:    pxor %xmm10, %xmm14
; SSE2-NEXT:    movdqa %xmm14, %xmm15
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm15
; SSE2-NEXT:    pcmpeqd %xmm11, %xmm14
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm15[0,0,2,2]
; SSE2-NEXT:    pshufd {{.*#+}} xmm14 = xmm14[1,1,3,3]
; SSE2-NEXT:    pand %xmm11, %xmm14
; SSE2-NEXT:    pshufd {{.*#+}} xmm15 = xmm15[1,1,3,3]
; SSE2-NEXT:    por %xmm14, %xmm15
; SSE2-NEXT:    movdqa %xmm9, %xmm11
; SSE2-NEXT:    pxor %xmm10, %xmm11
; SSE2-NEXT:    pxor %xmm4, %xmm10
; SSE2-NEXT:    movdqa %xmm10, %xmm14
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm14
; SSE2-NEXT:    pcmpeqd %xmm11, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm14[0,0,2,2]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm10[1,1,3,3]
; SSE2-NEXT:    pand %xmm11, %xmm0
; SSE2-NEXT:    movdqa %xmm13, %xmm10
; SSE2-NEXT:    pxor %xmm1, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm14 = xmm14[1,1,3,3]
; SSE2-NEXT:    por %xmm0, %xmm14
; SSE2-NEXT:    movdqa %xmm15, %xmm11
; SSE2-NEXT:    pxor %xmm1, %xmm11
; SSE2-NEXT:    pxor %xmm14, %xmm1
; SSE2-NEXT:    pandn %xmm9, %xmm14
; SSE2-NEXT:    pandn %xmm4, %xmm1
; SSE2-NEXT:    por %xmm14, %xmm1
; SSE2-NEXT:    pandn %xmm2, %xmm15
; SSE2-NEXT:    pandn %xmm5, %xmm11
; SSE2-NEXT:    por %xmm15, %xmm11
; SSE2-NEXT:    pandn %xmm3, %xmm13
; SSE2-NEXT:    pandn %xmm6, %xmm10
; SSE2-NEXT:    por %xmm13, %xmm10
; SSE2-NEXT:    pandn %xmm7, %xmm12
; SSE2-NEXT:    pandn -{{[0-9]+}}(%rsp), %xmm8 # 16-byte Folded Reload
; SSE2-NEXT:    por %xmm12, %xmm8
; SSE2-NEXT:    movdqa %xmm1, %xmm0
; SSE2-NEXT:    movdqa %xmm11, %xmm1
; SSE2-NEXT:    movdqa %xmm10, %xmm2
; SSE2-NEXT:    movdqa %xmm8, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test128:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm9
; SSE4-NEXT:    movdqa {{.*#+}} xmm0 = [9223372036854775808,9223372036854775808]
; SSE4-NEXT:    movdqa %xmm3, %xmm10
; SSE4-NEXT:    pxor %xmm0, %xmm10
; SSE4-NEXT:    movdqa %xmm7, %xmm8
; SSE4-NEXT:    pxor %xmm0, %xmm8
; SSE4-NEXT:    pcmpgtq %xmm10, %xmm8
; SSE4-NEXT:    pcmpeqd %xmm12, %xmm12
; SSE4-NEXT:    pxor %xmm12, %xmm8
; SSE4-NEXT:    movdqa %xmm2, %xmm11
; SSE4-NEXT:    pxor %xmm0, %xmm11
; SSE4-NEXT:    movdqa %xmm6, %xmm10
; SSE4-NEXT:    pxor %xmm0, %xmm10
; SSE4-NEXT:    pcmpgtq %xmm11, %xmm10
; SSE4-NEXT:    pxor %xmm12, %xmm10
; SSE4-NEXT:    movdqa %xmm1, %xmm13
; SSE4-NEXT:    pxor %xmm0, %xmm13
; SSE4-NEXT:    movdqa %xmm5, %xmm11
; SSE4-NEXT:    pxor %xmm0, %xmm11
; SSE4-NEXT:    pcmpgtq %xmm13, %xmm11
; SSE4-NEXT:    pxor %xmm12, %xmm11
; SSE4-NEXT:    movdqa %xmm9, %xmm13
; SSE4-NEXT:    pxor %xmm0, %xmm13
; SSE4-NEXT:    pxor %xmm4, %xmm0
; SSE4-NEXT:    pcmpgtq %xmm13, %xmm0
; SSE4-NEXT:    pxor %xmm12, %xmm0
; SSE4-NEXT:    blendvpd %xmm9, %xmm4
; SSE4-NEXT:    movdqa %xmm11, %xmm0
; SSE4-NEXT:    blendvpd %xmm1, %xmm5
; SSE4-NEXT:    movdqa %xmm10, %xmm0
; SSE4-NEXT:    blendvpd %xmm2, %xmm6
; SSE4-NEXT:    movdqa %xmm8, %xmm0
; SSE4-NEXT:    blendvpd %xmm3, %xmm7
; SSE4-NEXT:    movapd %xmm4, %xmm0
; SSE4-NEXT:    movapd %xmm5, %xmm1
; SSE4-NEXT:    movapd %xmm6, %xmm2
; SSE4-NEXT:    movapd %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test128:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vmovaps {{.*#+}} xmm5 = [9223372036854775808,9223372036854775808]
; AVX1-NEXT:    vxorps %xmm5, %xmm4, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm6
; AVX1-NEXT:    vxorps %xmm5, %xmm6, %xmm6
; AVX1-NEXT:    vpcmpgtq %xmm4, %xmm6, %xmm4
; AVX1-NEXT:    vpcmpeqd %xmm8, %xmm8, %xmm8
; AVX1-NEXT:    vpxor %xmm8, %xmm4, %xmm4
; AVX1-NEXT:    vxorps %xmm5, %xmm1, %xmm7
; AVX1-NEXT:    vxorps %xmm5, %xmm3, %xmm6
; AVX1-NEXT:    vpcmpgtq %xmm7, %xmm6, %xmm6
; AVX1-NEXT:    vpxor %xmm8, %xmm6, %xmm6
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm6, %ymm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm6
; AVX1-NEXT:    vxorps %xmm5, %xmm6, %xmm6
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm7
; AVX1-NEXT:    vxorps %xmm5, %xmm7, %xmm7
; AVX1-NEXT:    vpcmpgtq %xmm6, %xmm7, %xmm6
; AVX1-NEXT:    vpxor %xmm8, %xmm6, %xmm6
; AVX1-NEXT:    vxorps %xmm5, %xmm0, %xmm7
; AVX1-NEXT:    vxorps %xmm5, %xmm2, %xmm5
; AVX1-NEXT:    vpcmpgtq %xmm7, %xmm5, %xmm5
; AVX1-NEXT:    vpxor %xmm8, %xmm5, %xmm5
; AVX1-NEXT:    vinsertf128 $1, %xmm6, %ymm5, %ymm5
; AVX1-NEXT:    vblendvpd %ymm5, %ymm0, %ymm2, %ymm0
; AVX1-NEXT:    vblendvpd %ymm4, %ymm1, %ymm3, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test128:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpbroadcastq {{.*}}(%rip), %ymm4
; AVX2-NEXT:    vpxor %ymm4, %ymm1, %ymm5
; AVX2-NEXT:    vpxor %ymm4, %ymm3, %ymm6
; AVX2-NEXT:    vpcmpgtq %ymm5, %ymm6, %ymm5
; AVX2-NEXT:    vpcmpeqd %ymm6, %ymm6, %ymm6
; AVX2-NEXT:    vpxor %ymm6, %ymm5, %ymm5
; AVX2-NEXT:    vpxor %ymm4, %ymm0, %ymm7
; AVX2-NEXT:    vpxor %ymm4, %ymm2, %ymm4
; AVX2-NEXT:    vpcmpgtq %ymm7, %ymm4, %ymm4
; AVX2-NEXT:    vpxor %ymm6, %ymm4, %ymm4
; AVX2-NEXT:    vblendvpd %ymm4, %ymm0, %ymm2, %ymm0
; AVX2-NEXT:    vblendvpd %ymm5, %ymm1, %ymm3, %ymm1
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test128:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxuq %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp uge <8 x i64> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i64> %a, <8 x i64> %b
  ret <8 x i64> %sel
}

define <64 x i8> @test129(<64 x i8> %a, <64 x i8> %b) {
; SSE2-LABEL: test129:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm3, %xmm8
; SSE2-NEXT:    movdqa %xmm7, %xmm3
; SSE2-NEXT:    pcmpgtb %xmm8, %xmm3
; SSE2-NEXT:    movdqa %xmm6, %xmm9
; SSE2-NEXT:    pcmpgtb %xmm2, %xmm9
; SSE2-NEXT:    movdqa %xmm5, %xmm10
; SSE2-NEXT:    pcmpgtb %xmm1, %xmm10
; SSE2-NEXT:    movdqa %xmm4, %xmm11
; SSE2-NEXT:    pcmpgtb %xmm0, %xmm11
; SSE2-NEXT:    pand %xmm11, %xmm4
; SSE2-NEXT:    pandn %xmm0, %xmm11
; SSE2-NEXT:    por %xmm4, %xmm11
; SSE2-NEXT:    pand %xmm10, %xmm5
; SSE2-NEXT:    pandn %xmm1, %xmm10
; SSE2-NEXT:    por %xmm5, %xmm10
; SSE2-NEXT:    pand %xmm9, %xmm6
; SSE2-NEXT:    pandn %xmm2, %xmm9
; SSE2-NEXT:    por %xmm6, %xmm9
; SSE2-NEXT:    pand %xmm3, %xmm7
; SSE2-NEXT:    pandn %xmm8, %xmm3
; SSE2-NEXT:    por %xmm7, %xmm3
; SSE2-NEXT:    movdqa %xmm11, %xmm0
; SSE2-NEXT:    movdqa %xmm10, %xmm1
; SSE2-NEXT:    movdqa %xmm9, %xmm2
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test129:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxsb %xmm4, %xmm0
; SSE4-NEXT:    pmaxsb %xmm5, %xmm1
; SSE4-NEXT:    pmaxsb %xmm6, %xmm2
; SSE4-NEXT:    pmaxsb %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test129:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpmaxsb %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpmaxsb %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpmaxsb %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpmaxsb %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test129:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxsb %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpmaxsb %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test129:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpmaxsb %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp slt <64 x i8> %a, %b
  %sel = select <64 x i1> %cmp, <64 x i8> %b, <64 x i8> %a
  ret <64 x i8> %sel
}

define <64 x i8> @test130(<64 x i8> %a, <64 x i8> %b) {
; SSE2-LABEL: test130:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm2, %xmm8
; SSE2-NEXT:    movdqa %xmm3, %xmm12
; SSE2-NEXT:    pcmpgtb %xmm7, %xmm12
; SSE2-NEXT:    pcmpeqd %xmm13, %xmm13
; SSE2-NEXT:    movdqa %xmm12, %xmm9
; SSE2-NEXT:    pxor %xmm13, %xmm9
; SSE2-NEXT:    movdqa %xmm8, %xmm14
; SSE2-NEXT:    pcmpgtb %xmm6, %xmm14
; SSE2-NEXT:    movdqa %xmm14, %xmm2
; SSE2-NEXT:    pxor %xmm13, %xmm2
; SSE2-NEXT:    movdqa %xmm1, %xmm15
; SSE2-NEXT:    pcmpgtb %xmm5, %xmm15
; SSE2-NEXT:    movdqa %xmm15, %xmm10
; SSE2-NEXT:    pxor %xmm13, %xmm10
; SSE2-NEXT:    movdqa %xmm0, %xmm11
; SSE2-NEXT:    pcmpgtb %xmm4, %xmm11
; SSE2-NEXT:    pxor %xmm11, %xmm13
; SSE2-NEXT:    pandn %xmm4, %xmm11
; SSE2-NEXT:    pandn %xmm0, %xmm13
; SSE2-NEXT:    por %xmm13, %xmm11
; SSE2-NEXT:    pandn %xmm5, %xmm15
; SSE2-NEXT:    pandn %xmm1, %xmm10
; SSE2-NEXT:    por %xmm15, %xmm10
; SSE2-NEXT:    pandn %xmm6, %xmm14
; SSE2-NEXT:    pandn %xmm8, %xmm2
; SSE2-NEXT:    por %xmm14, %xmm2
; SSE2-NEXT:    pandn %xmm7, %xmm12
; SSE2-NEXT:    pandn %xmm3, %xmm9
; SSE2-NEXT:    por %xmm12, %xmm9
; SSE2-NEXT:    movdqa %xmm11, %xmm0
; SSE2-NEXT:    movdqa %xmm10, %xmm1
; SSE2-NEXT:    movdqa %xmm9, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test130:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxsb %xmm4, %xmm0
; SSE4-NEXT:    pmaxsb %xmm5, %xmm1
; SSE4-NEXT:    pmaxsb %xmm6, %xmm2
; SSE4-NEXT:    pmaxsb %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test130:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpmaxsb %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpmaxsb %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpmaxsb %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpmaxsb %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test130:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxsb %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpmaxsb %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test130:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpmaxsb %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp sle <64 x i8> %a, %b
  %sel = select <64 x i1> %cmp, <64 x i8> %b, <64 x i8> %a
  ret <64 x i8> %sel
}

define <64 x i8> @test131(<64 x i8> %a, <64 x i8> %b) {
; SSE2-LABEL: test131:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm3, %xmm8
; SSE2-NEXT:    pcmpgtb %xmm7, %xmm3
; SSE2-NEXT:    movdqa %xmm2, %xmm9
; SSE2-NEXT:    pcmpgtb %xmm6, %xmm9
; SSE2-NEXT:    movdqa %xmm1, %xmm10
; SSE2-NEXT:    pcmpgtb %xmm5, %xmm10
; SSE2-NEXT:    movdqa %xmm0, %xmm11
; SSE2-NEXT:    pcmpgtb %xmm4, %xmm11
; SSE2-NEXT:    pand %xmm11, %xmm4
; SSE2-NEXT:    pandn %xmm0, %xmm11
; SSE2-NEXT:    por %xmm4, %xmm11
; SSE2-NEXT:    pand %xmm10, %xmm5
; SSE2-NEXT:    pandn %xmm1, %xmm10
; SSE2-NEXT:    por %xmm5, %xmm10
; SSE2-NEXT:    pand %xmm9, %xmm6
; SSE2-NEXT:    pandn %xmm2, %xmm9
; SSE2-NEXT:    por %xmm6, %xmm9
; SSE2-NEXT:    pand %xmm3, %xmm7
; SSE2-NEXT:    pandn %xmm8, %xmm3
; SSE2-NEXT:    por %xmm7, %xmm3
; SSE2-NEXT:    movdqa %xmm11, %xmm0
; SSE2-NEXT:    movdqa %xmm10, %xmm1
; SSE2-NEXT:    movdqa %xmm9, %xmm2
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test131:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminsb %xmm4, %xmm0
; SSE4-NEXT:    pminsb %xmm5, %xmm1
; SSE4-NEXT:    pminsb %xmm6, %xmm2
; SSE4-NEXT:    pminsb %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test131:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpminsb %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpminsb %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpminsb %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpminsb %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test131:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminsb %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpminsb %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test131:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpminsb %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp sgt <64 x i8> %a, %b
  %sel = select <64 x i1> %cmp, <64 x i8> %b, <64 x i8> %a
  ret <64 x i8> %sel
}

define <64 x i8> @test132(<64 x i8> %a, <64 x i8> %b) {
; SSE2-LABEL: test132:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm2, %xmm8
; SSE2-NEXT:    movdqa %xmm0, %xmm10
; SSE2-NEXT:    movdqa %xmm7, %xmm12
; SSE2-NEXT:    pcmpgtb %xmm3, %xmm12
; SSE2-NEXT:    pcmpeqd %xmm0, %xmm0
; SSE2-NEXT:    movdqa %xmm12, %xmm9
; SSE2-NEXT:    pxor %xmm0, %xmm9
; SSE2-NEXT:    movdqa %xmm6, %xmm13
; SSE2-NEXT:    pcmpgtb %xmm8, %xmm13
; SSE2-NEXT:    movdqa %xmm13, %xmm2
; SSE2-NEXT:    pxor %xmm0, %xmm2
; SSE2-NEXT:    movdqa %xmm5, %xmm14
; SSE2-NEXT:    pcmpgtb %xmm1, %xmm14
; SSE2-NEXT:    movdqa %xmm14, %xmm11
; SSE2-NEXT:    pxor %xmm0, %xmm11
; SSE2-NEXT:    movdqa %xmm4, %xmm15
; SSE2-NEXT:    pcmpgtb %xmm10, %xmm15
; SSE2-NEXT:    pxor %xmm15, %xmm0
; SSE2-NEXT:    pandn %xmm4, %xmm15
; SSE2-NEXT:    pandn %xmm10, %xmm0
; SSE2-NEXT:    por %xmm15, %xmm0
; SSE2-NEXT:    pandn %xmm5, %xmm14
; SSE2-NEXT:    pandn %xmm1, %xmm11
; SSE2-NEXT:    por %xmm14, %xmm11
; SSE2-NEXT:    pandn %xmm6, %xmm13
; SSE2-NEXT:    pandn %xmm8, %xmm2
; SSE2-NEXT:    por %xmm13, %xmm2
; SSE2-NEXT:    pandn %xmm7, %xmm12
; SSE2-NEXT:    pandn %xmm3, %xmm9
; SSE2-NEXT:    por %xmm12, %xmm9
; SSE2-NEXT:    movdqa %xmm11, %xmm1
; SSE2-NEXT:    movdqa %xmm9, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test132:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminsb %xmm4, %xmm0
; SSE4-NEXT:    pminsb %xmm5, %xmm1
; SSE4-NEXT:    pminsb %xmm6, %xmm2
; SSE4-NEXT:    pminsb %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test132:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpminsb %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpminsb %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpminsb %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpminsb %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test132:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminsb %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpminsb %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test132:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpminsb %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp sge <64 x i8> %a, %b
  %sel = select <64 x i1> %cmp, <64 x i8> %b, <64 x i8> %a
  ret <64 x i8> %sel
}

define <64 x i8> @test133(<64 x i8> %a, <64 x i8> %b) {
; SSE-LABEL: test133:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pmaxub %xmm4, %xmm0
; SSE-NEXT:    pmaxub %xmm5, %xmm1
; SSE-NEXT:    pmaxub %xmm6, %xmm2
; SSE-NEXT:    pmaxub %xmm7, %xmm3
; SSE-NEXT:    retq
;
; AVX1-LABEL: test133:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpmaxub %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpmaxub %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpmaxub %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpmaxub %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test133:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxub %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpmaxub %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test133:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpmaxub %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp ult <64 x i8> %a, %b
  %sel = select <64 x i1> %cmp, <64 x i8> %b, <64 x i8> %a
  ret <64 x i8> %sel
}

define <64 x i8> @test134(<64 x i8> %a, <64 x i8> %b) {
; SSE-LABEL: test134:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pmaxub %xmm4, %xmm0
; SSE-NEXT:    pmaxub %xmm5, %xmm1
; SSE-NEXT:    pmaxub %xmm6, %xmm2
; SSE-NEXT:    pmaxub %xmm7, %xmm3
; SSE-NEXT:    retq
;
; AVX1-LABEL: test134:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpmaxub %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpmaxub %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpmaxub %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpmaxub %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test134:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxub %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpmaxub %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test134:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpmaxub %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp ule <64 x i8> %a, %b
  %sel = select <64 x i1> %cmp, <64 x i8> %b, <64 x i8> %a
  ret <64 x i8> %sel
}

define <64 x i8> @test135(<64 x i8> %a, <64 x i8> %b) {
; SSE-LABEL: test135:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pminub %xmm4, %xmm0
; SSE-NEXT:    pminub %xmm5, %xmm1
; SSE-NEXT:    pminub %xmm6, %xmm2
; SSE-NEXT:    pminub %xmm7, %xmm3
; SSE-NEXT:    retq
;
; AVX1-LABEL: test135:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpminub %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpminub %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpminub %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpminub %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test135:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminub %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpminub %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test135:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpminub %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp ugt <64 x i8> %a, %b
  %sel = select <64 x i1> %cmp, <64 x i8> %b, <64 x i8> %a
  ret <64 x i8> %sel
}

define <64 x i8> @test136(<64 x i8> %a, <64 x i8> %b) {
; SSE-LABEL: test136:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pminub %xmm4, %xmm0
; SSE-NEXT:    pminub %xmm5, %xmm1
; SSE-NEXT:    pminub %xmm6, %xmm2
; SSE-NEXT:    pminub %xmm7, %xmm3
; SSE-NEXT:    retq
;
; AVX1-LABEL: test136:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpminub %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpminub %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpminub %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpminub %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test136:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminub %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpminub %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test136:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpminub %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp uge <64 x i8> %a, %b
  %sel = select <64 x i1> %cmp, <64 x i8> %b, <64 x i8> %a
  ret <64 x i8> %sel
}

define <32 x i16> @test137(<32 x i16> %a, <32 x i16> %b) {
; SSE-LABEL: test137:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pmaxsw %xmm4, %xmm0
; SSE-NEXT:    pmaxsw %xmm5, %xmm1
; SSE-NEXT:    pmaxsw %xmm6, %xmm2
; SSE-NEXT:    pmaxsw %xmm7, %xmm3
; SSE-NEXT:    retq
;
; AVX1-LABEL: test137:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpmaxsw %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpmaxsw %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpmaxsw %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpmaxsw %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test137:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxsw %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpmaxsw %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test137:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpmaxsw %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp slt <32 x i16> %a, %b
  %sel = select <32 x i1> %cmp, <32 x i16> %b, <32 x i16> %a
  ret <32 x i16> %sel
}

define <32 x i16> @test138(<32 x i16> %a, <32 x i16> %b) {
; SSE-LABEL: test138:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pmaxsw %xmm4, %xmm0
; SSE-NEXT:    pmaxsw %xmm5, %xmm1
; SSE-NEXT:    pmaxsw %xmm6, %xmm2
; SSE-NEXT:    pmaxsw %xmm7, %xmm3
; SSE-NEXT:    retq
;
; AVX1-LABEL: test138:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpmaxsw %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpmaxsw %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpmaxsw %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpmaxsw %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test138:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxsw %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpmaxsw %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test138:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpmaxsw %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp sle <32 x i16> %a, %b
  %sel = select <32 x i1> %cmp, <32 x i16> %b, <32 x i16> %a
  ret <32 x i16> %sel
}

define <32 x i16> @test139(<32 x i16> %a, <32 x i16> %b) {
; SSE-LABEL: test139:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pminsw %xmm4, %xmm0
; SSE-NEXT:    pminsw %xmm5, %xmm1
; SSE-NEXT:    pminsw %xmm6, %xmm2
; SSE-NEXT:    pminsw %xmm7, %xmm3
; SSE-NEXT:    retq
;
; AVX1-LABEL: test139:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpminsw %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpminsw %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpminsw %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpminsw %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test139:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminsw %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpminsw %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test139:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpminsw %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp sgt <32 x i16> %a, %b
  %sel = select <32 x i1> %cmp, <32 x i16> %b, <32 x i16> %a
  ret <32 x i16> %sel
}

define <32 x i16> @test140(<32 x i16> %a, <32 x i16> %b) {
; SSE-LABEL: test140:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pminsw %xmm4, %xmm0
; SSE-NEXT:    pminsw %xmm5, %xmm1
; SSE-NEXT:    pminsw %xmm6, %xmm2
; SSE-NEXT:    pminsw %xmm7, %xmm3
; SSE-NEXT:    retq
;
; AVX1-LABEL: test140:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpminsw %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpminsw %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpminsw %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpminsw %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test140:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminsw %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpminsw %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test140:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpminsw %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp sge <32 x i16> %a, %b
  %sel = select <32 x i1> %cmp, <32 x i16> %b, <32 x i16> %a
  ret <32 x i16> %sel
}

define <32 x i16> @test141(<32 x i16> %a, <32 x i16> %b) {
; SSE2-LABEL: test141:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm0, %xmm11
; SSE2-NEXT:    movdqa {{.*#+}} xmm0 = [32768,32768,32768,32768,32768,32768,32768,32768]
; SSE2-NEXT:    movdqa %xmm3, %xmm9
; SSE2-NEXT:    pxor %xmm0, %xmm9
; SSE2-NEXT:    movdqa %xmm7, %xmm8
; SSE2-NEXT:    pxor %xmm0, %xmm8
; SSE2-NEXT:    pcmpgtw %xmm9, %xmm8
; SSE2-NEXT:    movdqa %xmm2, %xmm10
; SSE2-NEXT:    pxor %xmm0, %xmm10
; SSE2-NEXT:    movdqa %xmm6, %xmm9
; SSE2-NEXT:    pxor %xmm0, %xmm9
; SSE2-NEXT:    pcmpgtw %xmm10, %xmm9
; SSE2-NEXT:    movdqa %xmm1, %xmm12
; SSE2-NEXT:    pxor %xmm0, %xmm12
; SSE2-NEXT:    movdqa %xmm5, %xmm10
; SSE2-NEXT:    pxor %xmm0, %xmm10
; SSE2-NEXT:    pcmpgtw %xmm12, %xmm10
; SSE2-NEXT:    movdqa %xmm11, %xmm12
; SSE2-NEXT:    pxor %xmm0, %xmm12
; SSE2-NEXT:    pxor %xmm4, %xmm0
; SSE2-NEXT:    pcmpgtw %xmm12, %xmm0
; SSE2-NEXT:    pand %xmm0, %xmm4
; SSE2-NEXT:    pandn %xmm11, %xmm0
; SSE2-NEXT:    por %xmm4, %xmm0
; SSE2-NEXT:    pand %xmm10, %xmm5
; SSE2-NEXT:    pandn %xmm1, %xmm10
; SSE2-NEXT:    por %xmm5, %xmm10
; SSE2-NEXT:    pand %xmm9, %xmm6
; SSE2-NEXT:    pandn %xmm2, %xmm9
; SSE2-NEXT:    por %xmm6, %xmm9
; SSE2-NEXT:    pand %xmm8, %xmm7
; SSE2-NEXT:    pandn %xmm3, %xmm8
; SSE2-NEXT:    por %xmm7, %xmm8
; SSE2-NEXT:    movdqa %xmm10, %xmm1
; SSE2-NEXT:    movdqa %xmm9, %xmm2
; SSE2-NEXT:    movdqa %xmm8, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test141:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxuw %xmm4, %xmm0
; SSE4-NEXT:    pmaxuw %xmm5, %xmm1
; SSE4-NEXT:    pmaxuw %xmm6, %xmm2
; SSE4-NEXT:    pmaxuw %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test141:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpmaxuw %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpmaxuw %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpmaxuw %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpmaxuw %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test141:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxuw %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpmaxuw %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test141:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpmaxuw %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp ult <32 x i16> %a, %b
  %sel = select <32 x i1> %cmp, <32 x i16> %b, <32 x i16> %a
  ret <32 x i16> %sel
}

define <32 x i16> @test142(<32 x i16> %a, <32 x i16> %b) {
; SSE2-LABEL: test142:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm3, %xmm8
; SSE2-NEXT:    movdqa %xmm2, %xmm9
; SSE2-NEXT:    movdqa %xmm1, %xmm10
; SSE2-NEXT:    psubusw %xmm7, %xmm3
; SSE2-NEXT:    pxor %xmm12, %xmm12
; SSE2-NEXT:    pcmpeqw %xmm12, %xmm3
; SSE2-NEXT:    psubusw %xmm6, %xmm2
; SSE2-NEXT:    pcmpeqw %xmm12, %xmm2
; SSE2-NEXT:    psubusw %xmm5, %xmm1
; SSE2-NEXT:    pcmpeqw %xmm12, %xmm1
; SSE2-NEXT:    movdqa %xmm0, %xmm11
; SSE2-NEXT:    psubusw %xmm4, %xmm11
; SSE2-NEXT:    pcmpeqw %xmm12, %xmm11
; SSE2-NEXT:    pand %xmm11, %xmm4
; SSE2-NEXT:    pandn %xmm0, %xmm11
; SSE2-NEXT:    por %xmm4, %xmm11
; SSE2-NEXT:    pand %xmm1, %xmm5
; SSE2-NEXT:    pandn %xmm10, %xmm1
; SSE2-NEXT:    por %xmm5, %xmm1
; SSE2-NEXT:    pand %xmm2, %xmm6
; SSE2-NEXT:    pandn %xmm9, %xmm2
; SSE2-NEXT:    por %xmm6, %xmm2
; SSE2-NEXT:    pand %xmm3, %xmm7
; SSE2-NEXT:    pandn %xmm8, %xmm3
; SSE2-NEXT:    por %xmm7, %xmm3
; SSE2-NEXT:    movdqa %xmm11, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test142:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxuw %xmm4, %xmm0
; SSE4-NEXT:    pmaxuw %xmm5, %xmm1
; SSE4-NEXT:    pmaxuw %xmm6, %xmm2
; SSE4-NEXT:    pmaxuw %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test142:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpmaxuw %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpmaxuw %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpmaxuw %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpmaxuw %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test142:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxuw %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpmaxuw %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test142:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpmaxuw %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp ule <32 x i16> %a, %b
  %sel = select <32 x i1> %cmp, <32 x i16> %b, <32 x i16> %a
  ret <32 x i16> %sel
}

define <32 x i16> @test143(<32 x i16> %a, <32 x i16> %b) {
; SSE2-LABEL: test143:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm0, %xmm11
; SSE2-NEXT:    movdqa {{.*#+}} xmm0 = [32768,32768,32768,32768,32768,32768,32768,32768]
; SSE2-NEXT:    movdqa %xmm7, %xmm9
; SSE2-NEXT:    pxor %xmm0, %xmm9
; SSE2-NEXT:    movdqa %xmm3, %xmm8
; SSE2-NEXT:    pxor %xmm0, %xmm8
; SSE2-NEXT:    pcmpgtw %xmm9, %xmm8
; SSE2-NEXT:    movdqa %xmm6, %xmm10
; SSE2-NEXT:    pxor %xmm0, %xmm10
; SSE2-NEXT:    movdqa %xmm2, %xmm9
; SSE2-NEXT:    pxor %xmm0, %xmm9
; SSE2-NEXT:    pcmpgtw %xmm10, %xmm9
; SSE2-NEXT:    movdqa %xmm5, %xmm12
; SSE2-NEXT:    pxor %xmm0, %xmm12
; SSE2-NEXT:    movdqa %xmm1, %xmm10
; SSE2-NEXT:    pxor %xmm0, %xmm10
; SSE2-NEXT:    pcmpgtw %xmm12, %xmm10
; SSE2-NEXT:    movdqa %xmm4, %xmm12
; SSE2-NEXT:    pxor %xmm0, %xmm12
; SSE2-NEXT:    pxor %xmm11, %xmm0
; SSE2-NEXT:    pcmpgtw %xmm12, %xmm0
; SSE2-NEXT:    pand %xmm0, %xmm4
; SSE2-NEXT:    pandn %xmm11, %xmm0
; SSE2-NEXT:    por %xmm4, %xmm0
; SSE2-NEXT:    pand %xmm10, %xmm5
; SSE2-NEXT:    pandn %xmm1, %xmm10
; SSE2-NEXT:    por %xmm5, %xmm10
; SSE2-NEXT:    pand %xmm9, %xmm6
; SSE2-NEXT:    pandn %xmm2, %xmm9
; SSE2-NEXT:    por %xmm6, %xmm9
; SSE2-NEXT:    pand %xmm8, %xmm7
; SSE2-NEXT:    pandn %xmm3, %xmm8
; SSE2-NEXT:    por %xmm7, %xmm8
; SSE2-NEXT:    movdqa %xmm10, %xmm1
; SSE2-NEXT:    movdqa %xmm9, %xmm2
; SSE2-NEXT:    movdqa %xmm8, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test143:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminuw %xmm4, %xmm0
; SSE4-NEXT:    pminuw %xmm5, %xmm1
; SSE4-NEXT:    pminuw %xmm6, %xmm2
; SSE4-NEXT:    pminuw %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test143:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpminuw %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpminuw %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpminuw %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpminuw %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test143:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminuw %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpminuw %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test143:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpminuw %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp ugt <32 x i16> %a, %b
  %sel = select <32 x i1> %cmp, <32 x i16> %b, <32 x i16> %a
  ret <32 x i16> %sel
}

define <32 x i16> @test144(<32 x i16> %a, <32 x i16> %b) {
; SSE2-LABEL: test144:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm3, %xmm8
; SSE2-NEXT:    movdqa %xmm2, %xmm9
; SSE2-NEXT:    movdqa %xmm1, %xmm10
; SSE2-NEXT:    movdqa %xmm7, %xmm3
; SSE2-NEXT:    psubusw %xmm8, %xmm3
; SSE2-NEXT:    pxor %xmm12, %xmm12
; SSE2-NEXT:    pcmpeqw %xmm12, %xmm3
; SSE2-NEXT:    movdqa %xmm6, %xmm2
; SSE2-NEXT:    psubusw %xmm9, %xmm2
; SSE2-NEXT:    pcmpeqw %xmm12, %xmm2
; SSE2-NEXT:    movdqa %xmm5, %xmm1
; SSE2-NEXT:    psubusw %xmm10, %xmm1
; SSE2-NEXT:    pcmpeqw %xmm12, %xmm1
; SSE2-NEXT:    movdqa %xmm4, %xmm11
; SSE2-NEXT:    psubusw %xmm0, %xmm11
; SSE2-NEXT:    pcmpeqw %xmm12, %xmm11
; SSE2-NEXT:    pand %xmm11, %xmm4
; SSE2-NEXT:    pandn %xmm0, %xmm11
; SSE2-NEXT:    por %xmm4, %xmm11
; SSE2-NEXT:    pand %xmm1, %xmm5
; SSE2-NEXT:    pandn %xmm10, %xmm1
; SSE2-NEXT:    por %xmm5, %xmm1
; SSE2-NEXT:    pand %xmm2, %xmm6
; SSE2-NEXT:    pandn %xmm9, %xmm2
; SSE2-NEXT:    por %xmm6, %xmm2
; SSE2-NEXT:    pand %xmm3, %xmm7
; SSE2-NEXT:    pandn %xmm8, %xmm3
; SSE2-NEXT:    por %xmm7, %xmm3
; SSE2-NEXT:    movdqa %xmm11, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test144:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminuw %xmm4, %xmm0
; SSE4-NEXT:    pminuw %xmm5, %xmm1
; SSE4-NEXT:    pminuw %xmm6, %xmm2
; SSE4-NEXT:    pminuw %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test144:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpminuw %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpminuw %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpminuw %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpminuw %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test144:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminuw %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpminuw %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test144:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpminuw %zmm1, %zmm0, %zmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp uge <32 x i16> %a, %b
  %sel = select <32 x i1> %cmp, <32 x i16> %b, <32 x i16> %a
  ret <32 x i16> %sel
}

define <16 x i32> @test145(<16 x i32> %a, <16 x i32> %b) {
; SSE2-LABEL: test145:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm3, %xmm8
; SSE2-NEXT:    movdqa %xmm7, %xmm3
; SSE2-NEXT:    pcmpgtd %xmm8, %xmm3
; SSE2-NEXT:    movdqa %xmm6, %xmm9
; SSE2-NEXT:    pcmpgtd %xmm2, %xmm9
; SSE2-NEXT:    movdqa %xmm5, %xmm10
; SSE2-NEXT:    pcmpgtd %xmm1, %xmm10
; SSE2-NEXT:    movdqa %xmm4, %xmm11
; SSE2-NEXT:    pcmpgtd %xmm0, %xmm11
; SSE2-NEXT:    pand %xmm11, %xmm4
; SSE2-NEXT:    pandn %xmm0, %xmm11
; SSE2-NEXT:    por %xmm4, %xmm11
; SSE2-NEXT:    pand %xmm10, %xmm5
; SSE2-NEXT:    pandn %xmm1, %xmm10
; SSE2-NEXT:    por %xmm5, %xmm10
; SSE2-NEXT:    pand %xmm9, %xmm6
; SSE2-NEXT:    pandn %xmm2, %xmm9
; SSE2-NEXT:    por %xmm6, %xmm9
; SSE2-NEXT:    pand %xmm3, %xmm7
; SSE2-NEXT:    pandn %xmm8, %xmm3
; SSE2-NEXT:    por %xmm7, %xmm3
; SSE2-NEXT:    movdqa %xmm11, %xmm0
; SSE2-NEXT:    movdqa %xmm10, %xmm1
; SSE2-NEXT:    movdqa %xmm9, %xmm2
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test145:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxsd %xmm4, %xmm0
; SSE4-NEXT:    pmaxsd %xmm5, %xmm1
; SSE4-NEXT:    pmaxsd %xmm6, %xmm2
; SSE4-NEXT:    pmaxsd %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test145:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpmaxsd %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpmaxsd %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpmaxsd %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpmaxsd %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test145:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxsd %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpmaxsd %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test145:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxsd %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp slt <16 x i32> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i32> %b, <16 x i32> %a
  ret <16 x i32> %sel
}

define <16 x i32> @test146(<16 x i32> %a, <16 x i32> %b) {
; SSE2-LABEL: test146:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm2, %xmm8
; SSE2-NEXT:    movdqa %xmm3, %xmm12
; SSE2-NEXT:    pcmpgtd %xmm7, %xmm12
; SSE2-NEXT:    pcmpeqd %xmm13, %xmm13
; SSE2-NEXT:    movdqa %xmm12, %xmm9
; SSE2-NEXT:    pxor %xmm13, %xmm9
; SSE2-NEXT:    movdqa %xmm8, %xmm14
; SSE2-NEXT:    pcmpgtd %xmm6, %xmm14
; SSE2-NEXT:    movdqa %xmm14, %xmm2
; SSE2-NEXT:    pxor %xmm13, %xmm2
; SSE2-NEXT:    movdqa %xmm1, %xmm15
; SSE2-NEXT:    pcmpgtd %xmm5, %xmm15
; SSE2-NEXT:    movdqa %xmm15, %xmm10
; SSE2-NEXT:    pxor %xmm13, %xmm10
; SSE2-NEXT:    movdqa %xmm0, %xmm11
; SSE2-NEXT:    pcmpgtd %xmm4, %xmm11
; SSE2-NEXT:    pxor %xmm11, %xmm13
; SSE2-NEXT:    pandn %xmm4, %xmm11
; SSE2-NEXT:    pandn %xmm0, %xmm13
; SSE2-NEXT:    por %xmm13, %xmm11
; SSE2-NEXT:    pandn %xmm5, %xmm15
; SSE2-NEXT:    pandn %xmm1, %xmm10
; SSE2-NEXT:    por %xmm15, %xmm10
; SSE2-NEXT:    pandn %xmm6, %xmm14
; SSE2-NEXT:    pandn %xmm8, %xmm2
; SSE2-NEXT:    por %xmm14, %xmm2
; SSE2-NEXT:    pandn %xmm7, %xmm12
; SSE2-NEXT:    pandn %xmm3, %xmm9
; SSE2-NEXT:    por %xmm12, %xmm9
; SSE2-NEXT:    movdqa %xmm11, %xmm0
; SSE2-NEXT:    movdqa %xmm10, %xmm1
; SSE2-NEXT:    movdqa %xmm9, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test146:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxsd %xmm4, %xmm0
; SSE4-NEXT:    pmaxsd %xmm5, %xmm1
; SSE4-NEXT:    pmaxsd %xmm6, %xmm2
; SSE4-NEXT:    pmaxsd %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test146:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpmaxsd %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpmaxsd %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpmaxsd %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpmaxsd %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test146:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxsd %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpmaxsd %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test146:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxsd %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp sle <16 x i32> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i32> %b, <16 x i32> %a
  ret <16 x i32> %sel
}

define <16 x i32> @test147(<16 x i32> %a, <16 x i32> %b) {
; SSE2-LABEL: test147:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm3, %xmm8
; SSE2-NEXT:    pcmpgtd %xmm7, %xmm3
; SSE2-NEXT:    movdqa %xmm2, %xmm9
; SSE2-NEXT:    pcmpgtd %xmm6, %xmm9
; SSE2-NEXT:    movdqa %xmm1, %xmm10
; SSE2-NEXT:    pcmpgtd %xmm5, %xmm10
; SSE2-NEXT:    movdqa %xmm0, %xmm11
; SSE2-NEXT:    pcmpgtd %xmm4, %xmm11
; SSE2-NEXT:    pand %xmm11, %xmm4
; SSE2-NEXT:    pandn %xmm0, %xmm11
; SSE2-NEXT:    por %xmm4, %xmm11
; SSE2-NEXT:    pand %xmm10, %xmm5
; SSE2-NEXT:    pandn %xmm1, %xmm10
; SSE2-NEXT:    por %xmm5, %xmm10
; SSE2-NEXT:    pand %xmm9, %xmm6
; SSE2-NEXT:    pandn %xmm2, %xmm9
; SSE2-NEXT:    por %xmm6, %xmm9
; SSE2-NEXT:    pand %xmm3, %xmm7
; SSE2-NEXT:    pandn %xmm8, %xmm3
; SSE2-NEXT:    por %xmm7, %xmm3
; SSE2-NEXT:    movdqa %xmm11, %xmm0
; SSE2-NEXT:    movdqa %xmm10, %xmm1
; SSE2-NEXT:    movdqa %xmm9, %xmm2
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test147:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminsd %xmm4, %xmm0
; SSE4-NEXT:    pminsd %xmm5, %xmm1
; SSE4-NEXT:    pminsd %xmm6, %xmm2
; SSE4-NEXT:    pminsd %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test147:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpminsd %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpminsd %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpminsd %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpminsd %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test147:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminsd %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpminsd %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test147:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminsd %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp sgt <16 x i32> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i32> %b, <16 x i32> %a
  ret <16 x i32> %sel
}

define <16 x i32> @test148(<16 x i32> %a, <16 x i32> %b) {
; SSE2-LABEL: test148:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm2, %xmm8
; SSE2-NEXT:    movdqa %xmm0, %xmm10
; SSE2-NEXT:    movdqa %xmm7, %xmm12
; SSE2-NEXT:    pcmpgtd %xmm3, %xmm12
; SSE2-NEXT:    pcmpeqd %xmm0, %xmm0
; SSE2-NEXT:    movdqa %xmm12, %xmm9
; SSE2-NEXT:    pxor %xmm0, %xmm9
; SSE2-NEXT:    movdqa %xmm6, %xmm13
; SSE2-NEXT:    pcmpgtd %xmm8, %xmm13
; SSE2-NEXT:    movdqa %xmm13, %xmm2
; SSE2-NEXT:    pxor %xmm0, %xmm2
; SSE2-NEXT:    movdqa %xmm5, %xmm14
; SSE2-NEXT:    pcmpgtd %xmm1, %xmm14
; SSE2-NEXT:    movdqa %xmm14, %xmm11
; SSE2-NEXT:    pxor %xmm0, %xmm11
; SSE2-NEXT:    movdqa %xmm4, %xmm15
; SSE2-NEXT:    pcmpgtd %xmm10, %xmm15
; SSE2-NEXT:    pxor %xmm15, %xmm0
; SSE2-NEXT:    pandn %xmm4, %xmm15
; SSE2-NEXT:    pandn %xmm10, %xmm0
; SSE2-NEXT:    por %xmm15, %xmm0
; SSE2-NEXT:    pandn %xmm5, %xmm14
; SSE2-NEXT:    pandn %xmm1, %xmm11
; SSE2-NEXT:    por %xmm14, %xmm11
; SSE2-NEXT:    pandn %xmm6, %xmm13
; SSE2-NEXT:    pandn %xmm8, %xmm2
; SSE2-NEXT:    por %xmm13, %xmm2
; SSE2-NEXT:    pandn %xmm7, %xmm12
; SSE2-NEXT:    pandn %xmm3, %xmm9
; SSE2-NEXT:    por %xmm12, %xmm9
; SSE2-NEXT:    movdqa %xmm11, %xmm1
; SSE2-NEXT:    movdqa %xmm9, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test148:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminsd %xmm4, %xmm0
; SSE4-NEXT:    pminsd %xmm5, %xmm1
; SSE4-NEXT:    pminsd %xmm6, %xmm2
; SSE4-NEXT:    pminsd %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test148:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpminsd %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpminsd %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpminsd %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpminsd %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test148:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminsd %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpminsd %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test148:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminsd %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp sge <16 x i32> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i32> %b, <16 x i32> %a
  ret <16 x i32> %sel
}

define <16 x i32> @test149(<16 x i32> %a, <16 x i32> %b) {
; SSE2-LABEL: test149:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm0, %xmm11
; SSE2-NEXT:    movdqa {{.*#+}} xmm0 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm3, %xmm9
; SSE2-NEXT:    pxor %xmm0, %xmm9
; SSE2-NEXT:    movdqa %xmm7, %xmm8
; SSE2-NEXT:    pxor %xmm0, %xmm8
; SSE2-NEXT:    pcmpgtd %xmm9, %xmm8
; SSE2-NEXT:    movdqa %xmm2, %xmm10
; SSE2-NEXT:    pxor %xmm0, %xmm10
; SSE2-NEXT:    movdqa %xmm6, %xmm9
; SSE2-NEXT:    pxor %xmm0, %xmm9
; SSE2-NEXT:    pcmpgtd %xmm10, %xmm9
; SSE2-NEXT:    movdqa %xmm1, %xmm12
; SSE2-NEXT:    pxor %xmm0, %xmm12
; SSE2-NEXT:    movdqa %xmm5, %xmm10
; SSE2-NEXT:    pxor %xmm0, %xmm10
; SSE2-NEXT:    pcmpgtd %xmm12, %xmm10
; SSE2-NEXT:    movdqa %xmm11, %xmm12
; SSE2-NEXT:    pxor %xmm0, %xmm12
; SSE2-NEXT:    pxor %xmm4, %xmm0
; SSE2-NEXT:    pcmpgtd %xmm12, %xmm0
; SSE2-NEXT:    pand %xmm0, %xmm4
; SSE2-NEXT:    pandn %xmm11, %xmm0
; SSE2-NEXT:    por %xmm4, %xmm0
; SSE2-NEXT:    pand %xmm10, %xmm5
; SSE2-NEXT:    pandn %xmm1, %xmm10
; SSE2-NEXT:    por %xmm5, %xmm10
; SSE2-NEXT:    pand %xmm9, %xmm6
; SSE2-NEXT:    pandn %xmm2, %xmm9
; SSE2-NEXT:    por %xmm6, %xmm9
; SSE2-NEXT:    pand %xmm8, %xmm7
; SSE2-NEXT:    pandn %xmm3, %xmm8
; SSE2-NEXT:    por %xmm7, %xmm8
; SSE2-NEXT:    movdqa %xmm10, %xmm1
; SSE2-NEXT:    movdqa %xmm9, %xmm2
; SSE2-NEXT:    movdqa %xmm8, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test149:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxud %xmm4, %xmm0
; SSE4-NEXT:    pmaxud %xmm5, %xmm1
; SSE4-NEXT:    pmaxud %xmm6, %xmm2
; SSE4-NEXT:    pmaxud %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test149:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpmaxud %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpmaxud %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpmaxud %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpmaxud %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test149:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxud %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpmaxud %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test149:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxud %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp ult <16 x i32> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i32> %b, <16 x i32> %a
  ret <16 x i32> %sel
}

define <16 x i32> @test150(<16 x i32> %a, <16 x i32> %b) {
; SSE2-LABEL: test150:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm0, %xmm10
; SSE2-NEXT:    movdqa {{.*#+}} xmm14 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm7, %xmm0
; SSE2-NEXT:    pxor %xmm14, %xmm0
; SSE2-NEXT:    movdqa %xmm3, %xmm12
; SSE2-NEXT:    pxor %xmm14, %xmm12
; SSE2-NEXT:    pcmpgtd %xmm0, %xmm12
; SSE2-NEXT:    pcmpeqd %xmm0, %xmm0
; SSE2-NEXT:    movdqa %xmm12, %xmm8
; SSE2-NEXT:    pxor %xmm0, %xmm8
; SSE2-NEXT:    movdqa %xmm6, %xmm9
; SSE2-NEXT:    pxor %xmm14, %xmm9
; SSE2-NEXT:    movdqa %xmm2, %xmm13
; SSE2-NEXT:    pxor %xmm14, %xmm13
; SSE2-NEXT:    pcmpgtd %xmm9, %xmm13
; SSE2-NEXT:    movdqa %xmm13, %xmm9
; SSE2-NEXT:    pxor %xmm0, %xmm9
; SSE2-NEXT:    movdqa %xmm5, %xmm11
; SSE2-NEXT:    pxor %xmm14, %xmm11
; SSE2-NEXT:    movdqa %xmm1, %xmm15
; SSE2-NEXT:    pxor %xmm14, %xmm15
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm15
; SSE2-NEXT:    movdqa %xmm4, %xmm11
; SSE2-NEXT:    pxor %xmm14, %xmm11
; SSE2-NEXT:    pxor %xmm10, %xmm14
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm14
; SSE2-NEXT:    movdqa %xmm15, %xmm11
; SSE2-NEXT:    pxor %xmm0, %xmm11
; SSE2-NEXT:    pxor %xmm14, %xmm0
; SSE2-NEXT:    pandn %xmm4, %xmm14
; SSE2-NEXT:    pandn %xmm10, %xmm0
; SSE2-NEXT:    por %xmm14, %xmm0
; SSE2-NEXT:    pandn %xmm5, %xmm15
; SSE2-NEXT:    pandn %xmm1, %xmm11
; SSE2-NEXT:    por %xmm15, %xmm11
; SSE2-NEXT:    pandn %xmm6, %xmm13
; SSE2-NEXT:    pandn %xmm2, %xmm9
; SSE2-NEXT:    por %xmm13, %xmm9
; SSE2-NEXT:    pandn %xmm7, %xmm12
; SSE2-NEXT:    pandn %xmm3, %xmm8
; SSE2-NEXT:    por %xmm12, %xmm8
; SSE2-NEXT:    movdqa %xmm11, %xmm1
; SSE2-NEXT:    movdqa %xmm9, %xmm2
; SSE2-NEXT:    movdqa %xmm8, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test150:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pmaxud %xmm4, %xmm0
; SSE4-NEXT:    pmaxud %xmm5, %xmm1
; SSE4-NEXT:    pmaxud %xmm6, %xmm2
; SSE4-NEXT:    pmaxud %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test150:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpmaxud %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpmaxud %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpmaxud %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpmaxud %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test150:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpmaxud %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpmaxud %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test150:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxud %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp ule <16 x i32> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i32> %b, <16 x i32> %a
  ret <16 x i32> %sel
}

define <16 x i32> @test151(<16 x i32> %a, <16 x i32> %b) {
; SSE2-LABEL: test151:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm0, %xmm11
; SSE2-NEXT:    movdqa {{.*#+}} xmm0 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm7, %xmm9
; SSE2-NEXT:    pxor %xmm0, %xmm9
; SSE2-NEXT:    movdqa %xmm3, %xmm8
; SSE2-NEXT:    pxor %xmm0, %xmm8
; SSE2-NEXT:    pcmpgtd %xmm9, %xmm8
; SSE2-NEXT:    movdqa %xmm6, %xmm10
; SSE2-NEXT:    pxor %xmm0, %xmm10
; SSE2-NEXT:    movdqa %xmm2, %xmm9
; SSE2-NEXT:    pxor %xmm0, %xmm9
; SSE2-NEXT:    pcmpgtd %xmm10, %xmm9
; SSE2-NEXT:    movdqa %xmm5, %xmm12
; SSE2-NEXT:    pxor %xmm0, %xmm12
; SSE2-NEXT:    movdqa %xmm1, %xmm10
; SSE2-NEXT:    pxor %xmm0, %xmm10
; SSE2-NEXT:    pcmpgtd %xmm12, %xmm10
; SSE2-NEXT:    movdqa %xmm4, %xmm12
; SSE2-NEXT:    pxor %xmm0, %xmm12
; SSE2-NEXT:    pxor %xmm11, %xmm0
; SSE2-NEXT:    pcmpgtd %xmm12, %xmm0
; SSE2-NEXT:    pand %xmm0, %xmm4
; SSE2-NEXT:    pandn %xmm11, %xmm0
; SSE2-NEXT:    por %xmm4, %xmm0
; SSE2-NEXT:    pand %xmm10, %xmm5
; SSE2-NEXT:    pandn %xmm1, %xmm10
; SSE2-NEXT:    por %xmm5, %xmm10
; SSE2-NEXT:    pand %xmm9, %xmm6
; SSE2-NEXT:    pandn %xmm2, %xmm9
; SSE2-NEXT:    por %xmm6, %xmm9
; SSE2-NEXT:    pand %xmm8, %xmm7
; SSE2-NEXT:    pandn %xmm3, %xmm8
; SSE2-NEXT:    por %xmm7, %xmm8
; SSE2-NEXT:    movdqa %xmm10, %xmm1
; SSE2-NEXT:    movdqa %xmm9, %xmm2
; SSE2-NEXT:    movdqa %xmm8, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test151:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminud %xmm4, %xmm0
; SSE4-NEXT:    pminud %xmm5, %xmm1
; SSE4-NEXT:    pminud %xmm6, %xmm2
; SSE4-NEXT:    pminud %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test151:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpminud %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpminud %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpminud %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpminud %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test151:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminud %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpminud %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test151:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminud %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp ugt <16 x i32> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i32> %b, <16 x i32> %a
  ret <16 x i32> %sel
}

define <16 x i32> @test152(<16 x i32> %a, <16 x i32> %b) {
; SSE2-LABEL: test152:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm0, %xmm10
; SSE2-NEXT:    movdqa {{.*#+}} xmm14 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm3, %xmm0
; SSE2-NEXT:    pxor %xmm14, %xmm0
; SSE2-NEXT:    movdqa %xmm7, %xmm12
; SSE2-NEXT:    pxor %xmm14, %xmm12
; SSE2-NEXT:    pcmpgtd %xmm0, %xmm12
; SSE2-NEXT:    pcmpeqd %xmm0, %xmm0
; SSE2-NEXT:    movdqa %xmm12, %xmm8
; SSE2-NEXT:    pxor %xmm0, %xmm8
; SSE2-NEXT:    movdqa %xmm2, %xmm9
; SSE2-NEXT:    pxor %xmm14, %xmm9
; SSE2-NEXT:    movdqa %xmm6, %xmm13
; SSE2-NEXT:    pxor %xmm14, %xmm13
; SSE2-NEXT:    pcmpgtd %xmm9, %xmm13
; SSE2-NEXT:    movdqa %xmm13, %xmm9
; SSE2-NEXT:    pxor %xmm0, %xmm9
; SSE2-NEXT:    movdqa %xmm1, %xmm11
; SSE2-NEXT:    pxor %xmm14, %xmm11
; SSE2-NEXT:    movdqa %xmm5, %xmm15
; SSE2-NEXT:    pxor %xmm14, %xmm15
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm15
; SSE2-NEXT:    movdqa %xmm10, %xmm11
; SSE2-NEXT:    pxor %xmm14, %xmm11
; SSE2-NEXT:    pxor %xmm4, %xmm14
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm14
; SSE2-NEXT:    movdqa %xmm15, %xmm11
; SSE2-NEXT:    pxor %xmm0, %xmm11
; SSE2-NEXT:    pxor %xmm14, %xmm0
; SSE2-NEXT:    pandn %xmm4, %xmm14
; SSE2-NEXT:    pandn %xmm10, %xmm0
; SSE2-NEXT:    por %xmm14, %xmm0
; SSE2-NEXT:    pandn %xmm5, %xmm15
; SSE2-NEXT:    pandn %xmm1, %xmm11
; SSE2-NEXT:    por %xmm15, %xmm11
; SSE2-NEXT:    pandn %xmm6, %xmm13
; SSE2-NEXT:    pandn %xmm2, %xmm9
; SSE2-NEXT:    por %xmm13, %xmm9
; SSE2-NEXT:    pandn %xmm7, %xmm12
; SSE2-NEXT:    pandn %xmm3, %xmm8
; SSE2-NEXT:    por %xmm12, %xmm8
; SSE2-NEXT:    movdqa %xmm11, %xmm1
; SSE2-NEXT:    movdqa %xmm9, %xmm2
; SSE2-NEXT:    movdqa %xmm8, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test152:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    pminud %xmm4, %xmm0
; SSE4-NEXT:    pminud %xmm5, %xmm1
; SSE4-NEXT:    pminud %xmm6, %xmm2
; SSE4-NEXT:    pminud %xmm7, %xmm3
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test152:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vpminud %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpminud %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vpminud %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpminud %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test152:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpminud %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpminud %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test152:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminud %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp uge <16 x i32> %a, %b
  %sel = select <16 x i1> %cmp, <16 x i32> %b, <16 x i32> %a
  ret <16 x i32> %sel
}

; -----------------------

define <8 x i64> @test153(<8 x i64> %a, <8 x i64> %b) {
; SSE2-LABEL: test153:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm11 = [2147483648,0,2147483648,0]
; SSE2-NEXT:    movdqa %xmm3, %xmm8
; SSE2-NEXT:    pxor %xmm11, %xmm8
; SSE2-NEXT:    movdqa %xmm7, %xmm9
; SSE2-NEXT:    pxor %xmm11, %xmm9
; SSE2-NEXT:    movdqa %xmm9, %xmm10
; SSE2-NEXT:    pcmpgtd %xmm8, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm10[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm8, %xmm9
; SSE2-NEXT:    pshufd {{.*#+}} xmm9 = xmm9[1,1,3,3]
; SSE2-NEXT:    pand %xmm12, %xmm9
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm10[1,1,3,3]
; SSE2-NEXT:    por %xmm9, %xmm8
; SSE2-NEXT:    movdqa %xmm2, %xmm9
; SSE2-NEXT:    pxor %xmm11, %xmm9
; SSE2-NEXT:    movdqa %xmm6, %xmm10
; SSE2-NEXT:    pxor %xmm11, %xmm10
; SSE2-NEXT:    movdqa %xmm10, %xmm12
; SSE2-NEXT:    pcmpgtd %xmm9, %xmm12
; SSE2-NEXT:    pshufd {{.*#+}} xmm13 = xmm12[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm9, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm10 = xmm10[1,1,3,3]
; SSE2-NEXT:    pand %xmm13, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm9 = xmm12[1,1,3,3]
; SSE2-NEXT:    por %xmm10, %xmm9
; SSE2-NEXT:    movdqa %xmm1, %xmm10
; SSE2-NEXT:    pxor %xmm11, %xmm10
; SSE2-NEXT:    movdqa %xmm5, %xmm12
; SSE2-NEXT:    pxor %xmm11, %xmm12
; SSE2-NEXT:    movdqa %xmm12, %xmm13
; SSE2-NEXT:    pcmpgtd %xmm10, %xmm13
; SSE2-NEXT:    pshufd {{.*#+}} xmm14 = xmm13[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm10, %xmm12
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm12[1,1,3,3]
; SSE2-NEXT:    pand %xmm14, %xmm12
; SSE2-NEXT:    pshufd {{.*#+}} xmm10 = xmm13[1,1,3,3]
; SSE2-NEXT:    por %xmm12, %xmm10
; SSE2-NEXT:    movdqa %xmm0, %xmm12
; SSE2-NEXT:    pxor %xmm11, %xmm12
; SSE2-NEXT:    pxor %xmm4, %xmm11
; SSE2-NEXT:    movdqa %xmm11, %xmm13
; SSE2-NEXT:    pcmpgtd %xmm12, %xmm13
; SSE2-NEXT:    pshufd {{.*#+}} xmm14 = xmm13[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm12, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm11[1,1,3,3]
; SSE2-NEXT:    pand %xmm14, %xmm12
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm13[1,1,3,3]
; SSE2-NEXT:    por %xmm12, %xmm11
; SSE2-NEXT:    pand %xmm11, %xmm4
; SSE2-NEXT:    pandn %xmm0, %xmm11
; SSE2-NEXT:    por %xmm4, %xmm11
; SSE2-NEXT:    pand %xmm10, %xmm5
; SSE2-NEXT:    pandn %xmm1, %xmm10
; SSE2-NEXT:    por %xmm5, %xmm10
; SSE2-NEXT:    pand %xmm9, %xmm6
; SSE2-NEXT:    pandn %xmm2, %xmm9
; SSE2-NEXT:    por %xmm6, %xmm9
; SSE2-NEXT:    pand %xmm8, %xmm7
; SSE2-NEXT:    pandn %xmm3, %xmm8
; SSE2-NEXT:    por %xmm7, %xmm8
; SSE2-NEXT:    movdqa %xmm11, %xmm0
; SSE2-NEXT:    movdqa %xmm10, %xmm1
; SSE2-NEXT:    movdqa %xmm9, %xmm2
; SSE2-NEXT:    movdqa %xmm8, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test153:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm8
; SSE4-NEXT:    movdqa %xmm7, %xmm9
; SSE4-NEXT:    pcmpgtq %xmm3, %xmm9
; SSE4-NEXT:    movdqa %xmm6, %xmm10
; SSE4-NEXT:    pcmpgtq %xmm2, %xmm10
; SSE4-NEXT:    movdqa %xmm5, %xmm11
; SSE4-NEXT:    pcmpgtq %xmm1, %xmm11
; SSE4-NEXT:    movdqa %xmm4, %xmm0
; SSE4-NEXT:    pcmpgtq %xmm8, %xmm0
; SSE4-NEXT:    blendvpd %xmm4, %xmm8
; SSE4-NEXT:    movdqa %xmm11, %xmm0
; SSE4-NEXT:    blendvpd %xmm5, %xmm1
; SSE4-NEXT:    movdqa %xmm10, %xmm0
; SSE4-NEXT:    blendvpd %xmm6, %xmm2
; SSE4-NEXT:    movdqa %xmm9, %xmm0
; SSE4-NEXT:    blendvpd %xmm7, %xmm3
; SSE4-NEXT:    movapd %xmm8, %xmm0
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test153:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm5
; AVX1-NEXT:    vpcmpgtq %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpcmpgtq %xmm1, %xmm3, %xmm5
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm5, %ymm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm6
; AVX1-NEXT:    vpcmpgtq %xmm5, %xmm6, %xmm5
; AVX1-NEXT:    vpcmpgtq %xmm0, %xmm2, %xmm6
; AVX1-NEXT:    vinsertf128 $1, %xmm5, %ymm6, %ymm5
; AVX1-NEXT:    vblendvpd %ymm5, %ymm2, %ymm0, %ymm0
; AVX1-NEXT:    vblendvpd %ymm4, %ymm3, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test153:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpcmpgtq %ymm1, %ymm3, %ymm4
; AVX2-NEXT:    vpcmpgtq %ymm0, %ymm2, %ymm5
; AVX2-NEXT:    vblendvpd %ymm5, %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vblendvpd %ymm4, %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test153:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxsq %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp slt <8 x i64> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i64> %b, <8 x i64> %a
  ret <8 x i64> %sel
}

define <8 x i64> @test154(<8 x i64> %a, <8 x i64> %b) {
; SSE2-LABEL: test154:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm7, %xmm8
; SSE2-NEXT:    movdqa %xmm8, -{{[0-9]+}}(%rsp) # 16-byte Spill
; SSE2-NEXT:    movdqa %xmm3, %xmm7
; SSE2-NEXT:    movdqa %xmm2, %xmm3
; SSE2-NEXT:    movdqa %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm0, %xmm9
; SSE2-NEXT:    movdqa {{.*#+}} xmm10 = [2147483648,0,2147483648,0]
; SSE2-NEXT:    pxor %xmm10, %xmm8
; SSE2-NEXT:    movdqa %xmm7, %xmm0
; SSE2-NEXT:    pxor %xmm10, %xmm0
; SSE2-NEXT:    movdqa %xmm0, %xmm11
; SSE2-NEXT:    pcmpgtd %xmm8, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm11[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm8, %xmm0
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,1,3,3]
; SSE2-NEXT:    pand %xmm12, %xmm0
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm11[1,1,3,3]
; SSE2-NEXT:    por %xmm0, %xmm12
; SSE2-NEXT:    pcmpeqd %xmm1, %xmm1
; SSE2-NEXT:    movdqa %xmm12, %xmm8
; SSE2-NEXT:    pxor %xmm1, %xmm8
; SSE2-NEXT:    movdqa %xmm6, %xmm11
; SSE2-NEXT:    pxor %xmm10, %xmm11
; SSE2-NEXT:    movdqa %xmm3, %xmm13
; SSE2-NEXT:    pxor %xmm10, %xmm13
; SSE2-NEXT:    movdqa %xmm13, %xmm14
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm14
; SSE2-NEXT:    pshufd {{.*#+}} xmm15 = xmm14[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm11, %xmm13
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm13[1,1,3,3]
; SSE2-NEXT:    pand %xmm15, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm13 = xmm14[1,1,3,3]
; SSE2-NEXT:    por %xmm11, %xmm13
; SSE2-NEXT:    movdqa %xmm5, %xmm11
; SSE2-NEXT:    pxor %xmm10, %xmm11
; SSE2-NEXT:    movdqa %xmm2, %xmm14
; SSE2-NEXT:    pxor %xmm10, %xmm14
; SSE2-NEXT:    movdqa %xmm14, %xmm15
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm15
; SSE2-NEXT:    pcmpeqd %xmm11, %xmm14
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm15[0,0,2,2]
; SSE2-NEXT:    pshufd {{.*#+}} xmm14 = xmm14[1,1,3,3]
; SSE2-NEXT:    pand %xmm11, %xmm14
; SSE2-NEXT:    pshufd {{.*#+}} xmm15 = xmm15[1,1,3,3]
; SSE2-NEXT:    por %xmm14, %xmm15
; SSE2-NEXT:    movdqa %xmm4, %xmm11
; SSE2-NEXT:    pxor %xmm10, %xmm11
; SSE2-NEXT:    pxor %xmm9, %xmm10
; SSE2-NEXT:    movdqa %xmm10, %xmm14
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm14
; SSE2-NEXT:    pcmpeqd %xmm11, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm14[0,0,2,2]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm10[1,1,3,3]
; SSE2-NEXT:    pand %xmm11, %xmm0
; SSE2-NEXT:    movdqa %xmm13, %xmm10
; SSE2-NEXT:    pxor %xmm1, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm14 = xmm14[1,1,3,3]
; SSE2-NEXT:    por %xmm0, %xmm14
; SSE2-NEXT:    movdqa %xmm15, %xmm11
; SSE2-NEXT:    pxor %xmm1, %xmm11
; SSE2-NEXT:    pxor %xmm14, %xmm1
; SSE2-NEXT:    pandn %xmm4, %xmm14
; SSE2-NEXT:    pandn %xmm9, %xmm1
; SSE2-NEXT:    por %xmm14, %xmm1
; SSE2-NEXT:    pandn %xmm5, %xmm15
; SSE2-NEXT:    pandn %xmm2, %xmm11
; SSE2-NEXT:    por %xmm15, %xmm11
; SSE2-NEXT:    pandn %xmm6, %xmm13
; SSE2-NEXT:    pandn %xmm3, %xmm10
; SSE2-NEXT:    por %xmm13, %xmm10
; SSE2-NEXT:    pandn -{{[0-9]+}}(%rsp), %xmm12 # 16-byte Folded Reload
; SSE2-NEXT:    pandn %xmm7, %xmm8
; SSE2-NEXT:    por %xmm12, %xmm8
; SSE2-NEXT:    movdqa %xmm1, %xmm0
; SSE2-NEXT:    movdqa %xmm11, %xmm1
; SSE2-NEXT:    movdqa %xmm10, %xmm2
; SSE2-NEXT:    movdqa %xmm8, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test154:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm8
; SSE4-NEXT:    movdqa %xmm3, %xmm9
; SSE4-NEXT:    pcmpgtq %xmm7, %xmm9
; SSE4-NEXT:    pcmpeqd %xmm12, %xmm12
; SSE4-NEXT:    pxor %xmm12, %xmm9
; SSE4-NEXT:    movdqa %xmm2, %xmm10
; SSE4-NEXT:    pcmpgtq %xmm6, %xmm10
; SSE4-NEXT:    pxor %xmm12, %xmm10
; SSE4-NEXT:    movdqa %xmm1, %xmm11
; SSE4-NEXT:    pcmpgtq %xmm5, %xmm11
; SSE4-NEXT:    pxor %xmm12, %xmm11
; SSE4-NEXT:    pcmpgtq %xmm4, %xmm0
; SSE4-NEXT:    pxor %xmm12, %xmm0
; SSE4-NEXT:    blendvpd %xmm4, %xmm8
; SSE4-NEXT:    movdqa %xmm11, %xmm0
; SSE4-NEXT:    blendvpd %xmm5, %xmm1
; SSE4-NEXT:    movdqa %xmm10, %xmm0
; SSE4-NEXT:    blendvpd %xmm6, %xmm2
; SSE4-NEXT:    movdqa %xmm9, %xmm0
; SSE4-NEXT:    blendvpd %xmm7, %xmm3
; SSE4-NEXT:    movapd %xmm8, %xmm0
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test154:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm5
; AVX1-NEXT:    vpcmpgtq %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpcmpeqd %xmm5, %xmm5, %xmm5
; AVX1-NEXT:    vpxor %xmm5, %xmm4, %xmm4
; AVX1-NEXT:    vpcmpgtq %xmm3, %xmm1, %xmm6
; AVX1-NEXT:    vpxor %xmm5, %xmm6, %xmm6
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm6, %ymm4
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm6
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm7
; AVX1-NEXT:    vpcmpgtq %xmm6, %xmm7, %xmm6
; AVX1-NEXT:    vpxor %xmm5, %xmm6, %xmm6
; AVX1-NEXT:    vpcmpgtq %xmm2, %xmm0, %xmm7
; AVX1-NEXT:    vpxor %xmm5, %xmm7, %xmm5
; AVX1-NEXT:    vinsertf128 $1, %xmm6, %ymm5, %ymm5
; AVX1-NEXT:    vblendvpd %ymm5, %ymm2, %ymm0, %ymm0
; AVX1-NEXT:    vblendvpd %ymm4, %ymm3, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test154:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpcmpgtq %ymm3, %ymm1, %ymm4
; AVX2-NEXT:    vpcmpeqd %ymm5, %ymm5, %ymm5
; AVX2-NEXT:    vpxor %ymm5, %ymm4, %ymm4
; AVX2-NEXT:    vpcmpgtq %ymm2, %ymm0, %ymm6
; AVX2-NEXT:    vpxor %ymm5, %ymm6, %ymm5
; AVX2-NEXT:    vblendvpd %ymm5, %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vblendvpd %ymm4, %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test154:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxsq %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp sle <8 x i64> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i64> %b, <8 x i64> %a
  ret <8 x i64> %sel
}

define <8 x i64> @test155(<8 x i64> %a, <8 x i64> %b) {
; SSE2-LABEL: test155:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm11 = [2147483648,0,2147483648,0]
; SSE2-NEXT:    movdqa %xmm7, %xmm8
; SSE2-NEXT:    pxor %xmm11, %xmm8
; SSE2-NEXT:    movdqa %xmm3, %xmm9
; SSE2-NEXT:    pxor %xmm11, %xmm9
; SSE2-NEXT:    movdqa %xmm9, %xmm10
; SSE2-NEXT:    pcmpgtd %xmm8, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm10[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm8, %xmm9
; SSE2-NEXT:    pshufd {{.*#+}} xmm9 = xmm9[1,1,3,3]
; SSE2-NEXT:    pand %xmm12, %xmm9
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm10[1,1,3,3]
; SSE2-NEXT:    por %xmm9, %xmm8
; SSE2-NEXT:    movdqa %xmm6, %xmm9
; SSE2-NEXT:    pxor %xmm11, %xmm9
; SSE2-NEXT:    movdqa %xmm2, %xmm10
; SSE2-NEXT:    pxor %xmm11, %xmm10
; SSE2-NEXT:    movdqa %xmm10, %xmm12
; SSE2-NEXT:    pcmpgtd %xmm9, %xmm12
; SSE2-NEXT:    pshufd {{.*#+}} xmm13 = xmm12[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm9, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm10 = xmm10[1,1,3,3]
; SSE2-NEXT:    pand %xmm13, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm9 = xmm12[1,1,3,3]
; SSE2-NEXT:    por %xmm10, %xmm9
; SSE2-NEXT:    movdqa %xmm5, %xmm10
; SSE2-NEXT:    pxor %xmm11, %xmm10
; SSE2-NEXT:    movdqa %xmm1, %xmm12
; SSE2-NEXT:    pxor %xmm11, %xmm12
; SSE2-NEXT:    movdqa %xmm12, %xmm13
; SSE2-NEXT:    pcmpgtd %xmm10, %xmm13
; SSE2-NEXT:    pshufd {{.*#+}} xmm14 = xmm13[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm10, %xmm12
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm12[1,1,3,3]
; SSE2-NEXT:    pand %xmm14, %xmm12
; SSE2-NEXT:    pshufd {{.*#+}} xmm10 = xmm13[1,1,3,3]
; SSE2-NEXT:    por %xmm12, %xmm10
; SSE2-NEXT:    movdqa %xmm4, %xmm12
; SSE2-NEXT:    pxor %xmm11, %xmm12
; SSE2-NEXT:    pxor %xmm0, %xmm11
; SSE2-NEXT:    movdqa %xmm11, %xmm13
; SSE2-NEXT:    pcmpgtd %xmm12, %xmm13
; SSE2-NEXT:    pshufd {{.*#+}} xmm14 = xmm13[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm12, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm11[1,1,3,3]
; SSE2-NEXT:    pand %xmm14, %xmm12
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm13[1,1,3,3]
; SSE2-NEXT:    por %xmm12, %xmm11
; SSE2-NEXT:    pand %xmm11, %xmm4
; SSE2-NEXT:    pandn %xmm0, %xmm11
; SSE2-NEXT:    por %xmm4, %xmm11
; SSE2-NEXT:    pand %xmm10, %xmm5
; SSE2-NEXT:    pandn %xmm1, %xmm10
; SSE2-NEXT:    por %xmm5, %xmm10
; SSE2-NEXT:    pand %xmm9, %xmm6
; SSE2-NEXT:    pandn %xmm2, %xmm9
; SSE2-NEXT:    por %xmm6, %xmm9
; SSE2-NEXT:    pand %xmm8, %xmm7
; SSE2-NEXT:    pandn %xmm3, %xmm8
; SSE2-NEXT:    por %xmm7, %xmm8
; SSE2-NEXT:    movdqa %xmm11, %xmm0
; SSE2-NEXT:    movdqa %xmm10, %xmm1
; SSE2-NEXT:    movdqa %xmm9, %xmm2
; SSE2-NEXT:    movdqa %xmm8, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test155:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm8
; SSE4-NEXT:    movdqa %xmm3, %xmm9
; SSE4-NEXT:    pcmpgtq %xmm7, %xmm9
; SSE4-NEXT:    movdqa %xmm2, %xmm10
; SSE4-NEXT:    pcmpgtq %xmm6, %xmm10
; SSE4-NEXT:    movdqa %xmm1, %xmm11
; SSE4-NEXT:    pcmpgtq %xmm5, %xmm11
; SSE4-NEXT:    pcmpgtq %xmm4, %xmm0
; SSE4-NEXT:    blendvpd %xmm4, %xmm8
; SSE4-NEXT:    movdqa %xmm11, %xmm0
; SSE4-NEXT:    blendvpd %xmm5, %xmm1
; SSE4-NEXT:    movdqa %xmm10, %xmm0
; SSE4-NEXT:    blendvpd %xmm6, %xmm2
; SSE4-NEXT:    movdqa %xmm9, %xmm0
; SSE4-NEXT:    blendvpd %xmm7, %xmm3
; SSE4-NEXT:    movapd %xmm8, %xmm0
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test155:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm5
; AVX1-NEXT:    vpcmpgtq %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpcmpgtq %xmm3, %xmm1, %xmm5
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm5, %ymm4
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm5
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm6
; AVX1-NEXT:    vpcmpgtq %xmm5, %xmm6, %xmm5
; AVX1-NEXT:    vpcmpgtq %xmm2, %xmm0, %xmm6
; AVX1-NEXT:    vinsertf128 $1, %xmm5, %ymm6, %ymm5
; AVX1-NEXT:    vblendvpd %ymm5, %ymm2, %ymm0, %ymm0
; AVX1-NEXT:    vblendvpd %ymm4, %ymm3, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test155:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpcmpgtq %ymm3, %ymm1, %ymm4
; AVX2-NEXT:    vpcmpgtq %ymm2, %ymm0, %ymm5
; AVX2-NEXT:    vblendvpd %ymm5, %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vblendvpd %ymm4, %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test155:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminsq %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp sgt <8 x i64> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i64> %b, <8 x i64> %a
  ret <8 x i64> %sel
}

define <8 x i64> @test156(<8 x i64> %a, <8 x i64> %b) {
; SSE2-LABEL: test156:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm7, %xmm11
; SSE2-NEXT:    movdqa %xmm11, -{{[0-9]+}}(%rsp) # 16-byte Spill
; SSE2-NEXT:    movdqa %xmm3, %xmm7
; SSE2-NEXT:    movdqa %xmm2, %xmm3
; SSE2-NEXT:    movdqa %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm0, %xmm9
; SSE2-NEXT:    movdqa {{.*#+}} xmm10 = [2147483648,0,2147483648,0]
; SSE2-NEXT:    movdqa %xmm7, %xmm8
; SSE2-NEXT:    pxor %xmm10, %xmm8
; SSE2-NEXT:    movdqa %xmm11, %xmm0
; SSE2-NEXT:    pxor %xmm10, %xmm0
; SSE2-NEXT:    movdqa %xmm0, %xmm11
; SSE2-NEXT:    pcmpgtd %xmm8, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm11[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm8, %xmm0
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,1,3,3]
; SSE2-NEXT:    pand %xmm12, %xmm0
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm11[1,1,3,3]
; SSE2-NEXT:    por %xmm0, %xmm12
; SSE2-NEXT:    pcmpeqd %xmm1, %xmm1
; SSE2-NEXT:    movdqa %xmm12, %xmm8
; SSE2-NEXT:    pxor %xmm1, %xmm8
; SSE2-NEXT:    movdqa %xmm3, %xmm11
; SSE2-NEXT:    pxor %xmm10, %xmm11
; SSE2-NEXT:    movdqa %xmm6, %xmm13
; SSE2-NEXT:    pxor %xmm10, %xmm13
; SSE2-NEXT:    movdqa %xmm13, %xmm14
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm14
; SSE2-NEXT:    pshufd {{.*#+}} xmm15 = xmm14[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm11, %xmm13
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm13[1,1,3,3]
; SSE2-NEXT:    pand %xmm15, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm13 = xmm14[1,1,3,3]
; SSE2-NEXT:    por %xmm11, %xmm13
; SSE2-NEXT:    movdqa %xmm2, %xmm11
; SSE2-NEXT:    pxor %xmm10, %xmm11
; SSE2-NEXT:    movdqa %xmm5, %xmm14
; SSE2-NEXT:    pxor %xmm10, %xmm14
; SSE2-NEXT:    movdqa %xmm14, %xmm15
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm15
; SSE2-NEXT:    pcmpeqd %xmm11, %xmm14
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm15[0,0,2,2]
; SSE2-NEXT:    pshufd {{.*#+}} xmm14 = xmm14[1,1,3,3]
; SSE2-NEXT:    pand %xmm11, %xmm14
; SSE2-NEXT:    pshufd {{.*#+}} xmm15 = xmm15[1,1,3,3]
; SSE2-NEXT:    por %xmm14, %xmm15
; SSE2-NEXT:    movdqa %xmm9, %xmm11
; SSE2-NEXT:    pxor %xmm10, %xmm11
; SSE2-NEXT:    pxor %xmm4, %xmm10
; SSE2-NEXT:    movdqa %xmm10, %xmm14
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm14
; SSE2-NEXT:    pcmpeqd %xmm11, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm14[0,0,2,2]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm10[1,1,3,3]
; SSE2-NEXT:    pand %xmm11, %xmm0
; SSE2-NEXT:    movdqa %xmm13, %xmm10
; SSE2-NEXT:    pxor %xmm1, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm14 = xmm14[1,1,3,3]
; SSE2-NEXT:    por %xmm0, %xmm14
; SSE2-NEXT:    movdqa %xmm15, %xmm11
; SSE2-NEXT:    pxor %xmm1, %xmm11
; SSE2-NEXT:    pxor %xmm14, %xmm1
; SSE2-NEXT:    pandn %xmm4, %xmm14
; SSE2-NEXT:    pandn %xmm9, %xmm1
; SSE2-NEXT:    por %xmm14, %xmm1
; SSE2-NEXT:    pandn %xmm5, %xmm15
; SSE2-NEXT:    pandn %xmm2, %xmm11
; SSE2-NEXT:    por %xmm15, %xmm11
; SSE2-NEXT:    pandn %xmm6, %xmm13
; SSE2-NEXT:    pandn %xmm3, %xmm10
; SSE2-NEXT:    por %xmm13, %xmm10
; SSE2-NEXT:    pandn -{{[0-9]+}}(%rsp), %xmm12 # 16-byte Folded Reload
; SSE2-NEXT:    pandn %xmm7, %xmm8
; SSE2-NEXT:    por %xmm12, %xmm8
; SSE2-NEXT:    movdqa %xmm1, %xmm0
; SSE2-NEXT:    movdqa %xmm11, %xmm1
; SSE2-NEXT:    movdqa %xmm10, %xmm2
; SSE2-NEXT:    movdqa %xmm8, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test156:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm8
; SSE4-NEXT:    movdqa %xmm7, %xmm9
; SSE4-NEXT:    pcmpgtq %xmm3, %xmm9
; SSE4-NEXT:    pcmpeqd %xmm0, %xmm0
; SSE4-NEXT:    pxor %xmm0, %xmm9
; SSE4-NEXT:    movdqa %xmm6, %xmm10
; SSE4-NEXT:    pcmpgtq %xmm2, %xmm10
; SSE4-NEXT:    pxor %xmm0, %xmm10
; SSE4-NEXT:    movdqa %xmm5, %xmm11
; SSE4-NEXT:    pcmpgtq %xmm1, %xmm11
; SSE4-NEXT:    pxor %xmm0, %xmm11
; SSE4-NEXT:    movdqa %xmm4, %xmm12
; SSE4-NEXT:    pcmpgtq %xmm8, %xmm12
; SSE4-NEXT:    pxor %xmm12, %xmm0
; SSE4-NEXT:    blendvpd %xmm4, %xmm8
; SSE4-NEXT:    movdqa %xmm11, %xmm0
; SSE4-NEXT:    blendvpd %xmm5, %xmm1
; SSE4-NEXT:    movdqa %xmm10, %xmm0
; SSE4-NEXT:    blendvpd %xmm6, %xmm2
; SSE4-NEXT:    movdqa %xmm9, %xmm0
; SSE4-NEXT:    blendvpd %xmm7, %xmm3
; SSE4-NEXT:    movapd %xmm8, %xmm0
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test156:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm5
; AVX1-NEXT:    vpcmpgtq %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpcmpeqd %xmm5, %xmm5, %xmm5
; AVX1-NEXT:    vpxor %xmm5, %xmm4, %xmm4
; AVX1-NEXT:    vpcmpgtq %xmm1, %xmm3, %xmm6
; AVX1-NEXT:    vpxor %xmm5, %xmm6, %xmm6
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm6, %ymm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm6
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm7
; AVX1-NEXT:    vpcmpgtq %xmm6, %xmm7, %xmm6
; AVX1-NEXT:    vpxor %xmm5, %xmm6, %xmm6
; AVX1-NEXT:    vpcmpgtq %xmm0, %xmm2, %xmm7
; AVX1-NEXT:    vpxor %xmm5, %xmm7, %xmm5
; AVX1-NEXT:    vinsertf128 $1, %xmm6, %ymm5, %ymm5
; AVX1-NEXT:    vblendvpd %ymm5, %ymm2, %ymm0, %ymm0
; AVX1-NEXT:    vblendvpd %ymm4, %ymm3, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test156:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpcmpgtq %ymm1, %ymm3, %ymm4
; AVX2-NEXT:    vpcmpeqd %ymm5, %ymm5, %ymm5
; AVX2-NEXT:    vpxor %ymm5, %ymm4, %ymm4
; AVX2-NEXT:    vpcmpgtq %ymm0, %ymm2, %ymm6
; AVX2-NEXT:    vpxor %ymm5, %ymm6, %ymm5
; AVX2-NEXT:    vblendvpd %ymm5, %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vblendvpd %ymm4, %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test156:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminsq %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp sge <8 x i64> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i64> %b, <8 x i64> %a
  ret <8 x i64> %sel
}

define <8 x i64> @test157(<8 x i64> %a, <8 x i64> %b) {
; SSE2-LABEL: test157:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm11 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm3, %xmm8
; SSE2-NEXT:    pxor %xmm11, %xmm8
; SSE2-NEXT:    movdqa %xmm7, %xmm9
; SSE2-NEXT:    pxor %xmm11, %xmm9
; SSE2-NEXT:    movdqa %xmm9, %xmm10
; SSE2-NEXT:    pcmpgtd %xmm8, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm10[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm8, %xmm9
; SSE2-NEXT:    pshufd {{.*#+}} xmm9 = xmm9[1,1,3,3]
; SSE2-NEXT:    pand %xmm12, %xmm9
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm10[1,1,3,3]
; SSE2-NEXT:    por %xmm9, %xmm8
; SSE2-NEXT:    movdqa %xmm2, %xmm9
; SSE2-NEXT:    pxor %xmm11, %xmm9
; SSE2-NEXT:    movdqa %xmm6, %xmm10
; SSE2-NEXT:    pxor %xmm11, %xmm10
; SSE2-NEXT:    movdqa %xmm10, %xmm12
; SSE2-NEXT:    pcmpgtd %xmm9, %xmm12
; SSE2-NEXT:    pshufd {{.*#+}} xmm13 = xmm12[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm9, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm10 = xmm10[1,1,3,3]
; SSE2-NEXT:    pand %xmm13, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm9 = xmm12[1,1,3,3]
; SSE2-NEXT:    por %xmm10, %xmm9
; SSE2-NEXT:    movdqa %xmm1, %xmm10
; SSE2-NEXT:    pxor %xmm11, %xmm10
; SSE2-NEXT:    movdqa %xmm5, %xmm12
; SSE2-NEXT:    pxor %xmm11, %xmm12
; SSE2-NEXT:    movdqa %xmm12, %xmm13
; SSE2-NEXT:    pcmpgtd %xmm10, %xmm13
; SSE2-NEXT:    pshufd {{.*#+}} xmm14 = xmm13[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm10, %xmm12
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm12[1,1,3,3]
; SSE2-NEXT:    pand %xmm14, %xmm12
; SSE2-NEXT:    pshufd {{.*#+}} xmm10 = xmm13[1,1,3,3]
; SSE2-NEXT:    por %xmm12, %xmm10
; SSE2-NEXT:    movdqa %xmm0, %xmm12
; SSE2-NEXT:    pxor %xmm11, %xmm12
; SSE2-NEXT:    pxor %xmm4, %xmm11
; SSE2-NEXT:    movdqa %xmm11, %xmm13
; SSE2-NEXT:    pcmpgtd %xmm12, %xmm13
; SSE2-NEXT:    pshufd {{.*#+}} xmm14 = xmm13[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm12, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm11[1,1,3,3]
; SSE2-NEXT:    pand %xmm14, %xmm12
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm13[1,1,3,3]
; SSE2-NEXT:    por %xmm12, %xmm11
; SSE2-NEXT:    pand %xmm11, %xmm4
; SSE2-NEXT:    pandn %xmm0, %xmm11
; SSE2-NEXT:    por %xmm4, %xmm11
; SSE2-NEXT:    pand %xmm10, %xmm5
; SSE2-NEXT:    pandn %xmm1, %xmm10
; SSE2-NEXT:    por %xmm5, %xmm10
; SSE2-NEXT:    pand %xmm9, %xmm6
; SSE2-NEXT:    pandn %xmm2, %xmm9
; SSE2-NEXT:    por %xmm6, %xmm9
; SSE2-NEXT:    pand %xmm8, %xmm7
; SSE2-NEXT:    pandn %xmm3, %xmm8
; SSE2-NEXT:    por %xmm7, %xmm8
; SSE2-NEXT:    movdqa %xmm11, %xmm0
; SSE2-NEXT:    movdqa %xmm10, %xmm1
; SSE2-NEXT:    movdqa %xmm9, %xmm2
; SSE2-NEXT:    movdqa %xmm8, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test157:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm8
; SSE4-NEXT:    movdqa {{.*#+}} xmm0 = [9223372036854775808,9223372036854775808]
; SSE4-NEXT:    movdqa %xmm3, %xmm10
; SSE4-NEXT:    pxor %xmm0, %xmm10
; SSE4-NEXT:    movdqa %xmm7, %xmm9
; SSE4-NEXT:    pxor %xmm0, %xmm9
; SSE4-NEXT:    pcmpgtq %xmm10, %xmm9
; SSE4-NEXT:    movdqa %xmm2, %xmm11
; SSE4-NEXT:    pxor %xmm0, %xmm11
; SSE4-NEXT:    movdqa %xmm6, %xmm10
; SSE4-NEXT:    pxor %xmm0, %xmm10
; SSE4-NEXT:    pcmpgtq %xmm11, %xmm10
; SSE4-NEXT:    movdqa %xmm1, %xmm12
; SSE4-NEXT:    pxor %xmm0, %xmm12
; SSE4-NEXT:    movdqa %xmm5, %xmm11
; SSE4-NEXT:    pxor %xmm0, %xmm11
; SSE4-NEXT:    pcmpgtq %xmm12, %xmm11
; SSE4-NEXT:    movdqa %xmm8, %xmm12
; SSE4-NEXT:    pxor %xmm0, %xmm12
; SSE4-NEXT:    pxor %xmm4, %xmm0
; SSE4-NEXT:    pcmpgtq %xmm12, %xmm0
; SSE4-NEXT:    blendvpd %xmm4, %xmm8
; SSE4-NEXT:    movdqa %xmm11, %xmm0
; SSE4-NEXT:    blendvpd %xmm5, %xmm1
; SSE4-NEXT:    movdqa %xmm10, %xmm0
; SSE4-NEXT:    blendvpd %xmm6, %xmm2
; SSE4-NEXT:    movdqa %xmm9, %xmm0
; SSE4-NEXT:    blendvpd %xmm7, %xmm3
; SSE4-NEXT:    movapd %xmm8, %xmm0
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test157:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vmovaps {{.*#+}} xmm5 = [9223372036854775808,9223372036854775808]
; AVX1-NEXT:    vxorps %xmm5, %xmm4, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm6
; AVX1-NEXT:    vxorps %xmm5, %xmm6, %xmm6
; AVX1-NEXT:    vpcmpgtq %xmm4, %xmm6, %xmm4
; AVX1-NEXT:    vxorps %xmm5, %xmm1, %xmm6
; AVX1-NEXT:    vxorps %xmm5, %xmm3, %xmm7
; AVX1-NEXT:    vpcmpgtq %xmm6, %xmm7, %xmm6
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm6, %ymm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm6
; AVX1-NEXT:    vxorps %xmm5, %xmm6, %xmm6
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm7
; AVX1-NEXT:    vxorps %xmm5, %xmm7, %xmm7
; AVX1-NEXT:    vpcmpgtq %xmm6, %xmm7, %xmm6
; AVX1-NEXT:    vxorps %xmm5, %xmm0, %xmm7
; AVX1-NEXT:    vxorps %xmm5, %xmm2, %xmm5
; AVX1-NEXT:    vpcmpgtq %xmm7, %xmm5, %xmm5
; AVX1-NEXT:    vinsertf128 $1, %xmm6, %ymm5, %ymm5
; AVX1-NEXT:    vblendvpd %ymm5, %ymm2, %ymm0, %ymm0
; AVX1-NEXT:    vblendvpd %ymm4, %ymm3, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test157:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpbroadcastq {{.*}}(%rip), %ymm4
; AVX2-NEXT:    vpxor %ymm4, %ymm1, %ymm5
; AVX2-NEXT:    vpxor %ymm4, %ymm3, %ymm6
; AVX2-NEXT:    vpcmpgtq %ymm5, %ymm6, %ymm5
; AVX2-NEXT:    vpxor %ymm4, %ymm0, %ymm6
; AVX2-NEXT:    vpxor %ymm4, %ymm2, %ymm4
; AVX2-NEXT:    vpcmpgtq %ymm6, %ymm4, %ymm4
; AVX2-NEXT:    vblendvpd %ymm4, %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vblendvpd %ymm5, %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test157:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxuq %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp ult <8 x i64> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i64> %b, <8 x i64> %a
  ret <8 x i64> %sel
}

define <8 x i64> @test158(<8 x i64> %a, <8 x i64> %b) {
; SSE2-LABEL: test158:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm7, %xmm8
; SSE2-NEXT:    movdqa %xmm8, -{{[0-9]+}}(%rsp) # 16-byte Spill
; SSE2-NEXT:    movdqa %xmm3, %xmm7
; SSE2-NEXT:    movdqa %xmm2, %xmm3
; SSE2-NEXT:    movdqa %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm0, %xmm9
; SSE2-NEXT:    movdqa {{.*#+}} xmm10 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    pxor %xmm10, %xmm8
; SSE2-NEXT:    movdqa %xmm7, %xmm0
; SSE2-NEXT:    pxor %xmm10, %xmm0
; SSE2-NEXT:    movdqa %xmm0, %xmm11
; SSE2-NEXT:    pcmpgtd %xmm8, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm11[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm8, %xmm0
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,1,3,3]
; SSE2-NEXT:    pand %xmm12, %xmm0
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm11[1,1,3,3]
; SSE2-NEXT:    por %xmm0, %xmm12
; SSE2-NEXT:    pcmpeqd %xmm1, %xmm1
; SSE2-NEXT:    movdqa %xmm12, %xmm8
; SSE2-NEXT:    pxor %xmm1, %xmm8
; SSE2-NEXT:    movdqa %xmm6, %xmm11
; SSE2-NEXT:    pxor %xmm10, %xmm11
; SSE2-NEXT:    movdqa %xmm3, %xmm13
; SSE2-NEXT:    pxor %xmm10, %xmm13
; SSE2-NEXT:    movdqa %xmm13, %xmm14
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm14
; SSE2-NEXT:    pshufd {{.*#+}} xmm15 = xmm14[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm11, %xmm13
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm13[1,1,3,3]
; SSE2-NEXT:    pand %xmm15, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm13 = xmm14[1,1,3,3]
; SSE2-NEXT:    por %xmm11, %xmm13
; SSE2-NEXT:    movdqa %xmm5, %xmm11
; SSE2-NEXT:    pxor %xmm10, %xmm11
; SSE2-NEXT:    movdqa %xmm2, %xmm14
; SSE2-NEXT:    pxor %xmm10, %xmm14
; SSE2-NEXT:    movdqa %xmm14, %xmm15
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm15
; SSE2-NEXT:    pcmpeqd %xmm11, %xmm14
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm15[0,0,2,2]
; SSE2-NEXT:    pshufd {{.*#+}} xmm14 = xmm14[1,1,3,3]
; SSE2-NEXT:    pand %xmm11, %xmm14
; SSE2-NEXT:    pshufd {{.*#+}} xmm15 = xmm15[1,1,3,3]
; SSE2-NEXT:    por %xmm14, %xmm15
; SSE2-NEXT:    movdqa %xmm4, %xmm11
; SSE2-NEXT:    pxor %xmm10, %xmm11
; SSE2-NEXT:    pxor %xmm9, %xmm10
; SSE2-NEXT:    movdqa %xmm10, %xmm14
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm14
; SSE2-NEXT:    pcmpeqd %xmm11, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm14[0,0,2,2]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm10[1,1,3,3]
; SSE2-NEXT:    pand %xmm11, %xmm0
; SSE2-NEXT:    movdqa %xmm13, %xmm10
; SSE2-NEXT:    pxor %xmm1, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm14 = xmm14[1,1,3,3]
; SSE2-NEXT:    por %xmm0, %xmm14
; SSE2-NEXT:    movdqa %xmm15, %xmm11
; SSE2-NEXT:    pxor %xmm1, %xmm11
; SSE2-NEXT:    pxor %xmm14, %xmm1
; SSE2-NEXT:    pandn %xmm4, %xmm14
; SSE2-NEXT:    pandn %xmm9, %xmm1
; SSE2-NEXT:    por %xmm14, %xmm1
; SSE2-NEXT:    pandn %xmm5, %xmm15
; SSE2-NEXT:    pandn %xmm2, %xmm11
; SSE2-NEXT:    por %xmm15, %xmm11
; SSE2-NEXT:    pandn %xmm6, %xmm13
; SSE2-NEXT:    pandn %xmm3, %xmm10
; SSE2-NEXT:    por %xmm13, %xmm10
; SSE2-NEXT:    pandn -{{[0-9]+}}(%rsp), %xmm12 # 16-byte Folded Reload
; SSE2-NEXT:    pandn %xmm7, %xmm8
; SSE2-NEXT:    por %xmm12, %xmm8
; SSE2-NEXT:    movdqa %xmm1, %xmm0
; SSE2-NEXT:    movdqa %xmm11, %xmm1
; SSE2-NEXT:    movdqa %xmm10, %xmm2
; SSE2-NEXT:    movdqa %xmm8, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test158:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm8
; SSE4-NEXT:    movdqa {{.*#+}} xmm0 = [9223372036854775808,9223372036854775808]
; SSE4-NEXT:    movdqa %xmm7, %xmm10
; SSE4-NEXT:    pxor %xmm0, %xmm10
; SSE4-NEXT:    movdqa %xmm3, %xmm9
; SSE4-NEXT:    pxor %xmm0, %xmm9
; SSE4-NEXT:    pcmpgtq %xmm10, %xmm9
; SSE4-NEXT:    pcmpeqd %xmm12, %xmm12
; SSE4-NEXT:    pxor %xmm12, %xmm9
; SSE4-NEXT:    movdqa %xmm6, %xmm11
; SSE4-NEXT:    pxor %xmm0, %xmm11
; SSE4-NEXT:    movdqa %xmm2, %xmm10
; SSE4-NEXT:    pxor %xmm0, %xmm10
; SSE4-NEXT:    pcmpgtq %xmm11, %xmm10
; SSE4-NEXT:    pxor %xmm12, %xmm10
; SSE4-NEXT:    movdqa %xmm5, %xmm13
; SSE4-NEXT:    pxor %xmm0, %xmm13
; SSE4-NEXT:    movdqa %xmm1, %xmm11
; SSE4-NEXT:    pxor %xmm0, %xmm11
; SSE4-NEXT:    pcmpgtq %xmm13, %xmm11
; SSE4-NEXT:    pxor %xmm12, %xmm11
; SSE4-NEXT:    movdqa %xmm4, %xmm13
; SSE4-NEXT:    pxor %xmm0, %xmm13
; SSE4-NEXT:    pxor %xmm8, %xmm0
; SSE4-NEXT:    pcmpgtq %xmm13, %xmm0
; SSE4-NEXT:    pxor %xmm12, %xmm0
; SSE4-NEXT:    blendvpd %xmm4, %xmm8
; SSE4-NEXT:    movdqa %xmm11, %xmm0
; SSE4-NEXT:    blendvpd %xmm5, %xmm1
; SSE4-NEXT:    movdqa %xmm10, %xmm0
; SSE4-NEXT:    blendvpd %xmm6, %xmm2
; SSE4-NEXT:    movdqa %xmm9, %xmm0
; SSE4-NEXT:    blendvpd %xmm7, %xmm3
; SSE4-NEXT:    movapd %xmm8, %xmm0
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test158:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm4
; AVX1-NEXT:    vmovaps {{.*#+}} xmm5 = [9223372036854775808,9223372036854775808]
; AVX1-NEXT:    vxorps %xmm5, %xmm4, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm6
; AVX1-NEXT:    vxorps %xmm5, %xmm6, %xmm6
; AVX1-NEXT:    vpcmpgtq %xmm4, %xmm6, %xmm4
; AVX1-NEXT:    vpcmpeqd %xmm8, %xmm8, %xmm8
; AVX1-NEXT:    vpxor %xmm8, %xmm4, %xmm4
; AVX1-NEXT:    vxorps %xmm5, %xmm3, %xmm7
; AVX1-NEXT:    vxorps %xmm5, %xmm1, %xmm6
; AVX1-NEXT:    vpcmpgtq %xmm7, %xmm6, %xmm6
; AVX1-NEXT:    vpxor %xmm8, %xmm6, %xmm6
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm6, %ymm4
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm6
; AVX1-NEXT:    vxorps %xmm5, %xmm6, %xmm6
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm7
; AVX1-NEXT:    vxorps %xmm5, %xmm7, %xmm7
; AVX1-NEXT:    vpcmpgtq %xmm6, %xmm7, %xmm6
; AVX1-NEXT:    vpxor %xmm8, %xmm6, %xmm6
; AVX1-NEXT:    vxorps %xmm5, %xmm2, %xmm7
; AVX1-NEXT:    vxorps %xmm5, %xmm0, %xmm5
; AVX1-NEXT:    vpcmpgtq %xmm7, %xmm5, %xmm5
; AVX1-NEXT:    vpxor %xmm8, %xmm5, %xmm5
; AVX1-NEXT:    vinsertf128 $1, %xmm6, %ymm5, %ymm5
; AVX1-NEXT:    vblendvpd %ymm5, %ymm2, %ymm0, %ymm0
; AVX1-NEXT:    vblendvpd %ymm4, %ymm3, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test158:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpbroadcastq {{.*}}(%rip), %ymm4
; AVX2-NEXT:    vpxor %ymm4, %ymm3, %ymm5
; AVX2-NEXT:    vpxor %ymm4, %ymm1, %ymm6
; AVX2-NEXT:    vpcmpgtq %ymm5, %ymm6, %ymm5
; AVX2-NEXT:    vpcmpeqd %ymm6, %ymm6, %ymm6
; AVX2-NEXT:    vpxor %ymm6, %ymm5, %ymm5
; AVX2-NEXT:    vpxor %ymm4, %ymm2, %ymm7
; AVX2-NEXT:    vpxor %ymm4, %ymm0, %ymm4
; AVX2-NEXT:    vpcmpgtq %ymm7, %ymm4, %ymm4
; AVX2-NEXT:    vpxor %ymm6, %ymm4, %ymm4
; AVX2-NEXT:    vblendvpd %ymm4, %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vblendvpd %ymm5, %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test158:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpmaxuq %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp ule <8 x i64> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i64> %b, <8 x i64> %a
  ret <8 x i64> %sel
}

define <8 x i64> @test159(<8 x i64> %a, <8 x i64> %b) {
; SSE2-LABEL: test159:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm11 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm7, %xmm8
; SSE2-NEXT:    pxor %xmm11, %xmm8
; SSE2-NEXT:    movdqa %xmm3, %xmm9
; SSE2-NEXT:    pxor %xmm11, %xmm9
; SSE2-NEXT:    movdqa %xmm9, %xmm10
; SSE2-NEXT:    pcmpgtd %xmm8, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm10[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm8, %xmm9
; SSE2-NEXT:    pshufd {{.*#+}} xmm9 = xmm9[1,1,3,3]
; SSE2-NEXT:    pand %xmm12, %xmm9
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm10[1,1,3,3]
; SSE2-NEXT:    por %xmm9, %xmm8
; SSE2-NEXT:    movdqa %xmm6, %xmm9
; SSE2-NEXT:    pxor %xmm11, %xmm9
; SSE2-NEXT:    movdqa %xmm2, %xmm10
; SSE2-NEXT:    pxor %xmm11, %xmm10
; SSE2-NEXT:    movdqa %xmm10, %xmm12
; SSE2-NEXT:    pcmpgtd %xmm9, %xmm12
; SSE2-NEXT:    pshufd {{.*#+}} xmm13 = xmm12[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm9, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm10 = xmm10[1,1,3,3]
; SSE2-NEXT:    pand %xmm13, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm9 = xmm12[1,1,3,3]
; SSE2-NEXT:    por %xmm10, %xmm9
; SSE2-NEXT:    movdqa %xmm5, %xmm10
; SSE2-NEXT:    pxor %xmm11, %xmm10
; SSE2-NEXT:    movdqa %xmm1, %xmm12
; SSE2-NEXT:    pxor %xmm11, %xmm12
; SSE2-NEXT:    movdqa %xmm12, %xmm13
; SSE2-NEXT:    pcmpgtd %xmm10, %xmm13
; SSE2-NEXT:    pshufd {{.*#+}} xmm14 = xmm13[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm10, %xmm12
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm12[1,1,3,3]
; SSE2-NEXT:    pand %xmm14, %xmm12
; SSE2-NEXT:    pshufd {{.*#+}} xmm10 = xmm13[1,1,3,3]
; SSE2-NEXT:    por %xmm12, %xmm10
; SSE2-NEXT:    movdqa %xmm4, %xmm12
; SSE2-NEXT:    pxor %xmm11, %xmm12
; SSE2-NEXT:    pxor %xmm0, %xmm11
; SSE2-NEXT:    movdqa %xmm11, %xmm13
; SSE2-NEXT:    pcmpgtd %xmm12, %xmm13
; SSE2-NEXT:    pshufd {{.*#+}} xmm14 = xmm13[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm12, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm11[1,1,3,3]
; SSE2-NEXT:    pand %xmm14, %xmm12
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm13[1,1,3,3]
; SSE2-NEXT:    por %xmm12, %xmm11
; SSE2-NEXT:    pand %xmm11, %xmm4
; SSE2-NEXT:    pandn %xmm0, %xmm11
; SSE2-NEXT:    por %xmm4, %xmm11
; SSE2-NEXT:    pand %xmm10, %xmm5
; SSE2-NEXT:    pandn %xmm1, %xmm10
; SSE2-NEXT:    por %xmm5, %xmm10
; SSE2-NEXT:    pand %xmm9, %xmm6
; SSE2-NEXT:    pandn %xmm2, %xmm9
; SSE2-NEXT:    por %xmm6, %xmm9
; SSE2-NEXT:    pand %xmm8, %xmm7
; SSE2-NEXT:    pandn %xmm3, %xmm8
; SSE2-NEXT:    por %xmm7, %xmm8
; SSE2-NEXT:    movdqa %xmm11, %xmm0
; SSE2-NEXT:    movdqa %xmm10, %xmm1
; SSE2-NEXT:    movdqa %xmm9, %xmm2
; SSE2-NEXT:    movdqa %xmm8, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test159:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm8
; SSE4-NEXT:    movdqa {{.*#+}} xmm0 = [9223372036854775808,9223372036854775808]
; SSE4-NEXT:    movdqa %xmm7, %xmm10
; SSE4-NEXT:    pxor %xmm0, %xmm10
; SSE4-NEXT:    movdqa %xmm3, %xmm9
; SSE4-NEXT:    pxor %xmm0, %xmm9
; SSE4-NEXT:    pcmpgtq %xmm10, %xmm9
; SSE4-NEXT:    movdqa %xmm6, %xmm11
; SSE4-NEXT:    pxor %xmm0, %xmm11
; SSE4-NEXT:    movdqa %xmm2, %xmm10
; SSE4-NEXT:    pxor %xmm0, %xmm10
; SSE4-NEXT:    pcmpgtq %xmm11, %xmm10
; SSE4-NEXT:    movdqa %xmm5, %xmm12
; SSE4-NEXT:    pxor %xmm0, %xmm12
; SSE4-NEXT:    movdqa %xmm1, %xmm11
; SSE4-NEXT:    pxor %xmm0, %xmm11
; SSE4-NEXT:    pcmpgtq %xmm12, %xmm11
; SSE4-NEXT:    movdqa %xmm4, %xmm12
; SSE4-NEXT:    pxor %xmm0, %xmm12
; SSE4-NEXT:    pxor %xmm8, %xmm0
; SSE4-NEXT:    pcmpgtq %xmm12, %xmm0
; SSE4-NEXT:    blendvpd %xmm4, %xmm8
; SSE4-NEXT:    movdqa %xmm11, %xmm0
; SSE4-NEXT:    blendvpd %xmm5, %xmm1
; SSE4-NEXT:    movdqa %xmm10, %xmm0
; SSE4-NEXT:    blendvpd %xmm6, %xmm2
; SSE4-NEXT:    movdqa %xmm9, %xmm0
; SSE4-NEXT:    blendvpd %xmm7, %xmm3
; SSE4-NEXT:    movapd %xmm8, %xmm0
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test159:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm4
; AVX1-NEXT:    vmovaps {{.*#+}} xmm5 = [9223372036854775808,9223372036854775808]
; AVX1-NEXT:    vxorps %xmm5, %xmm4, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm6
; AVX1-NEXT:    vxorps %xmm5, %xmm6, %xmm6
; AVX1-NEXT:    vpcmpgtq %xmm4, %xmm6, %xmm4
; AVX1-NEXT:    vxorps %xmm5, %xmm3, %xmm6
; AVX1-NEXT:    vxorps %xmm5, %xmm1, %xmm7
; AVX1-NEXT:    vpcmpgtq %xmm6, %xmm7, %xmm6
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm6, %ymm4
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm6
; AVX1-NEXT:    vxorps %xmm5, %xmm6, %xmm6
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm7
; AVX1-NEXT:    vxorps %xmm5, %xmm7, %xmm7
; AVX1-NEXT:    vpcmpgtq %xmm6, %xmm7, %xmm6
; AVX1-NEXT:    vxorps %xmm5, %xmm2, %xmm7
; AVX1-NEXT:    vxorps %xmm5, %xmm0, %xmm5
; AVX1-NEXT:    vpcmpgtq %xmm7, %xmm5, %xmm5
; AVX1-NEXT:    vinsertf128 $1, %xmm6, %ymm5, %ymm5
; AVX1-NEXT:    vblendvpd %ymm5, %ymm2, %ymm0, %ymm0
; AVX1-NEXT:    vblendvpd %ymm4, %ymm3, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test159:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpbroadcastq {{.*}}(%rip), %ymm4
; AVX2-NEXT:    vpxor %ymm4, %ymm3, %ymm5
; AVX2-NEXT:    vpxor %ymm4, %ymm1, %ymm6
; AVX2-NEXT:    vpcmpgtq %ymm5, %ymm6, %ymm5
; AVX2-NEXT:    vpxor %ymm4, %ymm2, %ymm6
; AVX2-NEXT:    vpxor %ymm4, %ymm0, %ymm4
; AVX2-NEXT:    vpcmpgtq %ymm6, %ymm4, %ymm4
; AVX2-NEXT:    vblendvpd %ymm4, %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vblendvpd %ymm5, %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test159:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminuq %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp ugt <8 x i64> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i64> %b, <8 x i64> %a
  ret <8 x i64> %sel
}

define <8 x i64> @test160(<8 x i64> %a, <8 x i64> %b) {
; SSE2-LABEL: test160:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa %xmm7, %xmm11
; SSE2-NEXT:    movdqa %xmm11, -{{[0-9]+}}(%rsp) # 16-byte Spill
; SSE2-NEXT:    movdqa %xmm3, %xmm7
; SSE2-NEXT:    movdqa %xmm2, %xmm3
; SSE2-NEXT:    movdqa %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm0, %xmm9
; SSE2-NEXT:    movdqa {{.*#+}} xmm10 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm7, %xmm8
; SSE2-NEXT:    pxor %xmm10, %xmm8
; SSE2-NEXT:    movdqa %xmm11, %xmm0
; SSE2-NEXT:    pxor %xmm10, %xmm0
; SSE2-NEXT:    movdqa %xmm0, %xmm11
; SSE2-NEXT:    pcmpgtd %xmm8, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm11[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm8, %xmm0
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,1,3,3]
; SSE2-NEXT:    pand %xmm12, %xmm0
; SSE2-NEXT:    pshufd {{.*#+}} xmm12 = xmm11[1,1,3,3]
; SSE2-NEXT:    por %xmm0, %xmm12
; SSE2-NEXT:    pcmpeqd %xmm1, %xmm1
; SSE2-NEXT:    movdqa %xmm12, %xmm8
; SSE2-NEXT:    pxor %xmm1, %xmm8
; SSE2-NEXT:    movdqa %xmm3, %xmm11
; SSE2-NEXT:    pxor %xmm10, %xmm11
; SSE2-NEXT:    movdqa %xmm6, %xmm13
; SSE2-NEXT:    pxor %xmm10, %xmm13
; SSE2-NEXT:    movdqa %xmm13, %xmm14
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm14
; SSE2-NEXT:    pshufd {{.*#+}} xmm15 = xmm14[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm11, %xmm13
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm13[1,1,3,3]
; SSE2-NEXT:    pand %xmm15, %xmm11
; SSE2-NEXT:    pshufd {{.*#+}} xmm13 = xmm14[1,1,3,3]
; SSE2-NEXT:    por %xmm11, %xmm13
; SSE2-NEXT:    movdqa %xmm2, %xmm11
; SSE2-NEXT:    pxor %xmm10, %xmm11
; SSE2-NEXT:    movdqa %xmm5, %xmm14
; SSE2-NEXT:    pxor %xmm10, %xmm14
; SSE2-NEXT:    movdqa %xmm14, %xmm15
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm15
; SSE2-NEXT:    pcmpeqd %xmm11, %xmm14
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm15[0,0,2,2]
; SSE2-NEXT:    pshufd {{.*#+}} xmm14 = xmm14[1,1,3,3]
; SSE2-NEXT:    pand %xmm11, %xmm14
; SSE2-NEXT:    pshufd {{.*#+}} xmm15 = xmm15[1,1,3,3]
; SSE2-NEXT:    por %xmm14, %xmm15
; SSE2-NEXT:    movdqa %xmm9, %xmm11
; SSE2-NEXT:    pxor %xmm10, %xmm11
; SSE2-NEXT:    pxor %xmm4, %xmm10
; SSE2-NEXT:    movdqa %xmm10, %xmm14
; SSE2-NEXT:    pcmpgtd %xmm11, %xmm14
; SSE2-NEXT:    pcmpeqd %xmm11, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm11 = xmm14[0,0,2,2]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm10[1,1,3,3]
; SSE2-NEXT:    pand %xmm11, %xmm0
; SSE2-NEXT:    movdqa %xmm13, %xmm10
; SSE2-NEXT:    pxor %xmm1, %xmm10
; SSE2-NEXT:    pshufd {{.*#+}} xmm14 = xmm14[1,1,3,3]
; SSE2-NEXT:    por %xmm0, %xmm14
; SSE2-NEXT:    movdqa %xmm15, %xmm11
; SSE2-NEXT:    pxor %xmm1, %xmm11
; SSE2-NEXT:    pxor %xmm14, %xmm1
; SSE2-NEXT:    pandn %xmm4, %xmm14
; SSE2-NEXT:    pandn %xmm9, %xmm1
; SSE2-NEXT:    por %xmm14, %xmm1
; SSE2-NEXT:    pandn %xmm5, %xmm15
; SSE2-NEXT:    pandn %xmm2, %xmm11
; SSE2-NEXT:    por %xmm15, %xmm11
; SSE2-NEXT:    pandn %xmm6, %xmm13
; SSE2-NEXT:    pandn %xmm3, %xmm10
; SSE2-NEXT:    por %xmm13, %xmm10
; SSE2-NEXT:    pandn -{{[0-9]+}}(%rsp), %xmm12 # 16-byte Folded Reload
; SSE2-NEXT:    pandn %xmm7, %xmm8
; SSE2-NEXT:    por %xmm12, %xmm8
; SSE2-NEXT:    movdqa %xmm1, %xmm0
; SSE2-NEXT:    movdqa %xmm11, %xmm1
; SSE2-NEXT:    movdqa %xmm10, %xmm2
; SSE2-NEXT:    movdqa %xmm8, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test160:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm8
; SSE4-NEXT:    movdqa {{.*#+}} xmm0 = [9223372036854775808,9223372036854775808]
; SSE4-NEXT:    movdqa %xmm3, %xmm10
; SSE4-NEXT:    pxor %xmm0, %xmm10
; SSE4-NEXT:    movdqa %xmm7, %xmm9
; SSE4-NEXT:    pxor %xmm0, %xmm9
; SSE4-NEXT:    pcmpgtq %xmm10, %xmm9
; SSE4-NEXT:    pcmpeqd %xmm12, %xmm12
; SSE4-NEXT:    pxor %xmm12, %xmm9
; SSE4-NEXT:    movdqa %xmm2, %xmm11
; SSE4-NEXT:    pxor %xmm0, %xmm11
; SSE4-NEXT:    movdqa %xmm6, %xmm10
; SSE4-NEXT:    pxor %xmm0, %xmm10
; SSE4-NEXT:    pcmpgtq %xmm11, %xmm10
; SSE4-NEXT:    pxor %xmm12, %xmm10
; SSE4-NEXT:    movdqa %xmm1, %xmm13
; SSE4-NEXT:    pxor %xmm0, %xmm13
; SSE4-NEXT:    movdqa %xmm5, %xmm11
; SSE4-NEXT:    pxor %xmm0, %xmm11
; SSE4-NEXT:    pcmpgtq %xmm13, %xmm11
; SSE4-NEXT:    pxor %xmm12, %xmm11
; SSE4-NEXT:    movdqa %xmm8, %xmm13
; SSE4-NEXT:    pxor %xmm0, %xmm13
; SSE4-NEXT:    pxor %xmm4, %xmm0
; SSE4-NEXT:    pcmpgtq %xmm13, %xmm0
; SSE4-NEXT:    pxor %xmm12, %xmm0
; SSE4-NEXT:    blendvpd %xmm4, %xmm8
; SSE4-NEXT:    movdqa %xmm11, %xmm0
; SSE4-NEXT:    blendvpd %xmm5, %xmm1
; SSE4-NEXT:    movdqa %xmm10, %xmm0
; SSE4-NEXT:    blendvpd %xmm6, %xmm2
; SSE4-NEXT:    movdqa %xmm9, %xmm0
; SSE4-NEXT:    blendvpd %xmm7, %xmm3
; SSE4-NEXT:    movapd %xmm8, %xmm0
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test160:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vmovaps {{.*#+}} xmm5 = [9223372036854775808,9223372036854775808]
; AVX1-NEXT:    vxorps %xmm5, %xmm4, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm6
; AVX1-NEXT:    vxorps %xmm5, %xmm6, %xmm6
; AVX1-NEXT:    vpcmpgtq %xmm4, %xmm6, %xmm4
; AVX1-NEXT:    vpcmpeqd %xmm8, %xmm8, %xmm8
; AVX1-NEXT:    vpxor %xmm8, %xmm4, %xmm4
; AVX1-NEXT:    vxorps %xmm5, %xmm1, %xmm7
; AVX1-NEXT:    vxorps %xmm5, %xmm3, %xmm6
; AVX1-NEXT:    vpcmpgtq %xmm7, %xmm6, %xmm6
; AVX1-NEXT:    vpxor %xmm8, %xmm6, %xmm6
; AVX1-NEXT:    vinsertf128 $1, %xmm4, %ymm6, %ymm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm6
; AVX1-NEXT:    vxorps %xmm5, %xmm6, %xmm6
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm7
; AVX1-NEXT:    vxorps %xmm5, %xmm7, %xmm7
; AVX1-NEXT:    vpcmpgtq %xmm6, %xmm7, %xmm6
; AVX1-NEXT:    vpxor %xmm8, %xmm6, %xmm6
; AVX1-NEXT:    vxorps %xmm5, %xmm0, %xmm7
; AVX1-NEXT:    vxorps %xmm5, %xmm2, %xmm5
; AVX1-NEXT:    vpcmpgtq %xmm7, %xmm5, %xmm5
; AVX1-NEXT:    vpxor %xmm8, %xmm5, %xmm5
; AVX1-NEXT:    vinsertf128 $1, %xmm6, %ymm5, %ymm5
; AVX1-NEXT:    vblendvpd %ymm5, %ymm2, %ymm0, %ymm0
; AVX1-NEXT:    vblendvpd %ymm4, %ymm3, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test160:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpbroadcastq {{.*}}(%rip), %ymm4
; AVX2-NEXT:    vpxor %ymm4, %ymm1, %ymm5
; AVX2-NEXT:    vpxor %ymm4, %ymm3, %ymm6
; AVX2-NEXT:    vpcmpgtq %ymm5, %ymm6, %ymm5
; AVX2-NEXT:    vpcmpeqd %ymm6, %ymm6, %ymm6
; AVX2-NEXT:    vpxor %ymm6, %ymm5, %ymm5
; AVX2-NEXT:    vpxor %ymm4, %ymm0, %ymm7
; AVX2-NEXT:    vpxor %ymm4, %ymm2, %ymm4
; AVX2-NEXT:    vpcmpgtq %ymm7, %ymm4, %ymm4
; AVX2-NEXT:    vpxor %ymm6, %ymm4, %ymm4
; AVX2-NEXT:    vblendvpd %ymm4, %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vblendvpd %ymm5, %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: test160:
; AVX512F:       # BB#0: # %entry
; AVX512F-NEXT:    vpminuq %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    retq
entry:
  %cmp = icmp uge <8 x i64> %a, %b
  %sel = select <8 x i1> %cmp, <8 x i64> %b, <8 x i64> %a
  ret <8 x i64> %sel
}

define <4 x i64> @test161(<4 x i64> %a, <4 x i64> %b) {
; SSE2-LABEL: test161:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm4 = [2147483648,0,2147483648,0]
; SSE2-NEXT:    movdqa %xmm1, %xmm5
; SSE2-NEXT:    pxor %xmm4, %xmm5
; SSE2-NEXT:    movdqa %xmm3, %xmm6
; SSE2-NEXT:    pxor %xmm4, %xmm6
; SSE2-NEXT:    movdqa %xmm6, %xmm7
; SSE2-NEXT:    pcmpgtd %xmm5, %xmm7
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm7[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm5, %xmm6
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm6[1,1,3,3]
; SSE2-NEXT:    pand %xmm8, %xmm5
; SSE2-NEXT:    pshufd {{.*#+}} xmm6 = xmm7[1,1,3,3]
; SSE2-NEXT:    por %xmm5, %xmm6
; SSE2-NEXT:    movdqa %xmm0, %xmm5
; SSE2-NEXT:    pxor %xmm4, %xmm5
; SSE2-NEXT:    pxor %xmm2, %xmm4
; SSE2-NEXT:    movdqa %xmm4, %xmm7
; SSE2-NEXT:    pcmpgtd %xmm5, %xmm7
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm7[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm5, %xmm4
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm4[1,1,3,3]
; SSE2-NEXT:    pand %xmm8, %xmm4
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm7[1,1,3,3]
; SSE2-NEXT:    por %xmm4, %xmm5
; SSE2-NEXT:    pand %xmm5, %xmm0
; SSE2-NEXT:    pandn %xmm2, %xmm5
; SSE2-NEXT:    por %xmm5, %xmm0
; SSE2-NEXT:    pand %xmm6, %xmm1
; SSE2-NEXT:    pandn %xmm3, %xmm6
; SSE2-NEXT:    por %xmm6, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test161:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm4
; SSE4-NEXT:    movdqa %xmm3, %xmm5
; SSE4-NEXT:    pcmpgtq %xmm1, %xmm5
; SSE4-NEXT:    movdqa %xmm2, %xmm0
; SSE4-NEXT:    pcmpgtq %xmm4, %xmm0
; SSE4-NEXT:    blendvpd %xmm4, %xmm2
; SSE4-NEXT:    movdqa %xmm5, %xmm0
; SSE4-NEXT:    blendvpd %xmm1, %xmm3
; SSE4-NEXT:    movapd %xmm2, %xmm0
; SSE4-NEXT:    movapd %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test161:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm3
; AVX1-NEXT:    vpcmpgtq %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpcmpgtq %xmm0, %xmm1, %xmm3
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm3, %ymm2
; AVX1-NEXT:    vblendvpd %ymm2, %ymm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test161:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpcmpgtq %ymm0, %ymm1, %ymm2
; AVX2-NEXT:    vblendvpd %ymm2, %ymm0, %ymm1, %ymm0
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test161:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpminsq %ymm1, %ymm0, %ymm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp slt <4 x i64> %a, %b
  %sel = select <4 x i1> %cmp, <4 x i64> %a, <4 x i64> %b
  ret <4 x i64> %sel
}

define <4 x i64> @test162(<4 x i64> %a, <4 x i64> %b) {
; SSE2-LABEL: test162:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm7 = [2147483648,0,2147483648,0]
; SSE2-NEXT:    movdqa %xmm3, %xmm4
; SSE2-NEXT:    pxor %xmm7, %xmm4
; SSE2-NEXT:    movdqa %xmm1, %xmm5
; SSE2-NEXT:    pxor %xmm7, %xmm5
; SSE2-NEXT:    movdqa %xmm5, %xmm6
; SSE2-NEXT:    pcmpgtd %xmm4, %xmm6
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm6[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm4, %xmm5
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm5[1,1,3,3]
; SSE2-NEXT:    pand %xmm8, %xmm4
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm6[1,1,3,3]
; SSE2-NEXT:    por %xmm4, %xmm8
; SSE2-NEXT:    pcmpeqd %xmm4, %xmm4
; SSE2-NEXT:    movdqa %xmm8, %xmm9
; SSE2-NEXT:    pxor %xmm4, %xmm9
; SSE2-NEXT:    movdqa %xmm2, %xmm6
; SSE2-NEXT:    pxor %xmm7, %xmm6
; SSE2-NEXT:    pxor %xmm0, %xmm7
; SSE2-NEXT:    movdqa %xmm7, %xmm5
; SSE2-NEXT:    pcmpgtd %xmm6, %xmm5
; SSE2-NEXT:    pshufd {{.*#+}} xmm10 = xmm5[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm6, %xmm7
; SSE2-NEXT:    pshufd {{.*#+}} xmm6 = xmm7[1,1,3,3]
; SSE2-NEXT:    pand %xmm10, %xmm6
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm5[1,1,3,3]
; SSE2-NEXT:    por %xmm6, %xmm5
; SSE2-NEXT:    pxor %xmm5, %xmm4
; SSE2-NEXT:    pandn %xmm0, %xmm5
; SSE2-NEXT:    pandn %xmm2, %xmm4
; SSE2-NEXT:    por %xmm5, %xmm4
; SSE2-NEXT:    pandn %xmm1, %xmm8
; SSE2-NEXT:    pandn %xmm3, %xmm9
; SSE2-NEXT:    por %xmm8, %xmm9
; SSE2-NEXT:    movdqa %xmm4, %xmm0
; SSE2-NEXT:    movdqa %xmm9, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test162:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm4
; SSE4-NEXT:    movdqa %xmm1, %xmm5
; SSE4-NEXT:    pcmpgtq %xmm3, %xmm5
; SSE4-NEXT:    pcmpeqd %xmm6, %xmm6
; SSE4-NEXT:    pxor %xmm6, %xmm5
; SSE4-NEXT:    pcmpgtq %xmm2, %xmm0
; SSE4-NEXT:    pxor %xmm6, %xmm0
; SSE4-NEXT:    blendvpd %xmm4, %xmm2
; SSE4-NEXT:    movdqa %xmm5, %xmm0
; SSE4-NEXT:    blendvpd %xmm1, %xmm3
; SSE4-NEXT:    movapd %xmm2, %xmm0
; SSE4-NEXT:    movapd %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test162:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpcmpgtq %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpcmpeqd %xmm3, %xmm3, %xmm3
; AVX1-NEXT:    vpxor %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpcmpgtq %xmm1, %xmm0, %xmm4
; AVX1-NEXT:    vpxor %xmm3, %xmm4, %xmm3
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm3, %ymm2
; AVX1-NEXT:    vblendvpd %ymm2, %ymm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test162:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpcmpgtq %ymm1, %ymm0, %ymm2
; AVX2-NEXT:    vpcmpeqd %ymm3, %ymm3, %ymm3
; AVX2-NEXT:    vpxor %ymm3, %ymm2, %ymm2
; AVX2-NEXT:    vblendvpd %ymm2, %ymm0, %ymm1, %ymm0
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test162:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpminsq %ymm1, %ymm0, %ymm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp sle <4 x i64> %a, %b
  %sel = select <4 x i1> %cmp, <4 x i64> %a, <4 x i64> %b
  ret <4 x i64> %sel
}

define <4 x i64> @test163(<4 x i64> %a, <4 x i64> %b) {
; SSE2-LABEL: test163:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm4 = [2147483648,0,2147483648,0]
; SSE2-NEXT:    movdqa %xmm3, %xmm5
; SSE2-NEXT:    pxor %xmm4, %xmm5
; SSE2-NEXT:    movdqa %xmm1, %xmm6
; SSE2-NEXT:    pxor %xmm4, %xmm6
; SSE2-NEXT:    movdqa %xmm6, %xmm7
; SSE2-NEXT:    pcmpgtd %xmm5, %xmm7
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm7[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm5, %xmm6
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm6[1,1,3,3]
; SSE2-NEXT:    pand %xmm8, %xmm5
; SSE2-NEXT:    pshufd {{.*#+}} xmm6 = xmm7[1,1,3,3]
; SSE2-NEXT:    por %xmm5, %xmm6
; SSE2-NEXT:    movdqa %xmm2, %xmm5
; SSE2-NEXT:    pxor %xmm4, %xmm5
; SSE2-NEXT:    pxor %xmm0, %xmm4
; SSE2-NEXT:    movdqa %xmm4, %xmm7
; SSE2-NEXT:    pcmpgtd %xmm5, %xmm7
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm7[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm5, %xmm4
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm4[1,1,3,3]
; SSE2-NEXT:    pand %xmm8, %xmm4
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm7[1,1,3,3]
; SSE2-NEXT:    por %xmm4, %xmm5
; SSE2-NEXT:    pand %xmm5, %xmm0
; SSE2-NEXT:    pandn %xmm2, %xmm5
; SSE2-NEXT:    por %xmm5, %xmm0
; SSE2-NEXT:    pand %xmm6, %xmm1
; SSE2-NEXT:    pandn %xmm3, %xmm6
; SSE2-NEXT:    por %xmm6, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test163:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm4
; SSE4-NEXT:    movdqa %xmm1, %xmm5
; SSE4-NEXT:    pcmpgtq %xmm3, %xmm5
; SSE4-NEXT:    pcmpgtq %xmm2, %xmm0
; SSE4-NEXT:    blendvpd %xmm4, %xmm2
; SSE4-NEXT:    movdqa %xmm5, %xmm0
; SSE4-NEXT:    blendvpd %xmm1, %xmm3
; SSE4-NEXT:    movapd %xmm2, %xmm0
; SSE4-NEXT:    movapd %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test163:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpcmpgtq %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpcmpgtq %xmm1, %xmm0, %xmm3
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm3, %ymm2
; AVX1-NEXT:    vblendvpd %ymm2, %ymm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test163:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpcmpgtq %ymm1, %ymm0, %ymm2
; AVX2-NEXT:    vblendvpd %ymm2, %ymm0, %ymm1, %ymm0
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test163:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpmaxsq %ymm1, %ymm0, %ymm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp sgt <4 x i64> %a, %b
  %sel = select <4 x i1> %cmp, <4 x i64> %a, <4 x i64> %b
  ret <4 x i64> %sel
}

define <4 x i64> @test164(<4 x i64> %a, <4 x i64> %b) {
; SSE2-LABEL: test164:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm7 = [2147483648,0,2147483648,0]
; SSE2-NEXT:    movdqa %xmm1, %xmm4
; SSE2-NEXT:    pxor %xmm7, %xmm4
; SSE2-NEXT:    movdqa %xmm3, %xmm5
; SSE2-NEXT:    pxor %xmm7, %xmm5
; SSE2-NEXT:    movdqa %xmm5, %xmm6
; SSE2-NEXT:    pcmpgtd %xmm4, %xmm6
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm6[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm4, %xmm5
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm5[1,1,3,3]
; SSE2-NEXT:    pand %xmm8, %xmm4
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm6[1,1,3,3]
; SSE2-NEXT:    por %xmm4, %xmm8
; SSE2-NEXT:    pcmpeqd %xmm4, %xmm4
; SSE2-NEXT:    movdqa %xmm8, %xmm9
; SSE2-NEXT:    pxor %xmm4, %xmm9
; SSE2-NEXT:    movdqa %xmm0, %xmm6
; SSE2-NEXT:    pxor %xmm7, %xmm6
; SSE2-NEXT:    pxor %xmm2, %xmm7
; SSE2-NEXT:    movdqa %xmm7, %xmm5
; SSE2-NEXT:    pcmpgtd %xmm6, %xmm5
; SSE2-NEXT:    pshufd {{.*#+}} xmm10 = xmm5[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm6, %xmm7
; SSE2-NEXT:    pshufd {{.*#+}} xmm6 = xmm7[1,1,3,3]
; SSE2-NEXT:    pand %xmm10, %xmm6
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm5[1,1,3,3]
; SSE2-NEXT:    por %xmm6, %xmm5
; SSE2-NEXT:    pxor %xmm5, %xmm4
; SSE2-NEXT:    pandn %xmm0, %xmm5
; SSE2-NEXT:    pandn %xmm2, %xmm4
; SSE2-NEXT:    por %xmm5, %xmm4
; SSE2-NEXT:    pandn %xmm1, %xmm8
; SSE2-NEXT:    pandn %xmm3, %xmm9
; SSE2-NEXT:    por %xmm8, %xmm9
; SSE2-NEXT:    movdqa %xmm4, %xmm0
; SSE2-NEXT:    movdqa %xmm9, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test164:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm4
; SSE4-NEXT:    movdqa %xmm3, %xmm5
; SSE4-NEXT:    pcmpgtq %xmm1, %xmm5
; SSE4-NEXT:    pcmpeqd %xmm0, %xmm0
; SSE4-NEXT:    pxor %xmm0, %xmm5
; SSE4-NEXT:    movdqa %xmm2, %xmm6
; SSE4-NEXT:    pcmpgtq %xmm4, %xmm6
; SSE4-NEXT:    pxor %xmm6, %xmm0
; SSE4-NEXT:    blendvpd %xmm4, %xmm2
; SSE4-NEXT:    movdqa %xmm5, %xmm0
; SSE4-NEXT:    blendvpd %xmm1, %xmm3
; SSE4-NEXT:    movapd %xmm2, %xmm0
; SSE4-NEXT:    movapd %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test164:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm3
; AVX1-NEXT:    vpcmpgtq %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpcmpeqd %xmm3, %xmm3, %xmm3
; AVX1-NEXT:    vpxor %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpcmpgtq %xmm0, %xmm1, %xmm4
; AVX1-NEXT:    vpxor %xmm3, %xmm4, %xmm3
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm3, %ymm2
; AVX1-NEXT:    vblendvpd %ymm2, %ymm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test164:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpcmpgtq %ymm0, %ymm1, %ymm2
; AVX2-NEXT:    vpcmpeqd %ymm3, %ymm3, %ymm3
; AVX2-NEXT:    vpxor %ymm3, %ymm2, %ymm2
; AVX2-NEXT:    vblendvpd %ymm2, %ymm0, %ymm1, %ymm0
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test164:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpmaxsq %ymm1, %ymm0, %ymm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp sge <4 x i64> %a, %b
  %sel = select <4 x i1> %cmp, <4 x i64> %a, <4 x i64> %b
  ret <4 x i64> %sel
}

define <4 x i64> @test165(<4 x i64> %a, <4 x i64> %b) {
; SSE2-LABEL: test165:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm4 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm1, %xmm5
; SSE2-NEXT:    pxor %xmm4, %xmm5
; SSE2-NEXT:    movdqa %xmm3, %xmm6
; SSE2-NEXT:    pxor %xmm4, %xmm6
; SSE2-NEXT:    movdqa %xmm6, %xmm7
; SSE2-NEXT:    pcmpgtd %xmm5, %xmm7
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm7[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm5, %xmm6
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm6[1,1,3,3]
; SSE2-NEXT:    pand %xmm8, %xmm5
; SSE2-NEXT:    pshufd {{.*#+}} xmm6 = xmm7[1,1,3,3]
; SSE2-NEXT:    por %xmm5, %xmm6
; SSE2-NEXT:    movdqa %xmm0, %xmm5
; SSE2-NEXT:    pxor %xmm4, %xmm5
; SSE2-NEXT:    pxor %xmm2, %xmm4
; SSE2-NEXT:    movdqa %xmm4, %xmm7
; SSE2-NEXT:    pcmpgtd %xmm5, %xmm7
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm7[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm5, %xmm4
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm4[1,1,3,3]
; SSE2-NEXT:    pand %xmm8, %xmm4
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm7[1,1,3,3]
; SSE2-NEXT:    por %xmm4, %xmm5
; SSE2-NEXT:    pand %xmm5, %xmm0
; SSE2-NEXT:    pandn %xmm2, %xmm5
; SSE2-NEXT:    por %xmm5, %xmm0
; SSE2-NEXT:    pand %xmm6, %xmm1
; SSE2-NEXT:    pandn %xmm3, %xmm6
; SSE2-NEXT:    por %xmm6, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test165:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm4
; SSE4-NEXT:    movdqa {{.*#+}} xmm0 = [9223372036854775808,9223372036854775808]
; SSE4-NEXT:    movdqa %xmm1, %xmm6
; SSE4-NEXT:    pxor %xmm0, %xmm6
; SSE4-NEXT:    movdqa %xmm3, %xmm5
; SSE4-NEXT:    pxor %xmm0, %xmm5
; SSE4-NEXT:    pcmpgtq %xmm6, %xmm5
; SSE4-NEXT:    movdqa %xmm4, %xmm6
; SSE4-NEXT:    pxor %xmm0, %xmm6
; SSE4-NEXT:    pxor %xmm2, %xmm0
; SSE4-NEXT:    pcmpgtq %xmm6, %xmm0
; SSE4-NEXT:    blendvpd %xmm4, %xmm2
; SSE4-NEXT:    movdqa %xmm5, %xmm0
; SSE4-NEXT:    blendvpd %xmm1, %xmm3
; SSE4-NEXT:    movapd %xmm2, %xmm0
; SSE4-NEXT:    movapd %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test165:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX1-NEXT:    vmovaps {{.*#+}} xmm3 = [9223372036854775808,9223372036854775808]
; AVX1-NEXT:    vxorps %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vxorps %xmm3, %xmm4, %xmm4
; AVX1-NEXT:    vpcmpgtq %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vxorps %xmm3, %xmm0, %xmm4
; AVX1-NEXT:    vxorps %xmm3, %xmm1, %xmm3
; AVX1-NEXT:    vpcmpgtq %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm3, %ymm2
; AVX1-NEXT:    vblendvpd %ymm2, %ymm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test165:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpbroadcastq {{.*}}(%rip), %ymm2
; AVX2-NEXT:    vpxor %ymm2, %ymm0, %ymm3
; AVX2-NEXT:    vpxor %ymm2, %ymm1, %ymm2
; AVX2-NEXT:    vpcmpgtq %ymm3, %ymm2, %ymm2
; AVX2-NEXT:    vblendvpd %ymm2, %ymm0, %ymm1, %ymm0
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test165:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpminuq %ymm1, %ymm0, %ymm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp ult <4 x i64> %a, %b
  %sel = select <4 x i1> %cmp, <4 x i64> %a, <4 x i64> %b
  ret <4 x i64> %sel
}

define <4 x i64> @test166(<4 x i64> %a, <4 x i64> %b) {
; SSE2-LABEL: test166:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm7 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm3, %xmm4
; SSE2-NEXT:    pxor %xmm7, %xmm4
; SSE2-NEXT:    movdqa %xmm1, %xmm5
; SSE2-NEXT:    pxor %xmm7, %xmm5
; SSE2-NEXT:    movdqa %xmm5, %xmm6
; SSE2-NEXT:    pcmpgtd %xmm4, %xmm6
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm6[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm4, %xmm5
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm5[1,1,3,3]
; SSE2-NEXT:    pand %xmm8, %xmm4
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm6[1,1,3,3]
; SSE2-NEXT:    por %xmm4, %xmm8
; SSE2-NEXT:    pcmpeqd %xmm4, %xmm4
; SSE2-NEXT:    movdqa %xmm8, %xmm9
; SSE2-NEXT:    pxor %xmm4, %xmm9
; SSE2-NEXT:    movdqa %xmm2, %xmm6
; SSE2-NEXT:    pxor %xmm7, %xmm6
; SSE2-NEXT:    pxor %xmm0, %xmm7
; SSE2-NEXT:    movdqa %xmm7, %xmm5
; SSE2-NEXT:    pcmpgtd %xmm6, %xmm5
; SSE2-NEXT:    pshufd {{.*#+}} xmm10 = xmm5[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm6, %xmm7
; SSE2-NEXT:    pshufd {{.*#+}} xmm6 = xmm7[1,1,3,3]
; SSE2-NEXT:    pand %xmm10, %xmm6
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm5[1,1,3,3]
; SSE2-NEXT:    por %xmm6, %xmm5
; SSE2-NEXT:    pxor %xmm5, %xmm4
; SSE2-NEXT:    pandn %xmm0, %xmm5
; SSE2-NEXT:    pandn %xmm2, %xmm4
; SSE2-NEXT:    por %xmm5, %xmm4
; SSE2-NEXT:    pandn %xmm1, %xmm8
; SSE2-NEXT:    pandn %xmm3, %xmm9
; SSE2-NEXT:    por %xmm8, %xmm9
; SSE2-NEXT:    movdqa %xmm4, %xmm0
; SSE2-NEXT:    movdqa %xmm9, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test166:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm4
; SSE4-NEXT:    movdqa {{.*#+}} xmm0 = [9223372036854775808,9223372036854775808]
; SSE4-NEXT:    movdqa %xmm3, %xmm6
; SSE4-NEXT:    pxor %xmm0, %xmm6
; SSE4-NEXT:    movdqa %xmm1, %xmm5
; SSE4-NEXT:    pxor %xmm0, %xmm5
; SSE4-NEXT:    pcmpgtq %xmm6, %xmm5
; SSE4-NEXT:    pcmpeqd %xmm6, %xmm6
; SSE4-NEXT:    pxor %xmm6, %xmm5
; SSE4-NEXT:    movdqa %xmm2, %xmm7
; SSE4-NEXT:    pxor %xmm0, %xmm7
; SSE4-NEXT:    pxor %xmm4, %xmm0
; SSE4-NEXT:    pcmpgtq %xmm7, %xmm0
; SSE4-NEXT:    pxor %xmm6, %xmm0
; SSE4-NEXT:    blendvpd %xmm4, %xmm2
; SSE4-NEXT:    movdqa %xmm5, %xmm0
; SSE4-NEXT:    blendvpd %xmm1, %xmm3
; SSE4-NEXT:    movapd %xmm2, %xmm0
; SSE4-NEXT:    movapd %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test166:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vmovaps {{.*#+}} xmm3 = [9223372036854775808,9223372036854775808]
; AVX1-NEXT:    vxorps %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm4
; AVX1-NEXT:    vxorps %xmm3, %xmm4, %xmm4
; AVX1-NEXT:    vpcmpgtq %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpcmpeqd %xmm4, %xmm4, %xmm4
; AVX1-NEXT:    vpxor %xmm4, %xmm2, %xmm2
; AVX1-NEXT:    vxorps %xmm3, %xmm1, %xmm5
; AVX1-NEXT:    vxorps %xmm3, %xmm0, %xmm3
; AVX1-NEXT:    vpcmpgtq %xmm5, %xmm3, %xmm3
; AVX1-NEXT:    vpxor %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm3, %ymm2
; AVX1-NEXT:    vblendvpd %ymm2, %ymm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test166:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpbroadcastq {{.*}}(%rip), %ymm2
; AVX2-NEXT:    vpxor %ymm2, %ymm1, %ymm3
; AVX2-NEXT:    vpxor %ymm2, %ymm0, %ymm2
; AVX2-NEXT:    vpcmpgtq %ymm3, %ymm2, %ymm2
; AVX2-NEXT:    vpcmpeqd %ymm3, %ymm3, %ymm3
; AVX2-NEXT:    vpxor %ymm3, %ymm2, %ymm2
; AVX2-NEXT:    vblendvpd %ymm2, %ymm0, %ymm1, %ymm0
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test166:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpminuq %ymm1, %ymm0, %ymm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp ule <4 x i64> %a, %b
  %sel = select <4 x i1> %cmp, <4 x i64> %a, <4 x i64> %b
  ret <4 x i64> %sel
}

define <4 x i64> @test167(<4 x i64> %a, <4 x i64> %b) {
; SSE2-LABEL: test167:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm4 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm3, %xmm5
; SSE2-NEXT:    pxor %xmm4, %xmm5
; SSE2-NEXT:    movdqa %xmm1, %xmm6
; SSE2-NEXT:    pxor %xmm4, %xmm6
; SSE2-NEXT:    movdqa %xmm6, %xmm7
; SSE2-NEXT:    pcmpgtd %xmm5, %xmm7
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm7[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm5, %xmm6
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm6[1,1,3,3]
; SSE2-NEXT:    pand %xmm8, %xmm5
; SSE2-NEXT:    pshufd {{.*#+}} xmm6 = xmm7[1,1,3,3]
; SSE2-NEXT:    por %xmm5, %xmm6
; SSE2-NEXT:    movdqa %xmm2, %xmm5
; SSE2-NEXT:    pxor %xmm4, %xmm5
; SSE2-NEXT:    pxor %xmm0, %xmm4
; SSE2-NEXT:    movdqa %xmm4, %xmm7
; SSE2-NEXT:    pcmpgtd %xmm5, %xmm7
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm7[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm5, %xmm4
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm4[1,1,3,3]
; SSE2-NEXT:    pand %xmm8, %xmm4
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm7[1,1,3,3]
; SSE2-NEXT:    por %xmm4, %xmm5
; SSE2-NEXT:    pand %xmm5, %xmm0
; SSE2-NEXT:    pandn %xmm2, %xmm5
; SSE2-NEXT:    por %xmm5, %xmm0
; SSE2-NEXT:    pand %xmm6, %xmm1
; SSE2-NEXT:    pandn %xmm3, %xmm6
; SSE2-NEXT:    por %xmm6, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test167:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm4
; SSE4-NEXT:    movdqa {{.*#+}} xmm0 = [9223372036854775808,9223372036854775808]
; SSE4-NEXT:    movdqa %xmm3, %xmm6
; SSE4-NEXT:    pxor %xmm0, %xmm6
; SSE4-NEXT:    movdqa %xmm1, %xmm5
; SSE4-NEXT:    pxor %xmm0, %xmm5
; SSE4-NEXT:    pcmpgtq %xmm6, %xmm5
; SSE4-NEXT:    movdqa %xmm2, %xmm6
; SSE4-NEXT:    pxor %xmm0, %xmm6
; SSE4-NEXT:    pxor %xmm4, %xmm0
; SSE4-NEXT:    pcmpgtq %xmm6, %xmm0
; SSE4-NEXT:    blendvpd %xmm4, %xmm2
; SSE4-NEXT:    movdqa %xmm5, %xmm0
; SSE4-NEXT:    blendvpd %xmm1, %xmm3
; SSE4-NEXT:    movapd %xmm2, %xmm0
; SSE4-NEXT:    movapd %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test167:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vmovaps {{.*#+}} xmm3 = [9223372036854775808,9223372036854775808]
; AVX1-NEXT:    vxorps %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm4
; AVX1-NEXT:    vxorps %xmm3, %xmm4, %xmm4
; AVX1-NEXT:    vpcmpgtq %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vxorps %xmm3, %xmm1, %xmm4
; AVX1-NEXT:    vxorps %xmm3, %xmm0, %xmm3
; AVX1-NEXT:    vpcmpgtq %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm3, %ymm2
; AVX1-NEXT:    vblendvpd %ymm2, %ymm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test167:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpbroadcastq {{.*}}(%rip), %ymm2
; AVX2-NEXT:    vpxor %ymm2, %ymm1, %ymm3
; AVX2-NEXT:    vpxor %ymm2, %ymm0, %ymm2
; AVX2-NEXT:    vpcmpgtq %ymm3, %ymm2, %ymm2
; AVX2-NEXT:    vblendvpd %ymm2, %ymm0, %ymm1, %ymm0
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test167:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpmaxuq %ymm1, %ymm0, %ymm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp ugt <4 x i64> %a, %b
  %sel = select <4 x i1> %cmp, <4 x i64> %a, <4 x i64> %b
  ret <4 x i64> %sel
}

define <4 x i64> @test168(<4 x i64> %a, <4 x i64> %b) {
; SSE2-LABEL: test168:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm7 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm1, %xmm4
; SSE2-NEXT:    pxor %xmm7, %xmm4
; SSE2-NEXT:    movdqa %xmm3, %xmm5
; SSE2-NEXT:    pxor %xmm7, %xmm5
; SSE2-NEXT:    movdqa %xmm5, %xmm6
; SSE2-NEXT:    pcmpgtd %xmm4, %xmm6
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm6[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm4, %xmm5
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm5[1,1,3,3]
; SSE2-NEXT:    pand %xmm8, %xmm4
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm6[1,1,3,3]
; SSE2-NEXT:    por %xmm4, %xmm8
; SSE2-NEXT:    pcmpeqd %xmm4, %xmm4
; SSE2-NEXT:    movdqa %xmm8, %xmm9
; SSE2-NEXT:    pxor %xmm4, %xmm9
; SSE2-NEXT:    movdqa %xmm0, %xmm6
; SSE2-NEXT:    pxor %xmm7, %xmm6
; SSE2-NEXT:    pxor %xmm2, %xmm7
; SSE2-NEXT:    movdqa %xmm7, %xmm5
; SSE2-NEXT:    pcmpgtd %xmm6, %xmm5
; SSE2-NEXT:    pshufd {{.*#+}} xmm10 = xmm5[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm6, %xmm7
; SSE2-NEXT:    pshufd {{.*#+}} xmm6 = xmm7[1,1,3,3]
; SSE2-NEXT:    pand %xmm10, %xmm6
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm5[1,1,3,3]
; SSE2-NEXT:    por %xmm6, %xmm5
; SSE2-NEXT:    pxor %xmm5, %xmm4
; SSE2-NEXT:    pandn %xmm0, %xmm5
; SSE2-NEXT:    pandn %xmm2, %xmm4
; SSE2-NEXT:    por %xmm5, %xmm4
; SSE2-NEXT:    pandn %xmm1, %xmm8
; SSE2-NEXT:    pandn %xmm3, %xmm9
; SSE2-NEXT:    por %xmm8, %xmm9
; SSE2-NEXT:    movdqa %xmm4, %xmm0
; SSE2-NEXT:    movdqa %xmm9, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test168:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm4
; SSE4-NEXT:    movdqa {{.*#+}} xmm0 = [9223372036854775808,9223372036854775808]
; SSE4-NEXT:    movdqa %xmm1, %xmm6
; SSE4-NEXT:    pxor %xmm0, %xmm6
; SSE4-NEXT:    movdqa %xmm3, %xmm5
; SSE4-NEXT:    pxor %xmm0, %xmm5
; SSE4-NEXT:    pcmpgtq %xmm6, %xmm5
; SSE4-NEXT:    pcmpeqd %xmm6, %xmm6
; SSE4-NEXT:    pxor %xmm6, %xmm5
; SSE4-NEXT:    movdqa %xmm4, %xmm7
; SSE4-NEXT:    pxor %xmm0, %xmm7
; SSE4-NEXT:    pxor %xmm2, %xmm0
; SSE4-NEXT:    pcmpgtq %xmm7, %xmm0
; SSE4-NEXT:    pxor %xmm6, %xmm0
; SSE4-NEXT:    blendvpd %xmm4, %xmm2
; SSE4-NEXT:    movdqa %xmm5, %xmm0
; SSE4-NEXT:    blendvpd %xmm1, %xmm3
; SSE4-NEXT:    movapd %xmm2, %xmm0
; SSE4-NEXT:    movapd %xmm3, %xmm1
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test168:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX1-NEXT:    vmovaps {{.*#+}} xmm3 = [9223372036854775808,9223372036854775808]
; AVX1-NEXT:    vxorps %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vxorps %xmm3, %xmm4, %xmm4
; AVX1-NEXT:    vpcmpgtq %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpcmpeqd %xmm4, %xmm4, %xmm4
; AVX1-NEXT:    vpxor %xmm4, %xmm2, %xmm2
; AVX1-NEXT:    vxorps %xmm3, %xmm0, %xmm5
; AVX1-NEXT:    vxorps %xmm3, %xmm1, %xmm3
; AVX1-NEXT:    vpcmpgtq %xmm5, %xmm3, %xmm3
; AVX1-NEXT:    vpxor %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm3, %ymm2
; AVX1-NEXT:    vblendvpd %ymm2, %ymm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test168:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpbroadcastq {{.*}}(%rip), %ymm2
; AVX2-NEXT:    vpxor %ymm2, %ymm0, %ymm3
; AVX2-NEXT:    vpxor %ymm2, %ymm1, %ymm2
; AVX2-NEXT:    vpcmpgtq %ymm3, %ymm2, %ymm2
; AVX2-NEXT:    vpcmpeqd %ymm3, %ymm3, %ymm3
; AVX2-NEXT:    vpxor %ymm3, %ymm2, %ymm2
; AVX2-NEXT:    vblendvpd %ymm2, %ymm0, %ymm1, %ymm0
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test168:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpmaxuq %ymm1, %ymm0, %ymm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp uge <4 x i64> %a, %b
  %sel = select <4 x i1> %cmp, <4 x i64> %a, <4 x i64> %b
  ret <4 x i64> %sel
}

define <4 x i64> @test169(<4 x i64> %a, <4 x i64> %b) {
; SSE2-LABEL: test169:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm5 = [2147483648,0,2147483648,0]
; SSE2-NEXT:    movdqa %xmm1, %xmm4
; SSE2-NEXT:    pxor %xmm5, %xmm4
; SSE2-NEXT:    movdqa %xmm3, %xmm6
; SSE2-NEXT:    pxor %xmm5, %xmm6
; SSE2-NEXT:    movdqa %xmm6, %xmm7
; SSE2-NEXT:    pcmpgtd %xmm4, %xmm7
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm7[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm4, %xmm6
; SSE2-NEXT:    pshufd {{.*#+}} xmm6 = xmm6[1,1,3,3]
; SSE2-NEXT:    pand %xmm8, %xmm6
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm7[1,1,3,3]
; SSE2-NEXT:    por %xmm6, %xmm4
; SSE2-NEXT:    movdqa %xmm0, %xmm6
; SSE2-NEXT:    pxor %xmm5, %xmm6
; SSE2-NEXT:    pxor %xmm2, %xmm5
; SSE2-NEXT:    movdqa %xmm5, %xmm7
; SSE2-NEXT:    pcmpgtd %xmm6, %xmm7
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm7[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm6, %xmm5
; SSE2-NEXT:    pshufd {{.*#+}} xmm6 = xmm5[1,1,3,3]
; SSE2-NEXT:    pand %xmm8, %xmm6
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm7[1,1,3,3]
; SSE2-NEXT:    por %xmm6, %xmm5
; SSE2-NEXT:    pand %xmm5, %xmm2
; SSE2-NEXT:    pandn %xmm0, %xmm5
; SSE2-NEXT:    por %xmm2, %xmm5
; SSE2-NEXT:    pand %xmm4, %xmm3
; SSE2-NEXT:    pandn %xmm1, %xmm4
; SSE2-NEXT:    por %xmm3, %xmm4
; SSE2-NEXT:    movdqa %xmm5, %xmm0
; SSE2-NEXT:    movdqa %xmm4, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test169:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm4
; SSE4-NEXT:    movdqa %xmm3, %xmm5
; SSE4-NEXT:    pcmpgtq %xmm1, %xmm5
; SSE4-NEXT:    movdqa %xmm2, %xmm0
; SSE4-NEXT:    pcmpgtq %xmm4, %xmm0
; SSE4-NEXT:    blendvpd %xmm2, %xmm4
; SSE4-NEXT:    movdqa %xmm5, %xmm0
; SSE4-NEXT:    blendvpd %xmm3, %xmm1
; SSE4-NEXT:    movapd %xmm4, %xmm0
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test169:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm3
; AVX1-NEXT:    vpcmpgtq %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpcmpgtq %xmm0, %xmm1, %xmm3
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm3, %ymm2
; AVX1-NEXT:    vblendvpd %ymm2, %ymm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test169:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpcmpgtq %ymm0, %ymm1, %ymm2
; AVX2-NEXT:    vblendvpd %ymm2, %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test169:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpmaxsq %ymm1, %ymm0, %ymm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp slt <4 x i64> %a, %b
  %sel = select <4 x i1> %cmp, <4 x i64> %b, <4 x i64> %a
  ret <4 x i64> %sel
}

define <4 x i64> @test170(<4 x i64> %a, <4 x i64> %b) {
; SSE2-LABEL: test170:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm7 = [2147483648,0,2147483648,0]
; SSE2-NEXT:    movdqa %xmm3, %xmm4
; SSE2-NEXT:    pxor %xmm7, %xmm4
; SSE2-NEXT:    movdqa %xmm1, %xmm5
; SSE2-NEXT:    pxor %xmm7, %xmm5
; SSE2-NEXT:    movdqa %xmm5, %xmm6
; SSE2-NEXT:    pcmpgtd %xmm4, %xmm6
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm6[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm4, %xmm5
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm5[1,1,3,3]
; SSE2-NEXT:    pand %xmm8, %xmm4
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm6[1,1,3,3]
; SSE2-NEXT:    por %xmm4, %xmm8
; SSE2-NEXT:    pcmpeqd %xmm4, %xmm4
; SSE2-NEXT:    movdqa %xmm8, %xmm9
; SSE2-NEXT:    pxor %xmm4, %xmm9
; SSE2-NEXT:    movdqa %xmm2, %xmm6
; SSE2-NEXT:    pxor %xmm7, %xmm6
; SSE2-NEXT:    pxor %xmm0, %xmm7
; SSE2-NEXT:    movdqa %xmm7, %xmm5
; SSE2-NEXT:    pcmpgtd %xmm6, %xmm5
; SSE2-NEXT:    pshufd {{.*#+}} xmm10 = xmm5[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm6, %xmm7
; SSE2-NEXT:    pshufd {{.*#+}} xmm6 = xmm7[1,1,3,3]
; SSE2-NEXT:    pand %xmm10, %xmm6
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm5[1,1,3,3]
; SSE2-NEXT:    por %xmm6, %xmm5
; SSE2-NEXT:    pxor %xmm5, %xmm4
; SSE2-NEXT:    pandn %xmm2, %xmm5
; SSE2-NEXT:    pandn %xmm0, %xmm4
; SSE2-NEXT:    por %xmm5, %xmm4
; SSE2-NEXT:    pandn %xmm3, %xmm8
; SSE2-NEXT:    pandn %xmm1, %xmm9
; SSE2-NEXT:    por %xmm8, %xmm9
; SSE2-NEXT:    movdqa %xmm4, %xmm0
; SSE2-NEXT:    movdqa %xmm9, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test170:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm4
; SSE4-NEXT:    movdqa %xmm1, %xmm5
; SSE4-NEXT:    pcmpgtq %xmm3, %xmm5
; SSE4-NEXT:    pcmpeqd %xmm6, %xmm6
; SSE4-NEXT:    pxor %xmm6, %xmm5
; SSE4-NEXT:    pcmpgtq %xmm2, %xmm0
; SSE4-NEXT:    pxor %xmm6, %xmm0
; SSE4-NEXT:    blendvpd %xmm2, %xmm4
; SSE4-NEXT:    movdqa %xmm5, %xmm0
; SSE4-NEXT:    blendvpd %xmm3, %xmm1
; SSE4-NEXT:    movapd %xmm4, %xmm0
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test170:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpcmpgtq %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpcmpeqd %xmm3, %xmm3, %xmm3
; AVX1-NEXT:    vpxor %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpcmpgtq %xmm1, %xmm0, %xmm4
; AVX1-NEXT:    vpxor %xmm3, %xmm4, %xmm3
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm3, %ymm2
; AVX1-NEXT:    vblendvpd %ymm2, %ymm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test170:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpcmpgtq %ymm1, %ymm0, %ymm2
; AVX2-NEXT:    vpcmpeqd %ymm3, %ymm3, %ymm3
; AVX2-NEXT:    vpxor %ymm3, %ymm2, %ymm2
; AVX2-NEXT:    vblendvpd %ymm2, %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test170:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpmaxsq %ymm1, %ymm0, %ymm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp sle <4 x i64> %a, %b
  %sel = select <4 x i1> %cmp, <4 x i64> %b, <4 x i64> %a
  ret <4 x i64> %sel
}

define <4 x i64> @test171(<4 x i64> %a, <4 x i64> %b) {
; SSE2-LABEL: test171:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm5 = [2147483648,0,2147483648,0]
; SSE2-NEXT:    movdqa %xmm3, %xmm4
; SSE2-NEXT:    pxor %xmm5, %xmm4
; SSE2-NEXT:    movdqa %xmm1, %xmm6
; SSE2-NEXT:    pxor %xmm5, %xmm6
; SSE2-NEXT:    movdqa %xmm6, %xmm7
; SSE2-NEXT:    pcmpgtd %xmm4, %xmm7
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm7[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm4, %xmm6
; SSE2-NEXT:    pshufd {{.*#+}} xmm6 = xmm6[1,1,3,3]
; SSE2-NEXT:    pand %xmm8, %xmm6
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm7[1,1,3,3]
; SSE2-NEXT:    por %xmm6, %xmm4
; SSE2-NEXT:    movdqa %xmm2, %xmm6
; SSE2-NEXT:    pxor %xmm5, %xmm6
; SSE2-NEXT:    pxor %xmm0, %xmm5
; SSE2-NEXT:    movdqa %xmm5, %xmm7
; SSE2-NEXT:    pcmpgtd %xmm6, %xmm7
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm7[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm6, %xmm5
; SSE2-NEXT:    pshufd {{.*#+}} xmm6 = xmm5[1,1,3,3]
; SSE2-NEXT:    pand %xmm8, %xmm6
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm7[1,1,3,3]
; SSE2-NEXT:    por %xmm6, %xmm5
; SSE2-NEXT:    pand %xmm5, %xmm2
; SSE2-NEXT:    pandn %xmm0, %xmm5
; SSE2-NEXT:    por %xmm2, %xmm5
; SSE2-NEXT:    pand %xmm4, %xmm3
; SSE2-NEXT:    pandn %xmm1, %xmm4
; SSE2-NEXT:    por %xmm3, %xmm4
; SSE2-NEXT:    movdqa %xmm5, %xmm0
; SSE2-NEXT:    movdqa %xmm4, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test171:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm4
; SSE4-NEXT:    movdqa %xmm1, %xmm5
; SSE4-NEXT:    pcmpgtq %xmm3, %xmm5
; SSE4-NEXT:    pcmpgtq %xmm2, %xmm0
; SSE4-NEXT:    blendvpd %xmm2, %xmm4
; SSE4-NEXT:    movdqa %xmm5, %xmm0
; SSE4-NEXT:    blendvpd %xmm3, %xmm1
; SSE4-NEXT:    movapd %xmm4, %xmm0
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test171:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpcmpgtq %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpcmpgtq %xmm1, %xmm0, %xmm3
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm3, %ymm2
; AVX1-NEXT:    vblendvpd %ymm2, %ymm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test171:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpcmpgtq %ymm1, %ymm0, %ymm2
; AVX2-NEXT:    vblendvpd %ymm2, %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test171:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpminsq %ymm1, %ymm0, %ymm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp sgt <4 x i64> %a, %b
  %sel = select <4 x i1> %cmp, <4 x i64> %b, <4 x i64> %a
  ret <4 x i64> %sel
}

define <4 x i64> @test172(<4 x i64> %a, <4 x i64> %b) {
; SSE2-LABEL: test172:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm7 = [2147483648,0,2147483648,0]
; SSE2-NEXT:    movdqa %xmm1, %xmm4
; SSE2-NEXT:    pxor %xmm7, %xmm4
; SSE2-NEXT:    movdqa %xmm3, %xmm5
; SSE2-NEXT:    pxor %xmm7, %xmm5
; SSE2-NEXT:    movdqa %xmm5, %xmm6
; SSE2-NEXT:    pcmpgtd %xmm4, %xmm6
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm6[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm4, %xmm5
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm5[1,1,3,3]
; SSE2-NEXT:    pand %xmm8, %xmm4
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm6[1,1,3,3]
; SSE2-NEXT:    por %xmm4, %xmm8
; SSE2-NEXT:    pcmpeqd %xmm4, %xmm4
; SSE2-NEXT:    movdqa %xmm8, %xmm9
; SSE2-NEXT:    pxor %xmm4, %xmm9
; SSE2-NEXT:    movdqa %xmm0, %xmm6
; SSE2-NEXT:    pxor %xmm7, %xmm6
; SSE2-NEXT:    pxor %xmm2, %xmm7
; SSE2-NEXT:    movdqa %xmm7, %xmm5
; SSE2-NEXT:    pcmpgtd %xmm6, %xmm5
; SSE2-NEXT:    pshufd {{.*#+}} xmm10 = xmm5[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm6, %xmm7
; SSE2-NEXT:    pshufd {{.*#+}} xmm6 = xmm7[1,1,3,3]
; SSE2-NEXT:    pand %xmm10, %xmm6
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm5[1,1,3,3]
; SSE2-NEXT:    por %xmm6, %xmm5
; SSE2-NEXT:    pxor %xmm5, %xmm4
; SSE2-NEXT:    pandn %xmm2, %xmm5
; SSE2-NEXT:    pandn %xmm0, %xmm4
; SSE2-NEXT:    por %xmm5, %xmm4
; SSE2-NEXT:    pandn %xmm3, %xmm8
; SSE2-NEXT:    pandn %xmm1, %xmm9
; SSE2-NEXT:    por %xmm8, %xmm9
; SSE2-NEXT:    movdqa %xmm4, %xmm0
; SSE2-NEXT:    movdqa %xmm9, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test172:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm4
; SSE4-NEXT:    movdqa %xmm3, %xmm5
; SSE4-NEXT:    pcmpgtq %xmm1, %xmm5
; SSE4-NEXT:    pcmpeqd %xmm0, %xmm0
; SSE4-NEXT:    pxor %xmm0, %xmm5
; SSE4-NEXT:    movdqa %xmm2, %xmm6
; SSE4-NEXT:    pcmpgtq %xmm4, %xmm6
; SSE4-NEXT:    pxor %xmm6, %xmm0
; SSE4-NEXT:    blendvpd %xmm2, %xmm4
; SSE4-NEXT:    movdqa %xmm5, %xmm0
; SSE4-NEXT:    blendvpd %xmm3, %xmm1
; SSE4-NEXT:    movapd %xmm4, %xmm0
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test172:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm3
; AVX1-NEXT:    vpcmpgtq %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpcmpeqd %xmm3, %xmm3, %xmm3
; AVX1-NEXT:    vpxor %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpcmpgtq %xmm0, %xmm1, %xmm4
; AVX1-NEXT:    vpxor %xmm3, %xmm4, %xmm3
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm3, %ymm2
; AVX1-NEXT:    vblendvpd %ymm2, %ymm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test172:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpcmpgtq %ymm0, %ymm1, %ymm2
; AVX2-NEXT:    vpcmpeqd %ymm3, %ymm3, %ymm3
; AVX2-NEXT:    vpxor %ymm3, %ymm2, %ymm2
; AVX2-NEXT:    vblendvpd %ymm2, %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test172:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpminsq %ymm1, %ymm0, %ymm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp sge <4 x i64> %a, %b
  %sel = select <4 x i1> %cmp, <4 x i64> %b, <4 x i64> %a
  ret <4 x i64> %sel
}

define <4 x i64> @test173(<4 x i64> %a, <4 x i64> %b) {
; SSE2-LABEL: test173:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm5 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm1, %xmm4
; SSE2-NEXT:    pxor %xmm5, %xmm4
; SSE2-NEXT:    movdqa %xmm3, %xmm6
; SSE2-NEXT:    pxor %xmm5, %xmm6
; SSE2-NEXT:    movdqa %xmm6, %xmm7
; SSE2-NEXT:    pcmpgtd %xmm4, %xmm7
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm7[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm4, %xmm6
; SSE2-NEXT:    pshufd {{.*#+}} xmm6 = xmm6[1,1,3,3]
; SSE2-NEXT:    pand %xmm8, %xmm6
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm7[1,1,3,3]
; SSE2-NEXT:    por %xmm6, %xmm4
; SSE2-NEXT:    movdqa %xmm0, %xmm6
; SSE2-NEXT:    pxor %xmm5, %xmm6
; SSE2-NEXT:    pxor %xmm2, %xmm5
; SSE2-NEXT:    movdqa %xmm5, %xmm7
; SSE2-NEXT:    pcmpgtd %xmm6, %xmm7
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm7[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm6, %xmm5
; SSE2-NEXT:    pshufd {{.*#+}} xmm6 = xmm5[1,1,3,3]
; SSE2-NEXT:    pand %xmm8, %xmm6
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm7[1,1,3,3]
; SSE2-NEXT:    por %xmm6, %xmm5
; SSE2-NEXT:    pand %xmm5, %xmm2
; SSE2-NEXT:    pandn %xmm0, %xmm5
; SSE2-NEXT:    por %xmm2, %xmm5
; SSE2-NEXT:    pand %xmm4, %xmm3
; SSE2-NEXT:    pandn %xmm1, %xmm4
; SSE2-NEXT:    por %xmm3, %xmm4
; SSE2-NEXT:    movdqa %xmm5, %xmm0
; SSE2-NEXT:    movdqa %xmm4, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test173:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm4
; SSE4-NEXT:    movdqa {{.*#+}} xmm0 = [9223372036854775808,9223372036854775808]
; SSE4-NEXT:    movdqa %xmm1, %xmm6
; SSE4-NEXT:    pxor %xmm0, %xmm6
; SSE4-NEXT:    movdqa %xmm3, %xmm5
; SSE4-NEXT:    pxor %xmm0, %xmm5
; SSE4-NEXT:    pcmpgtq %xmm6, %xmm5
; SSE4-NEXT:    movdqa %xmm4, %xmm6
; SSE4-NEXT:    pxor %xmm0, %xmm6
; SSE4-NEXT:    pxor %xmm2, %xmm0
; SSE4-NEXT:    pcmpgtq %xmm6, %xmm0
; SSE4-NEXT:    blendvpd %xmm2, %xmm4
; SSE4-NEXT:    movdqa %xmm5, %xmm0
; SSE4-NEXT:    blendvpd %xmm3, %xmm1
; SSE4-NEXT:    movapd %xmm4, %xmm0
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test173:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX1-NEXT:    vmovaps {{.*#+}} xmm3 = [9223372036854775808,9223372036854775808]
; AVX1-NEXT:    vxorps %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vxorps %xmm3, %xmm4, %xmm4
; AVX1-NEXT:    vpcmpgtq %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vxorps %xmm3, %xmm0, %xmm4
; AVX1-NEXT:    vxorps %xmm3, %xmm1, %xmm3
; AVX1-NEXT:    vpcmpgtq %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm3, %ymm2
; AVX1-NEXT:    vblendvpd %ymm2, %ymm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test173:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpbroadcastq {{.*}}(%rip), %ymm2
; AVX2-NEXT:    vpxor %ymm2, %ymm0, %ymm3
; AVX2-NEXT:    vpxor %ymm2, %ymm1, %ymm2
; AVX2-NEXT:    vpcmpgtq %ymm3, %ymm2, %ymm2
; AVX2-NEXT:    vblendvpd %ymm2, %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test173:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpmaxuq %ymm1, %ymm0, %ymm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp ult <4 x i64> %a, %b
  %sel = select <4 x i1> %cmp, <4 x i64> %b, <4 x i64> %a
  ret <4 x i64> %sel
}

define <4 x i64> @test174(<4 x i64> %a, <4 x i64> %b) {
; SSE2-LABEL: test174:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm7 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm3, %xmm4
; SSE2-NEXT:    pxor %xmm7, %xmm4
; SSE2-NEXT:    movdqa %xmm1, %xmm5
; SSE2-NEXT:    pxor %xmm7, %xmm5
; SSE2-NEXT:    movdqa %xmm5, %xmm6
; SSE2-NEXT:    pcmpgtd %xmm4, %xmm6
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm6[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm4, %xmm5
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm5[1,1,3,3]
; SSE2-NEXT:    pand %xmm8, %xmm4
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm6[1,1,3,3]
; SSE2-NEXT:    por %xmm4, %xmm8
; SSE2-NEXT:    pcmpeqd %xmm4, %xmm4
; SSE2-NEXT:    movdqa %xmm8, %xmm9
; SSE2-NEXT:    pxor %xmm4, %xmm9
; SSE2-NEXT:    movdqa %xmm2, %xmm6
; SSE2-NEXT:    pxor %xmm7, %xmm6
; SSE2-NEXT:    pxor %xmm0, %xmm7
; SSE2-NEXT:    movdqa %xmm7, %xmm5
; SSE2-NEXT:    pcmpgtd %xmm6, %xmm5
; SSE2-NEXT:    pshufd {{.*#+}} xmm10 = xmm5[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm6, %xmm7
; SSE2-NEXT:    pshufd {{.*#+}} xmm6 = xmm7[1,1,3,3]
; SSE2-NEXT:    pand %xmm10, %xmm6
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm5[1,1,3,3]
; SSE2-NEXT:    por %xmm6, %xmm5
; SSE2-NEXT:    pxor %xmm5, %xmm4
; SSE2-NEXT:    pandn %xmm2, %xmm5
; SSE2-NEXT:    pandn %xmm0, %xmm4
; SSE2-NEXT:    por %xmm5, %xmm4
; SSE2-NEXT:    pandn %xmm3, %xmm8
; SSE2-NEXT:    pandn %xmm1, %xmm9
; SSE2-NEXT:    por %xmm8, %xmm9
; SSE2-NEXT:    movdqa %xmm4, %xmm0
; SSE2-NEXT:    movdqa %xmm9, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test174:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm4
; SSE4-NEXT:    movdqa {{.*#+}} xmm0 = [9223372036854775808,9223372036854775808]
; SSE4-NEXT:    movdqa %xmm3, %xmm6
; SSE4-NEXT:    pxor %xmm0, %xmm6
; SSE4-NEXT:    movdqa %xmm1, %xmm5
; SSE4-NEXT:    pxor %xmm0, %xmm5
; SSE4-NEXT:    pcmpgtq %xmm6, %xmm5
; SSE4-NEXT:    pcmpeqd %xmm6, %xmm6
; SSE4-NEXT:    pxor %xmm6, %xmm5
; SSE4-NEXT:    movdqa %xmm2, %xmm7
; SSE4-NEXT:    pxor %xmm0, %xmm7
; SSE4-NEXT:    pxor %xmm4, %xmm0
; SSE4-NEXT:    pcmpgtq %xmm7, %xmm0
; SSE4-NEXT:    pxor %xmm6, %xmm0
; SSE4-NEXT:    blendvpd %xmm2, %xmm4
; SSE4-NEXT:    movdqa %xmm5, %xmm0
; SSE4-NEXT:    blendvpd %xmm3, %xmm1
; SSE4-NEXT:    movapd %xmm4, %xmm0
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test174:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vmovaps {{.*#+}} xmm3 = [9223372036854775808,9223372036854775808]
; AVX1-NEXT:    vxorps %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm4
; AVX1-NEXT:    vxorps %xmm3, %xmm4, %xmm4
; AVX1-NEXT:    vpcmpgtq %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpcmpeqd %xmm4, %xmm4, %xmm4
; AVX1-NEXT:    vpxor %xmm4, %xmm2, %xmm2
; AVX1-NEXT:    vxorps %xmm3, %xmm1, %xmm5
; AVX1-NEXT:    vxorps %xmm3, %xmm0, %xmm3
; AVX1-NEXT:    vpcmpgtq %xmm5, %xmm3, %xmm3
; AVX1-NEXT:    vpxor %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm3, %ymm2
; AVX1-NEXT:    vblendvpd %ymm2, %ymm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test174:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpbroadcastq {{.*}}(%rip), %ymm2
; AVX2-NEXT:    vpxor %ymm2, %ymm1, %ymm3
; AVX2-NEXT:    vpxor %ymm2, %ymm0, %ymm2
; AVX2-NEXT:    vpcmpgtq %ymm3, %ymm2, %ymm2
; AVX2-NEXT:    vpcmpeqd %ymm3, %ymm3, %ymm3
; AVX2-NEXT:    vpxor %ymm3, %ymm2, %ymm2
; AVX2-NEXT:    vblendvpd %ymm2, %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test174:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpmaxuq %ymm1, %ymm0, %ymm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp ule <4 x i64> %a, %b
  %sel = select <4 x i1> %cmp, <4 x i64> %b, <4 x i64> %a
  ret <4 x i64> %sel
}

define <4 x i64> @test175(<4 x i64> %a, <4 x i64> %b) {
; SSE2-LABEL: test175:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm5 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm3, %xmm4
; SSE2-NEXT:    pxor %xmm5, %xmm4
; SSE2-NEXT:    movdqa %xmm1, %xmm6
; SSE2-NEXT:    pxor %xmm5, %xmm6
; SSE2-NEXT:    movdqa %xmm6, %xmm7
; SSE2-NEXT:    pcmpgtd %xmm4, %xmm7
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm7[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm4, %xmm6
; SSE2-NEXT:    pshufd {{.*#+}} xmm6 = xmm6[1,1,3,3]
; SSE2-NEXT:    pand %xmm8, %xmm6
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm7[1,1,3,3]
; SSE2-NEXT:    por %xmm6, %xmm4
; SSE2-NEXT:    movdqa %xmm2, %xmm6
; SSE2-NEXT:    pxor %xmm5, %xmm6
; SSE2-NEXT:    pxor %xmm0, %xmm5
; SSE2-NEXT:    movdqa %xmm5, %xmm7
; SSE2-NEXT:    pcmpgtd %xmm6, %xmm7
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm7[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm6, %xmm5
; SSE2-NEXT:    pshufd {{.*#+}} xmm6 = xmm5[1,1,3,3]
; SSE2-NEXT:    pand %xmm8, %xmm6
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm7[1,1,3,3]
; SSE2-NEXT:    por %xmm6, %xmm5
; SSE2-NEXT:    pand %xmm5, %xmm2
; SSE2-NEXT:    pandn %xmm0, %xmm5
; SSE2-NEXT:    por %xmm2, %xmm5
; SSE2-NEXT:    pand %xmm4, %xmm3
; SSE2-NEXT:    pandn %xmm1, %xmm4
; SSE2-NEXT:    por %xmm3, %xmm4
; SSE2-NEXT:    movdqa %xmm5, %xmm0
; SSE2-NEXT:    movdqa %xmm4, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test175:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm4
; SSE4-NEXT:    movdqa {{.*#+}} xmm0 = [9223372036854775808,9223372036854775808]
; SSE4-NEXT:    movdqa %xmm3, %xmm6
; SSE4-NEXT:    pxor %xmm0, %xmm6
; SSE4-NEXT:    movdqa %xmm1, %xmm5
; SSE4-NEXT:    pxor %xmm0, %xmm5
; SSE4-NEXT:    pcmpgtq %xmm6, %xmm5
; SSE4-NEXT:    movdqa %xmm2, %xmm6
; SSE4-NEXT:    pxor %xmm0, %xmm6
; SSE4-NEXT:    pxor %xmm4, %xmm0
; SSE4-NEXT:    pcmpgtq %xmm6, %xmm0
; SSE4-NEXT:    blendvpd %xmm2, %xmm4
; SSE4-NEXT:    movdqa %xmm5, %xmm0
; SSE4-NEXT:    blendvpd %xmm3, %xmm1
; SSE4-NEXT:    movapd %xmm4, %xmm0
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test175:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vmovaps {{.*#+}} xmm3 = [9223372036854775808,9223372036854775808]
; AVX1-NEXT:    vxorps %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm4
; AVX1-NEXT:    vxorps %xmm3, %xmm4, %xmm4
; AVX1-NEXT:    vpcmpgtq %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vxorps %xmm3, %xmm1, %xmm4
; AVX1-NEXT:    vxorps %xmm3, %xmm0, %xmm3
; AVX1-NEXT:    vpcmpgtq %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm3, %ymm2
; AVX1-NEXT:    vblendvpd %ymm2, %ymm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test175:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpbroadcastq {{.*}}(%rip), %ymm2
; AVX2-NEXT:    vpxor %ymm2, %ymm1, %ymm3
; AVX2-NEXT:    vpxor %ymm2, %ymm0, %ymm2
; AVX2-NEXT:    vpcmpgtq %ymm3, %ymm2, %ymm2
; AVX2-NEXT:    vblendvpd %ymm2, %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test175:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpminuq %ymm1, %ymm0, %ymm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp ugt <4 x i64> %a, %b
  %sel = select <4 x i1> %cmp, <4 x i64> %b, <4 x i64> %a
  ret <4 x i64> %sel
}

define <4 x i64> @test176(<4 x i64> %a, <4 x i64> %b) {
; SSE2-LABEL: test176:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm7 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm1, %xmm4
; SSE2-NEXT:    pxor %xmm7, %xmm4
; SSE2-NEXT:    movdqa %xmm3, %xmm5
; SSE2-NEXT:    pxor %xmm7, %xmm5
; SSE2-NEXT:    movdqa %xmm5, %xmm6
; SSE2-NEXT:    pcmpgtd %xmm4, %xmm6
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm6[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm4, %xmm5
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm5[1,1,3,3]
; SSE2-NEXT:    pand %xmm8, %xmm4
; SSE2-NEXT:    pshufd {{.*#+}} xmm8 = xmm6[1,1,3,3]
; SSE2-NEXT:    por %xmm4, %xmm8
; SSE2-NEXT:    pcmpeqd %xmm4, %xmm4
; SSE2-NEXT:    movdqa %xmm8, %xmm9
; SSE2-NEXT:    pxor %xmm4, %xmm9
; SSE2-NEXT:    movdqa %xmm0, %xmm6
; SSE2-NEXT:    pxor %xmm7, %xmm6
; SSE2-NEXT:    pxor %xmm2, %xmm7
; SSE2-NEXT:    movdqa %xmm7, %xmm5
; SSE2-NEXT:    pcmpgtd %xmm6, %xmm5
; SSE2-NEXT:    pshufd {{.*#+}} xmm10 = xmm5[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm6, %xmm7
; SSE2-NEXT:    pshufd {{.*#+}} xmm6 = xmm7[1,1,3,3]
; SSE2-NEXT:    pand %xmm10, %xmm6
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm5[1,1,3,3]
; SSE2-NEXT:    por %xmm6, %xmm5
; SSE2-NEXT:    pxor %xmm5, %xmm4
; SSE2-NEXT:    pandn %xmm2, %xmm5
; SSE2-NEXT:    pandn %xmm0, %xmm4
; SSE2-NEXT:    por %xmm5, %xmm4
; SSE2-NEXT:    pandn %xmm3, %xmm8
; SSE2-NEXT:    pandn %xmm1, %xmm9
; SSE2-NEXT:    por %xmm8, %xmm9
; SSE2-NEXT:    movdqa %xmm4, %xmm0
; SSE2-NEXT:    movdqa %xmm9, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test176:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm4
; SSE4-NEXT:    movdqa {{.*#+}} xmm0 = [9223372036854775808,9223372036854775808]
; SSE4-NEXT:    movdqa %xmm1, %xmm6
; SSE4-NEXT:    pxor %xmm0, %xmm6
; SSE4-NEXT:    movdqa %xmm3, %xmm5
; SSE4-NEXT:    pxor %xmm0, %xmm5
; SSE4-NEXT:    pcmpgtq %xmm6, %xmm5
; SSE4-NEXT:    pcmpeqd %xmm6, %xmm6
; SSE4-NEXT:    pxor %xmm6, %xmm5
; SSE4-NEXT:    movdqa %xmm4, %xmm7
; SSE4-NEXT:    pxor %xmm0, %xmm7
; SSE4-NEXT:    pxor %xmm2, %xmm0
; SSE4-NEXT:    pcmpgtq %xmm7, %xmm0
; SSE4-NEXT:    pxor %xmm6, %xmm0
; SSE4-NEXT:    blendvpd %xmm2, %xmm4
; SSE4-NEXT:    movdqa %xmm5, %xmm0
; SSE4-NEXT:    blendvpd %xmm3, %xmm1
; SSE4-NEXT:    movapd %xmm4, %xmm0
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test176:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX1-NEXT:    vmovaps {{.*#+}} xmm3 = [9223372036854775808,9223372036854775808]
; AVX1-NEXT:    vxorps %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm4
; AVX1-NEXT:    vxorps %xmm3, %xmm4, %xmm4
; AVX1-NEXT:    vpcmpgtq %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpcmpeqd %xmm4, %xmm4, %xmm4
; AVX1-NEXT:    vpxor %xmm4, %xmm2, %xmm2
; AVX1-NEXT:    vxorps %xmm3, %xmm0, %xmm5
; AVX1-NEXT:    vxorps %xmm3, %xmm1, %xmm3
; AVX1-NEXT:    vpcmpgtq %xmm5, %xmm3, %xmm3
; AVX1-NEXT:    vpxor %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm3, %ymm2
; AVX1-NEXT:    vblendvpd %ymm2, %ymm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test176:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpbroadcastq {{.*}}(%rip), %ymm2
; AVX2-NEXT:    vpxor %ymm2, %ymm0, %ymm3
; AVX2-NEXT:    vpxor %ymm2, %ymm1, %ymm2
; AVX2-NEXT:    vpcmpgtq %ymm3, %ymm2, %ymm2
; AVX2-NEXT:    vpcmpeqd %ymm3, %ymm3, %ymm3
; AVX2-NEXT:    vpxor %ymm3, %ymm2, %ymm2
; AVX2-NEXT:    vblendvpd %ymm2, %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test176:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpminuq %ymm1, %ymm0, %ymm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp uge <4 x i64> %a, %b
  %sel = select <4 x i1> %cmp, <4 x i64> %b, <4 x i64> %a
  ret <4 x i64> %sel
}

define <2 x i64> @test177(<2 x i64> %a, <2 x i64> %b) {
; SSE2-LABEL: test177:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [2147483648,0,2147483648,0]
; SSE2-NEXT:    movdqa %xmm0, %xmm3
; SSE2-NEXT:    pxor %xmm2, %xmm3
; SSE2-NEXT:    pxor %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm4
; SSE2-NEXT:    pcmpgtd %xmm3, %xmm4
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm4[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm3, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm2[1,1,3,3]
; SSE2-NEXT:    pand %xmm5, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm3 = xmm4[1,1,3,3]
; SSE2-NEXT:    por %xmm2, %xmm3
; SSE2-NEXT:    pand %xmm3, %xmm0
; SSE2-NEXT:    pandn %xmm1, %xmm3
; SSE2-NEXT:    por %xmm3, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test177:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm2
; SSE4-NEXT:    movdqa %xmm1, %xmm0
; SSE4-NEXT:    pcmpgtq %xmm2, %xmm0
; SSE4-NEXT:    blendvpd %xmm2, %xmm1
; SSE4-NEXT:    movapd %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test177:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vpcmpgtq %xmm0, %xmm1, %xmm2
; AVX1-NEXT:    vblendvpd %xmm2, %xmm0, %xmm1, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test177:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpcmpgtq %xmm0, %xmm1, %xmm2
; AVX2-NEXT:    vblendvpd %xmm2, %xmm0, %xmm1, %xmm0
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test177:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpminsq %xmm1, %xmm0, %xmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp slt <2 x i64> %a, %b
  %sel = select <2 x i1> %cmp, <2 x i64> %a, <2 x i64> %b
  ret <2 x i64> %sel
}

define <2 x i64> @test178(<2 x i64> %a, <2 x i64> %b) {
; SSE2-LABEL: test178:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [2147483648,0,2147483648,0]
; SSE2-NEXT:    movdqa %xmm1, %xmm3
; SSE2-NEXT:    pxor %xmm2, %xmm3
; SSE2-NEXT:    pxor %xmm0, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm4
; SSE2-NEXT:    pcmpgtd %xmm3, %xmm4
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm4[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm3, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm2[1,1,3,3]
; SSE2-NEXT:    pand %xmm5, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm3 = xmm4[1,1,3,3]
; SSE2-NEXT:    por %xmm2, %xmm3
; SSE2-NEXT:    pcmpeqd %xmm2, %xmm2
; SSE2-NEXT:    pxor %xmm3, %xmm2
; SSE2-NEXT:    pandn %xmm0, %xmm3
; SSE2-NEXT:    pandn %xmm1, %xmm2
; SSE2-NEXT:    por %xmm3, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test178:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm2
; SSE4-NEXT:    pcmpgtq %xmm1, %xmm0
; SSE4-NEXT:    pcmpeqd %xmm3, %xmm3
; SSE4-NEXT:    pxor %xmm3, %xmm0
; SSE4-NEXT:    blendvpd %xmm2, %xmm1
; SSE4-NEXT:    movapd %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test178:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vpcmpgtq %xmm1, %xmm0, %xmm2
; AVX1-NEXT:    vpcmpeqd %xmm3, %xmm3, %xmm3
; AVX1-NEXT:    vpxor %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vblendvpd %xmm2, %xmm0, %xmm1, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test178:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpcmpgtq %xmm1, %xmm0, %xmm2
; AVX2-NEXT:    vpcmpeqd %xmm3, %xmm3, %xmm3
; AVX2-NEXT:    vpxor %xmm3, %xmm2, %xmm2
; AVX2-NEXT:    vblendvpd %xmm2, %xmm0, %xmm1, %xmm0
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test178:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpminsq %xmm1, %xmm0, %xmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp sle <2 x i64> %a, %b
  %sel = select <2 x i1> %cmp, <2 x i64> %a, <2 x i64> %b
  ret <2 x i64> %sel
}

define <2 x i64> @test179(<2 x i64> %a, <2 x i64> %b) {
; SSE2-LABEL: test179:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [2147483648,0,2147483648,0]
; SSE2-NEXT:    movdqa %xmm1, %xmm3
; SSE2-NEXT:    pxor %xmm2, %xmm3
; SSE2-NEXT:    pxor %xmm0, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm4
; SSE2-NEXT:    pcmpgtd %xmm3, %xmm4
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm4[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm3, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm2[1,1,3,3]
; SSE2-NEXT:    pand %xmm5, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm3 = xmm4[1,1,3,3]
; SSE2-NEXT:    por %xmm2, %xmm3
; SSE2-NEXT:    pand %xmm3, %xmm0
; SSE2-NEXT:    pandn %xmm1, %xmm3
; SSE2-NEXT:    por %xmm3, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test179:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm2
; SSE4-NEXT:    pcmpgtq %xmm1, %xmm0
; SSE4-NEXT:    blendvpd %xmm2, %xmm1
; SSE4-NEXT:    movapd %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test179:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vpcmpgtq %xmm1, %xmm0, %xmm2
; AVX1-NEXT:    vblendvpd %xmm2, %xmm0, %xmm1, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test179:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpcmpgtq %xmm1, %xmm0, %xmm2
; AVX2-NEXT:    vblendvpd %xmm2, %xmm0, %xmm1, %xmm0
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test179:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpmaxsq %xmm1, %xmm0, %xmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp sgt <2 x i64> %a, %b
  %sel = select <2 x i1> %cmp, <2 x i64> %a, <2 x i64> %b
  ret <2 x i64> %sel
}

define <2 x i64> @test180(<2 x i64> %a, <2 x i64> %b) {
; SSE2-LABEL: test180:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [2147483648,0,2147483648,0]
; SSE2-NEXT:    movdqa %xmm0, %xmm3
; SSE2-NEXT:    pxor %xmm2, %xmm3
; SSE2-NEXT:    pxor %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm4
; SSE2-NEXT:    pcmpgtd %xmm3, %xmm4
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm4[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm3, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm2[1,1,3,3]
; SSE2-NEXT:    pand %xmm5, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm3 = xmm4[1,1,3,3]
; SSE2-NEXT:    por %xmm2, %xmm3
; SSE2-NEXT:    pcmpeqd %xmm2, %xmm2
; SSE2-NEXT:    pxor %xmm3, %xmm2
; SSE2-NEXT:    pandn %xmm0, %xmm3
; SSE2-NEXT:    pandn %xmm1, %xmm2
; SSE2-NEXT:    por %xmm3, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test180:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm2
; SSE4-NEXT:    movdqa %xmm1, %xmm3
; SSE4-NEXT:    pcmpgtq %xmm2, %xmm3
; SSE4-NEXT:    pcmpeqd %xmm0, %xmm0
; SSE4-NEXT:    pxor %xmm3, %xmm0
; SSE4-NEXT:    blendvpd %xmm2, %xmm1
; SSE4-NEXT:    movapd %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test180:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vpcmpgtq %xmm0, %xmm1, %xmm2
; AVX1-NEXT:    vpcmpeqd %xmm3, %xmm3, %xmm3
; AVX1-NEXT:    vpxor %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vblendvpd %xmm2, %xmm0, %xmm1, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test180:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpcmpgtq %xmm0, %xmm1, %xmm2
; AVX2-NEXT:    vpcmpeqd %xmm3, %xmm3, %xmm3
; AVX2-NEXT:    vpxor %xmm3, %xmm2, %xmm2
; AVX2-NEXT:    vblendvpd %xmm2, %xmm0, %xmm1, %xmm0
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test180:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpmaxsq %xmm1, %xmm0, %xmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp sge <2 x i64> %a, %b
  %sel = select <2 x i1> %cmp, <2 x i64> %a, <2 x i64> %b
  ret <2 x i64> %sel
}

define <2 x i64> @test181(<2 x i64> %a, <2 x i64> %b) {
; SSE2-LABEL: test181:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm0, %xmm3
; SSE2-NEXT:    pxor %xmm2, %xmm3
; SSE2-NEXT:    pxor %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm4
; SSE2-NEXT:    pcmpgtd %xmm3, %xmm4
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm4[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm3, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm2[1,1,3,3]
; SSE2-NEXT:    pand %xmm5, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm3 = xmm4[1,1,3,3]
; SSE2-NEXT:    por %xmm2, %xmm3
; SSE2-NEXT:    pand %xmm3, %xmm0
; SSE2-NEXT:    pandn %xmm1, %xmm3
; SSE2-NEXT:    por %xmm3, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test181:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm2
; SSE4-NEXT:    movdqa {{.*#+}} xmm0 = [9223372036854775808,9223372036854775808]
; SSE4-NEXT:    movdqa %xmm2, %xmm3
; SSE4-NEXT:    pxor %xmm0, %xmm3
; SSE4-NEXT:    pxor %xmm1, %xmm0
; SSE4-NEXT:    pcmpgtq %xmm3, %xmm0
; SSE4-NEXT:    blendvpd %xmm2, %xmm1
; SSE4-NEXT:    movapd %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test181:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm2 = [9223372036854775808,9223372036854775808]
; AVX1-NEXT:    vpxor %xmm2, %xmm0, %xmm3
; AVX1-NEXT:    vpxor %xmm2, %xmm1, %xmm2
; AVX1-NEXT:    vpcmpgtq %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vblendvpd %xmm2, %xmm0, %xmm1, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test181:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vmovdqa {{.*#+}} xmm2 = [9223372036854775808,9223372036854775808]
; AVX2-NEXT:    vpxor %xmm2, %xmm0, %xmm3
; AVX2-NEXT:    vpxor %xmm2, %xmm1, %xmm2
; AVX2-NEXT:    vpcmpgtq %xmm3, %xmm2, %xmm2
; AVX2-NEXT:    vblendvpd %xmm2, %xmm0, %xmm1, %xmm0
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test181:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpminuq %xmm1, %xmm0, %xmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp ult <2 x i64> %a, %b
  %sel = select <2 x i1> %cmp, <2 x i64> %a, <2 x i64> %b
  ret <2 x i64> %sel
}

define <2 x i64> @test182(<2 x i64> %a, <2 x i64> %b) {
; SSE2-LABEL: test182:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm1, %xmm3
; SSE2-NEXT:    pxor %xmm2, %xmm3
; SSE2-NEXT:    pxor %xmm0, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm4
; SSE2-NEXT:    pcmpgtd %xmm3, %xmm4
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm4[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm3, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm2[1,1,3,3]
; SSE2-NEXT:    pand %xmm5, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm3 = xmm4[1,1,3,3]
; SSE2-NEXT:    por %xmm2, %xmm3
; SSE2-NEXT:    pcmpeqd %xmm2, %xmm2
; SSE2-NEXT:    pxor %xmm3, %xmm2
; SSE2-NEXT:    pandn %xmm0, %xmm3
; SSE2-NEXT:    pandn %xmm1, %xmm2
; SSE2-NEXT:    por %xmm3, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test182:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm2
; SSE4-NEXT:    movdqa {{.*#+}} xmm3 = [9223372036854775808,9223372036854775808]
; SSE4-NEXT:    movdqa %xmm1, %xmm0
; SSE4-NEXT:    pxor %xmm3, %xmm0
; SSE4-NEXT:    pxor %xmm2, %xmm3
; SSE4-NEXT:    pcmpgtq %xmm0, %xmm3
; SSE4-NEXT:    pcmpeqd %xmm0, %xmm0
; SSE4-NEXT:    pxor %xmm3, %xmm0
; SSE4-NEXT:    blendvpd %xmm2, %xmm1
; SSE4-NEXT:    movapd %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test182:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm2 = [9223372036854775808,9223372036854775808]
; AVX1-NEXT:    vpxor %xmm2, %xmm1, %xmm3
; AVX1-NEXT:    vpxor %xmm2, %xmm0, %xmm2
; AVX1-NEXT:    vpcmpgtq %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpcmpeqd %xmm3, %xmm3, %xmm3
; AVX1-NEXT:    vpxor %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vblendvpd %xmm2, %xmm0, %xmm1, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test182:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vmovdqa {{.*#+}} xmm2 = [9223372036854775808,9223372036854775808]
; AVX2-NEXT:    vpxor %xmm2, %xmm1, %xmm3
; AVX2-NEXT:    vpxor %xmm2, %xmm0, %xmm2
; AVX2-NEXT:    vpcmpgtq %xmm3, %xmm2, %xmm2
; AVX2-NEXT:    vpcmpeqd %xmm3, %xmm3, %xmm3
; AVX2-NEXT:    vpxor %xmm3, %xmm2, %xmm2
; AVX2-NEXT:    vblendvpd %xmm2, %xmm0, %xmm1, %xmm0
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test182:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpminuq %xmm1, %xmm0, %xmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp ule <2 x i64> %a, %b
  %sel = select <2 x i1> %cmp, <2 x i64> %a, <2 x i64> %b
  ret <2 x i64> %sel
}

define <2 x i64> @test183(<2 x i64> %a, <2 x i64> %b) {
; SSE2-LABEL: test183:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm1, %xmm3
; SSE2-NEXT:    pxor %xmm2, %xmm3
; SSE2-NEXT:    pxor %xmm0, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm4
; SSE2-NEXT:    pcmpgtd %xmm3, %xmm4
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm4[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm3, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm2[1,1,3,3]
; SSE2-NEXT:    pand %xmm5, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm3 = xmm4[1,1,3,3]
; SSE2-NEXT:    por %xmm2, %xmm3
; SSE2-NEXT:    pand %xmm3, %xmm0
; SSE2-NEXT:    pandn %xmm1, %xmm3
; SSE2-NEXT:    por %xmm3, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test183:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm2
; SSE4-NEXT:    movdqa {{.*#+}} xmm0 = [9223372036854775808,9223372036854775808]
; SSE4-NEXT:    movdqa %xmm1, %xmm3
; SSE4-NEXT:    pxor %xmm0, %xmm3
; SSE4-NEXT:    pxor %xmm2, %xmm0
; SSE4-NEXT:    pcmpgtq %xmm3, %xmm0
; SSE4-NEXT:    blendvpd %xmm2, %xmm1
; SSE4-NEXT:    movapd %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test183:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm2 = [9223372036854775808,9223372036854775808]
; AVX1-NEXT:    vpxor %xmm2, %xmm1, %xmm3
; AVX1-NEXT:    vpxor %xmm2, %xmm0, %xmm2
; AVX1-NEXT:    vpcmpgtq %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vblendvpd %xmm2, %xmm0, %xmm1, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test183:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vmovdqa {{.*#+}} xmm2 = [9223372036854775808,9223372036854775808]
; AVX2-NEXT:    vpxor %xmm2, %xmm1, %xmm3
; AVX2-NEXT:    vpxor %xmm2, %xmm0, %xmm2
; AVX2-NEXT:    vpcmpgtq %xmm3, %xmm2, %xmm2
; AVX2-NEXT:    vblendvpd %xmm2, %xmm0, %xmm1, %xmm0
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test183:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpmaxuq %xmm1, %xmm0, %xmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp ugt <2 x i64> %a, %b
  %sel = select <2 x i1> %cmp, <2 x i64> %a, <2 x i64> %b
  ret <2 x i64> %sel
}

define <2 x i64> @test184(<2 x i64> %a, <2 x i64> %b) {
; SSE2-LABEL: test184:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm0, %xmm3
; SSE2-NEXT:    pxor %xmm2, %xmm3
; SSE2-NEXT:    pxor %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm4
; SSE2-NEXT:    pcmpgtd %xmm3, %xmm4
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm4[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm3, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm2[1,1,3,3]
; SSE2-NEXT:    pand %xmm5, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm3 = xmm4[1,1,3,3]
; SSE2-NEXT:    por %xmm2, %xmm3
; SSE2-NEXT:    pcmpeqd %xmm2, %xmm2
; SSE2-NEXT:    pxor %xmm3, %xmm2
; SSE2-NEXT:    pandn %xmm0, %xmm3
; SSE2-NEXT:    pandn %xmm1, %xmm2
; SSE2-NEXT:    por %xmm3, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test184:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm2
; SSE4-NEXT:    movdqa {{.*#+}} xmm3 = [9223372036854775808,9223372036854775808]
; SSE4-NEXT:    pxor %xmm3, %xmm0
; SSE4-NEXT:    pxor %xmm1, %xmm3
; SSE4-NEXT:    pcmpgtq %xmm0, %xmm3
; SSE4-NEXT:    pcmpeqd %xmm0, %xmm0
; SSE4-NEXT:    pxor %xmm3, %xmm0
; SSE4-NEXT:    blendvpd %xmm2, %xmm1
; SSE4-NEXT:    movapd %xmm1, %xmm0
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test184:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm2 = [9223372036854775808,9223372036854775808]
; AVX1-NEXT:    vpxor %xmm2, %xmm0, %xmm3
; AVX1-NEXT:    vpxor %xmm2, %xmm1, %xmm2
; AVX1-NEXT:    vpcmpgtq %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpcmpeqd %xmm3, %xmm3, %xmm3
; AVX1-NEXT:    vpxor %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vblendvpd %xmm2, %xmm0, %xmm1, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test184:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vmovdqa {{.*#+}} xmm2 = [9223372036854775808,9223372036854775808]
; AVX2-NEXT:    vpxor %xmm2, %xmm0, %xmm3
; AVX2-NEXT:    vpxor %xmm2, %xmm1, %xmm2
; AVX2-NEXT:    vpcmpgtq %xmm3, %xmm2, %xmm2
; AVX2-NEXT:    vpcmpeqd %xmm3, %xmm3, %xmm3
; AVX2-NEXT:    vpxor %xmm3, %xmm2, %xmm2
; AVX2-NEXT:    vblendvpd %xmm2, %xmm0, %xmm1, %xmm0
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test184:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpmaxuq %xmm1, %xmm0, %xmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp uge <2 x i64> %a, %b
  %sel = select <2 x i1> %cmp, <2 x i64> %a, <2 x i64> %b
  ret <2 x i64> %sel
}

define <2 x i64> @test185(<2 x i64> %a, <2 x i64> %b) {
; SSE2-LABEL: test185:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [2147483648,0,2147483648,0]
; SSE2-NEXT:    movdqa %xmm0, %xmm3
; SSE2-NEXT:    pxor %xmm2, %xmm3
; SSE2-NEXT:    pxor %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm4
; SSE2-NEXT:    pcmpgtd %xmm3, %xmm4
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm4[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm3, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm3 = xmm2[1,1,3,3]
; SSE2-NEXT:    pand %xmm5, %xmm3
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm4[1,1,3,3]
; SSE2-NEXT:    por %xmm3, %xmm2
; SSE2-NEXT:    pand %xmm2, %xmm1
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    por %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test185:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm2
; SSE4-NEXT:    movdqa %xmm1, %xmm0
; SSE4-NEXT:    pcmpgtq %xmm2, %xmm0
; SSE4-NEXT:    blendvpd %xmm1, %xmm2
; SSE4-NEXT:    movapd %xmm2, %xmm0
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test185:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vpcmpgtq %xmm0, %xmm1, %xmm2
; AVX1-NEXT:    vblendvpd %xmm2, %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test185:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpcmpgtq %xmm0, %xmm1, %xmm2
; AVX2-NEXT:    vblendvpd %xmm2, %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test185:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpmaxsq %xmm1, %xmm0, %xmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp slt <2 x i64> %a, %b
  %sel = select <2 x i1> %cmp, <2 x i64> %b, <2 x i64> %a
  ret <2 x i64> %sel
}

define <2 x i64> @test186(<2 x i64> %a, <2 x i64> %b) {
; SSE2-LABEL: test186:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [2147483648,0,2147483648,0]
; SSE2-NEXT:    movdqa %xmm1, %xmm3
; SSE2-NEXT:    pxor %xmm2, %xmm3
; SSE2-NEXT:    pxor %xmm0, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm4
; SSE2-NEXT:    pcmpgtd %xmm3, %xmm4
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm4[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm3, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm2[1,1,3,3]
; SSE2-NEXT:    pand %xmm5, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm3 = xmm4[1,1,3,3]
; SSE2-NEXT:    por %xmm2, %xmm3
; SSE2-NEXT:    pcmpeqd %xmm2, %xmm2
; SSE2-NEXT:    pxor %xmm3, %xmm2
; SSE2-NEXT:    pandn %xmm1, %xmm3
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    por %xmm3, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test186:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm2
; SSE4-NEXT:    pcmpgtq %xmm1, %xmm0
; SSE4-NEXT:    pcmpeqd %xmm3, %xmm3
; SSE4-NEXT:    pxor %xmm3, %xmm0
; SSE4-NEXT:    blendvpd %xmm1, %xmm2
; SSE4-NEXT:    movapd %xmm2, %xmm0
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test186:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vpcmpgtq %xmm1, %xmm0, %xmm2
; AVX1-NEXT:    vpcmpeqd %xmm3, %xmm3, %xmm3
; AVX1-NEXT:    vpxor %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vblendvpd %xmm2, %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test186:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpcmpgtq %xmm1, %xmm0, %xmm2
; AVX2-NEXT:    vpcmpeqd %xmm3, %xmm3, %xmm3
; AVX2-NEXT:    vpxor %xmm3, %xmm2, %xmm2
; AVX2-NEXT:    vblendvpd %xmm2, %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test186:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpmaxsq %xmm1, %xmm0, %xmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp sle <2 x i64> %a, %b
  %sel = select <2 x i1> %cmp, <2 x i64> %b, <2 x i64> %a
  ret <2 x i64> %sel
}

define <2 x i64> @test187(<2 x i64> %a, <2 x i64> %b) {
; SSE2-LABEL: test187:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [2147483648,0,2147483648,0]
; SSE2-NEXT:    movdqa %xmm1, %xmm3
; SSE2-NEXT:    pxor %xmm2, %xmm3
; SSE2-NEXT:    pxor %xmm0, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm4
; SSE2-NEXT:    pcmpgtd %xmm3, %xmm4
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm4[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm3, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm3 = xmm2[1,1,3,3]
; SSE2-NEXT:    pand %xmm5, %xmm3
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm4[1,1,3,3]
; SSE2-NEXT:    por %xmm3, %xmm2
; SSE2-NEXT:    pand %xmm2, %xmm1
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    por %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test187:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm2
; SSE4-NEXT:    pcmpgtq %xmm1, %xmm0
; SSE4-NEXT:    blendvpd %xmm1, %xmm2
; SSE4-NEXT:    movapd %xmm2, %xmm0
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test187:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vpcmpgtq %xmm1, %xmm0, %xmm2
; AVX1-NEXT:    vblendvpd %xmm2, %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test187:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpcmpgtq %xmm1, %xmm0, %xmm2
; AVX2-NEXT:    vblendvpd %xmm2, %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test187:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpminsq %xmm1, %xmm0, %xmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp sgt <2 x i64> %a, %b
  %sel = select <2 x i1> %cmp, <2 x i64> %b, <2 x i64> %a
  ret <2 x i64> %sel
}

define <2 x i64> @test188(<2 x i64> %a, <2 x i64> %b) {
; SSE2-LABEL: test188:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [2147483648,0,2147483648,0]
; SSE2-NEXT:    movdqa %xmm0, %xmm3
; SSE2-NEXT:    pxor %xmm2, %xmm3
; SSE2-NEXT:    pxor %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm4
; SSE2-NEXT:    pcmpgtd %xmm3, %xmm4
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm4[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm3, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm2[1,1,3,3]
; SSE2-NEXT:    pand %xmm5, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm3 = xmm4[1,1,3,3]
; SSE2-NEXT:    por %xmm2, %xmm3
; SSE2-NEXT:    pcmpeqd %xmm2, %xmm2
; SSE2-NEXT:    pxor %xmm3, %xmm2
; SSE2-NEXT:    pandn %xmm1, %xmm3
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    por %xmm3, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test188:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm2
; SSE4-NEXT:    movdqa %xmm1, %xmm3
; SSE4-NEXT:    pcmpgtq %xmm2, %xmm3
; SSE4-NEXT:    pcmpeqd %xmm0, %xmm0
; SSE4-NEXT:    pxor %xmm3, %xmm0
; SSE4-NEXT:    blendvpd %xmm1, %xmm2
; SSE4-NEXT:    movapd %xmm2, %xmm0
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test188:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vpcmpgtq %xmm0, %xmm1, %xmm2
; AVX1-NEXT:    vpcmpeqd %xmm3, %xmm3, %xmm3
; AVX1-NEXT:    vpxor %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vblendvpd %xmm2, %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test188:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpcmpgtq %xmm0, %xmm1, %xmm2
; AVX2-NEXT:    vpcmpeqd %xmm3, %xmm3, %xmm3
; AVX2-NEXT:    vpxor %xmm3, %xmm2, %xmm2
; AVX2-NEXT:    vblendvpd %xmm2, %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test188:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpminsq %xmm1, %xmm0, %xmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp sge <2 x i64> %a, %b
  %sel = select <2 x i1> %cmp, <2 x i64> %b, <2 x i64> %a
  ret <2 x i64> %sel
}

define <2 x i64> @test189(<2 x i64> %a, <2 x i64> %b) {
; SSE2-LABEL: test189:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm0, %xmm3
; SSE2-NEXT:    pxor %xmm2, %xmm3
; SSE2-NEXT:    pxor %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm4
; SSE2-NEXT:    pcmpgtd %xmm3, %xmm4
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm4[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm3, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm3 = xmm2[1,1,3,3]
; SSE2-NEXT:    pand %xmm5, %xmm3
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm4[1,1,3,3]
; SSE2-NEXT:    por %xmm3, %xmm2
; SSE2-NEXT:    pand %xmm2, %xmm1
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    por %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test189:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm2
; SSE4-NEXT:    movdqa {{.*#+}} xmm0 = [9223372036854775808,9223372036854775808]
; SSE4-NEXT:    movdqa %xmm2, %xmm3
; SSE4-NEXT:    pxor %xmm0, %xmm3
; SSE4-NEXT:    pxor %xmm1, %xmm0
; SSE4-NEXT:    pcmpgtq %xmm3, %xmm0
; SSE4-NEXT:    blendvpd %xmm1, %xmm2
; SSE4-NEXT:    movapd %xmm2, %xmm0
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test189:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm2 = [9223372036854775808,9223372036854775808]
; AVX1-NEXT:    vpxor %xmm2, %xmm0, %xmm3
; AVX1-NEXT:    vpxor %xmm2, %xmm1, %xmm2
; AVX1-NEXT:    vpcmpgtq %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vblendvpd %xmm2, %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test189:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vmovdqa {{.*#+}} xmm2 = [9223372036854775808,9223372036854775808]
; AVX2-NEXT:    vpxor %xmm2, %xmm0, %xmm3
; AVX2-NEXT:    vpxor %xmm2, %xmm1, %xmm2
; AVX2-NEXT:    vpcmpgtq %xmm3, %xmm2, %xmm2
; AVX2-NEXT:    vblendvpd %xmm2, %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test189:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpmaxuq %xmm1, %xmm0, %xmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp ult <2 x i64> %a, %b
  %sel = select <2 x i1> %cmp, <2 x i64> %b, <2 x i64> %a
  ret <2 x i64> %sel
}

define <2 x i64> @test190(<2 x i64> %a, <2 x i64> %b) {
; SSE2-LABEL: test190:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm1, %xmm3
; SSE2-NEXT:    pxor %xmm2, %xmm3
; SSE2-NEXT:    pxor %xmm0, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm4
; SSE2-NEXT:    pcmpgtd %xmm3, %xmm4
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm4[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm3, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm2[1,1,3,3]
; SSE2-NEXT:    pand %xmm5, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm3 = xmm4[1,1,3,3]
; SSE2-NEXT:    por %xmm2, %xmm3
; SSE2-NEXT:    pcmpeqd %xmm2, %xmm2
; SSE2-NEXT:    pxor %xmm3, %xmm2
; SSE2-NEXT:    pandn %xmm1, %xmm3
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    por %xmm3, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test190:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm2
; SSE4-NEXT:    movdqa {{.*#+}} xmm3 = [9223372036854775808,9223372036854775808]
; SSE4-NEXT:    movdqa %xmm1, %xmm0
; SSE4-NEXT:    pxor %xmm3, %xmm0
; SSE4-NEXT:    pxor %xmm2, %xmm3
; SSE4-NEXT:    pcmpgtq %xmm0, %xmm3
; SSE4-NEXT:    pcmpeqd %xmm0, %xmm0
; SSE4-NEXT:    pxor %xmm3, %xmm0
; SSE4-NEXT:    blendvpd %xmm1, %xmm2
; SSE4-NEXT:    movapd %xmm2, %xmm0
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test190:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm2 = [9223372036854775808,9223372036854775808]
; AVX1-NEXT:    vpxor %xmm2, %xmm1, %xmm3
; AVX1-NEXT:    vpxor %xmm2, %xmm0, %xmm2
; AVX1-NEXT:    vpcmpgtq %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpcmpeqd %xmm3, %xmm3, %xmm3
; AVX1-NEXT:    vpxor %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vblendvpd %xmm2, %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test190:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vmovdqa {{.*#+}} xmm2 = [9223372036854775808,9223372036854775808]
; AVX2-NEXT:    vpxor %xmm2, %xmm1, %xmm3
; AVX2-NEXT:    vpxor %xmm2, %xmm0, %xmm2
; AVX2-NEXT:    vpcmpgtq %xmm3, %xmm2, %xmm2
; AVX2-NEXT:    vpcmpeqd %xmm3, %xmm3, %xmm3
; AVX2-NEXT:    vpxor %xmm3, %xmm2, %xmm2
; AVX2-NEXT:    vblendvpd %xmm2, %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test190:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpmaxuq %xmm1, %xmm0, %xmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp ule <2 x i64> %a, %b
  %sel = select <2 x i1> %cmp, <2 x i64> %b, <2 x i64> %a
  ret <2 x i64> %sel
}

define <2 x i64> @test191(<2 x i64> %a, <2 x i64> %b) {
; SSE2-LABEL: test191:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm1, %xmm3
; SSE2-NEXT:    pxor %xmm2, %xmm3
; SSE2-NEXT:    pxor %xmm0, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm4
; SSE2-NEXT:    pcmpgtd %xmm3, %xmm4
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm4[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm3, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm3 = xmm2[1,1,3,3]
; SSE2-NEXT:    pand %xmm5, %xmm3
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm4[1,1,3,3]
; SSE2-NEXT:    por %xmm3, %xmm2
; SSE2-NEXT:    pand %xmm2, %xmm1
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    por %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test191:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm2
; SSE4-NEXT:    movdqa {{.*#+}} xmm0 = [9223372036854775808,9223372036854775808]
; SSE4-NEXT:    movdqa %xmm1, %xmm3
; SSE4-NEXT:    pxor %xmm0, %xmm3
; SSE4-NEXT:    pxor %xmm2, %xmm0
; SSE4-NEXT:    pcmpgtq %xmm3, %xmm0
; SSE4-NEXT:    blendvpd %xmm1, %xmm2
; SSE4-NEXT:    movapd %xmm2, %xmm0
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test191:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm2 = [9223372036854775808,9223372036854775808]
; AVX1-NEXT:    vpxor %xmm2, %xmm1, %xmm3
; AVX1-NEXT:    vpxor %xmm2, %xmm0, %xmm2
; AVX1-NEXT:    vpcmpgtq %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vblendvpd %xmm2, %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test191:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vmovdqa {{.*#+}} xmm2 = [9223372036854775808,9223372036854775808]
; AVX2-NEXT:    vpxor %xmm2, %xmm1, %xmm3
; AVX2-NEXT:    vpxor %xmm2, %xmm0, %xmm2
; AVX2-NEXT:    vpcmpgtq %xmm3, %xmm2, %xmm2
; AVX2-NEXT:    vblendvpd %xmm2, %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test191:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpminuq %xmm1, %xmm0, %xmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp ugt <2 x i64> %a, %b
  %sel = select <2 x i1> %cmp, <2 x i64> %b, <2 x i64> %a
  ret <2 x i64> %sel
}

define <2 x i64> @test192(<2 x i64> %a, <2 x i64> %b) {
; SSE2-LABEL: test192:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm0, %xmm3
; SSE2-NEXT:    pxor %xmm2, %xmm3
; SSE2-NEXT:    pxor %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm4
; SSE2-NEXT:    pcmpgtd %xmm3, %xmm4
; SSE2-NEXT:    pshufd {{.*#+}} xmm5 = xmm4[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm3, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm2[1,1,3,3]
; SSE2-NEXT:    pand %xmm5, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm3 = xmm4[1,1,3,3]
; SSE2-NEXT:    por %xmm2, %xmm3
; SSE2-NEXT:    pcmpeqd %xmm2, %xmm2
; SSE2-NEXT:    pxor %xmm3, %xmm2
; SSE2-NEXT:    pandn %xmm1, %xmm3
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    por %xmm3, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test192:
; SSE4:       # BB#0: # %entry
; SSE4-NEXT:    movdqa %xmm0, %xmm2
; SSE4-NEXT:    movdqa {{.*#+}} xmm3 = [9223372036854775808,9223372036854775808]
; SSE4-NEXT:    pxor %xmm3, %xmm0
; SSE4-NEXT:    pxor %xmm1, %xmm3
; SSE4-NEXT:    pcmpgtq %xmm0, %xmm3
; SSE4-NEXT:    pcmpeqd %xmm0, %xmm0
; SSE4-NEXT:    pxor %xmm3, %xmm0
; SSE4-NEXT:    blendvpd %xmm1, %xmm2
; SSE4-NEXT:    movapd %xmm2, %xmm0
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test192:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm2 = [9223372036854775808,9223372036854775808]
; AVX1-NEXT:    vpxor %xmm2, %xmm0, %xmm3
; AVX1-NEXT:    vpxor %xmm2, %xmm1, %xmm2
; AVX1-NEXT:    vpcmpgtq %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpcmpeqd %xmm3, %xmm3, %xmm3
; AVX1-NEXT:    vpxor %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vblendvpd %xmm2, %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test192:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vmovdqa {{.*#+}} xmm2 = [9223372036854775808,9223372036854775808]
; AVX2-NEXT:    vpxor %xmm2, %xmm0, %xmm3
; AVX2-NEXT:    vpxor %xmm2, %xmm1, %xmm2
; AVX2-NEXT:    vpcmpgtq %xmm3, %xmm2, %xmm2
; AVX2-NEXT:    vpcmpeqd %xmm3, %xmm3, %xmm3
; AVX2-NEXT:    vpxor %xmm3, %xmm2, %xmm2
; AVX2-NEXT:    vblendvpd %xmm2, %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    retq
;
; AVX512BW-LABEL: test192:
; AVX512BW:       # BB#0: # %entry
; AVX512BW-NEXT:    vpminuq %xmm1, %xmm0, %xmm0
; AVX512BW-NEXT:    retq
entry:
  %cmp = icmp uge <2 x i64> %a, %b
  %sel = select <2 x i1> %cmp, <2 x i64> %b, <2 x i64> %a
  ret <2 x i64> %sel
}
