part of 'chart_bloc.dart';

abstract class ChartState extends ScreenState {}

class ChartInitial extends ChartState {}

class ChartDataState extends ChartState {
  Symbols? symbols;
}

class ChartSymStreamState extends ChartState {
  final Map<dynamic, dynamic> streamDetails;
  ChartSymStreamState(this.streamDetails);
}

class ChartChangeState extends ChartState {}

class ChartErrorState extends ChartState {}
