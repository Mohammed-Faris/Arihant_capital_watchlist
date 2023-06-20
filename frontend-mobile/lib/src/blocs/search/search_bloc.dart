import 'dart:async';

import 'package:acml/src/data/store/app_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

import '../../constants/app_constants.dart';
import '../../constants/keys/search_keys.dart';
import '../../data/cache/cache_repository.dart';
import '../../data/repository/search/search_repository.dart';
import '../../data/store/app_helper.dart';
import '../../data/store/app_storage.dart';
import '../../data/store/app_store.dart';
import '../../localization/app_localization.dart';
import '../../models/common/message_model.dart';
import '../../models/common/symbols_model.dart';
import '../../models/search/search_model.dart';
import '../../models/watchlist/symbol_watchlist_map_holder_model.dart';
import '../../models/watchlist/watchlist_group_model.dart';
import '../../models/watchlist/watchlist_symbols_model.dart';
import '../common/base_bloc.dart';
import '../common/screen_state.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends BaseBloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchInitial());
  SymbolSearchDoneState symbolSearchDoneState = SymbolSearchDoneState();

  List<Symbols> searchModelfullData = [];
  SearchSymbolsModel? datamodel;
  String searchInput = '';
  String wName = '';

  @override
  Future<void> eventHandlerMethod(
      SearchEvent event, Emitter<SearchState> emit) async {
    if (event is SymbolSearchEvent) {
      await _handleSymbolSearchEvent(event, emit);
    } else if (event is SearchAddSymbolEvent) {
      await _handleAddSymbolEvent(event, emit);
    } else if (event is SearchdeleteSymbolEvent) {
      await _handledeleteSymbolEvent(event, emit);
    } else if (event is SymbolSearchRowTappedEvent) {
      await _handleSymbolSearchRowTappedEvent(event);
    } else if (event is SearchStreamingResponseEvent) {
      await responseCallback(event.data, emit);
    }
  }

  Future<void> _handleSymbolSearchEvent(
      SymbolSearchEvent event, Emitter<SearchState> emit) async {
    String searchSubStringText = "";
    emit(SearchLoaderState());
    symbolSearchDoneState.searchText = event.searchString;
    symbolSearchDoneState.selectedSymbolFilter = event.selectedFilter;
    if (event.searchString.isEmpty) {
      await _getRecentSearchData(emit, event.selectedFilter);
    } else {
      try {
        if (event.searchString.length > 2) {
          searchSubStringText = event.searchString.substring(0, 3);

          emit(symbolSearchDoneState
            ..isShowRecentSearch = false
            ..selectedSymbolFilter = event.selectedFilter);
          if ((searchInput.isNotEmpty &&
              event.searchString.length > 2 &&
              (searchInput.toLowerCase() ==
                  searchSubStringText.toLowerCase()))) {
            await localSearchFilter(event.searchString, event.selectedFilter);
          } else {
            emit(SearchLoaderState());
            final BaseRequest request = BaseRequest();
            request.addToData('input', searchSubStringText);

            final SearchSymbolsModel searchSymbolsModel =
                await SearchRepository().searchSymbolRequest(request);
            searchInput = searchSubStringText;
            searchModelfullData = searchSymbolsModel.symbols;
            symbolSearchDoneState.searchSymbolsModel = searchSymbolsModel;
            await localSearchFilter(event.searchString, event.selectedFilter);
          }

          emit(symbolSearchDoneState
            ..isShowRecentSearch = false
            ..selectedSymbolFilter = event.selectedFilter);
          if (symbolSearchDoneState.searchSymbolsModel?.symbols.isEmpty ??
              true) {
            emit(SearchFailedState()
              ..errorCode = ""
              ..selectedSymbolFilter = event.selectedFilter
              ..errorMsg = AppLocalizations().symbolnotfound);
          }
        } else {
          if ((symbolSearchDoneState.searchSymbolsModel?.symbols.isEmpty ??
              true)) {
            emit(symbolSearchDoneState
              ..isShowRecentSearch = true
              ..selectedSymbolFilter = event.selectedFilter);
          } else if (symbolSearchDoneState
              .recentSelecteddatamodel.symbols.isNotEmpty) {
            emit(symbolSearchDoneState
              ..isShowRecentSearch = true
              ..selectedSymbolFilter = event.selectedFilter);
          } else {
            emit(SearchFailedState()
              ..errorCode = ""
              ..selectedSymbolFilter = event.selectedFilter
              ..errorMsg = AppLocalizations().symbolnotfound);
          }
        }
      } on ServiceException catch (ex) {
        searchInput = searchSubStringText;

        emit(SearchServiceExpectionState()
          ..errorCode = ex.code
          ..errorMsg = ex.msg
          ..isShowRecentSearch = false
          ..selectedSymbolFilter = event.selectedFilter);
        throw (ServiceException(ex.code, ex.msg));
      } on FailedException catch (ex) {
        searchInput = searchSubStringText;

        emit(SearchFailedState()
          ..errorCode = ex.code
          ..errorMsg = ex.msg
          ..isShowRecentSearch = false
          ..selectedSymbolFilter = event.selectedFilter);
      }
    }
  }

  Future<void> _handleAddSymbolEvent(
      SearchAddSymbolEvent event, Emitter<SearchState> emit) async {
    emit(SearchProgressState());

    try {
      final BaseRequest request = BaseRequest();
      request.addToData('wName', event.groupname);
      request.addToData('syms', [event.symbolItem.sym]);
      MessageModel messageModel;
      if (event.isNewWatchlist) {
        messageModel = await SearchRepository().addSymbolsToNewGroup(request);
        // WatchlistRepository().clearAllWatchlistGroups();
        if (messageModel.isSuccess()) {
          Groups group = Groups(
            wId: event.groupname,
            wName: event.groupname,
            defaultMarketWatch: true,
            editable: true,
          );
          await SearchRepository().updateWatchlistGroup(group);
        }
        wName = event.groupname;

        emit(SearchChangeState());
      } else {
        messageModel = await SearchRepository().addSymbolInGroups(request);
      }
      SymbolWatchlistMapHolder()
          .add(event.symbolItem.sym!.id!, event.groupname);
      WatchlistSymbolsModel? previousData =
          await CacheRepository.watchlistCache.get(event.groupname);
      if (previousData != null) {
        previousData.symbols.add(event.symbolItem);
        CacheRepository.watchlistCache.put(event.groupname, previousData);
      }
      emit(SearchChangeState());
      emit(symbolSearchDoneState..wName = event.groupname);
      emit(SearchAddDoneState(messageModel.infoMsg));
    } on ServiceException catch (ex) {
      emit(SearchAddSymbolFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(SearchAddSymbolFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handledeleteSymbolEvent(
      SearchdeleteSymbolEvent event, Emitter<SearchState> emit) async {
    emit(SearchProgressState());

    try {
      final BaseRequest request = BaseRequest();
      request.addToData('wName', event.groupname);
      request.addToData('symbols', [event.symbolItem.sym!]);
      MessageModel messageModel =
          await SearchRepository().deleteSymbolInGroups(request);
      SymbolWatchlistMapHolder()
          .remove(event.symbolItem.sym!.id!, event.groupname);
      emit(symbolSearchDoneState..wName = event.groupname);
      WatchlistSymbolsModel? previousData =
          await CacheRepository.watchlistCache.get(event.groupname);
      if (previousData != null) {
        previousData.symbols
            .removeWhere((e) => e.dispSym == event.symbolItem.dispSym);
        CacheRepository.watchlistCache.put(event.groupname, previousData);
      }
      emit(SearchdeleteDoneState(messageModel.infoMsg));
    } on ServiceException catch (ex) {
      emit(SearchdeleteSymbolFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(SearchdeleteSymbolFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleSymbolSearchRowTappedEvent(
      SymbolSearchRowTappedEvent event) async {
    final dynamic getRecentSearch =
        await AppStorage().getData(getRecentSearchKey());

    symbolSearchDoneState.recentSelecteddatamodel = getRecentSearch != null
        ? SearchSymbolsModel.symbolsFromJson(getRecentSearch)
        : SearchSymbolsModel();

    List<Symbols> oldData =
        symbolSearchDoneState.recentSelecteddatamodel.symbols;

    if (oldData.isEmpty) {
      oldData.add(event.symbolItem);
    } else {
      final List<Symbols> filterSym = oldData
          .where((Symbols item) => item.sym?.id != event.symbolItem.sym?.id)
          .toList();

      filterSym.insert(0, event.symbolItem);

      if (filterSym.length > 4) {
        filterSym.removeLast();
      }
      oldData = filterSym;
    }

    symbolSearchDoneState.recentSelecteddatamodel.symbols = oldData;

    await AppStorage().setData(
        getRecentSearchKey(), symbolSearchDoneState.recentSelecteddatamodel);
  }

  Future<void> _getRecentSearchData(
      Emitter<SearchState> emit, String selectedFilter) async {
    final dynamic getRecentSearch =
        await AppStorage().getData(getRecentSearchKey());
    if (getRecentSearch != null) {
      datamodel = SearchSymbolsModel.symbolsFromJson(getRecentSearch);
      if (datamodel?.symbols.isNotEmpty ?? false) {
        Map<String, List<Symbols>> recentSymbolsStatusMap =
            filterSymbols(datamodel!.symbols);
        await localSearchFilter("", selectedFilter,
            isRecentSearch: true, symbolss: datamodel!.symbols);
        emit(symbolSearchDoneState
          ..isShowRecentSearch = true
          ..selectedSymbolFilter = selectedFilter
          ..recentSymbolsStatusMap = recentSymbolsStatusMap);

        await sendStream(emit);
      } else {
        datamodel?.symbols = <Symbols>[];

        emit(symbolSearchDoneState
          ..searchSymbolsModel = datamodel
          ..isShowRecentSearch = false);
      }
    } else {
      emit(symbolSearchDoneState..isShowRecentSearch = true);
    }
  }

  Future<void> sendStream(Emitter<SearchState> emit) async {
    final List<String> streamingKeys = <String>[
      AppConstants.streamingLtp,
      AppConstants.streamingChng,
      AppConstants.streamingChgnPer,
    ];

    if (symbolSearchDoneState.recentSelecteddatamodel.symbols.isNotEmpty) {
      emit(SearchSymStreamState(AppHelper().streamDetails(
          symbolSearchDoneState.recentSelecteddatamodel.symbols,
          streamingKeys)));
    }
  }

  Future<void> responseCallback(
      ResponseData streamData, Emitter<SearchState> emit) async {
    final List<Symbols> symbols =
        symbolSearchDoneState.recentSelecteddatamodel.symbols;
    final int index = symbols.indexWhere((Symbols element) {
      return element.sym!.streamSym == streamData.symbol;
    });
    if (index != -1) {
      symbols[index].ltp = streamData.ltp ?? symbols[index].ltp;
      symbols[index].chng = streamData.chng ?? symbols[index].chng;
      symbols[index].chngPer = streamData.chngPer ?? symbols[index].chngPer;
      symbols[index].yhigh = streamData.yHigh ?? symbols[index].yhigh;
      symbols[index].ylow = streamData.yLow ?? symbols[index].ylow;
      emit(SearchChangeState());
      emit(symbolSearchDoneState..recentSelecteddatamodel.symbols = symbols);
    }
  }

  Future<void> localSearchFilter(String input, String selectedFilter,
      {bool isRecentSearch = false, List<Symbols>? symbolss}) async {
    final List<Symbols> symbolsFilteredUsingSubString =
        symbolss?.where((Symbols element) {
              final String searchName =
                  '${element.dispSym!} ${element.sym!.exc!}';
              return checkSymNameMatchesInputString(
                  searchName, element.companyName ?? '', input);
            }).toList() ??
            (searchModelfullData.where((Symbols element) {
              final String searchName =
                  '${element.dispSym!} ${element.sym!.exc!}';
              return checkSymNameMatchesInputString(
                  searchName, element.companyName ?? '', input);
            }).toList());
    Map<String, List<Symbols>> symbolsStatusMap =
        filterSymbols(symbolsFilteredUsingSubString);
    List<Symbols> symbols = (selectedFilter == AppConstants.all
            ? symbolsStatusMap[AppConstants.all]
            : selectedFilter == AppConstants.stocks
                ? symbolsStatusMap[AppConstants.stocks]
                : selectedFilter == AppConstants.etfs
                    ? symbolsStatusMap[AppConstants.etfs]
                    : selectedFilter == AppConstants.future
                        ? symbolsStatusMap[AppConstants.future]
                        : selectedFilter == AppConstants.options
                            ? symbolsStatusMap[AppConstants.options]
                            : selectedFilter == AppConstants.commodity
                                ? symbolsStatusMap[AppConstants.commodity]
                                : symbolsStatusMap[AppConstants.currency]) ??
        [];
    if (isRecentSearch) {
      symbolSearchDoneState
        ..recentSelecteddatamodel.symbols = symbols
        ..selectedSymbolFilter = selectedFilter;
    } else {
      symbolSearchDoneState
        ..searchSymbolsModel?.symbols = symbols
        ..selectedSymbolFilter = selectedFilter
        ..isShowRecentSearch = false;
    }
  }

  bool checkSymNameMatchesInputString(
      String symbolName, String companyName, String input) {
    symbolName = symbolName.replaceAll(" ", "").toLowerCase();
    companyName = companyName.replaceAll(" ", "").toLowerCase();
    final List<String> queryArr = input.split(' ');

    return queryArr.every((String element) {
          symbolName = symbolName.replaceAll(" ", "").toLowerCase();
          return (symbolName
              .contains(element.replaceAll(" ", "").toLowerCase()));
        }) ||
        companyName
            .toLowerCase()
            .startsWith(input.replaceAll(" ", "").toLowerCase());
  }

  Map<String, List<Symbols>> filterSymbols(List<Symbols> symbolsToFilter) {
    List<Symbols> stocksSymbols = [];
    List<Symbols> etfsSymbols = [];
    List<Symbols> futureSymbols = [];
    List<Symbols> optionsSymbols = [];

    List<Symbols> currencySymbols = [];
    List<Symbols> commoditySymbols = [];
    symbolsToFilter = symbolsToFilter
        .where((element) => element.sym!.expiry != null
            ? (DateFormat('dd-MM-yyyy')
                    .parse(element.sym!.expiry.toString())
                    .compareTo(DateFormat('yyyy-MM-dd')
                        .parse(DateTime.now().toString())) >=
                0)
            : true)
        .toList();
    for (Symbols symbols in symbolsToFilter) {
      String symbolType = AppUtils().getsymbolTypeFromSym(symbols.sym);
      if (symbols.sym!.instrument == "STK") {
        stocksSymbols.add(symbols);
      } else if (symbols.sym!.instrument == AppConstants.etf) {
        etfsSymbols.add(symbols);
      } else if (symbols.sym!.instrument!.contains(AppConstants.fut)) {
        futureSymbols.add(symbols);
      } else if (symbols.sym!.instrument!.contains(AppConstants.opt)) {
        optionsSymbols.add(symbols);
      }
      if (symbolType == AppConstants.currency) {
        currencySymbols.add(symbols);
      }
      if (symbolType == AppConstants.commodity) {
        commoditySymbols.add(symbols);
      }
    }

    Map<String, List<Symbols>> symbolsStatusMap = {
      AppConstants.all: symbolsToFilter,
      AppConstants.stocks: stocksSymbols,
      AppConstants.etfs: etfsSymbols,
      AppConstants.future: futureSymbols,
      AppConstants.options: optionsSymbols,
      AppConstants.currency: currencySymbols,
      AppConstants.commodity: commoditySymbols,
    };

    return symbolsStatusMap;
  }

  String getRecentSearchKey() {
    return '${recentSearchSymbolsKey}_${AppStore().getAccountName()}';
  }

  @override
  SearchState getErrorState() {
    return SearchFailedState();
  }
}
