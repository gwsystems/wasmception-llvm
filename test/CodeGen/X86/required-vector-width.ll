; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=avx512vl,avx512bw,avx512dq,prefer-256-bit | FileCheck %s

; This file primarily contains tests for specific places in X86ISelLowering.cpp that needed be made aware of the legalizer not allowing 512-bit vectors due to prefer-256-bit even though AVX512 is enabled.

define void @add256(<16 x i32>* %a, <16 x i32>* %b, <16 x i32>* %c) "required-vector-width"="256" {
; CHECK-LABEL: add256:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vmovdqa (%rdi), %ymm0
; CHECK-NEXT:    vmovdqa 32(%rdi), %ymm1
; CHECK-NEXT:    vpaddd (%rsi), %ymm0, %ymm0
; CHECK-NEXT:    vpaddd 32(%rsi), %ymm1, %ymm1
; CHECK-NEXT:    vmovdqa %ymm1, 32(%rdx)
; CHECK-NEXT:    vmovdqa %ymm0, (%rdx)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
  %d = load <16 x i32>, <16 x i32>* %a
  %e = load <16 x i32>, <16 x i32>* %b
  %f = add <16 x i32> %d, %e
  store <16 x i32> %f, <16 x i32>* %c
  ret void
}

define void @add512(<16 x i32>* %a, <16 x i32>* %b, <16 x i32>* %c) "required-vector-width"="512" {
; CHECK-LABEL: add512:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vmovdqa64 (%rdi), %zmm0
; CHECK-NEXT:    vpaddd (%rsi), %zmm0, %zmm0
; CHECK-NEXT:    vmovdqa64 %zmm0, (%rdx)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
  %d = load <16 x i32>, <16 x i32>* %a
  %e = load <16 x i32>, <16 x i32>* %b
  %f = add <16 x i32> %d, %e
  store <16 x i32> %f, <16 x i32>* %c
  ret void
}

define void @avg_v64i8_256(<64 x i8>* %a, <64 x i8>* %b) "required-vector-width"="256" {
; CHECK-LABEL: avg_v64i8_256:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vmovdqa (%rsi), %ymm0
; CHECK-NEXT:    vmovdqa 32(%rsi), %ymm1
; CHECK-NEXT:    vpavgb (%rdi), %ymm0, %ymm0
; CHECK-NEXT:    vpavgb 32(%rdi), %ymm1, %ymm1
; CHECK-NEXT:    vmovdqu %ymm1, (%rax)
; CHECK-NEXT:    vmovdqu %ymm0, (%rax)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
  %1 = load <64 x i8>, <64 x i8>* %a
  %2 = load <64 x i8>, <64 x i8>* %b
  %3 = zext <64 x i8> %1 to <64 x i32>
  %4 = zext <64 x i8> %2 to <64 x i32>
  %5 = add nuw nsw <64 x i32> %3, <i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
  %6 = add nuw nsw <64 x i32> %5, %4
  %7 = lshr <64 x i32> %6, <i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
  %8 = trunc <64 x i32> %7 to <64 x i8>
  store <64 x i8> %8, <64 x i8>* undef, align 4
  ret void
}


define void @avg_v64i8_512(<64 x i8>* %a, <64 x i8>* %b) "required-vector-width"="512" {
; CHECK-LABEL: avg_v64i8_512:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vmovdqa64 (%rsi), %zmm0
; CHECK-NEXT:    vpavgb (%rdi), %zmm0, %zmm0
; CHECK-NEXT:    vmovdqu64 %zmm0, (%rax)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
  %1 = load <64 x i8>, <64 x i8>* %a
  %2 = load <64 x i8>, <64 x i8>* %b
  %3 = zext <64 x i8> %1 to <64 x i32>
  %4 = zext <64 x i8> %2 to <64 x i32>
  %5 = add nuw nsw <64 x i32> %3, <i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
  %6 = add nuw nsw <64 x i32> %5, %4
  %7 = lshr <64 x i32> %6, <i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
  %8 = trunc <64 x i32> %7 to <64 x i8>
  store <64 x i8> %8, <64 x i8>* undef, align 4
  ret void
}

define void @pmaddwd_32_256(<32 x i16>* %APtr, <32 x i16>* %BPtr, <16 x i32>* %CPtr) "required-vector-width"="256" {
; CHECK-LABEL: pmaddwd_32_256:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vmovdqa (%rdi), %ymm0
; CHECK-NEXT:    vmovdqa 32(%rdi), %ymm1
; CHECK-NEXT:    vpmaddwd (%rsi), %ymm0, %ymm0
; CHECK-NEXT:    vpmaddwd 32(%rsi), %ymm1, %ymm1
; CHECK-NEXT:    vmovdqa %ymm1, 32(%rdx)
; CHECK-NEXT:    vmovdqa %ymm0, (%rdx)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
   %A = load <32 x i16>, <32 x i16>* %APtr
   %B = load <32 x i16>, <32 x i16>* %BPtr
   %a = sext <32 x i16> %A to <32 x i32>
   %b = sext <32 x i16> %B to <32 x i32>
   %m = mul nsw <32 x i32> %a, %b
   %odd = shufflevector <32 x i32> %m, <32 x i32> undef, <16 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14, i32 16, i32 18, i32 20, i32 22, i32 24, i32 26, i32 28, i32 30>
   %even = shufflevector <32 x i32> %m, <32 x i32> undef, <16 x i32> <i32 1, i32 3, i32 5, i32 7, i32 9, i32 11, i32 13, i32 15, i32 17, i32 19, i32 21, i32 23, i32 25, i32 27, i32 29, i32 31>
   %ret = add <16 x i32> %odd, %even
   store <16 x i32> %ret, <16 x i32>* %CPtr
   ret void
}

define void @pmaddwd_32_512(<32 x i16>* %APtr, <32 x i16>* %BPtr, <16 x i32>* %CPtr) "required-vector-width"="512" {
; CHECK-LABEL: pmaddwd_32_512:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vmovdqa64 (%rdi), %zmm0
; CHECK-NEXT:    vpmaddwd (%rsi), %zmm0, %zmm0
; CHECK-NEXT:    vmovdqa64 %zmm0, (%rdx)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
   %A = load <32 x i16>, <32 x i16>* %APtr
   %B = load <32 x i16>, <32 x i16>* %BPtr
   %a = sext <32 x i16> %A to <32 x i32>
   %b = sext <32 x i16> %B to <32 x i32>
   %m = mul nsw <32 x i32> %a, %b
   %odd = shufflevector <32 x i32> %m, <32 x i32> undef, <16 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14, i32 16, i32 18, i32 20, i32 22, i32 24, i32 26, i32 28, i32 30>
   %even = shufflevector <32 x i32> %m, <32 x i32> undef, <16 x i32> <i32 1, i32 3, i32 5, i32 7, i32 9, i32 11, i32 13, i32 15, i32 17, i32 19, i32 21, i32 23, i32 25, i32 27, i32 29, i32 31>
   %ret = add <16 x i32> %odd, %even
   store <16 x i32> %ret, <16 x i32>* %CPtr
   ret void
}

define void @psubus_64i8_max_256(<64 x i8>* %xptr, <64 x i8>* %yptr, <64 x i8>* %zptr) "required-vector-width"="256" {
; CHECK-LABEL: psubus_64i8_max_256:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vmovdqa (%rdi), %ymm0
; CHECK-NEXT:    vmovdqa 32(%rdi), %ymm1
; CHECK-NEXT:    vpsubusb (%rsi), %ymm0, %ymm0
; CHECK-NEXT:    vpsubusb 32(%rsi), %ymm1, %ymm1
; CHECK-NEXT:    vmovdqa %ymm1, 32(%rdx)
; CHECK-NEXT:    vmovdqa %ymm0, (%rdx)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
  %x = load <64 x i8>, <64 x i8>* %xptr
  %y = load <64 x i8>, <64 x i8>* %yptr
  %cmp = icmp ult <64 x i8> %x, %y
  %max = select <64 x i1> %cmp, <64 x i8> %y, <64 x i8> %x
  %res = sub <64 x i8> %max, %y
  store <64 x i8> %res, <64 x i8>* %zptr
  ret void
}

define void @psubus_64i8_max_512(<64 x i8>* %xptr, <64 x i8>* %yptr, <64 x i8>* %zptr) "required-vector-width"="512" {
; CHECK-LABEL: psubus_64i8_max_512:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vmovdqa64 (%rdi), %zmm0
; CHECK-NEXT:    vpsubusb (%rsi), %zmm0, %zmm0
; CHECK-NEXT:    vmovdqa64 %zmm0, (%rdx)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
  %x = load <64 x i8>, <64 x i8>* %xptr
  %y = load <64 x i8>, <64 x i8>* %yptr
  %cmp = icmp ult <64 x i8> %x, %y
  %max = select <64 x i1> %cmp, <64 x i8> %y, <64 x i8> %x
  %res = sub <64 x i8> %max, %y
  store <64 x i8> %res, <64 x i8>* %zptr
  ret void
}

define i32 @_Z9test_charPcS_i_256(i8* nocapture readonly, i8* nocapture readonly, i32) "required-vector-width"="256" {
; CHECK-LABEL: _Z9test_charPcS_i_256:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movl %edx, %eax
; CHECK-NEXT:    vpxor %xmm0, %xmm0, %xmm0
; CHECK-NEXT:    xorl %ecx, %ecx
; CHECK-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; CHECK-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; CHECK-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; CHECK-NEXT:    .p2align 4, 0x90
; CHECK-NEXT:  .LBB8_1: # %vector.body
; CHECK-NEXT:    # =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    vpmovsxbw (%rdi,%rcx), %xmm4
; CHECK-NEXT:    vpmovsxbw 8(%rdi,%rcx), %xmm5
; CHECK-NEXT:    vpmovsxbw 16(%rdi,%rcx), %xmm6
; CHECK-NEXT:    vpmovsxbw 24(%rdi,%rcx), %xmm8
; CHECK-NEXT:    vpmovsxbw (%rsi,%rcx), %xmm7
; CHECK-NEXT:    vpmaddwd %xmm4, %xmm7, %xmm4
; CHECK-NEXT:    vpmovsxbw 8(%rsi,%rcx), %xmm7
; CHECK-NEXT:    vpmaddwd %xmm5, %xmm7, %xmm5
; CHECK-NEXT:    vpmovsxbw 16(%rsi,%rcx), %xmm7
; CHECK-NEXT:    vpmaddwd %xmm6, %xmm7, %xmm6
; CHECK-NEXT:    vpmovsxbw 24(%rsi,%rcx), %xmm7
; CHECK-NEXT:    vpmaddwd %xmm8, %xmm7, %xmm7
; CHECK-NEXT:    vpaddd %ymm3, %ymm7, %ymm3
; CHECK-NEXT:    vpaddd %ymm2, %ymm6, %ymm2
; CHECK-NEXT:    vpaddd %ymm1, %ymm5, %ymm1
; CHECK-NEXT:    vpaddd %ymm0, %ymm4, %ymm0
; CHECK-NEXT:    addq $32, %rcx
; CHECK-NEXT:    cmpq %rcx, %rax
; CHECK-NEXT:    jne .LBB8_1
; CHECK-NEXT:  # %bb.2: # %middle.block
; CHECK-NEXT:    vpaddd %ymm2, %ymm0, %ymm0
; CHECK-NEXT:    vpaddd %ymm3, %ymm1, %ymm1
; CHECK-NEXT:    vpaddd %ymm1, %ymm0, %ymm0
; CHECK-NEXT:    vextracti128 $1, %ymm0, %xmm1
; CHECK-NEXT:    vpaddd %ymm1, %ymm0, %ymm0
; CHECK-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[2,3,0,1]
; CHECK-NEXT:    vpaddd %ymm1, %ymm0, %ymm0
; CHECK-NEXT:    vphaddd %ymm0, %ymm0, %ymm0
; CHECK-NEXT:    vmovd %xmm0, %eax
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
entry:
  %3 = zext i32 %2 to i64
  br label %vector.body

vector.body:
  %index = phi i64 [ %index.next, %vector.body ], [ 0, %entry ]
  %vec.phi = phi <32 x i32> [ %11, %vector.body ], [ zeroinitializer, %entry ]
  %4 = getelementptr inbounds i8, i8* %0, i64 %index
  %5 = bitcast i8* %4 to <32 x i8>*
  %wide.load = load <32 x i8>, <32 x i8>* %5, align 1
  %6 = sext <32 x i8> %wide.load to <32 x i32>
  %7 = getelementptr inbounds i8, i8* %1, i64 %index
  %8 = bitcast i8* %7 to <32 x i8>*
  %wide.load14 = load <32 x i8>, <32 x i8>* %8, align 1
  %9 = sext <32 x i8> %wide.load14 to <32 x i32>
  %10 = mul nsw <32 x i32> %9, %6
  %11 = add nsw <32 x i32> %10, %vec.phi
  %index.next = add i64 %index, 32
  %12 = icmp eq i64 %index.next, %3
  br i1 %12, label %middle.block, label %vector.body

middle.block:
  %rdx.shuf1 = shufflevector <32 x i32> %11, <32 x i32> undef, <32 x i32> <i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %bin.rdx1 = add <32 x i32> %11, %rdx.shuf1
  %rdx.shuf = shufflevector <32 x i32> %bin.rdx1, <32 x i32> undef, <32 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %bin.rdx = add <32 x i32> %bin.rdx1, %rdx.shuf
  %rdx.shuf15 = shufflevector <32 x i32> %bin.rdx, <32 x i32> undef, <32 x i32> <i32 4, i32 5, i32 6, i32 7, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %bin.rdx32 = add <32 x i32> %bin.rdx, %rdx.shuf15
  %rdx.shuf17 = shufflevector <32 x i32> %bin.rdx32, <32 x i32> undef, <32 x i32> <i32 2, i32 3, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %bin.rdx18 = add <32 x i32> %bin.rdx32, %rdx.shuf17
  %rdx.shuf19 = shufflevector <32 x i32> %bin.rdx18, <32 x i32> undef, <32 x i32> <i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %bin.rdx20 = add <32 x i32> %bin.rdx18, %rdx.shuf19
  %13 = extractelement <32 x i32> %bin.rdx20, i32 0
  ret i32 %13
}

define i32 @_Z9test_charPcS_i_512(i8* nocapture readonly, i8* nocapture readonly, i32) "required-vector-width"="512" {
; CHECK-LABEL: _Z9test_charPcS_i_512:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movl %edx, %eax
; CHECK-NEXT:    vpxor %xmm0, %xmm0, %xmm0
; CHECK-NEXT:    xorl %ecx, %ecx
; CHECK-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; CHECK-NEXT:    .p2align 4, 0x90
; CHECK-NEXT:  .LBB9_1: # %vector.body
; CHECK-NEXT:    # =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    vpmovsxbw (%rdi,%rcx), %zmm2
; CHECK-NEXT:    vpmovsxbw (%rsi,%rcx), %zmm3
; CHECK-NEXT:    vpmaddwd %zmm2, %zmm3, %zmm2
; CHECK-NEXT:    vpaddd %zmm1, %zmm2, %zmm1
; CHECK-NEXT:    addq $32, %rcx
; CHECK-NEXT:    cmpq %rcx, %rax
; CHECK-NEXT:    jne .LBB9_1
; CHECK-NEXT:  # %bb.2: # %middle.block
; CHECK-NEXT:    vpaddd %zmm0, %zmm1, %zmm0
; CHECK-NEXT:    vextracti64x4 $1, %zmm0, %ymm1
; CHECK-NEXT:    vpaddd %zmm1, %zmm0, %zmm0
; CHECK-NEXT:    vextracti128 $1, %ymm0, %xmm1
; CHECK-NEXT:    vpaddd %zmm1, %zmm0, %zmm0
; CHECK-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[2,3,0,1]
; CHECK-NEXT:    vpaddd %zmm1, %zmm0, %zmm0
; CHECK-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[1,1,2,3]
; CHECK-NEXT:    vpaddd %zmm1, %zmm0, %zmm0
; CHECK-NEXT:    vmovd %xmm0, %eax
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
entry:
  %3 = zext i32 %2 to i64
  br label %vector.body

vector.body:
  %index = phi i64 [ %index.next, %vector.body ], [ 0, %entry ]
  %vec.phi = phi <32 x i32> [ %11, %vector.body ], [ zeroinitializer, %entry ]
  %4 = getelementptr inbounds i8, i8* %0, i64 %index
  %5 = bitcast i8* %4 to <32 x i8>*
  %wide.load = load <32 x i8>, <32 x i8>* %5, align 1
  %6 = sext <32 x i8> %wide.load to <32 x i32>
  %7 = getelementptr inbounds i8, i8* %1, i64 %index
  %8 = bitcast i8* %7 to <32 x i8>*
  %wide.load14 = load <32 x i8>, <32 x i8>* %8, align 1
  %9 = sext <32 x i8> %wide.load14 to <32 x i32>
  %10 = mul nsw <32 x i32> %9, %6
  %11 = add nsw <32 x i32> %10, %vec.phi
  %index.next = add i64 %index, 32
  %12 = icmp eq i64 %index.next, %3
  br i1 %12, label %middle.block, label %vector.body

middle.block:
  %rdx.shuf1 = shufflevector <32 x i32> %11, <32 x i32> undef, <32 x i32> <i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %bin.rdx1 = add <32 x i32> %11, %rdx.shuf1
  %rdx.shuf = shufflevector <32 x i32> %bin.rdx1, <32 x i32> undef, <32 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %bin.rdx = add <32 x i32> %bin.rdx1, %rdx.shuf
  %rdx.shuf15 = shufflevector <32 x i32> %bin.rdx, <32 x i32> undef, <32 x i32> <i32 4, i32 5, i32 6, i32 7, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %bin.rdx32 = add <32 x i32> %bin.rdx, %rdx.shuf15
  %rdx.shuf17 = shufflevector <32 x i32> %bin.rdx32, <32 x i32> undef, <32 x i32> <i32 2, i32 3, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %bin.rdx18 = add <32 x i32> %bin.rdx32, %rdx.shuf17
  %rdx.shuf19 = shufflevector <32 x i32> %bin.rdx18, <32 x i32> undef, <32 x i32> <i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %bin.rdx20 = add <32 x i32> %bin.rdx18, %rdx.shuf19
  %13 = extractelement <32 x i32> %bin.rdx20, i32 0
  ret i32 %13
}

@a = global [1024 x i8] zeroinitializer, align 16
@b = global [1024 x i8] zeroinitializer, align 16

define i32 @sad_16i8_256() "required-vector-width"="256" {
; CHECK-LABEL: sad_16i8_256:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vpxor %xmm0, %xmm0, %xmm0
; CHECK-NEXT:    movq $-1024, %rax # imm = 0xFC00
; CHECK-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; CHECK-NEXT:    .p2align 4, 0x90
; CHECK-NEXT:  .LBB10_1: # %vector.body
; CHECK-NEXT:    # =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    vmovdqu a+1024(%rax), %xmm2
; CHECK-NEXT:    vpsadbw b+1024(%rax), %xmm2, %xmm2
; CHECK-NEXT:    vpaddd %ymm1, %ymm2, %ymm1
; CHECK-NEXT:    addq $4, %rax
; CHECK-NEXT:    jne .LBB10_1
; CHECK-NEXT:  # %bb.2: # %middle.block
; CHECK-NEXT:    vpaddd %ymm0, %ymm1, %ymm0
; CHECK-NEXT:    vextracti128 $1, %ymm0, %xmm1
; CHECK-NEXT:    vpaddd %ymm1, %ymm0, %ymm0
; CHECK-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[2,3,0,1]
; CHECK-NEXT:    vpaddd %ymm1, %ymm0, %ymm0
; CHECK-NEXT:    vphaddd %ymm0, %ymm0, %ymm0
; CHECK-NEXT:    vmovd %xmm0, %eax
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
entry:
  br label %vector.body

vector.body:
  %index = phi i64 [ 0, %entry ], [ %index.next, %vector.body ]
  %vec.phi = phi <16 x i32> [ zeroinitializer, %entry ], [ %10, %vector.body ]
  %0 = getelementptr inbounds [1024 x i8], [1024 x i8]* @a, i64 0, i64 %index
  %1 = bitcast i8* %0 to <16 x i8>*
  %wide.load = load <16 x i8>, <16 x i8>* %1, align 4
  %2 = zext <16 x i8> %wide.load to <16 x i32>
  %3 = getelementptr inbounds [1024 x i8], [1024 x i8]* @b, i64 0, i64 %index
  %4 = bitcast i8* %3 to <16 x i8>*
  %wide.load1 = load <16 x i8>, <16 x i8>* %4, align 4
  %5 = zext <16 x i8> %wide.load1 to <16 x i32>
  %6 = sub nsw <16 x i32> %2, %5
  %7 = icmp sgt <16 x i32> %6, <i32 -1, i32 -1, i32 -1, i32 -1, i32 -1, i32 -1, i32 -1, i32 -1, i32 -1, i32 -1, i32 -1, i32 -1, i32 -1, i32 -1, i32 -1, i32 -1>
  %8 = sub nsw <16 x i32> zeroinitializer, %6
  %9 = select <16 x i1> %7, <16 x i32> %6, <16 x i32> %8
  %10 = add nsw <16 x i32> %9, %vec.phi
  %index.next = add i64 %index, 4
  %11 = icmp eq i64 %index.next, 1024
  br i1 %11, label %middle.block, label %vector.body

middle.block:
  %.lcssa = phi <16 x i32> [ %10, %vector.body ]
  %rdx.shuf = shufflevector <16 x i32> %.lcssa, <16 x i32> undef, <16 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %bin.rdx = add <16 x i32> %.lcssa, %rdx.shuf
  %rdx.shuf2 = shufflevector <16 x i32> %bin.rdx, <16 x i32> undef, <16 x i32> <i32 4, i32 5, i32 6, i32 7, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %bin.rdx2 = add <16 x i32> %bin.rdx, %rdx.shuf2
  %rdx.shuf3 = shufflevector <16 x i32> %bin.rdx2, <16 x i32> undef, <16 x i32> <i32 2, i32 3, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %bin.rdx3 = add <16 x i32> %bin.rdx2, %rdx.shuf3
  %rdx.shuf4 = shufflevector <16 x i32> %bin.rdx3, <16 x i32> undef, <16 x i32> <i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %bin.rdx4 = add <16 x i32> %bin.rdx3, %rdx.shuf4
  %12 = extractelement <16 x i32> %bin.rdx4, i32 0
  ret i32 %12
}

define i32 @sad_16i8_512() "required-vector-width"="512" {
; CHECK-LABEL: sad_16i8_512:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vpxor %xmm0, %xmm0, %xmm0
; CHECK-NEXT:    movq $-1024, %rax # imm = 0xFC00
; CHECK-NEXT:    .p2align 4, 0x90
; CHECK-NEXT:  .LBB11_1: # %vector.body
; CHECK-NEXT:    # =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    vmovdqu a+1024(%rax), %xmm1
; CHECK-NEXT:    vpsadbw b+1024(%rax), %xmm1, %xmm1
; CHECK-NEXT:    vpaddd %zmm0, %zmm1, %zmm0
; CHECK-NEXT:    addq $4, %rax
; CHECK-NEXT:    jne .LBB11_1
; CHECK-NEXT:  # %bb.2: # %middle.block
; CHECK-NEXT:    vextracti64x4 $1, %zmm0, %ymm1
; CHECK-NEXT:    vpaddd %zmm1, %zmm0, %zmm0
; CHECK-NEXT:    vextracti128 $1, %ymm0, %xmm1
; CHECK-NEXT:    vpaddd %zmm1, %zmm0, %zmm0
; CHECK-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[2,3,0,1]
; CHECK-NEXT:    vpaddd %zmm1, %zmm0, %zmm0
; CHECK-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[1,1,2,3]
; CHECK-NEXT:    vpaddd %zmm1, %zmm0, %zmm0
; CHECK-NEXT:    vmovd %xmm0, %eax
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
entry:
  br label %vector.body

vector.body:
  %index = phi i64 [ 0, %entry ], [ %index.next, %vector.body ]
  %vec.phi = phi <16 x i32> [ zeroinitializer, %entry ], [ %10, %vector.body ]
  %0 = getelementptr inbounds [1024 x i8], [1024 x i8]* @a, i64 0, i64 %index
  %1 = bitcast i8* %0 to <16 x i8>*
  %wide.load = load <16 x i8>, <16 x i8>* %1, align 4
  %2 = zext <16 x i8> %wide.load to <16 x i32>
  %3 = getelementptr inbounds [1024 x i8], [1024 x i8]* @b, i64 0, i64 %index
  %4 = bitcast i8* %3 to <16 x i8>*
  %wide.load1 = load <16 x i8>, <16 x i8>* %4, align 4
  %5 = zext <16 x i8> %wide.load1 to <16 x i32>
  %6 = sub nsw <16 x i32> %2, %5
  %7 = icmp sgt <16 x i32> %6, <i32 -1, i32 -1, i32 -1, i32 -1, i32 -1, i32 -1, i32 -1, i32 -1, i32 -1, i32 -1, i32 -1, i32 -1, i32 -1, i32 -1, i32 -1, i32 -1>
  %8 = sub nsw <16 x i32> zeroinitializer, %6
  %9 = select <16 x i1> %7, <16 x i32> %6, <16 x i32> %8
  %10 = add nsw <16 x i32> %9, %vec.phi
  %index.next = add i64 %index, 4
  %11 = icmp eq i64 %index.next, 1024
  br i1 %11, label %middle.block, label %vector.body

middle.block:
  %.lcssa = phi <16 x i32> [ %10, %vector.body ]
  %rdx.shuf = shufflevector <16 x i32> %.lcssa, <16 x i32> undef, <16 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %bin.rdx = add <16 x i32> %.lcssa, %rdx.shuf
  %rdx.shuf2 = shufflevector <16 x i32> %bin.rdx, <16 x i32> undef, <16 x i32> <i32 4, i32 5, i32 6, i32 7, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %bin.rdx2 = add <16 x i32> %bin.rdx, %rdx.shuf2
  %rdx.shuf3 = shufflevector <16 x i32> %bin.rdx2, <16 x i32> undef, <16 x i32> <i32 2, i32 3, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %bin.rdx3 = add <16 x i32> %bin.rdx2, %rdx.shuf3
  %rdx.shuf4 = shufflevector <16 x i32> %bin.rdx3, <16 x i32> undef, <16 x i32> <i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %bin.rdx4 = add <16 x i32> %bin.rdx3, %rdx.shuf4
  %12 = extractelement <16 x i32> %bin.rdx4, i32 0
  ret i32 %12
}

define void @sbto16f32_256(<16 x i16> %a, <16 x float>* %res) "required-vector-width"="256" {
; CHECK-LABEL: sbto16f32_256:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vpmovw2m %ymm0, %k0
; CHECK-NEXT:    kshiftrw $8, %k0, %k1
; CHECK-NEXT:    vpmovm2d %k1, %ymm0
; CHECK-NEXT:    vcvtdq2ps %ymm0, %ymm0
; CHECK-NEXT:    vpmovm2d %k0, %ymm1
; CHECK-NEXT:    vcvtdq2ps %ymm1, %ymm1
; CHECK-NEXT:    vmovaps %ymm1, (%rdi)
; CHECK-NEXT:    vmovaps %ymm0, 32(%rdi)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
  %mask = icmp slt <16 x i16> %a, zeroinitializer
  %1 = sitofp <16 x i1> %mask to <16 x float>
  store <16 x float> %1, <16 x float>* %res
  ret void
}

define void @sbto16f32_512(<16 x i16> %a, <16 x float>* %res) "required-vector-width"="512" {
; CHECK-LABEL: sbto16f32_512:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vpmovw2m %ymm0, %k0
; CHECK-NEXT:    vpmovm2d %k0, %zmm0
; CHECK-NEXT:    vcvtdq2ps %zmm0, %zmm0
; CHECK-NEXT:    vmovaps %zmm0, (%rdi)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
  %mask = icmp slt <16 x i16> %a, zeroinitializer
  %1 = sitofp <16 x i1> %mask to <16 x float>
  store <16 x float> %1, <16 x float>* %res
  ret void
}

define void @sbto16f64_256(<16 x i16> %a, <16 x double>* %res)  "required-vector-width"="256" {
; CHECK-LABEL: sbto16f64_256:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vpmovw2m %ymm0, %k0
; CHECK-NEXT:    kshiftrw $8, %k0, %k1
; CHECK-NEXT:    vpmovm2d %k1, %ymm0
; CHECK-NEXT:    vcvtdq2pd %xmm0, %ymm1
; CHECK-NEXT:    vextracti128 $1, %ymm0, %xmm0
; CHECK-NEXT:    vcvtdq2pd %xmm0, %ymm0
; CHECK-NEXT:    vpmovm2d %k0, %ymm2
; CHECK-NEXT:    vcvtdq2pd %xmm2, %ymm3
; CHECK-NEXT:    vextracti128 $1, %ymm2, %xmm2
; CHECK-NEXT:    vcvtdq2pd %xmm2, %ymm2
; CHECK-NEXT:    vmovaps %ymm2, 32(%rdi)
; CHECK-NEXT:    vmovaps %ymm3, (%rdi)
; CHECK-NEXT:    vmovaps %ymm0, 96(%rdi)
; CHECK-NEXT:    vmovaps %ymm1, 64(%rdi)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
  %mask = icmp slt <16 x i16> %a, zeroinitializer
  %1 = sitofp <16 x i1> %mask to <16 x double>
  store <16 x double> %1, <16 x double>* %res
  ret void
}

define void @sbto16f64_512(<16 x i16> %a, <16 x double>* %res)  "required-vector-width"="512" {
; CHECK-LABEL: sbto16f64_512:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vpmovw2m %ymm0, %k0
; CHECK-NEXT:    vpmovm2d %k0, %zmm0
; CHECK-NEXT:    vcvtdq2pd %ymm0, %zmm1
; CHECK-NEXT:    vextracti64x4 $1, %zmm0, %ymm0
; CHECK-NEXT:    vcvtdq2pd %ymm0, %zmm0
; CHECK-NEXT:    vmovaps %zmm0, 64(%rdi)
; CHECK-NEXT:    vmovaps %zmm1, (%rdi)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
  %mask = icmp slt <16 x i16> %a, zeroinitializer
  %1 = sitofp <16 x i1> %mask to <16 x double>
  store <16 x double> %1, <16 x double>* %res
  ret void
}

define void @ubto16f32_256(<16 x i16> %a, <16 x float>* %res) "required-vector-width"="256" {
; CHECK-LABEL: ubto16f32_256:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vpmovw2m %ymm0, %k0
; CHECK-NEXT:    kshiftrw $8, %k0, %k1
; CHECK-NEXT:    vpmovm2d %k1, %ymm0
; CHECK-NEXT:    vpsrld $31, %ymm0, %ymm0
; CHECK-NEXT:    vcvtdq2ps %ymm0, %ymm0
; CHECK-NEXT:    vpmovm2d %k0, %ymm1
; CHECK-NEXT:    vpsrld $31, %ymm1, %ymm1
; CHECK-NEXT:    vcvtdq2ps %ymm1, %ymm1
; CHECK-NEXT:    vmovaps %ymm1, (%rdi)
; CHECK-NEXT:    vmovaps %ymm0, 32(%rdi)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
  %mask = icmp slt <16 x i16> %a, zeroinitializer
  %1 = uitofp <16 x i1> %mask to <16 x float>
  store <16 x float> %1, <16 x float>* %res
  ret void
}

define void @ubto16f32_512(<16 x i16> %a, <16 x float>* %res) "required-vector-width"="512" {
; CHECK-LABEL: ubto16f32_512:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vpmovw2m %ymm0, %k0
; CHECK-NEXT:    vpmovm2d %k0, %zmm0
; CHECK-NEXT:    vpsrld $31, %zmm0, %zmm0
; CHECK-NEXT:    vcvtdq2ps %zmm0, %zmm0
; CHECK-NEXT:    vmovaps %zmm0, (%rdi)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
  %mask = icmp slt <16 x i16> %a, zeroinitializer
  %1 = uitofp <16 x i1> %mask to <16 x float>
  store <16 x float> %1, <16 x float>* %res
  ret void
}

define void @ubto16f64_256(<16 x i16> %a, <16 x double>* %res) "required-vector-width"="256" {
; CHECK-LABEL: ubto16f64_256:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vpmovw2m %ymm0, %k0
; CHECK-NEXT:    kshiftrw $8, %k0, %k1
; CHECK-NEXT:    vpmovm2d %k1, %ymm0
; CHECK-NEXT:    vpsrld $31, %ymm0, %ymm0
; CHECK-NEXT:    vcvtdq2pd %xmm0, %ymm1
; CHECK-NEXT:    vextracti128 $1, %ymm0, %xmm0
; CHECK-NEXT:    vcvtdq2pd %xmm0, %ymm0
; CHECK-NEXT:    vpmovm2d %k0, %ymm2
; CHECK-NEXT:    vpsrld $31, %ymm2, %ymm2
; CHECK-NEXT:    vcvtdq2pd %xmm2, %ymm3
; CHECK-NEXT:    vextracti128 $1, %ymm2, %xmm2
; CHECK-NEXT:    vcvtdq2pd %xmm2, %ymm2
; CHECK-NEXT:    vmovaps %ymm2, 32(%rdi)
; CHECK-NEXT:    vmovaps %ymm3, (%rdi)
; CHECK-NEXT:    vmovaps %ymm0, 96(%rdi)
; CHECK-NEXT:    vmovaps %ymm1, 64(%rdi)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
  %mask = icmp slt <16 x i16> %a, zeroinitializer
  %1 = uitofp <16 x i1> %mask to <16 x double>
  store <16 x double> %1, <16 x double>* %res
  ret void
}

define void @ubto16f64_512(<16 x i16> %a, <16 x double>* %res) "required-vector-width"="512" {
; CHECK-LABEL: ubto16f64_512:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vpmovw2m %ymm0, %k0
; CHECK-NEXT:    vpmovm2d %k0, %zmm0
; CHECK-NEXT:    vpsrld $31, %zmm0, %zmm0
; CHECK-NEXT:    vcvtdq2pd %ymm0, %zmm1
; CHECK-NEXT:    vextracti64x4 $1, %zmm0, %ymm0
; CHECK-NEXT:    vcvtdq2pd %ymm0, %zmm0
; CHECK-NEXT:    vmovaps %zmm0, 64(%rdi)
; CHECK-NEXT:    vmovaps %zmm1, (%rdi)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
  %mask = icmp slt <16 x i16> %a, zeroinitializer
  %1 = uitofp <16 x i1> %mask to <16 x double>
  store <16 x double> %1, <16 x double>* %res
  ret void
}

define <16 x i16> @test_16f32toub_256(<16 x float>* %ptr, <16 x i16> %passthru) "required-vector-width"="256" {
; CHECK-LABEL: test_16f32toub_256:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vcvttps2dq (%rdi), %ymm1
; CHECK-NEXT:    vpmovdw %ymm1, %xmm1
; CHECK-NEXT:    vcvttps2dq 32(%rdi), %ymm2
; CHECK-NEXT:    vpmovdw %ymm2, %xmm2
; CHECK-NEXT:    vinserti128 $1, %xmm2, %ymm1, %ymm1
; CHECK-NEXT:    vpsllw $15, %ymm1, %ymm1
; CHECK-NEXT:    vpmovw2m %ymm1, %k1
; CHECK-NEXT:    vmovdqu16 %ymm0, %ymm0 {%k1} {z}
; CHECK-NEXT:    retq
  %a = load <16 x float>, <16 x float>* %ptr
  %mask = fptoui <16 x float> %a to <16 x i1>
  %select = select <16 x i1> %mask, <16 x i16> %passthru, <16 x i16> zeroinitializer
  ret <16 x i16> %select
}

define <16 x i16> @test_16f32toub_512(<16 x float>* %ptr, <16 x i16> %passthru) "required-vector-width"="512" {
; CHECK-LABEL: test_16f32toub_512:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vcvttps2dq (%rdi), %zmm1
; CHECK-NEXT:    vpslld $31, %zmm1, %zmm1
; CHECK-NEXT:    vpmovd2m %zmm1, %k1
; CHECK-NEXT:    vmovdqu16 %ymm0, %ymm0 {%k1} {z}
; CHECK-NEXT:    retq
  %a = load <16 x float>, <16 x float>* %ptr
  %mask = fptoui <16 x float> %a to <16 x i1>
  %select = select <16 x i1> %mask, <16 x i16> %passthru, <16 x i16> zeroinitializer
  ret <16 x i16> %select
}

define <16 x i16> @test_16f32tosb_256(<16 x float>* %ptr, <16 x i16> %passthru) "required-vector-width"="256" {
; CHECK-LABEL: test_16f32tosb_256:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vcvttps2dq (%rdi), %ymm1
; CHECK-NEXT:    vpmovdw %ymm1, %xmm1
; CHECK-NEXT:    vcvttps2dq 32(%rdi), %ymm2
; CHECK-NEXT:    vpmovdw %ymm2, %xmm2
; CHECK-NEXT:    vinserti128 $1, %xmm2, %ymm1, %ymm1
; CHECK-NEXT:    vpsllw $15, %ymm1, %ymm1
; CHECK-NEXT:    vpmovw2m %ymm1, %k1
; CHECK-NEXT:    vmovdqu16 %ymm0, %ymm0 {%k1} {z}
; CHECK-NEXT:    retq
  %a = load <16 x float>, <16 x float>* %ptr
  %mask = fptosi <16 x float> %a to <16 x i1>
  %select = select <16 x i1> %mask, <16 x i16> %passthru, <16 x i16> zeroinitializer
  ret <16 x i16> %select
}

define <16 x i16> @test_16f32tosb_512(<16 x float>* %ptr, <16 x i16> %passthru) "required-vector-width"="512" {
; CHECK-LABEL: test_16f32tosb_512:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vcvttps2dq (%rdi), %zmm1
; CHECK-NEXT:    vpmovd2m %zmm1, %k1
; CHECK-NEXT:    vmovdqu16 %ymm0, %ymm0 {%k1} {z}
; CHECK-NEXT:    retq
  %a = load <16 x float>, <16 x float>* %ptr
  %mask = fptosi <16 x float> %a to <16 x i1>
  %select = select <16 x i1> %mask, <16 x i16> %passthru, <16 x i16> zeroinitializer
  ret <16 x i16> %select
}
