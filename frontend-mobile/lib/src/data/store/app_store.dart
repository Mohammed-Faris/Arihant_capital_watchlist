import 'dart:convert';

import 'package:async/async.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:msil_library/utils/lib_store.dart';

import '../../constants/app_constants.dart';
import '../../models/common/symbols_model.dart';
import '../../models/orders/order_book.dart';
import 'app_storage.dart';
import 'app_utils.dart';

class AppStore {
  static final AppStore _appStore = AppStore._();
  static String currentRoute = "";
  static Object? currentArgs = "";
  static CancelableOperation? fetchSession;

  factory AppStore() => _appStore;

  AppStore._();
  Map<String, dynamic>? _accDetails;

  late String _appID;
  String _accountName = "";
  String _uid = "";
  static Symbols? _selectedHolding;
  static Orders? _selectedPosition;

  static Orders? _selectedOrder;
  static String _accountStatus = AppConstants.activated;
  bool isCurrencyAvailable = false;
  bool isCommodityAvailable = false;
  static DateTime? initFetchedTime;
  static String themeType = AppConstants.lightMode;
  static List<String> subscribedPages = [];

  Map? _precisionList;
  late List<Symbols> indicesSymbolList;
  late List<Symbols> indicesEditSymbolList;
  String _userName = "";
  String pushLink = '';
  bool _isPushClicked = false;
  bool isFnoAvailable = false;
  static final ValueNotifier<bool> isNomineeAvailable =
      ValueNotifier<bool>(false);

  bool isAccountActivated = true;
  void setinitFetchedTime({bool clear = false}) {
    initFetchedTime = clear ? null : DateTime.now();
  }

  DateTime? getinitFetchedTime() {
    return initFetchedTime;
  }

  void setAppID(String appID) {
    _appID = appID;
    LibStore().setAppID(appID);
  }

  String getAppID() {
    return _appID;
  }

  Symbols? getSelectedHolding() {
    return _selectedHolding;
  }

  Orders? getSelectedPosition() {
    return _selectedPosition;
  }

  Orders? getSelectedOrder() {
    return _selectedOrder;
  }

  void setPosition(Orders? selectedPositiom) {
    _selectedPosition = selectedPositiom;
  }

  void setOrder(Orders? selectedOrder) {
    _selectedOrder = selectedOrder;
  }

  void setAccountStatus(String? accountStatus) {
    _accountStatus = accountStatus ?? AppConstants.activated;
  }

  void setAccountDetials(Map<String, dynamic>? accDetails) {
    _accDetails = accDetails;
  }

  Map<String, dynamic>? getAccDetails() {
    return _accDetails;
  }

  void setHolding(Symbols? selectedHolding) {
    _selectedHolding = selectedHolding;
  }

  String getAccStatus() {
    return _accountStatus;
  }

  String getUid() {
    return _uid;
  }

  String getAccountName() {
    return _accountName;
  }

  String getuserName() {
    return _userName;
  }

  void setUserName(String? username) {
    _userName = username ?? "";
  }

  void setAccountName(String? accountName) {
    _accountName = accountName ?? "";
  }

  String getPushLink() {
    return pushLink;
  }

  void setPushLink(String link) {
    pushLink = link;
  }

  bool getFnoAvailability() {
    return isFnoAvailable;
  }

  bool getCurrencyAvailability() {
    return isCurrencyAvailable;
  }

  bool getCommodityAvailability() {
    return isCommodityAvailable;
  }

  void setCurrencyAvailablity(bool isCurrency) {
    isCurrencyAvailable = isCurrency;
  }

  void setCommodityAvailablity(bool isCommodity) {
    isCommodityAvailable = isCommodity;
  }

  void setFnoAvailability(bool isFno) {
    isFnoAvailable = isFno;
  }

  void setisActivated(bool isActivated) {
    isAccountActivated = isActivated;
  }

  Future<void> setPushClicked(bool data) async {
    _isPushClicked = data;
  }

  bool isPushClicked() {
    return _isPushClicked;
  }

  bool isActivatedAccount() {
    return isAccountActivated;
  }

  List<Symbols> getIndicesList() {
    return indicesSymbolList;
  }

  void setIndicesList(List<Symbols> indicesList) {
    indicesSymbolList = indicesList;
  }

  List<Symbols> getIndicesEditorList() {
    return indicesEditSymbolList;
  }

  void setIndicesEditList(List<Symbols> indicesList) {
    indicesEditSymbolList = indicesList;
  }

  void setJSESSIONID(String s) {
    LibStore().setSESSIONID(s);
  }

  String? getJSESSIONID() {
    return LibStore().getSESSIONID();
  }

  Map getPrecision() {
    return _precisionList ?? {};
  }

  void setPrecision(Map precisionList) {
    _precisionList = precisionList;
  }

  void setThemeData(String data) {
    themeType = data;
  }

  void setOrientations() {
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp],
    );
    if (AppUtils.isTablet) {
      SystemChrome.setPreferredOrientations(
        DeviceOrientation.values,
      );
    }
  }

  void setUid(String uid) {
    _uid = uid;
  }

  String getThemeData() {
    return themeType;
  }

  void clearLoginSession() {
    AppStore().setCurrencyAvailablity(false);
    AppStore().setFnoAvailability(false);
    LibStore().clearSessionCookie();
  }

  Future<String> getSavedDataFromAppStorage(String key) async {
    final encrypt.Encrypter encrypter = encrypt.Encrypter(
      encrypt.AES(encrypt.Key.fromUtf8('acmlencryptk2021'),
          mode: encrypt.AESMode.cbc),
    );

    final String valueForKey = await AppStorage().getData(key);

    final String decryptedString = encrypter.decrypt64(
      valueForKey,
      iv: encrypt.IV(Uint8List.fromList(utf8.encode('acmlencryptk2021'))),
    );

    return decryptedString;
  }
}
