import 'dart:async';

import 'package:acml/src/localization/app_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_model.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

import '../../constants/app_constants.dart';
import '../../data/cache/cache_repository.dart';
import '../../data/repository/order/order_repository.dart';
import '../../data/store/app_helper.dart';
import '../../data/store/app_utils.dart';
import '../../models/orders/order_book.dart';
import '../../models/sort_filter/sort_filter_model.dart';
import '../common/base_bloc.dart';
import '../common/screen_state.dart';

part 'orders_event.dart';
part 'orders_state.dart';

class OrdersBloc extends BaseBloc<OrdersEvent, OrdersState> {
  OrdersBloc() : super(OrdersInitial());
  OrdersDoneState ordersDoneState = OrdersDoneState();

  late List<Orders> ordersFullModelData;

  @override
  Future<void> eventHandlerMethod(
      OrdersEvent event, Emitter<OrdersState> emit) async {
    if (event is OrdersBookEvent) {
      await _handleOrdersBookEvent(emit, event);
    } else if (event is StartSymStreamEvent) {
      await sendStream(emit);
    } else if (event is StreamingResponseEvent) {
      await responseCallback(event.data, emit);
    } else if (event is OrderBookCancelEvent) {
      await _cancelOrders(event, emit);
    } else if (event is OrderBookExitEvent) {
      await _handleOrderBookExitEvent(event, emit);
    } else if (event is OrdersSearchEvent) {
      await _handleOrdersSearchEvent(event, emit);
    } else if (event is OrdersResetSearchEvent) {
      await _handleOrdersResetSearchEvent(emit);
    }
  }

  num orderValue(Orders order) {
    num qty = AppUtils().doubleValue(AppUtils().decimalValue(order.qty));
    num avgPrice =
        AppUtils().doubleValue(AppUtils().decimalValue(order.avgPrice));

    return (qty * avgPrice);
  }

  List<Filters>? validityfilter;
  Future<void> _handleOrdersBookEvent(
    Emitter<OrdersState> emit,
    OrdersBookEvent event,
  ) async {
    if (event.loading) {
      emit(OrdersProgressState());
    }
    try {
      final BaseRequest request = BaseRequest();
      List<Filters> multiFilters = <Filters>[];
      List<String> filterKeys = [
        AppConstants.ordAction,
        AppConstants.actualExc,
        AppConstants.tab,
        AppConstants.instrument,
        AppConstants.prdType,
        AppConstants.ordType,
        AppConstants.isAmo,
      ];
      validityfilter = null;

      if (event.filterModel != null && event.filterModel!.isNotEmpty) {
        int i = 0;
        String isAmo = "false";
        for (FilterModel element in event.filterModel!) {
          List<String> filters = [];
          if (element.filterName != AppLocalizations().validity) {
            for (Filters element in element.filtersList!) {
              if (element.value != AppConstants.amo) {
                if (element.value == AppConstants.fo) {
                  element.value = AppConstants.nfo;
                }
                if (element.value == AppConstants.carryForward) {
                  element.value = AppConstants.carryForwardValue;
                }
                if (element.value != AppConstants.gtd) {
                  filters.add(element.value);
                }
              } else {
                isAmo = "true";
              }
            }
          } else {
            validityfilter = element.filtersList;
          }
          if (filters.isNotEmpty) {
            multiFilters.add(Filters(key: filterKeys[i], value: filters));
          }
          if (isAmo == "true") {
            multiFilters.add(Filters(key: AppConstants.isAmo, value: [isAmo]));
          }

          i++;
        }
      }
      request.addToData(('multiFilters'), multiFilters);
      if (event.fetchAgain) {
        final OrderBook? getOrdersCache = await CacheRepository.orderbook
            .get(event.isgtdorder ? 'getgtdOrders' : 'getOrders');
        if (getOrdersCache != null &&
            (getOrdersCache.orders?.isNotEmpty ?? false)) {
          afterApiFetch(getOrdersCache, emit, isGtd: event.isgtdorder);
          await afterFetch(event, emit);
        }
        final OrderBook orderBook = await OrderRepository()
            .getOrderBookRequest(request, isGtdorder: event.isgtdorder);

        afterApiFetch(orderBook, emit, isGtd: event.isgtdorder);
      }

      await afterFetch(event, emit);
    } on ServiceException catch (ex) {
      emit(OrdersServiceExceptionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(OrdersProgressState());

      if (ex.msg == "No data available" &&
          (event.filterModel != null || event.selectedSort?.sortType != null)) {
        CacheRepository.orderbook.clearAll();

        ordersDoneState.orderBook = OrderBook(orders: []);

        ordersDoneState.mainOrdersSymbols = [];
        ordersFullModelData = [];

        emit(ordersDoneState);
      } else {
        emit(OrdersFailedState()
          ..errorCode = ex.code
          ..errorMsg = ex.msg);
      }
    }
  }

  Future<void> afterFetch(
      OrdersBookEvent event, Emitter<OrdersState> emit) async {
    if (event.selectedSort != null && event.selectedSort!.sortName != null) {
      await _handleSortOrdersWithFilter(event.selectedSort!, emit);
    }
    await Future.delayed(const Duration(milliseconds: 200));
    await sendStream(emit);
  }

  void afterApiFetch(OrderBook orderBook, Emitter<OrdersState> emit,
      {bool isGtd = false}) {
    emit(OrdersChangeState());
    ordersDoneState.orderBook = orderBook;
    ordersDoneState.orderBook?.orders = orderBook.orders
        ?.where((element) => (validityfilter?.isEmpty ?? true)
            ? true
            : validityfilter
                    ?.where((e) => (element.comments?.toUpperCase() ==
                                AppConstants.gtd.toUpperCase()) &&
                            e.value.toString().toLowerCase() ==
                                AppConstants.gtd.toLowerCase()
                        ? true
                        : e.value.toString().toLowerCase() ==
                            element.ordDuration?.toLowerCase())
                    .toList()
                    .isNotEmpty ??
                true)
        .toList();
    if (isGtd) {
      ordersDoneState.orderBook?.orders?.sort(
          (Orders a, Orders b) => b.ordDate!.compareTo(a.ordDate.toString()));
    }
    ordersDoneState.mainOrdersSymbols =
        List.from(ordersDoneState.orderBook!.orders!);
    ordersFullModelData = List.from(ordersDoneState.orderBook!.orders!);

    emit(ordersDoneState);
  }

  Future<void> _handleSortOrdersWithFilter(
    SortModel selectedSort,
    Emitter<OrdersState> emit,
  ) async {
    final List<Orders> orders = ordersDoneState.mainOrdersSymbols!;

    if (selectedSort.sortName == AppConstants.orderValue) {
      if (selectedSort.sortType == Sort.ASCENDING) {
        orders.sort(
            (Orders a, Orders b) => orderValue(b).compareTo(orderValue(a)));
      } else {
        orders.sort(
            (Orders a, Orders b) => orderValue(a).compareTo(orderValue(b)));
      }
    } else if (selectedSort.sortName == AppConstants.quantity) {
      if (selectedSort.sortType == Sort.ASCENDING) {
        orders.sort((Orders a, Orders b) => AppUtils()
            .doubleValue(AppUtils().decimalValue(b.qty ?? '0'))
            .compareTo(
                AppUtils().doubleValue(AppUtils().decimalValue(a.qty ?? '0'))));
      } else {
        orders.sort((Orders a, Orders b) => AppUtils()
            .doubleValue(AppUtils().decimalValue(a.qty ?? '0'))
            .compareTo(
                AppUtils().doubleValue(AppUtils().decimalValue(b.qty ?? '0'))));
      }
    } else if (selectedSort.sortName == AppConstants.time) {
      if (selectedSort.sortType == Sort.ASCENDING) {
        orders.sort((Orders a, Orders b) => AppUtils()
            .getDateTime(b.ordDate!, 'dd/MM/yyyy HH:mm:ss')
            .compareTo(
                AppUtils().getDateTime(a.ordDate!, 'dd/MM/yyyy HH:mm:ss')));
      } else {
        orders.sort((Orders a, Orders b) => AppUtils()
            .getDateTime(a.ordDate!, 'dd/MM/yyyy HH:mm:ss')
            .compareTo(
                AppUtils().getDateTime(b.ordDate!, 'dd/MM/yyyy HH:mm:ss')));
      }
    } else if (selectedSort.sortName == AppConstants.alphabetically) {
      if (selectedSort.sortType == Sort.ASCENDING) {
        orders.sort((Orders a, Orders b) {
          return a.dispSym!.toLowerCase().compareTo(b.dispSym!.toLowerCase());
        });
      } else {
        orders.sort((Orders a, Orders b) {
          return b.dispSym!.toLowerCase().compareTo(a.dispSym!.toLowerCase());
        });
      }
    }

    ordersDoneState.orderBook!.orders = orders;

    emit(OrdersChangeState());

    emit(ordersDoneState);
  }

  Future<void> sendStream(Emitter<OrdersState> emit) async {
    if (ordersDoneState.orderBook != null) {}
    final List<String> streamingKeys = <String>[
      AppConstants.streamingLtp,
      AppConstants.streamingChng,
      AppConstants.streamingChgnPer,
    ];
    {
      List<Orders> orders = [];
      for (int i = 0;
          i < (ordersDoneState.orderBook!.orders?.length ?? 0);
          i++) {
        if (orders
            .where((element) =>
                element.sym?.streamSym ==
                ordersDoneState.orderBook?.orders?[i].sym?.streamSym)
            .toList()
            .isEmpty) {
          orders.add(ordersDoneState.orderBook?.orders?[i] ?? Orders());
        }
      }
      emit(OrdersBookStreamState(
        AppHelper().streamDetails(
          orders,
          streamingKeys,
        ),
      ));
    }
  }

  Future<void> responseCallback(
    ResponseData streamData,
    Emitter<OrdersState> emit,
  ) async {
    if (ordersDoneState.orderBook != null) {
      final List<Orders>? orders = ordersDoneState.orderBook!.orders;

      if (orders != null) {
        final String symbolName = streamData.symbol!;
        if (orders.isNotEmpty) {
          for (int i = 0; i < orders.length; i++) {
            if (orders[i].sym!.streamSym == symbolName) {
              orders[i].ltp = streamData.ltp ?? orders[i].ltp;
              orders[i].chng = streamData.chng ?? orders[i].chng;
              orders[i].chngPer = streamData.chngPer ?? orders[i].chngPer;
              emit(OrdersChangeState());
              emit(ordersDoneState..orderBook!.orders = orders);
            }
          }
        }
      }
    }
  }

  Future<void> _handleOrdersSearchEvent(
    OrdersSearchEvent event,
    Emitter<OrdersState> emit,
  ) async {
    ordersFullModelData = event.orders;
    final List<Orders> symbolsFilteredUsingSubString =
        ordersFullModelData.where((Orders orders) {
      final String searchName = '${orders.dispSym!} ${orders.sym!.exc!}';
      return checkSymNameMatchesInputString(
        searchName,
        event.searchString,
      );
    }).toList();
    emit(OrdersChangeState());
    emit(
      ordersDoneState..searchOrdersSymbols = symbolsFilteredUsingSubString,
    );
  }

  Future<void> _handleOrdersResetSearchEvent(
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersChangeState());
    ordersDoneState.searchOrdersSymbols = [];
    emit(ordersDoneState..searchOrdersSymbols = []);
  }

  bool checkSymNameMatchesInputString(
    String symbolName,
    String input,
  ) {
    final List<String> queryArr = input.split(' ');

    final bool isMatch = queryArr.every((String element) {
      symbolName = symbolName.toLowerCase();
      return symbolName.startsWith(input.split(' ')[0].toLowerCase());
    });
    return isMatch;
  }

  Future<void> _cancelOrders(
      OrderBookCancelEvent event, Emitter<OrdersState> emit) async {
    try {
      final BaseRequest request = BaseRequest();
      request.addToData('ordId', event.orders.ordId);
      request.addToData('sym', event.orders.sym);
      request.addToData('triggerid', event.orders.triggerid);

      BaseModel baseModel = await OrderRepository()
          .getCancelOrderBookRequest(request, event.isGtd);
      emit(OrdersCancelDoneState(baseModel));
    } on ServiceException catch (ex) {
      emit(OrdersCancelFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(OrdersCancelServiceExceptionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleOrderBookExitEvent(
    OrderBookExitEvent event,
    Emitter<OrdersState> emit,
  ) async {
    try {
      final BaseRequest request = BaseRequest();
      request.addToData('ordId', event.orders.ordId);
      request.addToData('sym', event.orders.sym);
      if (event.orders.prdType!.toLowerCase() ==
              AppConstants.coverOrder.toLowerCase() ||
          event.orders.prdType!.toLowerCase() ==
              AppConstants.bracketOrder.toLowerCase()) {
        request.addToData('prdType', event.orders.prdType);
        request.addToData('parOrdId', event.orders.parOrdId);
      }
      if (event.orders.prdType!.toLowerCase() ==
          AppConstants.bracketOrder.toLowerCase()) {
        request.addToData('boOrdStatus', event.orders.boOrdStatus);
      }

      BaseModel baseModel =
          await OrderRepository().getExitOrderBookRequest(request);
      emit(OrdersExitDoneState(baseModel));
    } on ServiceException catch (ex) {
      emit(OrdersExitFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(OrdersExitServiceExceptionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  @override
  OrdersState getErrorState() {
    return OrdersErrorState();
  }
}
