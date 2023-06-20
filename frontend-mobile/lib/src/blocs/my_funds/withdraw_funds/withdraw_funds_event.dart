// ignore_for_file: non_constant_identifier_names

part of 'withdraw_funds_bloc.dart';

abstract class WithdrawfundsEvent {}

class WithdrawfundsEventFetchEvent extends WithdrawfundsEvent {}

class GetBankDetailsEvent extends WithdrawfundsEvent {}

class GetFundsViewEvent extends WithdrawfundsEvent {}

class GetFundsViewUpdatedEvent extends WithdrawfundsEvent {}

class GetMaxPayoutWithdrawalCashEvent extends WithdrawfundsEvent {
  final bool fetchApi;

  GetMaxPayoutWithdrawalCashEvent({this.fetchApi = false});
}

class WithdrawfundsUpdatedBankdetailsEvent extends WithdrawfundsEvent {
  BankDetailsModel? bankDetailsModel;
}

class WithdrawfundsModifyUpdatedBankdetailsEvent extends WithdrawfundsEvent {
  History? history;
}

class EnableAndDisableContinueButtonEvent extends WithdrawfundsEvent {
  String amount = '';
  bool withdrawAll = false;
}

class CheckForErrorMessageEvent extends WithdrawfundsEvent {
  String amount = '';
}

class GetWithdrawFundsEvent extends WithdrawfundsEvent {
  String amount = '';
  String bank_name = '';
  String bank_account_id = '';
}

class GetModifyWithdrawFundsEvent extends WithdrawfundsEvent {
  String amount = '';
  String instructionId = '';
}

class WithdrawfundsFailedEvent extends WithdrawfundsEvent {}

class WithdrawfundsErrorEvent extends WithdrawfundsEvent {}
