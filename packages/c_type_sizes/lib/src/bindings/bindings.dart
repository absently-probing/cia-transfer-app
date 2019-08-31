import "dart:ffi";

import "../ffi/dylib_utils.dart";

import "signatures.dart";

class _CtypeBindings {
  DynamicLibrary ctypes;

  int Function() get_size_of_size_t;

  int Function() get_size_of_int;

  _CtypeBindings(){
    ctypes = dlopenPlatformSpecific("c_types");

    get_size_of_size_t = ctypes
        .lookup<NativeFunction<get_size_of_size_t_native_t>>("get_size_of_size_t")
        .asFunction();

    get_size_of_int = ctypes
        .lookup<NativeFunction<get_size_of_int_native_t>>("get_size_of_int")
        .asFunction();
  }
}

_CtypeBindings _cachedBindings;
_CtypeBindings get bindings => _cachedBindings ??= _CtypeBindings();
