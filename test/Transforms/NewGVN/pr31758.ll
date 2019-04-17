; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -newgvn %s -S -o - | FileCheck %s

%struct.dipsy = type {}
%struct.fluttershy = type { %struct.dipsy* }
%struct.patatino = type {}

define void @tinkywinky() {
; CHECK-LABEL: @tinkywinky(
; CHECK-NEXT:  bb:
; CHECK-NEXT:    br label [[BB90:%.*]]
; CHECK:       bb90:
; CHECK-NEXT:    br label [[BB90]]
; CHECK:       bb138:
; CHECK-NEXT:    store i8 undef, i8* null
; CHECK-NEXT:    br label [[BB138:%.*]]
;
bb:
  br label %bb90

bb90:
  %tmp = getelementptr inbounds %struct.fluttershy, %struct.fluttershy* undef, i64 0, i32 0
  %tmp91 = bitcast %struct.dipsy** %tmp to %struct.patatino**
  %tmp92 = load %struct.patatino*, %struct.patatino** %tmp91, align 8
  %tmp99 = getelementptr inbounds %struct.patatino, %struct.patatino* %tmp92
  %tmp134 = getelementptr inbounds %struct.fluttershy, %struct.fluttershy* undef, i64 0, i32 0
  %tmp135 = bitcast %struct.dipsy** %tmp134 to %struct.patatino**
  %tmp136 = load %struct.patatino*, %struct.patatino** %tmp135, align 8
  br label %bb90

bb138:
  %tmp139 = getelementptr inbounds %struct.patatino, %struct.patatino* %tmp136
  br label %bb138
}
