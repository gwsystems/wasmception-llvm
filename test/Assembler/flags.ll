; RUN: llvm-as < %s | llvm-dis | FileCheck %s

@addr = external global i64

define i64 @add_unsigned(i64 %x, i64 %y) {
; CHECK: %z = add nuw i64 %x, %y
	%z = add nuw i64 %x, %y
	ret i64 %z
}

define i64 @sub_unsigned(i64 %x, i64 %y) {
; CHECK: %z = sub nuw i64 %x, %y
	%z = sub nuw i64 %x, %y
	ret i64 %z
}

define i64 @mul_unsigned(i64 %x, i64 %y) {
; CHECK: %z = mul nuw i64 %x, %y
	%z = mul nuw i64 %x, %y
	ret i64 %z
}

define i64 @add_signed(i64 %x, i64 %y) {
; CHECK: %z = add nsw i64 %x, %y
	%z = add nsw i64 %x, %y
	ret i64 %z
}

define i64 @sub_signed(i64 %x, i64 %y) {
; CHECK: %z = sub nsw i64 %x, %y
	%z = sub nsw i64 %x, %y
	ret i64 %z
}

define i64 @mul_signed(i64 %x, i64 %y) {
; CHECK: %z = mul nsw i64 %x, %y
	%z = mul nsw i64 %x, %y
	ret i64 %z
}

define i64 @add_plain(i64 %x, i64 %y) {
; CHECK: %z = add i64 %x, %y
	%z = add i64 %x, %y
	ret i64 %z
}

define i64 @sub_plain(i64 %x, i64 %y) {
; CHECK: %z = sub i64 %x, %y
	%z = sub i64 %x, %y
	ret i64 %z
}

define i64 @mul_plain(i64 %x, i64 %y) {
; CHECK: %z = mul i64 %x, %y
	%z = mul i64 %x, %y
	ret i64 %z
}

define i64 @add_both(i64 %x, i64 %y) {
; CHECK: %z = add nuw nsw i64 %x, %y
	%z = add nuw nsw i64 %x, %y
	ret i64 %z
}

define i64 @sub_both(i64 %x, i64 %y) {
; CHECK: %z = sub nuw nsw i64 %x, %y
	%z = sub nuw nsw i64 %x, %y
	ret i64 %z
}

define i64 @mul_both(i64 %x, i64 %y) {
; CHECK: %z = mul nuw nsw i64 %x, %y
	%z = mul nuw nsw i64 %x, %y
	ret i64 %z
}

define i64 @add_both_reversed(i64 %x, i64 %y) {
; CHECK: %z = add nuw nsw i64 %x, %y
	%z = add nsw nuw i64 %x, %y
	ret i64 %z
}

define i64 @sub_both_reversed(i64 %x, i64 %y) {
; CHECK: %z = sub nuw nsw i64 %x, %y
	%z = sub nsw nuw i64 %x, %y
	ret i64 %z
}

define i64 @mul_both_reversed(i64 %x, i64 %y) {
; CHECK: %z = mul nuw nsw i64 %x, %y
	%z = mul nsw nuw i64 %x, %y
	ret i64 %z
}

define i64 @sdiv_exact(i64 %x, i64 %y) {
; CHECK: %z = sdiv exact i64 %x, %y
	%z = sdiv exact i64 %x, %y
	ret i64 %z
}

define i64 @sdiv_plain(i64 %x, i64 %y) {
; CHECK: %z = sdiv i64 %x, %y
	%z = sdiv i64 %x, %y
	ret i64 %z
}

define i64 @add_both_ce() {
; CHECK: ret i64 add nuw nsw (i64 ptrtoint (i64* @addr to i64), i64 91)
	ret i64 add nsw nuw (i64 ptrtoint (i64* @addr to i64), i64 91)
}

define i64 @sub_both_ce() {
; CHECK: ret i64 sub nuw nsw (i64 ptrtoint (i64* @addr to i64), i64 91)
	ret i64 sub nsw nuw (i64 ptrtoint (i64* @addr to i64), i64 91)
}

define i64 @mul_both_ce() {
; CHECK: ret i64 mul nuw nsw (i64 ptrtoint (i64* @addr to i64), i64 91)
	ret i64 mul nuw nsw (i64 ptrtoint (i64* @addr to i64), i64 91)
}

define i64 @sdiv_exact_ce() {
; CHECK: ret i64 sdiv exact (i64 ptrtoint (i64* @addr to i64), i64 91)
	ret i64 sdiv exact (i64 ptrtoint (i64* @addr to i64), i64 91)
}
