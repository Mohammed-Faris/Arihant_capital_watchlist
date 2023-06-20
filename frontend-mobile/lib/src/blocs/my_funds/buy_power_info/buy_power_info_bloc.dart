import '../../../data/store/app_storage.dart';
import '../../../models/my_funds/my_fund_view_updated_model.dart';

import '../../common/screen_state.dart';
import '../../../data/repository/funds/funds_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:msil_library/models/base/base_request.dart';
import 'package:msil_library/utils/exception/failed_exception.dart';
import 'package:msil_library/utils/exception/service_exception.dart';

import '../../common/base_bloc.dart';

part 'buy_power_info_event.dart';
part 'buy_power_info_state.dart';

class BuyPowerInfoBloc extends BaseBloc<BuyPowerInfoEvent, BuyPowerInfoState> {
  BuyPowerInfoBloc() : super(BuyPowerInfoInitial());

  AvailableFundsDoneState availableFundsDoneState = AvailableFundsDoneState();

  @override
  Future<void> eventHandlerMethod(
      BuyPowerInfoEvent event, Emitter<BuyPowerInfoState> emit) async {
    if (event is GetAvailableFundsEvent) {
      await _handleGetAvailableFundsEvent(event, emit);
    }
  }

  Future<void> _handleGetAvailableFundsEvent(
    GetAvailableFundsEvent event,
    Emitter<BuyPowerInfoState> emit,
  ) async {
    if (event.fundViewUpdatedModel != null) {
      emit(availableFundsDoneState
        ..fundViewUpdatedModel = event.fundViewUpdatedModel);
    } else {
      emit(BuyPowerInfoProgressState());
      try {
        final BaseRequest request = BaseRequest();
        request.addToData('segment', ['ALL']);
        FundViewUpdatedModel fundViewUpdatedModel =
            await FundsRepository().getFundViewUpdatedModel(request);
        AppStorage().setData('getFundViewUpdatedModel', fundViewUpdatedModel);

        emit(availableFundsDoneState
          ..fundViewUpdatedModel = fundViewUpdatedModel);
      } on ServiceException catch (ex) {
        emit(BuyPowerInfoFailedState()
          ..errorCode = ex.code
          ..errorMsg = ex.msg);
        throw (ServiceException(ex.code, ex.msg));
      } on FailedException catch (ex) {
        emit(BuyPowerInfoErrorState()
          ..errorCode = ex.code
          ..errorMsg = ex.msg);
      }
    }
  }

  @override
  BuyPowerInfoState getErrorState() {
    return BuyPowerInfoErrorState();
  }
}
