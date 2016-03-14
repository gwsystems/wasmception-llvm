; RUN: llc -march=mipsel -mcpu=mips32r6 -relocation-model=static < %s | FileCheck %s

; Function Attrs: nounwind
define void @l()  {
entry:
  %call = tail call i32 @k()
  %call1 = tail call i32 @j()
  %cmp = icmp eq i32 %call, %call1
; CHECK: bnec
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry:
; CHECK: nop
; CHECK: jal
  tail call void @f(i32 signext -2)
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  ret void
}

declare i32 @k()

declare i32 @j()

declare void @f(i32 signext) 

; Function Attrs: define void @l2()  {
define void @l2()  {
entry:
  %call = tail call i32 @k()
  %call1 = tail call i32 @i()
  %cmp = icmp eq i32 %call, %call1
; CHECK beqc
  br i1 %cmp, label %if.end, label %if.then

if.then:                                          ; preds = %entry:
; CHECK: nop
; CHECK: jal
  tail call void @f(i32 signext -1)
  br label %if.end

if.end:                                           ; preds = %entry, %if.then
  ret void
}

declare i32 @i()

; Function Attrs: nounwind
define void @l3()  {
entry:
  %call = tail call i32 @k()
  %cmp = icmp slt i32 %call, 0
; CHECK : bgez
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry:
; CHECK: nop
; CHECK: jal
  tail call void @f(i32 signext 0)
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  ret void
}

; Function Attrs: nounwind
define void @l4()  {
entry:
  %call = tail call i32 @k()
  %cmp = icmp slt i32 %call, 1
; CHECK: bgtzc
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry:
; CHECK: nop
; CHECK: jal
  tail call void @f(i32 signext 1)
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  ret void
}

; Function Attrs: nounwind
define void @l5()  {
entry:
  %call = tail call i32 @k()
  %cmp = icmp sgt i32 %call, 0
; CHECK: blezc
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry:
; CHECK: nop
; CHECK: jal
  tail call void @f(i32 signext 2) 
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  ret void
}

; Function Attrs: nounwind
define void @l6()  {
entry:
  %call = tail call i32 @k()
  %cmp = icmp sgt i32 %call, -1
; CHECK: bltzc
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry:
; CHECK: nop
; CHECK: jal
  tail call void @f(i32 signext 3)
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  ret void
}

; Function Attrs: nounwind
define void @l7()  {
entry:
  %call = tail call i32 @k()
  %cmp = icmp eq i32 %call, 0
; CHECK: bnezc
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry:
; CHECK: nop
; CHECK: jal
  tail call void @f(i32 signext 4)
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  ret void
}

; Function Attrs: nounwind
define void @l8()  {
entry:
  %call = tail call i32 @k()
  %cmp = icmp eq i32 %call, 0
; CHECK: beqzc
  br i1 %cmp, label %if.end, label %if.then

if.then:                                          ; preds = %entry:
; CHECK: nop
; CHECK: jal
  tail call void @f(i32 signext 5)
  br label %if.end

if.end:                                           ; preds = %entry, %if.then
  ret void
}
