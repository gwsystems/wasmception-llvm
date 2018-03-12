; RUN: llc -march=hexagon < %s | FileCheck %s
;
; Check that we do not generate v0 = vand(v1,v1)

; CHECK-NOT: v{{[0-9]+}} = vand(v{{[0-9]+}},v{{[0-9]+}})

; Function Attrs: nounwind
define void @f0(i8* nocapture readonly %a0, i8* nocapture readonly %a1, i32 %a2, i8* nocapture %a3, i32 %a4, i32 %a5) #0 {
b0:
  %v0 = bitcast i8* %a1 to i64*
  %v1 = load i64, i64* %v0, align 8, !tbaa !0
  %v2 = shl i64 %v1, 8
  %v3 = trunc i64 %v2 to i32
  %v4 = trunc i64 %v1 to i32
  %v5 = and i32 %v4, 16777215
  %v6 = bitcast i8* %a0 to <16 x i32>*
  %v7 = load <16 x i32>, <16 x i32>* %v6, align 64, !tbaa !4
  %v8 = getelementptr inbounds i8, i8* %a0, i32 32
  %v9 = bitcast i8* %v8 to <16 x i32>*
  %v10 = load <16 x i32>, <16 x i32>* %v9, align 64, !tbaa !4
  %v11 = tail call <32 x i32> @llvm.hexagon.V6.vcombine(<16 x i32> %v10, <16 x i32> %v7)
  %v12 = tail call <32 x i32> @llvm.hexagon.V6.vrmpybusi(<32 x i32> %v11, i32 %v5, i32 0)
  %v13 = tail call <32 x i32> @llvm.hexagon.V6.vrmpybusi(<32 x i32> %v11, i32 %v3, i32 0)
  %v14 = tail call <16 x i32> @llvm.hexagon.V6.hi(<32 x i32> %v12)
  %v15 = tail call <16 x i32> @llvm.hexagon.V6.vasrwuhsat(<16 x i32> %v14, <16 x i32> %v14, i32 %a2)
  %v16 = tail call <16 x i32> @llvm.hexagon.V6.lo(<32 x i32> %v13)
  %v17 = tail call <16 x i32> @llvm.hexagon.V6.vasrwuhsat(<16 x i32> %v16, <16 x i32> %v16, i32 %a2)
  %v18 = getelementptr inbounds i8, i8* %a3, i32 32
  %v19 = bitcast i8* %v18 to <16 x i32>*
  store <16 x i32> %v15, <16 x i32>* %v19, align 64, !tbaa !4
  %v20 = bitcast i8* %a3 to <16 x i32>*
  store <16 x i32> %v17, <16 x i32>* %v20, align 64, !tbaa !4
  ret void
}

; Function Attrs: nounwind readnone
declare <32 x i32> @llvm.hexagon.V6.vcombine(<16 x i32>, <16 x i32>) #1

; Function Attrs: nounwind readnone
declare <32 x i32> @llvm.hexagon.V6.vrmpybusi(<32 x i32>, i32, i32) #1

; Function Attrs: nounwind readnone
declare <16 x i32> @llvm.hexagon.V6.vasrwuhsat(<16 x i32>, <16 x i32>, i32) #1

; Function Attrs: nounwind readnone
declare <16 x i32> @llvm.hexagon.V6.hi(<32 x i32>) #1

; Function Attrs: nounwind readnone
declare <16 x i32> @llvm.hexagon.V6.lo(<32 x i32>) #1

; Function Attrs: nounwind readnone
define i32 @f1() #2 {
b0:
  ret i32 0
}

attributes #0 = { nounwind "target-cpu"="hexagonv60" "target-features"="+hvxv60,+hvx-length64b" }
attributes #1 = { nounwind readnone }
attributes #2 = { nounwind readnone "target-cpu"="hexagonv60" "target-features"="+hvxv60,+hvx-length64b" }

!0 = !{!1, !1, i64 0}
!1 = !{!"long long", !2, i64 0}
!2 = !{!"omnipotent char", !3, i64 0}
!3 = !{!"Simple C/C++ TBAA"}
!4 = !{!2, !2, i64 0}
