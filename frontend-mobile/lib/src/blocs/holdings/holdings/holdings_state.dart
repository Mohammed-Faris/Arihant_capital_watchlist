part of 'holdings_bloc.dart';

abstract class HoldingsState extends ScreenState {}

class HoldingsInitState extends HoldingsState {}

class HoldingsProgressState extends HoldingsState {}

class HoldingsChangeState extends HoldingsState {}

class HoldingsErrorState extends HoldingsState {}

class HoldingsServiceExpectionState extends HoldingsState {}

class HoldingsFailedState extends HoldingsState {}

class HoldingsFetchDoneState extends HoldingsState {
  HoldingsModel? holdingsModel;
  List<Symbols>? mainHoldingsSymbols;
  List<Symbols>? searchHoldingsSymbols;
  List<Symbols>? secondaryWatchlistSymbols;
  SortModel? selectedSortBy;
  List<FilterModel>? selectedFilter;
  bool isSortSelected = false;
  bool isFilterSelected = false;

  int visbleTop = 0;
  int visibleBottom = 0;
  HoldingsFetchDoneState();
}

class SuggestedStocksState extends HoldingsState {
  late List<Symbols> suggestedStocks;
  SuggestedStocksState();
}

class SuggestedStocksStartStreamState extends HoldingsState {
  Map<dynamic, dynamic> streamDetails;
  SuggestedStocksStartStreamState(this.streamDetails);
}

class HoldingsStartStreamState extends HoldingsState {
  Map<dynamic, dynamic> streamDetails;
  HoldingsStartStreamState(this.streamDetails);
}
