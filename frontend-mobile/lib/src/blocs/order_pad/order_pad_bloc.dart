import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

import '../../constants/app_constants.dart';
import '../../data/repository/order_pad/order_pad_repository.dart';
import '../../data/store/app_helper.dart';
import '../../models/common/symbols_model.dart';
import '../../models/order_pad/check_margin_model.dart';
import '../../models/order_pad/co_trigger_price_range_model.dart';
import '../../models/order_pad/order_pad_place_order_model.dart';
import '../../models/quote/get_symbol_info_model.dart';
import '../common/base_bloc.dart';
import '../common/screen_state.dart';

part 'order_pad_event.dart';
part 'order_pad_state.dart';

class OrderPadBloc extends BaseBloc<OrderPadEvent, OrderPadState> {
  OrderPadBloc() : super(OrderPadInitial());
  OrderPadSymbolItemState orderPadSymbolItemState = OrderPadSymbolItemState();
  CheckMarginDoneState checkMarginDoneState = CheckMarginDoneState();

  @override
  Future<void> eventHandlerMethod(
      OrderPadEvent event, Emitter<OrderPadState> emit) async {
    if (event is OrderPadGetOtherExcSymbolInfoEvent) {
      await _handleOrderPadGetOtherExcSymbolInfoEvent(event, emit);
    } else if (event is OrderPadSetSymbolItemEvent) {
      await _handleOrderPadSetSymbolItemEvent(event, emit);
    } else if (event is OrderPadPlaceOrderEvent) {
      await _handleOrderPadPlaceOrderEvent(event, emit);
    } else if (event is ModifyOrderPadPlaceOrderEvent) {
      await _handleModifyOrderPadPlaceOrderEvent(event, emit);
    } else if (event is OrderPadCheckMarginEvent) {
      await _handleOrderPadCheckMarginEvent(event, emit);
    } else if (event is OrderPadCoSlTriggerRangeEvent) {
      await _handleOrderPadCoSlTriggerRangeEvent(event, emit);
    } else if (event is OrderPadStartSymStreamEvent) {
      await sendStream(emit);
    } else if (event is OrderPadStreamingResponseEvent) {
      await responseCallback(event.data, emit);
    }
  }

  Future<void> _handleOrderPadGetOtherExcSymbolInfoEvent(
    OrderPadGetOtherExcSymbolInfoEvent event,
    Emitter<OrderPadState> emit,
  ) async {
    // emit(OrderPadProgressState());
    try {
      final BaseRequest request = BaseRequest();
      request.addToData('sym', event.symbols.sym!.toJson());
      request.addToData('otherExch', event.exchange);
      GetSymbolModel getSymbolModel =
          await OrderPadRepository().getSymbolInfoRequest(request);

      final Symbols symbolItem = Symbols.copyModel(event.symbols);
      symbolItem.sym = getSymbolModel.symbol!.sym;
      orderPadSymbolItemState.symbols.add(event.symbols);
      orderPadSymbolItemState.symbols.add(symbolItem);

      emit(orderPadSymbolItemState);
      emit(OrderPadOtherExcSymbolInfoDoneState(symbolItem));
    } on ServiceException catch (ex) {
      orderPadSymbolItemState.symbols.add(event.symbols);
      emit(OrderPadOtherExcSymbolInfoFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      orderPadSymbolItemState.symbols.add(event.symbols);
      emit(OrderPadOtherExcSymbolInfoFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleOrderPadSetSymbolItemEvent(
    OrderPadSetSymbolItemEvent event,
    Emitter<OrderPadState> emit,
  ) async {
    emit(OrderPadProgressState());

    orderPadSymbolItemState.symbols.add(event.symbols);
    emit(orderPadSymbolItemState);
    emit(OrderPadSetSymbolItemDoneState());
  }

  Future<void> sendStream(
    Emitter<OrderPadState> emit,
  ) async {
    if (orderPadSymbolItemState.symbols.isNotEmpty) {
      final List<String> streamingKeys = <String>[
        AppConstants.streamingLtp,
        AppConstants.streamingChng,
        AppConstants.streamingChgnPer,
        AppConstants.streamingLowerCircuit,
        AppConstants.streamingUpperCircuit,
      ];
      if (orderPadSymbolItemState.symbols.isNotEmpty) {
        emit(
          OrderPadSymStreamState(
            AppHelper().streamDetails(
              orderPadSymbolItemState.symbols,
              streamingKeys,
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleOrderPadPlaceOrderEvent(
    OrderPadPlaceOrderEvent event,
    Emitter<OrderPadState> emit,
  ) async {
    emit(OrderPadPlaceProgressState());
    try {
      final BaseRequest request = BaseRequest(data: event.data);
      OrderPadPlaceOrderModel orderPadPlaceOrderModel;

      if (event.basketorder) {
        orderPadPlaceOrderModel =
            await OrderPadRepository().placeBasketOrderRequest(request);
      } else if (event.isGtdOrder) {
        orderPadPlaceOrderModel =
            await OrderPadRepository().gtdPlaceOrderRequest(request);
      } else {
        orderPadPlaceOrderModel =
            await OrderPadRepository().placeOrderRequest(request);
      }

      emit(OrderPadPlaceOrderDoneState(orderPadPlaceOrderModel.data)
        ..isBasket = event.basketorder);
    } on ServiceException catch (ex) {
      emit(OrderPadPlaceOrderServiceExceptionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(OrderPadPlaceOrderFailedState(ex.data)
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleModifyOrderPadPlaceOrderEvent(
    ModifyOrderPadPlaceOrderEvent event,
    Emitter<OrderPadState> emit,
  ) async {
    emit(OrderPadPlaceProgressState());
    try {
      final BaseRequest request = BaseRequest(data: event.data);
      OrderPadPlaceOrderModel orderPadPlaceOrderModel;
      if (event.basketorder) {
        orderPadPlaceOrderModel =
            await OrderPadRepository().placeBasketModifyOrderRequest(request);
      } else if (event.isGtdOrder) {
        orderPadPlaceOrderModel =
            await OrderPadRepository().placegtdModifyOrderRequest(request);
      } else {
        orderPadPlaceOrderModel =
            await OrderPadRepository().placeModifyOrderRequest(request);
      }

      emit(OrderPadPlaceOrderDoneState(orderPadPlaceOrderModel.data)
        ..isBasket = event.basketorder);
    } on ServiceException catch (ex) {
      emit(OrderPadPlaceOrderServiceExceptionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(OrderPadPlaceOrderFailedState(ex.data)
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleOrderPadCheckMarginEvent(
    OrderPadCheckMarginEvent event,
    Emitter<OrderPadState> emit,
  ) async {
    emit(CheckMarginProgressState());
    try {
      final BaseRequest request = BaseRequest(data: event.data);
      CheckMarginModel availableFundsModel =
          await OrderPadRepository().checkMarginRequest(request);
      checkMarginDoneState.checkMarginModel = availableFundsModel;
      emit(OrderPadChangeState());
      emit(checkMarginDoneState);
    } on ServiceException catch (ex) {
      emit(CheckMarginServiceExceptionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(CheckMarginFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleOrderPadCoSlTriggerRangeEvent(
    OrderPadCoSlTriggerRangeEvent event,
    Emitter<OrderPadState> emit,
  ) async {
    try {
      final BaseRequest request = BaseRequest(data: event.data);
      CoTriggerPriceRangeModel coTriggerPriceRangeModel =
          await OrderPadRepository().coTriggerPriceRangeRequest(request);
      emit(OrderPadChangeState());
      emit(OrderPadCoSlTriggerRangeState()
        ..coTriggerPriceRangeModel = coTriggerPriceRangeModel);
    } on ServiceException catch (ex) {
      emit(OrderPadCoSlTriggerRangeFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(OrderPadCoSlTriggerRangeServiceExceptionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> responseCallback(
    ResponseData streamData,
    Emitter<OrderPadState> emit,
  ) async {
    if (orderPadSymbolItemState.symbols.isNotEmpty) {
      final List<Symbols> symbols = orderPadSymbolItemState.symbols;

      final int index = symbols.indexWhere((Symbols element) {
        return element.sym!.streamSym == streamData.symbol;
      });
      if (index != -1) {
        symbols[index].open = streamData.open ?? symbols[index].open;
        symbols[index].openInterest =
            streamData.oI ?? symbols[index].openInterest;
        symbols[index].atp = streamData.atp ?? symbols[index].atp;
        symbols[index].vol = streamData.vol ?? symbols[index].vol;
        symbols[index].close = streamData.close ?? symbols[index].close;

        symbols[index].high = streamData.high ?? symbols[index].high;
        symbols[index].low = streamData.low ?? symbols[index].low;
        symbols[index].ltp = streamData.ltp ?? symbols[index].ltp;
        symbols[index].chng = streamData.chng ?? symbols[index].chng;
        symbols[index].chngPer = streamData.chngPer ?? symbols[index].chngPer;
        symbols[index].yhigh = streamData.yHigh ?? symbols[index].yhigh;
        symbols[index].ylow = streamData.yLow ?? symbols[index].ylow;
        symbols[index].lcl = streamData.lcl ?? symbols[index].lcl;
        symbols[index].ucl = streamData.ucl ?? symbols[index].ucl;
        emit(OrderPadChangeState());
        emit(orderPadSymbolItemState..symbols = symbols);
      }
    }
  }

  @override
  OrderPadState getErrorState() {
    return OrderPadErrorState();
  }
}
