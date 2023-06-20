import 'package:msil_library/models/base/base_model.dart';

class UPIBankingDataModel extends BaseModel {
  String? payUrl;

  UPIBankingDataModel({this.payUrl});

  UPIBankingDataModel.fromJson(Map<String, dynamic> json)
      : super.fromJSON(json) {
    payUrl = data['payUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['payUrl'] = payUrl;
    return data;
  }
}
