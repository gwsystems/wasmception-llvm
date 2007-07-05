; RUN: llvm-as < %s | llc -march=ppc32 | grep {addc 4, 4, 6}
; RUN: llvm-as < %s | llc -march=ppc32 | grep {adde 3, 3, 5}

define i64 @foo(i64 %x, i64 %y) {
  %z = add i64 %x, %y
  ret i64 %z
}
