part of 'edis_bloc.dart';

abstract class EdisState extends ScreenState {}

class EdisInitial extends EdisState {}

class EdisProgressState extends EdisState {}

class VerifyEdisDoneState extends EdisState {
  VerifyEdisModel? verifyEdisModel;
}

class VerifyEdisFailedState extends EdisState {}

class VerifyEdisServiceExceptionState extends EdisState {}

class GenerateTpinDoneState extends EdisState {
  String? messageModel;
}

class GenerateTpinFailedState extends EdisState {}

class GenerateTpinServiceExceptionState extends EdisState {}

class NsdlAcknowledgementDoneState extends EdisState {
  NsdlAckModel? nsdlAckModel;
}

class NsdlAcknowledgementFailedState extends EdisState {}

class NsdlAcknowledgementServiceExceptionState extends EdisState {}

class EdisErrorState extends EdisState {}
