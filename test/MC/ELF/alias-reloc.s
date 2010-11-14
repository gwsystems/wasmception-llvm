// RUN: llvm-mc -filetype=obj -triple x86_64-pc-linux-gnu %s -o - | elf-dump  | FileCheck %s

// Test that this produces a R_X86_64_PLT32 with bar.

        .globl foo
foo:
bar = foo
        .section zed, "", @progbits
        call bar@PLT

// CHECK:       # Symbol 0x00000001
// CHECK-NEXT:  (('st_name', 0x00000005) # 'bar'
// CHECK-NEXT:   ('st_bind', 0x00000000)
// CHECK-NEXT:   ('st_type', 0x00000000)
// CHECK-NEXT:   ('st_other', 0x00000000)
// CHECK-NEXT:   ('st_shndx', 0x00000001)
// CHECK-NEXT:   ('st_value', 0x00000000)
// CHECK-NEXT:   ('st_size', 0x00000000)
// CHECK-NEXT:  ),

// CHECK:       # Relocation 0x00000000
// CHECK-NEXT:  (('r_offset', 0x00000001)
// CHECK-NEXT:   ('r_sym', 0x00000001)
// CHECK-NEXT:   ('r_type', 0x00000004)
// CHECK-NEXT:   ('r_addend', 0xfffffffc)
// CHECK-NEXT:  ),
