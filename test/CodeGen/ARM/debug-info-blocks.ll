; RUN: llc -O0 < %s | FileCheck %s
; CHECK: @DEBUG_VALUE: foobar_func_block_invoke_0:mydata <- [SP+{{[0-9]+}}]
; Radar 9331779
target datalayout = "e-p:32:32:32-i1:8:32-i8:8:32-i16:16:32-i32:32:32-i64:32:32-f32:32:32-f64:32:32-v64:32:64-v128:32:128-a0:0:32-n32"
target triple = "thumbv7-apple-ios"

%0 = type opaque
%1 = type { [4 x i32] }
%2 = type <{ i8*, i32, i32, i8*, %struct.Re*, i8*, %3*, %struct.my_struct* }>
%3 = type opaque
%struct.CP = type { float, float }
%struct.CR = type { %struct.CP, %struct.CP }
%struct.Re = type { i32, i32 }
%struct.__block_byref_mydata = type { i8*, %struct.__block_byref_mydata*, i32, i32, i8*, i8*, %0* }
%struct.my_struct = type opaque

@"\01L_OBJC_SELECTOR_REFERENCES_13" = external hidden global i8*, section "__DATA, __objc_selrefs, literal_pointers, no_dead_strip"
@"OBJC_IVAR_$_MyWork._bounds" = external hidden global i32, section "__DATA, __objc_const", align 4
@"OBJC_IVAR_$_MyWork._data" = external hidden global i32, section "__DATA, __objc_const", align 4
@"\01L_OBJC_SELECTOR_REFERENCES_222" = external hidden global i8*, section "__DATA, __objc_selrefs, literal_pointers, no_dead_strip"

declare void @llvm.dbg.declare(metadata, metadata, metadata) nounwind readnone

declare i8* @objc_msgSend(i8*, i8*, ...)

declare void @llvm.dbg.value(metadata, i64, metadata, metadata) nounwind readnone

declare void @llvm.memcpy.p0i8.p0i8.i32(i8* nocapture, i8* nocapture, i32, i32, i1) nounwind

define hidden void @foobar_func_block_invoke_0(i8* %.block_descriptor, %0* %loadedMydata, [4 x i32] %bounds.coerce0, [4 x i32] %data.coerce0) ssp {
  %1 = alloca %0*, align 4
  %bounds = alloca %struct.CR, align 4
  %data = alloca %struct.CR, align 4
  call void @llvm.dbg.value(metadata i8* %.block_descriptor, i64 0, metadata !27, metadata !MDExpression()), !dbg !129
  store %0* %loadedMydata, %0** %1, align 4
  call void @llvm.dbg.declare(metadata %0** %1, metadata !130, metadata !MDExpression()), !dbg !131
  %2 = bitcast %struct.CR* %bounds to %1*
  %3 = getelementptr %1, %1* %2, i32 0, i32 0
  store [4 x i32] %bounds.coerce0, [4 x i32]* %3
  call void @llvm.dbg.declare(metadata %struct.CR* %bounds, metadata !132, metadata !MDExpression()), !dbg !133
  %4 = bitcast %struct.CR* %data to %1*
  %5 = getelementptr %1, %1* %4, i32 0, i32 0
  store [4 x i32] %data.coerce0, [4 x i32]* %5
  call void @llvm.dbg.declare(metadata %struct.CR* %data, metadata !134, metadata !MDExpression()), !dbg !135
  %6 = bitcast i8* %.block_descriptor to %2*
  %7 = getelementptr inbounds %2, %2* %6, i32 0, i32 6
  call void @llvm.dbg.declare(metadata %2* %6, metadata !136, metadata !163), !dbg !137
  call void @llvm.dbg.declare(metadata %2* %6, metadata !138, metadata !164), !dbg !137
  call void @llvm.dbg.declare(metadata %2* %6, metadata !139, metadata !165), !dbg !140
  %8 = load %0*, %0** %1, align 4, !dbg !141
  %9 = load i8*, i8** @"\01L_OBJC_SELECTOR_REFERENCES_13", !dbg !141
  %10 = bitcast %0* %8 to i8*, !dbg !141
  %11 = call i8* bitcast (i8* (i8*, i8*, ...)* @objc_msgSend to i8* (i8*, i8*)*)(i8* %10, i8* %9), !dbg !141
  %12 = bitcast i8* %11 to %0*, !dbg !141
  %13 = getelementptr inbounds %2, %2* %6, i32 0, i32 5, !dbg !141
  %14 = load i8*, i8** %13, !dbg !141
  %15 = bitcast i8* %14 to %struct.__block_byref_mydata*, !dbg !141
  %16 = getelementptr inbounds %struct.__block_byref_mydata, %struct.__block_byref_mydata* %15, i32 0, i32 1, !dbg !141
  %17 = load %struct.__block_byref_mydata*, %struct.__block_byref_mydata** %16, !dbg !141
  %18 = getelementptr inbounds %struct.__block_byref_mydata, %struct.__block_byref_mydata* %17, i32 0, i32 6, !dbg !141
  store %0* %12, %0** %18, align 4, !dbg !141
  %19 = getelementptr inbounds %2, %2* %6, i32 0, i32 6, !dbg !143
  %20 = load %3*, %3** %19, align 4, !dbg !143
  %21 = load i32, i32* @"OBJC_IVAR_$_MyWork._data", !dbg !143
  %22 = bitcast %3* %20 to i8*, !dbg !143
  %23 = getelementptr inbounds i8, i8* %22, i32 %21, !dbg !143
  %24 = bitcast i8* %23 to %struct.CR*, !dbg !143
  %25 = bitcast %struct.CR* %24 to i8*, !dbg !143
  %26 = bitcast %struct.CR* %data to i8*, !dbg !143
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %25, i8* %26, i32 16, i32 4, i1 false), !dbg !143
  %27 = getelementptr inbounds %2, %2* %6, i32 0, i32 6, !dbg !144
  %28 = load %3*, %3** %27, align 4, !dbg !144
  %29 = load i32, i32* @"OBJC_IVAR_$_MyWork._bounds", !dbg !144
  %30 = bitcast %3* %28 to i8*, !dbg !144
  %31 = getelementptr inbounds i8, i8* %30, i32 %29, !dbg !144
  %32 = bitcast i8* %31 to %struct.CR*, !dbg !144
  %33 = bitcast %struct.CR* %32 to i8*, !dbg !144
  %34 = bitcast %struct.CR* %bounds to i8*, !dbg !144
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %33, i8* %34, i32 16, i32 4, i1 false), !dbg !144
  %35 = getelementptr inbounds %2, %2* %6, i32 0, i32 6, !dbg !145
  %36 = load %3*, %3** %35, align 4, !dbg !145
  %37 = getelementptr inbounds %2, %2* %6, i32 0, i32 5, !dbg !145
  %38 = load i8*, i8** %37, !dbg !145
  %39 = bitcast i8* %38 to %struct.__block_byref_mydata*, !dbg !145
  %40 = getelementptr inbounds %struct.__block_byref_mydata, %struct.__block_byref_mydata* %39, i32 0, i32 1, !dbg !145
  %41 = load %struct.__block_byref_mydata*, %struct.__block_byref_mydata** %40, !dbg !145
  %42 = getelementptr inbounds %struct.__block_byref_mydata, %struct.__block_byref_mydata* %41, i32 0, i32 6, !dbg !145
  %43 = load %0*, %0** %42, align 4, !dbg !145
  %44 = load i8*, i8** @"\01L_OBJC_SELECTOR_REFERENCES_222", !dbg !145
  %45 = bitcast %3* %36 to i8*, !dbg !145
  call void bitcast (i8* (i8*, i8*, ...)* @objc_msgSend to void (i8*, i8*, %0*)*)(i8* %45, i8* %44, %0* %43), !dbg !145
  ret void, !dbg !146
}

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!162}

!0 = !MDCompileUnit(language: DW_LANG_ObjC, producer: "Apple clang version 2.1", isOptimized: false, runtimeVersion: 2, emissionKind: 1, file: !153, enums: !147, retainedTypes: !26, subprograms: !148)
!1 = !MDCompositeType(tag: DW_TAG_enumeration_type, line: 248, size: 32, align: 32, file: !160, scope: !0, elements: !3)
!2 = !MDFile(filename: "header.h", directory: "/Volumes/Sandbox/llvm")
!3 = !{!4}
!4 = !MDEnumerator(name: "Ver1", value: 0) ; [ DW_TAG_enumerator ]
!5 = !MDCompositeType(tag: DW_TAG_enumeration_type, name: "Mode", line: 79, size: 32, align: 32, file: !160, scope: !0, elements: !7)
!6 = !MDFile(filename: "header2.h", directory: "/Volumes/Sandbox/llvm")
!7 = !{!8}
!8 = !MDEnumerator(name: "One", value: 0) ; [ DW_TAG_enumerator ]
!9 = !MDCompositeType(tag: DW_TAG_enumeration_type, line: 15, size: 32, align: 32, file: !149, scope: !0, elements: !11)
!10 = !MDFile(filename: "header3.h", directory: "/Volumes/Sandbox/llvm")
!11 = !{!12, !13}
!12 = !MDEnumerator(name: "Unknown", value: 0) ; [ DW_TAG_enumerator ]
!13 = !MDEnumerator(name: "Known", value: 1) ; [ DW_TAG_enumerator ]
!14 = !MDCompositeType(tag: DW_TAG_enumeration_type, line: 20, size: 32, align: 32, file: !150, scope: !0, elements: !16)
!15 = !MDFile(filename: "Private.h", directory: "/Volumes/Sandbox/llvm")
!16 = !{!17, !18}
!17 = !MDEnumerator(name: "Single", value: 0) ; [ DW_TAG_enumerator ]
!18 = !MDEnumerator(name: "Double", value: 1) ; [ DW_TAG_enumerator ]
!19 = !MDCompositeType(tag: DW_TAG_enumeration_type, line: 14, size: 32, align: 32, file: !151, scope: !0, elements: !21)
!20 = !MDFile(filename: "header4.h", directory: "/Volumes/Sandbox/llvm")
!21 = !{!22}
!22 = !MDEnumerator(name: "Eleven", value: 0) ; [ DW_TAG_enumerator ]
!23 = !MDSubprogram(name: "foobar_func_block_invoke_0", line: 609, isLocal: true, isDefinition: true, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: false, scopeLine: 609, file: !152, scope: !24, type: !25, function: void (i8*, %0*, [4 x i32], [4 x i32])* @foobar_func_block_invoke_0)
!24 = !MDFile(filename: "MyLibrary.m", directory: "/Volumes/Sandbox/llvm")
!25 = !MDSubroutineType(types: !26)
!26 = !{null}
!27 = !MDLocalVariable(tag: DW_TAG_arg_variable, name: ".block_descriptor", line: 609, arg: 1, flags: DIFlagArtificial, scope: !23, file: !24, type: !28)
!28 = !MDDerivedType(tag: DW_TAG_pointer_type, size: 32, scope: !0, baseType: !29)
!29 = !MDCompositeType(tag: DW_TAG_structure_type, name: "__block_literal_14", line: 609, size: 256, align: 32, file: !152, scope: !24, elements: !30)
!30 = !{!31, !33, !35, !36, !37, !48, !89, !124}
!31 = !MDDerivedType(tag: DW_TAG_member, name: "__isa", line: 609, size: 32, align: 32, file: !152, scope: !24, baseType: !32)
!32 = !MDDerivedType(tag: DW_TAG_pointer_type, size: 32, align: 32, scope: !0, baseType: null)
!33 = !MDDerivedType(tag: DW_TAG_member, name: "__flags", line: 609, size: 32, align: 32, offset: 32, file: !152, scope: !24, baseType: !34)
!34 = !MDBasicType(tag: DW_TAG_base_type, name: "int", size: 32, align: 32, encoding: DW_ATE_signed)
!35 = !MDDerivedType(tag: DW_TAG_member, name: "__reserved", line: 609, size: 32, align: 32, offset: 64, file: !152, scope: !24, baseType: !34)
!36 = !MDDerivedType(tag: DW_TAG_member, name: "__FuncPtr", line: 609, size: 32, align: 32, offset: 96, file: !152, scope: !24, baseType: !32)
!37 = !MDDerivedType(tag: DW_TAG_member, name: "__descriptor", line: 609, size: 32, align: 32, offset: 128, file: !152, scope: !24, baseType: !38)
!38 = !MDDerivedType(tag: DW_TAG_pointer_type, size: 32, align: 32, scope: !0, baseType: !39)
!39 = !MDCompositeType(tag: DW_TAG_structure_type, name: "__block_descriptor_withcopydispose", line: 307, size: 128, align: 32, file: !153, scope: !0, elements: !41)
!40 = !MDFile(filename: "MyLibrary.i", directory: "/Volumes/Sandbox/llvm")
!41 = !{!42, !44, !45, !47}
!42 = !MDDerivedType(tag: DW_TAG_member, name: "reserved", line: 307, size: 32, align: 32, file: !153, scope: !40, baseType: !43)
!43 = !MDBasicType(tag: DW_TAG_base_type, name: "long unsigned int", size: 32, align: 32, encoding: DW_ATE_unsigned)
!44 = !MDDerivedType(tag: DW_TAG_member, name: "Size", line: 307, size: 32, align: 32, offset: 32, file: !153, scope: !40, baseType: !43)
!45 = !MDDerivedType(tag: DW_TAG_member, name: "CopyFuncPtr", line: 307, size: 32, align: 32, offset: 64, file: !153, scope: !40, baseType: !46)
!46 = !MDDerivedType(tag: DW_TAG_pointer_type, size: 32, align: 32, scope: !0, baseType: !32)
!47 = !MDDerivedType(tag: DW_TAG_member, name: "DestroyFuncPtr", line: 307, size: 32, align: 32, offset: 96, file: !153, scope: !40, baseType: !46)
!48 = !MDDerivedType(tag: DW_TAG_member, name: "mydata", line: 609, size: 32, align: 32, offset: 160, file: !152, scope: !24, baseType: !49)
!49 = !MDDerivedType(tag: DW_TAG_pointer_type, size: 32, scope: !0, baseType: !50)
!50 = !MDCompositeType(tag: DW_TAG_structure_type, size: 224, flags: DIFlagBlockByrefStruct, file: !152, scope: !24, elements: !51)
!51 = !{!52, !53, !54, !55, !56, !57, !58}
!52 = !MDDerivedType(tag: DW_TAG_member, name: "__isa", size: 32, align: 32, file: !152, scope: !24, baseType: !32)
!53 = !MDDerivedType(tag: DW_TAG_member, name: "__forwarding", size: 32, align: 32, offset: 32, file: !152, scope: !24, baseType: !32)
!54 = !MDDerivedType(tag: DW_TAG_member, name: "__flags", size: 32, align: 32, offset: 64, file: !152, scope: !24, baseType: !34)
!55 = !MDDerivedType(tag: DW_TAG_member, name: "__size", size: 32, align: 32, offset: 96, file: !152, scope: !24, baseType: !34)
!56 = !MDDerivedType(tag: DW_TAG_member, name: "__copy_helper", size: 32, align: 32, offset: 128, file: !152, scope: !24, baseType: !32)
!57 = !MDDerivedType(tag: DW_TAG_member, name: "__destroy_helper", size: 32, align: 32, offset: 160, file: !152, scope: !24, baseType: !32)
!58 = !MDDerivedType(tag: DW_TAG_member, name: "mydata", size: 32, align: 32, offset: 192, file: !152, scope: !24, baseType: !59)
!59 = !MDDerivedType(tag: DW_TAG_pointer_type, size: 32, align: 32, scope: !0, baseType: !60)
!60 = !MDCompositeType(tag: DW_TAG_structure_type, name: "UIMydata", line: 26, size: 128, align: 32, runtimeLang: DW_LANG_ObjC, file: !154, scope: !24, elements: !62)
!61 = !MDFile(filename: "header11.h", directory: "/Volumes/Sandbox/llvm")
!62 = !{!63, !71, !75, !79}
!63 = !MDDerivedType(tag: DW_TAG_inheritance, file: !60, baseType: !64)
!64 = !MDCompositeType(tag: DW_TAG_structure_type, name: "NSO", line: 66, size: 32, align: 32, runtimeLang: DW_LANG_ObjC, file: !155, scope: !40, elements: !66)
!65 = !MDFile(filename: "NSO.h", directory: "/Volumes/Sandbox/llvm")
!66 = !{!67}
!67 = !MDDerivedType(tag: DW_TAG_member, name: "isa", line: 67, size: 32, align: 32, flags: DIFlagProtected, file: !155, scope: !65, baseType: !68, extraData: !"")
!68 = !MDDerivedType(tag: DW_TAG_typedef, name: "Class", line: 197, file: !153, scope: !0, baseType: !69)
!69 = !MDDerivedType(tag: DW_TAG_pointer_type, size: 32, align: 32, scope: !0, baseType: !70)
!70 = !MDCompositeType(tag: DW_TAG_structure_type, name: "objc_class", flags: DIFlagFwdDecl, file: !153, scope: !0)
!71 = !MDDerivedType(tag: DW_TAG_member, name: "_mydataRef", line: 28, size: 32, align: 32, offset: 32, file: !154, scope: !61, baseType: !72, extraData: !"")
!72 = !MDDerivedType(tag: DW_TAG_typedef, name: "CFTypeRef", line: 313, file: !152, scope: !0, baseType: !73)
!73 = !MDDerivedType(tag: DW_TAG_pointer_type, size: 32, align: 32, scope: !0, baseType: !74)
!74 = !MDDerivedType(tag: DW_TAG_const_type, scope: !0, baseType: null)
!75 = !MDDerivedType(tag: DW_TAG_member, name: "_scale", line: 29, size: 32, align: 32, offset: 64, file: !154, scope: !61, baseType: !76, extraData: !"")
!76 = !MDDerivedType(tag: DW_TAG_typedef, name: "Float", line: 89, file: !156, scope: !0, baseType: !78)
!77 = !MDFile(filename: "header12.h", directory: "/Volumes/Sandbox/llvm")
!78 = !MDBasicType(tag: DW_TAG_base_type, name: "float", size: 32, align: 32, encoding: DW_ATE_float)
!79 = !MDDerivedType(tag: DW_TAG_member, name: "_mydataFlags", line: 37, size: 8, align: 8, offset: 96, file: !154, scope: !61, baseType: !80, extraData: !"")
!80 = !MDCompositeType(tag: DW_TAG_structure_type, line: 30, size: 8, align: 8, file: !154, scope: !0, elements: !81)
!81 = !{!82, !84, !85, !86, !87, !88}
!82 = !MDDerivedType(tag: DW_TAG_member, name: "named", line: 31, size: 1, align: 32, file: !154, scope: !61, baseType: !83)
!83 = !MDBasicType(tag: DW_TAG_base_type, name: "unsigned int", size: 32, align: 32, encoding: DW_ATE_unsigned)
!84 = !MDDerivedType(tag: DW_TAG_member, name: "mydataO", line: 32, size: 3, align: 32, offset: 1, file: !154, scope: !61, baseType: !83)
!85 = !MDDerivedType(tag: DW_TAG_member, name: "cached", line: 33, size: 1, align: 32, offset: 4, file: !154, scope: !61, baseType: !83)
!86 = !MDDerivedType(tag: DW_TAG_member, name: "hasBeenCached", line: 34, size: 1, align: 32, offset: 5, file: !154, scope: !61, baseType: !83)
!87 = !MDDerivedType(tag: DW_TAG_member, name: "hasPattern", line: 35, size: 1, align: 32, offset: 6, file: !154, scope: !61, baseType: !83)
!88 = !MDDerivedType(tag: DW_TAG_member, name: "isCIMydata", line: 36, size: 1, align: 32, offset: 7, file: !154, scope: !61, baseType: !83)
!89 = !MDDerivedType(tag: DW_TAG_member, name: "self", line: 609, size: 32, align: 32, offset: 192, file: !152, scope: !24, baseType: !90)
!90 = !MDDerivedType(tag: DW_TAG_pointer_type, size: 32, align: 32, scope: !0, baseType: !91)
!91 = !MDCompositeType(tag: DW_TAG_structure_type, name: "MyWork", line: 36, size: 384, align: 32, runtimeLang: DW_LANG_ObjC, file: !152, scope: !40, elements: !92)
!92 = !{!93, !98, !101, !107, !123}
!93 = !MDDerivedType(tag: DW_TAG_inheritance, file: !152, scope: !91, baseType: !94)
!94 = !MDCompositeType(tag: DW_TAG_structure_type, name: "twork", line: 43, size: 32, align: 32, runtimeLang: DW_LANG_ObjC, file: !157, scope: !40, elements: !96)
!95 = !MDFile(filename: "header13.h", directory: "/Volumes/Sandbox/llvm")
!96 = !{!97}
!97 = !MDDerivedType(tag: DW_TAG_inheritance, file: !94, baseType: !64)
!98 = !MDDerivedType(tag: DW_TAG_member, name: "_itemID", line: 38, size: 64, align: 32, offset: 32, flags: DIFlagPrivate, file: !152, scope: !24, baseType: !99, extraData: !"")
!99 = !MDDerivedType(tag: DW_TAG_typedef, name: "uint64_t", line: 55, file: !153, scope: !0, baseType: !100)
!100 = !MDBasicType(tag: DW_TAG_base_type, name: "long long unsigned int", size: 64, align: 32, encoding: DW_ATE_unsigned)
!101 = !MDDerivedType(tag: DW_TAG_member, name: "_library", line: 39, size: 32, align: 32, offset: 96, flags: DIFlagPrivate, file: !152, scope: !24, baseType: !102, extraData: !"")
!102 = !MDDerivedType(tag: DW_TAG_pointer_type, size: 32, align: 32, scope: !0, baseType: !103)
!103 = !MDCompositeType(tag: DW_TAG_structure_type, name: "MyLibrary2", line: 22, size: 32, align: 32, runtimeLang: DW_LANG_ObjC, file: !158, scope: !40, elements: !105)
!104 = !MDFile(filename: "header14.h", directory: "/Volumes/Sandbox/llvm")
!105 = !{!106}
!106 = !MDDerivedType(tag: DW_TAG_inheritance, file: !103, baseType: !64)
!107 = !MDDerivedType(tag: DW_TAG_member, name: "_bounds", line: 40, size: 128, align: 32, offset: 128, flags: DIFlagPrivate, file: !152, scope: !24, baseType: !108, extraData: !"")
!108 = !MDDerivedType(tag: DW_TAG_typedef, name: "CR", line: 33, file: !153, scope: !0, baseType: !109)
!109 = !MDCompositeType(tag: DW_TAG_structure_type, name: "CR", line: 29, size: 128, align: 32, file: !156, scope: !0, elements: !110)
!110 = !{!111, !117}
!111 = !MDDerivedType(tag: DW_TAG_member, name: "origin", line: 30, size: 64, align: 32, file: !156, scope: !77, baseType: !112)
!112 = !MDDerivedType(tag: DW_TAG_typedef, name: "CP", line: 17, file: !156, scope: !0, baseType: !113)
!113 = !MDCompositeType(tag: DW_TAG_structure_type, name: "CP", line: 13, size: 64, align: 32, file: !156, scope: !0, elements: !114)
!114 = !{!115, !116}
!115 = !MDDerivedType(tag: DW_TAG_member, name: "x", line: 14, size: 32, align: 32, file: !156, scope: !77, baseType: !76)
!116 = !MDDerivedType(tag: DW_TAG_member, name: "y", line: 15, size: 32, align: 32, offset: 32, file: !156, scope: !77, baseType: !76)
!117 = !MDDerivedType(tag: DW_TAG_member, name: "size", line: 31, size: 64, align: 32, offset: 64, file: !156, scope: !77, baseType: !118)
!118 = !MDDerivedType(tag: DW_TAG_typedef, name: "Size", line: 25, file: !156, scope: !0, baseType: !119)
!119 = !MDCompositeType(tag: DW_TAG_structure_type, name: "Size", line: 21, size: 64, align: 32, file: !156, scope: !0, elements: !120)
!120 = !{!121, !122}
!121 = !MDDerivedType(tag: DW_TAG_member, name: "width", line: 22, size: 32, align: 32, file: !156, scope: !77, baseType: !76)
!122 = !MDDerivedType(tag: DW_TAG_member, name: "height", line: 23, size: 32, align: 32, offset: 32, file: !156, scope: !77, baseType: !76)
!123 = !MDDerivedType(tag: DW_TAG_member, name: "_data", line: 40, size: 128, align: 32, offset: 256, flags: DIFlagPrivate, file: !152, scope: !24, baseType: !108, extraData: !"")
!124 = !MDDerivedType(tag: DW_TAG_member, name: "semi", line: 609, size: 32, align: 32, offset: 224, file: !152, scope: !24, baseType: !125)
!125 = !MDDerivedType(tag: DW_TAG_typedef, name: "d_t", line: 35, file: !152, scope: !0, baseType: !126)
!126 = !MDDerivedType(tag: DW_TAG_pointer_type, size: 32, align: 32, scope: !0, baseType: !127)
!127 = !MDCompositeType(tag: DW_TAG_structure_type, name: "my_struct", line: 49, flags: DIFlagFwdDecl, file: !159, scope: !0)
!128 = !MDFile(filename: "header15.h", directory: "/Volumes/Sandbox/llvm")
!129 = !MDLocation(line: 609, column: 144, scope: !23)
!130 = !MDLocalVariable(tag: DW_TAG_arg_variable, name: "loadedMydata", line: 609, arg: 2, scope: !23, file: !24, type: !59)
!131 = !MDLocation(line: 609, column: 155, scope: !23)
!132 = !MDLocalVariable(tag: DW_TAG_arg_variable, name: "bounds", line: 609, arg: 3, scope: !23, file: !24, type: !108)
!133 = !MDLocation(line: 609, column: 175, scope: !23)
!134 = !MDLocalVariable(tag: DW_TAG_arg_variable, name: "data", line: 609, arg: 4, scope: !23, file: !24, type: !108)
!135 = !MDLocation(line: 609, column: 190, scope: !23)
!136 = !MDLocalVariable(tag: DW_TAG_auto_variable, name: "mydata", line: 604, scope: !23, file: !24, type: !50)
!137 = !MDLocation(line: 604, column: 49, scope: !23)
!138 = !MDLocalVariable(tag: DW_TAG_auto_variable, name: "self", line: 604, scope: !23, file: !40, type: !90)
!139 = !MDLocalVariable(tag: DW_TAG_auto_variable, name: "semi", line: 607, scope: !23, file: !24, type: !125)
!140 = !MDLocation(line: 607, column: 30, scope: !23)
!141 = !MDLocation(line: 610, column: 17, scope: !142)
!142 = distinct !MDLexicalBlock(line: 609, column: 200, file: !152, scope: !23)
!143 = !MDLocation(line: 611, column: 17, scope: !142)
!144 = !MDLocation(line: 612, column: 17, scope: !142)
!145 = !MDLocation(line: 613, column: 17, scope: !142)
!146 = !MDLocation(line: 615, column: 13, scope: !142)
!147 = !{!1, !1, !5, !5, !9, !14, !19, !19, !14, !14, !14, !19, !19, !19}
!148 = !{!23}
!149 = !MDFile(filename: "header3.h", directory: "/Volumes/Sandbox/llvm")
!150 = !MDFile(filename: "Private.h", directory: "/Volumes/Sandbox/llvm")
!151 = !MDFile(filename: "header4.h", directory: "/Volumes/Sandbox/llvm")
!152 = !MDFile(filename: "MyLibrary.m", directory: "/Volumes/Sandbox/llvm")
!153 = !MDFile(filename: "MyLibrary.i", directory: "/Volumes/Sandbox/llvm")
!154 = !MDFile(filename: "header11.h", directory: "/Volumes/Sandbox/llvm")
!155 = !MDFile(filename: "NSO.h", directory: "/Volumes/Sandbox/llvm")
!156 = !MDFile(filename: "header12.h", directory: "/Volumes/Sandbox/llvm")
!157 = !MDFile(filename: "header13.h", directory: "/Volumes/Sandbox/llvm")
!158 = !MDFile(filename: "header14.h", directory: "/Volumes/Sandbox/llvm")
!159 = !MDFile(filename: "header15.h", directory: "/Volumes/Sandbox/llvm")
!160 = !MDFile(filename: "header.h", directory: "/Volumes/Sandbox/llvm")
!161 = !{!"header2.h", !"/Volumes/Sandbox/llvm"}
!162 = !{i32 1, !"Debug Info Version", i32 3}
!163 = !MDExpression(DW_OP_plus, 20, DW_OP_deref, DW_OP_plus, 4, DW_OP_deref, DW_OP_plus, 24)
!164 = !MDExpression(DW_OP_plus, 24)
!165 = !MDExpression(DW_OP_plus, 28)
