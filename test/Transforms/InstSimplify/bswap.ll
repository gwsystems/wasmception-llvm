; RUN: opt < %s -S -instsimplify | FileCheck %s

declare i16 @llvm.bswap.i16(i16)

define i1 @test1(i16 %arg) {
; CHECK-LABEL: @test1
; CHECK: ret i1 false
  %a = or i16 %arg, 1
  %b = call i16 @llvm.bswap.i16(i16 %a)
  %res = icmp eq i16 %b, 0
  ret i1 %res
}

define i1 @test2(i16 %arg) {
; CHECK-LABEL: @test2
; CHECK: ret i1 false
  %a = or i16 %arg, 1024
  %b = call i16 @llvm.bswap.i16(i16 %a)
  %res = icmp eq i16 %b, 0
  ret i1 %res
}

define i1 @test3(i16 %arg) {
; CHECK-LABEL: @test3
; CHECK: ret i1 false
  %a = and i16 %arg, 1
  %b = call i16 @llvm.bswap.i16(i16 %a)
  %and = and i16 %b, 1
  %res = icmp eq i16 %and, 1
  ret i1 %res
}

define i1 @test4(i16 %arg) {
; CHECK-LABEL: @test4
; CHECK: ret i1 false
  %a = and i16 %arg, 511
  %b = call i16 @llvm.bswap.i16(i16 %a)
  %and = and i16 %b, 256
  %res = icmp eq i16 %and, 1
  ret i1 %res
}
