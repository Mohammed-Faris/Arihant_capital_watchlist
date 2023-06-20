import '../../common/base_bloc.dart';
import '../../common/screen_state.dart';
import '../../../constants/app_constants.dart';
import '../../../data/repository/quote/quote_repository.dart';
import '../../../data/store/app_helper.dart';
import '../../../data/store/app_utils.dart';
import '../../../data/store/app_calculator.dart';
import '../../../models/common/sym_model.dart';
import '../../../models/common/symbols_model.dart';
import '../../../models/quote/quote_performance/quote_contract_info.dart';
import '../../../models/quote/quote_performance/quote_delivery_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/streamer/models/quote2_stream_response_model.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';
import 'package:msil_library/streamer/models/streaming_symbol_model.dart';

part 'holdings_detail_event.dart';
part 'holdings_detail_state.dart';

class HoldingsDetailBloc
    extends BaseBloc<HoldingsDetailEvent, HoldingsDetailState> {
  HoldingsDetailBloc() : super(HoldingsDetailInitial());

  HoldingsDetailDataState holdingsDetailDataState = HoldingsDetailDataState();

  HoldingsDetailMktDepthDataState holdingsDetailMktDepthDataState =
      HoldingsDetailMktDepthDataState();

  @override
  Future<void> eventHandlerMethod(
      HoldingsDetailEvent event, Emitter<HoldingsDetailState> emit) async {
    if (event is HoldingsDetailStartSymStreamEvent) {
      await sendStream(emit, event.symbolItem);
    } else if (event is HoldingsDetailStreamingResponseEvent) {
      await responseCallback(event.data, emit);
    } else if (event is HoldingsDetailQuoteTwoStartStreamEvent) {
      await sendQuoteTwoStream(emit, event.symbolItem);
    } else if (event is HoldingsDetailQuoteTwoResponseEvent) {
      await _handleQuoteOverviewStreamingResponseEvent(
        emit,
        event.quoteDepthData,
      );
    } else if (event is HoldingsDetailGetPerformanceContractInfoEvent) {
      await _handleHoldingsDetailGetPerformanceContractInfoEvent(
        event,
        emit,
      );
    } else if (event is HoldingsDetailGetPerformanceDeliveryDataEvent) {
      await _handleHoldingsDetailGetPerformanceDeliveryDataEvent(
        event,
        emit,
      );
    }
  }

  Future<void> _handleHoldingsDetailGetPerformanceContractInfoEvent(
    HoldingsDetailGetPerformanceContractInfoEvent event,
    Emitter<HoldingsDetailState> emit,
  ) async {
    final BaseRequest request = BaseRequest();
    request.addToData('sym', event.sym);
    request.addToData('baseSym', event.sym.baseSym);

    final QuoteContractInfo quoteContractInfo =
        await QuoteRepository().getContractInfoRequest(request);
    holdingsDetailDataState.quoteContractInfo = quoteContractInfo;
    emit(HoldingsDetailChangeState());

    emit(holdingsDetailDataState);
  }

  Future<void> _handleHoldingsDetailGetPerformanceDeliveryDataEvent(
    HoldingsDetailGetPerformanceDeliveryDataEvent event,
    Emitter<HoldingsDetailState> emit,
  ) async {
    emit(HoldingsDetailPerformanceProgressState());

    final BaseRequest request = BaseRequest();
    request.addToData('sym', event.sym);

    final QuoteDeliveryData quoteDeliveryData =
        await QuoteRepository().getDeliveryDataRequest(request);
    holdingsDetailDataState.quoteDeliveryData = quoteDeliveryData;
    emit(HoldingsDetailChangeState());

    emit(holdingsDetailDataState);
  }

  Future<void> sendStream(
    Emitter<HoldingsDetailState> emit,
    Symbols symbolItem,
  ) async {
    final List<String> streamingKeys = <String>[
      AppConstants.streamingHigh,
      AppConstants.streamingLow,
      AppConstants.streamingVol,
      AppConstants.streamingAtp,
      AppConstants.streamingOpen,
      AppConstants.streamingClose,
      AppConstants.streamingLowerCircuit,
      AppConstants.streamingUpperCircuit,
      AppConstants.streamingOi,
    ];

    List<Symbols> symbols = [];

    symbols.add(symbolItem);

    holdingsDetailDataState.symbols = symbols[0];

    emit(holdingsDetailDataState);

    emit(
      HoldingsDetailSymStreamState(
        AppHelper().streamDetails(symbols, streamingKeys),
      ),
    );
  }

  Future<void> responseCallback(
    ResponseData streamData,
    Emitter<HoldingsDetailState> emit,
  ) async {
    final String symbolName = streamData.symbol!;
    final Symbols symbol = holdingsDetailDataState.symbols!;
    if (symbol.sym!.streamSym == symbolName) {
      symbol.high = streamData.high ?? symbol.high;
      symbol.low = streamData.low ?? symbol.low;
      symbol.vol = streamData.vol ?? symbol.vol;
      symbol.atp = streamData.atp ?? symbol.atp;
      symbol.open = streamData.open ?? symbol.open;
      symbol.close = streamData.close ?? symbol.close;
      symbol.lcl = streamData.lcl ?? symbol.lcl;
      symbol.ucl = streamData.ucl ?? symbol.ucl;
      symbol.yhigh = streamData.yHigh ?? symbol.yhigh;
      symbol.ylow = streamData.yLow ?? symbol.ylow;
      symbol.openInterest = streamData.oI ?? symbol.openInterest;
      symbol.mktValue = ACMCalci.holdingMktValue(symbol);
      symbol.oneDayPnL = ACMCalci.holdingOnedayPnl(symbol);
      symbol.overallPnL = ACMCalci.holdingOverallPnl(symbol);
    }
    holdingsDetailDataState.symbols = symbol;

    emit(HoldingsDetailChangeState());

    emit(holdingsDetailDataState);
  }

  Future<void> sendQuoteTwoStream(
    Emitter<HoldingsDetailState> emit,
    Symbols symbolItem,
  ) async {
    final List<StreamingSymbolModel> symbols = [];
    final StreamingSymbolModel symbol = StreamingSymbolModel.fromJson(
        <String, String>{'symbol': symbolItem.sym!.streamSym!});

    symbols.add(symbol);

    emit(
      HoldingsDetailQuoteTwoStreamState(
        AppHelper().streamDetails(symbols, []),
      ),
    );
  }

  Future<void> _handleQuoteOverviewStreamingResponseEvent(
    Emitter<HoldingsDetailState> emit,
    Quote2Data quoteDepthData,
  ) async {
    holdingsDetailMktDepthDataState.bidQtyPercent =
        calculateBidQtyPercent(quoteDepthData);

    holdingsDetailMktDepthDataState.askQtyPercent =
        calculateAskQtyPercent(quoteDepthData);

    holdingsDetailMktDepthDataState.quoteMarketDepthData = quoteDepthData;
    holdingsDetailMktDepthDataState.totalBidQtyPercent =
        getTotalBidQtyPercent(quoteDepthData);
    holdingsDetailMktDepthDataState.totalAskQtyPercent =
        getTotalAskQtyPercent(quoteDepthData);
    emit(HoldingsDetailChangeState());
    emit(holdingsDetailMktDepthDataState);
  }

  String getTotalBidQtyPercent(Quote2Data quoteDepthData) {
    double totalBidQtyPercent =
        (AppUtils().doubleValue(quoteDepthData.totBuyQty) /
                (AppUtils().doubleValue(quoteDepthData.totBuyQty) +
                    AppUtils().doubleValue(quoteDepthData.totSellQty))) *
            100;
    return totalBidQtyPercent.isNaN
        ? '0'
        : totalBidQtyPercent.toStringAsFixed(2);
  }

  String getTotalAskQtyPercent(Quote2Data quoteDepthData) {
    double totalAskQtyPercent =
        (AppUtils().doubleValue(quoteDepthData.totSellQty) /
                (AppUtils().doubleValue(quoteDepthData.totBuyQty) +
                    AppUtils().doubleValue(quoteDepthData.totSellQty))) *
            100;
    return totalAskQtyPercent.isNaN
        ? '0'
        : totalAskQtyPercent.toStringAsFixed(2);
  }

  List<String> calculateBidQtyPercent(Quote2Data quoteDepthData) {
    List<String> qtyList = [];
    for (var element in quoteDepthData.bid) {
      qtyList.add(getBidQtyPercent(element.qty, quoteDepthData.totBuyQty));
    }
    return qtyList;
  }

  List<String> calculateAskQtyPercent(Quote2Data quoteDepthData) {
    List<String> qtyList = [];
    for (var element in quoteDepthData.ask) {
      qtyList.add(getAskQtyPercent(element.qty, quoteDepthData.totSellQty));
    }
    return qtyList;
  }

  String getBidQtyPercent(String qty, String totBuyQty) {
    double bidQtyPercent =
        (AppUtils().doubleValue(qty) / AppUtils().doubleValue(totBuyQty)) * 100;
    return bidQtyPercent.toStringAsFixed(2);
  }

  String getAskQtyPercent(String qty, String totSellQty) {
    double askQtyPercent =
        (AppUtils().doubleValue(qty) / AppUtils().doubleValue(totSellQty)) *
            100;
    return askQtyPercent.toStringAsFixed(2);
  }

  String? getAvgPrice(Symbols holdings) {
    if (holdings.isPrevClose != null) {
      return holdings.isPrevClose!
          ? holdings.close.toString()
          : holdings.avgPrice;
    }
    return holdings.avgPrice;
  }

  @override
  HoldingsDetailState getErrorState() {
    return HoldingsDetailErrorState();
  }
}
