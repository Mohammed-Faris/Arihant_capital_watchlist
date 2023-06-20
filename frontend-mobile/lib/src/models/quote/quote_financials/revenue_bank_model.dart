import 'package:msil_library/models/base/base_model.dart';

class Data extends BaseModel {
  Values? values;
  List<String>? years;

  Data({this.values, this.years});

  Data.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    values = json['values'] != null ? Values.fromJson(json['values']) : null;
    years = json['years'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (values != null) {
      data['values'] = values!.toJson();
    }
    data['years'] = years;
    return data;
  }
}

class Values {
  List<String>? administrativeExpensesExpenditure;
  List<String>? profitLossOfAssociateCompanyExpenditure;
  List<String>? netProfitAfterMinorityIntExpenditure;
  List<String>? netProfitExpenditure;
  List<String>? fringeBenefitTaxExpenditure;
  List<String>? provisionsForEmployeesExpenditure;
  List<String>? deferredTaxExpenditure;
  List<String>? ePSAfterMinorityIntExpenditure;
  List<String>? minorityIntTaxExpenditure;
  List<String>? interestEarned;
  List<String>? expenditure;
  List<String>? provisionForTaxExpenditure;
  List<String>? totalIncome;
  List<String>? provisionsContingenciesExpenditure;
  List<String>? depreciationExpenditure;
  List<String>? otherIncome;
  List<String>? interestexpendedExpenditure;

  Values(
      {this.administrativeExpensesExpenditure,
      this.profitLossOfAssociateCompanyExpenditure,
      this.netProfitAfterMinorityIntExpenditure,
      this.netProfitExpenditure,
      this.fringeBenefitTaxExpenditure,
      this.provisionsForEmployeesExpenditure,
      this.deferredTaxExpenditure,
      this.ePSAfterMinorityIntExpenditure,
      this.minorityIntTaxExpenditure,
      this.interestEarned,
      this.expenditure,
      this.provisionForTaxExpenditure,
      this.totalIncome,
      this.provisionsContingenciesExpenditure,
      this.depreciationExpenditure,
      this.otherIncome,
      this.interestexpendedExpenditure});

  Values.fromJson(Map<String, dynamic> json) {
    administrativeExpensesExpenditure =
        json['Administrative Expenses Expenditure'].cast<String>();
    profitLossOfAssociateCompanyExpenditure =
        json['Profit Loss of Associate Company Expenditure'].cast<String>();
    netProfitAfterMinorityIntExpenditure =
        json['NetProfit after Minority Int. Expenditure'].cast<String>();
    netProfitExpenditure = json['NetProfit Expenditure'].cast<String>();
    fringeBenefitTaxExpenditure =
        json['Fringe Benefit tax Expenditure'].cast<String>();
    provisionsForEmployeesExpenditure =
        json['Provisions for Employees Expenditure'].cast<String>();
    deferredTaxExpenditure = json['Deferred Tax Expenditure'].cast<String>();
    ePSAfterMinorityIntExpenditure =
        json['EPS after Minority Int. Expenditure'].cast<String>();
    minorityIntTaxExpenditure =
        json['Minority Int. tax Expenditure'].cast<String>();
    interestEarned = json['Interest Earned'].cast<String>();
    expenditure = json['Expenditure'].cast<String>();
    provisionForTaxExpenditure =
        json['Provision for Tax Expenditure'].cast<String>();
    totalIncome = json['Total Income'].cast<String>();
    provisionsContingenciesExpenditure =
        json['Provisions Contingencies Expenditure'].cast<String>();
    depreciationExpenditure = json['Depreciation Expenditure'].cast<String>();
    otherIncome = json['Other Income'].cast<String>();
    interestexpendedExpenditure =
        json['Interestexpended Expenditure'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Administrative Expenses Expenditure'] =
        administrativeExpensesExpenditure;
    data['Profit Loss of Associate Company Expenditure'] =
        profitLossOfAssociateCompanyExpenditure;
    data['NetProfit after Minority Int. Expenditure'] =
        netProfitAfterMinorityIntExpenditure;
    data['NetProfit Expenditure'] = netProfitExpenditure;
    data['Fringe Benefit tax Expenditure'] = fringeBenefitTaxExpenditure;
    data['Provisions for Employees Expenditure'] =
        provisionsForEmployeesExpenditure;
    data['Deferred Tax Expenditure'] = deferredTaxExpenditure;
    data['EPS after Minority Int. Expenditure'] =
        ePSAfterMinorityIntExpenditure;
    data['Minority Int. tax Expenditure'] = minorityIntTaxExpenditure;
    data['Interest Earned'] = interestEarned;
    data['Expenditure'] = expenditure;
    data['Provision for Tax Expenditure'] = provisionForTaxExpenditure;
    data['Total Income'] = totalIncome;
    data['Provisions Contingencies Expenditure'] =
        provisionsContingenciesExpenditure;
    data['Depreciation Expenditure'] = depreciationExpenditure;
    data['Other Income'] = otherIncome;
    data['Interestexpended Expenditure'] = interestexpendedExpenditure;
    return data;
  }
}
