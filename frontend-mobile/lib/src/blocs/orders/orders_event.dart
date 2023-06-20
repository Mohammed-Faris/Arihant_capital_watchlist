part of 'orders_bloc.dart';

abstract class OrdersEvent {}

class OrdersBookEvent extends OrdersEvent {
  List<FilterModel>? filterModel;
  SortModel? selectedSort;
  bool fetchAgain;
  bool loading;
  bool isgtdorder;
  OrdersBookEvent(this.filterModel, this.selectedSort,
      {this.fetchAgain = false, this.loading = true, this.isgtdorder = false});
}

class OrdersSearchEvent extends OrdersEvent {
  final String searchString;
  List<Orders> orders;
  OrdersSearchEvent(
    this.searchString,
    this.orders,
  );
}

class OrdersResetSearchEvent extends OrdersEvent {}

class StartSymStreamEvent extends OrdersEvent {}

class StreamingResponseEvent extends OrdersEvent {
  ResponseData data;
  StreamingResponseEvent(this.data);
}

class OrderBookCancelEvent extends OrdersEvent {
  late Orders orders;
  bool isGtd;
  OrderBookCancelEvent(this.orders, this.isGtd);
}

class OrderBookExitEvent extends OrdersEvent {
  late Orders orders;
  OrderBookExitEvent(this.orders);
}

class OrdersFailedEvent extends OrdersEvent {}

class OrdersErrorEvent extends OrdersEvent {}
