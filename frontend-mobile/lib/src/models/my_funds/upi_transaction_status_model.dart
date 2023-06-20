import 'package:msil_library/models/base/base_model.dart';

class UPITransactionStatusModel extends BaseModel {
  String? reason;
  String? status;
  String? transId;

  UPITransactionStatusModel({this.status, this.reason, this.transId});

  UPITransactionStatusModel.fromJson(Map<String, dynamic> json)
      : super.fromJSON(json) {
    status = data['status'];
    reason = data['reason'];
    transId = data['TransId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = status;
    data['reason'] = reason;
    data['TransId'] = transId;
    return data;
  }
}
