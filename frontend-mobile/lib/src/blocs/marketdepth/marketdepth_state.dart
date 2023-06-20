part of 'marketdepth_bloc.dart';

abstract class MarketdepthState extends ScreenState {}

class MarketdepthInitial extends MarketdepthState {}

class MarketDepthErrorState extends MarketdepthState {}

class MarketDepthStreamState extends MarketdepthState {
  final Map<dynamic, dynamic> streamDetails;
  MarketDepthStreamState(this.streamDetails);
}

class MktDepthDataState extends MarketdepthState {
  Quote2Data quoteMarketDepthData = AppConfig().marketDepthData;
  String totalBidQtyPercent = '0.0';
  String totalAskQtyPercent = '0.0';
  List<String> bidQtyPercent = AppConfig().totalBuyAskQty;
  List<String> askQtyPercent = AppConfig().totalBuyAskQty;
}

class MktDepthDataChangeState extends MarketdepthState {}
