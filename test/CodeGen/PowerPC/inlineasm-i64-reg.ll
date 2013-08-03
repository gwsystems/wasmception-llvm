; RUN: llc -mtriple=powerpc64-bgq-linux -mcpu=a2 < %s | FileCheck %s
target datalayout = "E-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-f128:128:128-v128:128:128-n32:64"
target triple = "powerpc64-bgq-linux"

%struct.BG_CoordinateMapping_t = type { [4 x i8] }

; Function Attrs: alwaysinline inlinehint nounwind
define zeroext i32 @Kernel_RanksToCoords(i64 %mapsize, %struct.BG_CoordinateMapping_t* %map, i64* %numentries) #0 {
entry:
  %mapsize.addr = alloca i64, align 8
  %map.addr = alloca %struct.BG_CoordinateMapping_t*, align 8
  %numentries.addr = alloca i64*, align 8
  %r0 = alloca i64, align 8
  %r3 = alloca i64, align 8
  %r4 = alloca i64, align 8
  %r5 = alloca i64, align 8
  %tmp = alloca i64, align 8
  store i64 %mapsize, i64* %mapsize.addr, align 8
  store %struct.BG_CoordinateMapping_t* %map, %struct.BG_CoordinateMapping_t** %map.addr, align 8
  store i64* %numentries, i64** %numentries.addr, align 8
  store i64 1055, i64* %r0, align 8
  %0 = load i64* %mapsize.addr, align 8
  store i64 %0, i64* %r3, align 8
  %1 = load %struct.BG_CoordinateMapping_t** %map.addr, align 8
  %2 = ptrtoint %struct.BG_CoordinateMapping_t* %1 to i64
  store i64 %2, i64* %r4, align 8
  %3 = load i64** %numentries.addr, align 8
  %4 = ptrtoint i64* %3 to i64
  store i64 %4, i64* %r5, align 8
  %5 = load i64* %r0, align 8
  %6 = load i64* %r3, align 8
  %7 = load i64* %r4, align 8
  %8 = load i64* %r5, align 8
  %9 = call { i64, i64, i64, i64 } asm sideeffect "sc", "={r0},={r3},={r4},={r5},{r0},{r3},{r4},{r5},~{r6},~{r7},~{r8},~{r9},~{r10},~{r11},~{r12},~{cr0},~{memory}"(i64 %5, i64 %6, i64 %7, i64 %8) #1, !srcloc !0

; CHECK-LABEL: @Kernel_RanksToCoords

; These need to be 64-bit loads, not 32-bit loads (not lwz).
; CHECK-NOT: lwz

; CHECK: #APP
; CHECK: sc
; CHECK: #NO_APP

; CHECK: blr

  %asmresult = extractvalue { i64, i64, i64, i64 } %9, 0
  %asmresult1 = extractvalue { i64, i64, i64, i64 } %9, 1
  %asmresult2 = extractvalue { i64, i64, i64, i64 } %9, 2
  %asmresult3 = extractvalue { i64, i64, i64, i64 } %9, 3
  store i64 %asmresult, i64* %r0, align 8
  store i64 %asmresult1, i64* %r3, align 8
  store i64 %asmresult2, i64* %r4, align 8
  store i64 %asmresult3, i64* %r5, align 8
  %10 = load i64* %r3, align 8
  store i64 %10, i64* %tmp
  %11 = load i64* %tmp
  %conv = trunc i64 %11 to i32
  ret i32 %conv
}

attributes #0 = { alwaysinline inlinehint nounwind }
attributes #1 = { nounwind }

!0 = metadata !{i32 -2146895770}
