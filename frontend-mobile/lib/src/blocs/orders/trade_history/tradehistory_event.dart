part of 'tradehistory_bloc.dart';

abstract class TradeHistoryEvent {}

class TradeHistoryFetch extends TradeHistoryEvent {
  DateTime? fromDate;
  DateTime? toDate;
  List<FilterModel>? filterModel;
  final String search;
  bool fetchApi;
  bool clearData;

  TradeHistoryFetch(this.fromDate, this.toDate, this.filterModel, this.search,
      {this.fetchApi = true, this.clearData = false});
}

class TradeHistoryClear extends TradeHistoryEvent {}
