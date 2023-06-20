part of 'financials_view_more_bloc.dart';

abstract class FinancialsViewMoreState extends ScreenState {}

class FinancialsViewMoreInitial extends FinancialsViewMoreState {}

class FinancialsViewMoreProgressState extends FinancialsViewMoreState {}

class FinancialsShareHoldingsDoneState extends FinancialsViewMoreState {
  late FinancialsShareHoldings financialsShareHoldings;
}

class FinancialsQuarterlyIncomeStatementDoneState
    extends FinancialsViewMoreState {
  late QuarterlyIncomeStatement quarterlyIncomeStatement;
}

class FinancialsYearlyIncomeStatementDoneState extends FinancialsViewMoreState {
  late YearlyIncomeStatement yearlyIncomeStatement;
}

class FinancialsViewMoreFailedState extends FinancialsViewMoreState {}

class FinancialsServiceExceptionState extends FinancialsViewMoreState {}

class FinancialsViewMoreErrorState extends FinancialsViewMoreState {}

class FinancialsDataState extends FinancialsViewMoreState {
  Symbols? symbols;
}

class FinancialsChangeState extends FinancialsViewMoreState {}

class FinancialsSymStreamState extends FinancialsViewMoreState {
  final Map<dynamic, dynamic> streamDetails;
  FinancialsSymStreamState(this.streamDetails);
}
