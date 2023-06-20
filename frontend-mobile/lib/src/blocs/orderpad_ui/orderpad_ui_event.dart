part of 'orderpad_ui_bloc.dart';

@immutable
abstract class OrderpadUiEvent {}

class OrderpadUiinit extends OrderpadUiEvent {
  final dynamic arguments;
  OrderpadUiinit(this.arguments);
}

class OrdertypeChange extends OrderpadUiEvent {
  final String currentSelectedOrderType;

  OrdertypeChange(this.currentSelectedOrderType);
}

class ValidityChange extends OrderpadUiEvent {
  final String selectedValidity;

  ValidityChange(this.selectedValidity);
}

class UpdateUi extends OrderpadUiEvent {
  final String selectedProductType;
  final String orderType;
  final bool isReset;
  final bool initCallOrder;

  UpdateUi(this.selectedProductType, this.orderType,
      {this.isReset = false, this.initCallOrder = false});
}

class ExchangeChange extends OrderpadUiEvent {}

class CheckMariginEvent extends OrderpadUiEvent {}

class GetCoTriggerPrice extends OrderpadUiEvent {}

class OtherExchange extends OrderpadUiEvent {
  final Symbols symbols;

  OtherExchange(this.symbols);
}

class PrdChange extends OrderpadUiEvent {
  final String value;
  final int index;

  PrdChange(this.value, this.index);
}
