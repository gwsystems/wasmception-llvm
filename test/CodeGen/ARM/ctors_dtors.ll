; RUN: llvm-as <  %s | llc -mtriple=arm-apple-darwin | FileCheck %s -check-prefix=DARWIN
; RUN: llvm-as  < %s | llc -mtriple=arm-linux-gnu | FileCheck %s -check-prefix=ELF
; RUN: llvm-as < %s | llc -mtriple=arm-linux-gnueabi | FileCheck %s -check-prefix=GNUEABI

; DARWIN: .mod_init_func
; DARWIN: .mod_term_func

; ELF: .section .ctors,"aw",%progbits
; ELF: .section .dtors,"aw",%progbits

; GNUEABI: .section .init_array,"aw",%init_array
; GNUEABI: .section .fini_array,"aw",%fini_array

@llvm.global_ctors = appending global [1 x { i32, void ()* }] [ { i32, void ()* } { i32 65535, void ()* @__mf_init } ]                ; <[1 x { i32, void ()* }]*> [#uses=0]
@llvm.global_dtors = appending global [1 x { i32, void ()* }] [ { i32, void ()* } { i32 65535, void ()* @__mf_fini } ]                ; <[1 x { i32, void ()* }]*> [#uses=0]

define void @__mf_init() {
entry:
        ret void
}

define void @__mf_fini() {
entry:
        ret void
}
