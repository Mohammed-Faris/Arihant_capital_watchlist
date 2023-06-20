part of 'history_data_bloc.dart';

abstract class LineChartState extends ScreenState {
  int selectedIndex = 0;
}

class LineChartInitial extends LineChartState {}

class LineChartError extends LineChartState {}

class LineChartLoad extends LineChartState {}

class LineChartDone extends LineChartState {
  List<DataPoints> dataPoints = [];
  DateTime? startDate;
  DateTime? endDate;
}
