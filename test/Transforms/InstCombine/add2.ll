; RUN: opt < %s -instcombine -S | FileCheck %s

define i64 @test1(i64 %A, i32 %B) {
        %tmp12 = zext i32 %B to i64
        %tmp3 = shl i64 %tmp12, 32
        %tmp5 = add i64 %tmp3, %A
        %tmp6 = and i64 %tmp5, 123
        ret i64 %tmp6
; CHECK-LABEL: @test1(
; CHECK-NEXT: and i64 %A, 123
; CHECK-NEXT: ret i64
}

define i32 @test2(i32 %A) {
  %B = and i32 %A, 7
  %C = and i32 %A, 32
  %F = add i32 %B, %C
  ret i32 %F
; CHECK-LABEL: @test2(
; CHECK-NEXT: and i32 %A, 39
; CHECK-NEXT: ret i32
}

define i32 @test3(i32 %A) {
  %B = and i32 %A, 128
  %C = lshr i32 %A, 30
  %F = add i32 %B, %C
  ret i32 %F
; CHECK-LABEL: @test3(
; CHECK-NEXT: and
; CHECK-NEXT: lshr
; CHECK-NEXT: or i32 %B, %C
; CHECK-NEXT: ret i32
}

define i32 @test4(i32 %A) {
  %B = add nuw i32 %A, %A
  ret i32 %B
; CHECK-LABEL: @test4(
; CHECK-NEXT: %B = shl nuw i32 %A, 1
; CHECK-NEXT: ret i32 %B
}

define <2 x i1> @test5(<2 x i1> %A, <2 x i1> %B) {
  %add = add <2 x i1> %A, %B
  ret <2 x i1> %add
; CHECK-LABEL: @test5(
; CHECK-NEXT: %add = xor <2 x i1> %A, %B
; CHECK-NEXT: ret <2 x i1> %add
}

define <2 x i64> @test6(<2 x i64> %A) {
  %shl = shl <2 x i64> %A, <i64 2, i64 3>
  %add = add <2 x i64> %shl, %A
  ret <2 x i64> %add
; CHECK-LABEL: @test6(
; CHECK-NEXT: %add = mul <2 x i64> %A, <i64 5, i64 9>
; CHECK-NEXT: ret <2 x i64> %add
}

define <2 x i64> @test7(<2 x i64> %A) {
  %shl = shl <2 x i64> %A, <i64 2, i64 3>
  %mul = mul <2 x i64> %A, <i64 3, i64 4>
  %add = add <2 x i64> %shl, %mul
  ret <2 x i64> %add
; CHECK-LABEL: @test7(
; CHECK-NEXT: %add = mul <2 x i64> %A, <i64 7, i64 12>
; CHECK-NEXT: ret <2 x i64> %add
}

define <2 x i64> @test8(<2 x i64> %A) {
  %xor = xor <2 x i64> %A, <i64 -1, i64 -1>
  %add = add <2 x i64> %xor, <i64 2, i64 3>
  ret <2 x i64> %add
; CHECK-LABEL: @test8(
; CHECK-NEXT: %add = sub <2 x i64> <i64 1, i64 2>, %A
; CHECK-NEXT: ret <2 x i64> %add
}

define i16 @test9(i16 %a) {
       %b = mul i16 %a, 2
       %c = mul i16 %a, 32767
       %d = add i16 %b, %c
       ret i16 %d
; CHECK-LABEL: @test9(
; CHECK-NEXT:  %d = mul i16 %a, -32767
; CHECK-NEXT:  ret i16 %d
}

define i32 @test10(i32 %x) {
  %x.not = or i32 %x, -1431655766
  %neg = xor i32 %x.not, 1431655765
  %add = add i32 %x, 1
  %add1 = add i32 %add, %neg
  ret i32 %add1
; CHECK-LABEL: @test10(
; CHECK-NEXT: [[AND:%[a-z0-9]+]] = and i32 %x, -1431655766
; CHECK-NEXT: ret i32 [[AND]]
}

define i32 @test11(i32 %x, i32 %y) {
  %x.not = or i32 %x, -1431655766
  %neg = xor i32 %x.not, 1431655765
  %add = add i32 %y, 1
  %add1 = add i32 %add, %neg
  ret i32 %add1
; CHECK-LABEL: @test11(
; CHECK-NEXT: [[AND:%[a-z0-9]+]] = and i32 %x, 1431655765
; CHECK-NEXT: [[SUB:%[a-z0-9]+]] = sub i32 %y, [[AND]]
; CHECK-NEXT: ret i32 [[SUB]]
}

define i32 @test12(i32 %x, i32 %y) {
  %shr = ashr i32 %x, 3
  %shr.not = or i32 %shr, -1431655766
  %neg = xor i32 %shr.not, 1431655765
  %add = add i32 %y, 1
  %add1 = add i32 %add, %neg
  ret i32 %add1
; CHECK-LABEL: @test12(
; CHECK-NEXT: [[SHR:%[a-z0-9]+]] = ashr i32 %x, 3
; CHECK-NEXT: [[AND:%[a-z0-9]+]] = and i32 [[SHR]], 1431655765
; CHECK-NEXT: [[SUB:%[a-z0-9]+]] = sub i32 %y, [[AND]]
; CHECK-NEXT: ret i32 [[SUB]]
}

define i32 @test13(i32 %x, i32 %y) {
  %x.not = or i32 %x, -1431655767
  %neg = xor i32 %x.not, 1431655766
  %add = add i32 %y, 1
  %add1 = add i32 %add, %neg
  ret i32 %add1
; CHECK-LABEL: @test13(
; CHECK-NEXT: [[AND:%[a-z0-9]+]] = and i32 %x, 1431655766
; CHECK-NEXT: [[SUB:%[a-z0-9]+]] = sub i32 %y, [[AND]]
; CHECK-NEXT: ret i32 [[SUB]]
}

define i32 @test14(i32 %x, i32 %y) {
  %shr = ashr i32 %x, 3
  %shr.not = or i32 %shr, -1431655767
  %neg = xor i32 %shr.not, 1431655766
  %add = add i32 %y, 1
  %add1 = add i32 %add, %neg
  ret i32 %add1
; CHECK-LABEL: @test14(
; CHECK-NEXT: [[SHR:%[a-z0-9]+]] = ashr i32 %x, 3
; CHECK-NEXT: [[AND:%[a-z0-9]+]] = and i32 [[SHR]], 1431655766
; CHECK-NEXT: [[SUB:%[a-z0-9]+]] = sub i32 %y, [[AND]]
; CHECK-NEXT: ret i32 [[SUB]]
}

define i16 @add_nsw_mul_nsw(i16 %x) {
 %add1 = add nsw i16 %x, %x
 %add2 = add nsw i16 %add1, %x
 ret i16 %add2
; CHECK-LABEL: @add_nsw_mul_nsw(
; CHECK-NEXT: %add2 = mul nsw i16 %x, 3
; CHECK-NEXT: ret i16 %add2
}

define i16 @mul_add_to_mul_1(i16 %x) {
 %mul1 = mul nsw i16 %x, 8
 %add2 = add nsw i16 %x, %mul1
 ret i16 %add2
; CHECK-LABEL: @mul_add_to_mul_1(
; CHECK-NEXT: %add2 = mul nsw i16 %x, 9
; CHECK-NEXT: ret i16 %add2
}

define i16 @mul_add_to_mul_2(i16 %x) {
 %mul1 = mul nsw i16 %x, 8
 %add2 = add nsw i16 %mul1, %x
 ret i16 %add2
; CHECK-LABEL: @mul_add_to_mul_2(
; CHECK-NEXT: %add2 = mul nsw i16 %x, 9
; CHECK-NEXT: ret i16 %add2
}

define i16 @mul_add_to_mul_3(i16 %a) {
 %mul1 = mul i16 %a, 2
 %mul2 = mul i16 %a, 3
 %add = add nsw i16 %mul1, %mul2
 ret i16 %add
; CHECK-LABEL: @mul_add_to_mul_3(
; CHECK-NEXT: %add = mul i16 %a, 5
; CHECK-NEXT: ret i16 %add
}

define i16 @mul_add_to_mul_4(i16 %a) {
 %mul1 = mul nsw i16 %a, 2
 %mul2 = mul nsw i16 %a, 7
 %add = add nsw i16 %mul1, %mul2
 ret i16 %add
; CHECK-LABEL: @mul_add_to_mul_4(
; CHECK-NEXT: %add = mul nsw i16 %a, 9
; CHECK-NEXT: ret i16 %add
}

define i16 @mul_add_to_mul_5(i16 %a) {
 %mul1 = mul nsw i16 %a, 3
 %mul2 = mul nsw i16 %a, 7
 %add = add nsw i16 %mul1, %mul2
 ret i16 %add
; CHECK-LABEL: @mul_add_to_mul_5(
; CHECK-NEXT: %add = mul nsw i16 %a, 10
; CHECK-NEXT: ret i16 %add
}

define i32 @mul_add_to_mul_6(i32 %x, i32 %y) {
  %mul1 = mul nsw i32 %x, %y
  %mul2 = mul nsw i32 %mul1, 5
  %add = add nsw i32 %mul1, %mul2
  ret i32 %add
; CHECK-LABEL: @mul_add_to_mul_6(
; CHECK-NEXT: %mul1 = mul nsw i32 %x, %y
; CHECK-NEXT: %add = mul nsw i32 %mul1, 6
; CHECK-NEXT: ret i32 %add
}
