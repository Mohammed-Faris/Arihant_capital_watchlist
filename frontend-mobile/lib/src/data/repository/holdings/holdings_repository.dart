import 'package:msil_library/httpclient/msil_httpclient.dart';
import 'package:msil_library/models/base/base_request.dart';

import '../../../models/holdings/holdings_model.dart';
import '../../api_services_urls.dart';
import '../../cache/cache_repository.dart';

class HoldingsRepository {
  Future<HoldingsModel> fetchHoldingsRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
      url: ApiServicesUrls.holdings,
      data: request.getRequest(),
    );
    final HoldingsModel holdings = HoldingsModel.fromJson(resp);
    CacheRepository.holdingsCache.put('getHoldings', holdings);

    return holdings;
  }
}
