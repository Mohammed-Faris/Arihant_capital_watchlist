part of 'financials_view_more_bloc.dart';

abstract class FinancialsViewMoreEvent {
  bool consolidated = true;
}

class ViewMoreShareHoldingEvent extends FinancialsViewMoreEvent {
  late QuoteFinancialsShareHoldingsData quoteFinancialsShareHoldingsData;

  ViewMoreShareHoldingEvent(this.quoteFinancialsShareHoldingsData);
}

class ViewMoreIncomeQuarterlyStatementHoldingEvent
    extends FinancialsViewMoreEvent {
  late Sym? sym;
  ViewMoreIncomeQuarterlyStatementHoldingEvent(this.sym);
}

class ViewMoreIncomeYearlyStatementHoldingEvent
    extends FinancialsViewMoreEvent {
  late Sym? sym;
  ViewMoreIncomeYearlyStatementHoldingEvent(this.sym);
}

class QuoteFinancialsFailedState extends FinancialsViewMoreEvent {}

class QuoteFinancialsErrorState extends FinancialsViewMoreEvent {}

class QuoteFinancialsStartSymStreamEvent extends FinancialsViewMoreEvent {
  Symbols symbolItem;
  QuoteFinancialsStartSymStreamEvent(
    this.symbolItem,
  );
}

class QuoteFinancialsStreamingResponseEvent extends FinancialsViewMoreEvent {
  ResponseData data;
  QuoteFinancialsStreamingResponseEvent(this.data);
}
