; RUN: llvm-as < %s

;define float @foo({{i32},{float, double}}* %p) {
  ;%t = load {{i32},{float, double}}* %p
  ;%s = extractvalue {{i32},{float, double}} %t, i32 1, i32 0
  ;%r = insertvalue {{i32},{float, double}} %t, double 2.0, i32 1, i32 1
  ;store {{i32},{float, double}} %r, {{i32},{float, double}}* %p
  ;ret float %s
;}
define float @bar({{i32},{float, double}}* %p) {
  store {{i32},{float, double}} insertvalue ({{i32},{float, double}}{{i32}{i32 4},{float, double}{float 4.0, double 5.0}}, double 20.0, i32 1, i32 1), {{i32},{float, double}}* %p
  ret float extractvalue ({{i32},{float, double}}{{i32}{i32 3},{float, double}{float 7.0, double 9.0}}, i32 1, i32 0)
}
