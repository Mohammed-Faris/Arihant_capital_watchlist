import '../../common/sym_model.dart';

class FutureExpiryData {
  String? dispSym;
  Sym? sym;
  String? companyName;
  String? baseSym;
  List<Filters>? filters;

  FutureExpiryData(
      {this.dispSym, this.sym, this.companyName, this.baseSym, this.filters});

  FutureExpiryData.fromJson(Map<String, dynamic> json) {
    dispSym = json['dispSym'];
    sym = json['sym'] != null ? Sym.fromJson(json['sym']) : null;
    companyName = json['companyName'];
    baseSym = json['baseSym'];
    if (json['filters'] != null) {
      filters = <Filters>[];
      json['filters'].forEach((v) {
        filters!.add(Filters.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dispSym'] = dispSym;
    if (sym != null) {
      data['sym'] = sym!.toJson();
    }
    data['companyName'] = companyName;
    data['baseSym'] = baseSym;
    if (filters != null) {
      data['filters'] = filters!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Filters {
  String? key;
  String? value;

  Filters({this.key, this.value});

  Filters.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['value'] = value;
    return data;
  }
}
