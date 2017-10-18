; RUN: llc -march=hexagon -O3 < %s | FileCheck %s

; This test checks if we custom lower extract_subvector. If we cannot
; custom lower extract_subvector this test makes the compiler crash.

; CHECK: vmem
target triple = "hexagon-unknown--elf"

; Function Attrs: nounwind
define void @__processed() #0 {
entry:
  br label %"for matrix.s0.y"

"for matrix.s0.y":                                ; preds = %"for matrix.s0.y", %entry
  br i1 undef, label %"produce processed", label %"for matrix.s0.y"

"produce processed":                              ; preds = %"for matrix.s0.y"
  br i1 undef, label %"for processed.s0.ty.ty.preheader", label %"consume processed"

"for processed.s0.ty.ty.preheader":               ; preds = %"produce processed"
  br i1 undef, label %"for denoised.s0.y.preheader", label %"consume denoised"

"for denoised.s0.y.preheader":                    ; preds = %"for processed.s0.ty.ty.preheader"
  unreachable

"consume denoised":                               ; preds = %"for processed.s0.ty.ty.preheader"
  br i1 undef, label %"consume deinterleaved", label %if.then.i164

if.then.i164:                                     ; preds = %"consume denoised"
  unreachable

"consume deinterleaved":                          ; preds = %"consume denoised"
  %0 = tail call <64 x i32> @llvm.hexagon.V6.vshuffvdd.128B(<32 x i32> undef, <32 x i32> undef, i32 -2)
  %1 = bitcast <64 x i32> %0 to <128 x i16>
  %2 = shufflevector <128 x i16> %1, <128 x i16> undef, <64 x i32> <i32 64, i32 65, i32 66, i32 67, i32 68, i32 69, i32 70, i32 71, i32 72, i32 73, i32 74, i32 75, i32 76, i32 77, i32 78, i32 79, i32 80, i32 81, i32 82, i32 83, i32 84, i32 85, i32 86, i32 87, i32 88, i32 89, i32 90, i32 91, i32 92, i32 93, i32 94, i32 95, i32 96, i32 97, i32 98, i32 99, i32 100, i32 101, i32 102, i32 103, i32 104, i32 105, i32 106, i32 107, i32 108, i32 109, i32 110, i32 111, i32 112, i32 113, i32 114, i32 115, i32 116, i32 117, i32 118, i32 119, i32 120, i32 121, i32 122, i32 123, i32 124, i32 125, i32 126, i32 127>
  store <64 x i16> %2, <64 x i16>* undef, align 128
  unreachable

"consume processed":                              ; preds = %"produce processed"
  ret void
}

; Function Attrs: nounwind readnone
declare <64 x i32> @llvm.hexagon.V6.vshuffvdd.128B(<32 x i32>, <32 x i32>, i32) #1

attributes #0 = { nounwind "target-cpu"="hexagonv60" "target-features"="+hvx,+hvx-length128b" }
attributes #1 = { nounwind readnone "target-cpu"="hexagonv60" "target-features"="+hvx,+hvx-length128b" }
