; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=x86_64-unknown-unknown -mattr=+avx -fixup-byte-word-insts=1 < %s | FileCheck -check-prefix=CHECK -check-prefix=BWON %s
; RUN: llc -mtriple=x86_64-unknown-unknown -mattr=+avx -fixup-byte-word-insts=0 < %s | FileCheck -check-prefix=CHECK -check-prefix=BWOFF %s

%struct.A = type { i8, i8, i8, i8, i8, i8, i8, i8 }
%struct.B = type { i32, i32, i32, i32, i32, i32, i32, i32 }
%struct.C = type { i8, i8, i8, i8, i32, i32, i32, i64 }

; save 1,2,3 ... as one big integer.
define void @merge_const_store(i32 %count, %struct.A* nocapture %p) nounwind uwtable noinline ssp {
; CHECK-LABEL: merge_const_store:
; CHECK:       # %bb.0:
; CHECK-NEXT:    testl %edi, %edi
; CHECK-NEXT:    jle .LBB0_3
; CHECK-NEXT:  # %bb.1: # %.lr.ph.preheader
; CHECK-NEXT:    movabsq $578437695752307201, %rax # imm = 0x807060504030201
; CHECK-NEXT:    .p2align 4, 0x90
; CHECK-NEXT:  .LBB0_2: # %.lr.ph
; CHECK-NEXT:    # =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    movq %rax, (%rsi)
; CHECK-NEXT:    addq $8, %rsi
; CHECK-NEXT:    decl %edi
; CHECK-NEXT:    jne .LBB0_2
; CHECK-NEXT:  .LBB0_3: # %._crit_edge
; CHECK-NEXT:    retq
  %1 = icmp sgt i32 %count, 0
  br i1 %1, label %.lr.ph, label %._crit_edge
.lr.ph:
  %i.02 = phi i32 [ %10, %.lr.ph ], [ 0, %0 ]
  %.01 = phi %struct.A* [ %11, %.lr.ph ], [ %p, %0 ]
  %2 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 0
  store i8 1, i8* %2, align 1
  %3 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 1
  store i8 2, i8* %3, align 1
  %4 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 2
  store i8 3, i8* %4, align 1
  %5 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 3
  store i8 4, i8* %5, align 1
  %6 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 4
  store i8 5, i8* %6, align 1
  %7 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 5
  store i8 6, i8* %7, align 1
  %8 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 6
  store i8 7, i8* %8, align 1
  %9 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 7
  store i8 8, i8* %9, align 1
  %10 = add nsw i32 %i.02, 1
  %11 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 1
  %exitcond = icmp eq i32 %10, %count
  br i1 %exitcond, label %._crit_edge, label %.lr.ph
._crit_edge:
  ret void
}

; No vectors because we use noimplicitfloat
define void @merge_const_store_no_vec(i32 %count, %struct.B* nocapture %p) noimplicitfloat{
; CHECK-LABEL: merge_const_store_no_vec:
; CHECK:       # %bb.0:
; CHECK-NEXT:    testl %edi, %edi
; CHECK-NEXT:    jle .LBB1_2
; CHECK-NEXT:    .p2align 4, 0x90
; CHECK-NEXT:  .LBB1_1: # %.lr.ph
; CHECK-NEXT:    # =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    movq $0, (%rsi)
; CHECK-NEXT:    movq $0, 8(%rsi)
; CHECK-NEXT:    movq $0, 16(%rsi)
; CHECK-NEXT:    movq $0, 24(%rsi)
; CHECK-NEXT:    addq $32, %rsi
; CHECK-NEXT:    decl %edi
; CHECK-NEXT:    jne .LBB1_1
; CHECK-NEXT:  .LBB1_2: # %._crit_edge
; CHECK-NEXT:    retq
  %1 = icmp sgt i32 %count, 0
  br i1 %1, label %.lr.ph, label %._crit_edge
.lr.ph:
  %i.02 = phi i32 [ %10, %.lr.ph ], [ 0, %0 ]
  %.01 = phi %struct.B* [ %11, %.lr.ph ], [ %p, %0 ]
  %2 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 0
  store i32 0, i32* %2, align 4
  %3 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 1
  store i32 0, i32* %3, align 4
  %4 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 2
  store i32 0, i32* %4, align 4
  %5 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 3
  store i32 0, i32* %5, align 4
  %6 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 4
  store i32 0, i32* %6, align 4
  %7 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 5
  store i32 0, i32* %7, align 4
  %8 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 6
  store i32 0, i32* %8, align 4
  %9 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 7
  store i32 0, i32* %9, align 4
  %10 = add nsw i32 %i.02, 1
  %11 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 1
  %exitcond = icmp eq i32 %10, %count
  br i1 %exitcond, label %._crit_edge, label %.lr.ph
._crit_edge:
  ret void
}

; Move the constants using a single vector store.
define void @merge_const_store_vec(i32 %count, %struct.B* nocapture %p) nounwind uwtable noinline ssp {
; CHECK-LABEL: merge_const_store_vec:
; CHECK:       # %bb.0:
; CHECK-NEXT:    testl %edi, %edi
; CHECK-NEXT:    jle .LBB2_3
; CHECK-NEXT:  # %bb.1: # %.lr.ph.preheader
; CHECK-NEXT:    vxorps %xmm0, %xmm0, %xmm0
; CHECK-NEXT:    .p2align 4, 0x90
; CHECK-NEXT:  .LBB2_2: # %.lr.ph
; CHECK-NEXT:    # =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    vmovups %ymm0, (%rsi)
; CHECK-NEXT:    addq $32, %rsi
; CHECK-NEXT:    decl %edi
; CHECK-NEXT:    jne .LBB2_2
; CHECK-NEXT:  .LBB2_3: # %._crit_edge
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
  %1 = icmp sgt i32 %count, 0
  br i1 %1, label %.lr.ph, label %._crit_edge
.lr.ph:
  %i.02 = phi i32 [ %10, %.lr.ph ], [ 0, %0 ]
  %.01 = phi %struct.B* [ %11, %.lr.ph ], [ %p, %0 ]
  %2 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 0
  store i32 0, i32* %2, align 4
  %3 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 1
  store i32 0, i32* %3, align 4
  %4 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 2
  store i32 0, i32* %4, align 4
  %5 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 3
  store i32 0, i32* %5, align 4
  %6 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 4
  store i32 0, i32* %6, align 4
  %7 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 5
  store i32 0, i32* %7, align 4
  %8 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 6
  store i32 0, i32* %8, align 4
  %9 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 7
  store i32 0, i32* %9, align 4
  %10 = add nsw i32 %i.02, 1
  %11 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 1
  %exitcond = icmp eq i32 %10, %count
  br i1 %exitcond, label %._crit_edge, label %.lr.ph
._crit_edge:
  ret void
}

; Move the first 4 constants as a single vector. Move the rest as scalars.
define void @merge_nonconst_store(i32 %count, i8 %zz, %struct.A* nocapture %p) nounwind uwtable noinline ssp {
; CHECK-LABEL: merge_nonconst_store:
; CHECK:       # %bb.0:
; CHECK-NEXT:    testl %edi, %edi
; CHECK-NEXT:    jle .LBB3_2
; CHECK-NEXT:    .p2align 4, 0x90
; CHECK-NEXT:  .LBB3_1: # %.lr.ph
; CHECK-NEXT:    # =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    movl $67305985, (%rdx) # imm = 0x4030201
; CHECK-NEXT:    movb %sil, 4(%rdx)
; CHECK-NEXT:    movw $1798, 5(%rdx) # imm = 0x706
; CHECK-NEXT:    movb $8, 7(%rdx)
; CHECK-NEXT:    addq $8, %rdx
; CHECK-NEXT:    decl %edi
; CHECK-NEXT:    jne .LBB3_1
; CHECK-NEXT:  .LBB3_2: # %._crit_edge
; CHECK-NEXT:    retq
  %1 = icmp sgt i32 %count, 0
  br i1 %1, label %.lr.ph, label %._crit_edge
.lr.ph:
  %i.02 = phi i32 [ %10, %.lr.ph ], [ 0, %0 ]
  %.01 = phi %struct.A* [ %11, %.lr.ph ], [ %p, %0 ]
  %2 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 0
  store i8 1, i8* %2, align 1
  %3 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 1
  store i8 2, i8* %3, align 1
  %4 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 2
  store i8 3, i8* %4, align 1
  %5 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 3
  store i8 4, i8* %5, align 1
  %6 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 4
  store i8 %zz, i8* %6, align 1                     ;  <----------- Not a const;
  %7 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 5
  store i8 6, i8* %7, align 1
  %8 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 6
  store i8 7, i8* %8, align 1
  %9 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 7
  store i8 8, i8* %9, align 1
  %10 = add nsw i32 %i.02, 1
  %11 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 1
  %exitcond = icmp eq i32 %10, %count
  br i1 %exitcond, label %._crit_edge, label %.lr.ph
._crit_edge:
  ret void
}

define void @merge_loads_i16(i32 %count, %struct.A* noalias nocapture %q, %struct.A* noalias nocapture %p) nounwind uwtable noinline ssp {
; BWON-LABEL: merge_loads_i16:
; BWON:       # %bb.0:
; BWON-NEXT:    testl %edi, %edi
; BWON-NEXT:    jle .LBB4_2
; BWON-NEXT:    .p2align 4, 0x90
; BWON-NEXT:  .LBB4_1: # =>This Inner Loop Header: Depth=1
; BWON-NEXT:    movzwl (%rsi), %eax
; BWON-NEXT:    movw %ax, (%rdx)
; BWON-NEXT:    addq $8, %rdx
; BWON-NEXT:    decl %edi
; BWON-NEXT:    jne .LBB4_1
; BWON-NEXT:  .LBB4_2: # %._crit_edge
; BWON-NEXT:    retq
;
; BWOFF-LABEL: merge_loads_i16:
; BWOFF:       # %bb.0:
; BWOFF-NEXT:    testl %edi, %edi
; BWOFF-NEXT:    jle .LBB4_2
; BWOFF-NEXT:    .p2align 4, 0x90
; BWOFF-NEXT:  .LBB4_1: # =>This Inner Loop Header: Depth=1
; BWOFF-NEXT:    movw (%rsi), %ax
; BWOFF-NEXT:    movw %ax, (%rdx)
; BWOFF-NEXT:    addq $8, %rdx
; BWOFF-NEXT:    decl %edi
; BWOFF-NEXT:    jne .LBB4_1
; BWOFF-NEXT:  .LBB4_2: # %._crit_edge
; BWOFF-NEXT:    retq
  %1 = icmp sgt i32 %count, 0
  br i1 %1, label %.lr.ph, label %._crit_edge

.lr.ph:                                           ; preds = %0
  %2 = getelementptr inbounds %struct.A, %struct.A* %q, i64 0, i32 0
  %3 = getelementptr inbounds %struct.A, %struct.A* %q, i64 0, i32 1
  br label %4

; <label>:4                                       ; preds = %4, %.lr.ph
  %i.02 = phi i32 [ 0, %.lr.ph ], [ %9, %4 ]
  %.01 = phi %struct.A* [ %p, %.lr.ph ], [ %10, %4 ]
  %5 = load i8, i8* %2, align 1
  %6 = load i8, i8* %3, align 1
  %7 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 0
  store i8 %5, i8* %7, align 1
  %8 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 1
  store i8 %6, i8* %8, align 1
  %9 = add nsw i32 %i.02, 1
  %10 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 1
  %exitcond = icmp eq i32 %9, %count
  br i1 %exitcond, label %._crit_edge, label %4

._crit_edge:                                      ; preds = %4, %0
  ret void
}

; The loads and the stores are interleaved. Can't merge them.
define void @no_merge_loads(i32 %count, %struct.A* noalias nocapture %q, %struct.A* noalias nocapture %p) nounwind uwtable noinline ssp {
; BWON-LABEL: no_merge_loads:
; BWON:       # %bb.0:
; BWON-NEXT:    testl %edi, %edi
; BWON-NEXT:    jle .LBB5_2
; BWON-NEXT:    .p2align 4, 0x90
; BWON-NEXT:  .LBB5_1: # %a4
; BWON-NEXT:    # =>This Inner Loop Header: Depth=1
; BWON-NEXT:    movzbl (%rsi), %eax
; BWON-NEXT:    movb %al, (%rdx)
; BWON-NEXT:    movzbl 1(%rsi), %eax
; BWON-NEXT:    movb %al, 1(%rdx)
; BWON-NEXT:    addq $8, %rdx
; BWON-NEXT:    decl %edi
; BWON-NEXT:    jne .LBB5_1
; BWON-NEXT:  .LBB5_2: # %._crit_edge
; BWON-NEXT:    retq
;
; BWOFF-LABEL: no_merge_loads:
; BWOFF:       # %bb.0:
; BWOFF-NEXT:    testl %edi, %edi
; BWOFF-NEXT:    jle .LBB5_2
; BWOFF-NEXT:    .p2align 4, 0x90
; BWOFF-NEXT:  .LBB5_1: # %a4
; BWOFF-NEXT:    # =>This Inner Loop Header: Depth=1
; BWOFF-NEXT:    movb (%rsi), %al
; BWOFF-NEXT:    movb %al, (%rdx)
; BWOFF-NEXT:    movb 1(%rsi), %al
; BWOFF-NEXT:    movb %al, 1(%rdx)
; BWOFF-NEXT:    addq $8, %rdx
; BWOFF-NEXT:    decl %edi
; BWOFF-NEXT:    jne .LBB5_1
; BWOFF-NEXT:  .LBB5_2: # %._crit_edge
; BWOFF-NEXT:    retq
  %1 = icmp sgt i32 %count, 0
  br i1 %1, label %.lr.ph, label %._crit_edge

.lr.ph:                                           ; preds = %0
  %2 = getelementptr inbounds %struct.A, %struct.A* %q, i64 0, i32 0
  %3 = getelementptr inbounds %struct.A, %struct.A* %q, i64 0, i32 1
  br label %a4

a4:                                       ; preds = %4, %.lr.ph
  %i.02 = phi i32 [ 0, %.lr.ph ], [ %a9, %a4 ]
  %.01 = phi %struct.A* [ %p, %.lr.ph ], [ %a10, %a4 ]
  %a5 = load i8, i8* %2, align 1
  %a7 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 0
  store i8 %a5, i8* %a7, align 1
  %a8 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 0, i32 1
  %a6 = load i8, i8* %3, align 1
  store i8 %a6, i8* %a8, align 1
  %a9 = add nsw i32 %i.02, 1
  %a10 = getelementptr inbounds %struct.A, %struct.A* %.01, i64 1
  %exitcond = icmp eq i32 %a9, %count
  br i1 %exitcond, label %._crit_edge, label %a4

._crit_edge:                                      ; preds = %4, %0
  ret void
}

define void @merge_loads_integer(i32 %count, %struct.B* noalias nocapture %q, %struct.B* noalias nocapture %p) nounwind uwtable noinline ssp {
; CHECK-LABEL: merge_loads_integer:
; CHECK:       # %bb.0:
; CHECK-NEXT:    testl %edi, %edi
; CHECK-NEXT:    jle .LBB6_2
; CHECK-NEXT:    .p2align 4, 0x90
; CHECK-NEXT:  .LBB6_1: # =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    movq (%rsi), %rax
; CHECK-NEXT:    movq %rax, (%rdx)
; CHECK-NEXT:    addq $32, %rdx
; CHECK-NEXT:    decl %edi
; CHECK-NEXT:    jne .LBB6_1
; CHECK-NEXT:  .LBB6_2: # %._crit_edge
; CHECK-NEXT:    retq
  %1 = icmp sgt i32 %count, 0
  br i1 %1, label %.lr.ph, label %._crit_edge

.lr.ph:                                           ; preds = %0
  %2 = getelementptr inbounds %struct.B, %struct.B* %q, i64 0, i32 0
  %3 = getelementptr inbounds %struct.B, %struct.B* %q, i64 0, i32 1
  br label %4

; <label>:4                                       ; preds = %4, %.lr.ph
  %i.02 = phi i32 [ 0, %.lr.ph ], [ %9, %4 ]
  %.01 = phi %struct.B* [ %p, %.lr.ph ], [ %10, %4 ]
  %5 = load i32, i32* %2
  %6 = load i32, i32* %3
  %7 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 0
  store i32 %5, i32* %7
  %8 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 1
  store i32 %6, i32* %8
  %9 = add nsw i32 %i.02, 1
  %10 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 1
  %exitcond = icmp eq i32 %9, %count
  br i1 %exitcond, label %._crit_edge, label %4

._crit_edge:                                      ; preds = %4, %0
  ret void
}

define void @merge_loads_vector(i32 %count, %struct.B* noalias nocapture %q, %struct.B* noalias nocapture %p) nounwind uwtable noinline ssp {
; CHECK-LABEL: merge_loads_vector:
; CHECK:       # %bb.0:
; CHECK-NEXT:    testl %edi, %edi
; CHECK-NEXT:    jle .LBB7_2
; CHECK-NEXT:    .p2align 4, 0x90
; CHECK-NEXT:  .LBB7_1: # %block4
; CHECK-NEXT:    # =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    vmovups (%rsi), %xmm0
; CHECK-NEXT:    vmovups %xmm0, (%rdx)
; CHECK-NEXT:    addq $32, %rdx
; CHECK-NEXT:    decl %edi
; CHECK-NEXT:    jne .LBB7_1
; CHECK-NEXT:  .LBB7_2: # %._crit_edge
; CHECK-NEXT:    retq
  %a1 = icmp sgt i32 %count, 0
  br i1 %a1, label %.lr.ph, label %._crit_edge

.lr.ph:                                           ; preds = %0
  %a2 = getelementptr inbounds %struct.B, %struct.B* %q, i64 0, i32 0
  %a3 = getelementptr inbounds %struct.B, %struct.B* %q, i64 0, i32 1
  %a4 = getelementptr inbounds %struct.B, %struct.B* %q, i64 0, i32 2
  %a5 = getelementptr inbounds %struct.B, %struct.B* %q, i64 0, i32 3
  br label %block4

block4:                                       ; preds = %4, %.lr.ph
  %i.02 = phi i32 [ 0, %.lr.ph ], [ %c9, %block4 ]
  %.01 = phi %struct.B* [ %p, %.lr.ph ], [ %c10, %block4 ]
  %a7 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 0
  %a8 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 1
  %a9 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 2
  %a10 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 3
  %b1 = load i32, i32* %a2
  %b2 = load i32, i32* %a3
  %b3 = load i32, i32* %a4
  %b4 = load i32, i32* %a5
  store i32 %b1, i32* %a7
  store i32 %b2, i32* %a8
  store i32 %b3, i32* %a9
  store i32 %b4, i32* %a10
  %c9 = add nsw i32 %i.02, 1
  %c10 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 1
  %exitcond = icmp eq i32 %c9, %count
  br i1 %exitcond, label %._crit_edge, label %block4

._crit_edge:                                      ; preds = %4, %0
  ret void
}

; On x86, even unaligned copies can be merged to vector ops.
define void @merge_loads_no_align(i32 %count, %struct.B* noalias nocapture %q, %struct.B* noalias nocapture %p) nounwind uwtable noinline ssp {
; CHECK-LABEL: merge_loads_no_align:
; CHECK:       # %bb.0:
; CHECK-NEXT:    testl %edi, %edi
; CHECK-NEXT:    jle .LBB8_2
; CHECK-NEXT:    .p2align 4, 0x90
; CHECK-NEXT:  .LBB8_1: # %block4
; CHECK-NEXT:    # =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    vmovups (%rsi), %xmm0
; CHECK-NEXT:    vmovups %xmm0, (%rdx)
; CHECK-NEXT:    addq $32, %rdx
; CHECK-NEXT:    decl %edi
; CHECK-NEXT:    jne .LBB8_1
; CHECK-NEXT:  .LBB8_2: # %._crit_edge
; CHECK-NEXT:    retq
  %a1 = icmp sgt i32 %count, 0
  br i1 %a1, label %.lr.ph, label %._crit_edge

.lr.ph:                                           ; preds = %0
  %a2 = getelementptr inbounds %struct.B, %struct.B* %q, i64 0, i32 0
  %a3 = getelementptr inbounds %struct.B, %struct.B* %q, i64 0, i32 1
  %a4 = getelementptr inbounds %struct.B, %struct.B* %q, i64 0, i32 2
  %a5 = getelementptr inbounds %struct.B, %struct.B* %q, i64 0, i32 3
  br label %block4

block4:                                       ; preds = %4, %.lr.ph
  %i.02 = phi i32 [ 0, %.lr.ph ], [ %c9, %block4 ]
  %.01 = phi %struct.B* [ %p, %.lr.ph ], [ %c10, %block4 ]
  %a7 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 0
  %a8 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 1
  %a9 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 2
  %a10 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 0, i32 3
  %b1 = load i32, i32* %a2, align 1
  %b2 = load i32, i32* %a3, align 1
  %b3 = load i32, i32* %a4, align 1
  %b4 = load i32, i32* %a5, align 1
  store i32 %b1, i32* %a7, align 1
  store i32 %b2, i32* %a8, align 1
  store i32 %b3, i32* %a9, align 1
  store i32 %b4, i32* %a10, align 1
  %c9 = add nsw i32 %i.02, 1
  %c10 = getelementptr inbounds %struct.B, %struct.B* %.01, i64 1
  %exitcond = icmp eq i32 %c9, %count
  br i1 %exitcond, label %._crit_edge, label %block4

._crit_edge:                                      ; preds = %4, %0
  ret void
}

; Make sure that we merge the consecutive load/store sequence below and use a
; word (16 bit) instead of a byte copy.
define void @MergeLoadStoreBaseIndexOffset(i64* %a, i8* %b, i8* %c, i32 %n) {
; BWON-LABEL: MergeLoadStoreBaseIndexOffset:
; BWON:       # %bb.0:
; BWON-NEXT:    movl %ecx, %r8d
; BWON-NEXT:    xorl %ecx, %ecx
; BWON-NEXT:    .p2align 4, 0x90
; BWON-NEXT:  .LBB9_1: # =>This Inner Loop Header: Depth=1
; BWON-NEXT:    movq (%rdi,%rcx,8), %rax
; BWON-NEXT:    movzwl (%rdx,%rax), %eax
; BWON-NEXT:    movw %ax, (%rsi,%rcx,2)
; BWON-NEXT:    incq %rcx
; BWON-NEXT:    cmpl %ecx, %r8d
; BWON-NEXT:    jne .LBB9_1
; BWON-NEXT:  # %bb.2:
; BWON-NEXT:    retq
;
; BWOFF-LABEL: MergeLoadStoreBaseIndexOffset:
; BWOFF:       # %bb.0:
; BWOFF-NEXT:    movl %ecx, %r8d
; BWOFF-NEXT:    xorl %ecx, %ecx
; BWOFF-NEXT:    .p2align 4, 0x90
; BWOFF-NEXT:  .LBB9_1: # =>This Inner Loop Header: Depth=1
; BWOFF-NEXT:    movq (%rdi,%rcx,8), %rax
; BWOFF-NEXT:    movw (%rdx,%rax), %ax
; BWOFF-NEXT:    movw %ax, (%rsi,%rcx,2)
; BWOFF-NEXT:    incq %rcx
; BWOFF-NEXT:    cmpl %ecx, %r8d
; BWOFF-NEXT:    jne .LBB9_1
; BWOFF-NEXT:  # %bb.2:
; BWOFF-NEXT:    retq
  br label %1

; <label>:1
  %.09 = phi i32 [ %n, %0 ], [ %11, %1 ]
  %.08 = phi i8* [ %b, %0 ], [ %10, %1 ]
  %.0 = phi i64* [ %a, %0 ], [ %2, %1 ]
  %2 = getelementptr inbounds i64, i64* %.0, i64 1
  %3 = load i64, i64* %.0, align 1
  %4 = getelementptr inbounds i8, i8* %c, i64 %3
  %5 = load i8, i8* %4, align 1
  %6 = add i64 %3, 1
  %7 = getelementptr inbounds i8, i8* %c, i64 %6
  %8 = load i8, i8* %7, align 1
  store i8 %5, i8* %.08, align 1
  %9 = getelementptr inbounds i8, i8* %.08, i64 1
  store i8 %8, i8* %9, align 1
  %10 = getelementptr inbounds i8, i8* %.08, i64 2
  %11 = add nsw i32 %.09, -1
  %12 = icmp eq i32 %11, 0
  br i1 %12, label %13, label %1

; <label>:13
  ret void
}

; Make sure that we merge the consecutive load/store sequence below and use a
; word (16 bit) instead of a byte copy for complicated address calculation.
define void @MergeLoadStoreBaseIndexOffsetComplicated(i8* %a, i8* %b, i8* %c, i64 %n) {
; BWON-LABEL: MergeLoadStoreBaseIndexOffsetComplicated:
; BWON:       # %bb.0:
; BWON-NEXT:    xorl %r8d, %r8d
; BWON-NEXT:    .p2align 4, 0x90
; BWON-NEXT:  .LBB10_1: # =>This Inner Loop Header: Depth=1
; BWON-NEXT:    movsbq (%rsi), %rax
; BWON-NEXT:    movzwl (%rdx,%rax), %eax
; BWON-NEXT:    movw %ax, (%rdi,%r8)
; BWON-NEXT:    incq %rsi
; BWON-NEXT:    addq $2, %r8
; BWON-NEXT:    cmpq %rcx, %r8
; BWON-NEXT:    jl .LBB10_1
; BWON-NEXT:  # %bb.2:
; BWON-NEXT:    retq
;
; BWOFF-LABEL: MergeLoadStoreBaseIndexOffsetComplicated:
; BWOFF:       # %bb.0:
; BWOFF-NEXT:    xorl %r8d, %r8d
; BWOFF-NEXT:    .p2align 4, 0x90
; BWOFF-NEXT:  .LBB10_1: # =>This Inner Loop Header: Depth=1
; BWOFF-NEXT:    movsbq (%rsi), %rax
; BWOFF-NEXT:    movw (%rdx,%rax), %ax
; BWOFF-NEXT:    movw %ax, (%rdi,%r8)
; BWOFF-NEXT:    incq %rsi
; BWOFF-NEXT:    addq $2, %r8
; BWOFF-NEXT:    cmpq %rcx, %r8
; BWOFF-NEXT:    jl .LBB10_1
; BWOFF-NEXT:  # %bb.2:
; BWOFF-NEXT:    retq
  br label %1

; <label>:1
  %.09 = phi i64 [ 0, %0 ], [ %13, %1 ]
  %.08 = phi i8* [ %b, %0 ], [ %12, %1 ]
  %2 = load i8, i8* %.08, align 1
  %3 = sext i8 %2 to i64
  %4 = getelementptr inbounds i8, i8* %c, i64 %3
  %5 = load i8, i8* %4, align 1
  %6 = add nsw i64 %3, 1
  %7 = getelementptr inbounds i8, i8* %c, i64 %6
  %8 = load i8, i8* %7, align 1
  %9 = getelementptr inbounds i8, i8* %a, i64 %.09
  store i8 %5, i8* %9, align 1
  %10 = or i64 %.09, 1
  %11 = getelementptr inbounds i8, i8* %a, i64 %10
  store i8 %8, i8* %11, align 1
  %12 = getelementptr inbounds i8, i8* %.08, i64 1
  %13 = add nuw nsw i64 %.09, 2
  %14 = icmp slt i64 %13, %n
  br i1 %14, label %1, label %15

; <label>:15
  ret void
}

; Make sure that we merge the consecutive load/store sequence below and use a
; word (16 bit) instead of a byte copy even if there are intermediate sign
; extensions.
define void @MergeLoadStoreBaseIndexOffsetSext(i8* %a, i8* %b, i8* %c, i32 %n) {
; BWON-LABEL: MergeLoadStoreBaseIndexOffsetSext:
; BWON:       # %bb.0:
; BWON-NEXT:    movl %ecx, %r8d
; BWON-NEXT:    xorl %ecx, %ecx
; BWON-NEXT:    .p2align 4, 0x90
; BWON-NEXT:  .LBB11_1: # =>This Inner Loop Header: Depth=1
; BWON-NEXT:    movsbq (%rdi,%rcx), %rax
; BWON-NEXT:    movzwl (%rdx,%rax), %eax
; BWON-NEXT:    movw %ax, (%rsi,%rcx,2)
; BWON-NEXT:    incq %rcx
; BWON-NEXT:    cmpl %ecx, %r8d
; BWON-NEXT:    jne .LBB11_1
; BWON-NEXT:  # %bb.2:
; BWON-NEXT:    retq
;
; BWOFF-LABEL: MergeLoadStoreBaseIndexOffsetSext:
; BWOFF:       # %bb.0:
; BWOFF-NEXT:    movl %ecx, %r8d
; BWOFF-NEXT:    xorl %ecx, %ecx
; BWOFF-NEXT:    .p2align 4, 0x90
; BWOFF-NEXT:  .LBB11_1: # =>This Inner Loop Header: Depth=1
; BWOFF-NEXT:    movsbq (%rdi,%rcx), %rax
; BWOFF-NEXT:    movw (%rdx,%rax), %ax
; BWOFF-NEXT:    movw %ax, (%rsi,%rcx,2)
; BWOFF-NEXT:    incq %rcx
; BWOFF-NEXT:    cmpl %ecx, %r8d
; BWOFF-NEXT:    jne .LBB11_1
; BWOFF-NEXT:  # %bb.2:
; BWOFF-NEXT:    retq
  br label %1

; <label>:1
  %.09 = phi i32 [ %n, %0 ], [ %12, %1 ]
  %.08 = phi i8* [ %b, %0 ], [ %11, %1 ]
  %.0 = phi i8* [ %a, %0 ], [ %2, %1 ]
  %2 = getelementptr inbounds i8, i8* %.0, i64 1
  %3 = load i8, i8* %.0, align 1
  %4 = sext i8 %3 to i64
  %5 = getelementptr inbounds i8, i8* %c, i64 %4
  %6 = load i8, i8* %5, align 1
  %7 = add i64 %4, 1
  %8 = getelementptr inbounds i8, i8* %c, i64 %7
  %9 = load i8, i8* %8, align 1
  store i8 %6, i8* %.08, align 1
  %10 = getelementptr inbounds i8, i8* %.08, i64 1
  store i8 %9, i8* %10, align 1
  %11 = getelementptr inbounds i8, i8* %.08, i64 2
  %12 = add nsw i32 %.09, -1
  %13 = icmp eq i32 %12, 0
  br i1 %13, label %14, label %1

; <label>:14
  ret void
}

; However, we can only merge ignore sign extensions when they are on all memory
; computations;
define void @loadStoreBaseIndexOffsetSextNoSex(i8* %a, i8* %b, i8* %c, i32 %n) {
; BWON-LABEL: loadStoreBaseIndexOffsetSextNoSex:
; BWON:       # %bb.0:
; BWON-NEXT:    movl %ecx, %r8d
; BWON-NEXT:    xorl %ecx, %ecx
; BWON-NEXT:    .p2align 4, 0x90
; BWON-NEXT:  .LBB12_1: # =>This Inner Loop Header: Depth=1
; BWON-NEXT:    movsbq (%rdi,%rcx), %rax
; BWON-NEXT:    movzbl (%rdx,%rax), %r9d
; BWON-NEXT:    incl %eax
; BWON-NEXT:    movsbq %al, %rax
; BWON-NEXT:    movzbl (%rdx,%rax), %eax
; BWON-NEXT:    movb %r9b, (%rsi,%rcx,2)
; BWON-NEXT:    movb %al, 1(%rsi,%rcx,2)
; BWON-NEXT:    incq %rcx
; BWON-NEXT:    cmpl %ecx, %r8d
; BWON-NEXT:    jne .LBB12_1
; BWON-NEXT:  # %bb.2:
; BWON-NEXT:    retq
;
; BWOFF-LABEL: loadStoreBaseIndexOffsetSextNoSex:
; BWOFF:       # %bb.0:
; BWOFF-NEXT:    movl %ecx, %r8d
; BWOFF-NEXT:    xorl %ecx, %ecx
; BWOFF-NEXT:    .p2align 4, 0x90
; BWOFF-NEXT:  .LBB12_1: # =>This Inner Loop Header: Depth=1
; BWOFF-NEXT:    movsbq (%rdi,%rcx), %rax
; BWOFF-NEXT:    movb (%rdx,%rax), %r9b
; BWOFF-NEXT:    incl %eax
; BWOFF-NEXT:    movsbq %al, %rax
; BWOFF-NEXT:    movb (%rdx,%rax), %al
; BWOFF-NEXT:    movb %r9b, (%rsi,%rcx,2)
; BWOFF-NEXT:    movb %al, 1(%rsi,%rcx,2)
; BWOFF-NEXT:    incq %rcx
; BWOFF-NEXT:    cmpl %ecx, %r8d
; BWOFF-NEXT:    jne .LBB12_1
; BWOFF-NEXT:  # %bb.2:
; BWOFF-NEXT:    retq
  br label %1

; <label>:1
  %.09 = phi i32 [ %n, %0 ], [ %12, %1 ]
  %.08 = phi i8* [ %b, %0 ], [ %11, %1 ]
  %.0 = phi i8* [ %a, %0 ], [ %2, %1 ]
  %2 = getelementptr inbounds i8, i8* %.0, i64 1
  %3 = load i8, i8* %.0, align 1
  %4 = sext i8 %3 to i64
  %5 = getelementptr inbounds i8, i8* %c, i64 %4
  %6 = load i8, i8* %5, align 1
  %7 = add i8 %3, 1
  %wrap.4 = sext i8 %7 to i64
  %8 = getelementptr inbounds i8, i8* %c, i64 %wrap.4
  %9 = load i8, i8* %8, align 1
  store i8 %6, i8* %.08, align 1
  %10 = getelementptr inbounds i8, i8* %.08, i64 1
  store i8 %9, i8* %10, align 1
  %11 = getelementptr inbounds i8, i8* %.08, i64 2
  %12 = add nsw i32 %.09, -1
  %13 = icmp eq i32 %12, 0
  br i1 %13, label %14, label %1

; <label>:14
  ret void
}

; PR21711 ( http://llvm.org/bugs/show_bug.cgi?id=21711 )
define void @merge_vec_element_store(<8 x float> %v, float* %ptr) {
; CHECK-LABEL: merge_vec_element_store:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vmovups %ymm0, (%rdi)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
  %vecext0 = extractelement <8 x float> %v, i32 0
  %vecext1 = extractelement <8 x float> %v, i32 1
  %vecext2 = extractelement <8 x float> %v, i32 2
  %vecext3 = extractelement <8 x float> %v, i32 3
  %vecext4 = extractelement <8 x float> %v, i32 4
  %vecext5 = extractelement <8 x float> %v, i32 5
  %vecext6 = extractelement <8 x float> %v, i32 6
  %vecext7 = extractelement <8 x float> %v, i32 7
  %arrayidx1 = getelementptr inbounds float, float* %ptr, i64 1
  %arrayidx2 = getelementptr inbounds float, float* %ptr, i64 2
  %arrayidx3 = getelementptr inbounds float, float* %ptr, i64 3
  %arrayidx4 = getelementptr inbounds float, float* %ptr, i64 4
  %arrayidx5 = getelementptr inbounds float, float* %ptr, i64 5
  %arrayidx6 = getelementptr inbounds float, float* %ptr, i64 6
  %arrayidx7 = getelementptr inbounds float, float* %ptr, i64 7
  store float %vecext0, float* %ptr, align 4
  store float %vecext1, float* %arrayidx1, align 4
  store float %vecext2, float* %arrayidx2, align 4
  store float %vecext3, float* %arrayidx3, align 4
  store float %vecext4, float* %arrayidx4, align 4
  store float %vecext5, float* %arrayidx5, align 4
  store float %vecext6, float* %arrayidx6, align 4
  store float %vecext7, float* %arrayidx7, align 4
  ret void

}

; PR21711 - Merge vector stores into wider vector stores.
; These should be merged into 32-byte stores.
define void @merge_vec_extract_stores(<8 x float> %v1, <8 x float> %v2, <4 x float>* %ptr) {
; CHECK-LABEL: merge_vec_extract_stores:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vmovups %ymm0, 48(%rdi)
; CHECK-NEXT:    vmovups %ymm1, 80(%rdi)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
  %idx0 = getelementptr inbounds <4 x float>, <4 x float>* %ptr, i64 3
  %idx1 = getelementptr inbounds <4 x float>, <4 x float>* %ptr, i64 4
  %idx2 = getelementptr inbounds <4 x float>, <4 x float>* %ptr, i64 5
  %idx3 = getelementptr inbounds <4 x float>, <4 x float>* %ptr, i64 6
  %shuffle0 = shufflevector <8 x float> %v1, <8 x float> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %shuffle1 = shufflevector <8 x float> %v1, <8 x float> undef, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %shuffle2 = shufflevector <8 x float> %v2, <8 x float> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %shuffle3 = shufflevector <8 x float> %v2, <8 x float> undef, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  store <4 x float> %shuffle0, <4 x float>* %idx0, align 16
  store <4 x float> %shuffle1, <4 x float>* %idx1, align 16
  store <4 x float> %shuffle2, <4 x float>* %idx2, align 16
  store <4 x float> %shuffle3, <4 x float>* %idx3, align 16
  ret void

}

; Merging vector stores when sourced from vector loads.
define void @merge_vec_stores_from_loads(<4 x float>* %v, <4 x float>* %ptr) {
; CHECK-LABEL: merge_vec_stores_from_loads:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vmovups (%rdi), %ymm0
; CHECK-NEXT:    vmovups %ymm0, (%rsi)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
  %load_idx0 = getelementptr inbounds <4 x float>, <4 x float>* %v, i64 0
  %load_idx1 = getelementptr inbounds <4 x float>, <4 x float>* %v, i64 1
  %v0 = load <4 x float>, <4 x float>* %load_idx0
  %v1 = load <4 x float>, <4 x float>* %load_idx1
  %store_idx0 = getelementptr inbounds <4 x float>, <4 x float>* %ptr, i64 0
  %store_idx1 = getelementptr inbounds <4 x float>, <4 x float>* %ptr, i64 1
  store <4 x float> %v0, <4 x float>* %store_idx0, align 16
  store <4 x float> %v1, <4 x float>* %store_idx1, align 16
  ret void

}

; Merging vector stores when sourced from a constant vector is not currently handled.
define void @merge_vec_stores_of_constants(<4 x i32>* %ptr) {
; CHECK-LABEL: merge_vec_stores_of_constants:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vxorps %xmm0, %xmm0, %xmm0
; CHECK-NEXT:    vmovaps %xmm0, 48(%rdi)
; CHECK-NEXT:    vmovaps %xmm0, 64(%rdi)
; CHECK-NEXT:    retq
  %idx0 = getelementptr inbounds <4 x i32>, <4 x i32>* %ptr, i64 3
  %idx1 = getelementptr inbounds <4 x i32>, <4 x i32>* %ptr, i64 4
  store <4 x i32> <i32 0, i32 0, i32 0, i32 0>, <4 x i32>* %idx0, align 16
  store <4 x i32> <i32 0, i32 0, i32 0, i32 0>, <4 x i32>* %idx1, align 16
  ret void

}

; This is a minimized test based on real code that was failing.
; This should now be merged.
define void @merge_vec_element_and_scalar_load([6 x i64]* %array) {
; CHECK-LABEL: merge_vec_element_and_scalar_load:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vmovups (%rdi), %xmm0
; CHECK-NEXT:    vmovups %xmm0, 32(%rdi)
; CHECK-NEXT:    retq
  %idx0 = getelementptr inbounds [6 x i64], [6 x i64]* %array, i64 0, i64 0
  %idx1 = getelementptr inbounds [6 x i64], [6 x i64]* %array, i64 0, i64 1
  %idx4 = getelementptr inbounds [6 x i64], [6 x i64]* %array, i64 0, i64 4
  %idx5 = getelementptr inbounds [6 x i64], [6 x i64]* %array, i64 0, i64 5

  %a0 = load i64, i64* %idx0, align 8
  store i64 %a0, i64* %idx4, align 8

  %b = bitcast i64* %idx1 to <2 x i64>*
  %v = load <2 x i64>, <2 x i64>* %b, align 8
  %a1 = extractelement <2 x i64> %v, i32 0
  store i64 %a1, i64* %idx5, align 8
  ret void

}

; Don't let a non-consecutive store thwart merging of the last two.
define void @almost_consecutive_stores(i8* %p) {
; CHECK-LABEL: almost_consecutive_stores:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movb $0, (%rdi)
; CHECK-NEXT:    movb $1, 42(%rdi)
; CHECK-NEXT:    movw $770, 2(%rdi) # imm = 0x302
; CHECK-NEXT:    retq
  store i8 0, i8* %p
  %p1 = getelementptr i8, i8* %p, i64 42
  store i8 1, i8* %p1
  %p2 = getelementptr i8, i8* %p, i64 2
  store i8 2, i8* %p2
  %p3 = getelementptr i8, i8* %p, i64 3
  store i8 3, i8* %p3
  ret void
}

; We should be able to merge these.
define void @merge_bitcast(<4 x i32> %v, float* %ptr) {
; CHECK-LABEL: merge_bitcast:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vmovups %xmm0, (%rdi)
; CHECK-NEXT:    retq
  %fv = bitcast <4 x i32> %v to <4 x float>
  %vecext1 = extractelement <4 x i32> %v, i32 1
  %vecext2 = extractelement <4 x i32> %v, i32 2
  %vecext3 = extractelement <4 x i32> %v, i32 3
  %f0 = extractelement <4 x float> %fv, i32 0
  %f1 = bitcast i32 %vecext1 to float
  %f2 = bitcast i32 %vecext2 to float
  %f3 = bitcast i32 %vecext3 to float
  %idx0 = getelementptr inbounds float, float* %ptr, i64 0
  %idx1 = getelementptr inbounds float, float* %ptr, i64 1
  %idx2 = getelementptr inbounds float, float* %ptr, i64 2
  %idx3 = getelementptr inbounds float, float* %ptr, i64 3
  store float %f0, float* %idx0, align 4
  store float %f1, float* %idx1, align 4
  store float %f2, float* %idx2, align 4
  store float %f3, float* %idx3, align 4
  ret void
}

; same as @merge_const_store with heterogeneous types.
define void @merge_const_store_heterogeneous(i32 %count, %struct.C* nocapture %p) nounwind uwtable noinline ssp {
; CHECK-LABEL: merge_const_store_heterogeneous:
; CHECK:       # %bb.0:
; CHECK-NEXT:    testl %edi, %edi
; CHECK-NEXT:    jle .LBB20_3
; CHECK-NEXT:  # %bb.1: # %.lr.ph.preheader
; CHECK-NEXT:    movabsq $578437695752307201, %rax # imm = 0x807060504030201
; CHECK-NEXT:    .p2align 4, 0x90
; CHECK-NEXT:  .LBB20_2: # %.lr.ph
; CHECK-NEXT:    # =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    movq %rax, (%rsi)
; CHECK-NEXT:    addq $24, %rsi
; CHECK-NEXT:    decl %edi
; CHECK-NEXT:    jne .LBB20_2
; CHECK-NEXT:  .LBB20_3: # %._crit_edge
; CHECK-NEXT:    retq
  %1 = icmp sgt i32 %count, 0
  br i1 %1, label %.lr.ph, label %._crit_edge
.lr.ph:
  %i.02 = phi i32 [ %7, %.lr.ph ], [ 0, %0 ]
  %.01 = phi %struct.C* [ %8, %.lr.ph ], [ %p, %0 ]
  %2 = getelementptr inbounds %struct.C, %struct.C* %.01, i64 0, i32 0
  store i8 1, i8* %2, align 1
  %3 = getelementptr inbounds %struct.C, %struct.C* %.01, i64 0, i32 1
  store i8 2, i8* %3, align 1
  %4 = getelementptr inbounds %struct.C, %struct.C* %.01, i64 0, i32 2
  store i8 3, i8* %4, align 1
  %5 = getelementptr inbounds %struct.C, %struct.C* %.01, i64 0, i32 3
  store i8 4, i8* %5, align 1
  %6 = getelementptr inbounds %struct.C, %struct.C* %.01, i64 0, i32 4
  store i32 134678021, i32* %6, align 1
  %7 = add nsw i32 %i.02, 1
  %8 = getelementptr inbounds %struct.C, %struct.C* %.01, i64 1
  %exitcond = icmp eq i32 %7, %count
  br i1 %exitcond, label %._crit_edge, label %.lr.ph
._crit_edge:
  ret void
}

; Merging heterogeneous integer types.
define void @merge_heterogeneous(%struct.C* nocapture %p, %struct.C* nocapture %q) {
; CHECK-LABEL: merge_heterogeneous:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movq (%rdi), %rax
; CHECK-NEXT:    movq %rax, (%rsi)
; CHECK-NEXT:    retq
  %s0 = getelementptr inbounds %struct.C, %struct.C* %p, i64 0, i32 0
  %s1 = getelementptr inbounds %struct.C, %struct.C* %p, i64 0, i32 1
  %s2 = getelementptr inbounds %struct.C, %struct.C* %p, i64 0, i32 2
  %s3 = getelementptr inbounds %struct.C, %struct.C* %p, i64 0, i32 3
  %s4 = getelementptr inbounds %struct.C, %struct.C* %p, i64 0, i32 4
  %d0 = getelementptr inbounds %struct.C, %struct.C* %q, i64 0, i32 0
  %d1 = getelementptr inbounds %struct.C, %struct.C* %q, i64 0, i32 1
  %d2 = getelementptr inbounds %struct.C, %struct.C* %q, i64 0, i32 2
  %d3 = getelementptr inbounds %struct.C, %struct.C* %q, i64 0, i32 3
  %d4 = getelementptr inbounds %struct.C, %struct.C* %q, i64 0, i32 4
  %v0 = load i8, i8* %s0, align 1
  %v1 = load i8, i8* %s1, align 1
  %v2 = load i8, i8* %s2, align 1
  %v3 = load i8, i8* %s3, align 1
  %v4 = load i32, i32* %s4, align 1
  store i8 %v0, i8* %d0, align 1
  store i8 %v1, i8* %d1, align 1
  store i8 %v2, i8* %d2, align 1
  store i8 %v3, i8* %d3, align 1
  store i32 %v4, i32* %d4, align 4
  ret void
}

