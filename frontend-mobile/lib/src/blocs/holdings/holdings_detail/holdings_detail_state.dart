part of 'holdings_detail_bloc.dart';

abstract class HoldingsDetailState extends ScreenState {}

class HoldingsDetailInitial extends HoldingsDetailState {}

class HoldingsDetailDataState extends HoldingsDetailState {
  Symbols? symbols;
  QuoteContractInfo? quoteContractInfo;
  QuoteDeliveryData? quoteDeliveryData;
}

class HoldingsDetailMktDepthDataState extends HoldingsDetailState {
  Quote2Data? quoteMarketDepthData;
  String? totalBidQtyPercent;
  String? totalAskQtyPercent;
  List<String> bidQtyPercent = [];
  List<String> askQtyPercent = [];
}

class HoldingsDetailChangeState extends HoldingsDetailState {}

class HoldingsDetailSymStreamState extends HoldingsDetailState {
  final Map<dynamic, dynamic> streamDetails;
  HoldingsDetailSymStreamState(this.streamDetails);
}

class HoldingsDetailQuoteTwoStreamState extends HoldingsDetailState {
  final Map<dynamic, dynamic> streamDetails;
  HoldingsDetailQuoteTwoStreamState(this.streamDetails);
}

class HoldingsDetailPerformanceProgressState extends HoldingsDetailState {}

class HoldingsDetailErrorState extends HoldingsDetailState {}
