; RUN: llc  -march=mipsel -mcpu=mips16 -relocation-model=pic -O3 < %s | FileCheck %s -check-prefix=16

@j = global i32 5, align 4
@k = global i32 10, align 4
@l = global i32 20, align 4
@m = global i32 10, align 4
@r1 = common global i32 0, align 4
@r2 = common global i32 0, align 4
@r3 = common global i32 0, align 4

define void @test() nounwind {
entry:
  %0 = load i32* @j, align 4
  %1 = load i32* @k, align 4
  %cmp = icmp ule i32 %0, %1
  %conv = zext i1 %cmp to i32
  store i32 %conv, i32* @r1, align 4
; 16:	sltu	${{[0-9]+}}, ${{[0-9]+}}
; 16:	move	$[[REGISTER:[0-9]+]], $24
; 16:	xor	$[[REGISTER]], ${{[0-9]+}}
  %2 = load i32* @m, align 4
  %cmp1 = icmp ule i32 %2, %1
  %conv2 = zext i1 %cmp1 to i32
  store i32 %conv2, i32* @r2, align 4
  ret void
}
