part of 'search_bloc.dart';

abstract class SearchEvent {}

class SymbolSearchEvent extends SearchEvent {
  String searchString = "";
  String selectedFilter = AppConstants.all;

  SymbolSearchEvent();
}

class SearchAddSymbolEvent extends SearchEvent {
  String groupname;
  Symbols symbolItem;
  bool isNewWatchlist;
  SearchAddSymbolEvent(this.groupname, this.symbolItem, this.isNewWatchlist);
}

class SearchdeleteSymbolEvent extends SearchEvent {
  String groupname;
  Symbols symbolItem;
  SearchdeleteSymbolEvent(this.groupname, this.symbolItem);
}

class SearchStreamingResponseEvent extends SearchEvent {
  ResponseData data;
  SearchStreamingResponseEvent(this.data);
}

class SymbolSearchRowTappedEvent extends SearchEvent {
  final Symbols symbolItem;
  SymbolSearchRowTappedEvent(this.symbolItem,);
}
