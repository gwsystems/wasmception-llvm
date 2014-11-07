; RUN: llvm-link %s %p/Inputs/module-flags-pic-1-b.ll -S -o - | FileCheck %s

; test linking modules with specified and default PIC levels

!0 = metadata !{ i32 1, metadata !"PIC Level", i32 1 }

!llvm.module.flags = !{!0}
; CHECK: !llvm.module.flags = !{!0}
; CHECK: !0 = metadata !{i32 1, metadata !"PIC Level", i32 1}
