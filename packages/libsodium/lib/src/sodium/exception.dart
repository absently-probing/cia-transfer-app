class CryptoException implements Exception {
  String cause;
  CryptoException(this.cause);
}

class InvalidCiphertext implements Exception {
  String cause;
  InvalidCiphertext(this.cause);
}