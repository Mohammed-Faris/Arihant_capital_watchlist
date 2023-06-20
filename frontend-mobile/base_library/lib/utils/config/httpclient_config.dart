class HttpClientConfig {
  static bool encryptionEnabled = false;
  static String encryptionKey = '';
  static int requestTimeout = 30;
  static int connectionTimeout = 5;
  static bool setSSL = false;
  static List<String> setSSLHexASN1PubKeys = [];
  static bool ignoreSSL = false;
}
