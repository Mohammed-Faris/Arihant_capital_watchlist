part of 'orders_bloc.dart';

abstract class OrdersState extends ScreenState {}

class OrdersInitial extends OrdersState {}

class OrdersProgressState extends OrdersState {}

class OrdersChangeState extends OrdersState {}

class OrdersDoneState extends OrdersState {
  OrderBook? orderBook;
  List<Orders>? searchOrdersSymbols;
  List<Orders>? mainOrdersSymbols;
}

class OrdersBookStreamState extends OrdersState {
  Map<dynamic, dynamic> streamDetails;
  OrdersBookStreamState(this.streamDetails);
}

class OrdersCancelDoneState extends OrdersState {
  BaseModel baseModel;
  OrdersCancelDoneState(this.baseModel);
}

class OrdersCancelFailedState extends OrdersState {
  OrdersCancelFailedState();
}

class OrdersCancelServiceExceptionState extends OrdersState {}

class OrdersExitDoneState extends OrdersState {
  BaseModel baseModel;
  OrdersExitDoneState(this.baseModel);
}

class OrdersExitFailedState extends OrdersState {
  OrdersExitFailedState();
}

class OrdersExitServiceExceptionState extends OrdersState {}

class OrdersFailedState extends OrdersState {}

class OrdersServiceExceptionState extends OrdersState {}

class NoData extends OrdersState {}

class OrdersErrorState extends OrdersState {}
