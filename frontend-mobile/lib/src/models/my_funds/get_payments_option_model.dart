import 'package:msil_library/models/base/base_model.dart';

class GetPaymentOptionModel extends BaseModel {
  List<PayOptions>? payOptions;
  PayUrl? payUrl;

  GetPaymentOptionModel({this.payOptions, this.payUrl});

  GetPaymentOptionModel.fromJson(Map<String, dynamic> json)
      : super.fromJSON(json) {
    if (data['payOptions'] != null) {
      payOptions = <PayOptions>[];
      data['payOptions'].forEach((v) {
        payOptions!.add(PayOptions.fromJson(v));
      });
    }
    payUrl = data['payUrl'] != null ? PayUrl.fromJson(data['payUrl']) : null;
  }

  GetPaymentOptionModel.datafromJson(Map<String, dynamic> json) {
    if (json['payOptions'] != null) {
      payOptions = <PayOptions>[];
      json['payOptions'].forEach((v) {
        payOptions!.add(PayOptions.fromJson(v));
      });
    }
    payUrl = json['payUrl'] != null ? PayUrl.fromJson(json['payUrl']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (payOptions != null) {
      data['payOptions'] = payOptions!.map((v) => v.toJson()).toList();
    }
    if (payUrl != null) {
      data['payUrl'] = payUrl!.toJson();
    }
    return data;
  }
}

class PayOptions {
  String? bank;
  Channels? channels;
  List<String>? payMode;

  PayOptions({this.bank, this.channels, this.payMode});

  PayOptions.fromJson(Map<String, dynamic> json) {
    bank = json['bank'];
    channels =
        json['channels'] != null ? Channels.fromJson(json['channels']) : null;
    payMode = json['payMode'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['bank'] = bank;
    if (channels != null) {
      data['channels'] = channels!.toJson();
    }
    data['payMode'] = payMode;
    return data;
  }
}

class Channels {
  List<String>? pG;
  List<String>? uPI;

  Channels({this.pG, this.uPI});

  Channels.fromJson(Map<String, dynamic> json) {
    pG = (json['PG'] != null) ? json['PG'].cast<String>() : [];
    uPI = (json['UPI'] != null) ? json['UPI'].cast<String>() : [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['PG'] = (pG != null && pG!.isNotEmpty) ? pG : [];
    data['UPI'] = (uPI != null && uPI!.isNotEmpty) ? uPI : [];
    return data;
  }
}

class PayUrl {
  String? nETBANKING;
  String? pG;
  String? uPI;

  PayUrl({this.nETBANKING, this.pG, this.uPI});

  PayUrl.fromJson(Map<String, dynamic> json) {
    nETBANKING = json['NETBANKING'];
    pG = json['PG'];
    uPI = json['UPI'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['NETBANKING'] = nETBANKING;
    data['PG'] = pG;
    data['UPI'] = uPI;
    return data;
  }
}
