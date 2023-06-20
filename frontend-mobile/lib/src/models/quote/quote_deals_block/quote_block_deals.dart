import '../../common/sym_model.dart';

class BlockDeals {
  Sym? sym;

  BlockDeals({this.sym});

  BlockDeals.fromJson(Map<String, dynamic> json) {
    sym = json['sym'] != null ? Sym.fromJson(json['sym']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (sym != null) {
      data['sym'] = sym!.toJson();
    }
    return data;
  }
}
