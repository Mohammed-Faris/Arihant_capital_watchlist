import '../../../data/store/app_storage.dart';
import '../../../data/store/app_utils.dart';
import '../../../models/my_funds/fund_view_limit_model.dart';
import '../../../models/my_funds/my_fund_view_updated_model.dart';
import '../../../data/cache/cache_repository.dart';
import '../../common/screen_state.dart';
import '../../../data/repository/funds/funds_repository.dart';
import '../../../data/repository/my_funds/my_funds_repository.dart';
import '../../../models/my_funds/transaction_history_model.dart';
import '../../../models/my_funds/withdraw_funds_max_payout_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';
import '../../common/base_bloc.dart';
part 'my_funds_event.dart';
part 'my_funds_state.dart';

class MyFundsBloc extends BaseBloc<MyfundsEvent, MyFundsState> {
  MyFundsBloc() : super(MyFundsInitial());

  BuyPowerandWithdrawcashDoneState buyPowerandWithdrawcashDoneState =
      BuyPowerandWithdrawcashDoneState();
  final GetMaxPayoutWithdrawCashDoneState getMaxPayoutWithdrawCashDoneState =
      GetMaxPayoutWithdrawCashDoneState();

  bool isWithdraw = false;
  bool isbuypower = false;
  // bool _isWithdrawFundBuyPowerandWithdrawcash = false;

  @override
  Future<void> eventHandlerMethod(
      MyfundsEvent event, Emitter<MyFundsState> emit) async {
    if (event is GetMaxPayoutWithdrawalCashEvent) {
      await _handleGetMaxPayoutWithdrawalCashEvent(event, emit);
    } else if (event is GetFundsViewEvent) {
      await _handleGetFundsViewEvent(event, emit);
    } else if (event is GetFundsViewUpdatedEvent) {
      await _handleGetFundsViewUpdatedEvent(event, emit);
    } else if (event is GetTransactionHistoryEvent) {
      await _handleGetTransactionHistoryEvent(event, emit);
    } else if (event is GetTransactionHistoryCancelEvent) {
      await _handleGetTransactionHistoryCancelEvent(event, emit);
    }
  }

  Future<void> _handleGetTransactionHistoryCancelEvent(
    GetTransactionHistoryCancelEvent event,
    Emitter<MyFundsState> emit,
  ) async {
    emit(MyFundsProgressState());
    try {
      AppStorage().removeData('getRecentFundTransaction');
      final BaseRequest request = BaseRequest();
      request.addToData('refNo', event.idvalue);

      Map<String, dynamic> respData =
          await MyFundsRepository().getTransactionHistoryCancelRequest(request);
      String infoID = respData['response']['infoID'];

      emit(MyFundsChangedState());

      if (infoID == '0') {
        emit(MyFundsTransactionHistoryCancelDoneState()
          ..message = "Cancel Request is Successful");
      } else {
        emit(MyFundsTransactionHistoryCancelFailedDoneState()
          ..message = respData['response']['infoMsg']);
      }
    } on ServiceException catch (ex) {
      emit(MyFundsFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(MyFundsCancelErrorState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
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
    Emitter<MyFundsState> emit,
  ) async {
    //Map<String, dynamic>
    dynamic data = await AppStorage().getData('getRecentFundTransaction');

    if (data != null) {
      if (data.keys.contains('errorcode')) {
        //failed
        emit(MyFundsTransactionErrorState()
          ..errorCode = data['errorcode']
          ..errorMsg = data['errormsg']);
      } else if (!data.keys.contains('errorcode')) {
        TransactionHistoryModel transactionHistoryModel =
            TransactionHistoryModel.datafromJson(data);

        _frameBankDisplay(transactionHistoryModel.history!);

        emit(MyFundsChangedState());
        emit(MyFundsTransactionHistoryDoneState()
          ..transactionHistoryModel = transactionHistoryModel);
      }
    } else {
      emit(MyFundsProgressState());

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

        _frameBankDisplay(transactionHistoryModel.history!);

        AppStorage()
            .setData('getRecentFundTransaction', transactionHistoryModel);
        emit(MyFundsChangedState());

        emit(MyFundsTransactionHistoryDoneState()
          ..transactionHistoryModel = transactionHistoryModel);
      } on ServiceException catch (ex) {
        emit(MyFundsFailedState()
          ..errorCode = ex.code
          ..errorMsg = ex.msg);
        throw (ServiceException(ex.code, ex.msg));
      } on FailedException catch (ex) {
        AppStorage().setData('getRecentFundTransaction',
            {"errorcode": ex.code, "errormsg": ex.msg});
        emit(MyFundsTransactionErrorState()
          ..errorCode = ex.code
          ..errorMsg = ex.msg);
      }
    }
  }

  Future<void> _handleGetFundsViewUpdatedEvent(
    GetFundsViewUpdatedEvent event,
    Emitter<MyFundsState> emit,
  ) async {
    try {
      final BaseRequest request = BaseRequest();
      request.addToData('segment', ['ALL']);
      final getFundViewUpdateModel =
          await CacheRepository.groupCache.get('fundViewUpdatedModel');

      late FundViewUpdatedModel fundViewUpdatedModel;

      if (getFundViewUpdateModel == null || event.fetchApi) {
        fundViewUpdatedModel =
            await FundsRepository().getFundViewUpdatedModel(request);
        AppStorage().setData('getFundViewUpdatedModel', fundViewUpdatedModel);
      }
    } on ServiceException catch (ex) {
      emit(MyFundsErrorState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(MyFundsErrorState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleGetFundsViewEvent(
    GetFundsViewEvent event,
    Emitter<MyFundsState> emit,
  ) async {
    try {
      final BaseRequest request = BaseRequest();
      final getFundViewLimitModel =
          await CacheRepository.groupCache.get('getFundViewLimitModel');

      late FundViewLimitModel fundViewModel;
      if (getFundViewLimitModel != null) {
        fundViewModel = getFundViewLimitModel;
        buyPowerUpdate(emit, fundViewModel);
      }
      if (getFundViewLimitModel == null || event.fetchApi) {
        fundViewModel = await FundsRepository().getFundViewLimitModel(request);
      } else {
        fundViewModel = getFundViewLimitModel;
      }
      buyPowerUpdate(emit, fundViewModel);
    } on ServiceException catch (ex) {
      emit(MyFundsFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(MyFundsErrorState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  void buyPowerUpdate(
      Emitter<MyFundsState> emit, FundViewLimitModel fundViewModel) {
    emit(MyFundsChangedState());
    isbuypower = true;

    emit(buyPowerandWithdrawcashDoneState
      ..buy_power = fundViewModel.buypwr!
      ..account_balance = fundViewModel.openBalance!
      ..isFontreduce = false);

    if (isWithdraw == true && isbuypower == true) {
      if (fundViewModel.openBalance != null &&
          getMaxPayoutWithdrawCashDoneState.availableFundsModel != null) {
        String withdraw = getMaxPayoutWithdrawCashDoneState
            .availableFundsModel!.payReqResult!
            .elementAt(0)
            .maxPayout
            .toString();

        String buypower = fundViewModel.buypwr ?? "0";

        if (buypower.length > 13 || withdraw.length > 13) {
          emit(MyFundsChangedState());

          emit(buyPowerandWithdrawcashDoneState
            ..buy_power = fundViewModel.buypwr!
            ..account_balance = fundViewModel.openBalance!
            ..isFontreduce = true);

          emit(getMaxPayoutWithdrawCashDoneState
            ..availableFunds = getMaxPayoutWithdrawCashDoneState
                .availableFundsModel!.payReqResult!
                .elementAt(0)
                .maxPayout
                .toString()
            ..isFontreduce = true);
        }
      }
    }
  }

  Future<void> _handleGetMaxPayoutWithdrawalCashEvent(
    GetMaxPayoutWithdrawalCashEvent event,
    Emitter<MyFundsState> emit,
  ) async {
    try {
      final BaseRequest request = BaseRequest();

      final getMaxpayoutWithdrawCashModel =
          await CacheRepository.fundsCache.get('getMaxpayoutWithdrawCash');

      late WithdrawCashMaxPayoutModel availableFundsModel;
      if (getMaxpayoutWithdrawCashModel != null) {
        availableFundsModel =
            WithdrawCashMaxPayoutModel.fromJson(getMaxpayoutWithdrawCashModel);
        afterApiFetch(emit, availableFundsModel);
      }
      if (event.fetchApi) {
        availableFundsModel =
            await FundsRepository().getMaxpayoutWithdrawCash(request);
        afterApiFetch(emit, availableFundsModel);
      }
    } on ServiceException catch (ex) {
      emit(MyFundsWithdrawalErrorState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(MyFundsWithdrawalErrorState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  void afterApiFetch(Emitter<MyFundsState> emit,
      WithdrawCashMaxPayoutModel availableFundsModel) {
    emit(MyFundsChangedState());
    isWithdraw = true;
    getMaxPayoutWithdrawCashDoneState.availableFundsModel = availableFundsModel;

    String youcanwithdraw = '0.00';

    youcanwithdraw = AppUtils().commaFmt(
        availableFundsModel.payReqResult!.elementAt(0).maxPayout.toString());

    emit(getMaxPayoutWithdrawCashDoneState..availableFunds = youcanwithdraw);

    if (isWithdraw == true && isbuypower == true) {
      if (getMaxPayoutWithdrawCashDoneState.availableFundsModel != null) {
        String withdraw = youcanwithdraw;
        String buypower = buyPowerandWithdrawcashDoneState.buy_power;

        if (buypower.length > 13 || withdraw.length > 13) {
          emit(MyFundsChangedState());

          emit(buyPowerandWithdrawcashDoneState
            ..buy_power = buyPowerandWithdrawcashDoneState.buy_power
            ..account_balance = buyPowerandWithdrawcashDoneState.account_balance
            ..isFontreduce = true);

          emit(getMaxPayoutWithdrawCashDoneState
            ..availableFunds = youcanwithdraw
            ..isFontreduce = true);
        }
      }
    }
  }

  @override
  MyFundsState getErrorState() {
    return MyFundsErrorState();
  }
}
