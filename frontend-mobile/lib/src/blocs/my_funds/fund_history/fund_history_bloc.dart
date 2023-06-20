import '../../../data/store/app_storage.dart';

import '../../common/screen_state.dart';
import '../../../constants/app_constants.dart';
import '../../../data/repository/my_funds/my_funds_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

import '../../../models/my_funds/transaction_history_model.dart';
import '../../common/base_bloc.dart';

part 'fund_history_event.dart';
part 'fund_history_state.dart';

class FundhistoryBloc extends BaseBloc<FundHistoryEvent, FundHistoryState> {
  FundhistoryBloc() : super(FundHistoryInitial());

  FundTransactionHistoryDoneState fundTransactionHistoryDoneState =
      FundTransactionHistoryDoneState();

  @override
  Future<void> eventHandlerMethod(
      FundHistoryEvent event, Emitter<FundHistoryState> emit) async {
    if (event is GetTransactionHistoryEvent) {
      await _handleGetTransactionHistoryEvent(event, emit);
    } else if (event is FundHistoryOptionSelectedEvent) {
      await _handleFundHistoryOptionSelectedEvent(event, emit);
    } else if (event is FundHistoryDateSelectEvent) {
      await _handleFundHistoryDateSelectEvent(event, emit);
    } else if (event is GetTransactionClearDateEvent) {
      await _handleGetTransactionClearDateEvent(event, emit);
    } else if (event is FundHistoryCancelEvent) {
      await _handleFundHistoryCancelEvent(event, emit);
    }
  }

  Future<void> _handleFundHistoryCancelEvent(
    FundHistoryCancelEvent event,
    Emitter<FundHistoryState> emit,
  ) async {
    AppStorage().removeData('getFundHistorydata');
    emit(FundHistoryProgressState());

    try {
      final BaseRequest request = BaseRequest();
      request.addToData('refNo', event.idvalue);

      Map<String, dynamic> respData =
          await MyFundsRepository().getTransactionHistoryCancelRequest(request);
      String infoID = respData['response']['infoID'];

      emit(FundHistoryChangedState());

      if (infoID == '0') {
        emit(FundHistoryCancelDoneState()
          ..message = "Cancel Request is Successful");
      } else {
        emit(FundHistoryCancelFailedState()
          ..message = respData['response']['infoMsg']);
      }
    } on ServiceException catch (ex) {
      emit(FundHistoryFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(FundHistoryErrorState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleGetTransactionClearDateEvent(
    GetTransactionClearDateEvent event,
    Emitter<FundHistoryState> emit,
  ) async {
    emit(FundHistoryChangedState());
    emit(fundTransactionHistoryDoneState
      ..transactionHistoryModel = null
      ..filteredhistorydata = null
      ..selectedFromDate = ''
      ..selectedToDate = ''
      ..isTickMarkEnable = false);
  }

  Future<void> _handleFundHistoryDateSelectEvent(
    FundHistoryDateSelectEvent event,
    Emitter<FundHistoryState> emit,
  ) async {
    bool isCloseMark = false;
    bool isTickMarkEnable =
        (event.selectedFromDate.isNotEmpty && event.selectedToDate.isNotEmpty)
            ? true
            : false;

    if (isTickMarkEnable == true) {
      isCloseMark = false;
    }

    TransactionHistoryModel? datamodel;
    if (fundTransactionHistoryDoneState.transactionHistoryModel != null) {
      if (fundTransactionHistoryDoneState
          .transactionHistoryModel!.history!.isNotEmpty) {
        datamodel = fundTransactionHistoryDoneState.transactionHistoryModel;
        if (fundTransactionHistoryDoneState.isShowCrossMark == true) {
          isCloseMark = false;
        }
      }
    }

    emit(FundHistoryChangedState());
    emit(fundTransactionHistoryDoneState
      ..transactionHistoryModel = datamodel
      ..filteredhistorydata = null
      ..selectedFromDate = event.selectedFromDate
      ..selectedToDate = event.selectedToDate
      ..isShowCrossMark = isCloseMark
      ..isTickMarkEnable = isTickMarkEnable);
  }

  Future<void> _handleFundHistoryOptionSelectedEvent(
    FundHistoryOptionSelectedEvent event,
    Emitter<FundHistoryState> emit,
  ) async {
    emit(FundHistoryChangedState());
    emit(FundHistoryOptionSelectedDoneState()
      ..selectedValue = event.selectedValue);
  }

  void _frameBankDisplay(List<History> data) {
    List<History> history = data;
    Map.fromIterable(history, key: (item) {
      if (item.bankAccNo != null) {
        if (item.bankAccNo!.isNotEmpty) {
          String accountno = '';
          if (item.bankAccNo!.length > 4) {
            var newString =
                item.bankAccNo!.substring(item.bankAccNo!.length - 4);
            accountno = '****$newString';
          } else {
            accountno = '****$item.bankAccNo';
          }
          item.dispAccnumber = accountno;
        }
      }
    });
  }

  Future<void> _handleGetTransactionHistoryEvent(
    GetTransactionHistoryEvent event,
    Emitter<FundHistoryState> emit,
  ) async {
    debugPrint('event.selectedSegment -> ${event.selectedSegment}');

    if (event.selectedSegment == AppConstants.customdates) {
      if (event.fromdate.isNotEmpty && event.todate.isNotEmpty) {
        if (DateFormat('dd/MM/yyyy')
                .parse(event.fromdate)
                .isBefore(DateFormat('dd/MM/yyyy').parse(event.todate)) ||
            DateFormat('dd/MM/yyyy')
                    .parse(event.fromdate)
                    .compareTo(DateFormat('dd/MM/yyyy').parse(event.todate)) ==
                0) {
          emit(FundHistoryProgressState());
          try {
            final BaseRequest request = BaseRequest();

            request.addToData("frmDte", event.fromdate);
            request.addToData("toDte", event.todate);

            TransactionHistoryModel transactionHistoryModel =
                await MyFundsRepository().getTransactionHistoryRequest(request);
            _frameBankDisplay(transactionHistoryModel.history!);

            emit(FundHistoryChangedState());

            emit(fundTransactionHistoryDoneState
              ..transactionHistoryModel = transactionHistoryModel
              ..filteredhistorydata = null
              ..isCustomDateOptionSelected = true
              ..isShowCrossMark = true);
          } on ServiceException catch (ex) {
            emit(FundHistoryFailedState()
              ..errorCode = ex.code
              ..errorMsg = ex.msg);
            throw (ServiceException(ex.code, ex.msg));
          } on FailedException catch (ex) {
            emit(FundHistoryChangedState());
            emit(fundTransactionHistoryDoneState
              ..transactionHistoryModel = null
              ..filteredhistorydata = null
              ..isCustomDateOptionSelected = true
              ..isShowCrossMark = true
              ..isHideTextDescription = true);

            emit(FundHistoryTransactionErrorState()
              ..errorCode = ex.code
              ..errorMsg = ex.msg);
          }
        } else {
          emit(FundHistoryShowCalenderErrorDoneState()
            ..msg = 'To Date should be greater than From date');
        }
      } else {
        emit(FundHistoryChangedState());
        emit(fundTransactionHistoryDoneState
          ..transactionHistoryModel = null
          ..filteredhistorydata = null
          ..isCustomDateOptionSelected = true
          ..isShowCrossMark = false
          ..isHideTextDescription = false);
      }
    } else {
      dynamic data = await AppStorage().getData('getFundHistorydata');
      if (data != null) {
        if (data.keys.contains('errorcode')) {
          emit(FundHistoryChangedState());
          emit(fundTransactionHistoryDoneState
            ..transactionHistoryModel = null
            ..filteredhistorydata = null
            ..isCustomDateOptionSelected = false
            ..isShowCrossMark = false
            ..isHideTextDescription = true);

          emit(FundHistoryTransactionErrorState()
            ..errorCode = data['errorcode']
            ..errorMsg = data['errormsg']);
        } else if (!data.keys.contains('errorcode')) {
          TransactionHistoryModel transactionHistoryModel =
              TransactionHistoryModel.datafromJson(data);
          _frameBankDisplay(transactionHistoryModel.history!);

          List<History>? filteredOption;
          if (event.selectedSegment.isNotEmpty) {
            bool statusvalue = (event.selectedSegment == AppConstants.fundadded)
                ? true
                : false;
            filteredOption = transactionHistoryModel.history!.where((element) {
              if (element.payIn == statusvalue &&
                  element.status?.toLowerCase() != "failure") {
                return true;
              }
              return false;
            }).toList();
          }

          emit(FundHistoryChangedState());

          emit(fundTransactionHistoryDoneState
            ..transactionHistoryModel = transactionHistoryModel
            ..filteredhistorydata = filteredOption
            ..isCustomDateOptionSelected = false);
        }
      } else {
        emit(FundHistoryProgressState());
        try {
          final BaseRequest request = BaseRequest();

          var now = DateTime.now();
          var formatter = DateFormat('dd/MM/yyyy');
          String tDate = formatter.format(now);

          var prevMonth = DateTime(now.year, now.month - 1, now.day);
          String fDate = formatter.format(prevMonth);

          request.addToData("frmDte", fDate);
          request.addToData("toDte", tDate);

          TransactionHistoryModel transactionHistoryModel =
              await MyFundsRepository().getTransactionHistoryRequest(request);

          AppStorage().setData('getFundHistorydata', transactionHistoryModel);
          _frameBankDisplay(transactionHistoryModel.history!);

          List<History>? filteredOption;
          if (event.selectedSegment.isNotEmpty) {
            bool statusvalue = (event.selectedSegment == AppConstants.fundadded)
                ? true
                : false;

            filteredOption = transactionHistoryModel.history!.where((element) {
              if (element.payIn == statusvalue) {
                return true;
              }
              return false;
            }).toList();
          }

          emit(FundHistoryChangedState());

          emit(fundTransactionHistoryDoneState
            ..transactionHistoryModel = transactionHistoryModel
            ..filteredhistorydata = filteredOption
            ..isCustomDateOptionSelected = false);
        } on ServiceException catch (ex) {
          emit(FundHistoryFailedState()
            ..errorCode = ex.code
            ..errorMsg = ex.msg);
          throw (ServiceException(ex.code, ex.msg));
        } on FailedException catch (ex) {
          AppStorage().setData(
              'getFundHistorydata', {"errorcode": ex.code, "errormsg": ex.msg});
          emit(FundHistoryChangedState());
          emit(fundTransactionHistoryDoneState
            ..transactionHistoryModel = null
            ..filteredhistorydata = null
            ..isCustomDateOptionSelected = false
            ..isShowCrossMark = false
            ..isHideTextDescription = true);

          emit(FundHistoryTransactionErrorState()
            ..errorCode = ex.code
            ..errorMsg = ex.msg);
        }
      }
    }
  }

  @override
  FundHistoryState getErrorState() {
    return FundHistoryErrorState();
  }
}
