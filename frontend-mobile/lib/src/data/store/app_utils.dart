import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';
import 'dart:typed_data';

import 'package:acml/src/ui/screens/acml_app.dart';
import 'package:basic_utils/basic_utils.dart' as base_utils;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:intl/intl.dart' as intl;

import '../../config/app_config.dart';
import '../../constants/app_constants.dart';
import '../../constants/keys/login_keys.dart';
import '../../constants/storage_constants.dart';
import '../../localization/app_localization.dart';
import '../../models/alerts/alerts_model.dart';
import '../../models/common/sym_model.dart';
import '../../models/common/symbols_model.dart';
import '../../models/config/config_model.dart';
import '../../models/my_funds/transaction_history_model.dart';
import '../../models/watchlist/crop_symbol_list_model.dart';
import '../../models/watchlist/watchlist_group_model.dart';
import '../../ui/styles/app_color.dart';
import '../../ui/styles/app_images.dart';
import '../../ui/styles/app_widget_size.dart';
import '../../ui/widgets/label_border_text_widget.dart';
import '../cache/cache_repository.dart';
import 'app_storage.dart';
import 'app_store.dart';

class AppUtils {
  static String get _getDeviceType {
    final data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
    return data.size.shortestSide < 550 ? 'phone' : 'tablet';
  }

  static DateTime? start;
  static DateTime? end;
  static bool get isTablet {
    return _getDeviceType == 'tablet';
  }

  static List<String> streamingKeys = <String>[
    AppConstants.streamingHigh,
    AppConstants.streamingLow,
    AppConstants.streamingVol,
    AppConstants.streamingAtp,
    AppConstants.streamingOpen,
    AppConstants.streamingClose,
    AppConstants.streamingLowerCircuit,
    AppConstants.streamingUpperCircuit,
    AppConstants.streamingOi,
  ];
  void clearStorage({required String type}) {
    if (type == AppConstants.invalidAppInDErrorCode) {
      AppStorage().removeData(appid);
    }
  }

  double chooseWatchlistHeight(List<Groups> groups) {
    return (((groups.length + 1) * AppWidgetSize.dimen_70) +
        AppWidgetSize.dimen_3 +
        (watchlistLimitReached(groups) ? AppWidgetSize.dimen_110 : 0));
  }

  static Widget weekly(Symbols symbolItem, BuildContext context) {
    if (symbolItem.sym?.isWeekly ?? false) {
      return SizedBox(
        child: AppImages.weeklyBackground(context, width: 15.w),
      );
    } else {
      return Container();
    }
  }

  static setAccDetails() async {
    Map<String, dynamic>? accDetails =
        await AppStorage().getData("userLoginDetailsKey");
    accDetails?["uid"] =
        await AppStore().getSavedDataFromAppStorage("userIdKey");
    AppStore().setAccountDetials(accDetails);
  }

  static List<String> rollOverCashKeys = [
    "IDX",
    "highro",
    "lowest",
  ];
  static List<String> marketMoverTabKeysCash = [
    "topGainers",
    "topLosers",
    "yHigh",
    "yLow",
    "activeVolume",
    "activeValue",
    "ucl",
    "lcl",
    // "OIGainers",
    // "OILosers"
  ];
  static List<String> rollOverDispKeys = [
    AppLocalizations().indexRollover,
    AppLocalizations().highestRollover,
    AppLocalizations().lowestRollover,
  ];
  static List<String> marketMoverTabKeysCashDisplayKeys = [
    AppLocalizations().marketsTopGainers,
    AppLocalizations().marketsTopLosers,
    AppLocalizations().marketsTopFiftyTwoWkHgh,
    AppLocalizations().marketsTopFiftyTwoWkLow,
    AppLocalizations().marketsMostActiveVolume,
    AppLocalizations().marketsMostActiveValue,
    AppLocalizations().marketsUpperCircuit,
    AppLocalizations().marketsLowerCircuit,
    // AppLocalizations().oIGainers,
    // AppLocalizations().oILosers
  ];
  static List<String> marketMoverTabKeysDerivatives = [
    "topGainers",
    "topLosers",
    "activeValue",
    "OIGainers",
    "OILosers"
  ];
  static List<String> marketMoverTabKeysDerivativesDisplayKeys = [
    AppLocalizations().marketsTopGainers,
    AppLocalizations().marketsTopLosers,
    AppLocalizations().marketsMostActiveValue,
    AppLocalizations().oIGainers,
    AppLocalizations().oILosers
  ];
  String getAmoStatusForExchange(String exchange) {
    return getAmoStatus(
      exchange,
    )
        ? AppLocalizations().live
        : AppLocalizations().closed;
  }

  static ThemeData datePicketTheme({bool isPrimary = true}) {
    return AppStore().getThemeData() == AppConstants.darkMode
        ? ThemeData.dark().copyWith(
            colorScheme: ColorScheme.fromSwatch(
                primarySwatch: isPrimary
                    ? MaterialColor(AppColors().positiveColor.value,
                        AppColors.calendarPrimaryColorSwatch)
                    : MaterialColor(AppColors.negativeColor.value,
                        AppColors.calendarSecondaryColorSwatch)),
          )
        : ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSwatch(
                primarySwatch: isPrimary
                    ? MaterialColor(AppColors().positiveColor.value,
                        AppColors.calendarPrimaryColorSwatch)
                    : MaterialColor(AppColors.negativeColor.value,
                        AppColors.calendarSecondaryColorSwatch)),
          );
  }

  static bool isMarketStartedAndNodataavailable() {
    DateTime now = DateTime.now().toUtc();
    DateTime startTime = DateTime.utc(now.year, now.month, now.day,
        AppUtils().intValue("03"), AppUtils().intValue("30"));

    return now.difference(startTime).inMinutes < 15 &&
        now.difference(startTime).inMinutes > 0;
  }

  bool getAmoStatus(
    String exchange,
  ) {
    AmoMktTimings? amoMktTimings;

    for (var element in AppConfig.amoMktTimings) {
      if (element.exc == exchange) {
        amoMktTimings = element;
      }
    }
    if (amoMktTimings!.amoStartTime!.isNotEmpty &&
        amoMktTimings.amoEndTime!.isNotEmpty) {
      DateTime now = DateTime.now().toUtc();
      DateTime startTime = DateTime.utc(
              now.year,
              now.month,
              now.day,
              AppUtils().intValue(amoMktTimings.amoStartTime!.split(":")[0]),
              AppUtils().intValue(amoMktTimings.amoStartTime!.split(":")[1]))
          .subtract(const Duration(hours: 5, minutes: 30));
      DateTime endTime = DateTime.utc(
              now.year,
              now.month,
              now.day,
              AppUtils().intValue(amoMktTimings.amoEndTime!.split(":")[0]),
              AppUtils().intValue(amoMktTimings.amoEndTime!.split(":")[1]))
          .subtract(const Duration(hours: 5, minutes: 30));
      now = now.toLocal();
      startTime = startTime.toLocal();
      endTime = endTime.toLocal();
      return !(now.isBetween(endTime, startTime) ?? false);
    }
    return true;
  }

  bool watchlistLimitReached(List<Groups> groups) {
    return (groups.isEmpty ||
        groups.where((element) => element.editable != false).length <
            AppUtils().intValue(AppConfig.watchlistGroupLimit));
  }

  String getBankLogoName(String bankname) {
    if (bankname.isNotEmpty) {
      int indexvalue =
          _getBankNameList().values.toList().indexOf(bankname.toLowerCase());
      if (indexvalue != -1) {
        return _getBankNameList().keys.toList().elementAt(indexvalue);
      }
    }
    return AppConstants.DEFAULT_BANK;
  }

  Widget labelBorderWidgetBottom(
      String? title, Widget? svgPicture, Function? labelTapAction) {
    return Container(
      width: AppWidgetSize.dimen_100,
      padding: EdgeInsets.only(bottom: AppWidgetSize.dimen_5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
              width: AppWidgetSize.dimen_120,
              child: LabelBorderWidget(
                  keyText: Key(title ?? ""),
                  text: title,
                  textColor:
                      Theme.of(navigatorKey.currentContext!).primaryColor,
                  fontSize: AppWidgetSize.fontSize14,
                  margin: EdgeInsets.only(
                    right: AppWidgetSize.dimen_5,
                  ),
                  withicon: true,
                  svgPicture: svgPicture,
                  borderRadius: AppWidgetSize.dimen_24,
                  backgroundColor: Theme.of(navigatorKey.currentContext!)
                      .scaffoldBackgroundColor,
                  borderWidth: 1,
                  borderColor:
                      Theme.of(navigatorKey.currentContext!).dividerColor,
                  isSelectable: true,
                  textAlign: TextAlign.right,
                  labelTapAction: labelTapAction)),
        ],
      ),
    );
  }

  static String? getPayInStatus(BuildContext context, History data) {
    if (data.payIn != null) {
      if (data.payIn == true) {
        if (data.status?.toLowerCase() == "failure") {
          return AppLocalizations.of(context)?.moneyAddedFailed;
        }
        return AppLocalizations.of(context)?.moneyAdded;
      } else {
        if (data.status?.toLowerCase() == "failure") {
          return AppLocalizations.of(context)?.moneyWithdrawnFail;
        }
        return AppLocalizations.of(context)?.moneyWithdrawn;
      }
    }
    return null;
  }

  static Widget buildMoneyIcon(BuildContext context, History data) {
    if (data.status?.toLowerCase() == "failure") {
      return Container(
        padding: EdgeInsets.only(
            left: AppWidgetSize.dimen_15, right: AppWidgetSize.dimen_15),
        height: AppWidgetSize.dimen_70,
        child: AppImages.failImage(
          context,
          isColor: true,
          color: AppColors.negativeColor,
          height: AppWidgetSize.dimen_34,
        ),
      );
    }
    if (data.payIn != null) {
      if (data.payIn == true) {
        return AppImages.moneyAdded(
          context,
          color: Theme.of(context).primaryIconTheme.color,
          height: AppWidgetSize.dimen_60,
        );
      } else {
        return AppImages.moneyWithdraw(
          context,
          color: Theme.of(context).primaryIconTheme.color,
          height: AppWidgetSize.dimen_60,
        );
      }
    }

    return Container();
  }

  Widget buildFilterIcon(BuildContext context, {bool isSelected = false}) {
    return SizedBox(
      width: AppWidgetSize.dimen_30,
      height: AppWidgetSize.dimen_22,
      child: Stack(
        children: [
          AppImages.sortDisable(context,
              color: Theme.of(context).primaryIconTheme.color,
              isColor: true,
              height: 25.w,
              width: 25.w),
          isSelected
              ? Positioned(
                  right: AppWidgetSize.dimen_7,
                  child: Container(
                    width: AppWidgetSize.dimen_5,
                    height: AppWidgetSize.dimen_5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.w),
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  Map<String, String> _getBankNameList() {
    return {
      AppConstants.AXIS_BANK: 'axis bank',
      AppConstants.AU_SMALL_BANK: 'au small finanace bank',
      AppConstants.BOB_BANK: 'bank of baroda net banking retail',
      AppConstants.BOB_BANK_CORPORATE: 'bank of baroda net banking corporate',
      AppConstants.BOI_BANK: 'bank of india',
      AppConstants.BOM_BANK: 'bank of maharashtra',
      AppConstants.CSB_BANK: 'csb bank', //catholic syrian bank ltd
      AppConstants.CITI_BANK: 'citibank na',
      AppConstants.CUB_BANK: 'city union bank', //city union bank
      AppConstants.DEUTSCHE_BANK: 'deutsche bank',
      AppConstants.HDFC_BANK: 'hdfc bank', //hdfc bank ltd
      AppConstants.ICICI_BANK: 'icici bank',
      AppConstants.IDBI_BANK: 'idbi bank', //idbi bank ltd
      AppConstants.INDIAN_BANK: 'indian bank',
      AppConstants.INDIAN_OVERSEAS_BANK: 'indian overseas bank',
      AppConstants.INDUSIND_BANK: 'indusind bank',
      AppConstants.SARASWAT_BANK:
          'saraswat bank - retail', //saraswat co-operative bank ltd
      AppConstants.KARNATAKA_BANK: 'karnataka bank',
      AppConstants.LVB_BANK:
          'lakshmi vilas bank netbanking', //lakshmi vilas bank
      AppConstants.KMB_BANK: 'kotak mahindra bank',
      AppConstants.SBI_BANK: 'state bank of india',
      AppConstants.KVB_BANK: 'karur vysya bank',
      AppConstants.DHANLAXMI_BANK: 'dhanlaxmi bank', //dhanlaxmi bank ltd
      AppConstants.TMB_BANK: 'tamilnad mercantile bank',
      AppConstants.PUNJAB_SIND_BANK: 'punjab and sind bank',
      AppConstants.IDFC_FIRST_BANK:
          'idfc first bank limited', //idfc first bank ltd
      AppConstants.FEDERAL_BANK:
          'federal bank', //federal bank ltd federal bank - retail
      AppConstants.JK_BANK: 'jammu and kashmir bank', //jammu & kashmir bank ltd
      AppConstants.YES_BANK: 'yes bank',
      AppConstants.RBL_BANK: 'rbl bank',
      AppConstants.UNION_BANK: 'union bank of india - retail',
      AppConstants.PNB_BANK: 'punjab national bank [retail]',
      AppConstants.PNB_BANK_CORPORATE: 'punjab national bank - corporate',
    };
  }

  Widget buildBankLogo(String bankLogo) {
    Map<String, dynamic> banklogomap = {
      AppConstants.AXIS_BANK: AppImages.axis_bank(),
      AppConstants.AU_SMALL_BANK: AppImages.au_small_finance(),
      AppConstants.BOB_BANK: AppImages.bob_bank(),
      AppConstants.BOB_BANK_CORPORATE: AppImages.bob_bank(),
      AppConstants.BOI_BANK: AppImages.boi_bank(),
      AppConstants.BOM_BANK: AppImages.bom_bank(),
      AppConstants.CITI_BANK: AppImages.citi_bank(),
      AppConstants.CSB_BANK: AppImages.csb_bank(),
      AppConstants.CUB_BANK: AppImages.cub_bank(),
      AppConstants.DEFAULT_BANK: AppImages.default_bank(),
      AppConstants.DEUTSCHE_BANK: AppImages.deutsche_bank(),
      AppConstants.HDFC_BANK: AppImages.hdfc_bank(),
      AppConstants.ICICI_BANK: AppImages.icici_bank(),
      AppConstants.IDBI_BANK: AppImages.idbi_bank(),
      AppConstants.INDIAN_BANK: AppImages.indian_bank(),
      AppConstants.INDIAN_OVERSEAS_BANK: AppImages.indian_overseas(),
      AppConstants.INDUSIND_BANK: AppImages.indusind_bank(),
      AppConstants.SARASWAT_BANK: AppImages.saraswat_bank(),
      AppConstants.KARNATAKA_BANK: AppImages.karnataka_bank(),
      AppConstants.LVB_BANK: AppImages.lvb_bank(),
      AppConstants.KMB_BANK: AppImages.kmb_bank(),
      AppConstants.SBI_BANK: AppImages.sbi_bank(),
      AppConstants.KVB_BANK: AppImages.kvb_bank(),
      AppConstants.PUNJAB_SIND_BANK: AppImages.punjab_sind_bank(),
      AppConstants.DHANLAXMI_BANK: AppImages.dhanlaxmi_bank(),
      AppConstants.TMB_BANK: AppImages.tmb_bank(),
      AppConstants.IDFC_FIRST_BANK: AppImages.ifdc_first_bank(),
      AppConstants.FEDERAL_BANK: AppImages.federal_bank(),
      AppConstants.JK_BANK: AppImages.jk_bank(),
      AppConstants.YES_BANK: AppImages.yes_bank(),
      AppConstants.RBL_BANK: AppImages.rbl_bank(),
      AppConstants.UNION_BANK: AppImages.union_bank(),
      AppConstants.PNB_BANK: AppImages.pnb_bank(),
      AppConstants.PNB_BANK_CORPORATE: AppImages.pnb_bank(),
    };

    AssetImage logo = banklogomap[bankLogo] ?? AppImages.default_bank();

    return Padding(
      padding: EdgeInsets.only(right: AppWidgetSize.dimen_5),
      child: SizedBox(
        height: AppWidgetSize.dimen_40,
        width: AppWidgetSize.dimen_40,
        child: Image(image: logo),
      ),
    );
  }

  Future<List<dynamic>> getAlluserDetails() async {
    List<dynamic> users =
        await AppStorage().getData(lastThreeUserLoginDetailsKey) ?? [];

    return users
        .where((element) =>
            (element[accNameConstants] != null && element["uid"] != null) &&
                (element["isUserdisabled"] == "false") ||
            (element["isUserdisabled"] == null))
        .toList();
  }

  Widget ruppeText(String text, TextStyle textsyle, BuildContext context) {
    var stext = text.split("₹");

    return RichText(
      text: TextSpan(children: [
        for (int i = 0; i < stext.length; i++)
          TextSpan(children: [
            TextSpan(text: stext[i], style: textsyle),
            if (i != stext.length - 1)
              TextSpan(
                  text: "₹",
                  style: textsyle.copyWith(fontFamily: AppConstants.interFont)),
          ])
      ]),
      textAlign: TextAlign.justify,
    );
  }

  List<String> periodList(Symbols symbols) {
    String symbolType = AppUtils().getsymbolType(symbols, checkIndixes: false);
    bool isFnoCurrencyMcx = symbolType == AppConstants.fno ||
        symbolType == AppConstants.commodity ||
        symbolType == AppConstants.currency;
    return isFnoCurrencyMcx
        ? ["1D", "1W", "1M", "3M"]
        : ["1D", "1W", "1M", "1Y", "3Y", "5Y"];
  }

  Future<dynamic> getsmartDetails({String? userName, String? uid}) async {
    List<dynamic>? lastThreeUserLoginDetails =
        await AppStorage().getData(lastThreeUserLoginDetailsKey);
    var userDetails = await AppStorage().getData("userLoginDetailsKey");

    return userDetails = (lastThreeUserLoginDetails?.isEmpty ?? true)
        ? null
        : lastThreeUserLoginDetails!
                .where((e) => uid != null
                    ? e["uid"] == uid
                    : e["accName"] == (userName ?? userDetails?["accName"]))
                .toList()
                .isNotEmpty
            ? lastThreeUserLoginDetails
                .where((e) => uid != null
                    ? e["uid"] == uid
                    : e["accName"] == (userName ?? userDetails?["accName"]))
                .toList()
                .first
            : null;
  }

  Future<void> saveDataInAppStorage(String key, String value) async {
    final encrypt.Encrypter encrypter = encrypt.Encrypter(
      encrypt.AES(encrypt.Key.fromUtf8('acmlencryptk2021'),
          mode: encrypt.AESMode.cbc),
    );
    final encrypt.Encrypted encrypted = encrypter.encrypt(
      value,
      iv: encrypt.IV(Uint8List.fromList(utf8.encode('acmlencryptk2021'))),
    );
    AppStorage().setData(key, encrypted.base64);
  }

  Future<void> saveLastThreeUserData(
      {dynamic data,
      bool? biometric,
      String? token,
      String? uid,
      String? userName,
      String? key,
      String? value}) async {
    data ??= await AppStorage().getData("userLoginDetailsKey");
    if (Featureflag.isCheckSegmentsFromBo) {
      try {
        AppStore().setFnoAvailability(data?["exchArr"]?.contains("fno"));
        AppStore().setCurrencyAvailablity(
            data["exchArr"]?.contains(AppLocalizations().currency));
        AppStore().setCommodityAvailablity(
            data["exchArr"]?.contains(AppLocalizations().commodity));
      } catch (e) {
        AppStore().setCommodityAvailablity(false);

        AppStore().setFnoAvailability(false);
        AppStore().setCurrencyAvailablity(false);
      }
    }
    List<dynamic> lastThreeUserLoginDetails =
        await AppStorage().getData(lastThreeUserLoginDetailsKey) ?? [];
    bool isUserAvailable = lastThreeUserLoginDetails
        .where((element) => uid != null
            ? uid == element['uid']
            : element?[accNameConstants] == data?[accNameConstants])
        .toList()
        .isNotEmpty;

    if (isUserAvailable) {
      Map<String, dynamic> user = lastThreeUserLoginDetails
          .where((element) => uid != null
              ? uid == element['uid']
              : element[accNameConstants] == data[accNameConstants])
          .toList()
          .first;
      if (key != null) {
        user[key] = value;
      }
      user["biometric"] = biometric ?? user["biometric"];
      user['token'] = token ?? user["token"];
      user['lastLoginTime'] = data['lastLoginTime'];
      user['userSessionId'] = data['userSessionId'];

      if (key != 'isUserdisabled') {
        user['isUserdisabled'] = 'false';
      }
      int index = lastThreeUserLoginDetails.indexWhere(
          (element) => element[accNameConstants] == data[accNameConstants]);
      lastThreeUserLoginDetails.removeAt(index);
      lastThreeUserLoginDetails.insert(index, user);
      AppStore().setUid(user[uidConstants] ?? "");
    } else {
      if (data != null) {
        data['pin'] = true;
        data["userName"] = AppStore().getuserName();
        data["biometric"] = biometric ?? false;
        data['token'] = token ?? "";
        if (key != 'isUserdisabled') {
          data['isUserdisabled'] = 'false';
        }

        if (lastThreeUserLoginDetails.length == 5) {
          lastThreeUserLoginDetails.removeAt(0);
        }
        lastThreeUserLoginDetails.add(data);
        AppStore().setUid(data?[uidConstants] ?? "");
      }
    }

    AppStorage()
        .setData(lastThreeUserLoginDetailsKey, lastThreeUserLoginDetails);
  }

  Future<void> removeCurrentUser({String? uid, bool removeData = true}) async {
    var userDetails = await AppStorage().getData("userLoginDetailsKey");
    List<dynamic>? lastThreeUserLoginDetails =
        await AppStorage().getData(lastThreeUserLoginDetailsKey);
    if (uid != null) {
      if (removeData) {
        lastThreeUserLoginDetails?.removeWhere((e) => e["uid"] == uid);
      } else {
        saveLastThreeUserData(uid: uid, key: "isUserdisabled", value: "true");
      }
    } else if (userDetails != null) {
      if (removeData) {
        lastThreeUserLoginDetails
            ?.removeWhere((e) => e["accName"] == userDetails["accName"]);
      } else {
        saveLastThreeUserData(
            data: userDetails, key: "isUserdisabled", value: "true");
      }
    }
    await AppStorage()
        .setData(lastThreeUserLoginDetailsKey, lastThreeUserLoginDetails);
    await AppStorage().setData("userLoginDetailsKey", null);
  }

  String getDisplayNameForItem(String baseSym, String exchange) {
    List<NSE>? symbolListNSE = [];
    List<BSE>? symbolListBSE = [];
    if (exchange == AppConstants.nse) {
      symbolListNSE = AppConfig.indices?.nSE
          ?.where((element) => element.baseSym == baseSym)
          .toList();
      return symbolListNSE!.first.dispSym!;
    } else if (exchange == AppConstants.bse) {
      symbolListBSE = AppConfig.indices?.bSE
          ?.where((element) => element.baseSym == baseSym)
          .toList();
      return symbolListBSE!.first.dispSym!;
    }

    return "";
  }

  String getsymbolType(Symbols symbols, {bool checkIndixes = true}) {
    return symbols.sym?.instrument == AppConstants.idx && checkIndixes
        ? AppConstants.indices.toLowerCase()
        : (symbols.sym?.exc == AppConstants.nse ||
                symbols.sym?.exc == AppConstants.bse)
            ? AppConstants.equity.toLowerCase()
            : (symbols.sym?.exc == AppConstants.nfo ||
                    symbols.sym?.exc == AppConstants.bfo)
                ? AppConstants.fno.toLowerCase()
                : (symbols.sym?.exc == AppConstants.cds)
                    ? AppConstants.currency.toLowerCase()
                    : AppConstants.commodity.toLowerCase();
  }

  String getsymbolTypeFromSym(Sym? sym, {bool checkIndixes = true}) {
    String symbolType = sym?.instrument == AppConstants.idx && checkIndixes
        ? AppConstants.indices
        : (sym?.exc == AppConstants.nse || sym?.exc == AppConstants.bse)
            ? AppConstants.equity
            : (sym?.exc == AppConstants.nfo || sym?.exc == AppConstants.bfo)
                ? AppConstants.fno
                : (sym?.exc == AppConstants.cds)
                    ? AppConstants.currency
                    : AppConstants.commodity;
    return symbolType;
  }

  Symbols getSymbolsItemWithDispSym(String dispSym, List<Symbols> symbolsList) {
    return symbolsList.firstWhere((element) => element.dispSym == dispSym);
  }

  String getDateFormat(String date) {
    return date.split('/').join('');
  }

  bool isLightTheme() {
    return AppStore().getThemeData() == AppConstants.lightMode;
  }

  dynamic dataNullCheck(dynamic data) {
    return data ?? '';
  }

  dynamic dataNullCheckNumeric(dynamic data) {
    return data ?? '0.00';
  }

  dynamic dataNullCheckDashDash(dynamic data) {
    return data ?? '--';
  }

  double isValueNAN(dynamic data) {
    double value = data;
    if (value.isNaN ||
        value == double.infinity ||
        value == double.negativeInfinity) {
      value = 0.0;
    }
    return value;
  }

  int isValueNANInt(dynamic data) {
    int value = data;
    if (value.isNaN ||
        value == double.infinity ||
        value == double.negativeInfinity) {
      value = 0;
    }
    return value;
  }

  Color profitLostColor(String? value) {
    return AppUtils().doubleValue(value) != 0
        ? AppUtils().doubleValue(value).isNegative
            ? AppColors.negativeColor
            : AppUtils().isLightTheme()
                ? AppColors.primaryColor
                : AppColors().positiveColor
        : AppColors.labelColor;
  }

  void logSuccess(String logName, dynamic msg) {
    developer.log('\x1B[32m$logName $msg\x1B[0m');
  }

  bool checkTickSize(
    String getPrice, {
    String tickSize = '0.05',
    int decimalPoint = 2,
  }) {
    final num findTSize = pow(10, decimalPoint);

    final double price =
        decimalDoubleValue(getPrice, decimalPoint: decimalPoint);

    final double tick =
        decimalDoubleValue(tickSize, decimalPoint: decimalPoint);

    final int newPrice = (price * findTSize).round();

    final int newTick = (tick * findTSize).round();

    final double result = (newPrice % newTick).round() / findTSize;
    return result == 0.0;
  }

  double decimalDoubleValue(dynamic data, {int decimalPoint = 2}) {
    return double.parse(decimalValue(data, decimalPoint: decimalPoint));
  }

  double doubleValue(dynamic data) {
    final String value = (dataNullCheck(data).toString()).replaceAll(',', '');
    final double doubleValue = double.tryParse(value != '' ? value : '0') ?? 0;
    return doubleValue;
  }

  num doubleZeroValue(dynamic data) {
    final String value = (dataNullCheck(data).toString()).replaceAll(',', '');
    final num doubleValue = num.tryParse(value != '' ? value : '0') ?? 0;
    return doubleValue;
  }

  int intValue(dynamic data) {
    final String value = (dataNullCheck(data).toString()).replaceAll(',', '');
    final int intValue =
        isValueNAN(double.parse(value != '' ? value : '0')).toInt();
    return intValue;
  }

  String decimalValue(dynamic data, {int decimalPoint = 2}) {
    final String value = (dataNullCheck(data).toString()).replaceAll(',', '');
    final double doubleValue = double.parse(value != '' ? value : '0');
    return doubleValue.toStringAsFixed(decimalPoint);
  }

  dynamic colorIndicator(Symbols symbols) {
    return setcolorForChange(symbols.chng!);
  }

  dynamic setcolorForChange(String changeval) {
    final String data = changesIndicatorString(changeval);
    return data == AppConstants.positive
        ? AppUtils().isLightTheme()
            ? AppColors.primaryColor
            : AppColors().positiveColor
        : data == AppConstants.negative
            ? AppColors.negativeColor
            : AppUtils().isLightTheme()
                ? AppColors.labelColor //change color
                : Colors.white;
  }

  String changesIndicatorString(String changeValue) {
    final double changePrice = dataNullCheck(changeValue) != ''
        ? double.tryParse(dataNullCheck(changeValue.replaceAll(',', ''))) ?? 0
        : 0;
    return changePrice > 0
        ? AppConstants.positive
        : changePrice < 0
            ? AppConstants.negative
            : AppConstants.noChange;
  }

  String getPercentage(String data) {
    return dataNullCheck(data) != '' ? "( $data%)" : ' (0.00 %)';
  }

  String getChangePercentage(Symbols symbolItem) {
    return dataNullCheck(symbolItem.chng) != ''
        ? (dataNullCheck(AppUtils().doubleValue(symbolItem.chng).isNegative
                ? symbolItem.chng
                : '+${symbolItem.chng}') +
            ' (' +
            dataNullCheck(AppUtils().doubleValue(symbolItem.chngPer).isNegative
                ? symbolItem.chngPer
                : '+${symbolItem.chngPer}') +
            '%)')
        : '';
  }

  launchBrowser(String? url) async {
    if (url != null) {
      try {
        await ChromeSafariBrowser().open(
            url: Uri.parse(url),
            options: ChromeSafariBrowserClassOptions(
                android: AndroidChromeCustomTabsOptions(
                  noHistory: true,
                  enableUrlBarHiding: true,
                  instantAppsEnabled: true,
                  isSingleInstance: true,
                  toolbarBackgroundColor: Theme.of(navigatorKey.currentContext!)
                      .snackBarTheme
                      .backgroundColor,
                ),
                ios: IOSSafariOptions(
                    preferredControlTintColor:
                        Theme.of(navigatorKey.currentContext!).primaryColor,
                    barCollapsingEnabled: true,
                    preferredBarTintColor:
                        Theme.of(navigatorKey.currentContext!)
                            .snackBarTheme
                            .backgroundColor)));
      } catch (e) {
        await InAppBrowser.openWithSystemBrowser(
          url: Uri.parse(url),
        );
      }
    }
  }

  dynamic setColorForText(String value) {
    final double datavalue =
        dataNullCheck(value) != '' && dataNullCheck(value) != '--'
            ? double.parse(dataNullCheck(value.replaceAll(',', '')))
            : 0;
    return (datavalue > 0)
        ? AppColors().positiveColor
        : (datavalue == 0)
            ? AppUtils().isLightTheme()
                ? AppColors.labelColor
                : Colors.white
            : AppColors.negativeColor;
  }

  dynamic setColorForTextCompared(String? value1, String? value2) {
    value1 = value1 ?? "0";
    value2 = value2 ?? "0";
    final double datavalue1 =
        dataNullCheck(value1) != '' && dataNullCheck(value1) != '--'
            ? double.parse(dataNullCheck(value1.replaceAll(',', '')))
            : 0;
    final double datavalue2 =
        dataNullCheck(value2) != '' && dataNullCheck(value2) != '--'
            ? double.parse(dataNullCheck(value2.replaceAll(',', '')))
            : 0;

    return (datavalue1 > datavalue2)
        ? AppColors().positiveColor
        : (datavalue1 == datavalue2)
            ? (AppUtils().isLightTheme() ? AppColors.labelColor : Colors.white)
            : AppColors.negativeColor;
  }

  Widget getNoDateImageErrorWidget(BuildContext context) {
    return AppImages.noDataAction(context,
        isColor: false,
        width: AppWidgetSize.fullWidth(context) - AppWidgetSize.dimen_100,
        height: AppWidgetSize.dimen_150);
  }

  String commaFmt(String value, {int decimalPoint = 2}) {
    double v = double.tryParse(value) ?? 0.00;

    String data = intl.NumberFormat.currency(
            locale: 'hi', name: '', decimalDigits: decimalPoint)
        .format(v)
        .toString();
    return data;
  }

  String removeCommaFmt(dynamic value) {
    return value.split(',').join('');
  }

  int getDecimalpoint(String? exchange) {
    return exchange == null ? 2 : AppStore().getPrecision()[exchange] ?? 2;
  }

  String getTimeDifferenceFromNow(String time) {
    DateTime newDate1 = DateTime.parse(time);

    Duration diff = DateTime.now().difference(newDate1);
    if (diff.inDays > 365) {
      return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "year" : "years"} ago";
    }
    if (diff.inDays > 30) {
      return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "month" : "months"} ago";
    }
    if (diff.inDays > 7) {
      return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "week" : "weeks"} ago";
    }
    if (diff.inDays > 0) {
      return "${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago";
    }
    if (diff.inHours > 0) {
      return "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago";
    }
    if (diff.inMinutes > 0) {
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
    }
    return "just now";
  }

  String getDateStringInDateFormat(
    String date,
    String currentDateFormat,
    String dateFormatToConvert,
  ) {
    DateTime fomattedDate = intl.DateFormat(currentDateFormat).parse(date);

    return intl.DateFormat(dateFormatToConvert).format(fomattedDate);
  }

  DateTime getDateTime(
    String date,
    String currentDateFormat,
  ) {
    DateTime fomattedDate = intl.DateFormat(currentDateFormat).parse(date);

    return fomattedDate;
  }

  List<AlertType> alertTypeList() {
    return [
      AlertType(AppLocalizations().targetPrice, AppConstants.priceMoveAboveKey,
          AppConstants.priceAlerts),
      AlertType(AppLocalizations().priceMovesabove,
          AppConstants.priceMoveAboveKey, AppConstants.priceAlerts),
      AlertType(AppLocalizations().priceMovesupByPer,
          AppConstants.priceMoveUpByPerKey, AppConstants.priceAlerts),
      AlertType(AppLocalizations().priceMovesbelow,
          AppConstants.priceMoveBelowKey, AppConstants.priceAlerts),
      AlertType(AppLocalizations().priceMovesdownByPer,
          AppConstants.priceMoveBelowPerKey, AppConstants.priceAlerts),
      AlertType(AppLocalizations().volumeMovesabove,
          AppConstants.volumeMovesaboveKey, AppConstants.volumeAlerts),
      AlertType(AppLocalizations().volumeMovesbelow,
          AppConstants.volumeMovesBelowKey, AppConstants.volumeAlerts),
      AlertType(AppLocalizations().priceHits52WH,
          AppConstants.priceMoveAboveKey, AppConstants.priceAlerts),
      AlertType(AppLocalizations().priceHits52WL,
          AppConstants.priceMoveBelowKey, AppConstants.priceAlerts),
    ];
  }

  List<List<AlertType>> convertToListOfAlerts() {
    var groupedAlerts =
        groupBy(alertTypeList(), (AlertType alert) => alert.alertType);
    return groupedAlerts.values.toList();
  }

  List<Widget> getWatchlistIcons(
    BuildContext context,
    int watchlistGroupLenth,
  ) {
    List<Widget> iconsList = [
      AppImages.globeIcon(context, height: 26.w),
      AppImages.bellIcon(context, height: 26.w),
      AppImages.bicycleIcon(context, height: 26.w),
      AppImages.crystalballIcon(context, height: 26.w),
      AppImages.fireIcon(context, height: 26.w),
      AppImages.gemstoneIcon(context, height: 26.w),
      AppImages.highvoltageIcon(context, height: 26.w),
    ];

    List<Widget> watchlistIcons = [];
    for (int i = 0, j = 0; i <= watchlistGroupLenth; i++, j++) {
      if (j < iconsList.length) {
        watchlistIcons.add(iconsList[j]);
      } else {
        j = 1;
        watchlistIcons.add(iconsList[j]);
      }
    }
    return watchlistIcons;
  }

  bool isExcCdsOrMcx(String exc) {
    return exc == AppConstants.cds || exc == AppConstants.mcx;
  }

  bool isExcMcx(String exc) {
    return exc == AppConstants.mcx;
  }

  bool isExcCDS(String exc) {
    return exc == AppConstants.cds;
  }

  Future<int> isAlertAvailableFortheSymbol(Symbols symbol) async {
    final AlertModel? alerts =
        await CacheRepository.alerts.get('fetchPendingAlerts');

    if (alerts != null) {
      if (AppUtils().getsymbolType(symbol) == AppConstants.equity) {
        return alerts.alertList
            .where((element) => element.symbol.dispSym == symbol.dispSym)
            .toList()
            .length;
      }
    }
    return 0;
  }

  Future<bool> isSymAvailableInCorpSymList(Symbols symbol) async {
    final corpSymListCache =
        await CacheRepository.corpSymListCache.get('corpSymList');

    if (corpSymListCache != null) {
      CorpSymList corpSymList = corpSymListCache;
      if (AppUtils().getsymbolType(symbol) == AppConstants.equity) {
        return corpSymList.corpSymList!.contains(symbol.baseSym);
      }
    }
    return false;
  }

  String camelCase(String s) => s[0].toUpperCase() + s.substring(1);
}

extension StringExtension on String {
  double textHeight(TextStyle style, double textWidth) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: this, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(minWidth: 10, maxWidth: double.infinity);

    final int countLines = (textPainter.size.width / textWidth).ceil();
    final double height = countLines * textPainter.size.height;
    return height;
  }

  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  double textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size.width;
  }

  String get capitalizeFirstofEach => split(" ")
      .map((str) =>
          AppUtils().dataNullCheck(base_utils.StringUtils.capitalize(str)))
      .join(" ");
}

extension DateTimeExtension on DateTime? {
  bool? isAfterTo(DateTime dateTime) {
    final date = this;
    if (date != null) {
      return date.isAfter(dateTime);
    }
    return null;
  }

  bool? isBeforeTo(DateTime dateTime) {
    final date = this;
    if (date != null) {
      return date.isBefore(dateTime);
    }
    return null;
  }

  bool? isBetween(
    DateTime fromDateTime,
    DateTime toDateTime,
  ) {
    final date = this;
    if (date != null) {
      final isAfter = date.isAfterTo(fromDateTime) ?? false;
      final isBefore = date.isBeforeTo(toDateTime) ?? false;
      return isAfter && isBefore;
    }
    return null;
  }
}

extension NumberParsing on String? {
  num exdouble() {
    return AppUtils().doubleValue(this);
  }

  num exdoubleTrialZero() {
    return AppUtils().doubleZeroValue(this);
  }

  int exInt() {
    return AppUtils().intValue(this);
  }

  String commaFmt({int decimalPoint = 2}) {
    double v = double.tryParse(this ?? "") ?? 0.00;

    String data = intl.NumberFormat.currency(
            locale: 'hi', name: '', decimalDigits: decimalPoint)
        .format(v)
        .toString();
    return data;
  }
  // ···
}

extension StringParsing on String? {
  String dataNullCheck() {
    return AppUtils().dataNullCheck(this);
  }

  String removeMultipliertrade(Sym? sym, {bool floor = true}) {
    num withMult = AppUtils().isExcCdsOrMcx(sym!.exc!)
        ? (AppUtils().doubleValue(this) /
            ((AppUtils().doubleValue(sym.lotSize) *
                (multipliervalidate(sym)
                    ? AppUtils().doubleValue(sym.multiplier)
                    : 1))))
        : (AppUtils().doubleValue(this));

    return floor ? withMult.floor().toString() : withMult.toString();
  }

  String removeMultiplierOrderPad(Sym? sym, {bool forall = false}) {
    return (AppUtils().isExcCDS(sym!.exc!)) || forall
        ? (AppUtils().doubleValue(this) /
                ((AppUtils().doubleValue(sym.lotSize) *
                    (multipliervalidate(sym)
                        ? AppUtils().doubleValue(sym.multiplier)
                        : 1))))
            .floor()
            .toString()
        : (AppUtils().doubleValue(this)).floor().toString();
  }

  String removeMultiplierPositionModify(Sym? sym, {bool forall = false}) {
    return (AppUtils().isExcMcx(sym!.exc!))
        ? (AppUtils().doubleValue(this) /
                ((AppUtils().doubleValue(sym.lotSize))))
            .floor()
            .toString()
        : (AppUtils().doubleValue(this)).floor().toString();
  }

  String removeMultiplierTrade2(Sym? sym, {bool forall = false}) {
    return (!AppUtils().isExcMcx(sym!.exc!)) || forall
        ? (AppUtils().doubleValue(this) /
                ((AppUtils().doubleValue(sym.lotSize))))
            .floor()
            .toString()
        : (AppUtils().doubleValue(this)).floor().toString();
  }

  String withMultiplierOrderPad(Sym? sym, {bool forall = false}) {
    return AppUtils().isExcMcx(sym!.exc!) && !forall
        ? toString()
        : AppUtils().isExcCdsOrMcx(sym.exc!)
            ? (AppUtils().doubleValue(this) *
                    AppUtils().doubleValue(sym.lotSize) *
                    (multipliervalidate(sym)
                        ? AppUtils().doubleValue(sym.multiplier)
                        : 1))
                .floor()
                .toString()
            : (AppUtils().doubleValue(this) *
                    AppUtils().doubleValue(sym.lotSize))
                .abs()
                .floor()
                .toString();
  }

  String withMultiplierTrade2(Sym? sym, {bool forall = false}) {
    return AppUtils().isExcCdsOrMcx(sym!.exc!)
        ? (AppUtils().doubleValue(this) *
                AppUtils().doubleValue(sym.lotSize) *
                (multipliervalidate(sym)
                    ? AppUtils().doubleValue(sym.multiplier)
                    : 1))
            .floor()
            .toString()
        : (AppUtils().doubleValue(this) * AppUtils().doubleValue(sym.lotSize))
            .abs()
            .floor()
            .toString();
  }

  String withMultiplierOrderV2(Sym? sym, {floor = true}) {
    num withMult = (AppUtils().isExcCDS(sym!.exc!)
        ? (AppUtils().doubleValue(this) *
            AppUtils().doubleValue(sym.lotSize) *
            (multipliervalidate(sym)
                ? AppUtils().doubleValue(sym.multiplier)
                : 1))
        : (AppUtils().doubleValue(this)));
    return floor ? withMult.floor().toString() : withMult.toString();
  }

  String withMultiplierTrade(Sym? sym, {floor = true}) {
    num withMult = (AppUtils().isExcCdsOrMcx(sym!.exc!)
        ? (AppUtils().doubleValue(this) *
            AppUtils().doubleValue(sym.lotSize) *
            (multipliervalidate(sym)
                ? AppUtils().doubleValue(sym.multiplier)
                : 1))
        : (AppUtils().doubleValue(this)));
    return floor ? withMult.floor().toString() : withMult.toString();
  }
}

bool multipliervalidate(Sym sym) {
  return (Featureflag.isMultiplierCds &&
          sym.exc?.toLowerCase() == AppConstants.cds.toLowerCase()) ||
      (Featureflag.isMultiplierMcx &&
          sym.exc?.toLowerCase() == AppConstants.mcx.toLowerCase());
}

class AlertType {
  final String alertName;
  final String alertValue;
  final String alertType;
  AlertType(this.alertName, this.alertValue, this.alertType);
}
