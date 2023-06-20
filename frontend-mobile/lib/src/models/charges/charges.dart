import 'package:msil_library/models/base/base_model.dart';

class ChargesModel extends BaseModel {
  Brokerage? brokerage;

  ChargesModel({this.brokerage});

  ChargesModel.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    brokerage = data['brokerage'] != null
        ? Brokerage.fromJson(data['brokerage'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (brokerage != null) {
      data['brokerage'] = brokerage!.toJson();
    }
    return data;
  }
}

class Brokerage {
  String? stt;
  String? stampDuty;
  String? sebiFee;
  String? tot;
  String? gst;
  String? totalCharges;
  String? ipf;
  String? ipft;

  String? brokeragePrice;
  String? qty;
  String? price;
  String? externalCharges;
  String? taxes;

  Brokerage(
      {this.stt,
      this.stampDuty,
      this.sebiFee,
      this.tot,
      this.ipft,
      this.gst,
      this.totalCharges,
      this.ipf});

  Brokerage.fromJson(Map<String, dynamic> json) {
    stt = json['stt'];
    stampDuty = json['stampDuty'];
    sebiFee = json['sebiFee'];
    tot = json['tot'];
    gst = json['gst'];
    brokeragePrice = json['brokeragePrice'];
    qty = json['qty'];
    price = json['price'];
    totalCharges = json['totalCharges'];
    ipf = json['ipf'];
    ipft = json['ipft'];

    externalCharges = json['externalCharges'];
    taxes = json['taxes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stt'] = stt;
    data['stampDuty'] = stampDuty;
    data['sebiFee'] = sebiFee;
    data['tot'] = tot;
    data['gst'] = gst;
    data['totalCharges'] = totalCharges;
    data['ipf'] = ipf;
    data['ipft'] = ipft;

    data['price'] = price;
    data['qty'] = qty;
    data['brokeragePrice'] = brokeragePrice;
    data['externalCharges'] = externalCharges;
    data['taxes'] = taxes;
    return data;
  }
}
