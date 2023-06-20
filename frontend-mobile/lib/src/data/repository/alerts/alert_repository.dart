import 'package:msil_library/httpclient/msil_httpclient.dart';
import 'package:msil_library/models/base/base_model.dart';
import 'package:msil_library/models/base/base_request.dart';

import '../../../models/alerts/alerts_model.dart';
import '../../../models/alerts/create_modify_alert_model.dart';
import '../../api_services_urls.dart';

import '../../cache/cache_repository.dart';

class AlertsRepository {
  Future<AlertModel> fetchPendingAlerts() async {
    final HTTPClient httpClient = HTTPClient();
    final BaseRequest request = BaseRequest();
    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        isEncryption: false,
        url: ApiServicesUrls.getPendingAlerts,
        data: request.getRequest());
    AlertModel alertModel = AlertModel.fromJson(resp);
    CacheRepository.alerts.put('fetchPendingAlerts', alertModel);

    return alertModel;
  }

  Future<BaseModel> createAlert(
      CreateorModifyAlertModel createorModifyAlertModel) async {
    final HTTPClient httpClient = HTTPClient();
    final BaseRequest request =
        BaseRequest(data: createorModifyAlertModel.toJson());

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        isEncryption: false,
        url: ApiServicesUrls.addAlert,
        data: request.getRequest());
    return BaseModel.fromJSON(resp);
  }

  Future<BaseModel> updateAlert(
      CreateorModifyAlertModel createorModifyAlertModel) async {
    final HTTPClient httpClient = HTTPClient();
    final BaseRequest request =
        BaseRequest(data: createorModifyAlertModel.toJson());

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        isEncryption: false,
        url: ApiServicesUrls.modifyAlert,
        data: request.getRequest());
    return BaseModel.fromJSON(resp);
  }

  Future<BaseModel> deleteAlert(String alertId) async {
    final HTTPClient httpClient = HTTPClient();
    final BaseRequest request = BaseRequest(data: {"alertID": alertId});

    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        isEncryption: false,
        url: ApiServicesUrls.deleteAlert,
        data: request.getRequest());
    return BaseModel.fromJSON(resp);
  }

  Future<AlertModel> fetchTriggeredAlerts() async {
    final HTTPClient httpClient = HTTPClient();
    final BaseRequest request = BaseRequest();
    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        isEncryption: false,
        url: ApiServicesUrls.triggeredAlerts,
        data: request.getRequest());
    return AlertModel.fromJson(resp);
  }
}
