; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; Debug informations shouldn't affect spill cost.
; RUN: opt -S -slp-vectorizer %s -o - | FileCheck %s

target triple = "aarch64"

%struct.S = type { i64, i64 }

define void @patatino(i64 %n, i64 %i, %struct.S* %p) !dbg !7 {
; CHECK-LABEL: @patatino(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    call void @llvm.dbg.value(metadata i64 [[N:%.*]], metadata !18, metadata !DIExpression()), !dbg !23
; CHECK-NEXT:    call void @llvm.dbg.value(metadata i64 [[I:%.*]], metadata !19, metadata !DIExpression()), !dbg !24
; CHECK-NEXT:    call void @llvm.dbg.value(metadata %struct.S* [[P:%.*]], metadata !20, metadata !DIExpression()), !dbg !25
; CHECK-NEXT:    [[X1:%.*]] = getelementptr inbounds [[STRUCT_S:%.*]], %struct.S* [[P]], i64 [[N]], i32 0, !dbg !26
; CHECK-NEXT:    call void @llvm.dbg.value(metadata i64 undef, metadata !21, metadata !DIExpression()), !dbg !27
; CHECK-NEXT:    [[Y3:%.*]] = getelementptr inbounds [[STRUCT_S]], %struct.S* [[P]], i64 [[N]], i32 1, !dbg !28
; CHECK-NEXT:    [[TMP0:%.*]] = bitcast i64* [[X1]] to <2 x i64>*, !dbg !26
; CHECK-NEXT:    [[TMP1:%.*]] = load <2 x i64>, <2 x i64>* [[TMP0]], align 8, !dbg !26, !tbaa !29
; CHECK-NEXT:    call void @llvm.dbg.value(metadata i64 undef, metadata !22, metadata !DIExpression()), !dbg !33
; CHECK-NEXT:    [[X5:%.*]] = getelementptr inbounds [[STRUCT_S]], %struct.S* [[P]], i64 [[I]], i32 0, !dbg !34
; CHECK-NEXT:    [[Y7:%.*]] = getelementptr inbounds [[STRUCT_S]], %struct.S* [[P]], i64 [[I]], i32 1, !dbg !35
; CHECK-NEXT:    [[TMP2:%.*]] = bitcast i64* [[X5]] to <2 x i64>*, !dbg !36
; CHECK-NEXT:    store <2 x i64> [[TMP1]], <2 x i64>* [[TMP2]], align 8, !dbg !36, !tbaa !29
; CHECK-NEXT:    ret void, !dbg !37
;
entry:
  call void @llvm.dbg.value(metadata i64 %n, metadata !18, metadata !DIExpression()), !dbg !23
  call void @llvm.dbg.value(metadata i64 %i, metadata !19, metadata !DIExpression()), !dbg !24
  call void @llvm.dbg.value(metadata %struct.S* %p, metadata !20, metadata !DIExpression()), !dbg !25
  %x1 = getelementptr inbounds %struct.S, %struct.S* %p, i64 %n, i32 0, !dbg !26
  %0 = load i64, i64* %x1, align 8, !dbg !26, !tbaa !27
  call void @llvm.dbg.value(metadata i64 %0, metadata !21, metadata !DIExpression()), !dbg !32
  %y3 = getelementptr inbounds %struct.S, %struct.S* %p, i64 %n, i32 1, !dbg !33
  %1 = load i64, i64* %y3, align 8, !dbg !33, !tbaa !34
  call void @llvm.dbg.value(metadata i64 %1, metadata !22, metadata !DIExpression()), !dbg !35
  %x5 = getelementptr inbounds %struct.S, %struct.S* %p, i64 %i, i32 0, !dbg !36
  store i64 %0, i64* %x5, align 8, !dbg !37, !tbaa !27
  %y7 = getelementptr inbounds %struct.S, %struct.S* %p, i64 %i, i32 1, !dbg !38
  store i64 %1, i64* %y7, align 8, !dbg !39, !tbaa !34
  ret void, !dbg !40
}

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.value(metadata, metadata, metadata) #1

attributes #1 = { nounwind readnone speculatable }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4, !5}
!llvm.ident = !{!6}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 7.0.0 (trunk 330946) (llvm/trunk 330976)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !2)
!1 = !DIFile(filename: "slp-reduced.c", directory: "/usr2/gberry/local/loop-align")
!2 = !{}
!3 = !{i32 2, !"Dwarf Version", i32 4}
!4 = !{i32 2, !"Debug Info Version", i32 3}
!5 = !{i32 1, !"wchar_size", i32 4}
!6 = !{!"clang version 7.0.0 (trunk 330946) (llvm/trunk 330976)"}
!7 = distinct !DISubprogram(name: "patatino", scope: !1, file: !1, line: 6, type: !8, isLocal: false, isDefinition: true, scopeLine: 6, flags: DIFlagPrototyped, isOptimized: true, unit: !0, retainedNodes: !17)
!8 = !DISubroutineType(types: !9)
!9 = !{null, !10, !10, !11}
!10 = !DIBasicType(name: "long int", size: 64, encoding: DW_ATE_signed)
!11 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !12, size: 64)
!12 = !DIDerivedType(tag: DW_TAG_typedef, name: "S", file: !1, line: 4, baseType: !13)
!13 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !1, line: 1, size: 128, elements: !14)
!14 = !{!15, !16}
!15 = !DIDerivedType(tag: DW_TAG_member, name: "x", scope: !13, file: !1, line: 2, baseType: !10, size: 64)
!16 = !DIDerivedType(tag: DW_TAG_member, name: "y", scope: !13, file: !1, line: 3, baseType: !10, size: 64, offset: 64)
!17 = !{!18, !19, !20, !21, !22}
!18 = !DILocalVariable(name: "n", arg: 1, scope: !7, file: !1, line: 6, type: !10)
!19 = !DILocalVariable(name: "i", arg: 2, scope: !7, file: !1, line: 6, type: !10)
!20 = !DILocalVariable(name: "p", arg: 3, scope: !7, file: !1, line: 6, type: !11)
!21 = !DILocalVariable(name: "x", scope: !7, file: !1, line: 7, type: !10)
!22 = !DILocalVariable(name: "y", scope: !7, file: !1, line: 8, type: !10)
!23 = !DILocation(line: 6, column: 15, scope: !7)
!24 = !DILocation(line: 6, column: 23, scope: !7)
!25 = !DILocation(line: 6, column: 29, scope: !7)
!26 = !DILocation(line: 7, column: 19, scope: !7)
!27 = !{!28, !29, i64 0}
!28 = !{!"", !29, i64 0, !29, i64 8}
!29 = !{!"long", !30, i64 0}
!30 = !{!"omnipotent char", !31, i64 0}
!31 = !{!"Simple C/C++ TBAA"}
!32 = !DILocation(line: 7, column: 10, scope: !7)
!33 = !DILocation(line: 8, column: 19, scope: !7)
!34 = !{!28, !29, i64 8}
!35 = !DILocation(line: 8, column: 10, scope: !7)
!36 = !DILocation(line: 9, column: 10, scope: !7)
!37 = !DILocation(line: 9, column: 12, scope: !7)
!38 = !DILocation(line: 10, column: 10, scope: !7)
!39 = !DILocation(line: 10, column: 12, scope: !7)
!40 = !DILocation(line: 11, column: 1, scope: !7)
