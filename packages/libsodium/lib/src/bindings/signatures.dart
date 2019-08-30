import "dart:ffi";

typedef randombytes_buf_native_t = Void Function(Pointer<Uint8> buffer, Uint64 size);

// constant secret key crypto
typedef crypto_secretbox_keybytes_native_t = Uint64 Function();

typedef crypto_secretbox_noncebytes_native_t = Uint64 Function();

typedef crypto_secretbox_macbytes_native_t = Uint64 Function();

// secret key crypto
typedef crypto_secretbox_keygen_native_t = Void Function(Pointer<Uint8> key);

typedef crypto_secretbox_easy_native_t = Int32 Function(Pointer<Uint8> c, Pointer<Uint8> m, Uint64 mlen, Pointer<Uint8> n, Pointer<Uint8> k);

typedef crypto_secretbox_open_easy_native_t = Int32 Function(Pointer<Uint8> m, Pointer<Uint8> c, Uint64 clen, Pointer<Uint8> n, Pointer<Uint8> k);

// constant secretstream crypto
typedef crypto_secretstream_xchacha20poly1305_keybytes_native_t = Uint64 Function();

typedef crypto_secretstream_xchacha20poly1305_headerbytes_native_t = Uint64 Function();

typedef crypto_secretstream_xchacha20poly1305_abytes_native_t = Uint64 Function();

typedef crypto_secretstream_xchacha20poly1305_messagebytes_max_native_t = Uint64 Function();

typedef crypto_secretstream_xchacha20poly1305_statebytes_native_t = Uint64 Function();

typedef crypto_secretstream_xchacha20poly1305_tag_message_native_t = Uint8 Function();

typedef crypto_secretstream_xchacha20poly1305_tag_push_native_t = Uint8 Function();

typedef crypto_secretstream_xchacha20poly1305_tag_rekey_native_t = Uint8 Function();

typedef crypto_secretstream_xchacha20poly1305_tag_final_native_t = Uint8 Function();

// secretstream crypto
typedef crypto_secretstream_xchacha20poly1305_keygen_native_t = Void Function(Pointer<Uint8>);

typedef crypto_secretstream_xchacha20poly1305_init_push_native_t = Int32 Function(Pointer<Uint8> state, 
																					Pointer<Uint8> header,
																					Pointer<Uint8> k);

typedef crypto_secretstream_xchacha20poly1305_push_native_t = Int32 Function(Pointer<Uint8> state, 
																					Pointer<Uint8> c,
																					Pointer<Uint64> clen_p,
																					Pointer<Uint8> m,
																					Uint64 m_len,
																					Pointer<Uint8> ad,
																					Uint64 adlen,
																					Int8 tag);

typedef crypto_secretstream_xchacha20poly1305_init_pull_native_t = Int32 Function(Pointer<Uint8> state,
																					Pointer<Uint8> header,
																					Pointer<Uint8> k);

typedef crypto_secretstream_xchacha20poly1305_pull_native_t = Int32 Function(Pointer<Uint8> state,
																				Pointer<Uint8> m,
																				Pointer<Uint64> mlen_p,
																				Pointer<Uint8> tag_p,
																				Pointer<Uint8> c,
																				Uint64 c_len,
																				Pointer<Uint8> ad,
																				Uint64 adlen);


typedef crypto_secretstream_xchacha20poly1305_rekey_native_t = Void Function(Pointer<Uint8> state);

// constant kdf
typedef crypto_kdf_keybytes_native_t = Uint64 Function();

typedef crypto_kdf_bytes_min_native_t = Uint64 Function();

typedef crypto_kdf_bytes_max_native_t = Uint64 Function();

typedef crypto_kdf_contextbytes_native_t = Uint64 Function();

// kdf
typedef crypto_kdf_keygen_native_t = Void Function(Pointer<Uint8> key);

typedef crypto_kdf_derive_from_key_native_t = Int32 Function(Pointer<Uint8> subkey, Uint64 subkey_len, Uint64 subkey_id, Pointer<Int8> ctx, Pointer<Uint8> key);