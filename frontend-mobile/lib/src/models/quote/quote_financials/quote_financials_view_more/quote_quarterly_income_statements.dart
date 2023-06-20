import 'package:msil_library/models/base/base_model.dart';

class QuarterlyIncomeStatement extends BaseModel {
  List<Financials>? financials;

  QuarterlyIncomeStatement({this.financials});

  QuarterlyIncomeStatement.fromJson(Map<String, dynamic> json)
      : super.fromJSON(json) {
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
  String? rOA;
  String? eps;
  String? rOE;
  String? revnuFrmOprns;
  String? yrc;
  String? expnditure;
  String? debtEqty;
  String? ttlIncome;
  String? pe;
  String? prcBookVal;
  String? netproftLoss;
  String? eDIDTA;
  String? prftBfrTax;
  String? othrInc;

  Financials(
      {this.bookValue,
      this.rOA,
      this.eps,
      this.rOE,
      this.revnuFrmOprns,
      this.yrc,
      this.expnditure,
      this.debtEqty,
      this.ttlIncome,
      this.pe,
      this.prcBookVal,
      this.netproftLoss,
      this.eDIDTA,
      this.prftBfrTax,
      this.othrInc});

  Financials.fromJson(Map<String, dynamic> json) {
    bookValue = json['bookValue'];
    rOA = json['ROA'];
    eps = json['eps'];
    rOE = json['ROE'];
    revnuFrmOprns = json['revnuFrmOprns'];
    yrc = json['yrc'];
    expnditure = json['expnditure'];
    debtEqty = json['debtEqty'];
    ttlIncome = json['ttlIncome'];
    pe = json['pe'];
    prcBookVal = json['prcBookVal'];
    netproftLoss = json['netproftLoss'];
    eDIDTA = json['EDIDTA'];
    prftBfrTax = json['prftBfrTax'];
    othrInc = json['othrInc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bookValue'] = bookValue;
    data['ROA'] = rOA;
    data['eps'] = eps;
    data['ROE'] = rOE;
    data['revnuFrmOprns'] = revnuFrmOprns;
    data['yrc'] = yrc;
    data['expnditure'] = expnditure;
    data['debtEqty'] = debtEqty;
    data['ttlIncome'] = ttlIncome;
    data['pe'] = pe;
    data['prcBookVal'] = prcBookVal;
    data['netproftLoss'] = netproftLoss;
    data['EDIDTA'] = eDIDTA;
    data['prftBfrTax'] = prftBfrTax;
    data['othrInc'] = othrInc;
    return data;
  }
}
