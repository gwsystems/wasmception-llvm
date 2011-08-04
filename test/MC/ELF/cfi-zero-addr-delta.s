// RUN: llvm-mc -filetype=obj -triple x86_64-pc-linux-gnu %s -o - | elf-dump  --dump-section-data | FileCheck %s

// Test that we don't produce a DW_CFA_advance_loc 0

f:
	.cfi_startproc
        nop
	.cfi_def_cfa_offset 16
        nop
	.cfi_remember_state
	.cfi_def_cfa_offset 8
        nop
	.cfi_restore_state
        nop
	.cfi_endproc

// CHECK:      (('sh_name', 0x00000011) # '.eh_frame'
// CHECK-NEXT:  ('sh_type', 0x00000001)
// CHECK-NEXT:  ('sh_flags', 0x0000000000000002)
// CHECK-NEXT:  ('sh_addr', 0x0000000000000000)
// CHECK-NEXT:  ('sh_offset', 0x0000000000000048)
// CHECK-NEXT:  ('sh_size', 0x0000000000000038)
// CHECK-NEXT:  ('sh_link', 0x00000000)
// CHECK-NEXT:  ('sh_info', 0x00000000)
// CHECK-NEXT:  ('sh_addralign', 0x0000000000000008)
// CHECK-NEXT:  ('sh_entsize', 0x0000000000000000)
// CHECK-NEXT:  ('_section_data', '14000000 00000000 017a5200 01781001 1b0c0708 90010000 1c000000 1c000000 00000000 04000000 00410e10 410a0e08 410b0000 00000000')
// CHECK-NEXT: ),

// CHECK:      (('sh_name', 0x0000000c) # '.rela.eh_frame'
// CHECK-NEXT:  ('sh_type', 0x00000004)
// CHECK-NEXT:  ('sh_flags', 0x0000000000000000)
// CHECK-NEXT:  ('sh_addr', 0x0000000000000000)
// CHECK-NEXT:  ('sh_offset', 0x0000000000000398)
// CHECK-NEXT:  ('sh_size', 0x0000000000000018)
// CHECK-NEXT:  ('sh_link', 0x00000007)
// CHECK-NEXT:  ('sh_info', 0x00000004)
// CHECK-NEXT:  ('sh_addralign', 0x0000000000000008)
// CHECK-NEXT:  ('sh_entsize', 0x0000000000000018)
// CHECK-NEXT:  ('_relocations', [
// CHECK-NEXT:   # Relocation 0
// CHECK-NEXT:   (('r_offset', 0x0000000000000020)
// CHECK-NEXT:    ('r_sym', 0x00000002)
// CHECK-NEXT:    ('r_type', 0x00000002)
// CHECK-NEXT:    ('r_addend', 0x0000000000000000)
// CHECK-NEXT:   ),
// CHECK-NEXT:  ])
// CHECK-NEXT: ),
