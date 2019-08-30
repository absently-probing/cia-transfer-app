library cryptapi;

import 'dart:io';
import 'package:libsodium/libsodium.dart';
export 'package:libsodium/libsodium.dart';

enum CryptoMode { none, enc, dec }

class Filecrypt {
  Kdf _kdf = null;
  int _id = 0;
  Secretstream _stream = null;
  CryptoMode _mode = CryptoMode.none;
  RandomAccessFile _input = null;
  int _processed = 0;

  static const int bufferSize = 1024 * 1024;

  Filecrypt._(this._kdf);

  factory Filecrypt([List<int> key = null]) {
    if (key != null && key.length != Kdf.masterkeyBytes()) {
      return null;
    }

    Kdf kdf = key != null ? Kdf(key) : Kdf();
    return Filecrypt._(kdf);
  }

  // private methods
  _cleared() {
    return _kdf == null;
  }

  // read _input encrypt it and write ciphertext into buffer
  _intoBufferEncrypt(length) {
    int read = 0;
    List<int> out = [];
    if (_processed == 0) {
      out = out + _stream.pushInit();
    }

    // bufferSize = plaintext size
    List<int> buffer = new List<int>(bufferSize);
    List<int> m = null;
    List<int> c = null;
    read = _input.readIntoSync(buffer);
    _processed = _processed + read;
    var tag = length - _processed > 0
        ? Secretstream.tagMessage()
        : Secretstream.tagFinal();
    m = read == buffer.length ? buffer : buffer.sublist(0, read);
    c = _stream.push(m, tag);
    out = out + c;
    m.fillRange(0, m.length, 0);
    return out;
  }

  // read _input decrypt it and write plaintext into buffer
  _intoBufferDecrypt(length) {
    int read = 0;
    if (_processed == 0) {
      List<int> header = new List<int>(Secretstream.headerbytes());
      read = _input.readIntoSync(header);
      _processed = _processed + read;
      _stream.pullInit(header);
    }

    // bufferSize + abytes = ciphertext
    List<int> buffer = new List<int>(bufferSize + Secretstream.abytes());
    List<int> m = null;
    List<int> c = null;
    read = _input.readIntoSync(buffer);
    _processed = _processed + read;
    var tag = length - _processed > 0
        ? Secretstream.tagMessage()
        : Secretstream.tagFinal();
    c = read == buffer.length ? buffer : buffer.sublist(0, read);
    m = _stream.pull(c, tag);
    return m;
  }

  // read _input encrypt it and write ciphertext into out
  _intoFileEncrypt(RandomAccessFile out, int length,
      Function(int state, int quota, bool done) callback) {
    int read = 0;
    out.writeFromSync(_stream.pushInit());
    // bufferSize = plaintext size
    List<int> buffer = new List<int>(bufferSize);
    List<int> m = null;
    List<int> c = null;
    do {
      read = _input.readIntoSync(buffer);
      _processed = _processed + read;
      var tag = length - _processed > 0
          ? Secretstream.tagMessage()
          : Secretstream.tagFinal();
      m = read == buffer.length ? buffer : buffer.sublist(0, read);
      c = _stream.push(m, tag);
      out.writeFromSync(c);

      if (callback != null) {
        callback(_processed, length, false);
      }
    } while (length - _processed > 0);

    buffer.fillRange(0, buffer.length, 0);
    if (m != null) {
      m.fillRange(0, m.length, 0);
    }

    if (c != null) {
      c.fillRange(0, c.length, 0);
    }
  }

  // read _input decrypt and write plaintext into out
  _intoFileDecrypt(RandomAccessFile out, int length,
      Function(int state, int quota, bool done) callback) {
    int read = 0;
    // bufferSize + abytes = ciphertext size
    List<int> buffer = new List<int>(bufferSize + Secretstream.abytes());
    List<int> m = null;
    List<int> c = null;
    List<int> header = new List<int>(Secretstream.headerbytes());
    read = _input.readIntoSync(header);
    _processed = _processed + read;
    _stream.pullInit(header);
    while (length - _processed > 0) {
      read = _input.readIntoSync(buffer);
      _processed = _processed + read;
      var tag = length - _processed > 0
          ? Secretstream.tagMessage()
          : Secretstream.tagFinal();
      c = read == buffer.length ? buffer : buffer.sublist(0, read);
      m = _stream.pull(c, tag);
      out.writeFromSync(m);

			if (callback != null) {
				callback(_processed, length, false);
			}
    }

    buffer.fillRange(0, buffer.length, 0);
    if (m != null) {
      m.fillRange(0, m.length, 0);
    }

    if (c != null) {
      c.fillRange(0, c.length, 0);
    }
  }

  // get key
  getKey() {
    if (_cleared()) {
      throw CryptoException("Fliecrypt was cleared");
    }

    return _kdf.getMasterkey();
  }

  // get recently used subkey id
  int getId() {
    if (_cleared()) {
      throw CryptoException("Fliecrypt was cleared");
    }

    return _id - 1;
  }

  // init file encryption
  init(File input, CryptoMode mode, [int startId = -1]) {
    if (_cleared()) {
      throw CryptoException("Fliecrypt was cleared");
    }

    if (input == null || (mode != CryptoMode.enc && mode != CryptoMode.dec)) {
      throw CryptoException("Filecrypt: wrong mode");
    }

    if (_stream != null) {
      _stream.clear();
      _stream = null;
    }

    if (_input != null) {
      _input.close();
      _input = null;
    }

    _input = input.openSync(mode: FileMode.read);
    _processed = 0;
    _id = startId >= 0 ? startId : _id;

    List<int> subkey = _kdf.createSubkey(Secretstream.keybytes(), _id,
        Kdf.convertStringToCTX(Filecrypt._context()));
    if (subkey == null) {
      clear();
      throw CryptoException(
          "Filecrypt: unable to create subkey for encryption (internal error)");
    }

    _id = _id + 1;
    _stream = Secretstream(subkey);
    if (_stream == null) {
      clear();
      throw CryptoException(
          "Filecrypt: unable to create stream (internal error)");
    }

    _mode = mode;
  }

  // write decryption / encryption to file
  // encrypt or decrypt input file and write to output file
  bool writeIntoFile(File output,
      {Function(int state, int quota, bool done) callback = null}) {
    if (_cleared()) {
      throw CryptoException("Fliecrypt was cleared");
    }

    if (_input == null ||
        _stream == null ||
        output == null ||
        (_mode != CryptoMode.enc && _mode != CryptoMode.dec) ||
        _processed != 0 ||
        _input.lengthSync() <= 0) {
      return false;
    }

    if (_mode == CryptoMode.dec &&
        _input.lengthSync() <= Secretstream.headerbytes()) {
      throw InvalidCiphertext("Filecrypt: decryption failed");
    }

    int length = _input.lengthSync();
    var out = output.openSync(mode: FileMode.writeOnly);

    try {
      if (_mode == CryptoMode.enc) {
        // start encryption
        _intoFileEncrypt(out, length, callback);
      } else {
        // start decryption
        _intoFileDecrypt(out, length, callback);
      }
    } on CryptoException {
      out.close();
      _input.close();
      _input = null;
      _stream.clear();
      _stream = null;
      throw CryptoException(
          "Filecrypt: failed to encrypt/decrypt (internal error)");
    } catch (e) {
      out.close();
      _input.close();
      _input = null;
      _stream.clear();
      _stream = null;
      throw e;
    }

    _input.close();
    out.close();
    _input = null;
    _stream.clear();
    _stream = null;

    if (callback != null){
    	callback(1, 1, true);
		}

    return true;
  }

  // CryptoMode.enc: encrypt one message from _input file and return ciphertext
  // CryptoMode.dec: decrypt one message from _input file and return plaintext
  List<int> writePartIntoBuffer() {
    if (_cleared()) {
      throw CryptoException("Fliecrypt was cleared");
    }

    if (_input == null ||
        _stream == null ||
        (_mode != CryptoMode.enc && _mode != CryptoMode.dec) ||
        _input.lengthSync() <= 0) {
      return null;
    }

    if (_mode == CryptoMode.dec &&
        _input.lengthSync() <= Secretstream.headerbytes()) {
      throw InvalidCiphertext("Filecrypt: decryption failed");
    }

    int length = _input.lengthSync();
    List<int> out = null;
    try {
      if (_mode == CryptoMode.enc) {
        // encryption
        out = _intoBufferEncrypt(length);
      } else {
        // decryption
        out = _intoBufferDecrypt(length);
      }
    } on CryptoException {
      _input.close();
      _input = null;
      _stream.clear();
      _stream = null;
      throw CryptoException(
          "Filecrypt: failed to encrypt/decrypt (internal error)");
    } catch (e) {
      _input.close();
      _input = null;
      _stream.clear();
      _stream = null;
      throw e;
    }

    if (_processed == length) {
      _input.close();
      _input = null;
      _stream.clear();
      _stream = null;
    }

    return out;
  }

  // encrypt/decrypt complete _input File and return ciphertext/plaintext
  List<int> writeAllIntoBuffer() {
    if (_cleared()) {
      throw CryptoException("Fliecrypt was cleared");
    }

    if (_input == null ||
        _stream == null ||
        (_mode != CryptoMode.enc && _mode != CryptoMode.dec) ||
        _processed != 0 ||
        _input.lengthSync() <= 0) {
      return null;
    }

    List<int> output = [];
    List<int> part = null;

    if (_mode == CryptoMode.enc) {
      // encryption
      do {
        part = writePartIntoBuffer();
        if (part != null) {
          output = output + part;
        }
      } while (part != null);
    } else {
      // decryption
      do {
        part = writePartIntoBuffer();
        if (part != null) {
          output = output + part;
        }
      } while (part != null);
    }

    return output;
  }

  clear() {
    if (_cleared()) {
      throw CryptoException("Fliecrypt was cleared");
    }

    _kdf.clear();
    _kdf = null;

    if (_stream != null) {
      _stream.clear();
      _stream = null;
    }

    if (_input != null) {
      _input.close();
      _input = null;
    }
  }

  static String _context() {
    return "_FCRYPT_";
  }

  static String randomFilename() {
    return HexString(Random.randomBytes(6));
  }

  static String HexString(List<int> bytes) {
    String hexstr = "0123456789abcdef";
    StringBuffer str = new StringBuffer();
    for (int i = 0; i < bytes.length; ++i) {
      var upper = hexstr[(bytes[i] >> 4)];
      var lower = hexstr[(bytes[i] & 0x0f)];
      str.write(upper);
      str.write(lower);
    }

    return str.toString();
  }
}
