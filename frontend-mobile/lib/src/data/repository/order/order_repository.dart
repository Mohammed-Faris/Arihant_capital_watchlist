import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:msil_library/httpclient/msil_httpclient.dart';
import 'package:msil_library/models/base/base_model.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/utils/config/infoIDConfig.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

import '../../../constants/app_constants.dart';
import '../../../models/orders/order_book.dart';
import '../../../models/orders/order_status_log.dart';
import '../../../models/orders/tradehistory_model.dart';
import '../../../models/sort_filter/sort_filter_model.dart';
import '../../api_services_urls.dart';
import '../../cache/cache_repository.dart';
import '../../store/app_store.dart';
import '../../store/app_utils.dart';

class OrderRepository {
  Future<OrderBook> getOrderBookRequest(BaseRequest request,
      {bool isGtdorder = false}) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: isGtdorder
            ? ApiServicesUrls.getgtdOrderBook
            : ApiServicesUrls.getOrderBook,
        data: request.getRequest());

    final OrderBook orderBook = OrderBook.fromJson(resp);
    CacheRepository.orderbook
        .put(isGtdorder ? 'getgtdOrders' : 'getOrders', orderBook);

    return orderBook;
  }

  Future<TradeHistory> getTradeHistory(DateTime? fromDate, DateTime? toDate,
      List<FilterModel>? filterModel) async {
    final HTTPClient httpClient = HTTPClient();

    List<Filters> multiFilters = <Filters>[];
    List<String> filterKeys = [
      AppConstants.ordAction,
      AppConstants.actualExc,
      AppConstants.prdType,
      AppConstants.moreFilters,
    ];

    if (filterModel != null && filterModel.isNotEmpty) {
      int i = 0;
      for (FilterModel element in filterModel) {
        List<String> filters = [];
        for (Filters element in element.filtersList!) {
          if (element.value == AppConstants.fo) {
            element.value = AppConstants.nfo;
          }
          filters.add(element.value);
        }
        if (filters.isNotEmpty) {
          if (element.filterName != AppConstants.moreFilters) {
            multiFilters.add(Filters(key: filterKeys[i], value: filters));
          }
        }

        i++;
      }
    }

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.tradeHistoryUrl,
        data: BaseRequest(data: {
          "frmDte":
              fromDate != null ? DateFormat('dd/MM/yyyy').format(fromDate) : "",
          "toDte":
              toDate != null ? DateFormat('dd/MM/yyyy').format(toDate) : "",
          "prdt": "0",
          "multiFilters": multiFilters
        }).getRequest());

    return TradeHistory.fromJson(resp);
  }

  Future<OrderStatusLog> getOrderStatusLogRequest(
      BaseRequest request, bool isGtd) async {
    final HTTPClient httpClient = HTTPClient();

    log(ApiServicesUrls.getgtdOrderStatusLog);

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: isGtd
            ? ApiServicesUrls.getgtdOrderStatusLog
            : ApiServicesUrls.getOrderStatusLog,
        data: request.getRequest());
    return OrderStatusLog.fromJson(resp);
  }

  Future<BaseModel> getCancelOrderBookRequest(
      BaseRequest request, bool isGtd) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: isGtd
            ? ApiServicesUrls.cancelgtdOrderBook
            : ApiServicesUrls.cancelOrderBook,
        data: request.getRequest());

    return BaseModel.fromJSON(resp);
  }

  Future<BaseModel> getExitOrderBookRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.exitOrderBook, data: request.getRequest());

    return BaseModel.fromJSON(resp);
  }

  Future<bool> getOrderupdate() async {
    final HTTPClient httpClient = HTTPClient();
    final BaseRequest request = BaseRequest();
    var username = AppStore().getAccountName();
    dynamic getSmartLoginDetails =
        await AppUtils().getsmartDetails(userName: username);
    if (getSmartLoginDetails != null) {
      request.addToData('user', getSmartLoginDetails?['uid']);

      final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.orderUpdateUrl,
        isEncryption: false,
        data: request.getRequest(),
      );
      if (resp["response"]["infoID"] == InfoIDConfig.invalidSessionCode) {
        throw ServiceException(
            InfoIDConfig.invalidSessionCode, resp["response"]["infoMsg"]);
      }
      return resp["response"]["infoMsg"] == "New Updates are available"
          ? true
          : false;
    }
    return false;
  }

  Future<dynamic> connectOrdersocket() async {
    var username = AppStore().getAccountName();
    dynamic getSmartLoginDetails =
        await AppUtils().getsmartDetails(userName: username);

    if (getSmartLoginDetails?['userSessionId'] != null &&
        getSmartLoginDetails?['userSessionId'] != "" &&
        !AppConstants.connectedSocket) {
      final HTTPClient httpClient = HTTPClient();
      final BaseRequest request = BaseRequest();
      request.addToData('user', getSmartLoginDetails?['uid']);
      request.addToData('token', getSmartLoginDetails?['userSessionId']);

      try {
        await httpClient.postJSONRequest(
            url: ApiServicesUrls.ordersocketUrl,
            data: request.getRequest(),
            isEncryption: false);
        AppConstants.connectedSocket = true;
      } catch (e) {
        AppUtils().logSuccess("Error", e);
      }
    }
  }
}
