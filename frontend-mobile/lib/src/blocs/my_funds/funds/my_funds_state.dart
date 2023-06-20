// ignore_for_file: non_constant_identifier_names

part of 'my_funds_bloc.dart';

abstract class MyFundsState extends ScreenState {}

class MyFundsInitial extends MyFundsState {}

class MyFundsProgressState extends MyFundsState {}

class MyFundsChangedState extends MyFundsState {}

class MyFundsFailedState extends MyFundsState {
  MyFundsFailedState();
}

class MyFundsCancelErrorState extends MyFundsState {}

class MyFundsErrorState extends MyFundsState {}

class MyFundsWithdrawalErrorState extends MyFundsState {}

class MyFundsTransactionErrorState extends MyFundsState {}

class MyFundsTransactionHistoryDoneState extends MyFundsState {
  TransactionHistoryModel? transactionHistoryModel;
}

class MyFundsTransactionHistoryCancelDoneState extends MyFundsState {
  String message = '';
}

class MyFundsTransactionHistoryCancelFailedDoneState extends MyFundsState {
  String message = '';
}

class GetMaxPayoutWithdrawCashDoneState extends MyFundsState {
  String availableFunds = '';
  WithdrawCashMaxPayoutModel? availableFundsModel;
  bool isFontreduce = false;
}

class BuyPowerandWithdrawcashDoneState extends MyFundsState {
  String buy_power = '';
  String account_balance = '';
  FundViewLimitModel? fundviewLimitModel;
  bool isFontreduce = false;
}
