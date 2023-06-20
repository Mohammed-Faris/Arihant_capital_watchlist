// ignore_for_file: depend_on_referenced_packages

library msil_httpclient;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:asn1lib/asn1lib.dart';
import 'package:convert/convert.dart';
import 'package:encrypt/encrypt.dart';
import '../utils/constants/error_constants.dart';

import '../utils/config/errorMsgConfig.dart';
import '../utils/config/httpclient_config.dart';
import '../utils/config/log_config.dart';
import '../utils/exception/service_exception.dart';
import '../utils/lib_store.dart';

class HTTPClient {
  String unabletoResolveService = ErrorMsgConfig.showErrorCode
      ? ErrorMsgConfig.not_able_to_resolve_service +
          ERROR_UNABLE_TO_RESOLVE_SERVICE
      : ErrorMsgConfig.not_able_to_resolve_service;

  String connectionRefused = ErrorMsgConfig.showErrorCode
      ? ErrorMsgConfig.connection_refused + ERROR_CONNECTION_REFUSED
      : ErrorMsgConfig.connection_refused;

  String invalidResponse = ErrorMsgConfig.showErrorCode
      ? ErrorMsgConfig.invalid_response + ERROR_INVALID_RESPONSE
      : ErrorMsgConfig.invalid_response;

  String unabletoFetchData = ErrorMsgConfig.showErrorCode
      ? ErrorMsgConfig.unable_to_fetch_data + ERROR_UNABLE_TO_FETCH_DATA
      : ErrorMsgConfig.unable_to_fetch_data;

  String unabletoConnectServer = ErrorMsgConfig.showErrorCode
      ? ErrorMsgConfig.unable_to_connect_server + ERROR_UNABLE_TO_CONNECT_SERVER
      : ErrorMsgConfig.unable_to_connect_server;

  String timeOutException = ErrorMsgConfig.showErrorCode
      ? ErrorMsgConfig.server_busy + ERROR_SERVER_BUSY
      : ErrorMsgConfig.server_busy;

  String sslFailed = ErrorMsgConfig.showErrorCode
      ? ErrorMsgConfig.ssl_certificate_failed +
          ERROR_UNABLE_TO_CONNECT_SSL_FAILED
      : ErrorMsgConfig.ssl_certificate_failed;

  final Duration _requestTimeout =
      Duration(seconds: HttpClientConfig.requestTimeout);

  final Duration _connectTimeout =
      Duration(seconds: HttpClientConfig.connectionTimeout);

  final Encrypter encrypter = Encrypter(
    AES(Key.fromUtf8(HttpClientConfig.encryptionKey), mode: AESMode.cbc),
  );

  List<String> sslHexASN1PubKeys = HttpClientConfig.setSSLHexASN1PubKeys;

  Future<Map<String, dynamic>> postJSONRequest({
    required String url,
    Object? data,
    bool? isEncryption,
    Map<String, dynamic>? additionalHeaders,
  }) async {
    isEncryption = isEncryption ?? HttpClientConfig.encryptionEnabled;

    final String jsonRequest = json.encode(data);

    final String response = await fetchRequest(
      url: url,
      data: jsonRequest,
      isEncryption: isEncryption,
      additionalHeaders: additionalHeaders,
    );

    if (json.decode(response)["response"]["infoID"].toString() == "0") {
      LogConfig().logSuccess(
          url, {"url": url, "Request": jsonRequest, "Response": response});
    } else {
      LogConfig().logError(
          url, {"url": url, "Request": jsonRequest, "Response": response});
    }

    return json.decode(response) as Map<String, dynamic>;
  }

  Future<String> fetchRequest({
    required String url,
    String? data,
    required bool isEncryption,
    bool isGetMethod = false,
    Map<String, dynamic>? additionalHeaders,
  }) async {
    HttpClient client = HttpClient();

    if (HttpClientConfig.ignoreSSL) {
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
    }

    try {
      client.connectionTimeout = _connectTimeout;

      HttpClientRequest request;
      if (isGetMethod) {
        request = await client.getUrl(Uri.parse(url));
      } else {
        request = await client.postUrl(Uri.parse(url));
      }

      request.headers.set('Content-type', 'application/json');
      request.headers.set('Accept-Encoding', 'gzip');
      request.headers.set('Content-Encoding', 'gzip');
      request.headers.set('X-ENCRYPT', isEncryption);

      if (LibStore().getSessionCookie() != null) {
        request.headers.set('Cookie', LibStore().getSessionCookie() ?? '');
      }

      if (additionalHeaders != null) {
        additionalHeaders.forEach((key, value) {
          request.headers.set(key, value);
        });
      }

      if (data != null && data.isNotEmpty) {
        if (isEncryption) {
          final Encrypted encrypted = encrypter.encrypt(
            data,
            iv: IV(utf8.encoder.convert(HttpClientConfig.encryptionKey)),
          );

          request.write(encrypted.base64);
        } else {
          request.write(data);
        }
      }

      final HttpClientResponse response =
          await request.close().timeout(_requestTimeout);

      if (!HttpClientConfig.setSSL ||
          (response.certificate != null &&
              doSSLPubKeyPinning(response.certificate!))) {
        final int responseCode = response.statusCode;

        storeCookie(response.headers);
        if (responseCode == 200) {
          final String sResponse =
              await response.transform(utf8.decoder).join();
          if (isEncryption) {
            final String decrypted = encrypter.decrypt64(
              sResponse,
              iv: IV(utf8.encoder.convert(HttpClientConfig.encryptionKey)),
            );
            return decrypted;
          } else {
            return sResponse;
          }
        } else {
          LogConfig().logError(url, {"url": url, "Response": response});
          throw ServiceException(
            ERROR_INVALID_RESPONSE,
            invalidResponse,
          );
        }
      } else {
        LogConfig().logError(url, {"url": url, "Response": response});
        throw ServiceException(
          ERROR_UNABLE_TO_CONNECT_SSL_FAILED,
          sslFailed,
        );
      }
    } on SocketException catch (e) {
      LogConfig().logError(url, {
        "url": url,
        "Response":
            "SocketException - Failed HTTPClient Request > $url body> $data, error== ${e.osError}, toString==${e.toString()}"
      });
      if (e.osError == null) {
        throw ServiceException(
          ERROR_UNABLE_TO_CONNECT_SERVER,
          e.message,
        );
      } else {
        if (e.osError?.errorCode == 7 || e.osError?.errorCode == 8) {
          // 7 = Android, 8 = iOS
          throw ServiceException(
            ERROR_UNABLE_TO_RESOLVE_SERVICE,
            unabletoResolveService,
          );
        } else if (e.osError?.errorCode == 111 || e.osError?.errorCode == 54) {
          // 111 = Android, 54 = iOS
          throw ServiceException(
            ERROR_CONNECTION_REFUSED,
            connectionRefused,
          );
        } else {
          throw ServiceException(
            ERROR_UNABLE_TO_CONNECT_SERVER,
            e.message,
          );
        }
      }
    } on TimeoutException catch (e) {
      LogConfig().logError(url, {
        "url": url,
        "Response":
            "TimeoutException - Failed HTTPClient Request > $url body> $data' $e"
      });

      throw ServiceException(
        ERROR_SERVER_BUSY,
        timeOutException,
      );
    } on ServiceException catch (e) {
      LogConfig().logError(url, {
        "url": url,
        "Response":
            "ServiceException - Failed HTTPClient Request > $url body> $data code==${e.code} msg==${e.msg}"
      });

      throw ServiceException(
        e.code,
        e.msg,
      );
    } on Exception catch (e) {
      LogConfig().logError(url, {
        "url": url,
        "Response":
            "Exception - Failed HTTPClient Request > $url body> $data' $e"
      });

      throw ServiceException(
        ERROR_UNABLE_TO_FETCH_DATA,
        unabletoFetchData,
      );
    } finally {
      client.close();
    }
  }

  Future<Map<String, dynamic>> getJSONRequest({
    required String url,
    bool? isEncryption,
  }) async {
    isEncryption = isEncryption ?? HttpClientConfig.encryptionEnabled;

    String? response = await fetchRequest(
        url: url, isEncryption: isEncryption, isGetMethod: true);

    return json.decode(response) as Map<String, dynamic>;
  }

  certificateError(X509Certificate cert, String host, int port) {
    LogConfig().logError("", 'statement-1 cert $cert');
    LogConfig().logError("", 'statement-1 host $host');
    LogConfig().logError("", 'statement-1 port $port');
    return true;
  }

  List<int> getSSLPubKey(X509Certificate x509certificate) {
    ASN1Parser p = ASN1Parser(x509certificate.der);
    ASN1Sequence signedCert = p.nextObject() as ASN1Sequence;
    ASN1Sequence cert = signedCert.elements[0] as ASN1Sequence;
    ASN1Sequence pubKeyElement = cert.elements[6] as ASN1Sequence;
    ASN1BitString pubKeyBits = pubKeyElement.elements[1] as ASN1BitString;

    return pubKeyBits.stringValue;
  }

  bool doSSLPubKeyPinning(X509Certificate cert) {
    List<int> sslPubKey = getSSLPubKey(cert);

    String hexASN1 = hex.encode(sslPubKey);

    return sslHexASN1PubKeys.contains(hexASN1);
  }

  void storeCookie(final HttpHeaders headers) {
    String output = '';

    headers.forEach(
      (String key, List<String> values) {
        if (key == 'set-cookie') {
          for (var v in values) {
            output += ' ${v.split(';').elementAt(0)};';
          }
        }
      },
    );

    if (output.isEmpty) {
      return;
    }

    output = output.substring(0, output.length - 1);
    getSessionID(output);
    LibStore().setCookie(output);
  }

  void getSessionID(String cookiesString) {
    String sessionID = '';
    sessionID += cookiesString.split(';').elementAt(0).split('=').elementAt(1);
    LibStore().setSESSIONID(sessionID);
  }
}

class Response {
  String requestURL;
  String reqTime;
  String respTime;
  String duration;
  Response(
      {required this.duration,
      required this.reqTime,
      required this.requestURL,
      required this.respTime});
}
