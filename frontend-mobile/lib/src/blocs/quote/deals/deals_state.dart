part of 'deals_bloc.dart';

abstract class DealsState extends ScreenState {}

class DealsInitial extends DealsState {}

class DealsProgressState extends DealsState {}

class DealsBlockToggleState extends DealsState {
  late bool dealsBlock;
}

class DealsBulkToggleState extends DealsState {
  late bool dealsBulk;
}

class DealsBlockDoneState extends DealsState {
  late QuoteBlockDealsModel quoteBlockDealsModel;
}

class DealsBulkDoneState extends DealsState {
  late QuotesBulkDealsModel quotesBulkDealsModel;
}

class DealsFailedState extends DealsState {}

class DealsServiceExceptionState extends DealsState {}

class DealsErrorState extends DealsState {}
