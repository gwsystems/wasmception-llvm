# RUN: llvm-mc %s -triple=mips64el-unknown-linux -show-encoding -mcpu=mips64r2 | FileCheck %s
#
# Test the 'dli' and 'dla' 64-bit variants of 'li' and 'la'.

# Immediate is <= 32 bits.
  dli $5, 123
# CHECK:     ori   $5, $zero, 123   # encoding: [0x7b,0x00,0x05,0x34]

  dli $6, -2345
# CHECK:     addiu $6, $zero, -2345 # encoding: [0xd7,0xf6,0x06,0x24]

  dli $7, 65538
# CHECK:     lui   $7, 1            # encoding: [0x01,0x00,0x07,0x3c]
# CHECK:     ori   $7, $7, 2        # encoding: [0x02,0x00,0xe7,0x34]

  dli $8, ~7
# CHECK:     addiu $8, $zero, -8    # encoding: [0xf8,0xff,0x08,0x24]

  dli $9, 0x10000
# CHECK:     lui   $9, 1            # encoding: [0x01,0x00,0x09,0x3c]
# CHECK-NOT: ori   $9, $9, 0        # encoding: [0x00,0x00,0x29,0x35]


# Positive immediate which is => 32 bits and <= 48 bits.
  dli $8, 0x100000000
# CHECK: lui  $8, 1                 # encoding: [0x01,0x00,0x08,0x3c]
# CHECK: dsll $8, $8, 16            # encoding: [0x38,0x44,0x08,0x00]

  dli $8, 0x100000001
# CHECK: lui  $8, 1                 # encoding: [0x01,0x00,0x08,0x3c]
# CHECK: dsll $8, $8, 16            # encoding: [0x38,0x44,0x08,0x00]
# CHECK: ori  $8, $8, 1             # encoding: [0x01,0x00,0x08,0x35]

  dli $8, 0x100010000
# CHECK: lui  $8, 1                 # encoding: [0x01,0x00,0x08,0x3c]
# CHECK: ori  $8, $8, 1             # encoding: [0x01,0x00,0x08,0x35]
# CHECK: dsll $8, $8, 16            # encoding: [0x38,0x44,0x08,0x00]

  dli $8, 0x100010001
# CHECK: lui  $8, 1                 # encoding: [0x01,0x00,0x08,0x3c]
# CHECK: ori  $8, $8, 1             # encoding: [0x01,0x00,0x08,0x35]
# CHECK: dsll $8, $8, 16            # encoding: [0x38,0x44,0x08,0x00]
# CHECK: ori  $8, $8, 1             # encoding: [0x01,0x00,0x08,0x35]


# Positive immediate which is > 48 bits.
  dli $8, 0x1000000000000
# CHECK: lui    $8, 1               # encoding: [0x01,0x00,0x08,0x3c]
# CHECK: dsll32 $8, $8, 0           # encoding: [0x3c,0x40,0x08,0x00]

  dli $8, 0x1000000000001
# CHECK: lui    $8, 1               # encoding: [0x01,0x00,0x08,0x3c]
# CHECK: dsll32 $8, $8, 0           # encoding: [0x3c,0x40,0x08,0x00]
# CHECK: ori    $8, $8, 1           # encoding: [0x01,0x00,0x08,0x35]

  dli $8, 0x1000000010000
# CHECK: lui    $8, 1               # encoding: [0x01,0x00,0x08,0x3c]
# CHECK: dsll   $8, $8, 16          # encoding: [0x38,0x44,0x08,0x00]
# CHECK: ori    $8, $8, 1           # encoding: [0x01,0x00,0x08,0x35]
# CHECK: dsll   $8, $8, 16          # encoding: [0x38,0x44,0x08,0x00]

  dli $8, 0x1000100000000
# CHECK: lui    $8, 1               # encoding: [0x01,0x00,0x08,0x3c]
# CHECK: ori    $8, $8, 1           # encoding: [0x01,0x00,0x08,0x35]
# CHECK: dsll32 $8, $8, 0           # encoding: [0x3c,0x40,0x08,0x00]

  dli $8, 0x1000000010001
# CHECK: lui    $8, 1               # encoding: [0x01,0x00,0x08,0x3c]
# CHECK: dsll   $8, $8, 16          # encoding: [0x38,0x44,0x08,0x00]
# CHECK: ori    $8, $8, 1           # encoding: [0x01,0x00,0x08,0x35]
# CHECK: dsll   $8, $8, 16          # encoding: [0x38,0x44,0x08,0x00]
# CHECK: ori    $8, $8, 1           # encoding: [0x01,0x00,0x08,0x35]

  dli $8, 0x1000100010000
# CHECK: lui    $8, 1               # encoding: [0x01,0x00,0x08,0x3c]
# CHECK: ori    $8, $8, 1           # encoding: [0x01,0x00,0x08,0x35]
# CHECK: dsll   $8, $8, 16          # encoding: [0x38,0x44,0x08,0x00]
# CHECK: ori    $8, $8, 1           # encoding: [0x01,0x00,0x08,0x35]
# CHECK: dsll   $8, $8, 16          # encoding: [0x38,0x44,0x08,0x00]

  dli $8, 0x1000100000001
# CHECK: lui    $8, 1               # encoding: [0x01,0x00,0x08,0x3c]
# CHECK: ori    $8, $8, 1           # encoding: [0x01,0x00,0x08,0x35]
# CHECK: dsll32 $8, $8, 0           # encoding: [0x3c,0x40,0x08,0x00]
# CHECK: ori    $8, $8, 1           # encoding: [0x01,0x00,0x08,0x35]

  dli $8, 0x1000100010001
# CHECK: lui    $8, 1               # encoding: [0x01,0x00,0x08,0x3c]
# CHECK: ori    $8, $8, 1           # encoding: [0x01,0x00,0x08,0x35]
# CHECK: dsll   $8, $8, 16          # encoding: [0x38,0x44,0x08,0x00]
# CHECK: ori    $8, $8, 1           # encoding: [0x01,0x00,0x08,0x35]
# CHECK: dsll   $8, $8, 16          # encoding: [0x38,0x44,0x08,0x00]
# CHECK: ori    $8, $8, 1           # encoding: [0x01,0x00,0x08,0x35]


# Negative immediate which is => 32 bits and <= 48 bits.
  dli $8, -0x100000000
# CHECK: lui    $8, 65535           # encoding: [0xff,0xff,0x08,0x3c]
# CHECK: ori    $8, $8, 65535       # encoding: [0xff,0xff,0x08,0x35]
# CHECK: dsll32 $8, $8, 0           # encoding: [0x3c,0x40,0x08,0x00]

  dli $8, -0x100000001
# CHECK: lui    $8, 65535           # encoding: [0xff,0xff,0x08,0x3c]
# CHECK: ori    $8, $8, 65534       # encoding: [0xfe,0xff,0x08,0x35]
# CHECK: dsll   $8, $8, 16          # encoding: [0x38,0x44,0x08,0x00]
# CHECK: ori    $8, $8, 65535       # encoding: [0xff,0xff,0x08,0x35]
# CHECK: dsll   $8, $8, 16          # encoding: [0x38,0x44,0x08,0x00]
# CHECK: ori    $8, $8, 65535       # encoding: [0xff,0xff,0x08,0x35]

  dli $8, -0x100010000
# CHECK: lui    $8, 65535           # encoding: [0xff,0xff,0x08,0x3c]
# CHECK: ori    $8, $8, 65534       # encoding: [0xfe,0xff,0x08,0x35]
# CHECK: dsll   $8, $8, 16          # encoding: [0x38,0x44,0x08,0x00]
# CHECK: ori    $8, $8, 65535       # encoding: [0xff,0xff,0x08,0x35]
# CHECK: dsll   $8, $8, 16          # encoding: [0x38,0x44,0x08,0x00]

  dli $8, -0x100010001
# CHECK: lui    $8, 65535           # encoding: [0xff,0xff,0x08,0x3c]
# CHECK: ori    $8, $8, 65534       # encoding: [0xfe,0xff,0x08,0x35]
# CHECK: dsll   $8, $8, 16          # encoding: [0x38,0x44,0x08,0x00]
# CHECK: ori    $8, $8, 65534       # encoding: [0xfe,0xff,0x08,0x35]
# CHECK: dsll   $8, $8, 16          # encoding: [0x38,0x44,0x08,0x00]
# CHECK: ori    $8, $8, 65535       # encoding: [0xff,0xff,0x08,0x35]


# Negative immediate which is > 48 bits.
  dli $8, -0x1000000000000
# CHECK: lui    $8, 65535           # encoding: [0xff,0xff,0x08,0x3c]
# CHECK: dsll32 $8, $8, 0           # encoding: [0x3c,0x40,0x08,0x00]

  dli $8, -0x1000000000001
# CHECK: lui    $8, 65534           # encoding: [0xfe,0xff,0x08,0x3c]
# CHECK: ori    $8, $8, 65535       # encoding: [0xff,0xff,0x08,0x35]
# CHECK: dsll   $8, $8, 16          # encoding: [0x38,0x44,0x08,0x00]
# CHECK: ori    $8, $8, 65535       # encoding: [0xff,0xff,0x08,0x35]
# CHECK: dsll   $8, $8, 16          # encoding: [0x38,0x44,0x08,0x00]
# CHECK: ori    $8, $8, 65535       # encoding: [0xff,0xff,0x08,0x35]

  dli $8, -0x1000000010000
# CHECK: lui    $8, 65534           # encoding: [0xfe,0xff,0x08,0x3c]
# CHECK: ori    $8, $8, 65535       # encoding: [0xff,0xff,0x08,0x35]
# CHECK: dsll   $8, $8, 16          # encoding: [0x38,0x44,0x08,0x00]
# CHECK: ori    $8, $8, 65535       # encoding: [0xff,0xff,0x08,0x35]
# CHECK: dsll   $8, $8, 16          # encoding: [0x38,0x44,0x08,0x00]

  dli $8, -0x1000100000000
# CHECK: lui    $8, 65534           # encoding: [0xfe,0xff,0x08,0x3c]
# CHECK: ori    $8, $8, 65535       # encoding: [0xff,0xff,0x08,0x35]
# CHECK: dsll32 $8, $8, 0           # encoding: [0x3c,0x40,0x08,0x00]

  dli $8, -0x1000000010001
# CHECK: lui    $8, 65534           # encoding: [0xfe,0xff,0x08,0x3c]
# CHECK: ori    $8, $8, 65535       # encoding: [0xff,0xff,0x08,0x35]
# CHECK: dsll   $8, $8, 16          # encoding: [0x38,0x44,0x08,0x00]
# CHECK: ori    $8, $8, 65534       # encoding: [0xfe,0xff,0x08,0x35]
# CHECK: dsll   $8, $8, 16          # encoding: [0x38,0x44,0x08,0x00]
# CHECK: ori    $8, $8, 65535       # encoding: [0xff,0xff,0x08,0x35]

  dli $8, -0x1000100010000
# CHECK: lui    $8, 65534           # encoding: [0xfe,0xff,0x08,0x3c]
# CHECK: ori    $8, $8, 65534       # encoding: [0xfe,0xff,0x08,0x35]
# CHECK: dsll   $8, $8, 16          # encoding: [0x38,0x44,0x08,0x00]
# CHECK: ori    $8, $8, 65535       # encoding: [0xff,0xff,0x08,0x35]
# CHECK: dsll   $8, $8, 16          # encoding: [0x38,0x44,0x08,0x00]

  dli $8, -0x1000100000001
# CHECK: lui    $8, 65534           # encoding: [0xfe,0xff,0x08,0x3c]
# CHECK: ori    $8, $8, 65534       # encoding: [0xfe,0xff,0x08,0x35]
# CHECK: dsll   $8, $8, 16          # encoding: [0x38,0x44,0x08,0x00]
# CHECK: ori    $8, $8, 65535       # encoding: [0xff,0xff,0x08,0x35]
# CHECK: dsll   $8, $8, 16          # encoding: [0x38,0x44,0x08,0x00]
# CHECK: ori    $8, $8, 65535       # encoding: [0xff,0xff,0x08,0x35]

  dli $8, -0x1000100010001
# CHECK: lui    $8, 65534           # encoding: [0xfe,0xff,0x08,0x3c]
# CHECK: ori    $8, $8, 65534       # encoding: [0xfe,0xff,0x08,0x35]
# CHECK: dsll   $8, $8, 16          # encoding: [0x38,0x44,0x08,0x00]
# CHECK: ori    $8, $8, 65534       # encoding: [0xfe,0xff,0x08,0x35]
# CHECK: dsll   $8, $8, 16          # encoding: [0x38,0x44,0x08,0x00]
# CHECK: ori    $8, $8, 65535       # encoding: [0xff,0xff,0x08,0x35]

# Check that signed negative 32-bit immediates are loaded correctly:
  li $10, ~(0x101010)
# CHECK: lui $10, 65519        # encoding: [0xef,0xff,0x0a,0x3c]
# CHECK: ori $10, $10, 61423   # encoding: [0xef,0xef,0x4a,0x35]
# CHECK-NOT: dsll

  dli $10, ~(0x202020)
# CHECK: lui $10, 65503        # encoding: [0xdf,0xff,0x0a,0x3c]
# CHECK: ori $10, $10, 57311   # encoding: [0xdf,0xdf,0x4a,0x35]
# CHECK-NOT: dsll

  dli $9, 0x80000000
# CHECK: ori  $9, $zero, 32768 # encoding: [0x00,0x80,0x09,0x34]
# CHECK: dsll $9, $9, 16       # encoding: [0x38,0x4c,0x09,0x00]

# Test bne with an immediate as the 2nd operand.
  bne $2, 0x100010001, 1332
# CHECK: lui  $1, 1                 # encoding: [0x01,0x00,0x01,0x3c]
# CHECK: ori  $1, $1, 1             # encoding: [0x01,0x00,0x21,0x34]
# CHECK: dsll $1, $1, 16            # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori  $1, $1, 1             # encoding: [0x01,0x00,0x21,0x34]
# CHECK: bne  $2, $1, 1332          # encoding: [0x4d,0x01,0x41,0x14]
# CHECK: nop                        # encoding: [0x00,0x00,0x00,0x00]

  bne $2, 0x1000100010001, 1332
# CHECK: lui  $1, 1                 # encoding: [0x01,0x00,0x01,0x3c]
# CHECK: ori  $1, $1, 1             # encoding: [0x01,0x00,0x21,0x34]
# CHECK: dsll $1, $1, 16            # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori  $1, $1, 1             # encoding: [0x01,0x00,0x21,0x34]
# CHECK: dsll $1, $1, 16            # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori  $1, $1, 1             # encoding: [0x01,0x00,0x21,0x34]
# CHECK: bne  $2, $1, 1332          # encoding: [0x4d,0x01,0x41,0x14]
# CHECK: nop                        # encoding: [0x00,0x00,0x00,0x00]

  bne $2, -0x100010001, 1332
# CHECK: lui  $1, 65535             # encoding: [0xff,0xff,0x01,0x3c]
# CHECK: ori  $1, $1, 65534         # encoding: [0xfe,0xff,0x21,0x34]
# CHECK: dsll $1, $1, 16            # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori  $1, $1, 65534         # encoding: [0xfe,0xff,0x21,0x34]
# CHECK: dsll $1, $1, 16            # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori  $1, $1, 65535         # encoding: [0xff,0xff,0x21,0x34]
# CHECK: bne  $2, $1, 1332          # encoding: [0x4d,0x01,0x41,0x14]
# CHECK: nop                        # encoding: [0x00,0x00,0x00,0x00]

  bne $2, -0x1000100010001, 1332
# CHECK: lui  $1, 65534             # encoding: [0xfe,0xff,0x01,0x3c]
# CHECK: ori  $1, $1, 65534         # encoding: [0xfe,0xff,0x21,0x34]
# CHECK: dsll $1, $1, 16            # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori  $1, $1, 65534         # encoding: [0xfe,0xff,0x21,0x34]
# CHECK: dsll $1, $1, 16            # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori  $1, $1, 65535         # encoding: [0xff,0xff,0x21,0x34]
# CHECK: bne  $2, $1, 1332          # encoding: [0x4d,0x01,0x41,0x14]
# CHECK: nop                        # encoding: [0x00,0x00,0x00,0x00]

# Test beq with an immediate as the 2nd operand.
  beq $2, 0x100010001, 1332
# CHECK: lui  $1, 1                 # encoding: [0x01,0x00,0x01,0x3c]
# CHECK: ori  $1, $1, 1             # encoding: [0x01,0x00,0x21,0x34]
# CHECK: dsll $1, $1, 16            # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori  $1, $1, 1             # encoding: [0x01,0x00,0x21,0x34]
# CHECK: beq  $2, $1, 1332          # encoding: [0x4d,0x01,0x41,0x10]
# CHECK: nop                        # encoding: [0x00,0x00,0x00,0x00]

  beq $2, 0x1000100010001, 1332
# CHECK: lui  $1, 1                 # encoding: [0x01,0x00,0x01,0x3c]
# CHECK: ori  $1, $1, 1             # encoding: [0x01,0x00,0x21,0x34]
# CHECK: dsll $1, $1, 16            # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori  $1, $1, 1             # encoding: [0x01,0x00,0x21,0x34]
# CHECK: dsll $1, $1, 16            # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori  $1, $1, 1             # encoding: [0x01,0x00,0x21,0x34]
# CHECK: beq  $2, $1, 1332          # encoding: [0x4d,0x01,0x41,0x10]
# CHECK: nop                        # encoding: [0x00,0x00,0x00,0x00]

  beq $2, -0x100010001, 1332
# CHECK: lui  $1, 65535             # encoding: [0xff,0xff,0x01,0x3c]
# CHECK: ori  $1, $1, 65534         # encoding: [0xfe,0xff,0x21,0x34]
# CHECK: dsll $1, $1, 16            # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori  $1, $1, 65534         # encoding: [0xfe,0xff,0x21,0x34]
# CHECK: dsll $1, $1, 16            # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori  $1, $1, 65535         # encoding: [0xff,0xff,0x21,0x34]
# CHECK: beq  $2, $1, 1332          # encoding: [0x4d,0x01,0x41,0x10]
# CHECK: nop                        # encoding: [0x00,0x00,0x00,0x00]

  beq $2, -0x1000100010001, 1332
# CHECK: lui  $1, 65534             # encoding: [0xfe,0xff,0x01,0x3c]
# CHECK: ori  $1, $1, 65534         # encoding: [0xfe,0xff,0x21,0x34]
# CHECK: dsll $1, $1, 16            # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori  $1, $1, 65534         # encoding: [0xfe,0xff,0x21,0x34]
# CHECK: dsll $1, $1, 16            # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori  $1, $1, 65535         # encoding: [0xff,0xff,0x21,0x34]
# CHECK: beq  $2, $1, 1332          # encoding: [0x4d,0x01,0x41,0x10]
# CHECK: nop                        # encoding: [0x00,0x00,0x00,0x00]

# Test ulhu with 64-bit immediate addresses.
  ulhu $8, 0x100010001
# CHECK: lui  $1, 1            # encoding: [0x01,0x00,0x01,0x3c]
# CHECK: ori  $1, $1, 1        # encoding: [0x01,0x00,0x21,0x34]
# CHECK: dsll $1, $1, 16       # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori  $1, $1, 1        # encoding: [0x01,0x00,0x21,0x34]
# CHECK: lbu  $8, 1($1)        # encoding: [0x01,0x00,0x28,0x90]
# CHECK: lbu  $1, 0($1)        # encoding: [0x00,0x00,0x21,0x90]
# CHECK: sll  $8, $8, 8        # encoding: [0x00,0x42,0x08,0x00]
# CHECK: or   $8, $8, $1       # encoding: [0x25,0x40,0x01,0x01]

  ulhu $8, 0x1000100010001
# CHECK: lui  $1, 1            # encoding: [0x01,0x00,0x01,0x3c]
# CHECK: ori  $1, $1, 1        # encoding: [0x01,0x00,0x21,0x34]
# CHECK: dsll $1, $1, 16       # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori  $1, $1, 1        # encoding: [0x01,0x00,0x21,0x34]
# CHECK: dsll $1, $1, 16       # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori  $1, $1, 1        # encoding: [0x01,0x00,0x21,0x34]
# CHECK: lbu  $8, 1($1)        # encoding: [0x01,0x00,0x28,0x90]
# CHECK: lbu  $1, 0($1)        # encoding: [0x00,0x00,0x21,0x90]
# CHECK: sll  $8, $8, 8        # encoding: [0x00,0x42,0x08,0x00]
# CHECK: or   $8, $8, $1       # encoding: [0x25,0x40,0x01,0x01]

  ulhu $8, -0x100010001
# CHECK: lui  $1, 65535        # encoding: [0xff,0xff,0x01,0x3c]
# CHECK: ori  $1, $1, 65534    # encoding: [0xfe,0xff,0x21,0x34]
# CHECK: dsll $1, $1, 16       # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori  $1, $1, 65534    # encoding: [0xfe,0xff,0x21,0x34]
# CHECK: dsll $1, $1, 16       # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori  $1, $1, 65535    # encoding: [0xff,0xff,0x21,0x34]
# CHECK: lbu  $8, 1($1)        # encoding: [0x01,0x00,0x28,0x90]
# CHECK: lbu  $1, 0($1)        # encoding: [0x00,0x00,0x21,0x90]
# CHECK: sll  $8, $8, 8        # encoding: [0x00,0x42,0x08,0x00]
# CHECK: or   $8, $8, $1       # encoding: [0x25,0x40,0x01,0x01]

  ulhu $8, -0x1000100010001
# CHECK: lui  $1, 65534        # encoding: [0xfe,0xff,0x01,0x3c]
# CHECK: ori  $1, $1, 65534    # encoding: [0xfe,0xff,0x21,0x34]
# CHECK: dsll $1, $1, 16       # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori  $1, $1, 65534    # encoding: [0xfe,0xff,0x21,0x34]
# CHECK: dsll $1, $1, 16       # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori  $1, $1, 65535    # encoding: [0xff,0xff,0x21,0x34]
# CHECK: lbu  $8, 1($1)        # encoding: [0x01,0x00,0x28,0x90]
# CHECK: lbu  $1, 0($1)        # encoding: [0x00,0x00,0x21,0x90]
# CHECK: sll  $8, $8, 8        # encoding: [0x00,0x42,0x08,0x00]
# CHECK: or   $8, $8, $1       # encoding: [0x25,0x40,0x01,0x01]

# Test ulhu with source register and 64-bit immediate offset.
  ulhu $8, 0x100010001($9)
# CHECK: lui   $1, 1           # encoding: [0x01,0x00,0x01,0x3c]
# CHECK: ori   $1, $1, 1       # encoding: [0x01,0x00,0x21,0x34]
# CHECK: dsll  $1, $1, 16      # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori   $1, $1, 1       # encoding: [0x01,0x00,0x21,0x34]
# CHECK: daddu $1, $1, $9      # encoding: [0x2d,0x08,0x29,0x00]
# CHECK: lbu   $8, 1($1)       # encoding: [0x01,0x00,0x28,0x90]
# CHECK: lbu   $1, 0($1)       # encoding: [0x00,0x00,0x21,0x90]
# CHECK: sll   $8, $8, 8       # encoding: [0x00,0x42,0x08,0x00]
# CHECK: or    $8, $8, $1      # encoding: [0x25,0x40,0x01,0x01]

  ulhu $8, 0x1000100010001($9)
# CHECK: lui   $1, 1           # encoding: [0x01,0x00,0x01,0x3c]
# CHECK: ori   $1, $1, 1       # encoding: [0x01,0x00,0x21,0x34]
# CHECK: dsll  $1, $1, 16      # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori   $1, $1, 1       # encoding: [0x01,0x00,0x21,0x34]
# CHECK: dsll  $1, $1, 16      # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori   $1, $1, 1       # encoding: [0x01,0x00,0x21,0x34]
# CHECK: daddu $1, $1, $9      # encoding: [0x2d,0x08,0x29,0x00]
# CHECK: lbu   $8, 1($1)       # encoding: [0x01,0x00,0x28,0x90]
# CHECK: lbu   $1, 0($1)       # encoding: [0x00,0x00,0x21,0x90]
# CHECK: sll   $8, $8, 8       # encoding: [0x00,0x42,0x08,0x00]
# CHECK: or    $8, $8, $1      # encoding: [0x25,0x40,0x01,0x01]

  ulhu $8, -0x100010001($9)
# CHECK: lui   $1, 65535       # encoding: [0xff,0xff,0x01,0x3c]
# CHECK: ori   $1, $1, 65534   # encoding: [0xfe,0xff,0x21,0x34]
# CHECK: dsll  $1, $1, 16      # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori   $1, $1, 65534   # encoding: [0xfe,0xff,0x21,0x34]
# CHECK: dsll  $1, $1, 16      # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori   $1, $1, 65535   # encoding: [0xff,0xff,0x21,0x34]
# CHECK: daddu $1, $1, $9      # encoding: [0x2d,0x08,0x29,0x00]
# CHECK: lbu   $8, 1($1)       # encoding: [0x01,0x00,0x28,0x90]
# CHECK: lbu   $1, 0($1)       # encoding: [0x00,0x00,0x21,0x90]
# CHECK: sll   $8, $8, 8       # encoding: [0x00,0x42,0x08,0x00]
# CHECK: or    $8, $8, $1      # encoding: [0x25,0x40,0x01,0x01]

  ulhu $8, -0x1000100010001($9)
# CHECK: lui   $1, 65534       # encoding: [0xfe,0xff,0x01,0x3c]
# CHECK: ori   $1, $1, 65534   # encoding: [0xfe,0xff,0x21,0x34]
# CHECK: dsll  $1, $1, 16      # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori   $1, $1, 65534   # encoding: [0xfe,0xff,0x21,0x34]
# CHECK: dsll  $1, $1, 16      # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori   $1, $1, 65535   # encoding: [0xff,0xff,0x21,0x34]
# CHECK: daddu $1, $1, $9      # encoding: [0x2d,0x08,0x29,0x00]
# CHECK: lbu   $8, 1($1)       # encoding: [0x01,0x00,0x28,0x90]
# CHECK: lbu   $1, 0($1)       # encoding: [0x00,0x00,0x21,0x90]
# CHECK: sll   $8, $8, 8       # encoding: [0x00,0x42,0x08,0x00]
# CHECK: or    $8, $8, $1      # encoding: [0x25,0x40,0x01,0x01]

# Test ulw with 64-bit immediate addresses.
  ulw $8, 0x100010001
# CHECK: lui  $1, 1           # encoding: [0x01,0x00,0x01,0x3c]
# CHECK: ori  $1, $1, 1       # encoding: [0x01,0x00,0x21,0x34]
# CHECK: dsll $1, $1, 16      # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori  $1, $1, 1       # encoding: [0x01,0x00,0x21,0x34]
# CHECK: lwl  $8, 3($1)       # encoding: [0x03,0x00,0x28,0x88]
# CHECK: lwr  $8, 0($1)       # encoding: [0x00,0x00,0x28,0x98]

  ulw $8, 0x1000100010001
# CHECK: lui  $1, 1           # encoding: [0x01,0x00,0x01,0x3c]
# CHECK: ori  $1, $1, 1       # encoding: [0x01,0x00,0x21,0x34]
# CHECK: dsll $1, $1, 16      # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori  $1, $1, 1       # encoding: [0x01,0x00,0x21,0x34]
# CHECK: dsll $1, $1, 16      # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori  $1, $1, 1       # encoding: [0x01,0x00,0x21,0x34]
# CHECK: lwl  $8, 3($1)       # encoding: [0x03,0x00,0x28,0x88]
# CHECK: lwr  $8, 0($1)       # encoding: [0x00,0x00,0x28,0x98]

  ulw $8, -0x100010001
# CHECK: lui  $1, 65535       # encoding: [0xff,0xff,0x01,0x3c]
# CHECK: ori  $1, $1, 65534   # encoding: [0xfe,0xff,0x21,0x34]
# CHECK: dsll $1, $1, 16      # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori  $1, $1, 65534   # encoding: [0xfe,0xff,0x21,0x34]
# CHECK: dsll $1, $1, 16      # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori  $1, $1, 65535   # encoding: [0xff,0xff,0x21,0x34]
# CHECK: lwl  $8, 3($1)       # encoding: [0x03,0x00,0x28,0x88]
# CHECK: lwr  $8, 0($1)       # encoding: [0x00,0x00,0x28,0x98]

  ulw $8, -0x1000100010001
# CHECK: lui  $1, 65534       # encoding: [0xfe,0xff,0x01,0x3c]
# CHECK: ori  $1, $1, 65534   # encoding: [0xfe,0xff,0x21,0x34]
# CHECK: dsll $1, $1, 16      # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori  $1, $1, 65534   # encoding: [0xfe,0xff,0x21,0x34]
# CHECK: dsll $1, $1, 16      # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori  $1, $1, 65535   # encoding: [0xff,0xff,0x21,0x34]
# CHECK: lwl  $8, 3($1)       # encoding: [0x03,0x00,0x28,0x88]
# CHECK: lwr  $8, 0($1)       # encoding: [0x00,0x00,0x28,0x98]

# Test ulw with source register and 64-bit immediate offset.
  ulw $8, 0x100010001($9)
# CHECK: lui   $1, 1          # encoding: [0x01,0x00,0x01,0x3c]
# CHECK: ori   $1, $1, 1      # encoding: [0x01,0x00,0x21,0x34]
# CHECK: dsll  $1, $1, 16     # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori   $1, $1, 1      # encoding: [0x01,0x00,0x21,0x34]
# CHECK: daddu $1, $1, $9     # encoding: [0x2d,0x08,0x29,0x00]
# CHECK: lwl   $8, 3($1)      # encoding: [0x03,0x00,0x28,0x88]
# CHECK: lwr   $8, 0($1)      # encoding: [0x00,0x00,0x28,0x98]

  ulw $8, 0x1000100010001($9)
# CHECK: lui   $1, 1          # encoding: [0x01,0x00,0x01,0x3c]
# CHECK: ori   $1, $1, 1      # encoding: [0x01,0x00,0x21,0x34]
# CHECK: dsll  $1, $1, 16     # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori   $1, $1, 1      # encoding: [0x01,0x00,0x21,0x34]
# CHECK: dsll  $1, $1, 16     # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori   $1, $1, 1      # encoding: [0x01,0x00,0x21,0x34]
# CHECK: daddu $1, $1, $9     # encoding: [0x2d,0x08,0x29,0x00]
# CHECK: lwl   $8, 3($1)      # encoding: [0x03,0x00,0x28,0x88]
# CHECK: lwr   $8, 0($1)      # encoding: [0x00,0x00,0x28,0x98]

  ulw $8, -0x100010001($9)
# CHECK: lui   $1, 65535      # encoding: [0xff,0xff,0x01,0x3c]
# CHECK: ori   $1, $1, 65534  # encoding: [0xfe,0xff,0x21,0x34]
# CHECK: dsll  $1, $1, 16     # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori   $1, $1, 65534  # encoding: [0xfe,0xff,0x21,0x34]
# CHECK: dsll  $1, $1, 16     # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori   $1, $1, 65535  # encoding: [0xff,0xff,0x21,0x34]
# CHECK: daddu $1, $1, $9     # encoding: [0x2d,0x08,0x29,0x00]
# CHECK: lwl   $8, 3($1)      # encoding: [0x03,0x00,0x28,0x88]
# CHECK: lwr   $8, 0($1)      # encoding: [0x00,0x00,0x28,0x98]

  ulw $8, -0x1000100010001($9)
# CHECK: lui   $1, 65534      # encoding: [0xfe,0xff,0x01,0x3c]
# CHECK: ori   $1, $1, 65534  # encoding: [0xfe,0xff,0x21,0x34]
# CHECK: dsll  $1, $1, 16     # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori   $1, $1, 65534  # encoding: [0xfe,0xff,0x21,0x34]
# CHECK: dsll  $1, $1, 16     # encoding: [0x38,0x0c,0x01,0x00]
# CHECK: ori   $1, $1, 65535  # encoding: [0xff,0xff,0x21,0x34]
# CHECK: daddu $1, $1, $9     # encoding: [0x2d,0x08,0x29,0x00]
# CHECK: lwl   $8, 3($1)      # encoding: [0x03,0x00,0x28,0x88]
# CHECK: lwr   $8, 0($1)      # encoding: [0x00,0x00,0x28,0x98]
