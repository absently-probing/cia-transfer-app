import '../bindings/sodiumbindings.dart';
import '../ffi/carray.dart';
import 'exception.dart';
import 'package:c_type_sizes/c_type_sizes.dart';

import 'dart:convert';

class Kdf {
  Uint8CArray _masterKey = null;

  Kdf._(this._masterKey);

  factory Kdf([List<int> masterKey]){
    if (masterKey != null && masterKey.length != masterkeyBytes()){
      return null;
    }

    Uint8CArray master = Uint8CArray(masterkeyBytes());
    sodiumbindings.crypto_kdf_keygen(master.ptr);

    if (masterKey != null){
      for (int i = 0; i < master.length; i++){
        master[i] = masterKey[i];
      }
    }

    return Kdf._(master);
  }

  // private methods
  _cleared(){
    return _masterKey == null;
  }

  // public methods
  // get master key
  List<int> getMasterkey(){
    if (_cleared()){
      throw CryptoException("Kdf was cleared");
    }

    List<int> out = new List<int>(_masterKey.length);
    for (int i = 0; i < out.length; i++){
      out[i] = _masterKey[i];
    }

    return out;
  }

  // derive subkey from master key
  List<int> createSubkey(int subkeyLen, int id, List<int> context){
    if (_cleared()){
      throw CryptoException("Kdf was cleared");
    }

    if (context == null || subkeyLen < subkeyMinBytes() || subkeyLen > subkeyMaxBytes() || id < 0 || context.length != contextBytes()){
      return null;
    }

    Uint8CArray subkey = Uint8CArray(subkeyLen);
    Int8CArray ctx = Int8CArray(context.length);

    for (int i = 0; i < ctx.length; i++){
      ctx[i] = context[i];
    }

    int err = sodiumbindings.crypto_kdf_derive_from_key(subkey.ptr, subkey.length, id, ctx.ptr, _masterKey.ptr);

    List<int> out = null;
    if (err == 0){
      out = new List<int>(subkey.length);
      for (int i = 0; i < out.length; i++){
        out[i] = subkey[i];
      }
    }

    subkey.zfree();
    ctx.zfree();
    return out;
  }

  clear(){
    if (_cleared()){
      throw CryptoException("Kdf was cleared");
    }

    _masterKey.zfree();
  }

  // static methods
  // minimum length of subkey
  static int subkeyMinBytes(){
    return sodiumbindings.crypto_kdf_bytes_min();
  }

  // maximum length of subkey
  static int subkeyMaxBytes(){
    return sodiumbindings.crypto_kdf_bytes_max();
  }

  // sizeof context bytes
  static int contextBytes(){
    return sodiumbindings.crypto_kdf_contextbytes();
  }

  static int masterkeyBytes() {
    return sodiumbindings.crypto_kdf_keybytes();
  }

  static List<int> convertStringToCTX(String str){
    return Utf8Encoder().convert(str);
  }
}
