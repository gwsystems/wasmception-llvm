# Instructions that are valid
#
# RUN: llvm-mc %s -triple=mips-unknown-linux -show-encoding -mcpu=mips32r6 | FileCheck %s

        .set noat
        # FIXME: Add the instructions carried forward from older ISA's
        addiupc $4, 100          # CHECK: addiupc $4, 100     # encoding: [0xec,0x80,0x00,0x19]
        align   $4, $2, $3, 2    # CHECK: align $4, $2, $3, 2 # encoding: [0x7c,0x43,0x22,0xa0]
        aluipc  $3, 56           # CHECK: aluipc $3, 56       # encoding: [0xec,0x7f,0x00,0x38]
        aui     $3,$2,-23        # CHECK: aui $3, $2, -23     # encoding: [0x3c,0x62,0xff,0xe9]
        auipc   $3, -1           # CHECK: auipc $3, -1        # encoding: [0xec,0x7e,0xff,0xff]
        bitswap $4, $2           # CHECK: bitswap $4, $2      # encoding: [0x7c,0x02,0x20,0x20]
        div     $2,$3,$4         # CHECK: div $2, $3, $4   # encoding: [0x00,0x64,0x10,0x9a]
        divu    $2,$3,$4         # CHECK: divu $2, $3, $4  # encoding: [0x00,0x64,0x10,0x9b]
        mod     $2,$3,$4         # CHECK: mod $2, $3, $4   # encoding: [0x00,0x64,0x10,0xda]
        modu    $2,$3,$4         # CHECK: modu $2, $3, $4  # encoding: [0x00,0x64,0x10,0xdb]
#        mul     $2,$3,$4         # CHECK-TODO: mul $2, $3, $4   # encoding: [0x00,0x64,0x10,0x98]
        muh     $2,$3,$4         # CHECK: muh $2, $3, $4   # encoding: [0x00,0x64,0x10,0xd8]
        mulu    $2,$3,$4         # CHECK: mulu $2, $3, $4  # encoding: [0x00,0x64,0x10,0x99]
        muhu    $2,$3,$4         # CHECK: muhu $2, $3, $4  # encoding: [0x00,0x64,0x10,0xd9]
        sel.d   $f0,$f1,$f2      # CHECK: sel.d $f0, $f1, $f2 # encoding: [0x46,0x22,0x08,0x10]
        sel.s   $f0,$f1,$f2      # CHECK: sel.s $f0, $f1, $f2 # encoding: [0x46,0x02,0x08,0x10]
        max.s   $f0, $f2, $f4    # CHECK: max.s $f0, $f2, $f4 # encoding: [0x46,0x04,0x10,0x1d]
        max.d   $f0, $f2, $f4    # CHECK: max.d $f0, $f2, $f4 # encoding: [0x46,0x24,0x10,0x1d]
        min.s   $f0, $f2, $f4    # CHECK: min.s $f0, $f2, $f4 # encoding: [0x46,0x04,0x10,0x1c]
        min.d   $f0, $f2, $f4    # CHECK: min.d $f0, $f2, $f4 # encoding: [0x46,0x24,0x10,0x1c]
        maxa.s  $f0, $f2, $f4    # CHECK: maxa.s $f0, $f2, $f4 # encoding: [0x46,0x04,0x10,0x1f]
        maxa.d  $f0, $f2, $f4    # CHECK: maxa.d $f0, $f2, $f4 # encoding: [0x46,0x24,0x10,0x1f]
        mina.s  $f0, $f2, $f4    # CHECK: mina.s $f0, $f2, $f4 # encoding: [0x46,0x04,0x10,0x1e]
        mina.d  $f0, $f2, $f4    # CHECK: mina.d $f0, $f2, $f4 # encoding: [0x46,0x24,0x10,0x1e]
        seleqz.s $f0, $f2, $f4   # CHECK: seleqz.s $f0, $f2, $f4 # encoding: [0x46,0x04,0x10,0x14]
        seleqz.d $f0, $f2, $f4   # CHECK: seleqz.d $f0, $f2, $f4 # encoding: [0x46,0x24,0x10,0x14]
        selnez.s $f0, $f2, $f4   # CHECK: selnez.s $f0, $f2, $f4 # encoding: [0x46,0x04,0x10,0x17]
        selnez.d $f0, $f2, $f4   # CHECK: selnez.d $f0, $f2, $f4 # encoding: [0x46,0x24,0x10,0x17]
