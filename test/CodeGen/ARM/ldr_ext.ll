; RUN: llvm-as < %s | llc -march=arm &&
; RUN: llvm-as < %s | llc -march=arm | grep "ldrb"  | wc -l | grep 1 &&
; RUN: llvm-as < %s | llc -march=arm | grep "ldrh"  | wc -l | grep 1 &&
; RUN: llvm-as < %s | llc -march=arm | grep "ldrsb" | wc -l | grep 1 &&
; RUN: llvm-as < %s | llc -march=arm | grep "ldrsh" | wc -l | grep 1 &&
; RUN: llvm-as < %s | llc -march=arm -enable-thumb | grep "ldrb"  | wc -l | grep 1 &&
; RUN: llvm-as < %s | llc -march=arm -enable-thumb | grep "ldrh"  | wc -l | grep 1 &&
; RUN: llvm-as < %s | llc -march=arm -enable-thumb | grep "ldrsb" | wc -l | grep 1 &&
; RUN: llvm-as < %s | llc -march=arm -enable-thumb | grep "ldrsh" | wc -l | grep 1

define i32 @test1(i8* %v.pntr.s0.u1) {
    %tmp.u = load i8* %v.pntr.s0.u1
    %tmp1.s = zext i8 %tmp.u to i32
    ret i32 %tmp1.s
}

define i32 @test2(i16* %v.pntr.s0.u1) {
    %tmp.u = load i16* %v.pntr.s0.u1
    %tmp1.s = zext i16 %tmp.u to i32
    ret i32 %tmp1.s
}

define i32 @test3(i8* %v.pntr.s1.u0) {
    %tmp.s = load i8* %v.pntr.s1.u0
    %tmp1.s = sext i8 %tmp.s to i32
    ret i32 %tmp1.s
}

define i32 @test4() {
    %tmp.s = load i16* null
    %tmp1.s = sext i16 %tmp.s to i32
    ret i32 %tmp1.s
}
