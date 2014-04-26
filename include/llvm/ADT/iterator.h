//===- iterator.h - Utilities for using and defining iterators --*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_ADT_ITERATOR_H
#define LLVM_ADT_ITERATOR_H

#include <iterator>
#include <cstddef>

namespace llvm {

/// \brief CRTP base class which implements the entire standard iterator facade
/// in terms of a minimal subset of the interface.
///
/// Use this when it is reasonable to implement most of the iterator
/// functionality in terms of a core subset. If you need special behavior or
/// there are performance implications for this, you may want to override the
/// relevant members instead.
///
/// Note, one abstraction that this does *not* provide is implementing
/// subtraction in terms of addition by negating the difference. Negation isn't
/// always information preserving, and I can see very reasonable iterator
/// designs where this doesn't work well. It doesn't really force much added
/// boilerplate anyways.
///
/// Another abstraction that this doesn't provide is implementing increment in
/// terms of addition of one. These aren't equivalent for all iterator
/// categories, and respecting that adds a lot of complexity for little gain.
template <typename DerivedT, typename IteratorCategoryT, typename T,
          typename DifferenceTypeT = std::ptrdiff_t, typename PointerT = T *,
          typename ReferenceT = T &>
struct iterator_facade_base
    : std::iterator<IteratorCategoryT, T, DifferenceTypeT, PointerT,
                    ReferenceT> {
  DerivedT operator+(DifferenceTypeT n) const {
    DerivedT tmp = *static_cast<const DerivedT *>(this);
    tmp += n;
    return tmp;
  }
  friend DerivedT operator+(DifferenceTypeT n, const DerivedT &i) {
    return i + n;
  }
  DerivedT operator-(DifferenceTypeT n) const {
    DerivedT tmp = *static_cast<const DerivedT *>(this);
    tmp -= n;
    return tmp;
  }

  DerivedT &operator++() {
    return static_cast<DerivedT *>(this)->operator+=(1);
  }
  DerivedT operator++(int) {
    DerivedT tmp = *static_cast<DerivedT *>(this);
    ++*static_cast<DerivedT *>(this);
    return tmp;
  }
  DerivedT &operator--() {
    return static_cast<DerivedT *>(this)->operator-=(1);
  }
  DerivedT operator--(int) {
    DerivedT tmp = *static_cast<DerivedT *>(this);
    --*static_cast<DerivedT *>(this);
    return tmp;
  }

  bool operator!=(const DerivedT &RHS) const {
    return !static_cast<const DerivedT *>(this)->operator==(RHS);
  }

  bool operator>(const DerivedT &RHS) const {
    return !static_cast<const DerivedT *>(this)->operator<(RHS) &&
           !static_cast<const DerivedT *>(this)->operator==(RHS);
  }
  bool operator<=(const DerivedT &RHS) const {
    return !static_cast<const DerivedT *>(this)->operator>(RHS);
  }
  bool operator>=(const DerivedT &RHS) const {
    return !static_cast<const DerivedT *>(this)->operator<(RHS);
  }

  PointerT operator->() const {
    return &static_cast<const DerivedT *>(this)->operator*();
  }
  ReferenceT operator[](DifferenceTypeT n) const {
    return *static_cast<const DerivedT *>(this)->operator+(n);
  }
};

/// \brief CRTP base class for adapting an iterator to a different type.
///
/// This class can be used through CRTP to adapt one iterator into another.
/// Typically this is done through providing in the derived class a custom \c
/// operator* implementation. Other methods can be overridden as well.
template <typename DerivedT, typename WrappedIteratorT, typename T,
          typename PointerT = T *, typename ReferenceT = T &,
          // Don't provide these, they are mostly to act as aliases below.
          typename WrappedTraitsT = std::iterator_traits<WrappedIteratorT>>
class iterator_adaptor_base
    : public iterator_facade_base<
          DerivedT, typename WrappedTraitsT::iterator_category, T,
          typename WrappedTraitsT::difference_type, PointerT, ReferenceT> {
  typedef typename iterator_adaptor_base::iterator_facade_base BaseT;

protected:
  WrappedIteratorT I;

  iterator_adaptor_base() {}

  template <typename U>
  explicit iterator_adaptor_base(
      U &&u,
      typename std::enable_if<
          !std::is_base_of<typename std::remove_cv<
                               typename std::remove_reference<U>::type>::type,
                           DerivedT>::value,
          int>::type = 0)
      : I(std::forward<U &&>(u)) {}

public:
  typedef typename WrappedTraitsT::difference_type difference_type;

  DerivedT &operator+=(difference_type n) {
    I += n;
    return *static_cast<DerivedT *>(this);
  }
  DerivedT &operator-=(difference_type n) {
    I -= n;
    return *static_cast<DerivedT *>(this);
  }
  using BaseT::operator-;
  difference_type operator-(const DerivedT &RHS) const { return I - RHS.I; }

  // We have to explicitly provide ++ and -- rather than letting the facade
  // forward to += because WrappedIteratorT might not support +=.
  using BaseT::operator++;
  DerivedT &operator++() {
    ++I;
    return *static_cast<DerivedT *>(this);
  }
  using BaseT::operator--;
  DerivedT &operator--() {
    --I;
    return *static_cast<DerivedT *>(this);
  }

  bool operator==(const DerivedT &RHS) const { return I == RHS.I; }
  bool operator<(const DerivedT &RHS) const { return I < RHS.I; }

  ReferenceT operator*() const { return *I; }
};

/// \brief An iterator type that allows iterating over the pointees via some
/// other iterator.
///
/// The typical usage of this is to expose a type that iterates over Ts, but
/// which is implemented with some iterator over T*s:
///
/// \code
///   typedef pointee_iterator<SmallVectorImpl<T *>::iterator> iterator;
/// \endcode
template <typename WrappedIteratorT,
          typename T = typename std::remove_reference<
              decltype(**std::declval<WrappedIteratorT>())>::type>
struct pointee_iterator
    : iterator_adaptor_base<pointee_iterator<WrappedIteratorT>,
                            WrappedIteratorT, T> {
  pointee_iterator() {}
  template <typename U>
  pointee_iterator(U &&u)
      : pointee_iterator::iterator_adaptor_base(std::forward<U &&>(u)) {}

  T &operator*() const { return **this->I; }
};

}

#endif
