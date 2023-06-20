// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

class AppConstants {
  static const String darkMode = 'Dark Mode';
  static const String lightMode = 'Light Mode';
  static bool loadHoldingsFromQuote = false;
  static bool connectedSocket = false;

  static const String showHoldingsNote = "showHoldingsNote";
  static const String lastLoggedInWithOTP = 'lastLoggedInwithOTP';
  static const String activateAccountCode = 'ACTIVATE_ACCOUNT';
  static const String showSwitchAccNote = "showSwitchAccNote";
  static ValueNotifier<bool> materialbannerisopen = ValueNotifier<bool>(false);
  static final ValueNotifier<bool> animateBanner = ValueNotifier<bool>(false);

  //Info codes
  static const String noNetworkExceptionErrorCode = 'S01';
  static const String invalidAppInDErrorCode = 'EGN005';
  static const String noDataAvailableErrorCode = 'EGN007';
  static const String invalidSessionErrorCode = 'EGN006';
  static const String accountBlockedErrorCode = 'EGN018';
  static const String changePasswordErrorCode = 'EGN019';
  static const String reregisterMpinErrorCode = 'EGN0025';
  static const String passwordChangedErrorCode = 'EGN0028';
  static const String passwordChangedErrorCode2 = 'EGN0015';
  static const String close = 'close';
  static const String activated = 'Activated';

  static const String primary = 'Primary';
  static const String active = 'Active';
  static const String activate = 'Activate';
  static const String inactive = 'Inactive';
  static const String inactivate = 'InActivate';
  static const String pinBlockedErrorMessage =
      'Pin Blocked kindly unblock to continue.';
  static const int snackBarDuration = 1500;
  static const String portrait = 'portrait';
  static const String landscape = 'landscape';
  static const String portraitExpand = 'portrait expand';

  static const String icon = 'icon';
  static const String activeIcon = 'activeIcon';
  static const String title = 'title';

  static const String submitConstant = 'submitConstant';
  static const String dateFormatConstantDDMMYYYY = 'dd/MM/yyyy';
  static const String dateFormatWithDash = 'dd-MM-yyyy';

  static const String all = 'All';
  static const String stocks = 'Stocks';
  static const String etfs = 'ETFs';
  static const String none = 'NONE';

  static const String nifty = 'NIFTY 50';
  static const String bankNifty = 'BANK NIFTY';
  static const String topGainers = 'TOP GAINERS';
  static const String topLosers = 'TOP LOSERS';
  static const String whNifty = '52-WH NIFTY';
  static const String wlNifty = '52-WL NIFTY';
  static const String futureGainers = 'FUTURE GAINERS';
  static const String futureLosers = 'FUTURE LOSERS';
  static const String optionGainers = 'OPTION GAINERS';
  static const String optionLosers = 'OPTION LOSERS';

  static const String indexNifty = "NIFTY";
  static const String indexBankNifty = "BANKNIFTY";

  static const String streamingLtp = 'ltp';
  static const String streamingChng = 'chng';
  static const String streamingChgnPer = 'chngPer';
  static const String streamingHigh = 'yHigh';
  static const String streamingLow = 'yLow';
  static const String low = 'low';
  static const String high = 'high';

  static const String streamingLtt = 'ltt';
  static const String streamingVol = 'vol';
  static const String streamingBid = 'bid';
  static const String streamingAsk = 'ask';
  static const String streamingAtp = 'atp';
  static const String streamingOpen = 'open';
  static const String streamingClose = 'close';
  static const String streamingUpperCircuit = 'ucl';
  static const String streamingLowerCircuit = 'lcl';
  static const String streamingOi = 'oi';
  static const String streamingOiChngPer = 'OIChngPer';

  static const String tab1 = 'tab1';
  static const String tab2 = 'tab2';

  static const String positive = 'positive';
  static const String negative = 'negative';
  static const String noChange = '';
//watchlist sort
  static const String alphabeticalAtoZ = 'A -> Z';
  static const String alphabeticalZtoA = 'Z -> A';
  static const String priceLowToHigh = 'Price: Low -> High';
  static const String priceHighToLow = 'Price: High -> Low';
  static const String chngPerctLowToHigh = '% Change: Low -> High';
  static const String chngPerctHighToLow = '% Change: High -> Low';
  static const String price = 'Price';
  static const String chngPercent = '% Change';
  static const String tradePercent = '% Traded';

//watchlist filter
  static const String nse = 'NSE';
  static const String bse = 'BSE';
  static const String future = 'Future';
  static const String options = 'Options';
  static const String myHoldings = 'My Holdings';

  static const String stk = 'stk';
  static const String etf = 'ETF';
  static const String fut = 'FUT';
  static const String opt = 'OPT';

  static const String sortby = 'Sort by';
  static const String filter = 'Filter';
  static const String serverDown = 'S03';

  static const String fiftyTwoWL = '52W L';
  static const String fiftyTwoWH = '52W H';

  static const String trueConstant = 'true';
  static const String falseConstant = 'false';

  //ProductType
  static const String delivery = 'Delivery';
  static const String intraday = 'Intraday';
  static const String carryForwardValue = 'Carryforward';

  static const String carryForward = 'CarryForward';
  static const String normal = 'Normal';
  static const String coverOrder = 'CO';
  static const String bracketOrder = 'BO';

  //Profit Loss
  static const String profit = 'profit';
  static const String loss = 'loss';

  //OrderType
  static const String market = 'Market';
  static const String limit = 'Limit';
  static const String sl = 'SL';
  static const String slM = 'SL-M';
  static const String mkt = 'MKT';

  //Instrument
  static const String futureStock = 'Future Stock';
  static const String optionsStock = 'Options Stock';
  static const String futureIndex = 'Future Index';
  static const String optionsIndex = 'Options Index';
  static const String futureCurrency = 'Future Currency';
  static const String optionsCurrency = 'Option Currency';
  static const String cash = 'Cash';
  static const String ipo = 'IPO';

  //Instrument Keys
  static const String futureStockKey = 'futstk';
  static const String optionsStockKey = 'optstk';
  static const String futureIndexKey = 'futidx';
  static const String optionsIndexKey = 'optidx';
  static const String futureCurrencyKey = 'futcur';
  static const String optionsCurrencyKey = 'optcur';

  //Segment
  static const String mcx = 'MCX';
  static const String ncdex = 'NCDEX';
  static const String cds = 'CDS';
  static const String nfo = 'NFO';
  static const String bfo = 'BFO';
  static const String fo = 'F&O';
  static const String idx = 'IDX';

  static const String indices = 'indices';
  static const String equity = 'equity';
  static const String fno = 'fno';
  static const String currency = 'Currency';
  static const String commodity = 'Commodity';

  //Order Status
  static const String executed = 'Executed';
  static const String rejected = 'Rejected';
  static const String cancelled = 'Cancelled';
  static const String pending = 'Pending';
  static const String triggeredPending = 'Trigger Pending';
  static const String tradeConfirmed = 'Trade Confirmed';

  static const String trade_user = 'trade';

  //orderbook navigation
  static const String orderbookSelectedOrder = 'orderbookSelectedOrder';
  static const String orderbookModifyOrder = 'Modify';
  static const String orderbookCancelOrder = 'Cancel';
  static const String orderbookExitOrder = 'Exit';
  static const String orderbookRepeatOrder = 'Repeat';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String ok = 'Ok';
  static const String buttonAction = 'buttonAction';

  //Positions navigation
  static const String positionExitOrAdd = 'positionExitOrAdd';
  static const String positionsPrdType = 'positionsPrdType';
  static const String isOpenPosition = 'isOpenPosition';
  static const String positionButtonHeader = 'positionButtonHeader';

  //Holdings navigation
  static const String holdingsNavigation = 'holdingsNavigation';

  //Validity
  static const String day = 'DAY';
  static const String ioc = 'IOC';
  static const String gtd = 'GTD';

  //Action
  static const String buy = 'Buy';
  static const String sell = 'Sell';

  //corporate action filter
  static const String bonus = 'Bonus';
  static const String rights = 'Rights';
  static const String splits = 'Splits';
  static const String dividend = 'Dividend';

  //option filter option
  static const String oi = 'OI';
  static const String oiChng = 'OI Change';
  static const String volume = 'Volume';

  // Filter Type
  static const String prdType = 'prdType';
  static const String ordType = 'ordType';
  static const String instrument = 'instrument';
  static const String actualExc = 'actualExc';
  static const String holdingsPftOrLoss = 'holdingsPftOrLoss';
  static const String profitOrLoss = 'profitOrLoss';
  static const String tab = 'tab';
  static const String isAmo = 'isAmo';
  static const String ordAction = 'ordAction';

  static const String rupeeSymbol = '\u20B9';

  static const String action = 'Actions';
  static const String segment = 'Segment';
  static const String productType = 'Product Type';
  static const String orderStatus = 'Order Status';
  static const String instrumentSegment = 'Instrument';
  static const String moreFilters = 'More Filters';
  static const String amo = 'AMO';
  static const String mtf = 'MTF';
  static const String profitPositions = 'Profit Positions';
  static const String lossPositions = 'Loss Positions';

  // Sort Type
  static const String alphabetically = 'Alphabetically';
  static const String az = 'A-Z';
  static const String za = 'Z-A';
  static const String orderValue = 'Order Value';
  static const String hl = 'H-L';
  static const String lh = 'L-H';
  static const String quantity = 'Quantity';
  static const String time = 'Time';
  static const String latest = 'Latest';
  static const String earliest = 'Earliest';
  //Orderpad status
  static const String orderCancelled = 'Order Cancelled';
  static const String orderRejected = 'Order Rejected';
  static const String orderFreeze = 'Order Freeze';
  //sort and filter
  static const String hToL = 'H -> L';
  static const String lToH = 'L -> H';
  static const String filterOptions = 'filterOptions';
  static const String filterKeys = 'filterKeys';
  static const String oneDayReturn = '1D Return';
  static const String oneDayReturnPercent = '1D Return (%)';
  static const String overallReturn = 'Overall Return';
  static const String overallReturnPercent = 'Overall Return (%)';
  static const String currentValue = 'Current Value';
  static const String profitHoldings = 'Profit Holdings';
  static const String lossHoldings = 'Loss Holdings';
  static const String returns = 'Returns %';
  static const String absoluteChange = 'Absolute Change';
  static const String asc = 'ASC';
  static const String des = 'DES';
  static const String AU_SMALL_BANK = 'au_small';
  static const String AXIS_BANK = 'axis_bank';
  static const String BOB_BANK = 'bob_bank';
  static const String BOB_BANK_CORPORATE = 'bob_corporate_bank';
  static const String BOI_BANK = 'boi_bank';
  static const String BOM_BANK = 'bom_bank';
  static const String CANARA_BANK = 'canara_bank';
  static const String CSB_BANK = 'csb_bank';
  static const String CITI_BANK = 'citi_bank';
  static const String CUB_BANK = 'cub_bank';
  static const String DCB_BANK = 'dcb_bank';
  static const String DEFAULT_BANK = 'default_bank';
  static const String DEUTSCHE_BANK = 'deutsche_bank';
  static const String DHANLAXMI_BANK = 'dhanlaxmi_bank';
  static const String FEDERAL_BANK = 'federal_bank';
  static const String HDFC_BANK = 'hdfc_bank';
  static const String ICICI_BANK = 'icici_bank';
  static const String IDBI_BANK = 'idbi_bank';
  static const String IDFC_BANK = 'idfc_bank';
  static const String IDFC_FIRST_BANK = 'idfc_first_bank';
  static const String INDIAN_BANK = 'indian_bank';
  static const String INDIAN_OVERSEAS_BANK = 'indian_overseas_bank';
  static const String INDUSIND_BANK = 'indusind_bank';
  static const String JANATA_SAHAKARI_BANK = 'janata_sahakari_bank';
  static const String JK_BANK = 'jk_bank';
  static const String KARNATAKA_BANK = 'karnataka_bank';
  static const String KMB_BANK = 'kmb_bank';
  static const String KVB_BANK = 'kvb_bank';
  static const String LVB_BANK = 'lvb_bank';
  static const String PNB_BANK = 'pnb_bank';
  static const String PNB_BANK_CORPORATE = 'pnb_bank_corporate';
  static const String PUNJAB_SIND_BANK = 'punjab_sind_bank';
  static const String RBL_BANK = 'rbl_bank';
  static const String SBI_BANK = 'sbi_bank';
  static const String SARASWAT_BANK = 'saraswat_bank';
  static const String TMB_BANK = 'tmb_bank';
  static const String UCO_BANK = 'uco_bank';
  static const String UNION_BANK = 'union_bank';
  static const String YES_BANK = 'yes_bank';

  static const String authorizationSuccessful = 'Authorization Successful';
  static const String authorizationFailed = 'Authorization Failed';

  static const String cdsl = 'CDSL';
  static const String nsdl = 'NSDL';

  static const String fundadded = 'Fund Added';
  static const String fundwithdraw = 'Fund Withdrawn';
  static const String customdates = 'Custom Dates';

  static const String userPush = 'USER_PUSH';
  static const String pushClickAction = 'PUSH_CLICK_ACTION';
  static const String isFreshLaunch = 'IS_FRESH_LAUNCH';
  static const String pushVideoLink = 'VIDEO_LINK';
  static const String mnu_notification = 'MNU_NOTIFICATION';

  static const String interFont = 'Inter';

  static const String main = 'main';
  static const String second = 'second';
  static const String third = 'third';

  static const String event = 'event';
  static const String description = 'description';
  static const String userId = 'userId';
  static const String platform = 'platform';

  //Alerts
  static const String volumeAlerts = "Volume Alerts";
  static const String priceAlerts = "Price Alerts";
  static const String priceMoveAboveKey = "gp";
  static const String priceMoveBelowKey = "lp";
  static const String priceMoveUpByPerKey = "gp_p";
  static const String priceMoveBelowPerKey = "lp_p";
  static const String volumeMovesaboveKey = "gv";
  static const String volumeMovesBelowKey = "lv";
}

enum Sort { ASCENDING, DESCENDING, NONE }
