; RUN: llvm-as %s -o /dev/null

define void @foo() {
  %p = alloca i1, align 536870912
  load i1* %p, align 536870912
  store i1 false, i1* %p, align 536870912
  ret void
}
