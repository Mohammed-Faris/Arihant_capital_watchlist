part of 'fund_history_bloc.dart';

abstract class FundHistoryState extends ScreenState {}

class FundHistoryInitial extends FundHistoryState {}

class FundHistoryProgressState extends FundHistoryState {}

class FundHistoryChangedState extends FundHistoryState {}

class FundHistoryFailedState extends FundHistoryState {}

class FundHistoryErrorState extends FundHistoryState {}

class FundHistoryTransactionErrorState extends FundHistoryState {}

class FundTransactionHistoryDoneState extends FundHistoryState {
  TransactionHistoryModel? transactionHistoryModel;
  List<History>? filteredhistorydata;
  bool isCustomDateOptionSelected = false;
  String selectedFromDate = '';
  String selectedToDate = '';
  bool isTickMarkEnable = false;
  bool isShowCrossMark = false;
  bool isHideTextDescription = false;
}

class FundHistoryOptionSelectedDoneState extends FundHistoryState {
  String selectedValue = '';
}

class FundHistoryShowCalenderErrorDoneState extends FundHistoryState {
  String msg = '';
}

class FundHistoryCancelDoneState extends FundHistoryState {
  String message = '';
}

class FundHistoryCancelFailedState extends FundHistoryState {
  String message = '';
}
