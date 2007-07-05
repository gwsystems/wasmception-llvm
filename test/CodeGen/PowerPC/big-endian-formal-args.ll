; RUN: llvm-as < %s | llc -march=ppc32 | grep {li 6, 3}
; RUN: llvm-as < %s | llc -march=ppc32 | grep {li 4, 2}
; RUN: llvm-as < %s | llc -march=ppc32 | grep {li 3, 0}
; RUN: llvm-as < %s | llc -march=ppc32 | grep {mr 5, 3}

declare void @bar(i64 %x, i64 %y)

define void @foo() {
  call void @bar(i64 2, i64 3)
  ret void
}
