part of 'charges_bloc.dart';

abstract class ChargesEvent {}

class FetchChargesEvent extends ChargesEvent {
  Map<String, dynamic> data;

  FetchChargesEvent(this.data);
}
