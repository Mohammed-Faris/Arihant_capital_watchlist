import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_request.dart';

import '../../../data/repository/quote/quote_repository.dart';
import '../../../models/common/sym_model.dart';
import '../../../models/quote/quote_analysis/pivot_points_model.dart';
import '../../common/base_bloc.dart';
import '../../common/screen_state.dart';

part 'pivot_points_event.dart';
part 'pivot_points_state.dart';

class PivotPointsBloc extends BaseBloc<PivotPointsEvent, PivotPointsState> {
  PivotPointsBloc() : super(PivotPointsInitial());
  @override
  Future<void> eventHandlerMethod(
      PivotPointsEvent event, Emitter<PivotPointsState> emit) async {
    if (event is QuotePivotPointsEvent) {
      await _getPivotPoints(event, emit);
    }
  }

  Future<void> _getPivotPoints(
      QuotePivotPointsEvent event, Emitter<PivotPointsState> emit) async {
    emit(QuotePivotpointsProgressState());

    final BaseRequest request = BaseRequest();
    if (event.time == 'daily') {
      request.addToData('type', 'daily');
    } else if (event.time == 'weekly') {
      request.addToData('type', 'weekly');
    } else {
      request.addToData('type', 'monthly');
    }
    request.addToData('sym', event.sym);
    PivotPoints pivotPoints =
        await QuoteRepository().getQuotePivotPointsRequest(request);
    emit(QuotePivotPointsDoneState()..pivotPoints = pivotPoints);
  }

  @override
  PivotPointsState getErrorState() {
    return QuotePivotPointsErrorState();
  }
}
