import 'package:msil_library/models/base/base_model.dart';

class QuoteFinancialsRatios extends BaseModel {
  String? evToEbitda;
  String? netProfitMargin;
  String? operatingMargin;
  String? pegRatio;
  String? roa;
  String? fixedTurnover;
  String? roe;
  String? debtEqty;
  String? netSalesGrowth;
  String? interestCover;
  String? evToEbit;
  String? evToSales;

  QuoteFinancialsRatios(
      {this.evToEbitda,
      this.netProfitMargin,
      this.operatingMargin,
      this.pegRatio,
      this.roa,
      this.fixedTurnover,
      this.roe,
      this.debtEqty,
      this.netSalesGrowth,
      this.interestCover,
      this.evToEbit,
      this.evToSales});

  QuoteFinancialsRatios.fromJson(Map<String, dynamic> json)
      : super.fromJSON(json) {
    evToEbitda = data['evToEbitda'];
    netProfitMargin = data['netProfitMargin'];
    operatingMargin = data['operatingMargin'];
    pegRatio = data['pegRatio'];
    roa = data['roa'];
    fixedTurnover = data['fixedTurnover'];
    roe = data['roe'];
    debtEqty = data['debtEqty'];
    netSalesGrowth = data['netSalesGrowth'];
    interestCover = data['interestCover'];
    evToEbit = data['evToEbit'];
    evToSales = data['evToSales'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['evToEbitda'] = evToEbitda;
    data['netProfitMargin'] = netProfitMargin;
    data['operatingMargin'] = operatingMargin;
    data['pegRatio'] = pegRatio;
    data['roa'] = roa;
    data['fixedTurnover'] = fixedTurnover;
    data['roe'] = roe;
    data['debtEqty'] = debtEqty;
    data['netSalesGrowth'] = netSalesGrowth;
    data['interestCover'] = interestCover;
    data['evToEbit'] = evToEbit;
    data['evToSales'] = evToSales;
    return data;
  }
}
