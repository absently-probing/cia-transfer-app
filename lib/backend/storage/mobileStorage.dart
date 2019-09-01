import 'package:secure_upload/backend/storage/storage.dart' as storage;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class MobileStorage extends storage.Storage {

  FlutterSecureStorage _storage;

  MobileStorage() {
    _storage = FlutterSecureStorage();
  }

  @override
  Future<String> get(String key) {
    return _storage.read(key: key);
  }

  @override
  void set(String key, String value) {
    _storage.write(key: key, value: value);
  }

}