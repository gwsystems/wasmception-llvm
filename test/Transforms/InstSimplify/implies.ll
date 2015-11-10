; RUN: opt -S %s -instsimplify | FileCheck %s

; A ==> A -> true
define i1 @test(i32 %length.i, i32 %i) {
; CHECK-LABEL: @test
; CHECK: ret i1 true
  %var29 = icmp slt i32 %i, %length.i
  %res = icmp uge i1 %var29, %var29
  ret i1 %res
}

; i +_{nsw} C_{>0} <s L ==> i <s L -> true
define i1 @test2(i32 %length.i, i32 %i) {
; CHECK-LABEL: @test2
; CHECK: ret i1 true
  %iplus1 = add nsw i32 %i, 1
  %var29 = icmp slt i32 %i, %length.i
  %var30 = icmp slt i32 %iplus1, %length.i
  %res = icmp ule i1 %var30, %var29
  ret i1 %res
}

; i + C_{>0} <s L ==> i <s L -> unknown without the nsw
define i1 @test2_neg(i32 %length.i, i32 %i) {
; CHECK-LABEL: @test2_neg
; CHECK:   ret i1 %res
  %iplus1 = add i32 %i, 1
  %var29 = icmp slt i32 %i, %length.i
  %var30 = icmp slt i32 %iplus1, %length.i
  %res = icmp ule i1 %var30, %var29
  ret i1 %res
}

; sle is not implication
define i1 @test2_neg2(i32 %length.i, i32 %i) {
; CHECK-LABEL: @test2_neg2
; CHECK:   ret i1 %res
  %iplus1 = add i32 %i, 1
  %var29 = icmp slt i32 %i, %length.i
  %var30 = icmp slt i32 %iplus1, %length.i
  %res = icmp sle i1 %var30, %var29
  ret i1 %res
}

; The binary operator has to be an add
define i1 @test2_neg3(i32 %length.i, i32 %i) {
; CHECK-LABEL: @test2_neg3
; CHECK:   ret i1 %res
  %iplus1 = sub nsw i32 %i, 1
  %var29 = icmp slt i32 %i, %length.i
  %var30 = icmp slt i32 %iplus1, %length.i
  %res = icmp ule i1 %var30, %var29
  ret i1 %res
}

; i +_{nsw} C_{>0} <s L ==> i <s L -> true
; With an inverted conditional (ule B A rather than canonical ugt A B
define i1 @test3(i32 %length.i, i32 %i) {
; CHECK-LABEL: @test3
; CHECK: ret i1 true
  %iplus1 = add nsw i32 %i, 1
  %var29 = icmp slt i32 %i, %length.i
  %var30 = icmp slt i32 %iplus1, %length.i
  %res = icmp uge i1 %var29, %var30
  ret i1 %res
}

; i +_{nuw} C <u L ==> i <u L
define i1 @test4(i32 %length.i, i32 %i) {
; CHECK-LABEL: @test4
; CHECK: ret i1 true
  %iplus1 = add nuw i32 %i, 1
  %var29 = icmp ult i32 %i, %length.i
  %var30 = icmp ult i32 %iplus1, %length.i
  %res = icmp ule i1 %var30, %var29
  ret i1 %res
}

; A ==> A for vectors
define <4 x i1> @test5(<4 x i1> %vec) {
; CHECK-LABEL: @test5
; CHECK: ret <4 x i1> <i1 true, i1 true, i1 true, i1 true>
  %res = icmp ule <4 x i1> %vec, %vec
  ret <4 x i1> %res
}

; Don't crash on vector inputs - pr25040
define <4 x i1> @test6(<4 x i1> %a, <4 x i1> %b) {
; CHECK-LABEL: @test6
; CHECK: ret <4 x i1> %res
  %res = icmp ule <4 x i1> %a, %b
  ret <4 x i1> %res
}

; i +_{nsw} 1 <s L  ==> i < L +_{nsw} 1
define i1 @test7(i32 %length.i, i32 %i) {
; CHECK-LABEL: @test7(
; CHECK: ret i1 true
  %iplus1 = add nsw i32 %i, 1
  %len.plus.one = add nsw i32 %length.i, 1
  %var29 = icmp slt i32 %i, %len.plus.one
  %var30 = icmp slt i32 %iplus1, %length.i
  %res = icmp ule i1 %var30, %var29
  ret i1 %res
}

; i +_{nuw} 1 <s L  ==> i < L +_{nuw} 1
define i1 @test8(i32 %length.i, i32 %i) {
; CHECK-LABEL: @test8(
; CHECK: ret i1 true
  %iplus1 = add nuw i32 %i, 1
  %len.plus.one = add nuw i32 %length.i, 1
  %var29 = icmp ult i32 %i, %len.plus.one
  %var30 = icmp ult i32 %iplus1, %length.i
  %res = icmp ule i1 %var30, %var29
  ret i1 %res
}

; i +_{nuw} C <s L ==> i < L, even if C is negative
define i1 @test9(i32 %length.i, i32 %i) {
; CHECK-LABEL: @test9(
; CHECK: ret i1 true
  %iplus1 = add nuw i32 %i, -100
  %var29 = icmp ult i32 %i, %length.i
  %var30 = icmp ult i32 %iplus1, %length.i
  %res = icmp ule i1 %var30, %var29
  ret i1 %res
}

define i1 @test10(i32 %length.i, i32 %x.full) {
; CHECK-LABEL: @test10(
; CHECK:  ret i1 true

  %x = and i32 %x.full, 4294901760  ;; 4294901760 == 0xffff0000
  %large = or i32 %x, 100
  %small = or i32 %x, 90
  %known = icmp ult i32 %large, %length.i
  %to.prove = icmp ult i32 %small, %length.i
  %res = icmp ule i1 %known, %to.prove
  ret i1 %res
}

define i1 @test11(i32 %length.i, i32 %x) {
; CHECK-LABEL: @test11(
; CHECK: %res = icmp ule i1 %known, %to.prove
; CHECK: ret i1 %res

  %large = or i32 %x, 100
  %small = or i32 %x, 90
  %known = icmp ult i32 %large, %length.i
  %to.prove = icmp ult i32 %small, %length.i
  %res = icmp ule i1 %known, %to.prove
  ret i1 %res
}

define i1 @test12(i32 %length.i, i32 %x.full) {
; CHECK-LABEL: @test12(
; CHECK: %res = icmp ule i1 %known, %to.prove
; CHECK: ret i1 %res

  %x = and i32 %x.full, 4294901760  ;; 4294901760 == 0xffff0000
  %large = or i32 %x, 65536 ;; 65536 == 0x00010000
  %small = or i32 %x, 90
  %known = icmp ult i32 %large, %length.i
  %to.prove = icmp ult i32 %small, %length.i
  %res = icmp ule i1 %known, %to.prove
  ret i1 %res
}

define i1 @test13(i32 %length.i, i32 %x) {
; CHECK-LABEL: @test13(
; CHECK:  ret i1 true

  %large = add nuw i32 %x, 100
  %small = add nuw i32 %x, 90
  %known = icmp ult i32 %large, %length.i
  %to.prove = icmp ult i32 %small, %length.i
  %res = icmp ule i1 %known, %to.prove
  ret i1 %res
}

define i1 @test14(i32 %length.i, i32 %x.full) {
; CHECK-LABEL: @test14(
; CHECK:  ret i1 true

  %x = and i32 %x.full, 4294905615  ;; 4294905615 == 0xffff0f0f
  %large = or i32 %x, 8224 ;; == 0x2020
  %small = or i32 %x, 4112 ;; == 0x1010
  %known = icmp ult i32 %large, %length.i
  %to.prove = icmp ult i32 %small, %length.i
  %res = icmp ule i1 %known, %to.prove
  ret i1 %res
}

define i1 @test15(i32 %length.i, i32 %x) {
; CHECK-LABEL: @test15(
; CHECK:  %res = icmp ule i1 %known, %to.prove
; CHECK:  ret i1 %res

  %large = add nuw i32 %x, 100
  %small = add nuw i32 %x, 110
  %known = icmp ult i32 %large, %length.i
  %to.prove = icmp ult i32 %small, %length.i
  %res = icmp ule i1 %known, %to.prove
  ret i1 %res
}

; X >=(s) Y == X ==> Y (i1 1 becomes -1 for reasoning)
define i1 @test_sge(i32 %length.i, i32 %i) {
; CHECK-LABEL: @test_sge
; CHECK: ret i1 true
  %iplus1 = add nsw nuw i32 %i, 1
  %var29 = icmp ult i32 %i, %length.i
  %var30 = icmp ult i32 %iplus1, %length.i
  %res = icmp sge i1 %var30, %var29
  ret i1 %res
}
