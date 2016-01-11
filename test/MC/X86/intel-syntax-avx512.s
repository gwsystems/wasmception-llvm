// RUN: llvm-mc -triple x86_64-unknown-unknown -x86-asm-syntax=intel -output-asm-variant=1 -mcpu=knl --show-encoding %s | FileCheck %s

// CHECK: vaddps  zmm1 , zmm1, zmmword ptr [rax]
// CHECK: encoding: [0x62,0xf1,0x74,0x48,0x58,0x08]
vaddps zmm1, zmm1, zmmword ptr [rax]

// CHECK: vaddpd  zmm1 , zmm1, zmm2
// CHECK:  encoding: [0x62,0xf1,0xf5,0x48,0x58,0xca]
vaddpd zmm1,zmm1,zmm2

// CHECK: vaddpd  zmm1 {k5}, zmm1, zmm2
// CHECK:  encoding: [0x62,0xf1,0xf5,0x4d,0x58,0xca]
vaddpd zmm1{k5},zmm1,zmm2

// CHECK: vaddpd zmm1 {k5} {z}, zmm1, zmm2
// CHECK:  encoding: [0x62,0xf1,0xf5,0xcd,0x58,0xca]
vaddpd zmm1{k5} {z},zmm1,zmm2

// CHECK: vaddpd zmm1 , zmm1, zmm2, {rn-sae}
// CHECK:  encoding: [0x62,0xf1,0xf5,0x18,0x58,0xca]
vaddpd zmm1,zmm1,zmm2,{rn-sae}

// CHECK: vaddpd zmm1 , zmm1, zmm2, {ru-sae}
// CHECK:  encoding: [0x62,0xf1,0xf5,0x58,0x58,0xca]
vaddpd zmm1,zmm1,zmm2,{ru-sae}

// CHECK:  vaddpd zmm1 , zmm1, zmm2, {rd-sae}
// CHECK:  encoding: [0x62,0xf1,0xf5,0x38,0x58,0xca]
vaddpd zmm1,zmm1,zmm2,{rd-sae}

// CHECK: vaddpd zmm1 , zmm1, zmm2, {rz-sae}
// CHECK:  encoding: [0x62,0xf1,0xf5,0x78,0x58,0xca]
vaddpd zmm1,zmm1,zmm2,{rz-sae}

// CHECK: vcmppd k2 , zmm12, zmm26, 171
// CHECK:  encoding: [0x62,0x91,0x9d,0x48,0xc2,0xd2,0xab]
          vcmppd k2,zmm12,zmm26,0xab

// CHECK: vcmppd k2 {k3}, zmm12, zmm26, 171
// CHECK:  encoding: [0x62,0x91,0x9d,0x4b,0xc2,0xd2,0xab]
          vcmppd k2{k3},zmm12,zmm26,0xab

// CHECK: vcmppd k2 , zmm12, zmm26, {sae}, 171
// CHECK:  encoding: [0x62,0x91,0x9d,0x18,0xc2,0xd2,0xab]
          vcmppd k2,zmm12,zmm26,{sae},0xab

// CHECK: vcmppd k2 , zmm12, zmm26, 123
// CHECK:  encoding: [0x62,0x91,0x9d,0x48,0xc2,0xd2,0x7b]
          vcmppd k2 ,zmm12,zmm26,0x7b

// CHECK: vcmppd k2 , zmm12, zmm26, {sae}, 123
// CHECK:  encoding: [0x62,0x91,0x9d,0x18,0xc2,0xd2,0x7b]
          vcmppd k2,zmm12,zmm26,{sae},0x7b

// CHECK: vcmppd k2 , zmm12, zmmword ptr [rcx], 123
// CHECK:  encoding: [0x62,0xf1,0x9d,0x48,0xc2,0x11,0x7b]
          vcmppd k2,zmm12,zmmword PTR [rcx],0x7b

// CHECK: vcmppd  k2 , zmm12, zmmword ptr [rax + 8*r14 + 291], 123
// CHECK:  encoding: [0x62,0xb1,0x9d,0x48,0xc2,0x94,0xf0,0x23,0x01,0x00,0x00,0x7b]
          vcmppd k2 ,zmm12,zmmword PTR [rax+r14*8+0x123],0x7b

// CHECK: vcmppd  k2 , zmm12, qword ptr [rcx]{1to8}, 123
// CHECK:  encoding: [0x62,0xf1,0x9d,0x58,0xc2,0x11,0x7b]
          vcmppd k2,zmm12,QWORD PTR [rcx]{1to8},0x7b

// CHECK: vcmppd  k2 , zmm12, zmmword ptr [rdx + 8128], 123
// CHECK:  encoding: [0x62,0xf1,0x9d,0x48,0xc2,0x52,0x7f,0x7b]
          vcmppd k2,zmm12,zmmword PTR [rdx+0x1fc0],0x7b

// CHECK: vcmppd  k2 , zmm12, zmmword ptr [rdx + 8192], 123
// CHECK:  encoding: [0x62,0xf1,0x9d,0x48,0xc2,0x92,0x00,0x20,0x00,0x00,0x7b]
          vcmppd k2,zmm12,zmmword PTR [rdx+0x2000],0x7b

// CHECK: vcmppd  k2 , zmm12, zmmword ptr [rdx - 8192], 123
// CHECK:  encoding: [0x62,0xf1,0x9d,0x48,0xc2,0x52,0x80,0x7b]
          vcmppd k2,zmm12,zmmword PTR [rdx-0x2000],0x7b

// CHECK: vcmppd  k2 , zmm12, zmmword ptr [rdx - 8256], 123
// CHECK:  encoding: [0x62,0xf1,0x9d,0x48,0xc2,0x92,0xc0,0xdf,0xff,0xff,0x7b]
          vcmppd k2,zmm12,zmmword PTR [rdx-0x2040],0x7b

// CHECK: vcmppd  k2 , zmm12, qword ptr [rdx + 1016]{1to8}, 123
// CHECK:  encoding: [0x62,0xf1,0x9d,0x58,0xc2,0x52,0x7f,0x7b]
          vcmppd k2,zmm12,QWORD PTR [rdx+0x3f8]{1to8},0x7b

// CHECK: vcmppd  k2 , zmm12, qword ptr [rdx + 1024]{1to8}, 123
// CHECK:  encoding: [0x62,0xf1,0x9d,0x58,0xc2,0x92,0x00,0x04,0x00,0x00,0x7b]
          vcmppd k2,zmm12,QWORD PTR [rdx+0x400]{1to8},0x7b

// CHECK: vcmppd  k2 , zmm12, qword ptr [rdx - 1024]{1to8}, 123
// CHECK:  encoding: [0x62,0xf1,0x9d,0x58,0xc2,0x52,0x80,0x7b]
          vcmppd k2,zmm12,QWORD PTR [rdx-0x400]{1to8},0x7b

// CHECK: vcmppd  k2 , zmm12, qword ptr [rdx - 1032]{1to8}, 123
// CHECK:  encoding: [0x62,0xf1,0x9d,0x58,0xc2,0x92,0xf8,0xfb,0xff,0xff,0x7b]
          vcmppd k2,zmm12,QWORD PTR [rdx-0x408]{1to8},0x7b

// CHECK: vcmpps  k2 , zmm17, zmm22, 171
// CHECK:  encoding: [0x62,0xb1,0x74,0x40,0xc2,0xd6,0xab]
          vcmpps k2,zmm17,zmm22,0xab

// CHECK: vcmpps  k2 {k3}, zmm17, zmm22, 171
// CHECK:  encoding: [0x62,0xb1,0x74,0x43,0xc2,0xd6,0xab]
          vcmpps k2{k3},zmm17,zmm22,0xab

// CHECK: vcmpps  k2 , zmm17, zmm22, {sae}, 171
// CHECK:  encoding: [0x62,0xb1,0x74,0x10,0xc2,0xd6,0xab]
          vcmpps k2,zmm17,zmm22,{sae},0xab

// CHECK: vcmpps  k2 , zmm17, zmm22, 123
// CHECK:  encoding: [0x62,0xb1,0x74,0x40,0xc2,0xd6,0x7b]
          vcmpps k2,zmm17,zmm22,0x7b

// CHECK: vcmpps  k2 , zmm17, zmm22, {sae}, 123
// CHECK:  encoding: [0x62,0xb1,0x74,0x10,0xc2,0xd6,0x7b]
          vcmpps k2,zmm17,zmm22,{sae},0x7b

// CHECK: vcmpps  k2 , zmm17, zmmword ptr [rcx], 123
// CHECK:  encoding: [0x62,0xf1,0x74,0x40,0xc2,0x11,0x7b]
          vcmpps k2,zmm17,zmmword PTR [rcx],0x7b

// CHECK: vcmpps  k2 , zmm17, zmmword ptr [rax + 8*r14 + 291], 123
// CHECK:  encoding: [0x62,0xb1,0x74,0x40,0xc2,0x94,0xf0,0x23,0x01,0x00,0x00,0x7b]
          vcmpps k2,zmm17,zmmword PTR [rax+r14*8+0x123],0x7b

// CHECK: vcmpps  k2 , zmm17, dword ptr [rcx]{1to16}, 123
// CHECK:  encoding: [0x62,0xf1,0x74,0x50,0xc2,0x11,0x7b]
          vcmpps k2,zmm17,DWORD PTR [rcx]{1to16},0x7b

// CHECK: vcmpps  k2 , zmm17, zmmword ptr [rdx + 8128], 123
// CHECK:  encoding: [0x62,0xf1,0x74,0x40,0xc2,0x52,0x7f,0x7b]
          vcmpps k2,zmm17,zmmword PTR [rdx+0x1fc0],0x7b

// CHECK: vcmpps  k2 , zmm17, zmmword ptr [rdx + 8192], 123
// CHECK:  encoding: [0x62,0xf1,0x74,0x40,0xc2,0x92,0x00,0x20,0x00,0x00,0x7b]
          vcmpps k2,zmm17,zmmword PTR [rdx+0x2000],0x7b

// CHECK: vcmpps  k2 , zmm17, zmmword ptr [rdx - 8192], 123
// CHECK:  encoding: [0x62,0xf1,0x74,0x40,0xc2,0x52,0x80,0x7b]
          vcmpps k2,zmm17,zmmword PTR [rdx-0x2000],0x7b

// CHECK: vcmpps  k2 , zmm17, zmmword ptr [rdx - 8256], 123
// CHECK:  encoding: [0x62,0xf1,0x74,0x40,0xc2,0x92,0xc0,0xdf,0xff,0xff,0x7b]
          vcmpps k2,zmm17,zmmword PTR [rdx-0x2040],0x7b

// CHECK: vcmpps  k2 , zmm17, dword ptr [rdx + 508]{1to16}, 123
// CHECK:  encoding: [0x62,0xf1,0x74,0x50,0xc2,0x52,0x7f,0x7b]
          vcmpps k2,zmm17,DWORD PTR [rdx+0x1fc]{1to16},0x7b

// CHECK: vcmpps  k2 , zmm17, dword ptr [rdx + 512]{1to16}, 123
// CHECK:  encoding: [0x62,0xf1,0x74,0x50,0xc2,0x92,0x00,0x02,0x00,0x00,0x7b]
          vcmpps k2,zmm17,DWORD PTR [rdx+0x200]{1to16},0x7b

// CHECK: vcmpps  k2 , zmm17, dword ptr [rdx - 512]{1to16}, 123
// CHECK:  encoding: [0x62,0xf1,0x74,0x50,0xc2,0x52,0x80,0x7b]
          vcmpps k2,zmm17,DWORD PTR [rdx-0x200]{1to16},0x7b

// CHECK: vcmpps  k2 , zmm17, dword ptr [rdx - 516]{1to16}, 123
// CHECK:  encoding: [0x62,0xf1,0x74,0x50,0xc2,0x92,0xfc,0xfd,0xff,0xff,0x7b]
          vcmpps k2,zmm17,DWORD PTR [rdx-0x204]{1to16},0x7b


// CHECK:  vfixupimmss  xmm15 , xmm18, xmm28, 171
// CHECK:  encoding: [0x62,0x13,0x6d,0x00,0x55,0xfc,0xab]
          vfixupimmss xmm15,xmm18,xmm28,0xab

// CHECK:  vfixupimmss  xmm15 {k5}, xmm18, xmm28, 171
// CHECK:  encoding: [0x62,0x13,0x6d,0x05,0x55,0xfc,0xab]
          vfixupimmss xmm15{k5},xmm18,xmm28,0xab

// CHECK:  vfixupimmss  xmm15 {k5} {z}, xmm18, xmm28, 171
// CHECK:  encoding: [0x62,0x13,0x6d,0x85,0x55,0xfc,0xab]
          vfixupimmss xmm15{k5} {z},xmm18,xmm28,0xab

// CHECK:  vfixupimmss  xmm15 , xmm18, xmm28, {sae}, 171
// CHECK:  encoding: [0x62,0x13,0x6d,0x10,0x55,0xfc,0xab]
          vfixupimmss xmm15,xmm18,xmm28,{sae},0xab

// CHECK:  vfixupimmss  xmm15 , xmm18, xmm28, 123
// CHECK:  encoding: [0x62,0x13,0x6d,0x00,0x55,0xfc,0x7b]
          vfixupimmss xmm15,xmm18,xmm28,0x7b

// CHECK:  vfixupimmss  xmm15 , xmm18, xmm28, {sae}, 123
// CHECK:  encoding: [0x62,0x13,0x6d,0x10,0x55,0xfc,0x7b]
          vfixupimmss xmm15,xmm18,xmm28,{sae},0x7b

// CHECK:  vfixupimmss  xmm15 , xmm18, dword ptr [rcx], 123
// CHECK:  encoding: [0x62,0x73,0x6d,0x00,0x55,0x39,0x7b]
          vfixupimmss xmm15,xmm18,DWORD PTR [rcx],0x7b

// CHECK:  vfixupimmss  xmm15 , xmm18, dword ptr [rax + 8*r14 + 291], 123
// CHECK:  encoding: [0x62,0x33,0x6d,0x00,0x55,0xbc,0xf0,0x23,0x01,0x00,0x00,0x7b]
          vfixupimmss xmm15,xmm18,DWORD PTR [rax+r14*8+0x123],0x7b

// CHECK:  vfixupimmss  xmm15 , xmm18, dword ptr [rdx + 508], 123
// CHECK:  encoding: [0x62,0x73,0x6d,0x00,0x55,0x7a,0x7f,0x7b]
          vfixupimmss xmm15,xmm18,DWORD PTR [rdx+0x1fc],0x7b

// CHECK:  vfixupimmss  xmm15 , xmm18, dword ptr [rdx + 512], 123
// CHECK:  encoding: [0x62,0x73,0x6d,0x00,0x55,0xba,0x00,0x02,0x00,0x00,0x7b]
          vfixupimmss xmm15,xmm18,DWORD PTR [rdx+0x200],0x7b

// CHECK:  vfixupimmss  xmm15 , xmm18, dword ptr [rdx - 512], 123
// CHECK:  encoding: [0x62,0x73,0x6d,0x00,0x55,0x7a,0x80,0x7b]
          vfixupimmss xmm15,xmm18,DWORD PTR [rdx-0x200],0x7b

// CHECK:  vfixupimmss  xmm15 , xmm18, dword ptr [rdx - 516], 123
// CHECK:  encoding: [0x62,0x73,0x6d,0x00,0x55,0xba,0xfc,0xfd,0xff,0xff,0x7b]
          vfixupimmss xmm15,xmm18,DWORD PTR [rdx-0x204],0x7b

// CHECK:  vfixupimmsd  xmm13 , xmm26, xmm5, 171
// CHECK:  encoding: [0x62,0x73,0xad,0x00,0x55,0xed,0xab]
          vfixupimmsd xmm13,xmm26,xmm5,0xab

// CHECK:  vfixupimmsd  xmm13 {k6}, xmm26, xmm5, 171
// CHECK:  encoding: [0x62,0x73,0xad,0x06,0x55,0xed,0xab]
          vfixupimmsd xmm13{k6},xmm26,xmm5,0xab

// CHECK:  vfixupimmsd  xmm13 {k6} {z}, xmm26, xmm5, 171
// CHECK:  encoding: [0x62,0x73,0xad,0x86,0x55,0xed,0xab]
          vfixupimmsd xmm13{k6} {z},xmm26,xmm5,0xab

// CHECK:  vfixupimmsd  xmm13 , xmm26, xmm5, {sae}, 171
// CHECK:  encoding: [0x62,0x73,0xad,0x10,0x55,0xed,0xab]
          vfixupimmsd xmm13,xmm26,xmm5,{sae},0xab

// CHECK:  vfixupimmsd  xmm13 , xmm26, xmm5, 123
// CHECK:  encoding: [0x62,0x73,0xad,0x00,0x55,0xed,0x7b]
          vfixupimmsd xmm13,xmm26,xmm5,0x7b

// CHECK:  vfixupimmsd  xmm13 , xmm26, xmm5, {sae}, 123
// CHECK:  encoding: [0x62,0x73,0xad,0x10,0x55,0xed,0x7b]
          vfixupimmsd xmm13,xmm26,xmm5,{sae},0x7b

// CHECK:  vfixupimmsd  xmm13 , xmm26, qword ptr [rcx], 123
// CHECK:  encoding: [0x62,0x73,0xad,0x00,0x55,0x29,0x7b]
          vfixupimmsd xmm13,xmm26,QWORD PTR [rcx],0x7b

// CHECK:  vfixupimmsd  xmm13 , xmm26, qword ptr [rax + 8*r14 + 291], 123
// CHECK:  encoding: [0x62,0x33,0xad,0x00,0x55,0xac,0xf0,0x23,0x01,0x00,0x00,0x7b]
          vfixupimmsd xmm13,xmm26,QWORD PTR [rax+r14*8+0x123],0x7b

// CHECK:  vfixupimmsd  xmm13 , xmm26, qword ptr [rdx + 1016], 123
// CHECK:  encoding: [0x62,0x73,0xad,0x00,0x55,0x6a,0x7f,0x7b]
          vfixupimmsd xmm13,xmm26,QWORD PTR [rdx+0x3f8],0x7b

// CHECK:  vfixupimmsd  xmm13 , xmm26, qword ptr [rdx + 1024], 123
// CHECK:  encoding: [0x62,0x73,0xad,0x00,0x55,0xaa,0x00,0x04,0x00,0x00,0x7b]
          vfixupimmsd xmm13,xmm26,QWORD PTR [rdx+0x400],0x7b

// CHECK:  vfixupimmsd  xmm13 , xmm26, qword ptr [rdx - 1024], 123
// CHECK:  encoding: [0x62,0x73,0xad,0x00,0x55,0x6a,0x80,0x7b]
          vfixupimmsd xmm13,xmm26,QWORD PTR [rdx-0x400],0x7b

// CHECK:  vfixupimmsd  xmm13 , xmm26, qword ptr [rdx - 1032], 123
// CHECK:  encoding: [0x62,0x73,0xad,0x00,0x55,0xaa,0xf8,0xfb,0xff,0xff,0x7b]
          vfixupimmsd xmm13,xmm26,QWORD PTR [rdx-0x408],0x7b

// CHECK:  vcomisd xmm23, qword ptr [rcx]
// CHECK:  encoding: [0x62,0xe1,0xfd,0x08,0x2f,0x39]
          vcomisd xmm23, QWORD PTR [rcx]

// CHECK:  vcomiss xmm16, dword ptr [rcx]
// CHECK:  encoding: [0x62,0xe1,0x7c,0x08,0x2f,0x01]
          vcomiss xmm16, DWORD PTR [rcx]

// CHECK: vmovss dword ptr [rcx] {k2}, xmm13
// CHECK:  encoding: [0x62,0x71,0x7e,0x0a,0x11,0x29]
          vmovss dword ptr [rcx]{k2},xmm13

// CHECK: vmovss dword ptr [rax + 8*r14 + 4660], xmm13
// CHECK:  encoding: [0xc4,0x21,0x7a,0x11,0xac,0xf0,0x34,0x12,0x00,0x00]
          vmovss dword ptr [rax+r14*8+0x1234],xmm13

// CHECK: vmovss dword ptr [rdx + 508], xmm13
// CHECK:  encoding: [0xc5,0x7a,0x11,0xaa,0xfc,0x01,0x00,0x00]
          vmovss dword ptr [rdx+0x1fc],xmm13

// CHECK: vmovss dword ptr [rdx + 512], xmm13
// CHECK:  encoding: [0xc5,0x7a,0x11,0xaa,0x00,0x02,0x00,0x00]
          vmovss dword ptr [rdx+0x200],xmm13

// CHECK: vmovss dword ptr [rdx - 512], xmm13
// CHECK:  encoding: [0xc5,0x7a,0x11,0xaa,0x00,0xfe,0xff,0xff]
          vmovss dword ptr [rdx-0x200],xmm13

// CHECK: vmovss dword ptr [rdx - 516], xmm13
// CHECK:  encoding: [0xc5,0x7a,0x11,0xaa,0xfc,0xfd,0xff,0xff]
          vmovss dword ptr [rdx-0x204],xmm13

// CHECK: vmovss dword ptr [rdx + 508], xmm5
// CHECK:  encoding: [0xc5,0xfa,0x11,0xaa,0xfc,0x01,0x00,0x00]
          vmovss dword ptr [rdx+0x1fc],xmm5

// CHECK: vmovss dword ptr [rdx + 512], xmm5
// CHECK:  encoding: [0xc5,0xfa,0x11,0xaa,0x00,0x02,0x00,0x00]
          vmovss dword ptr [rdx+0x200],xmm5

// CHECK: vmovss dword ptr [rdx - 512], xmm5
// CHECK:  encoding: [0xc5,0xfa,0x11,0xaa,0x00,0xfe,0xff,0xff]
          vmovss dword ptr [rdx-0x200], xmm5

// CHECK: vmovss dword ptr [rdx - 516], xmm5
// CHECK:  encoding: [0xc5,0xfa,0x11,0xaa,0xfc,0xfd,0xff,0xff]
          vmovss dword ptr [rdx-0x204],xmm5

// CHECK: vmovss dword ptr [rcx], xmm13
// CHECK:  encoding: [0xc5,0x7a,0x11,0x29]
          vmovss dword ptr [rcx],xmm13

// CHECK: vmovss xmm2, dword ptr [rcx]
// CHECK:  encoding: [0xc5,0xfa,0x10,0x11]
          vmovss xmm2, dword ptr [rcx]

// CHECK: vmovss xmm2 {k4}, dword ptr [rcx]
// CHECK:  encoding: [0x62,0xf1,0x7e,0x0c,0x10,0x11]
          vmovss xmm2{k4}, dword ptr [rcx]

// CHECK: vmovss xmm2 {k4} {z}, dword ptr [rcx]
// CHECK:  encoding: [0x62,0xf1,0x7e,0x8c,0x10,0x11]
          vmovss xmm2{k4} {z}, dword ptr [rcx]

// CHECK: vmovsd xmm25 , qword ptr [rcx]
// CHECK:  encoding: [0x62,0x61,0xff,0x08,0x10,0x09]
          vmovsd xmm25, qword ptr [rcx]

// CHECK: vmovsd xmm25 {k3}, qword ptr [rcx]
// CHECK:  encoding: [0x62,0x61,0xff,0x0b,0x10,0x09]
          vmovsd xmm25{k3}, qword ptr [rcx]

// CHECK: vmovsd xmm25 {k3} {z}, qword ptr [rcx]
// CHECK:  encoding: [0x62,0x61,0xff,0x8b,0x10,0x09]
          vmovsd xmm25{k3} {z}, qword ptr [rcx]

// CHECK: vmovsd xmm25 , qword ptr [rax + 8*r14 + 291]
// CHECK:  encoding: [0x62,0x21,0xff,0x08,0x10,0x8c,0xf0,0x23,0x01,0x00,0x00]
          vmovsd xmm25, qword ptr [rax+r14*8+0x123]

// CHECK: vmovsd xmm25 , qword ptr [rdx + 1016]
// CHECK:  encoding: [0x62,0x61,0xff,0x08,0x10,0x4a,0x7f]
          vmovsd xmm25, qword ptr [rdx+0x3f8]

// CHECK: vmovsd xmm25 , qword ptr [rdx + 1024]
// CHECK:  encoding: [0x62,0x61,0xff,0x08,0x10,0x8a,0x00,0x04,0x00,0x00]
          vmovsd xmm25, qword ptr [rdx+0x400]

// CHECK: vmovsd xmm25 , qword ptr [rdx - 1024]
// CHECK:  encoding: [0x62,0x61,0xff,0x08,0x10,0x4a,0x80]
          vmovsd xmm25, qword ptr [rdx-0x400]

// CHECK: vmovsd xmm25 , qword ptr [rdx - 1032]
// CHECK:  encoding: [0x62,0x61,0xff,0x08,0x10,0x8a,0xf8,0xfb,0xff,0xff]
          vmovsd xmm25, qword ptr [rdx-0x408]
