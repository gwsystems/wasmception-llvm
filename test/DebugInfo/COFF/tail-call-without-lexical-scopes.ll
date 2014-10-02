; RUN: llc -mcpu=core2 -mtriple=i686-pc-win32 -O0 < %s | FileCheck --check-prefix=X86 %s

; This LL file was generated by running clang on the following code:
; D:\test.cpp:
; 1 void foo();
; 2
; 3 static void bar(int arg, ...) {
; 4   foo();
; 5 }
; 6
; 7 void spam(void) {
; 8   bar(42);
; 9 }
;
; The bar function happens to have no lexical scopes, yet it has one instruction
; with debug information available.  This used to be PR19239.

; X86-LABEL: {{^}}"?bar@@YAXHZZ":
; X86-NEXT: # BB
; X86-NEXT: [[JMP_LINE:^L.*]]:{{$}}
; X86-NEXT: jmp "?foo@@YAXXZ"
; X86-NEXT: [[END_OF_BAR:^L.*]]:{{$}}
; X86-NOT:  ret

; X86-LABEL: .section        .debug$S,"rd"
; X86:       .secrel32 "?bar@@YAXHZZ"
; X86-NEXT:  .secidx   "?bar@@YAXHZZ"
; X86:       .long   0
; X86-NEXT:  .long   1
; X86-NEXT:  .long {{.*}}
; X86-NEXT:  .long [[JMP_LINE]]-"?bar@@YAXHZZ"
; X86-NEXT:  .long   4

; X86-LABEL: .long   244

; ModuleID = 'test.cpp'
target datalayout = "e-m:w-p:32:32-i64:64-f80:32-n8:16:32-S32"
target triple = "i686-pc-win32"

; Function Attrs: nounwind
define void @"\01?spam@@YAXXZ"() #0 {
entry:
  tail call void @"\01?bar@@YAXHZZ"(), !dbg !11
  ret void, !dbg !12
}

; Function Attrs: nounwind
define internal void @"\01?bar@@YAXHZZ"() #0 {
entry:
  tail call void @"\01?foo@@YAXXZ"() #2, !dbg !13
  ret void, !dbg !14
}

declare void @"\01?foo@@YAXXZ"() #1

attributes #0 = { nounwind "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-realign-stack" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-realign-stack" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!8, !9}
!llvm.ident = !{!10}

!0 = metadata !{metadata !"0x11\004\00clang version 3.5.0 \001\00\000\00\002", metadata !1, metadata !2, metadata !2, metadata !3, metadata !2, metadata !2} ; [ DW_TAG_compile_unit ] [D:\/test.cpp] [DW_LANG_C_plus_plus]
!1 = metadata !{metadata !"test.cpp", metadata !"D:\5C"}
!2 = metadata !{}
!3 = metadata !{metadata !4, metadata !7}
!4 = metadata !{metadata !"0x2e\00spam\00spam\00\007\000\001\000\006\00256\001\007", metadata !1, metadata !5, metadata !6, null, void ()* @"\01?spam@@YAXXZ", null, null, metadata !2} ; [ DW_TAG_subprogram ] [line 7] [def] [spam]
!5 = metadata !{metadata !"0x29", metadata !1}          ; [ DW_TAG_file_type ] [D:\/test.cpp]
!6 = metadata !{metadata !"0x15\00\000\000\000\000\000\000", i32 0, null, null, metadata !2, null, null, null} ; [ DW_TAG_subroutine_type ] [line 0, size 0, align 0, offset 0] [from ]
!7 = metadata !{metadata !"0x2e\00bar\00bar\00\003\001\001\000\006\00256\001\003", metadata !1, metadata !5, metadata !6, null, null, null, null, metadata !2} ; [ DW_TAG_subprogram ] [line 3] [local] [def] [bar]
!8 = metadata !{i32 2, metadata !"Dwarf Version", i32 4}
!9 = metadata !{i32 1, metadata !"Debug Info Version", i32 2}
!10 = metadata !{metadata !"clang version 3.5.0 "}
!11 = metadata !{i32 8, i32 0, metadata !4, null}
!12 = metadata !{i32 9, i32 0, metadata !4, null}
!13 = metadata !{i32 4, i32 0, metadata !7, null}
!14 = metadata !{i32 5, i32 0, metadata !7, null}
