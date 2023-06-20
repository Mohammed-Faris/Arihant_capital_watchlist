part of 'markets_bloc.dart';

abstract class MarketsEvent {}

class FetchMarketIndicesItemsEvent extends MarketsEvent {
  final bool getNseItems;
  final bool getBseItems;
  final bool getCashSegmentItems;
  final bool getFOSegmentItems;
  final bool getPullDownMenuItems;
  final bool getPullDownMenuEditItems;
  FetchMarketIndicesItemsEvent(
      {this.getNseItems = false,
      this.getBseItems = false,
      this.getCashSegmentItems = false,
      this.getFOSegmentItems = false,
      this.getPullDownMenuItems = false,
      this.getPullDownMenuEditItems = false});
}

class MarketIndicesStartSymStreamEvent extends MarketsEvent {
  final List<Sym> symList;
  // Symbols symbolItem;
  MarketIndicesStartSymStreamEvent(this.symList);
}

class MarketsIndexConstituentsSymbolsEvent extends MarketsEvent {
  String indexName;

  MarketsIndexConstituentsSymbolsEvent(this.indexName);
}

class MarketFoScreenUpdate extends MarketsEvent {
  final String selectedExpiryDate;
  final int selectedToggleIndex;

  MarketFoScreenUpdate(this.selectedExpiryDate, this.selectedToggleIndex);
}

class MarketMoversStartSymStreamForIndicesEvent extends MarketsEvent {
  String selectedSegment;
  MarketMoversStartSymStreamForIndicesEvent(this.selectedSegment);
}

class MarketIndicesStreamingResponseEvent extends MarketsEvent {
  ResponseData data;
  MarketIndicesStreamingResponseEvent(this.data);
}

class MarketIndicesAnimate extends MarketsEvent {
  bool animate;
  MarketIndicesAnimate(this.animate);
}

class MarketIndicesStreamingPullDownMenuResponseEvent extends MarketsEvent {
  ResponseData data;
  MarketIndicesStreamingPullDownMenuResponseEvent(this.data);
}

class MarketMoversFOStreamingResponseEvent extends MarketsEvent {
  ResponseData data;
  MarketMoversFOStreamingResponseEvent(this.data);
}

class MarketMoversStreamingResponseEvent extends MarketsEvent {
  ResponseData data;
  MarketMoversStreamingResponseEvent(this.data);
}

class MarketMoversFOSendExpiryRequestEvent extends MarketsEvent {
  String? exc;
  String? segment;
  MarketMoversFOSendExpiryRequestEvent({this.exc, this.segment});
}

class MarketsFFIDIIFetch extends MarketsEvent {
  String type = "D";
  String category = "fiiCash";
}

class MarketMoversFetchTopGainersLosersFetchEvent extends MarketsEvent {
  String? exchange;
  bool? fetchAllDetails;
  String? indexName;
  int? limit;
  String? sortBy;
  MarketMoversFetchTopGainersLosersFetchEvent(
      {this.exchange,
      this.indexName,
      this.limit,
      this.sortBy,
      this.fetchAllDetails = false});
}

class MarketMoversFetchFOTopGainersLosersFetchEvent extends MarketsEvent {
  bool? fetchAllDetails;
  String? asset;
  String? segment;
  String? expiry;
  int? limit;
  String? sortBy;
  MarketMoversFetchFOTopGainersLosersFetchEvent(
      {this.asset,
      this.segment,
      this.expiry,
      this.limit,
      this.sortBy,
      this.fetchAllDetails = false});
}

class MarketsFilterSortSymbolEvent extends MarketsEvent {
  SortModel? selectedSort;
  List<Symbols> symbols;
  bool isFNOSort;
  bool isNiftySort;

  MarketsFilterSortSymbolEvent(
      this.selectedSort, this.symbols, this.isFNOSort, this.isNiftySort);
}
