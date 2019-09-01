import "dart:convert";
import "carray.dart";


class CString {
	final Int8CArray str;
	bool freed = false;

	CString._(this.str);

	// need to be freed manually
	factory CString(String dartStr){
		List<int> units = Utf8Encoder().convert(dartStr);
		Int8CArray str = Int8CArray(units.length + 1);
		for (int i = 0; i < units.length; ++i) {
			str[i] = units[i];
		}

		str[units.length] = 0;

		return new CString._(str);
	}

	factory CString.fromSize(int size){
		Int8CArray str = Int8CArray(size);
		return new CString._(str);
	}

	int strlen(){
		var len = 0;
		for(int i = 0; i < str.length; i++){
			if (str[i] == 0){
				len = i;
				break;
			}
		}

		return len;
	}

	String toString() {
		if (freed)
			return null;

		if (str == null) return null;
		int len = 0;
		while (str[++len] != 0);
		List<int> units = List(len);
		for (int i = 0; i < len; ++i) units[i] = str[i];
		return ascii.decode(units);
	}

	zfree(){
		if (!freed) {
			for (int i = 0; i < str.length; i++){
				str[i] = 0;
			}
			str.free();
		}

		freed = true;
	}

	free(){
		if (!freed) {
			str.free();
		}

		freed = true;
	}

  /// Read the string from C memory into Dart.
  static String fromUtf8(CString arr) {
	if(arr.freed) return null;
	if (arr.str == null) return null;
	int len = 0;
	while (arr.str[++len] != 0);
	List<int> units = List(len);
	for (int i = 0; i < len; ++i) units[i] = arr.str[i];
	return Utf8Decoder().convert(units);
  }
}

class UCString {
	final Uint8CArray str;
	bool freed = false;
	UCString._(this.str);

	// need to be freed manually
	factory UCString(String dartStr){
		List<int> units = Utf8Encoder().convert(dartStr);
		Uint8CArray str = Uint8CArray(units.length + 1);
		for (int i = 0; i < units.length; i++) {
			str[i] = units[i];
		}

		str[units.length] = 0;

		return new UCString._(str);
	}

	factory UCString.fromSize(int size){
		Uint8CArray str = Uint8CArray(size);
		return new UCString._(str);
	}

	int strlen(){
		var len = 0;
		for(int i = 0; i < str.length; i++){
			if (str[i] == 0){
				len = i;
				break;
			}
		}

		return len;
	}

	String toString() {
		if (freed)
			return null;

		if (str == null) return null;
		int len = 0;
		while (str[++len] != 0);
		List<int> units = List(len);
		for (int i = 0; i < len; ++i) units[i] = str[i];
		return ascii.decode(units);
	}

	zfree(){
		if (!freed) {
			for (int i = 0; i < str.length; i++){
				str[i] = 0;
			}
			str.free();
		}

		freed = true;
	}

	free(){
		if (!freed) {
			str.free();
		}

		freed = true;
	}

	/// Read the string from C memory into Dart.
	static String fromUtf8(CString arr) {
		if(arr.freed) return null;
		if (arr.str == null) return null;
		int len = 0;
		while (arr.str[++len] != 0);
		List<int> units = List(len);
		for (int i = 0; i < len; ++i) units[i] = arr.str[i];
		return Utf8Decoder().convert(units);
	}
}
