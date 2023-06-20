import 'package:msil_library/models/base/base_model.dart';

class TransactionHistoryModel extends BaseModel {
  List<History>? history;

  TransactionHistoryModel({this.history});

  TransactionHistoryModel.fromJson(Map<String, dynamic> json)
      : super.fromJSON(json) {
    if (data['history'] != null) {
      history = <History>[];
      data['history'].forEach((v) {
        history!.add(History.fromJson(v));
      });
    }
  }

  TransactionHistoryModel.datafromJson(Map<String, dynamic> json) {
    if (json['history'] != null) {
      history = <History>[];
      json['history'].forEach((v) {
        history!.add(History.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (history != null) {
      data['history'] = history!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class History {
  String? date;
  bool? payIn;
  String? instructionId;
  String? amt;
  String? bankName;
  String? bankAccNo;
  String? status;
  String? transType;
  String? transId;
  String? vpa;
  String dispAccnumber = '';

  History({
    this.date,
    this.payIn,
    this.instructionId,
    this.amt,
    this.bankName,
    this.bankAccNo,
    this.status,
    this.transType,
    this.transId,
    this.vpa,
  });

  History.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    payIn = json['payIn'];
    instructionId = json['instructionId'];
    amt = json['amt'];
    bankName = json['bankName'];
    bankAccNo = json['bankAccNo'];
    status = json['status'];
    transType = json['transType'];
    transId = json['transId'];
    vpa = json['vpa'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['date'] = date;
    data['payIn'] = payIn;
    data['instructionId'] = instructionId;
    data['amt'] = amt;
    data['bankName'] = bankName;
    data['bankAccNo'] = bankAccNo;
    data['status'] = status;
    data['transType'] = transType;
    data['transId'] = transId;
    data['vpa'] = vpa;
    return data;
  }
}
