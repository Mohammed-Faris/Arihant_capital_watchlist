import 'package:msil_library/models/base/base_model.dart';

class FinancialsYearly extends BaseModel {
  Values? values;
  List<String>? yrc;

  FinancialsYearly({this.values, this.yrc});

  FinancialsYearly.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    values = data['values'] != null ? Values.fromJson(data['values']) : null;
    yrc = data['yrc'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (values != null) {
      data['values'] = values!.toJson();
    }
    data['yrc'] = yrc;
    return data;
  }
}

class Values {
  List<String>? revenue;
  List<String>? netPrft;
  List<String>? expnses;
  List<String>? revnuFrmOprns;
  List<String>? ebitda;
  List<String>? prftBfrTax;
  List<String>? othrInc;

  Values(
      {this.revenue,
      this.netPrft,
      this.expnses,
      this.revnuFrmOprns,
      this.ebitda,
      this.prftBfrTax,
      this.othrInc});

  Values.fromJson(Map<String, dynamic> json) {
    revenue = json['revenue'].cast<String>();
    netPrft = json['netPrft'].cast<String>();
    expnses = json['expnses'].cast<String>();
    revnuFrmOprns = json['revnuFrmOprns'].cast<String>();
    ebitda = json['ebitda'].cast<String>();
    prftBfrTax = json['prftBfrTax'].cast<String>();
    othrInc = json['othrInc'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['revenue'] = revenue;
    data['netPrft'] = netPrft;
    data['expnses'] = expnses;
    data['revnuFrmOprns'] = revnuFrmOprns;
    data['ebitda'] = ebitda;
    data['prftBfrTax'] = prftBfrTax;
    data['othrInc'] = othrInc;
    return data;
  }
}
