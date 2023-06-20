import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

import '../../constants/app_constants.dart';
import '../../data/cache/cache_repository.dart';
import '../../data/repository/watchlist/watchlist_repository.dart';
import '../../data/store/app_helper.dart';
import '../../data/store/app_utils.dart';
import '../../localization/app_localization.dart';
import '../../models/common/message_model.dart';
import '../../models/common/sym_model.dart';
import '../../models/common/symbols_model.dart';
import '../../models/sort_filter/sort_filter_model.dart';
import '../../models/watchlist/symbol_watchlist_map_holder_model.dart';
import '../../models/watchlist/watchlist_delete_group_model.dart';
import '../../models/watchlist/watchlist_group_model.dart';
import '../../models/watchlist/watchlist_rename_watchlist_model.dart';
import '../../models/watchlist/watchlist_symbols_model.dart';
import '../common/base_bloc.dart';
import '../common/screen_state.dart';

part 'watchlist_event.dart';
part 'watchlist_state.dart';

class WatchlistBloc extends BaseBloc<WatchlistEvent, WatchlistState> {
  WatchlistBloc() : super(WatchlistInitState());

  WatchlistDoneState watchlistDoneState = WatchlistDoneState();
  WatchlistGetGroupsState watchlistGetGroupsState = WatchlistGetGroupsState();

  @override
  Future<void> eventHandlerMethod(
      WatchlistEvent event, Emitter<WatchlistState> emit) async {
    if (event is GetCorpSymListEvent) {
      await _handleGetCorpSymListEvent(event, emit);
    } else if (event is WatchlistGetGroupsEvent) {
      await _handleWatchlistGetGroupsEvent(event, emit);
    } else if (event is WatchlistGetSymbolsEvent) {
      await _handleWatchlistGetSymbolsEvent(event, emit);
    } else if (event is SelectedWatchlistAndTabEvent) {
      await _handleSelectedWatchlistAndTabEvent(event, emit);
    } else if (event is WatchlistDeleteGroupEvent) {
      await _handleWatchlistDeleteGroupEvent(event, emit);
    } else if (event is WatchlistReorderEvent) {
      await _handleRearrangeSymbolEvent(event, emit);
    } else if (event is WatchlistDeleteSymbolEvent) {
      await _handleDeleteSymbolEvent(event, emit);
    } else if (event is WatchlistStartSymStreamEvent) {
      await sendStream(emit);
    } else if (event is WatchlistStreamingResponseEvent) {
      await responseCallback(event.data, emit);
    } else if (event is WatchlistRenameGroupEvent) {
      await _handleWatchlistRenameGroupEvent(event, emit);
    } else if (event is WatchlistGetSymbolsForAllWatchlistEvent) {
      await _handleWatchlistGetSymbolsForAllWatchlistEvent(event, emit);
    } else if (event is WatchlistFilterSortSymbolEvent) {
      await _handleWatchlistFilterSortSymbolEvent(event, emit);
    } else if (event is WatchlistSetMyHoldingsSymbolsEvent) {
      await _handleWatchlistSetMyHoldingsSymbolsEvent(event, emit);
    }
  }

  Future<void> _handleGetCorpSymListEvent(
    GetCorpSymListEvent event,
    Emitter<WatchlistState> emit,
  ) async {
    try {
      final BaseRequest request = BaseRequest();
      await WatchlistRepository().getCorpSymListRequest(request);

      emit(CorpSymListDoneState());
    } on ServiceException catch (ex) {
      emit(CorpSymListFailureState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(CorpSymListFailureState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleWatchlistGetGroupsEvent(
      WatchlistGetGroupsEvent event, Emitter<WatchlistState> emit) async {
    emit(WatchlistProgressState());
    try {
      final BaseRequest request = BaseRequest();
      final WatchlistGroupModel watchlistGroupModel =
          await WatchlistRepository().getWatchlistGroupsRequest(request);
      if (event.requestAllSymbols) {
        emit(WatchlistGetGroupsState());
      }
      emit(WatchlistChangeState());
      emit(watchlistDoneState..watchlistGroupModel = watchlistGroupModel);
      emit(WatchlistGetGroupsDone());
    } on ServiceException catch (ex) {
      emit(WatchlistServiceExpectionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(WatchlistFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleWatchlistGetSymbolsEvent(
      WatchlistGetSymbolsEvent event, Emitter<WatchlistState> emit) async {
    emit(WatchlistProgressState());

    try {
      final BaseRequest request = BaseRequest(data: event.group.toJson());
      final symbolCacheModel =
          await CacheRepository.watchlistCache.get(event.group.wName ?? "");
      WatchlistSymbolsModel? watchlistSymsModel;
      if (symbolCacheModel is WatchlistSymbolsModel) {
        watchlistSymsModel = WatchlistSymbolsModel(
          symbolCacheModel
              .getSymbols()
              .map((symbol) => Symbols.copyModel(symbol))
              .toList(),
        );
        await postFetchEvent(watchlistSymsModel, event, emit);
        if (event.fetchApi) {
          WatchlistRepository().removeWatchlistItem(event.group.wName ?? "");
        }
      }
      if (event.fetchApi || (watchlistSymsModel?.symbols.isEmpty ?? true)) {
        watchlistSymsModel = await WatchlistRepository()
            .getWatchlistSymbolsRequest(request, wId: event.group.wId!);
      }

      await postFetchEvent(watchlistSymsModel, event, emit);
    } on ServiceException catch (ex) {
      watchlistDoneState.watchlistSymbolsModel = null;
      emit(WatchlistServiceExpectionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      watchlistDoneState.watchlistSymbolsModel = null;
      emit(WatchlistFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> postFetchEvent(WatchlistSymbolsModel? watchlistSymsModel,
      WatchlistGetSymbolsEvent event, Emitter<WatchlistState> emit) async {
    watchlistDoneState.secondaryWatchlistSymbols = watchlistSymsModel!.symbols;

    watchlistDoneState.mainWatchlistSymbols =
        List.from(watchlistSymsModel.symbols);

    watchlistDoneState.watchlistSymbolsModel = watchlistSymsModel;

    watchlistDoneState.watchlistGroupModel!.groups!
            .firstWhere((element) => element.wId == event.group.wId)
            .symbolsCount =
        watchlistDoneState.watchlistSymbolsModel!.symbols.length;
    if (event.isFromWatchlist) {
      await sendStream(emit);
      await _handleWatchlistFilterSortSymbolEvent(
          WatchlistFilterSortSymbolEvent(
              watchlistDoneState.selectedWatchlist,
              watchlistDoneState.watchlistGroupModel!.groups!
                  .firstWhere((element) =>
                      element.wName == watchlistDoneState.selectedWatchlist)
                  .selectedSortBy,
              watchlistDoneState.watchlistGroupModel!.groups!
                  .firstWhere((element) =>
                      element.wName == watchlistDoneState.selectedWatchlist)
                  .selectedFilter),
          emit);
    }

    emit(watchlistDoneState);
  }

  bool isSelectedWatchlistAvailableInGroups() {
    bool isSelectedWatchlistAvailableInGroup = false;
    for (var element in watchlistDoneState.watchlistGroupModel!.groups!) {
      if (element.wName == watchlistDoneState.selectedWatchlist) {
        isSelectedWatchlistAvailableInGroup = true;
      }
    }
    return isSelectedWatchlistAvailableInGroup;
  }

  Future<void> _handleWatchlistFilterSortSymbolEvent(
      WatchlistFilterSortSymbolEvent event,
      Emitter<WatchlistState> emit) async {
    emit(WatchlistProgressState());
    List<Symbols> symbols =
        (event.selectedWatchllist == AppLocalizations().myStocks
                ? (watchlistDoneState.myHoldingsSymbols ?? [])
                : (watchlistDoneState.secondaryWatchlistSymbols ?? []))
            .toList();

    if (event.selectedFilter
            ?.where((element) => element.filters?.isNotEmpty ?? false)
            .toList()
            .isNotEmpty ??
        false) {
      symbols = filterSymbols(event, symbols);
      watchlistDoneState.watchlistGroupModel!.groups!
          .firstWhere((element) =>
              element.wName == watchlistDoneState.selectedWatchlist)
          .selectedFilter = event.selectedFilter;
    } else {
      watchlistDoneState.watchlistGroupModel!.groups!
          .firstWhere((element) =>
              element.wName == watchlistDoneState.selectedWatchlist)
          .selectedFilter = getFilterModel();
    }
    if (event.selectedSort?.sortType != null) {
      sortSymbols(event, symbols);
      watchlistDoneState.watchlistGroupModel!.groups!
          .firstWhere((element) =>
              element.wName == watchlistDoneState.selectedWatchlist)
          .selectedSortBy = event.selectedSort;
      watchlistDoneState.watchlistSymbolsModel?.symbols = symbols;
    } else {
      watchlistDoneState.watchlistSymbolsModel?.symbols = symbols;
      watchlistDoneState.watchlistGroupModel!.groups!
          .firstWhere((element) =>
              element.wName == watchlistDoneState.selectedWatchlist)
          .selectedSortBy = SortModel();
    }
    emit(WatchlistChangeState());
    emit(watchlistDoneState);
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

  List<Symbols> filterSymbols(
      WatchlistFilterSortSymbolEvent event, List<Symbols> symbols) {
    if (event.selectedFilter != null && event.selectedFilter!.isNotEmpty) {
      {
        if (event.selectedFilter!.isNotEmpty) {
          List<Symbols>? filteredSymbols;
          bool isFilter = false;
          Set<Symbols>? filteredSymbolsSet = {}; // to avoid duplicates used set
          for (FilterModel element in event.selectedFilter!) {
            if (element.filters!.contains(AppConstants.nse)) {
              isFilter = true;
              filteredSymbols = symbols
                  .where((element) => element.sym!.exc == AppConstants.nse)
                  .toList();
              filteredSymbolsSet.addAll(filteredSymbols);
            }
            if (element.filters!.contains(AppConstants.bse)) {
              filteredSymbols = symbols
                  .where((element) => element.sym!.exc == AppConstants.bse)
                  .toList();
              filteredSymbolsSet.addAll(filteredSymbols);
              isFilter = true;
            }
            if (element.filters!.contains(AppConstants.future)) {
              filteredSymbols = symbols
                  .where((element) =>
                      element.sym!.instrument!.contains(AppConstants.fut))
                  .toList();
              isFilter = true;

              filteredSymbolsSet.addAll(filteredSymbols);
            }
            if (element.filters!.contains(AppConstants.options)) {
              filteredSymbols = symbols
                  .where((element) =>
                      element.sym!.instrument!.contains(AppConstants.opt))
                  .toList();
              isFilter = true;

              filteredSymbolsSet.addAll(filteredSymbols);
            }
            // if (element.filters!.contains(AppConstants.myHoldings)) {
            //   filteredSymbols = symbols
            //       .where((element) =>
            //       element.sym!.instrument!.contains(AppConstants.opt))
            //       .toList();
            //   isFilter = true;
            //
            //   filteredSymbolsSet.addAll(filteredSymbols);
            //
            // }
          }
          if (isFilter) {
            watchlistDoneState.watchlistSymbolsModel?.symbols =
                filteredSymbolsSet.toList();
            watchlistDoneState.watchlistGroupModel!.groups!
                .firstWhere(
                    (element) => element.wName == event.selectedWatchllist)
                .selectedFilter = event.selectedFilter;
          }
        } else {
          watchlistDoneState.watchlistGroupModel!.groups!
              .firstWhere(
                  (element) => element.wName == event.selectedWatchllist)
              .selectedFilter = null;
        }
      }
    }
    return watchlistDoneState.watchlistSymbolsModel?.symbols ?? [];
  }

  void sortSymbols(
      WatchlistFilterSortSymbolEvent event, List<Symbols> symbols) {
    if (event.selectedSort != null) {
      if (event.selectedSort!.sortName == AppConstants.alphabetically) {
        if (event.selectedSort!.sortType == Sort.ASCENDING) {
          symbols.sort((Symbols a, Symbols b) =>
              a.dispSym!.toLowerCase().compareTo(b.dispSym!.toLowerCase()));
        } else {
          symbols.sort((Symbols a, Symbols b) =>
              b.dispSym!.toLowerCase().compareTo(a.dispSym!.toLowerCase()));
        }
      } else if (event.selectedSort!.sortName == AppConstants.price) {
        if (event.selectedSort!.sortType == Sort.ASCENDING) {
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
      } else if (event.selectedSort!.sortName == AppConstants.chngPercent) {
        if (event.selectedSort!.sortType == Sort.ASCENDING) {
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
    }
  }

  Future<void> _handleWatchlistSetMyHoldingsSymbolsEvent(
      WatchlistSetMyHoldingsSymbolsEvent event,
      Emitter<WatchlistState> emit) async {
    watchlistDoneState.myHoldingsSymbols = event.myHoldingsSymbols;

    emit(WatchlistChangeState());

    emit(watchlistDoneState);
  }

  Future<void> _handleWatchlistGetSymbolsForAllWatchlistEvent(
      WatchlistGetSymbolsForAllWatchlistEvent event,
      Emitter<WatchlistState> emit) async {
    emit(WatchlistProgressState());
    WatchlistSymbolsModel? watchlistSymbols;
    try {
      emit(WatchlistProgressState());
      int i = 0;
      for (var element in watchlistDoneState.watchlistGroupModel!.groups!) {
        try {
          final BaseRequest request = BaseRequest(data: element.toJson());
          final WatchlistSymbolsModel? watchlistSymbolsModel =
              await WatchlistRepository()
                  .getWatchlistSymbolsRequest(request, wId: element.wId!);
          element.symbolsCount = watchlistSymbolsModel!.symbols.length;
          watchlistDoneState.watchlistGroupModel!.groups![i].symbolsCount =
              element.symbolsCount;

          for (var symbol in watchlistSymbolsModel.symbols) {
            SymbolWatchlistMapHolder().add(symbol.sym!.id!, element.wName!);
          }
        } catch (e) {
          watchlistDoneState.watchlistGroupModel!.groups![i].editable = false;
        }

        i++;
      }
      emit(WatchlistChangeState());

      emit(WatchlistAllSymsDoneState()
        ..watchlistSymbolsModel = watchlistSymbols
        ..watchlistGroupModel = watchlistDoneState.watchlistGroupModel);
      emit(watchlistDoneState);
    } on ServiceException catch (ex) {
      emit(WatchlistServiceExpectionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(WatchlistFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleSelectedWatchlistAndTabEvent(
      SelectedWatchlistAndTabEvent event, Emitter<WatchlistState> emit) async {
    emit(WatchlistChangeState());
    emit(watchlistDoneState
      ..selectedWatchlist = event.selectedWatchlist
      ..selectedTab = event.selectedTab);
  }

  Future<void> _handleWatchlistDeleteGroupEvent(
      WatchlistDeleteGroupEvent event, Emitter<WatchlistState> emit) async {
    emit(WatchlistProgressState());
    emit(watchlistDoneState);
    try {
      final BaseRequest request = BaseRequest();
      request.addToData('wName', event.group.wName);

      final WatchlistDeleteGroupModel watchlistDeleteGroupModel =
          await WatchlistRepository().deleteWatchlistGroup(request);
      WatchlistRepository().removeWatchlistItem(event.group.wId!);
      watchlistDoneState.watchlistGroupModel!.groups!
          .removeWhere((element) => element.wId == event.group.wId);
      SymbolWatchlistMapHolder().removeWatchlist(event.group.wName!);
      emit(watchlistDoneState);
      emit(WatchlistDeleteGroupState()
        ..watchlistDeleteGroupModel = watchlistDeleteGroupModel);
    } on ServiceException catch (ex) {
      emit(WatchlistServiceExpectionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(WatchlistDeleteGroupFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleRearrangeSymbolEvent(
      WatchlistReorderEvent event, Emitter<WatchlistState> emit) async {
    emit(WatchlistProgressState());
    final List<Symbols> symbols =
        watchlistDoneState.watchlistSymbolsModel!.symbols;
    final Symbols symbolAtOldPosition = symbols[event.oldPosition];
    symbols.removeAt(event.oldPosition);
    final int newIndex = event.oldPosition < event.newPosition
        ? event.newPosition - 1
        : event.newPosition;
    symbols.insert(newIndex, symbolAtOldPosition);
    final List<Sym?> symValueList =
        symbols.map((Symbols item) => item.sym).toList();
    watchlistDoneState.watchlistSymbolsModel!.symbols = symbols;
    emit(watchlistDoneState);

    try {
      final BaseRequest request = BaseRequest();
      request.addToData('wName', event.selectedGroup.wName);
      request.addToData('syms', symValueList);

      MessageModel messageModel =
          await WatchlistRepository().reArrangeSymbolInWatchlist(request);

      if (messageModel.isSuccess()) {
        watchlistDoneState.mainWatchlistSymbols = symbols;
        watchlistDoneState.watchlistSymbolsModel!.symbols = symbols;
        CacheRepository.watchlistCache.put(event.selectedGroup.wName!,
            watchlistDoneState.watchlistSymbolsModel!);
        emit(WatchlistRearrangeSymState(messageModel.infoMsg));
        SelectedWatchlistAndTabEvent(
            event.selectedGroup.wName!, AppConstants.tab1);
        emit(WatchlistChangeState());
        emit(watchlistDoneState
          ..selectedWatchlist = event.selectedGroup.wName!
          ..selectedTab = AppConstants.tab1);
      }
    } on ServiceException catch (ex) {
      onFailureRearrange(emit, symbols, event);
      emit(WatchlistRearrangeSymFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    } on FailedException catch (ex) {
      onFailureRearrange(emit, symbols, event);
      emit(WatchlistRearrangeSymFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  void onFailureRearrange(Emitter<WatchlistState> emit, List<Symbols> symbols,
      WatchlistReorderEvent event) {
    emit(WatchlistProgressState());

    final element = symbols.removeAt(event.oldPosition < event.newPosition
        ? event.newPosition - 1
        : event.newPosition);

    symbols.insert(event.oldPosition, element);

    watchlistDoneState.watchlistSymbolsModel!.symbols = symbols;
    emit(watchlistDoneState);
  }

  Future<void> _handleDeleteSymbolEvent(
      WatchlistDeleteSymbolEvent event, Emitter<WatchlistState> emit) async {
    emit(WatchlistProgressState());
    emit(watchlistDoneState);

    final List<Symbols> symbols = watchlistDoneState.mainWatchlistSymbols!;
    String symbolId = symbols.elementAt(event.indexToDelete).sym!.id!;
//for delete symbol only sym block needs to be sent.
    final List<dynamic> symValueList = [
      symbols.elementAt(event.indexToDelete).sym
    ];
    try {
      final BaseRequest request = BaseRequest();
      request.addToData('wName', event.selectedGroup.wName);
      request.addToData('symbols', symValueList);
      MessageModel messageModel =
          await WatchlistRepository().deleteSymbolInWatchlist(request);
      if (messageModel.isSuccess()) {
        symbols.removeAt(event.indexToDelete);
        emit(WatchlistDeleteSymbolState(messageModel.infoMsg));
        SelectedWatchlistAndTabEvent(
            event.selectedGroup.wName!, AppConstants.tab1);
        emit(WatchlistChangeState());
        watchlistDoneState.watchlistSymbolsModel!.symbols = symbols;
        // symbols after removing the symbol that need to be deleted
        SymbolWatchlistMapHolder().remove(symbolId, event.selectedGroup.wName!);
        CacheRepository.watchlistCache.put(event.selectedGroup.wName!,
            watchlistDoneState.watchlistSymbolsModel!);

        watchlistDoneState.watchlistGroupModel!.groups!
                .firstWhere((element) => element.wId == event.selectedGroup.wId)
                .symbolsCount =
            watchlistDoneState.watchlistSymbolsModel!.symbols.length;

        emit(watchlistDoneState
          ..selectedWatchlist = event.selectedGroup.wName!
          ..selectedTab = AppConstants.tab1);
      }
    } on ServiceException catch (ex) {
      emit(WatchlistDeleteSymbolFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    } on FailedException catch (ex) {
      emit(WatchlistDeleteSymbolFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleWatchlistRenameGroupEvent(
      WatchlistRenameGroupEvent event, Emitter<WatchlistState> emit) async {
    emit(WatchlistProgressState());

    try {
      final BaseRequest request = BaseRequest();
      request.addToData('wName', event.wName);
      request.addToData('oldWName', event.oldWName);

      final WatchlistRenameWatchlistModel watchlistRenameWatchlistModel =
          await WatchlistRepository().renameWatchlistGroup(request);
      emit(WatchlistChangeState());
      await _handleGroupUpdateEvent(event, emit);
      SymbolWatchlistMapHolder().updateWatchlist(event.oldWName, event.wName);
      CacheRepository.watchlistCache.clear(event.wId);
      emit(RenameWatchlistDoneState()
        ..watchlistRenameWatchlistModel = watchlistRenameWatchlistModel);
    } on ServiceException catch (ex) {
      emit(WatchlistServiceExpectionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(RenameWatchlistFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleGroupUpdateEvent(
      WatchlistRenameGroupEvent event, Emitter<WatchlistState> emit) async {
    final WatchlistGroupModel? model =
        await WatchlistRepository().updateGroup(event.wName, event.wId);
    emit(WatchlistChangeState());
    SelectedWatchlistAndTabEvent(event.wName, AppConstants.tab1);
    emit(watchlistDoneState
      ..watchlistGroupModel = model
      ..selectedWatchlist = event.wName);
  }

  Future<void> sendStream(Emitter<WatchlistState> emit) async {
    if (watchlistDoneState.watchlistSymbolsModel?.symbols != null) {
      final List<String> streamingKeys = <String>[
        AppConstants.streamingLtp,
        AppConstants.streamingChng,
        AppConstants.streamingChgnPer,
        AppConstants.streamingHigh,
        AppConstants.high,
        AppConstants.low,
        AppConstants.streamingLow,
      ];
      if (watchlistDoneState.watchlistSymbolsModel!.symbols.isNotEmpty) {
        emit(WatchlistSymStreamState(
          AppHelper().streamDetails(
              watchlistDoneState.watchlistSymbolsModel!.symbols, streamingKeys),
        ));
      }
    }
  }

  Symbols updateStreamData(Symbols symbol, ResponseData streamData) {
    symbol.close = streamData.close ?? symbol.close;
    symbol.ltp = streamData.ltp ?? symbol.ltp;
    symbol.chng = streamData.chng ?? symbol.chng;
    symbol.chngPer = streamData.chngPer ?? symbol.chng;
    symbol.yhigh = streamData.yHigh ?? symbol.yhigh;
    symbol.ylow = streamData.yLow ?? symbol.ylow;
    symbol.high = streamData.high ?? symbol.high;
    symbol.low = streamData.low ?? symbol.low;

    return symbol;
  }

  Future<void> responseCallback(
      ResponseData streamData, Emitter<WatchlistState> emit) async {
    if (watchlistDoneState.watchlistSymbolsModel != null) {
      final List<Symbols> symbols =
          watchlistDoneState.watchlistSymbolsModel!.symbols;

      final int index = symbols.indexWhere((Symbols element) {
        return element.sym!.streamSym == streamData.symbol;
      });

      if (index != -1) {
        symbols[index] = updateStreamData(symbols[index], streamData);

        emit(WatchlistChangeState());
        watchlistDoneState
          ..watchlistSymbolsModel!.symbols = symbols
          ..mainWatchlistSymbols = symbols;
        _handleWatchlistFilterSortSymbolEvent(
            WatchlistFilterSortSymbolEvent(
                watchlistDoneState.selectedWatchlist,
                watchlistDoneState.watchlistGroupModel!.groups!
                    .firstWhere((element) =>
                        element.wName == watchlistDoneState.selectedWatchlist)
                    .selectedSortBy,
                watchlistDoneState.watchlistGroupModel!.groups!
                    .firstWhere((element) =>
                        element.wName == watchlistDoneState.selectedWatchlist)
                    .selectedFilter),
            emit);
        updateCache(symbols, index);
      }
    }
  }

  Future<void> updateCache(List<Symbols> symbols, int index) async {
    WatchlistSymbolsModel? watchlistSymbolsModel = await CacheRepository
        .watchlistCache
        .get(watchlistDoneState.selectedWatchlist);
    watchlistSymbolsModel?.symbols = watchlistSymbolsModel.symbols
        .map((e) => e.dispSym == symbols[index].dispSym ? symbols[index] : e)
        .toList();
    CacheRepository.watchlistCache
        .put(watchlistDoneState.selectedWatchlist, watchlistSymbolsModel);
  }

  @override
  WatchlistState getErrorState() {
    return WatchlistErrorState();
  }
}
