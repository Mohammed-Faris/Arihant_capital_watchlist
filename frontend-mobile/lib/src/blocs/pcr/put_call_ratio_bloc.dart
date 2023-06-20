import 'package:acml/src/models/markets/put_call_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:msil_library/models/base/base_request.dart';

import '../../data/repository/markets/markets_repository.dart';
import '../common/base_bloc.dart';
import '../common/screen_state.dart';

part 'put_call_ratio_event.dart';
part 'put_call_ratio_state.dart';

class PutCallRatioBloc extends BaseBloc<PutCallRatioEvent, PutCallRatioState> {
  PutCallRatioBloc() : super(PutCallRatioInitial());

  @override
  Future<void> eventHandlerMethod(
      PutCallRatioEvent event, Emitter<PutCallRatioState> emit) async {
    if (event is PutCallRatioFetchEvent) {
      await _fetchPutCallRatioEvent(event, emit);
    }
  }

  @override
  PutCallRatioState getErrorState() {
    return PutCallRatioErrorState();
  }

  _fetchPutCallRatioEvent(
      PutCallRatioFetchEvent event, Emitter<PutCallRatioState> emit) async {
    emit(PutCallRatioLoadState());
    final BaseRequest request = BaseRequest();
    request.addToData("exc", "NFO");
    request.addToData("filters", [
      {"value": "IDX", "key": "asset"},
      {"value": event.expiry, "key": "expiry"},
      {"value": "10", "key": "limit"}
    ]);

    PutCallRatioModel data = await MarketMoversRepository().getPCR(request);
    emit(PutCallRatioDoneState(data));
  }
}
