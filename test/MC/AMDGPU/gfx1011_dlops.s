// RUN: llvm-mc -arch=amdgcn -mcpu=gfx1011 -show-encoding %s | FileCheck --check-prefix=GFX10 %s
// RUN: llvm-mc -arch=amdgcn -mcpu=gfx1012 -show-encoding %s | FileCheck --check-prefix=GFX10 %s

v_dot2_f32_f16 v0, v1, v2, v3
// GFX10: encoding: [0x00,0x40,0x13,0xcc,0x01,0x05,0x0e,0x1c]

v_dot2_i32_i16 v0, v1, v2, v3
// GFX10: encoding: [0x00,0x40,0x14,0xcc,0x01,0x05,0x0e,0x1c]

v_dot2_u32_u16 v0, v1, v2, v3
// GFX10: encoding: [0x00,0x40,0x15,0xcc,0x01,0x05,0x0e,0x1c]

v_dot4_i32_i8 v0, v1, v2, v3
// GFX10: encoding: [0x00,0x40,0x16,0xcc,0x01,0x05,0x0e,0x1c]

v_dot4_u32_u8 v0, v1, v2, v3
// GFX10: encoding: [0x00,0x40,0x17,0xcc,0x01,0x05,0x0e,0x1c]

v_dot8_i32_i4 v0, v1, v2, v3
// GFX10: encoding: [0x00,0x40,0x18,0xcc,0x01,0x05,0x0e,0x1c]

v_dot8_u32_u4 v0, v1, v2, v3
// GFX10: encoding: [0x00,0x40,0x19,0xcc,0x01,0x05,0x0e,0x1c]

v_dot2c_f32_f16 v5, v1, v2
// GFX10: encoding: [0x01,0x05,0x0a,0x04]

v_dot2c_f32_f16 v5, v1, v2 quad_perm:[0,1,2,3] row_mask:0x0 bank_mask:0x0
// GFX10: encoding: [0xfa,0x04,0x0a,0x04,0x01,0xe4,0x00,0x00]

v_dot2c_f32_f16 v5, v1, v2 quad_perm:[0,1,2,3] row_mask:0x0 bank_mask:0x0 fi:1
// GFX10: encoding: [0xfa,0x04,0x0a,0x04,0x01,0xe4,0x04,0x00]

v_dot2c_f32_f16 v5, v1, v2 dpp8:[7,6,5,4,3,2,1,0]
// GFX10: encoding: [0xe9,0x04,0x0a,0x04,0x01,0x77,0x39,0x05]

v_dot2c_f32_f16 v5, v1, v2 dpp8:[7,6,5,4,3,2,1,0] fi:1
// GFX10: encoding: [0xea,0x04,0x0a,0x04,0x01,0x77,0x39,0x05]

v_dot4c_i32_i8 v5, v1, v2
// GFX10: encoding: [0x01,0x05,0x0a,0x1a]

v_dot4c_i32_i8 v5, v1, v2 quad_perm:[0,1,2,3] row_mask:0x0 bank_mask:0x0
// GFX10: encoding: [0xfa,0x04,0x0a,0x1a,0x01,0xe4,0x00,0x00]

v_dot4c_i32_i8 v5, v1, v2 quad_perm:[0,1,2,3] row_mask:0x0 bank_mask:0x0 fi:1
// GFX10: encoding: [0xfa,0x04,0x0a,0x1a,0x01,0xe4,0x04,0x00]

v_dot4c_i32_i8 v5, v1, v2 dpp8:[7,6,5,4,3,2,1,0]
// GFX10: encoding: [0xe9,0x04,0x0a,0x1a,0x01,0x77,0x39,0x05]

v_dot4c_i32_i8 v5, v1, v2 dpp8:[7,6,5,4,3,2,1,0] fi:1
// GFX10: encoding: [0xea,0x04,0x0a,0x1a,0x01,0x77,0x39,0x05]
