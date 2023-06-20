// ignore_for_file: depend_on_referenced_packages

import 'package:acml/src/localization/app_localization.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

import '../../../config/app_config.dart';
import '../../../constants/app_constants.dart';
import '../../../data/cache/cache_repository.dart';
import '../../../data/repository/holdings/holdings_repository.dart';
import '../../../data/store/app_calculator.dart';
import '../../../data/store/app_helper.dart';
import '../../../data/store/app_utils.dart';
import '../../../models/common/symbols_model.dart';
import '../../../models/holdings/holdings_model.dart';
import '../../../models/sort_filter/sort_filter_model.dart';
import '../../common/base_bloc.dart';
import '../../common/screen_state.dart';

part 'holdings_event.dart';
part 'holdings_state.dart';

class HoldingsBloc extends BaseBloc<HoldingsEvent, HoldingsState> {
  HoldingsBloc() : super(HoldingsInitState());
  SuggestedStocksState suggestedStocksState = SuggestedStocksState();

  HoldingsFetchDoneState holdingsFetchDoneState = HoldingsFetchDoneState();

  late List<Symbols> holdingsModelfullData;

  @override
  Future<void> eventHandlerMethod(
      HoldingsEvent event, Emitter<HoldingsState> emit) async {
    if (event is HoldingsFetchEvent) {
      await _handleHoldingsFetchEvent(event, emit);
    } else if (event is SuggestedStocksStartSymStreamEvent) {
      await sendStreamForSuggestedStocks(emit);
    } else if (event is SuggestedStocksStreamingResponseEvent) {
      await responseCallbackForSuggestedStocks(event.data, emit);
    } else if (event is HoldingsStartSymStreamEvent) {
      await sendStream(event, emit);
    } else if (event is HoldingsStreamingResponseEvent) {
      await responseCallback(event.data, emit);
    } else if (event is HoldingsSearchEvent) {
      await _handleHoldingsSearchEvent(event, emit);
    } else if (event is HoldingsResetSearchEvent) {
      await _handleHoldingsResetSearchEvent(emit);
    } else if (event is FetchHoldingsWithFiltersEvent) {
      await _handleFetchHoldingsWithFiltersEvent(event, emit);
    }
  }

  Future<void> _handleHoldingsFetchEvent(
    HoldingsFetchEvent event,
    Emitter<HoldingsState> emit,
  ) async {
    if (event.loading) {
      emit(HoldingsProgressState());
    }
    try {
      final BaseRequest request = BaseRequest();
      final HoldingsModel? getHoldingsCache =
          await CacheRepository.holdingsCache.get('getHoldings');
      if (getHoldingsCache != null &&
          (getHoldingsCache.holdings?.isNotEmpty ?? false)) {
        await afterFetch(getHoldingsCache, emit, event);
      } else {
        if (event.isSuggestedStocksEnabled && getHoldingsCache != null) {
          emit(suggestedStocksState
            ..suggestedStocks = AppConfig.suggestedStocks);
          await sendStreamForSuggestedStocks(emit);
        } else if (getHoldingsCache != null) {
          emit(HoldingsFailedState()
            ..errorCode = AppConstants.noDataAvailableErrorCode
            ..errorMsg = AppLocalizations().noDataAvailableErrorMessage);
        }
      }
      if (event.isFetchAgain || getHoldingsCache == null) {
        final HoldingsModel holdingsModel =
            await HoldingsRepository().fetchHoldingsRequest(request);

        if (getHoldingsCache != null) {
          holdingsModel.holdings = holdingsModel.holdings?.map((e) {
            Symbols? holdings = getHoldingsCache.holdings
                ?.firstWhereOrNull((element) => e.dispSym == element.dispSym);
            if (holdings != null) {
              e = updateHoldingsData(
                  e, ResponseData.fromJson(holdings.toJson()),
                  holdings: holdings);
            }
            return e;
          }).toList();
          holdingsModel.overallReturn = getHoldingsCache.overallReturn;
          holdingsModel.overallReturnPercent =
              getHoldingsCache.overallReturnPercent;
          holdingsModel.oneDayReturn = getHoldingsCache.oneDayReturn;
          holdingsModel.totalInvested = getHoldingsCache.totalInvested;
          holdingsModel.oneDayReturnPercent =
              getHoldingsCache.oneDayReturnPercent;
          holdingsModel.overallcurrentValue =
              getHoldingsCache.overallcurrentValue;
        }
        await afterFetch(holdingsModel, emit, event);
      }
    } on ServiceException catch (ex) {
      emit(HoldingsServiceExpectionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      final HoldingsModel? getHoldingsCache =
          await CacheRepository.holdingsCache.get('getHoldings');
      if (getHoldingsCache != null &&
          (getHoldingsCache.holdings?.isNotEmpty ?? false)) {
        await afterFetch(getHoldingsCache, emit, event);
      }
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      if (ex.code == AppConstants.noDataAvailableErrorCode) {
        if (event.isSuggestedStocksEnabled) {
          emit(suggestedStocksState
            ..suggestedStocks = AppConfig.suggestedStocks);
          await sendStreamForSuggestedStocks(emit);
        } else {
          emit(HoldingsFailedState()
            ..errorCode = ex.code
            ..errorMsg = ex.msg);
        }
      } else {
        emit(HoldingsFailedState()
          ..errorCode = ex.code
          ..errorMsg = ex.msg);
      }
    }
  }

  Future<void> afterFetch(HoldingsModel holdingsModel,
      Emitter<HoldingsState> emit, HoldingsFetchEvent event) async {
    if (holdingsModel.holdings == null || holdingsModel.holdings!.isEmpty) {
      emit(suggestedStocksState..suggestedStocks = AppConfig.suggestedStocks);
      if (event.isSuggestedStocksEnabled) {
        await sendStreamForSuggestedStocks(emit);
      }
    } else {
      holdingsModelfullData = List.from((holdingsModel.holdings!.toList()));
      holdingsFetchDoneState
        ..holdingsModel = holdingsModel
        ..secondaryWatchlistSymbols =
            List.from((holdingsModel.holdings!.toList()))
        ..mainHoldingsSymbols = List.from((holdingsModel.holdings!.toList()));

      if (event.isStreaming) {
        await sendStream(HoldingsStartSymStreamEvent(), emit);
      }

      await _handleFetchHoldingsWithFiltersEvent(
        FetchHoldingsWithFiltersEvent(holdingsFetchDoneState.selectedFilter,
            holdingsFetchDoneState.selectedSortBy),
        emit,
      );

      emit(holdingsFetchDoneState);
      emit(HoldingsChangeState());
    }
  }

  Future<void> _handleFetchHoldingsWithFiltersEvent(
    FetchHoldingsWithFiltersEvent event,
    Emitter<HoldingsState> emit,
  ) async {
    emit(HoldingsProgressState());
    if ((event.filterModel
                ?.where((element) => element.filters?.isNotEmpty ?? false)
                .toList()
                .isNotEmpty ??
            false) ||
        event.selectedSort?.sortType != null) {
      await _filterHoldings(event, emit);
      await _handleSortHoldingsWithFilter(
        event.selectedSort ?? SortModel(),
        emit,
      );
      emit(holdingsFetchDoneState);
    } else {
      holdingsFetchDoneState.isFilterSelected = false;
      holdingsFetchDoneState.isSortSelected = false;
      holdingsFetchDoneState.selectedSortBy = SortModel();
      holdingsFetchDoneState.selectedFilter = getFilterModel();
      holdingsFetchDoneState.holdingsModel?.holdings =
          holdingsFetchDoneState.mainHoldingsSymbols;
      emit(holdingsFetchDoneState);
    }

    holdingsFetchDoneState.holdingsModel
      ?..totalInvested = ACMCalci.totalInvestedHoldings(
          holdingsFetchDoneState.holdingsModel?.holdings ?? [])
      ..overallReturn = ACMCalci.holdingsTotalOverallReturn(
          holdingsFetchDoneState.holdingsModel?.holdings ?? [])
      ..overallReturnPercent = ACMCalci.holdingdtotalOverallPnlPercent(
          holdingsFetchDoneState.holdingsModel?.holdings ?? [])
      ..oneDayReturn = ACMCalci.holdingsTotalOneDayReturn(
          holdingsFetchDoneState.holdingsModel?.holdings ?? [])
      ..oneDayReturnPercent = ACMCalci.holdingTotalOneDayReturnPercent(
          holdingsFetchDoneState.holdingsModel?.holdings ?? [])
      ..overallcurrentValue = ACMCalci.holdingsOverallCurrentValue(
          holdingsFetchDoneState.holdingsModel?.holdings ?? []);
    emit(holdingsFetchDoneState);
  }

  List<FilterModel> getFilterModel() {
    return [
      FilterModel(
        filterName: AppConstants.segment,
        filters: [],
        filtersList: [],
      ),
      FilterModel(
        filterName: AppConstants.moreFilters,
        filters: [],
        filtersList: [],
      ),
    ];
  }

  Future<void> _filterHoldings(
    FetchHoldingsWithFiltersEvent event,
    Emitter<HoldingsState> emit,
  ) async {
    final List<Symbols> holdingsSymbols =
        holdingsFetchDoneState.mainHoldingsSymbols ?? [];
    List<Symbols> filteredSymbols = [];
    bool isFilter = false;
    filteredSymbols = holdingsSymbols;
    if (event.filterModel != null) {
      isFilter = event.filterModel
              ?.where((element) => element.filters?.isNotEmpty ?? false)
              .toList()
              .isNotEmpty ??
          false;
      filteredSymbols =
          filteredSymbols.where((e) => compareFilters(event, e)).toList();

      if (isFilter) {
        holdingsFetchDoneState.selectedFilter = event.filterModel;
        holdingsFetchDoneState.isFilterSelected = true;
        holdingsFetchDoneState.holdingsModel!.holdings = filteredSymbols;
      }
    } else {
      holdingsFetchDoneState.isFilterSelected = false;

      holdingsFetchDoneState.holdingsModel!.holdings = holdingsSymbols;
    }

    emit(HoldingsChangeState());

    emit(holdingsFetchDoneState..isFilterSelected = true);
  }

  bool compareFilters(FetchHoldingsWithFiltersEvent event, Symbols e) {
    bool nse = nseCompare(event.filterModel, e);
    bool bse = bseCompare(event.filterModel, e);
    bool loss = lossCompare(event.filterModel, e);
    bool profit = profitCompare(event.filterModel, e);
    bool segment = nse || bse;
    bool moreFilters = loss || profit;

    return (segment && moreFilters);
  }

  bool bseCompare(List<FilterModel>? element, Symbols e) {
    bool isTrue = (element?.firstWhereOrNull(
                (e) => e.filters?.contains(AppConstants.bse) ?? false) !=
            null
        ? e.sym!.exc == AppConstants.bse
        : element?.firstWhereOrNull(
                    (e) => e.filters?.contains(AppConstants.nse) ?? false) !=
                null
            ? false
            : true);
    return isTrue;
  }

  bool nseCompare(List<FilterModel>? element, Symbols e) {
    bool isTrue = (element?.firstWhereOrNull(
                (e) => e.filters?.contains(AppConstants.nse) ?? false) !=
            null
        ? e.sym!.exc == AppConstants.nse
        : element?.firstWhereOrNull(
                    (e) => e.filters?.contains(AppConstants.bse) ?? false) !=
                null
            ? false
            : true);
    return isTrue;
  }

  bool profitCompare(List<FilterModel>? element, Symbols e) {
    bool isTrue = (element?.firstWhereOrNull((e) =>
                e.filters?.contains(AppConstants.profitHoldings) ?? false) !=
            null
        ? !AppUtils().doubleValue(e.mktValueChng).isNegative
        : element?.firstWhereOrNull((e) =>
                    e.filters?.contains(AppConstants.lossHoldings) ?? false) !=
                null
            ? false
            : true);
    return isTrue;
  }

  bool lossCompare(List<FilterModel>? element, Symbols e) {
    bool isTrue = (element?.firstWhereOrNull((e) =>
                e.filters?.contains(AppConstants.lossHoldings) ?? false) !=
            null
        ? AppUtils().doubleValue(e.mktValueChng).isNegative
        : element?.firstWhereOrNull((e) =>
                    e.filters?.contains(AppConstants.profitHoldings) ??
                    false) !=
                null
            ? false
            : true);
    return isTrue;
  }

  Future<void> _handleSortHoldingsWithFilter(
    SortModel selectedSort,
    Emitter<HoldingsState> emit,
  ) async {
    List<Symbols> symbols =
        holdingsFetchDoneState.holdingsModel?.holdings?.toList() ?? [];
    if (selectedSort.sortType != null) {
      if (selectedSort.sortName == AppConstants.oneDayReturn) {
        if (selectedSort.sortType == Sort.ASCENDING) {
          symbols.sort((Symbols a, Symbols b) => AppUtils()
              .doubleValue(AppUtils().decimalValue(b.oneDayPnL ?? '0'))
              .compareTo(AppUtils()
                  .doubleValue(AppUtils().decimalValue(a.oneDayPnL ?? '0'))));
        } else {
          symbols.sort((Symbols a, Symbols b) => AppUtils()
              .doubleValue(AppUtils().decimalValue(a.oneDayPnL ?? '0'))
              .compareTo(AppUtils()
                  .doubleValue(AppUtils().decimalValue(b.oneDayPnL ?? '0'))));
        }
      } else if (selectedSort.sortName == AppConstants.oneDayReturnPercent) {
        if (selectedSort.sortType == Sort.ASCENDING) {
          symbols.sort((Symbols a, Symbols b) => AppUtils()
              .doubleValue(AppUtils().decimalValue(b.oneDayPnLPercent ?? '0'))
              .compareTo(AppUtils().doubleValue(
                  AppUtils().decimalValue(a.oneDayPnLPercent ?? '0'))));
        } else {
          symbols.sort((Symbols a, Symbols b) => AppUtils()
              .doubleValue(AppUtils().decimalValue(a.oneDayPnLPercent ?? '0'))
              .compareTo(AppUtils().doubleValue(
                  AppUtils().decimalValue(b.oneDayPnLPercent ?? '0'))));
        }
      } else if (selectedSort.sortName == AppConstants.overallReturn) {
        if (selectedSort.sortType == Sort.ASCENDING) {
          symbols.sort((Symbols a, Symbols b) => AppUtils()
              .doubleValue(AppUtils().decimalValue(b.overallPnL ?? '0'))
              .compareTo(AppUtils()
                  .doubleValue(AppUtils().decimalValue(a.overallPnL ?? '0'))));
        } else {
          symbols.sort((Symbols a, Symbols b) => AppUtils()
              .doubleValue(AppUtils().decimalValue(a.overallPnL ?? '0'))
              .compareTo(AppUtils()
                  .doubleValue(AppUtils().decimalValue(b.overallPnL ?? '0'))));
        }
      } else if (selectedSort.sortName == AppConstants.overallReturnPercent) {
        if (selectedSort.sortType == Sort.ASCENDING) {
          symbols.sort((Symbols a, Symbols b) => AppUtils()
              .doubleValue(AppUtils().decimalValue(b.overallPnLPercent ?? '0'))
              .compareTo(AppUtils().doubleValue(
                  AppUtils().decimalValue(a.overallPnLPercent ?? '0'))));
        } else {
          symbols.sort((Symbols a, Symbols b) => AppUtils()
              .doubleValue(AppUtils().decimalValue(a.overallPnLPercent ?? '0'))
              .compareTo(AppUtils().doubleValue(
                  AppUtils().decimalValue(b.overallPnLPercent ?? '0'))));
        }
      } else if (selectedSort.sortName == AppConstants.currentValue) {
        if (selectedSort.sortType == Sort.ASCENDING) {
          symbols.sort((Symbols a, Symbols b) => AppUtils()
              .doubleValue(AppUtils().decimalValue(b.mktValue ?? '0'))
              .compareTo(AppUtils()
                  .doubleValue(AppUtils().decimalValue(a.mktValue ?? '0'))));
        } else {
          symbols.sort((Symbols a, Symbols b) => AppUtils()
              .doubleValue(AppUtils().decimalValue(a.mktValue ?? '0'))
              .compareTo(AppUtils()
                  .doubleValue(AppUtils().decimalValue(b.mktValue ?? '0'))));
        }
      } else if (selectedSort.sortName == AppConstants.alphabetically) {
        if (selectedSort.sortType == Sort.ASCENDING) {
          symbols.sort((Symbols a, Symbols b) {
            return a.dispSym!.toLowerCase().compareTo(b.dispSym!.toLowerCase());
          });
        } else {
          symbols.sort((Symbols a, Symbols b) {
            return b.dispSym!.toLowerCase().compareTo(a.dispSym!.toLowerCase());
          });
        }
      } else if (selectedSort.sortName == AppConstants.price) {
        if (selectedSort.sortType == Sort.ASCENDING) {
          symbols.sort((Symbols a, Symbols b) => AppUtils()
              .doubleValue(AppUtils().decimalValue(b.ltp ?? '0'))
              .compareTo(AppUtils()
                  .doubleValue(AppUtils().decimalValue(a.ltp ?? '0'))));
        } else {
          symbols.sort((Symbols a, Symbols b) => AppUtils()
              .doubleValue(AppUtils().decimalValue(a.ltp ?? '0'))
              .compareTo(AppUtils()
                  .doubleValue(AppUtils().decimalValue(b.ltp ?? '0'))));
        }
      } else if (selectedSort.sortName == AppConstants.chngPercent) {
        if (selectedSort.sortType == Sort.ASCENDING) {
          symbols.sort((Symbols a, Symbols b) => AppUtils()
              .doubleValue(AppUtils().decimalValue(b.chngPer ?? '0'))
              .compareTo(AppUtils()
                  .doubleValue(AppUtils().decimalValue(a.chngPer ?? '0'))));
        } else {
          symbols.sort((Symbols a, Symbols b) => AppUtils()
              .doubleValue(AppUtils().decimalValue(a.chngPer ?? '0'))
              .compareTo(AppUtils()
                  .doubleValue(AppUtils().decimalValue(b.chngPer ?? '0'))));
        }
      }
      holdingsFetchDoneState.selectedSortBy = selectedSort;

      holdingsFetchDoneState.isSortSelected = true;
      holdingsFetchDoneState.holdingsModel!.holdings = symbols;
    } else {
      holdingsFetchDoneState.selectedSortBy = null;

      holdingsFetchDoneState.isSortSelected = false;
      holdingsFetchDoneState.holdingsModel?.holdings = symbols;
    }
    emit(HoldingsChangeState());

    emit(holdingsFetchDoneState..isFilterSelected = true);
  }

  Future<void> _handleHoldingsSearchEvent(
    HoldingsSearchEvent event,
    Emitter<HoldingsState> emit,
  ) async {
    final List<Symbols>? symbolsFilteredUsingSubString = holdingsFetchDoneState
        .holdingsModel?.holdings
        ?.where((Symbols element) {
      final String searchName = '${element.dispSym!} ${element.sym!.exc!}';
      return checkSymNameMatchesInputString(
        searchName,
        event.searchString,
      );
    }).toList();
    emit(HoldingsChangeState());
    holdingsFetchDoneState.searchHoldingsSymbols =
        symbolsFilteredUsingSubString;
    emit(holdingsFetchDoneState
      ..searchHoldingsSymbols = symbolsFilteredUsingSubString);
  }

  Future<void> _handleHoldingsResetSearchEvent(
    Emitter<HoldingsState> emit,
  ) async {
    emit(HoldingsChangeState());
    holdingsFetchDoneState.searchHoldingsSymbols = [];
    emit(holdingsFetchDoneState..searchHoldingsSymbols = []);
  }

  bool checkSymNameMatchesInputString(
    String symbolName,
    String input,
  ) {
    final List<String> queryArr = input.split(' ');

    final bool isMatch = queryArr.every((String element) {
      symbolName = symbolName.toLowerCase();
      return symbolName.startsWith(input.split(' ')[0].toLowerCase());
    });
    return isMatch;
  }

  Future<void> sendStream(
    HoldingsStartSymStreamEvent event,
    Emitter<HoldingsState> emit,
  ) async {
    if (holdingsFetchDoneState.holdingsModel?.holdings != null) {
      final List<String> streamingKeys = <String>[
        AppConstants.streamingLtp,
        AppConstants.streamingChng,
        AppConstants.streamingChgnPer,
        AppConstants.streamingHigh,
        AppConstants.streamingLow,
        AppConstants.high,
        AppConstants.low,
        AppConstants.close
      ];
      if (holdingsFetchDoneState.holdingsModel?.holdings!.isNotEmpty ?? false) {
        emit(
          HoldingsStartStreamState(
            AppHelper().streamDetails(
                holdingsFetchDoneState.holdingsModel?.holdings, streamingKeys),
          ),
        );
      }
    }
  }

  Future<void> responseCallback(
    ResponseData streamData,
    Emitter<HoldingsState> emit,
  ) async {
    if (holdingsFetchDoneState.holdingsModel != null) {
      final List<Symbols>? symbols =
          holdingsFetchDoneState.holdingsModel!.holdings;

      if (symbols != null) {
        final int index = symbols.indexWhere(
            (Symbols element) => element.sym!.streamSym == streamData.symbol);
        if (index != -1) {
          symbols[index] = updateHoldingsData(symbols[index], streamData);
          holdingsFetchDoneState.holdingsModel
            ?..overallReturn = ACMCalci.holdingsTotalOverallReturn(symbols)
            ..overallReturnPercent =
                ACMCalci.holdingdtotalOverallPnlPercent(symbols)
            ..oneDayReturn = ACMCalci.holdingsTotalOneDayReturn(symbols)
            ..totalInvested = ACMCalci.totalInvestedHoldings(symbols)
            ..oneDayReturnPercent =
                ACMCalci.holdingTotalOneDayReturnPercent(symbols)
            ..overallcurrentValue =
                ACMCalci.holdingsOverallCurrentValue(symbols);
          holdingsFetchDoneState.holdingsModel!.holdings = symbols;
          if (holdingsFetchDoneState.isFilterSelected ||
              holdingsFetchDoneState.isSortSelected) {
            await _handleFetchHoldingsWithFiltersEvent(
              FetchHoldingsWithFiltersEvent(
                  holdingsFetchDoneState.selectedFilter,
                  holdingsFetchDoneState.selectedSortBy),
              emit,
            );
          }
          emit(HoldingsChangeState());
          emit(holdingsFetchDoneState);
          if (holdingsFetchDoneState.visibleBottom == 0) {
            holdingsFetchDoneState.visibleBottom = 10;
          }

          CacheRepository.holdingsCache.put(
              'getHoldings',
              HoldingsModel(
                holdingsFetchDoneState.mainHoldingsSymbols,
              ));
        }
      }
    }
  }

  Symbols updateHoldingsData(Symbols symbol, ResponseData? streamData,
      {Symbols? holdings}) {
    symbol.close = streamData?.close ?? symbol.close;
    symbol.ltp = streamData?.ltp ?? symbol.ltp;
    symbol.chng = streamData?.chng ?? symbol.chng;
    symbol.chngPer = streamData?.chngPer ?? symbol.chng;
    symbol.yhigh = streamData?.yHigh ?? symbol.yhigh;
    symbol.ylow = streamData?.yLow ?? symbol.ylow;
    symbol.high = streamData?.high ?? symbol.high;
    symbol.low = streamData?.low ?? symbol.low;
    symbol.invested = ACMCalci.holdingInvestedValue(symbol);
    symbol.avgPrice = symbol.avgPrice ?? "0";
    symbol.mktValue = ACMCalci.holdingMktValue(symbol);
    symbol.mktValueChng = ACMCalci.holdingMktValueChange(symbol);
    symbol.overallPnL = ACMCalci.holdingOverallPnl(symbol);
    symbol.overallPnLPercent = ACMCalci.holdingOverallPnlPercent(symbol);
    symbol.oneDayPnL = ACMCalci.holdingOnedayPnl(symbol);
    symbol.oneDayPnLPercent = ACMCalci.holdingOneDayPnlPercent(symbol);
    return symbol;
  }

  Future<void> sendStreamForSuggestedStocks(
    Emitter<HoldingsState> emit,
  ) async {
    final List<String> streamingKeys = <String>[
      AppConstants.streamingLtp,
      AppConstants.streamingChng,
      AppConstants.streamingChgnPer,
      AppConstants.streamingHigh,
      AppConstants.streamingLow,
      AppConstants.high,
      AppConstants.low,
    ];
    if (suggestedStocksState.suggestedStocks.isNotEmpty) {
      emit(SuggestedStocksStartStreamState(
        AppHelper()
            .streamDetails(suggestedStocksState.suggestedStocks, streamingKeys),
      ));
    }
  }

  Future<void> responseCallbackForSuggestedStocks(
    ResponseData streamData,
    Emitter<HoldingsState> emit,
  ) async {
    if (holdingsFetchDoneState.holdingsModel == null) {
      final List<Symbols> symbols = suggestedStocksState.suggestedStocks;

      final int index = symbols.indexWhere(
          (Symbols element) => element.sym!.streamSym == streamData.symbol);

      if (index != -1) {
        symbols[index].ltp = streamData.ltp ?? symbols[index].ltp;
        symbols[index].chng = streamData.chng ?? symbols[index].chng;
        symbols[index].chngPer = streamData.chngPer ?? symbols[index].chngPer;
        symbols[index].yhigh = streamData.yHigh ?? symbols[index].yhigh;
        symbols[index].ylow = streamData.yLow ?? symbols[index].ylow;
        symbols[index].high = streamData.high ?? symbols[index].high;
        symbols[index].low = streamData.low ?? symbols[index].low;

        emit(HoldingsChangeState());
        emit(suggestedStocksState..suggestedStocks = symbols);
      }
    }
  }

  @override
  HoldingsState getErrorState() {
    return HoldingsErrorState();
  }
}
