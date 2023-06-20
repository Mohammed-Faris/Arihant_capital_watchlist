part of 'put_call_ratio_bloc.dart';

abstract class PutCallRatioState extends ScreenState {}

class PutCallRatioInitial extends PutCallRatioState {}

class PutCallRatioErrorState extends PutCallRatioState {}

class PutCallRatioDoneState extends PutCallRatioState {
  final PutCallRatioModel response;

  PutCallRatioDoneState(this.response);
}

class PutCallRatioLoadState extends PutCallRatioState {}
