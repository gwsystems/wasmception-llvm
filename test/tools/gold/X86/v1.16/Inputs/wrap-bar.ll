target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define hidden void @bar() {
  ret void
}

define hidden void @__real_bar() {
  ret void
}

define hidden void @__wrap_bar() {
  ret void
}
