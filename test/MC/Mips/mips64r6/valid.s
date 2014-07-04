# Instructions that are valid
#
# Branches have some unusual encoding rules in MIPS32r6 so we need to test:
#   rs == 0
#   rs != 0
#   rt == 0
#   rt != 0
#   rs < rt
#   rs == rt
#   rs > rt
# appropriately for each branch instruction
#
# RUN: llvm-mc %s -triple=mips-unknown-linux -show-encoding -mcpu=mips64r6 2> %t0 | FileCheck %s
# RUN: FileCheck %s -check-prefix=WARNING < %t0

        .set noat
        # FIXME: Add the instructions carried forward from older ISA's
        and     $2,4           # CHECK: andi $2, $2, 4        # encoding: [0x30,0x42,0x00,0x04]
        addiupc $4, 100          # CHECK: addiupc $4, 100     # encoding: [0xec,0x80,0x00,0x19]
        align   $4, $2, $3, 2    # CHECK: align $4, $2, $3, 2 # encoding: [0x7c,0x43,0x22,0xa0]
        aluipc  $3, 56           # CHECK: aluipc $3, 56       # encoding: [0xec,0x7f,0x00,0x38]
        aui     $3,$2,-23        # CHECK: aui $3, $2, -23     # encoding: [0x3c,0x62,0xff,0xe9]
        auipc   $3, -1           # CHECK: auipc $3, -1        # encoding: [0xec,0x7e,0xff,0xff]
        bal     21100            # CHECK: bal 21100           # encoding: [0x04,0x11,0x14,0x9b]
        balc 14572256            # CHECK: balc 14572256       # encoding: [0xe8,0x37,0x96,0xb8]
        bc 14572256              # CHECK: bc 14572256         # encoding: [0xc8,0x37,0x96,0xb8]
        bc1eqz  $f0,4            # CHECK: bc1eqz $f0, 4       # encoding: [0x45,0x20,0x00,0x01]
        bc1eqz  $f31,4           # CHECK: bc1eqz $f31, 4      # encoding: [0x45,0x3f,0x00,0x01]
        bc1nez  $f0,4            # CHECK: bc1nez $f0, 4       # encoding: [0x45,0xa0,0x00,0x01]
        bc1nez  $f31,4           # CHECK: bc1nez $f31, 4      # encoding: [0x45,0xbf,0x00,0x01]
        bc2eqz  $0,8             # CHECK: bc2eqz $0, 8        # encoding: [0x49,0x20,0x00,0x02]
        bc2eqz  $31,8            # CHECK: bc2eqz $31, 8       # encoding: [0x49,0x3f,0x00,0x02]
        bc2nez  $0,8             # CHECK: bc2nez $0, 8        # encoding: [0x49,0xa0,0x00,0x02]
        bc2nez  $31,8            # CHECK: bc2nez $31, 8       # encoding: [0x49,0xbf,0x00,0x02]
        # beqc requires rs < rt && rs != 0 but we also accept when this is not true. See also bovc
        # FIXME: Testcases are in valid-xfail.s at the moment
        beqc $5, $6, 256         # CHECK: beqc $5, $6, 256    # encoding: [0x20,0xa6,0x00,0x40]
        beqzalc $2, 1332         # CHECK: beqzalc $2, 1332    # encoding: [0x20,0x02,0x01,0x4d]
        # bnec requires rs < rt && rs != 0 but we accept when this is not true. See also bnvc
        # FIXME: Testcases are in valid-xfail.s at the moment
        bnec $5, $6, 256         # CHECK: bnec $5, $6, 256    # encoding: [0x60,0xa6,0x00,0x40]
        bnezalc $2, 1332         # CHECK: bnezalc $2, 1332    # encoding: [0x60,0x02,0x01,0x4d]
        beqzc $5, 72256          # CHECK: beqzc $5, 72256     # encoding: [0xd8,0xa0,0x46,0x90]
        bgec $2, $3, 256         # CHECK: bgec $2, $3, 256    # encoding: [0x58,0x43,0x00,0x40]
        bgeuc $2, $3, 256        # CHECK: bgeuc $2, $3, 256   # encoding: [0x18,0x43,0x00,0x40]
        bgezalc $2, 1332         # CHECK: bgezalc $2, 1332    # encoding: [0x18,0x42,0x01,0x4d]
        bnezc $5, 72256          # CHECK: bnezc $5, 72256     # encoding: [0xf8,0xa0,0x46,0x90]
        bltzc $5, 256            # CHECK: bltzc $5, 256       # encoding: [0x5c,0xa5,0x00,0x40]
        bgezc $5, 256            # CHECK: bgezc $5, 256       # encoding: [0x58,0xa5,0x00,0x40]
        bgtzalc $2, 1332         # CHECK: bgtzalc $2, 1332    # encoding: [0x1c,0x02,0x01,0x4d]
        blezc $5, 256            # CHECK: blezc $5, 256       # encoding: [0x58,0x05,0x00,0x40]
        bltzalc $2, 1332         # CHECK: bltzalc $2, 1332    # encoding: [0x1c,0x42,0x01,0x4d]
        bgtzc $5, 256            # CHECK: bgtzc $5, 256       # encoding: [0x5c,0x05,0x00,0x40]
        bitswap $4, $2           # CHECK: bitswap $4, $2      # encoding: [0x7c,0x02,0x20,0x20]
        blezalc $2, 1332         # CHECK: blezalc $2, 1332    # encoding: [0x18,0x02,0x01,0x4d]
        bltc $5, $6, 256         # CHECK: bltc $5, $6, 256    # encoding: [0x5c,0xa6,0x00,0x40]
        bltuc $5, $6, 256        # CHECK: bltuc $5, $6, 256   # encoding: [0x1c,0xa6,0x00,0x40]
        # bnvc requires that rs >= rt but we accept both. See also bnec
        bnvc     $0, $0, 4       # CHECK: bnvc $zero, $zero, 4 # encoding: [0x60,0x00,0x00,0x01]
        bnvc     $2, $0, 4       # CHECK: bnvc $2, $zero, 4    # encoding: [0x60,0x40,0x00,0x01]
        bnvc     $4, $2, 4       # CHECK: bnvc $4, $2, 4      # encoding: [0x60,0x82,0x00,0x01]
        # bovc requires that rs >= rt but we accept both. See also beqc
        bovc     $0, $0, 4       # CHECK: bovc $zero, $zero, 4 # encoding: [0x20,0x00,0x00,0x01]
        bovc     $2, $0, 4       # CHECK: bovc $2, $zero, 4    # encoding: [0x20,0x40,0x00,0x01]
        bovc     $4, $2, 4       # CHECK: bovc $4, $2, 4      # encoding: [0x20,0x82,0x00,0x01]
        cache      1, 8($5)         # CHECK: cache 1, 8($5)         # encoding: [0x7c,0xa1,0x04,0x25]
        cmp.f.s    $f2,$f3,$f4      # CHECK: cmp.f.s $f2, $f3, $f4  # encoding: [0x46,0x84,0x18,0x80]
        cmp.f.d    $f2,$f3,$f4      # CHECK: cmp.f.d $f2, $f3, $f4  # encoding: [0x46,0xa4,0x18,0x80]
        cmp.un.s   $f2,$f3,$f4      # CHECK: cmp.un.s $f2, $f3, $f4  # encoding: [0x46,0x84,0x18,0x81]
        cmp.un.d   $f2,$f3,$f4      # CHECK: cmp.un.d $f2, $f3, $f4  # encoding: [0x46,0xa4,0x18,0x81]
        cmp.eq.s   $f2,$f3,$f4      # CHECK: cmp.eq.s $f2, $f3, $f4  # encoding: [0x46,0x84,0x18,0x82]
        cmp.eq.d   $f2,$f3,$f4      # CHECK: cmp.eq.d $f2, $f3, $f4  # encoding: [0x46,0xa4,0x18,0x82]
        cmp.ueq.s  $f2,$f3,$f4      # CHECK: cmp.ueq.s $f2, $f3, $f4  # encoding: [0x46,0x84,0x18,0x83]
        cmp.ueq.d  $f2,$f3,$f4      # CHECK: cmp.ueq.d $f2, $f3, $f4  # encoding: [0x46,0xa4,0x18,0x83]
        cmp.olt.s  $f2,$f3,$f4      # CHECK: cmp.olt.s $f2, $f3, $f4  # encoding: [0x46,0x84,0x18,0x84]
        cmp.olt.d  $f2,$f3,$f4      # CHECK: cmp.olt.d $f2, $f3, $f4  # encoding: [0x46,0xa4,0x18,0x84]
        cmp.ult.s  $f2,$f3,$f4      # CHECK: cmp.ult.s $f2, $f3, $f4  # encoding: [0x46,0x84,0x18,0x85]
        cmp.ult.d  $f2,$f3,$f4      # CHECK: cmp.ult.d $f2, $f3, $f4  # encoding: [0x46,0xa4,0x18,0x85]
        cmp.ole.s  $f2,$f3,$f4      # CHECK: cmp.ole.s $f2, $f3, $f4  # encoding: [0x46,0x84,0x18,0x86]
        cmp.ole.d  $f2,$f3,$f4      # CHECK: cmp.ole.d $f2, $f3, $f4  # encoding: [0x46,0xa4,0x18,0x86]
        cmp.ule.s  $f2,$f3,$f4      # CHECK: cmp.ule.s $f2, $f3, $f4  # encoding: [0x46,0x84,0x18,0x87]
        cmp.ule.d  $f2,$f3,$f4      # CHECK: cmp.ule.d $f2, $f3, $f4  # encoding: [0x46,0xa4,0x18,0x87]
        cmp.sf.s   $f2,$f3,$f4      # CHECK: cmp.sf.s $f2, $f3, $f4  # encoding: [0x46,0x84,0x18,0x88]
        cmp.sf.d   $f2,$f3,$f4      # CHECK: cmp.sf.d $f2, $f3, $f4  # encoding: [0x46,0xa4,0x18,0x88]
        cmp.ngle.s $f2,$f3,$f4      # CHECK: cmp.ngle.s $f2, $f3, $f4  # encoding: [0x46,0x84,0x18,0x89]
        cmp.ngle.d $f2,$f3,$f4      # CHECK: cmp.ngle.d $f2, $f3, $f4  # encoding: [0x46,0xa4,0x18,0x89]
        cmp.seq.s  $f2,$f3,$f4      # CHECK: cmp.seq.s $f2, $f3, $f4  # encoding: [0x46,0x84,0x18,0x8a]
        cmp.seq.d  $f2,$f3,$f4      # CHECK: cmp.seq.d $f2, $f3, $f4  # encoding: [0x46,0xa4,0x18,0x8a]
        cmp.ngl.s  $f2,$f3,$f4      # CHECK: cmp.ngl.s $f2, $f3, $f4  # encoding: [0x46,0x84,0x18,0x8b]
        cmp.ngl.d  $f2,$f3,$f4      # CHECK: cmp.ngl.d $f2, $f3, $f4  # encoding: [0x46,0xa4,0x18,0x8b]
        cmp.lt.s   $f2,$f3,$f4      # CHECK: cmp.lt.s $f2, $f3, $f4  # encoding: [0x46,0x84,0x18,0x8c]
        cmp.lt.d   $f2,$f3,$f4      # CHECK: cmp.lt.d $f2, $f3, $f4  # encoding: [0x46,0xa4,0x18,0x8c]
        cmp.nge.s  $f2,$f3,$f4      # CHECK: cmp.nge.s $f2, $f3, $f4  # encoding: [0x46,0x84,0x18,0x8d]
        cmp.nge.d  $f2,$f3,$f4      # CHECK: cmp.nge.d $f2, $f3, $f4  # encoding: [0x46,0xa4,0x18,0x8d]
        cmp.le.s   $f2,$f3,$f4      # CHECK: cmp.le.s $f2, $f3, $f4  # encoding: [0x46,0x84,0x18,0x8e]
        cmp.le.d   $f2,$f3,$f4      # CHECK: cmp.le.d $f2, $f3, $f4  # encoding: [0x46,0xa4,0x18,0x8e]
        cmp.ngt.s  $f2,$f3,$f4      # CHECK: cmp.ngt.s $f2, $f3, $f4  # encoding: [0x46,0x84,0x18,0x8f]
        cmp.ngt.d  $f2,$f3,$f4      # CHECK: cmp.ngt.d $f2, $f3, $f4  # encoding: [0x46,0xa4,0x18,0x8f]
        dalign  $4,$2,$3,5       # CHECK: dalign $4, $2, $3, 5 # encoding: [0x7c,0x43,0x23,0x64]
        daui    $3,$2,0x1234     # CHECK: daui $3, $2, 4660  # encoding: [0x74,0x62,0x12,0x34]
        dahi     $3,0x5678       # CHECK: dahi $3, 22136     # encoding: [0x04,0x66,0x56,0x78]
        dati     $3,0xabcd       # CHECK: dati $3, 43981     # encoding: [0x04,0x7e,0xab,0xcd]
        dbitswap $4, $2          # CHECK: dbitswap $4, $2    # encoding: [0x7c,0x02,0x20,0x24]
        div     $2,$3,$4         # CHECK: div $2, $3, $4   # encoding: [0x00,0x64,0x10,0x9a]
        divu    $2,$3,$4         # CHECK: divu $2, $3, $4  # encoding: [0x00,0x64,0x10,0x9b]
        jialc   $5, 256          # CHECK: jialc $5, 256    # encoding: [0xf8,0x05,0x01,0x00]
        jic     $5, 256          # CHECK: jic $5, 256      # encoding: [0xd8,0x05,0x01,0x00]
        mod     $2,$3,$4         # CHECK: mod $2, $3, $4   # encoding: [0x00,0x64,0x10,0xda]
        modu    $2,$3,$4         # CHECK: modu $2, $3, $4  # encoding: [0x00,0x64,0x10,0xdb]
        ddiv    $2,$3,$4         # CHECK: ddiv $2, $3, $4  # encoding: [0x00,0x64,0x10,0x9e]
        ddivu   $2,$3,$4         # CHECK: ddivu $2, $3, $4 # encoding: [0x00,0x64,0x10,0x9f]
        dmod    $2,$3,$4         # CHECK: dmod $2, $3, $4  # encoding: [0x00,0x64,0x10,0xde]
        dmodu   $2,$3,$4         # CHECK: dmodu $2, $3, $4 # encoding: [0x00,0x64,0x10,0xdf]
        lsa     $2, $3, $4, 3    # CHECK: lsa  $2, $3, $4, 3 # encoding: [0x00,0x64,0x10,0xc5]
        dlsa    $2, $3, $4, 3    # CHECK: dlsa $2, $3, $4, 3 # encoding: [0x00,0x64,0x10,0xd5]
        ldpc    $2,123456        # CHECK: ldpc $2, 123456  # encoding: [0xec,0x58,0x3c,0x48]
        lwpc    $2,268           # CHECK: lwpc $2, 268     # encoding: [0xec,0x48,0x00,0x43]
        lwupc   $2,268           # CHECK: lwupc $2, 268    # encoding: [0xec,0x50,0x00,0x43]
        mul     $2,$3,$4         # CHECK: mul $2, $3, $4   # encoding: [0x00,0x64,0x10,0x98]
        muh     $2,$3,$4         # CHECK: muh $2, $3, $4   # encoding: [0x00,0x64,0x10,0xd8]
        mulu    $2,$3,$4         # CHECK: mulu $2, $3, $4  # encoding: [0x00,0x64,0x10,0x99]
        muhu    $2,$3,$4         # CHECK: muhu $2, $3, $4  # encoding: [0x00,0x64,0x10,0xd9]
        dmul    $2,$3,$4         # CHECK: dmul $2, $3, $4  # encoding: [0x00,0x64,0x10,0x9c]
        dmuh    $2,$3,$4         # CHECK: dmuh $2, $3, $4  # encoding: [0x00,0x64,0x10,0xdc]
        dmulu   $2,$3,$4         # CHECK: dmulu $2, $3, $4 # encoding: [0x00,0x64,0x10,0x9d]
        dmuhu   $2,$3,$4         # CHECK: dmuhu $2, $3, $4 # encoding: [0x00,0x64,0x10,0xdd]
        maddf.s $f2,$f3,$f4      # CHECK: maddf.s $f2, $f3, $f4  # encoding: [0x46,0x04,0x18,0x98]
        maddf.d $f2,$f3,$f4      # CHECK: maddf.d $f2, $f3, $f4  # encoding: [0x46,0x24,0x18,0x98]
        msubf.s $f2,$f3,$f4      # CHECK: msubf.s $f2, $f3, $f4  # encoding: [0x46,0x04,0x18,0x99]
        msubf.d $f2,$f3,$f4      # CHECK: msubf.d $f2, $f3, $f4  # encoding: [0x46,0x24,0x18,0x99]
        pref    1, 8($5)         # CHECK: pref 1, 8($5)          # encoding: [0x7c,0xa1,0x04,0x35]
        sel.d   $f0,$f1,$f2      # CHECK: sel.d $f0, $f1, $f2 # encoding: [0x46,0x22,0x08,0x10]
        sel.s   $f0,$f1,$f2      # CHECK: sel.s $f0, $f1, $f2 # encoding: [0x46,0x02,0x08,0x10]
        seleqz  $2,$3,$4         # CHECK: seleqz $2, $3, $4 # encoding: [0x00,0x64,0x10,0x35]
        selnez  $2,$3,$4         # CHECK: selnez $2, $3, $4 # encoding: [0x00,0x64,0x10,0x37]
        max.s   $f0, $f2, $f4    # CHECK: max.s $f0, $f2, $f4 # encoding: [0x46,0x04,0x10,0x1d]
        max.d   $f0, $f2, $f4    # CHECK: max.d $f0, $f2, $f4 # encoding: [0x46,0x24,0x10,0x1d]
        min.s   $f0, $f2, $f4    # CHECK: min.s $f0, $f2, $f4 # encoding: [0x46,0x04,0x10,0x1c]
        min.d   $f0, $f2, $f4    # CHECK: min.d $f0, $f2, $f4 # encoding: [0x46,0x24,0x10,0x1c]
        maxa.s  $f0, $f2, $f4    # CHECK: maxa.s $f0, $f2, $f4 # encoding: [0x46,0x04,0x10,0x1f]
        maxa.d  $f0, $f2, $f4    # CHECK: maxa.d $f0, $f2, $f4 # encoding: [0x46,0x24,0x10,0x1f]
        mina.s  $f0, $f2, $f4    # CHECK: mina.s $f0, $f2, $f4 # encoding: [0x46,0x04,0x10,0x1e]
        mina.d  $f0, $f2, $f4    # CHECK: mina.d $f0, $f2, $f4 # encoding: [0x46,0x24,0x10,0x1e]
        or      $2, 4            # CHECK: ori $2, $2, 4          # encoding: [0x34,0x42,0x00,0x04]
        seleqz.s $f0, $f2, $f4   # CHECK: seleqz.s $f0, $f2, $f4 # encoding: [0x46,0x04,0x10,0x14]
        seleqz.d $f0, $f2, $f4   # CHECK: seleqz.d $f0, $f2, $f4 # encoding: [0x46,0x24,0x10,0x14]
        selnez.s $f0, $f2, $f4   # CHECK: selnez.s $f0, $f2, $f4 # encoding: [0x46,0x04,0x10,0x17]
        selnez.d $f0, $f2, $f4   # CHECK: selnez.d $f0, $f2, $f4 # encoding: [0x46,0x24,0x10,0x17]
        rint.s $f2, $f4          # CHECK: rint.s $f2, $f4        # encoding: [0x46,0x00,0x20,0x9a]
        rint.d $f2, $f4          # CHECK: rint.d $f2, $f4        # encoding: [0x46,0x20,0x20,0x9a]
        class.s $f2, $f4         # CHECK: class.s $f2, $f4       # encoding: [0x46,0x00,0x20,0x9b]
        class.d $f2, $f4         # CHECK: class.d $f2, $f4       # encoding: [0x46,0x20,0x20,0x9b]
        jr.hb   $4               # CHECK: jr.hb $4               # encoding: [0x00,0x80,0x04,0x09]
        jalr.hb $4               # CHECK: jalr.hb $4             # encoding: [0x00,0x80,0xfc,0x09]
        jalr.hb $4, $5           # CHECK: jalr.hb $4, $5         # encoding: [0x00,0xa0,0x24,0x09]
        ldc2    $8, -701($at)    # CHECK: ldc2 $8, -701($1)      # encoding: [0x49,0xc8,0x0d,0x43]
        lwc2    $18,-841($a2)    # CHECK: lwc2 $18, -841($6)     # encoding: [0x49,0x52,0x34,0xb7]
        sdc2    $20,629($s2)     # CHECK: sdc2 $20, 629($18)     # encoding: [0x49,0xf4,0x92,0x75]
        swc2    $25,304($s0)     # CHECK: swc2 $25, 304($16)     # encoding: [0x49,0x79,0x81,0x30]
        ll      $v0,-153($s2)    # CHECK: ll $2, -153($18)       # encoding: [0x7e,0x42,0xb3,0xb6]
        lld     $zero,112($ra)   # CHECK: lld $zero, 112($ra)    # encoding: [0x7f,0xe0,0x38,0x37]
        sc      $15,-40($s3)     # CHECK: sc $15, -40($19)       # encoding: [0x7e,0x6f,0xec,0x26]
        scd     $15,-51($sp)     # CHECK: scd $15, -51($sp)      # encoding: [0x7f,0xaf,0xe6,0xa7]
        clo     $11,$a1          # CHECK: clo $11, $5            # encoding: [0x00,0xa0,0x58,0x51]
        clz     $sp,$gp          # CHECK: clz $sp, $gp           # encoding: [0x03,0x80,0xe8,0x50]
        dclo    $s2,$a2          # CHECK: dclo $18, $6           # encoding: [0x00,0xc0,0x90,0x53]
        dclz    $s0,$25          # CHECK: dclz $16, $25          # encoding: [0x03,0x20,0x80,0x52]
        ssnop                    # WARNING: [[@LINE]]:9: warning: ssnop is deprecated for MIPS64r6 and is equivalent to a nop instruction
        ssnop                    # CHECK: ssnop                  # encoding: [0x00,0x00,0x00,0x40]
        sdbbp                    # CHECK: sdbbp                  # encoding: [0x00,0x00,0x00,0x0e]
        sdbbp     34             # CHECK: sdbbp 34               # encoding: [0x00,0x00,0x08,0x8e]
        sync                     # CHECK: sync                   # encoding: [0x00,0x00,0x00,0x0f]
        sync    1                # CHECK: sync 1                 # encoding: [0x00,0x00,0x00,0x4f]
