# RUN: llvm-mc %s -arch=mips -mcpu=mips32r2 -mattr=+msa -show-encoding | FileCheck %s
#
# RUN: llvm-mc %s -arch=mips -mcpu=mips32r2 -mattr=+msa -filetype=obj -o - | \
# RUN: llvm-objdump -d -arch=mips -mattr=+msa - | \
# RUN: FileCheck %s -check-prefix=CHECKOBJDUMP
#
# CHECK:        insve.b $w25[3], $w9[0]         # encoding: [0x79,0x43,0x4e,0x59]
# CHECK:        insve.h $w24[2], $w2[0]         # encoding: [0x79,0x62,0x16,0x19]
# CHECK:        insve.w $w0[2], $w13[0]         # encoding: [0x79,0x72,0x68,0x19]
# CHECK:        insve.d $w3[0], $w18[0]         # encoding: [0x79,0x78,0x90,0xd9]

# CHECKOBJDUMP:        insve.b $w25[3], $w9[0]
# CHECKOBJDUMP:        insve.h $w24[2], $w2[0]
# CHECKOBJDUMP:        insve.w $w0[2], $w13[0]
# CHECKOBJDUMP:        insve.d $w3[0], $w18[0]

                insve.b $w25[3], $w9[0]
                insve.h $w24[2], $w2[0]
                insve.w $w0[2], $w13[0]
                insve.d $w3[0], $w18[0]
