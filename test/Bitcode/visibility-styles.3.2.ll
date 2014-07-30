; RUN:  llvm-dis < %s.bc| FileCheck %s
; RUN:  verify-uselistorder < %s.bc -preserve-bc-use-list-order -num-shuffles=5

; visibility-styles.3.2.ll.bc was generated by passing this file to llvm-as-3.2.
; The test checks that LLVM does not silently misread visibility styles of
; older bitcode files.

@default.var = default global i32 0
; CHECK: @default.var = global i32 0

@hidden.var = hidden global i32 0
; CHECK: @hidden.var = hidden global i32 0

@protected.var = protected global i32 0
; CHECK: @protected.var = protected global i32 0

declare default void @default()
; CHECK: declare void @default

declare hidden void @hidden()
; CHECK: declare hidden void @hidden

declare protected void @protected()
; CHECK: declare protected void @protected
