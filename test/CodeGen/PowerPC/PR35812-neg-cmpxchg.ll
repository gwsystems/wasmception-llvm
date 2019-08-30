; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; Make sure that a negative value for the compare-and-swap is zero extended
; from i8/i16 to i32 since it will be compared for equality.
; RUN: llc -mtriple=powerpc64le-linux-gnu -verify-machineinstrs < %s | FileCheck %s
; RUN: llc -mtriple=powerpc64le-linux-gnu -mcpu=pwr7 -verify-machineinstrs < %s | FileCheck %s --check-prefix=CHECK-P7

@str = private unnamed_addr constant [46 x i8] c"FAILED: __atomic_compare_exchange_n() failed.\00"
@str.1 = private unnamed_addr constant [59 x i8] c"FAILED: __atomic_compare_exchange_n() set the wrong value.\00"
@str.2 = private unnamed_addr constant [7 x i8] c"PASSED\00"

define signext i32 @main() nounwind {
; CHECK-LABEL: main:
; CHECK:       # %bb.0: # %L.entry
; CHECK-NEXT:    mflr 0
; CHECK-NEXT:    std 0, 16(1)
; CHECK-NEXT:    stdu 1, -48(1)
; CHECK-NEXT:    li 3, -32477
; CHECK-NEXT:    li 6, 234
; CHECK-NEXT:    addi 5, 1, 46
; CHECK-NEXT:    sth 3, 46(1)
; CHECK-NEXT:    lis 3, 0
; CHECK-NEXT:    ori 4, 3, 33059
; CHECK-NEXT:    sync
; CHECK-NEXT:  .LBB0_1: # %L.entry
; CHECK-NEXT:    #
; CHECK-NEXT:    lharx 3, 0, 5
; CHECK-NEXT:    cmpw 4, 3
; CHECK-NEXT:    bne 0, .LBB0_3
; CHECK-NEXT:  # %bb.2: # %L.entry
; CHECK-NEXT:    #
; CHECK-NEXT:    sthcx. 6, 0, 5
; CHECK-NEXT:    bne 0, .LBB0_1
; CHECK-NEXT:    b .LBB0_4
; CHECK-NEXT:  .LBB0_3: # %L.entry
; CHECK-NEXT:    sthcx. 3, 0, 5
; CHECK-NEXT:  .LBB0_4: # %L.entry
; CHECK-NEXT:    cmplwi 3, 33059
; CHECK-NEXT:    lwsync
; CHECK-NEXT:    bne 0, .LBB0_7
; CHECK-NEXT:  # %bb.5: # %L.B0000
; CHECK-NEXT:    lhz 3, 46(1)
; CHECK-NEXT:    cmplwi 3, 234
; CHECK-NEXT:    bne 0, .LBB0_8
; CHECK-NEXT:  # %bb.6: # %L.B0001
; CHECK-NEXT:    addis 3, 2, .Lstr.2@toc@ha
; CHECK-NEXT:    addi 3, 3, .Lstr.2@toc@l
; CHECK-NEXT:    bl puts
; CHECK-NEXT:    nop
; CHECK-NEXT:    li 3, 0
; CHECK-NEXT:    b .LBB0_10
; CHECK-NEXT:  .LBB0_7: # %L.B0003
; CHECK-NEXT:    addis 3, 2, .Lstr@toc@ha
; CHECK-NEXT:    addi 3, 3, .Lstr@toc@l
; CHECK-NEXT:    b .LBB0_9
; CHECK-NEXT:  .LBB0_8: # %L.B0005
; CHECK-NEXT:    addis 3, 2, .Lstr.1@toc@ha
; CHECK-NEXT:    addi 3, 3, .Lstr.1@toc@l
; CHECK-NEXT:  .LBB0_9: # %L.B0003
; CHECK-NEXT:    bl puts
; CHECK-NEXT:    nop
; CHECK-NEXT:    li 3, 1
; CHECK-NEXT:  .LBB0_10: # %L.B0003
; CHECK-NEXT:    addi 1, 1, 48
; CHECK-NEXT:    ld 0, 16(1)
; CHECK-NEXT:    mtlr 0
; CHECK-NEXT:    blr
;
; CHECK-P7-LABEL: main:
; CHECK-P7:       # %bb.0: # %L.entry
; CHECK-P7-NEXT:    mflr 0
; CHECK-P7-NEXT:    std 0, 16(1)
; CHECK-P7-NEXT:    stdu 1, -48(1)
; CHECK-P7-NEXT:    li 3, -32477
; CHECK-P7-NEXT:    lis 5, 0
; CHECK-P7-NEXT:    addi 4, 1, 46
; CHECK-P7-NEXT:    li 7, 0
; CHECK-P7-NEXT:    sth 3, 46(1)
; CHECK-P7-NEXT:    li 6, 234
; CHECK-P7-NEXT:    ori 5, 5, 33059
; CHECK-P7-NEXT:    rlwinm 3, 4, 3, 27, 27
; CHECK-P7-NEXT:    ori 7, 7, 65535
; CHECK-P7-NEXT:    sync
; CHECK-P7-NEXT:    slw 6, 6, 3
; CHECK-P7-NEXT:    slw 8, 5, 3
; CHECK-P7-NEXT:    slw 5, 7, 3
; CHECK-P7-NEXT:    rldicr 4, 4, 0, 61
; CHECK-P7-NEXT:    and 7, 6, 5
; CHECK-P7-NEXT:    and 8, 8, 5
; CHECK-P7-NEXT:  .LBB0_1: # %L.entry
; CHECK-P7-NEXT:    #
; CHECK-P7-NEXT:    lwarx 9, 0, 4
; CHECK-P7-NEXT:    and 6, 9, 5
; CHECK-P7-NEXT:    cmpw 6, 8
; CHECK-P7-NEXT:    bne 0, .LBB0_3
; CHECK-P7-NEXT:  # %bb.2: # %L.entry
; CHECK-P7-NEXT:    #
; CHECK-P7-NEXT:    andc 9, 9, 5
; CHECK-P7-NEXT:    or 9, 9, 7
; CHECK-P7-NEXT:    stwcx. 9, 0, 4
; CHECK-P7-NEXT:    bne 0, .LBB0_1
; CHECK-P7-NEXT:    b .LBB0_4
; CHECK-P7-NEXT:  .LBB0_3: # %L.entry
; CHECK-P7-NEXT:    stwcx. 9, 0, 4
; CHECK-P7-NEXT:  .LBB0_4: # %L.entry
; CHECK-P7-NEXT:    srw 3, 6, 3
; CHECK-P7-NEXT:    lwsync
; CHECK-P7-NEXT:    cmplwi 3, 33059
; CHECK-P7-NEXT:    bne 0, .LBB0_7
; CHECK-P7-NEXT:  # %bb.5: # %L.B0000
; CHECK-P7-NEXT:    lhz 3, 46(1)
; CHECK-P7-NEXT:    cmplwi 3, 234
; CHECK-P7-NEXT:    bne 0, .LBB0_8
; CHECK-P7-NEXT:  # %bb.6: # %L.B0001
; CHECK-P7-NEXT:    addis 3, 2, .Lstr.2@toc@ha
; CHECK-P7-NEXT:    addi 3, 3, .Lstr.2@toc@l
; CHECK-P7-NEXT:    bl puts
; CHECK-P7-NEXT:    nop
; CHECK-P7-NEXT:    li 3, 0
; CHECK-P7-NEXT:    b .LBB0_10
; CHECK-P7-NEXT:  .LBB0_7: # %L.B0003
; CHECK-P7-NEXT:    addis 3, 2, .Lstr@toc@ha
; CHECK-P7-NEXT:    addi 3, 3, .Lstr@toc@l
; CHECK-P7-NEXT:    b .LBB0_9
; CHECK-P7-NEXT:  .LBB0_8: # %L.B0005
; CHECK-P7-NEXT:    addis 3, 2, .Lstr.1@toc@ha
; CHECK-P7-NEXT:    addi 3, 3, .Lstr.1@toc@l
; CHECK-P7-NEXT:  .LBB0_9: # %L.B0003
; CHECK-P7-NEXT:    bl puts
; CHECK-P7-NEXT:    nop
; CHECK-P7-NEXT:    li 3, 1
; CHECK-P7-NEXT:  .LBB0_10: # %L.B0003
; CHECK-P7-NEXT:    addi 1, 1, 48
; CHECK-P7-NEXT:    ld 0, 16(1)
; CHECK-P7-NEXT:    mtlr 0
; CHECK-P7-NEXT:    blr
L.entry:
  %value.addr = alloca i16, align 2
  store i16 -32477, i16* %value.addr, align 2
  %0 = cmpxchg i16* %value.addr, i16 -32477, i16 234 seq_cst seq_cst
  %1 = extractvalue { i16, i1 } %0, 1
  br i1 %1, label %L.B0000, label %L.B0003

L.B0003:                                          ; preds = %L.entry
  %puts = call i32 @puts(i8* getelementptr inbounds ([46 x i8], [46 x i8]* @str, i64 0, i64 0))
  ret i32 1

L.B0000:                                          ; preds = %L.entry
  %2 = load i16, i16* %value.addr, align 2
  %3 = icmp eq i16 %2, 234
  br i1 %3, label %L.B0001, label %L.B0005

L.B0005:                                          ; preds = %L.B0000
  %puts1 = call i32 @puts(i8* getelementptr inbounds ([59 x i8], [59 x i8]* @str.1, i64 0, i64 0))
  ret i32 1

L.B0001:                                          ; preds = %L.B0000
  %puts2 = call i32 @puts(i8* getelementptr inbounds ([7 x i8], [7 x i8]* @str.2, i64 0, i64 0))
  ret i32 0
}

; Function Attrs: nounwind
declare i32 @puts(i8* nocapture readonly) #0
