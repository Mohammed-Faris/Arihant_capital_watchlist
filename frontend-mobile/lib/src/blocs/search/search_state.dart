part of 'search_bloc.dart';

abstract class SearchState extends ScreenState {
  String searchText = "";
  bool isShowRecentSearch = true;
  String selectedSymbolFilter = AppConstants.all;
}

class SearchInitial extends SearchState {}

class SearchProgressState extends SearchState {}

class SearchLoaderState extends SearchState {}

class SearchFailedState extends SearchState {}

class SymbolSearchDoneState extends SearchState {
  SearchSymbolsModel? searchSymbolsModel;
  SearchSymbolsModel? selecteddatamodel;
  SearchSymbolsModel recentSelecteddatamodel = SearchSymbolsModel();
  Map<String, List<Symbols>> recentSymbolsStatusMap = {};
  String? wName;
}

class SearchAddSymbolFailedState extends SearchState {}

class SearchAddDoneState extends SearchState {
  String messageModel;
  SearchAddDoneState(this.messageModel);
}

class SearchdeleteDoneState extends SearchState {
  String messageModel;
  SearchdeleteDoneState(this.messageModel);
}

class SearchdeleteSymbolFailedState extends SearchState {}

class SearchServiceExpectionState extends SearchState {}

class SearchChangeState extends SearchState {}

class SearchSymStreamState extends SearchState {
  Map<dynamic, dynamic> streamDetails;
  SearchSymStreamState(this.streamDetails);
}
