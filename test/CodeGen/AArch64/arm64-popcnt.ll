; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=arm64-eabi -aarch64-neon-syntax=apple | FileCheck %s
; RUN: llc < %s -mtriple=aarch64-eabi -mattr -neon -aarch64-neon-syntax=apple | FileCheck -check-prefix=CHECK-NONEON %s

define i32 @cnt32_advsimd(i32 %x) nounwind readnone {
; CHECK-LABEL: cnt32_advsimd:
; CHECK:       // %bb.0:
; CHECK-NEXT:    mov w8, w0
; CHECK-NEXT:    fmov d0, x8
; CHECK-NEXT:    cnt.8b v0, v0
; CHECK-NEXT:    uaddlv.8b h0, v0
; CHECK-NEXT:    fmov w0, s0
; CHECK-NEXT:    ret
;
; CHECK-NONEON-LABEL: cnt32_advsimd:
; CHECK-NONEON:       // %bb.0:
; CHECK-NONEON-NEXT:    lsr w8, w0, #1
; CHECK-NONEON-NEXT:    and w8, w8, #0x55555555
; CHECK-NONEON-NEXT:    sub w8, w0, w8
; CHECK-NONEON-NEXT:    and w9, w8, #0x33333333
; CHECK-NONEON-NEXT:    lsr w8, w8, #2
; CHECK-NONEON-NEXT:    and w8, w8, #0x33333333
; CHECK-NONEON-NEXT:    add w8, w9, w8
; CHECK-NONEON-NEXT:    add w8, w8, w8, lsr #4
; CHECK-NONEON-NEXT:    and w8, w8, #0xf0f0f0f
; CHECK-NONEON-NEXT:    mov w9, #16843009
; CHECK-NONEON-NEXT:    mul w8, w8, w9
; CHECK-NONEON-NEXT:    lsr w0, w8, #24
; CHECK-NONEON-NEXT:    ret
  %cnt = tail call i32 @llvm.ctpop.i32(i32 %x)
  ret i32 %cnt
}

define i32 @cnt32_advsimd_2(<2 x i32> %x) {
; CHECK-LABEL: cnt32_advsimd_2:
; CHECK:       // %bb.0:
; CHECK-NEXT:    // kill: def $d0 killed $d0 def $q0
; CHECK-NEXT:    fmov w0, s0
; CHECK-NEXT:    fmov d0, x0
; CHECK-NEXT:    cnt.8b v0, v0
; CHECK-NEXT:    uaddlv.8b h0, v0
; CHECK-NEXT:    fmov w0, s0
; CHECK-NEXT:    ret
;
; CHECK-NONEON-LABEL: cnt32_advsimd_2:
; CHECK-NONEON:       // %bb.0:
; CHECK-NONEON-NEXT:    lsr w8, w0, #1
; CHECK-NONEON-NEXT:    and w8, w8, #0x55555555
; CHECK-NONEON-NEXT:    sub w8, w0, w8
; CHECK-NONEON-NEXT:    and w9, w8, #0x33333333
; CHECK-NONEON-NEXT:    lsr w8, w8, #2
; CHECK-NONEON-NEXT:    and w8, w8, #0x33333333
; CHECK-NONEON-NEXT:    add w8, w9, w8
; CHECK-NONEON-NEXT:    add w8, w8, w8, lsr #4
; CHECK-NONEON-NEXT:    and w8, w8, #0xf0f0f0f
; CHECK-NONEON-NEXT:    mov w9, #16843009
; CHECK-NONEON-NEXT:    mul w8, w8, w9
; CHECK-NONEON-NEXT:    lsr w0, w8, #24
; CHECK-NONEON-NEXT:    ret
  %1 = extractelement <2 x i32> %x, i64 0
  %2 = tail call i32 @llvm.ctpop.i32(i32 %1)
  ret i32 %2
}

define i64 @cnt64_advsimd(i64 %x) nounwind readnone {
; CHECK-LABEL: cnt64_advsimd:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fmov d0, x0
; CHECK-NEXT:    cnt.8b v0, v0
; CHECK-NEXT:    uaddlv.8b h0, v0
; CHECK-NEXT:    fmov w0, s0
; CHECK-NEXT:    ret
;
; CHECK-NONEON-LABEL: cnt64_advsimd:
; CHECK-NONEON:       // %bb.0:
; CHECK-NONEON-NEXT:    lsr x8, x0, #1
; CHECK-NONEON-NEXT:    and x8, x8, #0x5555555555555555
; CHECK-NONEON-NEXT:    sub x8, x0, x8
; CHECK-NONEON-NEXT:    and x9, x8, #0x3333333333333333
; CHECK-NONEON-NEXT:    lsr x8, x8, #2
; CHECK-NONEON-NEXT:    and x8, x8, #0x3333333333333333
; CHECK-NONEON-NEXT:    add x8, x9, x8
; CHECK-NONEON-NEXT:    add x8, x8, x8, lsr #4
; CHECK-NONEON-NEXT:    and x8, x8, #0xf0f0f0f0f0f0f0f
; CHECK-NONEON-NEXT:    mov x9, #72340172838076673
; CHECK-NONEON-NEXT:    mul x8, x8, x9
; CHECK-NONEON-NEXT:    lsr x0, x8, #56
; CHECK-NONEON-NEXT:    ret
  %cnt = tail call i64 @llvm.ctpop.i64(i64 %x)
  ret i64 %cnt
}

; Do not use AdvSIMD when -mno-implicit-float is specified.
; rdar://9473858

define i32 @cnt32(i32 %x) nounwind readnone noimplicitfloat {
; CHECK-LABEL: cnt32:
; CHECK:       // %bb.0:
; CHECK-NEXT:    lsr w8, w0, #1
; CHECK-NEXT:    and w8, w8, #0x55555555
; CHECK-NEXT:    sub w8, w0, w8
; CHECK-NEXT:    and w9, w8, #0x33333333
; CHECK-NEXT:    lsr w8, w8, #2
; CHECK-NEXT:    and w8, w8, #0x33333333
; CHECK-NEXT:    add w8, w9, w8
; CHECK-NEXT:    add w8, w8, w8, lsr #4
; CHECK-NEXT:    and w8, w8, #0xf0f0f0f
; CHECK-NEXT:    mov w9, #16843009
; CHECK-NEXT:    mul w8, w8, w9
; CHECK-NEXT:    lsr w0, w8, #24
; CHECK-NEXT:    ret
;
; CHECK-NONEON-LABEL: cnt32:
; CHECK-NONEON:       // %bb.0:
; CHECK-NONEON-NEXT:    lsr w8, w0, #1
; CHECK-NONEON-NEXT:    and w8, w8, #0x55555555
; CHECK-NONEON-NEXT:    sub w8, w0, w8
; CHECK-NONEON-NEXT:    and w9, w8, #0x33333333
; CHECK-NONEON-NEXT:    lsr w8, w8, #2
; CHECK-NONEON-NEXT:    and w8, w8, #0x33333333
; CHECK-NONEON-NEXT:    add w8, w9, w8
; CHECK-NONEON-NEXT:    add w8, w8, w8, lsr #4
; CHECK-NONEON-NEXT:    and w8, w8, #0xf0f0f0f
; CHECK-NONEON-NEXT:    mov w9, #16843009
; CHECK-NONEON-NEXT:    mul w8, w8, w9
; CHECK-NONEON-NEXT:    lsr w0, w8, #24
; CHECK-NONEON-NEXT:    ret
  %cnt = tail call i32 @llvm.ctpop.i32(i32 %x)
  ret i32 %cnt
}

define i64 @cnt64(i64 %x) nounwind readnone noimplicitfloat {
; CHECK-LABEL: cnt64:
; CHECK:       // %bb.0:
; CHECK-NEXT:    lsr x8, x0, #1
; CHECK-NEXT:    and x8, x8, #0x5555555555555555
; CHECK-NEXT:    sub x8, x0, x8
; CHECK-NEXT:    and x9, x8, #0x3333333333333333
; CHECK-NEXT:    lsr x8, x8, #2
; CHECK-NEXT:    and x8, x8, #0x3333333333333333
; CHECK-NEXT:    add x8, x9, x8
; CHECK-NEXT:    add x8, x8, x8, lsr #4
; CHECK-NEXT:    and x8, x8, #0xf0f0f0f0f0f0f0f
; CHECK-NEXT:    mov x9, #72340172838076673
; CHECK-NEXT:    mul x8, x8, x9
; CHECK-NEXT:    lsr x0, x8, #56
; CHECK-NEXT:    ret
;
; CHECK-NONEON-LABEL: cnt64:
; CHECK-NONEON:       // %bb.0:
; CHECK-NONEON-NEXT:    lsr x8, x0, #1
; CHECK-NONEON-NEXT:    and x8, x8, #0x5555555555555555
; CHECK-NONEON-NEXT:    sub x8, x0, x8
; CHECK-NONEON-NEXT:    and x9, x8, #0x3333333333333333
; CHECK-NONEON-NEXT:    lsr x8, x8, #2
; CHECK-NONEON-NEXT:    and x8, x8, #0x3333333333333333
; CHECK-NONEON-NEXT:    add x8, x9, x8
; CHECK-NONEON-NEXT:    add x8, x8, x8, lsr #4
; CHECK-NONEON-NEXT:    and x8, x8, #0xf0f0f0f0f0f0f0f
; CHECK-NONEON-NEXT:    mov x9, #72340172838076673
; CHECK-NONEON-NEXT:    mul x8, x8, x9
; CHECK-NONEON-NEXT:    lsr x0, x8, #56
; CHECK-NONEON-NEXT:    ret
  %cnt = tail call i64 @llvm.ctpop.i64(i64 %x)
  ret i64 %cnt
}

define i32 @ctpop_eq_one(i64 %x) nounwind readnone {
; CHECK-LABEL: ctpop_eq_one:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fmov d0, x0
; CHECK-NEXT:    cnt.8b v0, v0
; CHECK-NEXT:    uaddlv.8b h0, v0
; CHECK-NEXT:    fmov w8, s0
; CHECK-NEXT:    cmp x8, #1 // =1
; CHECK-NEXT:    cset w0, eq
; CHECK-NEXT:    ret
;
; CHECK-NONEON-LABEL: ctpop_eq_one:
; CHECK-NONEON:       // %bb.0:
; CHECK-NONEON-NEXT:    lsr x8, x0, #1
; CHECK-NONEON-NEXT:    and x8, x8, #0x5555555555555555
; CHECK-NONEON-NEXT:    sub x8, x0, x8
; CHECK-NONEON-NEXT:    and x9, x8, #0x3333333333333333
; CHECK-NONEON-NEXT:    lsr x8, x8, #2
; CHECK-NONEON-NEXT:    and x8, x8, #0x3333333333333333
; CHECK-NONEON-NEXT:    add x8, x9, x8
; CHECK-NONEON-NEXT:    add x8, x8, x8, lsr #4
; CHECK-NONEON-NEXT:    and x8, x8, #0xf0f0f0f0f0f0f0f
; CHECK-NONEON-NEXT:    mov x9, #72340172838076673
; CHECK-NONEON-NEXT:    mul x8, x8, x9
; CHECK-NONEON-NEXT:    lsr x8, x8, #56
; CHECK-NONEON-NEXT:    cmp x8, #1 // =1
; CHECK-NONEON-NEXT:    cset w0, eq
; CHECK-NONEON-NEXT:    ret
  %count = tail call i64 @llvm.ctpop.i64(i64 %x)
  %cmp = icmp eq i64 %count, 1
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}


declare i32 @llvm.ctpop.i32(i32) nounwind readnone
declare i64 @llvm.ctpop.i64(i64) nounwind readnone
