part of 'quote_corporate_action_bloc.dart';

abstract class QuoteCorporateActionState extends ScreenState {}

class QuoteCorporateActionInitial extends QuoteCorporateActionState {}

class QuoteCorporateActionDataState extends QuoteCorporateActionState {
  QuoteCorporateActionModel? quoteCorporateActionModel;
}

class QuoteCorporateActionProgressState extends QuoteCorporateActionState {}

class QuoteCorporateActionChangeState extends QuoteCorporateActionState {}

class QuoteCorporateActionErrorState extends QuoteCorporateActionState {}

class QuoteCorporateActionFailedState extends QuoteCorporateActionState {}

class QuoteCorporateActionServiceExceptionState
    extends QuoteCorporateActionState {}
