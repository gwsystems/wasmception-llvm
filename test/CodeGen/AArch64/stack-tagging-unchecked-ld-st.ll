; RUN: llc < %s -mtriple=aarch64 -mattr=+mte | FileCheck %s --check-prefixes=DEFAULT,COMMON
; RUN: llc < %s -mtriple=aarch64 -mattr=+mte -stack-tagging-unchecked-ld-st=never | FileCheck %s --check-prefixes=NEVER,COMMON
; RUN: llc < %s -mtriple=aarch64 -mattr=+mte -stack-tagging-unchecked-ld-st=always | FileCheck %s --check-prefixes=ALWAYS,COMMON

declare void @use8(i8*)
declare void @use32(i32*)
declare void @use2x64([2 x i64]*)
declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture)
declare void @llvm.lifetime.end.p0i8(i64, i8* nocapture)

define i32 @CallLd() sanitize_memtag {
entry:
  %x = alloca i32, align 4
  call void @use32(i32* %x)
  %a = load i32, i32* %x
  ret i32 %a
}

; COMMON:  CallLd:
; COMMON:  bl  use32

; ALWAYS:  ldr w0, [sp]
; DEFAULT: ldr w0, [sp]
; NEVER:   ldr w0, [x{{.*}}]

; COMMON:  ret

define void @CallStCall() sanitize_memtag {
entry:
  %x = alloca i32, align 4
  call void @use32(i32* %x)
  store i32 42, i32* %x
  call void @use32(i32* %x)
  ret void
}

; COMMON:  CallStCall:
; COMMON:  bl  use32

; ALWAYS:  str w{{.*}}, [sp]
; DEFAULT: str w{{.*}}, [sp]
; NEVER:   str w{{.*}}, [x{{.*}}]

; COMMON:  bl  use32
; COMMON:  ret

define void @CallStPair(i64 %z) sanitize_memtag {
entry:
  %x = alloca [2 x i64], align 8
  call void @use2x64([2 x i64]* %x)
  %x0 = getelementptr inbounds [2 x i64], [2 x i64]* %x, i64 0, i64 0
  store i64 %z, i64* %x0, align 8
  %x1 = getelementptr inbounds [2 x i64], [2 x i64]* %x, i64 0, i64 1
  store i64 %z, i64* %x1, align 8
  call void @use2x64([2 x i64]* %x)
  ret void
}

; COMMON:  CallStPair:
; COMMON:  bl  use2x64

; ALWAYS:  stp {{.*}}, [sp]
; DEFAULT: stp {{.*}}, [sp]
; NEVER:   stp {{.*}}, [x{{.*}}]

; COMMON:  bl  use2x64
; COMMON:  ret

; One of the two allocas will end up out of range of ldrb [sp].
define dso_local i8 @LargeFrame() sanitize_memtag {
entry:
  %x = alloca [4096 x i8], align 4
  %y = alloca [4096 x i8], align 4
  %0 = getelementptr inbounds [4096 x i8], [4096 x i8]* %x, i64 0, i64 0
  %1 = getelementptr inbounds [4096 x i8], [4096 x i8]* %y, i64 0, i64 0
  call void @use8(i8* %0)
  call void @use8(i8* %1)
  %2 = load i8, i8* %0, align 4
  %3 = load i8, i8* %1, align 4
  %add = add i8 %3, %2
  ret i8 %add
}

; COMMON: LargeFrame:
; COMMON: bl use8
; COMMON: bl use8

; NEVER:  ldrb [[A:w.*]], [x{{.*}}]
; NEVER:  ldrb [[B:w.*]], [x{{.*}}]

; DEFAULT:  ldrb [[A:w.*]], [x{{.*}}]
; DEFAULT:  ldrb [[B:w.*]], [x{{.*}}]

; ALWAYS: ldg [[PA:x.*]], [x{{.*}}]
; ALWAYS: ldrb [[B:w.*]], [sp]
; ALWAYS: ldrb [[A:w.*]], {{\[}}[[PA]]{{\]}}

; COMMON: add w0, [[B]], [[A]]
; COMMON: ret

; One of these allocas is closer to FP than to SP, and within 256 bytes
; of the former (see hardcoded limit in resolveFrameOffsetReference).
; It could be lowered to an FP-relative load, but not when doing an
; unchecked access to tagged memory!
define i8 @FPOffset() "frame-pointer"="all" sanitize_memtag {
  %x = alloca [200 x i8], align 4
  %y = alloca [200 x i8], align 4
  %z = alloca [200 x i8], align 4
  %x0 = getelementptr inbounds [200 x i8], [200 x i8]* %x, i64 0, i64 0
  %y0 = getelementptr inbounds [200 x i8], [200 x i8]* %y, i64 0, i64 0
  %z0 = getelementptr inbounds [200 x i8], [200 x i8]* %z, i64 0, i64 0
  call void @use8(i8* %x0)
  call void @use8(i8* %y0)
  call void @use8(i8* %z0)
  %x1 = load i8, i8* %x0, align 4
  %y1 = load i8, i8* %y0, align 4
  %z1 = load i8, i8* %z0, align 4
  %a = add i8 %x1, %y1
  %b = add i8 %a, %z1
  ret i8 %b
}

; COMMON: FPOffset:
; COMMON: bl use8
; COMMON: bl use8
; COMMON: bl use8

; All three loads are SP-based.
; ALWAYS-DAG: ldrb  w{{.*}}, [sp, #416]
; ALWAYS-DAG: ldrb  w{{.*}}, [sp, #208]
; ALWAYS-DAG: ldrb  w{{.*}}, [sp]

; DEFAULT-DAG: ldrb  w{{.*}}, [sp, #416]
; DEFAULT-DAG: ldrb  w{{.*}}, [sp, #208]
; DEFAULT-DAG: ldrb  w{{.*}}, [sp]

; NEVER-DAG: ldrb  w{{.*}}, [x{{.*}}]
; NEVER-DAG: ldrb  w{{.*}}, [x{{.*}}]
; NEVER-DAG: ldrb  w{{.*}}, [x{{.*}}]

; COMMON: ret
