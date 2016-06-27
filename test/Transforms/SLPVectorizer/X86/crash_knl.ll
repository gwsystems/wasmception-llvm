;RUN: opt < %s -slp-vectorizer -S

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: noreturn readonly uwtable
define void @_Z3fn1v(i32 %x, <16 x i32*>%y) local_unnamed_addr #0 {
entry:
  %conv42.le = sext i32 %x to i64
  %conv36109.le = zext i32 2 to i64
  %VectorGep = getelementptr i32, <16 x i32*> %y, i64 %conv36109.le
  %VectorGep208 = getelementptr i32, <16 x i32*> %y, i64 %conv42.le
  unreachable
}

attributes #0 = { noreturn readonly uwtable "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="knl" "target-features"="+adx,+aes,+avx,+avx2,+avx512cd,+avx512er,+avx512f,+avx512pf,+bmi,+bmi2,+cx16,+f16c,+fma,+fsgsbase,+fxsr,+lzcnt,+mmx,+movbe,+pclmul,+popcnt,+prefetchwt1,+rdrnd,+rdseed,+rtm,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave,+xsaveopt" "unsafe-fp-math"="false" "use-soft-float"="false" }

