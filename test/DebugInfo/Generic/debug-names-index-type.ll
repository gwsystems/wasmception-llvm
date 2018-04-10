; REQUIRES: object-emission
; RUN: %llc_dwarf -accel-tables=Dwarf -filetype=obj -o %t < %s
; RUN: llvm-dwarfdump -debug-names %t | FileCheck %s
; RUN: llvm-dwarfdump -debug-names -verify %t | FileCheck --check-prefix=VERIFY %s

; Check that the entry for the "__ARRAY_SIZE_TYPE__" index type is present in the
; accelerator table.
; CHECK: String: 0x{{[0-9a-f]*}} "__ARRAY_SIZE_TYPE__"
; CHECK-NEXT: Entry
; CHECK-NEXT: Abbrev
; CHECK-NEXT: Tag: DW_TAG_base_type

; VERIFY: No errors.

; Generated by:
; clang -g -x c - -o - -S -emit-llvm <<<"int a[1];"

@a = common dso_local global [1 x i32] zeroinitializer, align 4, !dbg !0

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!11, !12, !13}
!llvm.ident = !{!14}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "a", scope: !2, file: !6, line: 1, type: !7, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 7.0.0 (trunk 329543) (llvm/trunk 329575)", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, globals: !5)
!3 = !DIFile(filename: "-", directory: "/tmp")
!4 = !{}
!5 = !{!0}
!6 = !DIFile(filename: "<stdin>", directory: "/tmp")
!7 = !DICompositeType(tag: DW_TAG_array_type, baseType: !8, size: 32, elements: !9)
!8 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!9 = !{!10}
!10 = !DISubrange(count: 1)
!11 = !{i32 2, !"Dwarf Version", i32 4}
!12 = !{i32 2, !"Debug Info Version", i32 3}
!13 = !{i32 1, !"wchar_size", i32 4}
!14 = !{!"clang version 7.0.0 (trunk 329543) (llvm/trunk 329575)"}
