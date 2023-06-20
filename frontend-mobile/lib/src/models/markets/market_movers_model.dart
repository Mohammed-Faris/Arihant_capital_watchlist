// ignore_for_file: overridden_fields

import 'package:acml/src/models/common/symbols_model.dart';
import 'package:msil_library/models/base/base_model.dart';

import '../../constants/app_constants.dart';
import '../../data/store/app_utils.dart';
import '../common/sym_model.dart';

class MarketMoversModel extends BaseModel {
  List<MarketMovers>? marketMovers;
  bool? isMarketMoversG;

  MarketMoversModel({this.marketMovers, this.isMarketMoversG = false});

  MarketMoversModel.fromJson(Map<String, dynamic> json, {bool? isMarketMovers})
      : super.fromJSON(json) {
    if (data['marketMovers'] != null) {
      isMarketMoversG = isMarketMovers;
      marketMovers = <MarketMovers>[];
      data['marketMovers'].forEach((v) {
        marketMovers!.add(MarketMovers.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (marketMovers != null) {
      data['marketMovers'] = marketMovers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MarketMovers extends Symbols {
  @override
  String? dispSym;
  @override
  Sym? sym;
  @override
  String? companyName;
  @override
  String? baseSym;
  MarketMovers();

  MarketMovers.fromJson(Map<String, dynamic> json) {
    dispSym = json['dispSym'];
    sym = json['sym'] != null ? Sym.fromJson(json['sym']) : null;
    companyName = json['companyName'];
    baseSym = json['baseSym'];
    isFno = json['isFno'] == "true";
    if (AppUtils().getsymbolTypeFromSym(sym) == AppConstants.fno) {
      isFno = true;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dispSym'] = dispSym;
    if (sym != null) {
      data['sym'] = sym!.toJson();
    }
    data['isFno'] = isFno.toString();

    data['companyName'] = companyName;
    data['baseSym'] = baseSym;
    return data;
  }
}
