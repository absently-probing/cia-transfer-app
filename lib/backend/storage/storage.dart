abstract class Storage {
  Future<String> get(String key);
  void set(String key, String value);
}