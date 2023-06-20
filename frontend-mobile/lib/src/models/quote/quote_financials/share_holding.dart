class ShareHolding {
  List<ShareHoldDta>? shareHoldDta;

  ShareHolding({this.shareHoldDta});

  ShareHolding.fromJson(Map<String, dynamic> json) {
    if (json['shareHoldDta'] != null) {
      shareHoldDta = <ShareHoldDta>[];
      json['shareHoldDta'].forEach((v) {
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
