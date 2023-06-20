import 'package:msil_library/models/base/base_model.dart';

import '../../common/sym_model.dart';

class QuoteBlockDealsModel extends BaseModel {
  List<QuoteBlockDeals>? blockDeals;

  QuoteBlockDealsModel({this.blockDeals});

  QuoteBlockDealsModel.fromJson(Map<String, dynamic> json)
      : super.fromJSON(json) {
    if (data['blockDeals'] != null) {
      blockDeals = <QuoteBlockDeals>[];
      data['blockDeals'].forEach((v) {
        blockDeals!.add(QuoteBlockDeals.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (blockDeals != null) {
      data['blockDeals'] = blockDeals!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class QuoteBlockDeals {
  String? date;
  String? qtyShares;
  String? buySell;
  String? percentTraded;
  String? clientNme;
  String? avgPrce;
  String? dispSym;
  Sym? sym;
  String? baseSym;
  String? companyName;

  QuoteBlockDeals(
      {this.date,
      this.qtyShares,
      this.buySell,
      this.dispSym,
      this.companyName,
      this.baseSym,
      this.percentTraded,
      this.clientNme,
      this.sym,
      this.avgPrce});

  QuoteBlockDeals.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    qtyShares = json['qtyShares'];
    buySell = json['buySell'];
    if (json["sym"] != null) sym = Sym.fromJson(json['sym']);
    dispSym = json['dispSym'];
    baseSym = json['baseSym'];
    companyName = json['companyName'];

    percentTraded = json['percentTraded'];
    clientNme = json['clientNme'];
    avgPrce = json['avgPrce'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['qtyShares'] = qtyShares;
    data['buySell'] = buySell;
    data['percentTraded'] = percentTraded;
    data['clientNme'] = clientNme;
    data['avgPrce'] = avgPrce;
    data['dispSym'] = dispSym;
    data['companyName'] = companyName;
    data['baseSym'] = baseSym;
    data['sym'] = sym?.toJson();
    return data;
  }
}
