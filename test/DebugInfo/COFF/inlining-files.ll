; RUN: llc -mcpu=core2 -mtriple=i686-pc-win32 < %s -filetype=obj | llvm-readobj -codeview | FileCheck %s --check-prefix=OBJ

; This LL file was generated by running 'clang -O1 -g -gcodeview' on the
; volatile int x;
; static inline void file_change(void) {
;   x++;
; #include "t.inc"
;   x++;
; }
; void f(void) {
;   ++x;
;   file_change();
;   ++x;
; }
; t.inc contents:
; ++x;
; ++x;

; OBJ:  Subsection [
; OBJ:    SubSectionType: Symbols (0xF1)
; OBJ:    {{.*}}Proc{{.*}}Sym {
; OBJ:      DisplayName: f
; OBJ:    }
; OBJ:    InlineSiteSym {
; OBJ:      PtrParent: 0x0
; OBJ:      PtrEnd: 0x0
; OBJ:      Inlinee: file_change (0x1002)
; OBJ:      BinaryAnnotations [
; OBJ:        ChangeCodeOffsetAndLineOffset: {CodeOffset: 0x6, LineOffset: 1}
; OBJ:        ChangeFile: D:\src\llvm\build\t.inc (0x8)
; OBJ:        ChangeCodeOffsetAndLineOffset: {CodeOffset: 0x6, LineOffset: -2}
; OBJ:        ChangeCodeOffsetAndLineOffset: {CodeOffset: 0x6, LineOffset: 1}
; OBJ:        ChangeFile: D:\src\llvm\build\t.cpp (0x0)
; OBJ:        ChangeCodeOffsetAndLineOffset: {CodeOffset: 0x6, LineOffset: 3}
; OBJ:        ChangeCodeLength: 0x6
; OBJ:      ]
; OBJ:    }
; OBJ:    InlineSiteEnd {
; OBJ:    }
; OBJ:    ProcEnd
; OBJ:  ]

; ModuleID = 't.cpp'
source_filename = "test/DebugInfo/COFF/inlining-files.ll"
target datalayout = "e-m:w-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-windows-msvc18.0.0"

@x = common global i32 0, align 4, !dbg !0

; Function Attrs: norecurse nounwind uwtable
define void @f() #0 !dbg !12 {
entry:
  %0 = load volatile i32, i32* @x, align 4, !dbg !15, !tbaa !16
  %inc = add nsw i32 %0, 1, !dbg !15
  store volatile i32 %inc, i32* @x, align 4, !dbg !15, !tbaa !16
  %1 = load volatile i32, i32* @x, align 4, !dbg !20, !tbaa !16
  %inc.i = add nsw i32 %1, 1, !dbg !20
  store volatile i32 %inc.i, i32* @x, align 4, !dbg !20, !tbaa !16
  %2 = load volatile i32, i32* @x, align 4, !dbg !23, !tbaa !16
  %inc1.i = add nsw i32 %2, 1, !dbg !23
  store volatile i32 %inc1.i, i32* @x, align 4, !dbg !23, !tbaa !16
  %3 = load volatile i32, i32* @x, align 4, !dbg !26, !tbaa !16
  %inc2.i = add nsw i32 %3, 1, !dbg !26
  store volatile i32 %inc2.i, i32* @x, align 4, !dbg !26, !tbaa !16
  %4 = load volatile i32, i32* @x, align 4, !dbg !27, !tbaa !16
  %inc3.i = add nsw i32 %4, 1, !dbg !27
  store volatile i32 %inc3.i, i32* @x, align 4, !dbg !27, !tbaa !16
  %5 = load volatile i32, i32* @x, align 4, !dbg !29, !tbaa !16
  %inc1 = add nsw i32 %5, 1, !dbg !29
  store volatile i32 %inc1, i32* @x, align 4, !dbg !29, !tbaa !16
  ret void, !dbg !30
}

attributes #0 = { norecurse nounwind uwtable "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!8, !9, !10}
!llvm.ident = !{!11}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = !DIGlobalVariable(name: "x", scope: !2, file: !3, line: 1, type: !6, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 3.9.0 ", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, globals: !5)
!3 = !DIFile(filename: "t.cpp", directory: "D:\5Csrc\5Cllvm\5Cbuild")
!4 = !{}
!5 = !{!0}
!6 = !DIDerivedType(tag: DW_TAG_volatile_type, baseType: !7)
!7 = !DIBasicType(name: "int", size: 32, align: 32, encoding: DW_ATE_signed)
!8 = !{i32 2, !"CodeView", i32 1}
!9 = !{i32 2, !"Debug Info Version", i32 3}
!10 = !{i32 1, !"PIC Level", i32 2}
!11 = !{!"clang version 3.9.0 "}
!12 = distinct !DISubprogram(name: "f", scope: !3, file: !3, line: 7, type: !13, isLocal: false, isDefinition: true, scopeLine: 7, flags: DIFlagPrototyped, isOptimized: true, unit: !2, retainedNodes: !4)
!13 = !DISubroutineType(types: !14)
!14 = !{null}
!15 = !DILocation(line: 8, column: 3, scope: !12)
!16 = !{!17, !17, i64 0}
!17 = !{!"int", !18, i64 0}
!18 = !{!"omnipotent char", !19, i64 0}
!19 = !{!"Simple C/C++ TBAA"}
!20 = !DILocation(line: 3, column: 4, scope: !21, inlinedAt: !22)
!21 = distinct !DISubprogram(name: "file_change", scope: !3, file: !3, line: 2, type: !13, isLocal: true, isDefinition: true, scopeLine: 2, flags: DIFlagPrototyped, isOptimized: true, unit: !2, retainedNodes: !4)
!22 = distinct !DILocation(line: 9, column: 3, scope: !12)
!23 = !DILocation(line: 1, column: 1, scope: !24, inlinedAt: !22)
!24 = !DILexicalBlockFile(scope: !21, file: !25, discriminator: 0)
!25 = !DIFile(filename: "./t.inc", directory: "D:\5Csrc\5Cllvm\5Cbuild")
!26 = !DILocation(line: 2, column: 1, scope: !24, inlinedAt: !22)
!27 = !DILocation(line: 5, column: 4, scope: !28, inlinedAt: !22)
!28 = !DILexicalBlockFile(scope: !21, file: !3, discriminator: 0)
!29 = !DILocation(line: 10, column: 3, scope: !12)
!30 = !DILocation(line: 11, column: 1, scope: !12)

