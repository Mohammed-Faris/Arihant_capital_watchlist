import '../../../models/linechart/historydata.dart';
import 'package:msil_library/httpclient/msil_httpclient.dart';
import 'package:msil_library/models/base/base_request.dart';
import '../../api_services_urls.dart';

class LineChartRepository {
  Future<HistoryData> getHistoryData(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();
    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getHistoryChartUrl, data: request.getRequest());
    return HistoryData.fromJson(resp);
  }

  Future<HistoryData> getIntradayData(BaseRequest request) async {
    final HTTPClient httpClient = HTTPClient();
    final Map<String, dynamic> resp = await httpClient.postJSONRequest(
        url: ApiServicesUrls.getIntradayChartUrl, data: request.getRequest());

    return HistoryData.fromJson(resp);
  }
}
