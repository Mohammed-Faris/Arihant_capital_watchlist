import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_request.dart';

import '../../data/repository/market_status/market_status_repository.dart';
import '../../models/common/sym_model.dart';
import '../../models/market_status/market_status_model.dart';
import '../common/base_bloc.dart';
import '../common/screen_state.dart';

part 'market_status_event.dart';
part 'market_status_state.dart';

class MarketStatusBloc extends BaseBloc<MarketStatusEvent, MarketStatusState> {
  MarketStatusBloc() : super(MarketStatusInitial());

  MarketStatusDoneState marketStatusDoneState = MarketStatusDoneState();

  @override
  Future<void> eventHandlerMethod(
      MarketStatusEvent event, Emitter<MarketStatusState> emit) async {
    if (event is GetMarketStatusEvent) {
      await _handleGetMarketStatusEvent(event, emit);
    }
  }

  Future<void> _handleGetMarketStatusEvent(
    GetMarketStatusEvent event,
    Emitter<MarketStatusState> emit,
  ) async {
    emit(MarketStatusProgressState());

    final BaseRequest request = BaseRequest();
    request.addToData('sym', event.sym);

    final MarketStatusModel marketStatusModel =
        await MarketStatusRepository().getMarketStatusRequest(request);

    emit(marketStatusDoneState
      ..isOpen = marketStatusModel.isOpen ?? false
      ..isAmo = (marketStatusModel.isAmo ?? false));
  }

  @override
  MarketStatusState getErrorState() {
    return MarketStatusErrorState();
  }
}
