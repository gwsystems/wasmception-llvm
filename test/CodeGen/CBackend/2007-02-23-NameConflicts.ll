; RUN: llvm-as < %s | llc -march=c | grep 'llvm_cbe_A = \*llvm_cbe_G;' &&
; RUN: llvm-as < %s | llc -march=c | grep 'llvm_cbe_B = \*(&ltmp_0_1);' &&
; RUN: llvm-as < %s | llc -march=c | grep 'return (llvm_cbe_A + llvm_cbe_B);'
; PR1164
@G = global i32 123
@ltmp_0_1 = global i32 123

define i32 @test(i32 *%G) {
        %A = load i32* %G
        %B = load i32* @ltmp_0_1
        %C = add i32 %A, %B
        ret i32 %C
}
