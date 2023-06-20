part of 'order_pad_bloc.dart';

abstract class OrderPadEvent {}

class OrderPadStartSymStreamEvent extends OrderPadEvent {
  OrderPadStartSymStreamEvent();
}

class OrderPadStreamingResponseEvent extends OrderPadEvent {
  ResponseData data;
  OrderPadStreamingResponseEvent(this.data);
}

class OrderPadGetOtherExcSymbolInfoEvent extends OrderPadEvent {
  Symbols symbols;
  String exchange;
  OrderPadGetOtherExcSymbolInfoEvent(
    this.symbols,
    this.exchange,
  );
}

class OrderPadSetSymbolItemEvent extends OrderPadEvent {
  Symbols symbols;
  OrderPadSetSymbolItemEvent(this.symbols);
}

class OrderPadPlaceOrderEvent extends OrderPadEvent {
  Map<String, dynamic> data;
  bool isGtdOrder;
  bool basketorder;
  OrderPadPlaceOrderEvent(this.data, this.isGtdOrder,
      {this.basketorder = false});
}

class ModifyOrderPadPlaceOrderEvent extends OrderPadEvent {
  Map<String, dynamic> data;
  bool isGtdOrder;
  bool basketorder;
  ModifyOrderPadPlaceOrderEvent(this.data, this.isGtdOrder,
      {this.basketorder = false});
}

class OrderPadCheckMarginEvent extends OrderPadEvent {
  Map<String, dynamic> data;
  OrderPadCheckMarginEvent(this.data);
}

class OrderPadCoSlTriggerRangeEvent extends OrderPadEvent {
  Map<String, dynamic> data;
  OrderPadCoSlTriggerRangeEvent(this.data);
}
