import '../../api_services_urls.dart';
import '../../../models/init/init_model.dart';
import 'package:msil_library/httpclient/msil_httpclient.dart';
import 'package:msil_library/models/base/base_request.dart';

class InitRepository {
  Future<InitModel> sendRequest(BaseRequest initRequest) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.init, data: initRequest.getRequest());

    return InitModel.fromJson(resp);
  }
}
