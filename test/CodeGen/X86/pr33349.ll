; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mattr=+avx512f | FileCheck %s --check-prefix=KNL
; RUN: llc < %s -mattr=+avx512f,+avx512vl,+avx512bw,+avx512dq | FileCheck %s --check-prefix=SKX

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

 define void @test(<4 x i1> %m, <4 x x86_fp80> %v, <4 x x86_fp80>*%p) local_unnamed_addr {
; KNL-LABEL: test:
; KNL:       # BB#0: # %bb
; KNL-NEXT:    vpextrb $0, %xmm0, %eax
; KNL-NEXT:    testb $1, %al
; KNL-NEXT:    fld1
; KNL-NEXT:    fldz
; KNL-NEXT:    fld %st(0)
; KNL-NEXT:    fcmovne %st(2), %st(0)
; KNL-NEXT:    vpextrb $4, %xmm0, %eax
; KNL-NEXT:    testb $1, %al
; KNL-NEXT:    fld %st(1)
; KNL-NEXT:    fcmovne %st(3), %st(0)
; KNL-NEXT:    vpextrb $8, %xmm0, %eax
; KNL-NEXT:    testb $1, %al
; KNL-NEXT:    fld %st(2)
; KNL-NEXT:    fcmovne %st(4), %st(0)
; KNL-NEXT:    vpextrb $12, %xmm0, %eax
; KNL-NEXT:    testb $1, %al
; KNL-NEXT:    fxch %st(3)
; KNL-NEXT:    fcmovne %st(4), %st(0)
; KNL-NEXT:    fstp %st(4)
; KNL-NEXT:    fxch %st(3)
; KNL-NEXT:    fstpt 30(%rdi)
; KNL-NEXT:    fxch %st(1)
; KNL-NEXT:    fstpt 20(%rdi)
; KNL-NEXT:    fxch %st(1)
; KNL-NEXT:    fstpt 10(%rdi)
; KNL-NEXT:    fstpt (%rdi)
; KNL-NEXT:    retq
;
; SKX-LABEL: test:
; SKX:       # BB#0: # %bb
; SKX-NEXT:    vpslld $31, %xmm0, %xmm0
; SKX-NEXT:    vptestmd %xmm0, %xmm0, %k0
; SKX-NEXT:    kshiftrw $2, %k0, %k1
; SKX-NEXT:    kshiftlw $15, %k1, %k2
; SKX-NEXT:    kshiftrw $15, %k2, %k2
; SKX-NEXT:    kshiftlw $15, %k2, %k2
; SKX-NEXT:    kshiftrw $15, %k2, %k2
; SKX-NEXT:    kmovd %k2, %eax
; SKX-NEXT:    testb $1, %al
; SKX-NEXT:    fld1
; SKX-NEXT:    fldz
; SKX-NEXT:    fld %st(0)
; SKX-NEXT:    fcmovne %st(2), %st(0)
; SKX-NEXT:    kshiftlw $14, %k1, %k1
; SKX-NEXT:    kshiftrw $15, %k1, %k1
; SKX-NEXT:    kshiftlw $15, %k1, %k1
; SKX-NEXT:    kshiftrw $15, %k1, %k1
; SKX-NEXT:    kmovd %k1, %eax
; SKX-NEXT:    testb $1, %al
; SKX-NEXT:    fld %st(1)
; SKX-NEXT:    fcmovne %st(3), %st(0)
; SKX-NEXT:    kshiftlw $15, %k0, %k1
; SKX-NEXT:    kshiftrw $15, %k1, %k1
; SKX-NEXT:    kshiftlw $15, %k1, %k1
; SKX-NEXT:    kshiftrw $15, %k1, %k1
; SKX-NEXT:    kmovd %k1, %eax
; SKX-NEXT:    testb $1, %al
; SKX-NEXT:    fld %st(2)
; SKX-NEXT:    fcmovne %st(4), %st(0)
; SKX-NEXT:    kshiftlw $14, %k0, %k0
; SKX-NEXT:    kshiftrw $15, %k0, %k0
; SKX-NEXT:    kshiftlw $15, %k0, %k0
; SKX-NEXT:    kshiftrw $15, %k0, %k0
; SKX-NEXT:    kmovd %k0, %eax
; SKX-NEXT:    testb $1, %al
; SKX-NEXT:    fxch %st(3)
; SKX-NEXT:    fcmovne %st(4), %st(0)
; SKX-NEXT:    fstp %st(4)
; SKX-NEXT:    fxch %st(3)
; SKX-NEXT:    fstpt 10(%rdi)
; SKX-NEXT:    fxch %st(1)
; SKX-NEXT:    fstpt (%rdi)
; SKX-NEXT:    fxch %st(1)
; SKX-NEXT:    fstpt 30(%rdi)
; SKX-NEXT:    fstpt 20(%rdi)
; SKX-NEXT:    retq
 bb:
   %tmp = select <4 x i1> %m, <4 x x86_fp80> <x86_fp80 0xK3FFF8000000000000000, x86_fp80 0xK3FFF8000000000000000, x86_fp80 0xK3FFF8000000000000000, x86_fp80             0xK3FFF8000000000000000>, <4 x x86_fp80> zeroinitializer
   store <4 x x86_fp80> %tmp, <4 x x86_fp80>* %p, align 16
   ret void
 }

