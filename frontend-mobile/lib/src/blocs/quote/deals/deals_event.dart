part of 'deals_bloc.dart';

abstract class DealsEvent {}

class QuoteToggleBlockEvent extends DealsEvent {}

class QuoteToggleBulkEvent extends DealsEvent {}

class QuoteBlockEvent extends DealsEvent {
  late BlockDeals blockDeals;

  QuoteBlockEvent(this.blockDeals);
}

class MarketsBlockEvent extends DealsEvent {
  final String exc;
  final SortModel? selectedSortModel;

  MarketsBlockEvent(this.exc, this.selectedSortModel);
}

class MarketsBulkEvent extends DealsEvent {
  final String exc;
  final SortModel? selectedSortModel;

  MarketsBulkEvent(this.exc, this.selectedSortModel);
}

class QuoteBulkEvent extends DealsEvent {
  late BulkDeals bulkDeals;

  QuoteBulkEvent(this.bulkDeals);
}

class QuoteDealsFailedState extends DealsEvent {}

class QuoteDealsErrorState extends DealsEvent {}
