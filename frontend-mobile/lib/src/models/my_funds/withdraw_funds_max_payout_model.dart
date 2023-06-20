import 'package:msil_library/models/base/base_model.dart';

class WithdrawCashMaxPayoutModel extends BaseModel {
  List<PayReqResult>? payReqResult;

  WithdrawCashMaxPayoutModel({this.payReqResult});

  WithdrawCashMaxPayoutModel.fromJson(Map<String, dynamic> json)
      : super.fromJSON(json) {
    if (data['payReqResult'] != null) {
      payReqResult = <PayReqResult>[];
      data['payReqResult'].forEach((v) {
        payReqResult!.add(PayReqResult.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (payReqResult != null) {
      data['payReqResult'] = payReqResult!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PayReqResult {
  String? firm;
  String? bankType;
  String? clientCode;
  String? name;
  String? maxPayout;
  String? bankName;
  String? bankAccNo;

  PayReqResult(
      {this.firm,
      this.bankType,
      this.clientCode,
      this.name,
      this.maxPayout,
      this.bankName,
      this.bankAccNo});

  PayReqResult.fromJson(Map<String, dynamic> json) {
    firm = json['firm'];
    bankType = json['bankType'];
    clientCode = json['clientCode'];
    name = json['name'];
    maxPayout = json['maxPayout'];
    bankName = json['bankName'];
    bankAccNo = json['bankAccNo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['firm'] = firm;
    data['bankType'] = bankType;
    data['clientCode'] = clientCode;
    data['name'] = name;
    data['maxPayout'] = maxPayout;
    data['bankName'] = bankName;
    data['bankAccNo'] = bankAccNo;
    return data;
  }
}
