import 'package:acml/src/ui/styles/app_widget_size.dart';
import 'package:async/async.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

import '../../../constants/app_constants.dart';
import '../../../data/cache/cache_repository.dart';
import '../../../data/repository/funds/funds_repository.dart';
import '../../../data/repository/positions/positions_repository.dart';
import '../../../data/store/app_calculator.dart';
import '../../../data/store/app_helper.dart';
import '../../../data/store/app_utils.dart';
import '../../../localization/app_localization.dart';
import '../../../models/funds/available_funds_model.dart';
import '../../../models/positions/positions_model.dart';
import '../../../models/sort_filter/sort_filter_model.dart';
import '../../common/base_bloc.dart';
import '../../common/screen_state.dart';

part 'positions_event.dart';
part 'positions_state.dart';

class PositionsBloc extends BaseBloc<PositionsEvent, PositionsState> {
  PositionsBloc() : super(PositionsInitial());
  PositionsDoneState positionsDoneState = PositionsDoneState();
  CancelableOperation? fetchPosition;

  @override
  Future<void> eventHandlerMethod(
    PositionsEvent event,
    Emitter<PositionsState> emit,
  ) async {
    if (event is FetchPositionsEvent) {
      await _handleFetchPositionsEvent(emit, event);
    } else if (event is PositionsStreamingResponseEvent) {
      await responseCallback(event.data, emit);
    } else if (event is GetAvailableFundsEvent) {
      await _handleGetAvailableFundsEvent(event, emit);
    } else if (event is PositionStartStream) {
      await sendStream(emit);
    }
  }

  Future<void> _handleFetchPositionsEvent(
    Emitter<PositionsState> emit,
    FetchPositionsEvent event,
  ) async {
    positionsDoneState.searchString = event.searchString;
    fetchPosition?.cancel();
    if (event.loading || event.type != positionsDoneState.type) {
      emit(PositionsProgressState());
    }
    fetchPosition = CancelableOperation.fromFuture(fetchPositions(event, emit));
    await fetchPosition?.valueOrCancellation();
  }

  List<Positions> positionsCache = [];
  Future<void> fetchPositions(
      FetchPositionsEvent event, Emitter<PositionsState> emit) async {
    if (event.loading) emit(PositionsProgressState());
    final PositionsModel? getPositionsCache = event.loading && event.fetchAgain
        ? null
        : await CacheRepository.positions.get('getPositions');
    try {
      final BaseRequest request = BaseRequest();

      List<Filters> multiFilters = setFilter(event);
      request.addToData('type', 'net');
      request.addToData('multiFilters', multiFilters);
      List? current = [
        for (FilterModel list in event.filterModel ?? []) ...[
          ...list.filters ?? []
        ]
      ];
      List? previous = [
        for (FilterModel list in positionsDoneState.filterModel ?? []) ...[
          ...list.filters ?? []
        ]
      ];
      Function eq = const ListEquality().equals;

      if (getPositionsCache != null && eq(current, previous)) {
        await afterApiFetch(getPositionsCache, event, emit, true);
      }

      if (event.fetchAgain || (getPositionsCache == null)) {
        PositionsModel positionsModel =
            await PositionsRepository().getPositionsRequest(request);
        await afterApiFetch(positionsModel, event, emit, false);
      }
    } on ServiceException catch (ex) {
      if ((event.filterModel
                  ?.where((element) => element.filters?.isNotEmpty ?? false)
                  .toList()
                  .isNotEmpty ??
              false) ||
          event.selectedSort?.sortName != null) {
        positionsDoneState.positionsModel?.positions = [];
        if (event.loading) emit(PositionsProgressState());
        await Future.delayed(const Duration(milliseconds: 150));
        positionsDoneState.positionsModel?.positions = [];
        positionsDoneState.mainPositionsSymbols = [];
        positionsDoneState
          ..overallTodayPnL = "0.00"
          ..overallTodayPnLPercent = "0.00"
          ..overallPnL = "0.00"
          ..overallPnLPercent = "0.00";

        emit(positionsDoneState);
      } else {
        if (getPositionsCache != null) {
          await afterApiFetch(getPositionsCache, event, emit, true);
        } else {
          emit(PositionsFailedState()
            ..errorCode = ex.code
            ..errorMsg = ex.msg);
        }
      }
    } on FailedException catch (ex) {
      if ((event.filterModel
                  ?.where((element) => element.filters?.isNotEmpty ?? false)
                  .toList()
                  .isNotEmpty ??
              false) ||
          event.selectedSort?.sortName != null) {
        positionsDoneState.positionsModel?.positions = [];
        if (event.loading) emit(PositionsProgressState());
        await Future.delayed(const Duration(milliseconds: 150));
        positionsDoneState.positionsModel?.positions = [];
        positionsDoneState.mainPositionsSymbols = [];
        positionsDoneState
          ..overallTodayPnL = "0.00"
          ..overallTodayPnLPercent = "0.00"
          ..overallPnL = "0.00"
          ..overallPnLPercent = "0.00";

        emit(positionsDoneState);
      } else {
        if (getPositionsCache != null) {
          await afterApiFetch(getPositionsCache, event, emit, true);
        } else {
          emit(PositionsFailedState()
            ..errorCode = ex.code
            ..errorMsg = ex.msg);
        }
      }
    }
  }

  Future<void> afterApiFetch(PositionsModel positionsModel,
      FetchPositionsEvent event, emit, bool fromcache) async {
    final PositionsModel positionUpdateModel =
        PositionsModel.copyModel(positionsModel);

    positionUpdateModel.positions = positionUpdateModel.positions?.map((e) {
      e.isOneDay = event.type == AppLocalizations().day;
      e.ltp = fromcache
          ? (positionsCache.firstWhereOrNull((element) =>
                      element.positionIdForInternalValidation ==
                      e.positionIdForInternalValidation) ??
                  e)
              .ltp
          : e.ltp;
      e.close = fromcache
          ? (positionsCache.firstWhereOrNull((element) =>
                      element.positionIdForInternalValidation ==
                      e.positionIdForInternalValidation) ??
                  e)
              .close
          : e.close;
      return e;
    }).toList();
    positionsDoneState.filterModel = event.filterModel;
    positionsDoneState.mainPositionsSymbols = positionUpdateModel.positions;

    positionUpdateModel.positions = positionUpdateModel.positions;
    positionsDoneState.positionsModel = positionUpdateModel;
    positionsDoneState.type = event.type;
    positionsDoneState.selectedSort = event.selectedSort;
    await sortandSearchEvent(emit, loading: true);

    await sendStream(emit);
    if (positionsCache.length !=
            (positionsDoneState.positionsModel?.positions?.length ?? 0) ||
        event.loading) {
      emit(PositionsChangeState());

      positionsCache = positionsDoneState.positionsModel?.positions ?? [];
      await Future.delayed(const Duration(milliseconds: 100), () {});
      positionsDoneState
        ..totalInvestedValue =
            ACMCalci.totalInvestedPosition(positionUpdateModel.positions ?? [])
        ..overallTodayPnL =
            ACMCalci.totalOneDayPnlPosition(positionUpdateModel.positions ?? [])
        ..overallTodayPnLPercent = ACMCalci.totalOneDayPnlPercentPosition(
            positionUpdateModel.positions ?? [])
        ..overallPnL = ACMCalci.totalOverallPnLPosition(
            positionUpdateModel.positions ?? [])
        ..overallPnLPercent = ACMCalci.totalOverallPnlPercentPosition(
            positionUpdateModel.positions ?? []);
    }
    await Future.delayed(const Duration(milliseconds: 150));

    emit(positionsDoneState);
  }

  bool isFetchAgain(
    FetchPositionsEvent event,
  ) {
    return (((event.filterModel
                ?.where((element) => element.filters?.isNotEmpty ?? false)
                .toList()
                .isNotEmpty ??
            false)) ||
        event.fetchAgain);
  }

  List<Filters> setFilter(FetchPositionsEvent event) {
    List<Filters> multiFilters = <Filters>[];
    List<String> filterKeys = [
      AppConstants.ordAction,
      AppConstants.actualExc,
      AppConstants.prdType,
    ];

    if (event.filterModel != null && event.filterModel!.isNotEmpty) {
      int i = 0;
      for (FilterModel element in event.filterModel!) {
        List<String> filters = [];
        for (Filters element in element.filtersList!) {
          if (element.value == AppConstants.fo) {
            element.value = AppConstants.nfo;
          }
          if (element.value == AppConstants.carryForward) {
            element.value = AppConstants.carryForwardValue;
          }
          filters.add(element.value);
        }
        if (filters.isNotEmpty) {
          if (element.filterName != AppConstants.moreFilters) {
            multiFilters.add(Filters(key: filterKeys[i], value: filters));
          }
        }

        i++;
      }
    }
    return multiFilters;
  }

  Future<void> _handleSortOrdersWithFilter() async {
    List<Positions> positions =
        positionsDoneState.positionsModel?.positions ?? [];

    if (positionsDoneState.selectedSort?.sortName == AppConstants.returns) {
      if (positionsDoneState.selectedSort?.sortType == Sort.ASCENDING) {
        positions.sort((Positions a, Positions b) => AppUtils()
            .doubleValue(AppUtils().decimalValue(b.oneDayPnLPercent ?? '0'))
            .compareTo(AppUtils().doubleValue(
                AppUtils().decimalValue(a.oneDayPnLPercent ?? '0'))));
      } else {
        positions.sort((Positions a, Positions b) => AppUtils()
            .doubleValue(AppUtils().decimalValue(a.oneDayPnLPercent ?? '0'))
            .compareTo(AppUtils().doubleValue(
                AppUtils().decimalValue(b.oneDayPnLPercent ?? '0'))));
      }
    } else if (positionsDoneState.selectedSort?.sortName ==
        AppConstants.absoluteChange) {
      if (positionsDoneState.selectedSort?.sortType == Sort.ASCENDING) {
        positions.sort((Positions a, Positions b) => AppUtils()
            .doubleValue(AppUtils().decimalValue(b.oneDayPnL ?? '0'))
            .compareTo(AppUtils()
                .doubleValue(AppUtils().decimalValue(a.oneDayPnL ?? '0'))));
      } else {
        positions.sort((Positions a, Positions b) => AppUtils()
            .doubleValue(AppUtils().decimalValue(a.oneDayPnL ?? '0'))
            .compareTo(AppUtils()
                .doubleValue(AppUtils().decimalValue(b.oneDayPnL ?? '0'))));
      }
    } else if (positionsDoneState.selectedSort?.sortName ==
        AppConstants.currentValue) {
      if (positionsDoneState.selectedSort?.sortType == Sort.ASCENDING) {
        positions.sort((Positions a, Positions b) => AppUtils()
            .doubleValue(AppUtils().decimalValue(b.currentValue ?? '0'))
            .compareTo(AppUtils()
                .doubleValue(AppUtils().decimalValue(a.currentValue ?? '0'))));
      } else {
        positions.sort((Positions a, Positions b) => AppUtils()
            .doubleValue(AppUtils().decimalValue(a.currentValue ?? '0'))
            .compareTo(AppUtils()
                .doubleValue(AppUtils().decimalValue(b.currentValue ?? '0'))));
      }
    } else if (positionsDoneState.selectedSort?.sortName ==
        AppConstants.alphabetically) {
      if (positionsDoneState.selectedSort?.sortType == Sort.ASCENDING) {
        positions.sort((Positions a, Positions b) {
          return a.dispSym!.toLowerCase().compareTo(b.dispSym!.toLowerCase());
        });
      } else {
        positions.sort((Positions a, Positions b) {
          return b.dispSym!.toLowerCase().compareTo(a.dispSym!.toLowerCase());
        });
      }
    }
    positions.map((e) {
      e.avgPrice = ACMCalci.positionAvgPrice(
        e,
      );
      e.oneDayPnL = ACMCalci.oneDayPnlPosition(e);
      e.currentValue = ACMCalci.currentValuePosition(e);
      e.overallPnL = ACMCalci.overallPnLPosition(e);
      return e;
    }).toList();

    bool isProfitPositions = positionsDoneState.filterModel!
        .where((e) =>
            e.filterName == AppConstants.moreFilters &&
            e.filters!.contains(AppConstants.profitPositions))
        .toList()
        .isNotEmpty;
    bool isLossPositions = positionsDoneState.filterModel!
        .where((e) =>
            e.filterName == AppConstants.moreFilters &&
            e.filters!.contains(AppConstants.lossPositions))
        .toList()
        .isNotEmpty;

    if (!(isProfitPositions && isLossPositions)) {
      positions = positions.where((element) {
        if (isProfitPositions
            ? AppUtils().doubleValue(!element.isOneDay
                    ? element.overallPnL
                    : element.oneDayPnL) >=
                0
            : isLossPositions
                ? AppUtils().doubleValue(!element.isOneDay
                        ? element.overallPnL
                        : element.oneDayPnL) <
                    0
                : true) {
          return true;
        } else {
          return false;
        }
      }).toList();
    }
    positionsDoneState.positionsModel!.positions = positions;
  }

  Future<void> sendStream(
    Emitter<PositionsState> emit,
  ) async {
    if (positionsDoneState.positionsModel != null) {
      final List<String> streamingKeys = <String>[
        AppConstants.streamingLtp,
        AppConstants.streamingChng,
        AppConstants.streamingChgnPer,
        AppConstants.streamingHigh,
        AppConstants.close,
        AppConstants.streamingLow,
      ];
      if (positionsDoneState.mainPositionsSymbols?.isNotEmpty ?? false) {
        emit(
          PositionsStartStreamState(
            AppHelper().streamDetails(
              positionsDoneState.mainPositionsSymbols,
              streamingKeys,
            ),
          ),
        );
      }
    }
  }

  Future<void> responseCallback(
    ResponseData streamData,
    Emitter<PositionsState> emit,
  ) async {
    PositionsModel? positionCache =
        await CacheRepository.positions.get('getPositions');
    int positionIndex = -1;
    if (positionsDoneState.positionsModel != null) {
      final List<Positions>? positions =
          positionsDoneState.mainPositionsSymbols;

      if (positions != null && positions.isNotEmpty) {
        final String symbolName = streamData.symbol!;

        positions.map((Positions item) {
          if (item.sym?.streamSym == symbolName) {
            item.ltp = streamData.ltp ?? item.ltp;
            item.chng = streamData.chng ?? item.chng;
            item.chngPer = streamData.chngPer ?? item.chngPer;
            item.yhigh = streamData.yHigh ?? item.yhigh;
            item.close = streamData.close ?? item.close;

            item.ylow = streamData.yLow ?? item.ylow;
            item.invested = ACMCalci.investedValuePosition(item);
            item.oneDayPnL = ACMCalci.oneDayPnlPosition(item);

            item.oneDayPnLPercent = ACMCalci.oneDayPnlPercentPosition(item);
            item.overallPnL = ACMCalci.overallPnLPosition(item);
            item.overallPnLPercent = ACMCalci.overallPnLPercentPosition(item);
            item.currentValue = ACMCalci.currentValuePosition(item);
          }
          positionIndex = positionCache?.positions?.indexWhere(
                (element) =>
                    item.positionIdForInternalValidation ==
                    element.positionIdForInternalValidation,
              ) ??
              -1;
          if (positionIndex >= 0) {
            positionCache?.positions?[positionIndex] = item;
          }
        }).toList();
        positionsDoneState.positionsModel?.positions = positions;

        await sortandSearchEvent(emit, loading: false);
        emit(PositionsChangeState());
        emit(positionsDoneState
          ..totalInvestedValue = ACMCalci.totalInvestedPosition(
              positionsDoneState.positionsModel?.positions ?? [])
          ..overallTodayPnL = ACMCalci.totalOneDayPnlPosition(
              positionsDoneState.positionsModel?.positions ?? [])
          ..overallTodayPnLPercent = ACMCalci.totalOneDayPnlPercentPosition(
              positionsDoneState.positionsModel?.positions ?? [])
          ..overallPnL = ACMCalci.totalOverallPnLPosition(
              positionsDoneState.positionsModel?.positions ?? [])
          ..overallPnLPercent = ACMCalci.totalOverallPnlPercentPosition(
              positionsDoneState.positionsModel?.positions ?? []));
        if (positionIndex != -1) {
          CacheRepository.positions.put('getPositions', positionCache);
        }
      }
    }
  }

  Future<void> sortandSearchEvent(Emitter<PositionsState> emit,
      {bool loading = true}) async {
    await _handlePositionSearchEvent(
      emit,
    );

    await _handleSortOrdersWithFilter();
    await _handlePositionTypeChangeEvent();
  }

  Future<void> _handleGetAvailableFundsEvent(
    GetAvailableFundsEvent event,
    Emitter<PositionsState> emit,
  ) async {
    final availableFunds =
        await CacheRepository.groupCache.get('availableFunds');
    if (availableFunds != null) {
      emit(AvailableFundsDoneState()..availableFunds = availableFunds);
    } else {
      emit(PositionsProgressState());
    }
    try {
      final BaseRequest request = BaseRequest();
      AvailableFundsModel availableFundsModel =
          await FundsRepository().getAvailableFunds(request);
      CacheRepository.groupCache
          .put('availableFunds', availableFundsModel.availableFunds!);

      emit(AvailableFundsDoneState()
        ..availableFunds = availableFundsModel.availableFunds!);
    } on ServiceException catch (ex) {
      emit(PositionsFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      final availableFunds =
          await CacheRepository.groupCache.get('availableFunds');
      if (availableFunds != null) {
        emit(AvailableFundsDoneState()..availableFunds = availableFunds);
      }
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(PositionsErrorState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  @override
  PositionsState getErrorState() {
    return PositionsErrorState();
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

  _handlePositionSearchEvent(
    Emitter<PositionsState> emit,
  ) async {
    if (positionsDoneState.searchString != "" &&
        positionsDoneState.searchString != null) {
      final List<Positions> symbolsFilteredUsingSubString =
          positionsDoneState.mainPositionsSymbols!.where((Positions position) {
        final String searchName = position.baseSym?.toLowerCase() ?? "";
        return checkSymNameMatchesInputString(
          searchName,
          positionsDoneState.searchString?.toLowerCase() ?? "",
        );
      }).toList();

      positionsDoneState.positionsModel?.positions =
          symbolsFilteredUsingSubString;
    } else {
      _handlePositionResetSearchEvent();
    }
  }

  _handlePositionResetSearchEvent() async {
    positionsDoneState.positionsModel?.positions =
        positionsDoneState.mainPositionsSymbols;
  }

  _handlePositionTypeChangeEvent() async {
    List<Positions> symbolsFilteredUsingSubString =
        positionsDoneState.positionsModel!.positions!;
    if (positionsDoneState.type == AppLocalizations().day) {
      symbolsFilteredUsingSubString = [];
      for (int i = 0;
          (i < (positionsDoneState.positionsModel!.positions?.length ?? 0));
          i++) {
        Positions position = positionsDoneState.positionsModel!.positions![i];
        if ((AppUtils().intValue(position.dayBuyQty) +
                AppUtils().intValue(position.daySellQty)) !=
            0) {
          symbolsFilteredUsingSubString.add(position);
        }
      }
    }

    positionsDoneState
      ..isOneDay = true
      ..positionsModel?.positions = symbolsFilteredUsingSubString;
  }
}
