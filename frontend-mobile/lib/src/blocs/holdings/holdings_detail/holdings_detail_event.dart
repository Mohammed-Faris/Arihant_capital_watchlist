part of 'holdings_detail_bloc.dart';

abstract class HoldingsDetailEvent {}

class HoldingsDetailStartSymStreamEvent extends HoldingsDetailEvent {
  Symbols symbolItem;
  HoldingsDetailStartSymStreamEvent(
    this.symbolItem,
  );
}

class HoldingsDetailStreamingResponseEvent extends HoldingsDetailEvent {
  ResponseData data;
  HoldingsDetailStreamingResponseEvent(this.data);
}

class HoldingsDetailQuoteTwoStartStreamEvent extends HoldingsDetailEvent {
  Symbols symbolItem;
  HoldingsDetailQuoteTwoStartStreamEvent(this.symbolItem);
}

class HoldingsDetailQuoteTwoResponseEvent extends HoldingsDetailEvent {
  final Quote2Data quoteDepthData;
  HoldingsDetailQuoteTwoResponseEvent(this.quoteDepthData);
}

class HoldingsDetailGetPerformanceDeliveryDataEvent
    extends HoldingsDetailEvent {
  Sym sym;
  HoldingsDetailGetPerformanceDeliveryDataEvent(this.sym);
}

class HoldingsDetailGetPerformanceContractInfoEvent
    extends HoldingsDetailEvent {
  Sym sym;
  HoldingsDetailGetPerformanceContractInfoEvent(this.sym);
}
