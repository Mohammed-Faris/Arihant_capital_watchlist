import '../../../constants/app_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_model.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

import '../../../data/repository/positions/positions_repository.dart';
import '../../../models/positions/positions_model.dart';
import '../../common/base_bloc.dart';
import '../../common/screen_state.dart';

part 'position_convertion_event.dart';
part 'position_convertion_state.dart';

class PositionConvertionBloc
    extends BaseBloc<PositionConvertionEvent, PositionConvertionState> {
  PositionConvertionBloc() : super(PositionConvertionInitial());

  @override
  Future<void> eventHandlerMethod(PositionConvertionEvent event,
      Emitter<PositionConvertionState> emit) async {
    if (event is PostionConvertEvent) {
      await _hanldePositionConvertionEvent(emit, event);
    }
  }

  Future<void> _hanldePositionConvertionEvent(
    Emitter<PositionConvertionState> emit,
    PostionConvertEvent event,
  ) async {
    emit(PositionConvertionProgressState());
    try {
      String toPrdType = event.toPrdType;
      if (toPrdType == AppConstants.carryForward) {
        toPrdType = AppConstants.normal;
      }
      final BaseRequest request = BaseRequest();
      request.addToData('type', event.positions.type);
      request.addToData('ordAction', event.positions.ordAction);
      request.addToData('toPrdType', toPrdType);
      request.addToData(
          'prdType',
          event.positions.prdType!.toLowerCase() ==
                  AppConstants.carryForward.toLowerCase()
              ? AppConstants.normal
              : event.positions.prdType);
      request.addToData('qty', event.qty);
      request.addToData('sym', event.positions.sym);

      BaseModel baseModel =
          await PositionsRepository().getPositionsConversionRequest(request);

      emit(PositionConvertionDataState(baseModel));
    } on ServiceException catch (ex) {
      emit(PositionConvertionServiceExceptionState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
      throw (ServiceException(ex.code, ex.msg));
    } on FailedException catch (ex) {
      emit(PositionConvertionFailedState()
        ..errorCode = ex.code
        ..errorMsg = ex.msg);
    }
  }

  @override
  PositionConvertionState getErrorState() {
    return PositionConvertionErrorState();
  }
}
