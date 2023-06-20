part of 'fund_details_bloc.dart';

abstract class FunddetailsEvent {}

class GetFundDetailsEvent extends FunddetailsEvent {
  final bool fetchApi;

  GetFundDetailsEvent(this.fetchApi);
}

class LoadFundDetailsEvent extends FunddetailsEvent {
  FundViewUpdatedModel? fundViewModel;
}
