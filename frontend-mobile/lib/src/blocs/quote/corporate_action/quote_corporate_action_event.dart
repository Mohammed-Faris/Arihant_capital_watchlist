part of 'quote_corporate_action_bloc.dart';

abstract class QuoteCorporateActionEvent {}

class FetchQuoteCorporateActionEvent extends QuoteCorporateActionEvent {
  Sym sym;
  FetchQuoteCorporateActionEvent(this.sym);
}
