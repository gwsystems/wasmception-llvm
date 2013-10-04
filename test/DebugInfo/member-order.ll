; REQUIRES: object-emission

; RUN: llc -filetype=obj -O0 < %s | llvm-dwarfdump -debug-dump=info - | FileCheck %s

; generated by clang from:
; struct foo {
;   void f1();
;   void f2();
; };
;
; void foo::f1() {
; }

; CHECK: DW_TAG_structure_type
; CHECK-NEXT: DW_AT_name {{.*}} "foo"
; CHECK-NOT: NULL
; CHECK: DW_TAG_subprogram
; CHECK-NOT: NULL
; CHECK: DW_AT_name {{.*}} "f1"
; CHECK: DW_TAG_subprogram
; CHECK-NOT: NULL
; CHECK: DW_AT_name {{.*}} "f2"


%struct.foo = type { i8 }

; Function Attrs: nounwind uwtable
define void @_ZN3foo2f1Ev(%struct.foo* %this) #0 align 2 {
entry:
  %this.addr = alloca %struct.foo*, align 8
  store %struct.foo* %this, %struct.foo** %this.addr, align 8
  call void @llvm.dbg.declare(metadata !{%struct.foo** %this.addr}, metadata !16), !dbg !18
  %this1 = load %struct.foo** %this.addr
  ret void, !dbg !19
}

; Function Attrs: nounwind readnone
declare void @llvm.dbg.declare(metadata, metadata) #1

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!15}

!0 = metadata !{i32 786449, metadata !1, i32 4, metadata !"clang version 3.4 ", i1 false, metadata !"", i32 0, metadata !2, metadata !3, metadata !13, metadata !2, metadata !2, metadata !""} ; [ DW_TAG_compile_unit ] [/tmp/dbginfo/member-order.cpp] [DW_LANG_C_plus_plus]
!1 = metadata !{metadata !"member-order.cpp", metadata !"/tmp/dbginfo"}
!2 = metadata !{i32 0}
!3 = metadata !{metadata !4}
!4 = metadata !{i32 786451, metadata !1, null, metadata !"foo", i32 1, i64 8, i64 8, i32 0, i32 0, null, metadata !5, i32 0, null, null, metadata !"_ZTS3foo"} ; [ DW_TAG_structure_type ] [foo] [line 1, size 8, align 8, offset 0] [def] [from ]
!5 = metadata !{metadata !6, metadata !11}
!6 = metadata !{i32 786478, metadata !1, metadata !4, metadata !"f1", metadata !"f1", metadata !"_ZN3foo2f1Ev", i32 2, metadata !7, i1 false, i1 false, i32 0, i32 0, null, i32 256, i1 false, null, null, i32 0, metadata !10, i32 2} ; [ DW_TAG_subprogram ] [line 2] [f1]
!7 = metadata !{i32 786453, i32 0, null, metadata !"", i32 0, i64 0, i64 0, i64 0, i32 0, null, metadata !8, i32 0, null, null, null} ; [ DW_TAG_subroutine_type ] [line 0, size 0, align 0, offset 0] [from ]
!8 = metadata !{null, metadata !9}
!9 = metadata !{i32 786447, null, null, metadata !"", i32 0, i64 64, i64 64, i64 0, i32 1088, metadata !"_ZTS3foo"} ; [ DW_TAG_pointer_type ] [line 0, size 64, align 64, offset 0] [artificial] [from _ZTS3foo]
!10 = metadata !{i32 786468}
!11 = metadata !{i32 786478, metadata !1, metadata !4, metadata !"f2", metadata !"f2", metadata !"_ZN3foo2f2Ev", i32 3, metadata !7, i1 false, i1 false, i32 0, i32 0, null, i32 256, i1 false, null, null, i32 0, metadata !12, i32 3} ; [ DW_TAG_subprogram ] [line 3] [f2]
!12 = metadata !{i32 786468}
!13 = metadata !{metadata !14}
!14 = metadata !{i32 786478, metadata !1, null, metadata !"f1", metadata !"f1", metadata !"_ZN3foo2f1Ev", i32 6, metadata !7, i1 false, i1 true, i32 0, i32 0, null, i32 256, i1 false, void (%struct.foo*)* @_ZN3foo2f1Ev, null, metadata !6, metadata !2, i32 6} ; [ DW_TAG_subprogram ] [line 6] [def] [f1]
!15 = metadata !{i32 2, metadata !"Dwarf Version", i32 4}
!16 = metadata !{i32 786689, metadata !14, metadata !"this", null, i32 16777216, metadata !17, i32 1088, i32 0} ; [ DW_TAG_arg_variable ] [this] [line 0]
!17 = metadata !{i32 786447, null, null, metadata !"", i32 0, i64 64, i64 64, i64 0, i32 0, metadata !"_ZTS3foo"} ; [ DW_TAG_pointer_type ] [line 0, size 64, align 64, offset 0] [from _ZTS3foo]
!18 = metadata !{i32 0, i32 0, metadata !14, null}
!19 = metadata !{i32 7, i32 0, metadata !14, null}
