part of 'watchlist_bloc.dart';

abstract class WatchlistEvent {}

class GetCorpSymListEvent extends WatchlistEvent {
  GetCorpSymListEvent();
}

class WatchlistGetGroupsEvent extends WatchlistEvent {
  bool requestAllSymbols;
  WatchlistGetGroupsEvent(this.requestAllSymbols);
}

class WatchlistGetSymbolsForAllWatchlistEvent extends WatchlistEvent {}

class WatchlistGetSymbolsEvent extends WatchlistEvent {
  Groups group;
  bool isStreamEnabled;
  bool fetchApi;
  bool isFromWatchlist;
  WatchlistGetSymbolsEvent(
    this.group,
    this.isStreamEnabled,
    this.isFromWatchlist, {
    this.fetchApi = false,
  });
}

class WatchlistStartSymStreamEvent extends WatchlistEvent {}

class WatchlistStreamingResponseEvent extends WatchlistEvent {
  ResponseData data;
  WatchlistStreamingResponseEvent(this.data);
}

class WatchlistDeleteGroupEvent extends WatchlistEvent {
  Groups group;
  WatchlistDeleteGroupEvent(this.group);
}

class SelectedWatchlistAndTabEvent extends WatchlistEvent {
  String selectedWatchlist;
  String selectedTab;
  SelectedWatchlistAndTabEvent(
    this.selectedWatchlist,
    this.selectedTab,
  );
}

class WatchlistReorderEvent extends WatchlistEvent {
  Groups selectedGroup;
  int oldPosition;
  int newPosition;
  WatchlistReorderEvent(
    this.selectedGroup,
    this.oldPosition,
    this.newPosition,
  );
}

class WatchlistDeleteSymbolEvent extends WatchlistEvent {
  int indexToDelete;
  Groups selectedGroup;
  WatchlistDeleteSymbolEvent(
    this.indexToDelete,
    this.selectedGroup,
  );
}

class WatchlistRenameGroupEvent extends WatchlistEvent {
  String wId;
  String wName;
  String oldWName;
  WatchlistRenameGroupEvent(
    this.wId,
    this.wName,
    this.oldWName,
  );
}

class WatchlistSetMyHoldingsSymbolsEvent extends WatchlistEvent {
  List<Symbols> myHoldingsSymbols;
  WatchlistSetMyHoldingsSymbolsEvent(this.myHoldingsSymbols);
}

class WatchlistFilterSortSymbolEvent extends WatchlistEvent {
  String selectedWatchllist;
  SortModel? selectedSort;
  List<FilterModel>? selectedFilter;
  WatchlistFilterSortSymbolEvent(
      this.selectedWatchllist, this.selectedSort, this.selectedFilter);
}
