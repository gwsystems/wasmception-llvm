//===-- StringPool.h - Interned string pool -------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file was developed by Gordon Henriksen and is distributed under the
// University of Illinois Open Source License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares an interned string pool, which helps reduce the cost of
// strings by using the same storage for identical strings.
// 
// To intern a string:
// 
//   StringPool Pool;
//   PooledStringPtr Str = Pool.intern("wakka wakka");
// 
// To use the value of an interned string, use operator bool and operator*:
// 
//   if (Str)
//     cerr << "the string is" << *Str << "\n";
// 
// Pooled strings are immutable, but you can change a PooledStringPtr to point
// to another instance. So that interned strings can eventually be freed,
// strings in the string pool are reference-counted (automatically).
// 
//===----------------------------------------------------------------------===//

#ifndef LLVM_SUPPORT_STRINGPOOL_H
#define LLVM_SUPPORT_STRINGPOOL_H

#include <llvm/ADT/StringMap.h>
#include <new>
#include <cassert>

namespace llvm {

  class PooledStringPtr;

  /// StringPool - An interned string pool. Use the intern method to add a
  /// string. Strings are removed automatically as PooledStringPtrs are
  /// destroyed.
  class StringPool {
    struct PooledString {
      StringPool *Pool;  ///< So the string can remove itself.
      unsigned Refcount; ///< Number of referencing PooledStringPtrs.
      
    public:
      PooledString() : Pool(0), Refcount(0) { }
    };
    
    friend class PooledStringPtr;
    
    typedef StringMap<PooledString> table_t;
    typedef StringMapEntry<PooledString> entry_t;
    table_t InternTable;
    
  public:
    StringPool();
    ~StringPool();
    
    PooledStringPtr intern(const char *Begin, const char *End);
    inline PooledStringPtr intern(const char *Str);
  };
  
  /// PooledStringPtr - A pointer to an interned string. Use operator bool to
  /// test whether the pointer is valid, and operator * to get the string if so.
  /// This is a lightweight value class with storage requirements equivalent to
  /// a single pointer, but it does have reference-counting overhead when
  /// copied.
  class PooledStringPtr {
    typedef StringPool::entry_t entry_t;
    entry_t *S;
    
  public:
    PooledStringPtr() : S(0) {}
    
    explicit PooledStringPtr(entry_t *E) : S(E) {
      if (S) ++S->getValue().Refcount;
    }
    
    PooledStringPtr(const PooledStringPtr &That) : S(That.S) {
      if (S) ++S->getValue().Refcount;
    }
    
    PooledStringPtr &operator=(const PooledStringPtr &That) {
      if (S != That.S) {
        clear();
        S = That.S;
        if (S) ++S->getValue().Refcount;
      }
      return *this;
    }
    
    void clear() {
      if (!S)
        return;
      if (--S->getValue().Refcount == 0) {
        S->getValue().Pool->InternTable.remove(S);
        delete S;
      }
      S = 0;
    }
    
    ~PooledStringPtr() { clear(); }
    
    inline const char *begin() const {
      assert(*this && "Attempt to dereference empty PooledStringPtr!");
      return S->getKeyData();
    }
    
    inline const char *end() const {
      assert(*this && "Attempt to dereference empty PooledStringPtr!");
      return S->getKeyData() + S->getKeyLength();
    }
    
    inline unsigned size() const {
      assert(*this && "Attempt to dereference empty PooledStringPtr!");
      return S->getKeyLength();
    }
    
    inline const char *operator*() const { return begin(); }
    inline operator bool() const { return S != 0; }
    
    inline bool operator==(const PooledStringPtr &That) { return S == That.S; }
    inline bool operator!=(const PooledStringPtr &That) { return S != That.S; }
  };
  
  PooledStringPtr StringPool::intern(const char *Str) {
    return intern(Str, Str + strlen(Str));
  }

} // End llvm namespace

#endif
