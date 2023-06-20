import '../../../models/markets/fiidii_model.dart';
import '../../../models/markets/market_movers_model.dart';
import 'package:msil_library/httpclient/msil_httpclient.dart';
import 'package:msil_library/models/base/base_request.dart';

import '../../../models/markets/market_movers_expiry_model.dart';
import '../../../models/markets/put_call_model.dart';
import '../../../models/markets/rollover_model.dart';
import '../../api_services_urls.dart';

class MarketMoversRepository {
  Future<MarketMoversModel> getMarketMoversRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();
    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getMarketMovers, data: request.getRequest());

    return MarketMoversModel.fromJson(resp, isMarketMovers: true);
  }

  Future<PutCallRatioModel> getPCR(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();
    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.pcr, data: request.getRequest());

    return PutCallRatioModel.fromJson(resp);
  }

  Future<FIIDIIModel> getFiiDii(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();
    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getffiiDIi, data: request.getRequest());

    return FIIDIIModel.fromJson(resp);
  }

  Future<RollOverModel> getRollOverList(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();
    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.rollOver, data: request.getRequest());

    return RollOverModel.fromJson(resp);
  }

  Future<MarketMoversExpiryModel> getMarketMoversQuoteExpiryListRequest(
      BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();
    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getmarketMoversExpiryList,
        data: request.getRequest());

    return MarketMoversExpiryModel.fromJson(resp);
  }

  Future<MarketMoversModel> getMarketMoversFOTopGainersLosersRequest(
      BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();
    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getMarketMovers, data: request.getRequest());

    return MarketMoversModel.fromJson(resp);
  }
}
