# atomic builtins are required for threading support.

INCLUDE(CheckCXXSourceCompiles)

#ifdef _MSC_VER
#include <windows.h>
#endif
	
CHECK_CXX_SOURCE_COMPILES("
int main() {
#ifdef _MSC_VER
        volatile LONG val = 1;
        MemoryBarrier();
        InterlockedCompareExchange(&val, 0, 1);
        InterlockedIncrement(&val);
        InterlockedDecrement(&val);
#else
        volatile unsigned long val = 1;
        __sync_synchronize();
        __sync_val_compare_and_swap(&val, 1, 0);
        __sync_add_and_fetch(&val, 1);
        __sync_sub_and_fetch(&val, 1);
#endif
        return 0;
      }
" LLVM_MULTITHREADED)

if( NOT LLVM_MULTITHREADED )
  message(STATUS "Warning: LLVM will be built thread-unsafe because atomic builtins are missing")
endif()
