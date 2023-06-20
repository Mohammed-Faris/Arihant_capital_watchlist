import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

import '../../../data/cache/cache_repository.dart';
import '../../../data/repository/funds/funds_repository.dart';
import '../../../data/repository/my_funds/my_funds_repository.dart';
import '../../../data/store/app_storage.dart';
import '../../../data/store/app_utils.dart';
import '../../../models/my_funds/bank_details_model.dart';
import '../../../models/my_funds/fund_view_limit_model.dart';
import '../../../models/my_funds/funds_transaction_status_model.dart';
import '../../../models/my_funds/get_payments_option_model.dart';
import '../../../models/my_funds/my_fund_view_updated_model.dart';
import '../../../models/my_funds/my_funds_view_model.dart';
import '../../../models/my_funds/net_bank_data_model.dart';
import '../../../models/my_funds/upi_data_model.dart';
import '../../common/base_bloc.dart';
import '../../common/screen_state.dart';

part 'add_funds_event.dart';
part 'add_funds_state.dart';

class AddFundsBloc extends BaseBloc<AddfundsEvent, AddFundsState> {
  AddFundsBloc() : super(AddFundsInitial());

  AddFundsGetbankListDoneState getbankListDoneState =
      AddFundsGetbankListDoneState();
  AddFundsUPIDataDoneState addFundsUPIDataDoneState =
      AddFundsUPIDataDoneState();
  AddFundUPITransactionStatusDoneState addFundUPITransactionStatusDoneState =
      AddFundUPITransactionStatusDoneState();
  AddFundBuyPowerandWithdrawcashDoneState
      addFundBuyPowerandWithdrawcashDoneState =
      AddFundBuyPowerandWithdrawcashDoneState();

  AddFundsGetBankListNoData addFundsGetBankListNoData =
      AddFundsGetBankListNoData();

  @override
  Future<void> eventHandlerMethod(
      AddfundsEvent event, Emitter<AddFundsState> emit) async {
    if (event is UpdateAmountEvent) {
      await _handleUpdateAmountEvent(event, emit);
    } else if (event is GetBankDetailsEvent) {
      await _handleGetbankdetilsEvent(event, emit);
    } else if (event is AddfundsUpdatedBankdetailsEvent) {
      await _handleAddfundsUpdatedBankdetailsEvent(event, emit);
    } else if (event is AddfundsfetchUPIDataEvent) {
      await _handleAddfundsfetchUPIDataEvent(event, emit);
    } else if (event is AddfundsfetchNetBankingDataEvent) {
      await _handleAddfundsfetchNetBankingDataEvent(event, emit);
    } else if (event is AddfundsfetchNetBankingDataEvent) {
      await _handleAddfundsfetchNetBankingDataEvent(event, emit);
    } else if (event is GetFundsViewEvent) {
      await _handleGetFundsViewEvent(event, emit);
    } else if (event is GetFundsViewUpdatedEvent) {
      await _handleGetFundsViewUpdatedEvent(event, emit);
    } else if (event is GetTransactionStatusEvent) {
      await _handleGetTransactionStatusEvent(event, emit);
    } else if (event is ShowPrefixIconEvent) {
      await _handleShowPrefixIconEvent(event, emit);
    }
  }

  Future<void> _handleShowPrefixIconEvent(
    ShowPrefixIconEvent event,
    Emitter<AddFundsState> emit,
  ) async {
    emit(AddFundsChangedState());
    emit(ShowPrefixIconState()..isShow = event.isShow);
  }

  Future<void> _handleGetTransactionStatusEvent(
    GetTransactionStatusEvent event,
    Emitter<AddFundsState> emit,
  ) async {
    emit(AddFundsProgressState());
    try {
      final BaseRequest request = BaseRequest();
      Uri myUri =
          Uri.parse(addFundsUPIDataDoneState.upiBankingDataModel!.payUrl!);

      if (myUri.queryParameters.isNotEmpty) {
        Map<String, String> data = myUri.queryParameters;
        String transactionID = data['tr'] ?? "";
        request.addToData('transID', transactionID);

        FundsTransactionStatusUPIModel fundsTransactionStatusModel =
            await FundsRepository().getFundTransactionStausModel(request);

        emit(AddFundsChangedState());
        emit(addFundUPITransactionStatusDoneState
          ..fundsTransactionStatusUPIModel = fundsTransactionStatusModel);
      }
    } on ServiceException catch (ex) {
      emit(AddFundsFailedState(ex.code, ex.msg)
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(AddFundsFailedState(ex.code, ex.msg)
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleGetFundsViewUpdatedEvent(
    GetFundsViewUpdatedEvent event,
    Emitter<AddFundsState> emit,
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
      emit(AddFundsFailedState(ex.code, ex.msg)
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(AddFundsFailedState(ex.code, ex.msg)
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleGetFundsViewEvent(
    GetFundsViewEvent event,
    Emitter<AddFundsState> emit,
  ) async {
    emit(AddFundsProgressState());
    try {
      final BaseRequest request = BaseRequest();
      final getFundViewLimitModel =
          await CacheRepository.groupCache.get('getFundViewLimitModel');

      late FundViewLimitModel fundViewModel;

      if (getFundViewLimitModel == null || event.fetchApi) {
        fundViewModel = await FundsRepository().getFundViewLimitModel(request);
      } else {
        fundViewModel = getFundViewLimitModel;
      }
      emit(AddFundsChangedState());

      emit(addFundBuyPowerandWithdrawcashDoneState
        ..buy_power = fundViewModel.buypwr!);
    } on ServiceException catch (ex) {
      emit(AddFundsFailedState(ex.code, ex.msg)
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      final getFundViewLimitModel =
          await CacheRepository.groupCache.get('getFundViewLimitModel');

      if (getFundViewLimitModel != null) {
        emit(addFundBuyPowerandWithdrawcashDoneState
          ..buy_power = getFundViewLimitModel.buypwr!);
      } else {
        throw (ServiceException(ex.code, ex.msg));
      }
    } on FailedException catch (ex) {
      emit(AddFundsFailedState(ex.code, ex.msg)
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleAddfundsfetchUPIDataEvent(
      AddfundsfetchUPIDataEvent event, Emitter<AddFundsState> emit) async {
    emit(AddFundsProgressState());

    try {
      final BaseRequest request = BaseRequest();
      request.addToData('amount', event.amount.replaceAll(",", ""));
      request.addToData('payChannel', event.payChannel);
      request.addToData('accountNumbers', event.accountnumberlist);

      final UPIBankingDataModel upiBankingDataModel =
          await MyFundsRepository().getUPIDetailsRequest(request, event.url);
      emit(addFundsUPIDataDoneState..upiBankingDataModel = upiBankingDataModel);
    } on ServiceException catch (ex) {
      emit(AddFundsFailedState(ex.code, ex.msg)
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(AddFundsFailedState(ex.code, ex.msg)
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    } catch (e) {
      emit(AddFundsFailedState("", e.toString()));
    }
  }

  Future<void> _handleAddfundsfetchNetBankingDataEvent(
      AddfundsfetchNetBankingDataEvent event,
      Emitter<AddFundsState> emit) async {
    emit(AddFundsProgressState());
    try {
      final BaseRequest request = BaseRequest();
      request.addToData('amount', event.amount.replaceAll(",", ""));
      request.addToData('payChannel', event.payChannel);
      request.addToData('clientAccNo', event.clientAccNo);
      request.addToData('bankName', event.bankName);

      final NetBankingDataModel netBankingDataModel = await MyFundsRepository()
          .getNetBankingDetailsRequest(request, event.url);

      emit(AddFundsNetBankingDataDoneState()
        ..netBankingDataModel = netBankingDataModel);
    } on ServiceException catch (ex) {
      emit(AddFundsChangedState());
      emit(AddFundsFailedState(ex.code, ex.msg)
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(AddFundsChangedState());
      emit(AddFundsErrorState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    } catch (e) {
      emit(AddFundsChangedState());
      emit(AddFundsFailedState("", e.toString()));
    }
  }

  Future<void> _handleGetbankdetilsEvent(
      GetBankDetailsEvent event, Emitter<AddFundsState> emit) async {
    dynamic data = await AppStorage().getData('getBankdetailkey');

    if (data != null) {
      final BankDetailsModel bankDetailsModel =
          BankDetailsModel.dataFromJson(data);

      List<Map<String, dynamic>> updateData =
          _getResultListToDisplay(bankDetailsModel.banks!);

      addFundsGetBankListNoData
        ..isValid = true
        ..msg = '';

      getbankListDoneState
        ..bankDetailsModel = bankDetailsModel
        ..resultDataList = updateData
        ..dataindex = 0
        ..isBankPrimary = true;
      await _sendPaymentModeOptionsRequest(emit, bankDetailsModel);
    } else {
      try {
        emit(AddFundsProgressState());
        final BaseRequest request = BaseRequest();
        final BankDetailsModel bankDetailsModel =
            await MyFundsRepository().getBankDetailsRequest(request);

        if (bankDetailsModel.banks != null &&
            bankDetailsModel.banks!.isNotEmpty) {
          emit(AddFundsChangedState());

          AppStorage().setData('getBankdetailkey', bankDetailsModel);

          List<Map<String, dynamic>> updateData =
              _getResultListToDisplay(bankDetailsModel.banks!);

          addFundsGetBankListNoData
            ..isValid = true
            ..msg = '';

          getbankListDoneState
            ..bankDetailsModel = bankDetailsModel
            ..resultDataList = updateData
            ..dataindex = 0
            ..isBankPrimary = true;
          await _sendPaymentModeOptionsRequest(emit, bankDetailsModel);
        } else {
          emit(addFundsGetBankListNoData
            ..isValid = false
            ..msg = 'No Banks Found');
        }
      } on ServiceException catch (ex) {
        debugPrint('service call!!!');
        if (ex.code.toLowerCase() == 's03') {
          emit(addFundsGetBankListNoData
            ..isValid = false
            ..msg = 'No Banks Found');
        } else {
          emit(AddFundsFailedState(ex.code, ex.msg)
            ..errorCode = ex.code
            ..errorMsg = ex.msg);
        }
        throw (ServiceException(ex.code, ex.msg));
      } on FailedException catch (ex) {
        debugPrint('failed call!!!');
        if (ex.code.toLowerCase() == 'egn001') {
          emit(addFundsGetBankListNoData
            ..isValid = false
            ..msg = 'No Banks Found');
        } else {
          emit(AddFundsFailedState(ex.code, ex.msg)
            ..errorCode = ex.code
            ..errorMsg = ex.msg);
        }
      } catch (e) {
        emit(AddFundsFailedState("", e.toString()));
      }
    }
  }

  List<Map<String, dynamic>> _getResultListToDisplay(List<Banks> banklist) {
    List<Map<String, dynamic>> updateData = [];
    for (var element in banklist) {
      Map<String, dynamic> data = {};
      if (element.bankName != null) {
        data['bankName'] = element.bankName;

        data['bankLogo'] = (element.bankName!.isNotEmpty)
            ? AppUtils().getBankLogoName(element.bankName!.toLowerCase())
            : AppUtils().getBankLogoName('');

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

  Future<void> _sendPaymentModeOptionsRequest(
      Emitter<AddFundsState> emit, BankDetailsModel bankDetailsModel) async {
    dynamic data = await AppStorage().getData('getPaymentOptionkey');

    if (data != null) {
      getbankListDoneState.getPaymentOptionModel =
          GetPaymentOptionModel.datafromJson(data);
      Banks options =
          getbankListDoneState.bankDetailsModel!.banks!.elementAt(0);

      Map<String, dynamic> requiredData =
          _getPaymentModeRelateddetails(options.bankName ?? "");

      emit(getbankListDoneState
        ..selectedpayOption = requiredData['payoption']
        ..pgURL = requiredData['pgURL']
        ..upiURL = requiredData['upiURL']);
    } else {
      try {
        emit(AddFundsProgressState());
        final BaseRequest request = BaseRequest();
        List<String> bankname = [];

        for (var element in bankDetailsModel.banks!) {
          if (element.bankName != null && element.bankName!.isNotEmpty) {
            bankname.add(element.bankName!);
          }
        }

        request.addToData('banks', bankname.toList());
        emit(AddFundsChangedState());

        GetPaymentOptionModel data = await MyFundsRepository()
            .getPaymentOptionsModeDetailsRequest(request);

        AppStorage().setData('getPaymentOptionkey', data);

        getbankListDoneState.getPaymentOptionModel = data;

        Banks options =
            getbankListDoneState.bankDetailsModel!.banks!.elementAt(0);

        Map<String, dynamic> requiredData =
            _getPaymentModeRelateddetails(options.bankName ?? "");
        emit(getbankListDoneState
          ..selectedpayOption = requiredData['payoption']
          ..pgURL = requiredData['pgURL']
          ..upiURL = requiredData['upiURL']);
      } on ServiceException catch (ex) {
        emit(AddFundsFailedState(ex.code, ex.msg)
          ..errorCode = ex.code
          ..errorMsg = ex.msg);
        throw (ServiceException(ex.code, ex.msg));
      } on FailedException catch (ex) {
        emit(AddFundsFailedState(ex.code, ex.msg)
          ..errorCode = ex.code
          ..errorMsg = ex.msg);
      } catch (e) {
        emit(AddFundsFailedState("", e.toString()));
      }
    }
  }

  Future<void> _handleUpdateAmountEvent(
      UpdateAmountEvent event, Emitter<AddFundsState> emit) async {
    {
      emit(AddFundsUpdateAmountChangedState());
      int sum = event.amount_entered + event.amount_already_present;
      emit(AddFundsUpdateAmountState()
        ..updatedvalue = AppUtils().commaFmt(sum.toString(), decimalPoint: 0));
      _handleShowPrefixIconEvent(ShowPrefixIconEvent(), emit);
    }
  }

  Map<String, dynamic> _getPaymentModeRelateddetails(String selectedbank) {
    String pgURL = '';
    String upiURL = '';
    int indexpart = 0;
    PayOptions payoption = PayOptions();

    if (getbankListDoneState.getPaymentOptionModel != null) {
      if (getbankListDoneState.getPaymentOptionModel!.payUrl != null) {
        if (getbankListDoneState.getPaymentOptionModel!.payUrl!.pG != null &&
            getbankListDoneState
                .getPaymentOptionModel!.payUrl!.pG!.isNotEmpty) {
          pgURL = getbankListDoneState.getPaymentOptionModel!.payUrl!.pG!;
        }

        if (getbankListDoneState.getPaymentOptionModel!.payUrl!.uPI != null &&
            getbankListDoneState
                .getPaymentOptionModel!.payUrl!.uPI!.isNotEmpty) {
          upiURL = getbankListDoneState.getPaymentOptionModel!.payUrl!.uPI!;
        }
      }

      if (getbankListDoneState.getPaymentOptionModel!.payOptions != null &&
          getbankListDoneState.getPaymentOptionModel!.payOptions!.isNotEmpty) {
        for (var element
            in getbankListDoneState.getPaymentOptionModel!.payOptions!) {
          if (element.bank
              .toString()
              .toLowerCase()
              .startsWith(selectedbank.toLowerCase())) {
            break;
          }

          indexpart++;
        }
      }
    }

    if (indexpart != -1) {
      payoption = getbankListDoneState.getPaymentOptionModel!.payOptions!
          .elementAt(indexpart);
    }

    return {
      'pgURL': pgURL,
      'upiURL': upiURL,
      'payoption': payoption,
    };
  }

  Future<void> _handleAddfundsUpdatedBankdetailsEvent(
      AddfundsUpdatedBankdetailsEvent event,
      Emitter<AddFundsState> emit) async {
    List<Map<String, dynamic>> updateData =
        _getResultListToDisplay(event.bankDetailsModel!.banks!);

    int index = event.bankDetailsModel!.banks!.indexWhere((Banks element) {
      return element.isBankChoosen == true;
    });

    Banks selectedbank = event.bankDetailsModel!.banks!.elementAt(index);

    Map<String, dynamic> requiredData =
        _getPaymentModeRelateddetails(selectedbank.bankName ?? "");

    bool isBankPrimary = (index == 0) ? true : false;
    emit(AddFundsChangedState());
    emit(getbankListDoneState
      ..bankDetailsModel = event.bankDetailsModel
      ..resultDataList = updateData
      ..dataindex = (index != -1) ? index : 0
      ..isBankPrimary = isBankPrimary
      ..selectedpayOption = requiredData['payoption']
      ..pgURL = requiredData['pgURL']
      ..upiURL = requiredData['upiURL']);
  }

  @override
  AddFundsState getErrorState() {
    return AddFundsErrorState();
  }
}
