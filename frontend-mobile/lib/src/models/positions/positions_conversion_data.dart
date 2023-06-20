import '../common/sym_model.dart';
import 'package:msil_library/models/base/base_model.dart';

class PositionsConversionData extends BaseModel {
  String? type;
  String? ordAction;
  String? toPrdType;
  String? prdType;
  String? qty;
  Sym? sym;

  PositionsConversionData(
      {this.type,
      this.ordAction,
      this.toPrdType,
      this.prdType,
      this.qty,
      this.sym});

  PositionsConversionData.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    ordAction = json['ordAction'];
    toPrdType = json['toPrdType'];
    prdType = json['prdType'];
    qty = json['qty'];
    sym = json['sym'] != null ? Sym.fromJson(json['sym']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['ordAction'] = ordAction;
    data['toPrdType'] = toPrdType;
    data['prdType'] = prdType;
    data['qty'] = qty;
    if (sym != null) {
      data['sym'] = sym!.toJson();
    }
    return data;
  }
}
