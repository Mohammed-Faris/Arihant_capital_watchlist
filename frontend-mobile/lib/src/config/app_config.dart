import 'package:acml/src/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:msil_library/streamer/models/quote2_stream_response_model.dart';

import '../models/config/config_model.dart';
import '../models/config/suggested_stocks_model.dart';

class AppConfig {
  static bool materialbannerisopen = false;

  static String baseURL = "";
  static String baseUrl = '$baseURL/init-config';
  static String baseURLMarketData = '$baseURL/market-data';
  static String baseURLOmnesysWar = '$baseURL/trade';
  static String baseURLOrdersocket = baseURL;

  static String baseURLCmots = '$baseURL/cmots';
  static String baseUrlbackOffice = '$baseURL/backoffice';
  static String baseURLPayment = '$baseURL/payment-service';
  static String baseURLEdis = '$baseURL/edis';
  static String baseURLShield = '$baseURL/shield-services';
  static String otpTimerSec = "";
  static String poaLink = "";
  static String marginCalculatorUrl = "";
  static String lineChartUrl = "";
  static String callFortrade = "07314217186";
  static String referUrl = "";
  static int refreshTime = 0;
  static List? boUrls = [];
  static List holidays = [];
  static Map<String, dynamic>? chartTiming;
  static String contactMobile = "07314217003";

  static String contactSecMobile = "0731-2581003";
  static String contactEmail = "customersupport@arihantcapital.com";
  static Orientation orientation = Orientation.portrait;
  static bool isLandScape = AppConfig.orientation == Orientation.landscape;

  static ChartTimings? chartTimingv2;

  static late String appStorageKey;
  static String flavor = "";
  static bool twoFA = true;

  static late String appVersion;
  static late String displayVersion;
  static late String androidChannelName;
  static late String iOSChannelName;
  static int watchlistSymbolLimit = 0;

  static late String needHelpUrl;
  static late String signUpUrl;
  static late String watchlistGroupLimit;
  static late Map<String, dynamic> quoteTabs;
  static late Map<String, dynamic> overviewTab;
  static late Map<String, dynamic>? maintenance;

  static ArhtBnkDtls? arhtBnkDtls;

  static late String chartUrl;

  static late List<SuggestedStocks> suggestedStocks;

  static late List<PredefinedWatch> predefinedWatch;

  static late List<AmoMktTimings> amoMktTimings;

  static String? gtdTiming;
  static late Indices? indices;

  Quote2Data marketDepthData = Quote2Data.fromJson({
    'ask': [
      {'no': '--', 'price': '--', 'qty': '--'},
      {'no': '-', 'price': '--', 'qty': '--'},
      {'no': '--', 'price': '--', 'qty': '--'},
      {'no': '--', 'price': '--', 'qty': '--'},
      {'no': '--', 'price': '--', 'qty': '--'}
    ],
    'bid': [
      {'no': '--', 'price': '--', 'qty': '--'},
      {'no': '--', 'price': '--', 'qty': '--'},
      {'no': '--', 'price': '--', 'qty': '--'},
      {'no': '--', 'price': '--', 'qty': '--'},
      {'no': '--', 'price': '--', 'qty': '--'}
    ],
    'symbol': '--',
    'totBuyQty': '--',
    'totSellQty': '--'
  });
  List<String> totalBuyAskQty = ['0.0', '0.0', '0.0', '0.0', '0.0'];
}

class Featureflag {
  static int setOtpExpiry = 0;
  static bool showOverallPnl = true;
  static bool csToggle = false;
  static bool gTD = false;
  static bool coverOder = false;
  static bool bracketOder = false;
  static bool nomineeCampaign = false;
  static String campaignEndDate = "";
  static bool mcxBo = false;
    static bool cdsBo = false;
    static bool cdsCo = false;

  static bool mcxGtd = false;
  static bool isMultiplierCds = false;
  static bool isMultiplierMcx = false;
  static bool isCheckSegmentsFromBo = false;
  static bool alerts = true;
  static bool basketOrder = true;

  static bool fetchOrderfromSocket = false;
  static DateTime? lastUpdatedTime;

  static bool showCharges = true;
  static String? boSecondLegType = AppConstants.limit;
  static bool sessionValidation = false;

  static bool isFnoSymbolsKeyCheck = false;
  static bool isGtdNavValidation = true;

  static bool isActualCFPrice = false;
}
