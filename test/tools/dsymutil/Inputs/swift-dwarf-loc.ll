; ModuleID = '-'
source_filename = "-"
target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.12"

%TSi = type <{ i64 }>

@_var = hidden global %TSi zeroinitializer, align 8, !dbg !0

!llvm.dbg.cu = !{!8}
!llvm.module.flags = !{!11, !12}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "x", linkageName: "_var", scope: !2, file: !3, line: 1, type: !4, isLocal: false, isDefinition: true)
!2 = !DIModule(scope: null, name: "main")
!3 = !DIFile(filename: "<stdin>", directory: "")
!4 = !DICompositeType(tag: DW_TAG_structure_type, name: "Int", scope: !6, file: !5, size: 64, elements: !7, runtimeLang: DW_LANG_Swift, identifier: "_T0SiD")
!5 = !DIFile(filename: "foo", directory: "/tmp")
!6 = !DIModule(scope: null, name: "foo", includePath: "")
!7 = !{}
!8 = distinct !DICompileUnit(language: DW_LANG_Swift, file: !9, producer: "swiftc", isOptimized: false, flags: "", runtimeVersion: 4, emissionKind: FullDebug, enums: !7, globals: !10, imports: null)
!9 = !DIFile(filename: "/tmp", directory: "")
!10 = !{!0}
!11 = !{i32 2, !"Dwarf Version", i32 4}
!12 = !{i32 2, !"Debug Info Version", i32 3}
