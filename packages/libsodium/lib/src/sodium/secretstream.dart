import '../bindings/bindings.dart';
import '../ffi/carray.dart';
import '../ffi/constant.dart';
import 'exception.dart';

enum Mode {
  none,
  push,
  pull
}

class Secretstream {
  Uint8CArray _state = null;
  Uint8CArray _key = null;
  Mode _mode = Mode.none;

  // constructor
  Secretstream._(this._state, this._key);

  factory Secretstream([List<int> k = null]){
    if (k != null && k.length != keybytes()){
      return null;
    }

    Uint8CArray key = Uint8CArray(keybytes());
    Uint8CArray state = Uint8CArray(statebytes());

    bindings.crypto_secretstream_xchacha20poly1305_keygen(key.ptr);

    if (k != null){
      for (int i = 0; i < key.length; i++){
        key[i] = k[i];
      }
    }

    return Secretstream._(state, key);
  }

  //private methods
  _cleared(){
    return _state == null || _key == null;
  }

  // create a new key (private method because the use case is rather complicated)
  // The decryption algorithm and encryption algorithm must use this function
  // at the exact same stream position
  _rekey(){
    if (_cleared()){
      throw CryptoException("Secretstream was cleared");
    }

    bindings.crypto_secretstream_xchacha20poly1305_rekey(_key.ptr);
  }

  // get methods
  List<int> getKey(){
    if (_cleared()){
      throw CryptoException("Secretstream was cleared");
    }

    List<int> out = new List<int>(_key.length);
    for (int i = 0; i < _key.length; i++){
      out[i] = _key[i];
    }

    return out;
  }

  // pull (decryption) methods
  bool pullInit(List<int> header){
    if (_cleared()){
      throw CryptoException("Secretstream was cleared");
    }

    if (header == null){
      return false;
    }

    if (header.length != headerbytes()){
      throw InvalidCiphertext("Secretstream: decryption failed");
    }

    Uint8CArray hdr = Uint8CArray(header.length);
    for (int i = 0; i < hdr.length; i++){
      hdr[i] = header[i];
    }

    int err = bindings.crypto_secretstream_xchacha20poly1305_init_pull(_state.ptr, hdr.ptr, _key.ptr);
    hdr.zfree();

    if (err != 0){
      throw CryptoException("Secretstream: unable to initialize decryption");
    }

    _mode = Mode.pull;
    return true;
  }

  // pull (decrypt) method
  // returns plaintext
  List<int> pull(List<int> c, int expected_tag, [List<int> ad = null]){
    if (_cleared()){
      throw CryptoException("Secretstream was cleared");
    }

    bool legit_tag = (expected_tag == tagMessage() || expected_tag == tagPush()
        || expected_tag == tagRekey() || expected_tag == tagFinal());

    if (c == null || !legit_tag || _mode != Mode.pull){
      return null;
    }

    if (c.length <= abytes() || c.length > messagebytesMax() + abytes()){
      throw InvalidCiphertext("Secretstream: decryption failed");
    }

    // init c call
    Uint8CArray additional = null;
    Uint8CArray cipher = Uint8CArray(c.length);
    Uint8CArray m = Uint8CArray(c.length - abytes());
    Uint8CArray tag = Uint8CArray(1);

    if (ad != null){
      additional = Uint8CArray(ad.length);

      for (int i = 0; i < additional.length; i++){
        additional[i] = ad[i];
      }
    }

    for (int i = 0; i < cipher.length; i++){
      cipher[i] = c[i];
    }

    // with or without additional data
    int err = 0;
    if (additional == null){
      err = bindings.crypto_secretstream_xchacha20poly1305_pull(_state.ptr, m.ptr, const_ptr.uint64_null, tag.ptr, cipher.ptr, cipher.length, const_ptr.uint8_null, 0);
    } else {
      err = bindings.crypto_secretstream_xchacha20poly1305_pull(_state.ptr, m.ptr, const_ptr.uint64_null, tag.ptr, cipher.ptr, cipher.length, additional.ptr, additional.length);
    }

    // create result
    List<int> out = null;
    if (err == 0 && expected_tag == tag[0]){
      out = List<int>(m.length);
      for (int i = 0; i < out.length; i++){
        out[i] = m[i];
      }
    }

    bool correctTag = expected_tag == tag[0];
    // free c stuff
    cipher.zfree();
    m.zfree();
    tag.zfree();
    if (additional != null){
      additional.zfree();
    }

    if (err != 0 || !correctTag){
      throw InvalidCiphertext("Secretstream: decryption failed");
    }

    return out;
  }

  // push (encryption) methods
  // returns header or null
  List<int> pushInit() {
    if (_cleared()){
      throw CryptoException("Secretstream was cleared");
    }

    Uint8CArray hdr = Uint8CArray(headerbytes());

    int err = bindings.crypto_secretstream_xchacha20poly1305_init_push(_state.ptr, hdr.ptr, _key.ptr);
    List<int> out = new List<int>(hdr.length);
    for (int i = 0; i < out.length; i++){
      out[i] = hdr[i];
    }

    hdr.zfree();

    if (err != 0){
      throw CryptoException("Secretstream: unable to initialize encryption");
    }

    _mode = Mode.push;
    return out;
  }

  // push (encrypt) method
  // returns ciphertext
  List<int> push(List<int> m, int tag, [List<int> ad = null]){
    if (_cleared()){
      throw CryptoException("Secretstream was cleared");
    }


    bool legit_tag = (tag == tagMessage() || tag == tagPush()
        || tag == tagRekey() || tag == tagFinal());

    if (m == null || m.length == 0 || m.length > messagebytesMax() || !legit_tag || _mode != Mode.push){
      return null;
    }

    // init c call
    Uint8CArray additional = null;
    Uint8CArray c = Uint8CArray(m.length + abytes());
    Uint8CArray msg = Uint8CArray(m.length);

    if (ad != null){
      additional = Uint8CArray(ad.length);

      for (int i = 0; i < additional.length; i++){
        additional[i] = ad[i];
      }
    }

    for (int i = 0; i < msg.length; i++){
      msg[i] = m[i];
    }

    // with or without additional data
    int err = 0;
    if (additional == null) {
      err = bindings.crypto_secretstream_xchacha20poly1305_push(_state.ptr, c.ptr, const_ptr.uint64_null, msg.ptr, msg.length, const_ptr.uint8_null, 0, tag);
    } else {
      err = bindings.crypto_secretstream_xchacha20poly1305_push(_state.ptr, c.ptr, const_ptr.uint64_null, msg.ptr, msg.length, additional.ptr, additional.length, tag);
    }

    // create result
    List<int> out = null;
    if (err == 0){
      out = new List<int>(c.length);
      for (int i = 0; i < out.length; i++){
        out[i] = c[i];
      }
    }

    // free c stuff
    c.zfree();
    msg.zfree();
    if (additional != null){
      additional.zfree();
    }

    return out;
  }

  clear(){
    if (_cleared()){
      throw CryptoException("Secretstream was cleared");
    }

    _mode = Mode.none;
    _state.zfree();
    _key.zfree();
    _state = null;
    _key = null;
  }
  // static methods
  static int keybytes(){
    return bindings.crypto_secretstream_xchacha20poly1305_keybytes();
  }

  static int headerbytes(){
    return bindings.crypto_secretstream_xchacha20poly1305_headerbytes();
  }

  static int abytes(){
    return bindings.crypto_secretstream_xchacha20poly1305_abytes();
  }

  static int statebytes(){
    return bindings.crypto_secretstream_xchacha20poly1305_statebytes();
  }

  // The maximum length of an individual message is
  // crypto_secretstream_xchacha20poly1305_MESSAGEBYTES_MAX bytes (~ 256 GB)
  static int messagebytesMax() {
    return bindings.crypto_secretstream_xchacha20poly1305_messagebytes_max();
  }

  // 0, or crypto_secretstream_xchacha20poly1305_TAG_MESSAGE: the most common
  // tag, that doesn't add any information about the nature of the message.
  static int tagMessage(){
    return bindings.crypto_secretstream_xchacha20poly1305_tag_message();
  }

  // crypto_secretstream_xchacha20poly1305_TAG_PUSH: indicates that the message
  // marks the end of a set of messages, but not the end of the stream. For
  // example, a huge JSON string sent as multiple chunks can use this tag to
  // indicate to the application that the string is complete and that it can be
  // decoded. But the stream itself is not closed, and more data may follow.
  static int tagPush(){
    return bindings.crypto_secretstream_xchacha20poly1305_tag_push();
  }

  // crypto_secretstream_xchacha20poly1305_TAG_REKEY: "forget" the key used to
  // encrypt this message and the previous ones, and derive a new secret key.
  static int tagRekey() {
    return bindings.crypto_secretstream_xchacha20poly1305_tag_rekey();
  }

  // crypto_secretstream_xchacha20poly1305_TAG_FINAL: indicates that the message
  // marks the end of the stream, and erases the secret key used to encrypt the
  // previous sequence.
  static int tagFinal() {
    return bindings.crypto_secretstream_xchacha20poly1305_tag_final();
  }
}