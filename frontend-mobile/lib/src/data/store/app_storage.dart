import 'dart:convert';

import '../../config/app_config.dart';
import '../../constants/storage_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  static final AppStorage _appStorage = AppStorage._();
  factory AppStorage() => _appStorage;
  AppStorage._();

  static late FlutterSecureStorage _secureStorage;
  static late SharedPreferences prefs;

  Future<bool> init() async {
    _secureStorage = const FlutterSecureStorage();
    prefs = await SharedPreferences.getInstance();
    return true;
  }

  Future<dynamic> removeData(String key) async {
    key = key + AppConfig.appStorageKey;
    await _secureStorage.delete(key: key);
    return true;
  }

  Future<dynamic> removeAll() async {
    await _secureStorage.deleteAll();
    return true;
  }

  Future<dynamic> checkFirstLaunch() async {
    if (prefs.getBool(isFirstTimeLaunch) == null) {
      removeAll();
      prefs.setBool(isFirstTimeLaunch, true);
    }
  }

  Future<bool> setData(String key, dynamic data) async {
    key = key + AppConfig.appStorageKey;
    final String dataStringify = json.encode(data);
    await _secureStorage.write(key: key, value: dataStringify);
    return true;
  }

  Future<dynamic> getData(String key) async {
    key = key + AppConfig.appStorageKey;
    final String? data = await _secureStorage.read(key: key);
    return data != null ? (json.decode(data)) : null;
  }
}
