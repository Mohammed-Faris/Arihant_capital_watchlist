class LibStore {
  static final LibStore _httpStore = LibStore._();
  factory LibStore() => _httpStore;
  LibStore._();

  String? _sessionCookie;
  String? _sessionID;
  String? _appID;

  String? getSessionCookie() {
    return _sessionCookie;
  }

  void setCookie(String cookie) {
    _sessionCookie = cookie;
  }

  void clearSessionCookie() {
    _sessionCookie = null;
  }

  void setSESSIONID(String s) {
    _sessionID = s;
  }

  String? getSESSIONID() {
    return _sessionID;
  }

  void setAppID(String appID) {
    _appID = appID;
  }

  String? getAppID() {
    return _appID;
  }
}
