part of 'quote_peer_bloc.dart';

abstract class QuotePeerEvent {}

class QuoteFetchPeerRatiosEvent extends QuotePeerEvent {
  Sym sym;
  bool isLoaderNeeded;
  QuoteFetchPeerRatiosEvent(this.sym, this.isLoaderNeeded);
}

class QuotePeerStartSymStreamEvent extends QuotePeerEvent {
  QuotePeerStartSymStreamEvent();
}

class QuotePeerStreamingResponseEvent extends QuotePeerEvent {
  ResponseData data;
  QuotePeerStreamingResponseEvent(this.data);
}

class QuotePeerSortSymbolsEvent extends QuotePeerEvent {
  String selectedSort;
  QuotePeerSortSymbolsEvent(
    this.selectedSort,
  );
}
