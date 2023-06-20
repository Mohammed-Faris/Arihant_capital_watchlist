class InvalidException implements Exception {
  late String code;
  late String msg;

  InvalidException(String code, String msg) {
    this.code = code;
    this.msg = msg;
  }
}
