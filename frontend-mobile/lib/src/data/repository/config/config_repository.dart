import '../../api_services_urls.dart';
import '../../../models/config/config_model.dart';
import 'package:msil_library/httpclient/msil_httpclient.dart';
import 'package:msil_library/models/base/base_request.dart';

class ConfigRepository {
  Future<ConfigModel> sendRequest(BaseRequest configRequest) async {
    final Map<String, dynamic> resp = await HTTPClient().postJSONRequest(
        url: ApiServicesUrls.config, data: configRequest.getRequest());
    return ConfigModel.fromJson(resp);
  }
}
