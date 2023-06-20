part of 'fund_details_bloc.dart';

abstract class FunddetailsState extends ScreenState {}

class FunddetailsInitial extends FunddetailsState {}

class FunddetailsProgressState extends FunddetailsState {}

class FunddetailsChangedState extends FunddetailsState {}

class FunddetailsFailedState extends FunddetailsState {
  FunddetailsFailedState();
}

class FunddetailsErrorState extends FunddetailsState {}

class AvailableFundsDoneState extends FunddetailsState {
  String availableFunds = '';
}

class FundsViewDataDoneState extends FunddetailsState {
  FundViewUpdatedModel? fundViewModel;
}
