// RUN: llvm-mc -triple x86_64-unknown-unknown -mcpu=knl -mattr=+avx512vnni,+avx512vl --show-encoding < %s | FileCheck %s

// CHECK: vpdpbusd %xmm3, %xmm2, %xmm1
// CHECK: encoding: [0x62,0xf2,0x6d,0x08,0x50,0xcb]
          vpdpbusd %xmm3, %xmm2, %xmm1

// CHECK: vpdpbusds %xmm3, %xmm2, %xmm1
// CHECK: encoding: [0x62,0xf2,0x6d,0x08,0x51,0xcb]
          vpdpbusds %xmm3, %xmm2, %xmm1

// CHECK: vpdpwssd %xmm3, %xmm2, %xmm1
// CHECK: encoding: [0x62,0xf2,0x6d,0x08,0x52,0xcb]
          vpdpwssd %xmm3, %xmm2, %xmm1

// CHECK: vpdpwssds %xmm3, %xmm2, %xmm1
// CHECK: encoding: [0x62,0xf2,0x6d,0x08,0x53,0xcb]
          vpdpwssds %xmm3, %xmm2, %xmm1

// CHECK: vpdpbusd %xmm23, %xmm22, %xmm21
// CHECK: encoding: [0x62,0xa2,0x4d,0x00,0x50,0xef]
          vpdpbusd %xmm23, %xmm22, %xmm21

// CHECK: vpdpbusds %xmm23, %xmm22, %xmm21
// CHECK: encoding: [0x62,0xa2,0x4d,0x00,0x51,0xef]
          vpdpbusds %xmm23, %xmm22, %xmm21

// CHECK: vpdpwssd %xmm23, %xmm22, %xmm21
// CHECK: encoding: [0x62,0xa2,0x4d,0x00,0x52,0xef]
          vpdpwssd %xmm23, %xmm22, %xmm21

// CHECK: vpdpwssds %xmm23, %xmm22, %xmm21
// CHECK: encoding: [0x62,0xa2,0x4d,0x00,0x53,0xef]
          vpdpwssds %xmm23, %xmm22, %xmm21

// CHECK: vpdpbusd %xmm3, %xmm2, %xmm1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x6d,0x0a,0x50,0xcb]
          vpdpbusd %xmm3, %xmm2, %xmm1 {%k2}

// CHECK: vpdpbusds %xmm3, %xmm2, %xmm1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x6d,0x0a,0x51,0xcb]
          vpdpbusds %xmm3, %xmm2, %xmm1 {%k2}

// CHECK: vpdpwssd %xmm3, %xmm2, %xmm1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x6d,0x0a,0x52,0xcb]
          vpdpwssd %xmm3, %xmm2, %xmm1 {%k2}

// CHECK: vpdpwssds %xmm3, %xmm2, %xmm1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x6d,0x0a,0x53,0xcb]
          vpdpwssds %xmm3, %xmm2, %xmm1 {%k2}

// CHECK: vpdpbusd %xmm23, %xmm22, %xmm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x4d,0x02,0x50,0xef]
          vpdpbusd %xmm23, %xmm22, %xmm21 {%k2}

// CHECK: vpdpbusds %xmm23, %xmm22, %xmm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x4d,0x02,0x51,0xef]
          vpdpbusds %xmm23, %xmm22, %xmm21 {%k2}

// CHECK: vpdpwssd %xmm23, %xmm22, %xmm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x4d,0x02,0x52,0xef]
          vpdpwssd %xmm23, %xmm22, %xmm21 {%k2}

// CHECK: vpdpwssds %xmm23, %xmm22, %xmm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x4d,0x02,0x53,0xef]
          vpdpwssds %xmm23, %xmm22, %xmm21 {%k2}

// CHECK: vpdpbusd  (%rcx), %xmm2, %xmm1
// CHECK: encoding: [0x62,0xf2,0x6d,0x08,0x50,0x09]
          vpdpbusd  (%rcx), %xmm2, %xmm1

// CHECK: vpdpbusd  -64(%rsp), %xmm2, %xmm1
// CHECK: encoding: [0x62,0xf2,0x6d,0x08,0x50,0x4c,0x24,0xfc]
          vpdpbusd  -64(%rsp), %xmm2, %xmm1

// CHECK: vpdpbusd  64(%rsp), %xmm2, %xmm1
// CHECK: encoding: [0x62,0xf2,0x6d,0x08,0x50,0x4c,0x24,0x04]
          vpdpbusd  64(%rsp), %xmm2, %xmm1

// CHECK: vpdpbusd  268435456(%rcx,%r14,8), %xmm2, %xmm1
// CHECK: encoding: [0x62,0xb2,0x6d,0x08,0x50,0x8c,0xf1,0x00,0x00,0x00,0x10]
          vpdpbusd  268435456(%rcx,%r14,8), %xmm2, %xmm1

// CHECK: vpdpbusd  -536870912(%rcx,%r14,8), %xmm2, %xmm1
// CHECK: encoding: [0x62,0xb2,0x6d,0x08,0x50,0x8c,0xf1,0x00,0x00,0x00,0xe0]
          vpdpbusd  -536870912(%rcx,%r14,8), %xmm2, %xmm1

// CHECK: vpdpbusd  -536870910(%rcx,%r14,8), %xmm2, %xmm1
// CHECK: encoding: [0x62,0xb2,0x6d,0x08,0x50,0x8c,0xf1,0x02,0x00,0x00,0xe0]
          vpdpbusd  -536870910(%rcx,%r14,8), %xmm2, %xmm1

// CHECK: vpdpbusds  (%rcx), %xmm2, %xmm1
// CHECK: encoding: [0x62,0xf2,0x6d,0x08,0x51,0x09]
          vpdpbusds  (%rcx), %xmm2, %xmm1

// CHECK: vpdpbusds  -64(%rsp), %xmm2, %xmm1
// CHECK: encoding: [0x62,0xf2,0x6d,0x08,0x51,0x4c,0x24,0xfc]
          vpdpbusds  -64(%rsp), %xmm2, %xmm1

// CHECK: vpdpbusds  64(%rsp), %xmm2, %xmm1
// CHECK: encoding: [0x62,0xf2,0x6d,0x08,0x51,0x4c,0x24,0x04]
          vpdpbusds  64(%rsp), %xmm2, %xmm1

// CHECK: vpdpbusds  268435456(%rcx,%r14,8), %xmm2, %xmm1
// CHECK: encoding: [0x62,0xb2,0x6d,0x08,0x51,0x8c,0xf1,0x00,0x00,0x00,0x10]
          vpdpbusds  268435456(%rcx,%r14,8), %xmm2, %xmm1

// CHECK: vpdpbusds  -536870912(%rcx,%r14,8), %xmm2, %xmm1
// CHECK: encoding: [0x62,0xb2,0x6d,0x08,0x51,0x8c,0xf1,0x00,0x00,0x00,0xe0]
          vpdpbusds  -536870912(%rcx,%r14,8), %xmm2, %xmm1

// CHECK: vpdpbusds  -536870910(%rcx,%r14,8), %xmm2, %xmm1
// CHECK: encoding: [0x62,0xb2,0x6d,0x08,0x51,0x8c,0xf1,0x02,0x00,0x00,0xe0]
          vpdpbusds  -536870910(%rcx,%r14,8), %xmm2, %xmm1

// CHECK: vpdpwssd  (%rcx), %xmm2, %xmm1
// CHECK: encoding: [0x62,0xf2,0x6d,0x08,0x52,0x09]
          vpdpwssd  (%rcx), %xmm2, %xmm1

// CHECK: vpdpwssd  -64(%rsp), %xmm2, %xmm1
// CHECK: encoding: [0x62,0xf2,0x6d,0x08,0x52,0x4c,0x24,0xfc]
          vpdpwssd  -64(%rsp), %xmm2, %xmm1

// CHECK: vpdpwssd  64(%rsp), %xmm2, %xmm1
// CHECK: encoding: [0x62,0xf2,0x6d,0x08,0x52,0x4c,0x24,0x04]
          vpdpwssd  64(%rsp), %xmm2, %xmm1

// CHECK: vpdpwssd  268435456(%rcx,%r14,8), %xmm2, %xmm1
// CHECK: encoding: [0x62,0xb2,0x6d,0x08,0x52,0x8c,0xf1,0x00,0x00,0x00,0x10]
          vpdpwssd  268435456(%rcx,%r14,8), %xmm2, %xmm1

// CHECK: vpdpwssd  -536870912(%rcx,%r14,8), %xmm2, %xmm1
// CHECK: encoding: [0x62,0xb2,0x6d,0x08,0x52,0x8c,0xf1,0x00,0x00,0x00,0xe0]
          vpdpwssd  -536870912(%rcx,%r14,8), %xmm2, %xmm1

// CHECK: vpdpwssd  -536870910(%rcx,%r14,8), %xmm2, %xmm1
// CHECK: encoding: [0x62,0xb2,0x6d,0x08,0x52,0x8c,0xf1,0x02,0x00,0x00,0xe0]
          vpdpwssd  -536870910(%rcx,%r14,8), %xmm2, %xmm1

// CHECK: vpdpwssds  (%rcx), %xmm2, %xmm1
// CHECK: encoding: [0x62,0xf2,0x6d,0x08,0x53,0x09]
          vpdpwssds  (%rcx), %xmm2, %xmm1

// CHECK: vpdpwssds  -64(%rsp), %xmm2, %xmm1
// CHECK: encoding: [0x62,0xf2,0x6d,0x08,0x53,0x4c,0x24,0xfc]
          vpdpwssds  -64(%rsp), %xmm2, %xmm1

// CHECK: vpdpwssds  64(%rsp), %xmm2, %xmm1
// CHECK: encoding: [0x62,0xf2,0x6d,0x08,0x53,0x4c,0x24,0x04]
          vpdpwssds  64(%rsp), %xmm2, %xmm1

// CHECK: vpdpwssds  268435456(%rcx,%r14,8), %xmm2, %xmm1
// CHECK: encoding: [0x62,0xb2,0x6d,0x08,0x53,0x8c,0xf1,0x00,0x00,0x00,0x10]
          vpdpwssds  268435456(%rcx,%r14,8), %xmm2, %xmm1

// CHECK: vpdpwssds  -536870912(%rcx,%r14,8), %xmm2, %xmm1
// CHECK: encoding: [0x62,0xb2,0x6d,0x08,0x53,0x8c,0xf1,0x00,0x00,0x00,0xe0]
          vpdpwssds  -536870912(%rcx,%r14,8), %xmm2, %xmm1

// CHECK: vpdpwssds  -536870910(%rcx,%r14,8), %xmm2, %xmm1
// CHECK: encoding: [0x62,0xb2,0x6d,0x08,0x53,0x8c,0xf1,0x02,0x00,0x00,0xe0]
          vpdpwssds  -536870910(%rcx,%r14,8), %xmm2, %xmm1

// CHECK: vpdpbusd  (%rcx), %xmm22, %xmm21
// CHECK: encoding: [0x62,0xe2,0x4d,0x00,0x50,0x29]
          vpdpbusd  (%rcx), %xmm22, %xmm21

// CHECK: vpdpbusd  -64(%rsp), %xmm22, %xmm21
// CHECK: encoding: [0x62,0xe2,0x4d,0x00,0x50,0x6c,0x24,0xfc]
          vpdpbusd  -64(%rsp), %xmm22, %xmm21

// CHECK: vpdpbusd  64(%rsp), %xmm22, %xmm21
// CHECK: encoding: [0x62,0xe2,0x4d,0x00,0x50,0x6c,0x24,0x04]
          vpdpbusd  64(%rsp), %xmm22, %xmm21

// CHECK: vpdpbusd  268435456(%rcx,%r14,8), %xmm22, %xmm21
// CHECK: encoding: [0x62,0xa2,0x4d,0x00,0x50,0xac,0xf1,0x00,0x00,0x00,0x10]
          vpdpbusd  268435456(%rcx,%r14,8), %xmm22, %xmm21

// CHECK: vpdpbusd  -536870912(%rcx,%r14,8), %xmm22, %xmm21
// CHECK: encoding: [0x62,0xa2,0x4d,0x00,0x50,0xac,0xf1,0x00,0x00,0x00,0xe0]
          vpdpbusd  -536870912(%rcx,%r14,8), %xmm22, %xmm21

// CHECK: vpdpbusd  -536870910(%rcx,%r14,8), %xmm22, %xmm21
// CHECK: encoding: [0x62,0xa2,0x4d,0x00,0x50,0xac,0xf1,0x02,0x00,0x00,0xe0]
          vpdpbusd  -536870910(%rcx,%r14,8), %xmm22, %xmm21

// CHECK: vpdpbusds  (%rcx), %xmm22, %xmm21
// CHECK: encoding: [0x62,0xe2,0x4d,0x00,0x51,0x29]
          vpdpbusds  (%rcx), %xmm22, %xmm21

// CHECK: vpdpbusds  -64(%rsp), %xmm22, %xmm21
// CHECK: encoding: [0x62,0xe2,0x4d,0x00,0x51,0x6c,0x24,0xfc]
          vpdpbusds  -64(%rsp), %xmm22, %xmm21

// CHECK: vpdpbusds  64(%rsp), %xmm22, %xmm21
// CHECK: encoding: [0x62,0xe2,0x4d,0x00,0x51,0x6c,0x24,0x04]
          vpdpbusds  64(%rsp), %xmm22, %xmm21

// CHECK: vpdpbusds  268435456(%rcx,%r14,8), %xmm22, %xmm21
// CHECK: encoding: [0x62,0xa2,0x4d,0x00,0x51,0xac,0xf1,0x00,0x00,0x00,0x10]
          vpdpbusds  268435456(%rcx,%r14,8), %xmm22, %xmm21

// CHECK: vpdpbusds  -536870912(%rcx,%r14,8), %xmm22, %xmm21
// CHECK: encoding: [0x62,0xa2,0x4d,0x00,0x51,0xac,0xf1,0x00,0x00,0x00,0xe0]
          vpdpbusds  -536870912(%rcx,%r14,8), %xmm22, %xmm21

// CHECK: vpdpbusds  -536870910(%rcx,%r14,8), %xmm22, %xmm21
// CHECK: encoding: [0x62,0xa2,0x4d,0x00,0x51,0xac,0xf1,0x02,0x00,0x00,0xe0]
          vpdpbusds  -536870910(%rcx,%r14,8), %xmm22, %xmm21

// CHECK: vpdpwssd  (%rcx), %xmm22, %xmm21
// CHECK: encoding: [0x62,0xe2,0x4d,0x00,0x52,0x29]
          vpdpwssd  (%rcx), %xmm22, %xmm21

// CHECK: vpdpwssd  -64(%rsp), %xmm22, %xmm21
// CHECK: encoding: [0x62,0xe2,0x4d,0x00,0x52,0x6c,0x24,0xfc]
          vpdpwssd  -64(%rsp), %xmm22, %xmm21

// CHECK: vpdpwssd  64(%rsp), %xmm22, %xmm21
// CHECK: encoding: [0x62,0xe2,0x4d,0x00,0x52,0x6c,0x24,0x04]
          vpdpwssd  64(%rsp), %xmm22, %xmm21

// CHECK: vpdpwssd  268435456(%rcx,%r14,8), %xmm22, %xmm21
// CHECK: encoding: [0x62,0xa2,0x4d,0x00,0x52,0xac,0xf1,0x00,0x00,0x00,0x10]
          vpdpwssd  268435456(%rcx,%r14,8), %xmm22, %xmm21

// CHECK: vpdpwssd  -536870912(%rcx,%r14,8), %xmm22, %xmm21
// CHECK: encoding: [0x62,0xa2,0x4d,0x00,0x52,0xac,0xf1,0x00,0x00,0x00,0xe0]
          vpdpwssd  -536870912(%rcx,%r14,8), %xmm22, %xmm21

// CHECK: vpdpwssd  -536870910(%rcx,%r14,8), %xmm22, %xmm21
// CHECK: encoding: [0x62,0xa2,0x4d,0x00,0x52,0xac,0xf1,0x02,0x00,0x00,0xe0]
          vpdpwssd  -536870910(%rcx,%r14,8), %xmm22, %xmm21

// CHECK: vpdpwssds  (%rcx), %xmm22, %xmm21
// CHECK: encoding: [0x62,0xe2,0x4d,0x00,0x53,0x29]
          vpdpwssds  (%rcx), %xmm22, %xmm21

// CHECK: vpdpwssds  -64(%rsp), %xmm22, %xmm21
// CHECK: encoding: [0x62,0xe2,0x4d,0x00,0x53,0x6c,0x24,0xfc]
          vpdpwssds  -64(%rsp), %xmm22, %xmm21

// CHECK: vpdpwssds  64(%rsp), %xmm22, %xmm21
// CHECK: encoding: [0x62,0xe2,0x4d,0x00,0x53,0x6c,0x24,0x04]
          vpdpwssds  64(%rsp), %xmm22, %xmm21

// CHECK: vpdpwssds  268435456(%rcx,%r14,8), %xmm22, %xmm21
// CHECK: encoding: [0x62,0xa2,0x4d,0x00,0x53,0xac,0xf1,0x00,0x00,0x00,0x10]
          vpdpwssds  268435456(%rcx,%r14,8), %xmm22, %xmm21

// CHECK: vpdpwssds  -536870912(%rcx,%r14,8), %xmm22, %xmm21
// CHECK: encoding: [0x62,0xa2,0x4d,0x00,0x53,0xac,0xf1,0x00,0x00,0x00,0xe0]
          vpdpwssds  -536870912(%rcx,%r14,8), %xmm22, %xmm21

// CHECK: vpdpwssds  -536870910(%rcx,%r14,8), %xmm22, %xmm21
// CHECK: encoding: [0x62,0xa2,0x4d,0x00,0x53,0xac,0xf1,0x02,0x00,0x00,0xe0]
          vpdpwssds  -536870910(%rcx,%r14,8), %xmm22, %xmm21

// CHECK: vpdpbusd  (%rcx), %xmm2, %xmm1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x6d,0x0a,0x50,0x09]
          vpdpbusd  (%rcx), %xmm2, %xmm1 {%k2}

// CHECK: vpdpbusd  -64(%rsp), %xmm2, %xmm1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x6d,0x0a,0x50,0x4c,0x24,0xfc]
          vpdpbusd  -64(%rsp), %xmm2, %xmm1 {%k2}

// CHECK: vpdpbusd  64(%rsp), %xmm2, %xmm1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x6d,0x0a,0x50,0x4c,0x24,0x04]
          vpdpbusd  64(%rsp), %xmm2, %xmm1 {%k2}

// CHECK: vpdpbusd  268435456(%rcx,%r14,8), %xmm2, %xmm1 {%k2}
// CHECK: encoding: [0x62,0xb2,0x6d,0x0a,0x50,0x8c,0xf1,0x00,0x00,0x00,0x10]
          vpdpbusd  268435456(%rcx,%r14,8), %xmm2, %xmm1 {%k2}

// CHECK: vpdpbusd  -536870912(%rcx,%r14,8), %xmm2, %xmm1 {%k2}
// CHECK: encoding: [0x62,0xb2,0x6d,0x0a,0x50,0x8c,0xf1,0x00,0x00,0x00,0xe0]
          vpdpbusd  -536870912(%rcx,%r14,8), %xmm2, %xmm1 {%k2}

// CHECK: vpdpbusd  -536870910(%rcx,%r14,8), %xmm2, %xmm1 {%k2}
// CHECK: encoding: [0x62,0xb2,0x6d,0x0a,0x50,0x8c,0xf1,0x02,0x00,0x00,0xe0]
          vpdpbusd  -536870910(%rcx,%r14,8), %xmm2, %xmm1 {%k2}

// CHECK: vpdpbusds  (%rcx), %xmm2, %xmm1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x6d,0x0a,0x51,0x09]
          vpdpbusds  (%rcx), %xmm2, %xmm1 {%k2}

// CHECK: vpdpbusds  -64(%rsp), %xmm2, %xmm1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x6d,0x0a,0x51,0x4c,0x24,0xfc]
          vpdpbusds  -64(%rsp), %xmm2, %xmm1 {%k2}

// CHECK: vpdpbusds  64(%rsp), %xmm2, %xmm1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x6d,0x0a,0x51,0x4c,0x24,0x04]
          vpdpbusds  64(%rsp), %xmm2, %xmm1 {%k2}

// CHECK: vpdpbusds  268435456(%rcx,%r14,8), %xmm2, %xmm1 {%k2}
// CHECK: encoding: [0x62,0xb2,0x6d,0x0a,0x51,0x8c,0xf1,0x00,0x00,0x00,0x10]
          vpdpbusds  268435456(%rcx,%r14,8), %xmm2, %xmm1 {%k2}

// CHECK: vpdpbusds  -536870912(%rcx,%r14,8), %xmm2, %xmm1 {%k2}
// CHECK: encoding: [0x62,0xb2,0x6d,0x0a,0x51,0x8c,0xf1,0x00,0x00,0x00,0xe0]
          vpdpbusds  -536870912(%rcx,%r14,8), %xmm2, %xmm1 {%k2}

// CHECK: vpdpbusds  -536870910(%rcx,%r14,8), %xmm2, %xmm1 {%k2}
// CHECK: encoding: [0x62,0xb2,0x6d,0x0a,0x51,0x8c,0xf1,0x02,0x00,0x00,0xe0]
          vpdpbusds  -536870910(%rcx,%r14,8), %xmm2, %xmm1 {%k2}

// CHECK: vpdpwssd  (%rcx), %xmm2, %xmm1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x6d,0x0a,0x52,0x09]
          vpdpwssd  (%rcx), %xmm2, %xmm1 {%k2}

// CHECK: vpdpwssd  -64(%rsp), %xmm2, %xmm1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x6d,0x0a,0x52,0x4c,0x24,0xfc]
          vpdpwssd  -64(%rsp), %xmm2, %xmm1 {%k2}

// CHECK: vpdpwssd  64(%rsp), %xmm2, %xmm1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x6d,0x0a,0x52,0x4c,0x24,0x04]
          vpdpwssd  64(%rsp), %xmm2, %xmm1 {%k2}

// CHECK: vpdpwssd  268435456(%rcx,%r14,8), %xmm2, %xmm1 {%k2}
// CHECK: encoding: [0x62,0xb2,0x6d,0x0a,0x52,0x8c,0xf1,0x00,0x00,0x00,0x10]
          vpdpwssd  268435456(%rcx,%r14,8), %xmm2, %xmm1 {%k2}

// CHECK: vpdpwssd  -536870912(%rcx,%r14,8), %xmm2, %xmm1 {%k2}
// CHECK: encoding: [0x62,0xb2,0x6d,0x0a,0x52,0x8c,0xf1,0x00,0x00,0x00,0xe0]
          vpdpwssd  -536870912(%rcx,%r14,8), %xmm2, %xmm1 {%k2}

// CHECK: vpdpwssd  -536870910(%rcx,%r14,8), %xmm2, %xmm1 {%k2}
// CHECK: encoding: [0x62,0xb2,0x6d,0x0a,0x52,0x8c,0xf1,0x02,0x00,0x00,0xe0]
          vpdpwssd  -536870910(%rcx,%r14,8), %xmm2, %xmm1 {%k2}

// CHECK: vpdpwssds  (%rcx), %xmm2, %xmm1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x6d,0x0a,0x53,0x09]
          vpdpwssds  (%rcx), %xmm2, %xmm1 {%k2}

// CHECK: vpdpwssds  -64(%rsp), %xmm2, %xmm1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x6d,0x0a,0x53,0x4c,0x24,0xfc]
          vpdpwssds  -64(%rsp), %xmm2, %xmm1 {%k2}

// CHECK: vpdpwssds  64(%rsp), %xmm2, %xmm1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x6d,0x0a,0x53,0x4c,0x24,0x04]
          vpdpwssds  64(%rsp), %xmm2, %xmm1 {%k2}

// CHECK: vpdpwssds  268435456(%rcx,%r14,8), %xmm2, %xmm1 {%k2}
// CHECK: encoding: [0x62,0xb2,0x6d,0x0a,0x53,0x8c,0xf1,0x00,0x00,0x00,0x10]
          vpdpwssds  268435456(%rcx,%r14,8), %xmm2, %xmm1 {%k2}

// CHECK: vpdpwssds  -536870912(%rcx,%r14,8), %xmm2, %xmm1 {%k2}
// CHECK: encoding: [0x62,0xb2,0x6d,0x0a,0x53,0x8c,0xf1,0x00,0x00,0x00,0xe0]
          vpdpwssds  -536870912(%rcx,%r14,8), %xmm2, %xmm1 {%k2}

// CHECK: vpdpwssds  -536870910(%rcx,%r14,8), %xmm2, %xmm1 {%k2}
// CHECK: encoding: [0x62,0xb2,0x6d,0x0a,0x53,0x8c,0xf1,0x02,0x00,0x00,0xe0]
          vpdpwssds  -536870910(%rcx,%r14,8), %xmm2, %xmm1 {%k2}

// CHECK: vpdpbusd  (%rcx), %xmm22, %xmm21 {%k2}
// CHECK: encoding: [0x62,0xe2,0x4d,0x02,0x50,0x29]
          vpdpbusd  (%rcx), %xmm22, %xmm21 {%k2}

// CHECK: vpdpbusd  -64(%rsp), %xmm22, %xmm21 {%k2}
// CHECK: encoding: [0x62,0xe2,0x4d,0x02,0x50,0x6c,0x24,0xfc]
          vpdpbusd  -64(%rsp), %xmm22, %xmm21 {%k2}

// CHECK: vpdpbusd  64(%rsp), %xmm22, %xmm21 {%k2}
// CHECK: encoding: [0x62,0xe2,0x4d,0x02,0x50,0x6c,0x24,0x04]
          vpdpbusd  64(%rsp), %xmm22, %xmm21 {%k2}

// CHECK: vpdpbusd  268435456(%rcx,%r14,8), %xmm22, %xmm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x4d,0x02,0x50,0xac,0xf1,0x00,0x00,0x00,0x10]
          vpdpbusd  268435456(%rcx,%r14,8), %xmm22, %xmm21 {%k2}

// CHECK: vpdpbusd  -536870912(%rcx,%r14,8), %xmm22, %xmm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x4d,0x02,0x50,0xac,0xf1,0x00,0x00,0x00,0xe0]
          vpdpbusd  -536870912(%rcx,%r14,8), %xmm22, %xmm21 {%k2}

// CHECK: vpdpbusd  -536870910(%rcx,%r14,8), %xmm22, %xmm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x4d,0x02,0x50,0xac,0xf1,0x02,0x00,0x00,0xe0]
          vpdpbusd  -536870910(%rcx,%r14,8), %xmm22, %xmm21 {%k2}

// CHECK: vpdpbusds  (%rcx), %xmm22, %xmm21 {%k2}
// CHECK: encoding: [0x62,0xe2,0x4d,0x02,0x51,0x29]
          vpdpbusds  (%rcx), %xmm22, %xmm21 {%k2}

// CHECK: vpdpbusds  -64(%rsp), %xmm22, %xmm21 {%k2}
// CHECK: encoding: [0x62,0xe2,0x4d,0x02,0x51,0x6c,0x24,0xfc]
          vpdpbusds  -64(%rsp), %xmm22, %xmm21 {%k2}

// CHECK: vpdpbusds  64(%rsp), %xmm22, %xmm21 {%k2}
// CHECK: encoding: [0x62,0xe2,0x4d,0x02,0x51,0x6c,0x24,0x04]
          vpdpbusds  64(%rsp), %xmm22, %xmm21 {%k2}

// CHECK: vpdpbusds  268435456(%rcx,%r14,8), %xmm22, %xmm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x4d,0x02,0x51,0xac,0xf1,0x00,0x00,0x00,0x10]
          vpdpbusds  268435456(%rcx,%r14,8), %xmm22, %xmm21 {%k2}

// CHECK: vpdpbusds  -536870912(%rcx,%r14,8), %xmm22, %xmm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x4d,0x02,0x51,0xac,0xf1,0x00,0x00,0x00,0xe0]
          vpdpbusds  -536870912(%rcx,%r14,8), %xmm22, %xmm21 {%k2}

// CHECK: vpdpbusds  -536870910(%rcx,%r14,8), %xmm22, %xmm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x4d,0x02,0x51,0xac,0xf1,0x02,0x00,0x00,0xe0]
          vpdpbusds  -536870910(%rcx,%r14,8), %xmm22, %xmm21 {%k2}

// CHECK: vpdpwssd  (%rcx), %xmm22, %xmm21 {%k2}
// CHECK: encoding: [0x62,0xe2,0x4d,0x02,0x52,0x29]
          vpdpwssd  (%rcx), %xmm22, %xmm21 {%k2}

// CHECK: vpdpwssd  -64(%rsp), %xmm22, %xmm21 {%k2}
// CHECK: encoding: [0x62,0xe2,0x4d,0x02,0x52,0x6c,0x24,0xfc]
          vpdpwssd  -64(%rsp), %xmm22, %xmm21 {%k2}

// CHECK: vpdpwssd  64(%rsp), %xmm22, %xmm21 {%k2}
// CHECK: encoding: [0x62,0xe2,0x4d,0x02,0x52,0x6c,0x24,0x04]
          vpdpwssd  64(%rsp), %xmm22, %xmm21 {%k2}

// CHECK: vpdpwssd  268435456(%rcx,%r14,8), %xmm22, %xmm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x4d,0x02,0x52,0xac,0xf1,0x00,0x00,0x00,0x10]
          vpdpwssd  268435456(%rcx,%r14,8), %xmm22, %xmm21 {%k2}

// CHECK: vpdpwssd  -536870912(%rcx,%r14,8), %xmm22, %xmm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x4d,0x02,0x52,0xac,0xf1,0x00,0x00,0x00,0xe0]
          vpdpwssd  -536870912(%rcx,%r14,8), %xmm22, %xmm21 {%k2}

// CHECK: vpdpwssd  -536870910(%rcx,%r14,8), %xmm22, %xmm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x4d,0x02,0x52,0xac,0xf1,0x02,0x00,0x00,0xe0]
          vpdpwssd  -536870910(%rcx,%r14,8), %xmm22, %xmm21 {%k2}

// CHECK: vpdpwssds  (%rcx), %xmm22, %xmm21 {%k2}
// CHECK: encoding: [0x62,0xe2,0x4d,0x02,0x53,0x29]
          vpdpwssds  (%rcx), %xmm22, %xmm21 {%k2}

// CHECK: vpdpwssds  -64(%rsp), %xmm22, %xmm21 {%k2}
// CHECK: encoding: [0x62,0xe2,0x4d,0x02,0x53,0x6c,0x24,0xfc]
          vpdpwssds  -64(%rsp), %xmm22, %xmm21 {%k2}

// CHECK: vpdpwssds  64(%rsp), %xmm22, %xmm21 {%k2}
// CHECK: encoding: [0x62,0xe2,0x4d,0x02,0x53,0x6c,0x24,0x04]
          vpdpwssds  64(%rsp), %xmm22, %xmm21 {%k2}

// CHECK: vpdpwssds  268435456(%rcx,%r14,8), %xmm22, %xmm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x4d,0x02,0x53,0xac,0xf1,0x00,0x00,0x00,0x10]
          vpdpwssds  268435456(%rcx,%r14,8), %xmm22, %xmm21 {%k2}

// CHECK: vpdpwssds  -536870912(%rcx,%r14,8), %xmm22, %xmm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x4d,0x02,0x53,0xac,0xf1,0x00,0x00,0x00,0xe0]
          vpdpwssds  -536870912(%rcx,%r14,8), %xmm22, %xmm21 {%k2}

// CHECK: vpdpwssds  -536870910(%rcx,%r14,8), %xmm22, %xmm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x4d,0x02,0x53,0xac,0xf1,0x02,0x00,0x00,0xe0]
          vpdpwssds  -536870910(%rcx,%r14,8), %xmm22, %xmm21 {%k2}

// CHECK: vpdpbusd %ymm3, %ymm2, %ymm1
// CHECK: encoding: [0x62,0xf2,0x6d,0x28,0x50,0xcb]
          vpdpbusd %ymm3, %ymm2, %ymm1

// CHECK: vpdpbusds %ymm3, %ymm2, %ymm1
// CHECK: encoding: [0x62,0xf2,0x6d,0x28,0x51,0xcb]
          vpdpbusds %ymm3, %ymm2, %ymm1

// CHECK: vpdpwssd %ymm3, %ymm2, %ymm1
// CHECK: encoding: [0x62,0xf2,0x6d,0x28,0x52,0xcb]
          vpdpwssd %ymm3, %ymm2, %ymm1

// CHECK: vpdpwssds %ymm3, %ymm2, %ymm1
// CHECK: encoding: [0x62,0xf2,0x6d,0x28,0x53,0xcb]
          vpdpwssds %ymm3, %ymm2, %ymm1

// CHECK: vpdpbusd %ymm23, %ymm22, %ymm21
// CHECK: encoding: [0x62,0xa2,0x4d,0x20,0x50,0xef]
          vpdpbusd %ymm23, %ymm22, %ymm21

// CHECK: vpdpbusds %ymm23, %ymm22, %ymm21
// CHECK: encoding: [0x62,0xa2,0x4d,0x20,0x51,0xef]
          vpdpbusds %ymm23, %ymm22, %ymm21

// CHECK: vpdpwssd %ymm23, %ymm22, %ymm21
// CHECK: encoding: [0x62,0xa2,0x4d,0x20,0x52,0xef]
          vpdpwssd %ymm23, %ymm22, %ymm21

// CHECK: vpdpwssds %ymm23, %ymm22, %ymm21
// CHECK: encoding: [0x62,0xa2,0x4d,0x20,0x53,0xef]
          vpdpwssds %ymm23, %ymm22, %ymm21

// CHECK: vpdpbusd %ymm3, %ymm2, %ymm1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x6d,0x2a,0x50,0xcb]
          vpdpbusd %ymm3, %ymm2, %ymm1 {%k2}

// CHECK: vpdpbusds %ymm3, %ymm2, %ymm1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x6d,0x2a,0x51,0xcb]
          vpdpbusds %ymm3, %ymm2, %ymm1 {%k2}

// CHECK: vpdpwssd %ymm3, %ymm2, %ymm1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x6d,0x2a,0x52,0xcb]
          vpdpwssd %ymm3, %ymm2, %ymm1 {%k2}

// CHECK: vpdpwssds %ymm3, %ymm2, %ymm1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x6d,0x2a,0x53,0xcb]
          vpdpwssds %ymm3, %ymm2, %ymm1 {%k2}

// CHECK: vpdpbusd %ymm23, %ymm22, %ymm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x4d,0x22,0x50,0xef]
          vpdpbusd %ymm23, %ymm22, %ymm21 {%k2}

// CHECK: vpdpbusds %ymm23, %ymm22, %ymm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x4d,0x22,0x51,0xef]
          vpdpbusds %ymm23, %ymm22, %ymm21 {%k2}

// CHECK: vpdpwssd %ymm23, %ymm22, %ymm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x4d,0x22,0x52,0xef]
          vpdpwssd %ymm23, %ymm22, %ymm21 {%k2}

// CHECK: vpdpwssds %ymm23, %ymm22, %ymm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x4d,0x22,0x53,0xef]
          vpdpwssds %ymm23, %ymm22, %ymm21 {%k2}

// CHECK: vpdpbusd  (%rcx), %ymm2, %ymm1
// CHECK: encoding: [0x62,0xf2,0x6d,0x28,0x50,0x09]
          vpdpbusd  (%rcx), %ymm2, %ymm1

// CHECK: vpdpbusd  -128(%rsp), %ymm2, %ymm1
// CHECK: encoding: [0x62,0xf2,0x6d,0x28,0x50,0x4c,0x24,0xfc]
          vpdpbusd  -128(%rsp), %ymm2, %ymm1

// CHECK: vpdpbusd  128(%rsp), %ymm2, %ymm1
// CHECK: encoding: [0x62,0xf2,0x6d,0x28,0x50,0x4c,0x24,0x04]
          vpdpbusd  128(%rsp), %ymm2, %ymm1

// CHECK: vpdpbusd  268435456(%rcx,%r14,8), %ymm2, %ymm1
// CHECK: encoding: [0x62,0xb2,0x6d,0x28,0x50,0x8c,0xf1,0x00,0x00,0x00,0x10]
          vpdpbusd  268435456(%rcx,%r14,8), %ymm2, %ymm1

// CHECK: vpdpbusd  -536870912(%rcx,%r14,8), %ymm2, %ymm1
// CHECK: encoding: [0x62,0xb2,0x6d,0x28,0x50,0x8c,0xf1,0x00,0x00,0x00,0xe0]
          vpdpbusd  -536870912(%rcx,%r14,8), %ymm2, %ymm1

// CHECK: vpdpbusd  -536870910(%rcx,%r14,8), %ymm2, %ymm1
// CHECK: encoding: [0x62,0xb2,0x6d,0x28,0x50,0x8c,0xf1,0x02,0x00,0x00,0xe0]
          vpdpbusd  -536870910(%rcx,%r14,8), %ymm2, %ymm1

// CHECK: vpdpbusds  (%rcx), %ymm2, %ymm1
// CHECK: encoding: [0x62,0xf2,0x6d,0x28,0x51,0x09]
          vpdpbusds  (%rcx), %ymm2, %ymm1

// CHECK: vpdpbusds  -128(%rsp), %ymm2, %ymm1
// CHECK: encoding: [0x62,0xf2,0x6d,0x28,0x51,0x4c,0x24,0xfc]
          vpdpbusds  -128(%rsp), %ymm2, %ymm1

// CHECK: vpdpbusds  128(%rsp), %ymm2, %ymm1
// CHECK: encoding: [0x62,0xf2,0x6d,0x28,0x51,0x4c,0x24,0x04]
          vpdpbusds  128(%rsp), %ymm2, %ymm1

// CHECK: vpdpbusds  268435456(%rcx,%r14,8), %ymm2, %ymm1
// CHECK: encoding: [0x62,0xb2,0x6d,0x28,0x51,0x8c,0xf1,0x00,0x00,0x00,0x10]
          vpdpbusds  268435456(%rcx,%r14,8), %ymm2, %ymm1

// CHECK: vpdpbusds  -536870912(%rcx,%r14,8), %ymm2, %ymm1
// CHECK: encoding: [0x62,0xb2,0x6d,0x28,0x51,0x8c,0xf1,0x00,0x00,0x00,0xe0]
          vpdpbusds  -536870912(%rcx,%r14,8), %ymm2, %ymm1

// CHECK: vpdpbusds  -536870910(%rcx,%r14,8), %ymm2, %ymm1
// CHECK: encoding: [0x62,0xb2,0x6d,0x28,0x51,0x8c,0xf1,0x02,0x00,0x00,0xe0]
          vpdpbusds  -536870910(%rcx,%r14,8), %ymm2, %ymm1

// CHECK: vpdpwssd  (%rcx), %ymm2, %ymm1
// CHECK: encoding: [0x62,0xf2,0x6d,0x28,0x52,0x09]
          vpdpwssd  (%rcx), %ymm2, %ymm1

// CHECK: vpdpwssd  -128(%rsp), %ymm2, %ymm1
// CHECK: encoding: [0x62,0xf2,0x6d,0x28,0x52,0x4c,0x24,0xfc]
          vpdpwssd  -128(%rsp), %ymm2, %ymm1

// CHECK: vpdpwssd  128(%rsp), %ymm2, %ymm1
// CHECK: encoding: [0x62,0xf2,0x6d,0x28,0x52,0x4c,0x24,0x04]
          vpdpwssd  128(%rsp), %ymm2, %ymm1

// CHECK: vpdpwssd  268435456(%rcx,%r14,8), %ymm2, %ymm1
// CHECK: encoding: [0x62,0xb2,0x6d,0x28,0x52,0x8c,0xf1,0x00,0x00,0x00,0x10]
          vpdpwssd  268435456(%rcx,%r14,8), %ymm2, %ymm1

// CHECK: vpdpwssd  -536870912(%rcx,%r14,8), %ymm2, %ymm1
// CHECK: encoding: [0x62,0xb2,0x6d,0x28,0x52,0x8c,0xf1,0x00,0x00,0x00,0xe0]
          vpdpwssd  -536870912(%rcx,%r14,8), %ymm2, %ymm1

// CHECK: vpdpwssd  -536870910(%rcx,%r14,8), %ymm2, %ymm1
// CHECK: encoding: [0x62,0xb2,0x6d,0x28,0x52,0x8c,0xf1,0x02,0x00,0x00,0xe0]
          vpdpwssd  -536870910(%rcx,%r14,8), %ymm2, %ymm1

// CHECK: vpdpwssds  (%rcx), %ymm2, %ymm1
// CHECK: encoding: [0x62,0xf2,0x6d,0x28,0x53,0x09]
          vpdpwssds  (%rcx), %ymm2, %ymm1

// CHECK: vpdpwssds  -128(%rsp), %ymm2, %ymm1
// CHECK: encoding: [0x62,0xf2,0x6d,0x28,0x53,0x4c,0x24,0xfc]
          vpdpwssds  -128(%rsp), %ymm2, %ymm1

// CHECK: vpdpwssds  128(%rsp), %ymm2, %ymm1
// CHECK: encoding: [0x62,0xf2,0x6d,0x28,0x53,0x4c,0x24,0x04]
          vpdpwssds  128(%rsp), %ymm2, %ymm1

// CHECK: vpdpwssds  268435456(%rcx,%r14,8), %ymm2, %ymm1
// CHECK: encoding: [0x62,0xb2,0x6d,0x28,0x53,0x8c,0xf1,0x00,0x00,0x00,0x10]
          vpdpwssds  268435456(%rcx,%r14,8), %ymm2, %ymm1

// CHECK: vpdpwssds  -536870912(%rcx,%r14,8), %ymm2, %ymm1
// CHECK: encoding: [0x62,0xb2,0x6d,0x28,0x53,0x8c,0xf1,0x00,0x00,0x00,0xe0]
          vpdpwssds  -536870912(%rcx,%r14,8), %ymm2, %ymm1

// CHECK: vpdpwssds  -536870910(%rcx,%r14,8), %ymm2, %ymm1
// CHECK: encoding: [0x62,0xb2,0x6d,0x28,0x53,0x8c,0xf1,0x02,0x00,0x00,0xe0]
          vpdpwssds  -536870910(%rcx,%r14,8), %ymm2, %ymm1

// CHECK: vpdpbusd  (%rcx), %ymm22, %ymm21
// CHECK: encoding: [0x62,0xe2,0x4d,0x20,0x50,0x29]
          vpdpbusd  (%rcx), %ymm22, %ymm21

// CHECK: vpdpbusd  -128(%rsp), %ymm22, %ymm21
// CHECK: encoding: [0x62,0xe2,0x4d,0x20,0x50,0x6c,0x24,0xfc]
          vpdpbusd  -128(%rsp), %ymm22, %ymm21

// CHECK: vpdpbusd  128(%rsp), %ymm22, %ymm21
// CHECK: encoding: [0x62,0xe2,0x4d,0x20,0x50,0x6c,0x24,0x04]
          vpdpbusd  128(%rsp), %ymm22, %ymm21

// CHECK: vpdpbusd  268435456(%rcx,%r14,8), %ymm22, %ymm21
// CHECK: encoding: [0x62,0xa2,0x4d,0x20,0x50,0xac,0xf1,0x00,0x00,0x00,0x10]
          vpdpbusd  268435456(%rcx,%r14,8), %ymm22, %ymm21

// CHECK: vpdpbusd  -536870912(%rcx,%r14,8), %ymm22, %ymm21
// CHECK: encoding: [0x62,0xa2,0x4d,0x20,0x50,0xac,0xf1,0x00,0x00,0x00,0xe0]
          vpdpbusd  -536870912(%rcx,%r14,8), %ymm22, %ymm21

// CHECK: vpdpbusd  -536870910(%rcx,%r14,8), %ymm22, %ymm21
// CHECK: encoding: [0x62,0xa2,0x4d,0x20,0x50,0xac,0xf1,0x02,0x00,0x00,0xe0]
          vpdpbusd  -536870910(%rcx,%r14,8), %ymm22, %ymm21

// CHECK: vpdpbusds  (%rcx), %ymm22, %ymm21
// CHECK: encoding: [0x62,0xe2,0x4d,0x20,0x51,0x29]
          vpdpbusds  (%rcx), %ymm22, %ymm21

// CHECK: vpdpbusds  -128(%rsp), %ymm22, %ymm21
// CHECK: encoding: [0x62,0xe2,0x4d,0x20,0x51,0x6c,0x24,0xfc]
          vpdpbusds  -128(%rsp), %ymm22, %ymm21

// CHECK: vpdpbusds  128(%rsp), %ymm22, %ymm21
// CHECK: encoding: [0x62,0xe2,0x4d,0x20,0x51,0x6c,0x24,0x04]
          vpdpbusds  128(%rsp), %ymm22, %ymm21

// CHECK: vpdpbusds  268435456(%rcx,%r14,8), %ymm22, %ymm21
// CHECK: encoding: [0x62,0xa2,0x4d,0x20,0x51,0xac,0xf1,0x00,0x00,0x00,0x10]
          vpdpbusds  268435456(%rcx,%r14,8), %ymm22, %ymm21

// CHECK: vpdpbusds  -536870912(%rcx,%r14,8), %ymm22, %ymm21
// CHECK: encoding: [0x62,0xa2,0x4d,0x20,0x51,0xac,0xf1,0x00,0x00,0x00,0xe0]
          vpdpbusds  -536870912(%rcx,%r14,8), %ymm22, %ymm21

// CHECK: vpdpbusds  -536870910(%rcx,%r14,8), %ymm22, %ymm21
// CHECK: encoding: [0x62,0xa2,0x4d,0x20,0x51,0xac,0xf1,0x02,0x00,0x00,0xe0]
          vpdpbusds  -536870910(%rcx,%r14,8), %ymm22, %ymm21

// CHECK: vpdpwssd  (%rcx), %ymm22, %ymm21
// CHECK: encoding: [0x62,0xe2,0x4d,0x20,0x52,0x29]
          vpdpwssd  (%rcx), %ymm22, %ymm21

// CHECK: vpdpwssd  -128(%rsp), %ymm22, %ymm21
// CHECK: encoding: [0x62,0xe2,0x4d,0x20,0x52,0x6c,0x24,0xfc]
          vpdpwssd  -128(%rsp), %ymm22, %ymm21

// CHECK: vpdpwssd  128(%rsp), %ymm22, %ymm21
// CHECK: encoding: [0x62,0xe2,0x4d,0x20,0x52,0x6c,0x24,0x04]
          vpdpwssd  128(%rsp), %ymm22, %ymm21

// CHECK: vpdpwssd  268435456(%rcx,%r14,8), %ymm22, %ymm21
// CHECK: encoding: [0x62,0xa2,0x4d,0x20,0x52,0xac,0xf1,0x00,0x00,0x00,0x10]
          vpdpwssd  268435456(%rcx,%r14,8), %ymm22, %ymm21

// CHECK: vpdpwssd  -536870912(%rcx,%r14,8), %ymm22, %ymm21
// CHECK: encoding: [0x62,0xa2,0x4d,0x20,0x52,0xac,0xf1,0x00,0x00,0x00,0xe0]
          vpdpwssd  -536870912(%rcx,%r14,8), %ymm22, %ymm21

// CHECK: vpdpwssd  -536870910(%rcx,%r14,8), %ymm22, %ymm21
// CHECK: encoding: [0x62,0xa2,0x4d,0x20,0x52,0xac,0xf1,0x02,0x00,0x00,0xe0]
          vpdpwssd  -536870910(%rcx,%r14,8), %ymm22, %ymm21

// CHECK: vpdpwssds  (%rcx), %ymm22, %ymm21
// CHECK: encoding: [0x62,0xe2,0x4d,0x20,0x53,0x29]
          vpdpwssds  (%rcx), %ymm22, %ymm21

// CHECK: vpdpwssds  -128(%rsp), %ymm22, %ymm21
// CHECK: encoding: [0x62,0xe2,0x4d,0x20,0x53,0x6c,0x24,0xfc]
          vpdpwssds  -128(%rsp), %ymm22, %ymm21

// CHECK: vpdpwssds  128(%rsp), %ymm22, %ymm21
// CHECK: encoding: [0x62,0xe2,0x4d,0x20,0x53,0x6c,0x24,0x04]
          vpdpwssds  128(%rsp), %ymm22, %ymm21

// CHECK: vpdpwssds  268435456(%rcx,%r14,8), %ymm22, %ymm21
// CHECK: encoding: [0x62,0xa2,0x4d,0x20,0x53,0xac,0xf1,0x00,0x00,0x00,0x10]
          vpdpwssds  268435456(%rcx,%r14,8), %ymm22, %ymm21

// CHECK: vpdpwssds  -536870912(%rcx,%r14,8), %ymm22, %ymm21
// CHECK: encoding: [0x62,0xa2,0x4d,0x20,0x53,0xac,0xf1,0x00,0x00,0x00,0xe0]
          vpdpwssds  -536870912(%rcx,%r14,8), %ymm22, %ymm21

// CHECK: vpdpwssds  -536870910(%rcx,%r14,8), %ymm22, %ymm21
// CHECK: encoding: [0x62,0xa2,0x4d,0x20,0x53,0xac,0xf1,0x02,0x00,0x00,0xe0]
          vpdpwssds  -536870910(%rcx,%r14,8), %ymm22, %ymm21

// CHECK: vpdpbusd  (%rcx), %ymm2, %ymm1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x6d,0x2a,0x50,0x09]
          vpdpbusd  (%rcx), %ymm2, %ymm1 {%k2}

// CHECK: vpdpbusd  -128(%rsp), %ymm2, %ymm1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x6d,0x2a,0x50,0x4c,0x24,0xfc]
          vpdpbusd  -128(%rsp), %ymm2, %ymm1 {%k2}

// CHECK: vpdpbusd  128(%rsp), %ymm2, %ymm1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x6d,0x2a,0x50,0x4c,0x24,0x04]
          vpdpbusd  128(%rsp), %ymm2, %ymm1 {%k2}

// CHECK: vpdpbusd  268435456(%rcx,%r14,8), %ymm2, %ymm1 {%k2}
// CHECK: encoding: [0x62,0xb2,0x6d,0x2a,0x50,0x8c,0xf1,0x00,0x00,0x00,0x10]
          vpdpbusd  268435456(%rcx,%r14,8), %ymm2, %ymm1 {%k2}

// CHECK: vpdpbusd  -536870912(%rcx,%r14,8), %ymm2, %ymm1 {%k2}
// CHECK: encoding: [0x62,0xb2,0x6d,0x2a,0x50,0x8c,0xf1,0x00,0x00,0x00,0xe0]
          vpdpbusd  -536870912(%rcx,%r14,8), %ymm2, %ymm1 {%k2}

// CHECK: vpdpbusd  -536870910(%rcx,%r14,8), %ymm2, %ymm1 {%k2}
// CHECK: encoding: [0x62,0xb2,0x6d,0x2a,0x50,0x8c,0xf1,0x02,0x00,0x00,0xe0]
          vpdpbusd  -536870910(%rcx,%r14,8), %ymm2, %ymm1 {%k2}

// CHECK: vpdpbusds  (%rcx), %ymm2, %ymm1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x6d,0x2a,0x51,0x09]
          vpdpbusds  (%rcx), %ymm2, %ymm1 {%k2}

// CHECK: vpdpbusds  -128(%rsp), %ymm2, %ymm1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x6d,0x2a,0x51,0x4c,0x24,0xfc]
          vpdpbusds  -128(%rsp), %ymm2, %ymm1 {%k2}

// CHECK: vpdpbusds  128(%rsp), %ymm2, %ymm1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x6d,0x2a,0x51,0x4c,0x24,0x04]
          vpdpbusds  128(%rsp), %ymm2, %ymm1 {%k2}

// CHECK: vpdpbusds  268435456(%rcx,%r14,8), %ymm2, %ymm1 {%k2}
// CHECK: encoding: [0x62,0xb2,0x6d,0x2a,0x51,0x8c,0xf1,0x00,0x00,0x00,0x10]
          vpdpbusds  268435456(%rcx,%r14,8), %ymm2, %ymm1 {%k2}

// CHECK: vpdpbusds  -536870912(%rcx,%r14,8), %ymm2, %ymm1 {%k2}
// CHECK: encoding: [0x62,0xb2,0x6d,0x2a,0x51,0x8c,0xf1,0x00,0x00,0x00,0xe0]
          vpdpbusds  -536870912(%rcx,%r14,8), %ymm2, %ymm1 {%k2}

// CHECK: vpdpbusds  -536870910(%rcx,%r14,8), %ymm2, %ymm1 {%k2}
// CHECK: encoding: [0x62,0xb2,0x6d,0x2a,0x51,0x8c,0xf1,0x02,0x00,0x00,0xe0]
          vpdpbusds  -536870910(%rcx,%r14,8), %ymm2, %ymm1 {%k2}

// CHECK: vpdpwssd  (%rcx), %ymm2, %ymm1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x6d,0x2a,0x52,0x09]
          vpdpwssd  (%rcx), %ymm2, %ymm1 {%k2}

// CHECK: vpdpwssd  -128(%rsp), %ymm2, %ymm1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x6d,0x2a,0x52,0x4c,0x24,0xfc]
          vpdpwssd  -128(%rsp), %ymm2, %ymm1 {%k2}

// CHECK: vpdpwssd  128(%rsp), %ymm2, %ymm1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x6d,0x2a,0x52,0x4c,0x24,0x04]
          vpdpwssd  128(%rsp), %ymm2, %ymm1 {%k2}

// CHECK: vpdpwssd  268435456(%rcx,%r14,8), %ymm2, %ymm1 {%k2}
// CHECK: encoding: [0x62,0xb2,0x6d,0x2a,0x52,0x8c,0xf1,0x00,0x00,0x00,0x10]
          vpdpwssd  268435456(%rcx,%r14,8), %ymm2, %ymm1 {%k2}

// CHECK: vpdpwssd  -536870912(%rcx,%r14,8), %ymm2, %ymm1 {%k2}
// CHECK: encoding: [0x62,0xb2,0x6d,0x2a,0x52,0x8c,0xf1,0x00,0x00,0x00,0xe0]
          vpdpwssd  -536870912(%rcx,%r14,8), %ymm2, %ymm1 {%k2}

// CHECK: vpdpwssd  -536870910(%rcx,%r14,8), %ymm2, %ymm1 {%k2}
// CHECK: encoding: [0x62,0xb2,0x6d,0x2a,0x52,0x8c,0xf1,0x02,0x00,0x00,0xe0]
          vpdpwssd  -536870910(%rcx,%r14,8), %ymm2, %ymm1 {%k2}

// CHECK: vpdpwssds  (%rcx), %ymm2, %ymm1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x6d,0x2a,0x53,0x09]
          vpdpwssds  (%rcx), %ymm2, %ymm1 {%k2}

// CHECK: vpdpwssds  -128(%rsp), %ymm2, %ymm1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x6d,0x2a,0x53,0x4c,0x24,0xfc]
          vpdpwssds  -128(%rsp), %ymm2, %ymm1 {%k2}

// CHECK: vpdpwssds  128(%rsp), %ymm2, %ymm1 {%k2}
// CHECK: encoding: [0x62,0xf2,0x6d,0x2a,0x53,0x4c,0x24,0x04]
          vpdpwssds  128(%rsp), %ymm2, %ymm1 {%k2}

// CHECK: vpdpwssds  268435456(%rcx,%r14,8), %ymm2, %ymm1 {%k2}
// CHECK: encoding: [0x62,0xb2,0x6d,0x2a,0x53,0x8c,0xf1,0x00,0x00,0x00,0x10]
          vpdpwssds  268435456(%rcx,%r14,8), %ymm2, %ymm1 {%k2}

// CHECK: vpdpwssds  -536870912(%rcx,%r14,8), %ymm2, %ymm1 {%k2}
// CHECK: encoding: [0x62,0xb2,0x6d,0x2a,0x53,0x8c,0xf1,0x00,0x00,0x00,0xe0]
          vpdpwssds  -536870912(%rcx,%r14,8), %ymm2, %ymm1 {%k2}

// CHECK: vpdpwssds  -536870910(%rcx,%r14,8), %ymm2, %ymm1 {%k2}
// CHECK: encoding: [0x62,0xb2,0x6d,0x2a,0x53,0x8c,0xf1,0x02,0x00,0x00,0xe0]
          vpdpwssds  -536870910(%rcx,%r14,8), %ymm2, %ymm1 {%k2}

// CHECK: vpdpbusd  (%rcx), %ymm22, %ymm21 {%k2}
// CHECK: encoding: [0x62,0xe2,0x4d,0x22,0x50,0x29]
          vpdpbusd  (%rcx), %ymm22, %ymm21 {%k2}

// CHECK: vpdpbusd  -128(%rsp), %ymm22, %ymm21 {%k2}
// CHECK: encoding: [0x62,0xe2,0x4d,0x22,0x50,0x6c,0x24,0xfc]
          vpdpbusd  -128(%rsp), %ymm22, %ymm21 {%k2}

// CHECK: vpdpbusd  128(%rsp), %ymm22, %ymm21 {%k2}
// CHECK: encoding: [0x62,0xe2,0x4d,0x22,0x50,0x6c,0x24,0x04]
          vpdpbusd  128(%rsp), %ymm22, %ymm21 {%k2}

// CHECK: vpdpbusd  268435456(%rcx,%r14,8), %ymm22, %ymm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x4d,0x22,0x50,0xac,0xf1,0x00,0x00,0x00,0x10]
          vpdpbusd  268435456(%rcx,%r14,8), %ymm22, %ymm21 {%k2}

// CHECK: vpdpbusd  -536870912(%rcx,%r14,8), %ymm22, %ymm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x4d,0x22,0x50,0xac,0xf1,0x00,0x00,0x00,0xe0]
          vpdpbusd  -536870912(%rcx,%r14,8), %ymm22, %ymm21 {%k2}

// CHECK: vpdpbusd  -536870910(%rcx,%r14,8), %ymm22, %ymm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x4d,0x22,0x50,0xac,0xf1,0x02,0x00,0x00,0xe0]
          vpdpbusd  -536870910(%rcx,%r14,8), %ymm22, %ymm21 {%k2}

// CHECK: vpdpbusds  (%rcx), %ymm22, %ymm21 {%k2}
// CHECK: encoding: [0x62,0xe2,0x4d,0x22,0x51,0x29]
          vpdpbusds  (%rcx), %ymm22, %ymm21 {%k2}

// CHECK: vpdpbusds  -128(%rsp), %ymm22, %ymm21 {%k2}
// CHECK: encoding: [0x62,0xe2,0x4d,0x22,0x51,0x6c,0x24,0xfc]
          vpdpbusds  -128(%rsp), %ymm22, %ymm21 {%k2}

// CHECK: vpdpbusds  128(%rsp), %ymm22, %ymm21 {%k2}
// CHECK: encoding: [0x62,0xe2,0x4d,0x22,0x51,0x6c,0x24,0x04]
          vpdpbusds  128(%rsp), %ymm22, %ymm21 {%k2}

// CHECK: vpdpbusds  268435456(%rcx,%r14,8), %ymm22, %ymm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x4d,0x22,0x51,0xac,0xf1,0x00,0x00,0x00,0x10]
          vpdpbusds  268435456(%rcx,%r14,8), %ymm22, %ymm21 {%k2}

// CHECK: vpdpbusds  -536870912(%rcx,%r14,8), %ymm22, %ymm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x4d,0x22,0x51,0xac,0xf1,0x00,0x00,0x00,0xe0]
          vpdpbusds  -536870912(%rcx,%r14,8), %ymm22, %ymm21 {%k2}

// CHECK: vpdpbusds  -536870910(%rcx,%r14,8), %ymm22, %ymm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x4d,0x22,0x51,0xac,0xf1,0x02,0x00,0x00,0xe0]
          vpdpbusds  -536870910(%rcx,%r14,8), %ymm22, %ymm21 {%k2}

// CHECK: vpdpwssd  (%rcx), %ymm22, %ymm21 {%k2}
// CHECK: encoding: [0x62,0xe2,0x4d,0x22,0x52,0x29]
          vpdpwssd  (%rcx), %ymm22, %ymm21 {%k2}

// CHECK: vpdpwssd  -128(%rsp), %ymm22, %ymm21 {%k2}
// CHECK: encoding: [0x62,0xe2,0x4d,0x22,0x52,0x6c,0x24,0xfc]
          vpdpwssd  -128(%rsp), %ymm22, %ymm21 {%k2}

// CHECK: vpdpwssd  128(%rsp), %ymm22, %ymm21 {%k2}
// CHECK: encoding: [0x62,0xe2,0x4d,0x22,0x52,0x6c,0x24,0x04]
          vpdpwssd  128(%rsp), %ymm22, %ymm21 {%k2}

// CHECK: vpdpwssd  268435456(%rcx,%r14,8), %ymm22, %ymm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x4d,0x22,0x52,0xac,0xf1,0x00,0x00,0x00,0x10]
          vpdpwssd  268435456(%rcx,%r14,8), %ymm22, %ymm21 {%k2}

// CHECK: vpdpwssd  -536870912(%rcx,%r14,8), %ymm22, %ymm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x4d,0x22,0x52,0xac,0xf1,0x00,0x00,0x00,0xe0]
          vpdpwssd  -536870912(%rcx,%r14,8), %ymm22, %ymm21 {%k2}

// CHECK: vpdpwssd  -536870910(%rcx,%r14,8), %ymm22, %ymm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x4d,0x22,0x52,0xac,0xf1,0x02,0x00,0x00,0xe0]
          vpdpwssd  -536870910(%rcx,%r14,8), %ymm22, %ymm21 {%k2}

// CHECK: vpdpwssds  (%rcx), %ymm22, %ymm21 {%k2}
// CHECK: encoding: [0x62,0xe2,0x4d,0x22,0x53,0x29]
          vpdpwssds  (%rcx), %ymm22, %ymm21 {%k2}

// CHECK: vpdpwssds  -128(%rsp), %ymm22, %ymm21 {%k2}
// CHECK: encoding: [0x62,0xe2,0x4d,0x22,0x53,0x6c,0x24,0xfc]
          vpdpwssds  -128(%rsp), %ymm22, %ymm21 {%k2}

// CHECK: vpdpwssds  128(%rsp), %ymm22, %ymm21 {%k2}
// CHECK: encoding: [0x62,0xe2,0x4d,0x22,0x53,0x6c,0x24,0x04]
          vpdpwssds  128(%rsp), %ymm22, %ymm21 {%k2}

// CHECK: vpdpwssds  268435456(%rcx,%r14,8), %ymm22, %ymm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x4d,0x22,0x53,0xac,0xf1,0x00,0x00,0x00,0x10]
          vpdpwssds  268435456(%rcx,%r14,8), %ymm22, %ymm21 {%k2}

// CHECK: vpdpwssds  -536870912(%rcx,%r14,8), %ymm22, %ymm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x4d,0x22,0x53,0xac,0xf1,0x00,0x00,0x00,0xe0]
          vpdpwssds  -536870912(%rcx,%r14,8), %ymm22, %ymm21 {%k2}

// CHECK: vpdpwssds  -536870910(%rcx,%r14,8), %ymm22, %ymm21 {%k2}
// CHECK: encoding: [0x62,0xa2,0x4d,0x22,0x53,0xac,0xf1,0x02,0x00,0x00,0xe0]
          vpdpwssds  -536870910(%rcx,%r14,8), %ymm22, %ymm21 {%k2}

