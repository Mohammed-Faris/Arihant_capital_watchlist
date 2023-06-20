part of 'my_funds_bloc.dart';

abstract class MyfundsEvent {}

class MyfundsEventFetchEvent extends MyfundsEvent {
  MyfundsEventFetchEvent();
}

class GetMaxPayoutWithdrawalCashEvent extends MyfundsEvent {
  final bool fetchApi;

  GetMaxPayoutWithdrawalCashEvent({this.fetchApi = true});
}

class GetFundsViewEvent extends MyfundsEvent {
  final bool fetchApi;

  GetFundsViewEvent({this.fetchApi = true});
}

class GetFundsViewUpdatedEvent extends MyfundsEvent {
  final bool fetchApi;

  GetFundsViewUpdatedEvent({this.fetchApi = true});
}

class GetTransactionHistoryEvent extends MyfundsEvent {}

class GetTransactionHistoryCancelEvent extends MyfundsEvent {
  String idvalue = '';
}

class MyfundsFailedEvent extends MyfundsEvent {}

class MyfundsErrorEvent extends MyfundsEvent {}
