import 'package:acml/src/data/repository/markets/markets_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:acml/src/blocs/common/base_bloc.dart';
import 'package:acml/src/blocs/common/screen_state.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/streamer/models/stream_response_model.dart';

import '../../constants/app_constants.dart';
import '../../data/store/app_helper.dart';
import '../../models/common/symbols_model.dart';
import '../../models/markets/rollover_model.dart';

part 'rollover_event.dart';
part 'rollover_state.dart';

class RollOverBloc extends BaseBloc<RollOverEvent, RollOverState> {
  RollOverBloc() : super(RollOverInitial());
  RollOverDone rollOverDone = RollOverDone();
  @override
  Future<void> eventHandlerMethod(
      RollOverEvent event, Emitter<RollOverState> emit) async {
    if (event is FetchRolloverRollOverEvent) {
      await onFetchRolloverRollOverEvent(event, emit);
    } else if (event is FetchRolloverResponseEvent) {
      await responseCallback(event.data, emit);
    }
  }

  Future<void> onFetchRolloverRollOverEvent(
      FetchRolloverRollOverEvent event, Emitter<RollOverState> emit) async {
    emit(RollOverLoading());
    BaseRequest request = BaseRequest();

    request.addToData("exc", "NFO");
    request.addToData("sortBy", event.sortBy);
    request.addToData("filters", [
      {
        "value": event.sortBy == AppConstants.idx
            ? "IDX"
            : "STK", // IDX, COM, UNDCUR
        "key": "asset"
      }
    ]);

    RollOverModel rollOverModel =
        await MarketMoversRepository().getRollOverList(request);
    emit(rollOverDone..rollOver = (rollOverModel));
    await sendStream(emit);
  }

  Future<void> sendStream(Emitter<RollOverState> emit) async {
    if (rollOverDone.rollOver?.symList != null) {
      final List<String> streamingKeys = <String>[
        AppConstants.streamingLtp,
        AppConstants.streamingChng,
        AppConstants.streamingChgnPer,
        AppConstants.streamingHigh,
        AppConstants.high,
        AppConstants.low,
        AppConstants.streamingLow,
      ];
      if (rollOverDone.rollOver?.symList.isNotEmpty ?? false) {
        emit(RollOverSymStreamState(
          AppHelper()
              .streamDetails(rollOverDone.rollOver?.symList, streamingKeys),
        ));
      }
    }
  }

  Future<void> responseCallback(
    ResponseData streamData,
    Emitter<RollOverState> emit,
  ) async {
    if (rollOverDone.rollOver?.symList.isNotEmpty ?? false) {
      final List<Symbols>? symbols = rollOverDone.rollOver?.symList;

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
        symbols[index].chngPer = streamData.chngPer ?? symbols[index].chngPer;
      }

      emit(RollOverChange());

      emit(rollOverDone..rollOver?.symList = symbols ?? []);
    }
  }

  @override
  RollOverState getErrorState() {
    return RollOverError();
  }
}
