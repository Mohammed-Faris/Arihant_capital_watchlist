import '../../api_services_urls.dart';
import 'package:msil_library/httpclient/msil_httpclient.dart';
import 'package:msil_library/models/base/base_model.dart';
import 'package:msil_library/models/base/base_request.dart';

class SessionValidationRepository {
  factory SessionValidationRepository() {
    return _this;
  }

  SessionValidationRepository._();

  static final SessionValidationRepository _this =
      SessionValidationRepository._();

  static SessionValidationRepository get instance => _this;

  Future<BaseModel> validateSession(BaseRequest request) async {
    final Map<String, dynamic> resp = await HTTPClient().postJSONRequest(
      url: ApiServicesUrls.sessionValidationUrl,
      data: request.getRequest(),
    );

    return BaseModel.fromJSON(resp);
  }
}
