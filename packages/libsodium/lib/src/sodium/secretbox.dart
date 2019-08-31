import '../bindings/sodiumbindings.dart';
import '../ffi/carray.dart';
import 'exception.dart';

class Secretbox {
  Uint8CArray _key = null;
  Uint8CArray _nonce = null;

  //constructors
  Secretbox._() {
    _key = Uint8CArray(keybytes());
    _nonce = Uint8CArray(noncebytes());

    sodiumbindings.crypto_secretbox_keygen(_key.ptr);
  }

  factory Secretbox([List<int> k = null]){
    if (k != null && k.length != keybytes()){
      return null;
    }

    Secretbox sb = Secretbox._();

    if (k != null) {
      sb.setKey(k);
    }

    return sb;
  }

  //private methods
  bool _cleared(){
    return (_key == null || _nonce == null);
  }

  // begin public methods
  // get/set methods
  bool setKey(List<int> k){
    if (_cleared()){
      throw CryptoException("Secretbox was cleared");
    }

    if (k == null || k.length != keybytes()){
      return false;
    }

    for(int i = 0; i < _key.length; i++){
      _key[i] = k[i];
    }

    return true;
  }

  List<int> getKey(){
    if (_cleared()){
      throw CryptoException("Secretbox was cleared");
    }

    List<int> list =  [];

    for (int i = 0; i < _key.length; i++){
      list.add(_key[i]);
    }

    return list;
  }

  // return [ciphertext, nonce] or null
  List<List<int>> encryptBytes(List<int> m){
    if (_cleared()){
      throw CryptoException("Secretbox was cleared");
    }

    if (m == null || m.length == 0){
      return null;
    }

    Uint8CArray c = Uint8CArray(m.length + macbytes());
    Uint8CArray msg = Uint8CArray(m.length);
    sodiumbindings.randombytes_buf(_nonce.ptr, _nonce.length);

    for (int i = 0; i < m.length; i++){
      msg[i] =  m[i];
    }

    int err = sodiumbindings.crypto_secretbox_easy(c.ptr, msg.ptr, msg.length, _nonce.ptr, _key.ptr);
    List<List<int>> out = null;

    // encrypt call was successful
    if (err == 0){
      out = [];
      List<int> n = new List<int>(_nonce.length);
      for (int i = 0; i < _nonce.length; i++){
        n[i] = _nonce[i];
      }

      List<int> cipher = new List<int>(c.length);
      for (int i = 0; i < c.length; i++){
        cipher[i] = c[i];
      }

      out.add(cipher);
      out.add(n);
    }

    c.zfree();
    msg.zfree();
    return out;
  }

  // return message as bytes or null
  List<int> decryptBytes(List<int> c, List<int> n){
    if (_cleared()){
      throw CryptoException("Secretbox was cleared");
    }

    if (c == null || n == null){
      return null;
    }

    if (c.length <= macbytes() || n.length != noncebytes()){
      throw InvalidCiphertext("Secretbox: decryption failed");
    }

    Uint8CArray cipher = Uint8CArray(c.length);
    Uint8CArray msg = Uint8CArray(c.length - macbytes());
    Uint8CArray cnonce = Uint8CArray(n.length);

    for (int i = 0; i < c.length; i++){
      cipher[i] = c[i];
    }

    for (int i = 0; i < n.length; i++){
      cnonce[i] = n[i];
    }

    int err = sodiumbindings.crypto_secretbox_open_easy(msg.ptr, cipher.ptr, cipher.length, cnonce.ptr, _key.ptr);
    List<int> out = null;

    // decrypt call was successful
    if (err == 0){
      List<int> m = new List<int>(msg.length);
      for (int i = 0; i < msg.length; i++){
        m[i] = msg[i];
      }

      out = m;
    }

    cipher.zfree();
    msg.zfree();
    cnonce.zfree();

    if (err != 0){
      throw InvalidCiphertext("Secretbox: decryption failed");
    }

    return out;
  }

  reKey(){
    if (_cleared()){
      throw CryptoException("Secretbox was cleared");
    }

    sodiumbindings.crypto_secretbox_keygen(_key.ptr);
  }

  // zero memory and free it
  clear(){
    if (_cleared()){
      throw CryptoException("Secretbox was cleared");
    }

    _key.zfree();
    _nonce.zfree();
    _key = null;
    _nonce = null;
  }

  // static methods
  static int keybytes(){
    return sodiumbindings.crypto_secretbox_keybytes();
  }

  static int noncebytes(){
    return sodiumbindings.crypto_secretbox_noncebytes();
  }

  static int macbytes(){
    return sodiumbindings.crypto_secretbox_macbytes();
  }
}