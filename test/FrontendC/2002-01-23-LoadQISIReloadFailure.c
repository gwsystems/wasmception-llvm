// RUN: %llvmgcc -S %s -o - | llvm-as -o /dev/null

/* Regression test.  Just compile .c -> .ll to test */
int foo(void) {
  unsigned char *pp;
  unsigned w_cnt;

  w_cnt += *pp;
  
  return w_cnt;
}
