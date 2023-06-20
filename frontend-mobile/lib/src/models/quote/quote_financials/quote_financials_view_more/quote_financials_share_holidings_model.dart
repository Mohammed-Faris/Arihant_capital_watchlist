import 'package:msil_library/models/base/base_model.dart';

class FinancialsShareHoldings extends BaseModel {
  List<ShareHoldDta>? shareHoldDta;

  FinancialsShareHoldings({this.shareHoldDta});

  FinancialsShareHoldings.fromJson(Map<String, dynamic> json)
      : super.fromJSON(json) {
    if (data['shareHoldDta'] != null) {
      shareHoldDta = <ShareHoldDta>[];
      data['shareHoldDta'].forEach((v) {
        shareHoldDta!.add(ShareHoldDta.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (shareHoldDta != null) {
      data['shareHoldDta'] = shareHoldDta!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ShareHoldDta {
  String? date;
  String? fiis;
  String? otherDiis;
  String? promoters;
  String? insuranceComp;
  String? mutualFunds;
  String? nonInstitution;

  ShareHoldDta(
      {this.date,
      this.fiis,
      this.otherDiis,
      this.promoters,
      this.insuranceComp,
      this.mutualFunds,
      this.nonInstitution});

  ShareHoldDta.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    fiis = json['fiis'];
    otherDiis = json['otherDiis'];
    promoters = json['promoters'];
    insuranceComp = json['insuranceComp'];
    mutualFunds = json['mutualFunds'];
    nonInstitution = json['nonInstitution'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['fiis'] = fiis;
    data['otherDiis'] = otherDiis;
    data['promoters'] = promoters;
    data['insuranceComp'] = insuranceComp;
    data['mutualFunds'] = mutualFunds;
    data['nonInstitution'] = nonInstitution;
    return data;
  }
}
