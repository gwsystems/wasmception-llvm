; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=powerpc64-unknown-linux-gnu -mcpu=pwr8 < %s | FileCheck %s
; RUN: llc -mtriple=powerpc64le-unknown-linux-gnu -mcpu=pwr8 < %s | FileCheck %s

define zeroext i32 @ReverseBits(i32 zeroext %n) {
; CHECK-LABEL: ReverseBits:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    lis 4, -21846
; CHECK-NEXT:    lis 5, 21845
; CHECK-NEXT:    slwi 6, 3, 1
; CHECK-NEXT:    srwi 3, 3, 1
; CHECK-NEXT:    lis 7, -13108
; CHECK-NEXT:    lis 8, 13107
; CHECK-NEXT:    ori 4, 4, 43690
; CHECK-NEXT:    ori 5, 5, 21845
; CHECK-NEXT:    lis 10, -3856
; CHECK-NEXT:    lis 11, 3855
; CHECK-NEXT:    and 3, 3, 5
; CHECK-NEXT:    and 4, 6, 4
; CHECK-NEXT:    ori 5, 8, 13107
; CHECK-NEXT:    or 3, 3, 4
; CHECK-NEXT:    ori 4, 7, 52428
; CHECK-NEXT:    slwi 9, 3, 2
; CHECK-NEXT:    srwi 3, 3, 2
; CHECK-NEXT:    and 3, 3, 5
; CHECK-NEXT:    and 4, 9, 4
; CHECK-NEXT:    ori 5, 11, 3855
; CHECK-NEXT:    or 3, 3, 4
; CHECK-NEXT:    ori 4, 10, 61680
; CHECK-NEXT:    slwi 12, 3, 4
; CHECK-NEXT:    srwi 3, 3, 4
; CHECK-NEXT:    and 4, 12, 4
; CHECK-NEXT:    and 3, 3, 5
; CHECK-NEXT:    or 3, 3, 4
; CHECK-NEXT:    rotlwi 4, 3, 24
; CHECK-NEXT:    rlwimi 4, 3, 8, 8, 15
; CHECK-NEXT:    rlwimi 4, 3, 8, 24, 31
; CHECK-NEXT:    rldicl 3, 4, 0, 32
; CHECK-NEXT:    clrldi 3, 3, 32
; CHECK-NEXT:    blr
entry:
  %shr = lshr i32 %n, 1
  %and = and i32 %shr, 1431655765
  %and1 = shl i32 %n, 1
  %shl = and i32 %and1, -1431655766
  %or = or i32 %and, %shl
  %shr2 = lshr i32 %or, 2
  %and3 = and i32 %shr2, 858993459
  %and4 = shl i32 %or, 2
  %shl5 = and i32 %and4, -858993460
  %or6 = or i32 %and3, %shl5
  %shr7 = lshr i32 %or6, 4
  %and8 = and i32 %shr7, 252645135
  %and9 = shl i32 %or6, 4
  %shl10 = and i32 %and9, -252645136
  %or11 = or i32 %and8, %shl10
  %shr13 = lshr i32 %or11, 24
  %and14 = lshr i32 %or11, 8
  %shr15 = and i32 %and14, 65280
  %and17 = shl i32 %or11, 8
  %shl18 = and i32 %and17, 16711680
  %shl21 = shl i32 %or11, 24
  %or16 = or i32 %shl21, %shr13
  %or19 = or i32 %or16, %shr15
  %or22 = or i32 %or19, %shl18
  ret i32 %or22
}

define i64 @ReverseBits64(i64 %n) {
; CHECK-LABEL: ReverseBits64:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    lis 4, -21846
; CHECK-NEXT:    lis 5, 21845
; CHECK-NEXT:    lis 6, -13108
; CHECK-NEXT:    lis 7, 13107
; CHECK-NEXT:    sldi 8, 3, 1
; CHECK-NEXT:    rldicl 3, 3, 63, 1
; CHECK-NEXT:    ori 4, 4, 43690
; CHECK-NEXT:    ori 5, 5, 21845
; CHECK-NEXT:    ori 6, 6, 52428
; CHECK-NEXT:    ori 7, 7, 13107
; CHECK-NEXT:    sldi 4, 4, 32
; CHECK-NEXT:    sldi 5, 5, 32
; CHECK-NEXT:    oris 4, 4, 43690
; CHECK-NEXT:    oris 5, 5, 21845
; CHECK-NEXT:    ori 4, 4, 43690
; CHECK-NEXT:    ori 5, 5, 21845
; CHECK-NEXT:    and 3, 3, 5
; CHECK-NEXT:    sldi 5, 6, 32
; CHECK-NEXT:    sldi 6, 7, 32
; CHECK-NEXT:    and 4, 8, 4
; CHECK-NEXT:    lis 7, 3855
; CHECK-NEXT:    or 3, 3, 4
; CHECK-NEXT:    oris 12, 5, 52428
; CHECK-NEXT:    oris 9, 6, 13107
; CHECK-NEXT:    lis 6, -3856
; CHECK-NEXT:    ori 7, 7, 3855
; CHECK-NEXT:    sldi 8, 3, 2
; CHECK-NEXT:    ori 4, 12, 52428
; CHECK-NEXT:    rldicl 3, 3, 62, 2
; CHECK-NEXT:    ori 5, 9, 13107
; CHECK-NEXT:    ori 6, 6, 61680
; CHECK-NEXT:    and 3, 3, 5
; CHECK-NEXT:    sldi 5, 6, 32
; CHECK-NEXT:    and 4, 8, 4
; CHECK-NEXT:    sldi 6, 7, 32
; CHECK-NEXT:    or 3, 3, 4
; CHECK-NEXT:    oris 10, 5, 61680
; CHECK-NEXT:    oris 11, 6, 3855
; CHECK-NEXT:    sldi 6, 3, 4
; CHECK-NEXT:    ori 4, 10, 61680
; CHECK-NEXT:    rldicl 3, 3, 60, 4
; CHECK-NEXT:    ori 5, 11, 3855
; CHECK-NEXT:    and 4, 6, 4
; CHECK-NEXT:    and 3, 3, 5
; CHECK-NEXT:    or 3, 3, 4
; CHECK-NEXT:    rldicl 4, 3, 32, 32
; CHECK-NEXT:    rlwinm 6, 3, 24, 0, 31
; CHECK-NEXT:    rlwinm 5, 4, 24, 0, 31
; CHECK-NEXT:    rlwimi 6, 3, 8, 8, 15
; CHECK-NEXT:    rlwimi 5, 4, 8, 8, 15
; CHECK-NEXT:    rlwimi 6, 3, 8, 24, 31
; CHECK-NEXT:    rlwimi 5, 4, 8, 24, 31
; CHECK-NEXT:    sldi 12, 5, 32
; CHECK-NEXT:    or 3, 12, 6
; CHECK-NEXT:    blr
entry:
  %shr = lshr i64 %n, 1
  %and = and i64 %shr, 6148914691236517205
  %and1 = shl i64 %n, 1
  %shl = and i64 %and1, -6148914691236517206
  %or = or i64 %and, %shl
  %shr2 = lshr i64 %or, 2
  %and3 = and i64 %shr2, 3689348814741910323
  %and4 = shl i64 %or, 2
  %shl5 = and i64 %and4, -3689348814741910324
  %or6 = or i64 %and3, %shl5
  %shr7 = lshr i64 %or6, 4
  %and8 = and i64 %shr7, 1085102592571150095
  %and9 = shl i64 %or6, 4
  %shl10 = and i64 %and9, -1085102592571150096
  %or11 = or i64 %and8, %shl10
  %shr13 = lshr i64 %or11, 56
  %and14 = lshr i64 %or11, 40
  %shr15 = and i64 %and14, 65280
  %and17 = lshr i64 %or11, 24
  %shr18 = and i64 %and17, 16711680
  %and20 = lshr i64 %or11, 8
  %shr21 = and i64 %and20, 4278190080
  %and23 = shl i64 %or11, 8
  %shl24 = and i64 %and23, 1095216660480
  %and26 = shl i64 %or11, 24
  %shl27 = and i64 %and26, 280375465082880
  %and29 = shl i64 %or11, 40
  %shl30 = and i64 %and29, 71776119061217280
  %shl33 = shl i64 %or11, 56
  %or16 = or i64 %shl33, %shr13
  %or19 = or i64 %or16, %shr15
  %or22 = or i64 %or19, %shr18
  %or25 = or i64 %or22, %shr21
  %or28 = or i64 %or25, %shl24
  %or31 = or i64 %or28, %shl27
  %or34 = or i64 %or31, %shl30
  ret i64 %or34
}
