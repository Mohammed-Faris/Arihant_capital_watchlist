part of 'clientdetails_bloc.dart';

abstract class ClientdetailsEvent {}

class ClientdetailsFetchEvent extends ClientdetailsEvent {
  final bool fetchApi;
  final bool load;
  ClientdetailsFetchEvent({this.fetchApi = false, this.load = true});
}

class GetFundsViewEvent extends ClientdetailsEvent {}

class ClientdetailsFailedEvent extends ClientdetailsEvent {}

class ClientdetailsErrorEvent extends ClientdetailsEvent {}
