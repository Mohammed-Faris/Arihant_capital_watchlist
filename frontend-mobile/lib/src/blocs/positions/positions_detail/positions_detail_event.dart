part of 'positions_detail_bloc.dart';

abstract class PositionsDetailEvent {}

class PositionsDetailStartSymStreamEvent extends PositionsDetailEvent {
  Positions positions;
  PositionsDetailStartSymStreamEvent(
    this.positions,
  );
}

class PositionsDetailStreamingResponseEvent extends PositionsDetailEvent {
  ResponseData data;
  PositionsDetailStreamingResponseEvent(this.data);
}

class PositionsDetailQuoteTwoStartStreamEvent extends PositionsDetailEvent {
  Positions positions;
  PositionsDetailQuoteTwoStartStreamEvent(this.positions);
}

class PositionsDetailQuoteTwoResponseEvent extends PositionsDetailEvent {
  final Quote2Data quoteDepthData;
  PositionsDetailQuoteTwoResponseEvent(this.quoteDepthData);
}

class PositionsDetailGetPerformanceDeliveryDataEvent
    extends PositionsDetailEvent {
  Sym sym;
  PositionsDetailGetPerformanceDeliveryDataEvent(this.sym);
}

class PositionsDetailGetPerformanceContractInfoEvent
    extends PositionsDetailEvent {
  Sym sym;
  PositionsDetailGetPerformanceContractInfoEvent(this.sym);
}
