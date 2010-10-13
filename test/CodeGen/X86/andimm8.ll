; RUN: llc < %s -march=x86-64 -mtriple=x86_64-pc-linux-gnu -show-mc-encoding | FileCheck %s

; PR8365
; CHECK: andl	$-64, %edi              # encoding: [0x83,0xe7,0xc0]

define i64 @bra(i32 %zed) nounwind {
 %t1 = zext i32 %zed to i64
 %t2 = and i64  %t1, 4294967232
 ret i64 %t2
}
