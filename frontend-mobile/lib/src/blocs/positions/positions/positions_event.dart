part of 'positions_bloc.dart';

abstract class PositionsEvent {}

class FetchPositionsEvent extends PositionsEvent {
  List<FilterModel>? filterModel;
  SortModel? selectedSort;
  bool fetchAgain;
  bool loading;
  final String type;

  String searchString;
  FetchPositionsEvent(this.filterModel, this.selectedSort, this.type,
      {this.loading = true, this.fetchAgain = false, this.searchString = ""});
}

class GetAvailableFundsEvent extends PositionsEvent {}

class PositionStartStream extends PositionsEvent {}

class PositionsStreamingResponseEvent extends PositionsEvent {
  ResponseData data;
  PositionsStreamingResponseEvent(this.data);
}
