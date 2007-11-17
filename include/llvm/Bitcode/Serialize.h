//==- Serialize.h - Generic Object Serialization to Bitcode -------*- C++ -*-=//
//
//                     The LLVM Compiler Infrastructure
//
// This file was developed by Ted Kremenek and is distributed under the
// University of Illinois Open Source License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines the interface for generic object serialization to
// LLVM bitcode.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_BITCODE_SERIALIZE_OUTPUT
#define LLVM_BITCODE_SERIALIZE_OUTPUT

#include "llvm/Bitcode/Serialization.h"
#include "llvm/Bitcode/BitstreamWriter.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/DenseMap.h"

namespace llvm {

class Serializer {
  BitstreamWriter& Stream;
  SmallVector<uint64_t,10> Record;
  unsigned BlockLevel;
  
  typedef DenseMap<const void*,unsigned> MapTy;
  MapTy PtrMap;
  
public:
  Serializer(BitstreamWriter& stream);
  ~Serializer();
  
  template <typename T>
  inline void Emit(const T& X) { SerializeTrait<T>::Emit(*this,X); }
  
  void EmitInt(uint64_t X);
  void EmitSInt(int64_t X);
  
  void EmitBool(bool X) { EmitInt(X); }
  void EmitCStr(const char* beg, const char* end);
  void EmitCStr(const char* cstr);
  
  void EmitPtr(const void* ptr) { EmitInt(getPtrId(ptr)); }

  SerializedPtrID EmitPtr(const void* ptr,bool) {
    SerializedPtrID ptr_id = getPtrId(ptr);
    EmitInt(ptr_id);
    return ptr_id;
  }
  
  SerializedPtrID EmitDiffPtrID(const void* ptr, SerializedPtrID PrevID) {
    assert (!isRegistered(ptr));
    SerializedPtrID ptr_id = getPtrId(ptr);

    if (ptr_id == 0)
      EmitInt(0);
    else {
      assert (ptr_id > PrevID);
      EmitInt(ptr_id-PrevID);
    }
    
    return ptr_id;    
  }    
    
  
  template <typename T>
  void EmitRef(const T& ref) { EmitPtr(&ref); }
  
  template <typename T>
  void EmitOwnedPtr(T* ptr) {
    EmitPtr(ptr);
    if (ptr) SerializeTrait<T>::Emit(*this,*ptr);
  }
  
  template <typename T1, typename T2>
  void BatchEmitOwnedPtrs(T1* p1, T2* p2) {
    // Optimization: Only emit the differences between the IDs.  Most of
    // the time this difference will be "1", thus resulting in fewer bits.
    assert (!isRegistered(p1));
    assert (!isRegistered(p2));
    
    EmitDiffPtrID(p2,EmitPtr(p1,true));

    if (p1) SerializeTrait<T1>::Emit(*this,*p1);
    if (p2) SerializeTrait<T2>::Emit(*this,*p2);    
  }

  template <typename T1, typename T2, typename T3>
  void BatchEmitOwnedPtrs(T1* p1, T2* p2, T3* p3) {
    EmitDiffPtrID(p3,EmitDiffPtrID(p2,EmitPtr(p1)));

    if (p1) SerializeTrait<T1>::Emit(*this,*p1);
    if (p2) SerializeTrait<T2>::Emit(*this,*p2);
    if (p3) SerializeTrait<T3>::Emit(*this,*p3);
  }
  
  template <typename T1, typename T2, typename T3, typename T4>
  void BatchEmitOwnedPtrs(T1* p1, T2* p2, T3* p3, T4& p4) {
    EmitDiffPtrID(p4,EmitDiffPtrID(p3,EmitDiffPtrID(p2,EmitPtr(p1))));

    if (p1) SerializeTrait<T1>::Emit(*this,*p1);
    if (p2) SerializeTrait<T2>::Emit(*this,*p2);
    if (p3) SerializeTrait<T3>::Emit(*this,*p3);
    if (p4) SerializeTrait<T4>::Emit(*this,*p4);
  }

  template <typename T>
  void BatchEmitOwnedPtrs(unsigned NumPtrs, T* const * Ptrs) {
    SerializedPtrID ID;
    
    for (unsigned i = 0; i < NumPtrs; ++i) {
      if (i == 0) ID = EmitPtr(Ptrs[i],true);
      else ID = EmitDiffPtrID(Ptrs[i],ID);
    }

    for (unsigned i = 0; i < NumPtrs; ++i)
      if (Ptrs[i]) SerializeTrait<T>::Emit(*this,*Ptrs[i]);
  }
  
  template <typename T1, typename T2>
  void BatchEmitOwnedPtrs(unsigned NumT1Ptrs, T1* const * Ptrs, T2* p2) {
    
    SerializedPtrID ID = EmitPtr(p2,true);

    for (unsigned i = 0; i < NumT1Ptrs; ++i)
      ID = EmitDiffPtrID(Ptrs[i],ID);
    
    if (p2) SerializeTrait<T2>::Emit(*this,*p2);
    
    for (unsigned i = 0; i < NumT1Ptrs; ++i)
      if (Ptrs[i]) SerializeTrait<T1>::Emit(*this,*Ptrs[i]);    
  }
  
  template <typename T1, typename T2, typename T3>
  void BatchEmitOwnedPtrs(unsigned NumT1Ptrs, T1* const * Ptrs,
                          T2* p2, T3* p3) {
    
    SerializedPtrID TempID = EmitDiffPtrID(p3,EmitPtr(p2,true));
    
    for (unsigned i = 0; i < NumT1Ptrs; ++i)
      TempID = EmitDiffPtrID(Ptrs[i],TempID);
    
    if (p2) SerializeTrait<T2>::Emit(*this,*p2);
    if (p3) SerializeTrait<T3>::Emit(*this,*p3);
    
    for (unsigned i = 0; i < NumT1Ptrs; ++i)
      if (Ptrs[i]) SerializeTrait<T1>::Emit(*this,*Ptrs[i]);
    
  }
    
  bool isRegistered(const void* p) const;
  
  void FlushRecord() { if (inRecord()) EmitRecord(); }  
  void EnterBlock(unsigned BlockID = 8, unsigned CodeLen = 3);
  void ExitBlock();    
  
private:
  void EmitRecord();
  inline bool inRecord() { return Record.size() > 0; }
  SerializedPtrID getPtrId(const void* ptr);
};

} // end namespace llvm
#endif
