part of 'holdings_bloc.dart';

abstract class HoldingsEvent {}

class HoldingsFetchEvent extends HoldingsEvent {
  bool isSuggestedStocksEnabled;
  bool isFetchAgain;

  bool isStreaming;
  bool loading;
  HoldingsFetchEvent(this.isSuggestedStocksEnabled,
      {this.isStreaming = true,
      this.isFetchAgain = false,
      this.loading = true});
}

class HoldingsStartSymStreamEvent extends HoldingsEvent {
  int index = 0;
}

class HoldingsStreamingResponseEvent extends HoldingsEvent {
  ResponseData data;
  HoldingsStreamingResponseEvent(this.data);
}

class SuggestedStocksStartSymStreamEvent extends HoldingsEvent {}

class SuggestedStocksStreamingResponseEvent extends HoldingsEvent {
  ResponseData data;
  SuggestedStocksStreamingResponseEvent(this.data);
}

class HoldingsSortSymbolsEvent extends HoldingsEvent {
  SortModel? selectedSort;
  HoldingsSortSymbolsEvent(
    this.selectedSort,
  );
}

class HoldingsFilterSymbolsEvent extends HoldingsEvent {
  List<FilterModel>? selectedFilters;
  HoldingsFilterSymbolsEvent(
    this.selectedFilters,
  );
}

class ClearHoldingsSortSymbolsEvent extends HoldingsEvent {}

class ClearHoldingsFilterEvent extends HoldingsEvent {}

class FetchHoldingsWithFiltersEvent extends HoldingsEvent {
  List<FilterModel>? filterModel;
  SortModel? selectedSort;
  FetchHoldingsWithFiltersEvent(
    this.filterModel,
    this.selectedSort,
  );
}

class HoldingsSearchEvent extends HoldingsEvent {
  final String searchString;
  HoldingsSearchEvent(this.searchString);
}

class HoldingsResetSearchEvent extends HoldingsEvent {}
