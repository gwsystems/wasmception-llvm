;RUN: llc < %s -march=r600 -mcpu=redwood | diff %s.check -


define void @test() {
   %r0 = call float @llvm.R600.load.input(i32 0)
   %r1 = call float @llvm.AMDGPU.rcp( float %r0)
   call void @llvm.AMDGPU.store.output(float %r1, i32 0)
   ret void
}

declare float @llvm.R600.load.input(i32) readnone

declare void @llvm.AMDGPU.store.output(float, i32)

declare float @llvm.AMDGPU.rcp(float ) readnone
