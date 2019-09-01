library libsodium;

import 'src/sodium/kdf.dart';
import 'package:c_type_sizes/c_type_sizes.dart';

export 'src/sodium/exception.dart';
export 'src/sodium/secretbox.dart';
export 'src/sodium/secretstream.dart';
export 'src/sodium/kdf.dart';
export 'src/sodium/random.dart';

class Libsodium {
  static bool supported() {
    try {
      if (Ctypes.sizeofUnsignedLongLong() != 8 ||
          Ctypes.sizeofUnsignedChar() != 1) {
        return false;
      }

      if (Ctypes.sizeofInt() != 4 && Ctypes.sizeofInt() != 8) {
        return false;
      }

      if (Ctypes.sizeofSize_t() != 4 && Ctypes.sizeofSize_t() != 8) {
        return false;
      }

      Kdf();
    } catch (e){
      return false;
    }

    return true;
  }
}