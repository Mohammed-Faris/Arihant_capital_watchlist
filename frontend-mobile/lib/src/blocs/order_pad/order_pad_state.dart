part of 'order_pad_bloc.dart';

abstract class OrderPadState extends ScreenState {}

class OrderPadInitial extends OrderPadState {}

class OrderPadSymbolItemState extends OrderPadState {
  List<Symbols> symbols = [];

  OrderPadSymbolItemState();
}

class OrderPadChangeState extends OrderPadState {}

class OrderPadSymStreamState extends OrderPadState {
  final Map<dynamic, dynamic> streamDetails;
  OrderPadSymStreamState(this.streamDetails);
}

class OrderPadErrorState extends OrderPadState {}

class OrderPadProgressState extends OrderPadState {}

class OrderPadPlaceProgressState extends OrderPadState {}

class OrderPadOtherExcSymbolInfoDoneState extends OrderPadState {
  Symbols symbolItem;
  OrderPadOtherExcSymbolInfoDoneState(this.symbolItem);
}

class OrderPadOtherExcSymbolInfoFailedState extends OrderPadState {}

class OrderPadSetSymbolItemDoneState extends OrderPadState {
  OrderPadSetSymbolItemDoneState();
}

class OrderPadPlaceOrderDoneState extends OrderPadState {
  Map<String, dynamic> responseData;
   bool isBasket;
  OrderPadPlaceOrderDoneState(this.responseData, {this.isBasket = false});
}

class OrderPadPlaceOrderFailedState extends OrderPadState {
  Map<dynamic, dynamic> responseData;
  OrderPadPlaceOrderFailedState(this.responseData);
}

class OrderPadPlaceOrderServiceExceptionState extends OrderPadState {}

class CheckMarginProgressState extends OrderPadState {}

class CheckMarginDoneState extends OrderPadState {
  CheckMarginModel? checkMarginModel;
  CheckMarginDoneState();
}

class CheckMarginFailedState extends OrderPadState {}

class CheckMarginServiceExceptionState extends OrderPadState {}

class OrderPadCoSlTriggerRangeState extends OrderPadState {
  CoTriggerPriceRangeModel? coTriggerPriceRangeModel;
  OrderPadCoSlTriggerRangeState();
}

class OrderPadCoSlTriggerRangeFailedState extends OrderPadState {}

class OrderPadCoSlTriggerRangeServiceExceptionState extends OrderPadState {}
