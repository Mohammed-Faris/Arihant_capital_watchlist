import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:msil_library/utils/config/httpclient_config.dart';
import 'package:msil_library/utils/config/infoIDConfig.dart';
import 'package:msil_library/utils/config/log_config.dart';
import 'package:msil_library/utils/config/streamer_config.dart';
import 'package:msil_library/utils/constants/lib_constants.dart';

import 'init_data.dart';
import 'src/config/app_config.dart';
import 'src/ui/screens/acml_app.dart';

_setConfig() {
  AppConfig.baseURL = 'https://uat-ws.arihantcapital.com';
  AppConfig.flavor = "uat";
  AppConfig.appVersion = '1.0.114';
  AppConfig.displayVersion = '1.0.114';
  AppConfig.iOSChannelName = 'appstore';
  AppConfig.androidChannelName = 'androidmarket';
  AppConfig.appStorageKey = 'acmlUAT';
  StreamerConfig.socketHostUrl = 'uat-ws.arihantcapital.com';
  StreamerConfig.socketMode = SocketMode.TLS;
  StreamerConfig.socketHostPort = 8443;
  StreamerConfig.binaryStream = true;
  HttpClientConfig.encryptionEnabled = true;
  HttpClientConfig.encryptionKey = 'arihanttmsil2021';
  HttpClientConfig.requestTimeout = 30;
  HttpClientConfig.connectionTimeout = 15;
  AppConfig.twoFA = true;
  LogConfig.showLog = false;
  InfoIDConfig.invalidAppIDCode = 'EGN005';
  InfoIDConfig.invalidSessionCode = 'EGN006';
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _setConfig();

  runZonedGuarded(() async {
    await InitData.initCall();
    runApp(
      (const ACMLApp(key: Key("ACMLApp"))),
    );
  },
      (error, stack) => {
            FirebaseCrashlytics.instance.recordError(
              error,
              stack,
              fatal: true,
            ),
            InitData().onerror(
              error.toString(),
            )
          });
}
