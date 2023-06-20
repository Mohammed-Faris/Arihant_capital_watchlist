import 'package:acml/src/blocs/basket_order/basket_state.dart';
import 'package:acml/src/data/repository/basket_order/basket_repository.dart';
import 'package:acml/src/models/basket_order/basket_model.dart';
import 'package:acml/src/ui/screens/base/base_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_model.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

import '../../constants/app_constants.dart';
import '../../data/store/app_helper.dart';
import '../../models/basket_order/basket_orderbook.dart';
import '../../models/orders/order_book.dart';
import '../common/base_bloc.dart';

part 'basket_event.dart';

class BasketBloc extends BaseBloc<BasketEvent, BasketState> {
  BasketBloc() : super(BasketInitial());
  FetchBasketOrdersDone ordersDoneState =
      FetchBasketOrdersDone(BasketOrderBook());
  FetchBasketDone fetchBasketDone = FetchBasketDone(Basketmodel(baskets: []));
  @override
  Future<void> eventHandlerMethod(
      BasketEvent event, Emitter<BasketState> emit) async {
    if (event is CreateBasketEvent) {
      await onCreateBasketEvent(event, emit);
    } else if (event is FetchBasketEvent) {
      await onFetchBasketEvent(event, emit);
    } else if (event is FilterBasketEvent) {
      await onFilterBasketEvent(event, emit);
    } else if (event is FetchBasketOrdersEvent) {
      await onFetchBasketOrddersEvent(event, emit);
    } else if (event is BasketStreamingResponseEvent) {
      await responseCallback(event.data, emit);
    } else if (event is BasketStreamingResponseEvent) {
      await responseCallback(event.data, emit);
    } else if (event is ExecuteBasketOrdersEvent) {
      await onExecuteBasketOrderEvent(event, emit);
    } else if (event is DeleteBasketOrderEvent) {
      await onDeleteBasketOrderEvent(event, emit);
    } else if (event is DeleteBasketEvent) {
      await onDeleteBasketEvent(event, emit);
    } else if (event is RenameBasketEvent) {
      await onRenameBasketEvent(event, emit);
    } else if (event is RearrangeBasketOrderEvent) {
      await onRearrangeBasketOrderEvent(event, emit);
    } else if (event is ResetBasketEvent) {
      await onResetBasketEvent(event, emit);
    } else if (event is MarginCalculatorEvent) {
      await onMargincalculateEvent(event, emit);
    }
  }

  Future<void> onCreateBasketEvent(
      CreateBasketEvent event, Emitter<BasketState> emit) async {
    final BaseRequest request = BaseRequest();
    emit(CreateBasketLoading());
    request.addToData('basketName', event.basketName);
    try {
      BaseModel response = await BasketRepository().createBasket(request);
      showToast(message: response.infoMsg);
      emit(CreateBasketDone());
    } on FailedException catch (ex) {
      emit(CreateBasketDone());
      showToast(
        message: ex.msg,
        isError: true,
      );
    }
  }

  Future<void> onFetchBasketEvent(
      FetchBasketEvent event, Emitter<BasketState> emit) async {
    if (fetchBasketDone.basketModelMain?.isEmpty ?? true) {
      emit(FetchBasketLoading());
    }

    Basketmodel basketList = await BasketRepository().fetchBasket();
    emit(FetchBasketLoading());
    emit(fetchBasketDone
      ..basketModel = basketList
      ..basketModelMain = basketList.baskets);
  }

  Future<void> onFilterBasketEvent(
      FilterBasketEvent event, Emitter<BasketState> emit) async {
    emit(FetchBasketLoading());

    fetchBasketDone.basketModel.baskets = event.searchString.isEmpty
        ? fetchBasketDone.basketModelMain?.toList() ?? []
        : fetchBasketDone.basketModelMain
                ?.where((element) => element.basketName
                    .toLowerCase()
                    .startsWith(event.searchString.toLowerCase()))
                .toList() ??
            [];
    emit(fetchBasketDone);
  }

  Future<void> onFetchBasketOrddersEvent(
      FetchBasketOrdersEvent event, Emitter<BasketState> emit) async {
    if (ordersDoneState.basketOrders.orders?.isEmpty ?? true) {
      emit(FetchBasketOrderLoading());
    }
    emit(MarginCalculatorLoading());
    try {
      final BaseRequest request = BaseRequest();
      request.addToData('basketId', event.basketId);

      final BasketOrderBook basketOrders =
          await BasketRepository().fetchBasketOrders(request);
      emit(FetchBasketOrderLoading());

      emit(ordersDoneState..basketOrders = basketOrders);

      await sendStream(emit);
      await Future.delayed(const Duration(milliseconds: 500));
      await onMargincalculateEvent(
          MarginCalculatorEvent(ordersDoneState.basketOrders.orders ?? []),
          emit);
    } on ServiceException catch (ex) {
      emit(BasketError()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(BasketError()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> sendStream(Emitter<BasketState> emit) async {
    final List<String> streamingKeys = <String>[
      AppConstants.streamingLtp,
      AppConstants.streamingChng,
      AppConstants.streamingChgnPer,
    ];
    {
      emit(FetchBasketOrdersStreamState(
        AppHelper().streamDetails(
          ordersDoneState.basketOrders.orders,
          streamingKeys,
        ),
      ));
    }
  }

  Future<void> responseCallback(
    ResponseData streamData,
    Emitter<BasketState> emit,
  ) async {
    if (ordersDoneState.basketOrders.orders?.isNotEmpty ?? false) {
      final List<Orders>? orders = ordersDoneState.basketOrders.orders;

      if (orders != null) {
        final String symbolName = streamData.symbol!;
        if (orders.isNotEmpty) {
          for (int i = 0; i < orders.length; i++) {
            if (orders[i].sym!.streamSym == symbolName) {
              orders[i].ltp = streamData.ltp ?? orders[i].ltp;
              orders[i].chng = streamData.chng ?? orders[i].chng;
              orders[i].chngPer = streamData.chngPer ?? orders[i].chngPer;
              emit(BasketOrdersChangeState());
              emit(ordersDoneState..basketOrders.orders = orders);
            }
          }
        }
      }
    }
  }

  Future<void> onExecuteBasketOrderEvent(
      ExecuteBasketOrdersEvent event, Emitter<BasketState> emit) async {
    emit(ExecuteBasketOrdersLoading());

    try {
      final BaseRequest request = BaseRequest();
      request.addToData('type', "placebasket");
      request.addToData('orders',
          List.from(event.basketOrders.orders?.map((e) => e.toJson()) ?? []));

      BaseModel response = await BasketRepository().executeBasketorder(request);
      showToast(message: response.infoMsg);
      emit(ExecuteBasketOrdersDone());
    } on FailedException catch (ex) {
      emit(ExecuteBasketOrdersDone());
      showToast(
        message: ex.msg,
        isError: true,
      );
    }
  }

  Future<void> onDeleteBasketOrderEvent(
      DeleteBasketOrderEvent event, Emitter<BasketState> emit) async {
    emit(DeleteBasketOrdersLoading());

    try {
      final BaseRequest request = BaseRequest();
      request.addToData('basketOrderId', event.basketOrderId);

      BaseModel response = await BasketRepository().deleteBasketorder(request);
      showToast(message: response.infoMsg);
      emit(DeleteBasketOrdersDone());
    } on FailedException catch (ex) {
      emit(DeleteBasketOrdersDone());
      showToast(
        message: ex.msg,
        isError: true,
      );
    }
  }

  Future<void> onDeleteBasketEvent(
      DeleteBasketEvent event, Emitter<BasketState> emit) async {
    emit(DeleteBasketLoading());

    try {
      final BaseRequest request = BaseRequest();
      request.addToData('basketIds', [event.basketId]);

      BaseModel response = await BasketRepository().deleteBasket(request);
      showToast(message: response.infoMsg);
      emit(DeleteBasketDone());
    } on FailedException catch (ex) {
      emit(DeleteBasketDone());
      showToast(
        message: ex.msg,
        isError: true,
      );
    }
  }

  Future<void> onRenameBasketEvent(
      RenameBasketEvent event, Emitter<BasketState> emit) async {
    emit(RenameBasketLoading());

    try {
      final BaseRequest request = BaseRequest();
      request.addToData('basketId', event.basketId);
      request.addToData('basketName', event.basketName);

      BaseModel response = await BasketRepository().renameBasket(request);
      showToast(message: response.infoMsg);
      emit(RenameBasketDone());
    } on FailedException catch (ex) {
      emit(RenameBasketDone());
      showToast(
        message: ex.msg,
        isError: true,
      );
    }
  }

  Future<void> onRearrangeBasketOrderEvent(
      RearrangeBasketOrderEvent event, Emitter<BasketState> emit) async {
    if (ordersDoneState.basketOrders.orders?.isEmpty ?? true) {
      emit(FetchBasketOrderLoading());
    }
    final List<Orders> symbols = ordersDoneState.basketOrders.orders ?? [];
    final Orders symbolAtOldPosition = symbols[event.oldPosition];
    symbols.removeAt(event.oldPosition);
    final int newIndex = event.oldPosition < event.newposition
        ? event.newposition - 1
        : event.newposition;
    symbols.insert(newIndex, symbolAtOldPosition);
    ordersDoneState.basketOrders.orders = symbols;
    emit(ordersDoneState);
    try {
      final BaseRequest request = BaseRequest();
      request.addToData('basketId', event.basketId);
      request.addToData('orderDtls', event.orderDtls);

      BaseModel response = await BasketRepository().rearrangeBasket(request);
      showToast(message: response.infoMsg);
      emit(RearrangeBasketOrderDone());
    } on FailedException catch (ex) {
      emit(RearrangeBasketOrderDone());
      showToast(
        message: ex.msg,
        isError: true,
      );
    }
  }

  Future<void> onResetBasketEvent(
      ResetBasketEvent event, Emitter<BasketState> emit) async {
    emit(ResetBasketLoading());

    try {
      final BaseRequest request = BaseRequest();
      request.addToData('basketId', event.basketId);

      BaseModel response = await BasketRepository().resetBasket(request);
      showToast(message: response.infoMsg);
      emit(ResetBasketDone());
    } on FailedException catch (ex) {
      emit(ResetBasketDone());
      showToast(
        message: ex.msg,
        isError: true,
      );
    }
  }

  Future<void> onMargincalculateEvent(
      MarginCalculatorEvent event, Emitter<BasketState> emit) async {
    final BaseRequest request = BaseRequest();
    request.addToData(
        'symbols',
        event.symbolList
            .where((element) => (!(element.isExecutable ?? false) ||
                (element.isModifiable ?? false)))
            .toList());
    try {
      BaseModel response = await BasketRepository().marginCalculate(request);
      emit(fetchBasketDone..marigin = response.data["totalMarginPrice"] ?? "");
    } on ServiceException {
      // emit(BasketError()
      //   ..errorCode = ex.code
      //   ..errorMsg = ex.msg);
      // throw (ServiceException(ex.code, ex.msg));
    } on FailedException {
      // emit(BasketError()
      //   ..errorCode = ex.code
      //   ..errorMsg = ex.msg);
    }
    emit(MarginCalculatorDone());
  }

  @override
  BasketState getErrorState() {
    return BasketError();
  }
}
