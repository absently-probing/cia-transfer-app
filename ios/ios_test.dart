import 'dart:ffi';

typedef NativeBinaryOp = Uint64 Function();
typedef DartSignature = int Function();

class Simple {
  static int SimpleTest() {
    final ex = DynamicLibrary.executable();
    final nativeSum = ex.lookupFunction<NativeBinaryOp, DartSignature>("get_size_of_size_t");
    return nativeSum();
  }
}