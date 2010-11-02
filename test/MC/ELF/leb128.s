// RUN: llvm-mc -filetype=obj -triple x86_64-pc-linux-gnu %s -o - | elf-dump  --dump-section-data | FileCheck %s

        .sleb128 .Lfoo - .Lbar
.Lfoo:
        .uleb128 .Lbar - .Lfoo
        .fill 126, 1, 0x90
.Lbar:

// CHECK:     (('sh_name', 0x00000001) # '.text'
// CHECK-NEXT: ('sh_type', 0x00000001)
// CHECK-NEXT: ('sh_flags', 0x00000006)
// CHECK-NEXT: ('sh_addr', 0x00000000)
// CHECK-NEXT: ('sh_offset', 0x00000040)
// CHECK-NEXT: ('sh_size', 0x00000081)
// CHECK-NEXT: ('sh_link', 0x00000000)
// CHECK-NEXT: ('sh_info', 0x00000000)
// CHECK-NEXT: ('sh_addralign', 0x00000004)
// CHECK-NEXT: ('sh_entsize', 0x00000000)
// CHECK-NEXT: ('_section_data', '817f7f90 90909090 90909090 90909090 90909090 90909090 90909090 90909090 90909090 90909090 90909090 90909090 90909090 90909090 90909090 90909090 90909090 90909090 90909090 90909090 90909090 90909090 90909090 90909090 90909090 90909090 90909090 90909090 90909090 90909090 90909090 90909090 90')
