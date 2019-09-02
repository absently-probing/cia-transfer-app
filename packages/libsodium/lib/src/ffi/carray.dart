import 'dart:collection';

import 'dart:ffi';

import 'dart:typed_data';


abstract class CArray<NT extends NativeType, DT extends num>
	extends IterableBase<DT> {
  final Pointer<NT> ptr;
  TypedData data;
  final int length;
  bool freed = false;

  CArray(this.length)
	  : assert(length >= 0),
		ptr = Pointer<NT>.allocate(count: length){
    data = ptr.asExternalTypedData(count: length);
  }

  CArray.from(Iterable<DT> bytes)
	  : length = bytes.length,
		ptr = Pointer.allocate(count: bytes.length) {
    data = ptr.asExternalTypedData();
	final it = bytes.iterator;
	int index = 0;
	while (it.moveNext()) {
	  this[index] = it.current;
	  index++;
	}
  }

  CArray.fromPointer(this.ptr, this.length){
    data = ptr.asExternalTypedData();
  }

  /*
  List<DT> get bytes => List<DT>.unmodifiable(() sync* {
		for (int i = 0; i < length; i++) {
		  yield this[i];
		}
	  }());*/
  ByteBuffer get bytes => data.buffer;

  @override
  Iterator<DT> get iterator => CArrayIterator<NT, DT>(this);

  DT operator [](int index);

  void operator []=(int index, DT value);

  void free(){
   if (!freed){
     ptr.free();
   }

   freed = true;
  }

  @override
  String toString() => '$bytes';
}


class CArrayIterator<NT extends NativeType, DT extends num>
	extends Iterator<DT> {
  final CArray<NT, DT> cArray;
  int _index;

  CArrayIterator(this.cArray) : _index = -1;

  @override
  DT get current => cArray[_index];

  @override
  bool moveNext() {
	if (_index < cArray.length) {
	  _index++;
	  return true;
	}
	return false;
  }
}

abstract class _IntCArray<NT extends NativeType> extends CArray<NT, int> {
  _IntCArray(int length) : super(length);

  _IntCArray.from(Iterable<int> bytes) : super.from(bytes);

  _IntCArray.fromPointer(Pointer<NT> ptr, int length)
	  : super.fromPointer(ptr, length);

  @override
  String toString() => _IntCArray.HexString(bytes.asUint8List());

  static String HexString(List<int> bytes) {
    String hexstr = "0123456789abcdef";
    StringBuffer str = new StringBuffer();
    for (int i = 0; i < bytes.length; ++i){
      var upper = hexstr[(bytes[i] >> 4)];
      var lower = hexstr[(bytes[i] & 0x0f)];
      str.write(upper);
      str.write(lower);
    }

    return str.toString();
  }
}

class Uint8CArray extends _IntCArray<Uint8> {
  Uint8List _list;

  Uint8CArray(int length) : super(length){
    _list = data.buffer.asUint8List();
  }

  Uint8CArray.from(Iterable<int> bytes) : super.from(bytes){
    _list = data.buffer.asUint8List();
  }

  Uint8CArray.fromPointer(Pointer<Uint8> ptr, int length)
	  : super.fromPointer(ptr, length){
    _list = data.buffer.asUint8List();
  }


  @override
  int operator [](int index) {
	  //return ptr.elementAt(index).load<int>();
    return _list[index];
  }

  @override
  void operator []=(int index, int value) {
    //ptr.elementAt(index).store(value);
    _list[index] = value;
  }

  zfree(){
    if (!freed) {
      for (int i = 0; i < this.length; i++){
        //ptr.elementAt(i).store(0);
        _list[i] = 0;
      }
      ptr.free();
    }

    freed = true;
  }
}

class Uint16CArray extends _IntCArray<Uint16> {
  Uint16List _list;

  Uint16CArray(int length) : super(length){
    _list = data.buffer.asUint16List();
  }

  Uint16CArray.from(Iterable<int> bytes) : super.from(bytes){
    _list = data.buffer.asUint16List();
  }

  Uint16CArray.fromPointer(Pointer<Uint16> ptr, int length)
	  : super.fromPointer(ptr, length){
    _list = data.buffer.asUint16List();
  }

  @override
  int operator [](int index) {
	  //return ptr.elementAt(index).load<int>();
    return _list[index];
  }

  @override
  void operator []=(int index, int value) {
	  //return ptr.elementAt(index).store(value);
    _list[index] = value;
  }

  zfree(){
    if (!freed) {
      for (int i = 0; i < this.length; i++){
        //ptr.elementAt(i).store(0);
        _list[i] = 0;
      }
      ptr.free();
    }

    freed = true;
  }
}

class Uint32CArray extends _IntCArray<Uint32> {
  Uint32List _list;
  Uint32CArray(int length) : super(length){
    _list = data.buffer.asUint32List();
  }

  Uint32CArray.from(Iterable<int> bytes) : super.from(bytes){
    _list = data.buffer.asUint32List();
  }

  Uint32CArray.fromPointer(Pointer<Uint32> ptr, int length)
	  : super.fromPointer(ptr, length){
    _list = data.buffer.asUint32List();
  }

  @override
  int operator [](int index) {
	  //return ptr.elementAt(index).load<int>();
    return _list[index];
  }

  @override
  void operator []=(int index, int value) {
	  //return ptr.elementAt(index).store(value);
    _list[index] = value;
  }

  zfree(){
    if (!freed) {
      for (int i = 0; i < this.length; i++){
        //ptr.elementAt(i).store(0);
        _list[i] = 0;
      }
      ptr.free();
    }

    freed = true;
  }
}

class Uint64CArray extends _IntCArray<Uint64> {
  Uint64List _list;

  Uint64CArray(int length) : super(length){
    _list = data.buffer.asUint64List();
  }

  Uint64CArray.from(Iterable<int> bytes) : super.from(bytes){
    _list = data.buffer.asUint64List();
  }

  Uint64CArray.fromPointer(Pointer<Uint64> ptr, int length)
	  : super.fromPointer(ptr, length){
    _list = data.buffer.asUint64List();
  }

  @override
  int operator [](int index) {
	  //return ptr.elementAt(index).load<int>();
    return _list[index];
  }

  @override
  void operator []=(int index, int value) {
	  //return ptr.elementAt(index).store(value);
    _list[index] = value;
  }

  zfree(){
    if (!freed) {
      for (int i = 0; i < this.length; i++){
        //ptr.elementAt(i).store(0);
        _list[i] = 0;
      }
      ptr.free();
    }

    freed = true;
  }
}

class Int8CArray extends _IntCArray<Int8> {
  Int8List _list;

  Int8CArray(int length) : super(length){
    _list = data.buffer.asInt8List();
  }

  Int8CArray.from(Iterable<int> bytes) : super.from(bytes){
    _list = data.buffer.asInt8List();
  }

  Int8CArray.fromPointer(Pointer<Int8> ptr, int length)
	  : super.fromPointer(ptr, length){
    _list = data.buffer.asInt8List();
  }

  @override
  int operator [](int index) {
	  //return ptr.elementAt(index).load<int>();
    return _list[index];
  }

  @override
  void operator []=(int index, int value) {
	  //return ptr.elementAt(index).store(value);
	  _list[index] = value;
  }

  zfree(){
    if (!freed) {
      for (int i = 0; i < this.length; i++){
        //ptr.elementAt(i).store(0);
        _list[i] = 0;
      }
      ptr.free();
    }

    freed = true;
  }
}

class Int16CArray extends _IntCArray<Int16> {
  Int16List _list;

  Int16CArray(int length) : super(length){
    _list = data.buffer.asInt16List();
  }

  Int16CArray.from(Iterable<int> bytes) : super.from(bytes){
    _list = data.buffer.asInt16List();
  }

  Int16CArray.fromPointer(Pointer<Int16> ptr, int length)
	  : super.fromPointer(ptr, length){
    _list = data.buffer.asInt16List();
  }

  @override
  int operator [](int index) {
	  //return ptr.elementAt(index).load<int>();
    return _list[index];
  }

  @override
  void operator []=(int index, int value) {
	  //return ptr.elementAt(index).store(value);
    _list[index] = value;
  }

  zfree(){
    if (!freed) {
      for (int i = 0; i < this.length; i++){
        //ptr.elementAt(i).store(0);
        _list[i] = 0;
      }
      ptr.free();
    }

    freed = true;
  }
}

class Int32CArray extends _IntCArray<Int32> {
  Int32List _list;

  Int32CArray(int length) : super(length){
    _list = data.buffer.asInt32List();
  }

  Int32CArray.from(Iterable<int> bytes) : super.from(bytes){
    _list = data.buffer.asInt32List();
  }

  Int32CArray.fromPointer(Pointer<Int32> ptr, int length)
	  : super.fromPointer(ptr, length){
    _list = data.buffer.asInt32List();
  }

  @override
  int operator [](int index) {
	  //return ptr.elementAt(index).load<int>();
    return _list[index];
  }

  @override
  void operator []=(int index, int value) {
	  //return ptr.elementAt(index).store(value);
    _list[index] = value;
  }

  zfree(){
    if (!freed) {
      for (int i = 0; i < this.length; i++){
        //ptr.elementAt(i).store(0);
        _list[i] = 0;
      }
      ptr.free();
    }

    freed = true;
  }
}

class Int64CArray extends _IntCArray<Int64> {
  Int64List _list;

  Int64CArray(int length) : super(length){
    _list = data.buffer.asInt64List();
  }

  Int64CArray.from(Iterable<int> bytes) : super.from(bytes){
    _list = data.buffer.asInt64List();
  }

  Int64CArray.fromPointer(Pointer<Int64> ptr, int length)
	  : super.fromPointer(ptr, length){
    _list = data.buffer.asInt64List();
  }

  @override
  int operator [](int index) {
	  //return ptr.elementAt(index).load<int>();
    return _list[index];
  }

  @override
  void operator []=(int index, int value) {
	  //return ptr.elementAt(index).store(value);
    _list[index] = value;
  }

  zfree(){
    if (!freed) {
      for (int i = 0; i < this.length; i++){
        //ptr.elementAt(i).store(0);
        _list[i] = 0;
      }
      ptr.free();
    }

    freed = true;
  }
}
