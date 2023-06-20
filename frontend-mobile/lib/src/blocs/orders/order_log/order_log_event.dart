part of 'order_log_bloc.dart';

abstract class OrderLogEvent {}

class OrderLogStreamingResponseEvent extends OrderLogEvent {
  ResponseData data;
  OrderLogStreamingResponseEvent(this.data);
}

class OrderStatusLogEvent extends OrderLogEvent {
  Orders orders;
  bool isGtd;
  OrderStatusLogEvent(this.orders, {this.isGtd = false});
}
