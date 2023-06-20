import 'package:msil_library/httpclient/msil_httpclient.dart';
import 'package:msil_library/models/base/base_model.dart';
import 'package:msil_library/models/base/base_request.dart';

import '../../../models/positions/positions_model.dart';
import '../../api_services_urls.dart';
import '../../cache/cache_repository.dart';

class PositionsRepository {
  Future<PositionsModel> getPositionsRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();
    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getPositions, data: request.getRequest());
    final PositionsModel positions = PositionsModel.fromJson(resp);
    CacheRepository.positions.put('getPositions', positions);

    return positions;
  }

  Future<BaseModel> getPositionsConversionRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getPositionsConversion,
        data: request.getRequest());

    return BaseModel.fromJSON(resp);
  }
}
