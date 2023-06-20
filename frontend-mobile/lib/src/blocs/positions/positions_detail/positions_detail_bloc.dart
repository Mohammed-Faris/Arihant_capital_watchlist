import '../../common/base_bloc.dart';
import '../../common/screen_state.dart';
import '../../../constants/app_constants.dart';
import '../../../data/repository/quote/quote_repository.dart';
import '../../../data/store/app_helper.dart';
import '../../../data/store/app_utils.dart';
import '../../../models/common/sym_model.dart';
import '../../../models/positions/positions_model.dart';
import '../../../models/quote/quote_performance/quote_contract_info.dart';
import '../../../models/quote/quote_performance/quote_delivery_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/streamer/models/quote2_stream_response_model.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';
import 'package:msil_library/streamer/models/streaming_symbol_model.dart';

import '../../../data/store/app_calculator.dart';

part 'positions_detail_event.dart';
part 'positions_detail_state.dart';

class PositionsDetailBloc
    extends BaseBloc<PositionsDetailEvent, PositionsDetailState> {
  PositionsDetailBloc() : super(PositionsDetailInitial());

  PositionsDetailDataState positionsDetailDataState =
      PositionsDetailDataState();

  PositionsDetailMktDepthDataState positionsDetailMktDepthDataState =
      PositionsDetailMktDepthDataState();

  @override
  Future<void> eventHandlerMethod(
      PositionsDetailEvent event, Emitter<PositionsDetailState> emit) async {
    if (event is PositionsDetailStartSymStreamEvent) {
      await sendStream(emit, event.positions);
    } else if (event is PositionsDetailStreamingResponseEvent) {
      await responseCallback(event.data, emit);
    } else if (event is PositionsDetailQuoteTwoStartStreamEvent) {
      await sendQuoteTwoStream(emit, event.positions);
    } else if (event is PositionsDetailQuoteTwoResponseEvent) {
      await _handleQuoteOverviewStreamingResponseEvent(
        emit,
        event.quoteDepthData,
      );
    } else if (event is PositionsDetailGetPerformanceContractInfoEvent) {
      await _handleHoldingsDetailGetPerformanceContractInfoEvent(
        event,
        emit,
      );
    } else if (event is PositionsDetailGetPerformanceDeliveryDataEvent) {
      await _handleHoldingsDetailGetPerformanceDeliveryDataEvent(
        event,
        emit,
      );
    }
  }

  Future<void> _handleHoldingsDetailGetPerformanceContractInfoEvent(
    PositionsDetailGetPerformanceContractInfoEvent event,
    Emitter<PositionsDetailState> emit,
  ) async {
    final BaseRequest request = BaseRequest();
    request.addToData('sym', event.sym);
    request.addToData('baseSym', event.sym.baseSym);

    final QuoteContractInfo quoteContractInfo =
        await QuoteRepository().getContractInfoRequest(request);
    positionsDetailDataState.quoteContractInfo = quoteContractInfo;
    emit(PositionsDetailChangeState());

    emit(positionsDetailDataState);
  }

  Future<void> _handleHoldingsDetailGetPerformanceDeliveryDataEvent(
    PositionsDetailGetPerformanceDeliveryDataEvent event,
    Emitter<PositionsDetailState> emit,
  ) async {
    emit(PositionsDetailPerformanceProgressState());

    final BaseRequest request = BaseRequest();
    request.addToData('sym', event.sym);

    final QuoteDeliveryData quoteDeliveryData =
        await QuoteRepository().getDeliveryDataRequest(request);
    positionsDetailDataState.quoteDeliveryData = quoteDeliveryData;
    emit(PositionsDetailChangeState());

    emit(positionsDetailDataState);
  }

  Future<void> sendStream(
    Emitter<PositionsDetailState> emit,
    Positions symbolItem,
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

    List<Positions> symbols = [];

    symbols.add(symbolItem);

    positionsDetailDataState.positions = symbols[0];

    emit(positionsDetailDataState);

    emit(
      PositionsDetailSymStreamState(
        AppHelper().streamDetails(symbols, streamingKeys),
      ),
    );
  }

  Future<void> responseCallback(
    ResponseData streamData,
    Emitter<PositionsDetailState> emit,
  ) async {
    final String symbolName = streamData.symbol!;
    final Positions symbol = positionsDetailDataState.positions!;
    if (symbol.sym!.streamSym == symbolName) {
      symbol.high = streamData.high ?? symbol.high;
      symbol.low = streamData.low ?? symbol.low;
      symbol.vol = streamData.vol ?? symbol.vol;
      symbol.atp = streamData.atp ?? symbol.atp;
      symbol.open = streamData.open ?? symbol.open;
      symbol.close = streamData.close ?? symbol.close;
      symbol.avgPrice = ACMCalci.positionAvgPrice(symbol);

      symbol.lcl = streamData.lcl ?? symbol.lcl;
      symbol.ucl = streamData.ucl ?? symbol.ucl;
      symbol.yhigh = streamData.yHigh ?? symbol.yhigh;
      symbol.ylow = streamData.yLow ?? symbol.ylow;
      symbol.openInterest = streamData.oI ?? symbol.openInterest;
    }
    positionsDetailDataState.positions = symbol;

    emit(PositionsDetailChangeState());

    emit(positionsDetailDataState);
  }

  Future<void> sendQuoteTwoStream(
    Emitter<PositionsDetailState> emit,
    Positions symbolItem,
  ) async {
    final List<StreamingSymbolModel> symbols = [];
    final StreamingSymbolModel symbol = StreamingSymbolModel.fromJson(
        <String, String>{'symbol': symbolItem.sym!.streamSym!});

    symbols.add(symbol);

    emit(
      PositionsDetailQuoteTwoStreamState(
        AppHelper().streamDetails(symbols, []),
      ),
    );
  }

  Future<void> _handleQuoteOverviewStreamingResponseEvent(
    Emitter<PositionsDetailState> emit,
    Quote2Data quoteDepthData,
  ) async {
    positionsDetailMktDepthDataState.bidQtyPercent =
        calculateBidQtyPercent(quoteDepthData);

    positionsDetailMktDepthDataState.askQtyPercent =
        calculateAskQtyPercent(quoteDepthData);

    positionsDetailMktDepthDataState.quoteMarketDepthData = quoteDepthData;
    positionsDetailMktDepthDataState.totalBidQtyPercent =
        getTotalBidQtyPercent(quoteDepthData);
    positionsDetailMktDepthDataState.totalAskQtyPercent =
        getTotalAskQtyPercent(quoteDepthData);
    emit(PositionsDetailChangeState());
    emit(positionsDetailMktDepthDataState);
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

  @override
  PositionsDetailState getErrorState() {
    return PositionsDetailErrorState();
  }
}
