import 'package:acml/src/models/basket_order/basket_model.dart';

import '../../models/basket_order/basket_orderbook.dart';
import '../common/screen_state.dart';

abstract class BasketState extends ScreenState {}

class BasketInitial extends BasketState {
  BasketInitial();
}

//-----create basket-------------

class CreateBasketLoading extends BasketState {
  CreateBasketLoading();
}

class CreateBasketDone extends BasketState {
  String? message;
  CreateBasketDone({this.message});
}

//-----fetch basket-------

class FetchBasketLoading extends BasketState {
  FetchBasketLoading();
}

class FetchBasketDone extends BasketState {
  Basketmodel basketModel;
  List<Baskets>? basketModelMain;
  String? marigin;
  FetchBasketDone(this.basketModel);
}

//-----delete basket-----

class DeleteBasketLoading extends BasketState {
  DeleteBasketLoading();
}

class DeleteBasketDone extends BasketState {
  DeleteBasketDone();
}

//-------fetch basket orders--------

class FetchBasketOrderLoading extends BasketState {
  FetchBasketOrderLoading();
}

class FetchBasketOrdersDone extends BasketState {
  BasketOrderBook basketOrders;
  FetchBasketOrdersDone(this.basketOrders);
}

class FetchBasketOrdersStreamState extends BasketState {
  Map<dynamic, dynamic> streamDetails;
  FetchBasketOrdersStreamState(this.streamDetails);
}

class BasketOrdersChangeState extends BasketState {}

//-----delete basket order------

class DeleteBasketOrdersLoading extends BasketState {
  DeleteBasketOrdersLoading();
}

class DeleteBasketOrdersDone extends BasketState {
  DeleteBasketOrdersDone();
}

//----execute order
class ExecuteBasketOrdersLoading extends BasketState {
  ExecuteBasketOrdersLoading();
}

class ExecuteBasketOrdersDone extends BasketState {
  ExecuteBasketOrdersDone();
}

//---rename basket--------------
class RenameBasketLoading extends BasketState {
  RenameBasketLoading();
}

class RenameBasketDone extends BasketState {
  RenameBasketDone();
}

//---rearrange basket orders--------------
class RearrangeBasketOrderLoading extends BasketState {
  RearrangeBasketOrderLoading();
}

class RearrangeBasketOrderDone extends BasketState {
  RearrangeBasketOrderDone();
}

//---reset basket orders--------------
class ResetBasketLoading extends BasketState {
  ResetBasketLoading();
}

class ResetBasketDone extends BasketState {
  ResetBasketDone();
}

//---margin calculator----
class MarginCalculatorLoading extends BasketState {
  MarginCalculatorLoading();
}

class MarginCalculatorDone extends BasketState {
  MarginCalculatorDone();
}

//---error------

class BasketError extends BasketState {
  BasketError();
}
