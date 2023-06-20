part of 'edis_bloc.dart';

abstract class EdisEvent {}

class VerifyEdisEvent extends EdisEvent {
  List<OrderDetails> ordDetails;
  VerifyEdisEvent(this.ordDetails);
}

class GenerateTpinEvent extends EdisEvent {
  String reqTime;
  String reqId;
  GenerateTpinEvent(this.reqTime, this.reqId);
}

class GetNsdlAcknowledgementEvent extends EdisEvent {
  String reqId;
  GetNsdlAcknowledgementEvent(this.reqId);
}
