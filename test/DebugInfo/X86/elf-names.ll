; RUN: llc -mtriple=x86_64-unknown-linux-gnu %s -o %t -filetype=obj
; RUN: llvm-dwarfdump -debug-dump=info %t | FileCheck %s
; RUN: llvm-as < %s | llvm-dis | FileCheck --check-prefix=CHECK-DIS %s

; CHECK: 0x0000000b: DW_TAG_compile_unit
; CHECK:               DW_AT_name [DW_FORM_strp] ( .debug_str[0x00000035] = "foo.cpp")
; CHECK: 0x{{[0-9a-f]+}}:   DW_TAG_class_type
; CHECK:                 DW_AT_name [DW_FORM_strp]       ( .debug_str[0x{{[0-9a-f]+}}] = "D")
; CHECK: 0x{{[0-9a-f]+}}:     DW_TAG_member
; CHECK:                   DW_AT_name [DW_FORM_strp]     ( .debug_str[0x{{[0-9a-f]+}}] = "c1")
; CHECK: DW_TAG_subprogram
; CHECK-NEXT: DW_AT_name [DW_FORM_strp]     ( .debug_str[0x{{[0-9a-f]+}}] = "D")
; CHECK: DW_TAG_formal_parameter
; CHECK: DW_AT_artificial [DW_FORM_flag_present]       (true)

; CHECK-DIS: DIFlagArtificial

%class.D = type { i32, i32, i32, i32 }

@_ZN1DC1Ev = alias void (%class.D*)* @_ZN1DC2Ev
@_ZN1DC1ERKS_ = alias void (%class.D*, %class.D*)* @_ZN1DC2ERKS_

define void @_ZN1DC2Ev(%class.D* nocapture %this) unnamed_addr nounwind uwtable align 2 {
entry:
  tail call void @llvm.dbg.value(metadata %class.D* %this, i64 0, metadata !29, metadata !MDExpression()), !dbg !36
  %c1 = getelementptr inbounds %class.D, %class.D* %this, i64 0, i32 0, !dbg !37
  store i32 1, i32* %c1, align 4, !dbg !37
  %c2 = getelementptr inbounds %class.D, %class.D* %this, i64 0, i32 1, !dbg !42
  store i32 2, i32* %c2, align 4, !dbg !42
  %c3 = getelementptr inbounds %class.D, %class.D* %this, i64 0, i32 2, !dbg !43
  store i32 3, i32* %c3, align 4, !dbg !43
  %c4 = getelementptr inbounds %class.D, %class.D* %this, i64 0, i32 3, !dbg !44
  store i32 4, i32* %c4, align 4, !dbg !44
  ret void, !dbg !45
}

define void @_ZN1DC2ERKS_(%class.D* nocapture %this, %class.D* nocapture %d) unnamed_addr nounwind uwtable align 2 {
entry:
  tail call void @llvm.dbg.value(metadata %class.D* %this, i64 0, metadata !34, metadata !MDExpression()), !dbg !46
  tail call void @llvm.dbg.value(metadata %class.D* %d, i64 0, metadata !35, metadata !MDExpression()), !dbg !46
  %c1 = getelementptr inbounds %class.D, %class.D* %d, i64 0, i32 0, !dbg !47
  %0 = load i32, i32* %c1, align 4, !dbg !47
  %c12 = getelementptr inbounds %class.D, %class.D* %this, i64 0, i32 0, !dbg !47
  store i32 %0, i32* %c12, align 4, !dbg !47
  %c2 = getelementptr inbounds %class.D, %class.D* %d, i64 0, i32 1, !dbg !49
  %1 = load i32, i32* %c2, align 4, !dbg !49
  %c23 = getelementptr inbounds %class.D, %class.D* %this, i64 0, i32 1, !dbg !49
  store i32 %1, i32* %c23, align 4, !dbg !49
  %c3 = getelementptr inbounds %class.D, %class.D* %d, i64 0, i32 2, !dbg !50
  %2 = load i32, i32* %c3, align 4, !dbg !50
  %c34 = getelementptr inbounds %class.D, %class.D* %this, i64 0, i32 2, !dbg !50
  store i32 %2, i32* %c34, align 4, !dbg !50
  %c4 = getelementptr inbounds %class.D, %class.D* %d, i64 0, i32 3, !dbg !51
  %3 = load i32, i32* %c4, align 4, !dbg !51
  %c45 = getelementptr inbounds %class.D, %class.D* %this, i64 0, i32 3, !dbg !51
  store i32 %3, i32* %c45, align 4, !dbg !51
  ret void, !dbg !52
}

declare void @llvm.dbg.value(metadata, i64, metadata, metadata) nounwind readnone

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!54}

!0 = !MDCompileUnit(language: DW_LANG_C_plus_plus, producer: "clang version 3.2 (trunk 167506) (llvm/trunk 167505)", isOptimized: true, emissionKind: 0, file: !53, enums: !1, retainedTypes: !1, subprograms: !3, globals: !1, imports:  !1)
!1 = !{}
!3 = !{!5, !31}
!5 = !MDSubprogram(name: "D", linkageName: "_ZN1DC2Ev", line: 12, isLocal: false, isDefinition: true, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: true, scopeLine: 12, file: !6, scope: null, type: !7, function: void (%class.D*)* @_ZN1DC2Ev, declaration: !17, variables: !27)
!6 = !MDFile(filename: "foo.cpp", directory: "/usr/local/google/home/echristo")
!7 = !MDSubroutineType(types: !8)
!8 = !{null, !9}
!9 = !MDDerivedType(tag: DW_TAG_pointer_type, size: 64, align: 64, flags: DIFlagArtificial | DIFlagObjectPointer, baseType: !10)
!10 = !MDCompositeType(tag: DW_TAG_class_type, name: "D", line: 1, size: 128, align: 32, file: !53, elements: !11)
!11 = !{!12, !14, !15, !16, !17, !20}
!12 = !MDDerivedType(tag: DW_TAG_member, name: "c1", line: 6, size: 32, align: 32, flags: DIFlagPrivate, file: !53, scope: !10, baseType: !13)
!13 = !MDBasicType(tag: DW_TAG_base_type, name: "int", size: 32, align: 32, encoding: DW_ATE_signed)
!14 = !MDDerivedType(tag: DW_TAG_member, name: "c2", line: 7, size: 32, align: 32, offset: 32, flags: DIFlagPrivate, file: !53, scope: !10, baseType: !13)
!15 = !MDDerivedType(tag: DW_TAG_member, name: "c3", line: 8, size: 32, align: 32, offset: 64, flags: DIFlagPrivate, file: !53, scope: !10, baseType: !13)
!16 = !MDDerivedType(tag: DW_TAG_member, name: "c4", line: 9, size: 32, align: 32, offset: 96, flags: DIFlagPrivate, file: !53, scope: !10, baseType: !13)
!17 = !MDSubprogram(name: "D", line: 3, isLocal: false, isDefinition: false, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: true, scopeLine: 3, file: !6, scope: !10, type: !7)
!20 = !MDSubprogram(name: "D", line: 4, isLocal: false, isDefinition: false, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: true, scopeLine: 4, file: !6, scope: !10, type: !21)
!21 = !MDSubroutineType(types: !22)
!22 = !{null, !9, !23}
!23 = !MDDerivedType(tag: DW_TAG_reference_type, baseType: !24)
!24 = !MDDerivedType(tag: DW_TAG_const_type, baseType: !10)
!27 = !{!29}
!29 = !MDLocalVariable(tag: DW_TAG_arg_variable, name: "this", line: 12, arg: 1, flags: DIFlagArtificial | DIFlagObjectPointer, scope: !5, file: !6, type: !30)
!30 = !MDDerivedType(tag: DW_TAG_pointer_type, size: 64, align: 64, baseType: !10)
!31 = !MDSubprogram(name: "D", linkageName: "_ZN1DC2ERKS_", line: 19, isLocal: false, isDefinition: true, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: true, scopeLine: 19, file: !6, scope: null, type: !21, function: void (%class.D*, %class.D*)* @_ZN1DC2ERKS_, declaration: !20, variables: !32)
!32 = !{!34, !35}
!34 = !MDLocalVariable(tag: DW_TAG_arg_variable, name: "this", line: 19, arg: 1, flags: DIFlagArtificial | DIFlagObjectPointer, scope: !31, file: !6, type: !30)
!35 = !MDLocalVariable(tag: DW_TAG_arg_variable, name: "d", line: 19, arg: 2, scope: !31, file: !6, type: !23)
!36 = !MDLocation(line: 12, scope: !5)
!37 = !MDLocation(line: 13, scope: !38)
!38 = distinct !MDLexicalBlock(line: 12, column: 0, file: !6, scope: !5)
!42 = !MDLocation(line: 14, scope: !38)
!43 = !MDLocation(line: 15, scope: !38)
!44 = !MDLocation(line: 16, scope: !38)
!45 = !MDLocation(line: 17, scope: !38)
!46 = !MDLocation(line: 19, scope: !31)
!47 = !MDLocation(line: 20, scope: !48)
!48 = distinct !MDLexicalBlock(line: 19, column: 0, file: !6, scope: !31)
!49 = !MDLocation(line: 21, scope: !48)
!50 = !MDLocation(line: 22, scope: !48)
!51 = !MDLocation(line: 23, scope: !48)
!52 = !MDLocation(line: 24, scope: !48)
!53 = !MDFile(filename: "foo.cpp", directory: "/usr/local/google/home/echristo")
!54 = !{i32 1, !"Debug Info Version", i32 3}
