// RUN: llvm-mc -triple x86_64-unknown-unknown -mcpu=knl --show-encoding %s | FileCheck %s

// CHECK: vaddpd -8192(%rdx), %zmm27, %zmm8
// CHECK:  encoding: [0x62,0x71,0xa5,0x40,0x58,0x42,0x80]
          vaddpd -8192(%rdx), %zmm27, %zmm8

// CHECK: vaddpd -1024(%rdx){1to8}, %zmm27, %zmm8
// CHECK:  encoding: [0x62,0x71,0xa5,0x50,0x58,0x42,0x80]
          vaddpd -1024(%rdx){1to8}, %zmm27, %zmm8

// CHECK: vaddps -8192(%rdx), %zmm13, %zmm18
// CHECK:  encoding: [0x62,0xe1,0x14,0x48,0x58,0x52,0x80]
          vaddps -8192(%rdx), %zmm13, %zmm18

// CHECK: vaddps -512(%rdx){1to16}, %zmm13, %zmm18
// CHECK:  encoding: [0x62,0xe1,0x14,0x58,0x58,0x52,0x80]
          vaddps -512(%rdx){1to16}, %zmm13, %zmm18

// CHECK: vdivpd -8192(%rdx), %zmm6, %zmm18
// CHECK:  encoding: [0x62,0xe1,0xcd,0x48,0x5e,0x52,0x80]
          vdivpd -8192(%rdx), %zmm6, %zmm18

// CHECK: vdivpd -1024(%rdx){1to8}, %zmm6, %zmm18
// CHECK:  encoding: [0x62,0xe1,0xcd,0x58,0x5e,0x52,0x80]
          vdivpd -1024(%rdx){1to8}, %zmm6, %zmm18

// CHECK: vdivps -8192(%rdx), %zmm23, %zmm23
// CHECK:  encoding: [0x62,0xe1,0x44,0x40,0x5e,0x7a,0x80]
          vdivps -8192(%rdx), %zmm23, %zmm23

// CHECK: vdivps -512(%rdx){1to16}, %zmm23, %zmm23
// CHECK:  encoding: [0x62,0xe1,0x44,0x50,0x5e,0x7a,0x80]
          vdivps -512(%rdx){1to16}, %zmm23, %zmm23

// CHECK: vmaxpd -8192(%rdx), %zmm28, %zmm30
// CHECK:  encoding: [0x62,0x61,0x9d,0x40,0x5f,0x72,0x80]
          vmaxpd -8192(%rdx), %zmm28, %zmm30

// CHECK: vmaxpd -1024(%rdx){1to8}, %zmm28, %zmm30
// CHECK:  encoding: [0x62,0x61,0x9d,0x50,0x5f,0x72,0x80]
          vmaxpd -1024(%rdx){1to8}, %zmm28, %zmm30

// CHECK: vmaxps -8192(%rdx), %zmm6, %zmm25
// CHECK:  encoding: [0x62,0x61,0x4c,0x48,0x5f,0x4a,0x80]
          vmaxps -8192(%rdx), %zmm6, %zmm25

// CHECK: vmaxps -512(%rdx){1to16}, %zmm6, %zmm25
// CHECK:  encoding: [0x62,0x61,0x4c,0x58,0x5f,0x4a,0x80]
          vmaxps -512(%rdx){1to16}, %zmm6, %zmm25

// CHECK: vminpd -8192(%rdx), %zmm6, %zmm6
// CHECK:  encoding: [0x62,0xf1,0xcd,0x48,0x5d,0x72,0x80]
          vminpd -8192(%rdx), %zmm6, %zmm6

// CHECK: vminpd -1024(%rdx){1to8}, %zmm6, %zmm6
// CHECK:  encoding: [0x62,0xf1,0xcd,0x58,0x5d,0x72,0x80]
          vminpd -1024(%rdx){1to8}, %zmm6, %zmm6

// CHECK: vminps -8192(%rdx), %zmm3, %zmm3
// CHECK:  encoding: [0x62,0xf1,0x64,0x48,0x5d,0x5a,0x80]
          vminps -8192(%rdx), %zmm3, %zmm3

// CHECK: vminps -512(%rdx){1to16}, %zmm3, %zmm3
// CHECK:  encoding: [0x62,0xf1,0x64,0x58,0x5d,0x5a,0x80]
          vminps -512(%rdx){1to16}, %zmm3, %zmm3

// CHECK: vmulpd -8192(%rdx), %zmm4, %zmm24
// CHECK:  encoding: [0x62,0x61,0xdd,0x48,0x59,0x42,0x80]
          vmulpd -8192(%rdx), %zmm4, %zmm24

// CHECK: vmulpd -1024(%rdx){1to8}, %zmm4, %zmm24
// CHECK:  encoding: [0x62,0x61,0xdd,0x58,0x59,0x42,0x80]
          vmulpd -1024(%rdx){1to8}, %zmm4, %zmm24

// CHECK: vmulps -8192(%rdx), %zmm6, %zmm3
// CHECK:  encoding: [0x62,0xf1,0x4c,0x48,0x59,0x5a,0x80]
          vmulps -8192(%rdx), %zmm6, %zmm3

// CHECK: vmulps -512(%rdx){1to16}, %zmm6, %zmm3
// CHECK:  encoding: [0x62,0xf1,0x4c,0x58,0x59,0x5a,0x80]
          vmulps -512(%rdx){1to16}, %zmm6, %zmm3

// CHECK: vsubpd -8192(%rdx), %zmm12, %zmm9
// CHECK:  encoding: [0x62,0x71,0x9d,0x48,0x5c,0x4a,0x80]
          vsubpd -8192(%rdx), %zmm12, %zmm9

// CHECK: vsubpd -1024(%rdx){1to8}, %zmm12, %zmm9
// CHECK:  encoding: [0x62,0x71,0x9d,0x58,0x5c,0x4a,0x80]
          vsubpd -1024(%rdx){1to8}, %zmm12, %zmm9

// CHECK: vsubps -8192(%rdx), %zmm27, %zmm14
// CHECK:  encoding: [0x62,0x71,0x24,0x40,0x5c,0x72,0x80]
          vsubps -8192(%rdx), %zmm27, %zmm14

// CHECK: vsubps -512(%rdx){1to16}, %zmm27, %zmm14
// CHECK:  encoding: [0x62,0x71,0x24,0x50,0x5c,0x72,0x80]
          vsubps -512(%rdx){1to16}, %zmm27, %zmm14

// CHECK: vaddpd %zmm6, %zmm27, %zmm8
// CHECK:  encoding: [0x62,0x71,0xa5,0x40,0x58,0xc6]
          vaddpd %zmm6, %zmm27, %zmm8

// CHECK: vaddpd %zmm6, %zmm27, %zmm8 {%k7}
// CHECK:  encoding: [0x62,0x71,0xa5,0x47,0x58,0xc6]
          vaddpd %zmm6, %zmm27, %zmm8 {%k7}

// CHECK: vaddpd %zmm6, %zmm27, %zmm8 {%k7} {z}
// CHECK:  encoding: [0x62,0x71,0xa5,0xc7,0x58,0xc6]
          vaddpd %zmm6, %zmm27, %zmm8 {%k7} {z}

// CHECK: vaddpd (%rcx), %zmm27, %zmm8
// CHECK:  encoding: [0x62,0x71,0xa5,0x40,0x58,0x01]
          vaddpd (%rcx), %zmm27, %zmm8

// CHECK: vaddpd 291(%rax,%r14,8), %zmm27, %zmm8
// CHECK:  encoding: [0x62,0x31,0xa5,0x40,0x58,0x84,0xf0,0x23,0x01,0x00,0x00]
          vaddpd 291(%rax,%r14,8), %zmm27, %zmm8

// CHECK: vaddpd (%rcx){1to8}, %zmm27, %zmm8
// CHECK:  encoding: [0x62,0x71,0xa5,0x50,0x58,0x01]
          vaddpd (%rcx){1to8}, %zmm27, %zmm8

// CHECK: vaddpd 8128(%rdx), %zmm27, %zmm8
// CHECK:  encoding: [0x62,0x71,0xa5,0x40,0x58,0x42,0x7f]
          vaddpd 8128(%rdx), %zmm27, %zmm8

// CHECK: vaddpd 8192(%rdx), %zmm27, %zmm8
// CHECK:  encoding: [0x62,0x71,0xa5,0x40,0x58,0x82,0x00,0x20,0x00,0x00]
          vaddpd 8192(%rdx), %zmm27, %zmm8

// CHECK: vaddpd -8256(%rdx), %zmm27, %zmm8
// CHECK:  encoding: [0x62,0x71,0xa5,0x40,0x58,0x82,0xc0,0xdf,0xff,0xff]
          vaddpd -8256(%rdx), %zmm27, %zmm8

// CHECK: vaddpd 1016(%rdx){1to8}, %zmm27, %zmm8
// CHECK:  encoding: [0x62,0x71,0xa5,0x50,0x58,0x42,0x7f]
          vaddpd 1016(%rdx){1to8}, %zmm27, %zmm8

// CHECK: vaddpd 1024(%rdx){1to8}, %zmm27, %zmm8
// CHECK:  encoding: [0x62,0x71,0xa5,0x50,0x58,0x82,0x00,0x04,0x00,0x00]
          vaddpd 1024(%rdx){1to8}, %zmm27, %zmm8

// CHECK: vaddpd -1032(%rdx){1to8}, %zmm27, %zmm8
// CHECK:  encoding: [0x62,0x71,0xa5,0x50,0x58,0x82,0xf8,0xfb,0xff,0xff]
          vaddpd -1032(%rdx){1to8}, %zmm27, %zmm8

// CHECK: vaddps %zmm2, %zmm13, %zmm18
// CHECK:  encoding: [0x62,0xe1,0x14,0x48,0x58,0xd2]
          vaddps %zmm2, %zmm13, %zmm18

// CHECK: vaddps %zmm2, %zmm13, %zmm18 {%k4}
// CHECK:  encoding: [0x62,0xe1,0x14,0x4c,0x58,0xd2]
          vaddps %zmm2, %zmm13, %zmm18 {%k4}

// CHECK: vaddps %zmm2, %zmm13, %zmm18 {%k4} {z}
// CHECK:  encoding: [0x62,0xe1,0x14,0xcc,0x58,0xd2]
          vaddps %zmm2, %zmm13, %zmm18 {%k4} {z}

// CHECK: vaddps (%rcx), %zmm13, %zmm18
// CHECK:  encoding: [0x62,0xe1,0x14,0x48,0x58,0x11]
          vaddps (%rcx), %zmm13, %zmm18

// CHECK: vaddps 291(%rax,%r14,8), %zmm13, %zmm18
// CHECK:  encoding: [0x62,0xa1,0x14,0x48,0x58,0x94,0xf0,0x23,0x01,0x00,0x00]
          vaddps 291(%rax,%r14,8), %zmm13, %zmm18

// CHECK: vaddps (%rcx){1to16}, %zmm13, %zmm18
// CHECK:  encoding: [0x62,0xe1,0x14,0x58,0x58,0x11]
          vaddps (%rcx){1to16}, %zmm13, %zmm18

// CHECK: vaddps 8128(%rdx), %zmm13, %zmm18
// CHECK:  encoding: [0x62,0xe1,0x14,0x48,0x58,0x52,0x7f]
          vaddps 8128(%rdx), %zmm13, %zmm18

// CHECK: vaddps 8192(%rdx), %zmm13, %zmm18
// CHECK:  encoding: [0x62,0xe1,0x14,0x48,0x58,0x92,0x00,0x20,0x00,0x00]
          vaddps 8192(%rdx), %zmm13, %zmm18

// CHECK: vaddps -8256(%rdx), %zmm13, %zmm18
// CHECK:  encoding: [0x62,0xe1,0x14,0x48,0x58,0x92,0xc0,0xdf,0xff,0xff]
          vaddps -8256(%rdx), %zmm13, %zmm18

// CHECK: vaddps 508(%rdx){1to16}, %zmm13, %zmm18
// CHECK:  encoding: [0x62,0xe1,0x14,0x58,0x58,0x52,0x7f]
          vaddps 508(%rdx){1to16}, %zmm13, %zmm18

// CHECK: vaddps 512(%rdx){1to16}, %zmm13, %zmm18
// CHECK:  encoding: [0x62,0xe1,0x14,0x58,0x58,0x92,0x00,0x02,0x00,0x00]
          vaddps 512(%rdx){1to16}, %zmm13, %zmm18

// CHECK: vaddps -516(%rdx){1to16}, %zmm13, %zmm18
// CHECK:  encoding: [0x62,0xe1,0x14,0x58,0x58,0x92,0xfc,0xfd,0xff,0xff]
          vaddps -516(%rdx){1to16}, %zmm13, %zmm18

// CHECK: vdivpd %zmm11, %zmm6, %zmm18
// CHECK:  encoding: [0x62,0xc1,0xcd,0x48,0x5e,0xd3]
          vdivpd %zmm11, %zmm6, %zmm18

// CHECK: vdivpd %zmm11, %zmm6, %zmm18 {%k4}
// CHECK:  encoding: [0x62,0xc1,0xcd,0x4c,0x5e,0xd3]
          vdivpd %zmm11, %zmm6, %zmm18 {%k4}

// CHECK: vdivpd %zmm11, %zmm6, %zmm18 {%k4} {z}
// CHECK:  encoding: [0x62,0xc1,0xcd,0xcc,0x5e,0xd3]
          vdivpd %zmm11, %zmm6, %zmm18 {%k4} {z}

// CHECK: vdivpd (%rcx), %zmm6, %zmm18
// CHECK:  encoding: [0x62,0xe1,0xcd,0x48,0x5e,0x11]
          vdivpd (%rcx), %zmm6, %zmm18

// CHECK: vdivpd 291(%rax,%r14,8), %zmm6, %zmm18
// CHECK:  encoding: [0x62,0xa1,0xcd,0x48,0x5e,0x94,0xf0,0x23,0x01,0x00,0x00]
          vdivpd 291(%rax,%r14,8), %zmm6, %zmm18

// CHECK: vdivpd (%rcx){1to8}, %zmm6, %zmm18
// CHECK:  encoding: [0x62,0xe1,0xcd,0x58,0x5e,0x11]
          vdivpd (%rcx){1to8}, %zmm6, %zmm18

// CHECK: vdivpd 8128(%rdx), %zmm6, %zmm18
// CHECK:  encoding: [0x62,0xe1,0xcd,0x48,0x5e,0x52,0x7f]
          vdivpd 8128(%rdx), %zmm6, %zmm18

// CHECK: vdivpd 8192(%rdx), %zmm6, %zmm18
// CHECK:  encoding: [0x62,0xe1,0xcd,0x48,0x5e,0x92,0x00,0x20,0x00,0x00]
          vdivpd 8192(%rdx), %zmm6, %zmm18

// CHECK: vdivpd -8256(%rdx), %zmm6, %zmm18
// CHECK:  encoding: [0x62,0xe1,0xcd,0x48,0x5e,0x92,0xc0,0xdf,0xff,0xff]
          vdivpd -8256(%rdx), %zmm6, %zmm18

// CHECK: vdivpd 1016(%rdx){1to8}, %zmm6, %zmm18
// CHECK:  encoding: [0x62,0xe1,0xcd,0x58,0x5e,0x52,0x7f]
          vdivpd 1016(%rdx){1to8}, %zmm6, %zmm18

// CHECK: vdivpd 1024(%rdx){1to8}, %zmm6, %zmm18
// CHECK:  encoding: [0x62,0xe1,0xcd,0x58,0x5e,0x92,0x00,0x04,0x00,0x00]
          vdivpd 1024(%rdx){1to8}, %zmm6, %zmm18

// CHECK: vdivpd -1032(%rdx){1to8}, %zmm6, %zmm18
// CHECK:  encoding: [0x62,0xe1,0xcd,0x58,0x5e,0x92,0xf8,0xfb,0xff,0xff]
          vdivpd -1032(%rdx){1to8}, %zmm6, %zmm18

// CHECK: vdivps %zmm28, %zmm23, %zmm23
// CHECK:  encoding: [0x62,0x81,0x44,0x40,0x5e,0xfc]
          vdivps %zmm28, %zmm23, %zmm23

// CHECK: vdivps %zmm28, %zmm23, %zmm23 {%k2}
// CHECK:  encoding: [0x62,0x81,0x44,0x42,0x5e,0xfc]
          vdivps %zmm28, %zmm23, %zmm23 {%k2}

// CHECK: vdivps %zmm28, %zmm23, %zmm23 {%k2} {z}
// CHECK:  encoding: [0x62,0x81,0x44,0xc2,0x5e,0xfc]
          vdivps %zmm28, %zmm23, %zmm23 {%k2} {z}

// CHECK: vdivps (%rcx), %zmm23, %zmm23
// CHECK:  encoding: [0x62,0xe1,0x44,0x40,0x5e,0x39]
          vdivps (%rcx), %zmm23, %zmm23

// CHECK: vdivps 291(%rax,%r14,8), %zmm23, %zmm23
// CHECK:  encoding: [0x62,0xa1,0x44,0x40,0x5e,0xbc,0xf0,0x23,0x01,0x00,0x00]
          vdivps 291(%rax,%r14,8), %zmm23, %zmm23

// CHECK: vdivps (%rcx){1to16}, %zmm23, %zmm23
// CHECK:  encoding: [0x62,0xe1,0x44,0x50,0x5e,0x39]
          vdivps (%rcx){1to16}, %zmm23, %zmm23

// CHECK: vdivps 8128(%rdx), %zmm23, %zmm23
// CHECK:  encoding: [0x62,0xe1,0x44,0x40,0x5e,0x7a,0x7f]
          vdivps 8128(%rdx), %zmm23, %zmm23

// CHECK: vdivps 8192(%rdx), %zmm23, %zmm23
// CHECK:  encoding: [0x62,0xe1,0x44,0x40,0x5e,0xba,0x00,0x20,0x00,0x00]
          vdivps 8192(%rdx), %zmm23, %zmm23

// CHECK: vdivps -8256(%rdx), %zmm23, %zmm23
// CHECK:  encoding: [0x62,0xe1,0x44,0x40,0x5e,0xba,0xc0,0xdf,0xff,0xff]
          vdivps -8256(%rdx), %zmm23, %zmm23

// CHECK: vdivps 508(%rdx){1to16}, %zmm23, %zmm23
// CHECK:  encoding: [0x62,0xe1,0x44,0x50,0x5e,0x7a,0x7f]
          vdivps 508(%rdx){1to16}, %zmm23, %zmm23

// CHECK: vdivps 512(%rdx){1to16}, %zmm23, %zmm23
// CHECK:  encoding: [0x62,0xe1,0x44,0x50,0x5e,0xba,0x00,0x02,0x00,0x00]
          vdivps 512(%rdx){1to16}, %zmm23, %zmm23

// CHECK: vdivps -516(%rdx){1to16}, %zmm23, %zmm23
// CHECK:  encoding: [0x62,0xe1,0x44,0x50,0x5e,0xba,0xfc,0xfd,0xff,0xff]
          vdivps -516(%rdx){1to16}, %zmm23, %zmm23

// CHECK: vmaxpd %zmm20, %zmm28, %zmm30
// CHECK:  encoding: [0x62,0x21,0x9d,0x40,0x5f,0xf4]
          vmaxpd %zmm20, %zmm28, %zmm30

// CHECK: vmaxpd %zmm20, %zmm28, %zmm30 {%k1}
// CHECK:  encoding: [0x62,0x21,0x9d,0x41,0x5f,0xf4]
          vmaxpd %zmm20, %zmm28, %zmm30 {%k1}

// CHECK: vmaxpd %zmm20, %zmm28, %zmm30 {%k1} {z}
// CHECK:  encoding: [0x62,0x21,0x9d,0xc1,0x5f,0xf4]
          vmaxpd %zmm20, %zmm28, %zmm30 {%k1} {z}

// CHECK: vmaxpd (%rcx), %zmm28, %zmm30
// CHECK:  encoding: [0x62,0x61,0x9d,0x40,0x5f,0x31]
          vmaxpd (%rcx), %zmm28, %zmm30

// CHECK: vmaxpd 291(%rax,%r14,8), %zmm28, %zmm30
// CHECK:  encoding: [0x62,0x21,0x9d,0x40,0x5f,0xb4,0xf0,0x23,0x01,0x00,0x00]
          vmaxpd 291(%rax,%r14,8), %zmm28, %zmm30

// CHECK: vmaxpd (%rcx){1to8}, %zmm28, %zmm30
// CHECK:  encoding: [0x62,0x61,0x9d,0x50,0x5f,0x31]
          vmaxpd (%rcx){1to8}, %zmm28, %zmm30

// CHECK: vmaxpd 8128(%rdx), %zmm28, %zmm30
// CHECK:  encoding: [0x62,0x61,0x9d,0x40,0x5f,0x72,0x7f]
          vmaxpd 8128(%rdx), %zmm28, %zmm30

// CHECK: vmaxpd 8192(%rdx), %zmm28, %zmm30
// CHECK:  encoding: [0x62,0x61,0x9d,0x40,0x5f,0xb2,0x00,0x20,0x00,0x00]
          vmaxpd 8192(%rdx), %zmm28, %zmm30

// CHECK: vmaxpd -8256(%rdx), %zmm28, %zmm30
// CHECK:  encoding: [0x62,0x61,0x9d,0x40,0x5f,0xb2,0xc0,0xdf,0xff,0xff]
          vmaxpd -8256(%rdx), %zmm28, %zmm30

// CHECK: vmaxpd 1016(%rdx){1to8}, %zmm28, %zmm30
// CHECK:  encoding: [0x62,0x61,0x9d,0x50,0x5f,0x72,0x7f]
          vmaxpd 1016(%rdx){1to8}, %zmm28, %zmm30

// CHECK: vmaxpd 1024(%rdx){1to8}, %zmm28, %zmm30
// CHECK:  encoding: [0x62,0x61,0x9d,0x50,0x5f,0xb2,0x00,0x04,0x00,0x00]
          vmaxpd 1024(%rdx){1to8}, %zmm28, %zmm30

// CHECK: vmaxpd -1032(%rdx){1to8}, %zmm28, %zmm30
// CHECK:  encoding: [0x62,0x61,0x9d,0x50,0x5f,0xb2,0xf8,0xfb,0xff,0xff]
          vmaxpd -1032(%rdx){1to8}, %zmm28, %zmm30

// CHECK: vmaxps %zmm20, %zmm6, %zmm25
// CHECK:  encoding: [0x62,0x21,0x4c,0x48,0x5f,0xcc]
          vmaxps %zmm20, %zmm6, %zmm25

// CHECK: vmaxps %zmm20, %zmm6, %zmm25 {%k1}
// CHECK:  encoding: [0x62,0x21,0x4c,0x49,0x5f,0xcc]
          vmaxps %zmm20, %zmm6, %zmm25 {%k1}

// CHECK: vmaxps %zmm20, %zmm6, %zmm25 {%k1} {z}
// CHECK:  encoding: [0x62,0x21,0x4c,0xc9,0x5f,0xcc]
          vmaxps %zmm20, %zmm6, %zmm25 {%k1} {z}

// CHECK: vmaxps (%rcx), %zmm6, %zmm25
// CHECK:  encoding: [0x62,0x61,0x4c,0x48,0x5f,0x09]
          vmaxps (%rcx), %zmm6, %zmm25

// CHECK: vmaxps 291(%rax,%r14,8), %zmm6, %zmm25
// CHECK:  encoding: [0x62,0x21,0x4c,0x48,0x5f,0x8c,0xf0,0x23,0x01,0x00,0x00]
          vmaxps 291(%rax,%r14,8), %zmm6, %zmm25

// CHECK: vmaxps (%rcx){1to16}, %zmm6, %zmm25
// CHECK:  encoding: [0x62,0x61,0x4c,0x58,0x5f,0x09]
          vmaxps (%rcx){1to16}, %zmm6, %zmm25

// CHECK: vmaxps 8128(%rdx), %zmm6, %zmm25
// CHECK:  encoding: [0x62,0x61,0x4c,0x48,0x5f,0x4a,0x7f]
          vmaxps 8128(%rdx), %zmm6, %zmm25

// CHECK: vmaxps 8192(%rdx), %zmm6, %zmm25
// CHECK:  encoding: [0x62,0x61,0x4c,0x48,0x5f,0x8a,0x00,0x20,0x00,0x00]
          vmaxps 8192(%rdx), %zmm6, %zmm25

// CHECK: vmaxps -8256(%rdx), %zmm6, %zmm25
// CHECK:  encoding: [0x62,0x61,0x4c,0x48,0x5f,0x8a,0xc0,0xdf,0xff,0xff]
          vmaxps -8256(%rdx), %zmm6, %zmm25

// CHECK: vmaxps 508(%rdx){1to16}, %zmm6, %zmm25
// CHECK:  encoding: [0x62,0x61,0x4c,0x58,0x5f,0x4a,0x7f]
          vmaxps 508(%rdx){1to16}, %zmm6, %zmm25

// CHECK: vmaxps 512(%rdx){1to16}, %zmm6, %zmm25
// CHECK:  encoding: [0x62,0x61,0x4c,0x58,0x5f,0x8a,0x00,0x02,0x00,0x00]
          vmaxps 512(%rdx){1to16}, %zmm6, %zmm25

// CHECK: vmaxps -516(%rdx){1to16}, %zmm6, %zmm25
// CHECK:  encoding: [0x62,0x61,0x4c,0x58,0x5f,0x8a,0xfc,0xfd,0xff,0xff]
          vmaxps -516(%rdx){1to16}, %zmm6, %zmm25

// CHECK: vminpd %zmm22, %zmm6, %zmm6
// CHECK:  encoding: [0x62,0xb1,0xcd,0x48,0x5d,0xf6]
          vminpd %zmm22, %zmm6, %zmm6

// CHECK: vminpd %zmm22, %zmm6, %zmm6 {%k7}
// CHECK:  encoding: [0x62,0xb1,0xcd,0x4f,0x5d,0xf6]
          vminpd %zmm22, %zmm6, %zmm6 {%k7}

// CHECK: vminpd %zmm22, %zmm6, %zmm6 {%k7} {z}
// CHECK:  encoding: [0x62,0xb1,0xcd,0xcf,0x5d,0xf6]
          vminpd %zmm22, %zmm6, %zmm6 {%k7} {z}

// CHECK: vminpd (%rcx), %zmm6, %zmm6
// CHECK:  encoding: [0x62,0xf1,0xcd,0x48,0x5d,0x31]
          vminpd (%rcx), %zmm6, %zmm6

// CHECK: vminpd 291(%rax,%r14,8), %zmm6, %zmm6
// CHECK:  encoding: [0x62,0xb1,0xcd,0x48,0x5d,0xb4,0xf0,0x23,0x01,0x00,0x00]
          vminpd 291(%rax,%r14,8), %zmm6, %zmm6

// CHECK: vminpd (%rcx){1to8}, %zmm6, %zmm6
// CHECK:  encoding: [0x62,0xf1,0xcd,0x58,0x5d,0x31]
          vminpd (%rcx){1to8}, %zmm6, %zmm6

// CHECK: vminpd 8128(%rdx), %zmm6, %zmm6
// CHECK:  encoding: [0x62,0xf1,0xcd,0x48,0x5d,0x72,0x7f]
          vminpd 8128(%rdx), %zmm6, %zmm6

// CHECK: vminpd 8192(%rdx), %zmm6, %zmm6
// CHECK:  encoding: [0x62,0xf1,0xcd,0x48,0x5d,0xb2,0x00,0x20,0x00,0x00]
          vminpd 8192(%rdx), %zmm6, %zmm6

// CHECK: vminpd -8256(%rdx), %zmm6, %zmm6
// CHECK:  encoding: [0x62,0xf1,0xcd,0x48,0x5d,0xb2,0xc0,0xdf,0xff,0xff]
          vminpd -8256(%rdx), %zmm6, %zmm6

// CHECK: vminpd 1016(%rdx){1to8}, %zmm6, %zmm6
// CHECK:  encoding: [0x62,0xf1,0xcd,0x58,0x5d,0x72,0x7f]
          vminpd 1016(%rdx){1to8}, %zmm6, %zmm6

// CHECK: vminpd 1024(%rdx){1to8}, %zmm6, %zmm6
// CHECK:  encoding: [0x62,0xf1,0xcd,0x58,0x5d,0xb2,0x00,0x04,0x00,0x00]
          vminpd 1024(%rdx){1to8}, %zmm6, %zmm6

// CHECK: vminpd -1032(%rdx){1to8}, %zmm6, %zmm6
// CHECK:  encoding: [0x62,0xf1,0xcd,0x58,0x5d,0xb2,0xf8,0xfb,0xff,0xff]
          vminpd -1032(%rdx){1to8}, %zmm6, %zmm6

// CHECK: vminps %zmm7, %zmm3, %zmm3
// CHECK:  encoding: [0x62,0xf1,0x64,0x48,0x5d,0xdf]
          vminps %zmm7, %zmm3, %zmm3

// CHECK: vminps %zmm7, %zmm3, %zmm3 {%k3}
// CHECK:  encoding: [0x62,0xf1,0x64,0x4b,0x5d,0xdf]
          vminps %zmm7, %zmm3, %zmm3 {%k3}

// CHECK: vminps %zmm7, %zmm3, %zmm3 {%k3} {z}
// CHECK:  encoding: [0x62,0xf1,0x64,0xcb,0x5d,0xdf]
          vminps %zmm7, %zmm3, %zmm3 {%k3} {z}

// CHECK: vminps (%rcx), %zmm3, %zmm3
// CHECK:  encoding: [0x62,0xf1,0x64,0x48,0x5d,0x19]
          vminps (%rcx), %zmm3, %zmm3

// CHECK: vminps 291(%rax,%r14,8), %zmm3, %zmm3
// CHECK:  encoding: [0x62,0xb1,0x64,0x48,0x5d,0x9c,0xf0,0x23,0x01,0x00,0x00]
          vminps 291(%rax,%r14,8), %zmm3, %zmm3

// CHECK: vminps (%rcx){1to16}, %zmm3, %zmm3
// CHECK:  encoding: [0x62,0xf1,0x64,0x58,0x5d,0x19]
          vminps (%rcx){1to16}, %zmm3, %zmm3

// CHECK: vminps 8128(%rdx), %zmm3, %zmm3
// CHECK:  encoding: [0x62,0xf1,0x64,0x48,0x5d,0x5a,0x7f]
          vminps 8128(%rdx), %zmm3, %zmm3

// CHECK: vminps 8192(%rdx), %zmm3, %zmm3
// CHECK:  encoding: [0x62,0xf1,0x64,0x48,0x5d,0x9a,0x00,0x20,0x00,0x00]
          vminps 8192(%rdx), %zmm3, %zmm3

// CHECK: vminps -8256(%rdx), %zmm3, %zmm3
// CHECK:  encoding: [0x62,0xf1,0x64,0x48,0x5d,0x9a,0xc0,0xdf,0xff,0xff]
          vminps -8256(%rdx), %zmm3, %zmm3

// CHECK: vminps 508(%rdx){1to16}, %zmm3, %zmm3
// CHECK:  encoding: [0x62,0xf1,0x64,0x58,0x5d,0x5a,0x7f]
          vminps 508(%rdx){1to16}, %zmm3, %zmm3

// CHECK: vminps 512(%rdx){1to16}, %zmm3, %zmm3
// CHECK:  encoding: [0x62,0xf1,0x64,0x58,0x5d,0x9a,0x00,0x02,0x00,0x00]
          vminps 512(%rdx){1to16}, %zmm3, %zmm3

// CHECK: vminps -516(%rdx){1to16}, %zmm3, %zmm3
// CHECK:  encoding: [0x62,0xf1,0x64,0x58,0x5d,0x9a,0xfc,0xfd,0xff,0xff]
          vminps -516(%rdx){1to16}, %zmm3, %zmm3

// CHECK: vmulpd %zmm23, %zmm4, %zmm24
// CHECK:  encoding: [0x62,0x21,0xdd,0x48,0x59,0xc7]
          vmulpd %zmm23, %zmm4, %zmm24

// CHECK: vmulpd %zmm23, %zmm4, %zmm24 {%k6}
// CHECK:  encoding: [0x62,0x21,0xdd,0x4e,0x59,0xc7]
          vmulpd %zmm23, %zmm4, %zmm24 {%k6}

// CHECK: vmulpd %zmm23, %zmm4, %zmm24 {%k6} {z}
// CHECK:  encoding: [0x62,0x21,0xdd,0xce,0x59,0xc7]
          vmulpd %zmm23, %zmm4, %zmm24 {%k6} {z}

// CHECK: vmulpd (%rcx), %zmm4, %zmm24
// CHECK:  encoding: [0x62,0x61,0xdd,0x48,0x59,0x01]
          vmulpd (%rcx), %zmm4, %zmm24

// CHECK: vmulpd 291(%rax,%r14,8), %zmm4, %zmm24
// CHECK:  encoding: [0x62,0x21,0xdd,0x48,0x59,0x84,0xf0,0x23,0x01,0x00,0x00]
          vmulpd 291(%rax,%r14,8), %zmm4, %zmm24

// CHECK: vmulpd (%rcx){1to8}, %zmm4, %zmm24
// CHECK:  encoding: [0x62,0x61,0xdd,0x58,0x59,0x01]
          vmulpd (%rcx){1to8}, %zmm4, %zmm24

// CHECK: vmulpd 8128(%rdx), %zmm4, %zmm24
// CHECK:  encoding: [0x62,0x61,0xdd,0x48,0x59,0x42,0x7f]
          vmulpd 8128(%rdx), %zmm4, %zmm24

// CHECK: vmulpd 8192(%rdx), %zmm4, %zmm24
// CHECK:  encoding: [0x62,0x61,0xdd,0x48,0x59,0x82,0x00,0x20,0x00,0x00]
          vmulpd 8192(%rdx), %zmm4, %zmm24

// CHECK: vmulpd -8256(%rdx), %zmm4, %zmm24
// CHECK:  encoding: [0x62,0x61,0xdd,0x48,0x59,0x82,0xc0,0xdf,0xff,0xff]
          vmulpd -8256(%rdx), %zmm4, %zmm24

// CHECK: vmulpd 1016(%rdx){1to8}, %zmm4, %zmm24
// CHECK:  encoding: [0x62,0x61,0xdd,0x58,0x59,0x42,0x7f]
          vmulpd 1016(%rdx){1to8}, %zmm4, %zmm24

// CHECK: vmulpd 1024(%rdx){1to8}, %zmm4, %zmm24
// CHECK:  encoding: [0x62,0x61,0xdd,0x58,0x59,0x82,0x00,0x04,0x00,0x00]
          vmulpd 1024(%rdx){1to8}, %zmm4, %zmm24

// CHECK: vmulpd -1032(%rdx){1to8}, %zmm4, %zmm24
// CHECK:  encoding: [0x62,0x61,0xdd,0x58,0x59,0x82,0xf8,0xfb,0xff,0xff]
          vmulpd -1032(%rdx){1to8}, %zmm4, %zmm24

// CHECK: vmulps %zmm24, %zmm6, %zmm3
// CHECK:  encoding: [0x62,0x91,0x4c,0x48,0x59,0xd8]
          vmulps %zmm24, %zmm6, %zmm3

// CHECK: vmulps %zmm24, %zmm6, %zmm3 {%k4}
// CHECK:  encoding: [0x62,0x91,0x4c,0x4c,0x59,0xd8]
          vmulps %zmm24, %zmm6, %zmm3 {%k4}

// CHECK: vmulps %zmm24, %zmm6, %zmm3 {%k4} {z}
// CHECK:  encoding: [0x62,0x91,0x4c,0xcc,0x59,0xd8]
          vmulps %zmm24, %zmm6, %zmm3 {%k4} {z}

// CHECK: vmulps (%rcx), %zmm6, %zmm3
// CHECK:  encoding: [0x62,0xf1,0x4c,0x48,0x59,0x19]
          vmulps (%rcx), %zmm6, %zmm3

// CHECK: vmulps 291(%rax,%r14,8), %zmm6, %zmm3
// CHECK:  encoding: [0x62,0xb1,0x4c,0x48,0x59,0x9c,0xf0,0x23,0x01,0x00,0x00]
          vmulps 291(%rax,%r14,8), %zmm6, %zmm3

// CHECK: vmulps (%rcx){1to16}, %zmm6, %zmm3
// CHECK:  encoding: [0x62,0xf1,0x4c,0x58,0x59,0x19]
          vmulps (%rcx){1to16}, %zmm6, %zmm3

// CHECK: vmulps 8128(%rdx), %zmm6, %zmm3
// CHECK:  encoding: [0x62,0xf1,0x4c,0x48,0x59,0x5a,0x7f]
          vmulps 8128(%rdx), %zmm6, %zmm3

// CHECK: vmulps 8192(%rdx), %zmm6, %zmm3
// CHECK:  encoding: [0x62,0xf1,0x4c,0x48,0x59,0x9a,0x00,0x20,0x00,0x00]
          vmulps 8192(%rdx), %zmm6, %zmm3

// CHECK: vmulps -8256(%rdx), %zmm6, %zmm3
// CHECK:  encoding: [0x62,0xf1,0x4c,0x48,0x59,0x9a,0xc0,0xdf,0xff,0xff]
          vmulps -8256(%rdx), %zmm6, %zmm3

// CHECK: vmulps 508(%rdx){1to16}, %zmm6, %zmm3
// CHECK:  encoding: [0x62,0xf1,0x4c,0x58,0x59,0x5a,0x7f]
          vmulps 508(%rdx){1to16}, %zmm6, %zmm3

// CHECK: vmulps 512(%rdx){1to16}, %zmm6, %zmm3
// CHECK:  encoding: [0x62,0xf1,0x4c,0x58,0x59,0x9a,0x00,0x02,0x00,0x00]
          vmulps 512(%rdx){1to16}, %zmm6, %zmm3

// CHECK: vmulps -516(%rdx){1to16}, %zmm6, %zmm3
// CHECK:  encoding: [0x62,0xf1,0x4c,0x58,0x59,0x9a,0xfc,0xfd,0xff,0xff]
          vmulps -516(%rdx){1to16}, %zmm6, %zmm3

// CHECK: vsubpd %zmm9, %zmm12, %zmm9
// CHECK:  encoding: [0x62,0x51,0x9d,0x48,0x5c,0xc9]
          vsubpd %zmm9, %zmm12, %zmm9

// CHECK: vsubpd %zmm9, %zmm12, %zmm9 {%k7}
// CHECK:  encoding: [0x62,0x51,0x9d,0x4f,0x5c,0xc9]
          vsubpd %zmm9, %zmm12, %zmm9 {%k7}

// CHECK: vsubpd %zmm9, %zmm12, %zmm9 {%k7} {z}
// CHECK:  encoding: [0x62,0x51,0x9d,0xcf,0x5c,0xc9]
          vsubpd %zmm9, %zmm12, %zmm9 {%k7} {z}

// CHECK: vsubpd (%rcx), %zmm12, %zmm9
// CHECK:  encoding: [0x62,0x71,0x9d,0x48,0x5c,0x09]
          vsubpd (%rcx), %zmm12, %zmm9

// CHECK: vsubpd 291(%rax,%r14,8), %zmm12, %zmm9
// CHECK:  encoding: [0x62,0x31,0x9d,0x48,0x5c,0x8c,0xf0,0x23,0x01,0x00,0x00]
          vsubpd 291(%rax,%r14,8), %zmm12, %zmm9

// CHECK: vsubpd (%rcx){1to8}, %zmm12, %zmm9
// CHECK:  encoding: [0x62,0x71,0x9d,0x58,0x5c,0x09]
          vsubpd (%rcx){1to8}, %zmm12, %zmm9

// CHECK: vsubpd 8128(%rdx), %zmm12, %zmm9
// CHECK:  encoding: [0x62,0x71,0x9d,0x48,0x5c,0x4a,0x7f]
          vsubpd 8128(%rdx), %zmm12, %zmm9

// CHECK: vsubpd 8192(%rdx), %zmm12, %zmm9
// CHECK:  encoding: [0x62,0x71,0x9d,0x48,0x5c,0x8a,0x00,0x20,0x00,0x00]
          vsubpd 8192(%rdx), %zmm12, %zmm9

// CHECK: vsubpd -8256(%rdx), %zmm12, %zmm9
// CHECK:  encoding: [0x62,0x71,0x9d,0x48,0x5c,0x8a,0xc0,0xdf,0xff,0xff]
          vsubpd -8256(%rdx), %zmm12, %zmm9

// CHECK: vsubpd 1016(%rdx){1to8}, %zmm12, %zmm9
// CHECK:  encoding: [0x62,0x71,0x9d,0x58,0x5c,0x4a,0x7f]
          vsubpd 1016(%rdx){1to8}, %zmm12, %zmm9

// CHECK: vsubpd 1024(%rdx){1to8}, %zmm12, %zmm9
// CHECK:  encoding: [0x62,0x71,0x9d,0x58,0x5c,0x8a,0x00,0x04,0x00,0x00]
          vsubpd 1024(%rdx){1to8}, %zmm12, %zmm9

// CHECK: vsubpd -1032(%rdx){1to8}, %zmm12, %zmm9
// CHECK:  encoding: [0x62,0x71,0x9d,0x58,0x5c,0x8a,0xf8,0xfb,0xff,0xff]
          vsubpd -1032(%rdx){1to8}, %zmm12, %zmm9

// CHECK: vsubps %zmm21, %zmm27, %zmm14
// CHECK:  encoding: [0x62,0x31,0x24,0x40,0x5c,0xf5]
          vsubps %zmm21, %zmm27, %zmm14

// CHECK: vsubps %zmm21, %zmm27, %zmm14 {%k5}
// CHECK:  encoding: [0x62,0x31,0x24,0x45,0x5c,0xf5]
          vsubps %zmm21, %zmm27, %zmm14 {%k5}

// CHECK: vsubps %zmm21, %zmm27, %zmm14 {%k5} {z}
// CHECK:  encoding: [0x62,0x31,0x24,0xc5,0x5c,0xf5]
          vsubps %zmm21, %zmm27, %zmm14 {%k5} {z}

// CHECK: vsubps (%rcx), %zmm27, %zmm14
// CHECK:  encoding: [0x62,0x71,0x24,0x40,0x5c,0x31]
          vsubps (%rcx), %zmm27, %zmm14

// CHECK: vsubps 291(%rax,%r14,8), %zmm27, %zmm14
// CHECK:  encoding: [0x62,0x31,0x24,0x40,0x5c,0xb4,0xf0,0x23,0x01,0x00,0x00]
          vsubps 291(%rax,%r14,8), %zmm27, %zmm14

// CHECK: vsubps (%rcx){1to16}, %zmm27, %zmm14
// CHECK:  encoding: [0x62,0x71,0x24,0x50,0x5c,0x31]
          vsubps (%rcx){1to16}, %zmm27, %zmm14

// CHECK: vsubps 8128(%rdx), %zmm27, %zmm14
// CHECK:  encoding: [0x62,0x71,0x24,0x40,0x5c,0x72,0x7f]
          vsubps 8128(%rdx), %zmm27, %zmm14

// CHECK: vsubps 8192(%rdx), %zmm27, %zmm14
// CHECK:  encoding: [0x62,0x71,0x24,0x40,0x5c,0xb2,0x00,0x20,0x00,0x00]
          vsubps 8192(%rdx), %zmm27, %zmm14

// CHECK: vsubps -8256(%rdx), %zmm27, %zmm14
// CHECK:  encoding: [0x62,0x71,0x24,0x40,0x5c,0xb2,0xc0,0xdf,0xff,0xff]
          vsubps -8256(%rdx), %zmm27, %zmm14

// CHECK: vsubps 508(%rdx){1to16}, %zmm27, %zmm14
// CHECK:  encoding: [0x62,0x71,0x24,0x50,0x5c,0x72,0x7f]
          vsubps 508(%rdx){1to16}, %zmm27, %zmm14

// CHECK: vsubps 512(%rdx){1to16}, %zmm27, %zmm14
// CHECK:  encoding: [0x62,0x71,0x24,0x50,0x5c,0xb2,0x00,0x02,0x00,0x00]
          vsubps 512(%rdx){1to16}, %zmm27, %zmm14

// CHECK: vsubps -516(%rdx){1to16}, %zmm27, %zmm14
// CHECK:  encoding: [0x62,0x71,0x24,0x50,0x5c,0xb2,0xfc,0xfd,0xff,0xff]
          vsubps -516(%rdx){1to16}, %zmm27, %zmm14

// CHECK: vinserti32x4
// CHECK: encoding: [0x62,0xa3,0x55,0x48,0x38,0xcd,0x01]
vinserti32x4  $1, %xmm21, %zmm5, %zmm17

// CHECK: vinserti32x4
// CHECK: encoding: [0x62,0xe3,0x1d,0x40,0x38,0x4f,0x10,0x01]
vinserti32x4  $1, 256(%rdi), %zmm28, %zmm17

// CHECK: vextracti32x4
// CHECK: encoding: [0x62,0x33,0x7d,0x48,0x39,0xc9,0x01]
vextracti32x4  $1, %zmm9, %xmm17

// CHECK: vextracti64x4
// CHECK: encoding: [0x62,0x33,0xfd,0x48,0x3b,0xc9,0x01]
vextracti64x4  $1, %zmm9, %ymm17

// CHECK: vextracti64x4
// CHECK: encoding: [0x62,0x73,0xfd,0x48,0x3b,0x4f,0x10,0x01]
vextracti64x4  $1, %zmm9, 512(%rdi)

// CHECK: vpsrad
// CHECK: encoding: [0x62,0xb1,0x35,0x40,0x72,0xe1,0x02]
vpsrad $2, %zmm17, %zmm25

// CHECK: vpsrad
// CHECK: encoding: [0x62,0xf1,0x35,0x40,0x72,0x64,0xb7,0x08,0x02]
vpsrad $2, 512(%rdi, %rsi, 4), %zmm25

// CHECK: vpsrad
// CHECK: encoding: [0x62,0x21,0x1d,0x48,0xe2,0xc9]
vpsrad %xmm17, %zmm12, %zmm25

// CHECK: vpsrad
// CHECK: encoding: [0x62,0x61,0x1d,0x48,0xe2,0x4c,0xb7,0x20]
vpsrad 512(%rdi, %rsi, 4), %zmm12, %zmm25

// CHECK: vpbroadcastd {{.*}} {%k1} {z}
// CHECK: encoding: [0x62,0xf2,0x7d,0xc9,0x58,0xc8]
vpbroadcastd  %xmm0, %zmm1 {%k1} {z}

// CHECK: vmovdqu64 {{.*}} {%k3}
// CHECK: encoding: [0x62,0xf1,0xfe,0x4b,0x7f,0x07]
vmovdqu64 %zmm0, (%rdi) {%k3}

// CHECK: vmovdqa32 {{.*}} {%k4}
// CHECK: encoding: [0x62,0x61,0x7d,0x4c,0x6f,0x1e]
vmovdqa32 (%rsi), %zmm27 {%k4}

// CHECK: vmovd
// CHECK: encoding: [0x62,0xe1,0x7d,0x08,0x7e,0x74,0x24,0xeb]
vmovd %xmm22, -84(%rsp)

// CHECK: vextractps
// CHECK: encoding: [0x62,0xe3,0x7d,0x08,0x17,0x61,0x1f,0x02]
vextractps      $2, %xmm20, 124(%rcx)

// CHECK: vaddpd {{.*}}{1to8}
// CHECK: encoding: [0x62,0x61,0xdd,0x50,0x58,0x74,0xf7,0x40]
vaddpd 512(%rdi, %rsi, 8) {1to8}, %zmm20, %zmm30

// CHECK: vaddps {{.*}}{1to16}
// CHECK: encoding: [0x62,0x61,0x5c,0x50,0x58,0xb4,0xf7,0x00,0x02,0x00,0x00]
vaddps 512(%rdi, %rsi, 8) {1to16}, %zmm20, %zmm30
