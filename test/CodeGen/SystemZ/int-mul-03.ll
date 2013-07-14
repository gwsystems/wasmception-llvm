; Test multiplications between an i64 and a sign-extended i32.
;
; RUN: llc < %s -mtriple=s390x-linux-gnu | FileCheck %s

declare i64 @foo()

; Check MSGFR.
define i64 @f1(i64 %a, i32 %b) {
; CHECK-LABEL: f1:
; CHECK: msgfr %r2, %r3
; CHECK: br %r14
  %bext = sext i32 %b to i64
  %mul = mul i64 %a, %bext
  ret i64 %mul
}

; Check MSGF with no displacement.
define i64 @f2(i64 %a, i32 *%src) {
; CHECK-LABEL: f2:
; CHECK: msgf %r2, 0(%r3)
; CHECK: br %r14
  %b = load i32 *%src
  %bext = sext i32 %b to i64
  %mul = mul i64 %a, %bext
  ret i64 %mul
}

; Check the high end of the aligned MSGF range.
define i64 @f3(i64 %a, i32 *%src) {
; CHECK-LABEL: f3:
; CHECK: msgf %r2, 524284(%r3)
; CHECK: br %r14
  %ptr = getelementptr i32 *%src, i64 131071
  %b = load i32 *%ptr
  %bext = sext i32 %b to i64
  %mul = mul i64 %a, %bext
  ret i64 %mul
}

; Check the next word up, which needs separate address logic.
; Other sequences besides this one would be OK.
define i64 @f4(i64 %a, i32 *%src) {
; CHECK-LABEL: f4:
; CHECK: agfi %r3, 524288
; CHECK: msgf %r2, 0(%r3)
; CHECK: br %r14
  %ptr = getelementptr i32 *%src, i64 131072
  %b = load i32 *%ptr
  %bext = sext i32 %b to i64
  %mul = mul i64 %a, %bext
  ret i64 %mul
}

; Check the high end of the negative aligned MSGF range.
define i64 @f5(i64 %a, i32 *%src) {
; CHECK-LABEL: f5:
; CHECK: msgf %r2, -4(%r3)
; CHECK: br %r14
  %ptr = getelementptr i32 *%src, i64 -1
  %b = load i32 *%ptr
  %bext = sext i32 %b to i64
  %mul = mul i64 %a, %bext
  ret i64 %mul
}

; Check the low end of the MSGF range.
define i64 @f6(i64 %a, i32 *%src) {
; CHECK-LABEL: f6:
; CHECK: msgf %r2, -524288(%r3)
; CHECK: br %r14
  %ptr = getelementptr i32 *%src, i64 -131072
  %b = load i32 *%ptr
  %bext = sext i32 %b to i64
  %mul = mul i64 %a, %bext
  ret i64 %mul
}

; Check the next word down, which needs separate address logic.
; Other sequences besides this one would be OK.
define i64 @f7(i64 %a, i32 *%src) {
; CHECK-LABEL: f7:
; CHECK: agfi %r3, -524292
; CHECK: msgf %r2, 0(%r3)
; CHECK: br %r14
  %ptr = getelementptr i32 *%src, i64 -131073
  %b = load i32 *%ptr
  %bext = sext i32 %b to i64
  %mul = mul i64 %a, %bext
  ret i64 %mul
}

; Check that MSGF allows an index.
define i64 @f8(i64 %a, i64 %src, i64 %index) {
; CHECK-LABEL: f8:
; CHECK: msgf %r2, 524284({{%r4,%r3|%r3,%r4}})
; CHECK: br %r14
  %add1 = add i64 %src, %index
  %add2 = add i64 %add1, 524284
  %ptr = inttoptr i64 %add2 to i32 *
  %b = load i32 *%ptr
  %bext = sext i32 %b to i64
  %mul = mul i64 %a, %bext
  ret i64 %mul
}

; Check that multiplications of spilled values can use MSGF rather than MSGFR.
define i64 @f9(i32 *%ptr0) {
; CHECK-LABEL: f9:
; CHECK: brasl %r14, foo@PLT
; CHECK: msgf %r2, 16{{[04]}}(%r15)
; CHECK: br %r14
  %ptr1 = getelementptr i32 *%ptr0, i64 2
  %ptr2 = getelementptr i32 *%ptr0, i64 4
  %ptr3 = getelementptr i32 *%ptr0, i64 6
  %ptr4 = getelementptr i32 *%ptr0, i64 8
  %ptr5 = getelementptr i32 *%ptr0, i64 10
  %ptr6 = getelementptr i32 *%ptr0, i64 12
  %ptr7 = getelementptr i32 *%ptr0, i64 14
  %ptr8 = getelementptr i32 *%ptr0, i64 16
  %ptr9 = getelementptr i32 *%ptr0, i64 18

  %val0 = load i32 *%ptr0
  %val1 = load i32 *%ptr1
  %val2 = load i32 *%ptr2
  %val3 = load i32 *%ptr3
  %val4 = load i32 *%ptr4
  %val5 = load i32 *%ptr5
  %val6 = load i32 *%ptr6
  %val7 = load i32 *%ptr7
  %val8 = load i32 *%ptr8
  %val9 = load i32 *%ptr9

  %frob0 = add i32 %val0, 100
  %frob1 = add i32 %val1, 100
  %frob2 = add i32 %val2, 100
  %frob3 = add i32 %val3, 100
  %frob4 = add i32 %val4, 100
  %frob5 = add i32 %val5, 100
  %frob6 = add i32 %val6, 100
  %frob7 = add i32 %val7, 100
  %frob8 = add i32 %val8, 100
  %frob9 = add i32 %val9, 100

  store i32 %frob0, i32 *%ptr0
  store i32 %frob1, i32 *%ptr1
  store i32 %frob2, i32 *%ptr2
  store i32 %frob3, i32 *%ptr3
  store i32 %frob4, i32 *%ptr4
  store i32 %frob5, i32 *%ptr5
  store i32 %frob6, i32 *%ptr6
  store i32 %frob7, i32 *%ptr7
  store i32 %frob8, i32 *%ptr8
  store i32 %frob9, i32 *%ptr9

  %ret = call i64 @foo()

  %ext0 = sext i32 %frob0 to i64
  %ext1 = sext i32 %frob1 to i64
  %ext2 = sext i32 %frob2 to i64
  %ext3 = sext i32 %frob3 to i64
  %ext4 = sext i32 %frob4 to i64
  %ext5 = sext i32 %frob5 to i64
  %ext6 = sext i32 %frob6 to i64
  %ext7 = sext i32 %frob7 to i64
  %ext8 = sext i32 %frob8 to i64
  %ext9 = sext i32 %frob9 to i64

  %mul0 = mul i64 %ret, %ext0
  %mul1 = mul i64 %mul0, %ext1
  %mul2 = mul i64 %mul1, %ext2
  %mul3 = mul i64 %mul2, %ext3
  %mul4 = mul i64 %mul3, %ext4
  %mul5 = mul i64 %mul4, %ext5
  %mul6 = mul i64 %mul5, %ext6
  %mul7 = mul i64 %mul6, %ext7
  %mul8 = mul i64 %mul7, %ext8
  %mul9 = mul i64 %mul8, %ext9

  ret i64 %mul9
}
