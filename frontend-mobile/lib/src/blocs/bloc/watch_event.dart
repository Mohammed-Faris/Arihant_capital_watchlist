part of 'watch_bloc.dart';

abstract class WatchEvent {}

class LoadWatchEvent extends WatchEvent {
  List<Object?> get props => [];
}

class NewWatchlistStreamingResponseEvent extends WatchEvent {
  int selectedTabIndex;
  ResponseData data;
  NewWatchlistStreamingResponseEvent(this.data, this.selectedTabIndex);
}

// class FilteredEvent extends WatchEvent {
//   final List<WatchlistSymbolsModel> filteredusers;

//   final int currentTabIndex;
//   final String? selectedSort;
//   final String? query;

//   FilteredEvent(
//       {required this.filteredusers,
//       required this.currentTabIndex,
//       this.query,
//       this.selectedSort});
// }

// class OnSearchEvent extends FilteredEvent {
//   OnSearchEvent({
//     required super.query,
//     required super.currentTabIndex,
//     required super.filteredusers,
//   });
// }

class SearchEvent extends WatchEvent {
  String searchText;
  final int selectedTabIndex;

  SearchEvent({required this.searchText, required this.selectedTabIndex});
}

class OnSortEvent extends WatchEvent {
  final int selectedTabIndex;
  final String selectedSort;
  bool isSortedName = false;
  bool isSortedChange = false;
  bool isSortedPrice = false;
  bool isSelectedName = false;
  bool isSelectedChange = false;
  bool isSelectedPrice = false;
  OnSortEvent(
      {required this.selectedTabIndex,
      required this.selectedSort,
      required this.isSortedName,
      required this.isSortedChange,
      required this.isSortedPrice,
      required this.isSelectedName,
      required this.isSelectedChange,
      required this.isSelectedPrice});
}
