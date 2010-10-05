// RUN: llvm-mc -triple x86_64- --show-encoding %s | FileCheck %s

// CHECK: addb $0, %al
// CHECK: encoding: [0x04,0x00]
 	addb $0x00, %al

// CHECK: addb $127, %al
// CHECK: encoding: [0x04,0x7f]
 	addb $0x7F, %al

// CHECK: addb $128, %al
// CHECK: encoding: [0x04,0x80]
 	addb $0x80, %al

// CHECK: addb $255, %al
// CHECK: encoding: [0x04,0xff]
 	addb $0xFF, %al

// CHECK: addw $0, %ax
// CHECK: encoding: [0x66,0x83,0xc0,0x00]
 	addw $0x0000, %ax

// CHECK: addw $127, %ax
// CHECK: encoding: [0x66,0x83,0xc0,0x7f]
 	addw $0x007F, %ax

// CHECK: addw $65408, %ax
// CHECK: encoding: [0x66,0x83,0xc0,0x80]
 	addw $0xFF80, %ax

// CHECK: addw $65535, %ax
// CHECK: encoding: [0x66,0x83,0xc0,0xff]
	addw $0xFFFF, %ax

// CHECK: addl $0, %eax
// CHECK: encoding: [0x83,0xc0,0x00]
 	addl $0x00000000, %eax

// CHECK: addl $127, %eax
// CHECK: encoding: [0x83,0xc0,0x7f]
 	addl $0x0000007F, %eax

// CHECK: addl $65408, %eax
// CHECK: encoding: [0x05,0x80,0xff,0x00,0x00]
 	addl $0xFF80, %eax

// CHECK: addl $65535, %eax
// CHECK: encoding: [0x05,0xff,0xff,0x00,0x00]
	addl $0xFFFF, %eax

// CHECK: addl $4294967168, %eax
// CHECK: encoding: [0x83,0xc0,0x80]
 	addl $0xFFFFFF80, %eax

// CHECK: addl $4294967295, %eax
// CHECK: encoding: [0x83,0xc0,0xff]
 	addl $0xFFFFFFFF, %eax

// CHECK: addq $0, %rax
// CHECK: encoding: [0x48,0x83,0xc0,0x00]
 	addq $0x0000000000000000, %rax

// CHECK: addq $127, %rax
// CHECK: encoding: [0x48,0x83,0xc0,0x7f]
 	addq $0x000000000000007F, %rax

// CHECK: addq $-128, %rax
// CHECK: encoding: [0x48,0x83,0xc0,0x80]
 	addq $0xFFFFFFFFFFFFFF80, %rax

// CHECK: addq $-1, %rax
// CHECK: encoding: [0x48,0x83,0xc0,0xff]
 	addq $0xFFFFFFFFFFFFFFFF, %rax

// CHECK: addq $0, %rax
// CHECK: encoding: [0x48,0x83,0xc0,0x00]
 	addq $0x0000000000000000, %rax

// CHECK: addq $65408, %rax
// CHECK: encoding: [0x48,0x05,0x80,0xff,0x00,0x00]
 	addq $0xFF80, %rax

// CHECK: addq $65535, %rax
// CHECK: encoding: [0x48,0x05,0xff,0xff,0x00,0x00]
	addq $0xFFFF, %rax

// CHECK: movabsq $4294967168, %rax
// CHECK: encoding: [0x48,0xb8,0x80,0xff,0xff,0xff,0x00,0x00,0x00,0x00]
 	movq $0xFFFFFF80, %rax

// CHECK: movabsq $4294967295, %rax
// CHECK: encoding: [0x48,0xb8,0xff,0xff,0xff,0xff,0x00,0x00,0x00,0x00]
        movq $0xFFFFFFFF, %rax

// CHECK: addq $2147483647, %rax
// CHECK: encoding: [0x48,0x05,0xff,0xff,0xff,0x7f]
 	addq $0x000000007FFFFFFF, %rax

// CHECK: addq $-2147483648, %rax
// CHECK: encoding: [0x48,0x05,0x00,0x00,0x00,0x80]
	addq $0xFFFFFFFF80000000, %rax

// CHECK: addq $-256, %rax
// CHECK: encoding: [0x48,0x05,0x00,0xff,0xff,0xff]
 	addq $0xFFFFFFFFFFFFFF00, %rax
