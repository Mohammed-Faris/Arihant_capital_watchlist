import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

import '../../../../constants/app_constants.dart';
import '../../../../data/repository/order_pad/order_pad_repository.dart';
import '../../../../data/repository/quote/quote_repository.dart';
import '../../../../data/store/app_helper.dart';
import '../../../../models/common/sym_model.dart';
import '../../../../models/common/symbols_model.dart';
import '../../../../models/quote/get_symbol_info_model.dart';
import '../../../../models/quote/quote_expiry/quote_expiry.dart';
import '../../../../models/quote/quote_futures/quote_future_expiry_data.dart';
import '../../../../models/quote/quote_futures/quote_futures.dart';
import '../../../../models/quote/quote_options/quote_option_chain_data.dart';
import '../../../../models/quote/quote_options/quote_options.dart';
import '../../../common/base_bloc.dart';
import '../../../common/screen_state.dart';

part 'quote_futures_options_event.dart';
part 'quote_futures_options_state.dart';

class QuoteFuturesOptionsBloc
    extends BaseBloc<QuoteFuturesOptionsEvent, QuoteFuturesOptionsState> {
  QuoteFuturesOptionsBloc() : super(QuoteFuturesOptionsInitial());

  QuoteFuturesDoneState quoteFuturesDoneState = QuoteFuturesDoneState();
  QuoteOptionsDoneState quoteOptionsDoneState = QuoteOptionsDoneState();
  QuoteExpiryDoneState quoteExpiryDone = QuoteExpiryDoneState();

  QuoteOptionChainFilterDoneState quoteOptionChainFilterDoneState =
      QuoteOptionChainFilterDoneState();

  @override
  Future<void> eventHandlerMethod(QuoteFuturesOptionsEvent event,
      Emitter<QuoteFuturesOptionsState> emit) async {
    if (event is QuoteStartFutureStreamEvent) {
      await sendStream(emit);
    } else if (event is QuoteFutureStreamingResponseEvent) {
      await responseCallback(event.data, emit);
    } else if (event is QuoteToggleFuturesEvent) {
      await _toggleQuoteFutures(emit);
    } else if (event is QuoteToggleOptionsEvent) {
      await _toggleQuoteOptions(emit);
    } else if (event is QuoteFuturesExpiryEvent) {
      await _getQuotesFuturesEvent(event, emit, event.futureExpiryData);
    } else if (event is QuoteExpiryDataEvent) {
      await _getQuotesExpiryEvent(event, emit, event.futureExpiryData);
    } else if (event is QuoteOptionsChainEvent) {
      await _getQuotesOptionsChainEvent(event, emit);
    } else if (event is QuoteOptionChainStartSymStreamEvent) {
      await optionChainSendStream(emit);
    } else if (event is QuoteOptionChainStreamingResponseEvent) {
      await optionChainResponseCallback(event.data, emit);
    } else if (event is QuoteOptionChainUpdateFilterListEvent) {
      await _handleQuoteOptionChainUpdateFilterListEvent(event, emit);
    } else if (event is QuoteOptionChainGetFilterListEvent) {
      await _handleQuoteOptionChainGetFilterListEvent(event, emit);
    }
  }

  Future<void> _toggleQuoteFutures(
          Emitter<QuoteFuturesOptionsState> emit) async =>
      emit(QuoteToggleFuturesState()..quoteFuturesBloc = true);

  Future<void> _toggleQuoteOptions(
          Emitter<QuoteFuturesOptionsState> emit) async =>
      emit(QuoteToggleOptionsState()..quoteOptionsBloc = true);
  CancelableOperation? fetchFuture;
  CancelableOperation? fetchOption;

  Future<void> _getQuotesFuturesEvent(
      QuoteFuturesOptionsEvent event,
      Emitter<QuoteFuturesOptionsState> emit,
      FutureExpiryData expiryExpiryData) async {
    emit(QuoteFuturesOptionsProgressState());
    fetchOption?.cancel();
    try {
      Sym? sym = await callOtherExcforBSE(expiryExpiryData);
      final BaseRequest request = BaseRequest();
      request.addToData('dispSym', expiryExpiryData.dispSym);
      request.addToData('sym', sym);
      request.addToData('companyName', expiryExpiryData.companyName);
      request.addToData('baseSym', expiryExpiryData.baseSym);
      request.addToData('filters', expiryExpiryData.filters);
      fetchFuture = CancelableOperation.fromFuture(
          QuoteRepository().getQuoteFuturesExpiryRequest(request));
      final QuoteFuturesModel quoteFuturesModel = await fetchFuture?.value;
      quoteFuturesDoneState.quoteFuturesModel = quoteFuturesModel;
      await sendStream(emit);
      emit(QuoteFuturesDoneState()..quoteFuturesModel = quoteFuturesModel);
    } on ServiceException catch (ex) {
      emit(QuoteFuturesOptionsServiceException()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(QuoteFuturesOptionsFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<Sym?> callOtherExcforBSE(FutureExpiryData expiryExpiryData) async {
    Sym? sym;
    sym = Sym.copyModel(expiryExpiryData.sym!);

    if (expiryExpiryData.sym != null) {
      if (sym.exc == AppConstants.bse &&
          nseSymbol?.baseSym != expiryExpiryData.baseSym?.replaceAll("*", "") &&
          (sym.instrument != AppConstants.idx)) {
        final BaseRequest request = BaseRequest();
        request.addToData('sym', expiryExpiryData.sym!.toJson());
        request.addToData('otherExch', sym.otherExch?.first);
        GetSymbolModel getSymbolModel =
            await OrderPadRepository().getSymbolInfoRequest(request);
        expiryExpiryData.dispSym = getSymbolModel.symbol?.dispSym;
        expiryExpiryData.baseSym = getSymbolModel.symbol?.baseSym;
        sym = getSymbolModel.symbol!.sym;
        sym?.dispSym = getSymbolModel.symbol!.dispSym;
        sym?.baseSym = getSymbolModel.symbol!.baseSym;
        nseSymbol = getSymbolModel.symbol;
      } else if (nseSymbol?.baseSym ==
              expiryExpiryData.baseSym?.replaceAll("*", "") &&
          sym.exc == AppConstants.bse) {
        sym = nseSymbol!.sym;
        sym?.dispSym = nseSymbol!.dispSym;
        sym?.baseSym = nseSymbol!.baseSym;
      }
    }

    return sym;
  }

  static Symbols? nseSymbol;
  Future<void> _getQuotesExpiryEvent(
      QuoteFuturesOptionsEvent event,
      Emitter<QuoteFuturesOptionsState> emit,
      FutureExpiryData expiryExpiryData) async {
    emit(QuoteFuturesOptionsProgressState());
    fetchFuture?.cancel();
    try {
      Sym? sym = await callOtherExcforBSE(expiryExpiryData);

      final BaseRequest request = BaseRequest();
      request.addToData('dispSym', sym?.dispSym ?? expiryExpiryData.dispSym);
      request.addToData('sym', sym);
      request.addToData('companyName', expiryExpiryData.companyName);
      request.addToData('baseSym', sym?.baseSym ?? expiryExpiryData.baseSym);
      request.addToData('filters', expiryExpiryData.filters);
      fetchOption = CancelableOperation.fromFuture(
          QuoteRepository().getQuoteExpiryListRequest(request));
      final QuoteExpiry quoteExpiry = await fetchOption?.value;
      emit(QuoteExpiryDoneState()..quoteExpiry = quoteExpiry);
    } on ServiceException catch (ex) {
      emit(QuoteFuturesOptionsServiceException()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(QuoteFuturesOptionsFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _getQuotesOptionsChainEvent(
    QuoteOptionsChainEvent event,
    Emitter<QuoteFuturesOptionsState> emit,
  ) async {
    emit(QuoteFuturesOptionsProgressState());
    try {
      Sym? sym = await callOtherExcforBSE(FutureExpiryData(
          baseSym: event.quoteOptionChain.baseSym,
          dispSym: event.quoteOptionChain.dispSym,
          sym: event.quoteOptionChain.sym));

      // emit(QuoteFuturesOptionsProgressState());

      final BaseRequest request = BaseRequest();
      request.addToData(
          'dispSym', sym?.dispSym ?? event.quoteOptionChain.dispSym);
      request.addToData('sym', sym);
      request.addToData(
          'baseSym', sym?.baseSym ?? event.quoteOptionChain.baseSym);
      request.addToData('expiry', event.quoteOptionChain.expiry);

      final OptionQuoteModel optionQuoteModel =
          await QuoteRepository().getQuoteOptionsRequest(request);
      emit(QuoteOptionsChangeState());
      quoteOptionsDoneState.optionQuoteModel = optionQuoteModel;
      await optionChainSendStream(emit);

      if (event.isOptionChainStreaming) {
        await optionChainSendStream(emit);
      }

      emit(QuoteOptionsDoneState()..optionQuoteModel = optionQuoteModel);
    } on ServiceException catch (ex) {
      emit(QuoteFuturesOptionsServiceException()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(QuoteFuturesOptionsFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  Future<void> _handleQuoteOptionChainUpdateFilterListEvent(
    QuoteOptionChainUpdateFilterListEvent event,
    Emitter<QuoteFuturesOptionsState> emit,
  ) async {
    emit(QuoteOptionChainProgressState());
    quoteOptionChainFilterDoneState.selectedFilterList = event.selectedFilter!;
    emit(QuoteOptionsChangeState());
    emit(quoteOptionChainFilterDoneState);
  }

  Future<void> _handleQuoteOptionChainGetFilterListEvent(
    QuoteOptionChainGetFilterListEvent event,
    Emitter<QuoteFuturesOptionsState> emit,
  ) async {
    emit(QuoteOptionsChangeState());
    emit(quoteOptionChainFilterDoneState);
  }

  Future<void> optionChainSendStream(
      Emitter<QuoteFuturesOptionsState> emit) async {
    final OptionsResults? optionsResults =
        quoteOptionsDoneState.optionQuoteModel?.results;
    if (optionsResults != null &&
        (optionsResults.call!.isNotEmpty || optionsResults.put!.isNotEmpty)) {
      final List<Symbols> symbols = <Symbols>[
        ...optionsResults.call!,
        ...optionsResults.put!,
        ...optionsResults.spot!
      ];

      final List<String> streamingKeys = <String>[
        AppConstants.streamingLtp,
        AppConstants.streamingChgnPer,
        AppConstants.streamingOi,
        AppConstants.streamingOiChngPer,
        AppConstants.streamingVol,
      ];
      emit(
        QuoteOptionChainSymStreamState(
          AppHelper().streamDetails(symbols, streamingKeys),
        ),
      );
    }
  }

  Future<void> optionChainResponseCallback(
    ResponseData streamData,
    Emitter<QuoteFuturesOptionsState> emit,
  ) async {
    final OptionsResults? optionResults =
        quoteOptionsDoneState.optionQuoteModel?.results;
    if (optionResults != null) {
      final int callIndex = optionResults.call!.indexWhere(
          (Symbols element) => element.sym!.streamSym == streamData.symbol);
      final int putIndex = optionResults.put!.indexWhere(
          (Symbols element) => element.sym!.streamSym == streamData.symbol);
      final int spotIndex = optionResults.spot!.indexWhere(
          (Symbols element) => element.sym!.streamSym == streamData.symbol);

      if (putIndex != -1 || callIndex != -1 || spotIndex != -1) {
        emit(QuoteOptionsChangeState());
        quoteOptionsDoneState.optionQuoteModel!.results = optionResults;
        emit(quoteOptionsDoneState);
      }
      if (quoteOptionsDoneState.optionQuoteModel != null) {
        final OptionsResults? optionResults =
            quoteOptionsDoneState.optionQuoteModel!.results;

        if (optionResults != null) {
          final int callIndex =
              optionResults.call!.indexWhere((Symbols element) {
            return element.sym!.streamSym == streamData.symbol;
          });
          final int putIndex = optionResults.put!.indexWhere(
              (Symbols element) => element.sym!.streamSym == streamData.symbol);
          final int spotIndex = optionResults.spot!.indexWhere(
              (Symbols element) => element.sym!.streamSym == streamData.symbol);
          if (callIndex != -1) {
            optionResults.call![callIndex].ltp =
                streamData.ltp ?? optionResults.call![callIndex].ltp;
            optionResults.call![callIndex].chng =
                streamData.chng ?? optionResults.call![callIndex].chng;
            optionResults.call![callIndex].chngPer =
                streamData.chngPer ?? optionResults.call![callIndex].chngPer;
            optionResults.call![callIndex].yhigh =
                streamData.yHigh ?? optionResults.call![callIndex].yhigh;
            optionResults.call![callIndex].openInterest =
                streamData.oI ?? optionResults.call![callIndex].openInterest;
            optionResults.call![callIndex].oiChangePer = streamData.oIChngPer ??
                optionResults.call![callIndex].oiChangePer;
            optionResults.call![callIndex].vol =
                streamData.vol ?? optionResults.call![callIndex].vol;
            optionResults.call![callIndex].ylow =
                streamData.yLow ?? optionResults.call![callIndex].ylow;
          }
          if (putIndex != -1) {
            optionResults.put![putIndex].ltp =
                streamData.ltp ?? optionResults.put![putIndex].ltp;
            optionResults.put![putIndex].chng =
                streamData.chng ?? optionResults.put![putIndex].chng;
            optionResults.put![putIndex].chngPer =
                streamData.chngPer ?? optionResults.put![putIndex].chngPer;
            optionResults.put![putIndex].yhigh =
                streamData.yHigh ?? optionResults.put![putIndex].yhigh;
            optionResults.put![putIndex].ylow =
                streamData.yLow ?? optionResults.put![putIndex].ylow;
            optionResults.put![putIndex].openInterest =
                streamData.oI ?? optionResults.put![putIndex].openInterest;
            optionResults.put![putIndex].oiChangePer = streamData.oIChngPer ??
                optionResults.put![putIndex].oiChangePer;
            optionResults.put![putIndex].vol =
                streamData.vol ?? optionResults.put![putIndex].vol;
          }
          if (spotIndex != -1) {
            optionResults.spot![spotIndex].ltp =
                streamData.ltp ?? optionResults.spot![spotIndex].ltp;
            optionResults.spot![spotIndex].chng =
                streamData.chng ?? optionResults.spot![spotIndex].chng;
            optionResults.spot![spotIndex].chngPer =
                streamData.chngPer ?? optionResults.spot![spotIndex].chngPer;
            optionResults.spot![spotIndex].yhigh =
                streamData.yHigh ?? optionResults.spot![spotIndex].yhigh;
            optionResults.spot![spotIndex].ylow =
                streamData.yLow ?? optionResults.spot![spotIndex].ylow;
          }
          if (putIndex != -1 || callIndex != -1 || spotIndex != -1) {
            emit(QuoteOptionsChangeState());
            emit(quoteOptionsDoneState
              ..optionQuoteModel!.results = optionResults);
          }
        }
      }
    }
  }

  Future<void> sendStream(Emitter<QuoteFuturesOptionsState> emit) async {
    if (quoteFuturesDoneState.quoteFuturesModel != null) {
      final List<String> streamingKeys = <String>[
        AppConstants.streamingLtp,
        AppConstants.streamingChng,
        AppConstants.streamingChgnPer,
        AppConstants.streamingHigh,
        AppConstants.streamingLow,
      ];
      if (quoteFuturesDoneState.quoteFuturesModel!.results!.isNotEmpty) {
        emit(QuoteFutureStreamState(
          AppHelper().streamDetails(
              quoteFuturesDoneState.quoteFuturesModel!.results, streamingKeys),
        ));
      }
    }
  }

  Future<void> responseCallback(
    ResponseData streamData,
    Emitter<QuoteFuturesOptionsState> emit,
  ) async {
    if (quoteFuturesDoneState.quoteFuturesModel != null) {
      final List<Symbols>? symbols =
          quoteFuturesDoneState.quoteFuturesModel!.results;

      if (symbols != null) {
        final int index = symbols.indexWhere((Symbols element) {
          return element.sym!.streamSym == streamData.symbol;
        });
        if (index != -1) {
          symbols[index].ltp = streamData.ltp ?? symbols[index].ltp;
          symbols[index].chng = streamData.chng ?? symbols[index].chng;
          symbols[index].chngPer = streamData.chngPer ?? symbols[index].chngPer;
          symbols[index].yhigh = streamData.yHigh ?? symbols[index].yhigh;
          symbols[index].ylow = streamData.yLow ?? symbols[index].ylow;
          emit(QuoteOptionsChangeState());
          emit(quoteFuturesDoneState..quoteFuturesModel!.results = symbols);
        }
      }
    }
  }

  @override
  QuoteFuturesOptionsState getErrorState() {
    return QuoteFuturesOptionsErrorState();
  }
}
