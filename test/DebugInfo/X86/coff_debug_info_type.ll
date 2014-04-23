; RUN: llc -mtriple=i686-pc-mingw32 -filetype=asm -O0 < %s | FileCheck %s
; RUN: llc -mtriple=i686-pc-cygwin -filetype=asm -O0 < %s | FileCheck %s
; RUN: llc -mtriple=i686-w64-mingw32 -filetype=asm -O0 < %s | FileCheck %s
; CHECK:    .section  .debug_info

; RUN: llc -mtriple=i686-pc-win32 -filetype=asm -O0 < %s | FileCheck -check-prefix=WIN32 %s
; WIN32:    .section .debug$S,"rnd"

; generated from:
; clang -g -S -emit-llvm test.c -o test.ll
; int main()
; {
; 	return 0;
; }

define i32 @main() #0 {
entry:
  %retval = alloca i32, align 4
  store i32 0, i32* %retval
  ret i32 0, !dbg !10
}

attributes #0 = { nounwind "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!9, !11}

!0 = metadata !{i32 786449, metadata !1, i32 12, metadata !"clang version 3.4 ", i1 false, metadata !"", i32 0, metadata !2, metadata !2, metadata !3, metadata !2, metadata !2, metadata !""} ; [ DW_TAG_compile_unit ] [C:\Projects/test.c] [DW_LANG_C99]
!1 = metadata !{metadata !"test.c", metadata !"C:\5CProjects"}
!2 = metadata !{}
!3 = metadata !{metadata !4}
!4 = metadata !{i32 786478, metadata !1, metadata !5, metadata !"main", metadata !"main", metadata !"", i32 1, metadata !6, i1 false, i1 true, i32 0, i32 0, null, i32 0, i1 false, i32 ()* @main, null, null, metadata !2, i32 2} ; [ DW_TAG_subprogram ] [line 1] [def] [scope 2] [main]
!5 = metadata !{i32 786473, metadata !1}          ; [ DW_TAG_file_type ] [C:\Projects/test.c]
!6 = metadata !{i32 786453, i32 0, null, metadata !"", i32 0, i64 0, i64 0, i64 0, i32 0, null, metadata !7, i32 0, null, null, null} ; [ DW_TAG_subroutine_type ] [line 0, size 0, align 0, offset 0] [from ]
!7 = metadata !{metadata !8}
!8 = metadata !{i32 786468, null, null, metadata !"int", i32 0, i64 32, i64 32, i64 0, i32 0, i32 5} ; [ DW_TAG_base_type ] [int] [line 0, size 32, align 32, offset 0, enc DW_ATE_signed]
!9 = metadata !{i32 2, metadata !"Dwarf Version", i32 3}
!10 = metadata !{i32 3, i32 0, metadata !4, null}
!11 = metadata !{i32 1, metadata !"Debug Info Version", i32 1}
