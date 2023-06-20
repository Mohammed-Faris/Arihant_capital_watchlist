part of 'fund_history_bloc.dart';

abstract class FundHistoryEvent {}

class GetTransactionHistoryEvent extends FundHistoryEvent {
  String fromdate = '';
  String todate = '';
  String selectedSegment = '';
}

class GetTransactionClearDateEvent extends FundHistoryEvent {}

class FundHistoryOptionSelectedEvent extends FundHistoryEvent {
  String selectedValue = '';
}

class FundHistoryDateSelectEvent extends FundHistoryEvent {
  String selectedFromDate = '';
  String selectedToDate = '';
}

class FundHistoryCancelEvent extends FundHistoryEvent {
  String idvalue = '';
}
