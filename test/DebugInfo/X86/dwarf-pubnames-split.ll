; RUN: llc -mtriple=x86_64-pc-linux-gnu -split-dwarf=Enable %s -o - | FileCheck %s
; Derived from:

; int main (void) {
;    return 0;
; }

; Check that we get a symbol off of the debug_info section when using split dwarf and pubnames.

; CHECK: .LpubTypes_begin0:
; CHECK-NEXT: .short    2                       # DWARF Version
; CHECK-NEXT: .long     .L.debug_info_begin0    # Offset of Compilation Unit Info

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
entry:
  %retval = alloca i32, align 4
  store i32 0, i32* %retval
  ret i32 0, !dbg !10
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!9, !11}

!0 = !MDCompileUnit(language: DW_LANG_C99, producer: "clang version 3.4 (trunk 189287) (llvm/trunk 189296)", isOptimized: false, emissionKind: 0, file: !1, enums: !2, retainedTypes: !2, subprograms: !3, globals: !2, imports: !2)
!1 = !MDFile(filename: "foo.c", directory: "/usr/local/google/home/echristo/tmp")
!2 = !{}
!3 = !{!4}
!4 = !MDSubprogram(name: "main", line: 1, isLocal: false, isDefinition: true, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: false, scopeLine: 1, file: !1, scope: !5, type: !6, function: i32 ()* @main, variables: !2)
!5 = !MDFile(filename: "foo.c", directory: "/usr/local/google/home/echristo/tmp")
!6 = !MDSubroutineType(types: !7)
!7 = !{!8}
!8 = !MDBasicType(tag: DW_TAG_base_type, name: "int", size: 32, align: 32, encoding: DW_ATE_signed)
!9 = !{i32 2, !"Dwarf Version", i32 3}
!10 = !MDLocation(line: 2, scope: !4)
!11 = !{i32 1, !"Debug Info Version", i32 3}
