import 'dart:async';

import '../../../constants/app_constants.dart';
import '../../../data/store/app_utils.dart';
import '../../../models/sort_filter/sort_filter_model.dart';
import '../../common/base_bloc.dart';
import '../../common/screen_state.dart';
import '../../../models/quote/quote_deals_block/quote_block_deals_model.dart';
import '../../../models/quote/quote_deals_bulk/quote_deals_bulk.dart';
import '../../../models/quote/quote_deals_bulk/quote_deals_bulk_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import '../../../data/repository/quote/quote_repository.dart';
import '../../../models/quote/quote_deals_block/quote_block_deals.dart';

part 'deals_event.dart';
part 'deals_state.dart';

class QuotesDealsBloc extends BaseBloc<DealsEvent, DealsState> {
  QuotesDealsBloc() : super(DealsInitial());

  @override
  Future<void> eventHandlerMethod(
      DealsEvent event, Emitter<DealsState> emit) async {
    if (event is QuoteToggleBlockEvent) {
      await _toggleQuoteDealsBlockToggle(emit);
    } else if (event is QuoteToggleBulkEvent) {
      await _toggleQuoteDealsBulkToggle(emit);
    } else if (event is QuoteBlockEvent) {
      await _getQuotesBlockDealsEvent(event, emit, event.blockDeals);
    } else if (event is QuoteBulkEvent) {
      await _getQuotesBulkDealsEvent(event, emit, event.bulkDeals);
    } else if (event is MarketsBlockEvent) {
      await _getBlockDealsMarketEvent(emit, event);
    } else if (event is MarketsBulkEvent) {
      await _getBulkDealsMarketEvent(emit, event);
    }
  }

  Future<void> _toggleQuoteDealsBlockToggle(Emitter<DealsState> emit) async =>
      emit(DealsBlockToggleState()..dealsBlock = true);

  Future<void> _toggleQuoteDealsBulkToggle(Emitter<DealsState> emit) async =>
      emit(DealsBulkToggleState()..dealsBulk = true);

  Future<void> _getQuotesBlockDealsEvent(
      DealsEvent event, Emitter<DealsState> emit, BlockDeals blockDeals) async {
    emit(DealsProgressState());

    try {
      final BaseRequest request = BaseRequest();
      request.addToData('sym', blockDeals.sym);

      final QuoteBlockDealsModel quoteBlockDealsModel =
          await QuoteRepository().getQuoteBlockDealsRequest(request);

      emit(DealsBlockDoneState()..quoteBlockDealsModel = quoteBlockDealsModel);
    } on FailedException catch (ex) {
      emit(DealsFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _getQuotesBulkDealsEvent(
      DealsEvent event, Emitter<DealsState> emit, BulkDeals bulkDeals) async {
    emit(DealsProgressState());

    try {
      final BaseRequest request = BaseRequest();
      request.addToData('dispSym', bulkDeals.dispSym);
      request.addToData('sym', bulkDeals.sym);

      final QuotesBulkDealsModel quotesBulkDealsModel =
          await QuoteRepository().getQuoteBulkDealsRequest(request);

      emit(DealsBulkDoneState()..quotesBulkDealsModel = quotesBulkDealsModel);
    } on FailedException catch (ex) {
      emit(DealsFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  _getBulkDealsMarketEvent(
    Emitter<DealsState> emit,
    MarketsBulkEvent event,
  ) async {
    emit(DealsProgressState());

    try {
      final BaseRequest request = BaseRequest();
      request.addToData('exc', event.exc);

      final QuotesBulkDealsModel quotesBulkDealsModel =
          await QuoteRepository().getMarketsBulkDealsRequest(request);
      if (event.selectedSortModel != null) {
        if (event.selectedSortModel?.sortName == AppConstants.alphabetically) {
          if (event.selectedSortModel?.sortType == Sort.ASCENDING) {
            quotesBulkDealsModel.bulkDeals?.sort((BulkDealsModel a,
                    BulkDealsModel b) =>
                a.dispSym!.toLowerCase().compareTo(b.dispSym!.toLowerCase()));
          } else {
            quotesBulkDealsModel.bulkDeals?.sort((BulkDealsModel a,
                    BulkDealsModel b) =>
                b.dispSym!.toLowerCase().compareTo(a.dispSym!.toLowerCase()));
          }
        } else if (event.selectedSortModel?.sortName == AppConstants.price) {
          if (event.selectedSortModel?.sortType == Sort.ASCENDING) {
            quotesBulkDealsModel.bulkDeals?.sort(
                (BulkDealsModel a, BulkDealsModel b) => AppUtils()
                    .doubleValue(AppUtils().decimalValue(b.avgPrce ?? '0'))
                    .compareTo(AppUtils().doubleValue(
                        AppUtils().decimalValue(a.avgPrce ?? '0'))));
          } else {
            quotesBulkDealsModel.bulkDeals?.sort(
                (BulkDealsModel a, BulkDealsModel b) => AppUtils()
                    .doubleValue(AppUtils().decimalValue(a.avgPrce ?? '0'))
                    .compareTo(AppUtils().doubleValue(
                        AppUtils().decimalValue(b.avgPrce ?? '0'))));
          }
        } else if (event.selectedSortModel?.sortName == AppConstants.quantity) {
          if (event.selectedSortModel?.sortType == Sort.ASCENDING) {
            quotesBulkDealsModel.bulkDeals?.sort(
                (BulkDealsModel a, BulkDealsModel b) => AppUtils()
                    .doubleValue(AppUtils().decimalValue(b.qtyShares ?? '0'))
                    .compareTo(AppUtils().doubleValue(
                        AppUtils().decimalValue(a.qtyShares ?? '0'))));
          } else {
            quotesBulkDealsModel.bulkDeals?.sort(
                (BulkDealsModel a, BulkDealsModel b) => AppUtils()
                    .doubleValue(AppUtils().decimalValue(a.qtyShares ?? '0'))
                    .compareTo(AppUtils().doubleValue(
                        AppUtils().decimalValue(b.qtyShares ?? '0'))));
          }
        } else if (event.selectedSortModel?.sortName ==
            AppConstants.tradePercent) {
          if (event.selectedSortModel?.sortType == Sort.ASCENDING) {
            quotesBulkDealsModel.bulkDeals?.sort(
                (BulkDealsModel a, BulkDealsModel b) => AppUtils()
                    .doubleValue(
                        AppUtils().decimalValue(b.percentTraded ?? '0'))
                    .compareTo(AppUtils().doubleValue(
                        AppUtils().decimalValue(a.percentTraded ?? '0'))));
          } else {
            quotesBulkDealsModel.bulkDeals?.sort(
                (BulkDealsModel a, BulkDealsModel b) => AppUtils()
                    .doubleValue(
                        AppUtils().decimalValue(a.percentTraded ?? '0'))
                    .compareTo(AppUtils().doubleValue(
                        AppUtils().decimalValue(b.percentTraded ?? '0'))));
          }
        }
      }
      emit(DealsBulkDoneState()..quotesBulkDealsModel = quotesBulkDealsModel);
    } on FailedException catch (ex) {
      emit(DealsFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  _getBlockDealsMarketEvent(
    Emitter<DealsState> emit,
    MarketsBlockEvent event,
  ) async {
    emit(DealsProgressState());

    try {
      final BaseRequest request = BaseRequest();
      request.addToData('exc', event.exc);

      final QuoteBlockDealsModel quoteBlockDealsModel =
          await QuoteRepository().getMarketBlockDealsRequest(request);
      if (event.selectedSortModel != null) {
        if (event.selectedSortModel?.sortName == AppConstants.alphabetically) {
          if (event.selectedSortModel?.sortType == Sort.ASCENDING) {
            quoteBlockDealsModel.blockDeals?.sort((QuoteBlockDeals a,
                    QuoteBlockDeals b) =>
                a.dispSym!.toLowerCase().compareTo(b.dispSym!.toLowerCase()));
          } else {
            quoteBlockDealsModel.blockDeals?.sort((QuoteBlockDeals a,
                    QuoteBlockDeals b) =>
                b.dispSym!.toLowerCase().compareTo(a.dispSym!.toLowerCase()));
          }
        } else if (event.selectedSortModel?.sortName == AppConstants.price) {
          if (event.selectedSortModel?.sortType == Sort.ASCENDING) {
            quoteBlockDealsModel.blockDeals?.sort(
                (QuoteBlockDeals a, QuoteBlockDeals b) => AppUtils()
                    .doubleValue(AppUtils().decimalValue(b.avgPrce ?? '0'))
                    .compareTo(AppUtils().doubleValue(
                        AppUtils().decimalValue(a.avgPrce ?? '0'))));
          } else {
            quoteBlockDealsModel.blockDeals?.sort(
                (QuoteBlockDeals a, QuoteBlockDeals b) => AppUtils()
                    .doubleValue(AppUtils().decimalValue(a.avgPrce ?? '0'))
                    .compareTo(AppUtils().doubleValue(
                        AppUtils().decimalValue(b.avgPrce ?? '0'))));
          }
        } else if (event.selectedSortModel?.sortName == AppConstants.quantity) {
          if (event.selectedSortModel?.sortType == Sort.ASCENDING) {
            quoteBlockDealsModel.blockDeals?.sort(
                (QuoteBlockDeals a, QuoteBlockDeals b) => AppUtils()
                    .doubleValue(AppUtils().decimalValue(b.qtyShares ?? '0'))
                    .compareTo(AppUtils().doubleValue(
                        AppUtils().decimalValue(a.qtyShares ?? '0'))));
          } else {
            quoteBlockDealsModel.blockDeals?.sort(
                (QuoteBlockDeals a, QuoteBlockDeals b) => AppUtils()
                    .doubleValue(AppUtils().decimalValue(a.qtyShares ?? '0'))
                    .compareTo(AppUtils().doubleValue(
                        AppUtils().decimalValue(b.qtyShares ?? '0'))));
          }
        } else if (event.selectedSortModel?.sortName ==
            AppConstants.tradePercent) {
          if (event.selectedSortModel?.sortType == Sort.ASCENDING) {
            quoteBlockDealsModel.blockDeals?.sort(
                (QuoteBlockDeals a, QuoteBlockDeals b) => AppUtils()
                    .doubleValue(
                        AppUtils().decimalValue(b.percentTraded ?? '0'))
                    .compareTo(AppUtils().doubleValue(
                        AppUtils().decimalValue(a.percentTraded ?? '0'))));
          } else {
            quoteBlockDealsModel.blockDeals?.sort(
                (QuoteBlockDeals a, QuoteBlockDeals b) => AppUtils()
                    .doubleValue(
                        AppUtils().decimalValue(a.percentTraded ?? '0'))
                    .compareTo(AppUtils().doubleValue(
                        AppUtils().decimalValue(b.percentTraded ?? '0'))));
          }
        }
      }

      emit(DealsBlockDoneState()..quoteBlockDealsModel = quoteBlockDealsModel);
    } on FailedException catch (ex) {
      emit(DealsFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  @override
  DealsState getErrorState() {
    return DealsServiceExceptionState();
  }
}
