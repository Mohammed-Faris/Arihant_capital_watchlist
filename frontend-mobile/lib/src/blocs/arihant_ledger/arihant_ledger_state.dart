part of 'arihant_ledger_bloc.dart';

abstract class ArihantLedgerState extends ScreenState {}

class ArihantLedgerInitial extends ArihantLedgerState {
  ArihantLedgerInitial();
}

class ArihantLedgerLoading extends ArihantLedgerState {
  ArihantLedgerLoading();
}

class ArihantLedgerDone extends ArihantLedgerState {
  ArihantLedgerDone();
}

class ArihantLedgerFailure extends ArihantLedgerState {
  ArihantLedgerFailure();
}
