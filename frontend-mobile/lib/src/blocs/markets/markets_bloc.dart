import 'package:acml/src/models/markets/fiidii_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

import '../../config/app_config.dart';
import '../../constants/app_constants.dart';
import '../../constants/keys/watchlist_keys.dart';
import '../../data/repository/indices/indices_repository.dart';
import '../../data/repository/markets/markets_repository.dart';
import '../../data/store/app_calculator.dart';
import '../../data/store/app_helper.dart';
import '../../data/store/app_storage.dart';
import '../../data/store/app_utils.dart';
import '../../localization/app_localization.dart';
import '../../models/common/sym_model.dart';
import '../../models/common/symbols_model.dart';
import '../../models/config/config_model.dart';
import '../../models/indices/indices_constituents_model.dart';
import '../../models/markets/market_movers_expiry_model.dart';
import '../../models/markets/market_movers_model.dart';
import '../../models/sort_filter/sort_filter_model.dart';
import '../common/base_bloc.dart';
import '../common/screen_state.dart';

part 'markets_event.dart';
part 'markets_state.dart';

class MarketsBloc extends BaseBloc<MarketsEvent, MarketsState> {
  MarketsBloc() : super(MarketsInitial());

  MarketsFetchItemsDoneState marketsFetchItemsDoneState =
      MarketsFetchItemsDoneState();
  MarketsPullDownItemsDoneState marketsPullDownItemsDoneState =
      MarketsPullDownItemsDoneState();

  MarketMoversFetchItemsDoneState marketMoversFetchItemsDoneState =
      MarketMoversFetchItemsDoneState();
  MarketMoversFOFetchItemsDoneState marketMoversFOFetchItemsDoneState =
      MarketMoversFOFetchItemsDoneState();
  MarketMoversIndicesFetchItemsDoneState
      marketMoversIndicesFetchItemsDoneState =
      MarketMoversIndicesFetchItemsDoneState();
  List<String> pullDownSymbolsList = [];

  @override
  Future<void> eventHandlerMethod(
      MarketsEvent event, Emitter<MarketsState> emit) async {
    if (event is FetchMarketIndicesItemsEvent) {
      await _handleFetchMarketIndicesEvent(event, emit);
    } else if (event is MarketIndicesStreamingResponseEvent) {
      await responseCallback(event.data, emit);
    } else if (event is MarketIndicesAnimate) {
      emit(MarketsFetchItemsProgressState());
      await Future.delayed(const Duration(milliseconds: 100));
      emit(marketsPullDownItemsDoneState..isScroll = event.animate);
    } else if (event is MarketIndicesStreamingPullDownMenuResponseEvent) {
      await responseCallbackForPullDownMenu(event.data, emit);
    } else if (event is MarketFoScreenUpdate) {
      emit(MarketMoverFOLoaderState());
      await Future.delayed(const Duration(milliseconds: 100));
      emit(MarketMoverFOState(
          event.selectedExpiryDate, event.selectedToggleIndex));
    } else if (event is MarketMoversFetchTopGainersLosersFetchEvent) {
      await _handleMarketMoversFetchTopGainersLosersFetchEvent(event, emit);
    } else if (event is MarketsFFIDIIFetch) {
      await _handleMarketFiiDiiFetchEvent(event, emit);
    } else if (event is MarketMoversStreamingResponseEvent) {
      await responseCallbackForMarketMovers(event.data, emit);
    } else if (event is MarketMoversFOSendExpiryRequestEvent) {
      await _handleMarketMoversFOSendExpiryRequestEvent(event, emit);
    } else if (event is MarketMoversFetchFOTopGainersLosersFetchEvent) {
      await _handleMarketMoversFOFetchTopGainersLosersFetchEvent(event, emit);
    } else if (event is MarketMoversFOStreamingResponseEvent) {
      await responseCallbackForMarketMoversFO(event.data, emit);
    } else if (event is MarketsIndexConstituentsSymbolsEvent) {
      await _handleIndexConstituentsSymbolsEvent(event, emit);
    } else if (event is MarketsFilterSortSymbolEvent) {
      await _handleMarketsFilterSortSymbolEvent(event, emit);
    } else if (event is MarketMoversStartSymStreamForIndicesEvent) {
      if (event.selectedSegment == AppLocalizations().topIndices) {
        await sendStreamForMarketIndicesPullDownMenu(
            marketsPullDownItemsDoneState.pullDownMenuSymbols ?? [], emit);
      } else {
        await sendStreamForMarketIndices(emit);
      }
    }
    //MarketsFilterSortSymbolEvent
  }

  Future<void> _handleIndexConstituentsSymbolsEvent(
      MarketsIndexConstituentsSymbolsEvent event,
      Emitter<MarketsState> emit) async {
    emit(MarketsMoversFetchItemsProgressState());

    try {
      final BaseRequest request = BaseRequest();
      request.addToData('indexName', event.indexName);

      final IndicesConstituentsModel indicesConstituentsModel =
          await IndicesRepository().getIndicesConstituentsRequest(request);

      marketMoversIndicesFetchItemsDoneState.symbols =
          indicesConstituentsModel.result;
      emit(MarketMoversIndicesFetchItemsDoneState()
        ..symbols = indicesConstituentsModel.result);

      await sendStreamForConstituentIndices(
          emit, indicesConstituentsModel.result);
    } on ServiceException catch (ex) {
      emit(MarketsServiceExpectionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      if (ex.code == AppConstants.noDataAvailableErrorCode) {
        // emit(suggestedStocksState..suggestedStocks = AppConfig.suggestedStocks);
        // await sendStreamForSuggestedStocks(emit);
      } else {
        emit(MarketsFailedState()
          ..errorCode = ex.code
          ..errorMsg = ex.msg);
      }
    }
  }

  Future<void> sendStreamForConstituentIndices(
      Emitter<MarketsState> emit, List<Symbols> symList) async {
    final List<String> streamingKeys = <String>[
      AppConstants.streamingLtp,
      AppConstants.streamingChng,
      AppConstants.streamingLow,
      AppConstants.streamingHigh,
      AppConstants.streamingOpen,
      AppConstants.streamingClose,
      AppConstants.streamingLow,
      AppConstants.streamingChng,
      AppConstants.streamingChgnPer
    ];

    emit(
      MarketMoversStartStreamState(
        AppHelper().streamDetails(symList, streamingKeys),
      ),
    );
  }

  Future<void> _handleMarketMoversFOSendExpiryRequestEvent(
      MarketMoversFOSendExpiryRequestEvent event,
      Emitter<MarketsState> emit) async {
    // emit(MarketsMoversFOProgressState());

    final BaseRequest request = BaseRequest();

    request.addToData('exc', event.exc);
    request.addToData("segment", event.segment);

    final MarketMoversExpiryModel quoteExpiryResponse =
        await MarketMoversRepository()
            .getMarketMoversQuoteExpiryListRequest(request);
    emit(MarketMoversFOExpiryListResponseDoneState()
      ..results = quoteExpiryResponse.expList);
  }

  Future<void> sendStreamForMarketIndicesPullDownMenu(
    List<Symbols> symbolList,
    Emitter<MarketsState> emit,
  ) async {
    final List<String> streamingKeys = <String>[
      AppConstants.streamingLtp,
      AppConstants.streamingChng,
      AppConstants.streamingChgnPer
    ];

    emit(
      MarketIndicesStartStreamState(
        AppHelper().streamDetails(symbolList, streamingKeys),
      ),
    );
  }

  Future<void> sendStreamForMarketIndices(Emitter<MarketsState> emit,
      {bool isBse = false}) async {
    final List<String> streamingKeys = <String>[
      AppConstants.streamingLtp,
      AppConstants.streamingChng,
      AppConstants.streamingChgnPer
    ];

    emit(
      MarketIndicesStartStreamState(
        AppHelper().streamDetails(
            isBse
                ? marketsFetchItemsDoneState.bSE
                : marketsFetchItemsDoneState.nSE,
            streamingKeys),
      ),
    );
  }

  Future<void> sendStreamForFO(
    Emitter<MarketsState> emit,
  ) async {
    final List<String> streamingKeys = <String>[
      AppConstants.streamingLtp,
      AppConstants.streamingChng,
      AppConstants.streamingChgnPer
    ];

    emit(
      MarketMoversStartStreamState(
        AppHelper().streamDetails(
            marketMoversFOFetchItemsDoneState.marketMoversModel?.marketMovers,
            streamingKeys),
      ),
    );
  }

  Future<void> sendStreamForMarketMoversIndices(
    Emitter<MarketsState> emit,
  ) async {
    final List<String> streamingKeys = <String>[
      AppConstants.streamingLtp,
      AppConstants.streamingChng,
      AppConstants.streamingChgnPer
    ];

    emit(
      MarketMoversStartStreamState(
        AppHelper().streamDetails(
            marketMoversFetchItemsDoneState.marketMoversModel?.marketMovers,
            streamingKeys),
      ),
    );
  }

  Future<void> sendStream(
    Emitter<MarketsState> emit,
  ) async {
    final List<String> streamingKeys = <String>[
      AppConstants.streamingLtp,
      AppConstants.streamingChng,
      AppConstants.streamingChgnPer
    ];

    emit(
      MarketMoversStartStreamState(
        AppHelper().streamDetails(
            marketMoversFetchItemsDoneState.marketMoversModel?.marketMovers,
            streamingKeys),
      ),
    );
  }

  Future<void> _handleMarketMoversFOFetchTopGainersLosersFetchEvent(
      MarketMoversFetchFOTopGainersLosersFetchEvent event,
      Emitter<MarketsState> emit) async {
    emit(MarketsMoversFOProgressState());
    try {
      final BaseRequest request = BaseRequest();
      var filterString = [];
      if (event.fetchAllDetails == true) {
        filterString = [
          {"key": "asset", "value": "${event.asset}"},
          {"key": "segment", "value": "${event.segment}"},
          {"key": "expiry", "value": "${event.expiry}"},
        ];
      } else {
        filterString = [
          {"key": "asset", "value": "${event.asset}"},
          {"key": "segment", "value": "${event.segment}"},
          {"key": "limit", "value": "${event.limit}"},
          {"key": "expiry", "value": "${event.expiry}"},
        ];
      }

      request.addToData("filters", filterString);
      request.addToData('exc', "NFO");
      request.addToData('sortBy', "${event.sortBy}");

      final MarketMoversModel marketMoversResponse =
          await MarketMoversRepository().getMarketMoversRequest(request);

      marketMoversFOFetchItemsDoneState.marketMoversModel =
          marketMoversResponse;

      emit(MarketMoversFOFetchItemsDoneState()
        ..marketMoversModel = marketMoversResponse);
      emit(MarketMoversFOExpiryListResponseDoneDummyState());

      await sendStreamForFO(emit);
    } on ServiceException catch (ex) {
      emit(MarketsServiceExpectionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(MarketsFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleMarketMoversFetchTopGainersLosersFetchEvent(
      MarketMoversFetchTopGainersLosersFetchEvent event,
      Emitter<MarketsState> emit) async {
    try {
      emit(MarketsMoversFetchItemsProgressState());
      final BaseRequest request = BaseRequest();
      var filterString = [];
      var exc = event.exchange;

      if (event.indexName == "Nifty 50") {
        event.indexName = "Nifty";
      }
      if (event.fetchAllDetails == true) {
        filterString = [
          {"key": "indexName", "value": "${event.indexName}"},
        ];
      } else {
        filterString = [
          {"key": "indexName", "value": "${event.indexName}"},
          {"key": "limit", "value": "${event.limit}"}
        ];
      }
      request.addToData("filters", filterString);
      if (exc != null) {
        request.addToData('exc', event.exchange);
      } else {
        request.addToData('exc', "NSE");
      }
      // if (event.sortBy?.toLowerCase() == "yhigh") {
      //   event.sortBy = "52wkHigh";
      // }
      // if (event.sortBy?.toLowerCase() == "ylow") {
      //   event.sortBy = "52wkLow";
      // }
      request.addToData('sortBy', "${event.sortBy}");
      final MarketMoversModel marketMoversResponse =
          await MarketMoversRepository().getMarketMoversRequest(request);

      marketMoversFetchItemsDoneState.marketMoversModel = marketMoversResponse;
      emit(marketMoversFetchItemsDoneState
        ..marketMoversModel = marketMoversResponse);
      await sendStream(emit);
    } on ServiceException catch (ex) {
      emit(MarketsServiceExpectionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    } on FailedException catch (ex) {
      if (ex.code == AppConstants.noDataAvailableErrorCode) {
        emit(MarketsServiceExpectionState()
          ..errorCode = ex.code
          ..errorMsg = ex.msg);
      } else {
        emit(MarketsFailedState()
          ..errorCode = ex.code
          ..errorMsg = ex.msg);
      }
    }
  }

  Future<void> responseCallbackForMarketMoversFO(
    ResponseData streamData,
    Emitter<MarketsState> emit,
  ) async {
    if (marketMoversFOFetchItemsDoneState.marketMoversModel != null) {
      final List<Symbols>? symbols =
          marketMoversFOFetchItemsDoneState.marketMoversModel?.marketMovers;

      if (symbols != null) {
        final int index = symbols.indexWhere(
            (Symbols element) => element.sym?.streamSym == streamData.symbol);
        if (index >= 0) {
          symbols[index].yhigh = streamData.yHigh ?? symbols[index].yhigh;
          symbols[index].ylow = streamData.yLow ?? symbols[index].ylow;
          symbols[index].high = streamData.high ?? symbols[index].high;
          symbols[index].low = streamData.low ?? symbols[index].low;
          symbols[index].close = streamData.close ?? symbols[index].close;
          symbols[index].ltp = streamData.ltp ?? symbols[index].ltp;
          symbols[index].chng = streamData.chng ?? symbols[index].chng;
          symbols[index].chngPer =
              (ACMCalci.holdingChangePercent(symbols[index]));
        }
      }

      emit(marketMoversFetchItemsDoneState
        ..marketMoversModel =
            marketMoversFOFetchItemsDoneState.marketMoversModel);
    }
  }

  Future<void> responseCallbackForMarketMovers(
    ResponseData streamData,
    Emitter<MarketsState> emit,
  ) async {
    if (marketMoversFetchItemsDoneState.marketMoversModel != null) {
      final List<Symbols>? symbols =
          marketMoversFetchItemsDoneState.marketMoversModel?.marketMovers;

      if (symbols != null) {
        final int index = symbols.indexWhere(
            (Symbols element) => element.sym?.streamSym == streamData.symbol);

        if (index >= 0) {
          symbols[index].yhigh = streamData.yHigh ?? symbols[index].yhigh;
          symbols[index].ylow = streamData.yLow ?? symbols[index].ylow;
          symbols[index].high = streamData.high ?? symbols[index].high;
          symbols[index].low = streamData.low ?? symbols[index].low;

          symbols[index].close = streamData.close ?? symbols[index].close;
          symbols[index].ltp = streamData.ltp ?? symbols[index].ltp;
          symbols[index].chng = streamData.chng ?? symbols[index].chng;
          symbols[index].chngPer =
              ACMCalci.holdingChangePercent(symbols[index]);
        }
      }

      emit(marketMoversFetchItemsDoneState
        ..marketMoversModel =
            marketMoversFetchItemsDoneState.marketMoversModel);
    } else if (marketMoversIndicesFetchItemsDoneState.symbols != null) {
      final List<Symbols>? symbols =
          marketMoversIndicesFetchItemsDoneState.symbols;

      if (symbols != null) {
        final int index = symbols.indexWhere(
            (Symbols element) => element.sym?.streamSym == streamData.symbol);
        symbols[index].yhigh = streamData.yHigh ?? symbols[index].yhigh;
        symbols[index].ylow = streamData.yLow ?? symbols[index].ylow;

        symbols[index].close = streamData.close ?? symbols[index].close;
        symbols[index].ltp = streamData.ltp ?? symbols[index].ltp;
        symbols[index].chng = streamData.chng ?? symbols[index].chng;
        symbols[index].chngPer = ACMCalci.holdingChangePercent(symbols[index]);
      }

      emit(MarketMoversIndicesFetchItemsDoneState()
        ..symbols = marketMoversIndicesFetchItemsDoneState.symbols);
    }
  }

  Future<void> responseCallbackForPullDownMenu(
    ResponseData streamData,
    Emitter<MarketsState> emit,
  ) async {
    if (marketsPullDownItemsDoneState.pullDownMenuSymbols != null) {
      final List<Symbols>? symbols =
          marketsPullDownItemsDoneState.pullDownMenuSymbols;
      // marketMoversFetchItemsDoneState.marketMoversModel!.marketMovers;

      if (symbols != null) {
        final int index = symbols.indexWhere(
            (Symbols element) => element.sym?.streamSym == streamData.symbol);
        if (index >= 0) {
          symbols[index].yhigh = streamData.yHigh ?? symbols[index].yhigh;
          symbols[index].ylow = streamData.yLow ?? symbols[index].ylow;
          symbols[index].high = streamData.high ?? symbols[index].high;
          symbols[index].low = streamData.low ?? symbols[index].low;
          symbols[index].close = streamData.close ?? symbols[index].close;
          symbols[index].ltp = streamData.ltp ?? symbols[index].ltp;
          symbols[index].chng = streamData.chng ?? symbols[index].chng;
          symbols[index].chngPer =
              ACMCalci.holdingChangePercent(symbols[index]);
        }
      }
      emit(MarketsPullDownItemsDoneState()
        ..pullDownMenuSymbols =
            marketsPullDownItemsDoneState.pullDownMenuSymbols
        ..pullDownMenuEditSymbols =
            marketsPullDownItemsDoneState.pullDownMenuEditSymbols);
    }
  }

  Future<void> responseCallback(
    ResponseData streamData,
    Emitter<MarketsState> emit,
  ) async {
    if (marketsFetchItemsDoneState.nSE?.isNotEmpty ?? false) {
      final List<Symbols>? symbols = marketsFetchItemsDoneState.nSE;
      // marketMoversFetchItemsDoneState.marketMoversModel!.marketMovers;

      if (symbols != null) {
        final int index = symbols.indexWhere(
            (Symbols element) => element.sym?.streamSym == streamData.symbol);
        symbols[index].yhigh = streamData.yHigh ?? symbols[index].yhigh;
        symbols[index].ylow = streamData.yLow ?? symbols[index].ylow;
        symbols[index].high = streamData.high ?? symbols[index].high;
        symbols[index].low = streamData.low ?? symbols[index].low;

        symbols[index].close = streamData.close ?? symbols[index].close;
        symbols[index].ltp = streamData.ltp ?? symbols[index].ltp;
        symbols[index].chng = streamData.chng ?? symbols[index].chng;
        symbols[index].chngPer = ACMCalci.holdingChangePercent(symbols[index]);
      }

      emit(MarketsChangeState());

      emit(marketsFetchItemsDoneState..nSE = marketsFetchItemsDoneState.nSE);
    } else if (marketsFetchItemsDoneState.bSE?.isNotEmpty ?? false) {
      final List<Symbols>? symbols = marketsFetchItemsDoneState.bSE;
      // marketMoversFetchItemsDoneState.marketMoversModel!.marketMovers;

      if (symbols != null) {
        final int index = symbols.indexWhere(
            (Symbols element) => element.sym?.streamSym == streamData.symbol);
        symbols[index].yhigh = streamData.yHigh ?? symbols[index].yhigh;
        symbols[index].ylow = streamData.yLow ?? symbols[index].ylow;
        symbols[index].high = streamData.high ?? symbols[index].high;
        symbols[index].low = streamData.low ?? symbols[index].low;

        symbols[index].close = streamData.close ?? symbols[index].close;
        symbols[index].ltp = streamData.ltp ?? symbols[index].ltp;
        symbols[index].chng = streamData.chng ?? symbols[index].chng;
        symbols[index].chngPer = ACMCalci.holdingChangePercent(symbols[index]);
      }

      emit(MarketsChangeState());

      emit(marketsFetchItemsDoneState..bSE = marketsFetchItemsDoneState.bSE);
    }
  }

  Future<void> _handleFetchMarketIndicesEvent(
    FetchMarketIndicesItemsEvent event,
    Emitter<MarketsState> emit,
  ) async {
    {
      // emit(MarketsFetchItemsProgressState());

      List<NSE> symbolList = [];
      if (event.getCashSegmentItems == true) {
        // symbolList = AppConfig.indices!.nSE!.toList();
        AppConfig.indices?.nSE?.toList().forEach((element) {
          //Nifty Serv Sector
          if (element.baseSym == "NIFTY" ||
              element.baseSym == "India VIX" ||
              element.baseSym == "BANKNIFTY" ||
              element.baseSym == "NIFTY SMLCAP 100") {
            symbolList.add(element);
          }
        });

        AppConfig.indices?.bSE?.toList().forEach((element) {
          if (element.baseSym == "SENSEX") {
            NSE nseItem = NSE();
            nseItem.baseSym = element.baseSym;
            nseItem.dispSym = element.dispSym;
            nseItem.hasFutOpt = element.hasFutOpt;
            nseItem.sym = element.sym;
            symbolList.insert(1, nseItem);
          }
        });
        emit(marketsFetchItemsDoneState..nSE = symbolList);
        await sendStreamForMarketIndices(emit);
      } else if (event.getPullDownMenuEditItems == true) {
        List<NSE> fullSymbolList = [];
        AppConfig.indices?.nSE?.toList().forEach((element) {
          fullSymbolList.add(element);
          if (element.baseSym == "NIFTY" ||
              element.baseSym == "Nifty 100" ||
              element.baseSym == "BANKNIFTY") {
            symbolList.add(element);
          }
        });

        AppConfig.indices?.bSE?.toList().forEach((element) {
          if (element.baseSym == "SENSEX") {
            NSE nseItem = NSE();
            nseItem.baseSym = element.baseSym;
            nseItem.dispSym = element.dispSym;
            nseItem.hasFutOpt = element.hasFutOpt;
            nseItem.sym = element.sym;
            symbolList.insert(1, nseItem);
            fullSymbolList.add(nseItem);
          }
        });
        emit(MarketsPullDownItemsEditListDoneState()
          ..pullDownMenuEditSymbols = fullSymbolList);
        // await sendStreamForMarketIndices(emit);
      } else if (event.getPullDownMenuItems == true) {
        List<NSE> fullSymbolList = [];
        symbolList = [
          NSE(
            baseSym: "NIFTY",
          ),
          NSE(baseSym: "SENSEX"),
          NSE(baseSym: "Nifty 100"),
          NSE(baseSym: "BANKNIFTY")
        ];
        AppConfig.indices?.nSE?.toList().forEach((element) {
          fullSymbolList.add(element);
        });

        AppConfig.indices?.bSE?.toList().forEach((element) {
          if (element.baseSym == "SENSEX") {
            NSE nseItem = NSE();
            nseItem.baseSym = element.baseSym;
            nseItem.dispSym = element.dispSym;
            nseItem.hasFutOpt = element.hasFutOpt;
            nseItem.sym = element.sym;
            fullSymbolList.add(nseItem);
          }
        });
        symbolList = symbolList
            .map((element) => fullSymbolList
                .where((e2) => element.baseSym == e2.baseSym)
                .first)
            .toList();

        marketsPullDownItemsDoneState.pullDownMenuSymbols = symbolList;
        marketsPullDownItemsDoneState.pullDownMenuEditSymbols = fullSymbolList;
        emit(MarketsPullDownItemsDoneState()
          ..pullDownMenuSymbols = symbolList
          ..pullDownMenuEditSymbols = fullSymbolList);

        var symbols = await getSavedPullDownSymbols();
        int len = 0;
        if (symbols != null) {
          len = symbols.length; // Safe
        } else {
          setSavedPullDownSymbols(symbolList);
        }

        if (len != 0) {
          List<Symbols> symList = [];
          for (var element in pullDownSymbolsList) {
            symList.add(
                AppUtils().getSymbolsItemWithDispSym(element, fullSymbolList));
            marketsPullDownItemsDoneState.pullDownMenuSymbols = symList;
          }
        } else {
          marketsPullDownItemsDoneState.pullDownMenuSymbols = symbolList;
        }

        await sendStreamForMarketIndicesPullDownMenu(
            marketsPullDownItemsDoneState.pullDownMenuSymbols ?? [], emit);
      } else if (event.getFOSegmentItems == true) {
        for (NSE element in AppConfig.indices?.nSE ?? []) {
          if (element.baseSym == "NIFTY" ||
              element.baseSym == "BANKNIFTY" ||
              element.baseSym == "FINNIFTY") {
            symbolList.add(element);
          }
        }
        // AppConfig.indices?.nSE?.toList().forEach((element) {
        //   if (element.baseSym == "NIFTY" ||
        //       element.baseSym == "BANKNIFTY" ||
        //       element.baseSym == "FINNIFTY") {
        //     symbolList.add(element);
        //   }
        // });
        emit(marketsFetchItemsDoneState..nSE = symbolList);

        await sendStreamForMarketIndices(emit);
      } else if (event.getBseItems == true) {
        marketsFetchItemsDoneState.nSE = [];
        emit(
            marketsFetchItemsDoneState..bSE = AppConfig.indices?.bSE?.toList());
        await sendStreamForMarketIndices(emit, isBse: true);
      } else if (event.getNseItems == true) {
        marketsFetchItemsDoneState.bSE = [];
        emit(
            marketsFetchItemsDoneState..nSE = AppConfig.indices?.nSE?.toList());
        await sendStreamForMarketIndices(emit);
      }
    }
  }

  Future<void> _handleMarketsFilterSortSymbolEvent(
      MarketsFilterSortSymbolEvent event, Emitter<MarketsState> emit) async {
    emit(MarketsMoversFetchItemsProgressState());

    if (event.isFNOSort == false && event.isNiftySort == false) {
      marketMoversFetchItemsDoneState.marketMoversModel?.marketMovers =
          event.symbols as List<MarketMovers>;
    } else if (event.isNiftySort = true) {
      marketMoversIndicesFetchItemsDoneState.symbols = event.symbols;
    } else {
      marketMoversFOFetchItemsDoneState.marketMoversModel?.marketMovers =
          event.symbols as List<MarketMovers>;
    }
    List<Symbols> symbols = event.symbols;
    if (event.selectedSort != null) {
      if (event.selectedSort?.sortName == AppConstants.alphabetically) {
        if (event.selectedSort?.sortType == Sort.ASCENDING) {
          symbols.sort((Symbols a, Symbols b) =>
              a.dispSym!.toLowerCase().compareTo(b.dispSym!.toLowerCase()));
        } else {
          symbols.sort((Symbols a, Symbols b) =>
              b.dispSym!.toLowerCase().compareTo(a.dispSym!.toLowerCase()));
        }
      } else if (event.selectedSort?.sortName == AppConstants.price) {
        if (event.selectedSort?.sortType == Sort.ASCENDING) {
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
      } else if (event.selectedSort?.sortName == AppConstants.chngPercent) {
        if (event.selectedSort?.sortType == Sort.ASCENDING) {
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

    emit(MarketMoversSortItemsDoneState()..symbols = symbols);
  }

  void sortSymbols(MarketsFilterSortSymbolEvent event, List<Symbols> symbols) {}

  Future<dynamic> getSavedPullDownSymbols() async {
    List? data = await AppStorage().getData("savedPullDownMenuItemsKey");

    if (data != null) {
      for (var element in data) {
        pullDownSymbolsList.add(element['dispSym']);
      }
    }
    return data;
  }

  void setSavedPullDownSymbols(List<Symbols> symbolList) {
    AppStorage()
        .setData(savedPullDownMenuItemsKey, symbolList.take(4).toList());
  }

  @override
  MarketsState getErrorState() {
    return MarketsFailedState();
  }

  _handleMarketFiiDiiFetchEvent(
      MarketsFFIDIIFetch event, Emitter<MarketsState> emit) async {
    BaseRequest request = BaseRequest();
    try {
      request.addToData("type", event.type);
      request.addToData("category", event.category);
      final FIIDIIModel fiiDIIResponse =
          await MarketMoversRepository().getFiiDii(request);

      emit(MarketFIIDIIDoneState()..fiidiiModel = fiiDIIResponse);
    } catch (e) {
      emit(MarketFIIDIIFailedState());
    }
  }
}
