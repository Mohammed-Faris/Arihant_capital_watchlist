import '../config/app_config.dart';

class ApiServicesUrls {
  static String baseURL = AppConfig.baseUrl;
  static String baseURLMarketData = AppConfig.baseURLMarketData;
  static String baseURLOmnesysWar = AppConfig.baseURLOmnesysWar;
  static String baseURLCmots = AppConfig.baseURLCmots;
  static String baseUrlbackOffice = AppConfig.baseUrlbackOffice;
  static String baseUrlPayment = AppConfig.baseURLPayment;
  static String baseURLEdis = AppConfig.baseURLEdis;
  static String baseURLShield = AppConfig.baseURLShield;
  static String baseURLOrdersocket = AppConfig.baseURLOrdersocket;
  static String alertURL = "${AppConfig.baseURL}/Alert";

  static String basketURL = "${AppConfig.baseURL}/basketOrder";

  static String init = '$baseURL/Init/Base/1.0.0';
  static String config = '$baseURL/Config/Base/1.0.0';

  ///login
  static String sendSMS = '$baseUrlbackOffice/BO/SendSMS';
  static String validateOTP = '$baseUrlbackOffice/BO/ValidateOTP';
  static String retriveUser = '$baseUrlbackOffice/BO/RetrieveUserType/1.0.0';
  static String login2fa = '$baseURLOmnesysWar/Trade/Login2FA_v1';
  static String validateSession = '$baseURLOmnesysWar/Trade/ValidateSession';
  static String logout = '$baseURLOmnesysWar/Trade/Logout';
  static String registerPIN = '$baseURLOmnesysWar/Trade/RegisterPin';
  static String loginPIN = '$baseURLOmnesysWar/Trade/LoginPin';
  static String accountInfo = '$baseURLOmnesysWar/Trade/AccountInfo';

  static String unBlockAccount = '$baseURLOmnesysWar/Trade/Unblock_v1';
  static String changePassword = '$baseURLOmnesysWar/Trade/ChangePass_v1';
  static String registerBiometric =
      '$baseURLOmnesysWar/Trade/RegisterBiometric_v1';
  static String loginBiometric = '$baseURLOmnesysWar/Trade/LoginBiometric';
  static String generateOtp = '$baseURLOmnesysWar/Trade/GenerateOTP_v1';
  static String validateOtp = '$baseURLOmnesysWar/Trade/ValidateOTP';
  static String forgetPassword = '$baseURLOmnesysWar/Trade/ChangePass';
  static String resetPassword = '$baseURLOmnesysWar/Trade/SetPassword_v1';
  static String search = '$baseURLMarketData/Symbol/Search/1.0.1';
  static String pcr = '$baseURLMarketData/Market/PutCallRatio/1.0.0';
  static String rollOver = '$baseURLMarketData/Market/RollOver/1.0.0';

  ///session validation
  static String sessionValidationUrl =
      '$baseURLOmnesysWar/Trade/ValidateSession';

  ///holdings
  static String holdings = '$baseUrlbackOffice/Trade/Holdings';
  static String getClientDetails = '$baseUrlbackOffice/BO/ClientDetails/1.0.0';
  static String ssoLoginUrl = '$baseUrlbackOffice/BO/GenerateSSOLoginURL/1.0.0';
  static String tradeHistoryUrl = '$baseUrlbackOffice/BO/TradeHistory/1.0.0';
  static String addNomineeUrl = '$baseUrlbackOffice/BO/NomineeSSO/LoginURL';

  ///watchlist
  static String getWatchlistGroups = '$baseURLOmnesysWar/Watchlist/GetGroups';
  static String getSymbols = '$baseURLOmnesysWar/Watchlist/GetSymbols';
  static String deleteWatchlist = '$baseURLOmnesysWar/Watchlist/DeleteGroup';
  static String rearrangeSymbolsInWatchlist =
      '$baseURLOmnesysWar/Watchlist/Rearrange';
  static String deleteSymbolsInWatchlist =
      '$baseURLOmnesysWar/Watchlist/DeleteSymbols';
  static String renameWatchlistGroup =
      '$baseURLOmnesysWar/Watchlist/RenameGroup';
  static String addGroup = '$baseURLOmnesysWar/Watchlist/AddGroup';
  static String addSymbols = '$baseURLOmnesysWar/Watchlist/AddSymbols';
  static String deletegroupSymbols =
      '$baseURLOmnesysWar/Watchlist/DeleteSymbols';

  ///indices
  static String getIndicesConstituents =
      '$baseURLMarketData/MarketMovers/IndexConstituentsSymbolService/1.0.0';

  ///quotes
  static String getSymbolInfo = '$baseURLMarketData/Quote/GetSymbolInfo/1.0.0';
  static String getSectorName = '$baseURLCmots/Overview/Sector/1.0.0';
  static String getPerformanceDeliveyData =
      '$baseURLCmots/DeliveryDataEOD/1.0.0';
  static String getPerformanceContractInfo =
      '$baseURLOmnesysWar/MarketData/ContractInfo_v1';
  static String getFundamentalKeyStats =
      '$baseURLCmots/CorpInfo/KeyStats/1.0.0';
  static String getFundamentalFinancialRatios =
      '$baseURLCmots/FinancialRatios/1.0.0';
  static String getQuoteCompany = '$baseURLCmots/CorpInfo/GetBackground/1.0.0';
  static String getPeersRatio = '$baseURLCmots/CorpInfo/CompPeerRatio/1.0.0';
  static String getQuoteFuture =
      '$baseURLMarketData/Quote/FutureChainService/1.0.0';
  static String getQuoteOption =
      '$baseURLMarketData/Quote/OptionChain_v1/1.0.0';
  static String getQuoteExpiryList =
      '$baseURLMarketData/Quote/QuoteExpiryListService/1.0.0';
  static String getQuoteNews = '$baseURLCmots/StockWiseNews/1.0.0';
  static String getQuoteNewsDetail =
      '$baseURLCmots/News/CorporateNewsDetails/1.0.0';
  static String getCorporateAction = '$baseURLCmots/CorporateActions/All/1.0.0';
  static String getCorpSymList = '$baseURLCmots/ListCorpSymbols/1.0.0';
  static String getTechnicalRatio = '$baseURLCmots/TechnicalRatios/1.0.0';
  static String getMovingAverages = '$baseURLCmots/TechnicalRatios/1.0.0';
  static String getPivotsPoints = '$baseURLCmots/PivotClassic/1.0.0';
  static String getVolumeAnalysis = '$baseURLCmots/VolumeAnalysis/1.0.0';
  static String getQuoteBlockDeals = '$baseURLCmots/Equity/BlockDeals/1.0.0';
  static String getMarketBulkDeals = '$baseURLCmots/BulkExchData/1.0.0';
  static String getMarketBlockDeals = '$baseURLCmots/BlockExchData/1.0.0';
  static String getQuoteBulkDeals = '$baseURLCmots/Equity/BulkDeals/1.0.0';
  static String getQuoteFinancialsQuarter =
      '$baseURLCmots/CorpInfo/FinancialsQuarterly/1.0.0';
  static String getQuoteFinancialsYearly =
      '$baseURLCmots/CorpInfo/ProfitLoss/1.0.1';
  static String getQuoteFinancialsShareHolding =
      '$baseURLCmots/ShareHoldingData/1.0.0';

  static String getQuoteFinancialsIncomeStatements =
      '$baseURLCmots/CorpInfo/ProfitLoss/1.0.1';

  ///chart
  static String getIntradayChartUrl =
      '$baseURLMarketData/Chart/GetChartData/1.0.1';
  static String getHistoryChartUrl =
      '$baseURLMarketData/Chart/GetHistoryData/1.0.1';

  ///Orders
  static String getOrderBook = '$baseURLOmnesysWar/Trade/OrderBook_v1';
  static String cancelOrderBook = '$baseURLOmnesysWar/Trade/CancelOrder';
  static String cancelgtdOrderBook = '$baseURLOmnesysWar/Trade/CancelGTDOrder';
  static String exitOrderBook = '$baseURLOmnesysWar/Trade/ExitOrder';
  static String getOrderStatusLog = '$baseURLOmnesysWar/Trade/OrderLog_v1';
  static String getgtdOrderStatusLog = '$baseURLOmnesysWar/Trade/GTDOrderLog';

  ///gtd orders
  static String getgtdOrderBook = '$baseURLOmnesysWar/Trade/GTDOrderBook';
  static String ordersocketUrl = '$baseURLOrdersocket/ws/connect';
  static String orderUpdateUrl = '$baseURLOrdersocket/ws/orderUpdate';

  ///Positions
  static String getPositions = '$baseURLOmnesysWar/Trade/Positions_v1';
  static String getPositionsConversion =
      '$baseURLOmnesysWar/Trade/ConvertPosition';

  ///Orderpad
  static String chargesRequest = '$baseUrlbackOffice/BO/Brokerage';

  static String placeOrderRequest = '$baseURLOmnesysWar/Trade/PlaceOrder_v1';
  static String placeModifiedOrderRequest =
      '$baseURLOmnesysWar/Trade/ModifyOrder';
  static String checkMarginRequest = '$baseURLOmnesysWar/Trade/CheckMargin';
  static String gtdPlaceOrderRequest = '$baseURLOmnesysWar/Trade/GTDOrder';
  static String gtdModifyOrderRequest =
      '$baseURLOmnesysWar/Trade/ModifyGTDOrder';
  static String coTriggerPriceRangeRequest =
      '$baseURLOmnesysWar/Trade/COTriggerPriceRange';

  ///Funds
  static String getAvailableFunds =
      '$baseURLOmnesysWar/FundTransfer/AvailableFunds';
  static String withdrawfunds = '$baseURLOmnesysWar/FundTransfer/AddPayout';
  static String fundsView = '$baseURLOmnesysWar/Trade/FundsView_v1';
  static String fundsViewLimit = '$baseURLOmnesysWar/Trade/Limits';
  static String fundsViewUpdated = '$baseURLOmnesysWar/Trade/FundsView_v2';

  ///static String getBankDetails = '$baseURLOmnesysWar/FundTransfer/BankDetails';
  static String getBankDetails = '$baseUrlbackOffice/BO/BankDetails/1.0.0';

  static String getPaymentOptionsModeDetails =
      '$baseUrlPayment/Payments/Options';
  static String getFundsTransactionUPIStatus =
      '$baseUrlPayment/Payments/UPI/Intent/TranStatusEnq';

  static String verifyUPIVPA = '$baseUrlPayment/Payments/UPI/VerifyVPA';

  static String getUPIInitProcess = '$baseUrlPayment/Payments/UPI/init';

  static String getUPITransactionStatus =
      '$baseUrlPayment/Payments/UPI/TransStatus';

  static String transactionhistory =
      '$baseUrlbackOffice/BO/TransactionHistory/1.0.0';

  static String transactioncancelhistory =
      '$baseURLOmnesysWar/FundTransfer/CancelPayout';
  static String transactionmodifyhistory =
      '$baseURLOmnesysWar/FundTransfer/ModifyPayout';

  static String getMaxPayoutWithdrawCash =
      '$baseUrlbackOffice/BO/WithdrawalFunds/1.0.0';

  ///Edis
  static String verifyEdis = '$baseURLEdis/EDIS/VerifyEdis/1.0.0';
  static String generateTpin = '$baseURLEdis/EDIS/GenerateTPIN/1.0.0';
  static String getNsdlAck = '$baseURLEdis/EDIS/NSDLCallBackReturnAPI/1.0.0';

  ///Market Movers
  static String getmarketMoversExpiryList =
      '$baseURLMarketData/MarketMovers/ExpiryListService/1.0.0';
  static String getMarketMovers =
      '$baseURLMarketData/MarketMovers/MarketMoversService/1.0.0';

  ///FIIDII
  static String getffiiDIi = '$baseURLCmots/CorpInfo/FIIDII/1.0.0';

  ///market status
  static String getMarketState = '$baseURLMarketData/GetMarketStatus/1.0.0';

  ///Shield Notification
  static String shieldRegisterURL = '$baseURLShield/Device/Register/1.0.1';
  static String shieldPushLogURL = '$baseURLShield/Device/NotifyUpdate/1.0.0';
  static String getAllNotifications =
      '$baseURLShield/Inbox/GetAllMessage/1.0.0';
  static String getUnreadUserNotificationCount =
      '$baseURLShield/Inbox/GetAllUnreadMessage/1.0.0';
  static String updateNotificationStatus =
      '$baseURLShield/Inbox/UpdateInboxMessageStatus/1.0.0';

  ///Alerts

  static String getPendingAlerts = '$alertURL/ListPendingAlerts/1.0.0';
  static String addAlert = "$alertURL/AddAlert/1.0.0";
  static String modifyAlert = "$alertURL/ModifyAlert/1.0.0";
  static String deleteAlert = "$alertURL/DeleteAlert/1.0.0";
  static String triggeredAlerts = '$alertURL/ListTriggeredAlerts/1.0.0';
  static String enableAlert = '$alertURL/EnableAlert/1.0.0';
  static String disableAlert = '';

  //Basket Order

  static String createBasket = "$basketURL/CreateBasket/1.0.0";
  static String fetchBasket = "$basketURL/GetBaskets/1.0.0";
  static String fetchBasketOrders = "$basketURL/GetBasketOrders/1.0.0";

  static String addtoBasket = '$basketURL/AddToBasket/1.0.0';
  static String executeBasketorder = "$basketURL/PlaceBasketOrder/1.0.0";
  static String deleteBasketorder = "$basketURL/DeleteBasketOrder/1.0.0";
  static String deleteBasket = "$basketURL/DeleteBasket/1.0.0";
  static String renameBasket = "$basketURL/RenameBasket/1.0.0";
  static String rearrangeBasket = "$basketURL/rearrangeBasket/1.0.0";
  static String resetBasket = "$basketURL/ResetBasketOrder/1.0.0";
  static String modifyBasketOrder = "$basketURL/ModifyBasketOrder/1.0.0";
  static String marginCalculate = "$basketURL/SpanCalculator/1.0.0";
}
