import 'package:msil_library/models/base/base_model.dart';

import '../../../constants/app_constants.dart';
import '../../../data/store/app_utils.dart';
import '../../common/sym_model.dart';

class QuotesBulkDealsModel extends BaseModel {
  List<BulkDealsModel>? bulkDeals;

  QuotesBulkDealsModel({this.bulkDeals});

  QuotesBulkDealsModel.fromJson(Map<String, dynamic> json)
      : super.fromJSON(json) {
    if (data['bulkDeals'] != null) {
      bulkDeals = <BulkDealsModel>[];
      data['bulkDeals'].forEach((v) {
        bulkDeals!.add(BulkDealsModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (bulkDeals != null) {
      data['bulkDeals'] = bulkDeals!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BulkDealsModel {
  String? date;
  String? qtyShares;
  String? buySell;
  String? percentTraded;
  String? clientNme;
  String? avgPrce;
  String? dispSym;
  String? baseSym;
  String? companyName;
  bool isFno = false;

  Sym? sym;
  BulkDealsModel(
      {this.date,
      this.qtyShares,
      this.dispSym,
      this.buySell,
      this.sym,
      this.companyName,
      this.baseSym,
      this.percentTraded,
      this.clientNme,
      this.avgPrce});

  BulkDealsModel.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    qtyShares = json['qtyShares'];
    buySell = json['buySell'];
    companyName = json['companyName'];
    baseSym = json['baseSym'];
    percentTraded = json['percentTraded'];
    clientNme = json['clientNme'];
    if (json["sym"] != null) sym = Sym.fromJson(json['sym']);
    dispSym = json['dispSym'];
    avgPrce = json['avgPrce'];
    if (AppUtils().getsymbolTypeFromSym(sym) == AppConstants.fno) {
      isFno = true;
    }
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
    data['isFno'] = isFno.toString();

    return data;
  }
}
