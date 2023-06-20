part of 'technical_bloc.dart';

abstract class TechnicalEvent {
  bool consolidated = true;
}

class QuoteTechnicalEvent extends TechnicalEvent {
  late Sym? sym;
  QuoteTechnicalEvent(this.sym);
}
