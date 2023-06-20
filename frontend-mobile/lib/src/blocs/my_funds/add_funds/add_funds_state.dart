// ignore_for_file: non_constant_identifier_names

part of 'add_funds_bloc.dart';

abstract class AddFundsState extends ScreenState {}

class AddFundsInitial extends AddFundsState {}

class AddFundsProgressState extends AddFundsState {}

class AddFundsFailedState extends AddFundsState {
  String code;
  String msg;
  AddFundsFailedState(this.code, this.msg);
}

class AddFundsGetBankListNoData extends AddFundsState {
  String msg = '';
  bool isValid = false;
  AddFundsGetBankListNoData();
}

class ShowPrefixIconState extends AddFundsState {
  bool isShow = false;
}

class AddFundsUpdateAmountChangedState extends AddFundsState {}

class AddFundsUpdateAmountState extends AddFundsState {
  String updatedvalue = '';
}

class AddFundsGetbankListDoneState extends AddFundsState {
  BankDetailsModel? bankDetailsModel;
  GetPaymentOptionModel? getPaymentOptionModel;
  List<Map<String, dynamic>>? resultDataList;
  PayOptions? selectedpayOption;
  int dataindex = 0;
  bool isBankPrimary = false;
  String pgURL = '';
  String upiURL = '';
}

class AddFundsUPIDataDoneState extends AddFundsState {
  UPIBankingDataModel? upiBankingDataModel;
}

class AddFundsNetBankingDataDoneState extends AddFundsState {
  NetBankingDataModel? netBankingDataModel;
}

class AddFundBuyPowerandWithdrawcashDoneState extends AddFundsState {
  String buy_power = '';
  FundViewModel fundViewModel = FundViewModel();
}

class AddFundUPITransactionStatusDoneState extends AddFundsState {
  FundsTransactionStatusUPIModel fundsTransactionStatusUPIModel =
      FundsTransactionStatusUPIModel();
}

class AddFundsChangedState extends AddFundsState {}

class AddFundsErrorState extends AddFundsState {}
