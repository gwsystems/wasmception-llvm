; RUN: %llc_dwarf %s -o - -dwarf-version 2 -filetype=obj | llvm-dwarfdump - | FileCheck %s --check-prefix=DWARF2
; RUN: %llc_dwarf %s -o - -dwarf-version 3 -filetype=obj | llvm-dwarfdump - | FileCheck %s --check-prefix=DWARF34
; RUN: %llc_dwarf %s -o - -dwarf-version 4 -filetype=obj | llvm-dwarfdump - | FileCheck %s --check-prefix=DWARF34

; .debug_frame is not emitted for targeting Windows x64.
; REQUIRES: debug_frame

; Function Attrs: nounwind
define i32 @foo() #0 {
entry:
  %call = call i32 bitcast (i32 (...)* @bar to i32 ()*)(), !dbg !12
  %add = add nsw i32 %call, 1, !dbg !12
  ret i32 %add, !dbg !12
}

declare i32 @bar(...) #1

attributes #0 = { nounwind "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!9, !10}
!llvm.ident = !{!11}

!0 = !MDCompileUnit(language: DW_LANG_C99, producer: "clang version 3.5.0 ", isOptimized: false, emissionKind: 1, file: !1, enums: !2, retainedTypes: !2, subprograms: !3, globals: !2, imports: !2)
!1 = !MDFile(filename: "test.c", directory: "/tmp")
!2 = !{}
!3 = !{!4}
!4 = !MDSubprogram(name: "foo", line: 2, isLocal: false, isDefinition: true, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: false, scopeLine: 2, file: !1, scope: !5, type: !6, function: i32 ()* @foo, variables: !2)
!5 = !MDFile(filename: "test.c", directory: "/tmp")
!6 = !MDSubroutineType(types: !7)
!7 = !{!8}
!8 = !MDBasicType(tag: DW_TAG_base_type, name: "int", size: 32, align: 32, encoding: DW_ATE_signed)
!9 = !{i32 2, !"Dwarf Version", i32 4}
!10 = !{i32 1, !"Debug Info Version", i32 3}
!11 = !{!"clang version 3.5.0 "}
!12 = !MDLocation(line: 2, scope: !4)

; DWARF2:      .debug_frame contents:
; DWARF2:        Version:               1
; DWARF2-NEXT:   Augmentation:

; DWARF34:      .debug_frame contents:
; DWARF34:        Version:               3
; DWARF34-NEXT:   Augmentation:
