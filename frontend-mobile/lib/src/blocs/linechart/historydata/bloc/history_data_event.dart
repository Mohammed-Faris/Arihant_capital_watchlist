part of 'history_data_bloc.dart';

abstract class LineChartEvent {}

class HistoryDataFetchEvent extends LineChartEvent {
  final Symbols symbol;
  final String period;
  HistoryDataFetchEvent(this.symbol, this.period);
}

class HistoryDataUpdatedEvent extends LineChartEvent {
  final DataPoints dataPoint;
  HistoryDataUpdatedEvent(
    this.dataPoint,
  );
}
