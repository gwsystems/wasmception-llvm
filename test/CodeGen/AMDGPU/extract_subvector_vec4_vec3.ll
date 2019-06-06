; NOTE: Assertions have been autogenerated by utils/update_mir_test_checks.py
; RUN: llc -mtriple=amdgcn-mesa-mesa3d -mcpu=gfx900 < %s -stop-after=amdgpu-isel | FileCheck -check-prefix=GCN %s

; We want to see a BUFFER_LOAD, some register shuffling, and a BUFFER_STORE.
; Specifically, we do not want to see a BUFFER_STORE that says "store into
; stack" in the middle.

define amdgpu_hs void @main([0 x i8] addrspace(6)* inreg %arg) {
  ; GCN-LABEL: name: main
  ; GCN: bb.0.main_body:
  ; GCN:   [[S_MOV_B32_:%[0-9]+]]:sreg_32_xm0 = S_MOV_B32 0
  ; GCN:   [[DEF:%[0-9]+]]:sreg_32_xm0 = IMPLICIT_DEF
  ; GCN:   [[COPY:%[0-9]+]]:vgpr_32 = COPY [[DEF]]
  ; GCN:   [[DEF1:%[0-9]+]]:sreg_128 = IMPLICIT_DEF
  ; GCN:   [[BUFFER_LOAD_DWORDX4_OFFEN:%[0-9]+]]:vreg_128 = BUFFER_LOAD_DWORDX4_OFFEN [[COPY]], [[DEF1]], [[S_MOV_B32_]], 0, 0, 0, 0, 0, implicit $exec :: (dereferenceable load 16 from custom TargetCustom7, align 1, addrspace 4)
  ; GCN:   [[COPY1:%[0-9]+]]:vgpr_32 = COPY [[BUFFER_LOAD_DWORDX4_OFFEN]].sub2
  ; GCN:   [[COPY2:%[0-9]+]]:vgpr_32 = COPY [[BUFFER_LOAD_DWORDX4_OFFEN]].sub1
  ; GCN:   [[COPY3:%[0-9]+]]:vgpr_32 = COPY [[BUFFER_LOAD_DWORDX4_OFFEN]].sub0
  ; GCN:   [[REG_SEQUENCE:%[0-9]+]]:sgpr_96 = REG_SEQUENCE killed [[COPY3]], %subreg.sub0, killed [[COPY2]], %subreg.sub1, killed [[COPY1]], %subreg.sub2
  ; GCN:   [[COPY4:%[0-9]+]]:vreg_96 = COPY [[REG_SEQUENCE]]
  ; GCN:   [[DEF2:%[0-9]+]]:sreg_32_xm0 = IMPLICIT_DEF
  ; GCN:   [[COPY5:%[0-9]+]]:vgpr_32 = COPY [[DEF2]]
  ; GCN:   [[DEF3:%[0-9]+]]:sreg_128 = IMPLICIT_DEF
  ; GCN:   BUFFER_STORE_DWORDX3_OFFEN_exact killed [[COPY4]], [[COPY5]], [[DEF3]], [[S_MOV_B32_]], 0, 0, 0, 0, 0, implicit $exec :: (dereferenceable store 12 into custom TargetCustom7, align 1, addrspace 4)
  ; GCN:   S_ENDPGM 0
main_body:
  %tmp25 = call <4 x float> @llvm.amdgcn.raw.buffer.load.v4f32(<4 x i32> undef, i32 undef, i32 0, i32 0)
  %tmp27 = bitcast <4 x float> %tmp25 to <16 x i8>
  %tmp28 = shufflevector <16 x i8> %tmp27, <16 x i8> undef, <12 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11>
  %tmp29 = bitcast <12 x i8> %tmp28 to <3 x i32>
  call void @llvm.amdgcn.raw.buffer.store.v3i32(<3 x i32> %tmp29, <4 x i32> undef, i32 undef, i32 0, i32 0) #3
  ret void
}

declare void @llvm.amdgcn.raw.buffer.store.v3i32(<3 x i32>, <4 x i32>, i32, i32, i32 immarg)
declare <4 x float> @llvm.amdgcn.raw.buffer.load.v4f32(<4 x i32>, i32, i32, i32 immarg)

