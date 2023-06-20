import '../../common/base_bloc.dart';
import '../../common/screen_state.dart';
import '../../../constants/app_constants.dart';
import '../../../data/store/app_helper.dart';
import '../../../models/common/symbols_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:msil_library/streamer/models/stream_response_model.dart';

part 'chart_event.dart';
part 'chart_state.dart';

class ChartBloc extends BaseBloc<ChartEvent, ChartState> {
  ChartBloc() : super(ChartInitial());

  ChartDataState chartDataState = ChartDataState();

  @override
  Future<void> eventHandlerMethod(
    ChartEvent event,
    Emitter<ChartState> emit,
  ) async {
    if (event is ChartStartSymStreamEvent) {
      await sendStream(emit, event.symbolItem);
    } else if (event is ChartStreamingResponseEvent) {
      await responseCallback(event.data, emit);
    }
  }

  Future<void> sendStream(Emitter<ChartState> emit, Symbols symbolItem) async {
    final List<String> streamingKeys = <String>[
      AppConstants.streamingLtp,
      AppConstants.streamingChng,
      AppConstants.streamingChgnPer,
    ];

    List<Symbols> symbols = [];

    symbols.add(symbolItem);

    chartDataState.symbols = symbols[0];

    emit(chartDataState);

    emit(
      ChartSymStreamState(
        AppHelper().streamDetails(symbols, streamingKeys),
      ),
    );
  }

  Future<void> responseCallback(
    ResponseData streamData,
    Emitter<ChartState> emit,
  ) async {
    final String symbolName = streamData.symbol!;
    final Symbols symbol = chartDataState.symbols!;
    if (symbol.sym!.streamSym == symbolName) {
      symbol.ltp = streamData.ltp ?? symbol.ltp;
      symbol.chng = streamData.chng ?? symbol.chng;
      symbol.chngPer = streamData.chngPer ?? symbol.chngPer;
    }
    chartDataState.symbols = symbol;

    emit(ChartChangeState());

    emit(chartDataState);
  }

  @override
  ChartState getErrorState() {
    return ChartErrorState();
  }
}
