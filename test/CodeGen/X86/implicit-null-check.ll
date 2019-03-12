; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -verify-machineinstrs -O3 -mtriple=x86_64-apple-macosx -enable-implicit-null-checks < %s | FileCheck %s

define i32 @imp_null_check_load(i32* %x) {
; CHECK-LABEL: imp_null_check_load:
; CHECK:       ## %bb.0: ## %entry
; CHECK-NEXT:  Ltmp0:
; CHECK-NEXT:    movl (%rdi), %eax ## on-fault: LBB0_1
; CHECK-NEXT:  ## %bb.2: ## %not_null
; CHECK-NEXT:    retq
; CHECK-NEXT:  LBB0_1: ## %is_null
; CHECK-NEXT:    movl $42, %eax
; CHECK-NEXT:    retq

 entry:
  %c = icmp eq i32* %x, null
  br i1 %c, label %is_null, label %not_null, !make.implicit !0

 is_null:
  ret i32 42

 not_null:
  %t = load i32, i32* %x
  ret i32 %t
}

; TODO: can make implicit
define i32 @imp_null_check_unordered_load(i32* %x) {
; CHECK-LABEL: imp_null_check_unordered_load:
; CHECK:       ## %bb.0: ## %entry
; CHECK-NEXT:    testq %rdi, %rdi
; CHECK-NEXT:    je LBB1_1
; CHECK-NEXT:  ## %bb.2: ## %not_null
; CHECK-NEXT:    movl (%rdi), %eax
; CHECK-NEXT:    retq
; CHECK-NEXT:  LBB1_1: ## %is_null
; CHECK-NEXT:    movl $42, %eax
; CHECK-NEXT:    retq

 entry:
  %c = icmp eq i32* %x, null
  br i1 %c, label %is_null, label %not_null, !make.implicit !0

 is_null:
  ret i32 42

 not_null:
  %t = load atomic i32, i32* %x unordered, align 4
  ret i32 %t
}

;; Probably could be implicit, but we're conservative for now
define i32 @imp_null_check_seq_cst_load(i32* %x) {
; CHECK-LABEL: imp_null_check_seq_cst_load:
; CHECK:       ## %bb.0: ## %entry
; CHECK-NEXT:    testq %rdi, %rdi
; CHECK-NEXT:    je LBB2_1
; CHECK-NEXT:  ## %bb.2: ## %not_null
; CHECK-NEXT:    movl (%rdi), %eax
; CHECK-NEXT:    retq
; CHECK-NEXT:  LBB2_1: ## %is_null
; CHECK-NEXT:    movl $42, %eax
; CHECK-NEXT:    retq

 entry:
  %c = icmp eq i32* %x, null
  br i1 %c, label %is_null, label %not_null, !make.implicit !0

 is_null:
  ret i32 42

 not_null:
  %t = load atomic i32, i32* %x seq_cst, align 4
  ret i32 %t
}

;; Might be memory mapped IO, so can't rely on fault behavior
define i32 @imp_null_check_volatile_load(i32* %x) {
; CHECK-LABEL: imp_null_check_volatile_load:
; CHECK:       ## %bb.0: ## %entry
; CHECK-NEXT:    testq %rdi, %rdi
; CHECK-NEXT:    je LBB3_1
; CHECK-NEXT:  ## %bb.2: ## %not_null
; CHECK-NEXT:    movl (%rdi), %eax
; CHECK-NEXT:    retq
; CHECK-NEXT:  LBB3_1: ## %is_null
; CHECK-NEXT:    movl $42, %eax
; CHECK-NEXT:    retq

 entry:
  %c = icmp eq i32* %x, null
  br i1 %c, label %is_null, label %not_null, !make.implicit !0

 is_null:
  ret i32 42

 not_null:
  %t = load volatile i32, i32* %x, align 4
  ret i32 %t
}



define i32 @imp_null_check_gep_load(i32* %x) {
; CHECK-LABEL: imp_null_check_gep_load:
; CHECK:       ## %bb.0: ## %entry
; CHECK-NEXT:  Ltmp1:
; CHECK-NEXT:    movl 128(%rdi), %eax ## on-fault: LBB4_1
; CHECK-NEXT:  ## %bb.2: ## %not_null
; CHECK-NEXT:    retq
; CHECK-NEXT:  LBB4_1: ## %is_null
; CHECK-NEXT:    movl $42, %eax
; CHECK-NEXT:    retq

 entry:
  %c = icmp eq i32* %x, null
  br i1 %c, label %is_null, label %not_null, !make.implicit !0

 is_null:
  ret i32 42

 not_null:
  %x.gep = getelementptr i32, i32* %x, i32 32
  %t = load i32, i32* %x.gep
  ret i32 %t
}

define i32 @imp_null_check_add_result(i32* %x, i32 %p) {
; CHECK-LABEL: imp_null_check_add_result:
; CHECK:       ## %bb.0: ## %entry
; CHECK-NEXT:  Ltmp2:
; CHECK-NEXT:    addl (%rdi), %esi ## on-fault: LBB5_1
; CHECK-NEXT:  ## %bb.2: ## %not_null
; CHECK-NEXT:    movl %esi, %eax
; CHECK-NEXT:    retq
; CHECK-NEXT:  LBB5_1: ## %is_null
; CHECK-NEXT:    movl $42, %eax
; CHECK-NEXT:    retq

 entry:
  %c = icmp eq i32* %x, null
  br i1 %c, label %is_null, label %not_null, !make.implicit !0

 is_null:
  ret i32 42

 not_null:
  %t = load i32, i32* %x
  %p1 = add i32 %t, %p
  ret i32 %p1
}

define i32 @imp_null_check_hoist_over_unrelated_load(i32* %x, i32* %y, i32* %z) {
; CHECK-LABEL: imp_null_check_hoist_over_unrelated_load:
; CHECK:       ## %bb.0: ## %entry
; CHECK-NEXT:  Ltmp3:
; CHECK-NEXT:    movl (%rdi), %eax ## on-fault: LBB6_1
; CHECK-NEXT:  ## %bb.2: ## %not_null
; CHECK-NEXT:    movl (%rsi), %ecx
; CHECK-NEXT:    movl %ecx, (%rdx)
; CHECK-NEXT:    retq
; CHECK-NEXT:  LBB6_1: ## %is_null
; CHECK-NEXT:    movl $42, %eax
; CHECK-NEXT:    retq

 entry:
  %c = icmp eq i32* %x, null
  br i1 %c, label %is_null, label %not_null, !make.implicit !0

 is_null:
  ret i32 42

 not_null:
  %t0 = load i32, i32* %y
  %t1 = load i32, i32* %x
  store i32 %t0, i32* %z
  ret i32 %t1
}

define i32 @imp_null_check_via_mem_comparision(i32* %x, i32 %val) {
; CHECK-LABEL: imp_null_check_via_mem_comparision:
; CHECK:       ## %bb.0: ## %entry
; CHECK-NEXT:  Ltmp4:
; CHECK-NEXT:    cmpl %esi, 4(%rdi) ## on-fault: LBB7_3
; CHECK-NEXT:  ## %bb.1: ## %not_null
; CHECK-NEXT:    jge LBB7_2
; CHECK-NEXT:  ## %bb.4: ## %ret_100
; CHECK-NEXT:    movl $100, %eax
; CHECK-NEXT:    retq
; CHECK-NEXT:  LBB7_3: ## %is_null
; CHECK-NEXT:    movl $42, %eax
; CHECK-NEXT:    retq
; CHECK-NEXT:  LBB7_2: ## %ret_200
; CHECK-NEXT:    movl $200, %eax
; CHECK-NEXT:    retq

 entry:
  %c = icmp eq i32* %x, null
  br i1 %c, label %is_null, label %not_null, !make.implicit !0

 is_null:
  ret i32 42

 not_null:
  %x.loc = getelementptr i32, i32* %x, i32 1
  %t = load i32, i32* %x.loc
  %m = icmp slt i32 %t, %val
  br i1 %m, label %ret_100, label %ret_200

 ret_100:
  ret i32 100

 ret_200:
  ret i32 200
}

define i32 @imp_null_check_gep_load_with_use_dep(i32* %x, i32 %a) {
; CHECK-LABEL: imp_null_check_gep_load_with_use_dep:
; CHECK:       ## %bb.0: ## %entry
; CHECK-NEXT:    ## kill: def $esi killed $esi def $rsi
; CHECK-NEXT:  Ltmp5:
; CHECK-NEXT:    movl (%rdi), %eax ## on-fault: LBB8_1
; CHECK-NEXT:  ## %bb.2: ## %not_null
; CHECK-NEXT:    addl %edi, %esi
; CHECK-NEXT:    leal 4(%rax,%rsi), %eax
; CHECK-NEXT:    retq
; CHECK-NEXT:  LBB8_1: ## %is_null
; CHECK-NEXT:    movl $42, %eax
; CHECK-NEXT:    retq

 entry:
  %c = icmp eq i32* %x, null
  br i1 %c, label %is_null, label %not_null, !make.implicit !0

 is_null:
  ret i32 42

 not_null:
  %x.loc = getelementptr i32, i32* %x, i32 1
  %y = ptrtoint i32* %x.loc to i32
  %b = add i32 %a, %y
  %t = load i32, i32* %x
  %z = add i32 %t, %b
  ret i32 %z
}

define void @imp_null_check_store(i32* %x) {
; CHECK-LABEL: imp_null_check_store:
; CHECK:       ## %bb.0: ## %entry
; CHECK-NEXT:  Ltmp6:
; CHECK-NEXT:    movl $1, (%rdi) ## on-fault: LBB9_1
; CHECK-NEXT:  ## %bb.2: ## %not_null
; CHECK-NEXT:    retq
; CHECK-NEXT:  LBB9_1: ## %is_null
; CHECK-NEXT:    retq

 entry:
  %c = icmp eq i32* %x, null
  br i1 %c, label %is_null, label %not_null, !make.implicit !0

 is_null:
  ret void

 not_null:
  store i32 1, i32* %x
  ret void
}

;; TODO: can be implicit
define void @imp_null_check_unordered_store(i32* %x) {
; CHECK-LABEL: imp_null_check_unordered_store:
; CHECK:       ## %bb.0: ## %entry
; CHECK-NEXT:    testq %rdi, %rdi
; CHECK-NEXT:    je LBB10_1
; CHECK-NEXT:  ## %bb.2: ## %not_null
; CHECK-NEXT:    movl $1, (%rdi)
; CHECK-NEXT:    retq
; CHECK-NEXT:  LBB10_1: ## %is_null
; CHECK-NEXT:    retq

 entry:
  %c = icmp eq i32* %x, null
  br i1 %c, label %is_null, label %not_null, !make.implicit !0

 is_null:
  ret void

 not_null:
  store atomic i32 1, i32* %x unordered, align 4
  ret void
}

define i32 @imp_null_check_neg_gep_load(i32* %x) {
; CHECK-LABEL: imp_null_check_neg_gep_load:
; CHECK:       ## %bb.0: ## %entry
; CHECK-NEXT:  Ltmp7:
; CHECK-NEXT:    movl -128(%rdi), %eax ## on-fault: LBB11_1
; CHECK-NEXT:  ## %bb.2: ## %not_null
; CHECK-NEXT:    retq
; CHECK-NEXT:  LBB11_1: ## %is_null
; CHECK-NEXT:    movl $42, %eax
; CHECK-NEXT:    retq

 entry:
  %c = icmp eq i32* %x, null
  br i1 %c, label %is_null, label %not_null, !make.implicit !0

 is_null:
  ret i32 42

 not_null:
  %x.gep = getelementptr i32, i32* %x, i32 -32
  %t = load i32, i32* %x.gep
  ret i32 %t
}

!0 = !{}
