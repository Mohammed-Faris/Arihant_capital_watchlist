part of 'positions_bloc.dart';

abstract class PositionsState extends ScreenState {}

class PositionsInitial extends PositionsState {}

class PositionsProgressState extends PositionsState {}

class PositionsChangeState extends PositionsState {}

class PositionsSearchProgressState extends PositionsState {}

class PositionsDoneState extends PositionsState {
  PositionsModel? positionsModel;
  List<Positions>? mainPositionsSymbols;
  String? overallTodayPnL;
  String? overallTodayPnLPercent;
  String? overallPnL;
  String? searchString;
  String? type;
  String? overallPnLPercent;
  String? totalInvestedValue;
  bool isOneDay = false;
  SortModel? selectedSort;
  List<FilterModel>? filterModel;
  PositionsDoneState();
}

class PositionsStartStreamState extends PositionsState {
  Map<dynamic, dynamic> streamDetails;
  PositionsStartStreamState(this.streamDetails);
}

class AvailableFundsDoneState extends PositionsState {
  late String availableFunds;
}

class PositionsFailedState extends PositionsState {}

class PositionsServiceExceptionState extends PositionsState {}

class PositionsErrorState extends PositionsState {}
