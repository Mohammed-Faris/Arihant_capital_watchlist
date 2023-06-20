part of 'marketdepth_bloc.dart';

abstract class MarketdepthEvent {}

class MarketdepthEventStreamEvent extends MarketdepthEvent {
  final Symbols symbolItem;
  MarketdepthEventStreamEvent(this.symbolItem);
}

class MarketdepthStreamResponseEvent extends MarketdepthEvent {
  final Quote2Data quoteDepthData;
  MarketdepthStreamResponseEvent(this.quoteDepthData);
}
