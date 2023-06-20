part of 'charges_bloc.dart';

abstract class ChargesState extends ScreenState {}

class ChargesInitial extends ChargesState {}

class ChargesProgressState extends ChargesState {}

class ChargesDoneState extends ChargesState {
  final ChargesModel chargesModel;

  ChargesDoneState(this.chargesModel);
}

class ChargesFailedState extends ChargesState {
  ChargesFailedState();
}
