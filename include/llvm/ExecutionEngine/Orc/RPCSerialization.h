//===- llvm/ExecutionEngine/Orc/RPCSerialization.h --------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_EXECUTIONENGINE_ORC_RPCSERIALIZATION_H
#define LLVM_EXECUTIONENGINE_ORC_RPCSERIALIZATION_H

#include "OrcError.h"
#include "llvm/Support/thread.h"
#include <map>
#include <mutex>
#include <sstream>

namespace llvm {
namespace orc {
namespace rpc {

template <typename T>
class RPCTypeName;

/// TypeNameSequence is a utility for rendering sequences of types to a string
/// by rendering each type, separated by ", ".
template <typename... ArgTs> class RPCTypeNameSequence {};

/// Render an empty TypeNameSequence to an ostream.
template <typename OStream>
OStream &operator<<(OStream &OS, const RPCTypeNameSequence<> &V) {
  return OS;
}

/// Render a TypeNameSequence of a single type to an ostream.
template <typename OStream, typename ArgT>
OStream &operator<<(OStream &OS, const RPCTypeNameSequence<ArgT> &V) {
  OS << RPCTypeName<ArgT>::getName();
  return OS;
}

/// Render a TypeNameSequence of more than one type to an ostream.
template <typename OStream, typename ArgT1, typename ArgT2, typename... ArgTs>
OStream&
operator<<(OStream &OS, const RPCTypeNameSequence<ArgT1, ArgT2, ArgTs...> &V) {
  OS << RPCTypeName<ArgT1>::getName() << ", "
     << RPCTypeNameSequence<ArgT2, ArgTs...>();
  return OS;
}

template <>
class RPCTypeName<void> {
public:
  static const char* getName() { return "void"; }
};

template <>
class RPCTypeName<int8_t> {
public:
  static const char* getName() { return "int8_t"; }
};

template <>
class RPCTypeName<uint8_t> {
public:
  static const char* getName() { return "uint8_t"; }
};

template <>
class RPCTypeName<int16_t> {
public:
  static const char* getName() { return "int16_t"; }
};

template <>
class RPCTypeName<uint16_t> {
public:
  static const char* getName() { return "uint16_t"; }
};

template <>
class RPCTypeName<int32_t> {
public:
  static const char* getName() { return "int32_t"; }
};

template <>
class RPCTypeName<uint32_t> {
public:
  static const char* getName() { return "uint32_t"; }
};

template <>
class RPCTypeName<int64_t> {
public:
  static const char* getName() { return "int64_t"; }
};

template <>
class RPCTypeName<uint64_t> {
public:
  static const char* getName() { return "uint64_t"; }
};

template <>
class RPCTypeName<bool> {
public:
  static const char* getName() { return "bool"; }
};

template <>
class RPCTypeName<std::string> {
public:
  static const char* getName() { return "std::string"; }
};

template <>
class RPCTypeName<Error> {
public:
  static const char* getName() { return "Error"; }
};

template <typename T>
class RPCTypeName<Expected<T>> {
public:
  static const char* getName() {
    std::lock_guard<std::mutex> Lock(NameMutex);
    if (Name.empty())
      raw_string_ostream(Name) << "Expected<"
                               << RPCTypeNameSequence<T>()
                               << ">";
    return Name.data();
  }

private:
  static std::mutex NameMutex;
  static std::string Name;
};

template <typename T>
std::mutex RPCTypeName<Expected<T>>::NameMutex;

template <typename T>
std::string RPCTypeName<Expected<T>>::Name;

template <typename T1, typename T2>
class RPCTypeName<std::pair<T1, T2>> {
public:
  static const char* getName() {
    std::lock_guard<std::mutex> Lock(NameMutex);
    if (Name.empty())
      raw_string_ostream(Name) << "std::pair<" << RPCTypeNameSequence<T1, T2>()
                               << ">";
    return Name.data();
  }
private:
  static std::mutex NameMutex;
  static std::string Name;
};

template <typename T1, typename T2>
std::mutex RPCTypeName<std::pair<T1, T2>>::NameMutex;
template <typename T1, typename T2>
std::string RPCTypeName<std::pair<T1, T2>>::Name;

template <typename... ArgTs>
class RPCTypeName<std::tuple<ArgTs...>> {
public:
  static const char* getName() {
    std::lock_guard<std::mutex> Lock(NameMutex);
    if (Name.empty())
      raw_string_ostream(Name) << "std::tuple<"
                               << RPCTypeNameSequence<ArgTs...>() << ">";
    return Name.data();
  }
private:
  static std::mutex NameMutex;
  static std::string Name;
};

template <typename... ArgTs>
std::mutex RPCTypeName<std::tuple<ArgTs...>>::NameMutex;
template <typename... ArgTs>
std::string RPCTypeName<std::tuple<ArgTs...>>::Name;

template <typename T>
class RPCTypeName<std::vector<T>> {
public:
  static const char*getName() {
    std::lock_guard<std::mutex> Lock(NameMutex);
    if (Name.empty())
      raw_string_ostream(Name) << "std::vector<" << RPCTypeName<T>::getName()
                               << ">";
    return Name.data();
  }

private:
  static std::mutex NameMutex;
  static std::string Name;
};

template <typename T>
std::mutex RPCTypeName<std::vector<T>>::NameMutex;
template <typename T>
std::string RPCTypeName<std::vector<T>>::Name;


/// The SerializationTraits<ChannelT, T> class describes how to serialize and
/// deserialize an instance of type T to/from an abstract channel of type
/// ChannelT. It also provides a representation of the type's name via the
/// getName method.
///
/// Specializations of this class should provide the following functions:
///
///   @code{.cpp}
///
///   static const char* getName();
///   static Error serialize(ChannelT&, const T&);
///   static Error deserialize(ChannelT&, T&);
///
///   @endcode
///
/// The third argument of SerializationTraits is intended to support SFINAE.
/// E.g.:
///
///   @code{.cpp}
///
///   class MyVirtualChannel { ... };
///
///   template <DerivedChannelT>
///   class SerializationTraits<DerivedChannelT, bool,
///         typename std::enable_if<
///           std::is_base_of<VirtChannel, DerivedChannel>::value
///         >::type> {
///   public:
///     static const char* getName() { ... };
///   }
///
///   @endcode
template <typename ChannelT, typename WireType,
          typename ConcreteType = WireType, typename = void>
class SerializationTraits;

template <typename ChannelT>
class SequenceTraits {
public:
  static Error emitSeparator(ChannelT &C) { return Error::success(); }
  static Error consumeSeparator(ChannelT &C) { return Error::success(); }
};

/// Utility class for serializing sequences of values of varying types.
/// Specializations of this class contain 'serialize' and 'deserialize' methods
/// for the given channel. The ArgTs... list will determine the "over-the-wire"
/// types to be serialized. The serialize and deserialize methods take a list
/// CArgTs... ("caller arg types") which must be the same length as ArgTs...,
/// but may be different types from ArgTs, provided that for each CArgT there
/// is a SerializationTraits specialization
/// SerializeTraits<ChannelT, ArgT, CArgT> with methods that can serialize the
/// caller argument to over-the-wire value.
template <typename ChannelT, typename... ArgTs>
class SequenceSerialization;

template <typename ChannelT>
class SequenceSerialization<ChannelT> {
public:
  static Error serialize(ChannelT &C) { return Error::success(); }
  static Error deserialize(ChannelT &C) { return Error::success(); }
};

template <typename ChannelT, typename ArgT>
class SequenceSerialization<ChannelT, ArgT> {
public:

  template <typename CArgT>
  static Error serialize(ChannelT &C, CArgT &&CArg) {
    return SerializationTraits<ChannelT, ArgT,
                               typename std::decay<CArgT>::type>::
             serialize(C, std::forward<CArgT>(CArg));
  }

  template <typename CArgT>
  static Error deserialize(ChannelT &C, CArgT &CArg) {
    return SerializationTraits<ChannelT, ArgT, CArgT>::deserialize(C, CArg);
  }
};

template <typename ChannelT, typename ArgT, typename... ArgTs>
class SequenceSerialization<ChannelT, ArgT, ArgTs...> {
public:

  template <typename CArgT, typename... CArgTs>
  static Error serialize(ChannelT &C, CArgT &&CArg,
                         CArgTs &&... CArgs) {
    if (auto Err =
        SerializationTraits<ChannelT, ArgT, typename std::decay<CArgT>::type>::
          serialize(C, std::forward<CArgT>(CArg)))
      return Err;
    if (auto Err = SequenceTraits<ChannelT>::emitSeparator(C))
      return Err;
    return SequenceSerialization<ChannelT, ArgTs...>::
             serialize(C, std::forward<CArgTs>(CArgs)...);
  }

  template <typename CArgT, typename... CArgTs>
  static Error deserialize(ChannelT &C, CArgT &CArg,
                           CArgTs &... CArgs) {
    if (auto Err =
        SerializationTraits<ChannelT, ArgT, CArgT>::deserialize(C, CArg))
      return Err;
    if (auto Err = SequenceTraits<ChannelT>::consumeSeparator(C))
      return Err;
    return SequenceSerialization<ChannelT, ArgTs...>::deserialize(C, CArgs...);
  }
};

template <typename ChannelT, typename... ArgTs>
Error serializeSeq(ChannelT &C, ArgTs &&... Args) {
  return SequenceSerialization<ChannelT, typename std::decay<ArgTs>::type...>::
           serialize(C, std::forward<ArgTs>(Args)...);
}

template <typename ChannelT, typename... ArgTs>
Error deserializeSeq(ChannelT &C, ArgTs &... Args) {
  return SequenceSerialization<ChannelT, ArgTs...>::deserialize(C, Args...);
}

template <typename ChannelT>
class SerializationTraits<ChannelT, Error> {
public:

  using WrappedErrorSerializer =
    std::function<Error(ChannelT &C, const ErrorInfoBase&)>;

  using WrappedErrorDeserializer =
    std::function<Error(ChannelT &C, Error &Err)>;

  template <typename ErrorInfoT, typename SerializeFtor,
            typename DeserializeFtor>
  static void registerErrorType(std::string Name, SerializeFtor Serialize,
                                DeserializeFtor Deserialize) {
    assert(!Name.empty() &&
           "The empty string is reserved for the Success value");

    std::lock_guard<std::mutex> Lock(SerializersMutex);

    // We're abusing the stability of std::map here: We take a reference to the
    // key of the deserializers map to save us from duplicating the string in
    // the serializer. This should be changed to use a stringpool if we switch
    // to a map type that may move keys in memory.
    auto I =
      Deserializers.insert(Deserializers.begin(),
                           std::make_pair(std::move(Name),
                                          std::move(Deserialize)));

    const std::string &KeyName = I->first;
    // FIXME: Move capture Serialize once we have C++14.
    Serializers[ErrorInfoT::classID()] =
      [&KeyName, Serialize](ChannelT &C, const ErrorInfoBase &EIB) -> Error {
        assert(EIB.dynamicClassID() == ErrorInfoT::classID() &&
               "Serializer called for wrong error type");
        if (auto Err = serializeSeq(C, KeyName))
          return Err;
        return Serialize(C, static_cast<const ErrorInfoT&>(EIB));
      };
  }

  static Error serialize(ChannelT &C, Error &&Err) {
    std::lock_guard<std::mutex> Lock(SerializersMutex);
    if (!Err)
      return serializeSeq(C, std::string());

    return handleErrors(std::move(Err),
                        [&C](const ErrorInfoBase &EIB) {
                          auto SI = Serializers.find(EIB.dynamicClassID());
                          if (SI == Serializers.end())
                            return serializeAsStringError(C, EIB);
                          return (SI->second)(C, EIB);
                        });
  }

  static Error deserialize(ChannelT &C, Error &Err) {
    std::lock_guard<std::mutex> Lock(SerializersMutex);

    std::string Key;
    if (auto Err = deserializeSeq(C, Key))
      return Err;

    if (Key.empty()) {
      ErrorAsOutParameter EAO(&Err);
      Err = Error::success();
      return Error::success();
    }

    auto DI = Deserializers.find(Key);
    assert(DI != Deserializers.end() && "No deserializer for error type");
    return (DI->second)(C, Err);
  }

private:

  static Error serializeAsStringError(ChannelT &C, const ErrorInfoBase &EIB) {
    assert(EIB.dynamicClassID() != StringError::classID() &&
           "StringError serialization not registered");
    std::string ErrMsg;
    {
      raw_string_ostream ErrMsgStream(ErrMsg);
      EIB.log(ErrMsgStream);
    }
    return serialize(C, make_error<StringError>(std::move(ErrMsg),
                                                inconvertibleErrorCode()));
  }

  static std::mutex SerializersMutex;
  static std::map<const void*, WrappedErrorSerializer> Serializers;
  static std::map<std::string, WrappedErrorDeserializer> Deserializers;
};

template <typename ChannelT>
std::mutex SerializationTraits<ChannelT, Error>::SerializersMutex;

template <typename ChannelT>
std::map<const void*,
         typename SerializationTraits<ChannelT, Error>::WrappedErrorSerializer>
SerializationTraits<ChannelT, Error>::Serializers;

template <typename ChannelT>
std::map<std::string,
         typename SerializationTraits<ChannelT, Error>::WrappedErrorDeserializer>
SerializationTraits<ChannelT, Error>::Deserializers;

template <typename ChannelT>
void registerStringError() {
  static bool AlreadyRegistered = false;
  if (!AlreadyRegistered) {
    SerializationTraits<ChannelT, Error>::
      template registerErrorType<StringError>(
        "StringError",
        [](ChannelT &C, const StringError &SE) {
          return serializeSeq(C, SE.getMessage());
        },
        [](ChannelT &C, Error &Err) {
          ErrorAsOutParameter EAO(&Err);
          std::string Msg;
          if (auto E2 = deserializeSeq(C, Msg))
            return E2;
          Err =
            make_error<StringError>(std::move(Msg),
                                    orcError(
                                      OrcErrorCode::UnknownErrorCodeFromRemote));
          return Error::success();
        });
    AlreadyRegistered = true;
  }
};

/// SerializationTraits for Expected<T1> from an Expected<T2>.
template <typename ChannelT, typename T1, typename T2>
class SerializationTraits<ChannelT, Expected<T1>, Expected<T2>> {
public:

  static Error serialize(ChannelT &C, Expected<T2> &&ValOrErr) {
    if (ValOrErr) {
      if (auto Err = serializeSeq(C, true))
        return Err;
      return SerializationTraits<ChannelT, T1, T2>::serialize(C, *ValOrErr);
    }
    if (auto Err = serializeSeq(C, false))
      return Err;
    return serializeSeq(C, ValOrErr.takeError());
  }

  static Error deserialize(ChannelT &C, Expected<T2> &ValOrErr) {
    ExpectedAsOutParameter<T2> EAO(&ValOrErr);
    bool HasValue;
    if (auto Err = deserializeSeq(C, HasValue))
      return Err;
    if (HasValue)
      return SerializationTraits<ChannelT, T1, T2>::deserialize(C, *ValOrErr);
    Error Err = Error::success();
    if (auto E2 = deserializeSeq(C, Err))
      return E2;
    ValOrErr = std::move(Err);
    return Error::success();
  }
};

/// SerializationTraits for Expected<T1> from a T2.
template <typename ChannelT, typename T1, typename T2>
class SerializationTraits<ChannelT, Expected<T1>, T2> {
public:

  static Error serialize(ChannelT &C, T2 &&Val) {
    return serializeSeq(C, Expected<T2>(std::forward<T2>(Val)));
  }
};

/// SerializationTraits for Expected<T1> from an Error.
template <typename ChannelT, typename T>
class SerializationTraits<ChannelT, Expected<T>, Error> {
public:

  static Error serialize(ChannelT &C, Error &&Err) {
    return serializeSeq(C, Expected<T>(std::move(Err)));
  }
};

/// SerializationTraits default specialization for std::pair.
template <typename ChannelT, typename T1, typename T2>
class SerializationTraits<ChannelT, std::pair<T1, T2>> {
public:
  static Error serialize(ChannelT &C, const std::pair<T1, T2> &V) {
    return serializeSeq(C, V.first, V.second);
  }

  static Error deserialize(ChannelT &C, std::pair<T1, T2> &V) {
    return deserializeSeq(C, V.first, V.second);
  }
};

/// SerializationTraits default specialization for std::tuple.
template <typename ChannelT, typename... ArgTs>
class SerializationTraits<ChannelT, std::tuple<ArgTs...>> {
public:

  /// RPC channel serialization for std::tuple.
  static Error serialize(ChannelT &C, const std::tuple<ArgTs...> &V) {
    return serializeTupleHelper(C, V, llvm::index_sequence_for<ArgTs...>());
  }

  /// RPC channel deserialization for std::tuple.
  static Error deserialize(ChannelT &C, std::tuple<ArgTs...> &V) {
    return deserializeTupleHelper(C, V, llvm::index_sequence_for<ArgTs...>());
  }

private:
  // Serialization helper for std::tuple.
  template <size_t... Is>
  static Error serializeTupleHelper(ChannelT &C, const std::tuple<ArgTs...> &V,
                                    llvm::index_sequence<Is...> _) {
    return serializeSeq(C, std::get<Is>(V)...);
  }

  // Serialization helper for std::tuple.
  template <size_t... Is>
  static Error deserializeTupleHelper(ChannelT &C, std::tuple<ArgTs...> &V,
                                      llvm::index_sequence<Is...> _) {
    return deserializeSeq(C, std::get<Is>(V)...);
  }
};

/// SerializationTraits default specialization for std::vector.
template <typename ChannelT, typename T>
class SerializationTraits<ChannelT, std::vector<T>> {
public:

  /// Serialize a std::vector<T> from std::vector<T>.
  static Error serialize(ChannelT &C, const std::vector<T> &V) {
    if (auto Err = serializeSeq(C, static_cast<uint64_t>(V.size())))
      return Err;

    for (const auto &E : V)
      if (auto Err = serializeSeq(C, E))
        return Err;

    return Error::success();
  }

  /// Deserialize a std::vector<T> to a std::vector<T>.
  static Error deserialize(ChannelT &C, std::vector<T> &V) {
    uint64_t Count = 0;
    if (auto Err = deserializeSeq(C, Count))
      return Err;

    V.resize(Count);
    for (auto &E : V)
      if (auto Err = deserializeSeq(C, E))
        return Err;

    return Error::success();
  }
};

} // end namespace rpc
} // end namespace orc
} // end namespace llvm

#endif // LLVM_EXECUTIONENGINE_ORC_RPCSERIALIZATION_H
