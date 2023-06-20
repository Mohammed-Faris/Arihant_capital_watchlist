import '../../common/sym_model.dart';

class FinancialsData {
  FinancialsData({
    this.sym,
  });

  FinancialsData.fromJson(dynamic json) {
    sym = json['sym'] != null ? Sym.fromJson(json['sym']) : null;
  }
  Sym? sym;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (sym != null) {
      map['sym'] = sym?.toJson();
    }
    return map;
  }
}
