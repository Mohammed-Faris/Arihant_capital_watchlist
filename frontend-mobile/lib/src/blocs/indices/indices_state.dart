part of 'indices_bloc.dart';

abstract class IndicesState extends ScreenState {}

class IndicesInitState extends IndicesState {}

class IndicesProgressState extends IndicesState {}

class IndicesChangeState extends IndicesState {}

class IndicesErrorState extends IndicesState {}

class IndicesServiceExpectionState extends IndicesState {}

class IndicesFailedState extends IndicesState {}

class IndexConstituentsDoneState extends IndicesState {
  SortModel? selectedSort;
  List<FilterModel>? selectedFilter;
  bool isFilterSelected = false;
  bool isSortSelected = false;
  IndicesConstituentsModel? indicesConstituentsModel;
  List<Symbols>? filteredindicesConstituentsModel;

  String? selectedPredefinedWatchlist;
  String? baseSym;
  bool fromConstituents = false;
}

class IndexConstituentsSymStreamState extends IndicesState {
  Map<dynamic, dynamic> streamDetails;
  IndexConstituentsSymStreamState(this.streamDetails);
}
