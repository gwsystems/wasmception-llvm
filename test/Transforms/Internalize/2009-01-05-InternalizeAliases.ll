; RUN: opt < %s -internalize -internalize-public-api-list main -S | FileCheck %s

@A = global i32 0
; CHECK: @A = internal global i32 0

@B = alias i32* @A
; CHECK: @B = alias internal i32* @A

@C = alias i32* @B
; CHECK: @C = alias internal i32* @B

define i32 @main() {
	%tmp = load i32* @C
	ret i32 %tmp
}

; CHECK: define i32 @main() {
