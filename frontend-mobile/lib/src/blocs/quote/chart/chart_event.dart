part of 'chart_bloc.dart';

abstract class ChartEvent {}

class ChartStartSymStreamEvent extends ChartEvent {
  Symbols symbolItem;
  ChartStartSymStreamEvent(
    this.symbolItem,
  );
}

class ChartStreamingResponseEvent extends ChartEvent {
  ResponseData data;
  ChartStreamingResponseEvent(this.data);
}
