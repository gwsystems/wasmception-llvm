; RUN: llc -march=mips -mcpu=4ke < %s | FileCheck %s

; CHECK: clz $2, $4
define i32 @t1(i32 %X) nounwind readnone {
entry:
  %tmp1 = tail call i32 @llvm.ctlz.i32(i32 %X)
  ret i32 %tmp1
}

declare i32 @llvm.ctlz.i32(i32) nounwind readnone

; CHECK: clz $2, $4
define i32 @t2(i32 %X) nounwind readnone {
entry:
  %tmp1 = tail call i32 @llvm.ctlz.i32(i32 %X)
  ret i32 %tmp1
}

; CHECK: clo $2, $4
define i32 @t3(i32 %X) nounwind readnone {
entry:
  %neg = xor i32 %X, -1
  %tmp1 = tail call i32 @llvm.ctlz.i32(i32 %neg)
  ret i32 %tmp1
}

; CHECK: clo $2, $4
define i32 @t4(i32 %X) nounwind readnone {
entry:
  %neg = xor i32 %X, -1
  %tmp1 = tail call i32 @llvm.ctlz.i32(i32 %neg)
  ret i32 %tmp1
}
