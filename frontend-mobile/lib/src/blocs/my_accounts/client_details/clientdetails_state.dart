part of 'clientdetails_bloc.dart';

abstract class ClientdetailsState extends ScreenState {}

class ClientdetailsInitial extends ClientdetailsState {}

class ClientdetailsProgressState extends ClientdetailsState {}

class ClientdetailsDoneState extends ClientdetailsState {
  ClientDetails? clientDetails;
  ClientdetailsDoneState();
}

class ClientdetailsFailedState extends ClientdetailsState {
  String code;
  String msg;

  ClientdetailsFailedState(this.code, this.msg);
}

class BuyPowerDoneState extends ClientdetailsState {
  FundViewModel? fundviewModel;
}

class ClientdetailsErrorState extends ClientdetailsState {}
