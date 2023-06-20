import 'package:msil_library/models/base/base_model.dart';

class NetBankingDataModel extends BaseModel {
  String? listenUrl;
  String? method;
  String? payUrl;

  NetBankingDataModel({this.listenUrl, this.method, this.payUrl});

  NetBankingDataModel.fromJson(Map<String, dynamic> json)
      : super.fromJSON(json) {
    listenUrl = data['listenUrl'];
    method = data['method'];
    payUrl = data['payUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['listenUrl'] = listenUrl;
    data['method'] = method;
    data['payUrl'] = payUrl;
    return data;
  }
}
