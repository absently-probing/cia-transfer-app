class CryptoException implements Exception {
  String cause;
  CryptoException(this.cause);

  String toString(){
    return cause;
  }
}

class InvalidCiphertext implements Exception {
  String cause;
  InvalidCiphertext(this.cause);

  String toString(){
    return cause;
  }
}