part of 'withdraw_cash_info_bloc.dart';

abstract class WithdrawCashInfoEvent {}

class GetWithdrawCashEvent extends WithdrawCashInfoEvent {
  String withdrawcashdata = '';
}

class GetWithdrawCashFundViewUpdatedEvent extends WithdrawCashInfoEvent {
  FundViewUpdatedModel? fundViewUpdatedModel;
  final bool fetchApi;

  GetWithdrawCashFundViewUpdatedEvent(this.fetchApi);
}
