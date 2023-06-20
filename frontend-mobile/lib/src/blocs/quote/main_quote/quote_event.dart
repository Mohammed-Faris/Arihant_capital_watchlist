part of 'quote_bloc.dart';

abstract class QuoteEvent {}

class QuoteStartSymStreamEvent extends QuoteEvent {
  Symbols symbolItem;
  QuoteStartSymStreamEvent(this.symbolItem);
}

class QuoteStreamingResponseEvent extends QuoteEvent {
  ResponseData data;
  QuoteStreamingResponseEvent(this.data);
}

class QuoteAddSymbolEvent extends QuoteEvent {
  String groupname;
  Symbols symbolItem;
  bool isNewWatchlist;
  QuoteAddSymbolEvent(
    this.groupname,
    this.symbolItem,
    this.isNewWatchlist,
  );
}

class QuotedeleteSymbolEvent extends QuoteEvent {
  String groupname;
  Symbols symbolItem;
  QuotedeleteSymbolEvent(this.groupname, this.symbolItem);
}

class QuoteExcChangeEvent extends QuoteEvent {
  String exchange;
  QuoteExcChangeEvent(this.exchange);
}

class QuoteGetSectorEvent extends QuoteEvent {
  Sym sym;
  QuoteGetSectorEvent(this.sym);
}
