import '../../api_services_urls.dart';
import '../../../models/common/message_model.dart';
import '../../../models/edis/nsdl_ack_model.dart';
import '../../../models/edis/verify_edis_model.dart';
import 'package:msil_library/httpclient/msil_httpclient.dart';
import 'package:msil_library/models/base/base_request.dart';

class EdisRepository {
  Future<VerifyEdisModel> verifyEdisRequest(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.verifyEdis, data: request.getRequest());

    return VerifyEdisModel.fromJson(resp);
  }

  Future<MessageModel> generateTpinRequest(BaseRequest request) async {
    final Map<String, dynamic> resp = await HTTPClient().postJSONRequest(
      url: ApiServicesUrls.generateTpin,
      data: request.getRequest(),
    );
    return MessageModel.fromJson(resp);
  }

  Future<NsdlAckModel> getNsdlAckRequest(BaseRequest request) async {
    final Map<String, dynamic> resp = await HTTPClient().postJSONRequest(
      url: ApiServicesUrls.getNsdlAck,
      data: request.getRequest(),
    );
    return NsdlAckModel.fromJson(resp);
  }
}
