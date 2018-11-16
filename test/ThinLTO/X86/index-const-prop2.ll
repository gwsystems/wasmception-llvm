; Check constant propagation in thinlto combined summary. This allows us to do 2 things:
;  1. Internalize global definition which is not used externally if all accesses to it are read-only
;  2. Make a local copy of internal definition if all accesses to it are readonly. This allows constant
;     folding it during optimziation phase.
; RUN: opt -module-summary %s -o %t1.bc
; RUN: opt -module-summary %p/Inputs/index-const-prop.ll -o %t2.bc
; RUN: llvm-lto2 run %t1.bc %t2.bc -save-temps \
; RUN:  -r=%t2.bc,foo,pl \
; RUN:  -r=%t2.bc,bar,pl \
; RUN:  -r=%t2.bc,baz,pl \
; RUN:  -r=%t2.bc,rand, \
; RUN:  -r=%t2.bc,gBar,pl \
; RUN:  -r=%t1.bc,main,plx \
; RUN:  -r=%t1.bc,foo, \
; RUN:  -r=%t1.bc,bar, \
; RUN:  -r=%t1.bc,gBar, \
; RUN:  -o %t3
; RUN: llvm-dis %t3.1.3.import.bc -o - | FileCheck %s --check-prefix=IMPORT
; RUN: llvm-dis %t3.1.5.precodegen.bc -o - | FileCheck %s --check-prefix=CODEGEN

; Now check that we won't internalize global (gBar) if it's externally referenced
; RUN: llvm-lto2 run %t1.bc %t2.bc -save-temps \
; RUN:  -r=%t2.bc,foo,pl \
; RUN:  -r=%t2.bc,bar,pl \
; RUN:  -r=%t2.bc,baz,pl \
; RUN:  -r=%t2.bc,rand, \
; RUN:  -r=%t2.bc,gBar,plx \
; RUN:  -r=%t1.bc,main,plx \
; RUN:  -r=%t1.bc,foo, \
; RUN:  -r=%t1.bc,bar, \
; RUN:  -r=%t1.bc,gBar, \
; RUN:  -o %t3
; RUN: llvm-dis %t3.1.3.import.bc -o - | FileCheck %s --check-prefix=IMPORT2

; IMPORT:       @gFoo.llvm.0 = internal unnamed_addr global i32 1, align 4
; IMPORT-NEXT:  @gBar = internal local_unnamed_addr global i32 2, align 4
; IMPORT:       !DICompileUnit({{.*}}, globals: !{{[0-9]+}})

; CODEGEN:        i32 @main()
; CODEGEN-NEXT:     ret i32 3

; IMPORT2: @gBar = available_externally dso_local local_unnamed_addr global i32 2, align 4

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; We should be able to link external definition of gBar to its declaration
@gBar = external global i32

define i32 @main() local_unnamed_addr {
  %call = tail call i32 bitcast (i32 (...)* @foo to i32 ()*)()
  %call1 = tail call i32 bitcast (i32 (...)* @bar to i32 ()*)()
  %add = add nsw i32 %call1, %call
  ret i32 %add
}

declare i32 @foo(...) local_unnamed_addr

declare i32 @bar(...) local_unnamed_addr
