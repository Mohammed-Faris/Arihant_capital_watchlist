part of 'technical_bloc.dart';

abstract class TechnicalState extends ScreenState {}

class TechnicalInitial extends TechnicalState {}

class QuoteTechnicalProgressState extends TechnicalState {}

class QuoteTechnicalDoneState extends TechnicalState {
  late Technical technical;
}

class QuotetechnicalFailedState extends TechnicalState {}

class QuoteTechnicalErrorState extends TechnicalState {}

class QuoteTechnicalServiceExceptionState extends TechnicalState {}
