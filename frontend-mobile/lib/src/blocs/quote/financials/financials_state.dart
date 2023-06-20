part of 'financials_bloc.dart';

abstract class QuoteFinancialsState extends ScreenState {}

class FinancialsInitial extends QuoteFinancialsState {}

class FinancialsProgressState extends QuoteFinancialsState {}

class FinancialsRevenueToggleState extends QuoteFinancialsState {
  late bool financialsRevenue;
}

class FinancialsProfitToggleState extends QuoteFinancialsState {
  late bool financialsProfit;
}

class FinancialsNetWorthToggleState extends QuoteFinancialsState {
  late bool financialsNetWorth;
}

class FinancialsRevenueDoneState extends QuoteFinancialsState {
  late FinancialsModel financialsModel;
  late double positivePeak;
  late double negativePeak;
}

class FinancialsProfitDoneState extends QuoteFinancialsState {
  late FinancialsModel financialsModel;
  late double positivePeak;
  late double negativePeak;
}

class FinancialsYearlyRevenueDoneState extends QuoteFinancialsState {
  late FinancialsYearly financialsYearly;
  late double positivePeak;
  late double negativePeak;
}

class FinancialsYearlyProfitDoneState extends QuoteFinancialsState {
  late FinancialsYearly financialsYearly;
  late double positivePeak;
  late double negativePeak;
}

class FinancialsFailedState extends QuoteFinancialsState {}

class FinancialsServiceExceptionState extends QuoteFinancialsState {}

class FinancialsErrorState extends QuoteFinancialsState {}
