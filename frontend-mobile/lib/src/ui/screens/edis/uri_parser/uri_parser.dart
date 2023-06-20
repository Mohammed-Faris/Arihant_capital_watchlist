class UriParser {
  static const String title = 'title';
  static const String msg = 'msg';

  Map<String, String> queryParams = {};

  UriParser(Uri uri) {
    queryParams = uri.queryParameters;
  }

  String _getQueryParameter(String key) {
    return queryParams.containsKey(key) ? queryParams[key]! : '';
  }

  String getTitle() {
    return _getQueryParameter(title);
  }

  String getMsg() {
    return _getQueryParameter(msg);
  }
}
