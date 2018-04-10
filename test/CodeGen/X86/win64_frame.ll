; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-pc-win32              | FileCheck %s --check-prefix=ALL --check-prefix=PUSHF
; RUN: llc < %s -mtriple=x86_64-pc-win32 -mattr=+sahf | FileCheck %s --check-prefix=ALL --check-prefix=SAHF

define i32 @f1(i32 %p1, i32 %p2, i32 %p3, i32 %p4, i32 %p5) "no-frame-pointer-elim"="true" {
; ALL-LABEL: f1:
; ALL:       # %bb.0:
; ALL-NEXT:    pushq %rbp
; ALL-NEXT:    .seh_pushreg 5
; ALL-NEXT:    movq %rsp, %rbp
; ALL-NEXT:    .seh_setframe 5, 0
; ALL-NEXT:    .seh_endprologue
; ALL-NEXT:    movl 48(%rbp), %eax
; ALL-NEXT:    popq %rbp
; ALL-NEXT:    retq
; ALL-NEXT:    .seh_handlerdata
; ALL-NEXT:    .text
; ALL-NEXT:    .seh_endproc
  ret i32 %p5
}

define void @f2(i32 %p, ...) "no-frame-pointer-elim"="true" {
; ALL-LABEL: f2:
; ALL:       # %bb.0:
; ALL-NEXT:    pushq %rbp
; ALL-NEXT:    .seh_pushreg 5
; ALL-NEXT:    pushq %rax
; ALL-NEXT:    .seh_stackalloc 8
; ALL-NEXT:    movq %rsp, %rbp
; ALL-NEXT:    .seh_setframe 5, 0
; ALL-NEXT:    .seh_endprologue
; ALL-NEXT:    movq %r9, 48(%rbp)
; ALL-NEXT:    movq %r8, 40(%rbp)
; ALL-NEXT:    movq %rdx, 32(%rbp)
; ALL-NEXT:    leaq 32(%rbp), %rax
; ALL-NEXT:    movq %rax, (%rbp)
; ALL-NEXT:    addq $8, %rsp
; ALL-NEXT:    popq %rbp
; ALL-NEXT:    retq
; ALL-NEXT:    .seh_handlerdata
; ALL-NEXT:    .text
; ALL-NEXT:    .seh_endproc
  %ap = alloca i8, align 8
  call void @llvm.va_start(i8* %ap)
  ret void
}

define i8* @f3() "no-frame-pointer-elim"="true" {
; ALL-LABEL: f3:
; ALL:       # %bb.0:
; ALL-NEXT:    pushq %rbp
; ALL-NEXT:    .seh_pushreg 5
; ALL-NEXT:    movq %rsp, %rbp
; ALL-NEXT:    .seh_setframe 5, 0
; ALL-NEXT:    .seh_endprologue
; ALL-NEXT:    movq 8(%rbp), %rax
; ALL-NEXT:    popq %rbp
; ALL-NEXT:    retq
; ALL-NEXT:    .seh_handlerdata
; ALL-NEXT:    .text
; ALL-NEXT:    .seh_endproc
  %ra = call i8* @llvm.returnaddress(i32 0)
  ret i8* %ra
}

define i8* @f4() "no-frame-pointer-elim"="true" {
; ALL-LABEL: f4:
; ALL:       # %bb.0:
; ALL-NEXT:    pushq %rbp
; ALL-NEXT:    .seh_pushreg 5
; ALL-NEXT:    subq $304, %rsp # imm = 0x130
; ALL-NEXT:    .seh_stackalloc 304
; ALL-NEXT:    leaq {{[0-9]+}}(%rsp), %rbp
; ALL-NEXT:    .seh_setframe 5, 128
; ALL-NEXT:    .seh_endprologue
; ALL-NEXT:    movq 184(%rbp), %rax
; ALL-NEXT:    addq $304, %rsp # imm = 0x130
; ALL-NEXT:    popq %rbp
; ALL-NEXT:    retq
; ALL-NEXT:    .seh_handlerdata
; ALL-NEXT:    .text
; ALL-NEXT:    .seh_endproc
  alloca [300 x i8]
  %ra = call i8* @llvm.returnaddress(i32 0)
  ret i8* %ra
}

declare void @external(i8*)

define void @f5() "no-frame-pointer-elim"="true" {
; ALL-LABEL: f5:
; ALL:       # %bb.0:
; ALL-NEXT:    pushq %rbp
; ALL-NEXT:    .seh_pushreg 5
; ALL-NEXT:    subq $336, %rsp # imm = 0x150
; ALL-NEXT:    .seh_stackalloc 336
; ALL-NEXT:    leaq {{[0-9]+}}(%rsp), %rbp
; ALL-NEXT:    .seh_setframe 5, 128
; ALL-NEXT:    .seh_endprologue
; ALL-NEXT:    leaq -92(%rbp), %rcx
; ALL-NEXT:    callq external
; ALL-NEXT:    nop
; ALL-NEXT:    addq $336, %rsp # imm = 0x150
; ALL-NEXT:    popq %rbp
; ALL-NEXT:    retq
; ALL-NEXT:    .seh_handlerdata
; ALL-NEXT:    .text
; ALL-NEXT:    .seh_endproc
  %a = alloca [300 x i8]
  %gep = getelementptr [300 x i8], [300 x i8]* %a, i32 0, i32 0
  call void @external(i8* %gep)
  ret void
}

define void @f6(i32 %p, ...) "no-frame-pointer-elim"="true" {
; ALL-LABEL: f6:
; ALL:       # %bb.0:
; ALL-NEXT:    pushq %rbp
; ALL-NEXT:    .seh_pushreg 5
; ALL-NEXT:    subq $336, %rsp # imm = 0x150
; ALL-NEXT:    .seh_stackalloc 336
; ALL-NEXT:    leaq {{[0-9]+}}(%rsp), %rbp
; ALL-NEXT:    .seh_setframe 5, 128
; ALL-NEXT:    .seh_endprologue
; ALL-NEXT:    leaq -92(%rbp), %rcx
; ALL-NEXT:    callq external
; ALL-NEXT:    nop
; ALL-NEXT:    addq $336, %rsp # imm = 0x150
; ALL-NEXT:    popq %rbp
; ALL-NEXT:    retq
; ALL-NEXT:    .seh_handlerdata
; ALL-NEXT:    .text
; ALL-NEXT:    .seh_endproc
  %a = alloca [300 x i8]
  %gep = getelementptr [300 x i8], [300 x i8]* %a, i32 0, i32 0
  call void @external(i8* %gep)
  ret void
}

define i32 @f7(i32 %a, i32 %b, i32 %c, i32 %d, i32 %e) "no-frame-pointer-elim"="true" {
; ALL-LABEL: f7:
; ALL:       # %bb.0:
; ALL-NEXT:    pushq %rbp
; ALL-NEXT:    .seh_pushreg 5
; ALL-NEXT:    subq $304, %rsp # imm = 0x130
; ALL-NEXT:    .seh_stackalloc 304
; ALL-NEXT:    leaq {{[0-9]+}}(%rsp), %rbp
; ALL-NEXT:    .seh_setframe 5, 128
; ALL-NEXT:    .seh_endprologue
; ALL-NEXT:    andq $-64, %rsp
; ALL-NEXT:    movl 224(%rbp), %eax
; ALL-NEXT:    leaq 176(%rbp), %rsp
; ALL-NEXT:    popq %rbp
; ALL-NEXT:    retq
; ALL-NEXT:    .seh_handlerdata
; ALL-NEXT:    .text
; ALL-NEXT:    .seh_endproc
  alloca [300 x i8], align 64
  ret i32 %e
}

define i32 @f8(i32 %a, i32 %b, i32 %c, i32 %d, i32 %e) "no-frame-pointer-elim"="true" {
; ALL-LABEL: f8:
; ALL:       # %bb.0:
; ALL-NEXT:    pushq %rbp
; ALL-NEXT:    .seh_pushreg 5
; ALL-NEXT:    pushq %rsi
; ALL-NEXT:    .seh_pushreg 6
; ALL-NEXT:    pushq %rbx
; ALL-NEXT:    .seh_pushreg 3
; ALL-NEXT:    subq $352, %rsp # imm = 0x160
; ALL-NEXT:    .seh_stackalloc 352
; ALL-NEXT:    leaq {{[0-9]+}}(%rsp), %rbp
; ALL-NEXT:    .seh_setframe 5, 128
; ALL-NEXT:    .seh_endprologue
; ALL-NEXT:    andq $-64, %rsp
; ALL-NEXT:    movq %rsp, %rbx
; ALL-NEXT:    movl 288(%rbp), %esi
; ALL-NEXT:    movl %ecx, %eax
; ALL-NEXT:    leaq 15(,%rax,4), %rax
; ALL-NEXT:    andq $-16, %rax
; ALL-NEXT:    callq __chkstk
; ALL-NEXT:    subq %rax, %rsp
; ALL-NEXT:    subq $32, %rsp
; ALL-NEXT:    movq %rbx, %rcx
; ALL-NEXT:    callq external
; ALL-NEXT:    addq $32, %rsp
; ALL-NEXT:    movl %esi, %eax
; ALL-NEXT:    leaq 224(%rbp), %rsp
; ALL-NEXT:    popq %rbx
; ALL-NEXT:    popq %rsi
; ALL-NEXT:    popq %rbp
; ALL-NEXT:    retq
; ALL-NEXT:    .seh_handlerdata
; ALL-NEXT:    .text
; ALL-NEXT:    .seh_endproc
  %alloca = alloca [300 x i8], align 64
  alloca i32, i32 %a
  %gep = getelementptr [300 x i8], [300 x i8]* %alloca, i32 0, i32 0
  call void @external(i8* %gep)
  ret i32 %e
}

define i64 @f9() {
; ALL-LABEL: f9:
; ALL:       # %bb.0: # %entry
; ALL-NEXT:    pushq %rbp
; ALL-NEXT:    .seh_pushreg 5
; ALL-NEXT:    movq %rsp, %rbp
; ALL-NEXT:    .seh_setframe 5, 0
; ALL-NEXT:    .seh_endprologue
; ALL-NEXT:    pushfq
; ALL-NEXT:    popq %rax
; ALL-NEXT:    popq %rbp
; ALL-NEXT:    retq
; ALL-NEXT:    .seh_handlerdata
; ALL-NEXT:    .text
; ALL-NEXT:    .seh_endproc
entry:
  %call = call i64 @llvm.x86.flags.read.u64()
  ret i64 %call
}

declare i64 @dummy()

define i64 @f10(i64* %foo, i64 %bar, i64 %baz) {
; ALL-LABEL: f10:
; ALL:       # %bb.0:
; ALL-NEXT:    pushq %rsi
; ALL-NEXT:    .seh_pushreg 6
; ALL-NEXT:    pushq %rbx
; ALL-NEXT:    .seh_pushreg 3
; ALL-NEXT:    subq $40, %rsp
; ALL-NEXT:    .seh_stackalloc 40
; ALL-NEXT:    .seh_endprologue
; ALL-NEXT:    movq %rdx, %rsi
; ALL-NEXT:    movq %rdx, %rax
; ALL-NEXT:    lock cmpxchgq %r8, (%rcx)
; ALL-NEXT:    sete %bl
; ALL-NEXT:    callq dummy
; ALL-NEXT:    testb $-1, %bl
; ALL-NEXT:    cmoveq %rsi, %rax
; ALL-NEXT:    addq $40, %rsp
; ALL-NEXT:    popq %rbx
; ALL-NEXT:    popq %rsi
; ALL-NEXT:    retq
; ALL-NEXT:    .seh_handlerdata
; ALL-NEXT:    .text
; ALL-NEXT:    .seh_endproc
  %cx = cmpxchg i64* %foo, i64 %bar, i64 %baz seq_cst seq_cst
  %v = extractvalue { i64, i1 } %cx, 0
  %p = extractvalue { i64, i1 } %cx, 1
  %call = call i64 @dummy()
  %sel = select i1 %p, i64 %call, i64 %bar
  ret i64 %sel
}

define i8* @f11() "no-frame-pointer-elim"="true" {
; ALL-LABEL: f11:
; ALL:       # %bb.0:
; ALL-NEXT:    pushq %rbp
; ALL-NEXT:    .seh_pushreg 5
; ALL-NEXT:    movq %rsp, %rbp
; ALL-NEXT:    .seh_setframe 5, 0
; ALL-NEXT:    .seh_endprologue
; ALL-NEXT:    leaq 8(%rbp), %rax
; ALL-NEXT:    popq %rbp
; ALL-NEXT:    retq
; ALL-NEXT:    .seh_handlerdata
; ALL-NEXT:    .text
; ALL-NEXT:    .seh_endproc
  %aora = call i8* @llvm.addressofreturnaddress()
  ret i8* %aora
}

define i8* @f12() {
; ALL-LABEL: f12:
; ALL:       # %bb.0:
; ALL-NEXT:    movq %rsp, %rax
; ALL-NEXT:    retq
  %aora = call i8* @llvm.addressofreturnaddress()
  ret i8* %aora
}

declare i8* @llvm.returnaddress(i32) nounwind readnone
declare i8* @llvm.addressofreturnaddress() nounwind readnone
declare i64 @llvm.x86.flags.read.u64()
declare void @llvm.va_start(i8*) nounwind
