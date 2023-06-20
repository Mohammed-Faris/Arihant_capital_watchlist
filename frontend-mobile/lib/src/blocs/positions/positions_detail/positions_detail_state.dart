part of 'positions_detail_bloc.dart';

abstract class PositionsDetailState extends ScreenState {}

class PositionsDetailInitial extends PositionsDetailState {}

class PositionsDetailProgressState extends PositionsDetailState {}

class PositionsDetailDataState extends PositionsDetailState {
  Positions? positions;
  QuoteContractInfo? quoteContractInfo;
  QuoteDeliveryData? quoteDeliveryData;
}

class PositionsDetailMktDepthDataState extends PositionsDetailState {
  Quote2Data? quoteMarketDepthData;
  String? totalBidQtyPercent;
  String? totalAskQtyPercent;
  List<String> bidQtyPercent = [];
  List<String> askQtyPercent = [];
}

class PositionsDetailChangeState extends PositionsDetailState {}

class PositionsDetailSymStreamState extends PositionsDetailState {
  final Map<dynamic, dynamic> streamDetails;
  PositionsDetailSymStreamState(this.streamDetails);
}

class PositionsDetailQuoteTwoStreamState extends PositionsDetailState {
  final Map<dynamic, dynamic> streamDetails;
  PositionsDetailQuoteTwoStreamState(this.streamDetails);
}

class PositionsDetailPerformanceProgressState extends PositionsDetailState {}

class PositionsDetailFailedState extends PositionsDetailState {}

class PositionsDetailErrorState extends PositionsDetailState {}
