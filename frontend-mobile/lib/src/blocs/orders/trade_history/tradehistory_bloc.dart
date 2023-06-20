import 'package:async/async.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

import '../../../data/repository/order/order_repository.dart';
import '../../../models/orders/tradehistory_model.dart';
import '../../../models/sort_filter/sort_filter_model.dart';
import '../../common/base_bloc.dart';
import '../../common/screen_state.dart';

part 'tradehistory_event.dart';
part 'tradehistory_state.dart';

class TradehistoryBloc extends BaseBloc<TradeHistoryEvent, TradeHistoryState> {
  TradehistoryBloc() : super(TradehistoryInitial());
  TradeHistoryFetchDone tradeHistoryDoneState = TradeHistoryFetchDone();
  CancelableOperation? fetchTrade;
  @override
  Future<void> eventHandlerMethod(
    TradeHistoryEvent event,
    Emitter<TradeHistoryState> emit,
  ) async {
    if (event is TradeHistoryFetch) {
      await _getTradeHistory(emit, event);
    }
    if (event is TradeHistoryClear) {
      await _clearData(emit, event);
    }
  }

  @override
  TradeHistoryState getErrorState() {
    return TradeHistoryFetchFail();
  }

  bool checkSymNameMatchesInputString(
    String symbolName,
    String input,
  ) {
    final bool isMatch = symbolName
        .replaceAll(" ", "")
        .toLowerCase()
        .contains(input.replaceAll(" ", "").toLowerCase());
    return isMatch;
  }

  _getTradeHistory(
      Emitter<TradeHistoryState> emit, TradeHistoryFetch event) async {
    emit(TradehistoryLoad());
    fetchTrade?.cancel();

    try {
      if (event.fetchApi) {
        fetchTrade = CancelableOperation.fromFuture(OrderRepository()
            .getTradeHistory(event.fromDate, event.toDate, event.filterModel));
        TradeHistory tradeHistory = await fetchTrade?.value;
        tradeHistory.reportList.sort((ReportList a, ReportList b) {
          return DateFormat(
                  "dd/MM/yyyy ${(b.tradeTime != null) ? "hh:mm a" : ""}")
              .parse(b.tradeDate)
              .compareTo(DateFormat(
                      "dd/MM/yyyy ${(a.tradeTime != null) ? "hh:mm a" : ""}")
                  .parse(a.tradeDate));
        });
        tradeHistoryDoneState.tradeHistory = tradeHistory;
        tradeHistoryDoneState.reportlist = tradeHistory.reportList;
      }
      if (event.search != "") {
        tradeHistoryDoneState.tradeHistory?.reportList =
            tradeHistoryDoneState.reportlist!
                .where(
                  (element) => event.search != ""
                      ? checkSymNameMatchesInputString(
                          element.companyName,
                          event.search,
                        )
                      : true,
                )
                .toList();
      } else {
        tradeHistoryDoneState.tradeHistory?.reportList =
            tradeHistoryDoneState.reportlist!;
      }
      emit(tradeHistoryDoneState
        ..fromDate = event.fromDate
        ..toDate = event.toDate);
    } on ServiceException catch (ex) {
      emit(TradeHistoryFetchFail()
        ..fromDate = event.fromDate
        ..toDate = event.toDate
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(TradeHistoryFetchFail()
        ..fromDate = event.fromDate
        ..toDate = event.toDate
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  _clearData(Emitter<TradeHistoryState> emit, TradeHistoryClear event) {
    emit(TradehistoryLoad());
    tradeHistoryDoneState.tradeHistory?.reportList = [];
    tradeHistoryDoneState.reportlist = [];
    emit(tradeHistoryDoneState);
  }
}
