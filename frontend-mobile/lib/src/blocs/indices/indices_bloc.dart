// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

import '../../config/app_config.dart';
import '../../constants/app_constants.dart';
import '../../data/repository/indices/indices_repository.dart';
import '../../data/store/app_helper.dart';
import '../../data/store/app_utils.dart';
import '../../models/common/symbols_model.dart';
import '../../models/config/config_model.dart';
import '../../models/indices/indices_constituents_model.dart';
import '../../models/sort_filter/sort_filter_model.dart';
import '../common/base_bloc.dart';
import '../common/screen_state.dart';

part 'indices_event.dart';
part 'indices_state.dart';

class IndicesBloc extends BaseBloc<IndicesEvent, IndicesState> {
  IndicesBloc() : super(IndicesInitState());

  IndexConstituentsDoneState indexConstituentsDoneState =
      IndexConstituentsDoneState();

  @override
  Future<void> eventHandlerMethod(
      IndicesEvent event, Emitter<IndicesState> emit) async {
    if (event is IndexConstituentsSymbolsEvent) {
      await _handleIndexConstituentsSymbolsEvent(event, emit);
    } else if (event is IndexConstituentsStartSymStreamEvent) {
      await sendStream(emit);
    } else if (event is IndexConstituentsStreamingResponseEvent) {
      await responseCallback(event.data, emit);
    } else if (event is IndexConstituentsSortSymbolsEvent) {
      await _handleIndexConstituentsSortSymbolsEvent(event, emit);
    }
  }

  Future<void> _handleIndexConstituentsSymbolsEvent(
      IndexConstituentsSymbolsEvent event, Emitter<IndicesState> emit) async {
    emit(IndicesProgressState());
    try {
      final BaseRequest request = BaseRequest();
      request.addToData('indexName', event.indexName);

      final IndicesConstituentsModel indicesConstituentsModel =
          await IndicesRepository().getIndicesConstituentsRequest(request);

      indexConstituentsDoneState
        ..filteredindicesConstituentsModel = indicesConstituentsModel.result
        ..indicesConstituentsModel = indicesConstituentsModel
        ..selectedPredefinedWatchlist = event.dispSym;

      PredefinedWatch? predefinedWatch = AppConfig.predefinedWatch
          .firstWhereOrNull((element) => element.dispSym == event.dispSym);

      SortModel? sortModel = event.sortModel ?? predefinedWatch?.selectedSortBy;
      List<FilterModel>? filterModel =
          event.filtermodel ?? predefinedWatch?.selectedFilter;
      if ((filterModel
                  ?.where((element) => element.filters?.isNotEmpty ?? false)
                  .toList()
                  .isNotEmpty ??
              true) ||
          (sortModel?.sortName != null)) {
        await _handleIndexConstituentsSortSymbolsEvent(
            IndexConstituentsSortSymbolsEvent(
                event.baseSym ??
                    AppConfig.predefinedWatch
                        .firstWhere(
                            (element) => element.dispSym == event.dispSym)
                        .baseSym,
                filterModel,
                sortModel,
                fromConstituents: event.fromConstituents),
            emit);
      } else {
        indexConstituentsDoneState.selectedFilter = null;
        indexConstituentsDoneState.selectedSort = null;
      }
      indexConstituentsDoneState.baseSym = event.baseSym;
      indexConstituentsDoneState.fromConstituents = event.fromConstituents;

      IndexConstituentsStartSymStreamEvent();
      await sendStream(emit);
      emit(indexConstituentsDoneState);
    } on ServiceException catch (ex) {
      indexConstituentsDoneState
        ..filteredindicesConstituentsModel = null
        ..indicesConstituentsModel = null
        ..selectedPredefinedWatchlist = event.dispSym;
      emit(IndicesServiceExpectionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      indexConstituentsDoneState
        ..filteredindicesConstituentsModel = null
        ..indicesConstituentsModel = null
        ..selectedPredefinedWatchlist = event.dispSym;
      emit(IndicesFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleIndexConstituentsSortSymbolsEvent(
      IndexConstituentsSortSymbolsEvent event,
      Emitter<IndicesState> emit) async {
    emit(IndicesProgressState());
    final symbols =
        indexConstituentsDoneState.filteredindicesConstituentsModel ?? [];
    List<Symbols> filteredSymbols = symbols.toList();
    if (event.filterModel
            ?.where((element) => element.filters?.isNotEmpty ?? false)
            .toList()
            .isNotEmpty ??
        true) {
      filteredSymbols = filterSymbols(event, filteredSymbols);
    }
    if (event.selectedSort != null) {
      sortSymbols(event, filteredSymbols);
      indexConstituentsDoneState.isSortSelected = true;
    } else {
      indexConstituentsDoneState.isSortSelected = false;
    }

    indexConstituentsDoneState.indicesConstituentsModel?.result =
        filteredSymbols;
    indexConstituentsDoneState.selectedFilter = event.filterModel;
    indexConstituentsDoneState.selectedSort = event.selectedSort;

    if (!event.fromConstituents) {
      AppConfig.predefinedWatch
          .firstWhere((element) =>
              element.baseSym == event.selectedPredefinedWatchllist)
          .selectedSortBy = event.selectedSort;
      AppConfig.predefinedWatch
          .firstWhere((element) =>
              element.baseSym == event.selectedPredefinedWatchllist)
          .isSortSelected = event.selectedSort != null;

      indexConstituentsDoneState.indicesConstituentsModel?.selectedFilter =
          event.filterModel;
      AppConfig.predefinedWatch
          .firstWhere((element) =>
              element.baseSym == event.selectedPredefinedWatchllist)
          .selectedFilter = event.filterModel;
      AppConfig.predefinedWatch
          .firstWhere((element) =>
              element.baseSym == event.selectedPredefinedWatchllist)
          .isfilterModel = event.filterModel != null;
    }

    emit(IndicesChangeState());
    emit(indexConstituentsDoneState);
  }

  List<Symbols> filterSymbols(
      IndexConstituentsSortSymbolsEvent event, List<Symbols> symbols) {
    if (event.filterModel != null &&
        event.filterModel!.isNotEmpty &&
        indexConstituentsDoneState.indicesConstituentsModel != null) {
      {
        if (event.filterModel!.isNotEmpty) {
          List<Symbols>? filteredSymbols;
          bool isFilter = false;
          Set<Symbols>? filteredSymbolsSet = {}; // to avoid duplicates used set
          for (FilterModel element in event.filterModel!) {
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
          }
          if (isFilter) {
            symbols = filteredSymbolsSet.toList();
            indexConstituentsDoneState.isFilterSelected = true;
            indexConstituentsDoneState
                .indicesConstituentsModel!.selectedFilter = event.filterModel;
          }
        } else {
          indexConstituentsDoneState.isFilterSelected = false;

          indexConstituentsDoneState.indicesConstituentsModel!.selectedFilter =
              null;
        }
      }
    }
    return symbols;
  }

  void sortSymbols(
      IndexConstituentsSortSymbolsEvent event, List<Symbols> symbols) {
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
          symbols.sort((Symbols a, Symbols b) =>
              double.parse(AppUtils().decimalValue(b.ltp ?? '0')).compareTo(
                  double.parse(AppUtils().decimalValue(a.ltp ?? '0'))));
        } else {
          symbols.sort((Symbols a, Symbols b) =>
              double.parse(AppUtils().decimalValue(a.ltp ?? '0')).compareTo(
                  double.parse(AppUtils().decimalValue(b.ltp ?? '0'))));
        }
      } else if (event.selectedSort!.sortName == AppConstants.chngPercent) {
        if (event.selectedSort!.sortType == Sort.ASCENDING) {
          symbols.sort((Symbols a, Symbols b) =>
              double.parse(AppUtils().decimalValue(b.chngPer ?? '0')).compareTo(
                  double.parse(AppUtils().decimalValue(a.chngPer ?? '0'))));
        } else {
          symbols.sort((Symbols a, Symbols b) =>
              double.parse(AppUtils().decimalValue(a.chngPer ?? '0')).compareTo(
                  double.parse(AppUtils().decimalValue(b.chngPer ?? '0'))));
        }
      }
    }
  }

  Future<void> sendStream(Emitter<IndicesState> emit) async {
    final List<String> streamingKeys = <String>[
      AppConstants.streamingLtp,
      AppConstants.streamingChng,
      AppConstants.streamingChgnPer,
      AppConstants.streamingHigh,
      AppConstants.streamingLow,
    ];
    if (indexConstituentsDoneState
            .indicesConstituentsModel?.result.isNotEmpty ??
        false) {
      emit(IndexConstituentsSymStreamState(
        AppHelper().streamDetails(
            indexConstituentsDoneState.indicesConstituentsModel!.result,
            streamingKeys),
      ));
    }
  }

  Future<void> responseCallback(
      ResponseData streamData, Emitter<IndicesState> emit) async {
    if (indexConstituentsDoneState.indicesConstituentsModel != null) {
      final List<Symbols> symbols =
          indexConstituentsDoneState.indicesConstituentsModel!.result;

      final int index = symbols.indexWhere((Symbols element) {
        return element.sym!.streamSym == streamData.symbol;
      });
      if (index != -1) {
        symbols[index].ltp = streamData.ltp ?? symbols[index].ltp;
        symbols[index].chng = streamData.chng ?? symbols[index].chng;
        symbols[index].chngPer = streamData.chngPer ?? symbols[index].chngPer;
        symbols[index].yhigh = streamData.yHigh ?? symbols[index].yhigh;
        symbols[index].ylow = streamData.yLow ?? symbols[index].ylow;
        emit(IndicesChangeState());
        emit(indexConstituentsDoneState
          ..indicesConstituentsModel!.result = symbols);
        if (indexConstituentsDoneState.baseSym != null) {
          await _handleIndexConstituentsSortSymbolsEvent(
              IndexConstituentsSortSymbolsEvent(
                  indexConstituentsDoneState.baseSym!,
                  indexConstituentsDoneState.selectedFilter,
                  indexConstituentsDoneState.selectedSort,
                  fromConstituents:
                      indexConstituentsDoneState.fromConstituents),
              emit);
        }
      }
    }
  }

  @override
  IndicesState getErrorState() {
    return IndicesErrorState();
  }
}
