; RUN: llc < %s -march=systemz
define i64 @foo(i64 %a, i64 %b) {
entry:
    %c = add i64 %a, %b
    ret i64 %c
}
