;RUN: llc < %s -march=r600 -mcpu=verde | FileCheck %s

;CHECK_LABEL: @test1
;CHECK: TBUFFER_STORE_FORMAT_XYZW {{VGPR[0-9]+_VGPR[0-9]+_VGPR[0-9]+_VGPR[0-9]+}}, 32, -1, 0, -1, 0, 14, 4, {{VGPR[0-9]+}}, {{SGPR[0-9]+_SGPR[0-9]+_SGPR[0-9]+_SGPR[0-9]+}}, -1, 0, 0
define void @test1(i32 %a1, i32 %vaddr) {
    %vdata = insertelement <4 x i32> undef, i32 %a1, i32 0
    call void @llvm.SI.tbuffer.store.v4i32(<16 x i8> undef, <4 x i32> %vdata,
        i32 4, i32 %vaddr, i32 0, i32 32, i32 14, i32 4, i32 1, i32 0, i32 1,
        i32 1, i32 0)
    ret void
}

;CHECK_LABEL: @test2
;CHECK: TBUFFER_STORE_FORMAT_XYZ {{VGPR[0-9]+_VGPR[0-9]+_VGPR[0-9]+_VGPR[0-9]+}}, 24, -1, 0, -1, 0, 13, 4, {{VGPR[0-9]+}}, {{SGPR[0-9]+_SGPR[0-9]+_SGPR[0-9]+_SGPR[0-9]+}}, -1, 0, 0
define void @test2(i32 %a1, i32 %vaddr) {
    %vdata = insertelement <4 x i32> undef, i32 %a1, i32 0
    call void @llvm.SI.tbuffer.store.v4i32(<16 x i8> undef, <4 x i32> %vdata,
        i32 3, i32 %vaddr, i32 0, i32 24, i32 13, i32 4, i32 1, i32 0, i32 1,
        i32 1, i32 0)
    ret void
}

;CHECK_LABEL: @test3
;CHECK: TBUFFER_STORE_FORMAT_XY {{VGPR[0-9]+_VGPR[0-9]+}}, 16, -1, 0, -1, 0, 11, 4, {{VGPR[0-9]+}}, {{SGPR[0-9]+_SGPR[0-9]+_SGPR[0-9]+_SGPR[0-9]+}}, -1, 0, 0
define void @test3(i32 %a1, i32 %vaddr) {
    %vdata = insertelement <2 x i32> undef, i32 %a1, i32 0
    call void @llvm.SI.tbuffer.store.v2i32(<16 x i8> undef, <2 x i32> %vdata,
        i32 2, i32 %vaddr, i32 0, i32 16, i32 11, i32 4, i32 1, i32 0, i32 1,
        i32 1, i32 0)
    ret void
}

;CHECK_LABEL: @test4
;CHECK: TBUFFER_STORE_FORMAT_X {{VGPR[0-9]+}}, 8, -1, 0, -1, 0, 4, 4, {{VGPR[0-9]+}}, {{SGPR[0-9]+_SGPR[0-9]+_SGPR[0-9]+_SGPR[0-9]+}}, -1, 0, 0
define void @test4(i32 %vdata, i32 %vaddr) {
    call void @llvm.SI.tbuffer.store.i32(<16 x i8> undef, i32 %vdata,
        i32 1, i32 %vaddr, i32 0, i32 8, i32 4, i32 4, i32 1, i32 0, i32 1,
        i32 1, i32 0)
    ret void
}

declare void @llvm.SI.tbuffer.store.i32(<16 x i8>, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32)
declare void @llvm.SI.tbuffer.store.v2i32(<16 x i8>, <2 x i32>, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32)
declare void @llvm.SI.tbuffer.store.v4i32(<16 x i8>, <4 x i32>, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32)
