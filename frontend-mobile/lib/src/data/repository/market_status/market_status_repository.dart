import '../../api_services_urls.dart';
import '../../../models/market_status/market_status_model.dart';
import 'package:msil_library/httpclient/msil_httpclient.dart';
import 'package:msil_library/models/base/base_request.dart';

class MarketStatusRepository {
  Future<MarketStatusModel> getMarketStatusRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getMarketState, data: request.getRequest());

    return MarketStatusModel.fromJson(resp);
  }
}
