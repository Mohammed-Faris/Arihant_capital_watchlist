part of 'indices_bloc.dart';

abstract class IndicesEvent {}

class IndexConstituentsSymbolsEvent extends IndicesEvent {
  String indexName;
  String dispSym;

  SortModel? sortModel;
  List<FilterModel>? filtermodel;
  String? baseSym;
  bool fromConstituents;

  IndexConstituentsSymbolsEvent(this.indexName, this.dispSym,
      {this.baseSym,
      this.sortModel,
      this.filtermodel,
      this.fromConstituents = false});
}

class IndexConstituentsStartSymStreamEvent extends IndicesEvent {}

class IndexConstituentsStreamingResponseEvent extends IndicesEvent {
  ResponseData data;
  IndexConstituentsStreamingResponseEvent(this.data);
}

class IndexConstituentsSortSymbolsEvent extends IndicesEvent {
  String selectedPredefinedWatchllist;
  List<FilterModel>? filterModel;
  SortModel? selectedSort;
  bool fromConstituents;

  IndexConstituentsSortSymbolsEvent(
      this.selectedPredefinedWatchllist, this.filterModel, this.selectedSort,
      {this.fromConstituents = false});
}

class ClearPredefinedWatchlistSortSymbolsEvent extends IndicesEvent {
  String selectedPredefinedWatchllist;
  ClearPredefinedWatchlistSortSymbolsEvent(this.selectedPredefinedWatchllist);
}

class ClearPredefinedWatchlistFilterSymbolsEvent extends IndicesEvent {
  String selectedPredefinedWatchllist;
  ClearPredefinedWatchlistFilterSymbolsEvent(this.selectedPredefinedWatchllist);
}
