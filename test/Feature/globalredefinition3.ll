; When PR1067 is fixed, this should not be XFAIL any more.
; RUN: llvm-as < %s -o /dev/null -f 2>&1 | \
; RUN:   grep "Redefinition of global variable named 'B'"

; Test forward references and redefinitions of globals

@B = global i32 7
@B = global i32 7
