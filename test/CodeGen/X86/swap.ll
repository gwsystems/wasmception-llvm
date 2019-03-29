; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu -mcpu=haswell | FileCheck %s -check-prefix=NOAA
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu -mcpu=haswell -combiner-global-alias-analysis=1 | FileCheck %s -check-prefix=AA

declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture)
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture writeonly, i8* nocapture readonly, i64, i1)
declare void @llvm.lifetime.end.p0i8(i64, i8* nocapture)

%struct.S = type { [16 x i8] }

define dso_local void @_Z4SwapP1SS0_(%struct.S* nocapture %a, %struct.S* nocapture %b) local_unnamed_addr {
; NOAA-LABEL: _Z4SwapP1SS0_:
; NOAA:       # %bb.0: # %entry
; NOAA-NEXT:    vmovups (%rdi), %xmm0
; NOAA-NEXT:    vmovaps %xmm0, -{{[0-9]+}}(%rsp)
; NOAA-NEXT:    vmovups (%rsi), %xmm0
; NOAA-NEXT:    vmovups %xmm0, (%rdi)
; NOAA-NEXT:    vmovaps -{{[0-9]+}}(%rsp), %xmm0
; NOAA-NEXT:    vmovups %xmm0, (%rsi)
; NOAA-NEXT:    retq
;
; AA-LABEL: _Z4SwapP1SS0_:
; AA:       # %bb.0: # %entry
; AA-NEXT:    vmovups (%rdi), %xmm0
; AA-NEXT:    vmovups (%rsi), %xmm1
; AA-NEXT:    vmovups %xmm1, (%rdi)
; AA-NEXT:    vmovups %xmm0, (%rsi)
; AA-NEXT:    retq
entry:
  %tmp.sroa.0 = alloca [16 x i8], align 1
  %tmp.sroa.0.0..sroa_idx6 = getelementptr inbounds [16 x i8], [16 x i8]* %tmp.sroa.0, i64 0, i64 0
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %tmp.sroa.0.0..sroa_idx6)
  %tmp.sroa.0.0..sroa_idx1 = getelementptr inbounds %struct.S, %struct.S* %a, i64 0, i32 0, i64 0
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 1 %tmp.sroa.0.0..sroa_idx6, i8* align 1 %tmp.sroa.0.0..sroa_idx1, i64 16, i1 false)
  %0 = getelementptr inbounds %struct.S, %struct.S* %b, i64 0, i32 0, i64 0
  tail call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %tmp.sroa.0.0..sroa_idx1, i8* align 1 %0, i64 16, i1 false), !tbaa.struct !2
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %0, i8* nonnull align 1 %tmp.sroa.0.0..sroa_idx6, i64 16, i1 false)
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %tmp.sroa.0.0..sroa_idx6)
  ret void
}

define dso_local void @onealloc_noreadback(i8* nocapture %a, i8* nocapture %b) local_unnamed_addr {
; NOAA-LABEL: onealloc_noreadback:
; NOAA:       # %bb.0: # %entry
; NOAA-NEXT:    retq
;
; AA-LABEL: onealloc_noreadback:
; AA:       # %bb.0: # %entry
; AA-NEXT:    retq
entry:
  %alloc = alloca [16 x i8], i8 2, align 1
  %part1 = getelementptr inbounds [16 x i8], [16 x i8]* %alloc, i64 0, i64 0
  %part2 = getelementptr inbounds [16 x i8], [16 x i8]* %alloc, i64 1, i64 0
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %part1)
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %part2)
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 1 %part1, i8* align 1 %a, i64 16, i1 false)
  tail call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 1 %part2, i8* align 1 %b, i64 16, i1 false)
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %part1)
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %part2)
  ret void
}


define dso_local void @twoallocs_trivial(i8* nocapture %a, i8* nocapture %b) local_unnamed_addr {
; NOAA-LABEL: twoallocs_trivial:
; NOAA:       # %bb.0: # %entry
; NOAA-NEXT:    retq
;
; AA-LABEL: twoallocs_trivial:
; AA:       # %bb.0: # %entry
; AA-NEXT:    retq
entry:
  %alloc1 = alloca [16 x i8], align 1
  %alloc2 = alloca [16 x i8], align 1
  %part1 = getelementptr inbounds [16 x i8], [16 x i8]* %alloc1, i64 0, i64 0
  %part2 = getelementptr inbounds [16 x i8], [16 x i8]* %alloc2, i64 0, i64 0
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %part1)
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %part2)
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 1 %part1, i8* align 1 %a, i64 16, i1 false)
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 1 %part2, i8* align 1 %b, i64 16, i1 false)
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %part1)
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %part2)
  ret void
}

define dso_local void @twoallocs(i8* nocapture %a, i8* nocapture %b) local_unnamed_addr {
; NOAA-LABEL: twoallocs:
; NOAA:       # %bb.0: # %entry
; NOAA-NEXT:    vmovups (%rdi), %xmm0
; NOAA-NEXT:    vmovaps %xmm0, -{{[0-9]+}}(%rsp)
; NOAA-NEXT:    vmovups %xmm0, (%rsi)
; NOAA-NEXT:    retq
;
; AA-LABEL: twoallocs:
; AA:       # %bb.0: # %entry
; AA-NEXT:    vmovups (%rdi), %xmm0
; AA-NEXT:    vmovups %xmm0, (%rsi)
; AA-NEXT:    retq
entry:
  %alloc1 = alloca [16 x i8], align 1
  %alloc2 = alloca [16 x i8], align 1
  %part1 = getelementptr inbounds [16 x i8], [16 x i8]* %alloc1, i64 0, i64 0
  %part2 = getelementptr inbounds [16 x i8], [16 x i8]* %alloc2, i64 0, i64 0
  %part2_alias = getelementptr inbounds [16 x i8], [16 x i8]* %alloc2, i64 0, i64 0
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %part1)
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %part2)
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 1 %part2, i8* align 1 %a, i64 16, i1 false)
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %part1)
  tail call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 1 %b, i8* align 1 %part2_alias, i64 16, i1 false)
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %part2)
  ret void
}

define dso_local void @onealloc_readback_1(i8* nocapture %a, i8* nocapture %b) local_unnamed_addr {
; NOAA-LABEL: onealloc_readback_1:
; NOAA:       # %bb.0: # %entry
; NOAA-NEXT:    vmovups (%rdi), %xmm0
; NOAA-NEXT:    vmovaps %xmm0, -{{[0-9]+}}(%rsp)
; NOAA-NEXT:    vmovups (%rsi), %xmm0
; NOAA-NEXT:    vmovaps %xmm0, -{{[0-9]+}}(%rsp)
; NOAA-NEXT:    vmovups %xmm0, (%rdi)
; NOAA-NEXT:    retq
;
; AA-LABEL: onealloc_readback_1:
; AA:       # %bb.0: # %entry
; AA-NEXT:    vmovups (%rsi), %xmm0
; AA-NEXT:    vmovups %xmm0, (%rdi)
; AA-NEXT:    retq
entry:
  %alloc = alloca [16 x i8], i8 2, align 1
  %part2 = getelementptr inbounds [16 x i8], [16 x i8]* %alloc, i64 0, i64 0
  %part1 = getelementptr inbounds [16 x i8], [16 x i8]* %alloc, i64 1, i64 0
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %part1)
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %part2)
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 1 %part1, i8* align 1 %a, i64 16, i1 false)
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 1 %part2, i8* align 1 %b, i64 16, i1 false)
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %part1)
  tail call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 1 %a, i8* align 1 %part2, i64 16, i1 false)
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %part2)
  ret void
}

define dso_local void @onealloc_readback_2(i8* nocapture %a, i8* nocapture %b) local_unnamed_addr {
; NOAA-LABEL: onealloc_readback_2:
; NOAA:       # %bb.0: # %entry
; NOAA-NEXT:    vmovups (%rdi), %xmm0
; NOAA-NEXT:    vmovaps %xmm0, -{{[0-9]+}}(%rsp)
; NOAA-NEXT:    vmovups (%rsi), %xmm0
; NOAA-NEXT:    vmovaps %xmm0, -{{[0-9]+}}(%rsp)
; NOAA-NEXT:    vmovups %xmm0, (%rdi)
; NOAA-NEXT:    retq
;
; AA-LABEL: onealloc_readback_2:
; AA:       # %bb.0: # %entry
; AA-NEXT:    vmovups (%rsi), %xmm0
; AA-NEXT:    vmovups %xmm0, (%rdi)
; AA-NEXT:    retq
entry:
  %alloc = alloca [16 x i8], i8 2, align 1
  %part1 = getelementptr inbounds [16 x i8], [16 x i8]* %alloc, i64 0, i64 0
  %part2 = getelementptr inbounds [16 x i8], [16 x i8]* %alloc, i64 1, i64 0
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %part1)
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %part2)
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 1 %part1, i8* align 1 %a, i64 16, i1 false)
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 1 %part2, i8* align 1 %b, i64 16, i1 false)
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %part1)
  tail call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 1 %a, i8* align 1 %part2, i64 16, i1 false)
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %part2)
  ret void
}


!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 9.0.0 (trunk 352631) (llvm/trunk 352632)"}
!2 = !{i64 0, i64 16, !3}
!3 = !{!4, !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C++ TBAA"}
