; NOTE: Assertions have been autogenerated by utils/update_mir_test_checks.py
; RUN: llc -O0 -mtriple=mipsel-linux-gnu -global-isel -stop-after=irtranslator -verify-machineinstrs %s -o - | FileCheck %s -check-prefixes=MIPS32

%struct.S = type { i32, i32 }

define void @ZeroInit(%struct.S* noalias sret %agg.result) {
  ; MIPS32-LABEL: name: ZeroInit
  ; MIPS32: bb.1.entry:
  ; MIPS32:   liveins: $a0
  ; MIPS32:   [[COPY:%[0-9]+]]:_(p0) = COPY $a0
  ; MIPS32:   [[C:%[0-9]+]]:_(s32) = G_CONSTANT i32 0
  ; MIPS32:   [[COPY1:%[0-9]+]]:_(p0) = COPY [[COPY]](p0)
  ; MIPS32:   G_STORE [[C]](s32), [[COPY1]](p0) :: (store 4 into %ir.x)
  ; MIPS32:   [[C1:%[0-9]+]]:_(s32) = G_CONSTANT i32 4
  ; MIPS32:   [[GEP:%[0-9]+]]:_(p0) = G_GEP [[COPY]], [[C1]](s32)
  ; MIPS32:   G_STORE [[C]](s32), [[GEP]](p0) :: (store 4 into %ir.y)
  ; MIPS32:   RetRA
entry:
  %x = getelementptr inbounds %struct.S, %struct.S* %agg.result, i32 0, i32 0
  store i32 0, i32* %x, align 4
  %y = getelementptr inbounds %struct.S, %struct.S* %agg.result, i32 0, i32 1
  store i32 0, i32* %y, align 4
  ret void
}

define void @CallZeroInit(%struct.S* noalias sret %agg.result) {
  ; MIPS32-LABEL: name: CallZeroInit
  ; MIPS32: bb.1.entry:
  ; MIPS32:   liveins: $a0
  ; MIPS32:   [[COPY:%[0-9]+]]:_(p0) = COPY $a0
  ; MIPS32:   ADJCALLSTACKDOWN 16, 0, implicit-def $sp, implicit $sp
  ; MIPS32:   $a0 = COPY [[COPY]](p0)
  ; MIPS32:   JAL @ZeroInit, csr_o32, implicit-def $ra, implicit-def $sp, implicit $a0
  ; MIPS32:   ADJCALLSTACKUP 16, 0, implicit-def $sp, implicit $sp
  ; MIPS32:   RetRA
entry:
  call void @ZeroInit(%struct.S* sret %agg.result)
  ret void
}
