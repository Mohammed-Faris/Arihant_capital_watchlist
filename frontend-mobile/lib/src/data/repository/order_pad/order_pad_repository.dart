import 'package:msil_library/httpclient/msil_httpclient.dart';
import 'package:msil_library/models/base/base_request.dart';

import '../../../models/charges/charges.dart';
import '../../../models/order_pad/check_margin_model.dart';
import '../../../models/order_pad/co_trigger_price_range_model.dart';
import '../../../models/order_pad/order_pad_place_order_model.dart';
import '../../../models/quote/get_symbol_info_model.dart';
import '../../api_services_urls.dart';

class OrderPadRepository {
  Future<GetSymbolModel> getSymbolInfoRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getSymbolInfo, data: request.getRequest());

    return GetSymbolModel.fromJson(resp);
  }

  Future<ChargesModel> chargesRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.chargesRequest, data: request.getRequest());

    return ChargesModel.fromJson(resp);
  }

  Future<OrderPadPlaceOrderModel> placeOrderRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.placeOrderRequest, data: request.getRequest());

    return OrderPadPlaceOrderModel.fromJson(resp);
  }

  Future<OrderPadPlaceOrderModel> gtdPlaceOrderRequest(
      BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.gtdPlaceOrderRequest, data: request.getRequest());

    return OrderPadPlaceOrderModel.fromJson(resp);
  }

  Future<OrderPadPlaceOrderModel> placeModifyOrderRequest(
      BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.placeModifiedOrderRequest,
        data: request.getRequest());

    return OrderPadPlaceOrderModel.fromJson(resp);
  }

  Future<OrderPadPlaceOrderModel> placegtdModifyOrderRequest(
      BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.gtdModifyOrderRequest, data: request.getRequest());

    return OrderPadPlaceOrderModel.fromJson(resp);
  }

  Future<CheckMarginModel> checkMarginRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.checkMarginRequest, data: request.getRequest());

    return CheckMarginModel.fromJson(resp);
  }

  Future<CoTriggerPriceRangeModel> coTriggerPriceRangeRequest(
      BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.coTriggerPriceRangeRequest,
        data: request.getRequest());

    return CoTriggerPriceRangeModel.fromJson(resp);
  }

  //------basket order------
  Future<OrderPadPlaceOrderModel> placeBasketOrderRequest(
      BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.addtoBasket, data: request.getRequest());

    return OrderPadPlaceOrderModel.fromJson(resp);
  }

  Future<OrderPadPlaceOrderModel> placeBasketModifyOrderRequest(
      BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.modifyBasketOrder, data: request.getRequest());

    return OrderPadPlaceOrderModel.fromJson(resp);
  }
}
