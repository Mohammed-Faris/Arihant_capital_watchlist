part of 'quote_overview_bloc.dart';

abstract class QuoteOverviewEvent {
  bool consolidated = false;
}

class QuoteOverviewStartSymStreamEvent extends QuoteOverviewEvent {
  Symbols symbolItem;
  bool isHoldingsAvailable;
  QuoteOverviewStartSymStreamEvent(
    this.symbolItem,
    this.isHoldingsAvailable,
  );
}

class QuoteOverviewStreamingResponseEvent extends QuoteOverviewEvent {
  ResponseData data;
  QuoteOverviewStreamingResponseEvent(this.data);
}

class QuoteOverviewGetCompanyDetailsEvent extends QuoteOverviewEvent {
  Sym sym;
  QuoteOverviewGetCompanyDetailsEvent(this.sym);
}

class QuoteGetPerformanceDeliveryDataEvent extends QuoteOverviewEvent {
  Sym sym;
  QuoteGetPerformanceDeliveryDataEvent(this.sym);
}

class QuoteGetPerformanceContractInfoEvent extends QuoteOverviewEvent {
  Sym sym;
  QuoteGetPerformanceContractInfoEvent(this.sym);
}

class QuoteGetFundamentalsKeyStatsEvent extends QuoteOverviewEvent {
  Sym sym;
  QuoteGetFundamentalsKeyStatsEvent(this.sym);
}

class QuoteGetFundamentalsFinancialRatiosEvent extends QuoteOverviewEvent {
  Sym sym;
  QuoteGetFundamentalsFinancialRatiosEvent(this.sym);
}

class QuoteFetchPeerRatiosEvent extends QuoteOverviewEvent {
  Sym sym;
  bool isLoaderNeeded;
  QuoteFetchPeerRatiosEvent(this.sym, this.isLoaderNeeded);
}
