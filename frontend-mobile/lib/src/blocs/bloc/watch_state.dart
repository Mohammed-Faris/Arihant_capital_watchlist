part of 'watch_bloc.dart';

abstract class WatchState {}

// data loading state
class WatchLoadingState extends WatchState {}

// data loaded state
class WatchLoadedState extends WatchState {
  WatchlistGroupModel? watchlistGroupModel;
  // WatchlistSymbolsModel? watchlistSymbolsModel;
  List<WatchlistSymbolsModel> symbolsModelList = [];

  bool isSortedName = false;
  bool isSortedChange = false;
  bool isSortedPrice = false;
  bool isSelectedName = false;
  bool isSelectedChange = false;
  bool isSelectedPrice = false;
}

class WatchChangeState extends WatchState {}

// data loading error state
class WatchErrorState extends WatchState {
  final String error;
  WatchErrorState(this.error); // Constructor

  List<Object?> get props => [error];
}
