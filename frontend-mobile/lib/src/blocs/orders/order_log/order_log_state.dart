part of 'order_log_bloc.dart';

abstract class OrderLogState extends ScreenState {}

class OrderLogInitial extends OrderLogState {}

class OrdersStatusLogDoneState extends OrderLogState {
  OrderStatusLog? orderStatusLog;
  Orders? orders;
}
class OrderLogStreamResponse extends OrderLogState {
    Orders? orders;

}

class OrdersStatusLogFailedState extends OrderLogState {}

class OrdersStatusLogServiceExceptionState extends OrderLogState {}

class OrderLogProgressState extends OrderLogState {}

class OrderLogChangeState extends OrderLogState {}

class OrderLogErrorState extends OrderLogState {}

class OrderLogStreamState extends OrderLogState {
  Map<dynamic, dynamic>? streamDetails;
  OrderLogStreamState();
}
