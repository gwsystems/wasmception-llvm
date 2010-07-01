// RUN: llvm-mc -triple x86_64-unknown-unknown --show-encoding %s | FileCheck %s

// CHECK: crc32b 	%bl, %eax
// CHECK:  encoding: [0xf2,0x0f,0x38,0xf0,0xc3]
        crc32b	%bl, %eax

// CHECK: crc32b 	4(%rbx), %eax
// CHECK:  encoding: [0xf2,0x0f,0x38,0xf0,0x43,0x04]
        crc32b	4(%rbx), %eax

// CHECK: crc32w 	%bx, %eax
// CHECK:  encoding: [0x66,0xf2,0x0f,0x38,0xf1,0xc3]
        crc32w	%bx, %eax

// CHECK: crc32w 	4(%rbx), %eax
// CHECK:  encoding: [0x66,0xf2,0x0f,0x38,0xf1,0x43,0x04]
        crc32w	4(%rbx), %eax

// CHECK: crc32l 	%ebx, %eax
// CHECK:  encoding: [0xf2,0x0f,0x38,0xf1,0xc3]
        crc32l	%ebx, %eax

// CHECK: crc32l 	4(%rbx), %eax
// CHECK:  encoding: [0xf2,0x0f,0x38,0xf1,0x43,0x04]
        crc32l	4(%rbx), %eax

// CHECK: crc32l 	3735928559(%rbx,%rcx,8), %ecx
// CHECK:  encoding: [0xf2,0x0f,0x38,0xf1,0x8c,0xcb,0xef,0xbe,0xad,0xde]
        	crc32l   0xdeadbeef(%rbx,%rcx,8),%ecx

// CHECK: crc32l 	69, %ecx
// CHECK:  encoding: [0xf2,0x0f,0x38,0xf1,0x0c,0x25,0x45,0x00,0x00,0x00]
        	crc32l   0x45,%ecx

// CHECK: crc32l 	32493, %ecx
// CHECK:  encoding: [0xf2,0x0f,0x38,0xf1,0x0c,0x25,0xed,0x7e,0x00,0x00]
        	crc32l   0x7eed,%ecx

// CHECK: crc32l 	3133065982, %ecx
// CHECK:  encoding: [0xf2,0x0f,0x38,0xf1,0x0c,0x25,0xfe,0xca,0xbe,0xba]
        	crc32l   0xbabecafe,%ecx

// CHECK: crc32l 	%ecx, %ecx
// CHECK:  encoding: [0xf2,0x0f,0x38,0xf1,0xc9]
        	crc32l   %ecx,%ecx

// CHECK: crc32b 	%r11b, %eax
// CHECK:  encoding: [0xf2,0x41,0x0f,0x38,0xf0,0xc3]
        crc32b	%r11b, %eax

// CHECK: crc32b 	4(%rbx), %eax
// CHECK:  encoding: [0xf2,0x0f,0x38,0xf0,0x43,0x04]
        crc32b	4(%rbx), %eax

// CHECK: crc32b 	%dil, %rax
// CHECK:  encoding: [0xf2,0x48,0x0f,0x38,0xf0,0xc7]
        crc32b	%dil,%rax

// CHECK: crc32b 	%r11b, %rax
// CHECK:  encoding: [0xf2,0x49,0x0f,0x38,0xf0,0xc3]
        crc32b	%r11b,%rax

// CHECK: crc32b 	4(%rbx), %rax
// CHECK:  encoding: [0xf2,0x48,0x0f,0x38,0xf0,0x43,0x04]
        crc32b	4(%rbx), %rax

// CHECK: crc32q 	%rbx, %rax
// CHECK:  encoding: [0xf2,0x48,0x0f,0x38,0xf1,0xc3]
        crc32q	%rbx, %rax

// CHECK: crc32q 	4(%rbx), %rax
// CHECK:  encoding: [0xf2,0x48,0x0f,0x38,0xf1,0x43,0x04]
        crc32q	4(%rbx), %rax

// CHECK: movd %r8, %mm1
// CHECK:  encoding: [0x49,0x0f,0x6e,0xc8]
movd %r8, %mm1

// CHECK: movd %r8d, %mm1
// CHECK:  encoding: [0x41,0x0f,0x6e,0xc8]
movd %r8d, %mm1

// CHECK: movd %rdx, %mm1
// CHECK:  encoding: [0x48,0x0f,0x6e,0xca]
movd %rdx, %mm1

// CHECK: movd %edx, %mm1
// CHECK:  encoding: [0x0f,0x6e,0xca]
movd %edx, %mm1

// CHECK: movd %mm1, %r8
// CHECK:  encoding: [0x49,0x0f,0x7e,0xc8]
movd %mm1, %r8

// CHECK: movd %mm1, %r8d
// CHECK:  encoding: [0x41,0x0f,0x7e,0xc8]
movd %mm1, %r8d

// CHECK: movd %mm1, %rdx
// CHECK:  encoding: [0x48,0x0f,0x7e,0xca]
movd %mm1, %rdx

// CHECK: movd %mm1, %edx
// CHECK:  encoding: [0x0f,0x7e,0xca]
movd %mm1, %edx

// CHECK: vaddss  %xmm8, %xmm9, %xmm10
// CHECK:  encoding: [0xc4,0x41,0x32,0x58,0xd0]
vaddss  %xmm8, %xmm9, %xmm10

// CHECK: vmulss  %xmm8, %xmm9, %xmm10
// CHECK:  encoding: [0xc4,0x41,0x32,0x59,0xd0]
vmulss  %xmm8, %xmm9, %xmm10

// CHECK: vsubss  %xmm8, %xmm9, %xmm10
// CHECK:  encoding: [0xc4,0x41,0x32,0x5c,0xd0]
vsubss  %xmm8, %xmm9, %xmm10

// CHECK: vdivss  %xmm8, %xmm9, %xmm10
// CHECK:  encoding: [0xc4,0x41,0x32,0x5e,0xd0]
vdivss  %xmm8, %xmm9, %xmm10

// CHECK: vaddsd  %xmm8, %xmm9, %xmm10
// CHECK:  encoding: [0xc4,0x41,0x33,0x58,0xd0]
vaddsd  %xmm8, %xmm9, %xmm10

// CHECK: vmulsd  %xmm8, %xmm9, %xmm10
// CHECK:  encoding: [0xc4,0x41,0x33,0x59,0xd0]
vmulsd  %xmm8, %xmm9, %xmm10

// CHECK: vsubsd  %xmm8, %xmm9, %xmm10
// CHECK:  encoding: [0xc4,0x41,0x33,0x5c,0xd0]
vsubsd  %xmm8, %xmm9, %xmm10

// CHECK: vdivsd  %xmm8, %xmm9, %xmm10
// CHECK:  encoding: [0xc4,0x41,0x33,0x5e,0xd0]
vdivsd  %xmm8, %xmm9, %xmm10

// CHECK:   vaddss  -4(%rcx,%rbx,8), %xmm10, %xmm11
// CHECK:   encoding: [0xc5,0x2a,0x58,0x5c,0xd9,0xfc]
vaddss  -4(%rcx,%rbx,8), %xmm10, %xmm11

// CHECK:   vsubss  -4(%rcx,%rbx,8), %xmm10, %xmm11
// CHECK:   encoding: [0xc5,0x2a,0x5c,0x5c,0xd9,0xfc]
vsubss  -4(%rcx,%rbx,8), %xmm10, %xmm11

// CHECK:   vmulss  -4(%rcx,%rbx,8), %xmm10, %xmm11
// CHECK:   encoding: [0xc5,0x2a,0x59,0x5c,0xd9,0xfc]
vmulss  -4(%rcx,%rbx,8), %xmm10, %xmm11

// CHECK:   vdivss  -4(%rcx,%rbx,8), %xmm10, %xmm11
// CHECK:   encoding: [0xc5,0x2a,0x5e,0x5c,0xd9,0xfc]
vdivss  -4(%rcx,%rbx,8), %xmm10, %xmm11

// CHECK:   vaddsd  -4(%rcx,%rbx,8), %xmm10, %xmm11
// CHECK:   encoding: [0xc5,0x2b,0x58,0x5c,0xd9,0xfc]
vaddsd  -4(%rcx,%rbx,8), %xmm10, %xmm11

// CHECK:   vsubsd  -4(%rcx,%rbx,8), %xmm10, %xmm11
// CHECK:   encoding: [0xc5,0x2b,0x5c,0x5c,0xd9,0xfc]
vsubsd  -4(%rcx,%rbx,8), %xmm10, %xmm11

// CHECK:   vmulsd  -4(%rcx,%rbx,8), %xmm10, %xmm11
// CHECK:   encoding: [0xc5,0x2b,0x59,0x5c,0xd9,0xfc]
vmulsd  -4(%rcx,%rbx,8), %xmm10, %xmm11

// CHECK:   vdivsd  -4(%rcx,%rbx,8), %xmm10, %xmm11
// CHECK:   encoding: [0xc5,0x2b,0x5e,0x5c,0xd9,0xfc]
vdivsd  -4(%rcx,%rbx,8), %xmm10, %xmm11

// CHECK: vaddps  %xmm10, %xmm11, %xmm15
// CHECK: encoding: [0xc4,0x41,0x20,0x58,0xfa]
vaddps  %xmm10, %xmm11, %xmm15

// CHECK: vsubps  %xmm10, %xmm11, %xmm15
// CHECK: encoding: [0xc4,0x41,0x20,0x5c,0xfa]
vsubps  %xmm10, %xmm11, %xmm15

// CHECK: vmulps  %xmm10, %xmm11, %xmm15
// CHECK: encoding: [0xc4,0x41,0x20,0x59,0xfa]
vmulps  %xmm10, %xmm11, %xmm15

// CHECK: vdivps  %xmm10, %xmm11, %xmm15
// CHECK: encoding: [0xc4,0x41,0x20,0x5e,0xfa]
vdivps  %xmm10, %xmm11, %xmm15

// CHECK: vaddpd  %xmm10, %xmm11, %xmm15
// CHECK: encoding: [0xc4,0x41,0x21,0x58,0xfa]
vaddpd  %xmm10, %xmm11, %xmm15

// CHECK: vsubpd  %xmm10, %xmm11, %xmm15
// CHECK: encoding: [0xc4,0x41,0x21,0x5c,0xfa]
vsubpd  %xmm10, %xmm11, %xmm15

// CHECK: vmulpd  %xmm10, %xmm11, %xmm15
// CHECK: encoding: [0xc4,0x41,0x21,0x59,0xfa]
vmulpd  %xmm10, %xmm11, %xmm15

// CHECK: vdivpd  %xmm10, %xmm11, %xmm15
// CHECK: encoding: [0xc4,0x41,0x21,0x5e,0xfa]
vdivpd  %xmm10, %xmm11, %xmm15

// CHECK: vaddps  -4(%rcx,%rbx,8), %xmm10, %xmm11
// CHECK: encoding: [0xc5,0x28,0x58,0x5c,0xd9,0xfc]
vaddps  -4(%rcx,%rbx,8), %xmm10, %xmm11

// CHECK: vsubps  -4(%rcx,%rbx,8), %xmm10, %xmm11
// CHECK: encoding: [0xc5,0x28,0x5c,0x5c,0xd9,0xfc]
vsubps  -4(%rcx,%rbx,8), %xmm10, %xmm11

// CHECK: vmulps  -4(%rcx,%rbx,8), %xmm10, %xmm11
// CHECK: encoding: [0xc5,0x28,0x59,0x5c,0xd9,0xfc]
vmulps  -4(%rcx,%rbx,8), %xmm10, %xmm11

// CHECK: vdivps  -4(%rcx,%rbx,8), %xmm10, %xmm11
// CHECK: encoding: [0xc5,0x28,0x5e,0x5c,0xd9,0xfc]
vdivps  -4(%rcx,%rbx,8), %xmm10, %xmm11

// CHECK: vaddpd  -4(%rcx,%rbx,8), %xmm10, %xmm11
// CHECK: encoding: [0xc5,0x29,0x58,0x5c,0xd9,0xfc]
vaddpd  -4(%rcx,%rbx,8), %xmm10, %xmm11

// CHECK: vsubpd  -4(%rcx,%rbx,8), %xmm10, %xmm11
// CHECK: encoding: [0xc5,0x29,0x5c,0x5c,0xd9,0xfc]
vsubpd  -4(%rcx,%rbx,8), %xmm10, %xmm11

// CHECK: vmulpd  -4(%rcx,%rbx,8), %xmm10, %xmm11
// CHECK: encoding: [0xc5,0x29,0x59,0x5c,0xd9,0xfc]
vmulpd  -4(%rcx,%rbx,8), %xmm10, %xmm11

// CHECK: vdivpd  -4(%rcx,%rbx,8), %xmm10, %xmm11
// CHECK: encoding: [0xc5,0x29,0x5e,0x5c,0xd9,0xfc]
vdivpd  -4(%rcx,%rbx,8), %xmm10, %xmm11

// CHECK: vmaxss  %xmm10, %xmm14, %xmm12
// CHECK: encoding: [0xc4,0x41,0x0a,0x5f,0xe2]
          vmaxss  %xmm10, %xmm14, %xmm12

// CHECK: vmaxsd  %xmm10, %xmm14, %xmm12
// CHECK: encoding: [0xc4,0x41,0x0b,0x5f,0xe2]
          vmaxsd  %xmm10, %xmm14, %xmm12

// CHECK: vminss  %xmm10, %xmm14, %xmm12
// CHECK: encoding: [0xc4,0x41,0x0a,0x5d,0xe2]
          vminss  %xmm10, %xmm14, %xmm12

// CHECK: vminsd  %xmm10, %xmm14, %xmm12
// CHECK: encoding: [0xc4,0x41,0x0b,0x5d,0xe2]
          vminsd  %xmm10, %xmm14, %xmm12

// CHECK: vmaxss  -4(%rbx,%rcx,8), %xmm12, %xmm10
// CHECK: encoding: [0xc5,0x1a,0x5f,0x54,0xcb,0xfc]
          vmaxss  -4(%rbx,%rcx,8), %xmm12, %xmm10

// CHECK: vmaxsd  -4(%rbx,%rcx,8), %xmm12, %xmm10
// CHECK: encoding: [0xc5,0x1b,0x5f,0x54,0xcb,0xfc]
          vmaxsd  -4(%rbx,%rcx,8), %xmm12, %xmm10

// CHECK: vminss  -4(%rbx,%rcx,8), %xmm12, %xmm10
// CHECK: encoding: [0xc5,0x1a,0x5d,0x54,0xcb,0xfc]
          vminss  -4(%rbx,%rcx,8), %xmm12, %xmm10

// CHECK: vminsd  -4(%rbx,%rcx,8), %xmm12, %xmm10
// CHECK: encoding: [0xc5,0x1b,0x5d,0x54,0xcb,0xfc]
          vminsd  -4(%rbx,%rcx,8), %xmm12, %xmm10

// CHECK: vmaxps  %xmm10, %xmm14, %xmm12
// CHECK: encoding: [0xc4,0x41,0x08,0x5f,0xe2]
          vmaxps  %xmm10, %xmm14, %xmm12

// CHECK: vmaxpd  %xmm10, %xmm14, %xmm12
// CHECK: encoding: [0xc4,0x41,0x09,0x5f,0xe2]
          vmaxpd  %xmm10, %xmm14, %xmm12

// CHECK: vminps  %xmm10, %xmm14, %xmm12
// CHECK: encoding: [0xc4,0x41,0x08,0x5d,0xe2]
          vminps  %xmm10, %xmm14, %xmm12

// CHECK: vminpd  %xmm10, %xmm14, %xmm12
// CHECK: encoding: [0xc4,0x41,0x09,0x5d,0xe2]
          vminpd  %xmm10, %xmm14, %xmm12

// CHECK: vmaxps  -4(%rbx,%rcx,8), %xmm12, %xmm10
// CHECK: encoding: [0xc5,0x18,0x5f,0x54,0xcb,0xfc]
          vmaxps  -4(%rbx,%rcx,8), %xmm12, %xmm10

// CHECK: vmaxpd  -4(%rbx,%rcx,8), %xmm12, %xmm10
// CHECK: encoding: [0xc5,0x19,0x5f,0x54,0xcb,0xfc]
          vmaxpd  -4(%rbx,%rcx,8), %xmm12, %xmm10

// CHECK: vminps  -4(%rbx,%rcx,8), %xmm12, %xmm10
// CHECK: encoding: [0xc5,0x18,0x5d,0x54,0xcb,0xfc]
          vminps  -4(%rbx,%rcx,8), %xmm12, %xmm10

// CHECK: vminpd  -4(%rbx,%rcx,8), %xmm12, %xmm10
// CHECK: encoding: [0xc5,0x19,0x5d,0x54,0xcb,0xfc]
          vminpd  -4(%rbx,%rcx,8), %xmm12, %xmm10

// CHECK: vandps  %xmm10, %xmm14, %xmm12
// CHECK: encoding: [0xc4,0x41,0x08,0x54,0xe2]
          vandps  %xmm10, %xmm14, %xmm12

// CHECK: vandpd  %xmm10, %xmm14, %xmm12
// CHECK: encoding: [0xc4,0x41,0x09,0x54,0xe2]
          vandpd  %xmm10, %xmm14, %xmm12

// CHECK: vandps  -4(%rbx,%rcx,8), %xmm12, %xmm10
// CHECK: encoding: [0xc5,0x18,0x54,0x54,0xcb,0xfc]
          vandps  -4(%rbx,%rcx,8), %xmm12, %xmm10

// CHECK: vandpd  -4(%rbx,%rcx,8), %xmm12, %xmm10
// CHECK: encoding: [0xc5,0x19,0x54,0x54,0xcb,0xfc]
          vandpd  -4(%rbx,%rcx,8), %xmm12, %xmm10

// CHECK: vorps  %xmm10, %xmm14, %xmm12
// CHECK: encoding: [0xc4,0x41,0x08,0x56,0xe2]
          vorps  %xmm10, %xmm14, %xmm12

// CHECK: vorpd  %xmm10, %xmm14, %xmm12
// CHECK: encoding: [0xc4,0x41,0x09,0x56,0xe2]
          vorpd  %xmm10, %xmm14, %xmm12

// CHECK: vorps  -4(%rbx,%rcx,8), %xmm12, %xmm10
// CHECK: encoding: [0xc5,0x18,0x56,0x54,0xcb,0xfc]
          vorps  -4(%rbx,%rcx,8), %xmm12, %xmm10

// CHECK: vorpd  -4(%rbx,%rcx,8), %xmm12, %xmm10
// CHECK: encoding: [0xc5,0x19,0x56,0x54,0xcb,0xfc]
          vorpd  -4(%rbx,%rcx,8), %xmm12, %xmm10

// CHECK: vxorps  %xmm10, %xmm14, %xmm12
// CHECK: encoding: [0xc4,0x41,0x08,0x57,0xe2]
          vxorps  %xmm10, %xmm14, %xmm12

// CHECK: vxorpd  %xmm10, %xmm14, %xmm12
// CHECK: encoding: [0xc4,0x41,0x09,0x57,0xe2]
          vxorpd  %xmm10, %xmm14, %xmm12

// CHECK: vxorps  -4(%rbx,%rcx,8), %xmm12, %xmm10
// CHECK: encoding: [0xc5,0x18,0x57,0x54,0xcb,0xfc]
          vxorps  -4(%rbx,%rcx,8), %xmm12, %xmm10

// CHECK: vxorpd  -4(%rbx,%rcx,8), %xmm12, %xmm10
// CHECK: encoding: [0xc5,0x19,0x57,0x54,0xcb,0xfc]
          vxorpd  -4(%rbx,%rcx,8), %xmm12, %xmm10

// CHECK: vandnps  %xmm10, %xmm14, %xmm12
// CHECK: encoding: [0xc4,0x41,0x08,0x55,0xe2]
          vandnps  %xmm10, %xmm14, %xmm12

// CHECK: vandnpd  %xmm10, %xmm14, %xmm12
// CHECK: encoding: [0xc4,0x41,0x09,0x55,0xe2]
          vandnpd  %xmm10, %xmm14, %xmm12

// CHECK: vandnps  -4(%rbx,%rcx,8), %xmm12, %xmm10
// CHECK: encoding: [0xc5,0x18,0x55,0x54,0xcb,0xfc]
          vandnps  -4(%rbx,%rcx,8), %xmm12, %xmm10

// CHECK: vandnpd  -4(%rbx,%rcx,8), %xmm12, %xmm10
// CHECK: encoding: [0xc5,0x19,0x55,0x54,0xcb,0xfc]
          vandnpd  -4(%rbx,%rcx,8), %xmm12, %xmm10

// CHECK: vmovss  -4(%rbx,%rcx,8), %xmm10
// CHECK: encoding: [0xc5,0x7a,0x10,0x54,0xcb,0xfc]
          vmovss  -4(%rbx,%rcx,8), %xmm10

// CHECK: vmovss  %xmm14, %xmm10, %xmm15
// CHECK: encoding: [0xc4,0x41,0x2a,0x10,0xfe]
          vmovss  %xmm14, %xmm10, %xmm15

// CHECK: vmovsd  -4(%rbx,%rcx,8), %xmm10
// CHECK: encoding: [0xc5,0x7b,0x10,0x54,0xcb,0xfc]
          vmovsd  -4(%rbx,%rcx,8), %xmm10

// CHECK: vmovsd  %xmm14, %xmm10, %xmm15
// CHECK: encoding: [0xc4,0x41,0x2b,0x10,0xfe]
          vmovsd  %xmm14, %xmm10, %xmm15

// rdar://7840289
// CHECK: pshufb	CPI1_0(%rip), %xmm1
// CHECK:  encoding: [0x66,0x0f,0x38,0x00,0x0d,A,A,A,A]
// CHECK:  fixup A - offset: 5, value: CPI1_0-4
pshufb	CPI1_0(%rip), %xmm1

// CHECK: vunpckhps  %xmm15, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x18,0x15,0xef]
          vunpckhps  %xmm15, %xmm12, %xmm13

// CHECK: vunpckhpd  %xmm15, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0x15,0xef]
          vunpckhpd  %xmm15, %xmm12, %xmm13

// CHECK: vunpcklps  %xmm15, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x18,0x14,0xef]
          vunpcklps  %xmm15, %xmm12, %xmm13

// CHECK: vunpcklpd  %xmm15, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0x14,0xef]
          vunpcklpd  %xmm15, %xmm12, %xmm13

// CHECK: vunpckhps  -4(%rbx,%rcx,8), %xmm12, %xmm15
// CHECK: encoding: [0xc5,0x18,0x15,0x7c,0xcb,0xfc]
          vunpckhps  -4(%rbx,%rcx,8), %xmm12, %xmm15

// CHECK: vunpckhpd  -4(%rbx,%rcx,8), %xmm12, %xmm15
// CHECK: encoding: [0xc5,0x19,0x15,0x7c,0xcb,0xfc]
          vunpckhpd  -4(%rbx,%rcx,8), %xmm12, %xmm15

// CHECK: vunpcklps  -4(%rbx,%rcx,8), %xmm12, %xmm15
// CHECK: encoding: [0xc5,0x18,0x14,0x7c,0xcb,0xfc]
          vunpcklps  -4(%rbx,%rcx,8), %xmm12, %xmm15

// CHECK: vunpcklpd  -4(%rbx,%rcx,8), %xmm12, %xmm15
// CHECK: encoding: [0xc5,0x19,0x14,0x7c,0xcb,0xfc]
          vunpcklpd  -4(%rbx,%rcx,8), %xmm12, %xmm15

// CHECK: vcmpps  $0, %xmm10, %xmm12, %xmm15
// CHECK: encoding: [0xc4,0x41,0x18,0xc2,0xfa,0x00]
          vcmpps  $0, %xmm10, %xmm12, %xmm15

// CHECK: vcmpps  $0, (%rax), %xmm12, %xmm15
// CHECK: encoding: [0xc5,0x18,0xc2,0x38,0x00]
          vcmpps  $0, (%rax), %xmm12, %xmm15

// CHECK: vcmpps  $7, %xmm10, %xmm12, %xmm15
// CHECK: encoding: [0xc4,0x41,0x18,0xc2,0xfa,0x07]
          vcmpps  $7, %xmm10, %xmm12, %xmm15

// CHECK: vcmppd  $0, %xmm10, %xmm12, %xmm15
// CHECK: encoding: [0xc4,0x41,0x19,0xc2,0xfa,0x00]
          vcmppd  $0, %xmm10, %xmm12, %xmm15

// CHECK: vcmppd  $0, (%rax), %xmm12, %xmm15
// CHECK: encoding: [0xc5,0x19,0xc2,0x38,0x00]
          vcmppd  $0, (%rax), %xmm12, %xmm15

// CHECK: vcmppd  $7, %xmm10, %xmm12, %xmm15
// CHECK: encoding: [0xc4,0x41,0x19,0xc2,0xfa,0x07]
          vcmppd  $7, %xmm10, %xmm12, %xmm15

// CHECK: vshufps  $8, %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x18,0xc6,0xeb,0x08]
          vshufps  $8, %xmm11, %xmm12, %xmm13

// CHECK: vshufps  $8, -4(%rbx,%rcx,8), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x18,0xc6,0x6c,0xcb,0xfc,0x08]
          vshufps  $8, -4(%rbx,%rcx,8), %xmm12, %xmm13

// CHECK: vshufpd  $8, %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xc6,0xeb,0x08]
          vshufpd  $8, %xmm11, %xmm12, %xmm13

// CHECK: vshufpd  $8, -4(%rbx,%rcx,8), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xc6,0x6c,0xcb,0xfc,0x08]
          vshufpd  $8, -4(%rbx,%rcx,8), %xmm12, %xmm13

// CHECK: vcmpps  $0, %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x18,0xc2,0xeb,0x00]
          vcmpeqps   %xmm11, %xmm12, %xmm13

// CHECK: vcmpps  $2, %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x18,0xc2,0xeb,0x02]
          vcmpleps   %xmm11, %xmm12, %xmm13

// CHECK: vcmpps  $1, %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x18,0xc2,0xeb,0x01]
          vcmpltps   %xmm11, %xmm12, %xmm13

// CHECK: vcmpps  $4, %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x18,0xc2,0xeb,0x04]
          vcmpneqps   %xmm11, %xmm12, %xmm13

// CHECK: vcmpps  $6, %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x18,0xc2,0xeb,0x06]
          vcmpnleps   %xmm11, %xmm12, %xmm13

// CHECK: vcmpps  $5, %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x18,0xc2,0xeb,0x05]
          vcmpnltps   %xmm11, %xmm12, %xmm13

// CHECK: vcmpps  $7, %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x18,0xc2,0xeb,0x07]
          vcmpordps   %xmm11, %xmm12, %xmm13

// CHECK: vcmpps  $3, %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x18,0xc2,0xeb,0x03]
          vcmpunordps   %xmm11, %xmm12, %xmm13

// CHECK: vcmpps  $0, -4(%rbx,%rcx,8), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x18,0xc2,0x6c,0xcb,0xfc,0x00]
          vcmpeqps   -4(%rbx,%rcx,8), %xmm12, %xmm13

// CHECK: vcmpps  $2, -4(%rbx,%rcx,8), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x18,0xc2,0x6c,0xcb,0xfc,0x02]
          vcmpleps   -4(%rbx,%rcx,8), %xmm12, %xmm13

// CHECK: vcmpps  $1, -4(%rbx,%rcx,8), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x18,0xc2,0x6c,0xcb,0xfc,0x01]
          vcmpltps   -4(%rbx,%rcx,8), %xmm12, %xmm13

// CHECK: vcmpps  $4, -4(%rbx,%rcx,8), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x18,0xc2,0x6c,0xcb,0xfc,0x04]
          vcmpneqps   -4(%rbx,%rcx,8), %xmm12, %xmm13

// CHECK: vcmpps  $6, -4(%rbx,%rcx,8), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x18,0xc2,0x6c,0xcb,0xfc,0x06]
          vcmpnleps   -4(%rbx,%rcx,8), %xmm12, %xmm13

// CHECK: vcmpps  $5, -4(%rbx,%rcx,8), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x18,0xc2,0x6c,0xcb,0xfc,0x05]
          vcmpnltps   -4(%rbx,%rcx,8), %xmm12, %xmm13

// CHECK: vcmpps  $7, -4(%rbx,%rcx,8), %xmm6, %xmm2
// CHECK: encoding: [0xc5,0xc8,0xc2,0x54,0xcb,0xfc,0x07]
          vcmpordps   -4(%rbx,%rcx,8), %xmm6, %xmm2

// CHECK: vcmpps  $3, -4(%rbx,%rcx,8), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x18,0xc2,0x6c,0xcb,0xfc,0x03]
          vcmpunordps   -4(%rbx,%rcx,8), %xmm12, %xmm13

// CHECK: vcmppd  $0, %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xc2,0xeb,0x00]
          vcmpeqpd   %xmm11, %xmm12, %xmm13

// CHECK: vcmppd  $2, %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xc2,0xeb,0x02]
          vcmplepd   %xmm11, %xmm12, %xmm13

// CHECK: vcmppd  $1, %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xc2,0xeb,0x01]
          vcmpltpd   %xmm11, %xmm12, %xmm13

// CHECK: vcmppd  $4, %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xc2,0xeb,0x04]
          vcmpneqpd   %xmm11, %xmm12, %xmm13

// CHECK: vcmppd  $6, %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xc2,0xeb,0x06]
          vcmpnlepd   %xmm11, %xmm12, %xmm13

// CHECK: vcmppd  $5, %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xc2,0xeb,0x05]
          vcmpnltpd   %xmm11, %xmm12, %xmm13

// CHECK: vcmppd  $7, %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xc2,0xeb,0x07]
          vcmpordpd   %xmm11, %xmm12, %xmm13

// CHECK: vcmppd  $3, %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xc2,0xeb,0x03]
          vcmpunordpd   %xmm11, %xmm12, %xmm13

// CHECK: vcmppd  $0, -4(%rbx,%rcx,8), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xc2,0x6c,0xcb,0xfc,0x00]
          vcmpeqpd   -4(%rbx,%rcx,8), %xmm12, %xmm13

// CHECK: vcmppd  $2, -4(%rbx,%rcx,8), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xc2,0x6c,0xcb,0xfc,0x02]
          vcmplepd   -4(%rbx,%rcx,8), %xmm12, %xmm13

// CHECK: vcmppd  $1, -4(%rbx,%rcx,8), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xc2,0x6c,0xcb,0xfc,0x01]
          vcmpltpd   -4(%rbx,%rcx,8), %xmm12, %xmm13

// CHECK: vcmppd  $4, -4(%rbx,%rcx,8), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xc2,0x6c,0xcb,0xfc,0x04]
          vcmpneqpd   -4(%rbx,%rcx,8), %xmm12, %xmm13

// CHECK: vcmppd  $6, -4(%rbx,%rcx,8), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xc2,0x6c,0xcb,0xfc,0x06]
          vcmpnlepd   -4(%rbx,%rcx,8), %xmm12, %xmm13

// CHECK: vcmppd  $5, -4(%rbx,%rcx,8), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xc2,0x6c,0xcb,0xfc,0x05]
          vcmpnltpd   -4(%rbx,%rcx,8), %xmm12, %xmm13

// CHECK: vcmppd  $7, -4(%rbx,%rcx,8), %xmm6, %xmm2
// CHECK: encoding: [0xc5,0xc9,0xc2,0x54,0xcb,0xfc,0x07]
          vcmpordpd   -4(%rbx,%rcx,8), %xmm6, %xmm2

// CHECK: vcmppd  $3, -4(%rbx,%rcx,8), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xc2,0x6c,0xcb,0xfc,0x03]
          vcmpunordpd   -4(%rbx,%rcx,8), %xmm12, %xmm13

// CHECK: vcmpss  $0, %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x1a,0xc2,0xeb,0x00]
          vcmpeqss   %xmm11, %xmm12, %xmm13

// CHECK: vcmpss  $2, %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x1a,0xc2,0xeb,0x02]
          vcmpless   %xmm11, %xmm12, %xmm13

// CHECK: vcmpss  $1, %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x1a,0xc2,0xeb,0x01]
          vcmpltss   %xmm11, %xmm12, %xmm13

// CHECK: vcmpss  $4, %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x1a,0xc2,0xeb,0x04]
          vcmpneqss   %xmm11, %xmm12, %xmm13

// CHECK: vcmpss  $6, %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x1a,0xc2,0xeb,0x06]
          vcmpnless   %xmm11, %xmm12, %xmm13

// CHECK: vcmpss  $5, %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x1a,0xc2,0xeb,0x05]
          vcmpnltss   %xmm11, %xmm12, %xmm13

// CHECK: vcmpss  $7, %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x1a,0xc2,0xeb,0x07]
          vcmpordss   %xmm11, %xmm12, %xmm13

// CHECK: vcmpss  $3, %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x1a,0xc2,0xeb,0x03]
          vcmpunordss   %xmm11, %xmm12, %xmm13

// CHECK: vcmpss  $0, -4(%rbx,%rcx,8), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x1a,0xc2,0x6c,0xcb,0xfc,0x00]
          vcmpeqss   -4(%rbx,%rcx,8), %xmm12, %xmm13

// CHECK: vcmpss  $2, -4(%rbx,%rcx,8), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x1a,0xc2,0x6c,0xcb,0xfc,0x02]
          vcmpless   -4(%rbx,%rcx,8), %xmm12, %xmm13

// CHECK: vcmpss  $1, -4(%rbx,%rcx,8), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x1a,0xc2,0x6c,0xcb,0xfc,0x01]
          vcmpltss   -4(%rbx,%rcx,8), %xmm12, %xmm13

// CHECK: vcmpss  $4, -4(%rbx,%rcx,8), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x1a,0xc2,0x6c,0xcb,0xfc,0x04]
          vcmpneqss   -4(%rbx,%rcx,8), %xmm12, %xmm13

// CHECK: vcmpss  $6, -4(%rbx,%rcx,8), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x1a,0xc2,0x6c,0xcb,0xfc,0x06]
          vcmpnless   -4(%rbx,%rcx,8), %xmm12, %xmm13

// CHECK: vcmpss  $5, -4(%rbx,%rcx,8), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x1a,0xc2,0x6c,0xcb,0xfc,0x05]
          vcmpnltss   -4(%rbx,%rcx,8), %xmm12, %xmm13

// CHECK: vcmpss  $7, -4(%rbx,%rcx,8), %xmm6, %xmm2
// CHECK: encoding: [0xc5,0xca,0xc2,0x54,0xcb,0xfc,0x07]
          vcmpordss   -4(%rbx,%rcx,8), %xmm6, %xmm2

// CHECK: vcmpss  $3, -4(%rbx,%rcx,8), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x1a,0xc2,0x6c,0xcb,0xfc,0x03]
          vcmpunordss   -4(%rbx,%rcx,8), %xmm12, %xmm13

// CHECK: vcmpsd  $0, %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x1b,0xc2,0xeb,0x00]
          vcmpeqsd   %xmm11, %xmm12, %xmm13

// CHECK: vcmpsd  $2, %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x1b,0xc2,0xeb,0x02]
          vcmplesd   %xmm11, %xmm12, %xmm13

// CHECK: vcmpsd  $1, %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x1b,0xc2,0xeb,0x01]
          vcmpltsd   %xmm11, %xmm12, %xmm13

// CHECK: vcmpsd  $4, %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x1b,0xc2,0xeb,0x04]
          vcmpneqsd   %xmm11, %xmm12, %xmm13

// CHECK: vcmpsd  $6, %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x1b,0xc2,0xeb,0x06]
          vcmpnlesd   %xmm11, %xmm12, %xmm13

// CHECK: vcmpsd  $5, %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x1b,0xc2,0xeb,0x05]
          vcmpnltsd   %xmm11, %xmm12, %xmm13

// CHECK: vcmpsd  $7, %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x1b,0xc2,0xeb,0x07]
          vcmpordsd   %xmm11, %xmm12, %xmm13

// CHECK: vcmpsd  $3, %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x1b,0xc2,0xeb,0x03]
          vcmpunordsd   %xmm11, %xmm12, %xmm13

// CHECK: vcmpsd  $0, -4(%rbx,%rcx,8), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x1b,0xc2,0x6c,0xcb,0xfc,0x00]
          vcmpeqsd   -4(%rbx,%rcx,8), %xmm12, %xmm13

// CHECK: vcmpsd  $2, -4(%rbx,%rcx,8), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x1b,0xc2,0x6c,0xcb,0xfc,0x02]
          vcmplesd   -4(%rbx,%rcx,8), %xmm12, %xmm13

// CHECK: vcmpsd  $1, -4(%rbx,%rcx,8), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x1b,0xc2,0x6c,0xcb,0xfc,0x01]
          vcmpltsd   -4(%rbx,%rcx,8), %xmm12, %xmm13

// CHECK: vcmpsd  $4, -4(%rbx,%rcx,8), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x1b,0xc2,0x6c,0xcb,0xfc,0x04]
          vcmpneqsd   -4(%rbx,%rcx,8), %xmm12, %xmm13

// CHECK: vcmpsd  $6, -4(%rbx,%rcx,8), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x1b,0xc2,0x6c,0xcb,0xfc,0x06]
          vcmpnlesd   -4(%rbx,%rcx,8), %xmm12, %xmm13

// CHECK: vcmpsd  $5, -4(%rbx,%rcx,8), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x1b,0xc2,0x6c,0xcb,0xfc,0x05]
          vcmpnltsd   -4(%rbx,%rcx,8), %xmm12, %xmm13

// CHECK: vcmpsd  $7, -4(%rbx,%rcx,8), %xmm6, %xmm2
// CHECK: encoding: [0xc5,0xcb,0xc2,0x54,0xcb,0xfc,0x07]
          vcmpordsd   -4(%rbx,%rcx,8), %xmm6, %xmm2

// CHECK: vcmpsd  $3, -4(%rbx,%rcx,8), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x1b,0xc2,0x6c,0xcb,0xfc,0x03]
          vcmpunordsd   -4(%rbx,%rcx,8), %xmm12, %xmm13

// CHECK: vucomiss  %xmm11, %xmm12
// CHECK: encoding: [0xc4,0x41,0x78,0x2e,0xe3]
          vucomiss  %xmm11, %xmm12

// CHECK: vucomiss  (%rax), %xmm12
// CHECK: encoding: [0xc5,0x78,0x2e,0x20]
          vucomiss  (%rax), %xmm12

// CHECK: vcomiss  %xmm11, %xmm12
// CHECK: encoding: [0xc4,0x41,0x78,0x2f,0xe3]
          vcomiss  %xmm11, %xmm12

// CHECK: vcomiss  (%rax), %xmm12
// CHECK: encoding: [0xc5,0x78,0x2f,0x20]
          vcomiss  (%rax), %xmm12

// CHECK: vucomisd  %xmm11, %xmm12
// CHECK: encoding: [0xc4,0x41,0x79,0x2e,0xe3]
          vucomisd  %xmm11, %xmm12

// CHECK: vucomisd  (%rax), %xmm12
// CHECK: encoding: [0xc5,0x79,0x2e,0x20]
          vucomisd  (%rax), %xmm12

// CHECK: vcomisd  %xmm11, %xmm12
// CHECK: encoding: [0xc4,0x41,0x79,0x2f,0xe3]
          vcomisd  %xmm11, %xmm12

// CHECK: vcomisd  (%rax), %xmm12
// CHECK: encoding: [0xc5,0x79,0x2f,0x20]
          vcomisd  (%rax), %xmm12

// CHECK: vcvttss2si  (%rcx), %eax
// CHECK: encoding: [0xc5,0xfa,0x2c,0x01]
          vcvttss2si  (%rcx), %eax

// CHECK: vcvtsi2ss  (%rax), %xmm11, %xmm12
// CHECK: encoding: [0xc5,0x22,0x2a,0x20]
          vcvtsi2ss  (%rax), %xmm11, %xmm12

// CHECK: vcvtsi2ss  (%rax), %xmm11, %xmm12
// CHECK: encoding: [0xc5,0x22,0x2a,0x20]
          vcvtsi2ss  (%rax), %xmm11, %xmm12

// CHECK: vcvttsd2si  (%rcx), %eax
// CHECK: encoding: [0xc5,0xfb,0x2c,0x01]
          vcvttsd2si  (%rcx), %eax

// CHECK: vcvtsi2sd  (%rax), %xmm11, %xmm12
// CHECK: encoding: [0xc5,0x23,0x2a,0x20]
          vcvtsi2sd  (%rax), %xmm11, %xmm12

// CHECK: vcvtsi2sd  (%rax), %xmm11, %xmm12
// CHECK: encoding: [0xc5,0x23,0x2a,0x20]
          vcvtsi2sd  (%rax), %xmm11, %xmm12

// CHECK: vmovaps  (%rax), %xmm12
// CHECK: encoding: [0xc5,0x78,0x28,0x20]
          vmovaps  (%rax), %xmm12

// CHECK: vmovaps  %xmm11, %xmm12
// CHECK: encoding: [0xc4,0x41,0x78,0x28,0xe3]
          vmovaps  %xmm11, %xmm12

// CHECK: vmovaps  %xmm11, (%rax)
// CHECK: encoding: [0xc5,0x78,0x29,0x18]
          vmovaps  %xmm11, (%rax)

// CHECK: vmovapd  (%rax), %xmm12
// CHECK: encoding: [0xc5,0x79,0x28,0x20]
          vmovapd  (%rax), %xmm12

// CHECK: vmovapd  %xmm11, %xmm12
// CHECK: encoding: [0xc4,0x41,0x79,0x28,0xe3]
          vmovapd  %xmm11, %xmm12

// CHECK: vmovapd  %xmm11, (%rax)
// CHECK: encoding: [0xc5,0x79,0x29,0x18]
          vmovapd  %xmm11, (%rax)

// CHECK: vmovups  (%rax), %xmm12
// CHECK: encoding: [0xc5,0x78,0x10,0x20]
          vmovups  (%rax), %xmm12

// CHECK: vmovups  %xmm11, %xmm12
// CHECK: encoding: [0xc4,0x41,0x78,0x10,0xe3]
          vmovups  %xmm11, %xmm12

// CHECK: vmovups  %xmm11, (%rax)
// CHECK: encoding: [0xc5,0x78,0x11,0x18]
          vmovups  %xmm11, (%rax)

// CHECK: vmovupd  (%rax), %xmm12
// CHECK: encoding: [0xc5,0x79,0x10,0x20]
          vmovupd  (%rax), %xmm12

// CHECK: vmovupd  %xmm11, %xmm12
// CHECK: encoding: [0xc4,0x41,0x79,0x10,0xe3]
          vmovupd  %xmm11, %xmm12

// CHECK: vmovupd  %xmm11, (%rax)
// CHECK: encoding: [0xc5,0x79,0x11,0x18]
          vmovupd  %xmm11, (%rax)

// CHECK: vmovlps  %xmm11, (%rax)
// CHECK: encoding: [0xc5,0x78,0x13,0x18]
          vmovlps  %xmm11, (%rax)

// CHECK: vmovlps  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x18,0x12,0x28]
          vmovlps  (%rax), %xmm12, %xmm13

// CHECK: vmovlpd  %xmm11, (%rax)
// CHECK: encoding: [0xc5,0x79,0x13,0x18]
          vmovlpd  %xmm11, (%rax)

// CHECK: vmovlpd  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0x12,0x28]
          vmovlpd  (%rax), %xmm12, %xmm13

// CHECK: vmovhps  %xmm11, (%rax)
// CHECK: encoding: [0xc5,0x78,0x17,0x18]
          vmovhps  %xmm11, (%rax)

// CHECK: vmovhps  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x18,0x16,0x28]
          vmovhps  (%rax), %xmm12, %xmm13

// CHECK: vmovhpd  %xmm11, (%rax)
// CHECK: encoding: [0xc5,0x79,0x17,0x18]
          vmovhpd  %xmm11, (%rax)

// CHECK: vmovhpd  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0x16,0x28]
          vmovhpd  (%rax), %xmm12, %xmm13

// CHECK: vmovlhps  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x18,0x16,0xeb]
          vmovlhps  %xmm11, %xmm12, %xmm13

// CHECK: vmovhlps  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x18,0x12,0xeb]
          vmovhlps  %xmm11, %xmm12, %xmm13

// CHECK: vcvtss2sil  %xmm11, %eax
// CHECK: encoding: [0xc4,0xc1,0x7a,0x2d,0xc3]
          vcvtss2si  %xmm11, %eax

// CHECK: vcvtss2sil  (%rax), %ebx
// CHECK: encoding: [0xc5,0xfa,0x2d,0x18]
          vcvtss2si  (%rax), %ebx

// CHECK: vcvtdq2ps  %xmm10, %xmm12
// CHECK: encoding: [0xc4,0x41,0x78,0x5b,0xe2]
          vcvtdq2ps  %xmm10, %xmm12

// CHECK: vcvtdq2ps  (%rax), %xmm12
// CHECK: encoding: [0xc5,0x78,0x5b,0x20]
          vcvtdq2ps  (%rax), %xmm12

// CHECK: vcvtsd2ss  %xmm12, %xmm13, %xmm10
// CHECK: encoding: [0xc4,0x41,0x13,0x5a,0xd4]
          vcvtsd2ss  %xmm12, %xmm13, %xmm10

// CHECK: vcvtsd2ss  (%rax), %xmm13, %xmm10
// CHECK: encoding: [0xc5,0x13,0x5a,0x10]
          vcvtsd2ss  (%rax), %xmm13, %xmm10

// CHECK: vcvtps2dq  %xmm12, %xmm11
// CHECK: encoding: [0xc4,0x41,0x79,0x5b,0xdc]
          vcvtps2dq  %xmm12, %xmm11

// CHECK: vcvtps2dq  (%rax), %xmm11
// CHECK: encoding: [0xc5,0x79,0x5b,0x18]
          vcvtps2dq  (%rax), %xmm11

// CHECK: vcvtss2sd  %xmm12, %xmm13, %xmm10
// CHECK: encoding: [0xc4,0x41,0x12,0x5a,0xd4]
          vcvtss2sd  %xmm12, %xmm13, %xmm10

// CHECK: vcvtss2sd  (%rax), %xmm13, %xmm10
// CHECK: encoding: [0xc5,0x12,0x5a,0x10]
          vcvtss2sd  (%rax), %xmm13, %xmm10

// CHECK: vcvtdq2ps  %xmm13, %xmm10
// CHECK: encoding: [0xc4,0x41,0x78,0x5b,0xd5]
          vcvtdq2ps  %xmm13, %xmm10

// CHECK: vcvtdq2ps  (%ecx), %xmm13
// CHECK: encoding: [0xc5,0x78,0x5b,0x29]
          vcvtdq2ps  (%ecx), %xmm13

// CHECK: vcvttps2dq  %xmm12, %xmm11
// CHECK: encoding: [0xc4,0x41,0x7a,0x5b,0xdc]
          vcvttps2dq  %xmm12, %xmm11

// CHECK: vcvttps2dq  (%rax), %xmm11
// CHECK: encoding: [0xc5,0x7a,0x5b,0x18]
          vcvttps2dq  (%rax), %xmm11

// CHECK: vcvtps2pd  %xmm12, %xmm11
// CHECK: encoding: [0xc4,0x41,0x78,0x5a,0xdc]
          vcvtps2pd  %xmm12, %xmm11

// CHECK: vcvtps2pd  (%rax), %xmm11
// CHECK: encoding: [0xc5,0x78,0x5a,0x18]
          vcvtps2pd  (%rax), %xmm11

// CHECK: vcvtpd2ps  %xmm12, %xmm11
// CHECK: encoding: [0xc4,0x41,0x79,0x5a,0xdc]
          vcvtpd2ps  %xmm12, %xmm11

// CHECK: vsqrtpd  %xmm11, %xmm12
// CHECK: encoding: [0xc4,0x41,0x79,0x51,0xe3]
          vsqrtpd  %xmm11, %xmm12

// CHECK: vsqrtpd  (%rax), %xmm12
// CHECK: encoding: [0xc5,0x79,0x51,0x20]
          vsqrtpd  (%rax), %xmm12

// CHECK: vsqrtps  %xmm11, %xmm12
// CHECK: encoding: [0xc4,0x41,0x78,0x51,0xe3]
          vsqrtps  %xmm11, %xmm12

// CHECK: vsqrtps  (%rax), %xmm12
// CHECK: encoding: [0xc5,0x78,0x51,0x20]
          vsqrtps  (%rax), %xmm12

// CHECK: vsqrtsd  %xmm11, %xmm12, %xmm10
// CHECK: encoding: [0xc4,0x41,0x1b,0x51,0xd3]
          vsqrtsd  %xmm11, %xmm12, %xmm10

// CHECK: vsqrtsd  (%rax), %xmm12, %xmm10
// CHECK: encoding: [0xc5,0x1b,0x51,0x10]
          vsqrtsd  (%rax), %xmm12, %xmm10

// CHECK: vsqrtss  %xmm11, %xmm12, %xmm10
// CHECK: encoding: [0xc4,0x41,0x1a,0x51,0xd3]
          vsqrtss  %xmm11, %xmm12, %xmm10

// CHECK: vsqrtss  (%rax), %xmm12, %xmm10
// CHECK: encoding: [0xc5,0x1a,0x51,0x10]
          vsqrtss  (%rax), %xmm12, %xmm10

// CHECK: vrsqrtps  %xmm11, %xmm12
// CHECK: encoding: [0xc4,0x41,0x78,0x52,0xe3]
          vrsqrtps  %xmm11, %xmm12

// CHECK: vrsqrtps  (%rax), %xmm12
// CHECK: encoding: [0xc5,0x78,0x52,0x20]
          vrsqrtps  (%rax), %xmm12

// CHECK: vrsqrtss  %xmm11, %xmm12, %xmm10
// CHECK: encoding: [0xc4,0x41,0x1a,0x52,0xd3]
          vrsqrtss  %xmm11, %xmm12, %xmm10

// CHECK: vrsqrtss  (%rax), %xmm12, %xmm10
// CHECK: encoding: [0xc5,0x1a,0x52,0x10]
          vrsqrtss  (%rax), %xmm12, %xmm10

// CHECK: vrcpps  %xmm11, %xmm12
// CHECK: encoding: [0xc4,0x41,0x78,0x53,0xe3]
          vrcpps  %xmm11, %xmm12

// CHECK: vrcpps  (%rax), %xmm12
// CHECK: encoding: [0xc5,0x78,0x53,0x20]
          vrcpps  (%rax), %xmm12

// CHECK: vrcpss  %xmm11, %xmm12, %xmm10
// CHECK: encoding: [0xc4,0x41,0x1a,0x53,0xd3]
          vrcpss  %xmm11, %xmm12, %xmm10

// CHECK: vrcpss  (%rax), %xmm12, %xmm10
// CHECK: encoding: [0xc5,0x1a,0x53,0x10]
          vrcpss  (%rax), %xmm12, %xmm10

// CHECK: vmovntdq  %xmm11, (%rax)
// CHECK: encoding: [0xc5,0x79,0xe7,0x18]
          vmovntdq  %xmm11, (%rax)

// CHECK: vmovntpd  %xmm11, (%rax)
// CHECK: encoding: [0xc5,0x79,0x2b,0x18]
          vmovntpd  %xmm11, (%rax)

// CHECK: vmovntps  %xmm11, (%rax)
// CHECK: encoding: [0xc5,0x78,0x2b,0x18]
          vmovntps  %xmm11, (%rax)

// CHECK: vldmxcsr  -4(%rip)
// CHECK: encoding: [0xc5,0xf8,0xae,0x15,0xfc,0xff,0xff,0xff]
          vldmxcsr  -4(%rip)

// CHECK: vstmxcsr  -4(%rsp)
// CHECK: encoding: [0xc5,0xf8,0xae,0x5c,0x24,0xfc]
          vstmxcsr  -4(%rsp)

// CHECK: vpsubb  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xf8,0xeb]
          vpsubb  %xmm11, %xmm12, %xmm13

// CHECK: vpsubb  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xf8,0x28]
          vpsubb  (%rax), %xmm12, %xmm13

// CHECK: vpsubw  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xf9,0xeb]
          vpsubw  %xmm11, %xmm12, %xmm13

// CHECK: vpsubw  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xf9,0x28]
          vpsubw  (%rax), %xmm12, %xmm13

// CHECK: vpsubd  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xfa,0xeb]
          vpsubd  %xmm11, %xmm12, %xmm13

// CHECK: vpsubd  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xfa,0x28]
          vpsubd  (%rax), %xmm12, %xmm13

// CHECK: vpsubq  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xfb,0xeb]
          vpsubq  %xmm11, %xmm12, %xmm13

// CHECK: vpsubq  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xfb,0x28]
          vpsubq  (%rax), %xmm12, %xmm13

// CHECK: vpsubsb  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xe8,0xeb]
          vpsubsb  %xmm11, %xmm12, %xmm13

// CHECK: vpsubsb  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xe8,0x28]
          vpsubsb  (%rax), %xmm12, %xmm13

// CHECK: vpsubsw  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xe9,0xeb]
          vpsubsw  %xmm11, %xmm12, %xmm13

// CHECK: vpsubsw  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xe9,0x28]
          vpsubsw  (%rax), %xmm12, %xmm13

// CHECK: vpsubusb  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xd8,0xeb]
          vpsubusb  %xmm11, %xmm12, %xmm13

// CHECK: vpsubusb  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xd8,0x28]
          vpsubusb  (%rax), %xmm12, %xmm13

// CHECK: vpsubusw  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xd9,0xeb]
          vpsubusw  %xmm11, %xmm12, %xmm13

// CHECK: vpsubusw  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xd9,0x28]
          vpsubusw  (%rax), %xmm12, %xmm13

// CHECK: vpaddb  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xfc,0xeb]
          vpaddb  %xmm11, %xmm12, %xmm13

// CHECK: vpaddb  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xfc,0x28]
          vpaddb  (%rax), %xmm12, %xmm13

// CHECK: vpaddw  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xfd,0xeb]
          vpaddw  %xmm11, %xmm12, %xmm13

// CHECK: vpaddw  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xfd,0x28]
          vpaddw  (%rax), %xmm12, %xmm13

// CHECK: vpaddd  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xfe,0xeb]
          vpaddd  %xmm11, %xmm12, %xmm13

// CHECK: vpaddd  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xfe,0x28]
          vpaddd  (%rax), %xmm12, %xmm13

// CHECK: vpaddq  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xd4,0xeb]
          vpaddq  %xmm11, %xmm12, %xmm13

// CHECK: vpaddq  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xd4,0x28]
          vpaddq  (%rax), %xmm12, %xmm13

// CHECK: vpaddsb  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xec,0xeb]
          vpaddsb  %xmm11, %xmm12, %xmm13

// CHECK: vpaddsb  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xec,0x28]
          vpaddsb  (%rax), %xmm12, %xmm13

// CHECK: vpaddsw  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xed,0xeb]
          vpaddsw  %xmm11, %xmm12, %xmm13

// CHECK: vpaddsw  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xed,0x28]
          vpaddsw  (%rax), %xmm12, %xmm13

// CHECK: vpaddusb  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xdc,0xeb]
          vpaddusb  %xmm11, %xmm12, %xmm13

// CHECK: vpaddusb  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xdc,0x28]
          vpaddusb  (%rax), %xmm12, %xmm13

// CHECK: vpaddusw  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xdd,0xeb]
          vpaddusw  %xmm11, %xmm12, %xmm13

// CHECK: vpaddusw  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xdd,0x28]
          vpaddusw  (%rax), %xmm12, %xmm13

// CHECK: vpmulhuw  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xe4,0xeb]
          vpmulhuw  %xmm11, %xmm12, %xmm13

// CHECK: vpmulhuw  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xe4,0x28]
          vpmulhuw  (%rax), %xmm12, %xmm13

// CHECK: vpmulhw  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xe5,0xeb]
          vpmulhw  %xmm11, %xmm12, %xmm13

// CHECK: vpmulhw  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xe5,0x28]
          vpmulhw  (%rax), %xmm12, %xmm13

// CHECK: vpmullw  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xd5,0xeb]
          vpmullw  %xmm11, %xmm12, %xmm13

// CHECK: vpmullw  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xd5,0x28]
          vpmullw  (%rax), %xmm12, %xmm13

// CHECK: vpmuludq  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xf4,0xeb]
          vpmuludq  %xmm11, %xmm12, %xmm13

// CHECK: vpmuludq  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xf4,0x28]
          vpmuludq  (%rax), %xmm12, %xmm13

// CHECK: vpavgb  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xe0,0xeb]
          vpavgb  %xmm11, %xmm12, %xmm13

// CHECK: vpavgb  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xe0,0x28]
          vpavgb  (%rax), %xmm12, %xmm13

// CHECK: vpavgw  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xe3,0xeb]
          vpavgw  %xmm11, %xmm12, %xmm13

// CHECK: vpavgw  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xe3,0x28]
          vpavgw  (%rax), %xmm12, %xmm13

// CHECK: vpminsw  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xea,0xeb]
          vpminsw  %xmm11, %xmm12, %xmm13

// CHECK: vpminsw  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xea,0x28]
          vpminsw  (%rax), %xmm12, %xmm13

// CHECK: vpminub  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xda,0xeb]
          vpminub  %xmm11, %xmm12, %xmm13

// CHECK: vpminub  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xda,0x28]
          vpminub  (%rax), %xmm12, %xmm13

// CHECK: vpmaxsw  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xee,0xeb]
          vpmaxsw  %xmm11, %xmm12, %xmm13

// CHECK: vpmaxsw  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xee,0x28]
          vpmaxsw  (%rax), %xmm12, %xmm13

// CHECK: vpmaxub  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xde,0xeb]
          vpmaxub  %xmm11, %xmm12, %xmm13

// CHECK: vpmaxub  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xde,0x28]
          vpmaxub  (%rax), %xmm12, %xmm13

// CHECK: vpsadbw  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xf6,0xeb]
          vpsadbw  %xmm11, %xmm12, %xmm13

// CHECK: vpsadbw  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xf6,0x28]
          vpsadbw  (%rax), %xmm12, %xmm13

// CHECK: vpsllw  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xf1,0xeb]
          vpsllw  %xmm11, %xmm12, %xmm13

// CHECK: vpsllw  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xf1,0x28]
          vpsllw  (%rax), %xmm12, %xmm13

// CHECK: vpslld  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xf2,0xeb]
          vpslld  %xmm11, %xmm12, %xmm13

// CHECK: vpslld  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xf2,0x28]
          vpslld  (%rax), %xmm12, %xmm13

// CHECK: vpsllq  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xf3,0xeb]
          vpsllq  %xmm11, %xmm12, %xmm13

// CHECK: vpsllq  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xf3,0x28]
          vpsllq  (%rax), %xmm12, %xmm13

// CHECK: vpsraw  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xe1,0xeb]
          vpsraw  %xmm11, %xmm12, %xmm13

// CHECK: vpsraw  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xe1,0x28]
          vpsraw  (%rax), %xmm12, %xmm13

// CHECK: vpsrad  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xe2,0xeb]
          vpsrad  %xmm11, %xmm12, %xmm13

// CHECK: vpsrad  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xe2,0x28]
          vpsrad  (%rax), %xmm12, %xmm13

// CHECK: vpsrlw  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xd1,0xeb]
          vpsrlw  %xmm11, %xmm12, %xmm13

// CHECK: vpsrlw  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xd1,0x28]
          vpsrlw  (%rax), %xmm12, %xmm13

// CHECK: vpsrld  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xd2,0xeb]
          vpsrld  %xmm11, %xmm12, %xmm13

// CHECK: vpsrld  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xd2,0x28]
          vpsrld  (%rax), %xmm12, %xmm13

// CHECK: vpsrlq  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xd3,0xeb]
          vpsrlq  %xmm11, %xmm12, %xmm13

// CHECK: vpsrlq  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xd3,0x28]
          vpsrlq  (%rax), %xmm12, %xmm13

// CHECK: vpslld  $10, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0xc1,0x11,0x72,0xf4,0x0a]
          vpslld  $10, %xmm12, %xmm13

// CHECK: vpslldq  $10, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0xc1,0x11,0x73,0xfc,0x0a]
          vpslldq  $10, %xmm12, %xmm13

// CHECK: vpsllq  $10, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0xc1,0x11,0x73,0xf4,0x0a]
          vpsllq  $10, %xmm12, %xmm13

// CHECK: vpsllw  $10, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0xc1,0x11,0x71,0xf4,0x0a]
          vpsllw  $10, %xmm12, %xmm13

// CHECK: vpsrad  $10, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0xc1,0x11,0x72,0xe4,0x0a]
          vpsrad  $10, %xmm12, %xmm13

// CHECK: vpsraw  $10, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0xc1,0x11,0x71,0xe4,0x0a]
          vpsraw  $10, %xmm12, %xmm13

// CHECK: vpsrld  $10, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0xc1,0x11,0x72,0xd4,0x0a]
          vpsrld  $10, %xmm12, %xmm13

// CHECK: vpsrldq  $10, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0xc1,0x11,0x73,0xdc,0x0a]
          vpsrldq  $10, %xmm12, %xmm13

// CHECK: vpsrlq  $10, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0xc1,0x11,0x73,0xd4,0x0a]
          vpsrlq  $10, %xmm12, %xmm13

// CHECK: vpsrlw  $10, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0xc1,0x11,0x71,0xd4,0x0a]
          vpsrlw  $10, %xmm12, %xmm13

// CHECK: vpslld  $10, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0xc1,0x11,0x72,0xf4,0x0a]
          vpslld  $10, %xmm12, %xmm13

// CHECK: vpand  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xdb,0xeb]
          vpand  %xmm11, %xmm12, %xmm13

// CHECK: vpand  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xdb,0x28]
          vpand  (%rax), %xmm12, %xmm13

// CHECK: vpor  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xeb,0xeb]
          vpor  %xmm11, %xmm12, %xmm13

// CHECK: vpor  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xeb,0x28]
          vpor  (%rax), %xmm12, %xmm13

// CHECK: vpxor  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xef,0xeb]
          vpxor  %xmm11, %xmm12, %xmm13

// CHECK: vpxor  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xef,0x28]
          vpxor  (%rax), %xmm12, %xmm13

// CHECK: vpandn  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xdf,0xeb]
          vpandn  %xmm11, %xmm12, %xmm13

// CHECK: vpandn  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xdf,0x28]
          vpandn  (%rax), %xmm12, %xmm13

// CHECK: vpcmpeqb  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0x74,0xeb]
          vpcmpeqb  %xmm11, %xmm12, %xmm13

// CHECK: vpcmpeqb  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0x74,0x28]
          vpcmpeqb  (%rax), %xmm12, %xmm13

// CHECK: vpcmpeqw  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0x75,0xeb]
          vpcmpeqw  %xmm11, %xmm12, %xmm13

// CHECK: vpcmpeqw  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0x75,0x28]
          vpcmpeqw  (%rax), %xmm12, %xmm13

// CHECK: vpcmpeqd  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0x76,0xeb]
          vpcmpeqd  %xmm11, %xmm12, %xmm13

// CHECK: vpcmpeqd  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0x76,0x28]
          vpcmpeqd  (%rax), %xmm12, %xmm13

// CHECK: vpcmpgtb  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0x64,0xeb]
          vpcmpgtb  %xmm11, %xmm12, %xmm13

// CHECK: vpcmpgtb  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0x64,0x28]
          vpcmpgtb  (%rax), %xmm12, %xmm13

// CHECK: vpcmpgtw  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0x65,0xeb]
          vpcmpgtw  %xmm11, %xmm12, %xmm13

// CHECK: vpcmpgtw  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0x65,0x28]
          vpcmpgtw  (%rax), %xmm12, %xmm13

// CHECK: vpcmpgtd  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0x66,0xeb]
          vpcmpgtd  %xmm11, %xmm12, %xmm13

// CHECK: vpcmpgtd  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0x66,0x28]
          vpcmpgtd  (%rax), %xmm12, %xmm13

// CHECK: vpacksswb  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0x63,0xeb]
          vpacksswb  %xmm11, %xmm12, %xmm13

// CHECK: vpacksswb  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0x63,0x28]
          vpacksswb  (%rax), %xmm12, %xmm13

// CHECK: vpackssdw  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0x6b,0xeb]
          vpackssdw  %xmm11, %xmm12, %xmm13

// CHECK: vpackssdw  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0x6b,0x28]
          vpackssdw  (%rax), %xmm12, %xmm13

// CHECK: vpackuswb  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0x67,0xeb]
          vpackuswb  %xmm11, %xmm12, %xmm13

// CHECK: vpackuswb  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0x67,0x28]
          vpackuswb  (%rax), %xmm12, %xmm13

// CHECK: vpshufd  $4, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x79,0x70,0xec,0x04]
          vpshufd  $4, %xmm12, %xmm13

// CHECK: vpshufd  $4, (%rax), %xmm13
// CHECK: encoding: [0xc5,0x79,0x70,0x28,0x04]
          vpshufd  $4, (%rax), %xmm13

// CHECK: vpshufhw  $4, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x7a,0x70,0xec,0x04]
          vpshufhw  $4, %xmm12, %xmm13

// CHECK: vpshufhw  $4, (%rax), %xmm13
// CHECK: encoding: [0xc5,0x7a,0x70,0x28,0x04]
          vpshufhw  $4, (%rax), %xmm13

// CHECK: vpshuflw  $4, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x7b,0x70,0xec,0x04]
          vpshuflw  $4, %xmm12, %xmm13

// CHECK: vpshuflw  $4, (%rax), %xmm13
// CHECK: encoding: [0xc5,0x7b,0x70,0x28,0x04]
          vpshuflw  $4, (%rax), %xmm13

// CHECK: vpunpcklbw  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0x60,0xeb]
          vpunpcklbw  %xmm11, %xmm12, %xmm13

// CHECK: vpunpcklbw  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0x60,0x28]
          vpunpcklbw  (%rax), %xmm12, %xmm13

// CHECK: vpunpcklwd  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0x61,0xeb]
          vpunpcklwd  %xmm11, %xmm12, %xmm13

// CHECK: vpunpcklwd  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0x61,0x28]
          vpunpcklwd  (%rax), %xmm12, %xmm13

// CHECK: vpunpckldq  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0x62,0xeb]
          vpunpckldq  %xmm11, %xmm12, %xmm13

// CHECK: vpunpckldq  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0x62,0x28]
          vpunpckldq  (%rax), %xmm12, %xmm13

// CHECK: vpunpcklqdq  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0x6c,0xeb]
          vpunpcklqdq  %xmm11, %xmm12, %xmm13

// CHECK: vpunpcklqdq  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0x6c,0x28]
          vpunpcklqdq  (%rax), %xmm12, %xmm13

// CHECK: vpunpckhbw  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0x68,0xeb]
          vpunpckhbw  %xmm11, %xmm12, %xmm13

// CHECK: vpunpckhbw  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0x68,0x28]
          vpunpckhbw  (%rax), %xmm12, %xmm13

// CHECK: vpunpckhwd  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0x69,0xeb]
          vpunpckhwd  %xmm11, %xmm12, %xmm13

// CHECK: vpunpckhwd  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0x69,0x28]
          vpunpckhwd  (%rax), %xmm12, %xmm13

// CHECK: vpunpckhdq  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0x6a,0xeb]
          vpunpckhdq  %xmm11, %xmm12, %xmm13

// CHECK: vpunpckhdq  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0x6a,0x28]
          vpunpckhdq  (%rax), %xmm12, %xmm13

// CHECK: vpunpckhqdq  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0x6d,0xeb]
          vpunpckhqdq  %xmm11, %xmm12, %xmm13

// CHECK: vpunpckhqdq  (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0x6d,0x28]
          vpunpckhqdq  (%rax), %xmm12, %xmm13

// CHECK: vpinsrw  $7, %eax, %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xc4,0xe8,0x07]
          vpinsrw  $7, %eax, %xmm12, %xmm13

// CHECK: vpinsrw  $7, (%rax), %xmm12, %xmm13
// CHECK: encoding: [0xc5,0x19,0xc4,0x28,0x07]
          vpinsrw  $7, (%rax), %xmm12, %xmm13

// CHECK: vpextrw  $7, %xmm12, %eax
// CHECK: encoding: [0xc4,0xc1,0x79,0xc5,0xc4,0x07]
          vpextrw  $7, %xmm12, %eax

// CHECK: vpmovmskb  %xmm12, %eax
// CHECK: encoding: [0xc4,0xc1,0x79,0xd7,0xc4]
          vpmovmskb  %xmm12, %eax

// CHECK: vmaskmovdqu  %xmm14, %xmm15
// CHECK: encoding: [0xc4,0x41,0x79,0xf7,0xfe]
          vmaskmovdqu  %xmm14, %xmm15

// CHECK: vmovd  %eax, %xmm14
// CHECK: encoding: [0xc5,0x79,0x6e,0xf0]
          vmovd  %eax, %xmm14

// CHECK: vmovd  (%rax), %xmm14
// CHECK: encoding: [0xc5,0x79,0x6e,0x30]
          vmovd  (%rax), %xmm14

// CHECK: vmovd  %xmm14, (%rax)
// CHECK: encoding: [0xc5,0x79,0x7e,0x30]
          vmovd  %xmm14, (%rax)

// CHECK: vmovd  %rax, %xmm14
// CHECK: encoding: [0xc4,0x61,0xf9,0x6e,0xf0]
          vmovd  %rax, %xmm14

// CHECK: vmovq  %xmm14, (%rax)
// CHECK: encoding: [0xc5,0x79,0xd6,0x30]
          vmovq  %xmm14, (%rax)

// CHECK: vmovq  %xmm14, %xmm12
// CHECK: encoding: [0xc4,0x41,0x7a,0x7e,0xe6]
          vmovq  %xmm14, %xmm12

// CHECK: vmovq  (%rax), %xmm14
// CHECK: encoding: [0xc5,0x7a,0x7e,0x30]
          vmovq  (%rax), %xmm14

// CHECK: vmovq  %rax, %xmm14
// CHECK: encoding: [0xc4,0x61,0xf9,0x6e,0xf0]
          vmovq  %rax, %xmm14

// CHECK: vmovq  %xmm14, %rax
// CHECK: encoding: [0xc4,0x61,0xf9,0x7e,0xf0]
          vmovq  %xmm14, %rax

// CHECK: vcvtpd2dq  %xmm11, %xmm12
// CHECK: encoding: [0xc4,0x41,0x7b,0xe6,0xe3]
          vcvtpd2dq  %xmm11, %xmm12

// CHECK: vcvtdq2pd  %xmm11, %xmm12
// CHECK: encoding: [0xc4,0x41,0x7a,0xe6,0xe3]
          vcvtdq2pd  %xmm11, %xmm12

// CHECK: vcvtdq2pd  (%rax), %xmm12
// CHECK: encoding: [0xc5,0x7a,0xe6,0x20]
          vcvtdq2pd  (%rax), %xmm12

// CHECK: vmovshdup  %xmm11, %xmm12
// CHECK: encoding: [0xc4,0x41,0x7a,0x16,0xe3]
          vmovshdup  %xmm11, %xmm12

// CHECK: vmovshdup  (%rax), %xmm12
// CHECK: encoding: [0xc5,0x7a,0x16,0x20]
          vmovshdup  (%rax), %xmm12

// CHECK: vmovsldup  %xmm11, %xmm12
// CHECK: encoding: [0xc4,0x41,0x7a,0x12,0xe3]
          vmovsldup  %xmm11, %xmm12

// CHECK: vmovsldup  (%rax), %xmm12
// CHECK: encoding: [0xc5,0x7a,0x12,0x20]
          vmovsldup  (%rax), %xmm12

// CHECK: vmovddup  %xmm11, %xmm12
// CHECK: encoding: [0xc4,0x41,0x7b,0x12,0xe3]
          vmovddup  %xmm11, %xmm12

// CHECK: vmovddup  (%rax), %xmm12
// CHECK: encoding: [0xc5,0x7b,0x12,0x20]
          vmovddup  (%rax), %xmm12

// CHECK: vaddsubps  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x1b,0xd0,0xeb]
          vaddsubps  %xmm11, %xmm12, %xmm13

// CHECK: vaddsubps  (%rax), %xmm11, %xmm12
// CHECK: encoding: [0xc5,0x23,0xd0,0x20]
          vaddsubps  (%rax), %xmm11, %xmm12

// CHECK: vaddsubpd  %xmm11, %xmm12, %xmm13
// CHECK: encoding: [0xc4,0x41,0x19,0xd0,0xeb]
          vaddsubpd  %xmm11, %xmm12, %xmm13

// CHECK: vaddsubpd  (%rax), %xmm11, %xmm12
// CHECK: encoding: [0xc5,0x21,0xd0,0x20]
          vaddsubpd  (%rax), %xmm11, %xmm12

