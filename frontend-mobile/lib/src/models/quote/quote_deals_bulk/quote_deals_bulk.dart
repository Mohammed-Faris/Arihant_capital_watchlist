import '../../common/sym_model.dart';

class BulkDeals {
  String? dispSym;
  Sym? sym;

  BulkDeals({this.dispSym, this.sym});

  BulkDeals.fromJson(Map<String, dynamic> json) {
    dispSym = json['dispSym'];
    sym = json['sym'] != null ? Sym.fromJson(json['sym']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dispSym'] = dispSym;
    if (sym != null) {
      data['sym'] = sym!.toJson();
    }
    return data;
  }
}
