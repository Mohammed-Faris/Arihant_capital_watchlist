// ignore_for_file: overridden_fields

part of 'withdraw_funds_bloc.dart';

abstract class WithdrawFundsState extends ScreenState {
  bool withdrawAll;

  WithdrawFundsState({this.withdrawAll = false});
}

class WithdrawFundsInitial extends WithdrawFundsState {}

class WithdrawFundsProgressState extends WithdrawFundsState {}

class WithdrawFundsConfirmationProgressState extends WithdrawFundsState {}

class WithdrawFundsFailedState extends WithdrawFundsState {
  String code;
  String msg;
  WithdrawFundsFailedState(this.code, this.msg);
}

class WithdrawFundsChangedState extends WithdrawFundsState {}

class WithdrawalFundsGetBankListNoData extends WithdrawFundsState {
  String msg = '';
}

class WithdrawFundsGetbankListDoneState extends WithdrawFundsState {
  BankDetailsModel? bankDetailsModel;
  List<Map<String, dynamic>>? resultDataList;
  int dataindex = 0;
  bool isBankPrimary = false;
}

class WithdrawFundsGetbankListModifyDoneState extends WithdrawFundsState {
  BankDetailsModel? bankDetailsModel;
  List<Map<String, dynamic>>? resultDataList;
  int dataindex = 0;
  bool isBankPrimary = false;
}

class WithdrawFundsDoneState extends WithdrawFundsState {
  String msg = '';
  bool isSuccess = false;
}

class EnableAndDisableContinueButtonState extends WithdrawFundsState {
  bool isEnableButton = false;
}

class ShowErrorMessageOnContinueButtonPressedState extends WithdrawFundsState {
  @override
  String errorMsg = '';
  bool isShowError = false;
}

class WithdrawFundBuyPowerandWithdrawcashDoneState extends WithdrawFundsState {
  FundViewModel fundViewModel = FundViewModel();
}

class GetMaxPayoutWithdrawCashDoneState extends WithdrawFundsState {
  String availableFunds = '';
}

class GetMaxPayoutWithdrawCashFailedState extends WithdrawFundsState {}

class WithdrawErrorState extends WithdrawFundsState {}
