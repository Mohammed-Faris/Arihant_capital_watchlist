import '../../common/sym_model.dart';

class QuoteOptionChainData {
  String? dispSym;
  Sym? sym;
  String? baseSym;
  String? expiry;

  QuoteOptionChainData({this.dispSym, this.sym, this.baseSym, this.expiry});

  QuoteOptionChainData.fromJson(Map<String, dynamic> json) {
    dispSym = json['dispSym'];
    sym = json['sym'] != null ? Sym.fromJson(json['sym']) : null;
    baseSym = json['baseSym'];
    expiry = json['expiry'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dispSym'] = dispSym;
    if (sym != null) {
      data['sym'] = sym!.toJson();
    }
    data['baseSym'] = baseSym;
    data['expiry'] = expiry;
    return data;
  }
}
