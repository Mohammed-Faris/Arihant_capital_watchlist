import 'package:msil_library/httpclient/msil_httpclient.dart';
import 'package:msil_library/models/base/base_model.dart';
import 'package:msil_library/models/base/base_request.dart';

import '../../../models/basket_order/basket_model.dart';
import '../../../models/basket_order/basket_orderbook.dart';
import '../../api_services_urls.dart';

class BasketRepository {
  Future<BaseModel> createBasket(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        isEncryption: false,
        url: ApiServicesUrls.createBasket,
        data: request.getRequest());
    return BaseModel.fromJSON(resp);
  }

  Future<Basketmodel> fetchBasket() async {
    final HTTPClient httpClient = HTTPClient();
    final BaseRequest request = BaseRequest();
    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        isEncryption: false,
        url: ApiServicesUrls.fetchBasket,
        data: request.getRequest());

    return Basketmodel.fromJson(resp);
  }

  Future<BasketOrderBook> fetchBasketOrders(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        isEncryption: false,
        url: ApiServicesUrls.fetchBasketOrders,
        data: request.getRequest());

    return BasketOrderBook.fromJson(resp);
  }

  Future<BaseModel> executeBasketorder(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        isEncryption: false,
        url: ApiServicesUrls.executeBasketorder,
        data: request.getRequest());
    return BaseModel.fromJSON(resp);
  }

  Future<BaseModel> deleteBasketorder(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        isEncryption: false,
        url: ApiServicesUrls.deleteBasketorder,
        data: request.getRequest());
    return BaseModel.fromJSON(resp);
  }

  Future<BaseModel> deleteBasket(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        isEncryption: false,
        url: ApiServicesUrls.deleteBasket,
        data: request.getRequest());
    return BaseModel.fromJSON(resp);
  }

  Future<BaseModel> renameBasket(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        isEncryption: false,
        url: ApiServicesUrls.renameBasket,
        data: request.getRequest());
    return BaseModel.fromJSON(resp);
  }

  Future<BaseModel> rearrangeBasket(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        isEncryption: false,
        url: ApiServicesUrls.rearrangeBasket,
        data: request.getRequest());
    return BaseModel.fromJSON(resp);
  }

  Future<BaseModel> resetBasket(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        isEncryption: false,
        url: ApiServicesUrls.resetBasket,
        data: request.getRequest());
    return BaseModel.fromJSON(resp);
  }

  Future<BaseModel> marginCalculate(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        isEncryption: false,
        url: ApiServicesUrls.marginCalculate,
        data: request.getRequest());
    return BaseModel.fromJSON(resp);
  }
}
