part of 'quote_futures_options_bloc.dart';

abstract class QuoteFuturesOptionsState extends ScreenState {}

class QuoteFuturesOptionsInitial extends QuoteFuturesOptionsState {}

class QuoteFuturesOptionsProgressState extends QuoteFuturesOptionsState {}

class QuoteToggleFuturesState extends QuoteFuturesOptionsState {
  late bool quoteFuturesBloc;
}

class QuoteFutureStreamState extends QuoteFuturesOptionsState {
  final Map<dynamic, dynamic> streamDetails;
  QuoteFutureStreamState(this.streamDetails);
}

class QuoteToggleOptionsState extends QuoteFuturesOptionsState {
  late bool quoteOptionsBloc;
}

class QuoteFuturesDoneState extends QuoteFuturesOptionsState {
  // late final Map<dynamic, dynamic> quoteFuturesModel;
  QuoteFuturesModel? quoteFuturesModel;
}

class QuoteExpiryDoneState extends QuoteFuturesOptionsState {
  QuoteExpiry? quoteExpiry;
}

class QuoteOptionsDoneState extends QuoteFuturesOptionsState {
  OptionQuoteModel? optionQuoteModel;

  QuoteOptionsDoneState();
}

class QuoteFutureExcChangeState extends QuoteFuturesOptionsState {
  Symbols symbolItem;
  QuoteFutureExcChangeState(this.symbolItem);
}

class QuoteOptionExcChangeState extends QuoteFuturesOptionsState {
  Symbols symbolItem;
  QuoteOptionExcChangeState(this.symbolItem);
}

class QuoteOptionsChangeState extends QuoteFuturesOptionsState {}

class QuoteFuturesOptionsFailedState extends QuoteFuturesOptionsState {}

class QuoteFuturesOptionsErrorState extends QuoteFuturesOptionsState {}

class QuoteOptionChainSymStreamState extends QuoteFuturesOptionsState {
  final Map<dynamic, dynamic> streamDetails;
  QuoteOptionChainSymStreamState(this.streamDetails);
}

class QuoteOptionChainProgressState extends QuoteFuturesOptionsState {}

class QuoteOptionChainFilterDoneState extends QuoteFuturesOptionsState {
  List<String> selectedFilterList = <String>[];
}

class QuoteFuturesOptionsServiceException extends QuoteFuturesOptionsState {}
