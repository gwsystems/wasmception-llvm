; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

declare <4 x i32>  @llvm.x86.sse41.pmovzxbd(<16 x i8>) nounwind readnone
declare <2 x i64>  @llvm.x86.sse41.pmovzxbq(<16 x i8>) nounwind readnone
declare <8 x i16>  @llvm.x86.sse41.pmovzxbw(<16 x i8>) nounwind readnone
declare <2 x i64>  @llvm.x86.sse41.pmovzxdq(<4 x i32>) nounwind readnone
declare <4 x i32>  @llvm.x86.sse41.pmovzxwd(<8 x i16>) nounwind readnone
declare <2 x i64>  @llvm.x86.sse41.pmovzxwq(<8 x i16>) nounwind readnone

declare <8 x i32>  @llvm.x86.avx2.pmovzxbd(<16 x i8>) nounwind readnone
declare <4 x i64>  @llvm.x86.avx2.pmovzxbq(<16 x i8>) nounwind readnone
declare <16 x i16> @llvm.x86.avx2.pmovzxbw(<16 x i8>) nounwind readnone
declare <4 x i64>  @llvm.x86.avx2.pmovzxdq(<4 x i32>) nounwind readnone
declare <8 x i32>  @llvm.x86.avx2.pmovzxwd(<8 x i16>) nounwind readnone
declare <4 x i64>  @llvm.x86.avx2.pmovzxwq(<8 x i16>) nounwind readnone

;
; Basic zero extension tests
;

define <4 x i32> @sse41_pmovzxbd(<16 x i8> %v) nounwind readnone {
; CHECK-LABEL: @sse41_pmovzxbd(
; CHECK-NEXT:    [[TMP1:%.*]] = shufflevector <16 x i8> %v, <16 x i8> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
; CHECK-NEXT:    [[TMP2:%.*]] = zext <4 x i8> [[TMP1]] to <4 x i32>
; CHECK-NEXT:    ret <4 x i32> [[TMP2]]
;
  %res = call <4 x i32> @llvm.x86.sse41.pmovzxbd(<16 x i8> %v)
  ret <4 x i32> %res
}

define <2 x i64> @sse41_pmovzxbq(<16 x i8> %v) nounwind readnone {
; CHECK-LABEL: @sse41_pmovzxbq(
; CHECK-NEXT:    [[TMP1:%.*]] = shufflevector <16 x i8> %v, <16 x i8> undef, <2 x i32> <i32 0, i32 1>
; CHECK-NEXT:    [[TMP2:%.*]] = zext <2 x i8> [[TMP1]] to <2 x i64>
; CHECK-NEXT:    ret <2 x i64> [[TMP2]]
;
  %res = call <2 x i64> @llvm.x86.sse41.pmovzxbq(<16 x i8> %v)
  ret <2 x i64> %res
}

define <8 x i16> @sse41_pmovzxbw(<16 x i8> %v) nounwind readnone {
; CHECK-LABEL: @sse41_pmovzxbw(
; CHECK-NEXT:    [[TMP1:%.*]] = shufflevector <16 x i8> %v, <16 x i8> undef, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
; CHECK-NEXT:    [[TMP2:%.*]] = zext <8 x i8> [[TMP1]] to <8 x i16>
; CHECK-NEXT:    ret <8 x i16> [[TMP2]]
;
  %res = call <8 x i16> @llvm.x86.sse41.pmovzxbw(<16 x i8> %v)
  ret <8 x i16> %res
}

define <2 x i64> @sse41_pmovzxdq(<4 x i32> %v) nounwind readnone {
; CHECK-LABEL: @sse41_pmovzxdq(
; CHECK-NEXT:    [[TMP1:%.*]] = shufflevector <4 x i32> %v, <4 x i32> undef, <2 x i32> <i32 0, i32 1>
; CHECK-NEXT:    [[TMP2:%.*]] = zext <2 x i32> [[TMP1]] to <2 x i64>
; CHECK-NEXT:    ret <2 x i64> [[TMP2]]
;
  %res = call <2 x i64> @llvm.x86.sse41.pmovzxdq(<4 x i32> %v)
  ret <2 x i64> %res
}

define <4 x i32> @sse41_pmovzxwd(<8 x i16> %v) nounwind readnone {
; CHECK-LABEL: @sse41_pmovzxwd(
; CHECK-NEXT:    [[TMP1:%.*]] = shufflevector <8 x i16> %v, <8 x i16> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
; CHECK-NEXT:    [[TMP2:%.*]] = zext <4 x i16> [[TMP1]] to <4 x i32>
; CHECK-NEXT:    ret <4 x i32> [[TMP2]]
;
  %res = call <4 x i32> @llvm.x86.sse41.pmovzxwd(<8 x i16> %v)
  ret <4 x i32> %res
}

define <2 x i64> @sse41_pmovzxwq(<8 x i16> %v) nounwind readnone {
; CHECK-LABEL: @sse41_pmovzxwq(
; CHECK-NEXT:    [[TMP1:%.*]] = shufflevector <8 x i16> %v, <8 x i16> undef, <2 x i32> <i32 0, i32 1>
; CHECK-NEXT:    [[TMP2:%.*]] = zext <2 x i16> [[TMP1]] to <2 x i64>
; CHECK-NEXT:    ret <2 x i64> [[TMP2]]
;
  %res = call <2 x i64> @llvm.x86.sse41.pmovzxwq(<8 x i16> %v)
  ret <2 x i64> %res
}

define <8 x i32> @avx2_pmovzxbd(<16 x i8> %v) nounwind readnone {
; CHECK-LABEL: @avx2_pmovzxbd(
; CHECK-NEXT:    [[TMP1:%.*]] = shufflevector <16 x i8> %v, <16 x i8> undef, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
; CHECK-NEXT:    [[TMP2:%.*]] = zext <8 x i8> [[TMP1]] to <8 x i32>
; CHECK-NEXT:    ret <8 x i32> [[TMP2]]
;
  %res = call <8 x i32> @llvm.x86.avx2.pmovzxbd(<16 x i8> %v)
  ret <8 x i32> %res
}

define <4 x i64> @avx2_pmovzxbq(<16 x i8> %v) nounwind readnone {
; CHECK-LABEL: @avx2_pmovzxbq(
; CHECK-NEXT:    [[TMP1:%.*]] = shufflevector <16 x i8> %v, <16 x i8> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
; CHECK-NEXT:    [[TMP2:%.*]] = zext <4 x i8> [[TMP1]] to <4 x i64>
; CHECK-NEXT:    ret <4 x i64> [[TMP2]]
;
  %res = call <4 x i64> @llvm.x86.avx2.pmovzxbq(<16 x i8> %v)
  ret <4 x i64> %res
}

define <16 x i16> @avx2_pmovzxbw(<16 x i8> %v) nounwind readnone {
; CHECK-LABEL: @avx2_pmovzxbw(
; CHECK-NEXT:    [[TMP1:%.*]] = zext <16 x i8> %v to <16 x i16>
; CHECK-NEXT:    ret <16 x i16> [[TMP1]]
;
  %res = call <16 x i16> @llvm.x86.avx2.pmovzxbw(<16 x i8> %v)
  ret <16 x i16> %res
}

define <4 x i64> @avx2_pmovzxdq(<4 x i32> %v) nounwind readnone {
; CHECK-LABEL: @avx2_pmovzxdq(
; CHECK-NEXT:    [[TMP1:%.*]] = zext <4 x i32> %v to <4 x i64>
; CHECK-NEXT:    ret <4 x i64> [[TMP1]]
;
  %res = call <4 x i64> @llvm.x86.avx2.pmovzxdq(<4 x i32> %v)
  ret <4 x i64> %res
}

define <8 x i32> @avx2_pmovzxwd(<8 x i16> %v) nounwind readnone {
; CHECK-LABEL: @avx2_pmovzxwd(
; CHECK-NEXT:    [[TMP1:%.*]] = zext <8 x i16> %v to <8 x i32>
; CHECK-NEXT:    ret <8 x i32> [[TMP1]]
;
  %res = call <8 x i32> @llvm.x86.avx2.pmovzxwd(<8 x i16> %v)
  ret <8 x i32> %res
}

define <4 x i64> @avx2_pmovzxwq(<8 x i16> %v) nounwind readnone {
; CHECK-LABEL: @avx2_pmovzxwq(
; CHECK-NEXT:    [[TMP1:%.*]] = shufflevector <8 x i16> %v, <8 x i16> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
; CHECK-NEXT:    [[TMP2:%.*]] = zext <4 x i16> [[TMP1]] to <4 x i64>
; CHECK-NEXT:    ret <4 x i64> [[TMP2]]
;
  %res = call <4 x i64> @llvm.x86.avx2.pmovzxwq(<8 x i16> %v)
  ret <4 x i64> %res
}
