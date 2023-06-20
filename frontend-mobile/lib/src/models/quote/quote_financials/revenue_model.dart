import 'package:msil_library/models/base/base_model.dart';

class RevenueModel extends BaseModel {
  Values? values;
  List<String>? years;

  RevenueModel({values, years});

  RevenueModel.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    values = data['values'] != null ? Values.fromJson(data['values']) : null;
    years = data['years'].cast<String>();
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
  List<String>? pDBT;
  List<String>? pBT;
  List<String>? adjustedEPS;
  List<String>? ePS;
  List<String>? appropriations;
  List<String>? operatingProfit;
  List<String>? provisionForTax;
  List<String>? netSales;
  List<String>? interest;
  List<String>? adjustmentsToPAT;
  List<String>? profitBalance;
  List<String>? total;
  List<String>? expenditure;
  List<String>? profitBeforeTaxExceptionals;
  List<String>? extraItems;
  List<String>? profitAfterTax;
  List<String>? otherIncome;
  List<String>? depreciation;
  List<String>? exceptionalIncomeExpense;

  Values(
      {this.pDBT,
      this.pBT,
      this.adjustedEPS,
      this.ePS,
      this.appropriations,
      this.operatingProfit,
      this.provisionForTax,
      this.netSales,
      this.interest,
      this.adjustmentsToPAT,
      this.profitBalance,
      this.total,
      this.expenditure,
      this.profitBeforeTaxExceptionals,
      this.extraItems,
      this.profitAfterTax,
      this.otherIncome,
      this.depreciation,
      this.exceptionalIncomeExpense});

  Values.fromJson(Map<String, dynamic> json) {
    pDBT = json['PDBT'].cast<String>();
    pBT = json['PBT'].cast<String>();
    adjustedEPS = json['AdjustedEPS'].cast<String>();
    ePS = json['EPS'].cast<String>();
    appropriations = json['Appropriations'].cast<String>();
    operatingProfit = json['Operating Profit'].cast<String>();
    provisionForTax = json['Provision For Tax'].cast<String>();
    netSales = json['Net Sales'].cast<String>();
    interest = json['interest'].cast<String>();
    adjustmentsToPAT = json['Adjustments to PAT'].cast<String>();
    profitBalance = json['Profit Balance'].cast<String>();
    total = json['Total'].cast<String>();
    expenditure = json['Expenditure'].cast<String>();
    profitBeforeTaxExceptionals =
        json['Profit Before Tax Exceptionals'].cast<String>();
    extraItems = json['Extra Items'].cast<String>();
    profitAfterTax = json['Profit After Tax'].cast<String>();
    otherIncome = json['Other Income'].cast<String>();
    depreciation = json['depreciation'].cast<String>();
    exceptionalIncomeExpense =
        json['Exceptional Income Expense'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['PDBT'] = pDBT;
    data['PBT'] = pBT;
    data['AdjustedEPS'] = adjustedEPS;
    data['EPS'] = ePS;
    data['Appropriations'] = appropriations;
    data['Operating Profit'] = operatingProfit;
    data['Provision For Tax'] = provisionForTax;
    data['Net Sales'] = netSales;
    data['interest'] = interest;
    data['Adjustments to PAT'] = adjustmentsToPAT;
    data['Profit Balance'] = profitBalance;
    data['Total'] = total;
    data['Expenditure'] = expenditure;
    data['Profit Before Tax Exceptionals'] = profitBeforeTaxExceptionals;
    data['Extra Items'] = extraItems;
    data['Profit After Tax'] = profitAfterTax;
    data['Other Income'] = otherIncome;
    data['depreciation'] = depreciation;
    data['Exceptional Income Expense'] = exceptionalIncomeExpense;
    return data;
  }
}
