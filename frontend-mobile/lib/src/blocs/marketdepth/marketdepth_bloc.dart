import 'package:acml/src/blocs/common/screen_state.dart';
import 'package:acml/src/models/common/symbols_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:msil_library/streamer/models/quote2_stream_response_model.dart';
import 'package:msil_library/streamer/models/streaming_symbol_model.dart';

import '../../config/app_config.dart';
import '../../data/store/app_helper.dart';
import '../../data/store/app_utils.dart';
import '../common/base_bloc.dart';

part 'marketdepth_event.dart';
part 'marketdepth_state.dart';

class MarketdepthBloc extends BaseBloc<MarketdepthEvent, MarketdepthState> {
  MarketdepthBloc() : super(MarketdepthInitial());

  @override
  Future<void> eventHandlerMethod(
      MarketdepthEvent event, Emitter<MarketdepthState> emit) async {
    if (event is MarketdepthStreamResponseEvent) {
      await _handleMarketdepthStreamingResponseEvent(
        emit,
        event.quoteDepthData,
      );
    } else if (event is MarketdepthEventStreamEvent) {
      await _handleMarketdepthStreamEvent(
        emit,
        event.symbolItem,
      );
    }
  }

  @override
  MarketdepthState getErrorState() {
    return MarketDepthErrorState();
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

  _handleMarketdepthStreamEvent(
      Emitter<MarketdepthState> emit, Symbols symbolItem) {
    final List<StreamingSymbolModel> symbols = [];
    final StreamingSymbolModel symbol = StreamingSymbolModel.fromJson(
        <String, String>{'symbol': symbolItem.sym!.streamSym!});

    symbols.add(symbol);

    emit(
      MarketDepthStreamState(
        AppHelper().streamDetails(symbols, []),
      ),
    );
  }

  MktDepthDataState mktDepthDataState = MktDepthDataState();

  _handleMarketdepthStreamingResponseEvent(
      Emitter<MarketdepthState> emit, Quote2Data quoteDepthData) {
    mktDepthDataState.bidQtyPercent = calculateBidQtyPercent(quoteDepthData);

    mktDepthDataState.askQtyPercent = calculateAskQtyPercent(quoteDepthData);

    mktDepthDataState.quoteMarketDepthData = quoteDepthData;
    mktDepthDataState.totalBidQtyPercent =
        getTotalBidQtyPercent(quoteDepthData);
    mktDepthDataState.totalAskQtyPercent =
        getTotalAskQtyPercent(quoteDepthData);
    emit(MktDepthDataChangeState());
    emit(mktDepthDataState);
  }
}
