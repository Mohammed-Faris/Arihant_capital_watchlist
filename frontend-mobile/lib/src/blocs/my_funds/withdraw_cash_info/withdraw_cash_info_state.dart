part of 'withdraw_cash_info_bloc.dart';

abstract class WithdrawCashInfoState extends ScreenState {}

class WithdrawCashInfoInitial extends WithdrawCashInfoState {}

class WithdrawCashInfoProgressState extends WithdrawCashInfoState {}

class WithdrawCashInfoChangedState extends WithdrawCashInfoState {}

class WithdrawCashInfoFailedState extends WithdrawCashInfoState {
  WithdrawCashInfoFailedState();
}

class WithdrawCashInfoErrorState extends WithdrawCashInfoState {}

class WithdrawCashInfoNoDataErrorState extends WithdrawCashInfoState {}

class GetMaxPayoutWithdrawCashDoneState extends WithdrawCashInfoState {
  String availableFunds = '';
}

class WithdrawCashDoneState extends WithdrawCashInfoState {
  String withdrawfund = '';
}

class WithdrawCashFundViewDoneState extends WithdrawCashInfoState {
  FundViewUpdatedModel? fundViewUpdatedModel;
}
