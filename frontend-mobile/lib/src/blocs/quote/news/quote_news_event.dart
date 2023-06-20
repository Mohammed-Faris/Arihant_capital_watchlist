part of 'quote_news_bloc.dart';

abstract class QuoteNewsEvent {}

class QuoteFetchNewsEvent extends QuoteNewsEvent {
  Sym sym;
  QuoteFetchNewsEvent(this.sym);
}

class QuoteFetchNewsDetailsEvent extends QuoteNewsEvent {
  String serialNumber;
  QuoteFetchNewsDetailsEvent(this.serialNumber);
}
