import '../../api_services_urls.dart';
import '../../../models/indices/indices_constituents_model.dart';
import 'package:msil_library/httpclient/msil_httpclient.dart';
import 'package:msil_library/models/base/base_request.dart';

class IndicesRepository {
  Future<IndicesConstituentsModel> getIndicesConstituentsRequest(
      BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getIndicesConstituents,
        data: request.getRequest());

    return IndicesConstituentsModel.fromJson(resp);
  }
}
