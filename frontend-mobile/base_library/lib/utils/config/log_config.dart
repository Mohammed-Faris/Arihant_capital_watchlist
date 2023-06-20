import 'dart:developer';

import 'package:my_logger/models/logger.dart';

class LogConfig {
  static bool showLog = false;

  void printLog(String msg) {
    print('\x1B[32m$msg\x1B[0m');
  }

  void logInfo(String logName, dynamic msg) {
    log('\x1B[34m $logName $msg\x1B[0m');
  }

  Future<void> logSuccess(String logName, dynamic msg) async {
    if (showLog && (logName.contains("http") || logName.contains("ws"))) {
      MyLogger.trace('$msg', className: '$logName');
    }
    log('\x1B[32m SUCCESS API $logName $msg\x1B[0m');
  }

  void logWarning(String logName, dynamic msg) {
    log('\x1B[33m WARNING API $logName $msg \x1B[0m');
  }

  void logError(String logName, dynamic msg) {
    if (showLog && (logName.contains("http") || logName.contains("ws"))) {
      MyLogger.error('$msg', className: '$logName');
    }
    log('\x1B[31m FAILURE API $logName $msg\x1B[0m');
  }
}
