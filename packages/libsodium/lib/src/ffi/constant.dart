import "dart:ffi";

class const_ptr  {
	static Pointer<Uint8> uint8_null = Pointer<Uint8>.fromAddress(0);
	static Pointer<Int8> int8_null = Pointer<Int8>.fromAddress(0);

	static Pointer<Uint16> uint16_null = Pointer<Uint16>.fromAddress(0);
	static Pointer<Int16> int16_null = Pointer<Int16>.fromAddress(0);

	static Pointer<Uint32> uint32_null = Pointer<Uint32>.fromAddress(0);
	static Pointer<Int32> int32_null = Pointer<Int32>.fromAddress(0);

	static Pointer<Uint64> uint64_null = Pointer<Uint64>.fromAddress(0);
	static Pointer<Int64> int64_null = Pointer<Int64>.fromAddress(0);

	static Pointer<IntPtr> intptr_null = Pointer<IntPtr>.fromAddress(0);

	static Pointer<Float> float_null = Pointer<Float>.fromAddress(0);
	static Pointer<Double> double_null = Pointer<Double>.fromAddress(0);

	static Pointer<Void> void_null = Pointer<Void>.fromAddress(0);
}
