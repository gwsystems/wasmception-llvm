// RUN: llvm-mc -triple x86_64-unknown-unknown --show-encoding < %s | FileCheck %s

// CHECK: vpopcntb %zmm23, %zmm21
// CHECK: encoding: [0x62,0xa2,0x7d,0x48,0x54,0xef]
          vpopcntb %zmm23, %zmm21

// CHECK: vpopcntw %zmm23, %zmm21
// CHECK: encoding: [0x62,0xa2,0xfd,0x48,0x54,0xef]
          vpopcntw %zmm23, %zmm21

// CHECK: vpopcntb %zmm3, %zmm1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x7d,0x4a,0x54,0xcb]
          vpopcntb %zmm3, %zmm1 {%k2}

// CHECK: vpopcntw %zmm3, %zmm1 {%k2}
// CHECK: encoding: [0x62,0xf2,0xfd,0x4a,0x54,0xcb]
          vpopcntw %zmm3, %zmm1 {%k2}

// CHECK: vpopcntb  (%rcx), %zmm1
// CHECK: encoding: [0x62,0xf2,0x7d,0x48,0x54,0x09]
          vpopcntb  (%rcx), %zmm1

// CHECK: vpopcntb  -256(%rsp), %zmm1
// CHECK: encoding: [0x62,0xf2,0x7d,0x48,0x54,0x4c,0x24,0xfc]
          vpopcntb  -256(%rsp), %zmm1

// CHECK: vpopcntb  256(%rsp), %zmm1
// CHECK: encoding: [0x62,0xf2,0x7d,0x48,0x54,0x4c,0x24,0x04]
          vpopcntb  256(%rsp), %zmm1

// CHECK: vpopcntb  268435456(%rcx,%r14,8), %zmm1
// CHECK: encoding: [0x62,0xb2,0x7d,0x48,0x54,0x8c,0xf1,0x00,0x00,0x00,0x10]
          vpopcntb  268435456(%rcx,%r14,8), %zmm1

// CHECK: vpopcntb  -536870912(%rcx,%r14,8), %zmm1
// CHECK: encoding: [0x62,0xb2,0x7d,0x48,0x54,0x8c,0xf1,0x00,0x00,0x00,0xe0]
          vpopcntb  -536870912(%rcx,%r14,8), %zmm1

// CHECK: vpopcntb  -536870910(%rcx,%r14,8), %zmm1
// CHECK: encoding: [0x62,0xb2,0x7d,0x48,0x54,0x8c,0xf1,0x02,0x00,0x00,0xe0]
          vpopcntb  -536870910(%rcx,%r14,8), %zmm1

// CHECK: vpopcntw  (%rcx), %zmm1
// CHECK: encoding: [0x62,0xf2,0xfd,0x48,0x54,0x09]
          vpopcntw  (%rcx), %zmm1

// CHECK: vpopcntw  -256(%rsp), %zmm1
// CHECK: encoding: [0x62,0xf2,0xfd,0x48,0x54,0x4c,0x24,0xfc]
          vpopcntw  -256(%rsp), %zmm1

// CHECK: vpopcntw  256(%rsp), %zmm1
// CHECK: encoding: [0x62,0xf2,0xfd,0x48,0x54,0x4c,0x24,0x04]
          vpopcntw  256(%rsp), %zmm1

// CHECK: vpopcntw  268435456(%rcx,%r14,8), %zmm1
// CHECK: encoding: [0x62,0xb2,0xfd,0x48,0x54,0x8c,0xf1,0x00,0x00,0x00,0x10]
          vpopcntw  268435456(%rcx,%r14,8), %zmm1

// CHECK: vpopcntw  -536870912(%rcx,%r14,8), %zmm1
// CHECK: encoding: [0x62,0xb2,0xfd,0x48,0x54,0x8c,0xf1,0x00,0x00,0x00,0xe0]
          vpopcntw  -536870912(%rcx,%r14,8), %zmm1

// CHECK: vpopcntw  -536870910(%rcx,%r14,8), %zmm1
// CHECK: encoding: [0x62,0xb2,0xfd,0x48,0x54,0x8c,0xf1,0x02,0x00,0x00,0xe0]
          vpopcntw  -536870910(%rcx,%r14,8), %zmm1

// CHECK: vpopcntb  (%rcx), %zmm21 {%k2}
// CHECK: encoding: [0x62,0xe2,0x7d,0x4a,0x54,0x29]
          vpopcntb  (%rcx), %zmm21 {%k2}

// CHECK: vpopcntb  -256(%rsp), %zmm21 {%k2}
// CHECK: encoding: [0x62,0xe2,0x7d,0x4a,0x54,0x6c,0x24,0xfc]
          vpopcntb  -256(%rsp), %zmm21 {%k2}

// CHECK: vpopcntb  256(%rsp), %zmm21 {%k2}
// CHECK: encoding: [0x62,0xe2,0x7d,0x4a,0x54,0x6c,0x24,0x04]
          vpopcntb  256(%rsp), %zmm21 {%k2}

// CHECK: vpopcntb  268435456(%rcx,%r14,8), %zmm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x7d,0x4a,0x54,0xac,0xf1,0x00,0x00,0x00,0x10]
          vpopcntb  268435456(%rcx,%r14,8), %zmm21 {%k2}

// CHECK: vpopcntb  -536870912(%rcx,%r14,8), %zmm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x7d,0x4a,0x54,0xac,0xf1,0x00,0x00,0x00,0xe0]
          vpopcntb  -536870912(%rcx,%r14,8), %zmm21 {%k2}

// CHECK: vpopcntb  -536870910(%rcx,%r14,8), %zmm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x7d,0x4a,0x54,0xac,0xf1,0x02,0x00,0x00,0xe0]
          vpopcntb  -536870910(%rcx,%r14,8), %zmm21 {%k2}

// CHECK: vpopcntw  (%rcx), %zmm21 {%k2}
// CHECK: encoding: [0x62,0xe2,0xfd,0x4a,0x54,0x29]
          vpopcntw  (%rcx), %zmm21 {%k2}

// CHECK: vpopcntw  -256(%rsp), %zmm21 {%k2}
// CHECK: encoding: [0x62,0xe2,0xfd,0x4a,0x54,0x6c,0x24,0xfc]
          vpopcntw  -256(%rsp), %zmm21 {%k2}

// CHECK: vpopcntw  256(%rsp), %zmm21 {%k2}
// CHECK: encoding: [0x62,0xe2,0xfd,0x4a,0x54,0x6c,0x24,0x04]
          vpopcntw  256(%rsp), %zmm21 {%k2}

// CHECK: vpopcntw  268435456(%rcx,%r14,8), %zmm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0xfd,0x4a,0x54,0xac,0xf1,0x00,0x00,0x00,0x10]
          vpopcntw  268435456(%rcx,%r14,8), %zmm21 {%k2}

// CHECK: vpopcntw  -536870912(%rcx,%r14,8), %zmm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0xfd,0x4a,0x54,0xac,0xf1,0x00,0x00,0x00,0xe0]
          vpopcntw  -536870912(%rcx,%r14,8), %zmm21 {%k2}

// CHECK: vpopcntw  -536870910(%rcx,%r14,8), %zmm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0xfd,0x4a,0x54,0xac,0xf1,0x02,0x00,0x00,0xe0]
          vpopcntw  -536870910(%rcx,%r14,8), %zmm21 {%k2}

// CHECK: vpshufbitqmb %zmm2, %zmm23, %k1
// CHECK: encoding: [0x62,0xf2,0x45,0x40,0x8f,0xca]
          vpshufbitqmb %zmm2, %zmm23, %k1

// CHECK: vpshufbitqmb %zmm2, %zmm23, %k1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x45,0x42,0x8f,0xca]
          vpshufbitqmb %zmm2, %zmm23, %k1 {%k2}

// CHECK: vpshufbitqmb  (%rcx), %zmm23, %k1
// CHECK: encoding: [0x62,0xf2,0x45,0x40,0x8f,0x09]
          vpshufbitqmb  (%rcx), %zmm23, %k1

// CHECK: vpshufbitqmb  -256(%rsp), %zmm23, %k1
// CHECK: encoding: [0x62,0xf2,0x45,0x40,0x8f,0x4c,0x24,0xfc]
          vpshufbitqmb  -256(%rsp), %zmm23, %k1

// CHECK: vpshufbitqmb  256(%rsp), %zmm23, %k1
// CHECK: encoding: [0x62,0xf2,0x45,0x40,0x8f,0x4c,0x24,0x04]
          vpshufbitqmb  256(%rsp), %zmm23, %k1

// CHECK: vpshufbitqmb  268435456(%rcx,%r14,8), %zmm23, %k1
// CHECK: encoding: [0x62,0xb2,0x45,0x40,0x8f,0x8c,0xf1,0x00,0x00,0x00,0x10]
          vpshufbitqmb  268435456(%rcx,%r14,8), %zmm23, %k1

// CHECK: vpshufbitqmb  -536870912(%rcx,%r14,8), %zmm23, %k1
// CHECK: encoding: [0x62,0xb2,0x45,0x40,0x8f,0x8c,0xf1,0x00,0x00,0x00,0xe0]
          vpshufbitqmb  -536870912(%rcx,%r14,8), %zmm23, %k1

// CHECK: vpshufbitqmb  -536870910(%rcx,%r14,8), %zmm23, %k1
// CHECK: encoding: [0x62,0xb2,0x45,0x40,0x8f,0x8c,0xf1,0x02,0x00,0x00,0xe0]
          vpshufbitqmb  -536870910(%rcx,%r14,8), %zmm23, %k1

// CHECK: vpshufbitqmb  (%rcx), %zmm23, %k1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x45,0x42,0x8f,0x09]
          vpshufbitqmb  (%rcx), %zmm23, %k1 {%k2}

// CHECK: vpshufbitqmb  -256(%rsp), %zmm23, %k1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x45,0x42,0x8f,0x4c,0x24,0xfc]
          vpshufbitqmb  -256(%rsp), %zmm23, %k1 {%k2}

// CHECK: vpshufbitqmb  256(%rsp), %zmm23, %k1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x45,0x42,0x8f,0x4c,0x24,0x04]
          vpshufbitqmb  256(%rsp), %zmm23, %k1 {%k2}

// CHECK: vpshufbitqmb  268435456(%rcx,%r14,8), %zmm23, %k1 {%k2}
// CHECK: encoding: [0x62,0xb2,0x45,0x42,0x8f,0x8c,0xf1,0x00,0x00,0x00,0x10]
          vpshufbitqmb  268435456(%rcx,%r14,8), %zmm23, %k1 {%k2}

// CHECK: vpshufbitqmb  -536870912(%rcx,%r14,8), %zmm23, %k1 {%k2}
// CHECK: encoding: [0x62,0xb2,0x45,0x42,0x8f,0x8c,0xf1,0x00,0x00,0x00,0xe0]
          vpshufbitqmb  -536870912(%rcx,%r14,8), %zmm23, %k1 {%k2}

// CHECK: vpshufbitqmb  -536870910(%rcx,%r14,8), %zmm23, %k1 {%k2}
// CHECK: encoding: [0x62,0xb2,0x45,0x42,0x8f,0x8c,0xf1,0x02,0x00,0x00,0xe0]
          vpshufbitqmb  -536870910(%rcx,%r14,8), %zmm23, %k1 {%k2}

