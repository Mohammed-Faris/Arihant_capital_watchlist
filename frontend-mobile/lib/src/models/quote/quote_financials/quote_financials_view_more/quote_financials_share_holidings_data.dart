import '../../../common/sym_model.dart';

class QuoteFinancialsShareHoldingsData {
  Sym? sym;
  String? type;

  QuoteFinancialsShareHoldingsData({this.sym, this.type});

  QuoteFinancialsShareHoldingsData.fromJson(Map<String, dynamic> json) {
    sym = json['sym'] != null ? Sym.fromJson(json['sym']) : null;
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (sym != null) {
      data['sym'] = sym!.toJson();
    }
    data['type'] = type;
    return data;
  }
}
