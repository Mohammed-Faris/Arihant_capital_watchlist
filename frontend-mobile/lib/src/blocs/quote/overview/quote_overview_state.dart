part of 'quote_overview_bloc.dart';

abstract class QuoteOverviewState extends ScreenState {
  QuoteKeyStats? quoteKeyStats;
  QuoteFinancialsRatios? quoteFinancialsRatios;
}

class QuoteOverviewInitial extends QuoteOverviewState {}

class QuoteOverviewDataState extends QuoteOverviewState {
  Symbols? symbols;
  QuoteContractInfo? quoteContractInfo;
  QuoteDeliveryData? quoteDeliveryData;
}

class QuoteOverviewFailedState extends QuoteOverviewState {}

class QuoteOverviewServiceExceptionState extends QuoteOverviewState {}

class QuoteOverviewChangeState extends QuoteOverviewState {}

class QuoteOverviewSymStreamState extends QuoteOverviewState {
  final Map<dynamic, dynamic> streamDetails;
  QuoteOverviewSymStreamState(this.streamDetails);
}

class QuoteOverviewErrorState extends QuoteOverviewState {}

class QuoteOverviewGetCompanyDataState extends QuoteOverviewState {
  QuoteCompanyModel? quoteCompanyModel;
}

class QuoteOverviewGetCompanyFailedState extends QuoteOverviewState {}

class QuoteOverviewGetCompanyServiceExceptionState extends QuoteOverviewState {}

class QuotePerformanceProgressState extends QuoteOverviewState {}

class QuoteFundamentalsDoneState extends QuoteOverviewState {}

class QuoteSimilarStockDoneState extends QuoteOverviewState {
  QuotePeerModel? quotePeerModel;
}

class QuotePeerRatiosFailedState extends QuoteOverviewState {}

class QuotePeerRatiosServiceExceptionState extends QuoteOverviewState {}
