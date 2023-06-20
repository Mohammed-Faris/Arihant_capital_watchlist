part of 'market_status_bloc.dart';

abstract class MarketStatusEvent {}

class GetMarketStatusEvent extends MarketStatusEvent {
  Sym? sym;
  GetMarketStatusEvent(this.sym);
}
