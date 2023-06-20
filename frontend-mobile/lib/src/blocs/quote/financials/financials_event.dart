part of 'financials_bloc.dart';

abstract class QuoteFinancialsEvent {
  bool consolidated = true;
}

class QuoteToggleRevenueEvent extends QuoteFinancialsEvent {}

class QuoteToggleProfitEvent extends QuoteFinancialsEvent {}

class QuoteToggleNetWorthEvent extends QuoteFinancialsEvent {}

class QuoteFinancialsRevenueEvent extends QuoteFinancialsEvent {
  late FinancialsData financialsData;
  late bool quarterly;

  QuoteFinancialsRevenueEvent(
    this.financialsData,
    this.quarterly,
  );
}

class QuoteFinancialsProfitEvent extends QuoteFinancialsEvent {
  late FinancialsData financialsData;
  late bool quarterly;
  QuoteFinancialsProfitEvent(this.financialsData, this.quarterly);
}

class QuoteFinancialsNetWorthEvent extends QuoteFinancialsEvent {
  late FinancialsData financialsData;

  QuoteFinancialsNetWorthEvent(this.financialsData);
}

class QuoteRevenueYearlyEvent extends QuoteFinancialsEvent {
  late Sym? sym;
  QuoteRevenueYearlyEvent(this.sym);
}

class QuoteProfitYearlyEvent extends QuoteFinancialsEvent {
  late Sym? sym;
  QuoteProfitYearlyEvent(this.sym);
}

class QuoteFinancialsFailedEvent extends QuoteFinancialsEvent {}

class QuoteFinancialsErrorEvent extends QuoteFinancialsEvent {}
