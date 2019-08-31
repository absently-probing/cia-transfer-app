import "package:test/test.dart";

import 'dart:convert';
import 'dart:math';
import 'package:libsodium/libsodium.dart';
import 'package:libsodium/src/ffi/constant.dart';
import "package:libsodium/src/ffi/cstring.dart";
import "package:libsodium/src/ffi/carray.dart";
import "package:libsodium/src/bindings/sodiumbindings.dart";

void main(){
  group("random test", () {
    test("simple random test", (){
      List<int> rand = Random.randomBytes(1024 * 1024);
      expect(rand, isNotNull);
      expect(rand.length, equals(1024 * 1024));
    });
  });
  group("secretstream low level", () {
    test("secretstream low level encrypt/decrypt", () {
      bool success = true;
      var msg1 = "Arbitrary data to encrypt";
      var msg2 = "split into";
      var msg3 = "three messages";

      int stateSize = sodiumbindings.crypto_secretstream_xchacha20poly1305_statebytes();
      int keySize = sodiumbindings.crypto_secretstream_xchacha20poly1305_keybytes();
      int headerSize = sodiumbindings.crypto_secretstream_xchacha20poly1305_headerbytes();
      int aBytes = sodiumbindings.crypto_secretstream_xchacha20poly1305_abytes();
      int tagFinal = sodiumbindings.crypto_secretstream_xchacha20poly1305_tag_final();

      Uint8CArray state = Uint8CArray(stateSize);
      Uint8CArray key = Uint8CArray(keySize);
      Uint8CArray header = Uint8CArray(headerSize);
      Uint8CArray c1 = Uint8CArray(msg1.length + aBytes);
      Uint8CArray c2 = Uint8CArray(msg2.length + aBytes);
      Uint8CArray c3 = Uint8CArray(msg3.length + aBytes);

      UCString m1 = UCString(msg1);
      UCString m2 = UCString(msg2);
      UCString m3 = UCString(msg3);

      sodiumbindings.crypto_secretstream_xchacha20poly1305_keygen(key.ptr);

      int err = sodiumbindings.crypto_secretstream_xchacha20poly1305_init_push(state.ptr, header.ptr, key.ptr);
      if (err != 0){
        print("push_init failed");
        success = false;
      }

      err = sodiumbindings.crypto_secretstream_xchacha20poly1305_push(state.ptr, c1.ptr, const_ptr.uint64_null, m1.str.ptr, m1.strlen(), const_ptr.uint8_null, 0, 0);
      if (err != 0){
        print("push1 failed");
        success = false;
      }

      err = sodiumbindings.crypto_secretstream_xchacha20poly1305_push(state.ptr, c2.ptr, const_ptr.uint64_null, m2.str.ptr, m2.strlen(), const_ptr.uint8_null, 0, 0);
      if (err != 0){
        print("push2 failed");
        success = false;
      }

      err = sodiumbindings.crypto_secretstream_xchacha20poly1305_push(state.ptr, c3.ptr, const_ptr.uint64_null, m3.str.ptr, m3.strlen(), const_ptr.uint8_null, 0, tagFinal);
      if (err != 0){
        print("push3 failed");
        success = false;
      }


      UCString m21 =  UCString.fromSize(c1.length - aBytes);
      UCString m22 =  UCString.fromSize(c2.length - aBytes);
      UCString m23 =  UCString.fromSize(c3.length - aBytes);
      Uint8CArray tag = Uint8CArray(1);
      tag[0] = 0;

      err = sodiumbindings.crypto_secretstream_xchacha20poly1305_init_pull(state.ptr, header.ptr, key.ptr);
      if (err != 0) {
        print("init_pull failed");
        success = false;
      }


      err = sodiumbindings.crypto_secretstream_xchacha20poly1305_pull(state.ptr, m21.str.ptr, const_ptr.uint64_null, tag.ptr, c1.ptr, c1.length, const_ptr.uint8_null, 0);
      if (err != 0 || tag[0] != 0) {
        print("pull1 fail");
        success = false;
      }

      err = sodiumbindings.crypto_secretstream_xchacha20poly1305_pull(state.ptr, m22.str.ptr, const_ptr.uint64_null, tag.ptr, c2.ptr, c2.length, const_ptr.uint8_null, 0);
      if (err != 0 || tag[0] != 0) {
        print("pull2 fail");
        success = false;
      }

      err = sodiumbindings.crypto_secretstream_xchacha20poly1305_pull(state.ptr, m23.str.ptr, const_ptr.uint64_null, tag.ptr, c3.ptr, c3.length, const_ptr.uint8_null, 0);
      if (err != 0 || tag[0] != tagFinal) {
        print("pull3 fail");
        success = false;
      }

      state.zfree();
      key.zfree();
      header.zfree();
      c1.zfree();
      c2.zfree();
      c3.zfree();
      m1.zfree();
      m2.zfree();
      m3.zfree();
      m21.zfree();
      m22.zfree();
      m23.zfree();
      tag.zfree();
      expect(success, isTrue);
    });
  });

  group("secretstream high level tests", () {
    test ("secretstream high level simple test", () {
      bool success = true;
      Secretstream stream2 = Secretstream();
      List<int> key = stream2.getKey();
      List<int> header = stream2.pushInit();
      if (header == null){
        success = false;
      }

      List<int> m = [300, 300, 300, 300];
      int tag = Secretstream.tagMessage();
      List<int> c = stream2.push(m, tag);
      if (c == null){
        success = false;
      }

      stream2.clear();
      Secretstream stream = Secretstream(key);
      List<int> out = stream.pull(c, -1);
      if (out != null){
        success = false;
      }

      out = stream.pull(c, Secretstream.tagMessage());
      if (out != null){
        success = false;
      }

      List<int> c2 = [300];
      out = stream.pull(c2, Secretstream.tagMessage());
      if (out != null){
        success = false;
      }

      success = stream.pullInit(header);
      out = stream.pull(c, Secretstream.tagMessage());
      if (out == null){
        success = false;
      } else {
        for (int i = 0; i < out.length; i++){
          if (out[i] != (m[i] % 256)){
            success = false;
          }
        }
      }

      out = stream.push(m, Secretstream.tagMessage());
      if (out != null){
        success = false;
      }

      stream.clear();
      expect(success, isTrue);
    });
    test ("secretstream high level simple encryption test", () {
      bool success = true;
      Secretstream stream = Secretstream();
      List<int> header = stream.pushInit();
      if (header == null){
        success = false;
      }

      List<int> m = [300, 300, 300, 300];
      int tag = Secretstream.tagMessage();
      List<int> c = stream.push(m, tag);
      if (c == null){
        success = false;
      }

      stream.clear();
      expect(success, isTrue);
    });
    test ("secretstream high level simple encryption/decryption test", () {
      bool success = true;
      String msg1 = "Arbitrary data to encrypt";
      String msg2 = "split into";
      String msg3 = "three messages";

      // init encrypt stream and decrypt stream
      Secretstream enc = Secretstream();
      Secretstream dec = Secretstream(enc.getKey());

      // init enc and encrypt messages
      List<int> header = enc.pushInit();
      if (header == null){
        success = false;
      }

      List<int> c1 = enc.push(Utf8Encoder().convert(msg1), Secretstream.tagMessage());
      List<int> c2 = enc.push(Utf8Encoder().convert(msg2), Secretstream.tagMessage());
      List<int> c3 = enc.push(Utf8Encoder().convert(msg3), Secretstream.tagFinal());
      enc.clear();

      // init dec and decrypt messages
      success = dec.pullInit(header);
      List<int> m1 = dec.pull(c1, Secretstream.tagMessage());
      List<int> m2 = dec.pull(c2, Secretstream.tagMessage());
      List<int> m3 = dec.pull(c3, Secretstream.tagFinal());
      dec.clear();

      if (m1 == null || ascii.decode(m1) != msg1){
          success = false;
      }

      if (m2 == null || ascii.decode(m2) != msg2){
        success = false;
      }

      if (m3 == null || ascii.decode(m3) != msg3){
        success = false;
      }

      expect(success, isTrue);
    });
    test ("secretstream high level simple encryption/decryption test with additional data", () {
      bool success = true;
      String msg1 = "Arbitrary data to encrypt";
      String msg2 = "split into";
      String msg3 = "three messages";

      // init encrypt stream and decrypt stream
      Secretstream enc = Secretstream();
      Secretstream dec = Secretstream(enc.getKey());

      // init enc and encrypt messages
      List<int> header = enc.pushInit();
      if (header == null){
        success = false;
      }

      List<int> additional = [0xde, 0xad, 0xbe, 0xef];
      List<int> c1 = enc.push(Utf8Encoder().convert(msg1), Secretstream.tagMessage(), additional);
      List<int> c2 = enc.push(Utf8Encoder().convert(msg2), Secretstream.tagMessage(), additional);
      List<int> c3 = enc.push(Utf8Encoder().convert(msg3), Secretstream.tagFinal());
      enc.clear();

      // init dec and decrypt messages
      success = dec.pullInit(header);
      List<int> m1 = dec.pull(c1, Secretstream.tagMessage(), additional);
      List<int> m2 = dec.pull(c2, Secretstream.tagMessage(), additional);
      List<int> m3 = dec.pull(c3, Secretstream.tagFinal());
      dec.clear();

      if (m1 == null || ascii.decode(m1) != msg1){
        success = false;
      }

      if (m2 == null || ascii.decode(m2) != msg2){
        success = false;
      }

      if (m3 == null || ascii.decode(m3) != msg3){
        success = false;
      }

      expect(success, isTrue);
    });
  });

  group("secretbox high level test", () {
    test ("secretbox exceptions test", (){
      Secretbox sb = Secretbox();
      sb.clear();
      bool success = true;
      bool catch1 = false;
      bool catch2 = false;
      bool catch3 = false;
      bool catch4 = false;
      bool catch5 = false;
      bool catch6 = false;

      try {
        sb.setKey(null);
      } on CryptoException {
        catch1 = true;
      }

      try {
        sb.clear();
      } on CryptoException {
        catch2 = true;
      }

      try {
        sb.decryptBytes(null, null);
      } on CryptoException {
        catch3 = true;
      }

      try {
        sb.getKey();
      } on CryptoException {
        catch4 = true;
      }

      try {
        sb.encryptBytes(null);
      } on CryptoException {
        catch5 = true;
      }

      try {
        sb.reKey();
      } on CryptoException {
        catch6 = true;
      }

      success = catch1 && catch2 && catch3 && catch4 && catch5 && catch6;
      expect(success, isTrue);
    });
    test("secretbox simple encrypt test", (){
      Secretbox sb = Secretbox();
      List<int> m = [300];
      List<List<int>> box = sb.encryptBytes(m);
      sb.clear();
      expect(box, isNotNull);
    });
    test("secretbox simple decrypt test", (){
      bool success = true;
      Secretbox sb = Secretbox();
      List<int> key = sb.getKey();
      List<int> m = [300];
      List<List<int>> box = sb.encryptBytes(m);
      sb.clear();
      if (box != null){
        sb = Secretbox(key);
        List<int> m2 = sb.decryptBytes(box[0], box[1]);
        if (m2 != null) {
          success = (m[0] % 256) == m2[0];
        } else {
          success = false;
        }
        sb.clear();
      } else {
        success = false;
      }
      expect(success, isTrue);
    });
    test("secretbox simple encrypt/decrypt test", (){
      bool success = true;
      Secretbox sb = Secretbox();
      List<int> m = [300];
      List<List<int>> box = sb.encryptBytes(m);
      if (box != null){
        List<int> m2 = sb.decryptBytes(box[0], box[1]);
        if (m2 != null){
          success = (m[0] % 256) == m2[0];
        } else {
          success = false;
        }
      } else {
        success = false;
      }
      
      sb.clear();
      expect(success, isTrue);
    });
  });
  group("kdf high level test", () {
    test("kdf high level simple test", () {
      bool success = true;
      Kdf kdf = Kdf();
      List<int> key = kdf.getMasterkey();
      List<int> subkey1 = kdf.createSubkey(Kdf.subkeyMaxBytes(), 0, Kdf.convertStringToCTX("TESTTEST"));
      List<int> subkey2 = kdf.createSubkey(Kdf.subkeyMaxBytes(), 1, Kdf.convertStringToCTX("TESTTEST"));
      List<int> subkey3 = kdf.createSubkey(Kdf.subkeyMaxBytes(), 2, Kdf.convertStringToCTX("TESTTEST"));
      List<int> subkey4 = kdf.createSubkey(Kdf.subkeyMaxBytes(), 3, Kdf.convertStringToCTX("TESTTEST"));
      List<int> subkey5 = kdf.createSubkey(Kdf.subkeyMaxBytes(), 4, Kdf.convertStringToCTX("TESTTEST"));
      List<int> subkey6 = kdf.createSubkey(Kdf.subkeyMaxBytes(), 5, Kdf.convertStringToCTX("TESTTEST"));
      List<int> subkey7 = kdf.createSubkey(Kdf.subkeyMaxBytes(), 6, Kdf.convertStringToCTX("TESTTEST"));
      List<int> subkey8 = kdf.createSubkey(Kdf.subkeyMaxBytes(), 7, Kdf.convertStringToCTX("TESTTEST"));
      List<int> subkey9 = kdf.createSubkey(Kdf.subkeyMaxBytes(), 8, Kdf.convertStringToCTX("TESTTEST"));
      List<int> subkey10 = kdf.createSubkey(Kdf.subkeyMaxBytes(), 9, Kdf.convertStringToCTX("TESTTEST"));
      List<int> subkey11 = kdf.createSubkey(Kdf.subkeyMaxBytes(), 0, Kdf.convertStringToCTX("TESTTEST"));
      List<int> subkey12 = kdf.createSubkey(Kdf.subkeyMaxBytes(), 1, Kdf.convertStringToCTX("TESTTEST"));
      List<int> subkey13 = kdf.createSubkey(Kdf.subkeyMaxBytes(), 2, Kdf.convertStringToCTX("TESTTEST"));
      List<int> subkey14 = kdf.createSubkey(Kdf.subkeyMaxBytes(), 3, Kdf.convertStringToCTX("TESTTEST"));
      List<int> subkey15 = kdf.createSubkey(Kdf.subkeyMaxBytes(), 4, Kdf.convertStringToCTX("TESTTEST"));
      List<int> subkey16 = kdf.createSubkey(Kdf.subkeyMaxBytes(), 5, Kdf.convertStringToCTX("TESTTEST"));
      List<int> subkey17 = kdf.createSubkey(Kdf.subkeyMaxBytes(), 6, Kdf.convertStringToCTX("TESTTEST"));
      List<int> subkey18 = kdf.createSubkey(Kdf.subkeyMaxBytes(), 7, Kdf.convertStringToCTX("TESTTEST"));
      List<int> subkey19 = kdf.createSubkey(Kdf.subkeyMaxBytes(), 8, Kdf.convertStringToCTX("TESTTEST"));
      List<int> subkey20 = kdf.createSubkey(Kdf.subkeyMaxBytes(), 9, Kdf.convertStringToCTX("TESTTEST"));
      if (key != null && subkey1 != null && subkey2 != null && subkey3 != null  && subkey4 != null  && subkey5 != null
          && subkey6 != null  && subkey7 != null  && subkey8 != null  && subkey9 != null  && subkey10 != null
          && subkey11 != null  && subkey12 != null  && subkey13 != null  && subkey14 != null  && subkey15 != null
          && subkey16 != null  && subkey17 != null  && subkey18 != null  && subkey19 != null  && subkey20 != null){

        List<List<int>> target = [subkey1, subkey2, subkey3, subkey4, subkey5, subkey6, subkey7, subkey8, subkey9, subkey10,
        subkey11, subkey12, subkey13, subkey14, subkey15, subkey16, subkey17, subkey18, subkey19, subkey20];

        for (int i = 0; i < target.length; i++){
          bool equal = true;
          for (int j = 0; j < min(target[i].length, key.length); j++){
            if (key[j] != target[i][j]){
              equal = false;
              break;
            }
          }

          if (equal && target[i].length == key.length){
            success = false;
          }
        }

        for (int i = 0; i < target.length/10; i++){
          for (int j = 0; j < target[i].length; j++){
            if (target[i][j] != target[i+10][j]){
              success = false;
            }
          }
        }

        for (int i = 0; i < target.length; i++){
          for (int j = i + 1; j < target.length; j++){
            if (i + 10 == j){
              continue;
            }

            bool equal = true;
            for (int k = 0; k < min(target[i].length, target[j].length); k++){
              if (target[i][k] != target[j][k]){
                equal = false;
                break;
              }
            }

            if (equal && target[i].length == target[j].length){
              success = false;
            }
          }
        }

        Kdf kdf2 = Kdf(key);
        List<int> subkey21 = kdf2.createSubkey(Kdf.subkeyMaxBytes(), 0, Kdf.convertStringToCTX("TESTTEST"));
        List<int> subkey22 = kdf2.createSubkey(Kdf.subkeyMaxBytes(), 1, Kdf.convertStringToCTX("TESTTEST"));
        List<int> subkey23 = kdf2.createSubkey(Kdf.subkeyMaxBytes(), 2, Kdf.convertStringToCTX("TESTTEST"));
        List<int> subkey24 = kdf2.createSubkey(Kdf.subkeyMaxBytes(), 3, Kdf.convertStringToCTX("TESTTEST"));
        List<int> subkey25 = kdf2.createSubkey(Kdf.subkeyMaxBytes(), 4, Kdf.convertStringToCTX("TESTTEST"));
        List<int> subkey26 = kdf2.createSubkey(Kdf.subkeyMaxBytes(), 5, Kdf.convertStringToCTX("TESTTEST"));
        List<int> subkey27 = kdf2.createSubkey(Kdf.subkeyMaxBytes(), 6, Kdf.convertStringToCTX("TESTTEST"));
        List<int> subkey28 = kdf2.createSubkey(Kdf.subkeyMaxBytes(), 7, Kdf.convertStringToCTX("TESTTEST"));
        List<int> subkey29 = kdf2.createSubkey(Kdf.subkeyMaxBytes(), 8, Kdf.convertStringToCTX("TESTTEST"));
        List<int> subkey30 = kdf2.createSubkey(Kdf.subkeyMaxBytes(), 9, Kdf.convertStringToCTX("TESTTEST"));
        kdf2.clear();

        if (subkey21 != null && subkey22 != null && subkey23 != null && subkey24 != null && subkey25 != null
            && subkey26 != null && subkey27 != null && subkey28 != null && subkey29 != null && subkey30 != null) {
          target = [
            subkey1,
            subkey2,
            subkey3,
            subkey4,
            subkey5,
            subkey6,
            subkey7,
            subkey8,
            subkey9,
            subkey10,
            subkey21,
            subkey22,
            subkey23,
            subkey24,
            subkey25,
            subkey26,
            subkey27,
            subkey28,
            subkey29,
            subkey30
          ];

          for (int i = 0; i < target.length; i++) {
            bool equal = true;
            for (int j = 0; j < min(target[i].length, key.length); j++) {
              if (key[j] != target[i][j]) {
                equal = false;
                break;
              }
            }

            if (equal && target[i].length == key.length) {
              success = false;
            }
          }

          for (int i = 0; i < target.length / 10; i++) {
            for (int j = 0; j < target[i].length; j++) {
              if (target[i][j] != target[i + 10][j]) {
                success = false;
              }
            }
          }

          for (int i = 0; i < target.length; i++) {
            for (int j = i + 1; j < target.length; j++) {
              if (i + 10 == j) {
                continue;
              }

              bool equal = true;
              for (int k = 0; k <
                  min(target[i].length, target[j].length); k++) {
                if (target[i][k] != target[j][k]) {
                  equal = false;
                  break;
                }
              }

              if (equal && target[i].length == target[j].length) {
                success = false;
              }
            }
          }
        } else {
          success = false;
        }
      } else {
        success = false;
      }

      kdf.clear();
      expect(success, isTrue);
    });
  });
}