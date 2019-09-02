import '../bindings/sodiumbindings.dart';
import '../ffi/carray.dart';
import 'exception.dart';

class Random {
  static List<int> randomBytes(int size){
    if (size <= 0){
      throw CryptoException('Random: illegal size');
    }

    Uint8CArray rbytes = Uint8CArray(size);
    sodiumbindings.randombytes_buf(rbytes.ptr, rbytes.length);
    List<int> rand = List<int>(size);
    for (int i = 0; i < rand.length; i++){
      rand[i] = rbytes[i];
    }

    rbytes.zfree();
    return rand;
  }
}