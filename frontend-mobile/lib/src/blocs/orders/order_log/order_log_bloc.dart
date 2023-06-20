import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

import '../../../constants/app_constants.dart';
import '../../../data/repository/order/order_repository.dart';
import '../../../data/store/app_helper.dart';
import '../../../models/orders/order_book.dart';
import '../../../models/orders/order_status_log.dart';
import '../../common/base_bloc.dart';
import '../../common/screen_state.dart';

part 'order_log_event.dart';
part 'order_log_state.dart';

class OrderLogBloc extends BaseBloc<OrderLogEvent, OrderLogState> {
  OrderLogBloc() : super(OrderLogInitial());

  OrdersStatusLogDoneState ordersStatusLogDoneState =
      OrdersStatusLogDoneState();
  OrderLogStreamState ordersStatusLogStreamState = OrderLogStreamState();
    OrderLogStreamResponse orderStream = OrderLogStreamResponse();

  @override
  Future<void> eventHandlerMethod(
      OrderLogEvent event, Emitter<OrderLogState> emit) async {
    if (event is OrderLogStreamingResponseEvent) {
      await responseCallback(event.data, emit);
    } else if (event is OrderStatusLogEvent) {
      await _handleOrderStatusLogEvent(event, emit);
    }
  }

  Future<void> _handleOrderStatusLogEvent(
      OrderStatusLogEvent event, Emitter<OrderLogState> emit) async {
    emit(OrderLogProgressState());

    try {
      ordersStatusLogDoneState.orders = event.orders;

      final BaseRequest request = BaseRequest();
      if (event.isGtd) {
        request.addToData('ordId', event.orders.ordId);
        request.addToData('triggerid', event.orders.triggerid);
      } else {
        request.addToData('ordId', event.orders.ordId);
      }
      // request.addToData('triggerid', event.orders.triggerid);
      OrderStatusLog orderStatusLog = await OrderRepository()
          .getOrderStatusLogRequest(request, event.isGtd);
      ordersStatusLogDoneState.orderStatusLog = orderStatusLog;

      //"13 Feb 23  09:00 AM" - gtd

      ordersStatusLogDoneState.orderStatusLog?.history?.sort((a, b) =>
          DateFormat("dd MMM yy  hh:mm a").parse(b.lupdateDateTime!).compareTo(
              DateFormat("dd MMM yy  hh:mm a").parse(a.lupdateDateTime!)));

      emit(ordersStatusLogDoneState);

      await sendStream(emit);
    } on ServiceException catch (ex) {
      ordersStatusLogDoneState.orders = event.orders;
      await sendStream(emit);
      emit(OrdersStatusLogServiceExceptionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      ordersStatusLogDoneState.orders = event.orders;
      await sendStream(emit);
      emit(OrdersStatusLogFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> sendStream(Emitter<OrderLogState> emit) async {
    if (ordersStatusLogDoneState.orders != null) {}
    final List<String> streamingKeys = <String>[
      AppConstants.streamingLtp,
      AppConstants.streamingChng,
      AppConstants.streamingChgnPer,
    ];
    {
      emit(
        ordersStatusLogStreamState
          ..streamDetails = AppHelper().streamDetails(
            [ordersStatusLogDoneState.orders],
            streamingKeys,
          ),
      );
    }
  }

  Future<void> responseCallback(
    ResponseData streamData,
    Emitter<OrderLogState> emit,
  ) async {
    if (ordersStatusLogDoneState.orders != null) {
      final List<Orders> orders = [ordersStatusLogDoneState.orders!];

      final String symbolName = streamData.symbol!;
      if (orders.isNotEmpty) {
        for (int i = 0; i < orders.length; i++) {
          if (orders[i].sym!.streamSym == symbolName) {
            orders[i].ltp = streamData.ltp ?? orders[i].ltp;
            orders[i].chng = streamData.chng ?? orders[i].chng;
            orders[i].chngPer = streamData.chngPer ?? orders[i].chngPer;
            emit(OrderLogChangeState());
            emit(orderStream..orders = orders[i]);
          }
        }
      }
    }
  }

  @override
  OrderLogState getErrorState() {
    return OrderLogErrorState();
  }
}
