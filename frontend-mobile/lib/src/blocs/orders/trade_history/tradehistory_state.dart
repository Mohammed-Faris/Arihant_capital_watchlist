part of 'tradehistory_bloc.dart';

abstract class TradeHistoryState extends ScreenState {
  DateTime? fromDate;
  DateTime? toDate;
}

class TradehistoryInitial extends TradeHistoryState {}

class TradehistoryLoad extends TradeHistoryState {}

class TradeHistoryFetchDone extends TradeHistoryState {
  TradeHistory? tradeHistory;

  List<ReportList>? reportlist;
  TradeHistoryFetchDone();
}

class TradeHistoryFetchFail extends TradeHistoryState {}
