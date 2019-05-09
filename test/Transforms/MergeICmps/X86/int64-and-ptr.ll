; RUN: opt < %s -mtriple=x86_64-unknown-unknown -mergeicmps -S | FileCheck %s --check-prefix=X86

; 8-byte int and 8-byte pointer should merge into a 16-byte memcmp.
; X86: memcmp(i8* {{.*}}, i8* {{.*}}, i64 16)

%struct.outer = type { i64, %struct.inner* }
%struct.inner = type { i32, i32, i32 }

; Function Attrs: nounwind uwtable
define dso_local i1 @"?foo@@YAHAEAUouter@@0@Z"(%struct.outer* align 8 dereferenceable(16) %o1, %struct.outer* align 8 dereferenceable(116) %o2) local_unnamed_addr #0 {
entry:
  %p1 = getelementptr inbounds %struct.outer, %struct.outer* %o1, i64 0, i32 0
  %0 = load i64, i64* %p1, align 8
  %p11 = getelementptr inbounds %struct.outer, %struct.outer* %o2, i64 0, i32 0
  %1 = load i64, i64* %p11, align 8
  %cmp = icmp eq i64 %0, %1
  br i1 %cmp, label %if.then, label %if.end5

if.then:                                          ; preds = %entry
  %p2 = getelementptr inbounds %struct.outer, %struct.outer* %o1, i64 0, i32 1
  %2 = load %struct.inner*, %struct.inner** %p2, align 8
  %p22 = getelementptr inbounds %struct.outer, %struct.outer* %o2, i64 0, i32 1
  %3 = load %struct.inner*, %struct.inner** %p22, align 8
  %cmp3 = icmp eq %struct.inner* %2, %3
  br label %if.end5

if.end5:                                          ; preds = %if.then, %entry
  %rez.0 = phi i1 [ %cmp3, %if.then ], [ false, %entry ]
  ret i1 %rez.0
}
; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64, i8* nocapture) #1

attributes #0 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind }
attributes #2 = { nounwind }
