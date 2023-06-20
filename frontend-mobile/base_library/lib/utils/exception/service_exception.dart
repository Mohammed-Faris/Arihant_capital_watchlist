class ServiceException implements Exception {
  late String code;
  late String msg;

  ServiceException(String code, String msg) {
    this.code = code;
    this.msg = msg;
  }
}
