part of 'watchlist_bloc.dart';

abstract class WatchlistState extends ScreenState {}

class WatchlistInitState extends WatchlistState {}

class WatchlistProgressState extends WatchlistState {}

class WatchlistChangeState extends WatchlistState {}

class WatchlistErrorState extends WatchlistState {}

class WatchlistServiceExpectionState extends WatchlistState {}

class WatchlistFailedState extends WatchlistState {}

class CorpSymListDoneState extends WatchlistState {}

class CorpSymListFailureState extends WatchlistState {}

class WatchlistDoneState extends WatchlistState {
  WatchlistSymbolsModel? watchlistSymbolsModel;
  List<Symbols>? mainWatchlistSymbols;
  List<Symbols>? secondaryWatchlistSymbols;
  WatchlistGroupModel? watchlistGroupModel;
  List<Symbols>? myHoldingsSymbols;
  String selectedWatchlist = AppLocalizations().myStocks;
  String selectedTab = AppConstants.tab1;
}

class WatchlistGetGroupsState extends WatchlistState {}

class WatchlistGetGroupsDone extends WatchlistState {}

class WatchlistAllSymsDoneState extends WatchlistState {
  WatchlistSymbolsModel? watchlistSymbolsModel;
  WatchlistGroupModel? watchlistGroupModel;
}

class WatchlistSymStreamState extends WatchlistState {
  Map<dynamic, dynamic> streamDetails;
  WatchlistSymStreamState(this.streamDetails);
}

class WatchlistDeleteGroupState extends WatchlistState {
  WatchlistDeleteGroupModel? watchlistDeleteGroupModel;
}

class WatchlistDeleteGroupFailedState extends WatchlistState {}

class WatchlistRearrangeSymState extends WatchlistState {
  String message;
  WatchlistRearrangeSymState(this.message);
}

class WatchlistRearrangeSymFailedState extends WatchlistState {}

class WatchlistDeleteSymbolState extends WatchlistState {
  String message;
  WatchlistDeleteSymbolState(this.message);
}

class WatchlistDeleteSymbolFailedState extends WatchlistState {}

class RenameWatchlistDoneState extends WatchlistState {
  WatchlistRenameWatchlistModel? watchlistRenameWatchlistModel;
}

class RenameWatchlistFailedState extends WatchlistState {}
