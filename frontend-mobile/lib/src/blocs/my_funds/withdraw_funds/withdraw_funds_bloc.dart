import '../../../data/store/app_storage.dart';
import '../../../models/my_funds/my_fund_view_updated_model.dart';

import '../../../data/cache/cache_repository.dart';
import '../../common/screen_state.dart';
import '../../../constants/app_constants.dart';
import '../../../data/repository/funds/funds_repository.dart';
import '../../../data/repository/my_funds/my_funds_repository.dart';
import '../../../data/store/app_utils.dart';
import '../../../models/my_funds/bank_details_model.dart';
import '../../../models/my_funds/my_funds_view_model.dart';
import '../../../models/my_funds/transaction_history_model.dart';
import '../../../models/my_funds/withdraw_funds_max_payout_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

import '../../common/base_bloc.dart';

part 'withdraw_funds_event.dart';
part 'withdraw_funds_state.dart';

class WithdrawFundsBloc
    extends BaseBloc<WithdrawfundsEvent, WithdrawFundsState> {
  WithdrawFundsBloc() : super(WithdrawFundsInitial());

  final GetMaxPayoutWithdrawCashDoneState getMaxPayoutWithdrawCashDoneState =
      GetMaxPayoutWithdrawCashDoneState();

  WithdrawFundsGetbankListDoneState getbankListDoneState =
      WithdrawFundsGetbankListDoneState();

  WithdrawFundsGetbankListModifyDoneState getbankListModifyDoneState =
      WithdrawFundsGetbankListModifyDoneState();

  WithdrawFundsDoneState withdrawFundsDoneState = WithdrawFundsDoneState();
  WithdrawFundBuyPowerandWithdrawcashDoneState
      withdrawFundBuyPowerandWithdrawcashDoneState =
      WithdrawFundBuyPowerandWithdrawcashDoneState();

  bool _isWithdrawFundBuyPowerandWithdrawcash = false;
  bool _isMaxPayoutresponse = false;

  @override
  Future<void> eventHandlerMethod(
      WithdrawfundsEvent event, Emitter<WithdrawFundsState> emit) async {
    if (event is GetBankDetailsEvent) {
      await _handleGetbankdetilsEvent(event, emit);
    } else if (event is WithdrawfundsUpdatedBankdetailsEvent) {
      await _handleWithdrawfundsUpdatedBankdetailsEvent(event, emit);
    } else if (event is EnableAndDisableContinueButtonEvent) {
      await _handleEnableAndDisableContinueButtonEvent(event, emit);
    } else if (event is GetWithdrawFundsEvent) {
      await _handleGetWithdrawFundsEvent(event, emit);
    } else if (event is GetFundsViewEvent) {
      await _handleGetFundsViewEvent(event, emit);
    } else if (event is GetFundsViewUpdatedEvent) {
      await _handleGetFundsViewUpdatedEvent(event, emit);
    } else if (event is GetMaxPayoutWithdrawalCashEvent) {
      await _handleGetMaxPayoutWithdrawalCashEvent(event, emit);
    } else if (event is CheckForErrorMessageEvent) {
      await _handleCheckForErrorMessageEvent(event, emit);
    } else if (event is WithdrawfundsModifyUpdatedBankdetailsEvent) {
      await _handleWithdrawfundsModifyUpdatedBankdetailsEvent(event, emit);
    } else if (event is GetModifyWithdrawFundsEvent) {
      await _handleGetModifyWithdrawFundsEvent(event, emit);
    }
  }

  Future<void> _handleCheckForErrorMessageEvent(
    CheckForErrorMessageEvent event,
    Emitter<WithdrawFundsState> emit,
  ) async {
    double cashValue = 0;
    String errormsg = '';
    bool errorMsg = false;
    if (_isWithdrawFundBuyPowerandWithdrawcash == true) {
      if (getMaxPayoutWithdrawCashDoneState.availableFunds.isNotEmpty) {
        if (!getMaxPayoutWithdrawCashDoneState.availableFunds.contains('na')) {
          cashValue = AppUtils().doubleValue(AppUtils().removeCommaFmt(
              getMaxPayoutWithdrawCashDoneState.availableFunds));
        }
      }

      double value = AppUtils().doubleValue(event.amount.replaceAll(",", ""));

      if (cashValue < value) {
        errormsg = 'Enter the amount lesser than the withdrawal amount';
        errorMsg = true;
      }

      if (getMaxPayoutWithdrawCashDoneState.availableFunds.isNotEmpty ||
          _isMaxPayoutresponse == false) {
        if (getMaxPayoutWithdrawCashDoneState.availableFunds.contains('na')) {
          errormsg = '';
          errorMsg = false;
        }
      }
    }

    emit(ShowErrorMessageOnContinueButtonPressedState()
      ..isShowError = errorMsg
      ..errorMsg = errormsg);
  }

  Future<void> _handleGetMaxPayoutWithdrawalCashEvent(
    GetMaxPayoutWithdrawalCashEvent event,
    Emitter<WithdrawFundsState> emit,
  ) async {
    try {
      final BaseRequest request = BaseRequest();
      late WithdrawCashMaxPayoutModel availableFundsModel;
      final getMaxpayoutWithdrawCashModel =
          await CacheRepository.fundsCache.get('getMaxpayoutWithdrawCash');
      if (getMaxpayoutWithdrawCashModel == null || event.fetchApi) {
        availableFundsModel =
            await FundsRepository().getMaxpayoutWithdrawCash(request);
      } else {
        availableFundsModel =
            WithdrawCashMaxPayoutModel.fromJson(getMaxpayoutWithdrawCashModel);
      }
      emit(WithdrawFundsChangedState());

      String youcanwithdraw = '0.00';

      youcanwithdraw =
          availableFundsModel.payReqResult!.elementAt(0).maxPayout.toString();
      emit(getMaxPayoutWithdrawCashDoneState
        ..availableFunds = AppUtils().commaFmt(youcanwithdraw));
    } on ServiceException catch (ex) {
      _isMaxPayoutresponse = false;
      emit(WithdrawFundsFailedState(ex.code, ex.msg)
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      _isMaxPayoutresponse = false;
      emit(GetMaxPayoutWithdrawCashFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleGetFundsViewUpdatedEvent(
    GetFundsViewUpdatedEvent event,
    Emitter<WithdrawFundsState> emit,
  ) async {
    dynamic data = await AppStorage().getData('getFundViewUpdatedModel');

    if (data == null) {
      try {
        final BaseRequest request = BaseRequest();
        request.addToData('segment', ['ALL']);
        FundViewUpdatedModel fundViewUpdatedModel =
            await FundsRepository().getFundViewUpdatedModel(request);
        AppStorage().setData('getFundViewUpdatedModel', fundViewUpdatedModel);
        _isWithdrawFundBuyPowerandWithdrawcash = true;
      } on ServiceException catch (ex) {
        _isWithdrawFundBuyPowerandWithdrawcash = false;
        emit(WithdrawFundsFailedState(ex.code, ex.msg)
          ..errorCode = ex.code
          ..errorMsg = ex.msg);
        throw (ServiceException(ex.code, ex.msg));
      } on FailedException catch (ex) {
        _isWithdrawFundBuyPowerandWithdrawcash = false;
        emit(WithdrawFundsFailedState(ex.code, ex.msg)
          ..errorCode = ex.code
          ..errorMsg = ex.msg);
      }
    } else {
      _isWithdrawFundBuyPowerandWithdrawcash = true;
    }
  }

  Future<void> _handleGetFundsViewEvent(
    GetFundsViewEvent event,
    Emitter<WithdrawFundsState> emit,
  ) async {
    emit(WithdrawFundsProgressState());
    try {
      final BaseRequest request = BaseRequest();
      FundViewModel fundViewModel =
          await FundsRepository().getFundViewModel(request);

      emit(WithdrawFundsChangedState());
      _isWithdrawFundBuyPowerandWithdrawcash = true;
      emit(withdrawFundBuyPowerandWithdrawcashDoneState
        ..fundViewModel = fundViewModel);
    } on ServiceException catch (ex) {
      _isWithdrawFundBuyPowerandWithdrawcash = false;
      emit(WithdrawFundsFailedState(ex.code, ex.msg)
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      _isWithdrawFundBuyPowerandWithdrawcash = false;
      emit(WithdrawFundsFailedState(ex.code, ex.msg)
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleGetModifyWithdrawFundsEvent(
    GetModifyWithdrawFundsEvent event,
    Emitter<WithdrawFundsState> emit,
  ) async {
    emit(WithdrawFundsConfirmationProgressState());
    try {
      final BaseRequest request = BaseRequest();
      request.addToData('amount', event.amount);
      request.addToData('instructionId', event.instructionId);

      Map<String, dynamic> respData =
          await MyFundsRepository().getTransactionHistoryModifyRequest(request);

      String infoMSG = respData['response']['infoID'];

      if (infoMSG == '0') {
        withdrawFundsDoneState
          ..isSuccess = true
          ..msg = respData['response']['infoMsg'];
      } else {
        withdrawFundsDoneState
          ..isSuccess = false
          ..msg = respData['response']['infoMsg'];
      }

      emit(WithdrawFundsChangedState());
      emit(withdrawFundsDoneState);
    } on ServiceException catch (ex) {
      emit(WithdrawFundsFailedState(ex.code, ex.msg)
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(WithdrawFundsFailedState(ex.code, ex.msg)
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    } catch (e) {
      emit(WithdrawFundsFailedState("", e.toString()));
    }
  }

  Future<void> _handleGetWithdrawFundsEvent(
      GetWithdrawFundsEvent event, Emitter<WithdrawFundsState> emit) async {
    emit(WithdrawFundsConfirmationProgressState());
    try {
      final BaseRequest request = BaseRequest();
      request.addToData('amount', AppUtils().removeCommaFmt(event.amount));
      request.addToData('bankName', event.bank_name);
      request.addToData('accountId', event.bank_account_id);

      Map<String, dynamic> respData =
          await MyFundsRepository().getWithdrawFunds(request);
      String infoMSG = respData['response']['infoID'];

      if (infoMSG == '0') {
        withdrawFundsDoneState
          ..isSuccess = true
          ..msg = respData['response']['infoMsg'];
      } else {
        withdrawFundsDoneState
          ..isSuccess = false
          ..msg = respData['response']['infoMsg'];
      }

      emit(WithdrawFundsChangedState());
      emit(withdrawFundsDoneState);
    } on ServiceException catch (ex) {
      emit(WithdrawFundsFailedState(ex.code, ex.msg)
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(WithdrawFundsFailedState(ex.code, ex.msg)
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    } catch (e) {
      emit(WithdrawFundsFailedState("", e.toString()));
    }
  }

  Future<void> _handleEnableAndDisableContinueButtonEvent(
      EnableAndDisableContinueButtonEvent event,
      Emitter<WithdrawFundsState> emit) async {
    bool val = false;
    if (event.amount.isNotEmpty) {
      double parseval =
          AppUtils().doubleValue(AppUtils().removeCommaFmt(event.amount));

      if (parseval > 0) {
        val = true;
      }
    }
    emit(WithdrawFundsChangedState());
    emit(EnableAndDisableContinueButtonState()
      ..isEnableButton = val
      ..withdrawAll = event.withdrawAll);
  }

  Future<void> _handleGetbankdetilsEvent(
      GetBankDetailsEvent event, Emitter<WithdrawFundsState> emit) async {
    dynamic data = await AppStorage().getData('getBankdetailkey');

    if (data != null) {
      final BankDetailsModel bankDetailsModel =
          BankDetailsModel.dataFromJson(data);

      List<Map<String, dynamic>> updateData =
          _getResultListToDisplay(bankDetailsModel.banks!);

      emit(getbankListDoneState
        ..bankDetailsModel = bankDetailsModel
        ..resultDataList = updateData
        ..isBankPrimary = true
        ..dataindex = 0);
    } else {
      emit(WithdrawFundsProgressState());
      try {
        final BaseRequest request = BaseRequest();
        final BankDetailsModel bankDetailsModel =
            await MyFundsRepository().getBankDetailsRequest(request);

        if (bankDetailsModel.banks != null &&
            bankDetailsModel.banks!.isNotEmpty) {
          emit(WithdrawFundsChangedState());

          AppStorage().setData('getBankdetailkey', bankDetailsModel);

          List<Map<String, dynamic>> updateData =
              _getResultListToDisplay(bankDetailsModel.banks!);

          emit(getbankListDoneState
            ..bankDetailsModel = bankDetailsModel
            ..resultDataList = updateData
            ..isBankPrimary = true
            ..dataindex = 0);
        } else {
          emit(WithdrawalFundsGetBankListNoData()..msg = 'No Banks Found');
        }
      } on ServiceException catch (ex) {
        if (ex.code.toLowerCase() == 's03') {
          emit(WithdrawalFundsGetBankListNoData()..msg = 'No Banks Found');
        } else {
          emit(WithdrawFundsFailedState(ex.code, ex.msg)
            ..errorCode = ex.code
            ..errorMsg = ex.msg);
        }
        throw (ServiceException(ex.code, ex.msg));
      } on FailedException catch (ex) {
        if (ex.code.toLowerCase() == 'egn001') {
          emit(WithdrawalFundsGetBankListNoData()..msg = 'No Banks Found');
        } else {
          emit(WithdrawFundsFailedState(ex.code, ex.msg)
            ..errorCode = ex.code
            ..errorMsg = ex.msg);
        }
      } catch (e) {
        emit(WithdrawFundsFailedState("", e.toString()));
      }
    }
  }

  Future<void> _handleWithdrawfundsModifyUpdatedBankdetailsEvent(
    WithdrawfundsModifyUpdatedBankdetailsEvent event,
    Emitter<WithdrawFundsState> emit,
  ) async {
    List<Map<String, dynamic>> updateData =
        _getResultListToDisplay(getbankListDoneState.bankDetailsModel!.banks!);

    int index = getbankListDoneState.bankDetailsModel!.banks!
        .indexWhere((Banks element) {
      if (event.history!.bankName != null &&
          event.history!.bankName!.isNotEmpty) {
        if (element.bankName!
            .toLowerCase()
            .contains(event.history!.bankName!.toLowerCase())) {
          return true;
        }
      }
      return element.isBankChoosen == true;
    });

    bool isBankPrimary = (index == 0) ? true : false;

    emit(WithdrawFundsChangedState());
    emit(getbankListModifyDoneState
      ..bankDetailsModel = getbankListDoneState.bankDetailsModel
      ..resultDataList = updateData
      ..dataindex = (index != -1) ? index : 0
      ..isBankPrimary = isBankPrimary);
  }

  Future<void> _handleWithdrawfundsUpdatedBankdetailsEvent(
      WithdrawfundsUpdatedBankdetailsEvent event,
      Emitter<WithdrawFundsState> emit) async {
    List<Map<String, dynamic>> updateData =
        _getResultListToDisplay(event.bankDetailsModel!.banks!);

    int index = event.bankDetailsModel!.banks!.indexWhere((Banks element) {
      return element.isBankChoosen == true;
    });

    bool isBankPrimary = (index == 0) ? true : false;

    emit(WithdrawFundsChangedState());
    emit(getbankListDoneState
      ..bankDetailsModel = event.bankDetailsModel
      ..resultDataList = updateData
      ..dataindex = (index != -1) ? index : 0
      ..isBankPrimary = isBankPrimary);
  }

  List<Map<String, dynamic>> _getResultListToDisplay(List<Banks> banklist) {
    List<Map<String, dynamic>> updateData = [];
    for (var element in banklist) {
      Map<String, dynamic> data = {};

      if (element.bankName != null) {
        data['bankName'] = element.bankName;

        data['bankLogo'] = (element.bankName!.isNotEmpty)
            ? _getBankLogoName(element.bankName!.toLowerCase())
            : _getBankLogoName('');

        data['accountno'] = '';
        if (element.accountNo != null) {
          if (element.accountNo!.isNotEmpty) {
            String accountno = '';
            if (element.accountNo!.length > 4) {
              var newString =
                  element.accountNo!.substring(element.accountNo!.length - 4);
              accountno = '****$newString';
            } else {
              accountno = '****${element.accountNo!}';
            }
            data['accountno'] = accountno;
          }
        }
      }
      updateData.add(data);
    }
    return updateData;
  }

  String _getBankLogoName(String bankname) {
    if (bankname.isNotEmpty) {
      int indexvalue = _getBankNameList().values.toList().indexOf(bankname);
      if (indexvalue != -1) {
        return _getBankNameList().keys.toList().elementAt(indexvalue);
      }
    }
    return AppConstants.DEFAULT_BANK;
  }

  Map<String, String> _getBankNameList() {
    return {
      AppConstants.AXIS_BANK: 'axis bank',
      AppConstants.AU_SMALL_BANK: 'au small finanace bank',
      AppConstants.BOB_BANK: 'bank of baroda net banking retail',
      AppConstants.BOB_BANK_CORPORATE: 'bank of baroda net banking corporate',
      AppConstants.BOI_BANK: 'bank of india',
      AppConstants.BOM_BANK: 'bank of maharashtra',
      AppConstants.CSB_BANK: 'csb bank',
      AppConstants.CITI_BANK: 'citibank na',
      AppConstants.CUB_BANK: 'city union bank',
      AppConstants.DEUTSCHE_BANK: 'deutsche bank',
      AppConstants.HDFC_BANK: 'hdfc bank',
      AppConstants.ICICI_BANK: 'icici bank',
      AppConstants.IDBI_BANK: 'idbi bank',
      AppConstants.INDIAN_BANK: 'indian bank',
      AppConstants.INDIAN_OVERSEAS_BANK: 'indian overseas bank',
      AppConstants.INDUSIND_BANK: 'indusind bank',
      AppConstants.SARASWAT_BANK: 'saraswat bank - retail',
      AppConstants.KARNATAKA_BANK: 'karnataka bank',
      AppConstants.LVB_BANK: 'lakshmi vilas bank netbanking',
      AppConstants.KMB_BANK: 'kotak mahindra bank',
      AppConstants.SBI_BANK: 'state bank of india',
      AppConstants.KVB_BANK: 'karur vysya bank',
      AppConstants.DHANLAXMI_BANK: 'dhanlaxmi bank',
      AppConstants.TMB_BANK: 'tamilnad mercantile bank',
      AppConstants.PUNJAB_SIND_BANK: 'punjab and sind bank',
      AppConstants.IDFC_FIRST_BANK: 'idfc first bank limited',
      AppConstants.FEDERAL_BANK: 'federal bank',
      AppConstants.JK_BANK: 'jammu and kashmir bank',
      AppConstants.YES_BANK: 'yes bank',
      AppConstants.RBL_BANK: 'rbl bank',
      AppConstants.UNION_BANK: 'union bank of india - retail',
      AppConstants.PNB_BANK: 'punjab national bank [retail]',
      AppConstants.PNB_BANK_CORPORATE: 'punjab national bank - corporate',
    };
  }

  @override
  WithdrawFundsState getErrorState() {
    return WithdrawErrorState();
  }
}
