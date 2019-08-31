import "dart:ffi";

import "../ffi/dylib_utils.dart";

import "signatures.dart";

class _SodiumBindings {
	DynamicLibrary sodium;

	void Function(Pointer<Uint8> buffer, int size) randombytes32_buf;

	void Function(Pointer<Uint8> buffer, int size) randombytes64_buf;

	// constant secret key crypto (dart api)
	int Function() crypto32_secretbox_keybytes;

	int Function() crypto32_secretbox_noncebytes;

	int Function() crypto32_secretbox_macbytes;

	int Function() crypto64_secretbox_keybytes;

	int Function() crypto64_secretbox_noncebytes;

	int Function() crypto64_secretbox_macbytes;

	// secret key crypto (dart api)
	void Function(Pointer<Uint8> key) crypto_secretbox_keygen;

	int Function(Pointer<Uint8> c, Pointer<Uint8> m, int mlen, Pointer<Uint8> n, Pointer<Uint8> k) crypto32_secretbox_easy;

	int Function(Pointer<Uint8> m, Pointer<Uint8> c, int clen, Pointer<Uint8> n, Pointer<Uint8> k) crypto32_secretbox_open_easy;

	int Function(Pointer<Uint8> c, Pointer<Uint8> m, int mlen, Pointer<Uint8> n, Pointer<Uint8> k) crypto64_secretbox_easy;

	int Function(Pointer<Uint8> m, Pointer<Uint8> c, int clen, Pointer<Uint8> n, Pointer<Uint8> k) crypto64_secretbox_open_easy;

	// constant secretstream crypto (dart api)
	int Function() crypto32_secretstream_xchacha20poly1305_keybytes;

	int Function() crypto32_secretstream_xchacha20poly1305_headerbytes;

	int Function() crypto32_secretstream_xchacha20poly1305_abytes;

	int Function() crypto32_secretstream_xchacha20poly1305_messagebytes_max;

	int Function() crypto32_secretstream_xchacha20poly1305_statebytes;

	int Function() crypto64_secretstream_xchacha20poly1305_keybytes;

	int Function() crypto64_secretstream_xchacha20poly1305_headerbytes;

	int Function() crypto64_secretstream_xchacha20poly1305_abytes;

	int Function() crypto64_secretstream_xchacha20poly1305_messagebytes_max;

	int Function() crypto64_secretstream_xchacha20poly1305_statebytes;

	int Function() crypto_secretstream_xchacha20poly1305_tag_message;

	int Function() crypto_secretstream_xchacha20poly1305_tag_push;

	int Function() crypto_secretstream_xchacha20poly1305_tag_rekey;

	int Function() crypto_secretstream_xchacha20poly1305_tag_final;

	// secretstream crypto (dart api)
	void Function(Pointer<Uint8> key) crypto_secretstream_xchacha20poly1305_keygen;

	int Function(Pointer<Uint8> state, Pointer<Uint8> header, Pointer<Uint8> k) crypto32_secretstream_xchacha20poly1305_init_push;

	int Function(Pointer<Uint8> state, Pointer<Uint8> c, Pointer<Uint64> clen_p, Pointer<Uint8> m,
					int m_len, Pointer<Uint8> ad, int adlen, int tag) crypto32_secretstream_xchacha20poly1305_push;

	int Function(Pointer<Uint8> state, Pointer<Uint8> header, Pointer<Uint8> k) crypto32_secretstream_xchacha20poly1305_init_pull;

	int Function(Pointer<Uint8> state, Pointer<Uint8> m, Pointer<Uint64> mlen_p, Pointer<Uint8> tag_p,
					Pointer<Uint8> c, int c_len, Pointer<Uint8> ad, int adlen) crypto32_secretstream_xchacha20poly1305_pull;


	int Function(Pointer<Uint8> state, Pointer<Uint8> header, Pointer<Uint8> k) crypto64_secretstream_xchacha20poly1305_init_push;

	int Function(Pointer<Uint8> state, Pointer<Uint8> c, Pointer<Uint64> clen_p, Pointer<Uint8> m,
			int m_len, Pointer<Uint8> ad, int adlen, int tag) crypto64_secretstream_xchacha20poly1305_push;

	int Function(Pointer<Uint8> state, Pointer<Uint8> header, Pointer<Uint8> k) crypto64_secretstream_xchacha20poly1305_init_pull;

	int Function(Pointer<Uint8> state, Pointer<Uint8> m, Pointer<Uint64> mlen_p, Pointer<Uint8> tag_p,
			Pointer<Uint8> c, int c_len, Pointer<Uint8> ad, int adlen) crypto64_secretstream_xchacha20poly1305_pull;


	void Function(Pointer<Uint8> state) crypto_secretstream_xchacha20poly1305_rekey;
	// constant kdf (dart api)
	int Function() crypto32_kdf_keybytes;

	int Function() crypto32_kdf_bytes_min;

	int Function() crypto32_kdf_bytes_max;

	int Function() crypto32_kdf_contextbytes;

	int Function() crypto64_kdf_keybytes;

	int Function() crypto64_kdf_bytes_min;

	int Function() crypto64_kdf_bytes_max;

	int Function() crypto64_kdf_contextbytes;

	// kdf (dart api)
	void Function(Pointer<Uint8> key) crypto_kdf_keygen;

	int Function(Pointer<Uint8> subkey, int subkey_len, int subkey_id, Pointer<Int8> ctx, Pointer<Uint8> key) crypto32_32_kdf_derive_from_key;

	int Function(Pointer<Uint8> subkey, int subkey_len, int subkey_id, Pointer<Int8> ctx, Pointer<Uint8> key) crypto32_64_kdf_derive_from_key;

	int Function(Pointer<Uint8> subkey, int subkey_len, int subkey_id, Pointer<Int8> ctx, Pointer<Uint8> key) crypto64_32_kdf_derive_from_key;

	int Function(Pointer<Uint8> subkey, int subkey_len, int subkey_id, Pointer<Int8> ctx, Pointer<Uint8> key) crypto64_64_kdf_derive_from_key;


	_SodiumBindings(){
		sodium = dlopenPlatformSpecific("sodium");
		randombytes32_buf = sodium
				.lookup<NativeFunction<randombytes32_buf_native_t>>("randombytes_buf")
				.asFunction();
		randombytes64_buf = sodium
				.lookup<NativeFunction<randombytes64_buf_native_t>>("randombytes_buf")
				.asFunction();
		// constant secret key bindings
		crypto32_secretbox_keybytes = sodium
				.lookup<NativeFunction<crypto32_secretbox_keybytes_native_t>>("crypto_secretbox_keybytes")
				.asFunction();
		crypto32_secretbox_noncebytes = sodium
				.lookup<NativeFunction<crypto32_secretbox_noncebytes_native_t>>("crypto_secretbox_noncebytes")
				.asFunction();
		crypto32_secretbox_macbytes = sodium
				.lookup<NativeFunction<crypto32_secretbox_macbytes_native_t>>("crypto_secretbox_macbytes")
				.asFunction();
		crypto64_secretbox_keybytes = sodium
				.lookup<NativeFunction<crypto64_secretbox_keybytes_native_t>>("crypto_secretbox_keybytes")
				.asFunction();
		crypto64_secretbox_noncebytes = sodium
				.lookup<NativeFunction<crypto64_secretbox_noncebytes_native_t>>("crypto_secretbox_noncebytes")
				.asFunction();
		crypto64_secretbox_macbytes = sodium
				.lookup<NativeFunction<crypto64_secretbox_macbytes_native_t>>("crypto_secretbox_macbytes")
				.asFunction();
		// secret key bindings
		crypto_secretbox_keygen = sodium
				.lookup<NativeFunction<crypto_secretbox_keygen_native_t>>("crypto_secretbox_keygen")
				.asFunction();
		crypto32_secretbox_easy = sodium
				.lookup<NativeFunction<crypto32_secretbox_easy_native_t>>("crypto_secretbox_easy")
				.asFunction();
		crypto32_secretbox_open_easy = sodium
				.lookup<NativeFunction<crypto32_secretbox_open_easy_native_t>>("crypto_secretbox_open_easy")
				.asFunction();
		crypto64_secretbox_easy = sodium
				.lookup<NativeFunction<crypto64_secretbox_easy_native_t>>("crypto_secretbox_easy")
				.asFunction();
		crypto64_secretbox_open_easy = sodium
				.lookup<NativeFunction<crypto64_secretbox_open_easy_native_t>>("crypto_secretbox_open_easy")
				.asFunction();
		// constant secretstream bindings
		crypto32_secretstream_xchacha20poly1305_keybytes = sodium
				.lookup<NativeFunction<crypto32_secretstream_xchacha20poly1305_keybytes_native_t>>("crypto_secretstream_xchacha20poly1305_keybytes")
				.asFunction();
		crypto32_secretstream_xchacha20poly1305_headerbytes = sodium
				.lookup<NativeFunction<crypto32_secretstream_xchacha20poly1305_headerbytes_native_t>>("crypto_secretstream_xchacha20poly1305_headerbytes")
				.asFunction();
		crypto32_secretstream_xchacha20poly1305_abytes = sodium
				.lookup<NativeFunction<crypto32_secretstream_xchacha20poly1305_abytes_native_t>>("crypto_secretstream_xchacha20poly1305_abytes")
				.asFunction();
		crypto32_secretstream_xchacha20poly1305_messagebytes_max = sodium
				.lookup<NativeFunction<crypto32_secretstream_xchacha20poly1305_messagebytes_max_native_t>>("crypto_secretstream_xchacha20poly1305_messagebytes_max")
				.asFunction();
		crypto32_secretstream_xchacha20poly1305_statebytes = sodium
				.lookup<NativeFunction<crypto32_secretstream_xchacha20poly1305_statebytes_native_t>>("crypto_secretstream_xchacha20poly1305_statebytes")
				.asFunction();

		crypto64_secretstream_xchacha20poly1305_keybytes = sodium
				.lookup<NativeFunction<crypto64_secretstream_xchacha20poly1305_keybytes_native_t>>("crypto_secretstream_xchacha20poly1305_keybytes")
				.asFunction();
		crypto64_secretstream_xchacha20poly1305_headerbytes = sodium
				.lookup<NativeFunction<crypto64_secretstream_xchacha20poly1305_headerbytes_native_t>>("crypto_secretstream_xchacha20poly1305_headerbytes")
				.asFunction();
		crypto64_secretstream_xchacha20poly1305_abytes = sodium
				.lookup<NativeFunction<crypto64_secretstream_xchacha20poly1305_abytes_native_t>>("crypto_secretstream_xchacha20poly1305_abytes")
				.asFunction();
		crypto64_secretstream_xchacha20poly1305_messagebytes_max = sodium
				.lookup<NativeFunction<crypto64_secretstream_xchacha20poly1305_messagebytes_max_native_t>>("crypto_secretstream_xchacha20poly1305_messagebytes_max")
				.asFunction();
		crypto64_secretstream_xchacha20poly1305_statebytes = sodium
				.lookup<NativeFunction<crypto64_secretstream_xchacha20poly1305_statebytes_native_t>>("crypto_secretstream_xchacha20poly1305_statebytes")
				.asFunction();
		crypto_secretstream_xchacha20poly1305_tag_message = sodium
				.lookup<NativeFunction<crypto_secretstream_xchacha20poly1305_tag_message_native_t>>("crypto_secretstream_xchacha20poly1305_tag_message")
				.asFunction();
		crypto_secretstream_xchacha20poly1305_tag_push = sodium
				.lookup<NativeFunction<crypto_secretstream_xchacha20poly1305_tag_push_native_t>>("crypto_secretstream_xchacha20poly1305_tag_push")
				.asFunction();
		crypto_secretstream_xchacha20poly1305_tag_rekey = sodium
				.lookup<NativeFunction<crypto_secretstream_xchacha20poly1305_tag_rekey_native_t>>("crypto_secretstream_xchacha20poly1305_tag_rekey")
				.asFunction();
		crypto_secretstream_xchacha20poly1305_tag_final = sodium
				.lookup<NativeFunction<crypto_secretstream_xchacha20poly1305_tag_final_native_t>>("crypto_secretstream_xchacha20poly1305_tag_final")
				.asFunction();
		// secretstream bindings
		crypto_secretstream_xchacha20poly1305_keygen = sodium
				.lookup<NativeFunction<crypto_secretstream_xchacha20poly1305_keygen_native_t>>("crypto_secretstream_xchacha20poly1305_keygen")
				.asFunction();
		crypto32_secretstream_xchacha20poly1305_init_push = sodium
				.lookup<NativeFunction<crypto32_secretstream_xchacha20poly1305_init_push_native_t>>("crypto_secretstream_xchacha20poly1305_init_push")
				.asFunction();
		crypto32_secretstream_xchacha20poly1305_push = sodium
				.lookup<NativeFunction<crypto32_secretstream_xchacha20poly1305_push_native_t>>("crypto_secretstream_xchacha20poly1305_push")
				.asFunction();
		crypto32_secretstream_xchacha20poly1305_init_pull = sodium
				.lookup<NativeFunction<crypto32_secretstream_xchacha20poly1305_init_pull_native_t>>("crypto_secretstream_xchacha20poly1305_init_pull")
				.asFunction();
		crypto32_secretstream_xchacha20poly1305_pull = sodium
				.lookup<NativeFunction<crypto32_secretstream_xchacha20poly1305_pull_native_t>>("crypto_secretstream_xchacha20poly1305_pull")
				.asFunction();
		crypto64_secretstream_xchacha20poly1305_init_push = sodium
				.lookup<NativeFunction<crypto64_secretstream_xchacha20poly1305_init_push_native_t>>("crypto_secretstream_xchacha20poly1305_init_push")
				.asFunction();
		crypto64_secretstream_xchacha20poly1305_push = sodium
				.lookup<NativeFunction<crypto64_secretstream_xchacha20poly1305_push_native_t>>("crypto_secretstream_xchacha20poly1305_push")
				.asFunction();
		crypto64_secretstream_xchacha20poly1305_init_pull = sodium
				.lookup<NativeFunction<crypto64_secretstream_xchacha20poly1305_init_pull_native_t>>("crypto_secretstream_xchacha20poly1305_init_pull")
				.asFunction();
		crypto64_secretstream_xchacha20poly1305_pull = sodium
				.lookup<NativeFunction<crypto64_secretstream_xchacha20poly1305_pull_native_t>>("crypto_secretstream_xchacha20poly1305_pull")
				.asFunction();
		crypto_secretstream_xchacha20poly1305_rekey = sodium
				.lookup<NativeFunction<crypto_secretstream_xchacha20poly1305_rekey_native_t>>("crypto_secretstream_xchacha20poly1305_rekey")
				.asFunction();
		// constant kdf bindings
		crypto32_kdf_keybytes = sodium
				.lookup<NativeFunction<crypto32_kdf_keybytes_native_t>>("crypto_kdf_keybytes")
				.asFunction();
		crypto32_kdf_bytes_min = sodium
				.lookup<NativeFunction<crypto32_kdf_bytes_min_native_t>>("crypto_kdf_bytes_min")
				.asFunction();
		crypto32_kdf_bytes_max = sodium
				.lookup<NativeFunction<crypto32_kdf_bytes_max_native_t>>("crypto_kdf_bytes_max")
				.asFunction();
		crypto32_kdf_contextbytes = sodium
				.lookup<NativeFunction<crypto32_kdf_contextbytes_native_t>>("crypto_kdf_contextbytes")
				.asFunction();
		crypto64_kdf_keybytes = sodium
				.lookup<NativeFunction<crypto64_kdf_keybytes_native_t>>("crypto_kdf_keybytes")
				.asFunction();
		crypto64_kdf_bytes_min = sodium
				.lookup<NativeFunction<crypto64_kdf_bytes_min_native_t>>("crypto_kdf_bytes_min")
				.asFunction();
		crypto64_kdf_bytes_max = sodium
				.lookup<NativeFunction<crypto64_kdf_bytes_max_native_t>>("crypto_kdf_bytes_max")
				.asFunction();
		crypto64_kdf_contextbytes = sodium
				.lookup<NativeFunction<crypto64_kdf_contextbytes_native_t>>("crypto_kdf_contextbytes")
				.asFunction();
		// kdf bindings
		crypto_kdf_keygen = sodium
				.lookup<NativeFunction<crypto_kdf_keygen_native_t>>("crypto_kdf_keygen")
				.asFunction();
		crypto32_32_kdf_derive_from_key = sodium
				.lookup<NativeFunction<crypto32_32_kdf_derive_from_key_native_t>>("crypto_kdf_derive_from_key")
				.asFunction();
		crypto32_64_kdf_derive_from_key = sodium
				.lookup<NativeFunction<crypto32_64_kdf_derive_from_key_native_t>>("crypto_kdf_derive_from_key")
				.asFunction();
		crypto64_32_kdf_derive_from_key = sodium
				.lookup<NativeFunction<crypto64_32_kdf_derive_from_key_native_t>>("crypto_kdf_derive_from_key")
				.asFunction();
		crypto64_64_kdf_derive_from_key = sodium
				.lookup<NativeFunction<crypto64_64_kdf_derive_from_key_native_t>>("crypto_kdf_derive_from_key")
				.asFunction();
	}
}

_SodiumBindings _cachedBindings;
_SodiumBindings get bindings => _cachedBindings ??= _SodiumBindings();
