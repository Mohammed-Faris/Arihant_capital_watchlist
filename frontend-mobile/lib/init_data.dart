import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:msil_library/utils/config/errorMsgConfig.dart';
import 'package:msil_library/utils/config/log_config.dart' as log;
import 'package:my_logger/core/constants.dart';
import 'package:my_logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

import 'src/constants/app_constants.dart';
import 'src/constants/storage_constants.dart';
import 'src/data/store/app_storage.dart';
import 'src/data/store/app_store.dart';

class InitData {
  onerror(error) {
    if (log.LogConfig.showLog) {
      MyLogger.fatal('$error', className: 'UnHandled Exception');
    }
  }

  static Future<bool> initCall() async {
    await Firebase.initializeApp();
    ErrorMsgConfig.not_able_to_resolve_service =
        "Oops! Looks like there's a connection error. Try again!";
    FlutterError.onError = (FlutterErrorDetails details) async {
      InitData().onerror(
        (details.exception).toString(),
      );
      FirebaseCrashlytics.instance.recordFlutterError(
        details,
      );
    };

    if (kDebugMode) {
      log.LogConfig.showLog = true;
    }
    if (log.LogConfig.showLog) {
      var config = MyLogger.config;
      config.isDevelopmentDebuggingEnabled = false;
      config.timestampFormat = TimestampFormat.TIME_FORMAT_FULL_3;
      config.isLogsEnabled = false;
      config.isDebuggable = false;
      config.isDevelopmentDebuggingEnabled = false;
      config.activeLogLevel = LogLevel.DEBUG;
      MyLogger.applyConfig(config);
    }

    if (Platform.isAndroid) {
      await Permission.notification.isGranted.then((value) {
        if (!value) {
          Permission.notification.request();
        }
      });
      await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
    }
    final bool callBack = await AppStorage().init();
    final dynamic getTheme = await AppStorage().getData(themeType);
    final String themType = (getTheme ?? AppConstants.lightMode) as String;
    AppStore().setThemeData(themType);
    AppStore().setOrientations();
    if (callBack) {
      AppStore().setThemeData(AppStore().getThemeData());
      SystemChrome.setSystemUIOverlayStyle(
          AppStore.themeType == AppConstants.lightMode
              ? SystemUiOverlayStyle.dark
              : SystemUiOverlayStyle.light);
      await AppStorage().checkFirstLaunch();

      return true;
    }
    return false;
  }
}
