; RUN: %llc_dwarf -O0 -filetype=obj < %s | llvm-dwarfdump -debug-dump=info - | FileCheck --check-prefix=CHECK-INFO %s
; RUN: %llc_dwarf -O0 -filetype=obj < %s | llvm-dwarfdump -debug-dump=macro - | FileCheck --check-prefix=CHECK-MACRO %s
; RUN: %llc_dwarf -O0 -filetype=obj < %s | llvm-dwarfdump -debug-dump=line - | FileCheck --check-prefix=CHECK-LINE %s


; CHECK-INFO: .debug_info contents:
; CHECK-INFO: DW_TAG_compile_unit
; CHECK-INFO-NOT: DW_TAG
; CHECK-INFO:   DW_AT_name {{.*}}"debug-macro.cpp")
; CHECK-INFO:   DW_AT_macro_info {{.*}}(0x00000000)
; CHECK-INFO: DW_TAG_compile_unit
; CHECK-INFO-NOT: DW_TAG
; CHECK-INFO:   DW_AT_name {{.*}}"debug-macro1.cpp")
; CHECK-INFO:   DW_AT_macro_info {{.*}}(0x00000044)
; CHECK-INFO: DW_TAG_compile_unit
; CHECK-INFO-NOT: DW_TAG
; CHECK-INFO:   DW_AT_name {{.*}}"debug-macro2.cpp")
; CHECK-INFO-NOT: DW_AT_macro_info

; CHECK-MACRO:     .debug_macinfo contents:
; CHECK-MACRO-NEXT: DW_MACINFO_define - lineno: 0 macro: NameCMD ValueCMD
; CHECK-MACRO-NEXT: DW_MACINFO_start_file - lineno: 0 filenum: 1
; CHECK-MACRO-NEXT:   DW_MACINFO_start_file - lineno: 9 filenum: 2
; CHECK-MACRO-NEXT:     DW_MACINFO_define - lineno: 1 macro: NameDef Value
; CHECK-MACRO-NEXT:     DW_MACINFO_undef - lineno: 11 macro: NameUndef
; CHECK-MACRO-NEXT:   DW_MACINFO_end_file
; CHECK-MACRO-NEXT:   DW_MACINFO_undef - lineno: 10 macro: NameUndef2
; CHECK-MACRO-NEXT: DW_MACINFO_end_file
; CHECK-MACRO-NEXT: DW_MACINFO_start_file - lineno: 0 filenum: 1
; CHECK-MACRO-NEXT: DW_MACINFO_end_file

; CHECK-LINE: .debug_line contents:
; CHECK-LINE: Dir  Mod Time   File Len   File Name
; CHECK-LINE: file_names[  1] {{.*}}debug-macro.cpp
; CHECK-LINE: file_names[  2] {{.*}}debug-macro.h
; CHECK-LINE: Dir  Mod Time   File Len   File Name
; CHECK-LINE: file_names[  1] {{.*}}debug-macro1.cpp

!llvm.dbg.cu = !{!0, !16, !20}
!llvm.module.flags = !{!13, !14}
!llvm.ident = !{!15}

!0 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus, producer: "clang version 3.5.0 ", isOptimized: false, emissionKind: FullDebug, file: !1, enums: !2, retainedTypes: !2, subprograms: !2, globals: !2, imports: !2, macros: !3)
!1 = !DIFile(filename: "debug-macro.cpp", directory: "/")
!2 = !{}
!3 = !{!4, !5}
!4 = !DIMacro(type: DW_MACINFO_define, line: 0, name: "NameCMD", value: "ValueCMD")
!5 = !DIMacroFile(line: 0, file: !1, nodes: !6)
!6 = !{!7, !12}
!7 = !DIMacroFile(line: 9, file: !8, nodes: !9)
!8 = !DIFile(filename: "debug-macro.h", directory: "/")
!9 = !{!10, !11}
!10 = !DIMacro(type: DW_MACINFO_define, line: 1, name: "NameDef", value: "Value")
!11 = !DIMacro(type: DW_MACINFO_undef, line: 11, name: "NameUndef")
!12 = !DIMacro(type: DW_MACINFO_undef, line: 10, name: "NameUndef2")

!13 = !{i32 2, !"Dwarf Version", i32 4}
!14 = !{i32 1, !"Debug Info Version", i32 3}
!15 = !{!"clang version 3.5.0 "}

!16 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus, producer: "clang version 3.5.0 ", isOptimized: false, emissionKind: FullDebug, file: !17, enums: !2, retainedTypes: !2, subprograms: !2, globals: !2, imports: !2, macros: !18)
!17 = !DIFile(filename: "debug-macro1.cpp", directory: "/")
!18 = !{!19}
!19 = !DIMacroFile(line: 0, file: !17, nodes: !2)

!20 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus, producer: "clang version 3.5.0 ", isOptimized: false, emissionKind: FullDebug, file: !21, enums: !2, retainedTypes: !2, subprograms: !2, globals: !2, imports: !2)
!21 = !DIFile(filename: "debug-macro2.cpp", directory: "/")
