part of 'markets_bloc.dart';

abstract class MarketsState extends ScreenState {}

class MarketsInitial extends MarketsState {}

class MarketsFetchItemsProgressState extends MarketsState {}

class MarketsMoversFetchItemsProgressState extends MarketsState {}

class MarketsMoversFOProgressState extends MarketsState {}

class MarketsFetchItemsDoneState extends MarketsState {
  List<NSE>? nSE;
  List<BSE>? bSE;
  List<Symbols>? pullDownMenuSymbols;

  // MarketsFetchItemsDoneState(this.nSE, this.bSE);
}

class MarketsChangeState extends MarketsState {}

class MarketMoverFOLoaderState extends MarketsState {}

class MarketMoverFOState extends MarketsState {
  final String selectedExpiryDate;
  final int selectedToggleIndex;

  MarketMoverFOState(this.selectedExpiryDate, this.selectedToggleIndex);
}

class MarketsPullDownItemsDoneState extends MarketsState {
  List<Symbols>? pullDownMenuSymbols;
  List<Symbols>? pullDownMenuEditSymbols;
  bool isScroll = AppConstants.animateBanner.value;
}

class MarketsPullDownItemsEditListDoneState extends MarketsState {
  List<Symbols>? pullDownMenuEditSymbols;
}

class MarketSymStreamState extends MarketsState {
  final Map<dynamic, dynamic> streamDetails;
  MarketSymStreamState(this.streamDetails);
}

class MarketMoversStartStreamState extends MarketsState {
  Map<dynamic, dynamic> streamDetails;
  MarketMoversStartStreamState(this.streamDetails);
}

class MarketIndicesStartStreamState extends MarketsState {
  Map<dynamic, dynamic> streamDetails;
  MarketIndicesStartStreamState(this.streamDetails);
}

class MarketMoversFOFetchItemsDoneState extends MarketsState {
  MarketMoversModel? marketMoversModel;
}

class MarketMoversFetchItemsDoneState extends MarketsState {
  MarketMoversModel? marketMoversModel;
}

class MarketFIIDIIDoneState extends MarketsState {
  FIIDIIModel? fiidiiModel;
}

class MarketFIIDIIFailedState extends MarketsState {}

class MarketMoversIndicesFetchItemsDoneState extends MarketsState {
  List<Symbols>? symbols;
}

class MarketMoversSortItemsDoneState extends MarketsState {
  List<Symbols>? symbols;
}

class MarketMoversFOExpiryListResponseDoneState extends MarketsState {
  List<String>? results;
}

class MarketMoversFOExpiryListResponseDoneDummyState extends MarketsState {
  List<String>? results;
}

class MarketsFailedState extends MarketsState {}

class MarketsServiceExpectionState extends MarketsState {}
