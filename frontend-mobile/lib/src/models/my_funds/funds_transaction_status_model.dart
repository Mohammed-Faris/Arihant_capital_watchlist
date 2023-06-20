import 'package:msil_library/models/base/base_model.dart';

class FundsTransactionStatusUPIModel extends BaseModel {
  String? reason;
  String? amount;
  String? vpa;
  String? transId;
  String? status;

  FundsTransactionStatusUPIModel(
      {this.reason, this.amount, this.vpa, this.transId, this.status});

  FundsTransactionStatusUPIModel.fromJson(Map<String, dynamic> json)
      : super.fromJSON(json) {
    reason = data['reason'];
    amount = data['amount'];
    vpa = data['vpa'];
    transId = data['TransId'];
    status = data['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['reason'] = reason;
    data['amount'] = amount;
    data['vpa'] = vpa;
    data['TransId'] = transId;
    data['status'] = status;
    return data;
  }
}
