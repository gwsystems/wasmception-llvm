; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -newgvn -S | FileCheck %s

	%struct..0anon = type { i32 }
	%struct.FILE = type { i8*, i32, i32, i16, i16, %struct.__sbuf, i32, i8*, i32 (i8*)*, i32 (i8*, i8*, i32)*, i64 (i8*, i64, i32)*, i32 (i8*, i8*, i32)*, %struct.__sbuf, %struct.__sFILEX*, i32, [3 x i8], [1 x i8], %struct.__sbuf, i32, i64 }
	%struct.__sFILEX = type opaque
	%struct.__sbuf = type { i8*, i32 }
	%struct.rtx_def = type { i16, i8, i8, [1 x %struct..0anon] }
@n_spills = external global i32		; <i32*> [#uses=2]

define i32 @reload(%struct.rtx_def* %first, i32 %global, %struct.FILE* %dumpfile) {
; CHECK-LABEL: @reload(
; CHECK-NEXT:  cond_next2835.1:
; CHECK-NEXT:    br label [[BB2928:%.*]]
; CHECK:       bb2928:
; CHECK-NEXT:    br i1 false, label [[COND_NEXT2943:%.*]], label [[COND_TRUE2935:%.*]]
; CHECK:       cond_true2935:
; CHECK-NEXT:    br label [[COND_NEXT2943]]
; CHECK:       cond_next2943:
; CHECK-NEXT:    br i1 false, label [[BB2982_PREHEADER:%.*]], label [[BB2928]]
; CHECK:       bb2982.preheader:
; CHECK-NEXT:    store i8 undef, i8* null
; CHECK-NEXT:    ret i32 undef
;
cond_next2835.1:		; preds = %cond_next2861
  %tmp2922 = load i32, i32* @n_spills, align 4		; <i32> [#uses=0]
  br label %bb2928

bb2928:		; preds = %cond_next2835.1, %cond_next2943
  br i1 false, label %cond_next2943, label %cond_true2935

cond_true2935:		; preds = %bb2928
  br label %cond_next2943

cond_next2943:		; preds = %cond_true2935, %bb2928
  br i1 false, label %bb2982.preheader, label %bb2928

bb2982.preheader:		; preds = %cond_next2943
  %tmp298316 = load i32, i32* @n_spills, align 4		; <i32> [#uses=0]
  ret i32 %tmp298316

}
