part of 'basket_bloc.dart';

abstract class BasketEvent {}

class CreateBasketEvent extends BasketEvent {
  String basketName;
  CreateBasketEvent(this.basketName);
}

class FetchBasketEvent extends BasketEvent {
  FetchBasketEvent();
}

class FilterBasketEvent extends BasketEvent {
  final String searchString;
  FilterBasketEvent(this.searchString);
}

class FetchBasketOrdersEvent extends BasketEvent {
  String basketId;
  FetchBasketOrdersEvent(this.basketId);
}

class ExecuteBasketOrdersEvent extends BasketEvent {
  BasketOrderBook basketOrders;
  ExecuteBasketOrdersEvent(this.basketOrders);
}

class BasketStreamingResponseEvent extends BasketEvent {
  ResponseData data;
  BasketStreamingResponseEvent(this.data);
}

class DeleteBasketEvent extends BasketEvent {
  String basketId;
  DeleteBasketEvent(this.basketId);
}

class DeleteBasketOrderEvent extends BasketEvent {
  String basketOrderId;
  DeleteBasketOrderEvent(this.basketOrderId);
}

class RenameBasketEvent extends BasketEvent {
  String basketName;
  String basketId;
  RenameBasketEvent(this.basketId, this.basketName);
}

class RearrangeBasketOrderEvent extends BasketEvent {
  String basketId;
  List orderDtls;
  int oldPosition;
  int newposition;
  RearrangeBasketOrderEvent(
      this.orderDtls, this.basketId, this.oldPosition, this.newposition);
}

class ResetBasketEvent extends BasketEvent {
  String basketId;

  ResetBasketEvent(this.basketId);
}

class MarginCalculatorEvent extends BasketEvent {
  List<Orders> symbolList;
  MarginCalculatorEvent(this.symbolList);
}
