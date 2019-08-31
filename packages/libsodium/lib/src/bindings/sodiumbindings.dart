import 'bindings.dart';
import '../sodium/exception.dart';
import 'package:c_type_sizes/c_type_sizes.dart';

import 'dart:ffi';

class _DartSodiumBindings {
  int _sizeofInt = 0;
  int _sizeofSize_t = 0;

  _DartSodiumBindings() {
    _sizeofInt = Ctypes.sizeofInt();
    _sizeofSize_t = Ctypes.sizeofSize_t();
  }

  void randombytes_buf(Pointer<Uint8> buffer, int size){
    switch (_sizeofSize_t){
      case 4:
        bindings.randombytes32_buf(buffer, size);
        break;
      case 8:
        bindings.randombytes64_buf(buffer, size);
        break;
      default:
        throw CryptoException("Unsupported platform");
    }
  }

  // constant secret key crypto (dart api)
  int crypto_secretbox_keybytes(){
    switch (_sizeofSize_t){
      case 4:
        return bindings.crypto32_secretbox_keybytes();
      case 8:
        return bindings.crypto64_secretbox_keybytes();
      default:
        throw CryptoException("Unsupported platform");
    }
  }

  int crypto_secretbox_noncebytes(){
    switch (_sizeofSize_t){
      case 4:
        return bindings.crypto32_secretbox_noncebytes();
      case 8:
        return bindings.crypto64_secretbox_noncebytes();
      default:
        throw CryptoException("Unsupported platform");
    }
  }

  int crypto_secretbox_macbytes(){
    switch (_sizeofSize_t){
      case 4:
        return bindings.crypto32_secretbox_macbytes();
      case 8:
        return bindings.crypto64_secretbox_macbytes();
      default:
        throw CryptoException("Unsupported platform");
    }
  }

  // secret key crypto (dart api)
  void crypto_secretbox_keygen(Pointer<Uint8> key){
    bindings.crypto_secretbox_keygen(key);
  }

  int crypto_secretbox_easy(Pointer<Uint8> c, Pointer<Uint8> m, int mlen, Pointer<Uint8> n, Pointer<Uint8> k){
    switch (_sizeofInt){
      case 4:
        return bindings.crypto32_secretbox_easy(c, m, mlen, n, k);
      case 8:
        return bindings.crypto64_secretbox_easy(c, m, mlen, n, k);
      default:
        throw CryptoException("Unsupported platform");
    }
  }

  int crypto_secretbox_open_easy(Pointer<Uint8> m, Pointer<Uint8> c, int clen, Pointer<Uint8> n, Pointer<Uint8> k){
    switch (_sizeofInt){
      case 4:
        return bindings.crypto32_secretbox_open_easy(m, c, clen, n, k);
      case 8:
        return bindings.crypto64_secretbox_open_easy(m, c, clen, n, k);
      default:
        throw CryptoException("Unsupported platform");
    }
  }

  // constant secretstream crypto (dart api)
  int crypto_secretstream_xchacha20poly1305_keybytes(){
    switch (_sizeofSize_t){
      case 4:
        return bindings.crypto32_secretstream_xchacha20poly1305_keybytes();
      case 8:
        return bindings.crypto64_secretstream_xchacha20poly1305_keybytes();
      default:
        throw CryptoException("Unsupported platform");
    }
  }

  int crypto_secretstream_xchacha20poly1305_headerbytes(){
    switch (_sizeofSize_t){
      case 4:
        return bindings.crypto32_secretstream_xchacha20poly1305_headerbytes();
      case 8:
        return bindings.crypto64_secretstream_xchacha20poly1305_headerbytes();
      default:
        throw CryptoException("Unsupported platform");
    }
  }

  int crypto_secretstream_xchacha20poly1305_abytes(){
    switch (_sizeofSize_t){
      case 4:
        return bindings.crypto32_secretstream_xchacha20poly1305_abytes();
      case 8:
        return bindings.crypto64_secretstream_xchacha20poly1305_abytes();
      default:
        throw CryptoException("Unsupported platform");
    }
  }

  int crypto_secretstream_xchacha20poly1305_messagebytes_max(){
    switch (_sizeofSize_t){
      case 4:
        return bindings.crypto32_secretstream_xchacha20poly1305_messagebytes_max();
      case 8:
        return bindings.crypto64_secretstream_xchacha20poly1305_messagebytes_max();
      default:
        throw CryptoException("Unsupported platform");
    }
  }

  int crypto_secretstream_xchacha20poly1305_statebytes(){
    switch (_sizeofSize_t){
      case 4:
        return bindings.crypto32_secretstream_xchacha20poly1305_statebytes();
      case 8:
        return bindings.crypto64_secretstream_xchacha20poly1305_statebytes();
      default:
        throw CryptoException("Unsupported platform");
    }
  }

  int crypto_secretstream_xchacha20poly1305_tag_message(){
    return bindings.crypto_secretstream_xchacha20poly1305_tag_message();
  }

  int crypto_secretstream_xchacha20poly1305_tag_push(){
    return bindings.crypto_secretstream_xchacha20poly1305_tag_push();
  }

  int crypto_secretstream_xchacha20poly1305_tag_rekey(){
    return bindings.crypto_secretstream_xchacha20poly1305_tag_rekey();
  }

  int crypto_secretstream_xchacha20poly1305_tag_final(){
    return bindings.crypto_secretstream_xchacha20poly1305_tag_final();
  }


  // secretstream crypto (dart api)
  void crypto_secretstream_xchacha20poly1305_keygen(Pointer<Uint8> key){
    bindings.crypto_secretstream_xchacha20poly1305_keygen(key);
  }

  int crypto_secretstream_xchacha20poly1305_init_push(Pointer<Uint8> state, Pointer<Uint8> header, Pointer<Uint8> k){
    switch (_sizeofInt){
      case 4:
        return bindings.crypto32_secretstream_xchacha20poly1305_init_push(state, header, k);
      case 8:
        return bindings.crypto64_secretstream_xchacha20poly1305_init_push(state, header, k);
      default:
        throw CryptoException("Unsupported platform");
    }
  }

  int crypto_secretstream_xchacha20poly1305_push(Pointer<Uint8> state, Pointer<Uint8> c, Pointer<Uint64> clen_p, Pointer<Uint8> m,
      int m_len, Pointer<Uint8> ad, int adlen, int tag){
    switch (_sizeofInt){
      case 4:
        return bindings.crypto32_secretstream_xchacha20poly1305_push(state, c, clen_p, m, m_len, ad, adlen, tag);
      case 8:
        return bindings.crypto64_secretstream_xchacha20poly1305_push(state, c, clen_p, m, m_len, ad, adlen, tag);
      default:
        throw CryptoException("Unsupported platform");
    }
  }

  int crypto_secretstream_xchacha20poly1305_init_pull(Pointer<Uint8> state, Pointer<Uint8> header, Pointer<Uint8> k){
    switch (_sizeofInt){
      case 4:
        return bindings.crypto32_secretstream_xchacha20poly1305_init_pull(state, header, k);
      case 8:
        return bindings.crypto64_secretstream_xchacha20poly1305_init_pull(state, header, k);
      default:
        throw CryptoException("Unsupported platform");
    }
  }

  int crypto_secretstream_xchacha20poly1305_pull(Pointer<Uint8> state, Pointer<Uint8> m, Pointer<Uint64> mlen_p, Pointer<Uint8> tag_p,
      Pointer<Uint8> c, int c_len, Pointer<Uint8> ad, int adlen){
    switch (_sizeofInt){
      case 4:
        return bindings.crypto32_secretstream_xchacha20poly1305_pull(state, m, mlen_p, tag_p, c, c_len, ad, adlen);
      case 8:
        return bindings.crypto64_secretstream_xchacha20poly1305_pull(state, m, mlen_p, tag_p, c, c_len, ad, adlen);
      default:
        throw CryptoException("Unsupported platform");
    }
  }

  void crypto_secretstream_xchacha20poly1305_rekey(Pointer<Uint8> state){
    bindings.crypto_secretstream_xchacha20poly1305_rekey(state);
  }

  // constant kdf (dart api)
  int crypto_kdf_keybytes(){
    switch (_sizeofSize_t){
      case 4:
        return bindings.crypto32_kdf_keybytes();
      case 8:
        return bindings.crypto64_kdf_keybytes();
      default:
        throw CryptoException("Unsupported platform");
    }
  }

  int crypto_kdf_bytes_min(){
    switch (_sizeofSize_t){
      case 4:
        return bindings.crypto32_kdf_bytes_min();
      case 8:
        return bindings.crypto64_kdf_bytes_min();
      default:
        throw CryptoException("Unsupported platform");
    }
  }

  int crypto_kdf_bytes_max(){
    switch (_sizeofSize_t){
      case 4:
        return bindings.crypto32_kdf_bytes_max();
      case 8:
        return bindings.crypto64_kdf_bytes_max();
      default:
        throw CryptoException("Unsupported platform");
    }
  }

  int crypto_kdf_contextbytes(){
    switch (_sizeofSize_t){
      case 4:
        return bindings.crypto32_kdf_contextbytes();
      case 8:
        return bindings.crypto64_kdf_contextbytes();
      default:
        throw CryptoException("Unsupported platform");
    }
  }

  void crypto_kdf_keygen(Pointer<Uint8> key){
    bindings.crypto_kdf_keygen(key);
  }

  int crypto_kdf_derive_from_key(Pointer<Uint8> subkey, int subkey_len, int subkey_id, Pointer<Int8> ctx, Pointer<Uint8> key){
    switch (_sizeofInt){
      case 4:
        switch (_sizeofSize_t) {
          case 4:
            return bindings.crypto32_32_kdf_derive_from_key(subkey, subkey_len, subkey_id, ctx, key);
          case 8:
            return bindings.crypto32_64_kdf_derive_from_key(subkey, subkey_len, subkey_id, ctx, key);
          default:
            throw CryptoException("Unsupported platform");
        }
        break;
      case 8:
        switch (_sizeofSize_t) {
          case 4:
            return bindings.crypto64_32_kdf_derive_from_key(subkey, subkey_len, subkey_id, ctx, key);
          case 8:
            return bindings.crypto64_64_kdf_derive_from_key(subkey, subkey_len, subkey_id, ctx, key);
          default:
            throw CryptoException("Unsupported platform");
        }
        break;
      default:
        throw CryptoException("Unsupported platform");
    }
  }
}

_DartSodiumBindings _cachedBindings;
_DartSodiumBindings get sodiumbindings => _cachedBindings ??= _DartSodiumBindings();