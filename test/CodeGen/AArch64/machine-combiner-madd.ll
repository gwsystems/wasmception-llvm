; Test all AArch64 subarches with scheduling models.
; RUN: llc -mtriple=aarch64-linux-gnu -mcpu=cortex-a57 < %s | FileCheck %s
; RUN: llc -mtriple=aarch64-linux-gnu -mcpu=cortex-a72 < %s | FileCheck %s
; RUN: llc -mtriple=aarch64-linux-gnu -mcpu=cortex-a73 < %s | FileCheck %s
; RUN: llc -mtriple=aarch64-linux-gnu -mcpu=cyclone    < %s | FileCheck %s
; RUN: llc -mtriple=aarch64-linux-gnu -mcpu=exynos-m1  < %s | FileCheck %s
; RUN: llc -mtriple=aarch64-linux-gnu -mcpu=exynos-m2  < %s | FileCheck %s
; RUN: llc -mtriple=aarch64-linux-gnu -mcpu=kryo       < %s | FileCheck %s
; RUN: llc -mtriple=aarch64-linux-gnu -mcpu=vulcan     < %s | FileCheck %s
; RUN: llc -mtriple=aarch64-linux-gnu -mcpu=cortex-a57 -debug-only=machine-combiner < %s 2>&1 > /dev/null | FileCheck %s --check-prefix COMBINE-DUMP

; The machine-combiner debugging dumps should print the new instruction.
; COMBINE-DUMP: NEW INSTR{{.*}}MADDXrrr
; COMBINE-DUMP-NOT: NEW INSTR{{.*}}UNKNOWN

; Make sure that inst-combine fuses the multiply add in the addressing mode of
; the load.

; CHECK-LABEL: fun:
; CHECK-NOT: mul
; CHECK:     madd
; CHECK-NOT: mul

%class.D = type { %class.basic_string.base, [4 x i8] }
%class.basic_string.base = type <{ i64, i64, i32 }>
@a = global %class.D* zeroinitializer, align 8
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture writeonly, i8* nocapture readonly, i64, i32, i1)
define internal void @fun() section ".text.startup" {
entry:
  %tmp.i.i = alloca %class.D, align 8
  %y = bitcast %class.D* %tmp.i.i to i8*
  br label %loop
loop:
  %conv11.i.i = phi i64 [ 0, %entry ], [ %inc.i.i, %loop ]
  %i = phi i64 [ undef, %entry ], [ %inc.i.i, %loop ]
  %x = load %class.D*, %class.D** getelementptr inbounds (%class.D*, %class.D** @a, i64 0), align 8
  %arrayidx.i.i.i = getelementptr inbounds %class.D, %class.D* %x, i64 %conv11.i.i
  %d = bitcast %class.D* %arrayidx.i.i.i to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull %y, i8* %d, i64 24, i32 8, i1 false)
  %inc.i.i = add i64 %i, 1
  %cmp.i.i = icmp slt i64 %inc.i.i, 0
  br i1 %cmp.i.i, label %loop, label %exit
exit:
  ret void
}
