import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/streamer/models/quote2_stream_response_model.dart';

import '../../../../blocs/marketdepth/marketdepth_bloc.dart';
import '../../../../models/common/symbols_model.dart';
import '../../../widgets/market_depth_widget.dart';
import '../../base/base_screen.dart';

class MarketDepth extends BaseScreen {
  const MarketDepth(this.symbol,
      {Key? key, required this.screenName, required this.onCallOrderPad})
      : super(key: key);
  final Symbols symbol;
  final String screenName;

  final Function(String action, String? customPrice) onCallOrderPad;

  @override
  State<MarketDepth> createState() => _MarketDepthState();
}

class _MarketDepthState extends BaseAuthScreenState<MarketDepth> {
  late MarketdepthBloc marketdepthBloc;
  @override
  void initState() {
    marketdepthBloc = BlocProvider.of<MarketdepthBloc>(context)
      ..add(MarketdepthEventStreamEvent(widget.symbol))
      ..stream.listen((state) {
        if (state is MarketDepthStreamState) {
          subscribeLevel2(state.streamDetails);
        } else if (state is MarketDepthErrorState) {
          if (state.isInvalidException) {
            handleError(state);
          }
        }
      });
    super.initState();
  }

  @override
  Future<void> quote2responseCallback(Quote2Data streamData) async {
    if (!marketdepthBloc.isClosed) {
      marketdepthBloc.add(MarketdepthStreamResponseEvent(streamData));
    }
  }

  @override
  String getScreenRoute() {
    return widget.screenName;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketdepthBloc, MarketdepthState>(
      buildWhen: (previous, current) => current is MktDepthDataState,
      builder: (BuildContext context, MarketdepthState state) {
        if (state is MktDepthDataState) {
          return MarketDepthWidget(
              context: context,
              quoteDepthData: state.quoteMarketDepthData,
              totalBidQtyPercent: state.totalBidQtyPercent,
              totalAskQtyPercent: state.totalAskQtyPercent,
              bidQtyPercent: state.bidQtyPercent,
              askQtyPercent: state.askQtyPercent,
              onCallOrderPad: widget.onCallOrderPad);
        } else {
          return MarketDepthWidget(
            context: context,
            quoteDepthData:
                marketdepthBloc.mktDepthDataState.quoteMarketDepthData,
            totalBidQtyPercent:
                marketdepthBloc.mktDepthDataState.totalBidQtyPercent,
            totalAskQtyPercent:
                marketdepthBloc.mktDepthDataState.totalAskQtyPercent,
            bidQtyPercent: marketdepthBloc.mktDepthDataState.bidQtyPercent,
            askQtyPercent: marketdepthBloc.mktDepthDataState.askQtyPercent,
            onCallOrderPad: widget.onCallOrderPad,
          );
        }
      },
    );
  }
}
