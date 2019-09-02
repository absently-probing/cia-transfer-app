import "dart:ffi";

import "../ffi/dylib_utils.dart";

import "signatures.dart";

class _CtypeBindings {
  DynamicLibrary ctypes;

  int Function() get_size_of_size_t;

  int Function() get_size_of_int;

  int Function() get_size_of_unsigned_long_long;

  int Function() get_size_of_unsigned_char;

  _CtypeBindings(){
    ctypes = dlopenPlatformSpecific("c_types");

    get_size_of_size_t = ctypes
        .lookup<NativeFunction<get_size_of_size_t_native_t>>("get_size_of_size_t")
        .asFunction();

    get_size_of_int = ctypes
        .lookup<NativeFunction<get_size_of_int_native_t>>("get_size_of_int")
        .asFunction();
    get_size_of_unsigned_long_long = ctypes
        .lookup<NativeFunction<get_size_of_unsigned_long_long_native_t>>("get_size_of_unsigned_long_long")
        .asFunction();
    get_size_of_unsigned_char = ctypes
        .lookup<NativeFunction<get_size_of_unsigned_char_native_t>>("get_size_of_unsigned_char")
        .asFunction();
  }
}

_CtypeBindings _cachedBindings;
_CtypeBindings get bindings => _cachedBindings ??= _CtypeBindings();
