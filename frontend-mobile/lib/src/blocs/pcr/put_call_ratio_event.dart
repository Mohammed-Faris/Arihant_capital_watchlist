part of 'put_call_ratio_bloc.dart';

abstract class PutCallRatioEvent {}

class PutCallRatioFetchEvent extends PutCallRatioEvent {
  final String expiry;

  PutCallRatioFetchEvent(this.expiry);
}
