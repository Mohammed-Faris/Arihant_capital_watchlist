part of 'quote_futures_options_bloc.dart';

abstract class QuoteFuturesOptionsEvent {}

class QuoteToggleFuturesEvent extends QuoteFuturesOptionsEvent {}

class QuoteToggleOptionsEvent extends QuoteFuturesOptionsEvent {}

class QuoteFuturesExpiryEvent extends QuoteFuturesOptionsEvent {
  late FutureExpiryData futureExpiryData;

  QuoteFuturesExpiryEvent(this.futureExpiryData);
}

class QuoteStartFutureStreamEvent extends QuoteFuturesOptionsEvent {
  Symbols symbolItem;
  QuoteStartFutureStreamEvent(this.symbolItem);
}

class QuoteFutureStreamingResponseEvent extends QuoteFuturesOptionsEvent {
  ResponseData data;
  QuoteFutureStreamingResponseEvent(this.data);
}

class QuoteExpiryDataEvent extends QuoteFuturesOptionsEvent {
  late FutureExpiryData futureExpiryData;

  QuoteExpiryDataEvent(this.futureExpiryData);
}

class QuoteOptionsChainEvent extends QuoteFuturesOptionsEvent {
  late QuoteOptionChainData quoteOptionChain;
  bool isOptionChainStreaming;

  QuoteOptionsChainEvent(
    this.quoteOptionChain,
    this.isOptionChainStreaming,
  );
}

class QuoteFuturesFailedState extends QuoteFuturesOptionsEvent {}

class QuoteFuturesErrorState extends QuoteFuturesOptionsEvent {}

class QuoteOptionChainStartSymStreamEvent extends QuoteFuturesOptionsEvent {
  QuoteOptionChainStartSymStreamEvent();
}

class QuoteOptionChainStreamingResponseEvent extends QuoteFuturesOptionsEvent {
  ResponseData data;
  QuoteOptionChainStreamingResponseEvent(this.data);
}

class QuoteOptionChainUpdateFilterListEvent extends QuoteFuturesOptionsEvent {
  List<String>? selectedFilter;
  QuoteOptionChainUpdateFilterListEvent(this.selectedFilter);
}

class QuoteOptionChainGetFilterListEvent extends QuoteFuturesOptionsEvent {}
