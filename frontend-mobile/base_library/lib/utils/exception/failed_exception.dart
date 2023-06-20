class FailedException implements Exception {
  late String code;
  late String msg;
  late Map data;

  FailedException(String code, String msg, Map data) {
    this.code = code;
    this.msg = msg;
    this.data = data;
  }
}
