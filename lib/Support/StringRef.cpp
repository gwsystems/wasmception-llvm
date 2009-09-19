//===-- StringRef.cpp - Lightweight String References ---------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "llvm/ADT/StringRef.h"
using namespace llvm;

const size_t StringRef::npos;

/// GetAsUnsignedInteger - Workhorse method that converts a integer character
/// sequence of radix up to 36 to an unsigned long long value.
static bool GetAsUnsignedInteger(StringRef Str, unsigned Radix,
                                 unsigned long long &Result) {
  // Autosense radix if not specified.
  if (Radix == 0) {
    if (Str[0] != '0') {
      Radix = 10;
    } else {
      if (Str.size() < 2) {
        Radix = 8;
      } else {
        if (Str[1] == 'x') {
          Str = Str.substr(2);
          Radix = 16;
        } else if (Str[1] == 'b') {
          Str = Str.substr(2);
          Radix = 2;
        } else {
          Radix = 8;
        }
      }
    }
  }
  
  // Empty strings (after the radix autosense) are invalid.
  if (Str.empty()) return true;
  
  // Parse all the bytes of the string given this radix.  Watch for overflow.
  Result = 0;
  while (!Str.empty()) {
    unsigned CharVal;
    if (Str[0] >= '0' && Str[0] <= '9')
      CharVal = Str[0]-'0';
    else if (Str[0] >= 'a' && Str[0] <= 'z')
      CharVal = Str[0]-'a'+10;
    else if (Str[0] >= 'A' && Str[0] <= 'Z')
      CharVal = Str[0]-'A'+10;
    else
      return true;
    
    // If the parsed value is larger than the integer radix, the string is
    // invalid.
    if (CharVal >= Radix)
      return true;
    
    // Add in this character.
    unsigned long long PrevResult = Result;
    Result = Result*Radix+CharVal;
    
    // Check for overflow.
    if (Result < PrevResult)
      return true;

    Str = Str.substr(1);
  }
  
  return false;
}

bool StringRef::getAsInteger(unsigned Radix, unsigned long long &Result) const {
  return GetAsUnsignedInteger(*this, Radix, Result);
}


bool StringRef::getAsInteger(unsigned Radix, long long &Result) const {
  unsigned long long ULLVal;
  
  // Handle positive strings first.
  if (empty() || front() != '-') {
    if (GetAsUnsignedInteger(*this, Radix, ULLVal) ||
        // Check for value so large it overflows a signed value.
        (long long)ULLVal < 0)
      return true;
    Result = ULLVal;
    return false;
  }
  
  // Get the positive part of the value.
  if (GetAsUnsignedInteger(substr(1), Radix, ULLVal) ||
      // Reject values so large they'd overflow as negative signed, but allow
      // "-0".  This negates the unsigned so that the negative isn't undefined
      // on signed overflow.
      (long long)-ULLVal > 0)
    return true;
  
  Result = -ULLVal;
  return false;
}

bool StringRef::getAsInteger(unsigned Radix, int &Result) const {
  long long Val;
  if (getAsInteger(Radix, Val) ||
      (int)Val != Val)
    return true;
  Result = Val;
  return false;
}

bool StringRef::getAsInteger(unsigned Radix, unsigned &Result) const {
  unsigned long long Val;
  if (getAsInteger(Radix, Val) ||
      (unsigned)Val != Val)
    return true;
  Result = Val;
  return false;
}  
