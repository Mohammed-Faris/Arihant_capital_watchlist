import 'package:msil_library/models/base/base_model.dart';

class BankDetailsModel extends BaseModel {
  List<Banks>? banks;

  BankDetailsModel({this.banks});

  BankDetailsModel.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    if (data['banks'] != null) {
      banks = <Banks>[];
      data['banks'].forEach((v) {
        banks!.add(Banks.fromJson(v));
      });
    }
  }

  BankDetailsModel.dataFromJson(Map<String, dynamic> json) {
    if (json['banks'] != null) {
      banks = <Banks>[];
      json['banks'].forEach((v) {
        banks!.add(Banks.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (banks != null) {
      data['banks'] = banks!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Banks {
  String? accountNo;
  String? bankName;
  bool isBankChoosen = false;

  Banks({this.accountNo, this.bankName});

  Banks.fromJson(Map<String, dynamic> json) {
    accountNo = json['accountNo'];
    bankName = json['bankName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['accountNo'] = accountNo;
    data['bankName'] = bankName;
    return data;
  }
}
