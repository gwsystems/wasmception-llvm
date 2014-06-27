; RUN: not llc %s -o /dev/null 2>&1 | FileCheck %s

target datalayout = "e-m:w-p:32:32-i64:64-f80:32-n8:16:32-S32"
target triple = "i686-pc-windows-msvc"

$foo = comdat largest
@bar = global i32 0, comdat $foo
; CHECK: Associative COMDAT symbol 'foo' does not exist.
