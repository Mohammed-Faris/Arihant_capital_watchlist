import 'package:acml/src/models/watchlist/watchlist_symbols_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';

import '../../models/common/symbols_model.dart';
import '../../models/watchlist/watchlist_group_model.dart';
import '../watch_repository.dart';

part 'watch_event.dart';
part 'watch_state.dart';

class WatchBloc extends Bloc<WatchEvent, WatchState> {
  late WatchlistGroupModel groupModel;
  late List<WatchlistSymbolsModel> existingSymbolsModel;
  List<WatchlistSymbolsModel> unChangedArr = [];
  WatchLoadedState watchLoadedState = WatchLoadedState();

  double parseDoubleOrDefault(String value, {double defaultValue = 0.0}) {
    if (value == null) {
      return defaultValue;
    }
    return double.tryParse(value) ?? defaultValue;
  }

  WatchBloc() : super(WatchLoadingState()) {
    on<LoadWatchEvent>((event, emit) async {
      emit(WatchLoadingState());

      try {
        final BaseRequest request = BaseRequest();
        final WatchlistGroupModel groupModel =
            await WatchRepository().getWatchlistGroupsRequest(request);
        print('watchlistGroupModel: $groupModel');

        var symbols = await _handleWatchlistGetSymbolsEvent(groupModel);
        var unChangedSymbols =
            await _handleWatchlistGetSymbolsEvent(groupModel);
        watchLoadedState.watchlistGroupModel = groupModel;

        watchLoadedState.symbolsModelList = symbols;
        unChangedArr = unChangedSymbols;

        emit(watchLoadedState);
      } catch (e) {
        emit(WatchErrorState(e.toString()));
      }
    });

    on<NewWatchlistStreamingResponseEvent>((event, emit) {
      responseCallback(event.data, event.selectedTabIndex, emit);
    });

    on<SearchEvent>((event, emit) {
      searchCallback(event.searchText, event.selectedTabIndex, emit);
    });

    on<OnSortEvent>((event, emit) {
      sortUsers(event.selectedSort, event.selectedTabIndex, emit);
      print(
          'selectedSort ${event.selectedSort},selectedTabIndex ${event.selectedTabIndex}');
      emit(WatchChangeState());
      emit(watchLoadedState);
    });
  }

  void sortUsers(
      String sortType, int selectedTabIndex, Emitter<WatchState> emit) {
    if (sortType.toLowerCase() == 'Low to High'.toLowerCase()) {
      // numeric ascending
      List<Symbols> symbols =
          watchLoadedState.symbolsModelList[selectedTabIndex].symbols;

      print(num.parse('-1.76'));
      symbols.sort((a, b) {
        return num.parse(a.chngPer ?? '0')
            .compareTo(num.parse(b.chngPer ?? '0'));
      });

      watchLoadedState.symbolsModelList[selectedTabIndex].symbols = symbols;
      watchLoadedState.isSortedChange = !watchLoadedState.isSortedChange;
      watchLoadedState.isSelectedChange = true;
      watchLoadedState.isSelectedName = false;
      watchLoadedState.isSelectedPrice = false;
    } else if (sortType.toLowerCase() == 'High to Low'.toLowerCase()) {
      // numeric descending
      List<Symbols> symbols =
          watchLoadedState.symbolsModelList[selectedTabIndex].symbols;

      symbols.sort((b, a) =>
          num.parse(a.chngPer ?? '0').compareTo(num.parse(b.chngPer ?? '0')));
      watchLoadedState.symbolsModelList[selectedTabIndex].symbols = symbols;
      watchLoadedState.isSortedChange = !watchLoadedState.isSortedChange;
    } else if (sortType.toLowerCase() == 'A to Z'.toLowerCase()) {
      // alpha ascending
      List<Symbols> symbols =
          watchLoadedState.symbolsModelList[selectedTabIndex].symbols;

      symbols.sort((a, b) => a.dispSym!.compareTo(b.dispSym!));
      watchLoadedState.symbolsModelList[selectedTabIndex].symbols = symbols;
      watchLoadedState.isSortedName = !watchLoadedState.isSortedName;
      watchLoadedState.isSelectedChange = false;
      watchLoadedState.isSelectedName = true;
      watchLoadedState.isSelectedPrice = false;
    } else if (sortType.toLowerCase() == 'Z to A'.toLowerCase()) {
      // alpha descending
      List<Symbols> symbols =
          watchLoadedState.symbolsModelList[selectedTabIndex].symbols;

      symbols.sort((b, a) => a.dispSym!.compareTo(b.dispSym!));
      watchLoadedState.symbolsModelList[selectedTabIndex].symbols = symbols;
      watchLoadedState.isSortedName = !watchLoadedState.isSortedName;
      watchLoadedState.isSelectedChange = false;
      watchLoadedState.isSelectedName = true;
      watchLoadedState.isSelectedPrice = false;
    } else if (sortType.toLowerCase() == 'Price Low to High'.toLowerCase()) {
      // numeric ascending
      List<Symbols> symbols =
          watchLoadedState.symbolsModelList[selectedTabIndex].symbols;

      print(num.parse('-1.76'));
      symbols.sort((a, b) {
        return parseDoubleOrDefault(a.ltp ?? '0')
            .compareTo(parseDoubleOrDefault(b.ltp ?? '0'));
      });

      watchLoadedState.symbolsModelList[selectedTabIndex].symbols = symbols;
      watchLoadedState.isSortedPrice = !watchLoadedState.isSortedPrice;

      watchLoadedState.isSelectedChange = false;
      watchLoadedState.isSelectedName = false;
      watchLoadedState.isSelectedPrice = true;
    } else if (sortType.toLowerCase() == 'Price High to Low'.toLowerCase()) {
      // numeric descending
      List<Symbols> symbols =
          watchLoadedState.symbolsModelList[selectedTabIndex].symbols;

      symbols.sort((b, a) => parseDoubleOrDefault(a.ltp ?? '0')
          .compareTo(parseDoubleOrDefault(b.ltp ?? '0')));
      watchLoadedState.symbolsModelList[selectedTabIndex].symbols = symbols;
      watchLoadedState.isSortedPrice = !watchLoadedState.isSortedPrice;
      watchLoadedState.isSelectedChange = false;
      watchLoadedState.isSelectedName = false;
      watchLoadedState.isSelectedPrice = true;
    }
  }

  Future<void> searchCallback(
      String searchText, int selectedTabIndex, Emitter<WatchState> emit) async {
    // if (watchLoadedState.symbolsModelList != null) {

    List<Symbols> symbols = unChangedArr[selectedTabIndex].symbols;

    watchLoadedState.symbolsModelList[selectedTabIndex].symbols =
        List<Symbols>.from(symbols).where((element) {
      return element.dispSym!.toLowerCase().contains(searchText.toLowerCase());
    }).toList();

    if (searchText == "") {
      watchLoadedState.symbolsModelList[selectedTabIndex].symbols = symbols;
    }

    emit(WatchChangeState());
    emit(watchLoadedState);
  }

  Future<void> responseCallback(ResponseData streamData, int selectedTabIndex,
      Emitter<WatchState> emit) async {
    final List<Symbols> symbols =
        watchLoadedState.symbolsModelList[selectedTabIndex].symbols;

    final int index = symbols.indexWhere((Symbols element) {
      return element.sym!.streamSym == streamData.symbol;
    });

    if (index != -1) {
      symbols[index] = updateStreamData(symbols[index], streamData);
      watchLoadedState.symbolsModelList[selectedTabIndex].symbols[index] =
          symbols[index];

      emit(WatchChangeState());
      emit(watchLoadedState);
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

  Future<List<WatchlistSymbolsModel>> _handleWatchlistGetSymbolsEvent(
      WatchlistGroupModel model) async {
    List<WatchlistSymbolsModel> symbolsModelList = [];
    WatchlistSymbolsModel? symbolModel;

    model.groups?.forEach((element) async {
      Groups group = Groups();

      group.wName = element.wName;
      group.wId = element.wId;
      group.editable = element.editable;
      group.defaultMarketWatch = element.defaultMarketWatch;

      try {
        final BaseRequest request = BaseRequest(data: group.toJson());

        symbolModel = await WatchRepository()
            .getWatchlistSymbolsRequest(request, wId: group.wId!);
        symbolsModelList.add(symbolModel!);
      } catch (e) {
        emit(WatchErrorState(e.toString()));
      }
    });

    return symbolsModelList;
  }
}
