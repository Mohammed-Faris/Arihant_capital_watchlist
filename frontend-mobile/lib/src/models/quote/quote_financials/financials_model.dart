import 'package:msil_library/models/base/base_model.dart';

class FinancialsModel extends BaseModel {
  List<Financials>? financials;

  FinancialsModel({this.financials});

  FinancialsModel.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    if (data['financials'] != null) {
      financials = <Financials>[];
      data['financials'].forEach((v) {
        financials!.add(Financials.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (financials != null) {
      data['financials'] = financials!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Financials {
  String? bookValue;
  String? pe;
  String? prcBookVal;
  String? rOA;
  String? netproftLoss;
  String? eDIDTA;
  String? eps;
  String? rOE;
  String? yrc;
  String? debtEqty;
  String? ttlIncome;

  Financials(
      {this.bookValue,
      this.pe,
      this.prcBookVal,
      this.rOA,
      this.netproftLoss,
      this.eDIDTA,
      this.eps,
      this.rOE,
      this.yrc,
      this.debtEqty,
      this.ttlIncome});

  Financials.fromJson(Map<String, dynamic> json) {
    bookValue = json['bookValue'];
    pe = json['pe'];
    prcBookVal = json['prcBookVal'];
    rOA = json['ROA'];
    netproftLoss = json['netproftLoss'];
    eDIDTA = json['EDIDTA'];
    eps = json['eps'];
    rOE = json['ROE'];
    yrc = json['yrc'];
    debtEqty = json['debtEqty'];
    ttlIncome = json['ttlIncome'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bookValue'] = bookValue;
    data['pe'] = pe;
    data['prcBookVal'] = prcBookVal;
    data['ROA'] = rOA;
    data['netproftLoss'] = netproftLoss;
    data['EDIDTA'] = eDIDTA;
    data['eps'] = eps;
    data['ROE'] = rOE;
    data['yrc'] = yrc;
    data['debtEqty'] = debtEqty;
    data['ttlIncome'] = ttlIncome;
    return data;
  }
}
